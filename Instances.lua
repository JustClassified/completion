-- Completion: Midnight dungeons and raids. Their reviewed data (Data/InstanceText.lua) gives the entrance,
-- difficulties, Story Mode and drops; the season's Mythic+ rotation is read live from the game, because a Midnight
-- dungeon outside it has no Heroic or Mythic until it returns.

local _, ns = ...

local byName       -- English name -> journal instance ID, built on first use
local pool, poolNames   -- this season's Mythic+ dungeons: instance map IDs and lower-case names (nil = unknown)

-- The reviewed data for an instance item, by its journal ID or, failing that, its English name.
function ns.InstanceInfo(it)
    if not (it and ns.INSTANCE_INFO) then return end
    if it.instID and ns.INSTANCE_INFO[it.instID] then return ns.INSTANCE_INFO[it.instID], it.instID end
    if not byName then
        byName = {}
        for id, info in pairs(ns.INSTANCE_INFO) do byName[info.name:lower()] = id end
    end
    local id = it.name and byName[it.name:lower()]
    if id then return ns.INSTANCE_INFO[id], id end
end

-- Reads this season's Mythic+ dungeons once the game reports them. Returns false while it can't tell.
local function ReadPool()
    if pool then return true end
    if not (C_ChallengeMode and C_ChallengeMode.GetMapTable and C_ChallengeMode.GetMapUIInfo) then return false end
    local ok, list = pcall(C_ChallengeMode.GetMapTable)
    if not ok or type(list) ~= "table" or #list == 0 then return false end
    local maps, names = {}, {}
    for _, cid in ipairs(list) do
        local ok2, name, _, _, _, _, mapID = pcall(C_ChallengeMode.GetMapUIInfo, cid)
        if ok2 then
            if mapID then maps[mapID] = true end
            if name then names[name:lower()] = true end
        end
    end
    pool, poolNames = maps, names
    return true
end

-- For a Midnight dungeon: true when it is in this season's Mythic+ rotation, false when it isn't, nil when that
-- can't be read (or the instance isn't a dungeon).
function ns.InSeason(info, liveName)
    if not (info and info.kind == "dungeon") or not ReadPool() then return end
    if pool[info.map] then return true end
    if poolNames[info.name:lower()] or (type(liveName) == "string" and poolNames[liveName:lower()]) then return true end
    return false
end

-- achievement ID -> { info, tier } for every Heroic and Mythic dungeon achievement, built on first use
local tierOf
-- The dungeon and difficulty ("Heroic" or "Mythic") when this achievement can't be earned this season because its
-- dungeon is out of the Mythic+ rotation; nil otherwise.
function ns.AchClosedThisSeason(achID)
    if not (achID and ns.INSTANCE_INFO) then return end
    if not tierOf then
        tierOf = {}
        for _, info in pairs(ns.INSTANCE_INFO) do
            for _, a in ipairs(info.heroic or {}) do tierOf[a] = { info, "Heroic" } end
            for _, a in ipairs(info.mythic or {}) do tierOf[a] = { info, "Mythic" } end
        end
    end
    local t = tierOf[achID]
    if t and ns.InSeason(t[1]) == false then return t[1], t[2] end
end

