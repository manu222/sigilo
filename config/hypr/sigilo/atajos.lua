-- Atajos. Son los mismos que en i3 (config/i3/config) para que dé igual en
-- qué sesión estés; donde Hyprland funciona distinto está explicado al lado.
-- Super es la tecla de Windows.
--
-- Los scripts y menús son los mismos de i3: viven en ~/.config/i3/scripts
-- y ~/.config/rofi/scripts, y cada uno sabe en qué sesión está.
--
-- Cada atajo lleva su descripción (el tercer argumento de «tecla»). No es
-- decoración: la chuleta (Super+F1) la lee con «hyprctl binds» y la usa
-- tal cual, así que si cambias un atajo aquí, la chuleta ya lo sabe. Las
-- frases son las mismas que en la chuleta de i3 para que se agrupen igual.

local SUPER = "SUPER"
local ALT   = "ALT"

local terminal = "~/.config/i3/scripts/terminal"
local i3s      = "~/.config/i3/scripts/"
local rofis    = "~/.config/rofi/scripts/"
local hyprs    = "~/.config/hypr/scripts/"

local function tecla(combinacion, accion, descripcion, opciones)
    opciones = opciones or {}
    opciones.description = descripcion
    hl.bind(combinacion, accion, opciones)
end
local function ejecutar(cmd) return hl.dsp.exec_cmd(cmd) end


-- ── lo esencial: abrir, cerrar, lanzar ─────────────────────────────────
tecla(SUPER .. " + Return",         ejecutar(terminal),            "Abrir terminal")
tecla(SUPER .. " + T",              ejecutar(terminal),            "Abrir terminal")
tecla(SUPER .. " + SHIFT + Return", ejecutar(terminal .. " --max"), "Terminal maximizado")

tecla(SUPER .. " + SHIFT + Q", hl.dsp.window.close(), "Cerrar la ventana")
tecla(ALT   .. " + F4",        hl.dsp.window.close(), "Cerrar la ventana")

tecla(SUPER .. " + D",     ejecutar("rofi -show drun"), "Lanzador de apps")
tecla(SUPER .. " + space", ejecutar("rofi -show drun"), "Lanzador de apps")

tecla(SUPER .. " + B", ejecutar("firefox"), "Navegador")
tecla(SUPER .. " + N", ejecutar("thunar"),  "Gestor de archivos")
-- Como xkill: el puntero se vuelve una calavera y cierras a la fuerza la
-- ventana en la que hagas clic. Escape para salir sin matar nada.
tecla(SUPER .. " + Escape", ejecutar("hyprctl kill"), "Matar ventana a ratón")


-- ── ayuda y utilidades (menús de rofi) ───────────────────────────────────
tecla(SUPER .. " + F1",         ejecutar(i3s .. "chuleta-ventana"),    "Esta chuleta")
tecla(SUPER .. " + SHIFT + F1", ejecutar(i3s .. "chuleta --buscar"),   "Buscar un atajo")
tecla(SUPER .. " + I",          ejecutar(i3s .. "ia"),                 "Preguntar a la IA local")
tecla(SUPER .. " + U",          ejecutar(rofis .. "utilidades"),       "Menú de utilidades")
tecla(SUPER .. " + X",          ejecutar(rofis .. "calculadora"),      "Calculadora")
tecla(SUPER .. " + period",     ejecutar(rofis .. "emojis"),           "Emojis y símbolos")
tecla(SUPER .. " + O",          ejecutar(rofis .. "archivos"),         "Buscar archivos")
tecla(SUPER .. " + SHIFT + N",  ejecutar(rofis .. "notificaciones"),   "Notificaciones")
tecla(SUPER .. " + SHIFT + P",  ejecutar(hyprs .. "fondo --pausar"),   "Pausar el fondo animado")


-- ── foco y mover ─────────────────────────────────────────────────────────
-- hjkl (estilo vim) y flechas
local direcciones = {
    { "H", "left", "a la izquierda" },  { "J", "down", "abajo" },
    { "K", "up", "arriba" },            { "L", "right", "a la derecha" },
    { "left", "left", "a la izquierda" }, { "down", "down", "abajo" },
    { "up", "up", "arriba" },             { "right", "right", "a la derecha" },
}
for _, d in ipairs(direcciones) do
    tecla(SUPER .. " + " .. d[1],         hl.dsp.focus({ direction = d[2] }),       "Foco " .. d[3])
    tecla(SUPER .. " + SHIFT + " .. d[1], hl.dsp.window.move({ direction = d[2] }), "Mover " .. d[3])
end

