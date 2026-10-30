-- Completion: which books are switched on. Loaded after every data file and before the code, so a switched-off
-- book's pages, achievements, collectibles, spots and quests are taken out before anything is built (otherwise
-- they would fall back to the Midnight page).
--
-- For now only Midnight (with its PvP book) and the Seasonal pages are on: the other expansions' data is all
-- there, but evaluating it in one go was too much for the game. Add a key to ON to bring a book back. The tests
-- set COMPLETION_ALL_BOOKS to keep every book.

local _, ns = ...

local ON = { midnight = true, pvp = true, seasonal = true }
if COMPLETION_ALL_BOOKS then return end

ns.BOOKS_ON = ON
local function on(exp) return ON[exp or "midnight"] end

for _, e in ipairs(ns.EXPANSIONS or {}) do
    if not ON[e.key] then e.ready = false end
end

local function keep(list, test)
    if not list then return end
    local out = {}
    for _, v in ipairs(list) do if test(v) then out[#out + 1] = v end end
    for i = #list, 1, -1 do list[i] = nil end
    for i, v in ipairs(out) do list[i] = v end
end

keep(ns.ZONES, function(z) return on(z.exp) end)
keep(ns.ACH_GROUPS, function(g) return on(g.exp) end)
keep(ns.COLLECT_SETS, function(s) return on(s.exp) end)
keep(ns.POINTS, function(p) return on(p.exp) end)

-- the older expansions' and The War Within's own lists (their pages are gone, so they would have nowhere to go)
ns.LEGACY_MOUNTS, ns.LEGACY_PETS, ns.LEGACY_WILD, ns.LEGACY_TOYS, ns.LEGACY_QUESTS = nil, nil, nil, nil, nil
ns.WILD_PETS = nil
