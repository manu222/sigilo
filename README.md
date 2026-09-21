# Sigilo

Configuración de escritorio para EndeavourOS con i3. Tema propio, construido
sobre la paleta de mi CV y llevado a todas las piezas: la barra, el lanzador,
el terminal, las notificaciones, el monitor del sistema y el resaltado de
sintaxis.

La regla que ordena todo: **el color solo aparece donde significa algo**. El
resto es una escala de grises fríos. Por eso el menta luminoso (`#3ee8a8`)
está reservado a dos sitios y solo dos —el borde de la ventana con el foco y
el escritorio activo en la barra—, que son las dos cosas que necesitas
localizar sin pensar.

## Qué lleva

| Pieza | Programa | Detalle |
|---|---|---|
| Gestor de ventanas | i3 | Mosaico sin separación, esquinas redondeadas |
| Barra | Polybar | Módulos como píldoras, flotante y centrada |
| Lanzador y menús | Rofi | Rejilla con iconos, galería de fondos, menús de red y sesión |
| Compositor | picom | Transparencia en las ventanas sin foco, sombras y animaciones |
| Terminal | kitty + Starship | Prompt de dos líneas con git y duración; colores por tipo de fichero en `ls` |
| Notificaciones | dunst | Tarjetas con el borde según urgencia; volumen y brillo con barra |
| Apps GTK | adw-gtk3 | Solo se cambian los colores con nombre; el tema pone las formas |
| Iconos | Papirus recoloreado | Carpetas en menta con el dibujo interior en lila |
| Cursor | Bibata Modern Classic | |
| Conmutador | skippy-xd | Alt+Tab con previsualización en vivo |
| Monitor | btop | Paleta completa |
| Resaltado | bat | Tema `.tmTheme` propio |

## La paleta

```
Fondo         #070b09      Menta         #34d399
Superficie    #15201c      Menta vivo    #3ee8a8
Bordes        #26332e      Ámbar         #c99d6b
Texto         #e7edea      Azul pizarra  #8aa9c4
Texto suave   #94a3a0      Violeta       #b79ad4
Texto tenue   #70837c      Rojo          #e0777d
```

