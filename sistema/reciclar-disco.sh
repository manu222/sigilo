#!/usr/bin/env bash
# Convierte el disco que dejó Windows en un disco de datos para Linux.
#
#   sudo ~/dotfiles/sistema/reciclar-disco.sh            (usa /dev/sda)
#   sudo ~/dotfiles/sistema/reciclar-disco.sh /dev/sdX
#
# Qué hace, en este orden:
#   1. Comprueba que el disco NO es el del sistema y que nada está montado.
#   2. Pide escribir una frase para confirmar. Sin ella no toca nada.
#   3. Quita la entrada de Windows del menú de GRUB (sin borrar el script,
#      solo le quita el permiso de ejecución; se puede deshacer con chmod +x).
#   4. Borra el disco y crea una única partición ext4 con etiqueta "datos".
#   5. La monta en /datos al arrancar (con nofail: si el disco falla,
#      el sistema arranca igual).
#   6. Opcional: quita "Windows Boot Manager" de la lista de arranque de la BIOS.
#   7. Si Ollama está instalado como servicio, le ofrece usar /datos/ollama.

set -Eeuo pipefail
trap 'echo -e "\n\e[31m✗ Se paró en la línea $LINENO. No se ha seguido adelante.\e[0m"' ERR

DISCO="${1:-/dev/sda}"
ETIQUETA="datos"
PUNTO="/datos"
USUARIO="${SUDO_USER:-manu}"

ok()    { echo -e "  \e[32m✓\e[0m $*"; }
aviso() { echo -e "  \e[33m!\e[0m $*"; }
fallo() { echo -e "  \e[31m✗\e[0m $*"; exit 1; }
paso()  { echo -e "\n\e[1;36m── $* ──\e[0m"; }
pregunta() { local r; read -rp "  $1 [s/N] " r; [[ "$r" =~ ^[sS]$ ]]; }

# ───────────────────────── 1. Comprobaciones ─────────────────────────
paso "Comprobaciones"
[[ $EUID -eq 0 ]] || fallo "Hay que lanzarlo con sudo."
[[ -b "$DISCO" ]] || fallo "$DISCO no existe."
[[ "$(lsblk -dno TYPE "$DISCO")" == disk ]] || fallo "$DISCO no es un disco entero."
ok "$DISCO existe y es un disco"

RAIZ_PART=$(findmnt -no SOURCE / | sed 's/\[.*//')
RAIZ_DISCO="/dev/$(lsblk -no PKNAME "$RAIZ_PART" | head -1)"
[[ "$RAIZ_DISCO" != "$DISCO" ]] || fallo "$DISCO es el disco del sistema. Abortado."
ok "El sistema está en $RAIZ_DISCO, no en $DISCO"

EFI_PART=$(findmnt -no SOURCE /boot/efi 2>/dev/null || true)
if [[ -n "$EFI_PART" ]]; then
  EFI_DISCO="/dev/$(lsblk -no PKNAME "$EFI_PART" | head -1)"
  [[ "$EFI_DISCO" != "$DISCO" ]] || fallo "El arranque (/boot/efi) está en $DISCO. Abortado."
  ok "El arranque está en $EFI_DISCO"
fi

if lsblk -nro MOUNTPOINTS "$DISCO" | grep -q .; then
  fallo "Hay algo de $DISCO montado:\n$(lsblk -o NAME,MOUNTPOINTS "$DISCO")"
fi
ok "Nada de $DISCO está montado"

if grep -qs "^[^#]*[[:space:]]$PUNTO[[:space:]]" /etc/fstab; then
  fallo "Ya hay una línea para $PUNTO en /etc/fstab. Revísala antes."
fi

echo
lsblk -o NAME,SIZE,FSTYPE,LABEL,MODEL "$DISCO" | sed 's/^/    /'
if ! lsblk -nro FSTYPE "$DISCO" | grep -qiE 'bitlocker|ntfs'; then
  aviso "No veo restos de Windows en $DISCO. Asegúrate de que es el disco correcto."
fi

# ───────────────────────── 2. Confirmación ─────────────────────────
NOMBRE=$(basename "$DISCO")
echo -e "\n  \e[1;31mTodo lo que hay en $DISCO se va a perder y no se puede recuperar.\e[0m"
read -rp "  Para seguir escribe exactamente «borrar $NOMBRE»: " FRASE
[[ "$FRASE" == "borrar $NOMBRE" ]] || { echo "  No coincide. No se ha tocado nada."; exit 0; }

# ───────────────────────── 3. Menú de GRUB ─────────────────────────
paso "Menú de arranque"
ENTRADA=/etc/grub.d/45_eos_windows
if [[ -x "$ENTRADA" ]]; then
  chmod -x "$ENTRADA"
  ok "Desactivado $ENTRADA (se reactiva con: sudo chmod +x $ENTRADA)"
else
  ok "La entrada de Windows ya estaba desactivada o no existe"
fi

# ───────────────────────── 4. Borrado y partición ─────────────────────────
paso "Borrando $DISCO"
for p in $(lsblk -nrpo NAME "$DISCO" | tail -n +2); do wipefs -aq "$p" || true; done
wipefs -aq "$DISCO"
ok "Firmas borradas"

sfdisk -q --wipe always "$DISCO" <<< $'label: gpt\n,,L'
udevadm settle
PART=$(lsblk -nrpo NAME "$DISCO" | sed -n 2p)
[[ -b "$PART" ]] || fallo "No aparece la partición nueva."
ok "Tabla GPT con una partición: $PART"

