#!/usr/bin/env bash
# Ajustes de rendimiento y consumo. Todo es reversible y se guarda copia
# de lo que se toca.
#
#   sudo ~/dotfiles/sistema/optimizar.sh
#
# No hay valores fijos: cada paso mira el equipo y decide. En un portátil de
# 8 GB no hace falta lo mismo que en un sobremesa de 32, y las reglas de
# batería no pintan nada donde no hay batería.
#
# Qué hace:
#   1. zram: swap comprimida en RAM, del tamaño que le toque a este equipo.
#   2. Memoria: el kernel usa antes la zram y conserva más la caché de disco.
#   3. Energía: en un portátil, «equilibrado» enchufado y «ahorro» a pilas,
#      cambiando solo. En un sobremesa, «rendimiento» fijo: no hay batería
#      que cuidar, así que no tiene sentido frenarlo.
#   4. GRUB: si solo hay Linux, acorta la espera a 2 s; si hay más de un
#      sistema, quita la cuenta atrás para que elijas tú, con la distro ya
#      marcada. Todo con cuidado de no perder entradas del menú.
#   5. Limpieza semanal de la caché de pacman (deja las 2 últimas versiones).
#   6. Apagado: 20 segundos de margen para lo que se atasque, en vez de los
#      90 que trae Arch de serie.
#
# No toca ningún servicio: impresión, wifi, bluetooth y demás siguen igual.

set -Eeuo pipefail
trap 'echo -e "\n\e[31m✗ Se paró en la línea $LINENO.\e[0m"' ERR
FECHA=$(date +%Y%m%d-%H%M%S)
ok()   { echo -e "  \e[32m✓\e[0m $*"; }
ojo()  { echo -e "  \e[33m!\e[0m $*"; }
paso() { echo -e "\n\e[1;36m── $* ──\e[0m"; }
guardar() { [ -e "$1" ] && cp -a "$1" "$1.antes-optimizar-$FECHA" || true; }
[[ $EUID -eq 0 ]] || { echo "Hay que lanzarlo con sudo."; exit 1; }

# ── qué equipo es este ───────────────────────────────────────
MEM_MB=$(awk '/MemTotal/{print int($2/1024)}' /proc/meminfo)
PORTATIL=no
ls /sys/class/power_supply/BAT* >/dev/null 2>&1 && PORTATIL=si
paso "Este equipo"
ok "memoria: $((MEM_MB / 1024)) GB"
ok "$([ $PORTATIL = si ] && echo "portátil (tiene batería)" || echo "sobremesa (sin batería)")"

# ── 1. zram ──────────────────────────────────────────────────
# Cuanta menos RAM, más proporción conviene comprimir: con 8 GB la mitad es
# un alivio de verdad, pero reservar 16 GB de zram en un equipo de 32 no
# sirve de nada y encima gasta procesador comprimiendo lo que nunca se usa.
paso "zram"
if   [ "$MEM_MB" -le 8192 ];  then ZRAM_MB=$((MEM_MB / 2)); PORQUE="la mitad de la memoria"
elif [ "$MEM_MB" -le 32768 ]; then ZRAM_MB=$((MEM_MB / 4)); PORQUE="un cuarto de la memoria"
else                               ZRAM_MB=8192;            PORQUE="8 GB, que con esta memoria sobra"
fi
pacman -S --needed --noconfirm zram-generator >/dev/null
guardar /etc/systemd/zram-generator.conf
cat > /etc/systemd/zram-generator.conf <<CONF
# Swap comprimida en RAM. Con zstd, lo que se manda aquí ocupa entre un
# tercio y la mitad, así que es como tener más memoria sin tocar el disco.
# El tamaño lo calcula sistema/optimizar.sh según la memoria del equipo.
[zram0]
zram-size = $ZRAM_MB
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
CONF
systemctl daemon-reload
systemctl restart systemd-zram-setup@zram0.service
swapon --show=NAME,SIZE,PRIO | sed 's/^/    /'
ok "zram de $((ZRAM_MB / 1024)) GB ($PORQUE)"

