-- Paleta Sigilo, la misma de i3, polybar, rofi y el tema de VS Code.
-- Si cambias un color aquí, cámbialo también en ~/.config/waybar/style.css
-- y en ~/.config/hypr/hyprlock.conf, que no pueden leer este fichero.
--
-- Hyprland acepta los colores como "rgb(rrggbb)" o "rgba(rrggbbaa)".

local c = {
    fondo      = "070b09",   -- lo más oscuro: fondo de escritorio sin imagen
    fondo_alt  = "0a0f0d",
    pildora    = "15201c",   -- fondo de las píldoras de la barra
    linea      = "1a2320",   -- bordes de las ventanas sin foco
    texto      = "e7edea",
    apagado    = "70837c",   -- texto secundario
    menta      = "34d399",   -- acento: lo activo
    menta_viva = "3ee8a8",   -- borde de la ventana con el foco
    lila       = "c8aae5",   -- selección y detalles
    lila_osc   = "b79ad4",
    lila_fondo = "2c2342",
    ambar      = "c99d6b",
    rojo       = "e0777d",   -- urgente
}

-- Atajos para no escribir "rgb(" cada vez
function c.rgb(nombre)            return "rgb(" .. c[nombre] .. ")" end
function c.rgba(nombre, alfa)     return "rgba(" .. c[nombre] .. alfa .. ")" end

return c
