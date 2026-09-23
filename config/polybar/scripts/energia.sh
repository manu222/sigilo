#!/usr/bin/env bash
# Píldora del perfil de energía para polybar.
#
#   icono ámbar   rendimiento
#   icono menta   equilibrado
#   icono azul    ahorro
#
# Clic: pasa al siguiente perfil. Clic derecho: menú para elegir.
# Si el equipo no tiene power-profiles-daemon, no escribe nada y el módulo
# desaparece de la barra.
#
# El trabajo de verdad lo hace rofi/scripts/energia, que es el mismo en las
# dos sesiones; aquí solo se pinta.

command -v powerprofilesctl >/dev/null || exit 0
perfil=$(powerprofilesctl get 2>/dev/null) || exit 0
[ -z "$perfil" ] && exit 0

case "$perfil" in
    performance) I=$(printf '\U000f04c5'); C="#c99d6b" ;;
    balanced)    I=$(printf '\U000f0f85'); C="#34d399" ;;
    *)           I=$(printf '\U000f0f86'); C="#8aa9c4" ;;
esac

IZQ=
DER=
M=$HOME/.config/rofi/scripts/energia
PULSAR="%{A1:$M --siguiente:}%{A3:$M:}"

echo "$PULSAR%{B-}%{F#15201c}%{T3}$IZQ%{T-}%{B#15201c}%{F-} %{F$C}%{T4}$I%{T-}%{F-} %{B-}%{F#15201c}%{T3}$DER%{T-}%{F-}%{A}%{A} "
