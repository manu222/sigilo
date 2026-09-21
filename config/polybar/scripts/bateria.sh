#!/usr/bin/env bash
# Detalle de la batería en una notificación (clic en la batería de la barra).
#
# Enseña el porcentaje, si está cargando o descargando, cuánto le queda
# (si está instalado acpi) y el desgaste: la capacidad que tiene hoy frente
# a la que traía de fábrica. Por debajo del 80 % ya se nota en la autonomía.

# La primera batería que haya; en casi todos los portátiles es BAT0 o BAT1
B=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)
[ -z "$B" ] && { notify-send "Batería" "Este equipo no tiene batería"; exit 0; }
cap=$(cat "$B/capacity" 2>/dev/null)
est=$(cat "$B/status"   2>/dev/null)
sal=$(cat "$B/health" 2>/dev/null)

# Unos portátiles dan la capacidad en energía (Wh) y otros en carga (Ah)
full=$(cat "$B/energy_full" 2>/dev/null || cat "$B/charge_full" 2>/dev/null)
dis=$(cat "$B/energy_full_design" 2>/dev/null || cat "$B/charge_full_design" 2>/dev/null)
desgaste="-"
[ -n "$full" ] && [ -n "$dis" ] && [ "$dis" -gt 0 ] && desgaste="$((100 * full / dis))% de la capacidad original"

case "$est" in
    Charging)    est="cargando" ;;
    Discharging) est="descargando" ;;
    Full)        est="cargada" ;;
    "Not charging") est="en espera" ;;
esac

restante=""
if command -v acpi >/dev/null; then
    restante=$(acpi -b 2>/dev/null | sed 's/.*, //' | head -1)
fi

notify-send -u low -t 8000 "  Batería  ${cap}%" \
    "Estado: ${est}\nSalud: ${desgaste}${restante:+\nQueda: $restante}"