# ── 2. memoria ───────────────────────────────────────────────
paso "Memoria"
guardar /etc/sysctl.d/90-sigilo.conf
cat > /etc/sysctl.d/90-sigilo.conf <<'CONF'
# Con zram, mandar a swap es barato (se queda en RAM comprimido), así que
# conviene hacerlo antes y dejar sitio a la caché de disco.
vm.swappiness = 150
# zram no gana nada leyendo páginas de más de golpe
vm.page-cluster = 0
# Conserva más tiempo en caché las carpetas y ficheros usados
vm.vfs_cache_pressure = 50
CONF
sysctl -q --system
ok "swappiness $(sysctl -n vm.swappiness), cache_pressure $(sysctl -n vm.vfs_cache_pressure)"

# ── 3. energía ───────────────────────────────────────────────
paso "Energía"
if [ "$PORTATIL" = si ]; then
    guardar /etc/udev/rules.d/90-sigilo-energia.rules
    cat > /etc/udev/rules.d/90-sigilo-energia.rules <<'CONF'
# Enchufado: equilibrado (sube la frecuencia en cuanto hace falta).
# Con batería: ahorro. Se cambia solo al enchufar o desenchufar.
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set balanced"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set power-saver"
CONF
    udevadm control --reload
    udevadm trigger --subsystem-match=power_supply --action=change
    sleep 1
    ok "perfil actual: $(powerprofilesctl get)  (rendimiento, cuando lo quieras: powerprofilesctl set performance)"
else
    # En un sobremesa esas reglas no se dispararían nunca, y si hay una de
    # una instalación anterior conviene quitarla de en medio
    if [ -e /etc/udev/rules.d/90-sigilo-energia.rules ]; then
        guardar /etc/udev/rules.d/90-sigilo-energia.rules
        rm -f /etc/udev/rules.d/90-sigilo-energia.rules
        udevadm control --reload
        ok "quitadas las reglas de batería, que aquí no sirven"
    fi
    # Sin batería que cuidar no hay razón para frenarlo. El perfil no se
    # guarda solo entre arranques (power-profiles-daemon empieza siempre en
    # equilibrado), así que se pone un servicio que lo deja en rendimiento
    # al entrar. Para volver atrás:
    #   sudo systemctl disable --now sigilo-rendimiento.service
    if command -v powerprofilesctl >/dev/null && powerprofilesctl list 2>/dev/null | grep -q performance; then
        cat > /etc/systemd/system/sigilo-rendimiento.service <<'CONF'
[Unit]
Description=Perfil de energía en rendimiento (equipo sin batería)
After=power-profiles-daemon.service
Wants=power-profiles-daemon.service

[Service]
Type=oneshot
ExecStart=/usr/bin/powerprofilesctl set performance

[Install]
WantedBy=graphical.target
CONF
        systemctl daemon-reload
        systemctl enable --now sigilo-rendimiento.service >/dev/null 2>&1
        ok "sin batería: perfil en $(powerprofilesctl get), y se queda así en cada arranque"
    else
        ok "sin batería, pero este equipo no ofrece el perfil de rendimiento ($(powerprofilesctl get 2>/dev/null || echo "sin power-profiles-daemon"))"
    fi
fi

# ── 4. GRUB ──────────────────────────────────────────────────
# Lo delicado de este paso es que al regenerar el menú se pueden perder
# entradas: si os-prober está desactivado (en Arch viene así de serie),
# Windows y las demás particiones desaparecen del menú y te quedas sin
# poder arrancarlas. Por eso se cuenta antes y después, y si salen menos
# se deja todo como estaba.
paso "GRUB"
if [ ! -f /etc/default/grub ] || [ ! -d /boot/grub ]; then
    ojo "este equipo no arranca con GRUB: se salta"
