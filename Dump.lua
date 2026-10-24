-- Completion: a research tool for the authors. /comp dump reads everything the game knows and saves it in the saved
-- variables (CompletionDB.dump) so the book's data can be checked against the game itself:
--   every achievement (category, points, flags, criteria with type and asset) and where the book shows it,
--   every mount, battle pet species, toy and appearance set, collected or not, and which ones the book lists.
-- It reads only; no setting, filter or CVar is changed. Spread over many frames so the game doesn't stall.
-- /comp dump clear removes the saved copy again.

local _, ns = ...

local running = false

-- Achievements the book shows another way: storylines (lore rows) and treasure or rare section headings.
local shown
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

-- Where the book shows an achievement: "zone key" or "" when it isn't in the book.
local function InBook(id)
    local it = ns.AchItem and ns.AchItem(id)
    if it then return (it.zone and it.zone.key) or "?" end
    if Shown()[id] then return Shown()[id] end
    local p = ns.ACH_PLACE and ns.ACH_PLACE[id]
    if p then return "placed:" .. tostring(p[1]) end
    return ""
end

-- One achievement as a line: id, category, points, flags, done, book, name, then its criteria
-- (type:asset:required:name) separated by "|".
local function AchLine(id, cat)
    local ok, _, name, points, completed, _, _, _, _, flags = pcall(GetAchievementInfo, id)
    if not ok or not name then return end
    local crit = {}
    local okN, n = pcall(GetAchievementNumCriteria, id)
    for i = 1, (okN and n or 0) do
        local okC, cname, ctype, _, _, req, _, _, asset, _, cid = pcall(GetAchievementCriteriaInfo, id, i)
        if okC then
            crit[#crit + 1] = string.format("%s:%s:%s:%s:%s", tostring(ctype), tostring(asset), tostring(req), tostring(cid), (cname or ""):gsub("[|\t]", " "))
        end
    end
    return table.concat({ id, cat, points or 0, flags or 0, completed and 1 or 0, InBook(id), (name:gsub("[|\t]", " ")), table.concat(crit, "|") }, "\t")
end

-- Starts the read: categories first, then achievements a few categories per frame.
local function Start()
    if running then print("|cffe6c35cCompletion|r: the achievement read is already running."); return end
    if not (GetCategoryList and GetCategoryNumAchievements) then print("|cffe6c35cCompletion|r: this client can't list achievements."); return end
    running = true
    shown = nil
    local cats = GetCategoryList() or {}
    local out = { built = date("%Y-%m-%d %H:%M"), version = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("Completion", "Version")) or "?", cats = {}, ach = {} }
    for _, cat in ipairs(cats) do
        local ok, title, parent = pcall(GetCategoryInfo, cat)
        out.cats[#out.cats + 1] = string.format("%d\t%s\t%s", cat, tostring(ok and parent or ""), ok and title or "?")
    end
    local seen, i = {}, 0
    local f = CreateFrame("Frame")
    print("|cffe6c35cCompletion|r: reading every achievement (" .. #cats .. " categories)...")
    f:SetScript("OnUpdate", function(self)
        for _ = 1, 4 do
            i = i + 1
            local cat = cats[i]
            if not cat then
                self:SetScript("OnUpdate", nil)
                print(string.format("|cffe6c35cCompletion|r: read %d achievements; now the collections...", #out.ach))
                ns.CollectionDump(out, function()
                    ns.db.dump = out
                    running = false
                    print(string.format("|cffe6c35cCompletion|r: done: %d achievements, %d mounts, %d pets, %d toys, %d sets. Type /reload so the game saves them, then tell Claude.",
                        #out.ach, #out.mounts, #out.pets, #out.toys, #out.sets))
                end)
                return
            end
            local okN, n = pcall(GetCategoryNumAchievements, cat, true)
            for k = 1, (okN and n or 0) do
                local okA, id = pcall(GetAchievementInfo, cat, k)
                if okA and id then
                    -- a series shows only one step: walk the chain both ways for the rest
                    local chain = { id }
                    local p = GetPreviousAchievement and GetPreviousAchievement(id)
                    while p and not seen[p] and #chain < 30 do table.insert(chain, 1, p); p = GetPreviousAchievement(p) end
                    local n2 = GetNextAchievement and GetNextAchievement(id)
                    while n2 and not seen[n2] and #chain < 60 do chain[#chain + 1] = n2; n2 = GetNextAchievement(n2) end
                    for _, cid in ipairs(chain) do
                        if not seen[cid] then
                            seen[cid] = true
                            local line = AchLine(cid, cat)
                            if line then out.ach[#out.ach + 1] = line end
                        end
                    end
                end
            end
        end
    end)
end

------------------------------------------------------------------------
-- collections
------------------------------------------------------------------------

-- Text without the game's colour and texture codes, tabs or bars.
local function Clean(t)
    t = tostring(t or "")
    t = t:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):gsub("|n", " "):gsub("[|\t\r\n]", " ")
    return t
end

-- The mount IDs, pet species and toy items the book lists (its item lists, collectibles and holiday items).
local function BookCollect()
    local items = {}
    local function add(list) for _, id in ipairs(list or {}) do items[id] = true end end
    add(ns.MIDNIGHT_MOUNT_ITEMS); add(ns.MIDNIGHT_PET_ITEMS); add(ns.MIDNIGHT_TOY_ITEMS)
    for id in pairs(ns.COLLECT_INFO or {}) do items[id] = true end
    for _, list in pairs(ns.EVENT_ITEMS or {}) do for _, e in ipairs(list) do if e.i then items[e.i] = true end end end
    for _, it in pairs(ns.items or {}) do if it.itemID then items[it.itemID] = true end end
    local mounts, species = {}, {}
    for id in pairs(items) do
        if C_MountJournal and C_MountJournal.GetMountFromItem then
            local ok, m = pcall(C_MountJournal.GetMountFromItem, id)
            if ok and m then mounts[m] = id end
        end
        if C_PetJournal and C_PetJournal.GetPetInfoByItemID then
            local r = { pcall(C_PetJournal.GetPetInfoByItemID, id) }
            if r[1] and r[14] then species[r[14]] = id end
        end
    end
    return items, mounts, species
end

-- Reads mounts and sets at once, then pet species and toy items in slices; calls done() at the end.
function ns.CollectionDump(out, done)
    out.mounts, out.pets, out.toys, out.sets = {}, {}, {}, {}
    local items, bookMounts, bookSpecies = BookCollect()
    -- mounts: the journal's full list, whatever the filters
    if C_MountJournal and C_MountJournal.GetMountIDs then
        for _, mid in ipairs(C_MountJournal.GetMountIDs() or {}) do
            local ok, name, spell, _, _, _, sourceType, _, factionSpecific, faction, hide, collected = pcall(C_MountJournal.GetMountInfoByID, mid)
            if ok and name then
                local okX, _, _, source = pcall(C_MountJournal.GetMountInfoExtraByID, mid)
                out.mounts[#out.mounts + 1] = table.concat({ mid, spell or 0, Clean(name), sourceType or 0, collected and 1 or 0,
                    factionSpecific and tostring(faction) or "", hide and 1 or 0, bookMounts[mid] or "", okX and Clean(source) or "" }, "\t")
            end
        end
    end
    -- appearance sets: every set the game has, with its expansion
    if C_TransmogSets and C_TransmogSets.GetAllSets then
        for _, set in ipairs(C_TransmogSets.GetAllSets() or {}) do
            out.sets[#out.sets + 1] = table.concat({ set.setID, Clean(set.name), Clean(set.label), set.expansionID or "", set.classMask or 0,
                set.collected and 1 or 0, Clean(set.description), set.requiredFaction or "" }, "\t")
        end
    end
    -- pets by species ID, toys by item ID, a slice each frame
    local species, item = 0, 0
    local MAX_SPECIES, MAX_ITEM = 6000, 300000
    local f = CreateFrame("Frame")
    f:SetScript("OnUpdate", function(self)
        if species < MAX_SPECIES and C_PetJournal and C_PetJournal.GetPetInfoBySpeciesID then
            for _ = 1, 200 do
                species = species + 1
                local r = { pcall(C_PetJournal.GetPetInfoBySpeciesID, species) }
                if r[1] and r[2] then
                    local okN, owned = pcall(C_PetJournal.GetNumCollectedInfo, species)
                    out.pets[#out.pets + 1] = table.concat({ species, Clean(r[2]), r[4] or 0, r[5] or 0, r[9] and 1 or 0, r[12] and 1 or 0,
                        okN and owned or 0, bookSpecies[species] or "", Clean(r[6]) }, "\t")
                end
            end
            return
        end
        if item < MAX_ITEM and C_ToyBox and C_ToyBox.GetToyInfo then
            for _ = 1, 3000 do
                item = item + 1
                local ok, id, name = pcall(C_ToyBox.GetToyInfo, item)
                if ok and id then
                    local have = PlayerHasToy and PlayerHasToy(item)
                    out.toys[#out.toys + 1] = table.concat({ item, Clean(name), have and 1 or 0, items[item] and 1 or 0 }, "\t")
                end
            end
            return
        end
        self:SetScript("OnUpdate", nil)
        done()
    end)
end

-- /comp dump [clear]
function ns.AchievementDump(arg)
    if arg == "clear" then
        ns.db.dump = nil
        print("|cffe6c35cCompletion|r: the saved achievement read is removed (after /reload).")
        return
    end
    Start()
end
