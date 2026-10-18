-- Completion: how to get each Midnight mount, pet and toy (Data/CollectText.lua), with live progress: the renown,
-- achievement, quest and currency it needs, whether you can buy it right now, and the short tag on its row.

local _, ns = ...

------------------------------------------------------------------------
-- what counts
------------------------------------------------------------------------

-- True when an item is left out of 100%: it can't be earned by playing (shop, promotions, not in the game...), or it
-- is a PvP or world event one while that group is switched off in Options > What counts.
function ns.CollectLeftOut(itemID)
    local r = itemID and ns.COLLECT_OUT and ns.COLLECT_OUT[itemID]
    if not r then return false end
    if r == "pvp" then return false end   -- on the PvP page, counted there
    if r == "event" then return not ns.Counts("World Events") end
    return true
end

-- The how-to data of a collectible, or nil.
function ns.CollectInfo(it)
    return it and it.itemID and ns.COLLECT_INFO and ns.COLLECT_INFO[it.itemID] or nil
end

-- The achievement that gives it or unlocks it, for this character's faction (a few have a Horde version).
function ns.CollectAch(info)
    if not info then return end
    if info.aH and UnitFactionGroup and UnitFactionGroup("player") == "Horde" then return info.aH end
    return info.a
end

-- True when only other races can earn it (a race-locked event reward).
function ns.CollectWrongRace(info)
    if not (info and info.races and UnitRace) then return false end
    local _, race = UnitRace("player")
    for _, r in ipairs(info.races) do
        if r == race then return false end
    end
    return true
end

------------------------------------------------------------------------
-- how to get it
------------------------------------------------------------------------

-- Short words for the row tag and the tooltip, by kind.
local KIND_LABEL = {
    renown = "renown", vendor = "vendor", quest = "quest", ach = "achievement", dungeon = "dungeon", raid = "raid",
    delve = "delves", wild = "wild pet", craft = "crafted", fishing = "fishing", ritual = "ritual site",
    assault = "void assault", prey = "prey", paragon = "paragon", event = "event", secret = "secret", rare = "rare",
    treasure = "treasure",
}
ns.COLLECT_KIND_LABEL = KIND_LABEL

local STANDING   -- filled below, before it is used

local WILD = "Catch it in the wild: Midnight's wild pets don't battle, so find one at a marked spot and click it."

-- A vendor's name from Data/Vendors.lua, or nil.
local function VendorName(npcID)
    local v = npcID and ns.VENDOR_NPCS and ns.VENDOR_NPCS[npcID]
    return v and v.n
end

-- The main instruction for a collectible: the reviewed sentence, or one built from its kind. nil without data.
function ns.CollectHow(it)
    local info = ns.CollectInfo(it)
    if not info then return end
    if info.how then return info.how end
    local k = info.k
    if k == "renown" and info.fac and info.lvl then
        local r = ns.Rep(info.fac)
        return string.format("Reach Renown %d with %s, then buy it from %s.", info.lvl, r and r.name or "the faction",
            VendorName(info.npc) or "the renown quartermaster")
    end
    local npc = VendorName(info.npc)
    if npc then return "Buy it from " .. npc .. "." end
    if k == "quest" and info.q then return "Reward from the quest " .. ns.QuestTitle(info.q) .. "." end
    if k == "ach" then
        local a = ns.Ach(ns.CollectAch(info))
        return "Reward for the achievement " .. (a and a.name or "?") .. "."
    end
    if k == "wild" then return WILD end
end

