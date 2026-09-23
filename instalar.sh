#!/usr/bin/env bash
# Instala esta configuración en un equipo nuevo, y también sirve para poner
# al día uno que ya la tenga: se puede lanzar tantas veces como haga falta.
#
# Hace copia de seguridad de lo que ya hubiera antes de pisar nada: si algo
# no te convence, lo tienes en ~/.config-respaldo-<fecha>. Solo se guarda lo
# que de verdad cambia, así que si una carpeta de esas tiene poca cosa es
# buena señal, y si no aparece ninguna es que estabas ya al día.

set -uo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
ORIGEN="$REPO/config"
DESTINO="$HOME/.config"

# Apunte de lo que se instaló la última vez. Hace falta para saber qué
# ficheros sobran: si un script desaparece del repositorio, sin esta lista se
# quedaría en ~/.config para siempre, y polybar o i3 seguirían llamándolo.
ESTADO="$HOME/.local/state/sigilo"
LISTA="$ESTADO/instalado.txt"

# Cuántas carpetas de respaldo se conservan. Con una por cada «git pull» esto
# se llenaba solo: guardar once no protege más que guardar cinco.
RESPALDOS=5

# Si no hay lista es que este equipo no tenía Sigilo todavía
[ -f "$LISTA" ] && primera_vez=no || primera_vez=si

# La copia de la primera instalación es especial: es la única que tiene tu
# configuración de antes de conocer Sigilo, y es de donde tira desinstalar.sh
# para devolvértela. Por eso lleva nombre propio y la rotación no la toca.
# Si ya existe, esta no es la primera vez por mucho que falte la lista
ORIGINAL="$HOME/.config-antes-de-sigilo"
if [ "$primera_vez" = si ] && [ ! -e "$ORIGINAL" ]; then
    RESPALDO="$ORIGINAL"
else
    primera_vez=no
    RESPALDO="$HOME/.config-respaldo-$(date +%Y%m%d-%H%M%S)"
fi

[ -d "$ORIGEN" ] || { echo "No encuentro $ORIGEN"; exit 1; }

echo "Se va a instalar la configuración en $DESTINO"
echo "Lo que ya exista se guarda antes en $RESPALDO"
read -rp "¿Seguimos? [s/N] " r
[[ "$r" =~ ^[sSyY]$ ]] || exit 0

mkdir -p "$RESPALDO" "$ESTADO"
: > "$LISTA.nuevo"
while IFS= read -r -d '' ruta; do
    rel="${ruta#$ORIGEN/}"
    actual="$DESTINO/$rel"
    printf '%s\n' "$rel" >> "$LISTA.nuevo"
    # Copia de seguridad solo si el fichero que hay es distinto del que entra.
    # Guardar los idénticos llenaba el respaldo de ruido y escondía lo poco
    # que había cambiado de verdad.
    if [ -e "$actual" ] && ! cmp -s "$actual" "$ruta"; then
        mkdir -p "$RESPALDO/$(dirname "$rel")"
        cp -a "$actual" "$RESPALDO/$rel"
    fi
    mkdir -p "$(dirname "$actual")"
    cp -a "$ruta" "$actual"
done < <(find "$ORIGEN" -type f -print0)

# Lo que se instaló la vez anterior y ya no está en el repositorio se retira.
# No se borra: se mueve al respaldo de hoy, junto a lo demás.
retirados=0
if [ -f "$LISTA" ]; then
    while IFS= read -r rel; do
        [ -n "$rel" ] || continue
        viejo="$DESTINO/$rel"
        [ -e "$viejo" ] || continue
        mkdir -p "$RESPALDO/$(dirname "$rel")"
        mv "$viejo" "$RESPALDO/$rel"
        # Y si la carpeta se queda vacía, fuera también. «rmdir -p» sube
        # borrando mientras estén vacías y se para en cuanto una no lo está.
        rmdir -p --ignore-fail-on-non-empty "$(dirname "$viejo")" 2>/dev/null
        retirados=$((retirados + 1))
        echo "  retirado: $rel"
    done < <(comm -23 <(sort "$LISTA") <(sort "$LISTA.nuevo"))
fi
mv "$LISTA.nuevo" "$LISTA"
# Y de qué punto del repositorio salió lo que se acaba de copiar. Lo usa
# sincronizar para no dejarte subir configuración vieja por encima de la
# nueva: ese error ya ha pasado y no se ve venir
git -C "$REPO" rev-parse HEAD > "$ESTADO/instalado-commit.txt" 2>/dev/null || true
[ "$retirados" -gt 0 ] && echo "($retirados fichero(s) que ya no están en el repositorio, guardados en el respaldo)"

