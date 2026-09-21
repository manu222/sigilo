#!/usr/bin/env bash
# Ajustes de rendimiento y consumo. Todo es reversible y se guarda copia
# de lo que se toca.
#
#   sudo ~/dotfiles/sistema/optimizar.sh
#
# Qué hace:
#   1. zram: swap comprimida en RAM (la mitad de la memoria, con zstd). El
#      fichero de swap del disco se queda como reserva, con menos prioridad.
#   2. Memoria: el kernel usa antes la zram y conserva más la caché de disco.
#   3. Energía: perfil «equilibrado» enchufado y «ahorro» con batería, solo.
#   4. GRUB: el menú espera 2 s en vez de 5.
#   5. Limpieza semanal de la caché de pacman (deja las 2 últimas versiones).
#
# No toca ningún servicio: impresión, wifi, bluetooth y demás siguen igual.

set -Eeuo pipefail
trap 'echo -e "\n\e[31m✗ Se paró en la línea $LINENO.\e[0m"' ERR
FECHA=$(date +%Y%m%d-%H%M%S)
ok()   { echo -e "  \e[32m✓\e[0m $*"; }
paso() { echo -e "\n\e[1;36m── $* ──\e[0m"; }
guardar() { [ -e "$1" ] && cp -a "$1" "$1.antes-optimizar-$FECHA" || true; }
[[ $EUID -eq 0 ]] || { echo "Hay que lanzarlo con sudo."; exit 1; }

# ── 1. zram ──────────────────────────────────────────────────
paso "zram"
pacman -S --needed --noconfirm zram-generator >/dev/null
guardar /etc/systemd/zram-generator.conf
cat > /etc/systemd/zram-generator.conf <<'CONF'
# Swap comprimida en RAM. Con zstd, lo que se manda aquí ocupa entre un
# tercio y la mitad, así que es como tener más memoria sin tocar el disco.
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
CONF
systemctl daemon-reload
systemctl restart systemd-zram-setup@zram0.service
swapon --show=NAME,SIZE,PRIO | sed 's/^/    /'
ok "zram activa; el fichero de swap queda de reserva"

# ── 2. memoria ───────────────────────────────────────────────
paso "Memoria"
guardar /etc/sysctl.d/90-sigilo.conf
cat > /etc/sysctl.d/90-sigilo.conf <<'CONF'
# Con zram, mandar a swap es barato (se queda en RAM comprimido), así que
# conviene hacerlo antes y dejar sitio a la caché de disco.
vm.swappiness = 150
# zram no gana nada leyendo páginas de más de golpe
vm.page-cluster = 0
# Conserva más tiempo en caché las carpetas y ficheros usados
vm.vfs_cache_pressure = 50
CONF
sysctl -q --system
ok "swappiness $(sysctl -n vm.swappiness), cache_pressure $(sysctl -n vm.vfs_cache_pressure)"

# ── 3. energía ───────────────────────────────────────────────
paso "Energía"
guardar /etc/udev/rules.d/90-sigilo-energia.rules
cat > /etc/udev/rules.d/90-sigilo-energia.rules <<'CONF'
# Enchufado: equilibrado (sube la frecuencia en cuanto hace falta).
# Con batería: ahorro. Se cambia solo al enchufar o desenchufar.
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set power-saver"
CONF
udevadm control --reload
udevadm trigger --subsystem-match=power_supply --action=change
sleep 1
ok "perfil actual: $(powerprofilesctl get)  (rendimiento, cuando lo quieras: powerprofilesctl set performance)"

# ── 4. GRUB ──────────────────────────────────────────────────
paso "GRUB"
ANTES=$(sed -n 's/^GRUB_TIMEOUT=//p' /etc/default/grub | tr -d '"'"'")
if [ "$ANTES" != 2 ]; then
    guardar /etc/default/grub
    cp -a /boot/grub/grub.cfg "/boot/grub/grub.cfg.antes-optimizar-$FECHA"
    sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>&1
    if grep -qi "menuentry 'endeavour" /boot/grub/grub.cfg; then
        ok "espera del menú: ${ANTES} s → 2 s"
    else
        cp -a "/etc/default/grub.antes-optimizar-$FECHA" /etc/default/grub
        cp -a "/boot/grub/grub.cfg.antes-optimizar-$FECHA" /boot/grub/grub.cfg
        echo "  ✗ El menú nuevo no tenía EndeavourOS; se ha dejado como estaba."
    fi
else
    ok "ya estaba en 2 s"
fi

# ── 5. caché de pacman ───────────────────────────────────────
paso "Caché de pacman"
systemctl enable --now paccache.timer >/dev/null 2>&1
ok "limpieza semanal activada ($(du -sh /var/cache/pacman/pkg | cut -f1) ahora mismo)"

paso "Listo"
echo "  Reinicia cuando puedas para notar el arranque más corto."
