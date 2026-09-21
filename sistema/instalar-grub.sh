#!/usr/bin/env bash
# Pone el tema Sigilo al menu de arranque (GRUB).
#
# Solo toca el ASPECTO: una linea GRUB_THEME en /etc/default/grub y una
# carpeta con el tema. No cambia el tiempo de espera, ni que sistema arranca
# por defecto, ni los parametros del nucleo.
#
# Un tema no puede impedir el arranque: si algo del tema esta mal, GRUB lo
# ignora y enseña el menu de siempre. Aun asi se guarda copia de todo y, si
# la regeneracion del menu fallara, se restaura sola.

set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
ORIGEN="$AQUI/grub"
DEST=/boot/grub/themes/sigilo
CFG=/etc/default/grub
MENU=/boot/grub/grub.cfg

para() { echo; echo "  ✗ $*"; echo "  No se ha tocado nada."; exit 1; }

# Si cualquier orden falla, avisar de donde en vez de salir en silencio
trap 'echo; echo "  ✗ Se detuvo en la línea $LINENO: $BASH_COMMAND"' ERR

echo "Comprobando el sistema..."
pacman -Qq grub >/dev/null 2>&1           || para "No usas GRUB."
[ -f "$CFG" ]                              || para "No existe $CFG."
sudo test -f "$MENU"                       || para "No existe $MENU."
command -v grub-mkfont >/dev/null          || para "Falta grub-mkfont."
TTF=$(fc-match -f '%{file}' 'JetBrainsMono Nerd Font:style=Regular' 2>/dev/null)
[ -f "$TTF" ]                              || para "No encuentro la fuente JetBrains Mono."
echo "  ✓ GRUB presente"

# ── informe: que hay ahora mismo ───────────────────────────────────────────
espera=$({ grep -E '^GRUB_TIMEOUT=' "$CFG" || true; } | cut -d= -f2 | tr -d "'\"")
estilo=$({ grep -E '^GRUB_TIMEOUT_STYLE=' "$CFG" || true; } | cut -d= -f2 | tr -d "'\"")
salida=$({ grep -E '^GRUB_TERMINAL_OUTPUT=' "$CFG" || true; } | cut -d= -f2 | tr -d "'\"")
windows=$(sudo grep -ciE "^menuentry .*windows" "$MENU" || true)
echo "  · espera del menú: ${espera:-sin definir} s, estilo: ${estilo:-menu}"
echo "  · otros sistemas en el menú: $([ "${windows:-0}" -gt 0 ] && echo "sí, Windows" || echo "no se detecta ninguno")"

# ── construir el tema en una carpeta temporal ──────────────────────────────
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
cp -a "$ORIGEN/sigilo/." "$TMP/"

# Solo los caracteres necesarios: ASCII, acentos del castellano, flechas y
# el punto medio. Con la fuente entera el fichero pesaria varios megas y
# ralentizaria el arranque.
# Cada tramo tiene que ser DESDE-HASTA: grub-mkfont no admite caracteres
# sueltos. El punto medio (0xB7) ya cae dentro de 0xA0-0xFF.
RANGO="0x20-0x7E,0xA0-0xFF,0x2190-0x2193"
nombre() {  # lee el nombre grabado en un .pf2
    python3 - "$1" <<'PY'
import struct, sys
d = open(sys.argv[1], 'rb').read(); i = 0
while i + 8 <= len(d):
    tag = d[i:i+4]; n = struct.unpack('>I', d[i+4:i+8])[0]
    if tag == b'NAME':
        print(d[i+8:i+8+n].rstrip(b'\0').decode()); break
    i += 8 + n
PY
}
for t in 14 18; do
    grub-mkfont -n Sigilo -s "$t" -r "$RANGO" -o "$TMP/sigilo-$t.pf2" "$TTF"
done
F14=$(nombre "$TMP/sigilo-14.pf2"); F18=$(nombre "$TMP/sigilo-18.pf2")
[ -n "$F14" ] && [ -n "$F18" ] || para "No se pudo leer el nombre de las fuentes generadas."
sed -e "s|@F14@|$F14|g" -e "s|@F18@|$F18|g" "$ORIGEN/theme.txt" > "$TMP/theme.txt"
echo "  ✓ tema construido (fuentes: $F18 / $F14)"

# ── copia de seguridad ─────────────────────────────────────────────────────
RESPALDO="$CFG.antes-de-sigilo-$(date +%Y%m%d-%H%M%S)"
sudo cp -a "$CFG" "$RESPALDO"
echo "  ✓ copia de $CFG en $RESPALDO"

# ── instalar ───────────────────────────────────────────────────────────────
sudo rm -rf "$DEST"
sudo install -d "$DEST"
sudo cp -a "$TMP/." "$DEST/"
sudo chmod -R a+rX "$DEST"

if grep -qE '^#?[[:space:]]*GRUB_THEME=' "$CFG"; then
    sudo sed -i -E "s|^#?[[:space:]]*GRUB_THEME=.*|GRUB_THEME=\"$DEST/theme.txt\"|" "$CFG"
else
    echo "GRUB_THEME=\"$DEST/theme.txt\"" | sudo tee -a "$CFG" >/dev/null
fi
echo "  ✓ tema instalado en $DEST"

# Copia del MENU ya generado, no solo de los ajustes: si al regenerar se
# pierde algo (como la entrada de Windows), se puede volver al menu exacto.
MENU_RESPALDO="$MENU.antes-de-sigilo-$(date +%Y%m%d-%H%M%S)"
sudo cp -a "$MENU" "$MENU_RESPALDO"

# No se toca os-prober. Las entradas de otros sistemas pueden venir de el o
# de scripts propios de la distribucion (EndeavourOS usa 45_eos_windows), y
# activarlo a ciegas puede duplicarlas. La unica regla: ningun sistema debe
# desaparecer del menu al regenerarlo. Si pasa, se restaura todo.

restaurar() {
    echo "  ✗ $1: vuelvo a dejar el menú y los ajustes como estaban"
    sudo cp -a "$RESPALDO" "$CFG"
    sudo cp -a "$MENU_RESPALDO" "$MENU"
    exit 1
}

echo; echo "Regenerando el menú de arranque..."
sudo grub-mkconfig -o "$MENU" || restaurar "grub-mkconfig ha fallado"

# Comprobacion final: que no se haya perdido ningun sistema por el camino
despues=$(sudo grep -ciE "^menuentry .*windows" "$MENU" || true)
if [ "${windows:-0}" -gt 0 ] && [ "${despues:-0}" -eq 0 ]; then
    restaurar "la entrada de Windows ha desaparecido al regenerar"
fi
[ "${windows:-0}" -gt 0 ] && echo "  ✓ Windows sigue en el menú"

echo
echo "Listo. Lo verás en el próximo arranque."
[ "${salida:-}" = "console" ] && echo "  ⚠ GRUB_TERMINAL_OUTPUT=console: en modo texto el tema no se ve."
{ [ "${espera:-5}" = "0" ] || [ "${estilo:-}" = "hidden" ]; } && \
    echo "  ⚠ Tu menú está oculto o con espera 0: no lo verás salvo que pulses Shift al arrancar."
echo
echo "Para deshacerlo:"
echo "  sudo cp '$RESPALDO' $CFG && sudo cp '$MENU_RESPALDO' $MENU"