else
    contar() { grep -c "^menuentry" /boot/grub/grub.cfg 2>/dev/null || echo 0; }
    valor()  { sed -n "s/^$1=//p" /etc/default/grub | tail -1 | tr -d '"'"'"; }
    ANTES_N=$(contar)

    # Lo que debería tener este equipo. Con un solo sistema el menú solo
    # estorba: dos segundos y adentro. Con más de uno, nada de cuenta atrás,
    # que si no acabas arrancando Linux sin querer cuando ibas a Windows.
    declare -A QUIERE=( [GRUB_TIMEOUT_STYLE]=menu )   # con «hidden» no se ve
    if [ "$ANTES_N" -gt 1 ]; then
        QUIERE[GRUB_TIMEOUT]=-1
        # La primera entrada siempre es la distro que estás usando:
        # grub-mkconfig la pone antes que las que encuentra os-prober
        QUIERE[GRUB_DEFAULT]=0
        # Y que os-prober siga buscando los demás sistemas, que en Arch viene
        # apagado de serie y al regenerar el menú se perderían
        QUIERE[GRUB_DISABLE_OS_PROBER]=false
        COMO="sin cuenta atrás, esperando a que elijas"
    else
        QUIERE[GRUB_TIMEOUT]=2
        COMO="2 s"
    fi

    CAMBIA=()
    for k in "${!QUIERE[@]}"; do
        [ "$(valor "$k")" = "${QUIERE[$k]}" ] || CAMBIA+=("$k")
    done

    if [ ${#CAMBIA[@]} -eq 0 ]; then
        ok "el menú ya estaba como toca ($COMO)"
    else
        guardar /etc/default/grub
        cp -a /boot/grub/grub.cfg "/boot/grub/grub.cfg.antes-optimizar-$FECHA"
        for k in "${CAMBIA[@]}"; do
            sed -i "/^$k=/d" /etc/default/grub
            echo "$k=${QUIERE[$k]}" >> /etc/default/grub
        done
        grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>&1
        if [ "$(contar)" -ge "$ANTES_N" ]; then
            ok "menú: $COMO (cambiado: ${CAMBIA[*]})"
        else
            cp -a "/etc/default/grub.antes-optimizar-$FECHA" /etc/default/grub
            cp -a "/boot/grub/grub.cfg.antes-optimizar-$FECHA" /boot/grub/grub.cfg
            echo "  ✗ El menú nuevo tenía menos entradas ($(contar) en vez de $ANTES_N): se ha dejado como estaba."
            echo "    Suele ser os-prober apagado o sin instalar: sudo pacman -S os-prober"
        fi
    fi

    # Qué se ve de verdad al arrancar, leído del menú y de la configuración
    if [ "$ANTES_N" -gt 1 ]; then
        POR_DEFECTO=$(valor GRUB_DEFAULT)
        case "$POR_DEFECTO" in
            ""|0) ARRANCA=$(grep -m1 "^menuentry" /boot/grub/grub.cfg | cut -d"'" -f2) ;;
            *)    ARRANCA="la entrada «$POR_DEFECTO»" ;;
        esac
        ok "$ANTES_N sistemas en el menú; marcado de salida: $ARRANCA"
        grep "^menuentry" /boot/grub/grub.cfg | cut -d"'" -f2 | sed 's/^/      · /'
    fi
fi

# ── 5. caché de pacman ───────────────────────────────────────
paso "Caché de pacman"
systemctl enable --now paccache.timer >/dev/null 2>&1
ok "limpieza semanal activada ($(du -sh /var/cache/pacman/pkg | cut -f1) ahora mismo)"

# ── 6. apagado ───────────────────────────────────────────────────
# Cuando apagas, systemd le pide por las buenas a cada cosa que se cierre y,
# si no contesta, espera antes de matarla a la fuerza. Arch da noventa
# segundos, que es una eternidad mirando una pantalla de texto: la mayoría
# de distribuciones usan entre diez y treinta. Con veinte, un programa
# atascado cuesta veinte segundos en vez de minuto y medio.
#
# Se pone como fichero aparte, no tocando system.conf, para que una
# actualización no lo pise y para poder quitarlo borrando el fichero.
paso "Apagado"
for donde in system user; do
    guardar "/etc/systemd/$donde.conf.d/90-sigilo-apagado.conf"
    install -d "/etc/systemd/$donde.conf.d"
    cat > "/etc/systemd/$donde.conf.d/90-sigilo-apagado.conf" <<'CONF'
# Cuánto espera systemd a que algo se cierre por las buenas antes de
# matarlo. Lo pone sistema/optimizar.sh. Para volver a lo de Arch, borra
# este fichero y lanza: sudo systemctl daemon-reexec
[Manager]
DefaultTimeoutStopSec=20s
CONF
done
systemctl daemon-reexec
ok "margen de apagado: $(systemctl show -p DefaultTimeoutStopUSec --value)"

paso "Listo"
echo "  Reinicia cuando puedas para que cojan los cambios de memoria."
