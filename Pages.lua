-- Completion: two extra pages of the book, opened with their own tabs under the zones.
--   This Week  what is up now and repeats: events and bountiful delves on the maps, world quests that
--              count for an open achievement, renown still to earn, repeatable features with open achievements
--   Warband    every character you have logged in with the addon: level, storyline, side quests, treasures,
--              rares and profession knowledge (the parts of 100% that are per character)

local _, ns = ...

local ROW_H = 18
local page, list
local cacheKey, cacheTime, cacheLines   -- which page was built, when (GetTime) and its lines

local GOLD = { 0.93, 0.82, 0.55 }
local CREAM = { 0.93, 0.89, 0.80 }
local GREY = { 0.60, 0.58, 0.54 }
local GREEN = { 0.50, 0.85, 0.50 }

------------------------------------------------------------------------
-- tracking a place that isn't a book item (an event, a delve entrance, a world quest)
------------------------------------------------------------------------

local lastSpotKey

-- Tracks a bare spot with the arrow by registering a throwaway "x:" item for it in ns.items.
local function TrackSpot(key, name, spot, note)
    if lastSpotKey then ns.items[lastSpotKey] = nil end   -- only the one being tracked is kept
    local it = { key = "x:" .. key, kind = "spot", name = name, spots = { spot }, note = note, max = 0 }
    ns.items[it.key] = it
    lastSpotKey = it.key
    ns.Track(it)
end

