# Sigilo

Mi escritorio: EndeavourOS con i3, en un portátil Acer Nitro de 2018 (i7-8750H,
GTX 1050, 8 GB de RAM). Tema propio sacado de la paleta de mi CV y llevado a
todas las piezas: barra, menús, terminal, notificaciones, apps GTK, iconos,
GRUB y pantalla de inicio de sesión.

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

En un EndeavourOS recién instalado:

```bash
git clone https://github.com/manu222/dotfiles.git ~/dotfiles
cd ~/dotfiles
./instalar.sh              # copia la configuración (guarda antes lo que hubiera)
./extra/sigilo-apps        # elige apps con casillas e instala drivers y todo
```

`instalar.sh` guarda lo que ya tuvieras en `~/.config-respaldo-<fecha>`, deja
el visor de imágenes como programa por defecto, genera el tema de iconos y,
si tienes VS Code, le instala el tema Sigilo (también se puede lanzar suelto:
`vscode/instalar-tema`).

Falta una línea en el `~/.bashrc`:

```bash
[ -f ~/.config/sigilo-shell.sh ] && . ~/.config/sigilo-shell.sh
```

Y, si quieres las piezas del sistema, cada una por separado:

```bash
sistema/instalar-grub.sh                # tema del menú de arranque
sistema/instalar-acceso.sh              # pantalla de inicio de sesión
sudo sistema/instalar-instantaneas.sh   # copias de Timeshift (solo btrfs)
sudo sistema/optimizar.sh               # zram, memoria, energía, GRUB a 2 s
```

Los que van sin `sudo` piden la contraseña ellos mismos solo para el paso
que la necesita. Todos comprueban antes lo que van a tocar y guardan copia.

`reciclar-disco.sh` es de un caso concreto (convertir el disco que dejó
Windows en un disco de datos). Lee lo que hace antes de lanzarlo: borra un
disco entero, aunque se niega a tocar el del sistema.

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
| `❖ + Shift + E` | Menú de sesión |
| `❖ + botón central` | Menú de la ventana |

En la terminal, `comandos` enseña los atajos de shell: saltar entre carpetas
con `z`, `actualizar`, `limpiar`, alias de git, y herramientas de red y
seguridad como `miip`, `puertos`, `escanear`, `hashes` o `jwt`.

## Rendimiento

Con el escritorio en reposo, lo de Sigilo (barra, notificaciones, portapapeles,
picom y los scripts) ocupa unos 250 MB. Lo que más ayudó:

- **zram**: swap comprimida en RAM, la mitad de la memoria. Con 8 GB es la
  diferencia entre que el equipo se atasque o no.
- **Energía automática**: perfil equilibrado con cargador y ahorro con
  batería, sin tocar nada.
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