-- The achievements inside an instance item that count, and how many of them are still open.
local function Achievements(it)
    local list, open = {}, 0
    for _, ch in ipairs(it.children or {}) do
        if ch.kind == "ach" and not ch.hidden then
            list[#list + 1] = ch
            if not ch.done then open = open + 1 end
        end
    end
    return list, open
end

-- The short tag on an instance row: whether its Heroic and Mythic achievements wait for another season, or that it
-- is in this season's Mythic+.
function ns.InstanceTag(it)
    local info = ns.InstanceInfo(it)
    if not info or it.done then return end
    local season = ns.InSeason(info, it.name)
    if season == false then
        for _, ch in ipairs(it.children or {}) do
            if ch.kind == "ach" and not ch.done and ns.AchClosedThisSeason(ch.id) then
                return "|cffd08a50Heroic, Mythic: later season|r"
            end
        end
    elseif season == true then
        return "|cff55dd55in Mythic+ now|r"
    end
end

local KIND = { dungeon = "Dungeon", raid = "Raid", lair = "Lair boss" }
local FLAG_LABEL = { m = "mount", p = "pet", t = "toy", d = "decor" }

-- A map name and coordinates ("Eversong Woods  35.5, 78.8") with a label in front, in grey.
local function Place(tip, label, map, x, y)
    local ok, mi = pcall(C_Map.GetMapInfo, map)
    tip:AddLine(string.format("%s%s  %.1f, %.1f", label, ok and mi and mi.name or "", x, y), 0.6, 0.6, 0.6, true)
end

-- The tooltip for a dungeon or raid: what it is, what's left, whether it's open this season, where the entrance is,
-- how Story Mode opens, its bosses, the achievements still to do, its collectibles and tips. Returns false when there's
-- no reviewed data, so the caller can show the plain tooltip.
function ns.InstanceTooltip(it)
    local info = ns.InstanceInfo(it)
    if not info then return false end
    local tip = GameTooltip
    tip:AddLine((KIND[info.kind] or "Instance") .. ", " .. info.size, 0.8, 0.8, 0.8, true)
    local achs, open = Achievements(it)
    if #achs > 0 then
        if open == 0 then tip:AddLine("Every achievement done", 0.4, 0.9, 0.4)
        else tip:AddLine(string.format("Achievements: %d of %d done", #achs - open, #achs), 1, 0.82, 0.3) end
    end
    -- the season: a Midnight dungeon outside the Mythic+ rotation has only Normal
    local season = ns.InSeason(info, it.name)
    if season == true then
        tip:AddLine("In this season's Mythic+: Heroic, Mythic and keystones are open.", 0.4, 0.9, 0.4, true)
    elseif season == false then
        tip:AddLine("Not in this season's Mythic+: only Normal is open. Heroic and Mythic come back when it returns to the rotation.", 0.85, 0.55, 0.3, true)
    end
    local diffs = info.diffs
    if season == false then
        diffs = {}
        for _, d in ipairs(info.diffs) do
            if d ~= "Heroic" and d ~= "Mythic" and d ~= "Mythic+" then diffs[#diffs + 1] = d end
        end
    end
    if #diffs > 0 then
        tip:AddLine((season == false and "Open now: " or "Difficulties: ") .. table.concat(diffs, ", "), 0.8, 0.8, 0.8, true)
    end
    -- where
    tip:AddLine(" ")
    Place(tip, "Entrance: ", info.at[1], info.at[2], info.at[3])
    tip:AddLine(info.where, 0.9, 0.85, 0.7, true)
    if info.story then
        tip:AddLine(" ")
        tip:AddLine("Story Mode", 1, 0.82, 0.3)
        tip:AddLine(info.story.text, 0.9, 0.85, 0.7, true)
        if info.story.at then Place(tip, "", info.story.at[1], info.story.at[2], info.story.at[3]) end
    end
    -- bosses: the journal's names (in the player's language) when the game gave them
    local bosses = (it.bosses and #it.bosses > 0) and it.bosses or info.bosses
    if bosses and #bosses > 0 then
        tip:AddLine(" ")
        tip:AddLine((#bosses == 1 and "Boss: " or "Bosses: ") .. table.concat(bosses, ", "), 0.8, 0.8, 0.8, true)
    end
    -- what's left, closed ones marked
    if open > 0 then
        tip:AddLine(" ")
        tip:AddLine("Still to do", 1, 0.82, 0.3)
        local shown = 0
        for _, ch in ipairs(achs) do
            if not ch.done then
                shown = shown + 1
                if shown > 8 then tip:AddLine(string.format("...and %d more", open - 8), 0.6, 0.6, 0.6); break end
                local _, tier = ns.AchClosedThisSeason(ch.id)
                if tier then
                    tip:AddLine("- " .. (ch.liveName or ch.name or "?") .. "  |cffd08a50(" .. tier .. " closed this season)|r", 0.6, 0.6, 0.6, true)
                else
                    tip:AddLine("- " .. (ch.liveName or ch.name or "?"), 0.9, 0.9, 0.9, true)
                end
            end
        end
    end
    -- collectibles inside, with whether you have them
    if info.drops and #info.drops > 0 then
        tip:AddLine(" ")
        tip:AddLine("Drops", 1, 0.82, 0.3)
        for _, d in ipairs(info.drops) do
            local t, owned = ns.ItemCollect(d[1], d[2])
            local label = FLAG_LABEL[d[2]] or (t == "appearance" and "look") or "look"
            if t ~= false or d[2] then
                local name = ns.ItemName(d[1]) or ("item " .. d[1])
                local state = owned == true and "  |cff55ff55have|r" or (owned == false and "  |cffffd100need|r" or "")
                local line = string.format("%s (%s), %s%s", name, label, d[3], d[4] and (": " .. d[4]) or "")
                local c = owned == true and 0.6 or 0.9
                tip:AddLine(line .. state, c, c, c, true)
            end
        end
    end
    for _, x in ipairs(info.tips or {}) do
        tip:AddLine("- " .. x, 0.75, 0.75, 0.75, true)
    end
    tip:AddLine(" ")
    tip:AddLine("Click: show its achievements. Track it and the arrow leads to the entrance.", 0.5, 0.5, 0.5, true)
    return true
end
