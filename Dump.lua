-- Completion: a research tool for the authors. /comp dump reads everything the game can tell us and saves it in the
-- saved variables (CompletionDB.dump), so the book's data can be checked against the game itself:
--   achievements (with criteria, series steps and where the book shows each), mounts, battle pet species, toys,
--   appearance sets (with pieces collected), heirlooms, weapon illusions, titles, currencies, reputations and renown
--   rewards, every map in the game (child maps, dungeon entrances, flight points, map markers, quest lines),
--   campaigns and their chapters, the Adventure Guide (every instance and boss), and quests (every completed one,
--   quest lines, the book's own, and every quest title from ID 1 to 99999), for every expansion since Classic.
-- Each section is a list of tab-separated lines; dump.columns names the columns of each section.
-- It reads only: no setting, filter or CVar is changed (the Adventure Guide's selected tier is put back afterwards).
-- The work is spread over many frames and takes about half an hour (mostly quest titles); chat shows each step. /comp dump clear removes it.

local _, ns = ...

local running = false
local PREFIX = "|cffe6c35cCompletion|r: "
local QUEST_RANGE = { 1, 99999 }       -- every quest ID from Classic to Midnight
local ASK_PER_FRAME = 8                  -- quest title requests per frame, gentle on the server

local COLUMNS = {
    cats = "categoryID, parentID, name",
    ach = "achievementID, categoryID, points, flags, done, book, name, criteria (type:asset:required:criteriaID:done:name, joined by |)",
    mounts = "mountID, spellID, name, sourceType, collected, faction, hiddenForCharacter, bookItem, source",
    pets = "speciesID, name, petType, creatureID, canBattle, obtainable, owned, bookItem, source",
    toys = "itemID, name, owned, inBook",
    sets = "setID, name, label, expansionID, classMask, collected, piecesOwned, piecesTotal, description, faction",
    heirlooms = "itemID, name, owned, source",
    illusions = "visualID, sourceID, name, owned",
    titles = "titleID, name, known",
    currencies = "currencyID, name, quantity, max, discovered",
    factions = "factionID, name, standing, current, max, isHeader, parentFactionID, isMajorFaction",
    renown = "factionID, name, renownLevel, maxLevel, unlocked, rewards per level (level=name;name, joined by |)",
    maps = "mapID, name, mapType, parentMapID, expansion",
    entrances = "mapID, journalInstanceID, name, x, y",
    taxi = "mapID, nodeID, name, x, y, state",
    pois = "mapID, areaPoiID, name, x, y, description",
    questlines = "mapID, questLineID, name, quests (id, joined by ,)",
    campaigns = "campaignID, name, chapters (chapterID=name, joined by |)",
    journal = "tier, journalInstanceID, name, isRaid, mapID, bosses (encounterID=name, joined by |)",
    quests = "questID, title, completed, source",
    unmatched = "itemID, name, itemClass, itemSubClass (book items that aren't a mount, pet or toy)",
}

-- Text without the game's colour and texture codes, tabs or line breaks.
local function Clean(t)
    t = tostring(t or "")
    t = t:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):gsub("|A.-|a", ""):gsub("|n", " ")
    t = t:gsub("[|\t\r\n]", " ")
    return t
end

-- A tab-separated line from the given values.
local function Line(...)
    local n = select("#", ...)
    local parts = {}
    for i = 1, n do parts[i] = Clean((select(i, ...))) end
    return table.concat(parts, "\t")
end

-- Calls f safely; returns its results or nothing.
local function Try(f, ...)
    if not f then return end
    local r = { pcall(f, ...) }
    if r[1] then return unpack(r, 2) end
end

------------------------------------------------------------------------
-- what the book shows
------------------------------------------------------------------------

local shown
-- Achievements the book shows as storylines (lore rows) or treasure and rare section headings.
local function Shown()
    if shown then return shown end
    shown = {}
    for _, it in pairs(ns.items or {}) do
        local key = it.zone and it.zone.key or "?"
        if it.kind == "lore" and it.ach then shown[it.ach] = shown[it.ach] or key .. ":story" end
        if it.groupAch then shown[it.groupAch] = shown[it.groupAch] or key .. ":heading" end
    end
    return shown
end

-- Where the book shows an achievement: a zone key, or "" when it isn't in the book.
local function InBook(id)
    local it = ns.AchItem and ns.AchItem(id)
    if it then return (it.zone and it.zone.key) or "?" end
    if Shown()[id] then return Shown()[id] end
    local p = ns.ACH_PLACE and ns.ACH_PLACE[id]
    if p then return "placed:" .. tostring(p[1]) end
    return ""
end

-- Every collectible item the book lists: its item lists, every expansion's sets, collectibles, holiday items,
-- and items on its rows (rare and treasure loot included).
local function BookItems()
    local items = {}
    local function add(list) for _, id in ipairs(list or {}) do items[id] = true end end
    add(ns.MIDNIGHT_MOUNT_ITEMS); add(ns.MIDNIGHT_PET_ITEMS); add(ns.MIDNIGHT_TOY_ITEMS)
    for _, set in ipairs(ns.COLLECT_SETS or {}) do add(set.mounts); add(set.pets); add(set.toys) end
    for id in pairs(ns.COLLECT_INFO or {}) do items[id] = true end
    for _, list in pairs(ns.EVENT_ITEMS or {}) do for _, e in ipairs(list) do if e.i then items[e.i] = true end end end
    for _, it in pairs(ns.items or {}) do
        if it.itemID then items[it.itemID] = true end
        for _, l in ipairs(it.loot or {}) do if l[1] then items[l[1]] = true end end
    end
    return items
end

-- The mount IDs and pet species of the book's items (needs the items loaded first).
local function BookCollect(items)
    local mounts, species = {}, {}
    for id in pairs(items) do
        local m = C_MountJournal and Try(C_MountJournal.GetMountFromItem, id)
        -- second way: the item's spell, then the mount that spell teaches
        if not m and C_Item and C_Item.GetItemSpell and C_MountJournal.GetMountFromSpell then
            local _, spell = Try(C_Item.GetItemSpell, id)
            if spell then m = Try(C_MountJournal.GetMountFromSpell, spell) end
        end
        if m then mounts[m] = id end
        if C_PetJournal and C_PetJournal.GetPetInfoByItemID then
            local r = { pcall(C_PetJournal.GetPetInfoByItemID, id) }
            if r[1] and r[14] then species[r[14]] = id end
        end
    end
    return mounts, species
end

-- The book's items that are neither a known mount, pet nor toy (for checking the matching itself).
local function Unmatched(items, mounts, species)
    local isMount, isPet, out = {}, {}, {}
    for _, id in pairs(mounts) do isMount[id] = true end
    for _, id in pairs(species) do isPet[id] = true end
    for id in pairs(items) do
        local toy = C_ToyBox and Try(C_ToyBox.GetToyInfo, id)
        if not (isMount[id] or isPet[id] or toy) then
            local name, _, _, _, _, class, sub = Try(C_Item.GetItemInfo, id)
            out[#out + 1] = Line(id, name or "", class or "", sub or "")
        end
    end
    table.sort(out)
    return out
end

-- Every quest ID the book's data knows.
local function BookQuests()
    local q = {}
    for id in pairs(ns.QUEST_STARTS or {}) do q[id] = true end
    for id in pairs(ns.QUEST_NOTES or {}) do q[id] = true end
    for _, it in pairs(ns.items or {}) do
        if type(it.q) == "number" then q[it.q] = true end
        if type(it.quest) == "number" then q[it.quest] = true end
    end
    return q
end

------------------------------------------------------------------------
-- the job runner: each step is called every frame until it returns true
------------------------------------------------------------------------

local function Run(steps, done)
    local i, t0 = 1, GetTime()
    local f = CreateFrame("Frame")
    f:SetScript("OnUpdate", function(self)
        local step = steps[i]
        if not step then self:SetScript("OnUpdate", nil); done(GetTime() - t0); return end
        if not step.started then
            step.started = true
            print(PREFIX .. string.format("step %d/%d: %s...", i, #steps, step.name))
        end
        local ok, finished = pcall(step.run, step)
        if not ok then print(PREFIX .. "  " .. step.name .. " stopped: " .. tostring(finished)); finished = true end
        if finished then i = i + 1 end
    end)
end

------------------------------------------------------------------------
-- the steps
------------------------------------------------------------------------

local function Start(onlyCollect)
    if running then print(PREFIX .. "the read is already running."); return end
    running = true
    shown = nil
    local out = {
        built = date("%Y-%m-%d %H:%M"),
        version = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("Completion", "Version")) or "?",
        build = select(2, GetBuildInfo()) or "?",
        character = string.format("%s-%s %s %s %s level %s", UnitName("player") or "?", GetRealmName() or "?",
            select(2, UnitRace("player")) or "?", select(2, UnitClass("player")) or "?", UnitFactionGroup("player") or "?", UnitLevel("player") or "?"),
        columns = COLUMNS,
    }
    for k in pairs(COLUMNS) do out[k] = {} end
    local items = BookItems()
    local bookMounts, bookSpecies = {}, {}
    local mapIDs, mapSet = {}, {}
    local questSeen = {}
    local function addQuest(id, source) if id and not questSeen[id] then questSeen[id] = source end end

    local steps = {}
    local COLLECT_STEPS = { ["loading the book's items"] = true, ["mounts, sets, heirlooms, illusions, titles"] = true,
        ["battle pet species"] = true, ["toys"] = true }
    local function step(name, run)
        if onlyCollect and not COLLECT_STEPS[name] then return end
        steps[#steps + 1] = { name = name, run = run }
    end

    -- the book's items must be loaded before the game can tell which mount or pet each one teaches
    step("loading the book's items", function(s)
        if not s.list then
            s.list, s.i = {}, 0
            for id in pairs(items) do s.list[#s.list + 1] = id end
            print(PREFIX .. string.format("  %d items", #s.list))
        end
        for _ = 1, 30 do
            s.i = s.i + 1
            local id = s.list[s.i]
            if not id then
                s.wait = s.wait or (GetTime() + 30)
                if GetTime() < s.wait then return false end
                bookMounts, bookSpecies = BookCollect(items)
                out.unmatched = Unmatched(items, bookMounts, bookSpecies)
                return true
            end
            if C_Item and C_Item.RequestLoadItemDataByID then pcall(C_Item.RequestLoadItemDataByID, id) end
        end
    end)

    -- achievements, a few categories per frame, each series walked both ways
    step("achievements", function(s)
        if not s.cats then
            s.cats, s.i, s.seen = GetCategoryList() or {}, 0, {}
            for _, cat in ipairs(s.cats) do
                local title, parent = Try(GetCategoryInfo, cat)
                out.cats[#out.cats + 1] = Line(cat, parent or "", title or "?")
            end
        end
        for _ = 1, 3 do
            s.i = s.i + 1
            local cat = s.cats[s.i]
            if not cat then return true end
            local n = Try(GetCategoryNumAchievements, cat, true) or 0
            for k = 1, n do
                local id = Try(GetAchievementInfo, cat, k)
                if id then
                    local chain = { id }
                    local p = GetPreviousAchievement and GetPreviousAchievement(id)
                    while p and not s.seen[p] and #chain < 30 do table.insert(chain, 1, p); p = GetPreviousAchievement(p) end
                    local nx = GetNextAchievement and GetNextAchievement(id)
                    while nx and not s.seen[nx] and #chain < 60 do chain[#chain + 1] = nx; nx = GetNextAchievement(nx) end
                    for _, cid in ipairs(chain) do
                        if not s.seen[cid] then
                            s.seen[cid] = true
                            local _, name, points, completed, _, _, _, _, flags = Try(GetAchievementInfo, cid)
                            if name then
                                local crit = {}
                                for c = 1, (Try(GetAchievementNumCriteria, cid) or 0) do
                                    local cname, ctype, cdone, _, req, _, _, asset, _, critID = Try(GetAchievementCriteriaInfo, cid, c)
                                    crit[#crit + 1] = table.concat({ tostring(ctype), tostring(asset), tostring(req), tostring(critID), cdone and "1" or "0", Clean(cname) }, ":")
                                end
                                out.ach[#out.ach + 1] = Line(cid, cat, points or 0, flags or 0, completed and 1 or 0, InBook(cid), name) .. "\t" .. table.concat(crit, "|")
                            end
                        end
                    end
                end
            end
        end
    end)

    -- collections that come as one list
    step("mounts, sets, heirlooms, illusions, titles", function()
        for _, mid in ipairs(C_MountJournal and C_MountJournal.GetMountIDs() or {}) do
            local name, spell, _, _, _, sourceType, _, factionSpecific, faction, hide, collected = Try(C_MountJournal.GetMountInfoByID, mid)
            if name then
                local _, _, source = Try(C_MountJournal.GetMountInfoExtraByID, mid)
                out.mounts[#out.mounts + 1] = Line(mid, spell or 0, name, sourceType or 0, collected and 1 or 0,
                    factionSpecific and tostring(faction) or "", hide and 1 or 0, bookMounts[mid] or "", source)
            end
        end
        for _, set in ipairs(C_TransmogSets and Try(C_TransmogSets.GetAllSets) or {}) do
            local have, total = 0, 0
            for _, a in ipairs(Try(C_TransmogSets.GetSetPrimaryAppearances, set.setID) or {}) do
                total = total + 1
                if a.collected then have = have + 1 end
            end
            out.sets[#out.sets + 1] = Line(set.setID, set.name, set.label, set.expansionID or "", set.classMask or 0,
                set.collected and 1 or 0, have, total, set.description, set.requiredFaction or "")
        end
        for _, id in ipairs(C_Heirloom and Try(C_Heirloom.GetHeirloomItemIDs) or {}) do
            local name, _, _, _, _, source = Try(C_Heirloom.GetHeirloomInfo, id)
            out.heirlooms[#out.heirlooms + 1] = Line(id, name, (Try(C_Heirloom.PlayerHasHeirloom, id)) and 1 or 0, source)
        end
        for _, ill in ipairs(C_TransmogCollection and Try(C_TransmogCollection.GetIllusions) or {}) do
            local name = Try(C_TransmogCollection.GetIllusionStrings, ill.sourceID)
            out.illusions[#out.illusions + 1] = Line(ill.visualID, ill.sourceID, name or "", ill.isCollected and 1 or 0)
        end
        for t = 1, (GetNumTitles and GetNumTitles() or 0) do
            local name = Try(GetTitleName, t)
            if name then out.titles[#out.titles + 1] = Line(t, name, (Try(IsTitleKnown, t)) and 1 or 0) end
        end
        return true
    end)

    -- pets by species ID
    step("battle pet species", function(s)
        s.n = s.n or 0
        for _ = 1, 150 do
            s.n = s.n + 1
            if s.n > 6000 then return true end
            local r = { pcall(C_PetJournal.GetPetInfoBySpeciesID, s.n) }
            if r[1] and r[2] then
                local owned = Try(C_PetJournal.GetNumCollectedInfo, s.n) or 0
                out.pets[#out.pets + 1] = Line(s.n, r[2], r[4] or 0, r[5] or 0, r[9] and 1 or 0, r[12] and 1 or 0, owned, bookSpecies[s.n] or "", r[6])
            end
        end
    end)

    -- toys by item ID
    step("toys", function(s)
        s.n = s.n or 0
        for _ = 1, 2500 do
            s.n = s.n + 1
            if s.n > 300000 then return true end
            local id, name = Try(C_ToyBox.GetToyInfo, s.n)
            if id then out.toys[#out.toys + 1] = Line(s.n, name, (PlayerHasToy and PlayerHasToy(s.n)) and 1 or 0, items[s.n] and 1 or 0) end
        end
    end)

    -- currencies and reputations by ID
    step("currencies and reputations", function(s)
        s.n = s.n or 0
        for _ = 1, 200 do
            s.n = s.n + 1
            if s.n > 4000 then return true end
            local c = C_CurrencyInfo and Try(C_CurrencyInfo.GetCurrencyInfo, s.n)
            if c and c.name and c.name ~= "" then
                out.currencies[#out.currencies + 1] = Line(s.n, c.name, c.quantity or 0, c.maxQuantity or 0, c.discovered and 1 or 0)
            end
            local fd = C_Reputation and Try(C_Reputation.GetFactionDataByID, s.n)
            if fd and fd.name and fd.name ~= "" then
                local major = C_Reputation.IsMajorFaction and Try(C_Reputation.IsMajorFaction, s.n)
                out.factions[#out.factions + 1] = Line(s.n, fd.name, fd.reaction or "", (fd.currentStanding or 0) - (fd.currentReactionThreshold or 0),
                    (fd.nextReactionThreshold or 0) - (fd.currentReactionThreshold or 0), fd.isHeader and 1 or 0, "", major and 1 or 0)
            end
        end
    end)

    -- renown factions and their rewards, for every expansion that has them
    step("renown", function()
        local seen = {}
        for exp = 8, 12 do
            for _, fid in ipairs(C_MajorFactions and Try(C_MajorFactions.GetMajorFactionIDs, exp) or {}) do
                if not seen[fid] then
                    seen[fid] = true
                    local d = Try(C_MajorFactions.GetMajorFactionData, fid) or {}
                    local levels = Try(C_MajorFactions.GetRenownLevels, fid) or {}
                    local per = {}
                    for _, lv in ipairs(levels) do
                        local names = {}
                        for _, rw in ipairs(Try(C_MajorFactions.GetRenownRewardsForLevel, fid, lv.level) or {}) do
                            names[#names + 1] = Clean(rw.name or rw.description or (rw.itemID and ("item " .. rw.itemID)) or "?")
                        end
                        if #names > 0 then per[#per + 1] = lv.level .. "=" .. table.concat(names, ";") end
                    end
                    out.renown[#out.renown + 1] = Line(fid, d.name, d.renownLevel or 0, #levels, d.isUnlocked and 1 or 0) .. "\t" .. table.concat(per, "|")
                end
            end
        end
        return true
    end)

    -- maps: every map in the game, from the top of the map tree down, then the book's zones in case one isn't linked
    step("maps", function()
        local function addMap(id, exp)
            if not id or mapSet[id] then return end
            local info = Try(C_Map.GetMapInfo, id)
            if not info then return end
            mapSet[id] = true
            mapIDs[#mapIDs + 1] = id
            out.maps[#out.maps + 1] = Line(id, info.name, info.mapType or "", info.parentMapID or "", exp)
            for _, ch in ipairs(Try(C_Map.GetMapChildrenInfo, id, nil, true) or {}) do addMap(ch.mapID, exp) end
        end
        addMap(946, "")   -- the Cosmic map holds every world
        for _, z in ipairs(ns.ZONES or {}) do
            for _, m in ipairs(z.maps or { z.map }) do addMap(m, z.exp or "midnight") end
        end
        print(PREFIX .. string.format("  %d maps", #mapIDs))
        return true
    end)

    -- per map: dungeon entrances, flight points, map markers and quest lines (a few maps a frame)
    step("map details", function(s)
        s.i = s.i or 0
        for _ = 1, 4 do
            s.i = s.i + 1
            local m = mapIDs[s.i]
            if not m then return true end
            local function xy(p) if p then return string.format("%.2f", p.x * 100), string.format("%.2f", p.y * 100) end return "", "" end
            for _, e in ipairs(C_EncounterJournal and Try(C_EncounterJournal.GetDungeonEntrancesForMap, m) or {}) do
                local x, y = xy(e.position)
                out.entrances[#out.entrances + 1] = Line(m, e.journalInstanceID, e.name, x, y)
            end
            for _, n in ipairs(C_TaxiMap and Try(C_TaxiMap.GetTaxiNodesForMap, m) or {}) do
                local x, y = xy(n.position)
                out.taxi[#out.taxi + 1] = Line(m, n.nodeID, n.name, x, y, n.state or "")
            end
            for _, poi in ipairs(C_AreaPoiInfo and Try(C_AreaPoiInfo.GetAreaPOIForMap, m) or {}) do
                local info = Try(C_AreaPoiInfo.GetAreaPOIInfo, m, poi)
                if info then
                    local x, y = xy(info.position)
                    out.pois[#out.pois + 1] = Line(m, poi, info.name, x, y, info.description)
                end
            end
            if C_QuestLine then Try(C_QuestLine.RequestQuestLinesForMap, m) end
        end
    end)

    -- quest lines: asked for above; read them after a short wait so the server has answered
    step("quest lines", function(s)
        s.wait = s.wait or (GetTime() + 10)
        if GetTime() < s.wait then return false end
        for _, m in ipairs(mapIDs) do
            for _, ql in ipairs(C_QuestLine and Try(C_QuestLine.GetAvailableQuestLines, m) or {}) do
                local qs = Try(C_QuestLine.GetQuestLineQuests, ql.questLineID) or {}
                for _, q in ipairs(qs) do addQuest(q, "questline " .. ql.questLineID) end
                out.questlines[#out.questlines + 1] = Line(m, ql.questLineID, ql.questLineName, table.concat(qs, ","))
            end
        end
        return true
    end)

    -- campaigns and their chapters
    step("campaigns", function()
        for _, cid in ipairs(C_CampaignInfo and Try(C_CampaignInfo.GetAvailableCampaigns) or {}) do
            local info = Try(C_CampaignInfo.GetCampaignInfo, cid) or {}
            local chapters = {}
            for _, ch in ipairs(Try(C_CampaignInfo.GetChapterIDs, cid) or {}) do
                local ci = Try(C_CampaignInfo.GetCampaignChapterInfo, ch)
                chapters[#chapters + 1] = ch .. "=" .. Clean(ci and ci.name or "?")
            end
            out.campaigns[#out.campaigns + 1] = Line(cid, info.name) .. "\t" .. table.concat(chapters, "|")
        end
        return true
    end)

    -- the Adventure Guide: every tier's dungeons and raids with their bosses (one tier a frame)
    step("adventure guide", function(s)
        if not (EJ_GetNumTiers and EJ_SelectTier) then return true end
        if not s.tiers then s.tiers, s.t, s.saved = EJ_GetNumTiers(), 0, EJ_GetCurrentTier and EJ_GetCurrentTier() end
        s.t = s.t + 1
        if s.t > s.tiers then
            if s.saved then pcall(EJ_SelectTier, s.saved) end
            return true
        end
        pcall(EJ_SelectTier, s.t)
        local tierName = Try(EJ_GetTierInfo, s.t) or s.t
        for _, raid in ipairs({ false, true }) do
            local j = 1
            while j < 80 do
                local iid, name, _, _, _, _, _, mapID = Try(EJ_GetInstanceByIndex, j, raid)
                if not iid then break end
                pcall(EJ_SelectInstance, iid)
                local bosses, k = {}, 1
                while k < 40 do
                    local bname, _, eid = Try(EJ_GetEncounterInfoByIndex, k, iid)
                    if not bname then break end
                    bosses[#bosses + 1] = tostring(eid) .. "=" .. Clean(bname)
                    k = k + 1
                end
                out.journal[#out.journal + 1] = Line(tierName, iid, name, raid and 1 or 0, mapID or "") .. "\t" .. table.concat(bosses, "|")
                j = j + 1
            end
        end
    end)

    -- quests: completed ones, the book's own, the quest lines' and every ID in the recent range. Titles load from the
    -- server, so ask first, wait a minute, then read.
    local questList
    step("quests: asking the server", function(s)
        if not questList then
            for _, q in ipairs(C_QuestLog.GetAllCompletedQuestIDs and Try(C_QuestLog.GetAllCompletedQuestIDs) or {}) do
                addQuest(q, "completed")
            end
            for q in pairs(BookQuests()) do addQuest(q, "book") end
            for q = QUEST_RANGE[1], QUEST_RANGE[2] do addQuest(q, "range") end
            questList, s.i = {}, 0
            for q in pairs(questSeen) do questList[#questList + 1] = q end
            table.sort(questList)
            print(PREFIX .. string.format("  %d quest IDs to look up; this is the slow part.", #questList))
        end
        for _ = 1, ASK_PER_FRAME do
            s.i = s.i + 1
            local q = questList[s.i]
            if not q then
                s.waitUntil = s.waitUntil or (GetTime() + 90)
                return GetTime() > s.waitUntil
            end
            if not Try(C_QuestLog.GetTitleForQuestID, q) then Try(C_QuestLog.RequestLoadQuestByID, q) end
            if s.i % 10000 == 0 then print(PREFIX .. string.format("  asked for %d of %d quests", s.i, #questList)) end
        end
    end)
    step("quests: reading titles", function(s)
        s.i = s.i or 0
        for _ = 1, 400 do
            s.i = s.i + 1
            local q = questList and questList[s.i]
            if not q then return true end
            local title = Try(C_QuestLog.GetTitleForQuestID, q)
            local done = Try(C_QuestLog.IsQuestFlaggedCompleted, q)
            -- range IDs without a title aren't real quests; the others are kept even without one
            if title or questSeen[q] ~= "range" then
                out.quests[#out.quests + 1] = Line(q, title or "", done and 1 or 0, questSeen[q])
            end
        end
    end)

    print(PREFIX .. "reading everything the game knows; this takes about half an hour. Keep playing normally (or stand still).")
    Run(steps, function(seconds)
        if onlyCollect and ns.db.dump then
            for _, k in ipairs({ "mounts", "pets", "toys", "sets", "heirlooms", "illusions", "titles", "unmatched" }) do ns.db.dump[k] = out[k] end
            ns.db.dump.collectBuilt = out.built
            out = ns.db.dump
        end
        ns.db.dump = out
        running = false
        local parts = {}
        for _, k in ipairs({ "ach", "mounts", "pets", "toys", "sets", "quests", "questlines", "maps", "journal" }) do
            parts[#parts + 1] = #(out[k] or {}) .. " " .. k
        end
        print(PREFIX .. string.format("done in %d minutes: %s. Type /reload so the game saves it, then tell Claude.",
            math.floor(seconds / 60 + 0.5), table.concat(parts, ", ")))
    end)
end

-- /comp dump [collect | clear]
function ns.AchievementDump(arg)
    if arg == "clear" then
        ns.db.dump = nil
        print(PREFIX .. "the saved read is removed (after /reload).")
        return
    end
    Start(arg == "collect")
end