mkfs.ext4 -q -F -L "$ETIQUETA" -m 0 "$PART"
udevadm settle
UUID=$(blkid -s UUID -o value "$PART")
[[ -n "$UUID" ]] || fallo "No se pudo leer el UUID de $PART."
ok "Formateado en ext4, etiqueta «$ETIQUETA», UUID $UUID"

# ───────────────────────── 5. Montaje automático ─────────────────────────
paso "Montaje en $PUNTO"
RESPALDO_FSTAB="/etc/fstab.antes-de-datos-$(date +%Y%m%d-%H%M%S)"
cp -a /etc/fstab "$RESPALDO_FSTAB"
ok "Copia de fstab en $RESPALDO_FSTAB"

mkdir -p "$PUNTO"
printf '\n# Disco de datos (el antiguo de Windows)\nUUID=%s  %s  ext4  defaults,noatime,nofail,x-systemd.device-timeout=10s  0 2\n' \
  "$UUID" "$PUNTO" >> /etc/fstab
systemctl daemon-reload

if ! mount "$PUNTO"; then
  cp -a "$RESPALDO_FSTAB" /etc/fstab
  systemctl daemon-reload
  fallo "No se pudo montar. He devuelto fstab a como estaba."
fi
findmnt "$PUNTO" >/dev/null || fallo "$PUNTO no aparece montado."
ok "Montado en $PUNTO y apuntado en fstab"

chown "$USUARIO:$USUARIO" "$PUNTO"
ok "$PUNTO pertenece a $USUARIO"

CASA=$(getent passwd "$USUARIO" | cut -d: -f6)
MARCADORES="$CASA/.config/gtk-3.0/bookmarks"
if [[ -d "$(dirname "$MARCADORES")" ]] && ! grep -qs "file://$PUNTO " "$MARCADORES"; then
  echo "file://$PUNTO Datos" >> "$MARCADORES"
  chown "$USUARIO:$USUARIO" "$MARCADORES"
  ok "Añadido «Datos» a la barra lateral del gestor de archivos"
fi

# ───────────────────────── 6. Lista de arranque de la BIOS ─────────────────────────
paso "Lista de arranque de la BIOS"
if command -v efibootmgr >/dev/null && [[ -d /sys/firmware/efi ]]; then
  mapfile -t WIN < <(efibootmgr | grep -i 'Windows Boot Manager' | sed -nE 's/^Boot([0-9A-Fa-f]{4}).*/\1/p')
  if (( ${#WIN[@]} )); then
    efibootmgr | grep -E '^Boot(Current|Order)|Windows|endeavour' -i | sed 's/^/    /'
    if pregunta "¿Quito ${#WIN[@]} entrada(s) de Windows Boot Manager? EndeavourOS no se toca."; then
      for n in "${WIN[@]}"; do efibootmgr -q -b "$n" -B && ok "Quitada Boot$n"; done
    else
      aviso "Se dejan como están"
    fi
  else
    ok "No hay entradas de Windows"
  fi
else
  aviso "efibootmgr no disponible; se omite"
fi

# ───────────────────────── 7. Ollama ─────────────────────────
if systemctl cat ollama.service >/dev/null 2>&1; then
  paso "Ollama"
  if pregunta "¿Guardo los modelos de Ollama en $PUNTO/ollama a partir de ahora?"; then
    DUENO=$(systemctl show -p User --value ollama.service); DUENO=${DUENO:-ollama}
    ANTES=$(systemctl show -p Environment --value ollama.service | tr ' ' '\n' | sed -n 's/^OLLAMA_MODELS=//p')
    ANTES=${ANTES:-/var/lib/ollama}
    mkdir -p "$PUNTO/ollama"
    systemctl stop ollama.service || true
    if [[ -d "$ANTES" ]] && [[ -n "$(ls -A "$ANTES" 2>/dev/null)" ]]; then
      cp -a "$ANTES/." "$PUNTO/ollama/"
      ok "Copiado lo que había en $ANTES (el original se queda; bórralo cuando compruebes que va)"
    fi
    chown -R "$DUENO:" "$PUNTO/ollama" 2>/dev/null || true
    mkdir -p /etc/systemd/system/ollama.service.d
    printf '[Service]\nEnvironment="OLLAMA_MODELS=%s/ollama"\n' "$PUNTO" \
      > /etc/systemd/system/ollama.service.d/modelos.conf
    # Espera al disco antes de arrancar
    printf '[Unit]\nRequiresMountsFor=%s\n' "$PUNTO" \
      > /etc/systemd/system/ollama.service.d/disco.conf
    systemctl daemon-reload
    systemctl start ollama.service && ok "Ollama usa ahora $PUNTO/ollama"
  fi
fi

# ───────────────────────── Menú de GRUB regenerado ─────────────────────────
paso "Regenerando el menú de GRUB"
cp -a /boot/grub/grub.cfg "/boot/grub/grub.cfg.antes-de-datos"
grub-mkconfig -o /boot/grub/grub.cfg 2>&1 | sed 's/^/    /'
if grep -qi "menuentry 'endeavour" /boot/grub/grub.cfg; then
  ok "EndeavourOS sigue en el menú"
else
  cp -a /boot/grub/grub.cfg.antes-de-datos /boot/grub/grub.cfg
  fallo "El menú nuevo no tiene EndeavourOS. He restaurado el anterior."
fi
if grep -qi 'windows' /boot/grub/grub.cfg; then
  aviso "Todavía aparece algo de Windows en grub.cfg:"
  grep -ni 'windows' /boot/grub/grub.cfg | sed 's/^/    /'
else
  ok "Windows ya no aparece en el menú"
fi

paso "Listo"
df -h "$PUNTO" | sed 's/^/    /'
echo "  Si algo raro pasa, fstab anterior: $RESPALDO_FSTAB"
