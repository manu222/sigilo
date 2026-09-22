"""Lo mínimo para hablar con Hyprland desde los scripts de Sigilo.

Es el equivalente de i3ipc para esta sesión, sin dependencias: Hyprland
deja dos sockets en $XDG_RUNTIME_DIR/hypr/<instancia>/:

  .socket.sock    preguntas y órdenes (lo mismo que hace hyprctl)
  .socket2.sock   eventos: una línea por cada cosa que pasa, "evento>>datos"

Uso desde otro script:
    sys.path.insert(0, os.path.expanduser("~/.config/hypr/scripts"))
    import hypr
    hypr.consultar("clients")          -> lista de ventanas (JSON ya leído)
    hypr.despachar('hl.dsp.focus({ workspace = 3 })')
    for evento, datos in hypr.eventos(): ...
"""
import json, os, socket, subprocess

RUNTIME = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
FIRMA = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
DIR = os.path.join(RUNTIME, "hypr", FIRMA)


def en_hyprland():
    """True si este proceso corre dentro de una sesión Hyprland."""
    return bool(FIRMA) and os.path.exists(os.path.join(DIR, ".socket.sock"))


def consultar(que):
    """Pregunta algo a Hyprland (clients, workspaces, monitors, activewindow…)
    y devuelve el JSON ya convertido. Si falla, None."""
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(2)
            s.connect(os.path.join(DIR, ".socket.sock"))
            s.sendall(f"j/{que}".encode())
            trozos = []
            while True:
                t = s.recv(65536)
                if not t:
                    break
                trozos.append(t)
        return json.loads(b"".join(trozos) or b"null")
    except (OSError, ValueError):
        return None


def despachar(orden):
    """Ejecuta un dispatcher en Lua, p. ej. 'hl.dsp.window.close()'.
    Con la configuración en Lua, "hyprctl dispatch workspace 3" ya no vale:
    hay que pasarle la llamada a hl.dsp entera."""
    subprocess.run(["hyprctl", "dispatch", orden], stdout=subprocess.DEVNULL,
                   stderr=subprocess.DEVNULL, timeout=3)


def eventos():
    """Genera (evento, datos) según van llegando. Se queda esperando para
    siempre; si Hyprland se cierra, termina."""
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        s.connect(os.path.join(DIR, ".socket2.sock"))
        resto = b""
        while True:
            t = s.recv(8192)
            if not t:
                return
            resto += t
            *lineas, resto = resto.split(b"\n")
            for l in lineas:
                ev, _, datos = l.decode(errors="replace").partition(">>")
                yield ev, datos
