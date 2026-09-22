-- Aspecto: lo mismo que en i3 + picom, pero hecho por el propio compositor.
-- En i3 las esquinas, sombras y transparencias las pone picom; aquí salen
-- directamente de Hyprland y además hay desenfoque detrás de lo translúcido.

local c = require("sigilo.colores")

hl.config({
    general = {
        -- Sin huecos entre ventanas, como en i3: se aprovecha toda la
        -- pantalla. El hueco de arriba para la barra lo reserva waybar sola.
        gaps_in  = 0,
        gaps_out = 0,

        border_size = 2,
        col = {
            active_border   = c.rgb("menta_viva"),
            inactive_border = c.rgb("linea"),
        },

        -- En i3 las flotantes llevan un borde de 5 px para poder agarrarlas.
        -- Aquí no hace falta: se agarra desde 15 px alrededor del borde fino.
        resize_on_border        = true,
        extend_border_grab_area = 15,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 8,      -- lo mismo que corner-radius en picom.conf
        rounding_power = 2,

        -- Las ventanas sin foco se apagan un poco (inactive-opacity de picom).
        -- Los navegadores y lo que va a pantalla completa se libran en reglas.lua
        active_opacity   = 1.0,
        inactive_opacity = 0.92,

        -- La sombra de picom: radio 22, opacidad 0.60, y desplazada 8 px
        -- hacia abajo (en picom.conf: shadow-offset-y = -14 con radio 22)
        shadow = {
            enabled      = true,
            range        = 22,
            render_power = 3,
            color        = "rgba(00000099)",
            offset       = "0 8",
        },

        -- Desenfoque detrás de todo lo translúcido: kitty, las ventanas sin
        -- foco y, con las reglas de capa de abajo, la barra, rofi y dunst.
        blur = {
            enabled           = true,
            size              = 6,
            passes            = 2,
            new_optimizations = true,
            vibrancy          = 0.17,
            popups            = true,
        },
    },

    -- Pestañas (lo que en i3 es "layout tabbed"). En i3 la pestaña activa
    -- es oscura (#0a0f0d) con el texto claro y el borde menta, y las demás
    -- más oscuras (#070b09) con el texto apagado. Aquí se imita: sin relleno
    -- de color, texto claro/apagado y una rayita menta bajo la activa.
    group = {
        col = {
            border_active          = c.rgb("menta_viva"),
            border_inactive        = c.rgb("linea"),
            border_locked_active   = c.rgb("lila"),
            border_locked_inactive = c.rgb("linea"),
        },
        groupbar = {
            font_family         = "JetBrainsMono Nerd Font",
            font_size           = 10,
            height              = 18,
            gradients           = false,
            indicator_height    = 2,
            rounding            = 1,
            text_color          = c.rgb("texto"),
            text_color_inactive = c.rgb("apagado"),
            col = {
                active          = c.rgb("menta_viva"),
                inactive        = c.rgb("linea"),
                locked_active   = c.rgb("lila"),
                locked_inactive = c.rgb("linea"),
            },
        },
    },

    misc = {
        -- Nada de logo ni frases de Hyprland: sin fondo de pantalla se ve
        -- el color de fondo de Sigilo
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        background_color         = "rgb(" .. c.fondo .. ")",
    },

    dwindle = {
        -- Que Super+E (cambiar división) funcione y se respete
        preserve_split = true,
    },

    animations = { enabled = true },
})

-- ── animaciones ─────────────────────────────────────────────────────────
-- Cortas y sin rebotes: que acompañen, no que se hagan esperar. La
-- velocidad va en décimas de segundo (1.6 = 160 ms, lo mismo que en picom).
hl.curve("sigilo",  { type = "bezier", points = { {0.2, 0.9}, {0.1, 1} } })
-- Muelle para los menús: crecen de más y se asientan con un rebote corto,
-- como una tela que se estira y se queda quieta
-- (en Hyprland 0.56 el parámetro se llama "dampening"; en las versiones
-- nuevas pasa a llamarse "damping")
hl.curve("muelle",  { type = "spring", mass = 1, stiffness = 260, dampening = 18 })
hl.curve("suave",   { type = "bezier", points = { {0.25, 1},  {0.5, 1} } })
hl.curve("lineal",  { type = "bezier", points = { {0, 0},     {1, 1}   } })

hl.animation({ leaf = "global",        enabled = true, speed = 4,   bezier = "sigilo" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 1.6, bezier = "sigilo", style = "popin 94%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.3, bezier = "suave",  style = "popin 94%" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 2.2, bezier = "sigilo" })
hl.animation({ leaf = "border",        enabled = true, speed = 3,   bezier = "suave" })
hl.animation({ leaf = "fade",          enabled = true, speed = 2,   bezier = "suave" })
-- Menús, rejilla de apps y notificaciones (las "capas"). Elegido en el
-- muestrario: 280 ms al abrir. Cada capa lleva su estilo en las reglas de
-- abajo (los menús crecen, las notificaciones entran por la derecha).
hl.animation({ leaf = "layersIn",      enabled = true, speed = 2.8, spring = "muelle", style = "popin 40%" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 2.2, bezier = "suave",   style = "popin 40%" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 2.8, bezier = "suave" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.2, bezier = "suave" })
-- Cambiar de escritorio desliza de lado; el escritorio especial baja de arriba
hl.animation({ leaf = "workspaces",    enabled = true, speed = 2.6, bezier = "sigilo", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.4, bezier = "sigilo", style = "slidevert" })

-- ── bordes como en i3 ────────────────────────────────────────────────────
-- hide_edge_borders smart: si en el escritorio solo hay una ventana en
-- mosaico, no lleva borde (no hace falta marcar cuál tiene el foco)
hl.window_rule({
    name        = "sin-borde-si-esta-sola",
    match       = { float = false, workspace = "w[tv1]" },
    border_size = 0,
})

-- client.urgent de i3: la ventana que pide atención lleva el borde en rojo
-- hasta que la miras
local urgentes = {}
hl.on("window.urgent", function(v)
    if not v then return end
    urgentes[v.address] = true
    hl.dispatch(hl.dsp.window.set_prop({ window = v, prop = "inactive_border_color", value = c.rgb("rojo") }))
end)
hl.on("window.active", function(v)
    if not v or not urgentes[v.address] then return end
    urgentes[v.address] = nil
    hl.dispatch(hl.dsp.window.set_prop({ window = v, prop = "inactive_border_color", value = c.rgb("linea") }))
end)

-- ── desenfoque en las capas (lo que no son ventanas) ──────────────────────
-- ignore_alpha evita que se desenfoque el hueco transparente alrededor de
-- las píldoras y los menús: solo se desenfoca lo que se ve.
hl.layer_rule({ name = "barra",           match = { namespace = "waybar" },        blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ name = "rofi",            match = { namespace = "rofi" },          blur = true, ignore_alpha = 0.3,
                animation = "popin 40%" })
hl.layer_rule({ name = "notificaciones",  match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.3,
                animation = "slide right" })
hl.layer_rule({ name = "rejilla-de-apps", match = { namespace = "nwg-drawer" },    blur = true, ignore_alpha = 0.3,
                animation = "popin 40%" })
-- El menú de aplicaciones ya es opaco: no necesita desenfoque, y así no se
-- ve el fondo de pantalla a través de él
hl.layer_rule({ name = "menu-apps",       match = { namespace = "menu-apps" },     blur = false,
                animation = "popin 70%" })
