#!/usr/bin/env bash
# Quita Sigilo y te devuelve la configuración que tenías antes.
#
#   ./desinstalar.sh --ensayo     enseña el plan entero y no toca nada
#   ./desinstalar.sh              lo hace, después de enseñártelo y preguntar
#
# De dónde sale lo que te devuelve: instalar.sh, la primera vez que se lanzó
# en este equipo, guardó en ~/.config-antes-de-sigilo todo lo que iba a pisar,
# y apuntó en ~/.local/state/sigilo/instalado.txt cada fichero que dejó
# puesto. Con esas dos cosas se sabe exactamente qué es de Sigilo y qué era
# tuyo, así que no hay que adivinar nada.
#
# Nada se borra a las bravas: lo de Sigilo se aparta a una carpeta con fecha
# por si acaso, y de lo del sistema se tira de las copias que dejó cada
# script de sistema al instalarse.
#
# Lo que NO hace, a propósito:
#   · desinstalar programas. Los instaló pacman y ahí se quedan; si quieres
#     limpiarlos, están listados en paquetes/<equipo>-*.txt
#   · tocar la red, la impresora, el bluetooth ni nada que no pusiera Sigilo
#   · deshacer las instantáneas de Timeshift ni reciclar-disco.sh, que van
#     por su cuenta y desandarlas es más delicado que ponerlas

set -uo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
CASA="$HOME"
DESTINO="$CASA/.config"
ORIGINAL="$CASA/.config-antes-de-sigilo"
ESTADO="$CASA/.local/state/sigilo"
LISTA="$ESTADO/instalado.txt"
APARTADO="$CASA/.config-sigilo-retirado-$(date +%Y%m%d-%H%M%S)"

ENSAYO=no
[ "${1:-}" = "--ensayo" ] && ENSAYO=si
[ "${1:-}" = "-n" ] && ENSAYO=si

ok()   { printf '  \e[32m✓\e[0m %s\n' "$*"; }
mal()  { printf '  \e[31m✗\e[0m %s\n' "$*"; }
ojo()  { printf '  \e[33m!\e[0m %s\n' "$*"; }
paso() { printf '\n\e[1;36m── %s ──\e[0m\n' "$*"; }
nota() { printf '  \e[2m·\e[0m %s\n' "$*"; }
simula() { [ "$ENSAYO" = si ]; }

# ─────────────────────────── Comprobaciones ───────────────────────────
paso "Qué hay instalado"

if [ ! -f "$LISTA" ]; then
    echo "  No encuentro $LISTA."
    echo "  Sin esa lista no sé qué ficheros puso Sigilo y cuáles son tuyos, así"
    echo "  que no voy a tocar nada a ciegas. Se crea al lanzar ./instalar.sh."
    exit 1
fi
CUANTOS=$(grep -cve '^$' "$LISTA")
ok "$CUANTOS ficheros instalados por Sigilo, según su propia lista"

if [ -d "$ORIGINAL" ]; then
    DEVUELVE=$(find "$ORIGINAL" -type f | wc -l)
    ok "copia de tu configuración anterior: $DEVUELVE ficheros en $ORIGINAL"
else
    DEVUELVE=0
    ojo "no hay copia de una configuración anterior: este equipo no tenía nada"
    ojo "en ~/.config cuando se instaló Sigilo, así que no hay nada que devolver"
fi

# Piezas del sistema, cada una con su rastro
hay_grub=no;    [ -d /boot/grub/themes/sigilo ] && hay_grub=si
hay_acceso=no;  [ -d /var/lib/sigilo ] && hay_acceso=si
hay_sesion=no;  [ -e /usr/share/wayland-sessions/sigilo-hyprland.desktop ] && hay_sesion=si
hay_optim=no
for f in /etc/sysctl.d/90-sigilo.conf /etc/udev/rules.d/90-sigilo-energia.rules \
         /etc/systemd/system/sigilo-rendimiento.service \
         /etc/systemd/system.conf.d/90-sigilo-apagado.conf \
         /etc/systemd/user.conf.d/90-sigilo-apagado.conf; do
    [ -e "$f" ] && hay_optim=si
done
for v in grub acceso sesion optim; do
    eval "estado=\$hay_$v"
    case $v in
        grub)   texto="tema del menú de arranque" ;;
        acceso) texto="pantalla de inicio de sesión" ;;
        sesion) texto="sesión «Sigilo (Hyprland)»" ;;
        optim)  texto="ajustes de optimizar.sh (zram, memoria, energía, apagado)" ;;
    esac
    [ "$estado" = si ] && ok "$texto: puesto" || nota "$texto: no está"
done

# ─────────────────────────── El plan ───────────────────────────
paso "Lo que se va a hacer"

echo
printf '  \e[1mEn tu carpeta\e[0m\n'
nota "apartar los $CUANTOS ficheros de Sigilo a $APARTADO"
[ "$DEVUELVE" -gt 0 ] && nota "devolver tus $DEVUELVE ficheros de antes a ~/.config"
nota "quitar ~/Aplicaciones, que se genera sola y no guarda nada tuyo"
nota "quitar el tema de iconos Sigilo y los accesos propios (visor de imágenes…)"
nota "apagar la unidad que vigila las apps nuevas"
nota "quitar la línea del PATH que se añadió a ~/.xprofile"
command -v code >/dev/null && nota "desinstalar el tema de VS Code"

