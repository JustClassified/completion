-- Completion: rare patrol. Track any rare and the arrow keeps a loop going through the zone's rares you
-- still need, nearest first:
--   * get close to a rare's spawn; if it isn't up after a couple of seconds, the arrow moves on to the
--     nearest rare not checked yet
--   * a rare you still need comes up anywhere near you: a raid-warning style alert and the arrow turns to it
--   * kill it and the arrow goes on to the nearest one left
-- With farm mode on, rares already killed that can still drop a collectible you need (and weren't looted
-- today) are part of the loop too.
-- When every rare has been checked the loop starts over, so you can just keep flying. World bosses are not
-- part of the patrol. Tracking anything that isn't a rare (or starting a route) ends it.

local _, ns = ...

local RANGE = 90       -- yards: close enough that a rare that is up shows on the minimap
local WAIT = 2.5       -- seconds in range before a rare counts as not up
local RECHECK = 600    -- seconds before a rare that wasn't up is worth another look

local patrol = nil     -- { zone, skipped = { key = time }, near = key, nearAt = time, alerted = { key = true } }
local patrolling = false   -- true while the patrol itself changes the target

-- A rare that can be part of a patrol: a rare spot in a zone's Rares page (world bosses are not).
local function IsPatrolRare(it)
    return it and it.kind == "point" and it.pkind == "rare" and it.zone ~= nil and not it.parent
end

-- True while a rare patrol runs.
function ns.PatrolActive() return patrol ~= nil end

-- The rares still needed in the patrol's zone.
local function Candidates()
    local out = {}
    for _, it in ipairs(patrol.zone.sections.rare.items) do
        if IsPatrolRare(it) and ns.StillWanted(it) and not it.hidden then out[#out + 1] = it end
    end
    return out
end

-- The nearest rare not checked lately, leaving out one (the rare just checked). Starts the loop over when
-- every one has been checked. nil when no rare is left at all.
local function Choose(exclude)
    local now = GetTime()
    for k, t in pairs(patrol.skipped) do if now - t > RECHECK then patrol.skipped[k] = nil end end
    local pinst, pwx, pwy = ns.PlayerWorld()
    local function pick(useSkips)
        local best, bestD
        for _, it in ipairs(Candidates()) do
            if it ~= exclude and not (useSkips and patrol.skipped[it.key]) then
                local _, d = ns.Nearest(it.spots)
                if not best or (d and (not bestD or d < bestD)) then best, bestD = it, d end
            end
        end
        return best
    end
    local best = pick(true)
    if not best then
        wipe(patrol.skipped)   -- every rare checked: start the loop over
        best = pick(false)
    end
    return best or (exclude and ns.StillWanted(exclude) and exclude) or nil
end

-- Points the arrow at a rare without ending the patrol.
local function Go(it)
    patrol.near = nil
    patrolling = true
    ns.Track(it)
    patrolling = false
end

-- Ends the patrol; quiet skips the chat line.
local function Stop(quiet)
    patrol = nil
    if not quiet then ns.Print("Rare patrol stopped.") end
end

-- Called by ns.Track: tracking a rare by hand starts (or keeps) a patrol of its zone; anything else ends it.
function ns.PatrolOnTrack(it)
    if patrolling then return end
    if IsPatrolRare(it) and not (ns.RouteActive and ns.RouteActive()) then
        if not patrol or patrol.zone ~= it.zone then
            patrol = { zone = it.zone, skipped = {}, alerted = {} }
            ns.Print("Rare patrol in " .. (it.zone.short or it.zone.name)
                .. ": the arrow moves on when a rare isn't up, and turns to any rare you need that comes up. "
                .. "Track something else to stop.")
        end
        patrol.near = nil
    elseif patrol then
        Stop()
    end
end

-- Called by ns.TrackNext (a rare killed, or a right-click on the arrow): the nearest rare left.
function ns.PatrolNext()
    if not patrol then return false end
    local cur = ns.TargetItem()
    if cur and IsPatrolRare(cur) and ns.StillWanted(cur) then patrol.skipped[cur.key] = GetTime() end
    local nx = Choose(cur)
    if nx then Go(nx) else ns.Print("Every rare in " .. (patrol.zone.short or "this zone") .. " is killed."); Stop(true); ns.Track(nil) end
    return true
end

-- "[Patrol] " for the arrow and the tracking line; "checking" while you wait at a spawn.
function ns.PatrolLabel()
    if not patrol then return "" end
    local t = ns.TargetItem()
    if t and patrol.near == t.key then return "|cffff9040[Patrol: checking]|r " end
    return "|cffff9040[Patrol]|r "
end

-- The alert for a rare that just came up: raid-warning text in the middle of the screen, its sound, a chat line.
local function Alert(it)
    if ns.db.settings.rareAlerts == false then return end
    local msg = (it.liveName or it.name or "A rare") .. " is up!"
    if RaidNotice_AddMessage and RaidWarningFrame then
        RaidNotice_AddMessage(RaidWarningFrame, msg, (ChatTypeInfo and ChatTypeInfo.RAID_WARNING) or { r = 1, g = 0.3, b = 0.1 })
    end
    pcall(PlaySound, (SOUNDKIT and SOUNDKIT.RAID_WARNING) or 8959)
    ns.Print("|cffff9040" .. msg .. "|r")
end

-- Twice a second while a patrol runs: turn to a rare that is up, move on from one that isn't.
local function Tick()
    if not (patrol and ns.built) then return end
    local now = GetTime()
    -- a rare you still need is up: alert once per appearance and point at it
    for k in pairs(patrol.alerted) do if not ns.upNow[k] then patrol.alerted[k] = nil end end
    for key in pairs(ns.upNow) do
        local it = ns.items[key]
        if IsPatrolRare(it) and it.zone == patrol.zone and ns.StillWanted(it) then
            if not patrol.alerted[key] then
                patrol.alerted[key] = true
                Alert(it)
            end
            if ns.TargetItem() ~= it then Go(it) end
            return
        end
    end
    local t = ns.TargetItem()
    -- the target went away (a farmed rare looted today drops out of tracking): pick the next one
    if not t then
        local nx = Choose(nil)
        if nx then Go(nx) end
        return
    end
    if not IsPatrolRare(t) then return end
    if not ns.StillWanted(t) then ns.PatrolNext(); return end
    -- close to its spawn: give it a moment to show up, then move on
    local res = ns.Resolve(t)
    local pinst, pwx, pwy = ns.PlayerWorld()
    local d = res.spot and pinst and ns.Distance(res.spot, pinst, pwx, pwy)
    if d and d < RANGE and patrol.near ~= t.key then
        patrol.near, patrol.nearAt = t.key, now
        ns.UpdateTarget()
    elseif patrol.near == t.key and now - patrol.nearAt >= WAIT then
        patrol.skipped[t.key] = now
        local nx = Choose(t)
        if nx and nx ~= t then Go(nx) else patrol.near = nil; ns.UpdateTarget() end
    end
end

ns.PatrolTick = Tick   -- one step of the patrol, also callable directly
if C_Timer and C_Timer.NewTicker then C_Timer.NewTicker(0.5, Tick) end
