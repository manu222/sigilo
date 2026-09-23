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
#   3. Energía: solo si hay batería, perfil «equilibrado» enchufado y
#      «ahorro» a pilas. En un sobremesa no se toca nada.
#   4. GRUB: si solo hay Linux, acorta la espera a 2 s; si hay más de un
#      sistema, quita la cuenta atrás para que elijas tú, con la distro ya
#      marcada. Todo con cuidado de no perder entradas del menú.
#   5. Limpieza semanal de la caché de pacman (deja las 2 últimas versiones).
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
    ok "sin batería: el perfil de energía se deja como esté ($(powerprofilesctl get 2>/dev/null || echo "sin power-profiles-daemon"))"
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
    ANTES_N=$(contar)
    # Con un solo sistema, el menú solo estorba: dos segundos y adentro. Con
    # más de uno, nada de cuenta atrás: se queda esperando a que elijas, que
    # si no acabas arrancando Linux sin querer cuando ibas a Windows.
    if [ "$ANTES_N" -gt 1 ]; then
        ESPERA=-1
        COMO="sin cuenta atrás: espera a que elijas"
    else
        ESPERA=2
        COMO="2 s"
    fi
    ACTUAL=$(sed -n 's/^GRUB_TIMEOUT=//p' /etc/default/grub | tr -d '"'"'")

    if [ "$ACTUAL" = "$ESPERA" ]; then
        ok "el menú ya está como toca ($COMO)"
    else
        guardar /etc/default/grub
        cp -a /boot/grub/grub.cfg "/boot/grub/grub.cfg.antes-optimizar-$FECHA"
        sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=$ESPERA/" /etc/default/grub
        poner() {   # deja «clave=valor» en /etc/default/grub, esté o no
            sed -i "/^$1=/d" /etc/default/grub
            echo "$1=$2" >> /etc/default/grub
        }
        # Que el menú se vea de verdad: con «hidden» la espera no sirve
        poner GRUB_TIMEOUT_STYLE menu
        if [ "$ANTES_N" -gt 1 ]; then
            # La primera entrada siempre es la distro que estás usando:
            # grub-mkconfig la pone antes que las que encuentra os-prober
            poner GRUB_DEFAULT 0
            # Y que os-prober siga buscando los demás sistemas, que en Arch
            # viene apagado de serie y al regenerar se perderían
            poner GRUB_DISABLE_OS_PROBER false
        fi
        grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>&1
        if [ "$(contar)" -ge "$ANTES_N" ]; then
            ok "menú: $COMO ($(contar) entradas, las mismas de antes)"
        else
            cp -a "/etc/default/grub.antes-optimizar-$FECHA" /etc/default/grub
            cp -a "/boot/grub/grub.cfg.antes-optimizar-$FECHA" /boot/grub/grub.cfg
            echo "  ✗ El menú nuevo tenía menos entradas ($(contar) en vez de $ANTES_N): se ha dejado como estaba."
            echo "    Suele ser os-prober apagado o sin instalar: sudo pacman -S os-prober"
        fi
    fi
    if [ "$ANTES_N" -gt 1 ]; then
        ok "hay $ANTES_N sistemas en el menú, con $(grep -m1 "^menuentry" /boot/grub/grub.cfg | cut -d"'" -f2) marcado de salida"
    fi
fi

# ── 5. caché de pacman ───────────────────────────────────────
paso "Caché de pacman"
systemctl enable --now paccache.timer >/dev/null 2>&1
ok "limpieza semanal activada ($(du -sh /var/cache/pacman/pkg | cut -f1) ahora mismo)"

paso "Listo"
echo "  Reinicia cuando puedas para notar el arranque más corto."