echo
printf '  \e[1mEn el sistema\e[0m (pide la contraseña)\n'
[ "$hay_grub"   = si ] && nota "devolver /etc/default/grub y quitar el tema del menú de arranque"
[ "$hay_acceso" = si ] && nota "devolver la configuración de lightdm y quitar /var/lib/sigilo"
[ "$hay_sesion" = si ] && nota "quitar la sesión «Sigilo (Hyprland)» de la pantalla de acceso"
[ "$hay_optim"  = si ] && nota "deshacer lo de optimizar.sh, tirando de sus copias .antes-optimizar-*"
if [ "$hay_grub$hay_acceso$hay_sesion$hay_optim" = "nononono" ]; then
    nota "nada: no hay ninguna pieza de sistema puesta"
fi

echo
printf '  \e[1mLo que se queda como está\e[0m\n'
nota "los programas instalados: eso es cosa de pacman, no se toca ninguno"
nota "la red, la impresora, el bluetooth y todo lo que no pusiera Sigilo"
nota "las instantáneas de Timeshift y lo de reciclar-disco.sh, que van aparte"
nota "la línea de ~/.bashrc que carga sigilo-shell.sh: quítala tú si quieres"

if simula; then
    echo
    printf '\e[1;36mEsto era un ensayo: no se ha tocado nada.\e[0m\n'
    echo "Para hacerlo de verdad, lánzalo sin --ensayo."
    exit 0
fi

# ─────────────────────────── Confirmación ───────────────────────────
echo
printf '  \e[1;33mA partir de aquí se toca tu configuración.\e[0m\n'
read -rp "  Para seguir escribe exactamente «desinstalar»: " FRASE
[ "$FRASE" = "desinstalar" ] || { echo "  No coincide. No se ha tocado nada."; exit 0; }

# ─────────────────────────── Tu carpeta ───────────────────────────
paso "Tu carpeta"

mkdir -p "$APARTADO"
apartados=0
while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    f="$DESTINO/$rel"
    [ -e "$f" ] || continue
    mkdir -p "$APARTADO/$(dirname "$rel")"
    mv "$f" "$APARTADO/$rel" && apartados=$((apartados + 1))
    rmdir -p --ignore-fail-on-non-empty "$(dirname "$f")" 2>/dev/null
done < "$LISTA"

# Además de los de la lista, Sigilo fabrica unos cuantos sobre la marcha (el
# menú que lee la barra, el sello convertido para fastfetch y la pantalla de
# bloqueo, y lo que cada equipo elige por su cuenta). Como no salen de
# ninguna copia del repositorio, no están en la lista y hay que nombrarlos
for rel in sigilo jgmenu/sigilo.csv fastfetch/sigilo.png fastfetch/sigilo.ansi \
           i3/sello-bloqueo.png; do
    f="$DESTINO/$rel"
    [ -e "$f" ] || continue
    mkdir -p "$APARTADO/$(dirname "$rel")"
    mv "$f" "$APARTADO/$rel" && apartados=$((apartados + 1))
    rmdir -p --ignore-fail-on-non-empty "$(dirname "$f")" 2>/dev/null
done
ok "$apartados ficheros apartados en $APARTADO"

if [ "$DEVUELVE" -gt 0 ]; then
    cp -a "$ORIGINAL/." "$DESTINO/" && ok "devueltos tus $DEVUELVE ficheros de antes"
    ojo "la copia se queda en $ORIGINAL; bórrala tú cuando veas que todo va"
fi

# Lo generado: ~/Aplicaciones se rehace sola en cada arranque y no guarda
# nada tuyo, y el resto son cosas que fabricó Sigilo
for d in "$CASA/Aplicaciones" "$CASA/.local/share/sigilo-apps" \
         "$CASA/.local/share/icons/Sigilo" "$ESTADO"; do
    [ -e "$d" ] && rm -rf "$d" && ok "quitado ${d/$CASA/\~}"
done
rm -f "$CASA"/.local/share/applications/sigilo-*.desktop && ok "quitados los accesos propios"

# El visor de imágenes dejó de existir: que no se quede como programa por
# defecto o las imágenes no se abrirán con nada
MIMES="$DESTINO/mimeapps.list"
if [ -f "$MIMES" ] && grep -q "sigilo-" "$MIMES"; then
    sed -i '/sigilo-/d' "$MIMES" && ok "el visor de imágenes deja de ser el de por defecto"
    # Si el fichero lo creó Sigilo y ahora solo le quedan las cabeceras, fuera
    grep -qvE '^\[|^$' "$MIMES" || { rm -f "$MIMES"; ok "quitado un mimeapps.list que quedó vacío"; }
fi

