-- Completion: events, the minimap button, the chronicle clock and slash commands.
-- Every event is registered here at file scope and never unregistered (UnregisterEvent is blocked on this client).

local _, ns = ...

local dirty = true
local lastEval = 0
local rebuiltOnShow = false

-- Seconds since client start (GetTime), used to space out evaluations.
local function Now() return GetTime and GetTime() or 0 end

-- The quest-complete chime, if sound is on.
local function PlayDone()
    if ns.db.settings.sound then pcall(PlaySound, (SOUNDKIT and SOUNDKIT.IG_QUEST_LIST_COMPLETE) or 867) end
end

-- Re-reads all progress, announces anything newly finished, moves the arrow on if its target is
-- done, then refreshes the book, the world map pins and the character snapshot.
local function Evaluate()
    dirty = false
    lastEval = Now()
    local newly = ns.EvaluateAll()
    if #newly > 0 then
        if ns.db.settings.announce then
            for _, it in ipairs(newly) do
                local host = it.parent or it
                local z = host.zone
                local cur, max = 0, 0
                if z then cur, max = ns.ZoneTotals(z) end
                ns.Print(string.format("|TInterface\\RaidFrame\\ReadyCheck-Ready:14|t %s  |cffaaaaaa(%s %d%%)|r",
                    it.liveName or it.name or "?", z and z.short or "", ns.Pct(cur, max)))
            end
        end
        PlayDone()
        local t = ns.TargetItem()
        if t and t.done then ns.TrackNext(true) end
    end
    ns.UpdateTarget()
    ns.RefreshUI()
    ns.RefreshWorldPins()
    ns.RefreshMinimapPins()
    ns.SnapshotChar()
    ns.CountAttempts()
end
ns.Evaluate = Evaluate

-- Queues an evaluation; the 1-second ticker runs it once the wait has passed.
local function MarkDirty() dirty = true end

-- Called when the window opens: rebuild once per session so late-loading data (journal, POIs) is in.
function ns.OnShow()
    if not rebuiltOnShow then
        rebuiltOnShow = true
        ns.Build()
    end
    if ns.db.settings.follow then
        local z = ns.PlayerZone()
        if z then
            ns.cdb.lastZone = z.key
            -- open the expansion you are standing in (not while the Seasonal pages are open)
            if ns.cdb.lastExpansion ~= "seasonal" then ns.cdb.lastExpansion = z.exp or "midnight" end
        end
    end
    Evaluate()
end

------------------------------------------------------------------------
-- chronicle clock
------------------------------------------------------------------------

-- Adds secs to the time spent in the player's current zone; the first visit is logged as an arrival.
local function ChronicleTick(secs)
    local z = ns.PlayerZone()
    if not z or z.overview then return end
    local c = ns.cdb.chronicle[z.key]
    if not c then
        c = { secs = 0, firstTime = time(), firstLevel = UnitLevel and UnitLevel("player") or 0 }
        ns.cdb.chronicle[z.key] = c
        ns.Log(z.key, "Arrived in " .. z.name)
    end
    c.secs = (c.secs or 0) + secs
end

------------------------------------------------------------------------
-- minimap button
------------------------------------------------------------------------

local mm

-- Puts the button on the minimap's rim at the saved angle (degrees).
local function PlaceMinimap()
    local a = math.rad(ns.db.settings.minimap.angle or 215)
    local r = (Minimap:GetWidth() / 2) + 5
    mm:ClearAllPoints()
    mm:SetPoint("CENTER", Minimap, "CENTER", math.cos(a) * r, math.sin(a) * r)
end