Los seis primeros salen tal cual de [cv.manuelaraujo.com](https://cv.manuelaraujo.com).
El resto se derivó de ellos y se ajustó hasta que cada uno pasara WCAG AA
sobre su fondo real.

## Instalación

```bash
git clone https://github.com/manu222/dotfiles.git ~/dotfiles
cd ~/dotfiles
./instalar.sh
sudo pacman -S --needed - < paquetes-oficiales.txt
yay -S --needed - < paquetes-aur.txt
```

`instalar.sh` guarda lo que ya hubiera en `~/.config-respaldo-<fecha>` antes
de pisar nada.

Después, una línea en el `~/.bashrc`:

```bash
[ -f ~/.config/sigilo-shell.sh ] && . ~/.config/sigilo-shell.sh
```

Hay dos carpetas más que no copia `instalar.sh`:

- `sistema/` toca cosas fuera de tu carpeta personal (GRUB, pantalla de
  inicio de sesión, discos), así que cada script se lanza a mano con `sudo`,
  comprueba lo que va a tocar y guarda copia antes.
- `extra/iconos-sigilo.py` genera el tema de iconos en
  `~/.local/share/icons/Sigilo` a partir de Papirus. No necesita `sudo`.

El tema del navegador está en `config/sigilo/navegador`. En Brave o Chrome:
extensiones, modo de desarrollador, «Cargar descomprimida» y esa carpeta.

## Atajos

`❖` es la tecla Super. La lista completa sale con **`❖ + F1`**, y no está
escrita a mano: el script lee el propio config de i3, resuelve las variables
y agrupa por secciones, así que nunca se queda desfasada.

| | |
|---|---|
| `❖ + T` | Terminal |
| `❖ + D` | Lanzador de aplicaciones |
| `❖ + B` / `❖ + N` | Navegador / Archivos |
| `❖ + F1` | Chuleta de atajos |
| `Alt + Tab` | Conmutador con previsualización |
| `❖ + Shift + Tab` | Exposé |
| `❖ + Shift + E` | Menú de sesión |
| `❖ + Shift + W` / `B` / `F` | Wifi / Bluetooth / Fondos |
| `❖ + P` | Historial del portapapeles |
| `❖ + botón central` | Menú de la ventana |

## Cosas que tienen truco

Varias piezas están donde están por un motivo que no se ve en el fichero.
Las dejo anotadas porque me costaron un rato:

**Las píldoras de la barra.** Polybar no sabe redondear módulos. Cada uno va
envuelto entre dos medias lunas (`` y ``) de Nerd Font pintadas del color
del fondo de la píldora, y hay que dibujarlas con una fuente tan alta como la
barra o quedan medialunas enanas flotando en un hueco oscuro.

**Los iconos, con la variante Mono.** Nerd Fonts publica la fuente normal y
la *Mono*. La normal dibuja los iconos más anchos que una celda de texto y
polybar los recorta por la derecha. Los iconos se piden explícitamente con la
variante Mono; el texto, con la normal.

**Nada de saltos de píxeles.** Polybar calcula el ancho de cada módulo por su
texto. Si usas `%{O10}` para separar cosas, el módulo «ocupa» menos de lo que
dibuja y la bandeja acaba encima del reloj.

**El centro de la barra muestra la aplicación, no el título.** El título crece
sin control y desborda. El bloque derecho más la bandeja ocupan ~1580 px de
los 1855 disponibles; al centro le quedan ~120 px, catorce caracteres. Un
script escucha los eventos de i3 y devuelve la clase de la ventana, corta y
estable, traducida a un nombre presentable.

**Los iconos de los menús son PNG, no caracteres.** Los glifos de la zona de
uso privado se resuelven por cadena de reserva: pueden no existir, salir de
otra fuente, ignorar el color o recortarse. Dibujados como PNG, el color va
grabado y solo hay que escalarlos.

**Bash no guarda el byte nulo.** Rofi separa el texto de la ruta del icono con
`\0`, y ese byte desaparece si acumulas las filas en una variable. Hay que
escribirlas directas a la tubería con `printf`.

**Minimizar no existe en i3.** El sustituto es el scratchpad. Un pequeño
servicio (`scripts/botones-ventana`) escucha las peticiones de minimizar y
maximizar que i3 descarta y las traduce a apartar al scratchpad y pantalla
completa, para que los botones de las aplicaciones hagan algo.

**alttab no hace miniaturas.** Solo muestra el icono de la aplicación. Para
previsualización en vivo del contenido hace falta skippy-xd, cuyo modo pivot
(`--switch --pivot Alt_L --next`) reproduce el Alt+Tab de Windows.

**Thunar ignora el CSS para pintar la selección.** Pide directamente el color
con nombre `theme_selected_bg_color`, que adw-gtk3 enlaza al acento. Por
mucho que escribas reglas `:selected`, los archivos seleccionados salen del
color del acento hasta que redefines ese nombre.

**Los iconos de carpeta se recolorean, no se dibujan.** Papirus trae cada
carpeta con tres azules: la cara, la pestaña de atrás y el símbolo. El script
los ordena por claridad y los cambia por dos mentas y un lila. Así sirve para
cualquier tamaño y para las carpetas que Papirus añada en el futuro.

## Mantenimiento

```bash
./sincronizar        # copia ~/.config al repositorio y anota los paquetes
git add -A && git commit -m "actualizar configuración"
```

Se usan copias y no enlaces simbólicos a propósito: algunos programas
reescriben su fichero entero al guardar ajustes y eso convierte un enlace en
un fichero normal sin avisar.

## Licencia

MIT.
