#!/usr/bin/env python3
"""Crea el tema de iconos «Sigilo»: Papirus-Dark con las carpetas en menta
y el dibujo interior de cada carpeta en lila oscuro.

No toca nada del sistema. Escribe en ~/.local/share/icons/Sigilo y hereda
todo lo demás de Papirus-Dark. Para quitarlo basta con borrar esa carpeta.

Uso:  python3 iconos-sigilo.py      (hace falta papirus-icon-theme)
"""
import colorsys, os, re, shutil, sys
from pathlib import Path

ORIGEN = Path("/usr/share/icons/Papirus")
DESTINO = Path.home() / ".local/share/icons/Sigilo"
BASE = "blue"           # variante de Papirus que se toma como molde

# Tonos por orden de claridad: el más claro es la cara de la carpeta,
# el siguiente la pestaña de atrás, y el resto (símbolos) van en lila.
MENTA = ["#2ec28d", "#1a8a63"]
LILA = "#4a3b70"
CLARO_EXTRA = "#5fe3b3"

HEX = re.compile(r"#([0-9a-fA-F]{6})\b")

def tono(h):
    """Tono (0-360), luminosidad y saturación de un color «rrggbb»."""
    r, g, b = (int(h[i:i + 2], 16) / 255 for i in (0, 2, 4))
    hh, l, s = colorsys.rgb_to_hls(r, g, b)
    return hh * 360, l, s

def recolorear(svg):
    """Cambia los azules de un icono de carpeta por los tonos Sigilo, del más claro al más oscuro."""
    azules = sorted({m.lower() for m in HEX.findall(svg)
                     if 190 <= tono(m)[0] <= 240 and tono(m)[2] > 0.25},
                    key=lambda h: -tono(h)[1])
    mapa = {}
    for i, h in enumerate(azules):
        if len(azules) >= 3 and i == 0 and tono(h)[1] > 0.75:
            mapa[h] = CLARO_EXTRA           # brillo superior en algunos tamaños
            azules_resto = azules[1:]
            break
    else:
        azules_resto = azules
    for i, h in enumerate(azules_resto):
        mapa.setdefault(h, MENTA[i] if i < len(MENTA) else LILA)
    return HEX.sub(lambda m: mapa.get(m.group(1).lower(), "#" + m.group(1)), svg)

def main():
    """Genera el tema en ~/.local/share/icons/Sigilo a partir de Papirus."""
    if not ORIGEN.is_dir():
        sys.exit("No encuentro Papirus. Instálalo con: sudo pacman -S papirus-icon-theme")
    if DESTINO.exists():
        shutil.rmtree(DESTINO)
    dirs = []
    n = 0
    for places in sorted(ORIGEN.glob("*/places")):
        tam = places.parent.name
        salida = DESTINO / tam / "places"
        for f in places.glob(f"*-{BASE}*.svg"):
            if f.is_symlink() and not f.resolve().exists():
                continue
            nombre = f.name.replace(f"-{BASE}-", "-").replace(f"-{BASE}.svg", ".svg")
            svg = recolorear(f.read_text())
            salida.mkdir(parents=True, exist_ok=True)
            (salida / nombre).write_text(svg)
            (salida / f.name).write_text(svg)
            n += 1
        if salida.is_dir():
            dirs.append(f"{tam}/places")

    # Copia las secciones de esos directorios desde el index de Papirus
    indice = (ORIGEN / "index.theme").read_text()
    secciones = []
    for d in dirs:
        m = re.search(r"^\[" + re.escape(d) + r"\]\n(?:[^\[].*\n?)*", indice, re.M)
        if m:
            secciones.append(m.group(0).rstrip())
    (DESTINO / "index.theme").write_text(
        "[Icon Theme]\nName=Sigilo\nComment=Papirus-Dark con carpetas Sigilo\n"
        "Inherits=Papirus-Dark,Qogir-Dark,breeze-dark,hicolor\n"
        f"Directories={','.join(dirs)}\n\n" + "\n\n".join(secciones) + "\n")
    os.system(f"gtk-update-icon-cache -q -f -t '{DESTINO}' 2>/dev/null")
    print(f"Tema Sigilo creado: {n} iconos de carpeta en {len(dirs)} tamaños.")

if __name__ == "__main__":
    main()