-- Achievement progress as text: "done", or "3/7" from its criteria (nil when it has one criterion or none).
local function AchProgress(id)
    local a = ns.Ach(id)
    if not a then return end
    if a.done then return "done", true end
    local c = ns.Crits(id)
    local list = c and c.list or {}
    if #list > 1 then
        local got = 0
        for _, e in ipairs(list) do if e.done then got = got + 1 end end
        return string.format("%d/%d", got, #list), false
    end
    if list[1] and list[1].req and list[1].req > 1 then
        return string.format("%d/%d", list[1].qty or 0, list[1].req), false
    end
    return nil, false
end

-- How much of a currency you have, or nil when the client can't say.
local function CurrencyHave(id)
    if not (C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo) then return end
    local ok, info = pcall(C_CurrencyInfo.GetCurrencyInfo, id)
    if ok and info then return info.quantity or 0, info.name, info.iconFileID end
end

-- What a vendor price needs, part by part: { text, have, need } for money, currencies and items.
local function CostParts(cost)
    local parts = {}
    if type(cost) ~= "table" then return parts end
    local money = cost[1] or 0
    if money > 0 then
        parts[#parts + 1] = { text = GetCoinTextureString and GetCoinTextureString(money) or string.format("%dg", math.floor(money / 10000)),
                              have = GetMoney and GetMoney() or nil, need = money, money = true }
    end
    for _, c in ipairs(cost[2] or {}) do
        local have, name, icon = CurrencyHave(c[1])
        parts[#parts + 1] = { text = (BreakUpLargeNumbers and BreakUpLargeNumbers(c[2]) or tostring(c[2])) .. " " .. (name or ("currency " .. c[1])),
                              have = have, need = c[2], icon = icon }
    end
    for _, c in ipairs(cost[3] or {}) do
        local have = C_Item and C_Item.GetItemCount and select(2, pcall(C_Item.GetItemCount, c[1], true)) or nil
        parts[#parts + 1] = { text = string.format("%d %s", c[2], ns.ItemName(c[1]) or ("item " .. c[1])),
                              have = type(have) == "number" and have or nil, need = c[2] }
    end
    return parts
end
ns.CollectCostParts = CostParts

-- The vendor to buy it from: the one its how-to data names, else the first that sells it. nil when nobody sells it.
function ns.CollectVendor(it)
    local info = ns.CollectInfo(it)
    for _, v in ipairs(it.vendors or {}) do
        if info and v.npc == info.npc then return v end
    end
    return it.vendors and it.vendors[1]
end

-- Neutral-to-Exalted standings by level (1 Neutral ... 5 Exalted), in the player's language where the game has them.
STANDING = {}
for i = 1, 5 do STANDING[i] = _G["FACTION_STANDING_LABEL" .. (i + 3)] or ({ "Neutral", "Friendly", "Honored", "Revered", "Exalted" })[i] end

-- What the item still needs, with live progress: a list of { text = ..., met = true / false / nil }.
-- Renown or rank, the achievement or quest behind it, and the vendor price against what you have.
function ns.CollectNeeds(it)
    local out = {}
    local info = ns.CollectInfo(it)
    if info then
        local fac, lvl = info.needFac, info.needLvl
        if info.k == "renown" then fac, lvl = info.fac, info.lvl end
        if fac and lvl and info.needStanding then
            -- a Neutral-to-Exalted reputation: level 1 Neutral ... 5 Exalted, whichever way the game reports it
            local r = ns.Rep(fac)
            local cur = 0
            if r then cur = r.renown and (r.cur or 0) or math.max(0, (r.cur or 0) - 3) end
            out[#out + 1] = { text = string.format("%s with %s  (you: %s)", STANDING[lvl] or "?", r and r.name or "the faction",
                                  STANDING[cur] or "not yet"),
                              met = cur >= lvl, rep = true, cur = cur, need = lvl, label = "standing", standing = true }
        elseif fac and lvl then
            local r = ns.Rep(fac)
            local cur = r and r.cur or 0
            local label = (r and r.renown) and "Renown" or "Rank"
            out[#out + 1] = { text = string.format("%s %d with %s  (you: %d)", label, lvl, r and r.name or "the faction", cur),
                              met = cur >= lvl, rep = true, cur = cur, need = lvl, label = label }
        end
        local aid = info.needA or (info.k ~= "quest" and ns.CollectAch(info)) or nil
        if aid then
            local a = ns.Ach(aid)
            local prog, done = AchProgress(aid)
            out[#out + 1] = { text = (info.needA and "Unlocked by " or "Achievement: ") .. (a and a.name or ("achievement " .. aid))
                                  .. (prog and ("  (" .. prog .. ")") or ""), met = done, ach = aid }
        end
        if info.q then
            local done = ns.QuestDone(info.q)
            out[#out + 1] = { text = "Quest: " .. ns.QuestTitle(info.q) .. (done and "  (done)" or ""), met = done, quest = info.q }
        end
    elseif it.renown then
        local r = ns.Rep(it.renown.faction)
        local cur = r and r.cur or 0
        out[#out + 1] = { text = string.format("Renown %d with %s  (you: %d)", it.renown.level, r and r.name or "the faction", cur),
                          met = cur >= it.renown.level, rep = true, cur = cur, need = it.renown.level, label = "Renown" }
    end
    -- the price, at the vendor it names
    local v = ns.CollectVendor(it)
    if v then
        for _, p in ipairs(CostParts(v.cost)) do
            local met
            if p.have ~= nil then met = p.have >= p.need end
            local have = p.have and (p.money and (GetCoinTextureString and GetCoinTextureString(p.have) or "")
                or (BreakUpLargeNumbers and BreakUpLargeNumbers(p.have) or tostring(p.have)))
            out[#out + 1] = { text = "Costs " .. p.text .. (have and ("  (you have " .. have .. ")") or ""), met = met, cost = p }
        end
    end
    return out
end

-- True when a vendor item can be bought right now: every requirement met and the price in your pocket.
function ns.CollectReady(it)
    if it.done or not it.vendors then return false end
    local any = false
    for _, n in ipairs(ns.CollectNeeds(it)) do
        if n.met ~= true then return false end
        any = true
    end
    return any
end

-- The source word for a collectible without data: from the spot it drops from, its renown or its vendor.
local function SourceWord(it)
    local src = it.source
    if src then
        if src.pkind == "rare" then return "rare" end
        if src.pkind == "boss" then return "world boss" end
        if src.pkind == "delve" then return "delve chest" end
        return "treasure"
    end
    if it.renown then return "renown" end
    if it.vendors then return "vendor" end
    if it.viaAch then return "achievement" end
end

-- The row's right column for a collectible you don't have: what's in the way or where it comes from.
-- "Renown 12/16", "achievement 3/7", "2,310/6,000" (with the currency icon), "buy now" or the kind of source.
function ns.CollectTag(it)
    if it.done or (it.max or 0) == 0 then return end
    local needs = ns.CollectNeeds(it)
    for _, n in ipairs(needs) do
        if n.rep and n.met == false then
            if n.standing then return (STANDING[n.need] or "?") .. " needed" end
            return string.format("%s %d/%d", n.label, n.cur, n.need)
        end
    end
    for _, n in ipairs(needs) do
        if n.ach and n.met == false then
            local prog = AchProgress(n.ach)
            return "achievement" .. ((prog and prog ~= "done") and (" " .. prog) or "")
        end
    end
    for _, n in ipairs(needs) do
        local p = n.cost
        if p and n.met == false and not p.money then
            local num = BreakUpLargeNumbers or tostring
            return string.format("%s%s/%s", p.icon and ("|T" .. p.icon .. ":0|t ") or "", num(p.have or 0), num(p.need))
        end
    end
    if ns.CollectReady(it) then return "|cff55ff55buy now|r" end
    local info = ns.CollectInfo(it)
    if info and info.k == "quest" and info.q and ns.QuestActive(info.q) then return "|cffffd100quest in log|r" end
    if it.steps and #it.steps > 1 then
        local cur = ns.CurrentStep(it)
        return string.format("step %d/%d", cur or 1, #it.steps)
    end
    return (info and KIND_LABEL[info.k]) or SourceWord(it)
end

------------------------------------------------------------------------
-- what is left out, for the Midnight page
------------------------------------------------------------------------

-- Why items are left out, in the order the Midnight page lists them, with a plain explanation each.
local OUT_REASONS = {
    { "shop", "In-game shop", "Sold for real money in the in-game shop." },
    { "tradingpost", "Trading Post", "From the monthly Trading Post; its stock rotates, so it isn't tied to Midnight content." },
    { "promo", "Promotions", "Promotions outside the game (events, partner offers, gifts)." },
    { "china", "China only", "Only available in the Chinese version of the game." },
    { "notingame", "Not in the game yet", "In the game files, but nothing gives it out." },
    { "gone", "No longer available", "From an event or season that has ended (the pre-patch event, Season 1 feats)." },
    { "timewalking", "Timewalking", "Sold for Timewarped Badges at the Timewalking vendors." },
    { "mplus", "Mythic+ rating", "Rewards for Mythic+ ratings and Keystone Master or Legend." },
    { "oldpets", "Old-world pet battles", "Rewards for the old-world Family Battler achievements." },
    { "notpet", "Not a collectible", "Listed as a pet, but it's a quest item." },
    { "event", "World events", "Holiday rewards. Turn on World Events in Options > What counts to include them." },
}

-- The Midnight items left out of 100%, grouped by reason: a list of { key, label, why, ids }, empty groups skipped.
-- PvP and world event items only appear while their group is switched off.
function ns.CollectLeftOutSummary()
    local byReason = {}
    for _, list in ipairs({ ns.MIDNIGHT_MOUNT_ITEMS or {}, ns.MIDNIGHT_PET_ITEMS or {}, ns.MIDNIGHT_TOY_ITEMS or {} }) do
        for _, id in ipairs(list) do
            local r = ns.COLLECT_OUT and ns.COLLECT_OUT[id]
            if r and ns.CollectLeftOut(id) then
                byReason[r] = byReason[r] or {}
                table.insert(byReason[r], id)
            end
        end
    end
    local out = {}
    for _, def in ipairs(OUT_REASONS) do
        local ids = byReason[def[1]]
        if ids then out[#out + 1] = { key = def[1], label = def[2], why = def[3], ids = ids } end
    end
    return out
end
