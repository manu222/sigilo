#!/usr/bin/env bash
# Copias instantáneas del sistema con Timeshift sobre btrfs.
#
#   sudo ~/dotfiles/sistema/instalar-instantaneas.sh
#
# Qué deja montado:
#   · Una copia antes de cada actualización con pacman o yay (se guardan 5).
#   · Copias automáticas: 5 diarias y 3 semanales.
#   · Un submenú en GRUB, «Copias del sistema», para arrancar cualquiera.
#   · Solo se copia el sistema (@). Tu carpeta personal (@home) no se toca
#     ni al copiar ni al restaurar.
#
# Las copias de btrfs no duplican datos: solo ocupa lo que cambia después.
# Todo lo que modifica se guarda antes con la fecha en el nombre.

set -Eeuo pipefail
trap 'echo -e "\n\e[31m✗ Se paró en la línea $LINENO.\e[0m"' ERR

USUARIO="${SUDO_USER:-}"
# Antes ponía «manu» si no había SUDO_USER. Eso solo acierta en mi equipo:
# lanzado desde una shell de root (su -, una consola de rescate) le dejaría
# los ficheros a un usuario que a lo mejor no existe, o a otra persona que
# se llamara igual. Mejor parar y decirlo
FECHA=$(date +%Y%m%d-%H%M%S)
ok()    { echo -e "  \e[32m✓\e[0m $*"; }
aviso() { echo -e "  \e[33m!\e[0m $*"; }
fallo() { echo -e "  \e[31m✗\e[0m $*"; exit 1; }
paso()  { echo -e "\n\e[1;36m── $* ──\e[0m"; }

# ───────────────────────── Comprobaciones ─────────────────────────
paso "Comprobaciones"
[[ $EUID -eq 0 ]] || fallo "Hay que lanzarlo con sudo."
[[ -n "$USUARIO" ]] || fallo "Lánzalo con sudo desde tu sesión, no desde una shell de root: así sé de quién son los ficheros."
[[ "$(findmnt -no FSTYPE /)" == btrfs ]] || fallo "/ no está en btrfs."
SUBVOL=$(findmnt -no OPTIONS / | tr ',' '\n' | sed -n 's/^subvol=//p')
[[ "$SUBVOL" == "/@" ]] || fallo "/ está montado desde «$SUBVOL», y Timeshift necesita «/@»."
btrfs subvolume list / | grep -q ' path @home$' || fallo "No existe el subvolumen @home."
UUID=$(findmnt -no UUID /)
ok "btrfs con @ y @home (UUID $UUID)"
command -v grub-mkconfig >/dev/null || fallo "No encuentro GRUB."
ok "GRUB presente"
LIBRE=$(df --output=avail -BG / | tail -1 | tr -dc 0-9)
(( LIBRE > 15 )) || aviso "Solo quedan ${LIBRE} GB libres en /. Las copias ocupan poco, pero vigílalo."

# ───────────────────────── Paquetes ─────────────────────────
paso "Paquetes"
pacman -S --needed --noconfirm timeshift grub-btrfs inotify-tools cronie
ok "timeshift, grub-btrfs, inotify-tools y cronie"

if ! pacman -Qq timeshift-autosnap >/dev/null 2>&1; then
    if command -v yay >/dev/null; then
        echo "  Instalando timeshift-autosnap desde AUR (puede pedir tu contraseña otra vez)"
        sudo -u "$USUARIO" yay -S --needed --noconfirm timeshift-autosnap
    else
        fallo "Falta yay para instalar timeshift-autosnap desde AUR."
    fi
fi
ok "timeshift-autosnap"

# ───────────────────────── Timeshift ─────────────────────────
paso "Configuración de Timeshift"
mkdir -p /etc/timeshift
[[ -f /etc/timeshift/timeshift.json ]] && cp -a /etc/timeshift/timeshift.json "/etc/timeshift/timeshift.json.antes-$FECHA"
cat > /etc/timeshift/timeshift.json <<JSON
{
  "backup_device_uuid" : "$UUID",
  "parent_device_uuid" : "",
  "do_first_run" : "false",
  "btrfs_mode" : "true",
  "include_btrfs_home_for_backup" : "false",
  "include_btrfs_home_for_restore" : "false",
  "stop_cron_emails" : "true",
  "btrfs_use_qgroup" : "false",
  "schedule_monthly" : "false",
  "schedule_weekly" : "true",
  "schedule_daily" : "true",
  "schedule_hourly" : "false",
  "schedule_boot" : "false",
  "count_monthly" : "2",
  "count_weekly" : "3",
  "count_daily" : "5",
  "count_hourly" : "6",
  "count_boot" : "5",
  "date_format" : "%Y-%m-%d %H:%M:%S",
  "exclude" : [],
  "exclude-apps" : []
}
JSON
ok "5 diarias y 3 semanales, sin tocar @home"