# La línea del PATH de pipx que añadió instalar.sh
if [ -f "$CASA/.xprofile" ] && grep -q "Herramientas instaladas para el usuario (pipx)" "$CASA/.xprofile"; then
    sed -i '/# Herramientas instaladas para el usuario (pipx)/,+1d' "$CASA/.xprofile"
    ok "quitada la línea del PATH en ~/.xprofile"
fi

# La unidad que vigila las apps nuevas
if command -v systemctl >/dev/null; then
    systemctl --user disable --now sigilo-apps-nuevas.path >/dev/null 2>&1 \
        && ok "apagada la unidad que vigilaba las apps nuevas"
    systemctl --user daemon-reload 2>/dev/null
fi

# El tema de VS Code
if command -v code >/dev/null; then
    code --uninstall-extension manu222.sigilo-tema >/dev/null 2>&1 \
        && ok "desinstalado el tema de VS Code" \
        || ojo "el tema de VS Code no estaba instalado"
    AJUSTES="$CASA/.config/Code/User/settings.json"
    [ -f "$AJUSTES.bak-sigilo" ] && ojo "tu settings.json de antes está en $AJUSTES.bak-sigilo"
fi

# ─────────────────────────── El sistema ───────────────────────────
if [ "$hay_grub$hay_acceso$hay_sesion$hay_optim" = "nononono" ]; then
    paso "El sistema"
    ok "no había nada puesto"
else
    paso "El sistema"
    if ! sudo -v 2>/dev/null; then
        mal "sin permisos de administrador: las piezas del sistema se quedan como están"
        ojo "lánzalo otra vez cuando puedas usar sudo, o deshazlas a mano"
    else
        # Devuelve un fichero desde la copia más nueva que encaje con un patrón
        devolver() {   # $1 = fichero, $2 = patrón de sus copias
            local copia
            copia=$(ls -1t $2 2>/dev/null | head -1)
            if [ -n "$copia" ]; then
                sudo cp -a "$copia" "$1" && ok "devuelto $1 (desde $(basename "$copia"))"
            else
                ojo "no hay copia de $1: revísalo tú, puede que tenga algo de Sigilo"
            fi
        }

        if [ "$hay_grub" = si ]; then
            devolver /etc/default/grub "/etc/default/grub.antes-de-sigilo-*"
            sudo rm -rf /boot/grub/themes/sigilo && ok "quitado el tema del menú de arranque"
            if command -v grub-mkconfig >/dev/null; then
                sudo grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>&1 \
                    && ok "menú de arranque regenerado" || mal "no he podido regenerar el menú"
            fi
        fi

        if [ "$hay_acceso" = si ]; then
            devolver /etc/lightdm/slick-greeter.conf "/etc/lightdm/slick-greeter.conf.antes-de-sigilo-*"
            sudo rm -rf /var/lib/sigilo /usr/share/backgrounds/sigilo-sello.png \
                && ok "quitados el fondo y el sello de la pantalla de acceso"
        fi

        if [ "$hay_sesion" = si ]; then
            sudo rm -f /usr/local/bin/sigilo-hyprland \
                       /usr/share/wayland-sessions/sigilo-hyprland.desktop \
                && ok "quitada la sesión «Sigilo (Hyprland)»"
            ojo "la sesión «Hyprland» del paquete sigue ahí, que no la puso Sigilo"
        fi

        if [ "$hay_optim" = si ]; then
            # El servicio de rendimiento primero se para, luego se quita
            if systemctl list-unit-files sigilo-rendimiento.service >/dev/null 2>&1; then
                sudo systemctl disable --now sigilo-rendimiento.service >/dev/null 2>&1
            fi
            sudo rm -f /etc/systemd/system/sigilo-rendimiento.service \
                       /etc/sysctl.d/90-sigilo.conf \
                       /etc/udev/rules.d/90-sigilo-energia.rules \
                       /etc/systemd/system.conf.d/90-sigilo-apagado.conf \
                       /etc/systemd/user.conf.d/90-sigilo-apagado.conf \
                && ok "quitados los ficheros que puso optimizar.sh"
            # zram tenía fichero propio antes en algunos equipos
            if ls /etc/systemd/zram-generator.conf.antes-optimizar-* >/dev/null 2>&1; then
                devolver /etc/systemd/zram-generator.conf "/etc/systemd/zram-generator.conf.antes-optimizar-*"
            else
                sudo rm -f /etc/systemd/zram-generator.conf && ok "quitada la configuración de zram"
            fi
            sudo systemctl daemon-reload 2>/dev/null
            ojo "el zram y los ajustes de memoria se van del todo al reiniciar"
        fi
    fi
fi

# ─────────────────────────── Final ───────────────────────────
paso "Hecho"
echo "  Cierra sesión y vuelve a entrar para verlo."
echo
echo "  Lo de Sigilo que se ha apartado, por si te hace falta rescatar algo:"
echo "      $APARTADO"
[ "$DEVUELVE" -gt 0 ] && echo "      $ORIGINAL   (tu configuración de antes, tal cual estaba)"
echo
echo "  Los programas siguen instalados. Si quieres quitarlos también, en"
echo "  $REPO/paquetes/ tienes la lista de lo que había en cada equipo."
