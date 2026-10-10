-- Completion: the zones, what belongs to them, and the sections every zone page shows.
--
-- Zone fields:
--   key, name, short (tab tooltip), map (main uiMapID, drawn on the left page), maps (every uiMapID that
--   counts as this zone), desc (left page blurb), iconAch (achievement whose icon is the tab icon),
--   story / side (Loremaster achievements from Data/Lore.lua), factions (faction IDs for Reputation),
--   keywords (text that ties a live achievement to this zone), instances (fallback instance names; the
--   Encounter Journal is asked first and wins).
--
-- Everything else is found live: achievements come from the game's own "Midnight" achievement categories,
-- dungeons and raids from the Encounter Journal entrances on each map, delves from the map's delve POIs.

local _, ns = ...

ns.ZONES = {
    {
        key = "eversong", name = "Eversong Woods", short = "Eversong", map = 2395, maps = { 2395, 2393 },
        iconAch = 61960,
        desc = "The sin'dorei homeland under a new sun. Silvermoon City counts as part of this page.",
        story = { 41802 }, side = { 61957, 60891 },
        factions = { 2710, 2712, 2713, 2711, 2714 },   -- Silvermoon Court and its Blood Knights, Farstriders, Magisters, Shades of the Row
        keywords = { "Eversong", "Silvermoon" },
        instances = { "Windrunner Spire", "Murder Row" },
    },
    {
        key = "queldanas", name = "Isle of Quel'Danas", short = "Quel'Danas", map = 2424, maps = { 2424, 2432 },
        iconAch = 42045,
        desc = "The Sunwell's island, home of Magisters' Terrace and the March on Quel'Danas.",
        story = {}, side = {},
        factions = {},
        keywords = { "Quel'Danas", "Sunwell" },
        instances = { "Magisters' Terrace", "March on Quel'Danas" },
    },
    {
        key = "zulaman", name = "Zul'Aman", short = "Zul'Aman", map = 2437, maps = { 2437, 2536 },
        iconAch = 62125,
        desc = "The Amani heartland in the east of Quel'Thalas, Atal'Aman included.",
        story = { 41803 }, side = { 61452 },
        factions = { 2696 },
        keywords = { "Zul'Aman", "Atal'Aman" },
        instances = { "Maisara Caverns", "Den of Nalorakk" },
    },
    {
        key = "harandar", name = "Harandar", short = "Harandar", map = 2413, maps = { 2413, 2576 },
        iconAch = 61263,
        desc = "The Haranir rootlands under the great canopy, the Den included.",
        story = { 41804 }, side = { 61739, 61574, 42278, 61506 },
        factions = { 2704 },
        keywords = { "Harandar", "Haranir" },
        instances = { "The Blinding Vale", "The Dreamrift", "Chimaerus" },
    },
    {
        key = "voidstorm", name = "Voidstorm", short = "Voidstorm", map = 2405, maps = { 2405, 2444, 2527, 2599, 2600, 2646 },
        iconAch = 62126,
        desc = "The Void-torn realm past the rift: Slayer's Rise, Stormarion and the Naigtal and Val invasions.",
        story = { 41806 }, side = { 61864, 62385 },
        factions = { 2699, 2770 },                      -- The Singularity, Slayer's Duellum (Slayer's Rise PvP)
        keywords = { "Voidstorm", "Slayer's Rise", "Stormarion" },
        instances = { "Voidscar Arena", "Nexus-Point Xenas", "The Voidspire" },
    },
    {
        key = "coiled", name = "The Coiled Isle", short = "Coiled Isle", map = 2512, maps = { 2512, 2509, 2613, 2642 },
        iconAch = 63359,
        desc = "Patch 12.1: Ula'tek's cursed island, the Vaults of Atal'Utek and Captain Tokka's fishing.",
        story = { 62297 }, side = { 63641, 63633 },
        factions = { 2772, 2773 },
        keywords = { "Coiled Isle", "Atal'Utek", "Ula'tek" },
        instances = { "Altar of Fangs", "The Venomous Abyss" },
    },
    {
        key = "midnight", name = "Midnight", short = "Midnight", overview = true,
        iconAch = 62110,
        desc = "Everything not tied to one zone: the campaign, Loremaster, delves and dungeons found nowhere else, and every other Midnight achievement. The total here is the whole expansion.",
        story = { 62110, 42045, 41805, 42117, 61916 }, side = { 61910, 61219, 62105, 61942 },
        -- Delves (current season), Ritual Sites, Preyhunter's Journey, Prey: Season 1, Valeera Sanguinar
        factions = { 2796, 2792, 2808, 2764, 2744 },
        keywords = {},
        instances = {},
    },
}

-- Sections, in the order the Zone Progress list shows them.
ns.SECTIONS = {
    { key = "story",    name = "Storyline",        verb = "questlines" },
    { key = "side",     name = "Side Quests",      verb = "questlines" },
    { key = "achv",     name = "Achievements" },
    { key = "treasure", name = "Treasures" },
    { key = "rare",     name = "Rares" },
    { key = "collect",  name = "Collectibles" },
    { key = "instance", name = "Dungeons & Raids" },
    { key = "delve",    name = "Delves" },
    { key = "rep",      name = "Reputation" },
    { key = "prof",     name = "Professions" },
    -- shown on an expansion's overview page, never counted toward 100% (housing, levelling, gear)
    { key = "other",    name = "Other (not counted)", uncounted = true },
}
-- the sections a zone page lists: everything but the overview-only Other
ns.ZONE_SECTIONS = {}
for _, s in ipairs(ns.SECTIONS) do if not s.uncounted then ns.ZONE_SECTIONS[#ns.ZONE_SECTIONS + 1] = s end end

-- Delve maps as the spot data names them, so Sturdy Chests can find their delve.
ns.DELVE_MAPS = {
    [2502] = "Shadow Enclave", [2504] = "Twilight Crypts", [2505] = "Gulf of Memory", [2575] = "Gulf of Memory",
    [2506] = "Shadowguard Point", [2510] = "The Grudge Pit", [2525] = "The Darkway",
    [2528] = "Sunkiller Sanctum", [2571] = "Sunkiller Sanctum", [2535] = "Atal'aman",
    [2545] = "Parhelion Plaza", [2547] = "Collegiate Calamity", [2635] = "Gnarldor Isle", [2633] = "Ring of Glory",
}

-- Achievements that must never be counted: unused copies in the game files.
ns.IGNORE_ACH = { [62413] = true }

-- Base skill lines of the professions, for the Professions section (knowledge treasures only count
-- for professions this character has).
ns.PROF_SKILL = {
    Alchemy = 171, Blacksmithing = 164, Enchanting = 333, Engineering = 202, Herbalism = 182, Inscription = 773,
    Jewelcrafting = 755, Leatherworking = 165, Mining = 186, Skinning = 393, Tailoring = 197,
}
