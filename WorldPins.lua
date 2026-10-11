-- Completion: pins on Blizzard's world map for everything still missing in the zone you are looking at.
-- Pins sit on the map canvas and keep the same size on screen when you zoom. Click one to track it.
-- Only hooks are used (hooksecurefunc / HookScript), so the map itself is never tainted.

local _, ns = ...

local pool = {}        -- reused pin buttons, never released
local hooked = false
local shown = 0        -- how many pins from the start of the pool are in use

-- Pin art per section or point kind; anything missing falls back to the loot icon.
local ATLAS = { treasure = "VignetteLoot", rare = "VignetteKill", boss = "VignetteKillElite", achv = "VignetteEvent",
                container = "Dungeon", instance = "Dungeon", delve = "delves-regular", vendor = "banker", step = "QuestNormal" }

------------------------------------------------------------------------
-- which kinds of pins show (one checklist for the world map and the book's map)
------------------------------------------------------------------------

ns.PIN_KINDS = {
    { "treasure", "Treasures" },
    { "rare",     "Rares & world bosses" },
    { "achv",     "Achievements" },
    { "collect",  "Collectibles" },
    { "instance", "Dungeons & raids" },
    { "delve",    "Delves" },
    { "prof",     "Profession treasures" },
}

-- Whether a pin kind shows. Every kind is on by default except profession treasures.
function ns.PinOn(key)
    local v = ns.db and ns.db.settings.pins and ns.db.settings.pins[key]
    if v == nil then return key ~= "prof" end
    return v
end

-- Redraws everything that depends on the pin checklist.
local function PinsChanged()
    ns.RefreshWorldPins()
    if ns.IsShown and ns.IsShown() then ns.RefreshUI() end
    if ns.UpdatePinButtons then ns.UpdatePinButtons() end
end

-- Switches one pin kind on or off.
function ns.SetPin(key, on)
    ns.db.settings.pins = ns.db.settings.pins or {}
    ns.db.settings.pins[key] = on and true or false
    PinsChanged()
end

-- Sets every pin kind at once. only = a key: that kind alone; only = true: everything; only = false: nothing.
function ns.SetPinsOnly(only)
    for _, k in ipairs(ns.PIN_KINDS) do
        ns.db.settings.pins[k[1]] = (only == true) or (only == k[1])
    end
    PinsChanged()
end

-- Returns how many pin kinds are on and how many there are.
function ns.PinsShownCount()
    local n = 0
    for _, k in ipairs(ns.PIN_KINDS) do if ns.PinOn(k[1]) then n = n + 1 end end
    return n, #ns.PIN_KINDS
end

-- The checklist, as a Blizzard menu: tick what shows, or "Show only..." to focus on one kind.
function ns.ShowPinMenu(owner)
    if not (MenuUtil and MenuUtil.CreateContextMenu) then
        ns.Print("The pin checklist needs a newer game client.")
        return
    end
    MenuUtil.CreateContextMenu(owner, function(_, root)
        root:CreateTitle("Completion: map pins")
        for _, k in ipairs(ns.PIN_KINDS) do
            root:CreateCheckbox(k[2], function() return ns.PinOn(k[1]) end,
                function() ns.SetPin(k[1], not ns.PinOn(k[1])) end)
        end
        root:CreateDivider()
        local only = root:CreateButton("Show only...")
        for _, k in ipairs(ns.PIN_KINDS) do
            only:CreateButton(k[2], function() ns.SetPinsOnly(k[1]) end)
        end
        root:CreateButton("Show all", function() ns.SetPinsOnly(true) end)
        root:CreateButton("Hide all", function() ns.SetPinsOnly(false) end)
        root:CreateDivider()
        local zone = owner and owner.zoneFor and owner.zoneFor()
        if zone then
            root:CreateButton("Plan a route through these pins", function() ns.PlanRouteForPins(zone) end)
        end
        if ns.RouteActive() then root:CreateButton("Stop the route", function() ns.StopRoute() end) end
    end)
end

-- Tooltip for a pin button: which kinds are on and what a click does.
local function PinButtonTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine("Completion pins")
    local on = {}
    for _, k in ipairs(ns.PIN_KINDS) do if ns.PinOn(k[1]) then on[#on + 1] = k[2] end end
    GameTooltip:AddLine(#on > 0 and table.concat(on, ", ") or "None shown", 1, 1, 1, true)
    GameTooltip:AddLine("Click to choose what the maps show. Only what you still need is pinned.", 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
end

-- A small square map button with the book icon and an "on/total" badge; a click opens the pin menu.
function ns.MakePinButton(parent, size)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(size, size)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", 2, -2)
    b.icon:SetPoint("BOTTOMRIGHT", -2, 2)
    b.icon:SetTexture("Interface\\Icons\\inv_misc_book_16")
    b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    b.edge = CreateFrame("Frame", nil, b, "BackdropTemplate")
    b.edge:SetAllPoints()
    if b.edge.SetBackdrop then
        b.edge:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10 })
        b.edge:SetBackdropBorderColor(0.85, 0.7, 0.4)
    end
    b.count = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.count:SetPoint("BOTTOMRIGHT", 3, -3)
    b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    b:SetScript("OnClick", function(self) ns.ShowPinMenu(self) end)
    b:SetScript("OnEnter", PinButtonTooltip)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    ns.pinButtons = ns.pinButtons or {}
    ns.pinButtons[#ns.pinButtons + 1] = b
    return b
end

-- Updates the badge on every pin button. The badge is empty when every kind is on, and the icon greys out
-- when none is.
function ns.UpdatePinButtons()
    local n, total = ns.PinsShownCount()
    for _, b in ipairs(ns.pinButtons or {}) do
        b.count:SetText(n < total and (n .. "/" .. total) or "")
        b.icon:SetDesaturated(n == 0)
    end
end

-- The world map's canvas frame, or nil before the map exists.
local function Canvas()
    return WorldMapFrame and WorldMapFrame.GetCanvas and WorldMapFrame:GetCanvas()
end

-- The world map's current zoom, 1 when it can't be read. Pin sizes are divided by it.
local function CanvasScale()
    local ok, s = pcall(WorldMapFrame.GetCanvasScale, WorldMapFrame)
    return (ok and s and s > 0) and s or 1
end

-- Tooltip for a world map pin: the criteria row (or item) name, its achievement and any note.
local function Tooltip(pin)
    if not pin.it then return end
    GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
    local it, row = pin.it, pin.row
    GameTooltip:AddLine(row and row.name or it.liveName or it.name or "?", 1, 1, 1, true)
    if row then GameTooltip:AddLine(it.name or "", 0.9, 0.8, 0.5, true) end
    local note = (row and row.note) or it.note
    if note then GameTooltip:AddLine(note, 0.9, 0.85, 0.7, true) end
    if ns.upNow[it.key] then GameTooltip:AddLine("Up now", 0.4, 1, 0.4) end
    if not row and it.done then GameTooltip:AddLine("Done: nothing left to get here", 0.5, 0.8, 0.5) end
    if not row and not it.done then ns.AddDifficulty(GameTooltip, it) end
    GameTooltip:AddLine("Completion: click to track with the arrow.", 0.5, 0.5, 0.5)
    GameTooltip:Show()
end
ns.PinTooltip = Tooltip

-- Pin i from the pool, created on first use. A click tracks the pin's item (and row).
local function GetPin(i)
    local p = pool[i]
    if p then return p end
    p = CreateFrame("Button", nil, Canvas())
    p.tex = p:CreateTexture(nil, "OVERLAY")
    p.tex:SetAllPoints()
    p.ring = p:CreateTexture(nil, "OVERLAY", nil, 1)
    p.ring:SetPoint("CENTER")
    p.ring:SetTexture("Interface\\Minimap\\UI-Minimap-Ping-Center")
    p.ring:SetBlendMode("ADD")
    p:SetScript("OnEnter", Tooltip)
    p:SetScript("OnLeave", function() GameTooltip:Hide() end)
    p:SetScript("OnClick", function(self) ns.Track(self.it, self.row and self.row.key) end)
    pool[i] = p
    return p
end

-- Puts a pin at map position x, y (0-1) on the canvas. big is for the target or a rare that is up:
-- a larger pin with a ring.
local function Place(p, x, y, big)
    local canvas = Canvas()
    local scale = CanvasScale()
    local size = (big and 22 or 15) / scale
    p:SetParent(canvas)
    p:SetFrameStrata("HIGH")
    p:SetSize(size, size)
    p.ring:SetSize(size * 2, size * 2)
    p.ring:SetShown(big)
    p:ClearAllPoints()
    p:SetPoint("CENTER", canvas, "TOPLEFT", x * canvas:GetWidth(), -y * canvas:GetHeight())
    p:Show()
end

-- Everything still missing that has a spot, for the map showing mapID: { it, row, spot, kind } per spot.
-- A zone map lists its zone's sections (as the pin checklist allows); a delve map lists that delve's
-- unopened Sturdy Chests. The tracked target is always included.
function ns.PinEntries(mapID)
    local out, seen = {}, {}
    local function add(it, row, spot, kind, faded)
        if not spot or not spot.x or #out >= 400 then return end
        local key = string.format("%d:%.1f:%.1f", spot.map, spot.x, spot.y)
        if seen[key] then return end
        seen[key] = true
        out[#out + 1] = { it = it, row = row, spot = spot, kind = kind, faded = faded }
    end
    local delve = ns.DelveForMap(mapID)
    if delve then
        if ns.PinOn("delve") then
            for _, z in ipairs(ns.ZONES) do
                for _, d in ipairs(z.sections.delve.items) do
                    for _, ch in ipairs(d.children or {}) do
                        if ch.kind == "point" and not ch.done and not ch.hidden then
                            for _, sp in ipairs(ch.spots) do
                                if ns.DELVE_MAPS[sp.map] == delve then add(ch, nil, sp, "delve") end
                            end
                        end
                    end
                end
            end
        end
    else
        local zone = mapID and ns.ZoneForMap(mapID)
        if zone and not zone.overview then
            for _, k in ipairs(ns.PIN_KINDS) do
                local secKey = k[1]
                for _, it in ipairs(ns.PinOn(secKey) and zone.sections[secKey].items or {}) do
                    if (not it.done or ns.FarmWanted(it)) and not it.hidden then
                        if it.kind == "point" then
                            for _, sp in ipairs(it.spots) do add(it, nil, sp, it.pkind) end
                        elseif it.kind == "ach" then
                            local any = false
                            for _, row in ipairs(ns.Children(it)) do
                                if not row.done and row.spot then add(it, row, row.spot, "achv"); any = true end
                            end
                            if not any then
                                local res = ns.Resolve(it)
                                if res.spot then add(it, nil, res.spot, "achv") end
                            end
                        elseif it.kind == "container" then
                            for _, sp in ipairs(it.spots) do add(it, nil, sp, it.ctype) end
                        elseif it.kind == "collect" and it.spots and it.spots[1] then
                            -- drops share their rare's or treasure's spot (one pin if both kinds are on)
                            for _, sp in ipairs(it.spots) do add(it, nil, sp, it.source and it.source.pkind or "vendor") end
                        end
                    end
                end
            end
            -- "Show finished, faded": finished treasures and rares stay as faint pins (after the needed ones,
            -- so a spot that still has something to get keeps its full pin)
            if ns.db.settings.fadedDone then
                for _, secKey in ipairs({ "treasure", "rare" }) do
                    for _, it in ipairs(ns.PinOn(secKey) and zone.sections[secKey].items or {}) do
                        if it.kind == "point" and it.done and not it.hidden and not ns.FarmWanted(it) then
                            for _, sp in ipairs(it.spots) do add(it, nil, sp, it.pkind, true) end
                        end
                    end
                end
            end
        end
    end
    -- holidays that are on: their open guide steps and achievement criteria here (Seasonal.lua)
    if ns.EventPinEntries and mapID then ns.EventPinEntries(mapID, add) end
    -- whatever you track, even outside these sections (a storyline's next quest, say)
    local target, child = ns.TargetItem()
    if target then
        local res = ns.Resolve(target, child)
        if res.spot then add(target, nil, res.spot, target.pkind or "achv") end
    end
    return out
end

-- Redraws every pin for the map now showing (and the route line on it).
function ns.RefreshWorldPins()
    for i = 1, shown do pool[i]:Hide() end
    shown = 0
    if not (WorldMapFrame and WorldMapFrame:IsShown() and ns.built and ns.db) then return end
    local mapID = WorldMapFrame:GetMapID()
    local canvas = Canvas()
    if canvas then ns.DrawRoute(canvas, canvas:GetWidth(), canvas:GetHeight(), mapID, CanvasScale()) end
    local zone = mapID and ns.ZoneForMap(mapID)
    local delve = ns.DelveForMap(mapID)
    if ns.worldPinButton then
        ns.worldPinButton:SetShown(((zone and not zone.overview) or delve) and ns.db.settings.worldPins ~= "off")
    end
    if ns.db.settings.worldPins == "off" then return end
    local target = ns.TargetItem()
    for _, e in ipairs(ns.PinEntries(mapID)) do
        local x, y = ns.MapPosOn(e.spot, mapID)
        if x then
            shown = shown + 1
            local p = GetPin(shown)
            p.it, p.row = e.it, e.row
            local ok = pcall(p.tex.SetAtlas, p.tex, ATLAS[e.kind] or "VignetteLoot")
            if not ok or not p.tex:GetAtlas() then p.tex:SetTexture("Interface\\COMMON\\Indicator-Yellow") end
            -- a finished spot: grey and faint
            p.tex:SetDesaturated(e.faded and true or false)
            p:SetAlpha(e.faded and 0.45 or 1)
            Place(p, x, y, (target and target.key == e.it.key) or (ns.upNow[e.it.key] ~= nil))
        end
    end
end

-- What is pinned right now (shown by /comp debug).
function ns.WorldPinItems()
    local out = {}
    for i = 1, shown do out[i] = pool[i].it end
    return out
end

-- After a zoom: resizes the pins in place and redraws the route so they keep their size on screen.
local function Rescale()
    local scale = CanvasScale()
    local target = ns.TargetItem()
    for i = 1, shown do
        local p = pool[i]
        local big = (target and p.it and target.key == p.it.key) or (p.it and ns.upNow[p.it.key] ~= nil)
        local size = (big and 22 or 15) / scale
        p:SetSize(size, size)
        p.ring:SetSize(size * 2, size * 2)
    end
    local canvas = Canvas()
    if canvas and WorldMapFrame:GetMapID() then
        ns.DrawRoute(canvas, canvas:GetWidth(), canvas:GetHeight(), WorldMapFrame:GetMapID(), CanvasScale())
    end
end

-- Adds the pin button to the world map and hooks its show, hide, map change and zoom. Runs once.
function ns.HookWorldMap()
    if hooked or not WorldMapFrame then return end
    hooked = true
    -- the pin checklist button, bottom left of the map
    local holder = type(WorldMapFrame.ScrollContainer) == "table" and WorldMapFrame.ScrollContainer or WorldMapFrame
    ns.worldPinButton = ns.MakePinButton(holder, 30)
    ns.worldPinButton.zoneFor = function()
        local z = ns.ZoneForMap(WorldMapFrame:GetMapID())
        return z and not z.overview and z
    end
    ns.worldPinButton:SetPoint("BOTTOMLEFT", holder, "BOTTOMLEFT", 8, 8)
    ns.worldPinButton:SetFrameStrata("HIGH")
    ns.worldPinButton:SetFrameLevel(holder:GetFrameLevel() + 50)
    ns.UpdatePinButtons()
    WorldMapFrame:HookScript("OnShow", ns.RefreshWorldPins)
    WorldMapFrame:HookScript("OnHide", function() for i = 1, shown do pool[i]:Hide() end; shown = 0 end)
    if WorldMapFrame.OnMapChanged then hooksecurefunc(WorldMapFrame, "OnMapChanged", ns.RefreshWorldPins) end
    if WorldMapFrame.OnCanvasScaleChanged then hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", Rescale) end
end

-- Opens the big map on a zone (from the book's map). The map can't be opened by addons in combat.
function ns.OpenWorldMap(mapID)
    if InCombatLockdown and InCombatLockdown() then ns.Print("The world map can't be opened by addons in combat.") return end
    if OpenWorldMap then OpenWorldMap(mapID)
    elseif ToggleWorldMap then ToggleWorldMap() end
    ns.HookWorldMap()
    ns.RefreshWorldPins()
end
