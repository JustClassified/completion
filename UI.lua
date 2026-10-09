-- Completion: the book window.
-- Left page: the zone (name, blurb, a map of what is still missing with the pin filter button, Zone Progress).
-- Right page: the Chronicle (time here, recent adventures, next up), the list of one section with its
-- Sort, Nearest and Route buttons, or search results.
-- Tabs on the right edge switch zones. Under the gear (options and about) sit the This Week and Warband
-- tabs, which open their own pages through ns.showPage. Expansion bookmarks run along the top.

local _, ns = ...

local W, H = 940, 660
local LEFT_X, PAGE_W = 22, 440
local RIGHT_X = W - 22 - PAGE_W
local ROW_H, LIST_TOP, LIST_BOTTOM = 19, 72, 28
local MAP_W, MAP_H = 360, 240

local GOLD = { 0.93, 0.82, 0.55 }
local CREAM = { 0.93, 0.89, 0.80 }
local DONE_C = { 0.50, 0.78, 0.50 }
local GREY = { 0.60, 0.58, 0.54 }

local ICON_DONE = "Interface\\RaidFrame\\ReadyCheck-Ready"
local ICON_OPEN = "Interface\\COMMON\\Indicator-Gray"
local ICON_NOW = "Interface\\RaidFrame\\ReadyCheck-Waiting"

local main, L, R
local searchText = ""   -- lower-case; empty = no search
local tabs = {}       -- zone tabs, in ns.ZONES order
local expanded = {}   -- item key -> true while its children are listed
local scroll = 0      -- list lines scrolled past the top
local lines = {}      -- the right page list, as built by BuildLines
local history = {}   -- pages left by a jump (search result, tracking line), for the Back button

-- Plays a SOUNDKIT sound by key (Blizzard's own book sounds); unknown keys stay silent.
local function Sound(key)
    local id = SOUNDKIT and SOUNDKIT[key]
    if id then pcall(PlaySound, id) end
end
ns.BookSound = Sound

-- True while the book is turned to the Seasonal pages (the holidays).
local function Seasonal() return ns.cdb.lastExpansion == "seasonal" end

-- The holiday to open on: the one running now, else the next to start, else the first.
local function DefaultEvent()
    local best, bestStart
    for _, z in ipairs(ns.EVENT_ZONES or {}) do
        local state, a = ns.EventWhen(z)
        if state == "on" then return z end
        if state == "next" and (not bestStart or a < bestStart) then best, bestStart = z, a end
    end
    return best or (ns.EVENT_ZONES and ns.EVENT_ZONES[1])
end

-- The page the book is open on: a holiday on the Seasonal pages, else a zone (the first one by default).
local function Zone()
    if Seasonal() then
        local z = ns.eventByKey and ns.eventByKey[ns.cdb.lastEvent or ""] or DefaultEvent()
        if z then return z end
    end
    -- a zone of the open expansion: the last one opened there, else its first
    local exp = ns.cdb.lastExpansion or "midnight"
    local z = ns.zoneByKey[ns.cdb.lastZone or ""]
    if z and (z.exp or "midnight") == exp then return z end
    ns.cdb.lastZoneByExp = ns.cdb.lastZoneByExp or {}
    z = ns.zoneByKey[ns.cdb.lastZoneByExp[exp] or ""]
    if z then return z end
    for _, zz in ipairs(ns.ZONES) do
        if (zz.exp or "midnight") == exp then return zz end
    end
    return ns.ZONES[1]
end
-- The open section's key, or nil while the Chronicle is showing (or the saved one isn't on this page).
local function Section()
    local s = ns.cdb.lastSection
    local z = Zone()
    if s and z and z.sections and z.sections[s] then return s end
end
ns.BookPage = Zone

-- The section list of a page: its own (holidays) or the zone sections.
local function SectionDefs(z) return z and z.sectionDefs or ns.SECTIONS end

------------------------------------------------------------------------
-- fonts and small widgets
------------------------------------------------------------------------

-- Creates a named gold font in Morpheus (the quest book face); uses fallback if Morpheus fails to load.
local function MakeFont(name, size, fallback)
    local f = CreateFont(name)
    local ok = pcall(f.SetFont, f, "Fonts\\MORPHEUS.TTF", size, "")
    if not ok or not f:GetFont() then f:CopyFontObject(fallback) end
    f:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
    f:SetShadowColor(0, 0, 0, 1)
    f:SetShadowOffset(1, -1)
    return f
end

local FONT_TITLE, FONT_HEAD   -- created in ns.CreateMain

-- A left-justified font string. size, if given, changes the size but keeps the template's face and flags.
local function Text(parent, font, size)
    local fs = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
    if size then
        local path, _, flags = fs:GetFont()
        if path then fs:SetFont(path, size, flags or "") end
    end
    fs:SetJustifyH("LEFT")
    return fs
end

-- A centred header with a gold rule and a small diamond on each side. h:Set(text) sets the title.
local function Header(parent, width)
    local h = CreateFrame("Frame", nil, parent)
    h:SetSize(width, 26)
    h.text = h:CreateFontString(nil, "OVERLAY")
    h.text:SetFontObject(FONT_HEAD)
    h.text:SetPoint("CENTER")
    for side = 1, 2 do
        local line = h:CreateTexture(nil, "ARTWORK")
        line:SetColorTexture(0.72, 0.56, 0.30, 0.8)
        line:SetHeight(1)
        local gem = h:CreateTexture(nil, "ARTWORK")
        gem:SetColorTexture(0.85, 0.66, 0.34, 1)
        gem:SetSize(5, 5)
        gem:SetRotation(math.pi / 4)
        if side == 1 then
            line:SetPoint("RIGHT", h.text, "LEFT", -10, 0)
            line:SetPoint("LEFT", h, "LEFT", 30, 0)
            gem:SetPoint("CENTER", line, "LEFT", -3, 0)
        else
            line:SetPoint("LEFT", h.text, "RIGHT", 10, 0)
            line:SetPoint("RIGHT", h, "RIGHT", -30, 0)
            gem:SetPoint("CENTER", line, "RIGHT", 3, 0)
        end
    end
    function h:Set(s) self.text:SetText(s) end
    return h
end

-- A thin progress bar. b:SetFrac(cur, max) fills it (empty when max is 0 or nil) and turns it green at 100%.
local function Bar(parent, w, h)
    local b = CreateFrame("StatusBar", nil, parent)
    b:SetSize(w, h)
    b:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    b:SetMinMaxValues(0, 1)
    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.5)
    local border = b:CreateTexture(nil, "OVERLAY")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    border:SetColorTexture(0.72, 0.56, 0.30, 0.35)
    border:SetDrawLayer("BACKGROUND", -1)
    function b:SetFrac(cur, max)
        local f = (max and max > 0) and cur / max or 0
        self:SetValue(f)
        if f >= 1 then self:SetStatusBarColor(0.35, 0.75, 0.35) else self:SetStatusBarColor(0.85, 0.62, 0.22) end
    end
    return b
end

-- One page of the open book: a dark panel with a thin bronze border, x pixels from the frame's left edge.
local function Page(x)
    local p = CreateFrame("Frame", nil, main)
    p:SetPoint("TOPLEFT", x, -22)
    p:SetSize(PAGE_W, H - 44)
    local bg = p:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.10, 0.09, 0.08, 0.94)
    local edges = {
        { "TOPLEFT", "TOPRIGHT", nil, 1 }, { "BOTTOMLEFT", "BOTTOMRIGHT", nil, 1 },
        { "TOPLEFT", "BOTTOMLEFT", 1, nil }, { "TOPRIGHT", "BOTTOMRIGHT", 1, nil },
    }
    for _, e in ipairs(edges) do
        local t = p:CreateTexture(nil, "BORDER")
        t:SetColorTexture(0.45, 0.35, 0.20, 0.9)
        t:SetPoint(e[1]); t:SetPoint(e[2])
        if e[3] then t:SetWidth(e[3]) else t:SetHeight(e[4]) end
    end
    return p
end

------------------------------------------------------------------------
-- tooltips
------------------------------------------------------------------------

-- Adds a wrapped tooltip line in parchment colour unless r, g, b are given. Skips nil or empty text.
local function AddWrapped(text, r, g, b)
    if text and text ~= "" then GameTooltip:AddLine(text, r or 0.9, g or 0.85, b or 0.7, true) end
end

