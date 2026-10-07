-- Completion: the watch list. Keep several goals in view at once (a mount, a rare, an achievement...), shown
-- in the on-screen tracker under the current goal, nearest first, with their distance. Alt-click a row in the
-- book (or /comp watch while tracking something) to add it; in the tracker, click a line to point the arrow
-- at it, right-click to take it off.
-- Finished goals drop off by themselves, and when the arrow's target is done the nearest watched goal is next.

local _, ns = ...

local MAX = 8

-- The saved list for this character: { { k = item key, c = child row key or nil } }.
local function List()
    ns.cdb.watch = ns.cdb.watch or {}
    return ns.cdb.watch
end

-- True when this item (and row) is on the list.
function ns.Watched(it, child)
    for _, w in ipairs(List()) do
        if w.k == it.key and w.c == child then return true end
    end
    return false
end

-- Adds a goal, or takes it off when it is already there.
function ns.WatchToggle(it, child)
    if not it then return end
    local list = List()
    for i, w in ipairs(list) do
        if w.k == it.key and w.c == child then
            table.remove(list, i)
            ns.Print("Off the watch list: " .. (it.liveName or it.name or "?"))
            ns.RefreshWatch()
            return
        end
    end
    if #list >= MAX then ns.Print("The watch list holds " .. MAX .. " goals; take one off first.") return end
    list[#list + 1] = { k = it.key, c = child }
    ns.Print("On the watch list: " .. (it.liveName or it.name or "?"))
    ns.RefreshWatch()
end

-- Open goals on the list as { it, c, spot, d }, nearest first; finished or vanished ones are removed.
local function Entries()
    local list, out = List(), {}
    local pinst, pwx, pwy = ns.PlayerWorld()
    for i = #list, 1, -1 do
        local w = list[i]
        local it = ns.items[w.k]
        if not it or not ns.StillWanted(it) then
            if ns.built then table.remove(list, i) end
        else
            local res = ns.Resolve(it, w.c)
            local d = res.spot and pinst and ns.Distance(res.spot, pinst, pwx, pwy)
            out[#out + 1] = { it = it, c = w.c, title = res.title, d = d }
        end
    end
    table.sort(out, function(a, b)
        if a.d and b.d then return a.d < b.d end
        return a.d ~= nil and b.d == nil
    end)
    return out
end

ns.WatchEntries = Entries

-- The nearest watched goal other than one (the target just finished), for ns.TrackNext.
function ns.WatchNext(skip)
    if not (ns.cdb and ns.cdb.watch and #ns.cdb.watch > 0) then return false end
    for _, e in ipairs(Entries()) do
        if e.it ~= skip then
            ns.Track(e.it, e.c)
            ns.Print("Next on the watch list: " .. (e.it.liveName or e.it.name or "?"))
            return true
        end
    end
    return false
end

-- The watch list is drawn by the tracker (Tracker.lua), under the goal the arrow points at.
function ns.RefreshWatch()
    if ns.RefreshTracker then ns.RefreshTracker() end
end