-- Builds the minimap book button: left-click opens the book, right-click toggles the arrow,
-- dragging slides it around the rim, and the tooltip shows the current zone's progress.
local function CreateMinimapButton()
    mm = CreateFrame("Button", "CompletionMinimapButton", Minimap)
    mm:SetSize(31, 31)
    mm:SetFrameStrata("MEDIUM")
    mm:SetFrameLevel(8)
    mm:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    mm:RegisterForDrag("LeftButton")
    mm:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local bg = mm:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetSize(20, 20)
    bg:SetPoint("TOPLEFT", 7, -5)
    local icon = mm:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\Icons\\inv_misc_book_16")
    icon:SetSize(18, 18)
    icon:SetPoint("TOPLEFT", 7, -6)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local border = mm:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")
    mm:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            ns.db.settings.arrow = not ns.db.settings.arrow
            ns.Print("Arrow " .. (ns.db.settings.arrow and "on" or "off") .. ".")
            ns.UpdateTarget()
        else
            ns.Toggle()
        end
    end)
    mm:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local s = Minimap:GetEffectiveScale()
            ns.db.settings.minimap.angle = math.deg(math.atan2(py / s - my, px / s - mx))
            PlaceMinimap()
        end)
    end)
    mm:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    mm:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Completion")
        local z = ns.PlayerZone()
        if ns.built then
            if z then
                local cur, max = ns.ZoneTotals(z)
                GameTooltip:AddDoubleLine(z.name, string.format("%d / %d  (%d%%)", cur, max, ns.Pct(cur, max)), 1, 0.82, 0.5, 1, 1, 1)
                for _, s in ipairs(ns.SECTIONS) do
                    local sec = z.sections[s.key]
                    if sec.max > 0 and not s.uncounted then
                        local done = sec.cur >= sec.max
                        GameTooltip:AddDoubleLine("  " .. s.name, sec.cur .. " / " .. sec.max, 0.8, 0.8, 0.8,
                            done and 0.4 or 1, 1, done and 0.4 or 1)
                    end
                end
            end
            if ns.total then
                GameTooltip:AddDoubleLine("Midnight", string.format("%d%%", ns.Pct(ns.total.cur, ns.total.max)), 1, 0.82, 0.5, 1, 1, 1)
            end
        end
        GameTooltip:AddLine("Left-click: open the book. Right-click: arrow on/off. Drag: move.", 0.6, 0.6, 0.6, true)
        GameTooltip:Show()
    end)
    mm:SetScript("OnLeave", function() GameTooltip:Hide() end)
    PlaceMinimap()
    mm:SetShown(not ns.db.settings.minimap.hide)
end

------------------------------------------------------------------------
-- slash commands
------------------------------------------------------------------------

