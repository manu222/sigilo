#!/usr/bin/env bash
# Rueda del ratón sobre el brillo de la barra: arriba sube, abajo baja.
# El paso (5 %) es el mismo que el de las teclas de brillo del teclado.
case "$1" in
    up)   brightnessctl set 5%+ >/dev/null ;;
    down) brightnessctl set 5%- >/dev/null ;;
esac
