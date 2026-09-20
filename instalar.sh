#!/usr/bin/env bash
# Instala esta configuración en un equipo nuevo.
#
# Hace copia de seguridad de lo que ya hubiera antes de pisar nada: si algo
# no te convence, lo tienes en ~/.config-respaldo-<fecha>.

set -uo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
ORIGEN="$REPO/config"
DESTINO="$HOME/.config"
RESPALDO="$HOME/.config-respaldo-$(date +%Y%m%d-%H%M%S)"

[ -d "$ORIGEN" ] || { echo "No encuentro $ORIGEN"; exit 1; }

echo "Se va a instalar la configuración en $DESTINO"
echo "Lo que ya exista se guarda antes en $RESPALDO"
read -rp "¿Seguimos? [s/N] " r
[[ "$r" =~ ^[sSyY]$ ]] || exit 0

mkdir -p "$RESPALDO"
while IFS= read -r -d '' ruta; do
    rel="${ruta#$ORIGEN/}"
    actual="$DESTINO/$rel"
    if [ -e "$actual" ]; then
        mkdir -p "$RESPALDO/$(dirname "$rel")"
        cp -a "$actual" "$RESPALDO/$rel"
    fi
    mkdir -p "$(dirname "$actual")"
    cp -a "$ruta" "$actual"
done < <(find "$ORIGEN" -type f -print0)

chmod +x "$DESTINO"/i3/scripts/* "$DESTINO"/polybar/scripts/* \
         "$DESTINO"/polybar/launch.sh "$DESTINO"/rofi/scripts/* 2>/dev/null || true

echo
echo "Hecho. Faltan los paquetes:"
echo "    sudo pacman -S --needed - < $REPO/paquetes-oficiales.txt"
echo "    yay -S --needed - < $REPO/paquetes-aur.txt"
echo
echo "Y una línea en tu ~/.bashrc:"
echo "    [ -f ~/.config/sigilo-shell.sh ] && . ~/.config/sigilo-shell.sh"
