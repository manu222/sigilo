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

# ~/.local/bin en el PATH de la sesión gráfica (herramientas de pipx)
grep -qs '.local/bin' "$HOME/.xprofile" || \
    printf '# Herramientas instaladas para el usuario (pipx)\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.xprofile"

# Accesos propios: el visor de imágenes como programa por defecto
mkdir -p "$HOME/.local/share/applications"
cp -a "$REPO"/extra/aplicaciones/*.desktop "$HOME/.local/share/applications/" 2>/dev/null
command -v xdg-mime >/dev/null && for t in png jpeg webp gif bmp tiff avif heic svg+xml; do
    xdg-mime default sigilo-imagenes.desktop "image/$t"
done

# Tema de iconos (necesita papirus-icon-theme; si aún no está, se avisa)
python3 "$REPO/extra/iconos-sigilo.py" 2>/dev/null \
    || echo "Iconos: instala papirus-icon-theme y lanza  python3 $REPO/extra/iconos-sigilo.py"

# Tema de VS Code, si está instalado (si no, se puede lanzar más tarde)
if command -v code >/dev/null || command -v codium >/dev/null; then
    "$REPO/vscode/instalar-tema" || true
else
    echo "VS Code: cuando lo instales, lanza  $REPO/vscode/instalar-tema"
fi

echo
echo "Hecho. Faltan los paquetes:"
echo "    sudo pacman -S --needed - < $REPO/paquetes-oficiales.txt"
echo "    yay -S --needed - < $REPO/paquetes-aur.txt"
echo
echo "Y una línea en tu ~/.bashrc:"
echo "    [ -f ~/.config/sigilo-shell.sh ] && . ~/.config/sigilo-shell.sh"
