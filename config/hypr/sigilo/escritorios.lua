-- Escritorios "juntos": con varias pantallas, cada número es el conjunto
-- de todas. Super+2 cambia las tres pantallas a la vez, como en GNOME o
-- KDE, en vez de cambiar solo la que tiene el foco.
--
-- Cómo se consigue: Hyprland solo sabe de escritorios por pantalla, así que
-- cada pantalla tiene su propia decena de escritorios y aquí se mueven
-- juntos:
--
--     escritorio   principal   segunda   tercera   …
--         1            1          11        21
--         2            2          12        22
--        …             …           …         …
--
-- El orden de las pantallas no se escribe en ningún sitio: se deduce de lo
-- que diga Hyprland, de izquierda a derecha. Da igual que el equipo tenga
-- una, dos o cinco, y si enchufas o quitas una por el camino se recalcula
-- solo. Lo único que se puede decir a mano es cuál es la principal —la que
-- lleva la barra y los escritorios 1…10— poniendo «sigilo.principal» en el
-- fichero del equipo; si no se dice nada, es la de más a la izquierda.
--
-- La barra solo enseña 1…10 y junta los iconos de todas las pantallas.
-- Con una sola pantalla no hay nada que agrupar y todo funciona como
-- siempre, un escritorio por número.
--
-- Las funciones van en la tabla global «sigilo» para que atajos.lua y la
-- barra (con «hyprctl eval 'sigilo.ir(3)'») puedan usarlas.

sigilo = sigilo or {}
local S = sigilo
local POR_PANTALLA = 10

