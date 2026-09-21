#!/usr/bin/env bash
# Viste la pantalla de inicio de sesion con el tema Sigilo.
#
# Solo cambia el aspecto del programa que ya tienes (slick-greeter). No
# cambia de programa: eso es lo que puede dejarte sin entrar por interfaz
# grafica, y no merece el riesgo para un cambio estetico.
#
# Uso:
#   ./instalar-acceso.sh              usa el fondo que tengas en el escritorio
#   ./instalar-acceso.sh imagen.jpg   usa otra imagen
#
# Guarda copia de la configuracion anterior y al final dice como deshacerlo.

set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
CONF="$AQUI/lightdm/slick-greeter.conf"
SELLO="$AQUI/lightdm/sello.png"
DEST=/etc/lightdm/slick-greeter.conf
FONDOS=/usr/share/backgrounds

para() { echo; echo "  ✗ $*"; echo "  No se ha tocado nada."; exit 1; }

echo "Comprobando el sistema..."

# 1. lightdm tiene que ser el gestor de acceso activo
systemctl is-enabled lightdm >/dev/null 2>&1 \
    || para "lightdm no es tu gestor de acceso. Este script es solo para lightdm."

# 2. y slick-greeter la pantalla que usa
pacman -Qq lightdm-slick-greeter >/dev/null 2>&1 \
    || para "No tienes instalado lightdm-slick-greeter."
greeter=$(grep -hE '^[[:space:]]*greeter-session[[:space:]]*=' \
            /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.d/*.conf 2>/dev/null \
          | tail -1 | cut -d= -f2 | tr -d '[:space:]')
if [ -n "$greeter" ] && [ "$greeter" != "lightdm-slick-greeter" ]; then
    para "Tu pantalla de acceso es '$greeter', no slick-greeter. No la cambio por seguridad."
fi
echo "  ✓ lightdm con slick-greeter"

# 3. el fondo
if [ $# -ge 1 ]; then
    FONDO="$1"
else
    FONDO=$(grep -oP "feh --bg-fill '?\K[^']+" "$HOME/.config/i3/config" | head -1)
    FONDO="${FONDO/#\~/$HOME}"
fi
[ -f "$FONDO" ] || para "No encuentro la imagen de fondo: $FONDO"
EXT="${FONDO##*.}"; EXT="${EXT,,}"
case "$EXT" in png|jpg|jpeg) ;; *) para "El fondo tiene que ser png o jpg (es .$EXT)";; esac
echo "  ✓ fondo: $(basename "$FONDO")"

# 4. copia de seguridad
RESPALDO=""
if [ -f "$DEST" ]; then
    RESPALDO="$DEST.antes-de-sigilo-$(date +%Y%m%d-%H%M%S)"
    sudo cp -a "$DEST" "$RESPALDO"
    echo "  ✓ copia de la configuración anterior: $RESPALDO"
fi

# 5. instalar
sudo install -Dm644 "$FONDO" "$FONDOS/sigilo-acceso.$EXT"
sudo install -Dm644 "$SELLO" "$FONDOS/sigilo-sello.png"
sed "s|@FONDO@|$FONDOS/sigilo-acceso.$EXT|" "$CONF" | sudo tee "$DEST" >/dev/null
sudo chmod 644 "$DEST"
echo "  ✓ instalado"

echo
echo "Listo. Lo verás la próxima vez que cierres sesión o reinicies."
if [ -n "$RESPALDO" ]; then
    echo
    echo "Para deshacerlo:"
    echo "  sudo cp '$RESPALDO' $DEST"
fi
