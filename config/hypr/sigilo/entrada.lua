-- Teclado, ratón y foco.

hl.config({
    input = {
        kb_layout          = "es",
        numlock_by_default = true,   -- en i3 lo hace numlockx

        -- Como "focus_follows_mouse no" en i3: mover el ratón no cambia el
        -- foco del teclado, hay que hacer clic. Con el 2, además, la rueda
        -- sí va a la ventana que hay debajo del ratón aunque no tenga foco.
        follow_mouse = 2,

        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
        },
    },

    binds = {
        -- Pulsar el número del escritorio en el que ya estás te lleva al
        -- anterior (workspace_auto_back_and_forth de i3)
        workspace_back_and_forth = true,
    },

    cursor = {
        -- Oculta el puntero al escribir y vuelve en cuanto se mueve el ratón
        hide_on_key_press = true,
    },

    misc = {
        -- Cuando una app pide paso (pinchas un enlace en Discord y tiene que
        -- salir el navegador), que se venga al frente y se lleve el foco. Es
        -- lo que hace i3 con focus_on_window_activation; Hyprland viene con
        -- esto apagado y las ventanas se quedaban parpadeando en la barra.
        focus_on_activate = true,
    },
})

-- Tres dedos en el touchpad cambian de escritorio (en el sobremesa no
-- hace nada, en un portátil viene bien)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
