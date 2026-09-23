# Sigilo

Mi escritorio: EndeavourOS con i3, en un portátil Acer Nitro de 2018 (i7-8750H,
GTX 1050, 8 GB de RAM) y en un sobremesa con tres pantallas. Tema propio
sacado de la paleta de mi CV y llevado a todas las piezas: barra, menús,
terminal, notificaciones, apps GTK, iconos, GRUB y pantalla de inicio de
sesión.

En el sobremesa hay además una segunda sesión con Hyprland, con el mismo
aspecto y los mismos atajos. i3 es la base y va en cualquier equipo; Hyprland
está donde la gráfica lo aguanta.

La regla que ordena todo: **el color solo aparece donde significa algo**. El
resto es una escala de grises fríos. El menta marca lo activo (la ventana con
el foco, el escritorio en el que estás) y un lila suave marca lo seleccionado
(texto, archivos, pestañas de fondo). Si ves color, es por algo.

**Índice**

- [Qué lleva](#qué-lleva) · las piezas y qué programa hay detrás de cada una
- [La segunda sesión: Hyprland](#la-segunda-sesión-hyprland) · qué cambia y qué se mantiene
- [La paleta](#la-paleta) · los colores y de dónde salen
- [Qué hay en el repo](#qué-hay-en-el-repo) · para qué sirve cada carpeta
- [Instalación](#instalación) · desde cero, [desde una consola](#desde-una-consola-sin-entorno-gráfico), [qué sesiones aparecen](#qué-sesiones-aparecen-al-entrar), [en otra distro](#en-otra-distro-o-con-otro-escritorio) y [cómo quitarlo](#quitarlo-y-volver-a-lo-de-antes)
- [Apps](#apps) · las que instala, [dónde acaba cada una](#dónde-acaba-cada-app) y [cómo moverla](#mover-una-app-a-otra-carpeta)
- [Atajos](#atajos) · el teclado entero
- [Rendimiento](#rendimiento) · qué se toca y cuánto se nota
- [Cosas que tienen truco](#cosas-que-tienen-truco) · los problemas que costaron y cómo se resolvieron
- [Mantenimiento](#mantenimiento) · el día a día con el repositorio

## Qué lleva

| Pieza | Programa | Detalle |
|---|---|---|
| Gestor de ventanas | i3 | Mosaico sin huecos, botones de minimizar y maximizar que funcionan |
| Barra | Polybar | Píldoras flotantes; cada escritorio enseña los iconos de lo que tiene abierto |
| Menú de apps | jgmenu | Botón *Apps* en la barra con un desplegable por categorías |
| Lanzador y menús | Rofi | Buscador de apps, sesión, wifi, bluetooth, fondos, portapapeles, utilidades |
| Compositor | picom | Transparencia en lo que no tiene el foco, sombras, animaciones y esquinas |
| Editor | VS Code | Tema Sigilo: selección y coincidencias en lila, paréntesis por niveles, la terminal con los colores de kitty |
| Terminal | kitty + Starship | Prompt de dos líneas con git; `ls` con color e icono por tipo de fichero |
| Notificaciones | dunst | El borde dice la urgencia; volumen y brillo salen con barra |
| Apps GTK | adw-gtk3 | El tema pone las formas y Sigilo solo cambia los colores |
| Iconos | Papirus recoloreado | Carpetas en menta con el dibujo en lila |
| Conmutador | skippy-xd | Alt+Tab con vista previa de las ventanas de todos los escritorios |
| Fondos | feh + mpv | Imagen o vídeo; el vídeo se pausa solo a pantalla completa o con batería |
| Visor | imv | Supr manda la foto a la papelera y pasa a la siguiente; U la recupera |
| IA local | Ollama | ❖+I para preguntar; el robot de la barra dice si hay un modelo cargado |
| Copias | Timeshift | Una copia antes de cada actualización, arrancables desde GRUB |

## La segunda sesión: Hyprland

i3 sigue siendo la base y funciona en cualquier equipo, incluido el Nitro. En
el sobremesa hay además una segunda sesión con Hyprland, que se elige en la
pantalla de acceso. Mismo tema, mismos atajos y los mismos menús de rofi: la
idea no es otro escritorio, es el mismo aprovechando lo que X11 no puede dar.

Lo que gano con ella, en concreto:

- **Cada pantalla a su frecuencia.** Dos de 240 Hz y una de 144, cada una a lo
  suyo. En X11 acaban arrastrándose entre ellas.
- **VRR a pantalla completa**, que es para lo que compré los monitores.
- **Desenfoque y animaciones de verdad**, sin picom haciendo equilibrios.
- **Sin tearing**, sin tener que perseguir opciones de NVIDIA.

Qué cambia por dentro:

| En i3 | En Hyprland | |
|---|---|---|
| Polybar | Waybar | Mismas píldoras, mismos colores; los escritorios los pinta un demonio propio |
| picom | va dentro del compositor | Sombras, esquinas, desenfoque y opacidad, con los mismos valores |
| jgmenu | `sigilo/menu-apps` | Escrito para esto; las carpetas se abren al pasar el ratón |
| skippy-xd | `hypr/scripts/alternador` | Alt+Tab con la lista de todas las ventanas y una foto del escritorio de cada una |
| feh + xwinwrap | mpvpaper | Fondo de imagen o de vídeo |
| greenclip | cliphist | Historial del portapapeles |
| i3lock | hyprlock | Mismo sello en el centro, misma hora debajo |
| scrot | grim + slurp | El mismo guion de capturas sabe en cuál está |
| xss-lock | hypridle | Bloqueo y apagado de pantalla por inactividad |

**Los escritorios son el conjunto de todas las pantallas.** Como en GNOME o
KDE: el escritorio 3 es el 3 de todas a la vez, y cambian juntas. Por dentro
son varios escritorios de Hyprland (el 3, el 13, el 23…) que se mueven a la
par; está en `hypr/sigilo/escritorios.lua`.

Da igual cuántas pantallas tenga el equipo: el orden se deduce de lo que diga
Hyprland, de izquierda a derecha, y se recalcula si enchufas o quitas una. Con
una sola pantalla no hay nada que agrupar. Lo único que se dice a mano, en el
fichero del equipo, es cuál es la principal —la que lleva la barra— y a qué
resolución y frecuencia va cada monitor.

**El sello se cambia con `❖ + Shift + G`.** Hay quince: el de siempre y otros
en forma de escudo, candado, llave, chip, red, radar, señal, terminal y varias
figuras geométricas, cada uno con su color. Al elegir uno cambia en todos los
sitios donde sale: el terminal al abrirlo, la pantalla de bloqueo, el banner
del lanzador y el símbolo de la esquina de los menús.

La configuración está en Lua (Hyprland 0.56 en adelante), partida por temas en
`config/hypr/sigilo/`: pantallas, escritorios, aspecto, entrada, atajos,
reglas y arranque. Cada fichero se carga por separado, así que un error en uno
no se lleva por delante a los demás. Si una gráfica no traga con alguna parte,
`~/.config/hypr/omitir` con el nombre del módulo la deja fuera.

## La paleta

```
Fondo         #070b09      Menta         #34d399
Superficie    #15201c      Menta vivo    #3ee8a8
Bordes        #26332e      Ámbar         #c99d6b
Texto         #e7edea      Azul pizarra  #8aa9c4
Texto suave   #94a3a0      Violeta       #b79ad4
Texto tenue   #70837c      Rojo          #e0777d
                           Lila claro    #c8aae5
```

Los seis de la izquierda salen tal cual de [cv.manuelaraujo.com](https://cv.manuelaraujo.com).
El resto se derivó de ellos y se ajustó hasta que cada uno pasara WCAG AA
sobre su fondo real.

## Qué hay en el repo

```
config/     lo que va en ~/.config (i3, polybar, rofi, kitty, dunst, picom…)
extra/      scripts de uso diario: instalar apps, ordenarlas, comprobar el
            sistema, medir consumo y generar el tema de iconos. En
            extra/hooks/ está el que revisa la sintaxis antes de cada commit
sistema/    lo que toca fuera de tu carpeta: GRUB, pantalla de acceso,
            copias, rendimiento, discos. Se lanzan a mano y guardan copia
vscode/     el tema Sigilo para VS Code y el script que lo instala
iso/        la lista de apps por grupos y la detección de hardware, que
            también usará la ISO instalable
paquetes/   lo que tiene instalado cada equipo, solo para consultar. Lo
            escribe ./sincronizar, un fichero por máquina
```

En la raíz están los tres que se lanzan a mano: `instalar.sh` para ponerlo,
`sincronizar` para llevar los cambios de `~/.config` al repositorio, y
`desinstalar.sh` para quitarlo y recuperar lo que hubiera antes.

Lo de `extra/` que se lanza a mano de vez en cuando, y que si no se cuenta
aquí no lo encuentra nadie:

```
sigilo-apps       instala aplicaciones por grupos (lee iso/grupos.yaml)
organizar-apps    reparte las apps por categorías en ~/Aplicaciones y en el
                  menú de la barra. Se lanza solo al entrar en la sesión
comprobar         revisa el equipo montado: programas, servicios, temas
revisar           revisa el código del repositorio antes de un commit
dibujar-sellos    vuelve a dibujar los quince sellos con PIL
dibujar-banner    rehace el banner del lanzador con el sello puesto
tintar-sello      recolorea un sello con otra paleta
iconos-sigilo.py  genera el tema de iconos a partir de Papirus
curar-fondos      criba una carpeta de fondos y deja los que pegan con el
                  tema (está en config/i3/scripts/, con los demás)
```

## Instalación

No hay ISO ni nada que descargar aparte: se instala EndeavourOS o Arch como
siempre y desde ahí lo trae el repositorio. Así los paquetes son los del día
en que lo instales y no los de cuando yo generara una imagen.

En un EndeavourOS recién instalado:

```bash
git clone https://github.com/manu222/sigilo.git ~/dotfiles
cd ~/dotfiles
./instalar.sh              # copia la configuración (guarda antes lo que hubiera)
./extra/sigilo-apps        # elige apps con casillas e instala drivers y todo
```

`instalar.sh` guarda lo que ya tuvieras en `~/.config-respaldo-<fecha>`, deja
el visor de imágenes como programa por defecto, genera el tema de iconos y,
si tienes VS Code, le instala el tema Sigilo (también se puede lanzar suelto:
`vscode/instalar-tema`).

Los fondos de pantalla no están en este repo: pesan mucho y buena parte
no son míos. Viven en un repo privado aparte que `instalar.sh` descarga en
`~/Imágenes/fondos` si el equipo tiene acceso; si no, se lo salta.
`extra/fondos subir` sube los que añadas. Con tus propios fondos, apunta
a tu repo con `SIGILO_FONDOS=git@github.com:tu-usuario/tu-repo.git`.

Falta una línea en el `~/.bashrc`:

```bash
[ -f ~/.config/sigilo-shell.sh ] && . ~/.config/sigilo-shell.sh
```

Y, si quieres las piezas del sistema, cada una por separado:

```bash
sistema/instalar-grub.sh                # tema del menú de arranque
sistema/instalar-acceso.sh              # pantalla de inicio de sesión
sistema/instalar-sesion-hyprland.sh     # la segunda sesión, si la instalaste
sudo sistema/instalar-instantaneas.sh   # copias de Timeshift (solo btrfs)
sudo sistema/optimizar.sh               # zram, memoria, energía, GRUB, apagado
```

La segunda sesión es opcional y va aparte: en `sigilo-apps` hay un grupo
«Sigilo · Hyprland» que trae sus paquetes, y luego
`instalar-sesion-hyprland.sh` la deja disponible en la pantalla de acceso.
Para saber si el equipo puede con ella: `iso/detectar-hardware --hyprland`.

Los que van sin `sudo` piden la contraseña ellos mismos solo para el paso
que la necesita. Todos comprueban antes lo que van a tocar y guardan copia.

`reciclar-disco.sh` es de un caso concreto (convertir el disco que dejó
Windows en un disco de datos). Lee lo que hace antes de lanzarlo: borra un
disco entero, aunque se niega a tocar el del sistema.

### Desde una consola, sin entorno gráfico

Es el caso de un Arch recién instalado, sin escritorio todavía: entras en un
tty, y desde ahí sale todo. Los dos scripts están pensados para eso.

`instalar.sh` no necesita pantalla para nada: solo copia ficheros y deja
apuntadas preferencias. Lo que sí requiere un programa que aún no esté
(convertir una imagen, hablar con el gestor de archivos) lo comprueba antes
y se lo salta sin romperse.

`extra/sigilo-apps` elige con casillas en modo texto (`dialog`), así que se
maneja igual en un tty que en una terminal gráfica. Y monta solo lo que le
falte al equipo: si no hay `dialog`, `python`, `git` o `base-devel`, los
instala; si no hay ayudante del AUR, se compila `yay`. En Arch puro no hace
falta preparar nada antes:

```bash
sudo pacman -S --needed git
git clone https://github.com/manu222/sigilo.git ~/dotfiles
cd ~/dotfiles
./instalar.sh
./extra/sigilo-apps        # aquí entran i3, la barra, el servidor gráfico…
```

Al terminar, reinicia y ya tienes la pantalla de inicio de sesión. El orden
importa poco, pero así el segundo paso ya encuentra la configuración puesta.

### Qué sesiones aparecen al entrar

En la pantalla de acceso salen todas las que haya instaladas, no solo las de
Sigilo:

- **i3** · la entrada que trae el propio paquete de i3. Es la sesión de
  Sigilo: i3 lee `~/.config/i3/config` y ahí está todo, así que no hace
  falta una entrada aparte
- **Sigilo (Hyprland)** · la que añade `sistema/instalar-sesion-hyprland.sh`,
  y es la que hay que elegir
- **Hyprland** · la que trae el paquete. Se deja a propósito, pero arranca
  el compositor a pelo, sin esperar a que lightdm suelte la gráfica, y en el
  sobremesa con NVIDIA eso dejaba la imagen congelada

Para verlas:

```bash
ls /usr/share/xsessions /usr/share/wayland-sessions
```

### Quitarlo y volver a lo de antes

Si lo has instalado para probarlo y no te convence, se va entero:

```bash
cd ~/dotfiles
./desinstalar.sh --ensayo     # enseña el plan completo y no toca nada
./desinstalar.sh              # lo hace, después de enseñártelo y preguntar
```

No adivina nada, y por eso puede ser exacto. La primera vez que lanzaste
`instalar.sh`, guardó en `~/.config-antes-de-sigilo` todo lo que iba a pisar
y anotó en `~/.local/state/sigilo/instalado.txt` cada fichero que dejaba
puesto. Con esas dos cosas sabe qué es suyo y qué era tuyo, así que quita lo
uno y te devuelve lo otro tal cual estaba. Esa copia original está a salvo
de la rotación de respaldos a propósito: es la única irreemplazable.

Tampoco borra a las bravas: lo de Sigilo lo aparta a
`~/.config-sigilo-retirado-<fecha>` por si acaso, y de las piezas del
sistema tira de las copias que dejó cada script al instalarse — el GRUB, la
pantalla de acceso, la sesión de Hyprland y lo de `optimizar.sh`. Esa parte
pide la contraseña; si no puedes dártela, hace lo de tu carpeta y te avisa
de lo otro.

Lo que no toca, a propósito: **los programas instalados**, que los puso
pacman y ahí se quedan (si quieres limpiarlos, en `paquetes/` está la lista
de lo que había); la red, la impresora y todo lo que no pusiera Sigilo; y
las instantáneas de Timeshift y `reciclar-disco.sh`, que van por su cuenta y
desandarlas es más delicado que ponerlas.

### En otra distro o con otro escritorio

Sigilo es un escritorio i3 y funciona en cualquier distro basada en Arch
(Arch, EndeavourOS, Manjaro…), traiga i3 o no. `sigilo-apps` instala i3, la
barra y todo lo demás. Si ya usas KDE, GNOME u otro escritorio, no se borra
nada: al entrar eliges la sesión «i3» en la pantalla de inicio y el otro
escritorio sigue ahí.

Sin i3 hay partes que no funcionan, porque hablan con él directamente: la
barra de escritorios, los atajos, la chuleta, minimizar y maximizar,
cerrar escritorio y el Alt+Tab. Los fondos animados, picom y skippy-xd
también necesitan X11, así que no van en una sesión Wayland.

Lo que sí se puede usar suelto en cualquier escritorio: kitty, el prompt y
los alias (`sigilo-shell.sh`), fastfetch, bat, btop, los colores GTK, los
iconos, el cursor, el tema de VS Code y la mayoría de menús de rofi.

La pantalla de inicio (`instalar-acceso.sh`) es solo para lightdm. Con SDDM
o GDM se entra igual a i3, pero con el aspecto de esa pantalla.

## Apps

La lista está en `iso/grupos.yaml`: escritorio, copias, desarrollo,
ciberseguridad, día a día e IA local, cada app con su casilla.

- `extra/sigilo-apps` (o `apps` en la terminal) enseña esa lista. Lo que ya
  tienes sale como *ya instalado*; lo que falta, marcado. Instala los
  repositorios oficiales de golpe y el AUR de uno en uno, para que un
  paquete que falle no tumbe al resto. Mientras instala, el equipo no se
  bloquea ni se suspende, así que puedes irte.
- `iso/detectar-hardware` elige los drivers: la rama de NVIDIA según la
  generación de la gráfica, el microcódigo, la NPU si hay, y si es portátil.
- `extra/organizar-apps` (o `ordenar-apps`) monta `~/Aplicaciones` con
  accesos por categoría, y de ahí sale el menú de la barra. Las herramientas
  de terminal (nmap, sqlmap, john…) tienen su acceso: se abren en kitty con
  su chuleta de uso.

Los programas se quedan donde los pone pacman; lo que se ordena son los
accesos. También crea `~/Seguridad` (laboratorios, VPN, informes,
diccionarios…) y `~/Proyectos`.

### Dónde acaba cada app

Cuando instalas un programa nuevo, con `sigilo-apps` o con un `pacman -S` a
secas, el reparto lo coloca solo. Va por orden y manda la primera regla que
encaje:

1. **Lo que diga `iso/grupos.yaml`.** Ahí está decidido a mano dónde va cada
   cosa, con el campo `carpeta` (`gparted` → `Sistema/Discos`). Esto pesa
   por encima de todo lo demás.
2. **La categoría que declare la propia app** en su fichero `.desktop`:
   `Development` → `Desarrollo/Herramientas`, `Audio` → `Multimedia/Música`,
   `Network` → `Día a día/Internet`… La tabla completa es `POR_CATEGORIA`,
   al principio de `extra/organizar-apps`.
3. **Y si no declara ninguna que yo reparta**, `Sistema/Otras`, que es el
   cajón de sastre.

Conviene saber hasta dónde llega la regla 2, porque promete menos de lo que
parece: las categorías estándar son gruesas. Sabe que algo es «Security»,
pero no distingue entre `Seguridad/Red` y `Seguridad/Web` — esas subcarpetas
son mías y no existen en ningún estándar. Así que una herramienta de
seguridad instalada por libre acaba en `Seguridad/Otras`, y si la quieres
más fina hay que decirlo. Lo mismo con las de terminal a secas: el menú se
arma con ficheros `.desktop`, y una herramienta de consola no tiene ninguno,
así que no sale hasta que la apuntes.

Para salir de dudas con cualquier paquete, antes o después de instalarlo:

```bash
extra/organizar-apps --donde wireshark-qt
#  wireshark-qt -> Seguridad/Red
#     lo dice iso/grupos.yaml, que manda por encima de todo
```

Dice también cómo se llama su `.desktop`, que es el nombre que hacen falta
los dos arreglos de más abajo y que no se adivina: muchos son cosas como
`org.gnome.seahorse.Application`.

### Mover una app a otra carpeta

Hay tres sitios donde tocar, según el caso. **No vale con mover el acceso a
mano dentro de `~/Aplicaciones`**: esa carpeta se borra y se rehace entera
en cada reparto, así que cualquier cambio hecho ahí desaparece al rato.

**Si la app es una de las tuyas, o quieres que el cambio viaje a tus otros
equipos** → `iso/grupos.yaml`, que es el sitio bueno. Se añade el paquete al
grupo que le toque, y ese grupo ya lleva su `carpeta`:

```yaml
- {name: "Red", description: "…", packages: [wireshark-qt, tcpdump, nmap, brimstone],
   carpeta: "Seguridad/Red", terminal: [nmap, tcpdump, nc, brimstone]}
```

En `packages` van los programas del grupo. En `terminal` van los que no
traen ventana propia: a esos se les fabrica un acceso que abre kitty con su
chuleta de uso (`tldr`, y si no hay, su `--help`). Un paquete puede estar en
las dos listas, o solo en una.

Si te hace falta una carpeta que todavía no existe, la escribes y ya está:
se crea sola. Para que además tenga icono propio, añádela al diccionario
`ICONOS_CARPETA` de `extra/organizar-apps`; si no, se queda con el de
carpeta normal.

**Si es un caso suelto que no pinta en ningún grupo** → el diccionario
`MOVER` de `extra/organizar-apps`, que es para eso: apps sueltas que la
categoría automática coloca mal. Va por el nombre del `.desktop`:

```python
MOVER = {
    "hp-uiscan": "Sistema/Impresión",
    "org.flameshot.Flameshot": "Sistema/Utilidades",
}
```

**Si lo que quieres es que no salga** → el conjunto `OCULTAR`, en el mismo
fichero, también por el nombre del `.desktop`. Ahí están las entradas que
vienen de regalo con otros paquetes y no aportan nada: otros terminales,
herramientas internas de Qt o de Java, el propio lanzador. No se desinstala
nada, solo deja de mostrarse.

Toques lo que toques, se aplica con:

```bash
ordenar-apps          # o  extra/organizar-apps
```

Y si el cambio fue en `grupos.yaml`, acuérdate de que ese fichero vive en el
repositorio: un commit y ya lo tienen los dos equipos.

### Cuándo se rehace el reparto

Se rehace él solo en tres momentos: al iniciar sesión, al terminar
`sigilo-apps`, y cada vez que instalas o quitas algo con pacman o con yay. De lo último se encarga
una unidad de systemd que vigila la base de datos de pacman. Espera a que
pacman suelte el candado antes de ponerse, así que una actualización de cien
paquetes lo rehace una vez y no cien:

```bash
systemctl --user status sigilo-apps-nuevas.path
```

## Atajos

`❖` es la tecla Super. **`❖ + F1`** abre la chuleta completa, ordenada por
tareas, con los atajos de i3, lo que hace cada parte de la barra con el ratón,
las teclas del visor y los comandos de la terminal. No está escrita a mano:
lee el config de i3 y `sigilo-shell.sh`, así que no se queda desfasada. Dentro,
**`/`** abre un buscador: escribes «wifi» o «captura» y Enter lo hace.

| | |
|---|---|
| `❖ + T` | Terminal |
| `❖ + D` | Buscar una aplicación |
| Botón *Apps* de la barra | Menú de aplicaciones por categorías |
| `❖ + B` / `❖ + N` | Navegador / Archivos |
| `❖ + F1` / `❖ + Shift + F1` | Chuleta / buscador de atajos |
| `Alt + Tab` | Conmutador con vista previa |
| `❖ + Shift + Tab` | Todas las ventanas de todos los escritorios |
| `❖ + Ctrl + Q` | Cerrar el escritorio entero y saltar al más cercano |
| `❖ + U` | Utilidades: calculadora, emojis, archivos, notificaciones |
| `❖ + X` / `❖ + .` / `❖ + O` | Calculadora / emojis / buscar archivos |
| `❖ + I` | Preguntar a la IA local |
| `❖ + P` | Historial del portapapeles |
| `❖ + Shift + W` / `B` / `F` | Wifi / Bluetooth / Fondos |
| `❖ + Shift + P` | Pausar el fondo animado |
| `❖ + Shift + G` | Cambiar el sello |
| `❖ + Shift + E` | Menú de sesión |
| `❖ + botón central` | Menú de la ventana |

En Hyprland son los mismos, con dos diferencias: `❖ + Shift + Tab` no hace
nada (era skippy-xd, que es de X11) y `Alt + Tab` es un conmutador propio, con
todas las ventanas por uso reciente y una foto del escritorio de cada una.

En la terminal, `comandos` enseña los atajos de shell: saltar entre carpetas
con `z`, `actualizar`, `limpiar`, alias de git, y herramientas de red y
seguridad como `miip`, `puertos`, `escanear`, `hashes` o `jwt`.

## Rendimiento

Con el escritorio en reposo, lo de Sigilo (barra, notificaciones, portapapeles,
picom y los scripts) ocupa unos 250 MB. Lo que más ayudó:

- **zram**: swap comprimida en RAM. La mitad de la memoria hasta 8 GB, un
  cuarto hasta 32 y 8 GB de ahí para arriba: con 8 GB es la diferencia entre
  que el equipo se atasque o no, y reservar 16 en uno de 32 no sirve de nada.
- **Energía**: en un portátil, equilibrado con cargador y ahorro con batería,
  cambiando solo. En un sobremesa no hay nada que cuidar, así que se queda en
  rendimiento. Y una píldora en la barra para cambiarlo a mano cuando quieras.
- **Apagado**: 20 segundos de margen para lo que se atasque, en vez de los 90
  que trae Arch. Se nota cada vez que apagas.
- **Nada repetido**: i3 relanza sus `exec_always` en cada Mod+Shift+R. Tenía
  17 copias del portapapeles y del puente de botones comiéndose 700 MB hasta
  que cada uno aprendió a comprobar si ya estaba en marcha.

`extra/medir-rendimiento` (o `rendimiento`) saca una foto del consumo y
`extra/comprobar` (o `comprobar`) revisa que todo esté instalado, en marcha y
sin duplicados.

## Cosas que tienen truco

Varias piezas están como están por un motivo que no se ve en el fichero.
Las dejo anotadas porque me costaron un rato:

**Los programas de root necesitan que alguien les abra la puerta.** GParted,
Timeshift y demás se lanzan con `pkexec`: piden la contraseña y arrancan como
root. Pero root es otro usuario y el servidor gráfico es tuyo, así que no le
deja dibujar: pedía la contraseña, la aceptaba y luego moría con un
`cannot open display`. El lanzador de GParted ya resuelve eso llamando a
`xhost +SI:localuser:root`… si encuentra `xhost`. Si el paquete `xorg-xhost`
no está, se lo salta en silencio y no verás más pista que ese error. Va en el
grupo base, y pasa igual en X11 y en Wayland (ahí la ventana la pone
XWayland).

**Polybar no sabe encoger.** Si lo que pinta no cabe, lo monta encima de lo de
la derecha. Por eso los escritorios tienen un presupuesto de ancho: si con
todos los iconos se pasan, quitan iconos por escalones (primero de los
escritorios sin foco, luego de todos). Y por eso la red y el sistema van en
una píldora cada uno en vez de en cuatro.

**Las esquinas de la barra las recorta picom.** Polybar solo sabe «redondear»
pintando las esquinas con una copia del fondo de pantalla. Con un fondo claro
o de vídeo se ven esquinas de otro color. Picom recorta la ventana de verdad.

**La bandeja no sabe ser transparente.** Los iconos de la bandeja pintan
detrás el fondo de pantalla tal cual. Con la barra opaca y la bandeja del
mismo color, encajan con cualquier fondo.

**Las píldoras son medias lunas.** Cada módulo va entre dos glifos de Nerd
Font (`` y ``) pintados del color de la píldora, con una fuente tan alta
como la barra. Los iconos van con la variante *Mono*, que no se recorta.

**Bash no guarda el byte nulo.** Rofi separa el texto de la ruta del icono con
`\0`, y ese byte desaparece si metes las filas en una variable. Hay que
escribirlas directas a la tubería con `printf`.

**Minimizar no existe en i3.** `botones-ventana` escucha las peticiones de
minimizar y maximizar que i3 descarta y las convierte en apartar al
scratchpad y pantalla completa.

**La pantalla de acceso no puede leer tu carpeta.** Corre con su propio
usuario. El fondo que ve es una copia en `/var/lib/sigilo`, que el script de
fondos actualiza cada vez que cambias el del escritorio.

**Thunar ignora el CSS para la selección.** Lee directamente el color
`theme_selected_bg_color`. Hasta que no lo redefines, los archivos
seleccionados salen del color del acento aunque escribas reglas `:selected`.

**Las GTX 10xx y CUDA.** Las versiones actuales de CUDA ya no las soportan. En
una gráfica así Ollama va por procesador; `detectar-hardware` lo tiene en
cuenta y solo pone la versión con CUDA en gráficas más nuevas.

**pipx y el PATH.** Lo que instala pipx va a `~/.local/bin`, que en Arch no
está en el PATH. `sigilo-shell.sh` lo añade para la terminal y `~/.xprofile`
para el escritorio.

**lightdm no suelta la gráfica a tiempo.** Al entrar en Hyprland desde el
saludador, la pantalla se quedaba congelada con `Cannot commit when a
page-flip is awaiting`. El Xorg de lightdm sigue agarrado a la tarjeta
mientras Hyprland ya está arrancando. La sesión que instala
`sistema/instalar-sesion-hyprland.sh` espera a que ese Xorg muera antes de
arrancar nada.

**Waybar no sabe hablarle a la configuración en Lua.** Su módulo de
escritorios manda las órdenes con la sintaxis vieja (`dispatch workspace 3`) y
con la configuración en Lua eso ya no existe, así que el clic no hacía nada.
Por eso cada escritorio es un módulo propio con su
`hyprctl eval 'sigilo.ir(N)'`, y quien los pinta es un demonio que escucha los
eventos de Hyprland y avisa a la barra con una señal.

**Rofi empareja las comillas hasta el final de la línea.** Si le pasas dos
reglas en un `-theme-str` de una sola línea, junta la primera comilla de una
con la última de la otra y el menú sale destrozado. Hay que separar las reglas
con salto de línea.

**`less` no da por imprimibles los iconos.** Los de Nerd Font viven en la zona
de uso privado de Unicode, y `less` pinta como `<U+E5FF>` todo lo que no
considera texto. Por eso `ls` se veía bien y `lt`, que pagina, salía con
cuadraditos. Se arregla con `LESSUTFCHARDEF`, no tocando la fuente.

**GTK dice cómo se llama la ventana después de abrirla.** Las reglas de
Hyprland se miran una sola vez, al abrir, así que cuando llegaba el nombre ya
era tarde y el menú de apps salía en medio de la pantalla. La solución no es
una regla: es dibujarlo como una capa (gtk-layer-shell), igual que la barra.

**En Wayland un programa no puede preguntar dónde está el ratón.** Por eso el
menú de apps salía siempre en la pantalla de la izquierda. Hay que
preguntárselo a Hyprland, que sí lo sabe, y emparejar la pantalla por su
esquina, que es lo único que entienden los dos.

**Hyprland no distingue un diálogo de una ventana normal.** En i3 los flotaba
una regla general por `window_role` y `window_type`; en Wayland eso no existe,
así que hay que nombrar uno a uno los que salen a diario: el de abrir y
guardar ficheros (que lo pinta el portal, no la aplicación), el que pide la
contraseña de administrador y el de las llaves.

**El fondo animado se anunciaba como música.** mpvpaper es mpv, y mpv habla
MPRIS, así que la píldora de música enseñaba el nombre del fichero del fondo
como si fuera la canción. Se arranca con `load-scripts=no`.

**El Alt+Tab necesita el teclado para él solo.** Es la única forma de
enterarse de cuándo sueltas Alt. Al cerrarlo con Esc, el compositor no siempre
se lo devolvía a nadie y la ventana de debajo se quedaba sin recibir lo que
escribías, así que ahora se apunta cuál tenía el foco y se le devuelve.

**No hay vista de todos los escritorios.** En i3 eso era skippy-xd y en
Hyprland sería el plugin hyprexpo, que ya no está en el repositorio oficial de
plugins: solo quedan copias de terceros. Meter código ajeno dentro del
compositor y recompilarlo en cada actualización, a cambio de una animación, no
compensa cuando el Alt+Tab ya enseña una foto del escritorio de cada ventana.
Si algún día vuelve al repositorio oficial, se mira otra vez.

## Mantenimiento

```bash
dotfiles      # alias de: cd ~/dotfiles && ./sincronizar && git status
git add -A && git commit -m "…" && git push
```

`sincronizar` copia la configuración de `~/.config` al repo y anota los
paquetes instalados. Uso copias y no enlaces simbólicos a propósito: algunos
programas reescriben su fichero entero al guardar ajustes y convierten el
enlace en un fichero normal sin avisar. Se lanza en el equipo donde hayas
hecho los cambios, nunca en el otro: si no, se suben las listas de paquetes
de la máquina equivocada.

Antes de cada commit se revisa la sintaxis de todo el repositorio, que son
casi noventa ficheros entre bash, python, lua y json. De eso se encarga
`extra/revisar`, y lo lanza solo el hook de `extra/hooks/pre-commit`. Git no
guarda los hooks dentro del repositorio, así que cada clon tiene que
apuntar ahí una vez; lo hace `instalar.sh`, o a mano:

```bash
git -C ~/dotfiles config core.hooksPath extra/hooks
```

Si un día hace falta pasar por encima: `git commit --no-verify`. Y suelto,
sin commitear nada, para ver cómo está el repo:

```bash
extra/revisar
```

Para comprobar el sistema ya montado (programas, servicios, temas,
notificaciones) lo que hay es `extra/comprobar`, que es otra cosa: aquel mira
el equipo, este mira el código.

Lo que elige cada equipo por su cuenta no viaja en el repositorio: el sello
puesto, el fondo y poco más. Antes sí viajaban, y el resultado era que
instalar en el portátil le cambiaba el sello al que tuviera el sobremesa.
Ahora cada máquina se queda con el suyo, y una recién instalada arranca con
el clásico.

`instalar.sh` se puede relanzar tantas veces como quieras. Guarda copia de lo
que cambia en `~/.config-respaldo-<fecha>`, conserva los cinco últimos
respaldos y retira de `~/.config` los ficheros que hayan desaparecido del
repositorio, moviéndolos al respaldo en vez de borrarlos.

## Licencia

MIT.
