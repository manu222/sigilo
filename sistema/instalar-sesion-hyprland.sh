#!/usr/bin/env bash
# Añade la sesión «Sigilo (Hyprland)» a lightdm.
#
# Es la misma Hyprland de siempre, pero arrancada con un pequeño lanzador
# (hyprland/sigilo-hyprland) que espera a que lightdm suelte la gráfica.
# Sin él, en el sobremesa con NVIDIA la imagen se quedaba congelada al
# entrar. La entrada «Hyprland» que trae el paquete no se toca: sigue ahí,
# pero conviene elegir siempre la de Sigilo.
#
# Solo añade dos ficheros nuevos; no cambia nada de lo que ya hay.
# Para deshacerlo:
#   sudo rm /usr/local/bin/sigilo-hyprland /usr/share/wayland-sessions/sigilo-hyprland.desktop

set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"

command -v start-hyprland >/dev/null \
    || { echo "  ✗ No está instalado Hyprland (falta start-hyprland). No se ha tocado nada."; exit 1; }

sudo install -Dm755 "$AQUI/hyprland/sigilo-hyprland"         /usr/local/bin/sigilo-hyprland
sudo install -Dm644 "$AQUI/hyprland/sigilo-hyprland.desktop" /usr/share/wayland-sessions/sigilo-hyprland.desktop

echo "Listo. En lightdm elige la sesión «Sigilo (Hyprland)»."
