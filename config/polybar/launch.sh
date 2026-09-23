#!/usr/bin/env bash
# Arranca Polybar para i3. Vale tanto al iniciar sesion como al recargar i3.

LOG="${XDG_CACHE_HOME:-$HOME/.cache}/polybar.log"

# Esta barra es la de i3. Si se lanza estando en Hyprland arranca igual, por
# XWayland, se pone encima de la waybar y sus módulos se pasan la vida
# diciendo que no encuentran a i3, porque no está. Mejor no dejarlo empezar.
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    echo "Estás en Hyprland: esta barra es la de i3."
    echo "La de esta sesión se lanza con  ~/.config/waybar/lanzar  (o ❖+Shift+R)."
    exit 0
fi

echo "=============== $(date '+%F %T') lanzamiento ===============" >> "$LOG"

# ── cerrar la barra anterior, con limite ───────────────────────────────────
# Una barra de una sesion ya cerrada puede quedarse colgada intentando
# reconectar con un i3 que ya no existe. Esperarla sin limite dejaba la
# nueva sin arrancar nunca. Se le da un segundo y medio por las buenas y,
# si sigue ahi, se la mata por las malas.
# Primero el vigilante de abajo, para que no la resucite mientras se cierra
VIGILANTE="${XDG_RUNTIME_DIR:-/tmp}/polybar-vigilante.pid"
# (se comprueba que ese pid siga siendo este script y no otro proceso que
# haya heredado el número)
v=$(cat "$VIGILANTE" 2>/dev/null)
[ -n "$v" ] && grep -qs launch.sh "/proc/$v/cmdline" && kill "$v" 2>/dev/null
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
# Sin brillo que controlar (sobremesa) el módulo de brillo no sale, y la
# píldora del volumen, que comparte con él, se quedaría sin cerrar. Se usa
# la variante que se cierra sola. La batería va en su propia píldora y
# simplemente no aparece.
if [ -z "$BL" ]; then
    export MODULOS_DERECHA="musica ollama pulseaudio-solo red temperature cpu memory battery date systray"
fi

export LC_TIME="${LC_TIME:-es_ES.UTF-8}"

# Con varias pantallas, la barra va a la marcada como principal
# (--primary en ~/.screenlayout/pantallas.sh). Con una sola da igual.
if [ -z "${MONITOR:-}" ]; then
    MONITOR=$(xrandr --query 2>/dev/null | awk '/ connected primary/ {print $1; exit}')
    [ -n "$MONITOR" ] && export MONITOR
fi

# ── arrancar y vigilar ─────────────────────────────────────────────────────
# El módulo de volumen de polybar se cae entero (y con él toda la barra)
# si el servidor de sonido se reinicia o cambia de salida por debajo: sale
# «Assertion 'o' failed … pa_operation_get_state» en el log. Por eso la
# barra corre dentro de un bucle que la vuelve a levantar si muere sola.
# Si la cierra este mismo script (recargar i3) sale limpia y el bucle
# termina. El tope de 5 reinicios por minuto evita un bucle sin fin si el
# fallo es de la configuración.
(
    echo $BASHPID > "$VIGILANTE"
    trap 'kill "$hija" 2>/dev/null; exit 0' TERM
    caidas=()
    while true; do
        polybar sigilo >>"$LOG" 2>&1 &
        hija=$!
        # Si hay un fondo animado, la barra tiene que quedar por encima de él
        ( sleep 1.5; ~/.config/i3/scripts/fondo --subir-barra ) &
        wait "$hija"; codigo=$?
        [ "$codigo" -eq 0 ] && break
        ahora=$(date +%s)
        caidas=($(for t in "${caidas[@]}" "$ahora"; do [ $((ahora - t)) -lt 60 ] && echo "$t"; done))
        echo "la barra se cayó (código $codigo), se vuelve a lanzar" >> "$LOG"
        [ ${#caidas[@]} -ge 5 ] && { echo "demasiadas caídas seguidas, se deja parada" >> "$LOG"; break; }
        sleep 1
    done
    rm -f "$VIGILANTE"
) &
disown
