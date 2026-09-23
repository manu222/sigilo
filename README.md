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
            sistema, medir consumo y generar el tema de iconos
sistema/    lo que toca fuera de tu carpeta: GRUB, pantalla de acceso,
            copias, rendimiento, discos. Se lanzan a mano y guardan copia
vscode/     el tema Sigilo para VS Code y el script que lo instala
iso/        la lista de apps por grupos y la detección de hardware, que
            también usará la ISO instalable
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
  su chuleta de uso. Se rehace solo al iniciar sesión.

Los programas se quedan donde los pone pacman; lo que se ordena son los
accesos. También crea `~/Seguridad` (laboratorios, VPN, informes,
diccionarios…) y `~/Proyectos`.

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
enlace en un fichero normal sin avisar.

## Licencia

MIT.
