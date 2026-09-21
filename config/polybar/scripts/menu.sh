#!/usr/bin/env bash
# Botón de aplicaciones de la barra: abre (o cierra, si ya está abierto) el
# menú desplegable. Sin jgmenu instalado, cae al buscador de rofi.
if pgrep -x jgmenu >/dev/null; then pkill -x jgmenu; exit 0; fi
CSV=~/.config/jgmenu/sigilo.csv
[ -s "$CSV" ] || ~/dotfiles/extra/organizar-apps -q
if command -v jgmenu >/dev/null; then
    exec jgmenu --config-file="$HOME/.config/jgmenu/jgmenurc" --csv-file="$CSV"
else
    exec rofi -show drun
fi
