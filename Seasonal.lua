-- Completion: the Seasonal book. One page per holiday (the Darkmoon Faire included), opened from the
-- "Seasonal" bookmark along the top. Each page has four sections:
--   guide     the hand-written walkthrough (Data/EventGuides.lua): what to do, in order, with the arrow
--   achv      every achievement of the holiday for your side, the meta and its parts first
--   quests    the holiday's quests from the guide: once a year, then every day
--   collect   mounts, pets, toys and appearances, with the vendor and the price
-- Achievements and collectibles count toward the page's total; the guide and quests are a checklist.
--
-- Whether a holiday is on comes from the game's calendar, with the dates in Data/EventGuides.lua as a
-- fallback. Open steps and criteria of holidays that are on are pinned on the world map and minimap.

local _, ns = ...

ns.EVENT_ZONES = {}         -- event pages, in Data/EventGuides.lua order
ns.eventByKey = {}

local SECTIONS = {
    { key = "guide",   name = "Guide" },
    { key = "achv",    name = "Achievements" },
    { key = "quests",  name = "Quests" },
    { key = "collect", name = "Collectibles" },
}
ns.EVENT_SECTIONS = SECTIONS
local COUNTED = { achv = true, collect = true }

------------------------------------------------------------------------
-- sides and spots
------------------------------------------------------------------------

-- "A", "H" or nil (a Pandaren who has not chosen yet sees both sides).
local function MySide()
    local f = UnitFactionGroup and UnitFactionGroup("player")
    return f == "Alliance" and "A" or (f == "Horde" and "H" or nil)
end
ns.MySide = MySide

-- True when something marked for side s (nil, 0, "A", "H", 1 = Alliance, 2 = Horde) is for this character.
local function SideOK(s)
    if not s or s == 0 then return true end
    local me = MySide()
    if not me then return true end
    if s == 1 then s = "A" elseif s == 2 then s = "H" end
    return s == me
end
ns.SideOK = SideOK

-- A value, or the player's half of a { A = x, H = y } pair.
local function Pick(v)
    if type(v) == "table" and (v.A or v.H) then
        local me = MySide()
        if me then return v[me] end
        return v.A or v.H
    end
    return v
end
ns.EventPick = Pick

-- Quest IDs as a list (a single ID, a list, or a side pair).
local function QuestList(q)
    q = Pick(q)
    if not q then return {} end
    if type(q) == "table" then return q end
    return { q }
end

