# Extras de shell para Manu - se carga desde ~/.bashrc
# Quitar la linea del .bashrc deja el sistema como estaba.

# ── prompt ──────────────────────────────────────────────────────────────────
command -v starship >/dev/null && eval "$(starship init bash)"

# ── listados ────────────────────────────────────────────────────────────────
if command -v eza >/dev/null; then
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -lh  --group-directories-first --icons=auto --git'
    alias la='eza -lah --group-directories-first --icons=auto --git'
    alias lt='eza --tree --level=2 --icons=auto'
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -lh'
    alias la='ls -lah'
fi

# ── atajos de siempre ───────────────────────────────────────────────────────
alias grep='grep --color=auto'
alias df='df -h'
alias free='free -h'
alias ..='cd ..'
alias ...='cd ../..'
alias please='sudo $(history -p !!)'

# bat es un cat con resaltado de sintaxis; se llama asi en Arch
command -v bat >/dev/null && export BAT_THEME="Sigilo"

# ── colores de ls a juego con Sigilo ────────────────────────────────────────
export LS_COLORS='di=1;38;2;62;232;168:ln=38;2;111;201;192:ex=38;2;184;201;160:so=38;2;183;154;212:pi=38;2;201;157;107:bd=38;2;138;169;196:cd=38;2;138;169;196:or=38;2;224;119;125'

# ── man con color ───────────────────────────────────────────────────────────
export LESS='-R'
export MANROFFOPT='-P -c'
export LESS_TERMCAP_md=$'\e[1;38;2;52;211;153m'   # titulos
export LESS_TERMCAP_us=$'\e[3;38;2;201;157;107m'  # cursiva
export LESS_TERMCAP_so=$'\e[1;38;2;7;11;9;48;2;52;211;153m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'

# ── ficha del sistema al abrir un terminal ──────────────────────────────────
# Si te estorba, comenta las dos lineas de abajo.
[[ $- == *i* ]] && [ -z "$SIGILO_FETCH" ] && command -v fastfetch >/dev/null \
    && { export SIGILO_FETCH=1; fastfetch; }
