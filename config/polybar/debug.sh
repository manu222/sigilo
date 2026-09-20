#!/usr/bin/env bash
# Arranca polybar en primer plano mostrando los eventos de raton que recibe.
# Uso: ~/.config/polybar/debug.sh   -> pulsa y rueda sobre la barra -> Ctrl+C

pkill -x polybar 2>/dev/null
while pgrep -x polybar >/dev/null; do sleep 0.2; done

for d in /sys/class/hwmon/hwmon*; do
    [ "$(cat "$d/name" 2>/dev/null)" = "coretemp" ] && export TEMP_PATH="$d/temp1_input" && break
done
BL="$(ls -1 /sys/class/backlight 2>/dev/null | head -1)"
[ -n "$BL" ] && export BACKLIGHT="$BL"

echo ">>> Pulsa y usa la rueda sobre los modulos de la barra. Ctrl+C para salir."
echo
polybar sigilo --log=trace 2>&1 | grep -iE "button|input|action|click|scroll|shell|cmd"
