#!/usr/bin/env bash
# Calendario del mes. Usa gsimplecal si esta instalado; si no, lo muestra
# en una notificacion con el mes en curso y el dia de hoy resaltado.
if command -v gsimplecal >/dev/null; then
    exec gsimplecal
fi
CAL="$(cal | sed '1d')"
HOY="$(date '+%A, %-d de %B de %Y')"
notify-send -u low -t 8000 "  ${HOY^}" "<tt>$(echo "$CAL" | sed 's/&/\&amp;/g')</tt>"
