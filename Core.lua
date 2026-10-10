-- Completion: saved variables, small helpers and every read of live game state.
-- The client is the source of truth: achievements, criteria, quest flags and collections are read live,
-- the data files only add where things are and how to do them.

local ADDON, ns = ...
ns.ADDON = ADDON

ns.stamp = 0                       -- bumped whenever game state may have moved; caches key on it
-- Marks game state as possibly changed, so the next read of a cached value starts fresh.
function ns.Bump() ns.stamp = ns.stamp + 1 end

-- Chat output with the addon's gold prefix.
function ns.Print(msg) print("|cffe6c35cCompletion|r: " .. tostring(msg)) end

-- Lowercase with everything but letters and digits stripped, for loose name matching.
function ns.norm(s) return (tostring(s or ""):lower():gsub("[^%w]", "")) end

local DEFAULTS = {
    settings = {
        arrow = true, pin = false, sound = true, announce = true, follow = true,
        hidedone = false, transmog = true, scale = 1, arrowScale = 1,
        scope = {}, hardmodes = false, worldPins = "missing", tooltips = true,
        minimapPins = true, rareAlerts = true, farm = true, waypointAddon = true, followTracked = true, tracker = true,
        pins = {},        -- map pin filter: section key -> false to hide (see ns.PIN_KINDS)
        minimap = { angle = 215, hide = false },
    },
    frames = {},
}
local CHAR_DEFAULTS = {
    seen = {},        -- questID -> true once seen flagged (rares and bosses reset daily; this remembers the kill)
    steps = {},       -- "itemKey#step" -> true
    chronicle = {},   -- zoneKey -> { secs, firstTime, firstLevel }
    log = {},         -- newest first: { t = time(), zone = key, text }
    lastZone = nil, lastSection = nil,
}