-- Spots of a generated NPC or object entry ({ n = name, at = { {map, x, y}, ... } }).
local function ListSpots(entry, out)
    for _, at in ipairs(entry and entry.at or {}) do out[#out + 1] = { map = at[1], x = at[2], y = at[3] } end
end

-- Where a quest starts: the NPC or object that offers it (negative IDs are objects).
local function QuestStartSpots(q, out)
    local info = q and ns.EVENT_QUEST and ns.EVENT_QUEST[q]
    local s = info and info.s
    if not s then return end
    if s > 0 then ListSpots(ns.EVENT_NPC and ns.EVENT_NPC[s], out) else ListSpots(ns.EVENT_OBJ and ns.EVENT_OBJ[-s], out) end
end

-- The spots for a guide entry: its own coordinates, else its NPC or object, else where its quest starts.
local function SpotsFor(ref)
    local out = {}
    local at = Pick(ref.at)
    if at then
        if type(at[1]) == "table" then
            for _, a in ipairs(at) do out[#out + 1] = { map = a[1], x = a[2], y = a[3] } end
        else
            out[1] = { map = at[1], x = at[2], y = at[3] }
        end
    end
    if #out == 0 then
        local npc, obj = Pick(ref.npc), Pick(ref.obj)
        if npc then ListSpots(ns.EVENT_NPC and ns.EVENT_NPC[npc], out) end
        if obj and #out == 0 then ListSpots(ns.EVENT_OBJ and ns.EVENT_OBJ[obj], out) end
    end
    if #out == 0 then
        for _, q in ipairs(QuestList(ref.q)) do
            QuestStartSpots(q, out)
            if #out > 0 then break end
        end
    end
    return out
end
ns.EventSpots = SpotsFor

------------------------------------------------------------------------
-- calendar
------------------------------------------------------------------------

local found = {}            -- event key -> { { start, stop }, ... } (epoch seconds, local clock)
local scannedAt = -1000

-- Epoch seconds for a calendar time table.
local function ToEpoch(ct)
    if not ct then return end
    return time({ year = ct.year, month = ct.month, day = ct.monthDay or ct.day, hour = ct.hour or 0, min = ct.minute or 0 })
end

-- The event a calendar holiday belongs to: by the holiday's ID, else by its (English) title.
local function MatchDef(e)
    for _, def in ipairs(ns.EVENT_DEFS or {}) do
        if e.eventID and (e.eventID == def.id or (def.ids and tContains(def.ids, e.eventID))) then return def end
    end
    local t = ns.norm(e.title)
    if t == "" then return end
    for _, def in ipairs(ns.EVENT_DEFS or {}) do
        for _, n in ipairs(def.calendar or { def.name }) do
            if t:find(ns.norm(n), 1, true) then return def end
        end
    end
end

-- Reads every holiday from last month to a year ahead out of the calendar, without moving the month the
-- calendar window shows. Runs at most once a minute.
function ns.ScanCalendar(force)
    local now = GetTime and GetTime() or 0
    if not force and now - scannedAt < 60 then return end
    scannedAt = now
    if not (C_Calendar and C_Calendar.GetMonthInfo and C_Calendar.GetNumDayEvents and C_Calendar.GetDayEvent
            and C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime) then return end
    local okNow, today = pcall(C_DateAndTime.GetCurrentCalendarTime)
    local okShown, shown = pcall(C_Calendar.GetMonthInfo, 0)
    if not (okNow and today and okShown and shown and shown.year) then return end
    local base = (today.year * 12 + today.month) - (shown.year * 12 + shown.month)
    local out = {}
    for m = -1, 12 do
        local ok, info = pcall(C_Calendar.GetMonthInfo, base + m)
        if ok and info and info.numDays then
            for day = 1, info.numDays do
                local okn, n = pcall(C_Calendar.GetNumDayEvents, base + m, day)
                for i = 1, (okn and n or 0) do
                    local oke, e = pcall(C_Calendar.GetDayEvent, base + m, day, i)
                    if oke and e and e.calendarType == "HOLIDAY" and e.startTime and e.endTime then
                        local def = MatchDef(e)
                        if def then
                            local s, t = ToEpoch(e.startTime), ToEpoch(e.endTime)
                            out[def.key] = out[def.key] or {}
                            local dup = false
                            for _, o in ipairs(out[def.key]) do if o.start == s then dup = true; break end end
                            if s and t and not dup then table.insert(out[def.key], { start = s, stop = t }) end
                        end
                    end
                end
            end
        end
    end
    if next(out) then found = out end
end

-- The Darkmoon Faire: from the first Sunday of a month for a week.
local function MonthlyDates()
    local list = {}
    local now = date("*t")
    for i = -1, 2 do
        local y, m = now.year, now.month + i
        if m > 12 then y, m = y + 1, m - 12 elseif m < 1 then y, m = y - 1, m + 12 end
        local first = date("*t", time({ year = y, month = m, day = 1, hour = 12 }))
        local day = 1 + (8 - first.wday) % 7      -- wday 1 is Sunday
        local s = time({ year = y, month = m, day = day, hour = 0, min = 1 })
        list[#list + 1] = { start = s, stop = s + 7 * 86400 - 120 }
    end
    return list
end

-- Fallback occurrences from the data file: { { {y, m, d}, {y, m, d} }, ... }.
local function DataDates(def)
    if def.monthly then return MonthlyDates() end
    local list = {}
    for _, d in ipairs(def.dates or {}) do
        local a, b = d[1], d[2]
        list[#list + 1] = { start = time({ year = a[1], month = a[2], day = a[3], hour = a[4] or 10 }),
                            stop = time({ year = b[1], month = b[2], day = b[3], hour = b[4] or 10 }) }
    end
    return list
end

-- "on", stop time; "next", start, stop; or nil when nothing is known.
function ns.EventWhen(z)
    local def = z.def or z
    local list = found[def.key]
    if not list or #list == 0 then list = DataDates(def) end
    local now = time()
    local nextStart, nextStop
    for _, o in ipairs(list) do
        if o.start <= now and now < o.stop then return "on", o.stop end
        if o.start > now and (not nextStart or o.start < nextStart) then nextStart, nextStop = o.start, o.stop end
    end
    if nextStart then return "next", nextStart, nextStop end
end

-- True while the holiday is running.
function ns.EventActive(z)
    return (ns.EventWhen(z)) == "on"
end

-- "2 days 4 hours"-style span, rounded to the two biggest units.
local function Span(secs)
    secs = math.max(0, secs)
    local d, h, m = math.floor(secs / 86400), math.floor(secs % 86400 / 3600), math.floor(secs % 3600 / 60)
    if d > 0 then return d .. (d == 1 and " day" or " days") .. (h > 0 and (" " .. h .. (h == 1 and " hour" or " hours")) or "") end
    if h > 0 then return h .. (h == 1 and " hour" or " hours") end
    return m .. (m == 1 and " minute" or " minutes")
end

-- One line about when: "On now, ends in 3 days" or "Next: 19 October (in 14 days)".
function ns.EventStatusText(z)
    local state, a = ns.EventWhen(z)
    if state == "on" then return "|cff55ff55On now|r, ends in " .. Span(a - time()) end
    if state == "next" then
        return string.format("|cffc8a060Next:|r %s  (in %s)", date("%d %B", a):gsub("^0", ""), Span(a - time()))
    end
    return "|cff9a927fCheck the in-game calendar for the dates.|r"
end

------------------------------------------------------------------------
-- build
------------------------------------------------------------------------

-- Files an item in an event section and registers it.
local function Add(z, secKey, it)
    it.zone, it.sec = z, secKey
    local sec = z.sections[secKey]
    sec.items[#sec.items + 1] = it
    ns.items[it.key] = it
    return it
end

-- A guide step or quest row: { key, kind = "step", name, note, spots, quests, ach, own, item, count }.
local function StepItem(z, secKey, key, st, name)
    local it = {
        key = key, kind = "step", name = name, note = st.note, group = st.group,
        quests = QuestList(st.q), any = st.any, ach = Pick(st.ach), own = Pick(st.own), item = Pick(st.item), count = st.count,
        daily = st.daily, spots = SpotsFor(st), manual = st.manual,
    }
    return Add(z, secKey, it)
end

-- The guide: one item per step for this side, numbered in order.
local function BuildGuide(z, def)
    local n = 0
    z.steps = {}
    for i, st in ipairs(def.steps or {}) do
        if SideOK(st.side) then
            n = n + 1
            local it = StepItem(z, "guide", "e:" .. z.key .. ":g" .. i, st, n .. ". " .. (Pick(st[1]) or "?"))
            it.order = n
            z.steps[n] = it
        end
    end
end

-- Quests: every guide step that is a quest, once a year first, then the dailies. A step that any one of several
-- quests completes (the same quest at several places, either of two breweries) is one row.
local function BuildQuests(z, def)
    local rows = { yearly = {}, daily = {} }
    local seen = {}
    for i, st in ipairs(def.steps or {}) do
        if SideOK(st.side) then
            local list = rows[st.daily and "daily" or "yearly"]
            local qs = QuestList(st.q)
            if st.any and #qs > 1 then
                list[#list + 1] = { key = "s" .. i, st = st, any = true }
            else
                for _, q in ipairs(qs) do
                    if not seen[q] then
                        seen[q] = true
                        list[#list + 1] = { key = tostring(q), q = q, st = st }
                    end
                end
            end
        end
    end
    for _, part in ipairs({ { "yearly", "Once a year" }, { "daily", "Every day" } }) do
        for _, e in ipairs(rows[part[1]]) do
            local st = e.st
            local ref = { q = e.any and st.q or e.q, any = e.any, note = st.note, daily = st.daily, npc = st.npc, obj = st.obj,
                          at = st.qat or ((e.any or #QuestList(st.q) == 1) and st.at) or nil }
            local it = StepItem(z, "quests", "e:" .. z.key .. ":q" .. e.key, ref, e.any and Pick(st[1]) or nil)
            it.group = part[2]
            if not e.any then
                it.questRow = true
                it.questName = ns.EVENT_QUEST and ns.EVENT_QUEST[e.q] and ns.EVENT_QUEST[e.q].n
            end
        end
    end
end

-- Achievements: the metas with their parts first, then the rest, each for this side only.
local function BuildAchs(z, def)
    local list = ns.EVENT_ACHS and ns.EVENT_ACHS[z.key] or {}
    for _, e in ipairs(list) do
        local id, side, group = e[1], e[2], e[3]
        if SideOK(side) and not ns.items["e:" .. z.key .. ":a" .. id] then
            Add(z, "achv", { key = "e:" .. z.key .. ":a" .. id, kind = "ach", id = id, spots = {}, group = group })
        end
    end
end

-- Collectibles: vendor and price where it is sold, else where it comes from.
local function BuildCollect(z, def)
    for _, e in ipairs(ns.EVENT_ITEMS and ns.EVENT_ITEMS[z.key] or {}) do
        if SideOK(e.s) then
            local it = { key = "e:" .. z.key .. ":c" .. e.i, kind = "collect", itemID = e.i, spots = {}, sourceText = e.t or def.lootText }
            if e.v then
                it.vendors = {}
                for _, npc in ipairs(e.v) do
                    local info = ns.EVENT_NPC and ns.EVENT_NPC[npc]
                    if info then
                        local spots = {}
                        ListSpots(info, spots)
                        it.vendors[#it.vendors + 1] = { npc = npc, name = info.n, tag = info.tag, cost = e.c, spots = spots }
                        for _, sp in ipairs(spots) do it.spots[#it.spots + 1] = sp end
                    end
                end
                if #it.vendors == 0 then it.vendors = nil end
            end
            -- a price without a known vendor: still worth showing
            if not it.vendors and e.c then it.vendors = { { name = "the holiday vendors", cost = e.c, spots = {} } } end
            if #it.spots == 0 then
                for _, npc in ipairs(e.d or {}) do ListSpots(ns.EVENT_NPC and ns.EVENT_NPC[npc], it.spots) end
            end
            Add(z, "collect", it)
        end
    end
end

-- The map shown on the left page: the holiday's hub for this side.
local function HubMap(def)
    return Pick(def.hub)
end

-- Rebuilds every event page. Called from ns.Build after the zone pages.
function ns.BuildEvents()
    wipe(ns.EVENT_ZONES)
    wipe(ns.eventByKey)
    -- faction pairs of the same achievement (the meta lists one side's), for ns.AchItem
    ns.ACH_ALIAS = ns.ACH_ALIAS or {}
    for a, b in pairs(ns.EVENT_ACH_PAIRS or {}) do ns.ACH_ALIAS[a] = b; ns.ACH_ALIAS[b] = a end
    for _, def in ipairs(ns.EVENT_DEFS or {}) do
        local z = {
            key = def.key, name = def.name, short = def.short or def.name, event = true, def = def, id = def.id,
            iconAch = Pick(def.iconAch), icon = def.icon, desc = def.desc, map = HubMap(def), intro = def.intro,
            sectionDefs = SECTIONS, counted = COUNTED, sections = {},
        }
        for _, s in ipairs(SECTIONS) do z.sections[s.key] = { key = s.key, name = s.name, items = {}, cur = 0, max = 0 } end
        ns.EVENT_ZONES[#ns.EVENT_ZONES + 1] = z
        ns.eventByKey[z.key] = z
        BuildGuide(z, def)
        BuildQuests(z, def)
        BuildAchs(z, def)
        BuildCollect(z, def)
    end
end

------------------------------------------------------------------------
-- evaluate
------------------------------------------------------------------------

-- A step is done when its achievement is, when every quest it names is done (dailies reset by themselves),
-- when you own its collectible or carry its item, or when you ticked it by hand.
local function EvalStep(it)
    local done = ns.cdb.steps[it.key] and true or false
    local checks = false
    local achs = it.ach
    if achs and type(achs) ~= "table" then achs = { achs } end
    -- an achievement guide step: done when every achievement it names is (either side's version)
    if not done and achs and #achs > 0 then
        checks = true
        local all = true
        for _, id in ipairs(achs) do
            if not (ns.AchDone(id) or (ns.ACH_ALIAS and ns.ACH_ALIAS[id] and ns.AchDone(ns.ACH_ALIAS[id]))) then all = false; break end
        end
        done = all
    end
    -- a quest step: every quest it names, or any one of them (any = true)
    if not done and #it.quests > 0 then
        checks = true
        local all, one = true, false
        for _, q in ipairs(it.quests) do
            local ok = ns.QuestDone(q)
            if it.daily and ok then
                -- warband flags do not mean this character did today's
                local okc, mine = pcall(C_QuestLog.IsQuestFlaggedCompleted, q)
                ok = okc and mine
            end
            if ok then one = true else all = false end
        end
        done = (it.any and one) or (not it.any and all)
    end
    if not done and it.own then
        checks = true
        local _, owned = ns.ItemCollect(it.own)
        done = owned == true
    end
    if not done and it.item then
        checks = true
        done = (ns.bag[it.item] or 0) >= (it.count or 1)
    end
    it.done, it.max, it.cur = done, 1, done and 1 or 0
    it.handOnly = not checks
    if #it.quests == 1 then
        -- a row of the Quests section is named after its quest, in the client's language
        if it.questRow then it.name = ns.QuestTitle(it.quests[1], it.questName) end
        local active = not done and ns.QuestActive(it.quests[1])
        it.sub = active and "in your log" or (it.daily and "daily" or nil)
    else
        it.sub = it.daily and "daily" or nil
    end
end
ns.EvalStep = EvalStep

-- Re-reads every event page. Steps and quests are ticked but only achievements and collectibles count.
-- newly collects what just flipped to done (logged under the event, like a zone).
function ns.EvaluateEvents(newly, first, prevDone)
    for _, z in ipairs(ns.EVENT_ZONES) do
        z.cur, z.max = 0, 0
        for _, s in ipairs(SECTIONS) do
            local sec = z.sections[s.key]
            sec.cur, sec.max = 0, 0
            for _, it in ipairs(sec.items) do
                if it.kind == "step" then EvalStep(it) else ns.Eval(it) end
                sec.cur, sec.max = sec.cur + (it.cur or 0), sec.max + (it.max or 0)
                if (it.max or 0) > 0 and it.kind ~= "step" then
                    if it.done and prevDone[it.key] == false and not first and ns.Announceable(it) then
                        newly[#newly + 1] = it
                        ns.Log(z.key, (s.key == "achv" and "Achievement: " or "Collected: ") .. (it.name or "?"))
                    end
                    prevDone[it.key] = it.done and true or false
                end
            end
            if COUNTED[s.key] then z.cur, z.max = z.cur + sec.cur, z.max + sec.max end
        end
    end
end

------------------------------------------------------------------------
-- guide order
------------------------------------------------------------------------

-- The first open guide step after this one (or from the top), skipping ones without anything to point at
-- only when skipNoSpot. nil when every step is done.
function ns.NextEventStep(z, after)
    local start = after and after.order or 0
    for i = start + 1, #(z.steps or {}) do
        local st = z.steps[i]
        if not st.done then return st end
    end
    for i = 1, start do
        local st = z.steps[i]
        if not st.done and st ~= after then return st end
    end
end

-- The holidays running now.
function ns.ActiveEvents()
    local out = {}
    for _, z in ipairs(ns.EVENT_ZONES) do
        if ns.EventActive(z) then out[#out + 1] = z end
    end
    return out
end

------------------------------------------------------------------------
-- map pins for holidays that are on
------------------------------------------------------------------------

-- Adds the open places of running holidays that fall on mapID: guide steps and quests (pin kind "step"),
-- achievement criteria ("achv"). add is ns.PinEntries' own adder.
function ns.EventPinEntries(mapID, add)
    if not (ns.db and ns.db.settings.eventPins ~= false) then return end
    -- true when the spot is on mapID (or inside it)
    local function on(sp) return sp and sp.x and (sp.map == mapID or ns.MapPosOn(sp, mapID) ~= nil) end
    for _, z in ipairs(ns.ActiveEvents()) do
        for _, it in ipairs(z.sections.guide.items) do
            if not it.done then
                for _, sp in ipairs(it.spots) do if on(sp) then add(it, nil, sp, "step") end end
            end
        end
        for _, it in ipairs(z.sections.achv.items) do
            if not it.done and not it.hidden then
                for _, row in ipairs(ns.Children(it)) do
                    if not row.done and row.spot and on(row.spot) then add(it, row, row.spot, "achv") end
                end
            end
        end
    end
end

------------------------------------------------------------------------
-- events
------------------------------------------------------------------------

local f = CreateFrame("Frame")
for _, ev in ipairs({ "PLAYER_LOGIN", "CALENDAR_UPDATE_EVENT_LIST" }) do pcall(f.RegisterEvent, f, ev) end
f:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        -- asks the client for this month's calendar; holidays arrive with CALENDAR_UPDATE_EVENT_LIST
        if C_Calendar and C_Calendar.OpenCalendar then pcall(C_Calendar.OpenCalendar) end
        C_Timer.After(5, function() ns.ScanCalendar(true) end)
    else
        ns.ScanCalendar(true)
        if ns.IsShown and ns.IsShown() then ns.RefreshUI() end
    end
end)
