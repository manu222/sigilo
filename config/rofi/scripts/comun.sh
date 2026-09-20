# Funciones compartidas por los menus. No se ejecuta suelto.
esc() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }
MINT="#3ee8a8"; DIM="#94a3a0"; MUTE="#70837c"; AMBER="#c99d6b"
CYAN="#6fc9c0"; VIOLET="#b79ad4"; SLATE="#8aa9c4"; RED="#e0777d"

# Los iconos hay que pedirlos con la variante Mono de la fuente. La normal
# dibuja los glifos mas anchos que una celda y Pango los recorta.
NF='JetBrainsMono Nerd Font Mono'
icono() {   # $1 glifo  $2 color  $3 tamano en puntos (por defecto 13)
    printf '<span font_family="%s" foreground="%s" size="%d">%s</span>' \
           "$NF" "$2" "$(( ${3:-13} * 1024 ))" "$1"
}
pie() {     # texto de ayuda al pie de la ventana
    printf -- '-mesg'; printf '\0'; printf '<span foreground="%s">%s</span>' "$MUTE" "$1"
}
