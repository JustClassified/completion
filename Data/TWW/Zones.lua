-- Completion: The War Within's zones, added to the book after Midnight's (same fields as Data/Zones.lua, plus
-- exp = "tww"). The bookmark along the top shows one expansion's zones at a time.

local _, ns = ...

local TWW = {
    {
        key = "dorn", name = "Isle of Dorn", short = "Isle of Dorn", map = 2248, maps = { 2248, 2339, 2269 },
        iconAch = 40831,
        desc = "The earthen's island home under the storm. Dornogal counts as part of this page.",
        story = { 20118 }, side = { 20595 },
        factions = { 2590 },                            -- Council of Dornogal
        keywords = { "Isle of Dorn", "Dornogal" },
        instances = { "The Rookery", "Cinderbrew Meadery", "Earthcrawl Mines", "Fungal Folly", "Kriegval's Rest" },
    },
    {
        key = "deeps", name = "The Ringing Deeps", short = "Ringing Deeps", map = 2214, maps = { 2214 },
        iconAch = 40825,
        desc = "The machine-heart of Khaz Algar below the Isle of Dorn, Gundargaz and the Waterworks.",
        story = { 19560 }, side = { 40799 },
        factions = { 2594 },                            -- The Assembly of the Deeps
        keywords = { "Ringing Deeps", "Gundargaz" },
        instances = { "The Stonevault", "Darkflame Cleft", "The Waterworks", "The Dread Pit", "Excavation Site 9" },
    },
    {
        key = "undermine", name = "Undermine", short = "Undermine", map = 2346,
        maps = { 2346, 2374, 2406, 2407, 2408, 2409, 2411, 2428 },
        iconAch = 41587,
        desc = "Patch 11.1: the goblin capital under the Ringing Deeps, its cartels and the Gallagio.",
        story = { 40900 }, side = { 40894 },
        factions = { 2653, 2673, 2675, 2677, 2671, 2669, 2685 },   -- Cartels of Undermine, the four cartels, Darkfuse, the Gallagio club
        keywords = { "Undermine", "Gallagio", "Liberation of Undermine" },
        instances = { "Operation: Floodgate", "Liberation of Undermine", "Sidestreet Sluice" },
    },
    {
        key = "hallowfall", name = "Hallowfall", short = "Hallowfall", map = 2215, maps = { 2215 },
        iconAch = 40826,
        desc = "The cavern lit by the Beledar crystal, held by the Arathi of the Sacred Flame.",
        story = { 20598 }, side = { 40844 },
        factions = { 2570, 2688 },                      -- Hallowfall Arathi, Flame's Radiance
        keywords = { "Hallowfall", "Mereldar", "Beledar" },
        instances = { "Priory of the Sacred Flame", "The Dawnbreaker", "Mycomancer Cavern",
                      "Nightfall Sanctum", "The Sinkhole", "Skittering Breach" },
    },
    {
        key = "azjkahet", name = "Azj-Kahet", short = "Azj-Kahet", map = 2255, maps = { 2255, 2256, 2213, 2216, 2343, 2344 },
        iconAch = 40822,
        desc = "The nerubian empire under Khaz Algar. The City of Threads counts as part of this page.",
        story = { 19559 }, side = { 40636 },
        factions = { 2600, 2601, 2605, 2607 },          -- The Severed Threads and its three factions
        keywords = { "Azj-Kahet", "City of Threads", "Nerub-ar" },
        instances = { "Ara-Kara, City of Echoes", "City of Threads", "Nerub-ar Palace", "The Underkeep", "Tak-Rethan Abyss", "The Spiral Weave" },
    },
    {
        key = "siren", name = "Siren Isle", short = "Siren Isle", map = 2369, maps = { 2369, 2375 },
        iconAch = 41131,
        desc = "Patch 11.0.7: a storm-wrapped island of shipwrecks, Naga and the Kul Tiran excavation.",
        story = { 41042 }, side = {},
        factions = {},
        keywords = { "Siren Isle" },
        instances = {},
    },
    {
        key = "karesh", name = "K'aresh", short = "K'aresh", map = 2371, maps = { 2371, 2398, 2472 },
        iconAch = 42740,
        desc = "Patch 11.2: the ethereals' broken homeworld. Tazavesh counts as part of this page.",
        story = { 42299 }, side = { 42739 },
        factions = { 2658 },                            -- The K'aresh Trust
        keywords = { "K'aresh", "Tazavesh" },
        instances = { "Eco-Dome Al'dani", "Manaforge Omega", "Archival Assault" },
    },
    {
        key = "tww", name = "The War Within", short = "The War Within", overview = true, maps = { 2274, 2276 },
        iconAch = 20597,
        desc = "Everything not tied to one zone: the campaign, Loremaster, delves and dungeons found nowhere else, and every other War Within achievement. The total here is the whole expansion.",
        story = { 20597, 20596, 41818 }, side = {},
        factions = {},
        keywords = {},
        instances = {},
    },
}

for _, z in ipairs(TWW) do
    z.exp = "tww"
    ns.ZONES[#ns.ZONES + 1] = z
end

-- War Within delve maps, so Sturdy Chests find their delve.
for m, name in pairs({
    [2249] = "Fungal Folly", [2250] = "Kriegval's Rest", [2251] = "The Waterworks", [2259] = "Tak-Rethan Abyss",
    [2269] = "Earthcrawl Mines", [2277] = "Nightfall Sanctum", [2299] = "The Underkeep", [2301] = "The Sinkhole",
    [2302] = "The Dread Pit", [2310] = "Skittering Breach", [2312] = "Mycomancer Cavern", [2347] = "The Spiral Weave",
    [2396] = "Excavation Site 9", [2420] = "Sidestreet Sluice", [2422] = "Sidestreet Sluice",
    [2452] = "Archival Assault", [2455] = "Archival Assault", [2476] = "Archival Assault",
}) do ns.DELVE_MAPS[m] = name end

