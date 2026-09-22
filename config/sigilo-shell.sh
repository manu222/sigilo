# ─────────────────────────────────────────────────────────────
#  Extras de shell · Sigilo
#  Se carga desde ~/.bashrc. Quitar esa línea deja bash de serie.
#  «comandos» enseña todo lo que hay aquí.
# ─────────────────────────────────────────────────────────────

[[ $- == *i* ]] || return 0
# Programas instalados para el usuario (pipx, uv tool, scripts propios)
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac

_hay() { command -v "$1" >/dev/null 2>&1; }

# ── Historial ────────────────────────────────────────────────
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE='ls:ll:la:cd:pwd:exit:clear:history'
shopt -s histappend cmdhist autocd cdspell dirspell globstar 2>/dev/null

# ── Colores por tipo de fichero ──────────────────────────────
# Cada familia tiene su color, y eza pinta el icono igual que el nombre.
_rgb() { printf '38;2;%d;%d;%d' "0x${1:1:2}" "0x${1:3:2}" "0x${1:5:2}"; }
_sigilo_ls_colors() {
    local -a grupos=(
        "#9bbad6|py pyi ipynb c h cpp hpp cc cs lua"
        "#dcae76|js mjs cjs ts tsx jsx sql"
        "#b8c9a0|sh bash zsh fish ps1 bat nix"
        "#6fc9c0|go json jsonc yaml yml toml ini conf cfg rasi xml csv tsv env lock"
        "#f08b91|html htm java kt rb php"
        "#c8aae5|css scss sass png jpg jpeg webp gif svg ico bmp avif heic xcf kra"
        "#b79ad4|mp3 flac ogg opus wav m4a aac"
        "#d9a0c4|mp4 mkv webm avi mov m4v"
        "#e7edea|md markdown txt rst org tex"
        "#8aa9c4|pdf doc docx odt xls xlsx ods ppt pptx odp epub"
        "#c99d6b|zip tar gz tgz xz zst bz2 7z rar iso img deb rpm AppImage"
        "#e0777d|pem key crt cer csr p12 pfx gpg asc sig kdbx ovpn"
        "#dcae76|pcap pcapng evtx etl dmp"
        "#556760|log bak tmp swp old orig cache part"
    )
    local g hex e out=""
    for g in "${grupos[@]}"; do
        hex=${g%%|*}
        for e in ${g#*|}; do out+="*.${e}=$(_rgb "$hex"):"; done
    done
    printf 'di=1;%s:ln=3;%s:ex=1;%s:so=%s:pi=%s:bd=%s:cd=%s:or=%s:mi=%s:%s' \
        "$(_rgb '#3ee8a8')" "$(_rgb '#6fc9c0')" "$(_rgb '#b8c9a0')" \
        "$(_rgb '#b79ad4')" "$(_rgb '#c99d6b')" "$(_rgb '#8aa9c4')" \
        "$(_rgb '#8aa9c4')" "$(_rgb '#e0777d')" "$(_rgb '#e0777d')" "$out"
}
export LS_COLORS="$(_sigilo_ls_colors)"

# Columnas de eza -l: fecha en lila apagado, permisos por tipo, git en color
export EZA_COLORS="\
da=$(_rgb '#8f7fb0'):uu=$(_rgb '#34d399'):un=$(_rgb '#c99d6b'):\
gu=$(_rgb '#6fc9c0'):gn=$(_rgb '#94a3a0'):\
sn=$(_rgb '#8fd4b5'):sb=$(_rgb '#556760'):\
ur=$(_rgb '#94a3a0'):gr=$(_rgb '#94a3a0'):tr=$(_rgb '#94a3a0'):\
uw=$(_rgb '#c99d6b'):gw=$(_rgb '#c99d6b'):tw=$(_rgb '#c99d6b'):\
ux=1;$(_rgb '#34d399'):ue=1;$(_rgb '#34d399'):gx=$(_rgb '#34d399'):tx=$(_rgb '#34d399'):\
xx=$(_rgb '#3a4a44'):xa=$(_rgb '#556760'):hd=4;$(_rgb '#94a3a0'):\
ga=$(_rgb '#34d399'):gm=$(_rgb '#c99d6b'):gd=$(_rgb '#e0777d'):gv=$(_rgb '#6fc9c0'):gt=$(_rgb '#b79ad4'):\
lp=$(_rgb '#6fc9c0'):bO=$(_rgb '#e0777d')"

# ── Listados ─────────────────────────────────────────────────
if _hay eza; then
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -lh  --group-directories-first --icons=auto --git --time-style=relative'
    alias la='eza -lah --group-directories-first --icons=auto --git --time-style=relative'
    # Árbol completo, hasta el último fichero. Se saltan solo las carpetas
    # que nunca quieres ver enteras (.git, node_modules, entornos de Python,
    # cachés). Con un número delante se corta a esa profundidad:
    #   lt              todo el árbol de la carpeta actual
    #   lt 2            solo dos niveles
    #   lt 3 ~/dotfiles tres niveles de otra carpeta
    #   lt -a           también los ocultos (cualquier opción de eza vale)
    # Si el árbol es más largo que la ventana se abre para desplazarse
    # con las flechas o la rueda, / para buscar y q para salir.
    # Si ya existía un alias «lt» (de una versión anterior o al recargar
    # este fichero), bash lo sustituiría al definir la función y daría un
    # error de sintaxis. Se quita antes.
    unalias lt ltt 2>/dev/null
    function lt {
        local nivel=()
        [[ $1 =~ ^[0-9]+$ ]] && { nivel=(--level="$1"); shift; }
        local orden=(eza --tree --group-directories-first "${nivel[@]}"
            -I '.git|node_modules|__pycache__|.venv|venv|.cache|.mypy_cache|.pytest_cache|target|dist')
        if [[ -t 1 ]]; then
            # En pantalla: si el árbol no cabe se abre en less para poder
            # subir y bajar (q para salir); si cabe, sale tal cual (-F)
            "${orden[@]}" --icons=always --color=always "$@" | less -RFX
        else
            # Hacia un fichero o una tubería: texto normal
            "${orden[@]}" --icons=auto "$@"
        fi
    }
    alias ltt='lt 2'
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -lh'
    alias la='ls -lah'
fi

# ── De siempre ───────────────────────────────────────────────
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias please='sudo $(history -p !!)'
alias recargar='source ~/.bashrc && echo "shell recargada"'
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

_hay bat && { export BAT_THEME="Sigilo"; alias cat='bat --paging=never --style=plain'; }

# ── man con color ────────────────────────────────────────────
export LESS='-R --mouse'
# Los iconos de Nerd Font viven en la zona de uso privado de Unicode, y less
# pinta como «<U+E5FF>» todo lo que no da por imprimible. Por eso los árboles
# de «lt» (que pasan por less) salían con cuadraditos mientras que «ls», que
# no usa paginador, se veía bien. Con esto se le dice que esas tres zonas son
# texto normal y se dibujan.
export LESSUTFCHARDEF='E000-F8FF:p,F0000-FFFFD:p,100000-10FFFD:p'
export MANROFFOPT='-P -c'
export LESS_TERMCAP_md=$'\e[1;38;2;52;211;153m'
export LESS_TERMCAP_us=$'\e[3;38;2;200;170;229m'
export LESS_TERMCAP_so=$'\e[1;38;2;7;11;9;48;2;52;211;153m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'

# ── Paquetes y sistema ───────────────────────────────────────
if _hay yay; then _aur=yay; elif _hay paru; then _aur=paru; else _aur=""; fi

actualizar() {
    if [[ -n $_aur ]]; then $_aur -Syu "$@"; else sudo pacman -Syu "$@"; fi || return
    local h; h=$(pacman -Qdtq 2>/dev/null | wc -l)
    (( h )) && echo -e "\n\e[38;2;201;157;107m$h paquete(s) huérfano(s). «limpiar» los quita.\e[0m"
    [[ -d /usr/lib/modules/$(uname -r) ]] \
        || echo -e "\e[38;2;183;154;212mSe ha actualizado el núcleo: reinicia cuando puedas.\e[0m"
}
instalar() { if [[ -n $_aur ]]; then $_aur -S --needed "$@"; else sudo pacman -S --needed "$@"; fi; }
quitar()   { sudo pacman -Rns "$@"; }
huerfanos() { pacman -Qdt || echo "No hay huérfanos."; }

# «buscar algo» busca normal; «buscar» a secas abre un buscador con vista previa
buscar() {
    local gestor=${_aur:-pacman}
    if (( $# )); then $gestor -Ss "$@"; return; fi
    _hay fzf || { echo "Uso: buscar <nombre>"; return 1; }
    local sel
    sel=$($gestor -Slq | fzf --multi --prompt='  paquete ' \
          --preview "$gestor -Si {1} 2>/dev/null" --preview-window=right:60%:wrap) || return
    instalar $sel
}

limpiar() {
    local h; h=$(pacman -Qdtq)
    [[ -n $h ]] && sudo pacman -Rns $h
    if _hay paccache; then sudo paccache -rk2 && sudo paccache -ruk0; fi
    [[ -n $_aur ]] && $_aur -Sc --noconfirm >/dev/null 2>&1
    sudo journalctl --vacuum-time=3weeks -q
    echo -e "\e[38;2;52;211;153mHecho.\e[0m"
}

alias errores='journalctl -p 3 -b --no-pager'
alias fallos='systemctl --failed'
alias servicios='systemctl list-units --type=service --state=running'
alias recientes="expac --timefmt='%d/%m %H:%M' '%l  %n' 2>/dev/null | sort -r | head -25"
_hay duf && alias espacio='duf -hide special' || alias espacio='df -h -x tmpfs -x devtmpfs'

# ── Git ──────────────────────────────────────────────────────
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -m'
alias gca='git commit --amend --no-edit'
alias gp='git push'
alias gpl='git pull --rebase'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch -vv'
alias gsw='git switch'
alias gswc='git switch -c'
alias gst='git stash'
alias gstp='git stash pop'
alias glog="git log --graph --date=relative --pretty=format:'%C(#3ee8a8)%h%C(reset) %C(#e7edea)%s%C(reset) %C(#8f7fb0)· %ar%C(reset) %C(#6fc9c0)%an%C(reset)%C(#c99d6b)%d%C(reset)'"

if _hay delta; then
    export GIT_PAGER="delta --dark --line-numbers --navigate \
--syntax-theme=Sigilo \
--minus-style='syntax #2a1618' --minus-emph-style='syntax #4a2226' \
--plus-style='syntax #0f261c' --plus-emph-style='syntax #16402d' \
--line-numbers-minus-style='#e0777d' --line-numbers-plus-style='#34d399' \
--line-numbers-zero-style='#3a4a44' \
--file-style='bold #c8aae5' --file-decoration-style='#b79ad4 ul' \
--hunk-header-style='#8f7fb0' --hunk-header-decoration-style='#1b2723 box'"
fi

# ── Red y seguridad ──────────────────────────────────────────
alias puertos='sudo ss -tulpn'
alias conexiones='ss -tupn state established'

miip() {
    echo -e "\e[38;2;143;127;176mlocal\e[0m"
    command ip -4 -br addr | awk '$1!="lo"{print "  "$1"\t"$3}'
    echo -e "\e[38;2;143;127;176mpública\e[0m"
    echo "  $(curl -s --max-time 4 https://ifconfig.me || echo 'sin conexión')"
}

escanear() {
    _hay nmap || { echo "Falta nmap: instalar nmap"; return 1; }
    local red=${1:-$(command ip -o -4 route show scope link | awk '!/docker|br-|virbr/{print $1; exit}')}
    echo -e "\e[38;2;143;127;176mEscaneando $red…\e[0m"
    sudo nmap -sn "$red" | awk '/report for/{h=$5" "$6} /MAC/{$1=$2="";print "  "h"  "$0; h=""} END{if(h)print "  "h}'
}

hashes() {
    local f
    for f in "$@"; do
        echo -e "\e[1;38;2;200;170;229m$f\e[0m"
        printf '  md5     %s\n  sha1    %s\n  sha256  %s\n' \
            "$(md5sum "$f" | cut -d' ' -f1)" "$(sha1sum "$f" | cut -d' ' -f1)" "$(sha256sum "$f" | cut -d' ' -f1)"
    done
}

b64()   { if (( $# )); then printf '%s' "$*" | base64 -w0; else base64 -w0; fi; echo; }
unb64() { if (( $# )); then printf '%s' "$*" | base64 -d; else base64 -d; fi; echo; }

jwt() {
    local t=${1:-$(cat)} p
    for p in 1 2; do
        local s; s=$(cut -d. -f$p <<<"$t" | tr '_-' '/+')
        while (( ${#s} % 4 )); do s+='='; done
        if _hay jq; then base64 -d <<<"$s" 2>/dev/null | jq -C .; else base64 -d <<<"$s" 2>/dev/null; echo; fi
    done
}

cabeceras() { curl -sSIL --max-time 8 "$@"; }

dnsinfo() {
    _hay dig || { echo "Falta dig: instalar bind"; return 1; }
    local t
    for t in A AAAA MX NS TXT; do
        printf '\e[38;2;143;127;176m%-5s\e[0m %s\n' "$t" "$(dig +short "$t" "$1" | paste -sd' ')"
    done
}

certificado() {
    echo | openssl s_client -servername "$1" -connect "$1:${2:-443}" 2>/dev/null \
        | openssl x509 -noout -subject -issuer -dates -ext subjectAltName 2>/dev/null
}

servir() {
    local p=${1:-8000}
    echo -e "\e[38;2;52;211;153mSirviendo $(pwd) en http://$(command ip -4 -br addr | awk '$1!="lo"{sub(/\/.*/,"",$3);print $3;exit}'):$p\e[0m"
    python -m http.server "$p"
}

extraer() {
    local f
    for f in "$@"; do
        case "$f" in
            *.tar.gz|*.tgz)   tar xzf "$f" ;;
            *.tar.xz)         tar xJf "$f" ;;
            *.tar.zst)        tar --zstd -xf "$f" ;;
            *.tar.bz2)        tar xjf "$f" ;;
            *.tar)            tar xf "$f" ;;
            *.gz)             gunzip "$f" ;;
            *.zip)            unzip "$f" ;;
            *.7z)             7z x "$f" ;;
            *.rar)            unrar x "$f" ;;
            *.zst)            unzstd "$f" ;;
            *) echo "No sé abrir $f" ;;
        esac
    done
}

# ── Moverse rápido: fzf + zoxide ─────────────────────────────
if _hay fzf; then
    export FZF_DEFAULT_OPTS="--height=45% --layout=reverse --border=rounded --margin=0,1 \
--info=inline-right --prompt='  ' --pointer='▌' --marker='┃' --separator='─' --scrollbar='│' \
--color=fg:#94a3a0,bg:-1,hl:#3ee8a8,fg+:#e7edea,bg+:#15201c,hl+:#3ee8a8 \
--color=info:#8f7fb0,prompt:#34d399,pointer:#3ee8a8,marker:#c8aae5,spinner:#b79ad4 \
--color=header:#8aa9c4,border:#1f2b27,label:#b79ad4,query:#e7edea,gutter:-1"
    if _hay fd; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
    fi
    export FZF_CTRL_T_OPTS="--border-label=' ficheros ' --preview 'bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null || eza -la --icons=always --color=always {}'"
    export FZF_ALT_C_OPTS="--border-label=' carpetas ' --preview 'eza --tree --level=2 --icons=always --color=always {}'"
    export FZF_CTRL_R_OPTS="--border-label=' historial '"
    eval "$(fzf --bash 2>/dev/null)" 2>/dev/null || {
        [[ -f /usr/share/fzf/key-bindings.bash ]] && source /usr/share/fzf/key-bindings.bash
        [[ -f /usr/share/fzf/completion.bash ]]   && source /usr/share/fzf/completion.bash
    }
fi

# ── Mantenimiento de Sigilo ─────────────────────────────────
# Atajos a los scripts de ~/dotfiles/extra para no tener que recordar rutas
alias apps='~/dotfiles/extra/sigilo-apps'
alias ordenar-apps='~/dotfiles/extra/organizar-apps'
alias comprobar='~/dotfiles/extra/comprobar'
alias rendimiento='sudo -v && ~/dotfiles/extra/medir-rendimiento'
alias dotfiles='cd ~/dotfiles && ./sincronizar && git status -sb'

# ── Chuleta ──────────────────────────────────────────────────
# «comandos» la enseña aquí; la chuleta de ❖+F1 lee esta misma lista,
# así que lo que se añada aquí aparece en los dos sitios.
comandos() {
    local v=$'\e[1;38;2;200;170;229m' l=$'\e[38;2;143;127;176m' g=$'\e[38;2;148;163;160m' r=$'\e[0m'
    _fila() { printf "  ${v}%-18s${r}${g}%s${r}\n" "$1" "$2"; }
    _grupo() { printf "%s── %s %s${r}\n" "$l" "$1" "$(printf '─%.0s' $(seq $((40 - ${#1}))))"; }
    echo
    _grupo "moverse"
    _fila "z <trozo>"   "saltar a una carpeta usada"
    _fila "zi"          "saltar eligiendo de la lista"
    _fila "Ctrl+R"      "buscar en el historial"
    _fila "Ctrl+T"      "buscar un archivo"
    _fila "Alt+C"       "buscar una carpeta y entrar"
    _fila "mkcd"        "crear carpeta y entrar"
    _fila "lt [n]"      "árbol entero (o n niveles)"
    _grupo "sistema"
    _fila "actualizar"  "pacman + AUR con copia previa"
    _fila "instalar"    "instalar (repos o AUR)"
    _fila "quitar"      "desinstalar con dependencias"
    _fila "buscar"      "buscar paquetes"
    _fila "limpiar"     "huérfanos, caché y registros"
    _fila "huerfanos"   "paquetes que nadie usa"
    _fila "errores"     "errores de este arranque"
    _fila "fallos"      "servicios caídos"
    _fila "recientes"   "últimos instalados"
    _fila "espacio"     "uso de los discos"
    _grupo "git"
    _fila "gs ga gaa"   "estado, añadir, añadir todo"
    _fila "gc gca"      "commit, enmendar el último"
    _fila "gp gpl"      "push, pull con rebase"
    _fila "gd gds"      "diff, diff preparado"
    _fila "gsw gswc"    "cambiar rama, crear rama"
    _fila "glog"        "historial en árbol"
    _grupo "red y seguridad"
    _fila "miip"        "IP local y pública"
    _fila "puertos"     "qué escucha en el equipo"
    _fila "conexiones"  "conexiones abiertas"
    _fila "escanear"    "equipos en la red local"
    _fila "dnsinfo"     "registros DNS de un dominio"
    _fila "certificado" "certificado TLS de un dominio"
    _fila "cabeceras"   "cabeceras HTTP de una URL"
    _fila "hashes"      "md5, sha1 y sha256"
    _fila "b64 unb64"   "base64 ida y vuelta"
    _fila "jwt"         "leer un token JWT"
    _fila "servir"      "web en la carpeta actual"
    _fila "extraer"     "descomprimir casi todo"
    _fila "sigma"       "convertir reglas Sigma"
    _grupo "sigilo"
    _fila "apps"         "instalar apps con casillas"
    _fila "ordenar-apps" "rehacer ~/Aplicaciones y el menú"
    _fila "comprobar"    "revisar que todo funciona"
    _fila "rendimiento"  "medir consumo del equipo"
    _fila "dotfiles"     "copiar la config al repo"
    _grupo "kitty"
    _fila "Ctrl+Shift+T"     "pestaña nueva aquí"
    _fila "Ctrl+Shift+Intro" "dividir en horizontal"
    _fila "Ctrl+Shift+\\"    "dividir en vertical"
    _fila "Ctrl+Shift+←→↑↓"  "moverse entre paneles"
    _fila "Ctrl+Shift+Z"     "ampliar el panel"
    _fila "Ctrl+Shift+H"     "buscar en lo mostrado"
    _fila "Ctrl+Shift+A M/L" "más o menos transparencia"
    echo
    unset -f _fila _grupo
}

# ── Prompt ───────────────────────────────────────────────────
_hay starship && eval "$(starship init bash)"
_hay zoxide   && eval "$(zoxide init bash)"

# ── Ficha del sistema, una vez por sesión ────────────────────
if [[ -z $SIGILO_FETCH ]] && _hay fastfetch; then
    export SIGILO_FETCH=1
    _logo=(--logo ~/.config/fastfetch/sigilo.png --logo-width 30 --logo-height 15
           --logo-padding-top 1 --logo-padding-left 2 --logo-padding-right 4)
    if [[ $TERM == xterm-kitty && -f ~/.config/fastfetch/sigilo.png ]]; then
        fastfetch --logo-type kitty-direct "${_logo[@]}"
    elif [[ $TERM_PROGRAM == vscode && -f ~/.config/fastfetch/sigilo.png ]]; then
        # La terminal de VS Code no entiende el protocolo de imágenes de
        # kitty pero sí el de iTerm (con terminal.integrated.enableImages)
        fastfetch --logo-type iterm "${_logo[@]}"
    elif [[ -f ~/.config/fastfetch/sigilo.ansi ]]; then
        # Terminal sin imágenes: el sello en bloques de colores
        fastfetch --logo-type file-raw --logo ~/.config/fastfetch/sigilo.ansi \
                  --logo-width 35 --logo-height 19 --logo-padding-left 1
    else
        fastfetch
    fi
    unset _logo
fi
