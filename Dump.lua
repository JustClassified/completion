-- Completion: a temporary research tool. /comp dump reads every achievement the game knows (category, points, flags,
-- criteria with their type and asset) and whether the book shows it, and saves it all in the saved variables
-- (CompletionDB.dump) so the book's data can be checked against the game itself. It reads only; nothing is changed.
-- Spread over several frames so the game doesn't stall. /comp dump clear removes the saved copy again.

local _, ns = ...

local running = false

-- Where the book shows an achievement: "zone key" or "" when it isn't in the book.
local function InBook(id)
    local it = ns.AchItem and ns.AchItem(id)
    if it then return (it.zone and it.zone.key) or "?" end
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
                ns.db.dump = out
                running = false
                print(string.format("|cffe6c35cCompletion|r: read %d achievements. Type /reload so the game saves them, then tell Claude.", #out.ach))
                return
            end
            local okN, n = pcall(GetCategoryNumAchievements, cat, true)
            for k = 1, (okN and n or 0) do
                local okA, id = pcall(GetAchievementInfo, cat, k)
                if okA and id and not seen[id] then
                    seen[id] = true
                    local line = AchLine(id, cat)
                    if line then out.ach[#out.ach + 1] = line end
                end
            end
        end
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
