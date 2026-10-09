-- Completion: every achievement that counts toward Midnight 100%.
-- From the "added in Midnight" achievement list (checked 2026-09-29, 12.1), 753 entries before cleanup.
--
-- Left out on purpose: Feats of Strength, Legion Remix legacy, guild runs, statistics, level-90 / alt
-- counters, Timewalking, War Within leftovers, anything Blizzard marks [DNT] or Hidden, the old-world
-- pet battle "Battler of ..." set, housing chores that span every expansion (only Midnight Lumberjack
-- stays), and the unused copies 62413 (Curse of Ula'tek) and 62620 (Allied Race: Haranir).
--
-- The game is asked about each ID live; an ID the client doesn't know is simply hidden.
-- Where an achievement lands (a zone, a dungeon, a delve or the Midnight page) is worked out in
-- Model.lua from its spots, its name and criteria, and its parent meta-achievement.

local _, ns = ...

local function R(a, b)
    local t = {}
    for i = a, b do t[#t + 1] = i end
    return t
end

local function Join(...)
    local out = {}
    for _, part in ipairs({ ... }) do
        if type(part) == "table" then
            for _, v in ipairs(part) do out[#out + 1] = v end
        else
            out[#out + 1] = part
        end
    end
    return out
end

ns.ACH_GROUPS = {
    { "Quests", {
        41802, 41803, 41804, 41805, 41806, 42045, 42117, 42278, 60891, 61219, 61452, 61506, 61574, 61739,
        61864, 61910, 61916, 61942, 61957, 62105, 62110, 62191, 62297, 62385, 63633, 63641 } },
    { "Exploration", {
        61052, 61081, 61082, 61083, 61263, 61264, 61344, 61453, 61455, 61507, 61520, 61839, 61854, 61855,
        61856, 61857, 61859, 61860, 61861, 61912, 61913, 61922, 61960, 61961, 62057, 62104, 62120, 62121,
        62122, 62125, 62126, 62130, 62133, 62185, 62186, 62187, 62188, 62199, 62200, 62201, 62202, 62256,
        62260, 62261, 62267, 62269, 62270, 62288, 62289, 62290, 62291, 62386, 62600, 62601, 62604, 62649,
        63358, 63359, 63381, 63382, 63390, 63432, 63596, 63598, 63599, 63600, 63601, 63610, 63619, 63620,
        63630, 63636, 63639, 63640, 63653, 63662 } },
    { "Abundance", {
        42283, 61681, 61937, 61938, 61939, 61940, 61941, 61943, 62266, 62268, 62324, 62325, 62326, 62329,
        62330, 62331, 62332, 62333, 62336, 62337, 62338, 62339, 62340, 62341 } },
    { "Abyss Anglers", Join(62117, 62118, 62119, R(62207, 62222), 62271, 62272, 62342, 62343, 62506,
        R(62759, 62763), R(62772, 62778), 62829, 62832) },
    { "Fishing", { 63510, 63512, 63629, 63632, 63634, 63635 } },
    { "Skyriding", Join(R(61521, 61552), R(61555, 61564), 61576, 61581, 61582, 61583, 61584,
        63394, 63395, R(63420, 63428), 63430) },
    { "Reputation", { 62190, 62192, 62262, 62263, 62264, 62265, 63631, 63838 } },
    { "Dungeons", Join(41287, 41288, 41291, 41960, 41961, 41962, 61212, 61213, 61214, 61508, 61509, 61510,
        61567, 61568, R(61638, 61649), R(62145, 62152), R(62193, 62196), 62282, 62283, 62284) },
    { "Raids", Join(61346, R(61366, 61381), 61454, 61487, 61488, 61489, 61514, 61635, 61636, 61637, 61911,
        61936, 62058, 62106, 62352, 62406, 63237, 63240, 63241, 63250, 63254, 63391, 63397, 63418, 63476,
        R(63520, 63532), 63609, 63645, 63656, 63669, 63670, 63681, 63682, 63683) },
    { "Delves", Join(R(61707, 61734), 61741, 61832, 61835, 61836, 61863, R(61892, 61901), 61906, 62206,
        63170, 63171, 63434, 63435, 63436, 63437) },
    { "Prey", Join(42701, 42702, 42703, 61386, 61387, 61388, 61389, 61391, 61392, R(62134, 62144),
        R(62153, 62169), R(62173, 62184), 62351, 62383, 62403, 63415, 63416, 63451, 63452, 63453, 63454,
        63457, 63642, 63643, 63644) },
    { "Ritual Sites", Join(R(62450, 62454), R(62521, 62556), R(62558, 62562), 62621, 62622, R(62940, 62943),
        63182) },
    { "Void Assaults", Join(62498, 62499, R(62507, 62513), 62518, 62563, R(62568, 62574), R(62606, 62610),
        62873, 62874, R(62880, 62883), 62887, 62896, R(62898, 62901), 62903, 62904, 62905, 62909, 62917,
        62919, 62944, 62945, 62949, 63264, 63323, 63325, 63348, 63349, R(63383, 63386)) },
    { "Lorewalking", { 61442 } },
    { "Professions", Join(R(42786, 42798), 60888, R(61438, 61441), 62223, R(62232, 62252)) },
    { "Pet Battles", { 61091, 62492 } },
    { "Collections", { 61586, 61843, 61858, 62096, 62103, 63472, 63473, 63608 } },
    { "Housing", { 62370 } },
    { "PvP", Join(R(61221, 61232), 61234, 61238, 61265, 61266, R(61446, 61449), 61464, 61465,
        R(61953, 61956), 61958, 61959, 62107, 62108, 62109, R(62111, 62116), 62493, 62494, 62514, 62516,
        62517, 63167, R(63695, 63699)) },
    { "World Events", Join(61335, 61336, 61792, 61793, R(61878, 61883), 61886, 61887, 63253, 63400) },
}

-- Faction-only achievements: 1 = Alliance, 2 = Horde. Everything else is for both.
ns.ACH_SIDE = {
    [62103] = 1, [62096] = 2,      -- Insurmountable Collection
    [61958] = 1, [61959] = 2,      -- Focused Target
    [61336] = 1, [61335] = 2,      -- Flame Warden / Flame Keeper of Midnight
}

-- What counts toward 100% out of the box: the achievement tabs you finish by playing normally.
-- The "What counts" page in Options changes these; hard modes are one switch of their own.
ns.SCOPE_ORDER = {
    "Quests", "Exploration", "Abundance", "Abyss Anglers", "Fishing", "Skyriding", "Reputation", "Delves",
    "Prey", "Ritual Sites", "Void Assaults", "Horrific Visions", "Lorewalking", "Dungeons", "Raids", "Professions", "Pet Battles",
    "Collections", "Housing", "PvP", "World Events",
}
ns.SCOPE_DEFAULTS = {
    Quests = true, Exploration = true, Abundance = true, ["Abyss Anglers"] = true, Fishing = true,
    Skyriding = true, Reputation = true, Delves = true, Prey = true, ["Ritual Sites"] = true,
    ["Void Assaults"] = true, ["Horrific Visions"] = true, Lorewalking = true, Dungeons = true, Raids = true, Professions = true,
    ["Pet Battles"] = true, Collections = true, Housing = true,
    PvP = false,              -- rated play, honor grinds
    ["World Events"] = false, -- only doable a few weeks a year
}

-- Hard modes: Mythic raid and dungeon achievements, Glory metas, Nightmare Prey, Hall of Fame.
-- Matched against the achievement's live name. Collectibles whose source says Mythic follow the same switch.
ns.HARD_PATTERNS = { "^Mythic:", "^Glory of", "Nightmare", "Hall of Fame" }
