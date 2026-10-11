-- Completion: pins on the minimap. The same pins as the world map (and the same checklist), placed
-- around you by distance and direction: treasures, rares and, inside a delve, its unopened Sturdy Chests.
-- What you track stays on the minimap's edge when it is out of range, so you can always see which way it is.
-- Positions are read ten times a second; the list of pins is rebuilt every two seconds.

local _, ns = ...

-- Minimap diameter in yards per zoom level (0 = zoomed out), indoors and outdoors.
local SIZE = {
    indoor = { [0] = 300, 240, 180, 120, 80, 50 },
    outdoor = { [0] = 466 + 2 / 3, 400, 333 + 1 / 3, 266 + 2 / 3, 200, 133 + 1 / 3 },
}
local ATLAS = { treasure = "VignetteLoot", rare = "VignetteKill", boss = "VignetteKillElite", achv = "VignetteEvent",
                container = "Dungeon", instance = "Dungeon", delve = "VignetteLoot", vendor = "banker", prof = "VignetteLoot", step = "QuestNormal" }

local pool, used = {}, 0
local entries, entriesAt, entriesMap = {}, -100, nil
local driver

-- Pin i from the pool, created on first use. Hover shows what it is; a click tracks it.
local function GetPin(i)
    local p = pool[i]
    if p then return p end
    p = CreateFrame("Button", nil, Minimap)
    p:SetSize(12, 12)
    p:SetFrameLevel(Minimap:GetFrameLevel() + 6)
    p.tex = p:CreateTexture(nil, "OVERLAY")
    p.tex:SetAllPoints()
    p.ring = p:CreateTexture(nil, "OVERLAY", nil, 1)
    p.ring:SetPoint("CENTER")
    p.ring:SetSize(22, 22)
    p.ring:SetTexture("Interface\\Minimap\\UI-Minimap-Ping-Center")
    p.ring:SetBlendMode("ADD")
    p:SetScript("OnEnter", function(self) if ns.PinTooltip then ns.PinTooltip(self) end end)
    p:SetScript("OnLeave", function() GameTooltip:Hide() end)
    p:SetScript("OnClick", function(self) if self.it then ns.Track(self.it, self.row and self.row.key) end end)
    pool[i] = p
    return p
end

-- Hides every pin in use.
local function HideAll()
    for i = 1, used do pool[i]:Hide() end
    used = 0
end

-- Off by the option, before the book is built, or with the minimap hidden.
local function Enabled()
    return ns.built and ns.db and ns.db.settings.minimapPins ~= false and Minimap and Minimap:IsVisible()
end

-- The pin list for the map you stand on, rebuilt at most every two seconds (or when the map changes).
local function Entries(now)
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if mapID ~= entriesMap or now - entriesAt > 2 then
        entriesMap, entriesAt = mapID, now
        entries = mapID and ns.PinEntries and ns.PinEntries(mapID) or {}
    end
    return entries
end

-- Places every pin within the minimap's range; the tracked target is clamped to the edge when farther.
local function Update()
    if not Enabled() then HideAll(); return end
    local now = GetTime()
    local list = Entries(now)
    local pinst, pwx, pwy = ns.PlayerWorld()
    if not pinst or #list == 0 then HideAll(); return end
    local zoom = Minimap:GetZoom() or 0
    local indoor = IsIndoors and IsIndoors()
    local rangeYd = ((indoor and SIZE.indoor or SIZE.outdoor)[zoom] or 466) / 2
    local radiusPx = Minimap:GetWidth() / 2
    local rotate = C_CVar and C_CVar.GetCVar and C_CVar.GetCVar("rotateMinimap") == "1"
    local facing = rotate and GetPlayerFacing and GetPlayerFacing() or 0
    local target = ns.TargetItem()
    local n = 0
    for _, e in ipairs(list) do
        local d, bearing = ns.Distance(e.spot, pinst, pwx, pwy)
        if d then
            local tracked = target and target.key == e.it.key
            local inRange = d < rangeYd * 0.92
            if inRange or tracked then
                n = n + 1
                local p = GetPin(n)
                p.it, p.row = e.it, e.row
                local ok = pcall(p.tex.SetAtlas, p.tex, ATLAS[e.kind] or "VignetteLoot")
                if not ok or not p.tex:GetAtlas() then p.tex:SetTexture("Interface\\COMMON\\Indicator-Yellow") end
                local r = inRange and (d / rangeYd * radiusPx) or (radiusPx - 4)
                local a = bearing - facing
                p:ClearAllPoints()
                p:SetPoint("CENTER", Minimap, "CENTER", -math.sin(a) * r, math.cos(a) * r)
                p.tex:SetDesaturated(e.faded and true or false)
                p:SetAlpha((inRange and 1 or 0.7) * (e.faded and 0.45 or 1))
                p.ring:SetShown(tracked or ns.upNow[e.it.key] ~= nil)
                p:Show()
            end
        end
    end
    for i = n + 1, used do pool[i]:Hide() end
    used = n
end

-- Rebuilds the pin list and redraws now (after an evaluation or a change of target).
function ns.RefreshMinimapPins()
    entriesAt = -100
    Update()
end

-- How many pins the minimap shows (for /comp debug).
function ns.MinimapPinCount() return used end

-- Starts the ten-times-a-second update once the minimap exists.
function ns.CreateMinimapPins()
    if driver or not Minimap then return end
    driver = CreateFrame("Frame")
    driver:SetScript("OnUpdate", function(self, elapsed)
        self.acc = (self.acc or 0) + elapsed
        if self.acc < 0.1 then return end
        self.acc = 0
        Update()
    end)
end
