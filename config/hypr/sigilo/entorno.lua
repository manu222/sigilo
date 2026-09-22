-- Variables de entorno de la sesión. Solo afectan a Hyprland: i3 no las ve,
-- por eso van aquí y no en /etc/environment ni en ~/.xprofile.

-- ── NVIDIA ──────────────────────────────────────────────────────────────
-- Solo se ponen si la gráfica es NVIDIA; en AMD o Intel sobran y alguna
-- (LIBVA_DRIVER_NAME) hasta estorba. Se mira si el módulo del driver está
-- cargado, que es instantáneo y no depende de ningún programa externo.
local function hay_nvidia()
    local f = io.open("/sys/module/nvidia_drm/parameters/modeset", "r")
    if not f then return false end
    f:close()
    return true
end

if hay_nvidia() then
    -- Aceleración de vídeo por hardware (paquete libva-nvidia-driver)
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("NVD_BACKEND", "direct")
    -- Que las apps OpenGL usen la librería de NVIDIA y no la de mesa
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
end

-- Plan B para el cuelgue al arrancar ("Cannot commit when a page-flip is
-- awaiting"): si existe el fichero ~/.config/hypr/sin-atomic, la gráfica
-- se configura con el método antiguo (no atómico). La wiki no lo
-- recomienda en general, pero a varios con este fallo les ha servido.
-- Se prueba creando el fichero y se deshace borrándolo.
do
    local f = io.open(os.getenv("HOME") .. "/.config/hypr/sin-atomic", "r")
    if f then
        f:close()
        hl.env("AQ_NO_ATOMIC", "1")
    end
end

-- ── que las aplicaciones usen Wayland cuando sepan ───────────────────────
-- Todas llevan X11 de reserva: lo que no sepa Wayland sigue abriendo por
-- XWayland en vez de no abrir.
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")   -- sin marco propio en apps Qt
hl.env("SDL_VIDEODRIVER", "wayland,x11")
-- Electron (VS Code, Discord, Obsidian…) en Wayland nativo: se ve nítido
-- y respeta la frecuencia de cada pantalla
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Para que los portales y las apps sepan en qué escritorio están
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- ── cursor y tema ───────────────────────────────────────────────────────
-- El mismo cursor que en i3 (gtk-3.0/settings.ini)
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- Las fechas de la barra y del bloqueo en español
hl.env("LC_TIME", "es_ES.UTF-8")
-- Las herramientas instaladas con pipx (en i3 esto lo hace ~/.xprofile)
hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. (os.getenv("PATH") or ""))