-- /comp missing: prints what is still open on the last opened zone page, up to 12 names per section.
local function Missing()
    local z = ns.zoneByKey[ns.cdb.lastZone or ""] or ns.PlayerZone() or ns.ZONES[1]
    ns.Print("Missing in " .. z.name .. ":")
    for _, s in ipairs(ns.ZONE_SECTIONS) do
        local sec = z.sections[s.key]
        local open = {}
        for _, it in ipairs(sec.items) do
            if not it.done and not it.hidden and (it.max or 0) > 0 then open[#open + 1] = it.liveName or it.name or "?" end
        end
        if #open > 0 then
            print(string.format("|cffe6c35c%s|r (%d): %s", s.name, #open, table.concat(open, ", ", 1, math.min(#open, 12)) .. (#open > 12 and ", ..." or "")))
        end
    end
end

-- /comp audit: achievements on the open page with no spot, steps or written walkthrough at all.
local function Audit()
    local z = ns.zoneByKey[ns.cdb.lastZone or ""] or ns.PlayerZone() or ns.ZONES[1]
    local bare = ns.AuditList(z)
    ns.Print(string.format("%s: %d open achievements without a location or walkthrough", z.name, #bare))
    for i = 1, math.min(#bare, 40) do print("  " .. bare[i]) end
end

-- /comp debug: per-zone section counts plus which optional APIs this client has.
local function Debug()
    local counts = { zones = 0, items = 0 }
    for _, z in ipairs(ns.ZONES) do
        local parts = {}
        for _, s in ipairs(ns.SECTIONS) do
            local sec = z.sections[s.key]
            parts[#parts + 1] = string.format("%s %d/%d(%d)", s.key, sec.cur, sec.max, #sec.items)
            counts.items = counts.items + #sec.items
        end
        print(string.format("|cffe6c35c%s|r %s", z.short, table.concat(parts, "  ")))
    end
    print("items:", counts.items, "decor API:", C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByItem and "yes" or "no",
        "EJ entrances API:", C_EncounterJournal and C_EncounterJournal.GetDungeonEntrancesForMap and "yes" or "no")
    local up = 0
    for _ in pairs(ns.upNow) do up = up + 1 end
    local r = ns.cdb.route
    print("world map pins:", #ns.WorldPinItems(), "rares up now:", up,
        "route:", r and string.format("%d/%d (%s)", r.i or 1, #r.stops, r.label or "") or "none",
        "page lines:", #ns.PageLines(), "minimap pins:", ns.MinimapPinCount())
    -- where you stand, and (inside a delve) whether its chests can be placed: what a delve bug report needs
    local m = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    local info = m and C_Map.GetMapInfo and C_Map.GetMapInfo(m)
    local pinst = ns.PlayerWorld()
    print("map:", m or "?", info and info.name or "?", "instance:", pinst or "none", "delve:", ns.DelveForMap(m) or "no")
    local d = ns.CurrentDelve and ns.CurrentDelve()
    if d then
        for _, ch in ipairs(d.children or {}) do
            if ch.kind == "point" then
                local sp = ch.spots[1]
                local cinst = sp and ns.MapToWorld(sp.map, sp.x / 100, sp.y / 100)
                print(string.format("  chest map %d at %.1f, %.1f: %s, world %s", sp.map, sp.x, sp.y,
                    ch.done and "opened" or "closed", cinst and ("instance " .. cinst) or "unknown"))
            end
        end
    end
end

-- Handler for /comp and /completion. Input is lowercased; anything unknown prints the command list.
local function Slash(msg)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    local cmd, rest = msg:match("^(%S*)%s*(.*)$")
    local s = ns.db.settings
    if cmd == "" then ns.Toggle()
    elseif cmd == "zone" then
        if rest == "" then ns.Print("Usage: /comp zone <name>") return end
        for _, z in ipairs(ns.ZONES) do
            if z.key:find(rest, 1, true) or z.name:lower():find(rest, 1, true) then
                ns.cdb.lastZone = z.key; ns.Toggle(true); ns.RefreshUI(); return
            end
        end
        ns.Print("No zone matches '" .. rest .. "'.")
    elseif cmd == "missing" then Missing()
    elseif cmd == "arrow" then s.arrow = not s.arrow; ns.Print("Arrow " .. (s.arrow and "on" or "off") .. "."); ns.UpdateTarget()
    elseif cmd == "pin" then s.pin = not s.pin; ns.Print("Map pin " .. (s.pin and "on" or "off") .. "."); ns.UpdateTarget(true)
    elseif cmd == "pins" then
        -- /comp pins rare (toggle), /comp pins only rare, /comp pins all, /comp pins none
        local word, kind = rest:match("^(%S*)%s*(%S*)")
        -- True when k is one of the pin kinds in ns.PIN_KINDS.
        local function known(k) for _, p in ipairs(ns.PIN_KINDS) do if p[1] == k then return true end end end
        if word == "all" then ns.SetPinsOnly(true)
        elseif word == "none" then ns.SetPinsOnly(false)
        elseif word == "only" and known(kind) then ns.SetPinsOnly(kind)
        elseif known(word) then ns.SetPin(word, not ns.PinOn(word))
        elseif word ~= "" then ns.Print("Pin kinds: treasure, rare, achv, collect, instance, delve, prof (or all, none, only <kind>).") end
        local on = {}
        for _, p in ipairs(ns.PIN_KINDS) do if ns.PinOn(p[1]) then on[#on + 1] = p[1] end end
        ns.Print("Map pins: " .. (#on > 0 and table.concat(on, ", ") or "none") .. ".")
    elseif cmd == "route" then
        -- /comp route (the open section, else what the map pins show), /comp route stop
        if rest == "stop" then ns.StopRoute(); return end
        local delve = ns.CurrentDelve()
        if delve then ns.PlanDelveRoute(delve) return end
        local z = ns.zoneByKey[ns.cdb.lastZone or ""] or ns.PlayerZone()
        if not z or z.overview then ns.Print("Routes are per zone: open a zone page first.") return end
        if ns.cdb.lastSection then ns.PlanRouteForSection(z, ns.cdb.lastSection) else ns.PlanRouteForPins(z) end
    elseif cmd == "week" or cmd == "warband" then
        ns.showPage, ns.showAbout = cmd, false
        ns.Toggle(true); ns.RefreshUI()
    elseif cmd == "tracker" then
        s.tracker = s.tracker == false
        ns.Print("On-screen tracker " .. (s.tracker and "on" or "off") .. ".")
        ns.RefreshTracker()
    elseif cmd == "watch" then
        -- /comp watch: add what the arrow points at (or take it off); /comp watch clear empties the list
        if rest == "clear" then ns.cdb.watch = {}; ns.RefreshWatch(); ns.Print("Watch list cleared.") return end
        local it, child = ns.TargetItem()
        if it then ns.WatchToggle(it, child) else ns.Print("Track something first, or Alt-click a row in the book.") end
    elseif cmd == "clear" then ns.Track(nil)
    elseif cmd == "next" then ns.TrackNext(true)
    elseif cmd == "sound" then s.sound = not s.sound; ns.Print("Sound " .. (s.sound and "on" or "off") .. ".")
    elseif cmd == "announce" then s.announce = not s.announce; ns.Print("Chat messages " .. (s.announce and "on" or "off") .. ".")
    elseif cmd == "follow" then s.follow = not s.follow; ns.Print("Open on your current zone: " .. (s.follow and "on" or "off") .. ".")
    elseif cmd == "hidedone" then s.hidedone = not s.hidedone; ns.RefreshUI()
    elseif cmd == "transmog" then
        s.transmog = not s.transmog
        ns.Print("Appearances count toward Collectibles: " .. (s.transmog and "yes" or "no") .. ".")
        Evaluate()
    elseif cmd == "minimap" then
        s.minimap.hide = not s.minimap.hide
        if mm then mm:SetShown(not s.minimap.hide) end
    elseif cmd == "scale" then
        local v = tonumber(rest)
        if v and v >= 0.6 and v <= 1.5 then s.scale = v; if ns.main then ns.main:SetScale(v) end
        else ns.Print("Usage: /comp scale 0.5-2") end
    elseif cmd == "arrowscale" then
        local v = tonumber(rest)
        if v and v >= 0.5 and v <= 3 then s.arrowScale = v; if ns.arrow then ns.arrow:SetScale(v) end
        else ns.Print("Usage: /comp arrowscale 0.5-3") end
    elseif cmd == "reset" then
        ns.db.frames = {}
        if ns.main then ns.RestorePos(ns.main, "main", "CENTER", -30, 20) end
        if ns.arrow then ns.RestorePos(ns.arrow, "arrow", "TOP", 0, -140) end
    elseif cmd == "clearlog" then
        ns.cdb.log = {}
        ns.Print("Recent Adventures cleared for this character.")
        ns.RefreshUI()
    elseif cmd == "rebuild" then ns.Build(); Evaluate(); ns.Print("Rebuilt.")
    elseif cmd == "debug" then Debug()
    elseif cmd == "audit" then Audit()
    elseif cmd == "report" then ns.ShowReport()
    else
        ns.Print("/comp - open or close the book")
        print("  zone <name>, missing, next, clear, arrow, pin, pins <kind|all|none|only kind>, hidedone, transmog,")
        print("  route [stop], watch [clear], tracker, report, week, warband, follow, sound, announce, minimap, scale <n>, arrowscale <n>, reset,")
        print("  clearlog, rebuild, audit, debug")
    end
end

_G.SLASH_COMPLETION1 = "/comp"
_G.SLASH_COMPLETION2 = "/completion"
SlashCmdList["COMPLETION"] = Slash

------------------------------------------------------------------------
-- events
------------------------------------------------------------------------

local f = CreateFrame("Frame")
local EVENTS = {
    "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED",
    "CRITERIA_UPDATE", "CRITERIA_COMPLETE", "ACHIEVEMENT_EARNED",
    "QUEST_TURNED_IN", "QUEST_ACCEPTED", "QUEST_REMOVED", "QUEST_LOG_UPDATE", "QUESTLINE_UPDATE",
    "NEW_MOUNT_ADDED", "NEW_PET_ADDED", "NEW_TOY_ADDED", "TRANSMOG_COLLECTION_UPDATED",
    "MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "UPDATE_FACTION", "SKILL_LINES_CHANGED",
    "GET_ITEM_INFO_RECEIVED", "BAG_UPDATE_DELAYED", "LOOT_CLOSED", "CHAT_MSG_LOOT",
}
for _, ev in ipairs(EVENTS) do pcall(f.RegisterEvent, f, ev) end

local itemInfoPending = false

-- Login sets everything up and starts the timers; most other events just mark progress dirty.
f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == ns.ADDON then ns.InitDB() end
        if arg1 == "Blizzard_WorldMap" then ns.HookWorldMap() end
    elseif event == "PLAYER_LOGIN" then
        if not ns.db then ns.InitDB() end
        ns.CreateArrow()
        ns.CreateMain()
        CreateMinimapButton()
        ns.HookWorldMap()
        ns.CreateMinimapPins()
        ns.CreateTracker()
        ns.ScanBags()
        C_Timer.After(3, function()
            ns.UpdatePlayerChain()
            ns.Build()
            Evaluate()
        end)
        C_Timer.NewTicker(1, function()
            if not ns.built then return end
            local wait = ns.IsShown() and 2 or 8
            if dirty and Now() - lastEval >= wait then Evaluate() end
        end)
        C_Timer.NewTicker(10, function() ChronicleTick(10) end)
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then
        ns.UpdatePlayerChain()
        for _, m in ipairs(ns.playerChain) do ns.AskQuestLines(m) end
        if event ~= "ZONE_CHANGED" and ns.db and ns.db.settings.follow and ns.IsShown() then
            local z = ns.PlayerZone()
            if z and z.key ~= ns.cdb.lastZone then
                ns.cdb.lastZone = z.key
                if ns.cdb.lastExpansion ~= "seasonal" then ns.cdb.lastExpansion = z.exp or "midnight" end
                ns.RefreshUI()
            end
        end
        if ns.built then ns.UpdateTarget() end
    elseif event == "BAG_UPDATE_DELAYED" then
        ns.ScanBags()
        if ns.built then ns.UpdateTarget(); if ns.IsShown() then ns.RefreshUI() end end
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        -- only worth a refresh while a collectible is still waiting for its data; otherwise every
        -- evaluation's own item lookups would keep triggering the next one
        if ns.IsShown() and not itemInfoPending and (ns.collectLoading or 0) > 0 then
            itemInfoPending = true
            C_Timer.After(1, function() itemInfoPending = false; MarkDirty() end)
        end
    elseif event == "LOOT_CLOSED" or event == "CHAT_MSG_LOOT" or event == "NEW_MOUNT_ADDED"
        or event == "NEW_PET_ADDED" or event == "NEW_TOY_ADDED" then
        -- a real gain: collectible flips in the next few seconds may be announced
        -- (TRANSMOG_COLLECTION_UPDATED is left out: it also fires while the client loads)
        ns.lastGainEvent = GetTime and GetTime() or 0
        MarkDirty()
    elseif event == "QUESTLINE_UPDATE" then
        ns.ResetQuestLines()
    else
        MarkDirty()
    end
end)
