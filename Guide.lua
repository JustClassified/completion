-- Completion: the guide. Works out where the arrow should point for anything you track, and draws it.
--
-- A target is { key = item key, child = child row key or nil }. What it resolves to:
--   point with steps   the first step not done yet (quest flags and bag items tick steps; a later step
--                      being done marks every earlier one, so steps the addon can't see never strand you)
--   point              the nearest of its spawn points
--   lore               the next quest of the chain: its live objective, else where the questline is offered
--   ach                its current hand-written step if it has steps, else the nearest open criterion that
--                      has a spot (or the one you picked)
--   container          the entrance
--   collect            where it drops

local _, ns = ...

local TEXTURE = "Interface\\AddOns\\" .. ns.ADDON .. "\\Textures\\arrow"
local arrow
local pinSet = false   -- true while the game's user waypoint is one this addon placed

------------------------------------------------------------------------
-- quest positions (live)
------------------------------------------------------------------------

local qlAsked, qlLines, qlQuests = {}, {}, {}   -- per map: asked once, last scan time, quest ID -> position

-- Asks the client to load the quest lines offered on a map (once per map per session); the answer arrives later.
local function AskQuestLines(mapID)
    if not mapID or not C_QuestLine then return end
    if not qlAsked[mapID] and C_QuestLine.RequestQuestLinesForMap then
        qlAsked[mapID] = true
        pcall(C_QuestLine.RequestQuestLinesForMap, mapID)
    end
end
ns.AskQuestLines = AskQuestLines

-- Lets every map rescan its quest lines on the next lookup (when the game says quest lines changed).
function ns.ResetQuestLines() qlLines = {} end

-- Records where each quest of the quest lines offered on a map is picked up. A quest that isn't the offered
-- one gets its questline's pickup spot. Rescans at most every 20 seconds per map.
local function ScanQuestLines(mapID)
    if not mapID or not (C_QuestLine and C_QuestLine.GetAvailableQuestLines) then return end
    local now = GetTime and GetTime() or 0
    local cache = qlLines[mapID]
    if cache and (now - cache.time) < 20 then return end
    AskQuestLines(mapID)
    local ok, lines = pcall(C_QuestLine.GetAvailableQuestLines, mapID)
    if not ok or type(lines) ~= "table" then return end
    local quests = {}
    for _, info in ipairs(lines) do
        if info.x and info.y and info.questLineID then
            local pos = { map = mapID, x = info.x * 100, y = info.y * 100 }
            if info.questID then quests[info.questID] = pos end
            local ok2, list = pcall(C_QuestLine.GetQuestLineQuests, info.questLineID)
            if ok2 and type(list) == "table" then
                for _, qid in ipairs(list) do if not quests[qid] then quests[qid] = pos end end
            end
        end
    end
    qlLines[mapID] = { time = now }
    qlQuests[mapID] = quests
end

-- Best known position for a quest: its live objective first, then where its questline is offered (on mapHint
-- or the player's map and its parents). Returns spot, "objective" or "pickup"; nil when neither is known.
function ns.QuestPos(questID, mapHint)
    if not questID then return end
    if ns.QuestActive(questID) and C_QuestLog and C_QuestLog.GetNextWaypoint then
        local ok, m, x, y = pcall(C_QuestLog.GetNextWaypoint, questID)
        if ok and m and x and y then return { map = m, x = x * 100, y = y * 100 }, "objective" end
    end
    local maps = {}
    if mapHint then maps[#maps + 1] = mapHint end
    for _, id in ipairs(ns.playerChain) do maps[#maps + 1] = id end
    for _, m in ipairs(maps) do
        ScanQuestLines(m)
        local q = qlQuests[m] and qlQuests[m][questID]
        if q then return q, "pickup" end
    end
end

------------------------------------------------------------------------
-- steps
------------------------------------------------------------------------

-- The saved-variable key for step i of an item.
local function stepKey(it, i) return it.key .. "#" .. i end

-- True when step i is done: the item is done, the step was ticked by hand, its quest is done or the bags hold
-- enough of its item. False for a step that doesn't exist.
function ns.StepDone(it, i)
    local s = it.steps and it.steps[i]
    if not s then return false end
    if it.done or ns.cdb.steps[stepKey(it, i)] then return true end
    if s.quest and ns.QuestDone(s.quest) then return true end
    if s.item and type(s.item) == "number" and (ns.bag[s.item] or 0) >= (s.count or 1) then return true end
    return false
end

-- Index of the step to do now: the one after the last step that is done, capped at the final step. nil without steps.
function ns.CurrentStep(it)
    if not it.steps then return end
    local last = 0
    for i = #it.steps, 1, -1 do
        if ns.StepDone(it, i) then last = i; break end
    end
    return math.min(last + 1, #it.steps)
end

-- Ticks steps 1 to i by hand.
function ns.MarkStep(it, i)
    for j = 1, i do ns.cdb.steps[stepKey(it, j)] = true end
end

local Nearest   -- defined with the target code below

-- Flight paths: the game lists every taxi node of a map with its name and position.
local taxiByName
-- { map, x, y } (0-100) of the flight master with this name, or nil. The node list is read once per session.
local function TaxiSpot(name)
    if not (C_TaxiMap and C_TaxiMap.GetTaxiNodesForMap and name) then return end
    if not taxiByName then
        taxiByName = {}
        for _, z in ipairs(ns.ZONES) do
            for _, m in ipairs(z.maps or {}) do
                local ok, nodes = pcall(C_TaxiMap.GetTaxiNodesForMap, m)
                if ok and type(nodes) == "table" then
                    for _, n in ipairs(nodes) do
                        if n.name and n.position then
                            local x, y
                            if n.position.GetXY then x, y = n.position:GetXY() else x, y = n.position.x, n.position.y end
                            if x then taxiByName[ns.norm(n.name)] = taxiByName[ns.norm(n.name)] or { m, x * 100, y * 100 } end
                        end
                    end
                end
            end
        end
    end
    local key = ns.norm(name)
    if taxiByName[key] then return taxiByName[key] end
    -- criteria read "Sanctum of Light, Silvermoon City"; nodes may be named with or without the zone
    local short = ns.norm((name:match("^([^,]+)")) or name)
    for k, v in pairs(taxiByName) do
        if k:find(short, 1, true) then return v end
    end
end

local normNotes = {}
-- Hand note for a criterion by name, matched ignoring case and punctuation ("Part 1--Finding Hope" vs
-- "Part 1 - Finding Hope"). nil when the achievement has no hand notes or none matches.
function ns.NormNote(achID, name)
    local hand = ns.CRIT_NOTES and ns.CRIT_NOTES[achID]
    if not hand then return end
    local idx = normNotes[achID]
    if not idx then
        idx = {}
        for k, v in pairs(hand) do if type(k) == "string" then idx[ns.norm(k)] = v end end
        normNotes[achID] = idx
    end
    return idx[ns.norm(name)]
end

-- Walkthrough entry { at, t } for one criterion: hand notes (ns.CRIT_NOTES) win over generated data
-- (ns.CRIT_GUIDE), field by field. Flight path criteria (type 262) point at the flight master. nil if nothing is known.
function ns.WalkthroughFor(achID, e)
    if e.t == 262 and e.name then
        local at = TaxiSpot(e.name)
        if at then return { at = { at }, t = "Talk to the flight master here to learn the flight path" } end
    end
    local key = e.t and e.asset and (e.t .. ":" .. e.asset)
    local hand = ns.CRIT_NOTES and ns.CRIT_NOTES[achID]
    local gen = ns.CRIT_GUIDE and ns.CRIT_GUIDE[achID]
    local h = hand and ((key and hand[key]) or (e.name and (hand[e.name] or ns.NormNote(achID, e.name))))
    local g = gen and key and gen[key]
    -- the cost is added once; until item and currency names have loaded it is tried again next time
    if g and g.c and not g.priced and ns.CostText then
        local cost = ns.CostText(g.c)
        if cost then g.t = (g.t or "") .. "  (" .. cost .. ")"; g.priced = true end
    end
    -- a hand note can name a flight path instead of coordinates: the hub's flight master, read from the game
    if h and h.taxi and not h.at then
        local at = TaxiSpot(h.taxi)
        if at then h.at = { at } end
    end
    if not h then return g end
    if not g then return h end
    return { at = h.at or g.at, t = h.t or g.t }
end

------------------------------------------------------------------------
-- children rows (what an item expands into)
------------------------------------------------------------------------

-- The book's item for an achievement ID (the first one when an achievement is split over zones), or nil
-- when it isn't in the book. Indexed once per build.
local achIndex, achIndexStamp
function ns.AchItem(id)
    if not id then return end
    if achIndexStamp ~= ns.buildStamp or not achIndex then
        achIndexStamp, achIndex = ns.buildStamp, {}
        for _, it in pairs(ns.items) do
            if it.kind == "ach" and it.id and (not achIndex[it.id] or (achIndex[it.id].split and not it.split)) then
                achIndex[it.id] = it
            end
        end
    end
    -- a holiday achievement has one ID per faction; a meta may list the other side's
    return achIndex[id] or (ns.ACH_ALIAS and ns.ACH_ALIAS[id] and achIndex[ns.ACH_ALIAS[id]])
end

-- An achievement split over zones (spots in several zones, one part per zone page): all its parts, this one
-- first and the rest in zone order, plus the criteria no part covers, and done/total for the whole achievement.
-- Returns parts, loose (criteria entries), done, total.
local splitParts, splitStamp = {}, nil
function ns.SplitParts(it)
    if splitStamp ~= ns.buildStamp then splitStamp, splitParts = ns.buildStamp, {} end
    local all = splitParts[it.id]
    if not all then
        all = {}
        for _, other in pairs(ns.items) do
            if other.kind == "ach" and other.id == it.id and other.split then all[#all + 1] = other end
        end
        local order = {}
        for i, z in ipairs(ns.ZONES) do order[z] = i end
        table.sort(all, function(a, b) return (order[a.zone] or 99) < (order[b.zone] or 99) end)
        splitParts[it.id] = all
    end
    local parts = { it }
    for _, p in ipairs(all) do
        if p ~= it then parts[#parts + 1] = p end
    end
    local loose, done, total = {}, 0, 0
    local c = ns.Crits(it.id)
    for _, e in ipairs(c and c.list or {}) do
        total = total + 1
        if e.done then done = done + 1 end
        local covered = false
        for _, p in ipairs(all) do
            if ns.InPart(p, e) then covered = true; break end
        end
        if not covered then loose[#loose + 1] = e end
    end
    return parts, loose, done, total
end

-- Copies an achievement's hand-written walkthrough steps (ns.ACH_STEPS) onto it as it.steps, shaped like
-- treasure steps. Checked once per item.
local function AttachAchSteps(it)
    if it.kind ~= "ach" or it.stepsChecked then return end
    it.stepsChecked = true
    local list = ns.ACH_STEPS and ns.ACH_STEPS[it.id]
    if not list then return end
    it.steps = {}
    for i, st in ipairs(list) do
        local at = st.at
        it.steps[i] = { text = st.t, map = at and at[1], x = at and at[2], y = at and at[3], quest = st.quest, item = st.item, count = st.count }
    end
end
ns.AttachAchSteps = AttachAchSteps

-- The feature note for an achievement's group (Delves, Fishing, ...), from its own expansion:
-- ns.GROUP_NOTES holds Midnight's, ns.GROUP_NOTES_EXP[exp] the other expansions'.
function ns.GroupNote(it)
    if not (it and it.group) then return end
    local exp = (it.zone and it.zone.exp) or "midnight"
    if exp ~= "midnight" then return ns.GROUP_NOTES_EXP and ns.GROUP_NOTES_EXP[exp] and ns.GROUP_NOTES_EXP[exp][it.group] end
    return ns.GROUP_NOTES and ns.GROUP_NOTES[it.group]
end

-- A note as a list of short points: a table is used as written, a string is split at its sentences
-- (a full stop, ! or ? followed by a space and a capital letter).
function ns.NotePoints(note)
    if type(note) == "table" then return note end
    if type(note) ~= "string" or note == "" then return {} end
    local out, start = {}, 1
    while true do
        local s = note:find("[%.!?] %u", start)
        if not s then break end
        out[#out + 1] = note:sub(start, s)
        start = s + 2
    end
    out[#out + 1] = note:sub(start)
    return out
end

-- Adds an achievement's guide to a tooltip: the numbered steps (done ones greyed when `it` is given),
-- then the notes and the group's note as bullet points.
function ns.AddGuide(tooltip, id, it, groupNote)
    local steps = ns.ACH_STEPS and ns.ACH_STEPS[id]
    local note = ns.ACH_NOTES and ns.ACH_NOTES[id]
    if not (steps or note or groupNote) then return end
    tooltip:AddLine(" ")
    if steps then
        tooltip:AddLine("Step by step", 1, 0.82, 0.3)
        if it then AttachAchSteps(it) end
        for i, st in ipairs(steps) do
            local done = it and it.steps and ns.StepDone(it, i)
            local c = done and 0.5 or 0.95
            tooltip:AddLine(i .. ". " .. st.t, c, done and 0.5 or 0.9, done and 0.5 or 0.8, true)
        end
    end
    local points = ns.NotePoints(note)
    if #points > 0 then
        tooltip:AddLine(steps and "Good to know" or "How to do it", 1, 0.82, 0.3)
        for _, p in ipairs(points) do tooltip:AddLine("- " .. p, 0.9, 0.85, 0.7, true) end
    end
    for _, p in ipairs(ns.NotePoints(groupNote)) do tooltip:AddLine("- " .. p, 0.7, 0.7, 0.7, true) end
end

-- Appends one row per step, with bag counts for item steps and the current step flagged.
local function StepRows(it, rows)
    local cur = ns.CurrentStep(it)
    for i, st in ipairs(it.steps) do
        local text = st.text or ("Step " .. i)
        if st.count then text = string.format("%s  (%d/%d)", text, ns.bag[st.item] or 0, st.count) end
        rows[#rows + 1] = { key = "s" .. i, step = i, name = i .. ". " .. text, done = ns.StepDone(it, i),
                            current = (i == cur and not it.done), spot = st.x and { map = st.map, x = st.x, y = st.y } }
    end
end

-- Spot lists for walkthrough entries, built once so their world positions stay cached.
local guideSpots = setmetatable({}, { __mode = "k" })
-- The spot list for a walkthrough entry, reused across calls.
local function SpotsOf(g)
    local key = g.at[1]   -- a table from the data files (or the taxi cache), so it is stable between calls
    local list = guideSpots[key]
    if not list then
        list = {}
        for _, at in ipairs(g.at) do list[#list + 1] = { map = at[1], x = at[2], y = at[3] } end
        guideSpots[key] = list
    end
    return list
end

-- The rows an item expands into in the book: a container's items, a treasure's steps, a storyline's quests,
-- or an achievement's steps and criteria.
-- Row: { key, name, done, spot, quest, sub, note, item (a real item, for containers) }
function ns.Children(it)
    local rows = {}
    AttachAchSteps(it)
    if it.kind == "container" then
        for _, ch in ipairs(it.children) do
            if not ch.hidden then rows[#rows + 1] = { key = ch.key, item = ch } end
        end
        return rows
    end
    if it.kind == "point" and it.steps then
        StepRows(it, rows)
        return rows
    end
    if it.kind == "lore" and it.crit.chain then
        local c = it.crit
        local limit = (c.pos and c.pos > 0) and math.min(c.pos, #c.chain) or #c.chain
        local nextFound = false
        for i = 1, limit do
            local qid, qname = c.chain[i][1], c.chain[i][2]
            local done, acct = ns.QuestDone(qid)
            local active = not done and ns.QuestActive(qid)
            local row = { key = "q" .. qid, quest = qid, name = i .. ". " .. ns.QuestTitle(qid, qname), done = done or it.done,
                          sub = acct and "warband" or (active and "in log" or nil) }
            if not row.done and not nextFound then row.current = true; nextFound = true end
            rows[#rows + 1] = row
        end
        return rows
    end
    if it.kind == "ach" then
        if it.steps and not it.done then StepRows(it, rows) end
        local a = ns.Ach(it.id)
        local c = ns.Crits(it.id)
        local used = {}
        local pinst, pwx, pwy, havePos
        -- The spot closest to the player; the player's position is read once per call to ns.Children.
        local function nearest(spots)
            if #spots == 1 then return spots[1] end
            if not havePos then havePos = true; pinst, pwx, pwy = ns.PlayerWorld() end
            local best, bestD = spots[1], nil
            if pinst then
                for _, sp in ipairs(spots) do
                    local d = ns.Distance(sp, pinst, pwx, pwy)
                    if d and (not bestD or d < bestD) then best, bestD = sp, d end
                end
            end
            return best
        end
        for _, e in ipairs(c and c.list or {}) do
            if ns.InPart(it, e) then
                local p = (e.id and ns.achvByCrit[e.id])
                    or (e.name and ns.achvByName and ns.achvByName[it.id] and ns.achvByName[it.id][ns.norm(e.name)])
                local ov = e.id and ns.OVERRIDES[e.id]
                local name = (ov and ov.n) or ((e.name and e.name ~= "") and e.name) or (p and p.n) or ("Criterion " .. e.index)
                local row = { key = "c" .. (e.id or e.index), name = name, done = e.done or (a and a.done),
                              note = (ov and ov.note) or (p and p.note) }
                if p then
                    row.spot = p.x and { map = p.m, x = p.x, y = p.y }
                    if p.q then used[p.q] = true end
                    if p.c then used["c" .. p.c] = true end
                end
                -- walkthrough data (Data/Walkthroughs.lua): where to go and what to do, by criterion type:asset
                local g = ns.WalkthroughFor(it.id, e)
                if g then
                    if not row.spot and g.at and g.at[1] then
                        row.spots = SpotsOf(g)
                        row.spot = nearest(row.spots)
                    end
                    row.note = row.note or g.t
                    row.how = g.t
                end
                if e.t == 27 and e.asset and e.asset > 0 then row.quest = e.asset end
                -- a meta achievement: a part that is itself an achievement in the book becomes that
                -- achievement's own row, so the book shows the whole tree and each part can be opened and tracked
                if e.t == 8 and e.asset then
                    local part = ns.AchItem(e.asset)
                    if part and part ~= it then row.item = part end
                end
                if e.req and e.req > 1 then row.sub = string.format("%d/%d", e.qty or 0, e.req) end
                rows[#rows + 1] = row
            end
        end
        -- a delve's Stories achievement: the extra stories that aren't part of it, shown but never counted
        for _, info in pairs(ns.DELVE_INFO or {}) do
            if info.stories == it.id then
                for i, x in ipairs(info.extra or {}) do
                    rows[#rows + 1] = { key = "x" .. i, name = x.n, note = x.d, extra = true,
                                        sub = "not needed", done = false }
                end
            end
        end
        -- spots without a criterion (e.g. the Glowing Moths of Dust 'Em Off): tracked by their quest flag
        for _, p in ipairs(it.points or {}) do
            if not p.c and p.q and not used[p.q] then
                rows[#rows + 1] = { key = "q" .. p.q, name = p.n or ("Spot " .. p.q), done = ns.QuestDone(p.q),
                                    spot = p.x and { map = p.m, x = p.x, y = p.y }, note = p.note }
            end
        end
        return rows
    end
    return rows
end

------------------------------------------------------------------------
-- target resolution
------------------------------------------------------------------------

-- Yards and bearing (radians, for the arrow) from the player's world position to a spot (0-100 map coords).
-- nil when the spot is on another instance or has no position. The world position is cached on the spot.
local function Distance(spot, pinst, pwx, pwy)
    if not spot or not spot.x then return end
    if spot.wmap ~= spot.map or spot.wx0 ~= spot.x or spot.wy0 ~= spot.y then
        local inst, wx, wy = ns.MapToWorld(spot.map, spot.x / 100, spot.y / 100)
        spot.wmap, spot.wx0, spot.wy0, spot.inst, spot.wx, spot.wy = spot.map, spot.x, spot.y, inst, wx, wy
    end
    if not spot.inst or spot.inst ~= pinst then return end
    local dn, dw = spot.wx - pwx, spot.wy - pwy
    return math.sqrt(dn * dn + dw * dw), math.atan2(dw, dn)
end
ns.Distance = Distance

-- The spot closest to the player and its distance. Without a known distance, returns the first spot that
-- has a position and nil.
Nearest = function(spots)
    local pinst, pwx, pwy = ns.PlayerWorld()
    local best, bestD
    for _, s in ipairs(spots) do
        if s.x then
            local d = pinst and Distance(s, pinst, pwx, pwy)
            if d and (not bestD or d < bestD) then best, bestD = s, d end
            best = best or s
        end
    end
    return best, bestD
end
ns.Nearest = Nearest

-- True when the player stands on this map (or a map inside it), e.g. inside the delve a chest is in.
-- The delve a map belongs to, by name ("Twilight Crypts"), or nil. Known delve maps come from
-- ns.DELVE_MAPS; any other map (another floor, or an ID the data doesn't list) is matched by its name,
-- so being inside a delve is recognised whatever map the game shows there.
local delveNames
function ns.DelveForMap(mapID)
    if not mapID then return end
    if ns.DELVE_MAPS[mapID] then return ns.DELVE_MAPS[mapID] end
    if not delveNames then
        delveNames = {}
        for _, name in pairs(ns.DELVE_MAPS) do delveNames[ns.norm((name:gsub("^The ", "")))] = name end
    end
    local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
    local n = info and info.name and ns.norm((info.name:gsub("^The ", "")))
    return n and delveNames[n]
end

-- True when the player stands on this map (or a map inside it), or inside the same delve on another of its maps.
local function PlayerOnMap(mapID)
    for _, m in ipairs(ns.playerChain) do if m == mapID then return true end end
    local delve = ns.DELVE_MAPS[mapID]
    return delve ~= nil and ns.DelveForMap(ns.playerChain[1]) == delve
end
ns.PlayerOnMap = PlayerOnMap

-- The nearest unopened chest (or other point) inside a container you are standing in, with its spot.
-- skip leaves one child out (the one just finished). nil when you are not inside or none is left.
local function NearestOpenChild(container, skip)
    local pinst, pwx, pwy = ns.PlayerWorld()
    local best, bestSpot, bestD
    for _, ch in ipairs(container.children or {}) do
        if ch.kind == "point" and ch ~= skip and not ch.done and not ch.hidden then
            for _, sp in ipairs(ch.spots) do
                if PlayerOnMap(sp.map) then
                    local d = pinst and Distance(sp, pinst, pwx, pwy)
                    if not best or (d and (not bestD or d < bestD)) then best, bestSpot, bestD = ch, sp, d end
                end
            end
        end
    end
    return best, bestSpot
end
ns.NearestOpenChild = NearestOpenChild

-- Distance in yards from the player to an item's nearest spot (for list sorting and display), or nil.
function ns.ItemDistance(it)
    local _, d = Nearest(it.spots or {})
    return d
end

-- Returns { spot, title, text, step, stepCount } for an item, or for one of its child rows. spot is nil when
-- there is nowhere to point; an unknown childKey falls back to the whole item.
function ns.Resolve(it, childKey)
    local t = { title = it.name or "?" }
    if childKey then
        for _, row in ipairs(ns.Children(it)) do
            if row.key == childKey then
                if row.item then return ns.Resolve(row.item) end
                t.title = (it.name or "") .. ": " .. (row.name or "")
                if row.step then
                    t.step = row.step
                    t.text = it.steps[row.step].text
                    t.spot = row.spot
                    return t
                end
                if row.spot then t.spot = row.spot end
                if row.quest and not t.spot then
                    local pos, how = ns.QuestPos(row.quest)
                    if pos then t.spot = pos; t.text = (how == "objective" and "On: " or "Pick up: ") .. ns.QuestTitle(row.quest) end
                end
                t.text = t.text or row.note
                -- a criterion with no place of its own (a delve story): where its delve is
                if not t.spot and it.parent and it.parent.kind == "container" then
                    t.spot = ns.Resolve(it.parent).spot
                end
                return t
            end
        end
    end
    AttachAchSteps(it)
    if it.kind == "ach" and it.steps and not it.done then
        local i = ns.CurrentStep(it)
        local st = it.steps[i]
        t.step, t.text, t.stepCount = i, st.text, #it.steps
        t.spot = st.x and { map = st.map, x = st.x, y = st.y }
        return t
    end
    if it.kind == "point" then
        if it.steps and not it.done then
            local i = ns.CurrentStep(it)
            local s = it.steps[i]
            t.step, t.text = i, s.text
            if s.count then t.text = string.format("%s  |cffffffff%d/%d|r", s.text or "", ns.bag[s.item] or 0, s.count) end
            t.spot = s.x and { map = s.map, x = s.x, y = s.y }
            t.stepCount = #it.steps
        else
            t.spot = Nearest(it.spots)
            t.text = it.note
            -- a Sturdy Chest while you are outside its delve: the entrance first
            local host = it.parent
            if host and host.kind == "container" and t.spot and not PlayerOnMap(t.spot.map) and host.spots[1] then
                t.spot = Nearest(host.spots) or host.spots[1]
                t.text = "Enter " .. (host.name or "it") .. " first"
            end
            -- a rare that is up right now: point at where it stands
            local up = ns.upNow and ns.upNow[it.key]
            if up then
                t.spot = up.spot or t.spot
                t.text = "|cff55ff55Up now|r" .. (it.note and (": " .. it.note) or "")
            end
        end
        return t
    end
    if it.kind == "lore" then
        local c = it.crit
        local nextQ, nextName
        local limit = (c.pos and c.pos > 0) and math.min(c.pos, #(c.chain or {})) or #(c.chain or {})
        for i = 1, limit do
            if not ns.QuestDone(c.chain[i][1]) then nextQ, nextName = c.chain[i][1], c.chain[i][2]; break end
        end
        nextQ = nextQ or c.q
        if nextQ then
            local pos, how = ns.QuestPos(nextQ, c.map)
            t.spot = pos
            local title = ns.QuestTitle(nextQ, nextName)
            if pos then
                t.text = (how == "objective" and "On: " or "Pick up: ") .. title
            else
                t.text = "Next: " .. title .. (c.start and ("  (from " .. c.start .. ")") or "")
            end
        end
        return t
    end
    if it.kind == "ach" then
        -- the nearest open criterion; spot tables can be shared between rows, so the text comes from the row
        local pinst, pwx, pwy = ns.PlayerWorld()
        local best, bestD, bestSpot, bestText
        it.resolving = true   -- a meta achievement asks its parts; this stops a loop if two ever point at each other
        for _, row in ipairs(ns.Children(it)) do
            local spot, text
            if not row.done and row.spot then
                spot, text = row.spot, row.how or row.note or row.name
            elseif not row.done and row.item and not row.item.done and not row.item.resolving then
                local r = ns.Resolve(row.item)
                if r.spot then spot, text = r.spot, (row.item.liveName or row.item.name or "") .. ": " .. (r.text or "") end
            end
            if spot then
                local d = pinst and Distance(spot, pinst, pwx, pwy)
                if not best or (d and (not bestD or d < bestD)) then best, bestD, bestSpot, bestText = row, d, spot, text end
            end
        end
        it.resolving = nil
        if best then t.spot = bestSpot; t.text = bestText; return t end
        -- single-glyph achievements ("Skyriding Glyphs: Brightwing Estate"): use the Glyph Hunter spot of that name
        local a = ns.Ach(it.id)
        local glyph = a and a.name and a.name:match("^Sky%a+ Glyphs?:%s*(.+)$")   -- also "Skydiving Glyphs", "Skyriding Glyph"
        if glyph then
            local want = ns.norm(glyph)
            for _, p in ipairs(ns.POINTS) do
                if p.k == "achv" and p.n and ns.norm(p.n) == want and p.x then
                    t.spot, t.text = { map = p.m, x = p.x, y = p.y }, "Fly through the skyriding glyph" .. (p.note and (" - " .. p.note) or "")
                    return t
                end
            end
        end
        -- the whole achievement happens in one place (ns.ACH_SPOTS in Data/Notes.lua)
        local where = ns.ACH_SPOTS and ns.ACH_SPOTS[it.id]
        if where then
            local spots = {}
            for _, at in ipairs(where.at) do spots[#spots + 1] = { map = at[1], x = at[2], y = at[3] } end
            t.spot, t.text = Nearest(spots) or spots[1], where.t
            return t
        end
        -- an achievement of a delve or dungeon (Discoveries and the like): its delve's next chest or entrance
        if it.parent and it.parent.kind == "container" then
            local r = ns.Resolve(it.parent)
            t.spot, t.text = r.spot, r.text
        end
        return t
    end
    if it.kind == "collect" then
        t.spot = Nearest(it.spots or {})
        t.text = it.sourceText
        -- an achievement reward: follow the achievement's walkthrough
        if not t.spot and it.viaAch and not it.viaAch.done then
            local r = ns.Resolve(it.viaAch)
            t.spot, t.step, t.stepCount = r.spot, r.step, r.stepCount
            t.text = (it.viaAch.name or "Achievement") .. ": " .. (r.text or "")
        end
        return t
    end
    if it.kind == "step" then
        -- a holiday guide step or quest: the quest's objective while it is in your log, else where it starts
        for _, q in ipairs(it.quests or {}) do
            if not ns.QuestDone(q) and ns.QuestActive(q) then
                local pos, how = ns.QuestPos(q)
                if pos and how == "objective" then
                    t.spot, t.text = pos, "On: " .. ns.QuestTitle(q)
                    return t
                end
            end
        end
        -- a chain: where the next quest not done yet starts
        if #(it.quests or {}) > 1 and not it.any and ns.EventSpots then
            for _, q in ipairs(it.quests) do
                if not ns.QuestDone(q) then
                    local spots = ns.EventSpots({ q = q })
                    if #spots > 0 then
                        t.spot, t.text = Nearest(spots), "Next: " .. ns.QuestTitle(q) .. (it.note and ("  -  " .. it.note) or "")
                        return t
                    end
                    break
                end
            end
        end
        t.spot = Nearest(it.spots or {})
        t.text = it.note
        -- an achievement step with no place of its own: the achievement's nearest open part
        if not t.spot and it.ach then
            for _, id in ipairs(type(it.ach) == "table" and it.ach or { it.ach }) do
                local a = ns.AchItem(id)
                if a and not a.done then
                    local r = ns.Resolve(a)
                    if r.spot then
                        t.spot = r.spot
                        t.text = (r.text and r.text ~= "" and (r.text .. (it.note and ("  -  " .. it.note) or ""))) or it.note
                        break
                    end
                end
            end
        end
        return t
    end
    if it.kind == "container" then
        -- inside a delve: the nearest chest still to open; outside: the entrance
        local ch, spot = NearestOpenChild(it)
        if ch then
            t.spot, t.text = spot, "Next: " .. (ch.name or "Sturdy Chest") .. (ch.note and (" - " .. ch.note) or "")
            return t
        end
        t.spot = Nearest(it.spots or {})
        if it.ctype == "delve" and t.spot then t.text = "Entrance" end
        return t
    end
    t.spot = Nearest(it.spots or {})
    return t
end

------------------------------------------------------------------------
-- tracking
------------------------------------------------------------------------

-- Places the game's own map pin on a spot and supertracks it, unless that map doesn't allow pins.
local function SetPin(spot)
    if not (spot and C_Map and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates) then return end
    if C_Map.CanSetUserWaypointOnMap then
        local ok, can = pcall(C_Map.CanSetUserWaypointOnMap, spot.map)
        if ok and can == false then return end
    end
    local ok = pcall(function()
        C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(spot.map, spot.x / 100, spot.y / 100))
        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
    end)
    pinSet = ok and true or false
end

-- Removes the map pin, but only if this addon placed it.
-- Waypoint addons: WaypointUI (preferred, it draws the target in the world) or TomTom, when installed and
-- the option is on. One waypoint at a time, replaced as the target moves.
local tomtomUID, waypointUISet = nil, false

-- "WaypointUI" or "TomTom" when one is installed and the option is on, else nil.
local function WaypointAddon()
    if not (ns.db and ns.db.settings.waypointAddon ~= false) then return end
    if WaypointUIAPI and WaypointUIAPI.Navigation and WaypointUIAPI.Navigation.NewUserNavigation then return "WaypointUI" end
    if TomTom and TomTom.AddWaypoint then return "TomTom" end
end
ns.WaypointAddon = WaypointAddon

-- Removes the waypoint this addon gave to WaypointUI or TomTom (never one you placed yourself).
local function ClearAddonWaypoint()
    if tomtomUID and TomTom and TomTom.RemoveWaypoint then pcall(TomTom.RemoveWaypoint, TomTom, tomtomUID) end
    tomtomUID = nil
    if waypointUISet and WaypointUIAPI and WaypointUIAPI.Navigation then
        pcall(WaypointUIAPI.Navigation.ClearUserNavigation)
    end
    waypointUISet = false
end

-- Hands the target to the waypoint addon. Returns true when one took it.
local function SetAddonWaypoint(spot, title)
    local which = WaypointAddon()
    if not (which and spot and spot.x) then return false end
    ClearAddonWaypoint()
    local name = (title or "Completion"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    if which == "WaypointUI" then
        waypointUISet = pcall(WaypointUIAPI.Navigation.NewUserNavigation,
            { name = name, mapID = spot.map, x = spot.x, y = spot.y, suppressAudio = true })
        return waypointUISet
    end
    local ok, uid = pcall(TomTom.AddWaypoint, TomTom, spot.map, spot.x / 100, spot.y / 100,
        { title = name, from = "Completion", persistent = false, minimap = true, world = true })
    if ok then tomtomUID = uid end
    return ok
end

-- Removes Blizzard's map pin (when this addon set it) and the waypoint addon's waypoint.
local function ClearPin()
    if pinSet and C_Map and C_Map.ClearUserWaypoint then pcall(C_Map.ClearUserWaypoint) end
    pinSet = false
    ClearAddonWaypoint()
end

-- Tracks an item (or one of its rows) with the arrow; nil stops tracking. Tracking by hand ends a route.
function ns.Track(it, childKey)
    if ns.RouteOnTrack then ns.RouteOnTrack() end
    if ns.PatrolOnTrack then ns.PatrolOnTrack(it) end
    if not it then
        ns.cdb.target = nil
    else
        ns.cdb.target = { key = it.key, child = childKey }
    end
    ns.UpdateTarget(true)
    if ns.RefreshUI then ns.RefreshUI() end
    if ns.RefreshWorldPins then ns.RefreshWorldPins() end
    if ns.RefreshMinimapPins then ns.RefreshMinimapPins() end
    if ns.RefreshTracker then ns.RefreshTracker() end
end

-- The tracked item and child row key, or nil.
function ns.TargetItem()
    local t = ns.cdb.target
    return t and ns.items[t.key], t and t.child
end

-- Re-resolves the target and updates the arrow's text and the map pin. The pin is only moved when the spot
-- changes, or always with force. Clears tracking once the target is done.
function ns.UpdateTarget(force)
    if not arrow then return end
    if ns.RouteCheck then ns.RouteCheck() end
    local it, child = ns.TargetItem()
    -- a tracked criterion or step that is now done hands over to the whole achievement (nearest open part)
    if it and child and not it.done then
        for _, row in ipairs(ns.Children(it)) do
            if row.key == child then
                if row.done then ns.cdb.target.child, child = nil, nil end
                break
            end
        end
    end
    if it and it.done and not child and not (ns.FarmWanted and ns.FarmWanted(it)) then it = nil end
    if not it then
        ns.cdb.target = nil
        arrow.res = nil
        arrow:Hide()
        ClearPin()
        return
    end
    local res = ns.Resolve(it, child)
    local old = arrow.res
    arrow.res, arrow.item = res, it
    arrow.lastDist, arrow.lastRot = nil, nil
    local title = res.title
    if ns.RouteActive and ns.RouteActive() then title = ns.RouteLabel() .. title end
    if ns.PatrolActive and ns.PatrolActive() then title = ns.PatrolLabel() .. title end
    if res.step and res.stepCount then title = string.format("%s  |cffaaaaaa(step %d/%d)|r", title, res.step, res.stepCount) end
    arrow.title:SetText(title)
    arrow.stepText:SetText(res.text or "")
    local moved = force or not old or not old.spot ~= not res.spot
        or (old.spot and res.spot and (old.spot.x ~= res.spot.x or old.spot.y ~= res.spot.y))
    if moved then
        ClearPin()
        -- a waypoint addon takes the target when there is one; Blizzard's own map pin otherwise, if switched on
        if res.spot and not SetAddonWaypoint(res.spot, res.title) and ns.db.settings.pin then SetPin(res.spot) end
    end
    if ns.db.settings.arrow then arrow:Show() else arrow:Hide() end
end

-- Next open item in the same section, nearest first (arrow right-click, and after finishing one).
function ns.TrackNext(skipCurrent)
    if ns.RouteActive and ns.RouteActive() and ns.RouteNext() then return end
    if ns.PatrolActive and ns.PatrolActive() and ns.PatrolNext() then return end
    local cur = ns.TargetItem()
    local zone, sec
    if cur then
        local host = cur.parent or cur
        zone, sec = host.zone, host.sec
    end
    -- a Sturdy Chest hands over to the nearest one still closed in the same delve
    if cur and cur.kind == "point" and cur.parent and cur.parent.kind == "container" then
        local nextChest = NearestOpenChild(cur.parent, skipCurrent and cur)
        if not nextChest then
            for _, ch in ipairs(cur.parent.children) do
                if ch.kind == "point" and ch ~= cur and not ch.done and not ch.hidden then nextChest = ch; break end
            end
        end
        if nextChest then
            ns.Track(nextChest)
            ns.Print("Next chest in " .. (cur.parent.name or "this delve") .. ".")
            return
        end
        ns.Print("Every Sturdy Chest in " .. (cur.parent.name or "this delve") .. " is open.")
    end
    -- an achievement split over zones (this zone's part done): on to its nearest unfinished part elsewhere
    if cur and cur.kind == "ach" and cur.split and cur.done then
        local pinst, pwx, pwy = ns.PlayerWorld()
        local best, bestD
        for _, other in pairs(ns.items) do
            if other.kind == "ach" and other.id == cur.id and other ~= cur and not other.done and not other.hidden then
                local r = ns.Resolve(other)
                local d = r.spot and pinst and Distance(r.spot, pinst, pwx, pwy)
                if not best or (d and (not bestD or d < bestD)) then best, bestD = other, d end
            end
        end
        if best then
            ns.Track(best)
            ns.Print("Next part of " .. (best.liveName or best.name or "the achievement") .. ": " .. (best.zone and best.zone.name or "?") .. ".")
            return
        end
    end
    -- a holiday guide step hands over to the next open step, in the guide's order
    if cur and cur.kind == "step" and cur.sec == "guide" and cur.zone and ns.NextEventStep then
        local nxt = ns.NextEventStep(cur.zone, cur)
        if nxt then
            ns.Track(nxt)
            ns.Print("Next step: " .. (nxt.name or "?"))
            return
        end
    end
    -- goals on the watch list come before the rest of the section
    if ns.WatchNext and ns.WatchNext(cur) then return end
    -- nothing tracked: the section open in the book, in the zone you are in (or the book's zone)
    if not zone then
        zone = ns.PlayerZone() or ns.zoneByKey[ns.cdb.lastZone or ""]
        sec = ns.cdb.lastSection
    end
    if not zone or not sec or not zone.sections[sec] then ns.Track(nil); return end
    local candidates = {}
    for _, it in ipairs(zone.sections[sec].items) do
        if not it.done and not it.hidden and (it.max or 0) > 0 and not (skipCurrent and cur and it.key == cur.key) then
            candidates[#candidates + 1] = it
        end
    end
    local pinst, pwx, pwy = ns.PlayerWorld()
    local best, bestD
    for _, it in ipairs(candidates) do
        local res = ns.Resolve(it)
        local d = res.spot and pinst and Distance(res.spot, pinst, pwx, pwy)
        if d and (not bestD or d < bestD) then best, bestD = it, d end
    end
    best = best or candidates[1]
    ns.Track(best)
    if best then ns.Print("Now tracking: " .. (best.name or "?")) else ns.Print("Nothing left to track in " .. zone.sections[sec].name .. ".") end
end

------------------------------------------------------------------------
-- arrow frame
------------------------------------------------------------------------

-- Turns the arrow towards the target and updates the distance line. Shows the map coordinates instead when
-- there is no distance (another continent, an instance) and a hint when there is no spot at all.
local function ArrowTick(self)
    local res = self.res
    if not res then return end
    local spot = res.spot
    if not spot or not spot.x then
        self.tex:SetVertexColor(0.7, 0.7, 0.7)
        self.tex:SetAlpha(0.3)
        if self.lastDist ~= -2 then
            self.lastDist = -2
            self.dist:SetText("|cffaaaaaano fixed spot - see the note|r")
        end
        return
    end
    local pinst, pwx, pwy = ns.PlayerWorld()
    local dist, bearing
    if pinst then dist, bearing = Distance(spot, pinst, pwx, pwy) end
    local facing = GetPlayerFacing and GetPlayerFacing()
    if not dist or not facing then
        self.tex:SetVertexColor(0.7, 0.7, 0.7)
        self.tex:SetAlpha(0.4)
        if self.lastDist ~= -1 then
            self.lastDist = -1
            local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(spot.map)
            self.dist:SetText(string.format("|cffaaaaaa%s %.1f, %.1f|r", info and info.name or "", spot.x, spot.y))
        end
        return
    end
    self.tex:SetAlpha(1)
    local rot = bearing - facing
    if not self.lastRot or math.abs(rot - self.lastRot) > 0.02 then
        self.lastRot = rot
        self.tex:SetRotation(rot)
        -- green when you face the target, fading to gold as you turn away
        local off = math.abs((rot + math.pi) % (2 * math.pi) - math.pi)
        local t = math.min(1, math.max(0, (off - 0.2) / 0.6))
        self.tex:SetVertexColor(0.45 + 0.55 * t, 1 - 0.2 * t, 0.45 - 0.1 * t)
    end
    local d = math.floor(dist)
    if d ~= self.lastDist then
        self.lastDist = d
        local color = d < 25 and "|cff55ff55" or "|cffffffff"
        self.dist:SetText(string.format("%s%d yd|r  |cffaaaaaa%.1f, %.1f|r", color, d, spot.x, spot.y))
    end
end

-- Builds the movable arrow frame. Right-click ticks a guided step or moves on; shift-right-click stops.
function ns.CreateArrow()
    arrow = CreateFrame("Frame", "CompletionArrow", UIParent)
    arrow:SetSize(44, 44)
    arrow:SetMovable(true)
    arrow:EnableMouse(true)
    arrow:SetClampedToScreen(true)
    arrow:SetFrameStrata("MEDIUM")
    arrow.tex = arrow:CreateTexture(nil, "ARTWORK")
    arrow.tex:SetAllPoints()
    arrow.tex:SetTexture(TEXTURE)
    arrow.title = arrow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    arrow.title:SetPoint("TOP", arrow, "BOTTOM", 0, -2)
    arrow.title:SetWidth(320)
    arrow.title:SetJustifyH("CENTER")
    arrow.dist = arrow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    arrow.dist:SetPoint("TOP", arrow.title, "BOTTOM", 0, -1)
    arrow.stepText = arrow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    arrow.stepText:SetPoint("TOP", arrow.dist, "BOTTOM", 0, -3)
    arrow.stepText:SetWidth(320)
    arrow.stepText:SetJustifyH("CENTER")
    arrow.stepText:SetWordWrap(true)
    arrow.stepText:SetTextColor(0.95, 0.88, 0.6)
    arrow:RegisterForDrag("LeftButton")
    arrow:SetScript("OnDragStart", arrow.StartMoving)
    arrow:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); ns.SavePos(self, "arrow") end)
    arrow:SetScript("OnMouseUp", function(_, button)
        if button ~= "RightButton" then return end
        local it, child = ns.TargetItem()
        if IsShiftKeyDown() then ns.Track(nil); return end
        -- a guided treasure: right-click ticks the current step by hand (talked to an NPC, drank a potion...)
        if it and it.steps and not child and not it.done then
            local i = ns.CurrentStep(it)
            if i < #it.steps then
                ns.MarkStep(it, i)
                ns.UpdateTarget()
                if ns.RefreshUI then ns.RefreshUI() end
                return
            end
        end
        ns.TrackNext(true)
    end)
    arrow:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -60)
        GameTooltip:AddLine(self.item and self.item.name or "Completion")
        GameTooltip:AddLine("Drag to move.", 0.6, 0.6, 0.6)
        GameTooltip:AddLine(ns.RouteActive and ns.RouteActive() and "Right-click: step done / skip to the next stop of the route."
            or "Right-click: step done / next open item.", 0.6, 0.6, 0.6)
        GameTooltip:AddLine(ns.RouteActive and ns.RouteActive() and "Shift-right-click: stop the route."
            or "Shift-right-click: stop tracking.", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    arrow:SetScript("OnLeave", function() GameTooltip:Hide() end)
    arrow:SetScript("OnUpdate", function(self, elapsed)
        self.acc = (self.acc or 0) + elapsed
        if self.acc < 0.05 then return end
        self.acc = 0
        ArrowTick(self)
    end)
    ns.RestorePos(arrow, "arrow", "TOP", 0, -140)
    arrow:SetScale(ns.db.settings.arrowScale or 1)
    arrow:Hide()
    ns.arrow = arrow
end

------------------------------------------------------------------------
-- frame positions
------------------------------------------------------------------------

-- Saves a frame's first anchor under ns.db.frames[key].
function ns.SavePos(frame, key)
    local point, _, relPoint, x, y = frame:GetPoint()
    if point then ns.db.frames[key] = { point = point, relPoint = relPoint, x = x, y = y } end
end

-- Puts a frame back where it was saved, or at the given default anchor on UIParent.
function ns.RestorePos(frame, key, dPoint, dx, dy)
    local p = ns.db.frames[key]
    frame:ClearAllPoints()
    if p and p.point then
        frame:SetPoint(p.point, UIParent, p.relPoint or p.point, p.x or 0, p.y or 0)
    else
        frame:SetPoint(dPoint, UIParent, dPoint, dx, dy)
    end
end
