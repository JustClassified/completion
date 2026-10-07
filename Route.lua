-- Completion: route mode. Plans the shortest loop through everything still open in a section (or every kind
-- the map pins show), tracks the first stop and moves the arrow on as each stop is done. The route is drawn
-- on the world map and on the book's map.
--
-- ns.cdb.route = { zone = key, sec = section key (book routes), label = text,
--                  stops = { { k = item key, c = child row key or nil } }, i = index }

local _, ns = ...

local routing = false   -- true while the route itself changes the target (so it doesn't cancel itself)

------------------------------------------------------------------------
-- stops
------------------------------------------------------------------------

-- Appends every open place in one section of a zone to out as { k, c, spot }. An achievement adds its
-- open criteria rows that have a spot, or itself when none do.
local function StopsFor(zone, secKey, out)
    for _, it in ipairs(zone.sections[secKey].items) do
        if not it.done and not it.hidden and (it.max or 0) > 0 then
            if it.kind == "ach" then
                local any = false
                for _, row in ipairs(ns.Children(it)) do
                    if not row.done and row.spot and not row.step then
                        out[#out + 1] = { k = it.key, c = row.key, spot = row.spot }
                        any = true
                    end
                end
                if not any then
                    local res = ns.Resolve(it)
                    if res.spot then out[#out + 1] = { k = it.key, spot = res.spot } end
                end
            else
                local res = ns.Resolve(it)
                if res.spot then out[#out + 1] = { k = it.key, spot = res.spot } end
            end
        end
    end
end

-- Adds world positions (inst, wx, wy) to each stop and keeps only those on the instance most of them share.
-- Returns the kept stops and that instance.
local function Place(stops)
    local count = {}
    for _, s in ipairs(stops) do
        local inst, wx, wy = ns.MapToWorld(s.spot.map, s.spot.x / 100, s.spot.y / 100)
        s.inst, s.wx, s.wy = inst, wx, wy
        if inst then count[inst] = (count[inst] or 0) + 1 end
    end
    local best, bestN
    for inst, n in pairs(count) do if not bestN or n > bestN then best, bestN = inst, n end end
    local out = {}
    for _, s in ipairs(stops) do if s.inst and s.inst == best then out[#out + 1] = s end end
    return out, best
end

-- Straight-line distance between two placed stops, in world units (yards).
local function D(a, b)
    local dx, dy = a.wx - b.wx, a.wy - b.wy
    return math.sqrt(dx * dx + dy * dy)
end

-- Nearest neighbour from where you stand, then 2-opt until nothing improves (six passes at most).
-- start is the player's world position, or nil when they are elsewhere; the path is left open at the end.
local function Order(stops, start)
    local left, path = {}, {}
    for i, s in ipairs(stops) do left[i] = s end
    local cur = start
    while #left > 0 do
        local bi, bd = 1, nil
        if cur then
            for i, s in ipairs(left) do
                local d = D(cur, s)
                if not bd or d < bd then bi, bd = i, d end
            end
        end
        cur = table.remove(left, bi)
        path[#path + 1] = cur
    end
    local n = #path
    if n < 4 then return path end
    -- Index 0 is the starting position, so the first stop can be swapped too.
    local function at(i) return i == 0 and start or path[i] end
    for _ = 1, 6 do
        local improved = false
        for i = (start and 1 or 2), n - 1 do
            local a = at(i - 1)
            if a then
                for j = i + 1, n do
                    local b, c, e = path[i], path[j], path[j + 1]
                    local before = D(a, b) + (e and D(c, e) or 0)
                    local after = D(a, c) + (e and D(b, e) or 0)
                    if after < before - 0.5 then
                        local x, y = i, j
                        while x < y do path[x], path[y] = path[y], path[x]; x, y = x + 1, y - 1 end
                        improved = true
                    end
                end
            end
        end
        if not improved then break end
    end
    return path
end

-- Total length of the path in yards, counting the leg from start when there is one.
local function RouteLength(path, start)
    local total, prev = 0, start
    for _, s in ipairs(path) do
        if prev then total = total + D(prev, s) end
        prev = s
    end
    return total
end

------------------------------------------------------------------------
-- state
------------------------------------------------------------------------

-- The saved route for this character, or nil.
local function Route() return ns.cdb and ns.cdb.route end

-- True while a route is running.
function ns.RouteActive() return Route() ~= nil end

-- True when a stop no longer needs a visit: its item or criteria row is done, hidden or gone.
local function StopDone(s)
    local it = ns.items[s.k]
    if not it or it.done or it.hidden then return true end
    if s.c then
        for _, row in ipairs(ns.Children(it)) do
            if row.key == s.c then return row.done end
        end
        return true   -- the row is gone (filtered or finished)
    end
    return false
end

-- Makes stop i the current one and tracks it, without ending the route.
local function Go(i)
    local r = Route()
    r.i = i
    local s = r.stops[i]
    routing = true
    ns.Track(ns.items[s.k], s.c)
    routing = false
end

-- Moves on to the first stop from index from that isn't done, or finishes the route when none is left.
-- Returns false only when no route is running.
local function Advance(from)
    local r = Route()
    if not r then return false end
    for i = from, #r.stops do
        if not StopDone(r.stops[i]) then Go(i); return true end
    end
    ns.cdb.route = nil
    ns.Print("Route finished: " .. (r.label or "everything on it is done") .. ".")
    if ns.db.settings.sound then pcall(PlaySound, (SOUNDKIT and SOUNDKIT.UI_70_ARTIFACT_FORGE_TRAIT_RANKUP) or 867) end
    routing = true
    ns.Track(nil)
    routing = false
    return true
end

-- Called before the arrow updates: a stop that is now done hands over to the next one.
function ns.RouteCheck()
    local r = Route()
    if not r or routing or not ns.built then return end   -- before the build every item looks gone
    local s = r.stops[r.i or 1]
    if s and StopDone(s) then Advance((r.i or 1) + 1) end
end

-- Right-click on the arrow while a route runs: skip to the next stop. Returns false when no route runs.
function ns.RouteNext()
    local r = Route()
    if not r then return false end
    return Advance((r.i or 1) + 1)
end

-- Called when the target changes: anything you track by hand ends the route.
function ns.RouteOnTrack()
    if not routing and Route() then
        ns.cdb.route = nil
        ns.Print("Route stopped.")
    end
end

-- Cancels the running route and clears the arrow.
function ns.StopRoute()
    if not Route() then return end
    ns.cdb.route = nil
    routing = true
    ns.Track(nil)
    routing = false
    ns.Print("Route stopped.")
end

-- "[3/24] " (current stop of all stops) for the arrow and the tracking line; "" when no route runs.
function ns.RouteLabel()
    local r = Route()
    if not r then return "" end
    return string.format("|cff88ccff[%d/%d]|r ", r.i or 1, #r.stops)
end

-- Orders raw stops into the shortest loop from where you stand, saves the route and tracks the first stop.
-- name is the full label for chat ("Treasures in Eversong"); zoneKey and sec tie it to a book page.
local function Start(raw, name, zoneKey, sec)
    local stops, inst = Place(raw)
    if #stops == 0 then
        ns.Print("Nothing with a known spot is left there (" .. name .. ").")
        return
    end
    local start
    local pinst, pwx, pwy = ns.PlayerWorld()
    if pinst and pinst == inst then start = { wx = pwx, wy = pwy } end
    local path = Order(stops, start)
    local saved = {}
    for i, s in ipairs(path) do saved[i] = { k = s.k, c = s.c } end
    ns.cdb.route = { zone = zoneKey, sec = sec, label = name, stops = saved, i = 1 }
    local yards = RouteLength(path, start)
    ns.Print(string.format("Route: %d stops, about %s. The arrow moves on as you finish each one; right-click it to skip one.",
        #path, yards >= 1760 and string.format("%.1f miles", yards / 1760) or string.format("%d yards", math.floor(yards))))
    Go(1)
end

-- Plans a route through the open places of these sections (keys) of a zone. label names it in chat;
-- sec is set only for routes started from a book page.
function ns.PlanRoute(zone, secKeys, label, sec)
    if not zone then ns.Print("Open a zone first.") return end
    local raw = {}
    for _, k in ipairs(secKeys) do
        if zone.sections[k] then StopsFor(zone, k, raw) end
    end
    Start(raw, (label or "") .. " in " .. (zone.short or zone.name), zone.key, sec)
end

-- The delve you are standing in: the delve item whose Sturdy Chests are on your current map, or nil.
function ns.CurrentDelve()
    for _, z in ipairs(ns.ZONES) do
        for _, d in ipairs(z.sections.delve.items) do
            for _, ch in ipairs(d.children or {}) do
                if ch.kind == "point" then
                    for _, sp in ipairs(ch.spots) do
                        if ns.PlayerOnMap(sp.map) then return d end
                    end
                end
            end
        end
    end
end

-- Plans a route through the unopened Sturdy Chests of the delve you are in.
function ns.PlanDelveRoute(delve)
    local raw = {}
    for _, ch in ipairs(delve.children or {}) do
        if ch.kind == "point" and not ch.done and not ch.hidden then
            local spot
            for _, sp in ipairs(ch.spots) do if ns.PlayerOnMap(sp.map) then spot = sp; break end end
            if spot then raw[#raw + 1] = { k = ch.key, spot = spot } end
        end
    end
    Start(raw, "Sturdy Chests in " .. (delve.name or "this delve"), delve.zone and delve.zone.key, "delve")
end

-- Plans a route for the section a book page shows.
function ns.PlanRouteForSection(zone, secKey)
    -- inside a delve, the Delves page plans a route through its chests instead of the entrances
    local inside = secKey == "delve" and ns.CurrentDelve()
    if inside then ns.PlanDelveRoute(inside) return end
    local name
    for _, s in ipairs(ns.SECTIONS) do if s.key == secKey then name = s.name end end
    ns.PlanRoute(zone, { secKey }, name, secKey)
end

-- Plans a route through every pin kind that is switched on.
function ns.PlanRouteForPins(zone)
    local keys, names = {}, {}
    for _, k in ipairs(ns.PIN_KINDS) do
        if ns.PinOn(k[1]) then keys[#keys + 1] = k[1]; names[#names + 1] = k[2] end
    end
    if #keys == 0 then ns.Print("Every pin kind is off; tick some first.") return end
    ns.PlanRoute(zone, keys, #names == 1 and names[1] or "Pinned places")
end

------------------------------------------------------------------------
-- drawing (world map canvas or the book's map)
------------------------------------------------------------------------

local pools = setmetatable({}, { __mode = "k" })   -- canvas -> reused lines and number labels

-- Draws the rest of the route on a canvas showing mapID, as numbered stops joined by lines (the first
-- leg brighter). w, h: canvas size; scale: divide sizes by it.
function ns.DrawRoute(canvas, w, h, mapID, scale)
    local pool = pools[canvas]
    if not pool then pool = { lines = {}, labels = {} }; pools[canvas] = pool end
    for _, l in ipairs(pool.lines) do l:Hide() end
    for _, l in ipairs(pool.labels) do l:Hide() end
    local r = Route()
    if not r or not mapID or not canvas.CreateLine then return end
    scale = scale or 1
    local pts = {}
    for i = r.i or 1, #r.stops do
        local s = r.stops[i]
        if not StopDone(s) then
            local it = ns.items[s.k]
            local res = it and ns.Resolve(it, s.c)
            local x, y
            if res and res.spot then x, y = ns.MapPosOn(res.spot, mapID) end
            if x then pts[#pts + 1] = { x = x * w, y = -y * h, n = i } end
        end
    end
    for i = 1, #pts - 1 do
        local l = pool.lines[i]
        if not l then
            l = canvas:CreateLine(nil, "OVERLAY")
            pool.lines[i] = l
        end
        l:SetThickness(3 / scale)
        l:SetColorTexture(0.45, 0.8, 1, i == 1 and 0.95 or 0.6)
        l:SetStartPoint("TOPLEFT", canvas, pts[i].x, pts[i].y)
        l:SetEndPoint("TOPLEFT", canvas, pts[i + 1].x, pts[i + 1].y)
        l:Show()
    end
    for i, p in ipairs(pts) do
        local f = pool.labels[i]
        if not f then
            f = canvas:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            f:SetTextColor(0.6, 0.9, 1)
            f:SetShadowColor(0, 0, 0, 1)
            f:SetShadowOffset(1, -1)
            pool.labels[i] = f
        end
        local font, _, flags = f:GetFont()
        if font then f:SetFont(font, math.max(4, 11 / scale), flags) end
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", canvas, "TOPLEFT", p.x + 5 / scale, p.y + 2 / scale)
        f:SetText(p.n)
        f:Show()
    end
end