-- Alt+Tab pasa de una ventana a otra del escritorio y la trae delante.
-- (La vista con miniaturas, como skippy-xd en i3, llega en la fase 3.)
tecla(ALT .. " + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end, "Cambiar de ventana")
tecla(ALT .. " + SHIFT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
    hl.dispatch(hl.dsp.window.bring_to_top())
end, "Ventana anterior")
tecla(SUPER .. " + Tab", ejecutar("rofi -show window"), "Lista de ventanas")


-- ── colocar ventanas ─────────────────────────────────────────────────────
tecla(SUPER .. " + C", hl.dsp.window.center(), "Centrar la flotante")

-- Dividir: como en i3, se dice antes de abrir hacia dónde irá la siguiente
-- ventana. V = la próxima va debajo, Shift+V = al lado. E cambia la
-- división de la ventana actual entre vertical y horizontal.
tecla(SUPER .. " + V",         hl.dsp.layout("preselect d"), "Siguiente ventana debajo")
tecla(SUPER .. " + SHIFT + V", hl.dsp.layout("preselect r"), "Siguiente ventana al lado")
tecla(SUPER .. " + E",         hl.dsp.layout("togglesplit"), "Cambiar la división")

-- Pestañas. En i3 son "tabbed" (W) y "stacking" (S); en Hyprland las dos
-- cosas son un grupo: W mete la ventana en un grupo o lo deshace, y S
-- pasa a la siguiente pestaña del grupo.
tecla(SUPER .. " + W", hl.dsp.group.toggle(), "Apilar en pestañas")
tecla(SUPER .. " + S", hl.dsp.group.next(),   "Siguiente pestaña")

tecla(SUPER .. " + F",             hl.dsp.window.fullscreen(),                       "Pantalla completa")
tecla(SUPER .. " + M",             hl.dsp.window.fullscreen({ mode = "maximized" }), "Maximizar sin tapar la barra")
tecla(SUPER .. " + SHIFT + space", hl.dsp.window.float(),                            "Soltar del mosaico")

-- Minimizar: en i3 va al scratchpad; aquí, al escritorio especial
-- "minimizadas", que se enseña y se esconde encima de cualquier otro.
tecla(SUPER .. " + SHIFT + M",     hl.dsp.window.move({ workspace = "special:minimizadas" }), "Apartar (minimizar)")
tecla(SUPER .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:minimizadas" }), "Apartar (minimizar)")
tecla(SUPER .. " + minus",         hl.dsp.workspace.toggle_special("minimizadas"),            "Recuperar la apartada")


-- ── redimensionar (Super+R, y luego flechas o hjkl) ─────────────────────
tecla(SUPER .. " + R", hl.dsp.submap("redimensionar"), "Modo redimensionar")
hl.define_submap("redimensionar", function()
    local paso = 40
    local cambios = {
        { "H", -paso, 0, "Estrechar" }, { "L", paso, 0, "Ensanchar" },
        { "K", 0, -paso, "Encoger" },   { "J", 0, paso, "Estirar" },
        { "left", -paso, 0, "Estrechar" }, { "right", paso, 0, "Ensanchar" },
        { "up", 0, -paso, "Encoger" },     { "down", 0, paso, "Estirar" },
    }
    for _, k in ipairs(cambios) do
        hl.bind(k[1], hl.dsp.window.resize({ x = k[2], y = k[3], relative = true }),
                { repeating = true, description = k[4] })
    end
    -- Cualquiera de estas tres saca del modo
    hl.bind("Return",        hl.dsp.submap("reset"), { description = "Salir del modo" })
    hl.bind("Escape",        hl.dsp.submap("reset"), { description = "Salir del modo" })
    hl.bind(SUPER .. " + R", hl.dsp.submap("reset"), { description = "Salir del modo" })
end)


-- ── escritorios ──────────────────────────────────────────────────────────
-- Super+número va al escritorio; Super+Shift+número manda la ventana allí
-- sin moverte (como "move container to workspace" en i3). Con varias
-- pantallas, cada escritorio es el conjunto de todas y cambian a la vez:
-- la lógica está en sigilo/escritorios.lua.
for i = 1, 10 do
    local tecla_num = tostring(i % 10)   -- el 10 es la tecla 0
    tecla(SUPER .. " + " .. tecla_num,         function() sigilo.ir(i) end,     "Ir al escritorio " .. i)
    tecla(SUPER .. " + SHIFT + " .. tecla_num, function() sigilo.llevar(i) end, "Llevar al escritorio " .. i)
end
tecla(SUPER .. " + CTRL + right", function() sigilo.siguiente(1) end,  "Escritorio siguiente")
tecla(SUPER .. " + CTRL + left",  function() sigilo.siguiente(-1) end, "Escritorio previo")
tecla(SUPER .. " + grave",        function() sigilo.volver() end,      "Escritorio anterior")
-- Cierra todas las ventanas del escritorio (en todas las pantallas) y salta
-- al más cercano que tenga algo abierto. Lo mismo que i3/scripts/cerrar-escritorio.
tecla(SUPER .. " + CTRL + Q",     function() sigilo.cerrar() end,      "Cerrar el escritorio entero")


-- ── sesión ───────────────────────────────────────────────────────────────
tecla(SUPER .. " + SHIFT + C", ejecutar("hyprctl reload"), "Recargar config")
-- En i3 esto reinicia i3. Aquí recarga la configuración y relanza la barra
tecla(SUPER .. " + SHIFT + R", ejecutar("hyprctl reload; ~/.config/waybar/lanzar"), "Recargar config y barra")
tecla(SUPER .. " + SHIFT + X", ejecutar("loginctl lock-session"), "Bloquear pantalla")

tecla(SUPER .. " + SHIFT + E", ejecutar(rofis .. "apagado"),      "Menú de sesión")
tecla(SUPER .. " + SHIFT + W", ejecutar(rofis .. "wifi"),         "Redes wifi")
tecla(SUPER .. " + SHIFT + B", ejecutar(rofis .. "bluetooth"),    "Bluetooth")
tecla(SUPER .. " + SHIFT + O", ejecutar(rofis .. "sonido"),       "Salida y micro de sonido")
tecla(SUPER .. " + SHIFT + F", ejecutar(rofis .. "fondos"),       "Fondos de pantalla")
tecla(SUPER .. " + P",         ejecutar(rofis .. "portapapeles"), "Portapapeles")

-- Modo prueba (ver scripts/vigilante): confirma que la pantalla va bien
-- para que la sesión no se cierre sola a los 45 segundos
tecla(SUPER .. " + ALT + Return",
      ejecutar("touch \"$XDG_RUNTIME_DIR/hypr-prueba-ok\" && notify-send 'Hyprland' 'Confirmado: la sesión se queda abierta'"),
      nil)   -- sin descripción: no sale en la chuleta


-- ── teclas multimedia ────────────────────────────────────────────────────
-- "locked" = también funcionan con la pantalla bloqueada
local vb = i3s .. "volumen-brillo "
local function rep() return { locked = true, repeating = true } end
local function bloq() return { locked = true } end
tecla("XF86AudioRaiseVolume",  ejecutar(vb .. "volume_up"),       "Subir volumen",   rep())
tecla("XF86AudioLowerVolume",  ejecutar(vb .. "volume_down"),     "Bajar volumen",   rep())
tecla("XF86AudioMute",         ejecutar(vb .. "volume_mute"),     "Silenciar",       bloq())
tecla("XF86AudioMicMute",      ejecutar(vb .. "mic_mute"),        "Silenciar micro", bloq())
tecla("XF86MonBrightnessUp",   ejecutar(vb .. "brightness_up"),   "Subir brillo",    rep())
tecla("XF86MonBrightnessDown", ejecutar(vb .. "brightness_down"), "Bajar brillo",    rep())

tecla("XF86AudioPlay",  ejecutar("playerctl play-pause"), "Reproducir / pausa", bloq())
tecla("XF86AudioPause", ejecutar("playerctl play-pause"), "Reproducir / pausa", bloq())
tecla("XF86AudioNext",  ejecutar("playerctl next"),       "Pista siguiente",    bloq())
tecla("XF86AudioPrev",  ejecutar("playerctl previous"),   "Pista anterior",     bloq())


-- ── capturas ─────────────────────────────────────────────────────────────
-- El mismo script que en i3: en Wayland usa grim y slurp
tecla("Print",                 ejecutar(i3s .. "captura full"), "Captura completa")
tecla(SUPER .. " + SHIFT + S", ejecutar(i3s .. "captura sel"),  "Captura con selección")


-- ── ratón ────────────────────────────────────────────────────────────────
-- Super + botón izquierdo arrastra, Super + botón derecho redimensiona,
-- tanto flotantes como en mosaico (tiling_drag de i3)
tecla(SUPER .. " + mouse:272", hl.dsp.window.drag(),   "Mover con el ratón",        { mouse = true })
tecla(SUPER .. " + mouse:273", hl.dsp.window.resize(), "Redimensionar con el ratón", { mouse = true })
-- Super + botón central abre el menú de la ventana (cerrar, minimizar,
-- maximizar, soltar del mosaico, llevar a otro escritorio). En i3 además
-- el clic derecho en el borde lo abría, pero Hyprland no deja atar clics
-- al borde de las ventanas.
tecla(SUPER .. " + mouse:274", ejecutar(rofis .. "ventana"), "Menú de la ventana")