-- "3 days 4 hours": ns.Duration cut to its first two units.
local function Short(secs)
    local parts = {}
    for p in ns.Duration(secs):gmatch("%d+ %a+") do parts[#parts + 1] = p end
    return table.concat(parts, " ", 1, math.min(2, #parts))
end

-- x, y (0-1) from a position that is a vector or a plain { x, y } table; nil for no position.
local function XY(pos)
    if not pos then return end
    if pos.GetXY then return pos:GetXY() end
    return pos.x, pos.y
end

------------------------------------------------------------------------
-- This Week
------------------------------------------------------------------------

-- Achievement groups listed under Repeatables, in this order.
local REPEATABLE = { "Prey", "Abundance", "Void Assaults", "Ritual Sites", "Delves", "Abyss Anglers", "Fishing", "Pet Battles" }

-- Every map the zones cover, once each, as { m = mapID, z = zone }.
local function AllMaps()
    local maps, seen = {}, {}
    for _, z in ipairs(ns.ZONES) do
        for _, m in ipairs(z.maps or { z.map }) do
            if m and not seen[m] then seen[m] = true; maps[#maps + 1] = { m = m, z = z } end
        end
    end
    return maps
end

-- Appends a line for each timed area POI or event on the Midnight maps, with time left when the game gives it.
local function Events(out)
    if not (C_AreaPoiInfo and C_AreaPoiInfo.GetAreaPOIForMap) then return end
    local seen = {}
    for _, mz in ipairs(AllMaps()) do
        local ids = {}
        local ok, a = pcall(C_AreaPoiInfo.GetAreaPOIForMap, mz.m)
        if ok and type(a) == "table" then for _, id in ipairs(a) do ids[#ids + 1] = id end end
        if C_AreaPoiInfo.GetEventsForMap then
            local ok2, e = pcall(C_AreaPoiInfo.GetEventsForMap, mz.m)
            if ok2 and type(e) == "table" then for _, id in ipairs(e) do ids[#ids + 1] = id end end
        end
        for _, id in ipairs(ids) do
            if not seen[id] then
                local secs
                if C_AreaPoiInfo.GetAreaPOISecondsLeft then
                    local ok3, s = pcall(C_AreaPoiInfo.GetAreaPOISecondsLeft, id)
                    if ok3 and type(s) == "number" and s > 0 then secs = s end
                end
                local timed = secs
                if not timed and C_AreaPoiInfo.IsAreaPOITimed then
                    local ok4, t = pcall(C_AreaPoiInfo.IsAreaPOITimed, id)
                    timed = ok4 and t
                end
                if timed then
                    local ok5, info = pcall(C_AreaPoiInfo.GetAreaPOIInfo, mz.m, id)
                    local x, y = XY(ok5 and info and info.position)
                    if info and info.name and x then
                        seen[id] = true
                        local spot = { map = mz.m, x = x * 100, y = y * 100 }
                        out[#out + 1] = {
                            text = info.name, right = (secs and (Short(secs) .. " left") or "now") .. "  " .. (mz.z.short or ""),
                            tip = info.description, click = function() TrackSpot("poi" .. id, info.name, spot, info.description) end,
                        }
                    end
                end
            end
        end
    end
end

-- Appends a line for each delve whose map icon is the bountiful one.
local function BountifulDelves(out)
    if not (C_AreaPoiInfo and C_AreaPoiInfo.GetDelvesForMap) then return end
    local seen = {}
    for _, mz in ipairs(AllMaps()) do
        local ok, ids = pcall(C_AreaPoiInfo.GetDelvesForMap, mz.m)
        for _, id in ipairs(ok and type(ids) == "table" and ids or {}) do
            local ok2, info = pcall(C_AreaPoiInfo.GetAreaPOIInfo, mz.m, id)
            local atlas = ok2 and info and info.atlasName
            local x, y = XY(info and info.position)
            if atlas and atlas:lower():find("bountiful") and x and not seen[id] then
                seen[id] = true
                local spot = { map = mz.m, x = x * 100, y = y * 100 }
                -- the delve's own book item when there is one, so the arrow leads on to its chests inside
                local item = ns.items["d:" .. ns.norm(info.name or "")]
                out[#out + 1] = { text = "Bountiful: " .. (info.name or "?"), right = mz.z.short or "",
                                  tip = "Bountiful now: use a Coffer Key at the end for the better chest.",
                                  click = function()
                                      if item then ns.Track(item) else TrackSpot("delve" .. id, info.name, spot) end
                                  end }
            end
        end
    end
end

-- True when the delve of this name is bountiful right now (read from the map, cached for 30 seconds).
local bountiful, bountifulAt = {}, -100
function ns.IsBountiful(name)
    local now = GetTime and GetTime() or 0
    if now - bountifulAt > 30 then
        bountifulAt, bountiful = now, {}
        local list = {}
        BountifulDelves(list)
        for _, ln in ipairs(list) do bountiful[ns.norm((ln.text:gsub("^Bountiful: ", "")))] = true end
    end
    return bountiful[ns.norm(name or "")] or false
end

-- Quest ID -> { it, what, crit } for achievement criteria that are "complete this quest" (criteria type 27)
-- and for rares with a world quest. Built once per book build; whether each is still open is checked later.
local wqIndex, wqStamp
local function WorldQuestIndex()
    if wqStamp == ns.buildStamp and wqIndex then return wqIndex end
    wqStamp, wqIndex = ns.buildStamp, {}
    for _, it in pairs(ns.items) do
        if it.kind == "ach" and it.id and not it.hidden then
            local c = ns.Crits(it.id)
            for _, e in ipairs(c and c.list or {}) do
                if e.t == 27 and e.asset and e.asset > 0 then
                    wqIndex[e.asset] = wqIndex[e.asset] or { it = it, what = e.name, crit = e.id }
                end
            end
        elseif it.kind == "point" and it.wq and it.q then
            wqIndex[it.q] = wqIndex[it.q] or { it = it }
        end
    end
    return wqIndex
end

-- False once the item, or the one criterion the quest counts for, is done.
local function StillOpen(hit)
    if hit.it.done then return false end
    if hit.crit then
        local cr = ns.Crit(hit.it.id, hit.crit)
        if cr and cr.done then return false end
    end
    return true
end

-- Appends a line for each active world quest on the Midnight maps that counts for something still open.
local function WorldQuests(out)
    local get = C_TaskQuest and (C_TaskQuest.GetQuestsOnMap or C_TaskQuest.GetQuestsForPlayerByMapID)
    if not get then return end
    local idx = WorldQuestIndex()
    local seen = {}
    for _, mz in ipairs(AllMaps()) do
        local ok, quests = pcall(get, mz.m)
        for _, q in ipairs(ok and type(quests) == "table" and quests or {}) do
            local qid = q.questID or q.questId
            local hit = qid and idx[qid]
            if hit and not seen[qid] and q.x and q.y and StillOpen(hit) then
                seen[qid] = true
                local title = ns.QuestTitle(qid)
                local mins
                if C_TaskQuest.GetQuestTimeLeftMinutes then
                    local ok2, m = pcall(C_TaskQuest.GetQuestTimeLeftMinutes, qid)
                    if ok2 and type(m) == "number" and m > 0 then mins = m end
                end
                local spot = { map = q.mapID or mz.m, x = q.x * 100, y = q.y * 100 }
                local forWhat = hit.it.kind == "ach" and (hit.it.liveName or hit.it.name or "an achievement") or "the rare"
                out[#out + 1] = {
                    text = title, right = (mins and (Short(mins * 60) .. " left  ") or "") .. (mz.z.short or ""),
                    tip = "Counts for: " .. forWhat .. (hit.what and (" (" .. hit.what .. ")") or ""),
                    click = function() TrackSpot("wq" .. qid, title, spot, "World quest for " .. forWhat) end,
                }
            end
        end
    end
end

-- Appends a line for each zone faction not yet maxed, with progress to the next renown level when known.
local function Renown(out)
    local seen = {}
    for _, z in ipairs(ns.ZONES) do
        for _, fid in ipairs(z.factions or {}) do
            if not seen[fid] then
                seen[fid] = true
                local r = ns.Rep(fid)
                if r and not r.done and r.max and r.max > 0 then
                    local right = string.format("%d / %d", r.cur, r.max)
                    if r.renown and C_MajorFactions and C_MajorFactions.GetMajorFactionData then
                        local ok, d = pcall(C_MajorFactions.GetMajorFactionData, fid)
                        if ok and d and d.renownLevelThreshold and d.renownLevelThreshold > 0 then
                            right = string.format("Renown %d / %d   %d%% to next", r.cur, r.max,
                                math.floor(100 * (d.renownReputationEarned or 0) / d.renownLevelThreshold))
                        end
                    end
                    out[#out + 1] = { text = r.name, right = right, hint = "Click: open its page in the book.",
                                      click = function() ns.JumpTo(ns.items["r:" .. fid]) end }
                end
            end
        end
    end
end

-- Appends a line per repeatable feature you count that still has open achievements; a click opens the first.
local function Repeatables(out)
    local open, first = {}, {}
    local seenID = {}
    for _, it in pairs(ns.items) do
        if it.kind == "ach" and it.group and not it.done and not it.hidden and (it.max or 0) > 0 and not seenID[it.id] then
            seenID[it.id] = true
            open[it.group] = (open[it.group] or 0) + 1
            first[it.group] = first[it.group] or it
        end
    end
    for _, g in ipairs(REPEATABLE) do
        if ns.Counts(g) and (open[g] or 0) > 0 then
            local note = ns.GROUP_NOTES and ns.GROUP_NOTES[g]
            out[#out + 1] = { text = g, right = open[g] .. (open[g] == 1 and " achievement left" or " achievements left"),
                              tip = note, hint = "Click: open the first one in the book.",
                              click = function() ns.JumpTo(first[g]) end }
        end
    end
end

-- All the lines of the This Week page: the reset timers, then one section per kind of thing.
local function WeekLines()
    local out = {}
    local weekly = C_DateAndTime and C_DateAndTime.GetSecondsUntilWeeklyReset and C_DateAndTime.GetSecondsUntilWeeklyReset()
    local daily = C_DateAndTime and C_DateAndTime.GetSecondsUntilDailyReset and C_DateAndTime.GetSecondsUntilDailyReset()
    local resets = {}
    if weekly then resets[#resets + 1] = "Weekly reset in " .. Short(weekly) end
    if daily then resets[#resets + 1] = "daily in " .. Short(daily) end
    if #resets > 0 then out[#out + 1] = { text = table.concat(resets, ", "), color = GREY } end

    -- A header, then whatever fill adds, or the empty text when it adds nothing.
    local function section(title, fill, empty)
        out[#out + 1] = { header = title }
        local n = #out
        fill(out)
        if #out == n then out[#out + 1] = { text = empty, color = GREY } end
    end
    section("Happening Now", function(o) Events(o); BountifulDelves(o) end, "No timed events on the Midnight maps right now.")
    section("World Quests That Count", WorldQuests, "None of today's world quests count for anything still open.")
    section("Renown To Earn", Renown, "Every Midnight renown is maxed.")
    section("Repeatables With Achievements Left", Repeatables, "Nothing left in the repeatable features you count.")
    return out
end

------------------------------------------------------------------------
-- Warband
------------------------------------------------------------------------

-- Sections whose progress is per character: { section key, label }.
local PER_CHAR = { { "story", "Storyline" }, { "side", "Side quests" }, { "treasure", "Treasures" }, { "rare", "Rares" } }

-- "Name-Realm" for the current character, or nil before the name is known.
local function CharKey()
    local name = UnitName and UnitName("player")
    local realm = GetRealmName and GetRealmName()
    if not name then return end
    return name .. "-" .. (realm or "")
end

-- Called after every evaluation: saves what this character has (level, per-character sections, professions and
-- their knowledge treasures) for the Warband page.
function ns.SnapshotChar()
    local key = CharKey()
    if not (key and ns.built and ns.db) then return end
    ns.db.chars = ns.db.chars or {}
    local c = ns.db.chars[key] or {}
    c.name = UnitName("player")
    c.realm = GetRealmName and GetRealmName() or ""
    c.class = select(2, UnitClass("player"))
    c.level = UnitLevel and UnitLevel("player") or 0
    c.t = time and time() or 0
    c.secs = {}
    for _, p in ipairs(PER_CHAR) do
        local cur, max = 0, 0
        for _, z in ipairs(ns.ZONES) do
            local s = z.sections[p[1]]
            if s then cur, max = cur + (s.cur or 0), max + (s.max or 0) end
        end
        c.secs[p[1]] = { cur, max }
    end
    c.profs = {}
    if GetProfessions and GetProfessionInfo then
        local idx = { GetProfessions() }
        for i = 1, 6 do
            if idx[i] then
                local ok, pname, _, skill, maxSkill = pcall(GetProfessionInfo, idx[i])
                if ok and pname then
                    local kc, km = 0, 0
                    for _, z in ipairs(ns.ZONES) do
                        for _, it in ipairs(z.sections.prof.items) do
                            if it.group == pname then kc, km = kc + (it.cur or 0), km + (it.max or 0) end
                        end
                    end
                    c.profs[#c.profs + 1] = { pname, skill or 0, maxSkill or 0, kc, km }
                end
            end
        end
    end
    ns.db.chars[key] = c
end

-- The class colour as an "ffrrggbb" string for |c codes; white when unknown.
local function ClassHex(class)
    local c = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
    if c then return string.format("ff%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255) end
    return "ffffffff"
end

-- All the lines of the Warband page: this character first, then the others by when they were last seen.
local function WarbandLines()
    local out = {}
    local me = CharKey()
    local keys = {}
    for k in pairs(ns.db.chars or {}) do keys[#keys + 1] = k end
    table.sort(keys, function(a, b)
        if a == me then return true elseif b == me then return false end
        return (ns.db.chars[a].t or 0) > (ns.db.chars[b].t or 0)
    end)
    out[#out + 1] = { text = "Achievements, collections and renown are shared by the warband. These are the parts each character does on its own.",
                      color = GREY, wrap = true }
    for _, k in ipairs(keys) do
        local c = ns.db.chars[k]
        out[#out + 1] = {
            header = string.format("|c%s%s|r  |cffaaaaaa%s, level %d|r", ClassHex(c.class), c.name or "?", c.realm or "", c.level or 0),
            right = k == me and "this character" or ("seen " .. ns.Ago(c.t or 0)),
            tip = k ~= me and "Shift-right-click: forget this character." or nil,
            forget = k ~= me and k or nil,
        }
        local parts = {}
        for _, p in ipairs(PER_CHAR) do
            local v = c.secs and c.secs[p[1]]
            if v and v[2] > 0 then parts[#parts + 1] = string.format("%s %d/%d", p[2], v[1], v[2]) end
        end
        for i = 1, #parts, 2 do
            out[#out + 1] = { text = parts[i], right = parts[i + 1] or "", indent = 12 }
        end
        for _, p in ipairs(c.profs or {}) do
            local know = p[5] > 0 and string.format("knowledge treasures %d/%d", p[4], p[5]) or ""
            out[#out + 1] = { text = string.format("%s  %d/%d", p[1], p[2], p[3]), right = know, indent = 12,
                              color = (p[5] > 0 and p[4] >= p[5]) and GREEN or CREAM }
        end
        if #(c.profs or {}) == 0 then out[#out + 1] = { text = "No professions", indent = 12, color = GREY } end
    end
    if #keys == 0 then out[#out + 1] = { text = "Log in on your other characters once and they appear here.", color = GREY } end
    return out
end

------------------------------------------------------------------------
-- the page frame (built by UI.lua into the right page)
------------------------------------------------------------------------

-- Draws the visible slice of list.lines into rows, creating rows as needed and clamping the scroll.
local function FillRows()
    local lines = list.lines or {}
    local visible = math.floor((list:GetHeight() or 500) / ROW_H)
    local maxScroll = math.max(0, #lines - visible)
    list.scroll = math.min(list.scroll or 0, maxScroll)
    for i = 1, visible do
        local r = list.rows[i]
        if not r then
            r = CreateFrame("Button", nil, list)
            r:SetHeight(ROW_H)
            r:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_H)
            r:SetPoint("RIGHT", list, "RIGHT")
            r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            r.hl = r:CreateTexture(nil, "HIGHLIGHT")
            r.hl:SetAllPoints()
            r.hl:SetColorTexture(1, 0.85, 0.5, 0.08)
            r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            r.text:SetWordWrap(false)
            r.text:SetJustifyH("LEFT")
            r.right = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            r.right:SetPoint("RIGHT", -4, 0)
            r.right:SetJustifyH("RIGHT")
            r.bar = r:CreateTexture(nil, "BACKGROUND")
            r.bar:SetHeight(1)
            r.bar:SetPoint("BOTTOMLEFT", 4, 1)
            r.bar:SetPoint("BOTTOMRIGHT", -4, 1)
            r.bar:SetColorTexture(0.72, 0.56, 0.30, 0.5)
            -- Shift-right-click forgets a character on the Warband page; left-click runs the line's action.
            r:SetScript("OnClick", function(self, button)
                local ln = self.line
                if not ln then return end
                if button == "RightButton" and ln.forget and IsShiftKeyDown() then
                    ns.db.chars[ln.forget] = nil
                    cacheLines = nil
                    ns.RefreshPage()
                    return
                end
                if button == "LeftButton" and ln.click then ln.click() end
            end)
            r:SetScript("OnEnter", function(self)
                local ln = self.line
                if not (ln and (ln.tip or ln.click)) then return end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(ln.header or ln.text or "", 1, 1, 1, true)
                local points = ns.NotePoints(ln.tip)
                for _, p in ipairs(points) do GameTooltip:AddLine(#points > 1 and ("- " .. p) or p, 0.9, 0.85, 0.7, true) end
                if ln.click then GameTooltip:AddLine(ln.hint or "Click: track it with the arrow.", 0.5, 0.5, 0.5) end
                GameTooltip:Show()
            end)
            r:SetScript("OnLeave", function() GameTooltip:Hide() end)
            list.rows[i] = r
        end
        local ln = lines[i + list.scroll]
        r.line = ln
        if ln then
            r.text:ClearAllPoints()
            r.text:SetPoint("LEFT", 4 + (ln.indent or 0), 0)
            r.text:SetPoint("RIGHT", r.right, "LEFT", -6, 0)
            local c = ln.header and GOLD or (ln.color or CREAM)
            r.text:SetText(ln.header or ln.text or "")
            r.text:SetTextColor(c[1], c[2], c[3])
            r.right:SetText(ln.right or "")
            r.right:SetTextColor(GREY[1], GREY[2], GREY[3])
            r.bar:SetShown(ln.header and true or false)
            r:Show()
        else
            r:Hide()
        end
    end
    for i = visible + 1, #list.rows do list.rows[i]:Hide() end
end

-- Creates the shared page frame on the book's right page R. Header and Text are UI.lua's widget makers.
function ns.BuildPages(R, Header, Text, pageW)
    page = CreateFrame("Frame", nil, R)
    page:SetAllPoints()
    page:Hide()
    page.head = Header(page, pageW)
    page.head:SetPoint("TOP", 0, -14)
    page.sub = Text(page, "GameFontDisableSmall")
    page.sub:SetPoint("TOP", 0, -46)
    page.sub:SetWidth(pageW - 40)
    page.sub:SetJustifyH("CENTER")
    list = CreateFrame("Frame", nil, page)
    list:SetPoint("TOPLEFT", 14, -66)
    list:SetPoint("BOTTOMRIGHT", -14, 28)
    list:EnableMouseWheel(true)
    list:SetScript("OnMouseWheel", function(_, delta)
        list.scroll = math.max(0, (list.scroll or 0) - delta * 3)
        FillRows()
    end)
    list.rows = {}
    R.page = page
end

-- The lines on the open page (counted by /comp debug).
function ns.PageLines() return list and list.lines or {} end

-- Shows the page named by ns.showPage ("week" or else Warband) or hides it when nil. Lines are rebuilt at most
-- every five seconds unless the page changes.
function ns.RefreshPage()
    if not page then return end
    local which = ns.showPage
    page:SetShown(which ~= nil)
    if not which then return end
    local now = GetTime and GetTime() or 0
    if which ~= cacheKey or not cacheLines or now - (cacheTime or 0) > 5 then
        if cacheKey ~= which then list.scroll = 0 end
        cacheKey, cacheTime = which, now
        cacheLines = which == "week" and WeekLines() or WarbandLines()
    end
    if which == "week" then
        page.head:Set("This Week")
        page.sub:SetText("What is up now and what repeats. Click a line to track it or open its page.")
    else
        page.head:Set("Warband")
        page.sub:SetText("Every character that has opened the book.")
    end
    list.lines = cacheLines
    FillRows()
end