-- Fills GameTooltip for a list item, or for one of its child rows (criterion, step, quest) when row is
-- given. A row that carries an item of its own falls through to the full item tooltip.
local function ItemTooltip(owner, it, row)
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    -- a child row: name, state, note and where it is
    if row and not row.item then
        GameTooltip:AddLine(row.name or "?", 1, 1, 1, true)
        GameTooltip:AddLine(row.done and "Done" or (row.current and "Next up" or "Not done"),
            row.done and 0.4 or 1, row.done and 0.9 or 0.8, row.done and 0.4 or 0.3)
        AddWrapped(row.note)
        if row.spot then
            local ok, info = pcall(C_Map.GetMapInfo, row.spot.map)
            GameTooltip:AddLine(string.format("%s  %.1f, %.1f", ok and info and info.name or "", row.spot.x, row.spot.y), 0.6, 0.6, 0.6)
            if row.spots and #row.spots > 1 then GameTooltip:AddLine(string.format("(%d places; the arrow picks the nearest)", #row.spots), 0.6, 0.6, 0.6) end
        end
        GameTooltip:AddLine("Click: point the arrow here.", 0.5, 0.5, 0.5)
        GameTooltip:Show()
        return
    end
    -- a holiday guide step or quest: what to do, where, and whether it is done
    if it.kind == "step" then
        GameTooltip:AddLine(it.liveName or it.name or "?", 1, 1, 1, true)
        GameTooltip:AddLine(it.done and "Done" or "Not done", it.done and 0.4 or 1, it.done and 0.9 or 0.8, it.done and 0.4 or 0.3)
        AddWrapped(it.note)
        for _, q in ipairs(it.quests or {}) do
            local title = ns.QuestTitle(q, ns.EVENT_QUEST and ns.EVENT_QUEST[q] and ns.EVENT_QUEST[q].n)
            local qd = ns.QuestDone(q)
            GameTooltip:AddLine("Quest: " .. title .. (qd and "  |cff55ff55(done)|r" or (ns.QuestActive(q) and "  |cffffd100(in your log)|r" or "")), 0.6, 0.8, 1, true)
        end
        for _, id in ipairs(type(it.ach) == "table" and it.ach or { it.ach }) do
            local a = ns.Ach(id)
            if a then GameTooltip:AddLine("Achievement: " .. a.name .. (a.done and "  |cff55ff55(done)|r" or ""), 0.6, 0.8, 1, true) end
        end
        local sp = it.spots and it.spots[1]
        if sp then
            local ok, info = pcall(C_Map.GetMapInfo, sp.map)
            GameTooltip:AddLine(string.format("%s  %.1f, %.1f", ok and info and info.name or "", sp.x, sp.y), 0.6, 0.6, 0.6)
            if #it.spots > 1 then GameTooltip:AddLine(string.format("(%d places; the arrow picks the nearest)", #it.spots), 0.6, 0.6, 0.6) end
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click: point the arrow here.", 0.5, 0.5, 0.5)
        if it.handOnly then GameTooltip:AddLine("Shift-click: tick it done (the game can't see this one).", 0.5, 0.5, 0.5)
        else GameTooltip:AddLine("Shift-click: tick or untick it by hand.", 0.5, 0.5, 0.5) end
        GameTooltip:Show()
        return
    end
    -- the top: Blizzard's own item, mount or achievement tooltip where there is one
    if it.kind == "collect" and it.itemID then
        GameTooltip:SetItemByID(it.itemID)
    elseif it.kind == "collect" and it.mountID and C_MountJournal and GameTooltip.SetMountBySpellID then
        local ok, _, spellID = pcall(C_MountJournal.GetMountInfoByID, it.mountID)
        if not (ok and spellID and pcall(GameTooltip.SetMountBySpellID, GameTooltip, spellID)) then
            GameTooltip:AddLine(it.name or "?", 1, 1, 1)
        end
    elseif it.kind == "ach" and it.id and GameTooltip.SetHyperlink and GetAchievementLink then
        local ok, link = pcall(GetAchievementLink, it.id)
        if ok and link then GameTooltip:SetHyperlink(link) else GameTooltip:AddLine(it.name or "?", 1, 1, 1) end
    else
        GameTooltip:AddLine(it.liveName or it.name or "?", 1, 1, 1, true)
    end
    GameTooltip:AddLine(" ")
    -- state, then details by kind
    if ns.upNow[it.key] then GameTooltip:AddLine("Up now: it is on your minimap", 0.4, 1, 0.4) end
    if it.done then GameTooltip:AddLine("Done", 0.4, 0.9, 0.4)
    elseif (it.max or 0) == 0 then GameTooltip:AddLine("Not counted: the game can't tell yet", 0.7, 0.7, 0.7)
    else GameTooltip:AddLine("Missing", 1, 0.5, 0.3) end
    if it.sub and it.sub ~= "" then GameTooltip:AddLine(it.sub, 0.8, 0.8, 0.8) end
    if it.kind == "lore" then
        local a = ns.LORE_ACH[it.ach]
        if a then GameTooltip:AddLine("Part of: " .. a.name, 0.8, 0.7, 0.5) end
        if it.crit.start then GameTooltip:AddLine("Starts with " .. (it.crit.first or "?") .. " from " .. it.crit.start, 0.8, 0.8, 0.8, true) end
    end
    if it.kind == "container" then
        AddWrapped(it.desc, 0.75, 0.75, 0.75)
        if it.bosses and #it.bosses > 0 then GameTooltip:AddLine("Bosses: " .. table.concat(it.bosses, ", "), 0.8, 0.8, 0.8, true) end
        -- delves: chests opened, bountiful now, how the arrow behaves inside
        if it.ctype == "delve" then
            local open, total = 0, 0
            for _, ch in ipairs(it.children or {}) do
                if ch.kind == "point" and not ch.hidden then
                    total = total + 1
                    if ch.done then open = open + 1 end
                end
            end
            if total > 0 then
                GameTooltip:AddLine(string.format("Sturdy Chests opened: %d / %d", open, total),
                    open >= total and 0.4 or 1, open >= total and 0.9 or 0.82, open >= total and 0.4 or 0.3)
            end
            -- its story variants (Delve Loremaster: Midnight needs every one)
            local info = ns.DelveInfo(it.name)
            local c = info and info.stories and ns.Crits(info.stories)
            if c and c.list and #c.list > 0 then
                local got = 0
                for _, e in ipairs(c.list) do if e.done then got = got + 1 end end
                GameTooltip:AddLine(string.format("Stories done: %d / %d", got, #c.list),
                    got >= #c.list and 0.4 or 1, got >= #c.list and 0.9 or 0.82, got >= #c.list and 0.4 or 0.3)
                if info.extra and #info.extra > 0 then
                    local names = {}
                    for _, x in ipairs(info.extra) do names[#names + 1] = x.n end
                    GameTooltip:AddLine("Also: " .. table.concat(names, ", ") .. " (not needed for the achievement)", 0.7, 0.7, 0.7, true)
                end
            end
            if ns.IsBountiful(it.name) then
                GameTooltip:AddLine("Bountiful now: use a Coffer Key at the end for the better chest.", 1, 0.82, 0.3, true)
            end
            if total > open then
                GameTooltip:AddLine("Track it: the arrow leads to the entrance, then from chest to chest inside. "
                    .. "Inside, Route on this page plans a loop through the chests.", 0.6, 0.8, 1, true)
            end
        end
    end
    if it.kind == "rep" and it.rep then GameTooltip:AddLine(it.rep.text, 1, 1, 1) end
    -- walkthrough notes, for achievements and lore only
    local achNote = ns.ACH_NOTES and ns.ACH_NOTES[it.id or it.ach or 0]
    local groupNote = it.kind == "ach" and it.group and ns.GROUP_NOTES and ns.GROUP_NOTES[it.group]
    if (achNote or groupNote) and (it.kind == "ach" or it.kind == "lore") then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Walkthrough", 1, 0.82, 0.3)
        AddWrapped(achNote)
        if groupNote then AddWrapped(groupNote, 0.75, 0.75, 0.75) end
    end
    if it.kind == "ach" and ns.ACH_STEPS and ns.ACH_STEPS[it.id] then
        GameTooltip:AddLine(string.format("%d-step walkthrough: click to follow it with the arrow.", #ns.ACH_STEPS[it.id]), 0.6, 0.8, 1)
    end
    if it.kind == "collect" or (it.kind == "point" and (it.pkind == "rare" or it.pkind == "boss")) then
        ns.AddHowToGet(it)
    end
    AddWrapped(it.note)
    for _, tip in ipairs(it.tips or {}) do AddWrapped("- " .. tip, 0.75, 0.75, 0.75) end
    -- treasures and other map points: collectible rewards and coordinates
    if it.kind == "point" and it.pkind ~= "rare" and it.pkind ~= "boss" then
        local loot = {}
        for _, l in ipairs(it.loot or {}) do
            if l[2] then
                local n = ns.ItemName(l[1])
                if n then loot[#loot + 1] = n .. " (" .. (ns.TYPE_LABEL[({ m = "mount", p = "pet", t = "toy", d = "decor" })[l[2]] or ""] or "item") .. ")" end
            end
        end
        if #loot > 0 then GameTooltip:AddLine("Rewards: " .. table.concat(loot, ", "), 0.6, 0.8, 1, true) end
        local s = it.spots[1]
        if s then GameTooltip:AddLine(string.format("%.1f, %.1f%s", s.x, s.y, #it.spots > 1 and ("  (+" .. (#it.spots - 1) .. " more spots)") or ""), 0.6, 0.6, 0.6) end
    end
    GameTooltip:AddLine(" ")
    if it.kind == "collect" or it.pkind == "rare" or it.pkind == "boss" then
        GameTooltip:AddLine("Click: see it in 3D and track where it comes from.", 0.5, 0.5, 0.5)
    else
        GameTooltip:AddLine("Click: track with the arrow, show details.", 0.5, 0.5, 0.5)
    end
    GameTooltip:AddLine("Right-click: stop tracking.", 0.5, 0.5, 0.5)
    GameTooltip:AddLine("Alt-click: add to (or take off) the watch list.", 0.5, 0.5, 0.5)
    GameTooltip:Show()
end

------------------------------------------------------------------------
-- left page: map
------------------------------------------------------------------------

local tilePool, pinPool = {}, {}   -- map tile textures and pin buttons, reused between zones

-- Lays a map's art tiles (first art layer) onto the left page's map canvas, scaled to MAP_W wide.
-- Leaves the map blank if the map APIs are missing or fail.
local function DrawMap(mapID)
    local box = L.map
    for _, t in ipairs(tilePool) do t:Hide() end
    if not (mapID and C_Map and C_Map.GetMapArtLayers and C_Map.GetMapArtLayerTextures) then return end
    local ok, layers = pcall(C_Map.GetMapArtLayers, mapID)
    local ok2, textures = pcall(C_Map.GetMapArtLayerTextures, mapID, 1)
    if not ok or not ok2 or type(layers) ~= "table" or not layers[1] or type(textures) ~= "table" then return end
    local l = layers[1]
    local cols = math.ceil(l.layerWidth / l.tileWidth)
    local scale = MAP_W / l.layerWidth
    local tw, th = l.tileWidth * scale, l.tileHeight * scale
    for i, tex in ipairs(textures) do
        local t = tilePool[i]
        if not t then t = box.canvas:CreateTexture(nil, "ARTWORK"); tilePool[i] = t end
        local r, c = math.floor((i - 1) / cols), (i - 1) % cols
        t:SetTexture(tex)
        t:SetSize(tw, th)
        t:ClearAllPoints()
        t:SetPoint("TOPLEFT", box.canvas, "TOPLEFT", c * tw, -r * th)
        t:Show()
    end
end

-- Sets a pin's icon by kind (treasure, rare, vendor, ...); a plain yellow dot if the atlas is missing.
local function PinAtlas(pin, kind)
    local atlas = ({ vendor = "banker", treasure = "VignetteLoot", rare = "VignetteKill", boss = "VignetteKillElite", achv = "VignetteEvent",
                     lore = "QuestNormal", step = "QuestNormal", container = "Dungeon", delve = "delves-regular" })[kind] or "VignetteLoot"
    local ok = pcall(pin.tex.SetAtlas, pin.tex, atlas)
    if not ok or not pin.tex:GetAtlas() then
        pin.tex:SetTexture("Interface\\COMMON\\Indicator-Yellow")
    end
end

-- Returns map pin i from the pool, creating it on first use. A pin's it (and row) drive its tooltip and click.
local function GetPin(i)
    local p = pinPool[i]
    if p then return p end
    p = CreateFrame("Button", nil, L.map.canvas)
    p:SetSize(14, 14)
    p.tex = p:CreateTexture(nil, "OVERLAY")
    p.tex:SetAllPoints()
    p:SetScript("OnEnter", function(self) ItemTooltip(self, self.it, self.row) end)
    p:SetScript("OnLeave", function() GameTooltip:Hide() end)
    p:SetScript("OnClick", function(self) ns.Track(self.it, self.row and self.row.key) end)
    pinPool[i] = p
    return p
end

-- Pins every open item of the wanted sections on the left page map (250 at most), then draws the route.
local function PlacePins(zone)
    for _, p in ipairs(pinPool) do p:Hide() end
    if not zone.map then return end
    local secKey = Section()
    -- an open section pins its own items; otherwise treasures, rares and profession treasures, as the pin filter allows
    local wanted = secKey and { [secKey] = true }
                   or (zone.event and { guide = true, achv = true })
                   or { treasure = ns.PinOn("treasure") or nil, rare = ns.PinOn("rare") or nil, prof = ns.PinOn("prof") or nil }
    local target = ns.TargetItem()
    local n = 0
    -- one pin; the tracked item and anything up now are drawn larger and on top
    local function add(it, row, spot, kind)
        if n >= 250 or not spot or not spot.x then return end
        local x, y = ns.MapPosOn(spot, zone.map)
        if not x then return end
        n = n + 1
        local p = GetPin(n)
        p.it, p.row = it, row
        PinAtlas(p, kind)
        local big = (target and target.key == it.key) or ns.upNow[it.key] ~= nil
        p:SetSize(big and 20 or 13, big and 20 or 13)
        p:SetFrameLevel(L.map.canvas:GetFrameLevel() + (big and 5 or 2))
        p:ClearAllPoints()
        p:SetPoint("CENTER", L.map.canvas, "TOPLEFT", x * MAP_W, -y * L.map.canvas:GetHeight())
        p:Show()
    end
    for key in pairs(wanted) do
        for _, it in ipairs(zone.sections[key].items) do
            if (not it.done or ns.FarmWanted(it)) and not it.hidden then
                if it.kind == "point" then
                    for _, s in ipairs(it.spots) do add(it, nil, s, it.pkind) end
                elseif it.kind == "ach" then
                    local any = false
                    for _, row in ipairs(ns.Children(it)) do
                        if not row.done and row.spot then add(it, row, row.spot, "achv"); any = true end
                    end
                    -- no criterion has a spot: use the achievement's steps, its own spot or a glyph
                    if not any then
                        local res = ns.Resolve(it)
                        if res.spot then add(it, nil, res.spot, "achv") end
                    end
                elseif it.kind == "container" then
                    for _, s in ipairs(it.spots) do add(it, nil, s, it.ctype) end
                elseif it.kind == "lore" and expanded[it.key] then
                    local res = ns.Resolve(it)
                    if res.spot then add(it, nil, res.spot, "lore") end
                elseif it.kind == "collect" then
                    local s = it.spots and it.spots[1]
                    if s then add(it, nil, s, it.source and it.source.pkind or "vendor") end
                elseif it.kind == "step" then
                    for _, s in ipairs(it.spots) do add(it, nil, s, "step") end
                end
            end
        end
    end
    ns.DrawRoute(L.map.canvas, MAP_W, L.map.canvas:GetHeight(), zone.map, 1)
end

-- Moves the player arrow on the left page map, hidden when you are not on this zone's map.
-- Called from the frame's OnUpdate four times a second.
local function UpdatePlayerDot()
    local zone = Zone()
    local dot = L.map.player
    if not zone.map or not (C_Map and C_Map.GetPlayerMapPosition) then dot:Hide(); return end
    local ok, pos = pcall(C_Map.GetPlayerMapPosition, zone.map, "player")
    if not ok or not pos then dot:Hide(); return end
    local x, y
    if pos.GetXY then x, y = pos:GetXY() else x, y = pos.x, pos.y end
    if not x or x <= 0 or y <= 0 or x >= 1 or y >= 1 then dot:Hide(); return end
    dot:ClearAllPoints()
    dot:SetPoint("CENTER", L.map.canvas, "TOPLEFT", x * MAP_W, -y * L.map.canvas:GetHeight())
    local facing = GetPlayerFacing and GetPlayerFacing()
    if facing then dot.tex:SetRotation(facing) end
    dot:Show()
end

------------------------------------------------------------------------
-- left page: zone progress rows
------------------------------------------------------------------------

-- Opens a section's list on the right page; picking the open section again closes it to the Chronicle.
-- Also leaves the options, This Week or Warband page, and clears the Back history.
local function SelectSection(key)
    Sound("IG_ABILITY_PAGE_TURN")
    if ns.showAbout or ns.showPage then ns.showAbout = false; ns.showPage = nil; ns.cdb.lastSection = nil end
    if ns.cdb.lastSection == key then key = nil end
    ns.cdb.lastSection = key
    wipe(history)
    ns.selected = nil
    scroll = 0
    ns.RefreshUI()
end

-- Builds the left page: title and blurb, the map, the showcase that can take the map's place,
-- the Zone Progress rows and the zone total along the bottom.
local function BuildLeft()
    L = Page(LEFT_X)
    L.title = L:CreateFontString(nil, "OVERLAY")
    L.title:SetFontObject(FONT_TITLE)
    L.title:SetPoint("TOP", 0, -14)
    L.desc = Text(L, "GameFontHighlight")
    L.desc:SetPoint("TOP", L.title, "BOTTOM", 0, -6)
    L.desc:SetWidth(PAGE_W - 40)
    L.desc:SetTextColor(CREAM[1], CREAM[2], CREAM[3])
    L.desc:SetJustifyH("CENTER")

    -- the map: tiles, pins and the player arrow all live on map.canvas
    local map = CreateFrame("Frame", nil, L)
    map:SetSize(MAP_W, MAP_H)
    map:SetPoint("TOP", 0, -80)
    map:SetClipsChildren(true)
    local mbg = map:CreateTexture(nil, "BACKGROUND")
    mbg:SetAllPoints()
    mbg:SetColorTexture(0, 0, 0, 0.6)
    map.canvas = CreateFrame("Frame", nil, map)
    map.canvas:SetPoint("TOPLEFT")
    map.canvas:SetSize(MAP_W, MAP_H)
    map.player = CreateFrame("Frame", nil, map.canvas)
    map.player:SetSize(18, 18)
    map.player:SetFrameLevel(map.canvas:GetFrameLevel() + 10)
    map.player.tex = map.player:CreateTexture(nil, "OVERLAY")
    map.player.tex:SetAllPoints()
    map.player.tex:SetTexture("Interface\\WorldMap\\WorldMapArrow")
    map.player:Hide()
    map:EnableMouse(true)
    map:SetScript("OnMouseUp", function(_, button)
        local z = Zone()
        if button == "LeftButton" and z.map then ns.OpenWorldMap(z.map) end
    end)
    map:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Click to open the big map")
        GameTooltip:AddLine("Everything still missing is pinned there. Click a pin to track it.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    map:SetScript("OnLeave", function() GameTooltip:Hide() end)
    -- the pin filter button; zoneFor gives it the zone to count pins for (none on the overview)
    map.filter = ns.MakePinButton(map, 22)
    map.filter.zoneFor = function() local z = Zone(); return z and not z.overview and z end
    map.filter:SetPoint("TOPRIGHT", -4, -4)
    map.filter:SetFrameLevel(map.canvas:GetFrameLevel() + 20)
    map.hint = Text(map, "GameFontDisableSmall")
    map.hint:SetPoint("BOTTOMRIGHT", -4, 3)
    map.hint:SetJustifyH("RIGHT")
    L.map = map

    -- the showcase (3D model) sits over the map; closing it clears the pick
    L.show = ns.CreateShowcase(L, MAP_W, MAP_H, function() ns.selected = nil; ns.RefreshUI() end)
    L.show:SetPoint("TOP", 0, -80)

    L.progHead = Header(L, PAGE_W)
    L.progHead:SetPoint("TOP", map, "BOTTOM", 0, -6)
    L.progHead:Set("Zone Progress")

    -- one row per section, with a thin progress bar along its bottom
    L.rows = {}
    for i, s in ipairs(ns.SECTIONS) do
        local r = CreateFrame("Button", nil, L)
        r:SetSize(PAGE_W - 60, 18)
        r:SetPoint("TOP", L.progHead, "BOTTOM", 0, -2 - (i - 1) * 18)
        r:RegisterForClicks("LeftButtonUp")
        r.hl = r:CreateTexture(nil, "HIGHLIGHT")
        r.hl:SetAllPoints()
        r.hl:SetColorTexture(1, 0.85, 0.5, 0.08)
        r.sel = r:CreateTexture(nil, "BACKGROUND")
        r.sel:SetAllPoints()
        r.sel:SetColorTexture(1, 0.8, 0.4, 0.12)
        r.label = Text(r, "GameFontHighlight")
        r.label:SetPoint("LEFT", 6, 0)
        r.count = Text(r, "GameFontHighlight")
        r.count:SetPoint("RIGHT", -6, 0)
        r.count:SetJustifyH("RIGHT")
        r.barBg = r:CreateTexture(nil, "ARTWORK")
        r.barBg:SetHeight(2)
        r.barBg:SetPoint("BOTTOMLEFT", 6, 1)
        r.barBg:SetPoint("BOTTOMRIGHT", -6, 1)
        r.barBg:SetColorTexture(0, 0, 0, 0.45)
        r.barFill = r:CreateTexture(nil, "OVERLAY")
        r.barFill:SetHeight(2)
        r.barFill:SetPoint("BOTTOMLEFT", r.barBg, "BOTTOMLEFT")
        r.key = s.key
        r:SetScript("OnClick", function(self) SelectSection(self.key) end)
        r:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.label:GetText() or s.name)
            GameTooltip:AddLine("Click to list everything in this section.", 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end)
        r:SetScript("OnLeave", function() GameTooltip:Hide() end)
        L.rows[i] = r
    end

    -- the zone total
    L.total = Text(L, "GameFontNormalLarge")
    L.total:SetPoint("BOTTOMLEFT", 36, 30)
    L.totalPct = Text(L, "GameFontNormalLarge")
    L.totalPct:SetPoint("BOTTOMRIGHT", -36, 30)
    L.totalPct:SetJustifyH("RIGHT")
    L.bar = Bar(L, PAGE_W - 72, 8)
    L.bar:SetPoint("BOTTOM", 0, 16)
end

-- Redraws the left page for the open zone. The map tiles are only redrawn when the map ID changes.
local function RefreshLeft()
    local z = Zone()
    L.title:SetText(z.name)
    -- a holiday: when it is on, then its blurb
    -- a holiday: only when it is on (its blurb would run into the map; the right page has it)
    if z.event then
        L.desc:SetText(ns.EventStatusText(z))
    else
        L.desc:SetText(z.desc or "")
    end
    L.progHead:Set(z.event and "Holiday Progress" or "Zone Progress")
    local mapID = z.map or 2537   -- map art for zones without a map of their own
    if L.drawn ~= mapID then
        L.drawn = mapID
        DrawMap(mapID)
    end
    -- a picked mount, pet, appearance or rare replaces the map with its model (a pick from another zone is dropped)
    local sel = ns.selected
    if sel and ((sel.parent or sel).zone ~= z) then sel = nil; ns.selected = nil end
    if sel and (L.presented == sel or L.show:Present(sel)) then
        L.presented = sel
        L.map:Hide(); L.show:Show()
    else
        L.presented = nil
        L.show:Hide(); L.map:Show()
    end
    PlacePins(z)
    UpdatePlayerDot()
    local sec = Section()
    L.map.hint:SetText(z.map and ((sec and z.sections[sec].name or (z.event and "Holiday spots" or "Treasures and rares")) .. " still missing  -  click to enlarge") or "")
    -- section rows: grey with a dash when the section has nothing countable; a holiday has fewer sections
    local defs = SectionDefs(z)
    for i, r in ipairs(L.rows) do
        local def = defs[i]
        r:SetShown(def ~= nil)
        if def then r.key = def.key end
    end
    for _, r in ipairs(L.rows) do
        local s = r:IsShown() and z.sections[r.key]
        if not s then break end
        local label = s.name
        r.label:SetText(label)
        local frac = (s.max > 0) and (s.cur / s.max) or 0
        r.barFill:SetWidth(math.max(0.001, (PAGE_W - 72) * frac))
        if frac >= 1 then r.barFill:SetColorTexture(0.35, 0.75, 0.35, 0.9) else r.barFill:SetColorTexture(0.85, 0.62, 0.22, 0.9) end
        r.barFill:SetShown(s.max > 0)
        if s.max == 0 then
            r.count:SetText("-")
            r.label:SetTextColor(GREY[1], GREY[2], GREY[3])
            r.count:SetTextColor(GREY[1], GREY[2], GREY[3])
        else
            r.count:SetText(string.format("%d / %d", s.cur, s.max))
            local c = s.cur >= s.max and DONE_C or CREAM
            r.label:SetTextColor(c[1], c[2], c[3])
            r.count:SetTextColor(c[1], c[2], c[3])
        end
        r.sel:SetShown(sec == r.key)
    end
    local cur, max = ns.ZoneTotals(z)
    L.total:SetText(string.format("%s: %d / %d", z.overview and z.name or "Total", cur, max))
    L.totalPct:SetText(ns.Pct(cur, max) .. "%")
    L.bar:SetFrac(cur, max)
end

------------------------------------------------------------------------
-- right page: chronicle
------------------------------------------------------------------------

-- The prose at the top of the Chronicle: when you first came here, time spent and progress, closed by a
-- line that depends on the percentage. On the overview the time is summed over every zone.
local function ChronicleText(z)
    -- a holiday: when it is on, how far you are, what it is about and what you carry of its currency
    if z.event then
        local cur, max = ns.ZoneTotals(z)
        local parts = { z.desc and (z.desc .. "\n\n") or "", ns.EventStatusText(z) .. "." }
        if max > 0 then
            parts[#parts + 1] = string.format("You have %d of its %d achievements and collectibles.", cur, max)
        end
        if z.intro then parts[#parts + 1] = "\n\n" .. z.intro end
        local cur2 = z.def and z.def.currency
        if cur2 and GetItemCount then
            local ok, n = pcall(GetItemCount, cur2, true)
            local name = ns.ItemName(cur2)
            if ok and n and name then parts[#parts + 1] = string.format("\n\nIn your bags and bank: |cffffffff%d %s|r.", n, name) end
        end
        local cid = z.def and z.def.currencyID
        if cid and C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
            local ok, info = pcall(C_CurrencyInfo.GetCurrencyInfo, cid)
            if ok and info and info.name then parts[#parts + 1] = string.format("\n\nYou have |cffffffff%d %s|r.", info.quantity or 0, info.name) end
        end
        return table.concat(parts, " ")
    end
    local c = ns.cdb.chronicle[z.key]
    local cur, max = ns.ZoneTotals(z)
    local pct = ns.Pct(cur, max)
    local parts = {}
    if z.overview then
        local secs = 0
        for k, v in pairs(ns.cdb.chronicle) do
            local zz = ns.zoneByKey[k]
            if zz and zz.exp == z.exp then secs = secs + (v.secs or 0) end
        end
        parts[#parts + 1] = string.format("You have spent %s in %s's zones and finished %d of the %d things this book tracks for it.", ns.Duration(secs), z.name, cur, max)
    elseif not c or not c.firstTime then
        parts[#parts + 1] = string.format("You have not set foot in %s since this book was opened.", z.name)
        if cur > 0 then parts[#parts + 1] = string.format("Still, %d of its %d pages are already written, many by your warband.", cur, max) end
    else
        parts[#parts + 1] = string.format("You first reached %s on %s at level %d. You have spent %s here and finished %d of the %d things this page tracks.",
            z.name, date("%d %B %Y", c.firstTime), c.firstLevel or 0, ns.Duration(c.secs), cur, max)
    end
    if max > 0 then
        if pct >= 100 then parts[#parts + 1] = "Every page is written."
        elseif pct >= 75 then parts[#parts + 1] = "Only a few pages remain blank."
        elseif pct >= 40 then parts[#parts + 1] = "Much has revealed itself, though parts of its story remain unwritten."
        elseif cur > 0 then parts[#parts + 1] = "Its story has only begun."
        end
    end
    return table.concat(parts, " ")
end

-- Up to four things worth doing now for Next Up, nearest first but weighted: a rare that is up comes first,
-- then the storyline, achievements nearly done, bountiful delves and rares worth farming.
-- Entries are { it, d = yards or nil, res = ns.Resolve result, score, why = the reason shown, or nil }.
local function NextUp(z)
    -- a holiday: the next open steps of its guide, in order
    if z.event then
        local out, after = {}, nil
        for _ = 1, 4 do
            local st = ns.NextEventStep(z, after)
            if not st or (out[1] and st == out[1].it) then break end
            local res = ns.Resolve(st)
            local pinst, pwx, pwy = ns.PlayerWorld()
            out[#out + 1] = { it = st, res = res, d = res.spot and pinst and ns.Distance(res.spot, pinst, pwx, pwy) }
            after = st
        end
        return out
    end
    local pinst, pwx, pwy = ns.PlayerWorld()
    local cands = {}
    -- score = distance in yards, scaled down for what is worth more right now; lower comes first
    local function consider(it, secKey)
        local wanted = (not it.done and (it.max or 0) > 0) or ns.FarmWanted(it)
        if it.hidden or not wanted then return end
        local res = ns.Resolve(it)
        local d = res.spot and pinst and ns.Distance(res.spot, pinst, pwx, pwy)
        local score, why = d or 6000, nil
        if ns.upNow[it.key] then
            score, why = -1, "|cff55ff55up now|r"
        elseif secKey == "story" then
            score, why = score * 0.5, "story"
        elseif it.kind == "ach" and (it.max or 0) > 1 and (it.cur or 0) >= it.max * 0.75 then
            score, why = score * 0.4, string.format("|cffffd100almost: %d/%d|r", it.cur, it.max)
        elseif it.kind == "container" and it.ctype == "delve" and ns.IsBountiful(it.name) then
            score, why = score * 0.6, "|cffffd100bountiful|r"
        elseif ns.FarmWanted(it) then
            score, why = score * 0.8, "|cffff9040" .. (ns.FarmTag(it) or "farm") .. "|r"
        end
        cands[#cands + 1] = { it = it, d = d, res = res, score = score, why = why }
    end
    for _, key in ipairs({ "story", "side", "treasure", "rare", "achv", "delve" }) do
        for _, it in ipairs(z.sections[key].items) do consider(it, key) end
    end
    table.sort(cands, function(a, b) return a.score < b.score end)
    local out = {}
    for i = 1, math.min(4, #cands) do out[i] = cands[i] end
    return out
end

-- Builds the right page: the Chronicle, the section list and its buttons, the search box and the tracking
-- line. The options, This Week and Warband pages are added to R later by About.lua and Pages.lua.
local function BuildRight()
    R = Page(RIGHT_X)

    -- chronicle mode
    R.chron = CreateFrame("Frame", nil, R)
    R.chron:SetAllPoints()
    R.chronHead = Header(R.chron, PAGE_W)
    R.chronHead:SetPoint("TOP", 0, -14)
    R.chronHead:Set("Chronicle Entry")
    R.chronText = Text(R.chron, "GameFontHighlight")
    R.chronText:SetPoint("TOPLEFT", 26, -72)
    R.chronText:SetWidth(PAGE_W - 52)
    R.chronText:SetTextColor(CREAM[1], CREAM[2], CREAM[3])
    R.chronText:SetSpacing(3)

    -- Recent Adventures: seven log lines, each with its time underneath (placed by RefreshChronicle)
    R.advHead = Header(R.chron, PAGE_W)
    R.advHead:Set("Recent Adventures")
    R.adv = {}
    for i = 1, 7 do
        local a = Text(R.chron, "GameFontHighlight")
        a:SetWidth(PAGE_W - 60)
        a:SetWordWrap(false)
        a:SetTextColor(CREAM[1], CREAM[2], CREAM[3])
        local t = Text(R.chron, "GameFontDisableSmall")
        a.time = t
        R.adv[i] = a
    end

    -- Next Up: four buttons, each tracks its item
    R.nextHead = Header(R.chron, PAGE_W)
    R.nextHead:Set("Next Up")
    R.next = {}
    for i = 1, 4 do
        local b = CreateFrame("Button", nil, R.chron)
        b:SetSize(PAGE_W - 52, 20)
        b.hl = b:CreateTexture(nil, "HIGHLIGHT")
        b.hl:SetAllPoints()
        b.hl:SetColorTexture(1, 0.85, 0.5, 0.08)
        b.text = Text(b, "GameFontHighlight")
        b.text:SetPoint("LEFT", 4, 0)
        b.text:SetWidth(PAGE_W - 200)
        b.text:SetWordWrap(false)
        b.dist = Text(b, "GameFontDisableSmall")
        b.dist:SetPoint("RIGHT", -4, 0)
        b:SetScript("OnClick", function(self) if self.it then ns.Track(self.it) end end)
        b:SetScript("OnEnter", function(self) if self.it then ItemTooltip(self, self.it) end end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        R.next[i] = b
    end

    -- list mode
    R.list = CreateFrame("Frame", nil, R)
    R.list:SetAllPoints()
    R.listHead = Header(R.list, PAGE_W)
    R.listHead:SetPoint("TOP", 0, -14)
    -- reads "< Back" while there is history, "< Chronicle" otherwise
    R.back = CreateFrame("Button", nil, R.list)
    R.back:SetSize(90, 18)
    R.back:SetPoint("TOPLEFT", 12, -46)
    R.back.text = Text(R.back, "GameFontNormalSmall")
    R.back.text:SetPoint("LEFT")
    R.back.text:SetText("< Chronicle")
    R.back:SetScript("OnClick", function() ns.Back() end)

    -- the toolbar: small icon buttons on one row, between the back link and the search box. The two
    -- switches (Hide done, Sort) light up when on; Route lights up while a route runs on this page.
    local function Tool(n, icon, title, tip, onClick)
        local b = CreateFrame("Button", nil, R.list, "BackdropTemplate")
        b:SetSize(24, 24)
        b:SetPoint("TOPRIGHT", -(18 + 160 + 8) - (5 - n) * 27, -40)
        if b.SetBackdrop then
            b:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 9 })
        end
        b.icon = b:CreateTexture(nil, "ARTWORK")
        b.icon:SetPoint("TOPLEFT", 3, -3)
        b.icon:SetPoint("BOTTOMRIGHT", -3, 3)
        b.icon:SetTexture(icon)
        b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
        b.title, b.tip = title, tip
        b:SetScript("OnClick", onClick)
        b:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(type(self.title) == "function" and self.title() or self.title)
            GameTooltip:AddLine(self.tip, 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        -- on: gold border and full colour; off: dim
        function b:SetActive(on)
            if self.SetBackdropBorderColor then
                self:SetBackdropBorderColor(on and 1 or 0.45, on and 0.82 or 0.38, on and 0.3 or 0.28, 1)
            end
            self.icon:SetDesaturated(not on)
            self.icon:SetAlpha(on and 1 or 0.75)
        end
        b:SetActive(false)
        return b
    end

    R.hide = Tool(1, "Interface\\RaidFrame\\ReadyCheck-Ready",
        function() return ns.db.settings.hidedone and "Hide done: on" or "Hide done: off" end,
        "Show only what is still missing.", function()
            ns.db.settings.hidedone = not ns.db.settings.hidedone
            scroll = 0
            ns.RefreshUI()
        end)
    R.hide.icon:SetTexCoord(0, 1, 0, 1)

    R.sort = Tool(2, "Interface\\Icons\\INV_Misc_Spyglass_03",
        function() return ns.db.settings.sortNearest and "Sort: nearest first" or "Sort: list order" end,
        "Nearest to you first (anything with a spot), or the list's own order.", function()
            ns.db.settings.sortNearest = not ns.db.settings.sortNearest
            scroll = 0
            ns.RefreshUI()
        end)

    -- Nearest: tracks the closest open item, or the first open one when none has a known spot
    R.nearest = Tool(3, "Interface\\Icons\\Ability_Hunter_MarkedForDeath", "Track the nearest",
        "Points the arrow at the closest open one on this page.", function()
            local z, sec = Zone(), Section()
            if not sec then return end
            local best, bestD, first
            local pinst, pwx, pwy = ns.PlayerWorld()
            for _, it in ipairs(z.sections[sec].items) do
                if not it.done and not it.hidden and (it.max or 0) > 0 then
                    first = first or it
                    local res = ns.Resolve(it)
                    local d = res.spot and pinst and ns.Distance(res.spot, pinst, pwx, pwy)
                    if d and (not bestD or d < bestD) then best, bestD = it, d end
                end
            end
            best = best or first
            if best then ns.Track(best) else ns.Print("Nothing open in this section.") end
        end)
    R.nearest:SetActive(true)

    -- Route: plans a route through this section, or stops the one already running here
    local function RouteHere()
        local r, z, sec = ns.cdb.route, Zone(), Section()
        return r and r.zone == z.key and r.sec == sec
    end
    R.route = Tool(4, "Interface\\Icons\\Ability_Hunter_Pathfinding",
        function() return RouteHere() and "Stop the route" or "Plan a route" end,
        "The shortest loop through everything still open here, starting from where you stand. The arrow moves on "
            .. "as you finish each stop; right-click the arrow to skip one. Drawn on both maps.", function()
            local z, sec = Zone(), Section()
            if RouteHere() then ns.StopRoute()
            elseif sec then ns.PlanRouteForSection(z, sec) end
            ns.RefreshUI()
        end)
    R.route.IsHere = RouteHere

    -- Report a gap: copyable details for a bug report about this page
    R.report = Tool(5, "Interface\\Icons\\INV_Misc_Note_01", "Report a gap",
        "Something missing or wrong here? Opens the details to copy into a bug report.", function() ns.ShowReport() end)
    R.report:SetActive(true)

    R.empty = Text(R.list, "GameFontDisable")
    R.empty:SetPoint("TOP", 0, -120)

    -- the scrolling list: rows are pooled slots in the viewport, the wheel moves three lines
    R.viewport = CreateFrame("Frame", nil, R.list)
    R.viewport:SetPoint("TOPLEFT", 10, -LIST_TOP)
    R.viewport:SetPoint("BOTTOMRIGHT", -16, LIST_BOTTOM)
    R.viewport:EnableMouseWheel(true)
    R.viewport:SetScript("OnMouseWheel", function(_, delta)
        scroll = math.max(0, scroll - delta * 3)
        ns.RefreshList()
    end)
    R.thumb = R.list:CreateTexture(nil, "OVERLAY")
    R.thumb:SetColorTexture(0.72, 0.56, 0.30, 0.6)
    R.thumb:SetWidth(4)
    R.footer = Text(R.list, "GameFontDisableSmall")
    R.footer:SetPoint("BOTTOM", 0, 8)
    R.rows = {}

    -- search: the whole book from the Chronicle, the open section otherwise
    R.search = CreateFrame("EditBox", nil, R, "SearchBoxTemplate")
    R.search:SetSize(160, 20)
    R.search:SetPoint("TOPRIGHT", -18, -42)
    R.search:SetAutoFocus(false)
    if type(R.search.Instructions) == "table" then R.search.Instructions:SetText("Search the book") end
    R.search:HookScript("OnTextChanged", function(self)
        local t = (self:GetText() or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
        if t == searchText then return end
        searchText = t
        scroll = 0
        ns.RefreshUI()
    end)
    R.search:SetScript("OnEscapePressed", function(self) self:SetText(""); self:ClearFocus() end)

    -- what you are tracking, always one click away
    R.track = CreateFrame("Button", nil, R)
    R.track:SetHeight(18)
    R.track:SetPoint("BOTTOMLEFT", 16, 6)
    R.track:SetPoint("BOTTOMRIGHT", -16, 6)
    R.track:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    R.track.bg = R.track:CreateTexture(nil, "BACKGROUND")
    R.track.bg:SetAllPoints()
    R.track.bg:SetColorTexture(1, 0.8, 0.35, 0.08)
    R.track.text = Text(R.track, "GameFontNormalSmall")
    R.track.text:SetPoint("LEFT", 6, 0)
    R.track.text:SetPoint("RIGHT", -6, 0)
    R.track.text:SetWordWrap(false)
    R.track:SetScript("OnClick", function(_, button)
        if button == "RightButton" then ns.Track(nil); return end
        ns.JumpTo(ns.TargetItem())
    end)
    R.track:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Now tracking")
        GameTooltip:AddLine("Click: open its page. Right-click: stop tracking.", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    R.track:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Back: the page before the last jump, else out of the section (or search) to the Chronicle.
function ns.Back()
    local h = table.remove(history)
    if h then
        Sound("IG_ABILITY_PAGE_TURN")
        ns.cdb.lastZone, ns.cdb.lastSection = h.zone, h.sec
        ns.cdb.lastExpansion, ns.cdb.lastEvent = h.exp, h.event
        ns.showPage = h.page
        if R.search then R.search:SetText(h.search) end
        searchText = h.search
        scroll = h.scroll
        ns.RefreshUI()
        return
    end
    if R.search then R.search:SetText("") end
    if ns.cdb.lastSection then SelectSection(ns.cdb.lastSection) else ns.RefreshUI() end
end

-- Opens the page an item lives on and scrolls it into view. The page you leave is kept for Back (last 10).
function ns.JumpTo(it)
    if not it then return end
    local host = it.parent or it
    if not host.zone then return end
    if not ns.showAbout and (Zone() ~= host.zone or ns.cdb.lastSection ~= host.sec or searchText ~= "") then
        history[#history + 1] = { zone = ns.cdb.lastZone, sec = ns.cdb.lastSection, search = searchText, scroll = scroll,
                                  page = ns.showPage, exp = ns.cdb.lastExpansion, event = ns.cdb.lastEvent }
        if #history > 10 then table.remove(history, 1) end
    end
    -- a holiday item opens the Seasonal pages, anything else the zone book
    if host.zone.event then
        ns.cdb.lastExpansion = "seasonal"
        ns.cdb.lastEvent = host.zone.key
    else
        ns.cdb.lastExpansion = host.zone.exp or "midnight"
        ns.cdb.lastZone = host.zone.key
    end
    ns.cdb.lastSection = host.sec
    ns.showAbout = false
    ns.showPage = nil
    if it.parent then expanded[it.parent.key] = true end
    searchText = ""
    if R and R.search then R.search:SetText("") end
    scroll = 0
    ns.RefreshUI()
    -- with the list rebuilt, put the item's line fourth from the top
    for i, ln in ipairs(lines) do
        if ln.it == it and not ln.row then scroll = math.max(0, i - 4); break end
    end
    ns.RefreshList()
end

-- Fills the Chronicle: the prose, the latest adventures here (from every zone on the overview) and Next Up.
-- Laid out top-down by hand, since the prose height varies.
local function RefreshChronicle()
    local z = Zone()
    R.chronHead:Set(z.event and "The Holiday" or "Chronicle Entry")
    R.nextHead:Set(z.event and "Next Steps" or "Next Up")
    R.chronText:SetText(ChronicleText(z))
    local y = -72 - R.chronText:GetStringHeight() - 16
    R.advHead:ClearAllPoints()
    R.advHead:SetPoint("TOP", 0, y)
    y = y - 32
    local shown = 0
    -- the log is newest first
    for _, e in ipairs(ns.cdb.log) do
        if shown >= #R.adv then break end
        local ez = ns.zoneByKey[e.zone or ""]
        if e.zone == z.key or (z.overview and ez and ez.exp == z.exp) then
            shown = shown + 1
            local a = R.adv[shown]
            a:ClearAllPoints()
            a:SetPoint("TOPLEFT", 30, y)
            a:SetText("|cffc8a060*|r " .. e.text)
            a.time:ClearAllPoints()
            a.time:SetPoint("TOPLEFT", a, "BOTTOMLEFT", 10, -1)
            a.time:SetText(ns.Ago(e.t))
            a:Show(); a.time:Show()
            y = y - 32
        end
    end
    for i = shown + 1, #R.adv do R.adv[i]:Hide(); R.adv[i].time:Hide() end
    if shown == 0 then
        local a = R.adv[1]
        a:ClearAllPoints()
        a:SetPoint("TOPLEFT", 30, y)
        a:SetText("|cff9a927fNothing yet. Finished things are written here as you do them.|r")
        a:Show()
        y = y - 26
    end
    R.nextHead:ClearAllPoints()
    R.nextHead:SetPoint("TOP", 0, y - 6)
    y = y - 40
    local nexts = NextUp(z)
    for i, b in ipairs(R.next) do
        local n = nexts[i]
        if n then
            b.it = n.it
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", 26, y)
            local secName = n.it.sec and z.sections[n.it.sec].name or ""
            b.text:SetText(string.format("|cffc8a060%s:|r %s", secName, n.it.liveName or n.it.name or "?"))
            local dist = n.d and string.format("%d yd", math.floor(n.d)) or ""
            b.dist:SetText(n.why and (n.why .. (dist ~= "" and ("  " .. dist) or "")) or dist)
            b:Show()
            y = y - 21
        else
            b:Hide()
        end
    end
    if #nexts == 0 then R.nextHead:Hide() else R.nextHead:Show() end
end

------------------------------------------------------------------------
-- right page: section list
------------------------------------------------------------------------

-- Order and headings of the collectible groups in the Collectibles list.
local GROUP_ORDER = { mount = 1, pet = 2, toy = 3, decor = 4, title = 5, set = 6, appearance = 7 }
local GROUP_PLURAL = { mount = "Mounts", pet = "Pets", toy = "Toys", decor = "Decor", title = "Titles", set = "Sets",
                       appearance = "Appearances" }

-- Returns an item's group key (which also sorts collectibles) and its heading: the collectible type,
-- the parent achievement or the data group. Ungrouped items share "zz" with no heading.
local function GroupOf(it)
    if it.pkind == "boss" then return "zzboss", "World bosses" end
    if it.kind == "collect" then
        local t = it.ctype or "zz"
        return "t" .. (GROUP_ORDER[t] or 9) .. t, GROUP_PLURAL[t] or "Loading"
    end
    if it.groupAch then
        local a = ns.Ach(it.groupAch)
        return "a" .. it.groupAch, a and a.name or ("Achievement " .. it.groupAch)
    end
    if it.group then return "g" .. it.group, it.group end
    return "zz", nil
end

-- Whether an item gets a line: never when hidden, and not when done while Hide done is on.
local function Visible(it)
    if it.hidden then return false end
    if ns.db.settings.hidedone and it.done and not ns.FarmWanted(it) then return false end
    return true
end

-- True when s contains the search text, ignoring case (a plain find, no patterns).
local function Matches(s) return type(s) == "string" and s:lower():find(searchText, 1, true) ~= nil end

-- True when an item's name matches the search, or, from three letters on, the name of one of its children.
local function ItemMatches(it)
    if Matches(it.liveName or it.name) then return true end
    if #searchText >= 3 and (it.kind == "ach" or it.kind == "lore" or it.kind == "container" or it.steps) then
        for _, row in ipairs(ns.Children(it)) do
            if Matches(row.name) or (row.item and Matches(row.item.name)) then return true end
        end
    end
    return false
end

-- Fills lines with search hits from every zone and section, under a heading per zone. Dungeon and delve
-- children are searched too. Stops adding hits at 300 lines.
local function BuildSearch()
    local pages = {}
    for _, z in ipairs(ns.ZONES) do pages[#pages + 1] = z end
    for _, z in ipairs(ns.EVENT_ZONES or {}) do pages[#pages + 1] = z end
    for _, z in ipairs(pages) do
        local header = false
        for _, sdef in ipairs(SectionDefs(z)) do
            for _, it in ipairs(z.sections[sdef.key].items) do
                local cands = { it }
                if it.kind == "container" then for _, ch in ipairs(it.children) do cands[#cands + 1] = ch end end
                for _, c in ipairs(cands) do
                    if #lines < 300 and not c.hidden and ItemMatches(c) then
                        if not header then
                            lines[#lines + 1] = { header = true, text = z.name, cur = 0, max = 0 }
                            header = true
                        end
                        lines[#lines + 1] = { it = c, depth = 0, result = true, secName = sdef.name }
                    end
                end
            end
        end
    end
end

-- Sections where "Sort: nearest" applies.
local SORTABLE = { treasure = true, rare = true, collect = true, achv = true, prof = true, instance = true, delve = true }

-- Builds the right page list for the open section (or the book-wide search when none is open):
-- group headings, items, and the children of expanded items, two levels deep.
local function BuildLines()
    wipe(lines)
    local z, secKey = Zone(), Section()
    if not secKey then
        if searchText ~= "" then BuildSearch() end
        return
    end
    local items = z.sections[secKey].items
    -- searching inside a section filters it, and opens items whose match is in a child
    if searchText ~= "" then
        local filtered = {}
        for _, it in ipairs(items) do
            if ItemMatches(it) then filtered[#filtered + 1] = it; expanded[it.key] = expanded[it.key] or (#searchText >= 3 and not Matches(it.liveName or it.name)) end
        end
        items = filtered
    end
    -- group the shown items, groups in order of first appearance (expanded items stay even when done)
    local groups, order = {}, {}
    for idx, it in ipairs(items) do
        if Visible(it) or (not it.hidden and expanded[it.key]) then
            local gk, glabel = GroupOf(it)
            local g = groups[gk]
            if not g then
                g = { key = gk, label = glabel, items = {}, first = idx, cur = 0, max = 0 }
                groups[gk] = g
                order[#order + 1] = g
            end
            g.items[#g.items + 1] = it
        end
    end
    -- group totals count done items too, even when they are hidden
    for _, it in ipairs(items) do
        local gk = GroupOf(it)
        local g = groups[gk]
        if g then g.cur, g.max = g.cur + (it.cur or 0), g.max + (it.max or 0) end
    end
    -- collectible groups go in type order (mounts, pets, toys, ...); other groups keep list order
    if secKey == "collect" then table.sort(order, function(a, b) return a.key < b.key end) end
    -- world bosses always come last on the Rares page, apart from the rares the patrol visits
    for i, g in ipairs(order) do
        if g.key == "zzboss" and i < #order then table.remove(order, i); order[#order + 1] = g; break end
    end
    -- "Sort: nearest" reorders items within each group; ones without a known distance go last
    if ns.db.settings.sortNearest and SORTABLE[secKey] then
        for _, g in ipairs(order) do
            local d = {}
            for _, it in ipairs(g.items) do d[it] = ns.ItemDistance(it) or math.huge end
            table.sort(g.items, function(a, b) return d[a] < d[b] end)
        end
    end
    -- headings only when there is more than one group, or the only group has a name
    local multi = #order > 1 or (order[1] and order[1].label)
    for _, g in ipairs(order) do
        if multi and g.label then
            lines[#lines + 1] = { header = true, text = g.label, cur = g.cur, max = g.max }
        end
        for _, it in ipairs(g.items) do
            lines[#lines + 1] = { it = it, depth = 0 }
            -- children are either real items (which can expand again) or rows such as criteria, steps and quests
            if expanded[it.key] then
                for _, row in ipairs(ns.Children(it)) do
                    if row.item then
                        if Visible(row.item) then
                            lines[#lines + 1] = { it = row.item, depth = 1, parent = it }
                            if expanded[row.item.key] then
                                for _, sub in ipairs(ns.Children(row.item)) do
                                    if not (ns.db.settings.hidedone and sub.done) then
                                        lines[#lines + 1] = { it = row.item, row = sub, depth = 2 }
                                    end
                                end
                            end
                        end
                    elseif not (ns.db.settings.hidedone and row.done and not row.current) then
                        lines[#lines + 1] = { it = it, row = row, depth = 1 }
                    end
                end
                -- an achievement split over zones: its parts in the other zones, each opening into its rows
                if it.kind == "ach" and it.split then
                    local parts = ns.SplitParts(it)
                    for i = 2, #parts do
                        local p = parts[i]
                        lines[#lines + 1] = { it = p, depth = 1, part = true }
                        if expanded[p.key] then
                            for _, sub in ipairs(ns.Children(p)) do
                                if not (ns.db.settings.hidedone and sub.done) then
                                    lines[#lines + 1] = { it = p, row = sub, depth = 2 }
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Whether an item can expand: dungeons and delves, achievements, lore with a quest chain, multi-step treasures.
local function HasChildren(it)
    return it.kind == "container" or it.kind == "ach" or (it.kind == "lore" and it.crit.chain) or (it.kind == "point" and it.steps)
end

-- List row clicks. Right-click stops tracking; a chat-link click links it; a search hit jumps to its page;
-- a child row is tracked (shift-click marks a step done); an item opens or closes, shows its model if it
-- has one, and is tracked unless it is done or a reputation.
local function OnRowClick(r, button)
    local ln = r.line
    if not ln or ln.header then return end
    local it, row = ln.it, ln.row
    if button == "RightButton" then
        local t = ns.cdb.target
        if t and t.key == it.key then ns.Track(nil) end
        return
    end
    -- Alt-click: on or off the watch list
    if IsAltKeyDown and IsAltKeyDown() then
        ns.WatchToggle(it, row and not row.item and row.key or nil)
        ns.RefreshUI()
        return
    end
    if IsModifiedClick and IsModifiedClick("CHATLINK") then
        local link
        if it.kind == "ach" and GetAchievementLink then link = GetAchievementLink(it.id)
        elseif it.kind == "lore" and GetAchievementLink then link = GetAchievementLink(it.ach)
        elseif it.kind == "collect" and it.itemID then
            local get = (C_Item and C_Item.GetItemInfo) or GetItemInfo
            if get then local _, l = get(it.itemID); link = l end
        end
        if link and ChatEdit_InsertLink then ChatEdit_InsertLink(link) end
        return
    end
    if ln.result then
        ns.JumpTo(it)
        if it.kind ~= "rep" and ns.StillWanted(it) then ns.Track(it) end
        return
    end
    if row then
        if row.step and IsShiftKeyDown() then
            ns.MarkStep(it, row.step)
            ns.UpdateTarget()
            ns.RefreshUI()
            return
        end
        ns.Track(it, row.key)
        return
    end
    -- a holiday step: shift-click ticks or unticks it by hand
    if it.kind == "step" and IsShiftKeyDown and IsShiftKeyDown() then
        ns.cdb.steps[it.key] = (not ns.cdb.steps[it.key]) or nil
        if ns.Evaluate then ns.Evaluate() end
        return
    end
    if HasChildren(it) then expanded[it.key] = not expanded[it.key] or nil end
    local showable = it.kind == "collect" or (it.kind == "point" and (it.pkind == "rare" or it.pkind == "boss"))
    if showable and ns.ModelInfo(it) then ns.selected = it else ns.selected = nil end
    L.presented = nil
    -- a finished zone part of a split achievement: track the next unfinished part instead
    if it.kind == "ach" and it.split and it.done then
        local parts = ns.SplitParts(it)
        for i = 2, #parts do
            if not parts[i].done then ns.Track(parts[i]); return end
        end
    end
    if it.kind ~= "rep" and ns.StillWanted(it) then ns.Track(it) else ns.RefreshUI() end
end

-- Returns list row slot i, creating it on first use. Slots stay put; FillRow puts a line into one.
local function GetRow(i)
    local r = R.rows[i]
    if r then return r end
    r = CreateFrame("Button", nil, R.viewport)
    r:SetHeight(ROW_H)
    r:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_H)
    r:SetPoint("RIGHT", R.viewport, "RIGHT", 0, 0)
    r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    r.hl = r:CreateTexture(nil, "HIGHLIGHT")
    r.hl:SetAllPoints()
    r.hl:SetColorTexture(1, 0.85, 0.5, 0.08)
    r.track = r:CreateTexture(nil, "BACKGROUND")
    r.track:SetAllPoints()
    r.track:SetColorTexture(1, 0.8, 0.3, 0.14)
    r.status = r:CreateTexture(nil, "ARTWORK")
    r.status:SetSize(13, 13)
    r.icon = r:CreateTexture(nil, "ARTWORK")
    r.icon:SetSize(15, 15)
    r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    r.plus = Text(r, "GameFontNormalSmall")
    r.plus:SetWidth(10)
    r.text = Text(r, "GameFontHighlight")
    r.text:SetWordWrap(false)
    r.right = Text(r, "GameFontHighlightSmall")
    r.right:SetPoint("RIGHT", -2, 0)
    r.right:SetJustifyH("RIGHT")
    r.bar = r:CreateTexture(nil, "BACKGROUND")
    r.bar:SetHeight(1)
    r.bar:SetPoint("BOTTOMLEFT", 4, 1)
    r.bar:SetPoint("BOTTOMRIGHT", -4, 1)
    r.bar:SetColorTexture(0.72, 0.56, 0.30, 0.5)
    r:SetScript("OnClick", OnRowClick)
    r:SetScript("OnEnter", function(self)
        local ln = self.line
        if ln and not ln.header then ItemTooltip(self, ln.it, ln.row) end
    end)
    r:SetScript("OnLeave", function() GameTooltip:Hide() end)
    R.rows[i] = r
    return r
end

-- Draws one line into a row: a group heading with its count, an item, or a child row indented by depth.
-- The right column shows the item's note, "up now", a distance in yards, or the section of a search hit.
local function FillRow(r, ln)
    r.line = ln
    r.icon:Hide(); r.plus:SetText(""); r.bar:Hide(); r.track:Hide()
    r.status:ClearAllPoints(); r.text:ClearAllPoints(); r.plus:ClearAllPoints()
    if ln.header then
        r.status:Hide()
        r.text:SetPoint("LEFT", 4, 0)
        r.text:SetPoint("RIGHT", r.right, "LEFT", -6, 0)
        r.text:SetText(ln.text)
        r.text:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
        r.right:SetText(ln.max > 0 and string.format("%d/%d", ln.cur, ln.max) or "")
        local c = (ln.max > 0 and ln.cur >= ln.max) and DONE_C or GOLD
        r.right:SetTextColor(c[1], c[2], c[3])
        r.bar:Show()
        return
    end
    local it, row = ln.it, ln.row
    local indent = 4 + ln.depth * 16
    local target = ns.cdb.target
    local done, current, name, sub
    if row then
        done, current, name, sub = row.done, row.current, row.name, row.sub
        if target and target.key == it.key and target.child == row.key then r.track:Show() end
        if not sub and row.spot and ns.Distance then
            local pinst, pwx, pwy = ns.PlayerWorld()
            local d = pinst and ns.Distance(row.spot, pinst, pwx, pwy)
            if d then sub = string.format("%d yd", math.floor(d)) end
        end
    else
        done, name, sub = it.done, it.liveName or it.name or "?", it.sub
        if target and target.key == it.key and not target.child then r.track:Show() end
        -- a holiday guide: the step to do now stands out, and steps show how far away they are
        if it.kind == "step" then
            current = it.sec == "guide" and not done and ns.NextEventStep(it.zone) == it
            if not sub and not done then
                local d = ns.ItemDistance(it)
                if d then sub = string.format("%d yd", math.floor(d)) end
            end
        end
        if HasChildren(it) then
            r.plus:SetPoint("LEFT", indent, 0)
            r.plus:SetText(expanded[it.key] and "-" or "+")
            indent = indent + 10
        end
        if it.split then
            -- this zone's part, with the whole achievement's count beside it
            local _, _, adone, atotal = ns.SplitParts(it)
            if ln.part then
                name = "In " .. (it.zone and it.zone.name or "another zone")
            else
                name = name .. " |cff9a927f(this zone)|r"
                if atotal > 0 then sub = string.format("%s here, %d/%d", it.sub or "", adone, atotal) end
            end
        end
        if ns.Watched(it) then name = name .. " |cffffd100(watching)|r" end
        local farm = ns.FarmTag(it)
        if farm then sub = "|cffff9040" .. farm .. "|r" end
        if ns.upNow[it.key] then sub = "|cff55ff55up now|r" end
        if it.kind == "container" and it.ctype == "delve" and ns.IsBountiful(it.name) then
            sub = "|cffffd100bountiful|r" .. (sub and sub ~= "" and ("  " .. sub) or "")
        end
        -- a small book marks achievements that have a walkthrough or notes
        local aid = it.id or it.ach
        if (it.kind == "ach" or it.kind == "lore") and aid and ((ns.ACH_STEPS and ns.ACH_STEPS[aid]) or (ns.ACH_NOTES and ns.ACH_NOTES[aid])
            or (ns.CRIT_NOTES and ns.CRIT_NOTES[aid])) then
            name = name .. " |TInterface\\Icons\\INV_Misc_Book_09:12:12:2:0|t"
        end
    end
    r.status:Show()
    r.status:SetPoint("LEFT", indent, 0)
    r.status:SetTexture(done and ICON_DONE or (current and ICON_NOW or ICON_OPEN))
    -- a rare that is up right now gets a green "online" dot
    if not row and not done and ns.upNow[it.key] then r.status:SetTexture("Interface\\COMMON\\Indicator-Green") end
    -- faded status icon for items the game can't count yet
    if (not done and not current and (it.max or 0) == 0 and not row) or (row and row.extra) then r.status:SetAlpha(0.35) else r.status:SetAlpha(1) end
    local textLeft = indent + 17
    if not row and it.kind == "collect" then
        local icon = it.icon or (it.itemID and ns.ItemIcon(it.itemID))
        if icon then
            r.icon:SetTexture(icon)
            r.icon:SetPoint("LEFT", indent + 16, 0)
            r.icon:Show()
            textLeft = textLeft + 18
        end
    end
    r.text:SetPoint("LEFT", textLeft, 0)
    r.text:SetPoint("RIGHT", r.right, "LEFT", -6, 0)
    r.text:SetText(name)
    local c = done and DONE_C or (current and GOLD or CREAM)
    r.text:SetTextColor(c[1], c[2], c[3])
    if ln.secName then sub = ln.secName end
    r.right:SetText(sub or "")
    r.right:SetTextColor(GREY[1], GREY[2], GREY[3])
end

-- Shows the window of lines starting at scroll and places the scroll thumb. Does not rebuild lines,
-- so it is cheap enough for the mouse wheel.
function ns.RefreshList()
    if not (R and R.list:IsShown()) then return end
    local visible = math.floor((R.viewport:GetHeight() or 400) / ROW_H)
    local maxScroll = math.max(0, #lines - visible)
    if scroll > maxScroll then scroll = maxScroll end
    for i = 1, visible do
        local r = GetRow(i)
        local ln = lines[i + scroll]
        if ln then FillRow(r, ln); r:Show() else r:Hide(); r.line = nil end
    end
    for i = visible + 1, #R.rows do R.rows[i]:Hide() end
    if #lines > visible then
        local vh = R.viewport:GetHeight()
        local th = math.max(20, vh * visible / #lines)
        R.thumb:SetHeight(th)
        R.thumb:ClearAllPoints()
        R.thumb:SetPoint("TOPRIGHT", R.list, "TOPRIGHT", -7, -LIST_TOP - (vh - th) * (scroll / maxScroll))
        R.thumb:Show()
    else
        R.thumb:Hide()
    end
    R.empty:SetText(#lines == 0 and (ns.db.settings.hidedone and "Everything here is done." or (searchText ~= "" and not Section() and "Nothing in the book matches." or "Nothing found for this zone.")) or "")
end

-- A hint under each section's list, shown only while nothing is being tracked.
local FOOTERS = {
    story = "Click a questline to follow its chain; the arrow shows your next quest.",
    side = "Click a questline to follow its chain; the arrow shows your next quest.",
    achv = "Click to expand criteria and track the nearest one. Shift-click links it.",
    treasure = "Click to track. Multi-step treasures guide you step by step.",
    rare = "Track any rare to start a patrol: the arrow moves on when one isn't up and alerts you when one is.",
    collect = "Click one to see it in 3D; hover for Blizzard's tooltip and how to get it.",
    instance = "Achievements found for each dungeon and raid.",
    delve = "Track a delve: entrance first, then chest to chest inside. Inside, Route loops through its chests.",
    rep = "Maxed renown or rank counts as done.",
    prof = "Knowledge treasures for your professions (once per character).",
    guide = "Follow the steps in order; the arrow moves on as each is done. Shift-click ticks one by hand.",
    quests = "Daily quests come back each day, the others each year. Click one to go to its quest giver.",
}

-- The "Tracking:" line at the foot of the right page, with the route stop and step count when there are any.
-- Hidden on the options page or when nothing is tracked.
local function RefreshTrackLine()
    local it, child = ns.TargetItem()
    if not it or ns.showAbout then R.track:Hide(); return end
    local res = ns.Resolve(it, child)
    local step = (res.step and res.stepCount) and string.format("  |cffaaaaaa(step %d/%d)|r", res.step, res.stepCount) or ""
    R.track.text:SetText("|TInterface\\AddOns\\" .. ns.ADDON .. "\\Textures\\arrow:14:14:0:0|t |cffe6c35cTracking:|r " .. (ns.RouteActive() and ns.RouteLabel() or "") .. ns.PatrolLabel() .. (res.title or it.name or "?") .. step)
    R.track:Show()
end

-- Decides what the right page shows, first match wins: options, This Week or Warband, book-wide search
-- results, the Chronicle, or the open section's list.
local function RefreshRight()
    local sec = Section()
    R.search:SetShown(not ns.showAbout and not ns.showPage)
    if ns.showAbout then
        R.list:Hide(); R.chron:Hide(); R.track:Hide(); R.page:Hide()
        ns.RefreshAbout()
        return
    end
    R.options:Hide(); R.about:Hide(); R.scope:Hide()
    RefreshTrackLine()
    if ns.showPage then
        R.list:Hide(); R.chron:Hide()
        ns.RefreshPage()
        return
    end
    R.page:Hide()
    R.back.text:SetText(#history > 0 and "< Back" or "< Chronicle")
    if not sec and searchText ~= "" then
        R.chron:Hide()
        R.list:Show()
        R.listHead:Set("Search")
        R.hide:Hide(); R.sort:Hide(); R.nearest:Hide(); R.route:Hide()
        R.footer:SetText("")
        BuildLines()
        ns.RefreshList()
        return
    end
    R.hide:Show(); R.sort:Show(); R.nearest:Show(); R.route:Show()
    if not sec then
        R.list:Hide()
        R.chron:Show()
        RefreshChronicle()
        return
    end
    R.chron:Hide()
    R.list:Show()
    local z = Zone()
    local s = z.sections[sec]
    R.listHead:Set(string.format("%s  %d/%d", s.name, s.cur, s.max))
    R.hide:SetActive(ns.db.settings.hidedone)
    R.footer:SetText(R.track:IsShown() and "" or (FOOTERS[sec] or ""))
    R.sort:SetActive(ns.db.settings.sortNearest)
    R.route:SetActive(R.route.IsHere())
    BuildLines()
    ns.RefreshList()
end

------------------------------------------------------------------------
-- tabs on the right edge
------------------------------------------------------------------------

-- A zone tab's icon: the icon of the zone's achievement, or a question mark until it is known.
local function TabIcon(z)
    local a = ns.Ach(ns.EventPick and ns.EventPick(z.iconAch) or z.iconAch)
    return a and a.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
end

local TAB_SIZE, TAB_GAP = 50, 6   -- pixels

-- Creates a square bookmark tab in slot i down the right edge, with a percentage strip along the bottom.
-- t:SetSelected(on) lights it up and pulls it 4 px further out.
local function MakeTab(i, iconTexture, onClick, onEnter, size, y)
    size = size or TAB_SIZE
    y = y or (-30 - (i - 1) * (TAB_SIZE + TAB_GAP))
    local t = CreateFrame("Button", nil, main, "BackdropTemplate")
    t:SetSize(size, size)
    t:SetPoint("TOPLEFT", main, "TOPRIGHT", -4, y)
    t:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    t:SetBackdropColor(0.08, 0.07, 0.06, 0.95)
    t:SetBackdropBorderColor(0.60, 0.46, 0.24, 1)
    t.icon = t:CreateTexture(nil, "ARTWORK")
    t.icon:SetSize(size - 12, size - 12)
    t.icon:SetPoint("CENTER")
    t.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    if iconTexture then t.icon:SetTexture(iconTexture) end
    t.pctBg = t:CreateTexture(nil, "OVERLAY")
    t.pctBg:SetPoint("BOTTOMLEFT", t.icon, "BOTTOMLEFT")
    t.pctBg:SetPoint("BOTTOMRIGHT", t.icon, "BOTTOMRIGHT")
    t.pctBg:SetHeight(12)
    t.pctBg:SetColorTexture(0, 0, 0, 0.65)
    t.pct = t:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    t.pct:SetPoint("CENTER", t.pctBg, "CENTER", 0, 0)
    t.hl = t:CreateTexture(nil, "HIGHLIGHT")
    t.hl:SetAllPoints(t.icon)
    t.hl:SetColorTexture(1, 0.9, 0.6, 0.15)
    t:SetScript("OnClick", onClick)
    t:SetScript("OnEnter", onEnter)
    t:SetScript("OnLeave", function() GameTooltip:Hide() end)
    t.y = y
    function t:SetSelected(on)
        self:SetBackdropBorderColor(on and 1 or 0.60, on and 0.82 or 0.46, on and 0.35 or 0.24, 1)
        self.icon:SetDesaturated(not on)
        self.icon:SetAlpha(on and 1 or 0.8)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", main, "TOPRIGHT", on and 0 or -4, self.y)
    end
    return t
end

local aboutTab        -- the gear: options and about
local pageTabs = {}   -- This Week and Warband
local eventTabs = {}  -- one per holiday, shown on the Seasonal pages
local gearY = {}      -- the gear's place: under the zone tabs, or under the holiday tabs
local tabRule         -- the thin rule above the small tabs
local SMALL, SMALL_GAP = 36, 5

-- Builds a tab per zone, then the gear and, under it, the This Week and Warband tabs.
-- Clicking the gear or a page tab a second time closes that page again.
local function BuildTabs()
    -- zone tabs: click turns to the zone (the open section stays open), hover shows its total
    for i, z in ipairs(ns.ZONES) do
        local t = MakeTab(i, nil, function(self)
            if ns.cdb.lastZone ~= self.zone.key then Sound("IG_ABILITY_PAGE_TURN") end
            ns.cdb.lastZone = self.zone.key
            ns.cdb.lastZoneByExp = ns.cdb.lastZoneByExp or {}
            ns.cdb.lastZoneByExp[self.zone.exp or "midnight"] = self.zone.key
            ns.showAbout = false
            ns.showPage = nil
            wipe(history)
            ns.selected = nil
            scroll = 0
            ns.RefreshUI()
        end, function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local cur, max = ns.ZoneTotals(self.zone)
            GameTooltip:AddLine(self.zone.name)
            GameTooltip:AddLine(string.format("%d / %d  (%d%%)", cur, max, ns.Pct(cur, max)), 1, 1, 1)
            GameTooltip:Show()
        end)
        t.zone = z
        tabs[i] = t
    end
    -- the gear: toggles the options and about page
    -- This Week, Warband and the gear: smaller tabs in a group of their own under the zones, after a thin rule
    local top = -30 - 7 * (TAB_SIZE + TAB_GAP) - 12   -- moved under the zone tabs of the open expansion by RefreshTabs
    local rule = main:CreateTexture(nil, "ARTWORK")
    tabRule = rule
    rule:SetColorTexture(0.72, 0.56, 0.30, 0.6)
    rule:SetSize(SMALL - 6, 1)
    rule:SetPoint("TOPLEFT", main, "TOPRIGHT", 3, top + 7)
    local defs = {
        { "week", "Interface\\Icons\\INV_Misc_PocketWatch_01", "This Week",
          "Events up now, world quests that count, renown to earn, repeatables." },
        { "warband", "Interface\\Icons\\Ability_Warrior_RallyingCry", "Warband",
          "Your characters: storyline, side quests, treasures, rares, professions." },
    }
    for n, def in ipairs(defs) do
        local t = MakeTab(nil, def[2], function()
            ns.showPage = ns.showPage ~= def[1] and def[1] or nil
            ns.showAbout = false
            Sound("IG_ABILITY_PAGE_TURN")
            ns.RefreshUI()
        end, function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(def[3])
            GameTooltip:AddLine(def[4], 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end, SMALL, top - (n - 1) * (SMALL + SMALL_GAP))
        t.pctBg:Hide()
        t.page = def[1]
        t.slot = n
        t:SetSelected(false)
        pageTabs[#pageTabs + 1] = t
    end
    -- holiday tabs: smaller, as there are twelve; hover shows when it is on
    local EV_SIZE, EV_GAP = 36, 4
    for i, def in ipairs(ns.EVENT_DEFS or {}) do
        local t = MakeTab(nil, nil, function(self)
            if ns.cdb.lastEvent ~= self.key then Sound("IG_ABILITY_PAGE_TURN") end
            ns.cdb.lastEvent = self.key
            ns.showAbout = false
            ns.showPage = nil
            wipe(history)
            ns.selected = nil
            scroll = 0
            ns.RefreshUI()
        end, function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local z = ns.eventByKey[self.key]
            GameTooltip:AddLine(self.name)
            if z then
                GameTooltip:AddLine(ns.EventStatusText(z), 1, 1, 1)
                local cur, max = ns.ZoneTotals(z)
                if max > 0 then GameTooltip:AddLine(string.format("%d / %d  (%d%%)", cur, max, ns.Pct(cur, max)), 0.8, 0.8, 0.8) end
            end
            GameTooltip:Show()
        end, EV_SIZE, -30 - (i - 1) * (EV_SIZE + EV_GAP))
        t.key, t.name, t.def = def.key, def.name, def
        t:Hide()
        eventTabs[i] = t
    end
    gearY.zones = top - #defs * (SMALL + SMALL_GAP)
    gearY.events = -30 - #eventTabs * (EV_SIZE + EV_GAP) - 12
    aboutTab = MakeTab(nil, "Interface\\Icons\\INV_Misc_Gear_01", function()
        ns.showAbout = not ns.showAbout
        ns.showPage = nil
        ns.RefreshUI()
    end, function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Options & About")
        GameTooltip:Show()
    end, SMALL, top - #defs * (SMALL + SMALL_GAP))
    aboutTab.pctBg:Hide()
end

-- Updates the zone tabs' icons and percentages, and which tab is selected.
local function RefreshTabs()
    local cur = Zone()
    local seasonal = Seasonal()
    for _, t in ipairs(tabs) do t:SetShown(not seasonal) end
    for _, t in ipairs(pageTabs) do t:SetShown(not seasonal) end
    for _, t in ipairs(eventTabs) do
        t:SetShown(seasonal)
        if seasonal then
            local z = ns.eventByKey[t.key]
            t.icon:SetTexture(TabIcon(t.def))
            t:SetSelected(z ~= nil and z == cur and not ns.showAbout)
            -- the percentage strip reads "on" while the holiday runs
            if z and ns.EventActive(z) then
                t.pct:SetText("on"); t.pct:SetTextColor(0.4, 1, 0.4)
            elseif z then
                local c, m = ns.ZoneTotals(z)
                local p = ns.Pct(c, m)
                t.pct:SetText(p .. "%")
                if p >= 100 then t.pct:SetTextColor(0.4, 1, 0.4) else t.pct:SetTextColor(1, 1, 1) end
            end
        end
    end
    if seasonal then
        aboutTab.y = gearY.events
        tabRule:ClearAllPoints()
        tabRule:SetPoint("TOPLEFT", main, "TOPRIGHT", 3, gearY.events + 7)
        aboutTab:SetSelected(ns.showAbout and true or false)
        return
    end
    -- only the open expansion's zones, one under the other; the small tabs follow them
    local exp = cur.exp or "midnight"
    local n = 0
    for _, t in ipairs(tabs) do
        local mine = (t.zone.exp or "midnight") == exp
        t:SetShown(mine)
        if mine then
            n = n + 1
            t.y = -30 - (n - 1) * (TAB_SIZE + TAB_GAP)
        end
    end
    local top = -30 - n * (TAB_SIZE + TAB_GAP) - 12
    tabRule:ClearAllPoints()
    tabRule:SetPoint("TOPLEFT", main, "TOPRIGHT", 3, top + 7)
    for _, t in ipairs(pageTabs) do t.y = top - (t.slot - 1) * (SMALL + SMALL_GAP) end
    gearY.zones = top - #pageTabs * (SMALL + SMALL_GAP)
    aboutTab.y = gearY.zones
    for _, t in ipairs(tabs) do
        if not t:IsShown() then
            -- hidden tabs of another expansion keep their old place
        else
        t.icon:SetTexture(TabIcon(t.zone))
        t:SetSelected(t.zone == cur and not ns.showAbout and not ns.showPage)
        local c, m = ns.ZoneTotals(t.zone)
        local p = ns.Pct(c, m)
        t.pct:SetText(p .. "%")
        if p >= 100 then t.pct:SetTextColor(0.4, 1, 0.4) else t.pct:SetTextColor(1, 1, 1) end
        end
    end
    aboutTab:SetSelected(ns.showAbout and true or false)
    for _, t in ipairs(pageTabs) do t:SetSelected(ns.showPage == t.page) end
end

------------------------------------------------------------------------
-- expansions: bookmarks along the top, a "coming later" spread for the ones without data
------------------------------------------------------------------------

local expTabs = {}   -- one bookmark per ns.EXPANSIONS entry
local SL, SR         -- the left and right pages of the "coming later" spread

-- The expansion the book is open on. Falls back to Midnight if the saved key or the list is missing.
local function Expansion()
    local key = ns.cdb.lastExpansion or "midnight"
    for _, e in ipairs(ns.EXPANSIONS or {}) do
        if e.key == key then return e end
    end
    return { key = "midnight", name = "Midnight", ready = true }
end

-- Builds the expansion bookmarks, evenly spaced along the top edge, and the "coming later" spread.
local function BuildExpansions()
    local n = #(ns.EXPANSIONS or {})
    local w = math.floor((W - 60) / math.max(n, 1)) - 4
    for i, e in ipairs(ns.EXPANSIONS or {}) do
        local b = CreateFrame("Button", nil, main, "BackdropTemplate")
        b:SetSize(w, 26)
        b:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        b.text:SetPoint("CENTER", 0, 1)
        b.text:SetText(e.short)
        b.exp = e
        b.x = 30 + (i - 1) * (w + 4)
        b:SetScript("OnClick", function(self)
            ns.cdb.lastExpansion = self.exp.key
            ns.showAbout = false
            ns.showPage = nil
            ns.RefreshUI()
        end)
        b:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(self.exp.name)
            if not self.exp.ready then GameTooltip:AddLine("Coming later", 0.7, 0.7, 0.7) end
            -- the Seasonal bookmark: what is on right now
            if self.exp.seasonal and ns.built then
                local on = ns.ActiveEvents()
                if #on == 0 then GameTooltip:AddLine("No holiday is on right now.", 0.7, 0.7, 0.7) end
                for _, z in ipairs(on) do GameTooltip:AddLine(z.name .. ": " .. ns.EventStatusText(z), 1, 1, 1) end
            end
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        expTabs[i] = b
    end

    -- the "coming later" spread: the expansion's planned contents on the left, a note on the right
    SL = Page(LEFT_X)
    SL:Hide()
    SL.title = SL:CreateFontString(nil, "OVERLAY")
    SL.title:SetFontObject(FONT_TITLE)
    SL.title:SetPoint("TOP", 0, -40)
    SL.sub = Text(SL, "GameFontHighlight")
    SL.sub:SetPoint("TOP", SL.title, "BOTTOM", 0, -10)
    SL.sub:SetJustifyH("CENTER")
    SL.sub:SetWidth(PAGE_W - 60)
    SL.sub:SetTextColor(CREAM[1], CREAM[2], CREAM[3])
    SL.head = Header(SL, PAGE_W)
    SL.head:SetPoint("TOP", 0, -170)
    SL.head:Set("This Book Will Cover")
    SL.plan = Text(SL, "GameFontHighlight")
    SL.plan:SetPoint("TOPLEFT", 50, -210)
    SL.plan:SetWidth(PAGE_W - 100)
    SL.plan:SetSpacing(8)
    SL.plan:SetTextColor(CREAM[1], CREAM[2], CREAM[3])

    SR = Page(RIGHT_X)
    SR:Hide()
    SR.head = Header(SR, PAGE_W)
    SR.head:SetPoint("TOP", 0, -14)
    SR.head:Set("Not Written Yet")
    SR.text = Text(SR, "GameFontHighlight")
    SR.text:SetPoint("TOPLEFT", 30, -56)
    SR.text:SetWidth(PAGE_W - 60)
    SR.text:SetSpacing(4)
    SR.text:SetTextColor(CREAM[1], CREAM[2], CREAM[3])
    SR.text:SetText("Midnight is the first expansion in the book. Every other expansion gets the same pages: "
        .. "a tab per zone with its storyline, side quests, achievements, treasures, rares, collectibles, "
        .. "dungeons, reputation and professions, the arrow guide, map pins and hover hints.\n\n"
        .. "Until then, the Midnight bookmark on the right of this row takes you back.")
end

-- Raises the current expansion's bookmark and dims the ones without data. Returns the current expansion.
local function RefreshExpansions()
    local cur = Expansion()
    for _, b in ipairs(expTabs) do
        local on = b.exp.key == cur.key
        b:ClearAllPoints()
        b:SetPoint("BOTTOMLEFT", main, "TOPLEFT", b.x, on and -6 or -10)
        b:SetBackdropColor(on and 0.16 or 0.08, on and 0.12 or 0.07, on and 0.07 or 0.06, 0.97)
        b:SetBackdropBorderColor(on and 1 or 0.55, on and 0.82 or 0.42, on and 0.35 or 0.22, 1)
        if on then b.text:SetTextColor(1, 0.86, 0.45)
        elseif b.exp.ready then b.text:SetTextColor(0.9, 0.85, 0.75)
        else b.text:SetTextColor(0.55, 0.52, 0.48) end
    end
    return cur
end

------------------------------------------------------------------------
-- main frame
------------------------------------------------------------------------

-- Redraws the whole book; does nothing while it is closed. An expansion without data gets the
-- "coming later" spread instead (or the options page, while the gear is open).
function ns.RefreshUI()
    if not (main and main:IsShown()) then return end
    local exp = RefreshExpansions()
    local ready = exp.ready and true or false
    L:SetShown(ready); R:SetShown(ready)
    SL:SetShown(not ready); SR:SetShown(not ready)
    for _, t in ipairs(tabs) do t:SetShown(ready) end
    for _, t in ipairs(pageTabs) do t:SetShown(ready) end
    if not ready then
        for _, t in ipairs(eventTabs) do t:Hide() end
        aboutTab.y = gearY.zones
        if ns.showAbout then
            SR:Hide(); R:Show(); R.list:Hide(); R.chron:Hide()
            R.search:Hide(); R.track:Hide(); R.page:Hide()
            ns.RefreshAbout()
        end
        aboutTab:SetSelected(ns.showAbout and true or false)
        SL.title:SetText(exp.name)
        SL.sub:SetText("Coming later. Midnight comes first; this expansion gets its own pages once its data is in.")
        local lines = {}   -- the plan's bullet lines (shadows the list's lines)
        for _, p in ipairs(exp.plan or {}) do lines[#lines + 1] = "|cffc8a060*|r  " .. p end
        SL.plan:SetText(table.concat(lines, "\n"))
        return
    end
    if not ns.built then return end
    RefreshTabs()
    RefreshLeft()
    RefreshRight()
end

-- Creates the book frame and everything in it, hidden. Called once from Main.lua.
function ns.CreateMain()
    FONT_TITLE = MakeFont("CompletionTitleFont", 30, GameFontNormalHuge)
    FONT_HEAD = MakeFont("CompletionHeadFont", 19, GameFontNormalLarge)
    main = CreateFrame("Frame", "CompletionFrame", UIParent, "BackdropTemplate")
    main:SetSize(W, H)
    main:SetFrameStrata("HIGH")
    main:SetToplevel(true)
    main:SetMovable(true)
    main:EnableMouse(true)
    main:SetClampedToScreen(true)
    main:RegisterForDrag("LeftButton")
    main:SetScript("OnDragStart", main.StartMoving)
    main:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); ns.SavePos(self, "main") end)
    main:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    -- the spine down the middle of the book
    local spine = main:CreateTexture(nil, "ARTWORK")
    spine:SetColorTexture(0.55, 0.42, 0.22, 0.9)
    spine:SetWidth(2)
    spine:SetPoint("TOP", 0, -24)
    spine:SetPoint("BOTTOM", 0, 24)
    local close = CreateFrame("Button", nil, main, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -6, -6)
    close:SetFrameLevel(main:GetFrameLevel() + 20)
    close:SetScript("OnClick", function() main:Hide() end)
    -- the pages; About.lua and Pages.lua hang theirs on the right page
    BuildLeft()
    BuildRight()
    ns.BuildAbout(R, Header, Text, FONT_TITLE, PAGE_W)
    ns.BuildPages(R, Header, Text, PAGE_W)
    BuildTabs()
    BuildExpansions()
    ns.RestorePos(main, "main", "CENTER", -30, 20)
    main:SetScale(ns.db.settings.scale or 1)
    -- a quick fade in, the spellbook's sounds on open and close
    local fade = main:CreateAnimationGroup()
    local alpha = fade:CreateAnimation("Alpha")
    alpha:SetFromAlpha(0)
    alpha:SetToAlpha(1)
    alpha:SetDuration(0.15)
    main:SetScript("OnShow", function()
        Sound("IG_SPELLBOOK_OPEN")
        fade:Play()
        if ns.OnShow then ns.OnShow() end
        ns.RefreshUI()
    end)
    main:SetScript("OnHide", function() Sound("IG_SPELLBOOK_CLOSE") end)
    -- keeps the player arrow on the map moving while the book is open
    main:SetScript("OnUpdate", function(self, elapsed)
        self.acc = (self.acc or 0) + elapsed
        if self.acc < 0.25 then return end
        self.acc = 0
        UpdatePlayerDot()
    end)
    tinsert(UISpecialFrames, "CompletionFrame")   -- Escape closes it
    main:Hide()
    ns.main = main
end

-- Opens (true) or closes (false) the book; nil flips it.
function ns.Toggle(show)
    if not main then return end
    if show == nil then show = not main:IsShown() end
    if show then main:Show() else main:Hide() end
end

-- Turns the book to a zone (nil keeps the current one) and refreshes it. The open section is kept.
function ns.ShowZone(z)
    if z then ns.cdb.lastZone = z.key end
    ns.RefreshUI()
end

-- True while the book is open (nil before it is created).
function ns.IsShown() return main and main:IsShown() end
