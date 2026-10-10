-- Completion: how hard something is and roughly how long it takes, so players can pick easy things first.
--
-- ns.Rate(it) -> { lvl = 1..4, time = key, why = text } or nil when there's nothing sensible to say.
--   lvl   1 Easy, 2 Medium, 3 Hard, 4 Very hard: what it asks of you (group size, difficulty, skill)
--   time  quick, hour, hours, days, weeks, luck, wait: roughly how long, or what it hangs on
-- Ratings are estimates from rules (group, name, description, guide, spot notes, sources); Data/Difficulty.lua
-- corrects single achievements by hand and always wins.

local _, ns = ...

ns.DIFF_LABEL = { "Easy", "Medium", "Hard", "Very hard" }
ns.DIFF_COLOR = { "55dd55", "ffd100", "ff8a30", "ff4a4a" }
ns.TIME_LABEL = {
    quick = "Quick: a few minutes",
    hour = "About an hour",
    hours = "A few hours",
    days = "Several days of play",
    weeks = "Weeks: weekly gated or a long grind",
    luck = "Luck: a random drop, can take many tries",
    wait = "Waiting: spawns on a timer or event",
}
local TIME_ORDER = { quick = 1, hour = 2, hours = 3, days = 4, wait = 4, luck = 5, weeks = 6 }

local cache, cacheStamp = {}, nil

local groupOf
-- The ACH_GROUPS group an achievement is listed in ("Raids", "PvP", ...), or nil.
function ns.AchGroup(id)
    if not groupOf then
        groupOf = {}
        for _, g in ipairs(ns.ACH_GROUPS or {}) do
            for _, aid in ipairs(g[2]) do groupOf[aid] = groupOf[aid] or g[1] end
        end
    end
    return groupOf[id]
end

