-- Completion: builds every zone page (sections -> items) and evaluates what is done.
--
-- Item kinds
--   point      treasure / rare / world boss / Sturdy Chest / profession knowledge (Data/Points.lua)
--   lore       one questline criterion of a Loremaster achievement (Data/Lore.lua), chain as children
--   ach        a live achievement; criteria as children, spots from achievement points
--   container  a dungeon, raid or delve; its achievements and chests as children
--   rep        a faction
--   collect    a mount, pet, toy, decor piece, appearance, title or set
--
-- item.max = units it counts for (0 = shown but not counted), item.cur = units done, item.done.

local _, ns = ...

ns.zoneByKey, ns.zoneByMap = {}, {}
ns.items = {}               -- key -> item (every item, children included)
ns.built = false

local norm = ns.norm

-- The zone page a map belongs to. An unknown map walks up to six parent maps and caches the
-- answer; nil when none of them is ours.
local function ZoneForMap(m)
    if not m then return end
    local z = ns.zoneByMap[m]
    if z then return z end
    if C_Map and C_Map.GetMapInfo then
        local cur = m
        for _ = 1, 6 do
            local ok, info = pcall(C_Map.GetMapInfo, cur)
            if not ok or not info or not info.parentMapID or info.parentMapID == 0 then break end
            cur = info.parentMapID
            if ns.zoneByMap[cur] then
                ns.zoneByMap[m] = ns.zoneByMap[cur]
                return ns.zoneByMap[cur]
            end
        end
    end
end
ns.ZoneForMap = ZoneForMap

