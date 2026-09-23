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
-- 0 = apagado · 1 = siempre · 2 = solo a pantalla completa.
-- Si en algún equipo se ve parpadeo, se pone a 0.
hl.config({ misc = { vrr = 2 } })

-- Fichero propio del equipo, si lo hay. Solo hace falta para clavar la
-- resolución, la frecuencia y la posición de unas pantallas concretas, y
-- para decir cuál es la principal. Lo demás (el reparto de escritorios
-- entre pantallas) se deduce solo, con las que haya.
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
