#!/usr/bin/env bash
# Arranca Polybar para i3. Mata cualquier instancia previa para que valga
# tanto al iniciar sesion como al recargar i3.

pkill -x polybar 2>/dev/null
while pgrep -x polybar >/dev/null; do sleep 0.2; done

# El numero de hwmon puede cambiar entre arranques, asi que buscamos
# coretemp cada vez en lugar de dejar la ruta fija.
for d in /sys/class/hwmon/hwmon*; do
    if [ "$(cat "$d/name" 2>/dev/null)" = "coretemp" ]; then
        export TEMP_PATH="$d/temp1_input"
        break
    fi
done
[ -z "${TEMP_PATH:-}" ] && export TEMP_PATH="/sys/class/hwmon/hwmon0/temp1_input"

# Tarjeta de retroiluminacion (la primera que haya)
BL="$(ls -1 /sys/class/backlight 2>/dev/null | head -1)"
[ -n "$BL" ] && export BACKLIGHT="$BL"

# Nombre del dia y del mes en castellano en el formato largo de la fecha
export LC_TIME="${LC_TIME:-es_ES.UTF-8}"

LOG="${XDG_CACHE_HOME:-$HOME/.cache}/polybar.log"
polybar sigilo >>"$LOG" 2>&1 &
