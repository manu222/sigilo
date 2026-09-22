# Funciones y colores que comparten todos los menús de rofi.
# No se ejecuta suelto: cada script lo carga con «. comun.sh».

# Escapa &, < y > para que rofi (que pinta con marcado Pango) no se líe
# con nombres de redes, canciones o ventanas que los lleven.
esc() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }
# Paleta Sigilo, la misma de la barra y el resto del escritorio
MINT="#3ee8a8"; DIM="#94a3a0"; MUTE="#70837c"; AMBER="#c99d6b"
CYAN="#6fc9c0"; VIOLET="#b79ad4"; SLATE="#8aa9c4"; RED="#e0777d"

# Los iconos hay que pedirlos con la variante Mono de la fuente. La normal
# dibuja los glifos mas anchos que una celda y Pango los recorta.
NF='JetBrainsMono Nerd Font Mono'
icono() {   # $1 glifo  $2 color  $3 tamano en puntos (por defecto 13)
    printf '<span font_family="%s" foreground="%s" size="%d">%s</span>' \
           "$NF" "$2" "$(( ${3:-13} * 1024 ))" "$1"
}
# ¿Estamos en Hyprland o en i3? Los menús son los mismos en las dos
# sesiones; solo cambia cómo se habla con el gestor de ventanas y con el
# portapapeles.
en_hyprland() { [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; }

# Copia lo que llegue por la entrada al portapapeles de la sesión
copiar() {
    if [ -n "${WAYLAND_DISPLAY:-}" ]; then wl-copy "$@"; else xclip -selection clipboard "$@"; fi
}

# Abre un archivo o carpeta con su programa, desenganchado del menú (si no,
# al cerrarse rofi se lo puede llevar por delante). Prueba primero gio,
# que respeta ~/.config/mimeapps.list igual en las dos sesiones, y si no,
# xdg-open. Si ninguno sabe con qué abrirlo, lo dice en vez de callarse.
abrir() {
    local log="${XDG_CACHE_HOME:-$HOME/.cache}/abrir.log"
    setsid -f sh -c '
        { command -v gio >/dev/null && gio open "$1"; } || xdg-open "$1" || {
            notify-send -a Archivos -i dialog-warning "No sé con qué abrirlo" "$1"; exit 1; }
    ' abrir "$1" >>"$log" 2>&1
}

pie() {     # texto de ayuda al pie de la ventana
    printf -- '-mesg'; printf '\0'; printf '<span foreground="%s">%s</span>' "$MUTE" "$1"
}