-- ¿Este monitor es el que describe «sel»? (un nombre como DP-1 o "desc:…")
local function coincide(m, sel)
    if sel:sub(1, 5) == "desc:" then
        local d = sel:sub(6)
        return (m.description or ""):sub(1, #d) == d
    end
    return m.name == sel
end

-- Las pantallas en orden: de izquierda a derecha por dónde están puestas,
-- y la principal la primera de todas. Se pregunta cada vez en vez de
-- guardarlo, que sale gratis y así enchufar o quitar una pantalla no deja
-- nada desparejado.
local function orden()
    local ms = hl.get_monitors() or {}
    table.sort(ms, function(a, b)
        if a.x ~= b.x then return a.x < b.x end
        return a.y < b.y
    end)
    if S.principal then
        for i, m in ipairs(ms) do
            if coincide(m, S.principal) then
                table.insert(ms, 1, table.remove(ms, i))
                break
            end
        end
    end
    return ms
end

-- Posición de un monitor en ese orden (1 = principal), o nil
local function posicion(m, ms)
    if not m then return nil end
    for i, o in ipairs(ms or orden()) do
        if o.name == m.name then return i end
    end
    return nil
end

local function juntos() return #(hl.get_monitors() or {}) > 1 end

-- Se escribe más abajo (hace falta S.id), pero se anuncia aquí porque S.ir
-- la usa antes: en Lua un «local» solo existe a partir de donde se declara
local repartir

-- Número de escritorio (1…10) de un id de Hyprland, y al revés
function S.numero(id) return ((id - 1) % POR_PANTALLA) + 1 end
function S.id(n, pos) return n + ((pos or 1) - 1) * POR_PANTALLA end

-- El escritorio en el que estás y el anterior (para Super+` y para volver
-- al pulsar dos veces el mismo número). Los lleva al día el vigilante de
-- más abajo, así que también cuentan los cambios que no pasan por aquí.
S.ultimo   = S.ultimo or 1
S.anterior = S.anterior or 1

local function actual()
    local ws = hl.get_active_workspace()
    if not ws or ws.id < 1 then return S.ultimo end
    return S.numero(ws.id)
end

-- Mientras se cambian las pantallas desde aquí, el vigilante no interviene
local moviendo = false

-- Pone el escritorio n en todas las pantallas menos en «salvo» (la que ya
-- lo tiene o lo va a tener). OJO: cambiar el escritorio de otra pantalla le da el foco a esa
-- pantalla (así lo hace Hyprland), por eso quien llama a esto tiene que
-- devolver el foco a su sitio justo después.
local function igualar_las_demas(n, salvo)
    moviendo = true
    for pos, m in ipairs(orden()) do
        if not salvo or m.name ~= salvo.name then
            local ws = m.active_workspace
            if not ws or ws.id < 1 or S.numero(ws.id) ~= n then
                m:set_workspace({ workspace = S.id(n, pos) })
            end
        end
    end
    moviendo = false
end

-- Ir al escritorio n en todas las pantallas. Pulsar el número del que ya
-- estás te lleva al anterior (como workspace_auto_back_and_forth en i3).
function S.ir(n)
    repartir()          -- por si has enchufado o quitado una pantalla
    if not juntos() then
        hl.dispatch(hl.dsp.focus({ workspace = n }))
        return
    end
    local ahora = actual()
    if n == ahora then n = S.anterior end
    if n == ahora then return end
    local enfocada = hl.get_active_monitor()
    -- Primero las demás pantallas y la tuya la última, que es la que se
    -- queda con el foco
    igualar_las_demas(n, enfocada)
    hl.dispatch(hl.dsp.focus({ workspace = S.id(n, posicion(enfocada)) }))
end

-- Mandar la ventana con el foco al escritorio n, en la misma pantalla
function S.llevar(n)
    local pos = juntos() and posicion(hl.get_active_monitor()) or 1
    hl.dispatch(hl.dsp.window.move({ workspace = S.id(n, pos), follow = false }))
end

-- Números con alguna ventana abierta (en cualquier pantalla), más el actual
local function ocupados()
    local hay = { [actual()] = true }
    for _, w in ipairs(hl.get_workspaces() or {}) do
        if w.id > 0 and (w.windows or 0) > 0 then hay[S.numero(w.id)] = true end
    end
    local lista = {}
    for n in pairs(hay) do lista[#lista + 1] = n end
    table.sort(lista)
    return lista
end

-- Siguiente o anterior escritorio con algo abierto (Super+Ctrl+→/←)
function S.siguiente(paso)
    local lista, ahora = ocupados(), actual()
    for i, n in ipairs(lista) do
        if n == ahora then
            local destino = lista[((i - 1 + paso) % #lista) + 1]
            if destino ~= ahora then S.ir(destino) end
            return
        end
    end
end

function S.volver() S.ir(S.anterior) end

-- Cerrar el escritorio entero (todas sus ventanas, en todas las pantallas)
-- y saltar al más cercano que tenga algo abierto; si empatan, el de la
-- izquierda, como al cerrar una pestaña.
function S.cerrar()
    local ahora = actual()
    for _, w in ipairs(hl.get_workspaces() or {}) do
        if w.id > 0 and S.numero(w.id) == ahora then
            for _, v in ipairs(hl.get_workspace_windows(w) or {}) do
                hl.dispatch(hl.dsp.window.close({ window = v }))
            end
        end
    end
    local destino, mejor = nil, math.huge
    for _, n in ipairs(ocupados()) do
        local d = math.abs(n - ahora)
        if n ~= ahora and (d < mejor or (d == mejor and n < ahora)) then
            destino, mejor = n, d
        end
    end
    if destino then S.ir(destino) end
end

-- Vigilante: si el escritorio cambia en una sola pantalla por otro camino
-- (la lista de ventanas de Super+Tab, una app que pide atención, arrastrar
-- una ventana…), las demás se ponen en el mismo número para que nunca se
-- queden desparejadas. Y apunta el escritorio anterior.
hl.on("workspace.active", function(ws)
    if moviendo or not ws or ws.id < 1 then return end
    local n = S.numero(ws.id)
    if n ~= S.ultimo then
        S.anterior, S.ultimo = S.ultimo, n
    end
    if not juntos() then return end
    local enfocada = hl.get_active_monitor()
    local ventana = hl.get_active_window()
    local hacia_falta = false
    for _, m in ipairs(orden()) do
        local otro = m.active_workspace
        if otro and otro.id > 0 and S.numero(otro.id) ~= n then
            hacia_falta = true
        end
    end
    if not hacia_falta then return end
    -- Se igualan todas menos la que acaba de cambiar
    igualar_las_demas(n, ws.monitor or enfocada)
    -- Devolver el foco a donde estaba
    moviendo = true
    if ventana then
        hl.dispatch(hl.dsp.focus({ window = ventana }))
    elseif enfocada then
        hl.dispatch(hl.dsp.focus({ monitor = enfocada.name }))
    end
    moviendo = false
end)

-- Cada pantalla, con su decena de escritorios. Son persistentes (existen
-- aunque estén vacíos) para poder enseñarlos en una pantalla sin tener que
-- llevarle el foco. El 1 de cada una es el que sale al arrancar.
--
-- Esto se hace cuando ya se sabe qué pantallas hay de verdad, no al leer
-- este fichero: aquí arriba todavía se están aplicando las resoluciones.
local cuantas = -1
function repartir()
    local ms = orden()
    if #ms == cuantas then return end
    cuantas = #ms
    if #ms < 2 then return end
    for pos, m in ipairs(ms) do
        for n = 1, POR_PANTALLA do
            hl.workspace_rule({ workspace = tostring(S.id(n, pos)), monitor = m.name,
                                persistent = true, default = (n == 1) })
        end
    end
end

hl.on("hyprland.start", repartir)
-- Y también ahora, por si esto es una recarga de la configuración con la
-- sesión ya en marcha, que entonces «hyprland.start» no vuelve a saltar
repartir()
