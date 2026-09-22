-- ============================================================================
--  Hyprland · Sigilo
--  Ruta: ~/.config/hypr/hyprland.lua
--
--  La segunda sesión de Sigilo. i3 sigue siendo la base y funciona en
--  cualquier equipo; esta es la misma idea (mismos colores, mismos atajos,
--  mismos menús de rofi) para los equipos con una gráfica que aguanta
--  Wayland, y aprovecha lo que en X11 no se puede: cada pantalla a su
--  frecuencia, VRR, animaciones y desenfoque de verdad.
--
--  Hyprland recarga solo al guardar cualquiera de estos ficheros.
--  Si algo se rompe, sale un aviso rojo arriba con el fichero y la línea.
--  Para volver a i3: cerrar sesión (Super+Shift+E) y elegir i3 en lightdm.
-- ============================================================================

-- Cada require va en su propio ámbito: si un fichero tiene un error, los
-- demás se siguen cargando. Por eso está todo partido por temas.
-- El orden importa en dos casos: el entorno tiene que ir el primero (las
-- variables se aplican antes de arrancar nada) y los colores los usan los
-- demás, así que se cargan antes que el aspecto.

-- Salida de emergencia: Ctrl+Alt+Supr cierra la sesión pase lo que pase.
-- Va aquí y no en atajos.lua a propósito: si ese fichero tiene un error y
-- no carga ningún atajo, esta tecla sigue funcionando.
hl.bind("CTRL + ALT + Delete", hl.dsp.exit())

-- Registro de Hyprland activado mientras se pone a punto en cada equipo:
-- queda en $XDG_RUNTIME_DIR/hypr/<instancia>/hyprland.log. Viene apagado
-- de serie; cuando todo vaya bien se puede volver a poner a true.
hl.config({ debug = { disable_logs = false } })

-- Para buscar qué parte da problemas en un equipo nuevo: los módulos que
-- aparezcan en ~/.config/hypr/omitir (uno por línea, p. ej. "aspecto") no
-- se cargan. Sin ese fichero se carga todo.
local omitir = {}
do
    local f = io.open(os.getenv("HOME") .. "/.config/hypr/omitir", "r")
    if f then
        for linea in f:lines() do
            local m = linea:gsub("%s", "")
            if m ~= "" then omitir[m] = true end
        end
        f:close()
    end
end
local function cargar(modulo)
    if omitir[modulo] then return end
    require("sigilo." .. modulo)
end

cargar("entorno")     -- variables para NVIDIA, Qt, GTK, cursor…
cargar("pantallas")   -- resolución, frecuencia y posición de cada pantalla
cargar("escritorios") -- con varias pantallas, cada escritorio es el conjunto de todas
cargar("aspecto")     -- bordes, esquinas, sombras, desenfoque, animaciones
cargar("entrada")     -- teclado, ratón y comportamiento del foco
cargar("atajos")      -- todos los atajos de teclado y ratón
cargar("reglas")      -- qué ventanas flotan, dónde y con qué tamaño
cargar("arranque")    -- lo que se lanza al entrar en la sesión

-- Red de seguridad para las pruebas (ver scripts/vigilante). Va aquí y no
-- en arranque.lua para que funcione aunque ese módulo se omita.
hl.on("hyprland.start", function()
    hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/vigilante")
end)