-- The guide text of an achievement (steps and tips), lowercased, for keyword checks.
local function GuideText(id)
    local out = {}
    local steps = (ns.ACH_STEPS and ns.ACH_STEPS[id]) or (ns.ACH_READ and ns.ACH_READ[id])
    for _, st in ipairs(steps or {}) do out[#out + 1] = st.t or "" end
    local n = ns.ACH_NOTES and ns.ACH_NOTES[id]
    if type(n) == "table" then for _, t in ipairs(n) do out[#out + 1] = t end elseif n then out[#out + 1] = n end
    return table.concat(out, " "):lower()
end

-- The biggest number in a text (counts like "Win 250 matches"), or 0.
local function BiggestNumber(s)
    local best = 0
    for digits in (s or ""):gsub(",", ""):gmatch("%d+") do
        local n = tonumber(digits)
        if n and n > best and n < 100000 then best = n end
    end
    return best
end

local function R(lvl, why, time) return { lvl = lvl, why = why, time = time } end

-- A meta achievement's parts (criteria that are achievements), as achievement IDs.
local function MetaParts(id)
    local c = ns.Crits(id)
    local parts, others = {}, 0
    for _, e in ipairs(c and c.list or {}) do
        if e.t == 8 and e.asset and e.asset > 0 then parts[#parts + 1] = e.asset else others = others + 1 end
    end
    if #parts > 0 and others == 0 then return parts end
end

local RateAch

-- How long, from the name, description and guide. nil when nothing points anywhere.
local function AchTime(id, name, desc, group, gt)
    local d = (desc or ""):lower()
    local n = BiggestNumber(desc)
    if group == "Professions" or group == "Fishing" then return n >= 100 and "days" or "hours" end
    if d:find("season") then return "weeks" end
    if gt:find("weekly") or gt:find("each week") or gt:find("a week") or gt:find("time gated") or gt:find("timegate")
        or gt:find("reset") or gt:find("alternate") or d:find("week") then return "weeks" end
    if gt:find("drop chance") or gt:find("chance to drop") or gt:find("rare drop") then return "luck" end
    if name:find("Champion$") or d:find("renown") then return "weeks" end
    if n >= 250 then return "weeks" end
    if n >= 50 then return "days" end
    if d:find("all of the rare creatures") or d:find("rare creatures") then return "days" end
    if d:find("storylines") or name:find("^Sojourner") or name:find("Loremaster") then return "days" end
    if d:find("hidden treasures") or d:find("explore") or name:find("^Explore") then return "hours" end
    if d:find("storyline") or d:find("questline") then return "hours" end
    if group == "Raids" and name:find("^Mythic:") then return "weeks" end
    if group == "Raids" then return d:find("following bosses") and "hours" or "hour" end
    if group == "Dungeons" or group == "Delves" then return "hour" end
    if name:find("Glyph") then return "quick" end
    if d:find("races in") then return "hours" end
    if name:find(": Bronze$") or name:find(": Silver$") or name:find(": Gold$") then return "quick" end
    if n >= 10 then return "hours" end
    if d:find("all of the following") or d:find("catch all") or name:find("Safari") then return "days" end
    if name:find("^Lorewalking") then return "hours" end
    if d:find("each of the following") or d:find("in each") or d:find("^visit each") or d:find("listed below") then return "hours" end
    if d:find("^complete") or d:find("^defeat") or d:find("^disrupt") or d:find("^win") or d:find("^unlock")
        or d:find("^trigger") or d:find("^turn in") then return "hour" end
    -- last resort: the number of rows to tick
    local c = ns.Crits(id)
    local rows = c and #c.list or 0
    if rows >= 15 then return "hours" end
    if rows >= 2 then return "hour" end
end

-- How hard, from the name, description, group and guide. Always answers (Easy by default).
local function AchLevel(id, name, desc, group)
    local d = desc or ""
    local tier = tonumber(d:match("[Tt]ier (%d+)") or name:match("[Tt]ier (%d+)") or "")
    -- the very hardest: Mythic raiding, high ratings, top delve and Ritual tiers, the full mask set
    if name:find("^Mythic:") and group == "Raids" then return R(4, "Mythic raid: an organized 20-player group") end
    if name:find("Hall of Fame") or name:find("Cutting Edge") then return R(4, "Among the first to kill the boss on Mythic") end
    -- seasonal ranks and ratings
    local need = tonumber(d:match("[Rr]ating of at least ([%d,]+)") and d:match("[Rr]ating of at least ([%d,]+)"):gsub(",", "") or "")
    if need then
        if need >= 2500 then return R(4, "Needs a " .. need .. " rating") end
        if need >= 2000 then return R(3, "Needs a " .. need .. " rating") end
        return R(2, "Needs a " .. need .. " rating")
    end
    if d:find("rank of Elite") or d:find("rank of Gladiator") or d:find("rank of Duelist") or name:find("Gladiator") then
        return R(4, "A top PvP rank")
    end
    if d:find("rank of Rival") then return R(3, "A high PvP rank") end
    if d:find("rank of Challenger") or d:find("rank of Combatant") then return R(2, "A rated PvP rank") end
    if d:find("%f[%a][Rr]ating%f[%A]") then return R(4, "Needs a high PvP or Mythic+ rating") end
    if tier and tier >= 11 then return R(4, "Tier 11 delves without running out of lives") end
    if tier and tier >= 6 and d:find("challenges") then return R(4, "The top Ritual Site tier with every challenge on") end
    if name:find("^Masked Sextet") or name:find("^Masked Septet") or name:find("Most Horrific Vision") or name:find("^Horrific Masquerade")
        or name:find("Orchestra of Masks") or name:find("Symphony of Masks") then
        return R(4, "A full vision clear with many masks on")
    end
    -- hard: Mythic dungeons, Heroic raids, gold times, high tiers, many masks, Nightmare
    if name:find("^Glory of") then return R(3, "A long list of group achievements") end
    if name:find("^Heroic:") and group == "Raids" then return R(3, "Heroic raid: an organized group") end
    if name:find("Nightmare") then return R(3, "Nightmare difficulty") end
    if name:find(": Gold$") or d:find("[Oo]btain gold") then return R(3, "Gold times need clean, practised runs") end
    if tier and tier >= 8 then return R(3, "High delve tier without running out of lives") end
    if tier and tier >= 5 and (d:find("challenges") or name:find("Expert")) then return R(3, "Tier 5 Ritual Site with challenges") end
    if name:find("^Masked Trio") or name:find("^Masked Quartet") or name:find("^Masked Quintet") or name:find("^Mastering the Visions") then
        return R(3, "A full vision clear with several masks on")
    end
    if name:find("^Masked") then return R(2, "A full vision clear with a mask or two on") end
    if name:find("Hard Mode") then return R(2, "Hard difficulty") end
    -- medium: groups, PvP, Heroic dungeons, silver, mid tiers, pet battle teams, raid tricks
    if name:find("^Mythic:") then return R(2, "Mythic dungeon: a five-player group from Premade Groups") end
    if name:find("^Heroic:") and group == "Dungeons" then return R(2, "Heroic dungeon: a five-player group from the finder") end
    if name:find("^Heroic:") then return R(2, "Heroic difficulty") end
    if group == "Raids" and d:find("^Defeat") and not d:find("Heroic") then return R(1, "A boss kill: Raid Finder is enough") end
    if group == "Raids" then return R(2, "A raid group that does the trick with you") end
    if group == "PvP" then return R(2, "PvP against other players") end
    if name:find(": Silver$") or d:find("[Oo]btain silver") then return R(2, "Silver times need a decent run") end
    if tier and tier >= 4 then return R(2, "Tier 4 or higher") end
    if group == "Pet Battles" and (d:find("team of all") or d:find("[Dd]efeat")) then return R(2, "Needs levelled pets and a plan per fight") end
    if group == "Horrific Visions" then return R(2, "Horrific Vision runs") end
    if group == "Ritual Sites" and tier and tier >= 4 then return R(2, "Tier 4 or higher Ritual Site") end
    if name:find("^Glyph") or name:find("Glyph") then return R(1, "Fly to it and pass through") end
    if group == "Dungeons" then return R(1, "Normal dungeon from the finder") end
    return R(1, nil)
end

-- An achievement's rating; metas take their hardest and longest part.
RateAch = function(id, depth)
    local key = "a" .. id
    if cache[key] ~= nil then return cache[key] or nil end
    cache[key] = false   -- guards loops between metas
    local a = ns.Ach(id)
    if not a then return end
    local hand = ns.DIFFICULTY and ns.DIFFICULTY[id]
    local group = ns.AchGroup and ns.AchGroup(id)
    local gt = GuideText(id)
    local r
    local parts = (depth or 0) < 3 and MetaParts(id)
    if parts and (a.desc or ""):lower():find("one of") then
        -- any one part will do: the easiest one counts
        local best, bestName, time
        for _, pid in ipairs(parts) do
            local pr = RateAch(pid, (depth or 0) + 1)
            if pr and (not best or pr.lvl < best) then best, bestName, time = pr.lvl, ns.Ach(pid) and ns.Ach(pid).name, pr.time end
        end
        r = R(best or 1, bestName and ("Easiest way: " .. bestName), time)
    elseif parts then
        local best, bestName, time = 1, nil, "quick"
        for _, pid in ipairs(parts) do
            local pr = RateAch(pid, (depth or 0) + 1)
            if pr then
                if pr.lvl > best then best, bestName = pr.lvl, ns.Ach(pid) and ns.Ach(pid).name end
                if pr.time and (TIME_ORDER[pr.time] or 0) > (TIME_ORDER[time] or 0) then time = pr.time end
            end
        end
        -- many parts add up even when each is short
        if #parts >= 6 and (TIME_ORDER[time] or 0) < TIME_ORDER.days then time = "days" end
        r = R(best, bestName and ("Its hardest part: " .. bestName) or "Every part is easy", time)
        -- a meta can be harder than its parts (Glory metas, Mythic sets)
        local own = AchLevel(id, a.name or "", a.desc or "", group)
        if own.lvl > r.lvl then r.lvl, r.why = own.lvl, own.why end
    else
        r = AchLevel(id, a.name or "", a.desc or "", group)
        r.time = AchTime(id, a.name or "", a.desc or "", group, gt)
    end
    if hand then
        r = { lvl = hand[1] or r.lvl, time = hand[2] or r.time, why = hand[3] or r.why }
    end
    cache[key] = r
    return r
end

-- A treasure, rare, world boss, chest or knowledge spot.
local function RatePoint(it)
    local note = ((it.note or "") .. " " .. table.concat(it.tips or {}, " ")):lower()
    if it.pkind == "rare" then
        if note:find("%f[%a]group%f[%A]") then return R(3, "Needs a group", "hour") end
        -- something you do brings it out: a summon, a gathered item, a trap, an event to finish
        if note:find("summon") or note:find("kill the") or note:find("gather") or note:find("combine") or note:find("use the")
            or note:find("use them") or note:find("trap") or note:find("charge the") or note:find("fish up") then
            return R(2, "You bring it out with a small task (see the note)", "hour")
        end
        -- it comes on its own schedule or with a zone event
        if note:find("during") or note:find("every %d") or note:find("spawns after") or note:find("shortly after")
            or note:find("after other rares") or note:find("event") or note:find("objective of") or note:find("daily") then
            return R(1, "Only up at certain times or with an event (see the note)", "wait")
        end
        return R(1, "A normal rare: kill it when it's up", "quick")
    elseif it.pkind == "boss" then
        return R(2, "World boss: join a group through the finder", "hour")
    elseif it.pkind == "treasure" then
        local multi = it.steps and #it.steps > 1
        if multi or note:find("need") or note:find("key") or note:find("first") or note:find("requires") or note:find("puzzle") then
            return R(2, multi and "Several steps in order (see the steps)" or "A small task or item first (see the note)", "hour")
        end
        return R(1, "Go there and loot it", "quick")
    elseif it.pkind == "delve" then
        return R(1, "Inside its delve", "quick")
    elseif it.pkind == "prof" then
        return R(1, "Go there and loot it (your profession only)", "quick")
    end
end

-- Raids whose drops count as raid loot (journal source texts name the zone).
local RAIDS = { "voidspire", "march on quel'danas", "dreamrift", "venomous abyss", "unbinding of kith'ix",
                "nerub-ar palace", "liberation of undermine", "manaforge omega" }

-- A mount, pet, toy or other collectible: from its achievement, the treasure or rare it drops from, or its
-- source text. nil when the source says nothing useful (shop, promotions).
local function RateCollect(it)
    local function fromAch(id, prefix)
        local r = id and RateAch(id)
        if not r then return end
        local a = ns.Ach(id)
        return R(r.lvl, prefix .. (a and a.name or "an achievement"), r.time)
    end
    if it.viaAch and it.viaAch.id then
        local r = fromAch(it.viaAch.id, "Reward for ")
        if r then return r end
    end
    -- loot from a treasure, rare, world boss or Sturdy Chest on the map
    local p = it.source
    if p and p.kind == "point" then
        local pr = RatePoint(p)
        if p.pkind == "treasure" then return R(pr and pr.lvl or 1, "Inside the treasure " .. (p.name or ""), pr and pr.time or "quick") end
        if p.pkind == "delve" then return R(1, "From a Sturdy Chest in its delve", "quick") end
        if p.pkind == "boss" then return R(2, "World boss drop; not every kill", "luck") end
        if p.pkind == "rare" then return R(pr and pr.lvl or 1, "Drops from the rare " .. (p.name or "") .. "; not every kill", "luck") end
    end
    -- a researched source (Data/Sources.lua)
    local ds = it.dropSource
    if ds then
        if ds.a then
            local r = fromAch(ds.a, "Reward for ")
            if r then return r end
        end
        local t = (ds.t or ""):lower()
        if t:find("crafted") then return R(2, "Crafted by a profession, or bought from one who has it", "hours") end
        if t:find("quest") then return R(1, "A quest reward", "hour") end
        if t:find("contained in") then return R(1, "Inside a container item", "hours") end
        if t:find("drop") then return R(1, "A random drop", "luck") end
    end
    if it.vendors then return R(1, "Bought from a vendor (needs its currency or reputation)", "hours") end
    -- the game's own source text
    local src = (it.sourceText or ""):lower()
    if src == "" then return end
    if src:find("mythic") then return R(4, "Drops on Mythic difficulty", "luck") end
    if src:find("drop") then
        for _, raid in ipairs(RAIDS) do
            if src:find(raid, 1, true) then return R(2, "Raid boss drop (Raid Finder works); not every kill", "luck") end
        end
        return R(1, "A random drop", "luck")
    end
    if src:find("treasure") then return R(1, "From a treasure", "quick") end
    if src:find("vendor") then return R(1, "Bought from a vendor (needs its currency or reputation)", "hours") end
    if src:find("renown") or src:find("reputation") then return R(1, "Reputation reward", "weeks") end
    if src:find("quest") then return R(1, "A quest reward", "hour") end
    if src:find("pet battle") then return R(2, "Pet battle reward", "hours") end
    if src:find("profession") or src:find("crafted") then return R(2, "Crafted by a profession", "hours") end
    if src:find("world event") or src:find("holiday") then return R(1, "Only during its holiday", "wait") end
end

-- The rating for any list item, cached until the book is rebuilt. nil when there's no sensible rating.
function ns.Rate(it)
    if not it then return end
    if cacheStamp ~= ns.buildStamp then cache, cacheStamp = {}, ns.buildStamp end
    local k = it.kind
    if k == "ach" then return RateAch(it.id) end
    if k == "lore" then
        local r = cache["l" .. it.key]
        if r == nil then r = R(1, "Quests: follow the chain", "hours"); cache["l" .. it.key] = r end
        return r
    end
    if k == "point" then
        local r = cache["p" .. it.key]
        if r == nil then r = RatePoint(it) or false; cache["p" .. it.key] = r end
        return r or nil
    end
    if k == "collect" then
        local r = cache["c" .. it.key]
        if r == nil then r = RateCollect(it) or false; cache["c" .. it.key] = r end
        return r or nil
    end
    if k == "rep" then return R(1, "Do the faction's world quests and weekly tasks", "weeks") end
end

-- The short coloured tag for a list row, e.g. "|cff55dd55Easy|r", or nil.
function ns.DiffTag(it)
    if ns.db and ns.db.settings and ns.db.settings.difficulty == false then return end
    local r = ns.Rate(it)
    if not r then return end
    return "|cff" .. ns.DIFF_COLOR[r.lvl] .. ns.DIFF_LABEL[r.lvl] .. "|r"
end

-- Tooltip lines: difficulty with its reason, then the time estimate.
function ns.AddDifficulty(tooltip, it)
    if ns.db and ns.db.settings and ns.db.settings.difficulty == false then return end
    local r = ns.Rate(it)
    if not r then return end
    local c = ns.DIFF_COLOR[r.lvl]
    tooltip:AddLine("Difficulty: |cff" .. c .. ns.DIFF_LABEL[r.lvl] .. "|r" .. (r.why and ("  |cffaaaaaa(" .. r.why .. ")|r") or ""), 0.9, 0.85, 0.7, true)
    if r.time and ns.TIME_LABEL[r.time] then tooltip:AddLine("Time: " .. ns.TIME_LABEL[r.time], 0.9, 0.85, 0.7, true) end
end
