-- Pantallas.
--
-- Regla general, válida para cualquier equipo: cada pantalla a su
-- resolución nativa con la frecuencia más alta que admita, colocadas una
-- detrás de otra. Las que conozcamos se colocan a mano en el fichero de su
-- equipo, en sigilo/equipos/<nombre del equipo>.lua, que se carga solo si
-- existe. Así el mismo repositorio sirve en el sobremesa, en el portátil y
-- en un equipo nuevo sin tocar nada.
--
-- Para ver cómo se llama cada pantalla y qué modos admite:
--     hyprctl monitors all

hl.monitor({
    output   = "",           -- vacío = cualquier pantalla sin regla propia
    mode     = "highrr",     -- la frecuencia más alta a la mayor resolución
    position = "auto",
    scale    = 1,
})

-- VRR (FreeSync / G-Sync compatible) solo a pantalla completa: en juegos y
-- vídeos va perfecto, y en el escritorio normal evita el parpadeo que da
-- en algunos monitores cuando la frecuencia sube y baja con cada cosa que
-- se mueve.
-- De momento apagado (0) mientras se pone a punto el sobremesa. Cuando todo
-- vaya fino se puede probar a ponerlo en 2.
hl.config({ misc = { vrr = 0 } })

-- Fichero propio del equipo, si lo hay
local f = io.open("/etc/hostname", "r")
local equipo = f and f:read("l") or ""
if f then f:close() end
equipo = equipo:gsub("%s+", "")
if equipo ~= "" then
    local ok, err = pcall(require, "sigilo.equipos." .. equipo)
    if not ok and not tostring(err):find("not found") then
        print("pantallas: error en equipos/" .. equipo .. ".lua: " .. tostring(err))
    end
end
