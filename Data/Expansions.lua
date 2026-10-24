-- Completion: the expansions along the top of the book. Midnight and The War Within have full guides; the older
-- ones (legacy = true) have every zone, achievement, dungeon, raid and journal collectible placed (Data/Legacy/,
-- Tools/gen_legacy.py) with their guides still to come.
--
-- To bring one online later: give it zones (same format as Data/Zones.lua), an achievement list (like
-- Data/Achievements.lua), spots (Tools/gen.lua against that expansion's spot data) and ready = true.

local _, ns = ...

ns.EXPANSIONS = {
    { key = "classic", short = "Classic", name = "Classic", ready = true, legacy = true,
      plan = { "Eastern Kingdoms and Kalimdor zone exploration", "Classic quest and reputation achievements",
               "Classic dungeons and raids", "Old-world rares, treasures and collectibles" } },
    { key = "tbc", short = "TBC", name = "The Burning Crusade", ready = true, legacy = true,
      plan = { "Outland exploration and Loremaster of Outland", "Aldor, Scryers, Sha'tari Skyguard, Netherwing",
               "Burning Crusade dungeons and raids", "Outland mounts and pets" } },
    { key = "wotlk", short = "WotLK", name = "Wrath of the Lich King", ready = true, legacy = true,
      plan = { "Northrend exploration and Loremaster of Northrend", "Argent Tournament and Northrend reputations",
               "Wrath dungeons and raids", "Northrend rares and collectibles" } },
    { key = "cata", short = "Cata", name = "Cataclysm", ready = true, legacy = true,
      plan = { "Vashj'ir, Deepholm, Uldum, Hyjal, Twilight Highlands", "Molten Front and Tol Barad",
               "Cataclysm dungeons and raids", "Cataclysm rares and collectibles" } },
    { key = "mop", short = "MoP", name = "Mists of Pandaria", ready = true, legacy = true,
      plan = { "Pandaria exploration and treasures", "Timeless Isle and Isle of Thunder",
               "Pandaria reputations", "Mists dungeons, raids and collectibles" } },
    { key = "wod", short = "WoD", name = "Warlords of Draenor", ready = true, legacy = true,
      plan = { "Draenor exploration, treasures and rares", "Garrison achievements", "Tanaan Jungle",
               "Draenor dungeons, raids and collectibles" } },
    { key = "legion", short = "Legion", name = "Legion", ready = true, legacy = true,
      plan = { "Broken Isles exploration, treasures and rares", "Broken Shore and Argus",
               "Legion reputations and class halls", "Legion dungeons, raids and collectibles" } },
    { key = "bfa", short = "BfA", name = "Battle for Azeroth", ready = true, legacy = true,
      plan = { "Kul Tiras and Zandalar exploration, treasures and rares", "Nazjatar and Mechagon",
               "Island Expeditions, Warfronts, Visions", "BfA dungeons, raids and collectibles" } },
    { key = "sl", short = "SL", name = "Shadowlands", ready = true, legacy = true,
      plan = { "Shadowlands exploration, treasures and rares", "Covenants, Torghast, the Maw, Korthia, Zereth Mortis",
               "Shadowlands reputations", "Shadowlands dungeons, raids and collectibles" } },
    { key = "df", short = "DF", name = "Dragonflight", ready = true, legacy = true,
      plan = { "Dragon Isles exploration, treasures and rares", "Dragonriding glyphs and races",
               "Zaralek Cavern, the Emerald Dream, Time Rifts", "Dragonflight dungeons, raids and collectibles" } },
    { key = "tww", short = "TWW", name = "The War Within", ready = true,
      plan = { "Khaz Algar exploration, treasures and rares", "Delves, Undermine, Siren Isle, K'aresh",
               "Worldsoul Saga storylines", "War Within dungeons, raids and collectibles" } },
    { key = "midnight", short = "Midnight", name = "Midnight", ready = true },
    -- not an expansion: Midnight's PvP on a book of its own, so the PvE pages stay PvE
    { key = "pvp", short = "PvP", name = "Player vs. Player", ready = true },
    -- not an expansion: achievements of no expansion (professions, pet battles, collections, characters, older PvP)
    { key = "general", short = "General", name = "General", ready = true, legacy = true },
    -- not an expansion: the holidays and the Darkmoon Faire, one page each (Seasonal.lua)
    { key = "seasonal", short = "Seasonal", name = "Seasonal events", ready = true, seasonal = true },
}

-- The older expansions' keys, for matching their achievements to their own pages only (Model.lua MatchAch).
ns.LEGACY_EXP = {}
for _, e in ipairs(ns.EXPANSIONS) do if e.legacy then ns.LEGACY_EXP[e.key] = true end end
