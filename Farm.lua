-- Completion: farm mode. A rare that is already killed for its achievement still counts while it can drop a
-- mount, pet, toy or decor you don't have, and you haven't looted it today. Such rares stay on the maps and in
-- the rare patrol, carry a "farm" tag in the book, and every kill counts as an attempt for each missing drop
-- (shown in tooltips, like Rarity).

local _, ns = ...

local LABEL = { mount = "mount", pet = "pet", toy = "toy", decor = "decor", appearance = "appearance" }

-- Drops of a rare (its own loot and the table it shares with its group) that you don't have yet:
-- { { itemID, type } }. Only collectibles count; appearances only when they count toward Collectibles.
function ns.FarmWants(it)
    local out = {}
    if not (it and it.kind == "point" and (it.pkind == "rare" or it.pkind == "boss")) then return out end
    -- appearances only keep a rare on the map for completionists (Options > Every item of a look)
    local looks = ns.db and ns.db.settings.transmogSources
    local function check(l)
        if not l[2] and not looks then return end
        local t, owned = ns.ItemCollect(l[1], l[2])
        if t and owned == false and (l[2] or t == "appearance") then out[#out + 1] = { l[1], t } end
    end
    for _, l in ipairs(it.loot or {}) do check(l) end
    if it.sl and ns.SHARED_LOOT and ns.SHARED_LOOT[it.sl] then
        for _, l in ipairs(ns.SHARED_LOOT[it.sl]) do check(l) end
    end
    return out
end

-- For a rare: true when you own every collectible it can drop (appearances when they count), false when one
-- is missing, nil when it drops nothing collectible or the game hasn't loaded them all yet.
function ns.AllLootCollected(it)
    local any = false
    local function check(l)
        local t, owned = ns.ItemCollect(l[1], l[2])
        if t == nil then return nil end           -- still loading: can't say yet
        if t == false then return true end         -- not a collectible (or not one for this character)
        any = true
        if owned == nil then return nil end
        return owned
    end
    local list = {}
    for _, l in ipairs(it.loot or {}) do list[#list + 1] = l end
    if it.sl and ns.SHARED_LOOT and ns.SHARED_LOOT[it.sl] then
        for _, l in ipairs(ns.SHARED_LOOT[it.sl]) do list[#list + 1] = l end
    end
    local unsure = false
    for _, l in ipairs(list) do
        local r = check(l)
        if r == false then return false end
        if r == nil then unsure = true end
    end
    if unsure or not any then return nil end
    return true
end

-- True when the rare's daily loot is used up (its tracking quest is flagged until the daily reset).
function ns.LootedToday(it)
    return it and it.q and (ns.QuestDone(it.q)) or false
end

-- A killed rare worth farming right now: farm mode on, a drop still missing, not looted today.
function ns.FarmWanted(it)
    if not (ns.db and ns.db.settings.farm ~= false) then return false end
    if not (it and it.done and not it.hidden) then return false end
    if ns.LootedToday(it) then return false end
    return #ns.FarmWants(it) > 0
end

-- Still worth a visit: not done yet, or worth farming.
function ns.StillWanted(it)
    if not it then return false end
    return not it.done or ns.FarmWanted(it)
end

-- "farm: mount" style tag for a rare's row, or nil.
function ns.FarmTag(it)
    if not ns.FarmWanted(it) then return end
    local w = ns.FarmWants(it)
    return "farm: " .. (LABEL[w[1][2]] or "drop") .. (#w > 1 and (" +" .. (#w - 1)) or "")
end

------------------------------------------------------------------------
-- attempts
------------------------------------------------------------------------

local scanned = false

-- The next daily reset as a whole hour, so one looting day has one key.
local function ResetKey()
    local left = GetQuestResetTime and GetQuestResetTime() or 0
    return math.floor(((time() + left) / 3600) + 0.5)
end

-- Counts an attempt for every missing drop of a rare looted since the last check. Runs after each evaluation.
-- The first check of a session only records what is already looted, so a reload never counts twice.
function ns.CountAttempts()
    if not (ns.built and ns.db and ns.cdb) then return end
    ns.db.attempts = ns.db.attempts or {}
    ns.cdb.lootDay = ns.cdb.lootDay or {}
    local key = ResetKey()
    for _, z in ipairs(ns.ZONES) do
        for _, it in ipairs(z.sections.rare.items) do
            if it.kind == "point" and it.q and ns.cdb.lootDay[it.q] ~= key and ns.QuestDone(it.q) then
                local wants = ns.FarmWants(it)
                if scanned and #wants > 0 then
                    for _, w in ipairs(wants) do ns.db.attempts[w[1]] = (ns.db.attempts[w[1]] or 0) + 1 end
                    ns.Print(string.format("Attempt counted for %s: %s.", it.liveName or it.name or "a rare",
                        ns.ItemName(wants[1][1]) or "a missing drop"))
                end
                ns.cdb.lootDay[it.q] = key
            end
        end
    end
    scanned = true
end

-- How many times you have looted a source of this item without getting it.
function ns.Attempts(itemID)
    return ns.db and ns.db.attempts and ns.db.attempts[itemID] or 0
end
