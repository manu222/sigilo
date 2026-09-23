#!/usr/bin/env bash
# Red en una sola píldora, solo iconos: la wifi con su intensidad y, si hay
# cable, su icono al lado. El nombre de la red sale al hacer clic. La IP ya no va en la barra: «miip» en la terminal.
# Clic: menú de wifi. Clic derecho: nmtui.

WIFI_ICONOS=(󰤯 󰤟 󰤢 󰤥 󰤨)
CABLE=󰈀
SIN=󰖪
IZQ=
DER=

wifi="" cable=""
while IFS=: read -r tipo estado conexion; do
    [ "$estado" = connected ] || continue
    case $tipo in
        wifi)     wifi=$conexion ;;
        ethernet) cable=1 ;;
    esac
done < <(nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null)

contenido=""
if [ -n "$wifi" ]; then
    q=$(awk 'NR==3 {gsub(/\./,"",$3); print int($3)}' /proc/net/wireless 2>/dev/null)
    n=$(( ${q:-0} * 5 / 71 )); (( n > 4 )) && n=4
    contenido="%{F#6fc9c0}%{T4}${WIFI_ICONOS[$n]}%{T-}%{F-}"
fi
if [ -n "$cable" ]; then
    [ -n "$contenido" ] && contenido+=" "
    contenido+="%{F#8aa9c4}%{T4}$CABLE%{T-}%{F-}"
fi
[ -z "$contenido" ] && contenido="%{F#e0777d}%{T4}$SIN%{T-}%{F-}"

echo "%{A1:$HOME/.config/rofi/scripts/wifi:}%{A3:$HOME/.config/i3/scripts/terminal --titulo Redes --tam 90x26 -- nmtui:}%{B-}%{F#15201c}%{T3}$IZQ%{T-}%{B#15201c}%{F-} $contenido %{B-}%{F#15201c}%{T3}$DER%{T-}%{F-}%{A}%{A} "
