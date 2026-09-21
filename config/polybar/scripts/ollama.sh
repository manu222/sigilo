#!/usr/bin/env bash
# Estado de Ollama para la barra.
#   sin salida     el servicio no está en marcha (el módulo desaparece)
#   icono lila     en marcha, sin modelo en memoria
#   icono menta    hay un modelo cargado; se muestra su nombre corto
# Clic izquierdo: preguntar. Clic derecho: sacar el modelo de la memoria.

API=http://127.0.0.1:11434

if [ "$1" = descargar ]; then
    for m in $(curl -s --max-time 2 $API/api/ps | grep -o '"name":"[^"]*"' | cut -d'"' -f4); do
        curl -s --max-time 5 $API/api/generate -d "{\"model\":\"$m\",\"keep_alive\":0}" >/dev/null
    done
    notify-send -a IA -i dialog-information "IA local" "Modelo descargado de la memoria"
    exit 0
fi

ps=$(curl -s --max-time 1 $API/api/ps) || exit 0
[ -z "$ps" ] && exit 0

I=󰙴
IZQ=
DER=
ABRIR="%{A1:/home/manu/.config/i3/scripts/ia:}%{A3:/home/manu/.config/polybar/scripts/ollama.sh descargar:}"

nombre=$(printf '%s' "$ps" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
if [ -n "$nombre" ]; then
    corto=${nombre%%:*}
    echo "$ABRIR%{B-}%{F#15201c}%{T3}$IZQ%{T-}%{B#15201c}%{F-} %{F#3ee8a8}%{T4}$I%{T-}%{F-} %{F#94a3a0}$corto%{F-} %{B-}%{F#15201c}%{T3}$DER%{T-}%{F-}%{A}%{A}"
else
    echo "$ABRIR%{B-}%{F#15201c}%{T3}$IZQ%{T-}%{B#15201c}%{F-} %{F#8f7fb0}%{T4}$I%{T-}%{F-} %{B-}%{F#15201c}%{T3}$DER%{T-}%{F-}%{A}%{A}"
fi
