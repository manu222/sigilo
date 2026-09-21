#!/usr/bin/env bash
# Arranca Polybar para i3. Vale tanto al iniciar sesion como al recargar i3.

LOG="${XDG_CACHE_HOME:-$HOME/.cache}/polybar.log"
echo "=============== $(date '+%F %T') lanzamiento ===============" >> "$LOG"

# ── cerrar la barra anterior, con limite ───────────────────────────────────
# Una barra de una sesion ya cerrada puede quedarse colgada intentando
# reconectar con un i3 que ya no existe. Esperarla sin limite dejaba la
# nueva sin arrancar nunca. Se le da un segundo y medio por las buenas y,
# si sigue ahi, se la mata por las malas.
pkill -x polybar 2>/dev/null
for _ in $(seq 15); do
    pgrep -x polybar >/dev/null || break
    sleep 0.1
done
if pgrep -x polybar >/dev/null; then
    echo "barra anterior colgada: se fuerza el cierre" >> "$LOG"
    pkill -9 -x polybar 2>/dev/null
    sleep 0.3
fi

# ── esperar al servidor de sonido ──────────────────────────────────────────
# Al entrar en sesion la barra podia arrancar antes que pipewire, y entonces
# desactivaba el modulo de volumen para toda la sesion. Se espera hasta 8 s.
for _ in $(seq 40); do
    pactl info >/dev/null 2>&1 && break
    sleep 0.2
done
pactl info >/dev/null 2>&1 || echo "el sonido no respondio a tiempo" >> "$LOG"

# ── datos del hardware que cambian entre arranques ─────────────────────────
for d in /sys/class/hwmon/hwmon*; do
    if [ "$(cat "$d/name" 2>/dev/null)" = "coretemp" ]; then
        export TEMP_PATH="$d/temp1_input"
        break
    fi
done
[ -z "${TEMP_PATH:-}" ] && export TEMP_PATH="/sys/class/hwmon/hwmon0/temp1_input"

BL="$(ls -1 /sys/class/backlight 2>/dev/null | head -1)"
[ -n "$BL" ] && export BACKLIGHT="$BL"

export LC_TIME="${LC_TIME:-es_ES.UTF-8}"

polybar sigilo >>"$LOG" 2>&1 &