systemctl enable --now cronie.service >/dev/null 2>&1
ok "cronie en marcha (lanza las copias programadas)"

CONF_AUTOSNAP=/etc/timeshift-autosnap.conf
if [[ -f $CONF_AUTOSNAP ]]; then
    cp -a "$CONF_AUTOSNAP" "$CONF_AUTOSNAP.antes-$FECHA"
    sed -i -e 's/^maxSnapshots=.*/maxSnapshots=5/' \
           -e 's/^updateGrub=.*/updateGrub=false/' \
           -e 's/^snapshotDescription=.*/snapshotDescription={timeshift-autosnap} {antes de actualizar}/' "$CONF_AUTOSNAP"
    ok "Copia previa a cada actualización (se guardan las 5 últimas)"
else
    aviso "No encuentro $CONF_AUTOSNAP; se queda con sus valores por defecto"
fi

# ───────────────────────── GRUB ─────────────────────────
paso "Submenú de GRUB"
CONF_GB=/etc/default/grub-btrfs/config
if [[ -f $CONF_GB ]]; then
    cp -a "$CONF_GB" "$CONF_GB.antes-$FECHA"
    if grep -q '^#\?GRUB_BTRFS_SUBMENUNAME=' "$CONF_GB"; then
        sed -i 's|^#\?GRUB_BTRFS_SUBMENUNAME=.*|GRUB_BTRFS_SUBMENUNAME="Copias del sistema"|' "$CONF_GB"
    else
        echo 'GRUB_BTRFS_SUBMENUNAME="Copias del sistema"' >> "$CONF_GB"
    fi
    ok "Submenú: «Copias del sistema»"
fi

# El vigilante de grub-btrfs, apuntando a donde Timeshift deja las copias
mkdir -p /etc/systemd/system/grub-btrfsd.service.d
cat > /etc/systemd/system/grub-btrfsd.service.d/timeshift.conf <<'UNIT'
[Service]
ExecStart=
ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto
UNIT
systemctl daemon-reload
systemctl enable --now grub-btrfsd.service >/dev/null 2>&1
systemctl is-active -q grub-btrfsd.service && ok "grub-btrfsd vigila las copias nuevas" \
                                           || aviso "grub-btrfsd no arrancó (journalctl -u grub-btrfsd)"

# ───────────────────────── Primera copia ─────────────────────────
paso "Primera copia"
timeshift --create --comments "primera copia" --tags O --scripted | sed 's/^/    /'

paso "Regenerando el menú de GRUB"
cp -a /boot/grub/grub.cfg "/boot/grub/grub.cfg.antes-copias-$FECHA"
if ! grub-mkconfig -o /boot/grub/grub.cfg 2>&1 | sed 's/^/    /'; then
    cp -a "/boot/grub/grub.cfg.antes-copias-$FECHA" /boot/grub/grub.cfg
    fallo "grub-mkconfig falló. Menú anterior restaurado."
fi
if ! grep -qi "menuentry 'endeavour" /boot/grub/grub.cfg; then
    cp -a "/boot/grub/grub.cfg.antes-copias-$FECHA" /boot/grub/grub.cfg
    fallo "El menú nuevo no tiene EndeavourOS. Menú anterior restaurado."
fi
ok "EndeavourOS sigue en el menú"
if [[ -s /boot/grub/grub-btrfs.cfg ]] && grep -q "grub-btrfs.cfg" /boot/grub/grub.cfg; then
    ok "Submenú de copias añadido ($(grep -c '^[[:space:]]*menuentry' /boot/grub/grub-btrfs.cfg) entradas)"
else
    aviso "No veo el submenú de copias todavía. Se añadirá con la próxima copia."
fi

paso "Listo"
timeshift --list | sed -n '/^Num/,$p' | sed 's/^/    /'
cat <<'TXT'

  Cómo se usa:
    · Ver copias:            sudo timeshift --list   (o la app Timeshift)
    · Copia a mano:          sudo timeshift --create --comments "lo que sea"
    · Volver atrás:          abre Timeshift, elige la copia y «Restaurar»;
                             reinicia y listo. Tu carpeta personal no cambia.
    · Si el sistema no arranca: en GRUB entra en «Copias del sistema»,
                             arranca la de antes y restaura desde ahí.
TXT
