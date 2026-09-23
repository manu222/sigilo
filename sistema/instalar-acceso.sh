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
#
# El fondo va en /var/lib/sigilo/acceso.jpg, una carpeta fuera de /home que
# la pantalla de acceso sí puede leer.
#
# Esa carpeta es de root a propósito, y solo escribe aquí este script. Antes
# era tuya, para que el script «fondo» pudiera ir actualizando la copia cada
# vez que cambiabas el fondo del escritorio; la comodidad estaba bien, pero
# significaba que un fichero que puede cambiar cualquier programa tuyo se lo
# come el greeter antes de que nadie haya puesto su contraseña. Para cambiar
# el fondo de la pantalla de acceso, relanza este script.

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
# El del escritorio sale de ~/.config/sigilo/fondo-actual. Si es un vídeo
# se usa su fotograma fijo, y si es webp/avif se convierte a png: la
# pantalla de acceso solo lee png y jpg.
if [ $# -ge 1 ]; then
    FONDO="$1"
else
    FONDO=$(cat "$HOME/.config/sigilo/fondo-actual" 2>/dev/null)
    [ -z "$FONDO" ] && FONDO=$(grep -oP "feh --bg-fill '?\K[^']+" "$HOME/.fehbg" 2>/dev/null | head -1)
fi
[ -f "$FONDO" ] || para "No encuentro la imagen de fondo: $FONDO"
TMP_FONDO=""; TMP_ACCESO=""
# Si el script se corta a medias, que no se queden las copias en /tmp
# Con ${x:-} porque el script puede salirse antes de que estas existan, y
# «set -u» se quejaría desde dentro del propio trap. El «true» del final deja
# el código de salida tal y como venía
trap 'rm -f "${TMP_FONDO:-}"; [ "${TMP_ACCESO:-}" != "${FONDO:-}" ] && rm -f "${TMP_ACCESO:-}"; true' EXIT
case "${FONDO,,}" in
    *.mp4|*.webm|*.mkv|*.mov|*.gif)
        CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/fondos-miniaturas"
        FOTO="$CACHE/$(printf '%s' "$FONDO" | md5sum | cut -c1-16)-fondo.png"
        if [ ! -f "$FOTO" ]; then
            command -v ffmpeg >/dev/null || para "Hace falta ffmpeg para sacar un fotograma del vídeo"
            mkdir -p "$CACHE"; ffmpeg -loglevel error -y -ss 1 -i "$FONDO" -frames:v 1 "$FOTO"
        fi
        echo "  · el fondo es un vídeo: se usa un fotograma"
        FONDO="$FOTO" ;;
    *.png|*.jpg|*.jpeg) ;;
    *)
        command -v magick >/dev/null || para "Hace falta imagemagick para convertir el fondo a png"
        TMP_FONDO=$(mktemp --suffix=.png); magick "$FONDO" "$TMP_FONDO"
        echo "  · el fondo se ha convertido a png"
        FONDO="$TMP_FONDO" ;;
esac
EXT="${FONDO##*.}"; EXT="${EXT,,}"
echo "  ✓ fondo: $(basename "$FONDO")"

# 4. copia de seguridad
RESPALDO=""
if [ -f "$DEST" ]; then
    RESPALDO="$DEST.antes-de-sigilo-$(date +%Y%m%d-%H%M%S)"
    sudo cp -a "$DEST" "$RESPALDO"
    echo "  ✓ copia de la configuración anterior: $RESPALDO"
fi

# 5. instalar
ACCESO=/var/lib/sigilo
sudo install -d -o root -g root -m 755 "$ACCESO"
# La imagen se prepara con tu usuario y la deja root en su sitio: así la
# carpeta no tiene que ser escribible por nadie más que root
if command -v magick >/dev/null; then
    TMP_ACCESO=$(mktemp --suffix=.jpg)
    magick "$FONDO" -resize 1920x1080^ -gravity center -extent 1920x1080 -quality 90 "$TMP_ACCESO"
else
    TMP_ACCESO="$FONDO"
fi
sudo install -m 644 -o root -g root "$TMP_ACCESO" "$ACCESO/acceso.jpg"
sudo install -Dm644 "$SELLO" "$FONDOS/sigilo-sello.png"
sed "s|@FONDO@|$ACCESO/acceso.jpg|" "$CONF" | sudo tee "$DEST" >/dev/null
sudo chmod 644 "$DEST"
echo "  ✓ instalado"

echo
echo "Listo. Lo verás la próxima vez que cierres sesión o reinicies."
if [ -n "$RESPALDO" ]; then
    echo
    echo "Para deshacerlo:"
    echo "  sudo cp '$RESPALDO' $DEST"
fi
