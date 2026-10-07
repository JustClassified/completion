-- Completion: "up now". A rare you still need that is up right now shows on your minimap as a vignette
-- (the skull icon). The book marks its row, its pin gets the ring and the arrow points at where it stands.
-- Nothing is announced: no sound, no popup. The vignette list is read when the game says it changed.

local _, ns = ...

ns.upNow = {}   -- item key -> { spot = live position or nil }

local byNpc, byName, indexStamp

-- Builds the npc ID and name lookups for every rare point, once per book build.
local function Index()
    if indexStamp == ns.buildStamp then return end
    indexStamp = ns.buildStamp
    byNpc, byName = {}, {}
    for _, z in ipairs(ns.ZONES) do
        for _, it in ipairs(z.sections.rare.items) do
            if it.kind == "point" then
                if it.npc then byNpc[it.npc] = it end
                if it.name then byName[ns.norm(it.name)] = it end
            end
        end
    end
end

-- True for a secret value the addon may not read; always false on clients without issecretvalue.
local function Secret(v) return issecretvalue and issecretvalue(v) end

-- The npc ID from a creature or vehicle GUID, or nil for anything else.
local function NpcID(guid)
    if type(guid) ~= "string" or Secret(guid) then return end
    local kind, _, _, _, _, id = strsplit("-", guid)
    if kind == "Creature" or kind == "Vehicle" then return tonumber(id) end
end

-- Matches the current vignettes against open rares (by npc ID, then by name) and rebuilds ns.upNow.
-- The book, world pins and arrow refresh only when the set of rares changes, not when one moves.
local function Scan()
    if not (ns.built and C_VignetteInfo and C_VignetteInfo.GetVignettes) then return end
    Index()
    local ok, list = pcall(C_VignetteInfo.GetVignettes)
    if not ok or type(list) ~= "table" then return end
    local found = {}
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    for _, guid in ipairs(list) do
        local ok2, info = pcall(C_VignetteInfo.GetVignetteInfo, guid)
        if ok2 and info then
            local it = byNpc[NpcID(info.objectGUID) or -1]
            if not it and type(info.name) == "string" and not Secret(info.name) then it = byName[ns.norm(info.name)] end
            if it and ns.StillWanted(it) then
                local spot
                if mapID and C_VignetteInfo.GetVignettePosition then
                    local ok3, pos = pcall(C_VignetteInfo.GetVignettePosition, guid, mapID)
                    if ok3 and pos then
                        local x, y
                        if pos.GetXY then x, y = pos:GetXY() else x, y = pos.x, pos.y end
                        if x and y and not Secret(x) then spot = { map = mapID, x = x * 100, y = y * 100 } end
                    end
                end
                found[it.key] = { spot = spot }
            end
        end
    end
    -- refresh only when the set changed
    local changed = false
    for k in pairs(found) do if not ns.upNow[k] then changed = true end end
    for k in pairs(ns.upNow) do if not found[k] then changed = true end end
    ns.upNow = found
    if changed then
        if ns.IsShown and ns.IsShown() then ns.RefreshUI() end
        if ns.RefreshWorldPins then ns.RefreshWorldPins() end
        if ns.UpdateTarget then ns.UpdateTarget() end
    end
end

-- The live position of a rare that is up, or nil when it isn't up or its position is unknown.
function ns.UpSpot(it)
    local u = it and ns.upNow[it.key]
    return u and u.spot
end

local pending = false
local f = CreateFrame("Frame")
for _, ev in ipairs({ "VIGNETTES_UPDATED", "VIGNETTE_MINIMAP_UPDATED", "PLAYER_ENTERING_WORLD" }) do
    pcall(f.RegisterEvent, f, ev)
end
-- Vignette events come in bursts, so one scan runs half a second after the first.
f:SetScript("OnEvent", function()
    if pending or not C_Timer then return end
    pending = true
    C_Timer.After(0.5, function() pending = false; Scan() end)
end)