-- Files an item under a zone section and registers it by key. Returns the item.
local function AddItem(zone, secKey, it)
    it.zone, it.sec = zone, secKey
    local sec = zone.sections[secKey]
    sec.items[#sec.items + 1] = it
    ns.items[it.key] = it
    return it
end

-- Registers an item by key without putting it in a section (children of a container).
local function Register(it)
    ns.items[it.key] = it
    return it
end

------------------------------------------------------------------------
-- build: points
------------------------------------------------------------------------

local achvPoints = {}       -- achievementID -> { points }
local achvByCrit = {}       -- criterionID -> point
local groupAchs = {}        -- achievement IDs shown as treasure/rare group headers (not listed again)
local delveChests = {}      -- delve name -> { point items }
local chestAchs = {}        -- delve name -> set of achievement IDs
local achvLoot = {}         -- achievement spots that hand out rewards (vendors like the Mothkeeper)

-- Walkthrough steps for a point: the hand-written override steps, or else its helper spots followed
-- by the point itself. nil when it has neither.
local function PointSteps(p, name)
    local ov = p.c and ns.OVERRIDES[p.c]
    if ov and ov.steps then
        local steps = {}
        for i, s in ipairs(ov.steps) do
            steps[i] = { x = s.x, y = s.y, map = s.map or p.m, text = s.text, item = s.item, count = s.count, quest = s.quest }
        end
        return steps
    end
    if p.rel then
        local steps = {}
        for _, r in ipairs(p.rel) do
            local text = r.text
            if r.item then
                local iname = ns.ItemName(r.item)
                text = "Pick up " .. (iname or ("item " .. r.item)) .. (text and (": " .. text) or "")
            end
            steps[#steps + 1] = { x = r.x, y = r.y, map = p.m, item = r.item, text = text or "Helper spot" }
        end
        if p.x then steps[#steps + 1] = { x = p.x, y = p.y, map = p.m, text = "Open " .. (name or "it") } end
        return steps
    end
end

-- Turns a Data/Points.lua entry into a point item, with its override applied. Returns the item and
-- its zone (fallbackZone when the map is not one of ours).
local function BuildPoint(p, fallbackZone)
    local zone = ZoneForMap(p.m) or fallbackZone
    local ov = p.c and ns.OVERRIDES[p.c] or {}
    local name = ov.n or p.n
    local it = {
        key = string.format("p:%d:%s:%s:%s", p.m, tostring(p.q or p.c or ""), tostring(p.x or ""), tostring(p.y or "")),
        kind = "point", pkind = p.k, name = name, a = p.a, c = p.c, q = p.q, npc = p.npc, prof = p.prof,
        fish = p.fish, wq = p.wq, note = ov.note or p.note, tips = ov.tips, loot = p.loot, sl = p.sl,
        spots = {},
    }
    if p.x then it.spots[1] = { map = p.m, x = p.x, y = p.y } end
    for _, a in ipairs(p.alt or {}) do it.spots[#it.spots + 1] = { map = a[1], x = a[2], y = a[3] } end
    it.steps = PointSteps(p, name)
    return it, zone
end

-- Sorts every point: achievement spots and vendors are kept for later, Sturdy Chests wait for their
-- delve, and the rest go to the treasure, rare or knowledge section of their zone.
local function BuildPoints(midnight)
    local function fallback(p) return (p.exp and ns.overviews[p.exp]) or midnight end
    local all = {}
    for _, p in ipairs(ns.POINTS) do all[#all + 1] = p end
    for _, p in ipairs(ns.EXTRA_POINTS or {}) do all[#all + 1] = p end
    for _, p in ipairs(all) do
        if p.k == "vendor" then
            achvLoot[#achvLoot + 1] = p
        elseif p.k == "achv" then
            if p.a and not ns.IGNORE_ACH[p.a] then
                achvPoints[p.a] = achvPoints[p.a] or {}
                table.insert(achvPoints[p.a], p)
                if p.c then achvByCrit[p.c] = p end
            end
            if p.loot then achvLoot[#achvLoot + 1] = p end
        else
            local it, zone = BuildPoint(p, fallback(p))
            if p.k == "delve" then
                local dname = ns.DELVE_MAPS[p.m] or ("Delve " .. p.m)
                delveChests[dname] = delveChests[dname] or {}
                table.insert(delveChests[dname], it)
                it.zoneHint = zone
                if p.a then
                    chestAchs[dname] = chestAchs[dname] or {}
                    chestAchs[dname][p.a] = true
                    groupAchs[p.a] = true
                end
                Register(it)
            else
                local sec = (p.k == "rare" or p.k == "boss") and "rare" or (p.k == "prof" and "prof") or "treasure"
                it.groupAch = p.a
                if p.a then groupAchs[p.a] = true end
                if p.k == "boss" then it.group = "World bosses" end
                if p.k == "prof" then it.group = p.prof end
                AddItem(zone, sec, it)
            end
        end
    end
end

------------------------------------------------------------------------
-- build: Loremaster
------------------------------------------------------------------------

local loreIDs, loreZone = {}, {}

-- One item per questline criterion of each Loremaster achievement, or a plain achievement item when
-- Data/Lore.lua lists no criteria for it.
local function BuildLore(zone, secKey, ids)
    for _, id in ipairs(ids or {}) do
        local a = ns.LORE_ACH[id]
        loreIDs[id] = true
        loreZone[id] = zone
        if a then
            if a.crits and #a.crits > 0 then
                for i, c in ipairs(a.crits) do
                    local it = {
                        key = string.format("l:%d:%d", id, c.id or i), kind = "lore", ach = id, crit = c,
                        name = c.n, groupAch = id, order = i, note = c.note,
                        spots = {},
                    }
                    AddItem(zone, secKey, it)
                end
            else
                AddItem(zone, secKey, { key = "a:lore:" .. id, kind = "ach", id = id, name = a.name, groupAch = id, spots = {} })
            end
            if a.note then zone.loreNotes = zone.loreNotes or {}; zone.loreNotes[id] = a.note end
        else
            -- no questline data for it (another expansion's storyline): the plain achievement with its criteria
            AddItem(zone, secKey, { key = "a:lore:" .. id, kind = "ach", id = id, groupAch = id, spots = {} })
        end
    end
end

------------------------------------------------------------------------
-- build: dungeons, raids, delves (live from the map)
------------------------------------------------------------------------

local keywordTargets = {}   -- { key = normalized text, zone, container (or nil) }
local instanceZone = {}     -- normalized dungeon/raid/delve name -> zone
local instanceItem = {}     -- normalized dungeon/raid/delve name -> its container item
local placedInstance = {}   -- "i:name" / "d:name" -> true once filed in a zone (each only once)

-- Remembers text that ties an achievement to a zone, and to a dungeon, raid or delve when container
-- is given. Keys under 5 characters are too loose to match on.
local function AddKeyword(text, zone, container)
    local k = norm(text)
    if container and container.name and norm(container.name) == k then instanceZone[k] = zone; instanceItem[k] = container end
    if #k >= 5 then keywordTargets[#keywordTargets + 1] = { key = k, zone = zone, container = container } end
end

-- Dungeon and raid entrances on the zone's maps, from the Encounter Journal. Boss names become
-- keywords for their instance.
-- The zone an entrance really lies in. The game lists entrances near a border on the neighbouring zone's map
-- too, so the continent map decides: the zone it shows at that spot. nil when that can't be worked out.
local function OwnerZone(spot)
    if not (spot and C_Map and C_Map.GetMapInfo and C_Map.GetMapInfoAtPosition) then return end
    local continentType = Enum and Enum.UIMapType and Enum.UIMapType.Continent or 2
    local cont, cur = nil, spot.map
    for _ = 1, 6 do
        local ok, info = pcall(C_Map.GetMapInfo, cur)
        if not ok or not info then break end
        if info.mapType == continentType then cont = info.mapID or cur; break end
        if not info.parentMapID or info.parentMapID == 0 then break end
        cur = info.parentMapID
    end
    if not cont then return end
    local x, y = ns.MapPosOn(spot, cont)
    if not x then return end
    local ok, at = pcall(C_Map.GetMapInfoAtPosition, cont, x, y)
    local z = ok and at and ZoneForMap(at.mapID)
    return z and not z.overview and z or nil
end

-- A delve's entrance from Data/Notes.lua ({ map, x, y }), matched by name with or without "The".
local function DelveEntrance(name)
    local want = norm((tostring(name):gsub("^The ", "")))
    for n, at in pairs(ns.DELVE_ENTRANCES or {}) do
        if norm((n:gsub("^The ", ""))) == want then return at end
    end
    for n, info in pairs(ns.DELVE_INFO or {}) do
        if info.at and norm((n:gsub("^The ", ""))) == want then return info.at end
    end
end

-- A delve's entry in Data/Delves.lua (achievements, entrance, story notes), matched by name with or without "The".
local function DelveInfo(name)
    local want = norm((tostring(name):gsub("^The ", "")))
    for n, info in pairs(ns.DELVE_INFO or {}) do
        if norm((n:gsub("^The ", ""))) == want then return info, n end
    end
end
ns.DelveInfo = DelveInfo

-- A note on a delve (Data/Notes.lua ns.DELVE_NOTES), shown in its tooltip; nil when there is none.
local function DelveNote(name)
    local want = norm((tostring(name):gsub("^The ", "")))
    for n, note in pairs(ns.DELVE_NOTES or {}) do
        if norm((n:gsub("^The ", ""))) == want then return note end
    end
end

-- Dungeons and raids on the zone's maps, from the Encounter Journal. Each is filed once, in the zone its
-- entrance is in (the journal lists entrances near a border on both zones' maps).
local function BuildInstances(zone)
    local seen = {}
    if C_EncounterJournal and C_EncounterJournal.GetDungeonEntrancesForMap then
        for _, m in ipairs(zone.maps or {}) do
            local ok, list = pcall(C_EncounterJournal.GetDungeonEntrancesForMap, m)
            if ok and type(list) == "table" then
                for _, e in ipairs(list) do
                    local instID = e.journalInstanceID
                    if e.name and not seen[norm(e.name)] and not placedInstance["i:" .. norm(e.name)] then
                        seen[norm(e.name)] = true
                        placedInstance["i:" .. norm(e.name)] = true
                        local it = { key = "i:" .. norm(e.name), kind = "container", ctype = "instance", name = e.name,
                                     instID = instID, children = {}, spots = {} }
                        if e.position then
                            local x, y
                            if e.position.GetXY then x, y = e.position:GetXY() else x, y = e.position.x, e.position.y end
                            if x then it.spots[1] = { map = m, x = x * 100, y = y * 100 } end
                        end
                        if instID and EJ_GetInstanceInfo then
                            local ok2, _, desc, _, _, _, _, _, _, _, _, _, isRaid = pcall(EJ_GetInstanceInfo, instID)
                            if ok2 then it.desc = desc; it.raid = isRaid end
                        end
                        it.group = it.raid and "Raids" or "Dungeons"
                        local owner = OwnerZone(it.spots[1]) or zone
                        AddItem(owner, "instance", it)
                        AddKeyword(e.name, owner, it)
                        if instID and EJ_GetEncounterInfoByIndex then
                            it.bosses = {}
                            for i = 1, 20 do
                                local ok3, bname = pcall(EJ_GetEncounterInfoByIndex, i, instID)
                                if not ok3 or not bname then break end
                                it.bosses[#it.bosses + 1] = bname
                                AddKeyword(bname, owner, it)
                            end
                        end
                    end
                end
            end
        end
    end
    -- names from Zones.lua when the journal gave nothing (not verified in game; the journal wins)
    for _, name in ipairs(zone.instances or {}) do
        if not seen[norm(name)] and not placedInstance["i:" .. norm(name)] then
            seen[norm(name)] = true
            placedInstance["i:" .. norm(name)] = true
            local it = { key = "i:" .. norm(name), kind = "container", ctype = "instance", name = name,
                         children = {}, spots = {}, group = "Dungeons & raids" }
            AddItem(zone, "instance", it)
            AddKeyword(name, zone, it)
        end
    end
end

-- Delves on the zone's maps, from their area POIs. Each delve is filed once, in the zone its entrance is in.
local function BuildDelves(zone)
    if not (C_AreaPoiInfo and C_AreaPoiInfo.GetDelvesForMap) then return end
    for _, m in ipairs(zone.maps or {}) do
        local ok, ids = pcall(C_AreaPoiInfo.GetDelvesForMap, m)
        if ok and type(ids) == "table" then
            for _, poi in ipairs(ids) do
                local ok2, info = pcall(C_AreaPoiInfo.GetAreaPOIInfo, m, poi)
                local key = ok2 and info and info.name and ("d:" .. norm(info.name))
                if key and not placedInstance[key] then
                    placedInstance[key] = true
                    local it = { key = key, kind = "container", ctype = "delve", name = info.name, children = {}, spots = {} }
                    local entrance = DelveEntrance(info.name)
                    if entrance then
                        it.spots[1] = { map = entrance[1], x = entrance[2], y = entrance[3] }
                    elseif info.position then
                        local x, y
                        if info.position.GetXY then x, y = info.position:GetXY() else x, y = info.position.x, info.position.y end
                        if x then it.spots[1] = { map = m, x = x * 100, y = y * 100 } end
                    end
                    it.desc = DelveNote(info.name)
                    local owner = (entrance and ZoneForMap(entrance[1])) or OwnerZone(it.spots[1]) or zone
                    if owner.overview then owner = zone end
                    AddItem(owner, "delve", it)
                    AddKeyword(info.name, owner, it)
                end
            end
        end
    end
end

-- Every delve in Data/Delves.lua gets a page entry even when the map didn't list it, in its own zone.
local function EnsureDelves()
    for name, info in pairs(ns.DELVE_INFO or {}) do
        local want = norm((name:gsub("^The ", "")))
        local found
        for _, z in ipairs(ns.ZONES) do
            for _, it in ipairs(z.sections.delve.items) do
                if norm((it.name:gsub("^The ", ""))) == want then found = it; break end
            end
            if found then break end
        end
        local zone = ns.zoneByKey[info.zone]
        if not found and zone then
            local it = { key = "d:" .. norm(name), kind = "container", ctype = "delve", name = name, children = {}, spots = {} }
            if info.at then it.spots[1] = { map = info.at[1], x = info.at[2], y = info.at[3] } end
            it.desc = DelveNote(name)
            placedInstance[it.key] = true
            AddItem(zone, "delve", it)
            AddKeyword(name, zone, it)
        end
    end
end

-- A delve's Stories and Discoveries achievements go inside it (Stories first), with the story notes from
-- Data/Delves.lua as their walkthrough. They are marked so the achievement list doesn't file them again.
local function AttachDelveAchievements()
    local notesDone = ns.delveNotesMerged
    for _, z in ipairs(ns.ZONES) do
        for _, d in ipairs(z.sections.delve.items) do
            local info = DelveInfo(d.name)
            if info then
                d.achSet = d.achSet or {}
                for i, aid in ipairs({ info.stories, info.chests }) do
                    if aid and not d.achSet[aid] then
                        local child = Register({ key = "a:" .. d.key .. ":" .. aid, kind = "ach", id = aid, spots = {}, parent = d })
                        table.insert(d.children, i, child)
                        d.achSet[aid] = true
                    end
                    if aid then groupAchs[aid] = true end
                end
                if not notesDone and info.stories then
                    ns.CRIT_NOTES[info.stories] = ns.CRIT_NOTES[info.stories] or {}
                    for story, text in pairs(info.notes or {}) do
                        ns.CRIT_NOTES[info.stories][story] = ns.CRIT_NOTES[info.stories][story] or { t = text }
                    end
                end
            end
        end
    end
    ns.delveNotesMerged = true
end

-- Sturdy Chests and their Discoveries achievements go under the delve they belong to. A delve the
-- map did not list (and Data/Delves.lua doesn't know) is added to the zone of its entrance, else to the
-- page its chests were filed on, else to the Midnight page.
local function AttachDelveChests(midnight)
    for dname, chests in pairs(delveChests) do
        local target
        local dn = norm(dname)
        for _, z in ipairs(ns.ZONES) do
            for _, it in ipairs(z.sections.delve.items) do
                local n = norm(it.name)
                if n == dn or n:find(dn, 1, true) or dn:find(n, 1, true) then target = it; break end
            end
            if target then break end
        end
        if not target then
            local at = DelveEntrance(dname)
            local home = (at and ZoneForMap(at[1])) or (chests[1] and chests[1].zoneHint) or midnight
            target = AddItem(home, "delve", { key = "d:" .. dn, kind = "container", ctype = "delve", name = dname,
                                              children = {}, spots = {} })
            AddKeyword(dname, home, target)
        end
        if #target.spots == 0 and ns.DELVE_ENTRANCES then
            for name, at in pairs(ns.DELVE_ENTRANCES) do
                local n = norm(name)
                if n == dn or n:find(dn, 1, true) or dn:find(n, 1, true) then
                    target.spots[1] = { map = at[1], x = at[2], y = at[3] }
                    break
                end
            end
        end
        for _, c in ipairs(chests) do
            c.name = c.name or "Sturdy Chest"
            c.parent = target
            table.insert(target.children, c)
        end
        for aid in pairs(chestAchs[dname] or {}) do
            local child = Register({ key = "a:" .. target.key .. ":" .. aid, kind = "ach", id = aid, spots = {}, parent = target })
            table.insert(target.children, 1, child)
            target.achSet = target.achSet or {}
            target.achSet[aid] = true
        end
    end
end

------------------------------------------------------------------------
-- build: achievements (live categories + achievement points)
------------------------------------------------------------------------

-- The game's achievement categories under a "Midnight" category, as { id, label, sub }. sub is the
-- category just below Midnight (often a zone); label is that, or the parent above Midnight.
local function MidnightCategories()
    local out = {}
    if not (GetCategoryList and GetCategoryInfo) then return out end
    local ok, cats = pcall(GetCategoryList)
    if not ok or type(cats) ~= "table" then return out end
    local info = {}
    for _, id in ipairs(cats) do
        local ok2, title, parent = pcall(GetCategoryInfo, id)
        if ok2 then info[id] = { title = title, parent = parent } end
    end
    local EXP = _G.EXPANSION_NAME11
    -- the English name or the client's own name for the expansion
    local function isMidnight(t) return type(t) == "string" and (t:find("Midnight", 1, true) ~= nil or (EXP and t:find(EXP, 1, true) ~= nil)) end
    for _, id in ipairs(cats) do
        -- walk up; remember the category right under "Midnight" and the one above it
        local cur, depth, below = id, 0, nil
        while cur and cur > 0 and depth < 6 do
            local c = info[cur]
            if not c then break end
            if isMidnight(c.title) then
                local above = c.parent and info[c.parent]
                local label = below and info[below].title or (above and above.title) or "Midnight"
                out[#out + 1] = { id = id, label = label, sub = below and info[below].title }
                break
            end
            below = cur
            cur, depth = c.parent, depth + 1
        end
    end
    return out
end

-- An achievement's name, description and criteria as one normalized string, for keyword matching.
local function AchText(id)
    local a = ns.Ach(id)
    if not a then return "" end
    local parts = { a.name or "", a.desc or "" }
    local c = ns.Crits(id)
    for _, e in ipairs(c and c.list or {}) do parts[#parts + 1] = e.name or "" end
    return norm(table.concat(parts, " "))
end

-- Guesses where an achievement belongs from its category and text. Returns zone and container when
-- exactly one instance is named, the zone alone when only one zone is, otherwise nil.
local function MatchAch(id, catSub)
    -- a sub-category named after a zone decides it outright
    if catSub then
        for _, z in ipairs(ns.ZONES) do
            if norm(z.name) == norm(catSub) then return z end
        end
    end
    local text = AchText(id)
    local hitC, hitZ = {}, {}
    local nC, nZ = 0, 0
    for _, kw in ipairs(keywordTargets) do
        if text:find(kw.key, 1, true) then
            if kw.container and not hitC[kw.container] then hitC[kw.container] = true; nC = nC + 1 end
            if not hitZ[kw.zone] then hitZ[kw.zone] = true; nZ = nZ + 1 end
        end
    end
    if nC == 1 then
        for c in pairs(hitC) do return c.zone, c end
    end
    -- several instances of one zone (or none): the zone's general list
    if nZ == 1 then
        for z in pairs(hitZ) do return z end
    end
end

local SpotZone            -- defined below MetaZones

-- 1 for Alliance, 2 for Horde (the values ACH_SIDE uses), nil for a neutral character.
local function PlayerSide()
    local f = UnitFactionGroup and UnitFactionGroup("player")
    return f == "Alliance" and 1 or (f == "Horde" and 2 or nil)
end

-- Zone for each achievement that is a criterion of an achievement already sitting in a zone
-- (Glyph Hunter -> its single glyphs, a zone meta -> its parts).
local function MetaZones(zoneOfAch)
    local out = {}
    for aid, z in pairs(zoneOfAch) do
        if not z.overview then
            local c = ns.Crits(aid)
            for _, e in ipairs(c and c.list or {}) do
                if e.t == 8 and e.asset and e.asset > 0 and out[e.asset] == nil then out[e.asset] = z end
            end
        end
    end
    return out
end

-- The zone where all of an achievement's walkthrough spots are (hand-written steps, a whole-achievement
-- spot or criterion notes). nil when they disagree or none is on a zone page.
SpotZone = function(aid)
    local found
    -- false when m is in a different zone from the spots before it; the overview and unknown maps are skipped
    local function consider(m)
        local z = m and ZoneForMap(m)
        if not z or z.overview then return true end
        if found and found ~= z then return false end
        found = z
        return true
    end
    local where = ns.ACH_SPOTS and ns.ACH_SPOTS[aid]
    for _, at in ipairs(where and where.at or {}) do if not consider(at[1]) then return end end
    for _, st in ipairs(ns.ACH_STEPS and ns.ACH_STEPS[aid] or {}) do if st.at and not consider(st.at[1]) then return end end
    for _, g in pairs(ns.CRIT_NOTES and ns.CRIT_NOTES[aid] or {}) do
        for _, at in ipairs(g.at or {}) do if not consider(at[1]) then return end end
    end
    for _, g in pairs(ns.CRIT_GUIDE and ns.CRIT_GUIDE[aid] or {}) do
        for _, at in ipairs(g.at or {}) do if not consider(at[1]) then return end end
    end
    return found
end

-- Places every achievement in scope that is not already shown elsewhere (Loremaster, point group
-- headers). One that names a single dungeon, raid or delve goes inside it; the rest go to a zone.
local function BuildAchievements(midnight)
    for _, z in ipairs(ns.ZONES) do
        for _, kw in ipairs(z.keywords or {}) do AddKeyword(kw, z, nil) end
        -- a zone's reputation name ties "<Faction> Champion" and the like to it
        for _, fid in ipairs(z.factions or {}) do
            if not z.overview then
                local r = ns.Rep(fid)
                if r and r.name then AddKeyword(r.name, z, nil) end
            end
        end
    end
    local groupOf, expOf = {}, {}
    for _, g in ipairs(ns.ACH_GROUPS or {}) do
        for _, id in ipairs(g[2]) do groupOf[id] = g[1]; expOf[id] = g.exp end
    end
    -- the overview page an achievement falls back to: its expansion's
    local function home(aid) return (expOf[aid] and ns.overviews[expOf[aid]]) or midnight end
    local side = PlayerSide()
    local placed, zoneOfAch = {}, {}
    for id in pairs(loreIDs) do placed[id] = true; zoneOfAch[id] = loreZone[id] end
    for id in pairs(groupAchs) do placed[id] = true end
    for id in pairs(ns.IGNORE_ACH) do placed[id] = true end

    -- achievements with spots: they live where their spots are
    for aid, pts in pairs(achvPoints) do
        local a = ns.Ach(aid)
        -- Other (not counted) achievements are listed once on the overview page, not by their spots
        local other = ns.OTHER_GROUPS and ns.OTHER_GROUPS[groupOf[aid]]
        if not placed[aid] and (not ns.Counts(groupOf[aid]) or (a and ns.IsHard(a.name))) then placed[aid] = true end
        if not placed[aid] and not other then
            placed[aid] = true
            local byZone, order = {}, {}
            for _, p in ipairs(pts) do
                local z = ZoneForMap(p.m) or home(aid)
                if not byZone[z] then byZone[z] = {}; order[#order + 1] = z end
                table.insert(byZone[z], p)
            end
            local split = #order > 1
            if not split then zoneOfAch[aid] = order[1] end
            for _, z in ipairs(order) do
                local it = { key = "a:" .. z.key .. ":" .. aid, kind = "ach", id = aid, points = byZone[z], spots = {},
                             group = groupOf[aid] }
                if split then
                    -- this zone's criteria: by criterion ID, and by name in case the game's IDs differ from the data
                    it.filter, it.filterNames = {}, {}
                    for _, p in ipairs(byZone[z]) do
                        if p.c then it.filter[p.c] = true end
                        if p.n then it.filterNames[norm(p.n)] = true end
                    end
                    if not next(it.filter) then it.filter = nil end
                    if not next(it.filterNames) then it.filterNames = nil end
                    it.split = true
                end
                AddItem(z, "achv", it)
            end
        end
    end

    -- the Midnight list (Data/Achievements.lua), then anything new in the game's Midnight categories
    local todo, queued = {}, {}
    -- skips achievements already placed, for the other faction, or unknown to the client
    local function queue(aid, group, catSub)
        if placed[aid] or queued[aid] then return end
        local s = ns.ACH_SIDE and ns.ACH_SIDE[aid]
        if s and side and s ~= side then return end
        local a = ns.Ach(aid)
        if not a then return end
        -- out of scope (Options > What counts): never built, never counted
        if not ns.Counts(groupOf[aid] or group) or ns.IsHard(a.name) then placed[aid] = true; return end
        queued[aid] = true
        todo[#todo + 1] = { id = aid, group = group, sub = catSub }
    end
    for _, g in ipairs(ns.ACH_GROUPS or {}) do
        for _, aid in ipairs(g[2]) do queue(aid, g[1]) end
    end
    for _, cat in ipairs(MidnightCategories()) do
        local ok, n = pcall(GetCategoryNumAchievements, cat.id, true)
        if ok and type(n) == "number" then
            for i = 1, n do
                local ok2, aid = pcall(GetAchievementInfo, cat.id, i)
                if ok2 and aid then queue(aid, cat.label, cat.sub) end
            end
        end
    end

    -- first pass: what the text says
    for _, t in ipairs(todo) do
        t.zone, t.container = MatchAch(t.id, t.sub)
        -- a zone hint from the data (Data/TWW/Points.lua) wins over a guess from the text, never over an instance
        local hint = ns.ACH_ZONE and ns.ACH_ZONE[t.id]
        if hint and not t.container and ns.zoneByKey[hint] then t.zone = ns.zoneByKey[hint] end
        if t.zone and not t.container then zoneOfAch[t.id] = t.zone end
    end
    -- parts of a zone meta follow the meta
    local meta = MetaZones(zoneOfAch)
    for _, t in ipairs(todo) do
        placed[t.id] = true
        if ns.OTHER_GROUPS and ns.OTHER_GROUPS[t.group] then
            local z = home(t.id)
            AddItem(z, "other", { key = "a:" .. z.key .. ":" .. t.id, kind = "ach", id = t.id, group = t.group, spots = {} })
        elseif t.container then
            local child = Register({ key = "a:" .. t.container.key .. ":" .. t.id, kind = "ach", id = t.id,
                                     spots = {}, parent = t.container, group = t.group })
            table.insert(t.container.children, child)
        else
            local z = meta[t.id] or t.zone or SpotZone(t.id) or home(t.id)
            AddItem(z, "achv", { key = "a:" .. z.key .. ":" .. t.id, kind = "ach", id = t.id, group = t.group, spots = {} })
        end
    end
end

------------------------------------------------------------------------
-- build: reputation and collectibles
------------------------------------------------------------------------

-- One reputation item per faction listed for the zone.
local function BuildRep(zone)
    for _, fid in ipairs(zone.factions or {}) do
        AddItem(zone, "rep", { key = "r:" .. fid, kind = "rep", faction = fid, spots = {} })
    end
end

local collectSeen = {}      -- collect keys already built ("i<itemID>", "m<mountID>", ...)

-- Where an item is sold (Data/Vendors.lua): { npc, name, tag, cost, spots } per vendor, or nil.
local function VendorsFor(itemID)
    local list = itemID and ns.ITEM_VENDORS and ns.ITEM_VENDORS[itemID]
    if not list then return end
    local out = {}
    for _, v in ipairs(list) do
        local npc = ns.VENDOR_NPCS and ns.VENDOR_NPCS[v[1]]
        if npc then
            local spots = {}
            for _, at in ipairs(npc.at or {}) do spots[#spots + 1] = { map = at[1], x = at[2], y = at[3] } end
            out[#out + 1] = { npc = v[1], name = npc.n, tag = npc.tag, cost = v[2], spots = spots }
        end
    end
    if #out > 0 then return out end
end
ns.VendorsFor = VendorsFor

-- The zone a vendor stands in, if it is one of ours.
local function VendorZone(vendors)
    for _, v in ipairs(vendors or {}) do
        for _, sp in ipairs(v.spots) do
            local z = ZoneForMap(sp.map)
            if z and not z.overview then return z end
        end
    end
end

-- The zone of the first source spot, if it is one of ours.
local function SourceZone(itemID)
    local ds = itemID and ns.ITEM_SOURCES and ns.ITEM_SOURCES[itemID]
    for _, at in ipairs(ds and ds.at or {}) do
        local z = ZoneForMap(at[1])
        if z and not z.overview then return z end
    end
end

local mountItem   -- mountID -> item that teaches it (renown rewards only know the mount)

-- Adds a collectible once per key and fills in what it can: the item behind a renown mount, the
-- vendors, and spots to point at (the vendor first, then where it drops).
local function AddCollect(zone, key, it)
    if collectSeen[key] then return end
    collectSeen[key] = true
    it.key, it.kind = "c:" .. key, "collect"
    it.spots = it.spots or {}
    if it.mountID and not it.itemID then
        if not mountItem then
            mountItem = {}
            for _, item in ipairs(ns.MIDNIGHT_MOUNT_ITEMS or {}) do
                local ok, mid = pcall(C_MountJournal.GetMountFromItem, item)
                if ok and mid then mountItem[mid] = item end
            end
        end
        it.itemID = mountItem[it.mountID]
        if it.itemID then collectSeen["i" .. it.itemID] = true end
    end
    it.vendors = VendorsFor(it.itemID)
    -- nothing to point at yet: point at the vendor
    if #it.spots == 0 and it.vendors then
        for _, v in ipairs(it.vendors) do
            for _, sp in ipairs(v.spots) do it.spots[#it.spots + 1] = sp end
        end
    end
    -- still nothing: where it drops or starts (Data/Sources.lua)
    local ds = it.itemID and ns.ITEM_SOURCES and ns.ITEM_SOURCES[it.itemID]
    if ds and not it.source and not it.vendors then
        it.dropSource = ds
        if #it.spots == 0 then
            for _, at in ipairs(ds.at or {}) do it.spots[#it.spots + 1] = { map = at[1], x = at[2], y = at[3] } end
        end
    end
    AddItem(zone, "collect", it)
end

-- Own loot first, then the drop table the point shares with its group (marked shared = true).
local function LootOf(pointItem)
    local list = {}
    for _, l in ipairs(pointItem.loot or {}) do list[#list + 1] = { l[1], l[2] } end
    if pointItem.sl and ns.SHARED_LOOT[pointItem.sl] then
        for _, l in ipairs(ns.SHARED_LOOT[pointItem.sl]) do list[#list + 1] = { l[1], l[2], shared = true } end
    end
    return list
end

-- One-line source for loot from a point, e.g. "Drops from <rare>".
local function SourceText(it)
    if it.pkind == "rare" then return "Drops from " .. (it.name or "a rare") end
    if it.pkind == "boss" then return "World boss: " .. (it.name or "?") end
    if it.pkind == "delve" then return "Sturdy Chest" end
    return "Treasure: " .. (it.name or "?")
end

-- A collectible for each drop of a treasure, rare or chest, pointing at the same spots.
local function CollectFromPoint(zone, it)
    for _, l in ipairs(LootOf(it)) do
        AddCollect(zone, "i" .. l[1], { itemID = l[1], flag = l[2], source = it, sourceText = SourceText(it),
                                        spots = it.spots, shared = l.shared })
    end
end

-- A zone's collectibles: loot from its treasures, rares and delve chests, rewards from achievement
-- spots and vendors, then the renown rewards of its factions.
local function BuildCollect(zone)
    for _, secKey in ipairs({ "treasure", "rare" }) do
        for _, it in ipairs(zone.sections[secKey].items) do CollectFromPoint(zone, it) end
    end
    for _, d in ipairs(zone.sections.delve.items) do
        for _, c in ipairs(d.children) do if c.kind == "point" then CollectFromPoint(zone, c) end end
    end
    -- rewards handed out at achievement spots
    for _, p in ipairs(achvLoot) do
        if (ZoneForMap(p.m) or ns.midnight) == zone then
            local a = p.a and ns.Ach(p.a)
            local src = p.k == "vendor" and ("From " .. (p.n or "a vendor") .. (p.note and (": " .. p.note) or ""))
                or ("Reward: " .. (p.n or (a and a.name) or "achievement"))
            for _, l in ipairs(p.loot or {}) do
                AddCollect(zone, "i" .. l[1], { itemID = l[1], flag = l[2], sourceText = src,
                                                spots = p.x and { { map = p.m, x = p.x, y = p.y } } or {} })
            end
        end
    end
    -- renown rewards
    if not (C_MajorFactions and C_MajorFactions.GetRenownRewardsForLevel and C_MajorFactions.GetRenownLevels) then return end
    for _, fid in ipairs(zone.factions or {}) do
        local ok, levels = pcall(C_MajorFactions.GetRenownLevels, fid)
        local fname
        local okd, d = pcall(C_MajorFactions.GetMajorFactionData, fid)
        if okd and d then fname = d.name end
        if ok and type(levels) == "table" then
            for lvl = 1, #levels do
                local ok2, rewards = pcall(C_MajorFactions.GetRenownRewardsForLevel, fid, lvl)
                if ok2 and type(rewards) == "table" then
                    for _, r in ipairs(rewards) do
                        local src = string.format("Renown %d: %s", lvl, fname or ("faction " .. fid))
                        local base = { sourceText = src, renown = { faction = fid, level = lvl }, rname = r.name, icon = r.icon }
                        if r.mountID and r.mountID > 0 then
                            base.mountID = r.mountID; AddCollect(zone, "m" .. r.mountID, base)
                        elseif r.titleMaskID and r.titleMaskID > 0 then
                            base.titleID = r.titleMaskID; AddCollect(zone, "ti" .. r.titleMaskID, base)
                        elseif r.transmogSetID and r.transmogSetID > 0 then
                            base.setID = r.transmogSetID; AddCollect(zone, "s" .. r.transmogSetID, base)
                        elseif r.itemID and r.itemID > 0 then
                            base.itemID = r.itemID; AddCollect(zone, "i" .. r.itemID, base)
                        elseif r.transmogID and r.transmogID > 0 then
                            base.sourceID = r.transmogID; AddCollect(zone, "tm" .. r.transmogID, base)
                        end
                    end
                end
            end
        end
    end
end

-- Removes colour, texture and hyperlink codes, keeping the visible text of a link.
local function StripCodes(s)
    s = tostring(s or "")
    s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):gsub("|H.-|h", ""):gsub("|h", "")
    return s
end

-- Reads a journal source string. Returns the lines joined with "; ", the zone named on a "Zone:"
-- line, true when the source is out of scope, and the dungeon, raid or delve item it names.
local function SourceInfo(raw)
    local lines = {}
    for rawLine in (tostring(raw or "") .. "|n"):gmatch("(.-)|n") do
        local line = StripCodes(rawLine):gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" then lines[#lines + 1] = line end
    end
    local text = table.concat(lines, "; ")
    local inst
    for _, pat in ipairs(ns.COLLECT_EXCLUDE or {}) do
        if text:find(pat) then return text, nil, true end
    end
    -- follow Options > What counts
    if not ns.Counts("PvP") and (text:find("PvP") or text:find("Gladiator") or text:find("Rated")) then return text, nil, true end
    if not ns.Counts("World Events") and text:find("World Event") then return text, nil, true end
    if not ns.db.settings.hardmodes and text:find("Mythic") then return text, nil, true end
    local zone
    for _, line in ipairs(lines) do
        local zname = line:match("^Zone:%s*(.+)$")
        if zname then
            local n = norm(zname)
            -- a dungeon, raid or delve belongs to the zone its entrance is in
            for iname, z in pairs(instanceZone) do
                if n:find(iname, 1, true) and not z.overview then zone = zone or z; inst = inst or instanceItem[iname] end
            end
            for _, z in ipairs(ns.ZONES) do
                if not z.overview then
                    if n:find(norm(z.name), 1, true) then zone = z end
                    for _, kw in ipairs(z.keywords or {}) do
                        if #norm(kw) >= 5 and n:find(norm(kw), 1, true) then zone = zone or z end
                    end
                end
            end
        end
    end
    return text, zone, false, inst
end

-- A reward from an achievement that does not count (M+, rated PvP, hard modes, the ones left out of
-- Data/Achievements.lua) does not count either.
local achGroup              -- achievementID -> group name, built on first use
local function RewardOutOfScope(itemID)
    local ds = itemID and ns.ITEM_SOURCES and ns.ITEM_SOURCES[itemID]
    if not (ds and ds.a) then return false end
    if not achGroup then
        achGroup = {}
        for _, g in ipairs(ns.ACH_GROUPS or {}) do
            for _, id in ipairs(g[2]) do achGroup[id] = g[1] end
        end
    end
    local group = achGroup[ds.a]
    if not group or not ns.Counts(group) then return true end
    return ns.IsHard(ds.t and ds.t:match("achievement (.+)$"))
end

-- Each expansion's mounts, pets and toys (Data/Collections.lua, Data/TWW/Collections.lua) that no zone source
-- claimed yet. Each goes to the zone its journal source names, else where it is sold or drops, else its
-- expansion's overview page.
local function BuildJournalCollect(midnight)
    local mySide = UnitFactionGroup and UnitFactionGroup("player")
    local sets = { { exp = "midnight", name = "Midnight", mounts = ns.MIDNIGHT_MOUNT_ITEMS, pets = ns.MIDNIGHT_PET_ITEMS,
                     toys = ns.MIDNIGHT_TOY_ITEMS } }
    for _, set in ipairs(ns.COLLECT_SETS or {}) do sets[#sets + 1] = set end
    for _, set in ipairs(sets) do
        local home = ns.overviews[set.exp] or midnight
        -- extraKey is the same collectible under another key (a mount by mount ID)
        local function add(zone, key, extraKey, it)
            if collectSeen[key] or (extraKey and collectSeen[extraKey]) then return end
            if RewardOutOfScope(it.itemID) then return end
            if extraKey then collectSeen[extraKey] = true end
            -- a zone of another expansion named in the source text doesn't count: stay in this expansion
            if zone and zone.exp ~= set.exp then zone = nil end
            AddCollect(zone or VendorZone(VendorsFor(it.itemID)) or SourceZone(it.itemID) or home, key, it)
        end
        if C_MountJournal and C_MountJournal.GetMountFromItem then
            for _, itemID in ipairs(set.mounts or {}) do
                local ok, mid = pcall(C_MountJournal.GetMountFromItem, itemID)
                if ok and mid then
                    local r = { pcall(C_MountJournal.GetMountInfoByID, mid) }
                    local name, factionSpecific, faction, hide = r[2], r[9], r[10], r[11]
                    local wrongSide = factionSpecific and mySide and ((faction == 0 and mySide ~= "Horde") or (faction == 1 and mySide ~= "Alliance"))
                    if r[1] and name and not hide and not wrongSide then
                        local okx, _, _, source = pcall(C_MountJournal.GetMountInfoExtraByID, mid)
                        local text, zone, excluded, inst = SourceInfo(okx and source)
                        if not excluded then
                            add(zone, "i" .. itemID, "m" .. mid, { itemID = itemID, flag = "m", sourceText = text,
                                                                  spots = inst and { unpack(inst.spots) }, instance = inst })
                        end
                    end
                end
            end
        end
        if C_PetJournal and C_PetJournal.GetPetInfoByItemID then
            for _, itemID in ipairs(set.pets or {}) do
                local r = { pcall(C_PetJournal.GetPetInfoByItemID, itemID) }
                if r[1] and r[2] and r[12] ~= false then
                    local text, zone, excluded, inst = SourceInfo(r[6])
                    if not excluded then
                        add(zone, "i" .. itemID, nil, { itemID = itemID, flag = "p", sourceText = text, spots = inst and { unpack(inst.spots) }, instance = inst })
                    end
                end
            end
        end
        for _, itemID in ipairs(set.toys or {}) do
            add(nil, "i" .. itemID, nil, { itemID = itemID, flag = "t", sourceText = "Toy added in " .. set.name })
        end
    end
end

------------------------------------------------------------------------
-- build
------------------------------------------------------------------------

-- Rebuilds every zone page from the data files and the live client. Progress is read separately,
-- by ns.EvaluateAll.
function ns.Build()
    ns.items = {}
    achvPoints, achvByCrit, groupAchs, delveChests, chestAchs, loreIDs, loreZone, keywordTargets, collectSeen = {}, {}, {}, {}, {}, {}, {}, {}, {}
    placedInstance = {}
    instanceZone, instanceItem = {}, {}
    mountItem = nil
    achvLoot = {}
    ns.achvByCrit = achvByCrit
    -- achievement spots by name too, for criteria whose ID the data doesn't know
    ns.achvByName = {}
    for aid, pts in pairs(achvPoints) do
        ns.achvByName[aid] = {}
        for _, p in ipairs(pts) do if p.n then ns.achvByName[aid][norm(p.n)] = p end end
    end
    local midnight
    ns.overviews = {}
    for _, z in ipairs(ns.ZONES) do
        z.exp = z.exp or "midnight"
        ns.zoneByKey[z.key] = z
        z.sections = {}
        for _, s in ipairs(ns.SECTIONS) do z.sections[s.key] = { key = s.key, name = s.name, items = {}, cur = 0, max = 0 } end
        for _, m in ipairs(z.maps or {}) do ns.zoneByMap[m] = z end
        if z.overview then ns.overviews[z.exp] = z end
    end
    midnight = ns.overviews.midnight
    ns.midnight = midnight
    ns.Bump()
    BuildPoints(midnight)
    for _, z in ipairs(ns.ZONES) do
        BuildLore(z, "story", z.story)
        BuildLore(z, "side", z.side)
        if not z.overview then BuildInstances(z); BuildDelves(z) end
    end
    EnsureDelves()
    AttachDelveChests(midnight)
    AttachDelveAchievements()
    BuildAchievements(midnight)
    for _, z in ipairs(ns.ZONES) do BuildRep(z); BuildCollect(z) end
    BuildJournalCollect(midnight)
    -- collectibles rewarded by an achievement follow that achievement's walkthrough
    local achByName, achById = {}, {}
    for _, z in ipairs(ns.ZONES) do
        for _, sdef in ipairs(ns.SECTIONS) do
            for _, it in ipairs(z.sections[sdef.key].items) do
                local cands = { it }
                if it.kind == "container" then for _, ch in ipairs(it.children) do cands[#cands + 1] = ch end end
                for _, c in ipairs(cands) do
                    if c.kind == "ach" then
                        local a = ns.Ach(c.id)
                        if a and a.name then achByName[norm(a.name)] = achByName[norm(a.name)] or c end
                        achById[c.id] = achById[c.id] or c
                    end
                end
            end
        end
    end
    for _, z in ipairs(ns.ZONES) do
        for _, it in ipairs(z.sections.collect.items) do
            local an = it.sourceText and it.sourceText:match("Achievement:%s*([^;]+)")
            if an then it.viaAch = achByName[norm(an)] end
            if not it.viaAch and it.dropSource and it.dropSource.a then it.viaAch = achById[it.dropSource.a] end
        end
    end
    -- the Seasonal book's holiday pages (Seasonal.lua)
    if ns.BuildEvents then ns.BuildEvents() end
    ns.built = true
    ns.buildStamp = (ns.buildStamp or 0) + 1
    ns.firstEval = true
    -- no announcements for 20 seconds while the client fills in its data
    ns.quietUntil = (GetTime and GetTime() or 0) + 20
end

------------------------------------------------------------------------
-- evaluate
------------------------------------------------------------------------

local Eval                  -- defined below; containers call it for their children

-- Done when its criterion, quest or whole achievement is. Rares and bosses use a quest that only
-- tracks the kill. Knowledge spots for a profession the character lacks are hidden.
local function EvalPoint(it)
    if it.prof and not ns.HasProf(it.prof) then it.max, it.cur, it.done, it.hidden = 0, 0, false, true; return end
    it.hidden = nil
    local done = false
    if it.a and it.c then
        local cr = ns.Crit(it.a, it.c)
        if cr and cr.done then done = true end
        if cr and not it.name and cr.name and cr.name ~= "" then it.name = cr.name end
    end
    if not done and it.fish and it.a and it.name then
        local c = ns.Crits(it.a)
        local cr = c and c.byName[norm(it.name)]
        if cr and cr.done then done = true end
    end
    if not done and it.q then
        if it.pkind == "rare" or it.pkind == "boss" then done = ns.SeenQuest(it.q) else done = ns.QuestDone(it.q) end
    end
    if not done and it.a and it.c and ns.AchDone(it.a) then done = true end
    it.done, it.max, it.cur = done, 1, done and 1 or 0
end

-- Done by the live criterion, its quest or sub-achievement, or the whole achievement. With a chain,
-- sub counts quests done up to c.pos (where the criterion quest sits), or the whole chain.
local function EvalLore(it)
    local c = it.crit
    local done = ns.AchDone(it.ach)
    if not done and c.id then
        local cr = ns.Crit(it.ach, c.id)
        if cr then done = cr.done; it.liveName = cr.name end
    end
    if not done and c.t == 27 and c.q and ns.QuestDone(c.q) then done = true end
    if not done and c.t == 8 and c.q and ns.AchDone(c.q) then done = true end
    it.done, it.max, it.cur = done, 1, done and 1 or 0
    if c.chain then
        local n = 0
        local limit = (c.pos and c.pos > 0) and math.min(c.pos, #c.chain) or #c.chain
        for i = 1, limit do if ns.QuestDone(c.chain[i][1]) then n = n + 1 end end
        it.sub = done and "" or string.format("%d/%d", n, limit)
    end
end

-- True when a criterion belongs to this item: every criterion for a whole achievement, only the zone's own
-- (matched by criterion ID or by name) for one zone's part of a split achievement.
function ns.InPart(it, e)
    if not it.filter and not it.filterNames then return true end
    return (e.id and it.filter and it.filter[e.id]) or (e.name and it.filterNames and it.filterNames[norm(e.name)]) or false
end

-- Counts as one unit. A split achievement (spots in several zones) is done on a page once that page's
-- criteria are; sub shows criteria progress, or the quantity for a single counted criterion.
local function EvalAch(it)
    -- a momentary "unknown" from the client keeps the last answer instead of hiding the row
    local a = ns.Ach(it.id) or it.lastAch
    it.lastAch = a
    if not a then it.max, it.cur, it.done, it.hidden = 0, 0, false, true; return end
    it.hidden = nil
    it.name = a.name
    local c = ns.Crits(it.id)
    local total, got = 0, 0
    for _, e in ipairs(c.list) do
        if ns.InPart(it, e) then
            total = total + 1
            if e.done or a.done then got = got + 1 end
        end
    end
    local done
    if it.split then done = a.done or (total > 0 and got >= total) else done = a.done end
    it.done, it.max, it.cur = done, 1, done and 1 or 0
    if total == 1 and c.list[1] and c.list[1].req and c.list[1].req > 1 and not done then
        it.sub = string.format("%d/%d", c.list[1].qty or 0, c.list[1].req)
    elseif total > 1 then
        it.sub = string.format("%d/%d", got, total)
    else
        it.sub = nil
    end
end

-- Evaluates the children and adds up their units; sub says "nothing to count" when none count.
local function EvalContainer(it)
    local cur, max = 0, 0
    for _, ch in ipairs(it.children) do
        Eval(ch)
        cur, max = cur + (ch.cur or 0), max + (ch.max or 0)
    end
    it.cur, it.max = cur, max
    it.done = max > 0 and cur >= max
    it.sub = max > 0 and string.format("%d/%d", cur, max) or "nothing to count"
end

-- Done when ns.Rep says the faction is maxed; sub is its standing text. Hidden if the client has no data.
local function EvalRep(it)
    local r = ns.Rep(it.faction) or it.lastRep
    it.lastRep = r
    if not r then it.max, it.cur, it.done, it.hidden = 0, 0, false, true; return end
    it.hidden = nil
    it.name, it.rep = r.name, r
    it.done, it.max, it.cur = r.done, 1, r.done and 1 or 0
    it.sub = r.text
end

-- Display names for the collectible types ns.ItemCollect and friends return.
local TYPE_LABEL = { mount = "Mount", pet = "Pet", toy = "Toy", decor = "Decor", appearance = "Appearance",
                     title = "Title", set = "Set" }
ns.TYPE_LABEL = TYPE_LABEL

-- Owned or not. A nil type means data is still loading (not counted yet), false means it is not a
-- collectible (hidden); when ownership can't be read it is shown but not counted.
local function EvalCollect(it)
    local t, owned, name
    if it.itemID then
        t, owned = ns.ItemCollect(it.itemID, it.flag)
        name = ns.ItemName(it.itemID)
    elseif it.mountID then t, owned, name = ns.MountCollect(it.mountID)
    elseif it.titleID then t, owned = ns.TitleCollect(it.titleID)
    elseif it.setID then t, owned, name = ns.SetCollect(it.setID)
    elseif it.sourceID then t, owned, name = ns.SourceCollect(it.sourceID) end
    -- the client drops and reloads collection data all the time; a known collectible keeps its last
    -- definite answer while the data is away, so counts and rows don't jump on every refresh
    if t == nil and it.lastType then t = it.lastType end
    if t then it.lastType = t end
    if owned == true then it.everOwned = true end
    if it.everOwned then owned = true
    elseif owned == nil and it.lastOwned ~= nil then owned = it.lastOwned end
    if owned ~= nil then it.lastOwned = owned end
    it.ctype = t
    if t == nil then ns.collectLoading = (ns.collectLoading or 0) + 1 end
    -- the real name wins over a renown screen's label once it's been seen, and stays
    if name then it.realName = name end
    it.name = it.realName or it.rname or it.name or (t == nil and "Loading..." or "?")
    if not t then it.max, it.cur, it.done, it.hidden = 0, 0, false, (t == false); return end
    it.hidden = nil
    if owned == nil then
        it.max, it.cur, it.done, it.sub = 0, 0, false, (TYPE_LABEL[t] or "item") .. ", can't tell"
        return
    end
    it.done, it.max, it.cur = owned, 1, owned and 1 or 0
    it.sub = TYPE_LABEL[t]
end

-- Sets cur, max, done and sub on one item, by kind.
Eval = function(it)
    local k = it.kind
    if k == "point" then EvalPoint(it)
    elseif k == "lore" then EvalLore(it)
    elseif k == "ach" then EvalAch(it)
    elseif k == "container" then EvalContainer(it)
    elseif k == "rep" then EvalRep(it)
    elseif k == "collect" then EvalCollect(it) end
end
ns.Eval = Eval

local prevDone = {}         -- item key -> done at the last evaluation

-- Whether a flip to done is something the player just did, not the client finishing a lazy load
-- (decor ownership and item data arrive seconds after login and would read as "just collected").
ns.lastGainEvent = 0        -- GetTime() of the last loot or new-collectible event (set in Main.lua)
function ns.Announceable(it)
    local now = GetTime and GetTime() or 0
    if now < (ns.quietUntil or 0) then return false end
    if it.kind == "collect" then return now - (ns.lastGainEvent or 0) <= 15 end
    return true
end

-- Log line for a newly finished item, e.g. "Treasure: <name>".
local function Label(it)
    local sec = it.sec or (it.parent and it.parent.sec)
    local pre = ({ treasure = "Treasure", rare = "Rare", story = "Storyline", side = "Side quest", achv = "Achievement",
                   collect = "Collected", instance = "Dungeon", delve = "Delve", rep = "Reputation", prof = "Knowledge" })[sec or ""]
    if it.kind == "rep" then return "Maxed " .. (it.name or "reputation") end
    return (pre and (pre .. ": ") or "") .. (it.name or "?")
end

-- Re-reads everything. Returns the items that just flipped to done (empty on the first pass).
function ns.EvaluateAll()
    if not ns.built then return {} end
    ns.Bump()
    local newly = {}
    local first = ns.firstEval
    ns.collectLoading = 0   -- collectibles still waiting for item data (counted by EvalCollect)
    local totals = {}
    for _, z in ipairs(ns.ZONES) do
        z.cur, z.max = 0, 0
        for _, s in ipairs(ns.SECTIONS) do
            local sec = z.sections[s.key]
            sec.cur, sec.max = 0, 0
            for _, it in ipairs(sec.items) do
                Eval(it)
                sec.cur, sec.max = sec.cur + (it.cur or 0), sec.max + (it.max or 0)
                if s.uncounted then it.uncounted = true end
                local watch = { it }
                if it.kind == "container" then watch = it.children end
                for _, w in ipairs(watch) do
                    if (w.max or 0) > 0 then
                        if w.done and prevDone[w.key] == false and not first and ns.Announceable(w) then
                            newly[#newly + 1] = w
                            ns.Log(z.key, Label(w))
                        end
                        prevDone[w.key] = w.done and true or false
                    end
                end
            end
            -- Other is shown with its own count but stays out of the zone and expansion totals
            if not s.uncounted then z.cur, z.max = z.cur + sec.cur, z.max + sec.max end
        end
        local t = totals[z.exp] or { cur = 0, max = 0 }
        totals[z.exp] = t
        t.cur, t.max = t.cur + z.cur, t.max + z.max
    end
    -- holiday pages count on their own, never toward Midnight
    if ns.EvaluateEvents then ns.EvaluateEvents(newly, first, prevDone) end
    -- keep the Midnight page's own counts; its headline is the whole expansion (see ZoneTotals)
    for _, ov in pairs(ns.overviews or {}) do ov.ownCur, ov.ownMax = ov.cur, ov.max end
    ns.totals = totals
    ns.total = totals.midnight or { cur = 0, max = 0 }
    ns.firstEval = false
    return newly
end

-- Whole percent, rounded down (the epsilon absorbs float error); 0 when max is 0 or nil.
function ns.Pct(cur, max)
    if not max or max == 0 then return 0 end
    return math.floor(cur / max * 100 + 0.0001)
end

-- Headline cur, max for a zone page; an expansion's overview page shows the whole expansion.
function ns.ZoneTotals(z)
    local t = z.overview and ns.totals and ns.totals[z.exp]
    if t then return t.cur, t.max end
    return z.cur or 0, z.max or 0
end