-- Fills in missing keys from src, recursing into tables. Values the player already has are kept.
local function copyDefaults(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            copyDefaults(dst[k], v)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

-- Creates or upgrades the account and character saved variables and exposes them as ns.db and ns.cdb.
function ns.InitDB()
    CompletionDB = CompletionDB or {}
    CompletionCharDB = CompletionCharDB or {}
    copyDefaults(CompletionDB, DEFAULTS)
    copyDefaults(CompletionCharDB, CHAR_DEFAULTS)
    ns.db, ns.cdb = CompletionDB, CompletionCharDB
end

-- Adds an entry to the top of the character's adventure log; older entries past the cap are dropped.
function ns.Log(zoneKey, text)
    local log = ns.cdb.log
    table.insert(log, 1, { t = time(), zone = zoneKey, text = text })
    for i = #log, 81, -1 do log[i] = nil end
end

-- A time() stamp as a rough "5m ago" / "3 days ago" string.
function ns.Ago(t)
    local d = time() - (t or 0)
    if d < 60 then return "just now" end
    if d < 3600 then return string.format("%dm ago", math.floor(d / 60)) end
    if d < 86400 then return string.format("%dh ago", math.floor(d / 3600)) end
    local days = math.floor(d / 86400)
    return days == 1 and "1 day ago" or (days .. " days ago")
end

-- Seconds as "2 days 3 hours 5 minutes"; zero parts are left out, and under a minute reads "0 minutes".
function ns.Duration(secs)
    secs = math.floor(secs or 0)
    local d, h, m = math.floor(secs / 86400), math.floor(secs % 86400 / 3600), math.floor(secs % 3600 / 60)
    local parts = {}
    if d > 0 then parts[#parts + 1] = d .. (d == 1 and " day" or " days") end
    if h > 0 then parts[#parts + 1] = h .. (h == 1 and " hour" or " hours") end
    if m > 0 or #parts == 0 then parts[#parts + 1] = m .. (m == 1 and " minute" or " minutes") end
    return table.concat(parts, " ")
end

------------------------------------------------------------------------
-- quests
------------------------------------------------------------------------

-- True when the quest is flagged done on this character or, failing that, on the warband.
-- The second return is true only for the warband case.
function ns.QuestDone(id)
    if not id or not C_QuestLog then return false end
    local ok, done = pcall(C_QuestLog.IsQuestFlaggedCompleted, id)
    if ok and done then return true end
    if C_QuestLog.IsQuestFlaggedCompletedOnAccount then
        local ok2, acc = pcall(C_QuestLog.IsQuestFlaggedCompletedOnAccount, id)
        if ok2 and acc then return true, true end
    end
    return false
end

-- True while the quest is in the player's quest log.
function ns.QuestActive(id)
    if not id or not (C_QuestLog and C_QuestLog.IsOnQuest) then return false end
    local ok, on = pcall(C_QuestLog.IsOnQuest, id)
    return ok and on == true
end

-- The client's quest title, else the fallback, else "Quest <id>" (titles may not be cached yet).
function ns.QuestTitle(id, fallback)
    if id and C_QuestLog and C_QuestLog.GetTitleForQuestID then
        local ok, t = pcall(C_QuestLog.GetTitleForQuestID, id)
        if ok and t and t ~= "" then return t end
    end
    return fallback or ("Quest " .. tostring(id))
end

-- A quest flag that has ever been seen stays done for this character (rare kills reset daily).
function ns.SeenQuest(id)
    if not id then return false end
    if ns.cdb.seen[id] then return true end
    if ns.QuestDone(id) then ns.cdb.seen[id] = true; return true end
    return false
end

------------------------------------------------------------------------
-- achievements and criteria (cached per stamp)
------------------------------------------------------------------------

local achCache, critCache = {}, {}
local cacheStamp = -1

-- Empties both caches once ns.stamp has moved on.
local function checkStamp()
    if cacheStamp ~= ns.stamp then
        cacheStamp = ns.stamp
        achCache, critCache = {}, {}
    end
end

-- Returns { name, done, desc, icon, points } or nil when the achievement doesn't exist.
function ns.Ach(id)
    if not id then return end
    checkStamp()
    local c = achCache[id]
    if c == nil then
        local ok, aid, name, points, completed, _, _, _, desc, _, icon = pcall(GetAchievementInfo, id)
        if ok and aid then
            c = { name = name, done = completed and true or false, desc = desc, icon = icon, points = points }
        else
            c = false
        end
        achCache[id] = c
    end
    return c or nil
end

-- True when the achievement is earned; false when it isn't or is unknown.
function ns.AchDone(id)
    local a = ns.Ach(id)
    return a and a.done or false
end

-- Every criterion of an achievement: list (in client order), byID, byName (keyed by ns.norm, first wins).
function ns.Crits(id)
    if not id then return end
    checkStamp()
    local c = critCache[id]
    if c == nil then
        c = { list = {}, byID = {}, byName = {} }
        local ok, n = pcall(GetAchievementNumCriteria, id)
        if ok and type(n) == "number" then
            for i = 1, n do
                local ok2, name, ctype, done, qty, req, _, _, asset, qtyStr, cid = pcall(GetAchievementCriteriaInfo, id, i)
                if ok2 then
                    local e = { index = i, name = name, t = ctype, done = done and true or false, qty = qty, req = req,
                                asset = asset, qtyStr = qtyStr, id = cid }
                    c.list[i] = e
                    if cid and cid ~= 0 then c.byID[cid] = e end
                    if name and name ~= "" and not c.byName[ns.norm(name)] then c.byName[ns.norm(name)] = e end
                end
            end
        end
        critCache[id] = c
    end
    return c
end

-- One criterion by its criteria ID, or nil.
function ns.Crit(achID, critID)
    local c = ns.Crits(achID)
    return c and c.byID[critID]
end

------------------------------------------------------------------------
-- professions
------------------------------------------------------------------------

local profStamp, profSet = -1, {}
-- True when the character has the profession, given by name or skill line (see ns.PROF_SKILL).
-- A nil name means no profession is needed. The known set is rebuilt once per stamp.
function ns.HasProf(name)
    if not name then return true end
    if profStamp ~= ns.stamp then
        profStamp, profSet = ns.stamp, {}
        if GetProfessions and GetProfessionInfo then
            local list = { GetProfessions() }
            for i = 1, 6 do
                local idx = list[i]
                if idx then
                    local ok, pname, _, _, _, _, _, skillLine = pcall(GetProfessionInfo, idx)
                    if ok then
                        if pname then profSet[pname] = true end
                        if skillLine then profSet[skillLine] = true end
                    end
                end
            end
        end
    end
    return profSet[name] or profSet[ns.PROF_SKILL[name] or -1] or false
end

------------------------------------------------------------------------
-- reputation: renown, friendship ranks or plain standing
------------------------------------------------------------------------

-- Returns { name, cur, max, text, done } or nil when the client knows nothing about the faction.
-- Tries renown first, then friendship ranks, then plain standing (Exalted = 8); renown also sets .renown.
function ns.Rep(factionID)
    if C_MajorFactions and C_MajorFactions.GetMajorFactionData then
        local ok, d = pcall(C_MajorFactions.GetMajorFactionData, factionID)
        if ok and d and d.name then
            local max
            if C_MajorFactions.GetRenownLevels then
                local ok2, levels = pcall(C_MajorFactions.GetRenownLevels, factionID)
                if ok2 and type(levels) == "table" then max = #levels end
            end
            local cur = d.renownLevel or 0
            max = max or cur
            local done = false
            if C_MajorFactions.HasMaximumRenown then
                local ok3, m = pcall(C_MajorFactions.HasMaximumRenown, factionID)
                done = ok3 and m == true
            end
            done = done or (max > 0 and cur >= max)
            if not d.isUnlocked then cur = 0 end
            return { name = d.name, cur = cur, max = max, done = done,
                     text = string.format("Renown %d / %d", cur, max), renown = true }
        end
    end
    if C_GossipInfo and C_GossipInfo.GetFriendshipReputation then
        local ok, f = pcall(C_GossipInfo.GetFriendshipReputation, factionID)
        if ok and f and f.friendshipFactionID and f.friendshipFactionID > 0 then
            local cur, max = 0, 0
            if C_GossipInfo.GetFriendshipReputationRanks then
                local ok2, r = pcall(C_GossipInfo.GetFriendshipReputationRanks, factionID)
                if ok2 and r then cur, max = r.currentLevel or 0, r.maxLevel or 0 end
            end
            local name = f.name
            if (not name or name == "") and C_Reputation and C_Reputation.GetFactionDataByID then
                local ok3, fd = pcall(C_Reputation.GetFactionDataByID, factionID)
                name = ok3 and fd and fd.name or name
            end
            return { name = name or ("Faction " .. factionID), cur = cur, max = max,
                     done = max > 0 and cur >= max,
                     text = string.format("%s  (%d / %d)", f.reaction or "", cur, max) }
        end
    end
    if C_Reputation and C_Reputation.GetFactionDataByID then
        local ok, fd = pcall(C_Reputation.GetFactionDataByID, factionID)
        if ok and fd and fd.name then
            local reaction = fd.reaction or 0
            return { name = fd.name, cur = reaction, max = 8, done = reaction >= 8,
                     text = _G["FACTION_STANDING_LABEL" .. reaction] or "" }
        end
    end
end

------------------------------------------------------------------------
-- collectibles
------------------------------------------------------------------------

local itemReq = {}
-- Asks the client to load an item's data, once per item per session.
local function RequestItem(id)
    if id and not itemReq[id] and C_Item and C_Item.RequestLoadItemDataByID then
        itemReq[id] = true
        pcall(C_Item.RequestLoadItemDataByID, id)
    end
end

-- The item's name, or nil while the client hasn't loaded it (a load is requested then).
local itemNames = {}   -- itemID -> name, kept once known (names don't change; the client's cache does)
function ns.ItemName(id)
    if not id then return end
    if itemNames[id] then return itemNames[id] end
    local name
    if C_Item and C_Item.GetItemNameByID then
        local ok, n = pcall(C_Item.GetItemNameByID, id)
        if ok then name = n end
    end
    if not name and GetItemInfo then
        local ok, n = pcall(GetItemInfo, id)
        if ok then name = n end
    end
    if name and name ~= "" then itemNames[id] = name else RequestItem(id) end
    return name
end

-- The item's icon file ID, or nil.
local itemIcons = {}   -- itemID -> icon, kept once known
function ns.ItemIcon(id)
    if not id then return end
    if itemIcons[id] then return itemIcons[id] end
    local icon
    if C_Item and C_Item.GetItemIconByID then
        local ok, i = pcall(C_Item.GetItemIconByID, id)
        if ok then icon = i end
    end
    if not icon and GetItemIcon then
        local ok, i = pcall(GetItemIcon, id)
        if ok then icon = i end
    end
    itemIcons[id] = icon
    return icon
end

-- Returns owned, name for a mount journal ID; nil when the journal doesn't know it.
local function MountOwned(mountID)
    if not (mountID and C_MountJournal and C_MountJournal.GetMountInfoByID) then return end
    local ok, name, _, _, _, _, _, _, _, _, _, isCollected = pcall(C_MountJournal.GetMountInfoByID, mountID)
    if ok and name then return isCollected and true or false, name end
end

-- Returns owned, name for an item that teaches a battle pet; nil when the item isn't a pet.
-- r[14] is the species ID (13th return, after pcall's ok).
local function PetOwned(itemID)
    if not (C_PetJournal and C_PetJournal.GetPetInfoByItemID) then return end
    local r = { pcall(C_PetJournal.GetPetInfoByItemID, itemID) }
    if not r[1] then return end
    local speciesID = r[14]
    if not speciesID or not C_PetJournal.GetNumCollectedInfo then return end
    local ok, have = pcall(C_PetJournal.GetNumCollectedInfo, speciesID)
    if ok and have then return have > 0, r[2] end
end

-- Returns true or false for a toy; nil when the item isn't in the toy box.
local function ToyOwned(itemID)
    if not (C_ToyBox and C_ToyBox.GetToyInfo) then return end
    local ok, tid = pcall(C_ToyBox.GetToyInfo, itemID)
    if ok and tid then
        local ok2, has = pcall(PlayerHasToy, itemID)
        return ok2 and has and true or false
    end
end

-- Housing decor. The catalog API is new and not verified in game yet, so every field is read
-- defensively; nil means "can't tell" and the row is shown but not counted. Owned counts every
-- copy, whether placed, in storage or still redeemable.
local function DecorOwned(itemID)
    if not (C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByItem) then return end
    local ok, info = pcall(C_HousingCatalog.GetCatalogEntryInfoByItem, itemID, true)
    if not ok or type(info) ~= "table" then return end
    local n = (info.quantity or 0) + (info.numPlaced or 0) + (info.remainingRedeemable or 0) + (info.numStored or 0)
    return n > 0
end

-- Returns true or false for an appearance, "skip" when this character can't learn it,
-- or nil when the item has no appearance or the client can't tell.
local canLearn = {}   -- sourceID -> true/false, decided once the client has the data (it doesn't change)
local function AppearanceOwned(itemID)
    if not (C_TransmogCollection and C_TransmogCollection.GetItemInfo) then return end
    local ok, appearanceID, sourceID = pcall(C_TransmogCollection.GetItemInfo, itemID)
    if not ok or not appearanceID or not sourceID then return end
    -- whether this character can learn it is only trusted when the client has the data; asking again
    -- while it's loading or evicted would flip the row between hidden and counted on every refresh
    if canLearn[sourceID] == nil and C_TransmogCollection.PlayerCanCollectSource then
        local ok2, hasData, canCollect = pcall(C_TransmogCollection.PlayerCanCollectSource, sourceID)
        if ok2 and hasData then canLearn[sourceID] = canCollect and true or false end
    end
    if canLearn[sourceID] == false then return "skip" end
    if C_TransmogCollection.GetAppearanceInfoBySource then
        local ok3, info = pcall(C_TransmogCollection.GetAppearanceInfoBySource, sourceID)
        if ok3 and type(info) == "table" and info.appearanceIsCollected ~= nil then
            return info.appearanceIsCollected and true or false
        end
    end
    if C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance then
        local ok4, has = pcall(C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance, sourceID)
        if ok4 then return has and true or false end
    end
end

local typeCache = {}   -- itemID -> resolved type or false (not a collectible)

-- Returns ctype, owned. ctype nil = still loading, false = not a collectible for this character.
-- owned nil = the client can't tell (row shown, not counted).
-- flag ("m", "p", "t", "d") forces the type from the data files; otherwise it is detected and cached.
local lastOwned = {}   -- itemID -> last definite owned answer (true sticks: nothing gets uncollected)

-- Steadies an owned answer: once collected it stays collected, and "can't tell" (the client still
-- loading) falls back to the last definite answer, so counts don't jump while data comes and goes.
local function Steady(itemID, owned)
    if owned == true or (owned == false and lastOwned[itemID] ~= true) then lastOwned[itemID] = owned end
    return lastOwned[itemID]
end

function ns.ItemCollect(itemID, flag)
    local t, owned = ns.ItemCollectRaw(itemID, flag)
    if t then return t, Steady(itemID, owned) end
    -- a known collectible whose data is loading again: keep the last answer rather than hiding the row
    if t == nil and typeCache[itemID] and lastOwned[itemID] ~= nil then return typeCache[itemID], lastOwned[itemID] end
    return t, owned
end

function ns.ItemCollectRaw(itemID, flag)
    local t = typeCache[itemID]
    if t == nil then
        if flag == "m" then t = "mount"
        elseif flag == "p" then t = "pet"
        elseif flag == "t" then t = "toy"
        elseif flag == "d" then t = "decor"
        else
            if C_MountJournal and C_MountJournal.GetMountFromItem then
                local ok, mid = pcall(C_MountJournal.GetMountFromItem, itemID)
                if ok and mid then t = "mount" end
            end
            if not t and ToyOwned(itemID) ~= nil then t = "toy" end
            if not t and PetOwned(itemID) ~= nil then t = "pet" end
            if not t then
                if not ns.ItemName(itemID) then return nil end   -- wait for item data
                local a = AppearanceOwned(itemID)
                if a == "skip" then t = false
                elseif a ~= nil then t = "appearance"
                elseif DecorOwned(itemID) ~= nil then t = "decor"
                else t = false end
            end
        end
        typeCache[itemID] = t
    end
    if not t then return false end
    if t == "appearance" and not ns.db.settings.transmog then return false end
    if t == "mount" then
        local ok, mid = pcall(C_MountJournal.GetMountFromItem, itemID)
        return t, MountOwned(ok and mid)
    elseif t == "pet" then return t, PetOwned(itemID)
    elseif t == "toy" then return t, ToyOwned(itemID)
    elseif t == "decor" then return t, DecorOwned(itemID)
    elseif t == "appearance" then
        local a = AppearanceOwned(itemID)
        if a == "skip" then return false end
        return t, a
    end
    return false
end

-- Non-item renown rewards. Each returns ctype, owned (nil = can't tell) and, where known, a name.
function ns.MountCollect(mountID) return "mount", MountOwned(mountID) end

-- A title by title ID.
function ns.TitleCollect(titleID)
    if not IsTitleKnown then return "title", nil end
    local ok, known = pcall(IsTitleKnown, titleID)
    return "title", ok and (known and true or false) or nil
end

-- A whole transmog set by set ID.
function ns.SetCollect(setID)
    if not (C_TransmogSets and C_TransmogSets.GetSetInfo) then return "set", nil end
    local ok, info = pcall(C_TransmogSets.GetSetInfo, setID)
    if ok and info then return "set", info.collected and true or false, info.name end
    return "set", nil
end

-- A single appearance by transmog source ID.
function ns.SourceCollect(sourceID)
    if not (C_TransmogCollection and C_TransmogCollection.GetSourceInfo) then return "appearance", nil end
    local ok, info = pcall(C_TransmogCollection.GetSourceInfo, sourceID)
    if ok and info then return "appearance", info.isCollected and true or false, info.name end
    return "appearance", nil
end

------------------------------------------------------------------------
-- bags (for guide steps that ask you to pick something up)
------------------------------------------------------------------------

ns.bag = {}
-- Rebuilds ns.bag as itemID -> total count across the backpack and equipped bags.
function ns.ScanBags()
    if not (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo) then return end
    local ids = {}
    local last = NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4
    for bag = 0, last do
        local slots = C_Container.GetContainerNumSlots(bag) or 0
        for slot = 1, slots do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID then ids[info.itemID] = (ids[info.itemID] or 0) + (info.stackCount or 1) end
        end
    end
    ns.bag = ids
end

------------------------------------------------------------------------
-- map helpers (world x axis = north, y axis = west; same convention as HereBeDragons)
------------------------------------------------------------------------

-- Map position (0-1) to world coordinates. Returns instanceID, wx, wy and the raw vector, or nil.
function ns.MapToWorld(mapID, x, y)
    if not (C_Map and C_Map.GetWorldPosFromMapPos) then return end
    local v = CreateVector2D and CreateVector2D(x, y) or { x = x, y = y }
    local ok, inst, pos = pcall(C_Map.GetWorldPosFromMapPos, mapID, v)
    if not ok or not pos then return end
    local wx, wy
    if pos.GetXY then wx, wy = pos:GetXY() else wx, wy = pos.x, pos.y end
    if not wx or not wy then return end
    return inst, wx, wy, pos
end

-- The player's world position, same returns as ns.MapToWorld; nil where the map has no position (instances).
function ns.PlayerWorld()
    if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition) then return end
    local m = C_Map.GetBestMapForUnit("player")
    if not m then return end
    local ok, pos = pcall(C_Map.GetPlayerMapPosition, m, "player")
    if not ok or not pos then return end
    local px, py
    if pos.GetXY then px, py = pos:GetXY() else px, py = pos.x, pos.y end
    if not px or not py then return end
    return ns.MapToWorld(m, px, py)
end

-- A spot's position on another map (e.g. a Slayer's Rise treasure on the Voidstorm page), 0-1.
-- Spot coordinates are 0-100. Returns nil when the spot falls outside the target map.
function ns.MapPosOn(spot, targetMap)
    if spot.map == targetMap then return spot.x / 100, spot.y / 100 end
    if not (C_Map and C_Map.GetMapPosFromWorldPos) then return end
    local inst, _, _, pos = ns.MapToWorld(spot.map, spot.x / 100, spot.y / 100)
    if not inst then return end
    local ok, _, mp = pcall(C_Map.GetMapPosFromWorldPos, inst, pos, targetMap)
    if not ok or not mp then return end
    local x, y
    if mp.GetXY then x, y = mp:GetXY() else x, y = mp.x, mp.y end
    if x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then return x, y end
end

ns.playerChain = {}
-- Stores the player's current map and its parents (up to 8), innermost first, in ns.playerChain.
function ns.UpdatePlayerChain()
    local chain = {}
    if C_Map and C_Map.GetBestMapForUnit and C_Map.GetMapInfo then
        local m = C_Map.GetBestMapForUnit("player")
        for _ = 1, 8 do
            if not m or m == 0 then break end
            chain[#chain + 1] = m
            local info = C_Map.GetMapInfo(m)
            m = info and info.parentMapID
        end
    end
    ns.playerChain = chain
end

-- The book zone the player is in (the innermost map in the chain that has a page), or nil.
function ns.PlayerZone()
    for _, id in ipairs(ns.playerChain) do
        local z = ns.zoneByMap[id]
        if z then return z end
    end
end

------------------------------------------------------------------------
-- what counts (Options > What counts)
------------------------------------------------------------------------

-- Whether an achievement group counts toward 100%: the player's choice, else the default, else yes.
function ns.Counts(group)
    if not group then return true end
    -- Other (not counted) groups are always listed; they never count anyway
    if ns.OTHER_GROUPS and ns.OTHER_GROUPS[group] then return true end
    local v = ns.db.settings.scope[group]
    if v == nil then v = ns.SCOPE_DEFAULTS and ns.SCOPE_DEFAULTS[group] end
    if v == nil then v = true end
    return v
end

-- True when a name matches a hard-mode pattern and hard modes are left out of the count.
function ns.IsHard(name)
    if ns.db.settings.hardmodes or not name then return false end
    for _, pat in ipairs(ns.HARD_PATTERNS or {}) do
        if name:find(pat) then return true end
    end
    return false
end