chmod +x "$DESTINO"/i3/scripts/* "$DESTINO"/polybar/scripts/* \
         "$DESTINO"/polybar/launch.sh "$DESTINO"/rofi/scripts/* \
         "$DESTINO"/hypr/scripts/* "$DESTINO"/waybar/scripts/* 2>/dev/null || true

# ~/.local/bin en el PATH de la sesión gráfica (herramientas de pipx)
grep -qs '.local/bin' "$HOME/.xprofile" || \
    printf '# Herramientas instaladas para el usuario (pipx)\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.xprofile"

# Accesos propios: el visor de imágenes como programa por defecto
mkdir -p "$HOME/.local/share/applications"
for d in "$REPO"/extra/aplicaciones/*.desktop; do
    [ -e "$d" ] || continue
    # Un .desktop no expande ~ ni $HOME: la ruta va entera, y se pone aquí
    sed "s|@CASA@|$HOME|g" "$d" > "$HOME/.local/share/applications/$(basename "$d")"
done
command -v xdg-mime >/dev/null && for t in png jpeg webp gif bmp tiff avif heic svg+xml; do
    xdg-mime default sigilo-imagenes.desktop "image/$t"
done

# Tema de iconos (necesita papirus-icon-theme; si aún no está, se avisa)
python3 "$REPO/extra/iconos-sigilo.py" 2>/dev/null \
    || echo "Iconos: instala papirus-icon-theme y lanza  python3 $REPO/extra/iconos-sigilo.py"

# Fondos de pantalla desde su repo privado (si este equipo tiene acceso)
"$REPO/extra/fondos" bajar || true

# Tema de VS Code, si está instalado (si no, se puede lanzar más tarde)
if command -v code >/dev/null || command -v codium >/dev/null; then
    "$REPO/vscode/instalar-tema" || true
else
    echo "VS Code: cuando lo instales, lanza  $REPO/vscode/instalar-tema"
fi

# El sello que tuvieras puesto. La copia de la configuración ha dejado el
# del repositorio encima, así que se vuelve a poner el tuyo: eso rehace
# también el de la pantalla de bloqueo, el banner del lanzador y el símbolo
# de los menús. Si nunca elegiste ninguno, se queda el de siempre.
[ -x "$DESTINO/i3/scripts/sello" ] && "$DESTINO/i3/scripts/sello" --rehacer 2>/dev/null

# Vigilante de programas nuevos: cuando instalas algo con pacman o con yay,
# rehace ~/Aplicaciones y el menú para que la app aparezca en su categoría
# sin tener que cerrar sesión.
if command -v systemctl >/dev/null && [ -f "$DESTINO/systemd/user/sigilo-apps-nuevas.path" ]; then
    systemctl --user daemon-reload 2>/dev/null
    systemctl --user enable --now sigilo-apps-nuevas.path >/dev/null 2>&1 \
        && echo "Las apps nuevas se colocarán solas en el menú."
fi

# El hook que revisa la sintaxis antes de cada commit. Git no guarda los
# hooks dentro del repositorio, así que se le dice a este clon dónde están.
git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1 && \
    git -C "$REPO" config core.hooksPath extra/hooks

# Si no cambió nada, no tiene sentido dejar una carpeta de respaldo vacía.
if rmdir "$RESPALDO" 2>/dev/null && [ "$primera_vez" = no ]; then
    echo "Sin respaldo: lo que tenías ya era igual que el repositorio."
fi

# Y de los respaldos viejos solo se guardan los últimos. La copia original
# (~/.config-antes-de-sigilo) no entra aquí: no lleva «respaldo» en el nombre
# a propósito, para que esta línea no pueda llevársela por delante.
sobran=$(ls -1d "$HOME"/.config-respaldo-* 2>/dev/null | sort -r | tail -n +$((RESPALDOS + 1)))
if [ -n "$sobran" ]; then
    echo "$sobran" | while IFS= read -r d; do rm -rf "$d"; done
    echo "Respaldos viejos retirados: $(echo "$sobran" | wc -l) (se guardan los $RESPALDOS últimos)"
fi

echo
echo "Hecho. Faltan los paquetes, que se eligen por grupos:"
echo "    $REPO/extra/sigilo-apps"
echo "(en $REPO/paquetes/ está lo que tiene instalado cada equipo, por si quieres comparar)"
echo
echo "Y una línea en tu ~/.bashrc:"
echo "    [ -f ~/.config/sigilo-shell.sh ] && . ~/.config/sigilo-shell.sh"
