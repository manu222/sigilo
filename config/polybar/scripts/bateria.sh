#!/usr/bin/env bash
# Detalle de la bateria en una notificacion.
B=/sys/class/power_supply/BAT1
cap=$(cat "$B/capacity" 2>/dev/null)
est=$(cat "$B/status"   2>/dev/null)
sal=$(cat "$B/health" 2>/dev/null)

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

notify-send -u low -t 8000 "  Bateria  ${cap}%" \
    "Estado: ${est}\nSalud: ${desgaste}${restante:+\nQueda: $restante}"
