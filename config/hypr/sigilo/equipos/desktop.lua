-- Sobremesa (Z390 + RTX 3070): tres pantallas.
--
--   izquierda  1440p a 240 Hz     centro  1440p a 240 Hz (la principal)
--   derecha    1080p a 144 Hz, bajada 360 px para que quede centrada
--
-- Cada pantalla se reconoce por su descripción (marca, modelo y número de
-- serie), así da igual a qué puerto de la gráfica vaya enchufada. Para
-- verlas:  hyprctl monitors all | grep -E '^Monitor|description'
-- Las dos Gigabyte son el mismo modelo; solo cambia el número de serie.
--
-- La principal es la del centro: ahí va la barra (waybar se pone en la
-- pantalla del escritorio 1).

local IZQUIERDA = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. GS27Q X 25312B600425"
local CENTRO    = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. GS27Q X 25312B600417"
local DERECHA   = "desc:NSL ICARUS-F24 0x00000001"

local function pantalla(salida, modo, posicion)
    hl.monitor({ output = salida, mode = modo, position = posicion, scale = 1 })
end

-- Cada una a su frecuencia buena desde el principio. (Los cuelgues al
-- entrar de las primeras pruebas no eran por esto sino por lightdm; ver
-- sistema/hyprland/sigilo-hyprland.)
pantalla(IZQUIERDA, "2560x1440@240", "0x0")
pantalla(CENTRO,    "2560x1440@240", "2560x0")
pantalla(DERECHA,   "1920x1080@144", "5120x360")

-- Cuál es la principal: la que lleva la barra y los escritorios 1…10. El
-- resto del reparto lo deduce solo sigilo/escritorios.lua, ordenándolas de
-- izquierda a derecha, así que aquí no hay que enumerarlas. Sin esta línea
-- la principal sería la de la izquierda.
sigilo = sigilo or {}
sigilo.principal = CENTRO
