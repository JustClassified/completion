-- Completion: the War Within delves for the delve pages: map, Discoveries (chests) and Stories achievements,
-- zone and entrance. Same shape as Data/Delves.lua; the story walkthroughs live in Data/TWW/Guides.lua.
-- extra = stories the delve offers that its Stories achievement doesn't need.

local _, ns = ...

local TWW_DELVES = {
    ["Fungal Folly"] = { map = 2249, chests = 40803, stories = 40525, zone = "dorn", at = { 2248, 52.3, 66.0 },
        extra = { { n = "Teleporter Tremors", d = "Help Engineer Fizzlepickle fix his teleporters, clear the Black Blood with the Blower, then defeat Lil Leacher." } } },
    ["Kriegval's Rest"] = { map = 2250, chests = 40807, stories = 40526, zone = "dorn", at = { 2248, 62.0, 42.0 },
        extra = { { n = "Funny Candles", d = "Use Waxmonger Squick's Funny Candles on Void Bubbles, defeat the Abominable Aberration, then the Faceless One." } } },
    ["Earthcrawl Mines"] = { map = 2269, chests = 40806, stories = 40527, zone = "dorn", at = { 2248, 38.7, 73.6 } },
    ["The Waterworks"] = { map = 2251, chests = 40816, stories = 40528, zone = "deeps", at = { 2214, 42.0, 48.0 } },
    ["The Dread Pit"] = { map = 2302, chests = 40812, stories = 40529, zone = "deeps", at = { 2214, 69.4, 38.4 } },
    ["Excavation Site 9"] = { map = 2396, chests = 41100, stories = 41098, zone = "deeps", at = { 2214, 76.25, 95.85 },
        extra = { { n = "A Knightly Quest", d = "Help Sir Lostalot track Beste Glatisant with the Snufflehounds, then defeat it." },
                  { n = "Culinary Catastrophe", d = "Harvest 144 tentacles for Chef Carl, then defeat Xel'anegh the Many." } } },
    ["Nightfall Sanctum"] = { map = 2277, chests = 40809, stories = 40530, zone = "hallowfall", at = { 2215, 35.1, 46.2 } },
    ["Mycomancer Cavern"] = { map = 2312, chests = 40808, stories = 40531, zone = "hallowfall", at = { 2215, 71.2, 31.1 } },
    ["The Sinkhole"] = { map = 2301, chests = 40813, stories = 40532, zone = "hallowfall", at = { 2215, 50.6, 50.7 } },
    ["Skittering Breach"] = { map = 2310, chests = 40810, stories = 40533, zone = "hallowfall", at = { 2215, 66.6, 61.7 } },
    ["The Underkeep"] = { map = 2299, chests = 40815, stories = 40534, zone = "azjkahet", at = { 2216, 57.3, 64.9 } },
    ["Tak-Rethan Abyss"] = { map = 2259, chests = 40811, stories = 40535, zone = "azjkahet", at = { 2255, 54.8, 72.6 } },
    ["The Spiral Weave"] = { map = 2347, chests = 40814, stories = 40536, zone = "azjkahet", at = { 2255, 45.5, 21.6 } },
    ["Sidestreet Sluice"] = { map = 2420, chests = 41101, stories = 41099, zone = "undermine", at = { 2346, 34.95, 53.14 },
        extra = { { n = "Crocolisk Reintroduction", d = "Release 6 sewer crocolisks and remove the poachers, then defeat Maulspike." },
                  { n = "Explosive Demolition", d = "Disarm the kickbombs, explosives and mines, then defeat Dr. Clavus Geargrave." } } },
    ["Archival Assault"] = { map = 2452, chests = 42679, stories = 42771, zone = "karesh", at = { 2371, 55.0, 48.0 } },
}

for name, info in pairs(TWW_DELVES) do ns.DELVE_INFO[name] = info end
