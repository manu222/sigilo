-- Reglas de ventanas: las mismas "for_window" de i3.
-- En Wayland la "clase" de muchas apps cambia (pavucontrol pasa a llamarse
-- org.pulseaudio.pavucontrol, por ejemplo), así que donde hace falta se
-- aceptan los dos nombres. Para ver cómo se llama una ventana:
--     hyprctl clients | grep -E 'class|title'

local function flotante(nombre, match, extra)
    local regla = { name = nombre, match = match, float = true, center = true }
    for k, v in pairs(extra or {}) do regla[k] = v end
    hl.window_rule(regla)
end

-- Diálogos y utilidades que no pintan nada en mosaico
flotante("mezclador",     { class = "^(pavucontrol|org\\.pulseaudio\\.pavucontrol)$" }, { size = { 800, 600 } })
flotante("bluetooth",     { class = "^(blueman-manager|\\.blueman-manager-wrapped)$" })
flotante("editor-de-red", { class = "^(nm-connection-editor)$" })
flotante("calculadora",   { class = "^(galculator)$" })
flotante("visor",         { class = "^(imv)$" },          { size = { 1500, 920 } })

-- Ventanas que abren los scripts de Sigilo con un título fijo
flotante("chuleta", { title = "^chuleta-i3$" }, { border_size = 0 })
flotante("btop",    { title = "^btop$" },       { size = { 1180, 760 } })
flotante("redes",   { title = "^Redes$" },      { size = { 820, 560 } })
flotante("ia",      { title = "^IA local$" },   { size = { 1040, 720 } })

-- El menú de aplicaciones (config/sigilo/menu-apps): flotante, pegado
-- debajo del botón Apps de la barra y sin borde ni sombra, que ya se
-- dibuja él su propio marco
-- Se busca por clase y también por título: según la sesión (Wayland o
-- XWayland) GTK la anuncia de una forma o de otra.
hl.window_rule({
    name  = "menu-apps",
    match = { class = "^([Mm]enu-apps)$" },
    float = true, move = { 50, 76 }, border_size = 0, no_shadow = true, rounding = 14,
})
hl.window_rule({
    name  = "menu-apps-titulo",
    match = { title = "^menu-apps$" },
    float = true, move = { 50, 76 }, border_size = 0, no_shadow = true, rounding = 14,
})

-- GTK dice cómo se llama la ventana un instante DESPUÉS de abrirla, y para
-- entonces Hyprland ya ha decidido si flota y dónde (eso se mira una sola
-- vez, al abrirse). Por eso se vuelve a colocar en cuanto se sabe el
-- nombre: se suelta del mosaico y se pega bajo el botón Apps de su
-- pantalla. Sin esto salía en medio y, al ir abriendo columnas, se metía
-- en la pantalla de al lado.
hl.on("window.class", function(v)
    if not v or v.class ~= "menu-apps" then return end
    hl.dispatch(hl.dsp.window.float({ window = v, action = "enable" }))
    local m = v.monitor
    hl.dispatch(hl.dsp.window.move({
        window = v, relative = false,
        x = (m and m.x or 0) + 50,
        y = (m and m.y or 0) + 76,
    }))
end)

-- Ventanita de vídeo de Firefox: flotante y visible en todos los escritorios
hl.window_rule({
    name  = "imagen-en-imagen",
    match = { title = "^(Picture-in-Picture|Imagen en imagen)$" },
    float = true, pin = true, keep_aspect_ratio = true,
})

-- Sin transparencia en los navegadores ni a pantalla completa (lo mismo
-- que opacity-rule en picom): un vídeo o una web medio transparentes
-- cansan la vista.
hl.window_rule({
    name    = "opacos",
    match   = { class = "^(firefox|brave-browser|Brave-browser|chromium|Chromium)$" },
    opacity = "1.0 override 1.0 override",
})
hl.window_rule({
    name    = "opaco-a-pantalla-completa",
    match   = { fullscreen = true },
    opacity = "1.0 override 1.0 override",
})

-- El botón de maximizar de las apps funciona: Hyprland maximiza sin tapar
-- la barra, igual que Super+M. (En i3 esto lo hacía botones-ventana.) El de
-- minimizar no hace nada: Hyprland no tiene ventanas minimizadas; para
-- apartar una está Super+Shift+M o el menú de ventana (Super + clic central).

-- Arreglo de la wiki de Hyprland: algunas apps X11 abren una ventana
-- invisible al arrastrar cosas y se queda con el foco
hl.window_rule({
    name     = "arrastres-xwayland",
    match    = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Si hay algo a pantalla completa (un juego, un vídeo), la pantalla no se
-- bloquea ni se apaga sola
hl.window_rule({
    name         = "sin-reposo-a-pantalla-completa",
    match        = { class = ".*" },
    idle_inhibit = "fullscreen",
})
