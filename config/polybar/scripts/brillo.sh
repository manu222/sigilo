#!/usr/bin/env bash
case "$1" in
    up)   brightnessctl set 5%+ >/dev/null ;;
    down) brightnessctl set 5%- >/dev/null ;;
esac
