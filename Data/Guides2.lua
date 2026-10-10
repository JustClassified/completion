-- Completion: step-by-step guides for Midnight achievements, researched from players' tips (own words).
-- Same shape as the other Guides files; loaded after them, before the generated guides, so these win
-- over generated steps but never over an earlier hand-written guide of the same achievement.

local _, ns = ...

local EVERSONG, SILVERMOON, ZULAMAN, HARANDAR, VOIDSTORM, COILED, VAULTS, ARCANTINA =
    2395, 2393, 2437, 2413, 2405, 2512, 2509, 2541

local G = {}

-- GUIDES

G[42045] = {
    steps = {
        { t = "Play the Midnight campaign zone by zone: Eversong, Zul'Aman, Harandar, then Voidstorm (each zone achievement lists its questlines)." },
        { t = "Reach level 86 before the Voidstorm part; the quest log tells you to level if you're below it." },
        { t = "Finish the last chapter; the achievement completes with it." },
    },
    tips = { "Once one character has finished the whole campaign, alts get a skip option from the NPC who gives Midnight's first quest." },
}
G[42117] = {
    steps = {
        { t = "At max level, do each listed questline (expand the achievement; each row leads to its first quest)." },
        { t = "Some chapters were released over several weeks; if the next one isn't there, check after the weekly reset." },
    },
    tips = { "After the campaign, Corlen Hordralin sells paintings for your house." },
}
G[42278] = {
    steps = {
        { t = "Do the Legends of the Haranir questlines on one character: credit from alts doesn't add up." },
        { t = "Each week, pick up the relic quest from the Haranir legends keeper outside the Den (in a hut on top; entrance at 53.5, 53.2)." },
        { t = "Follow each relic's story; new ones open weekly." },
    },
}
G[61574] = {
    steps = {
        { t = "Each week, talk to the legends keeper in the hut above the Den in Harandar (entrance at 53.5, 53.2) for the Legends of the Haranir relic quest.", at = { HARANDAR, 53.52, 53.20 } },
        { t = "Learn the story of each relic; it's once per week per account, so seven relics take seven weeks." },
    },
}
G[60891] = {
    steps = {
        { t = "Find Valeera; behind her, by Telemancer Astrandis's desk, lies a letter from Anduin Wrynn. Reading it starts A Favor for the Lion." },
        { t = "In Zul'Aman, do Valeera's three quests at Speaker's Rest; she then gives you the delve quest." },
        { t = "Finish both storylines, including the last quest in her chain; skipping it is the usual reason the achievement doesn't pop." },
    },
}
local sojourner = function(zone, first)
    return {
        steps = {
            { t = "Finish " .. zone .. "'s main campaign first: most optional storylines unlock with it." .. (first or "") },
            { t = "Expand the achievement: each optional storyline has its own row and its first quest giver; do them in any order." },
            { t = "If a storyline's start is missing, it's tied to later campaign progress or a renown level; check again after the next chapter." },
        },
    }
end
G[61452] = sojourner("Zul'Aman", " Loa worship also opens some of them.")
G[61739] = sojourner("Harandar", " Trials of the Shul'ka and The Greenspeaker's Vigil need campaign progress.")
G[61864] = sojourner("Voidstorm")
G[61957] = {
    steps = {
        { t = "Expand the achievement: each optional Eversong storyline has its own row and its first quest giver (several start in Silvermoon)." },
        { t = "These don't need the Eversong campaign; one (Paladin Rescue) needs level 90." },
        { t = "Do them in any order." },
    },
}
G[62110] = {
    steps = {
        { t = "Finish every zone's quest achievement listed (each has its own guide)." },
        { t = "Do each zone's main campaign first: every Sojourner except Eversong's needs it." },
    },
}
G[61506] = {
    steps = {
        { t = "Finish the three Harandar campaign storylines: Of Caves and Cradles, Call of the Goddess and Emergence." },
        { t = "If you finished the campaign before Midnight went live, pick up The War Beyond the Roots in Silvermoon." },
    },
}
G[61910] = {
    steps = {
        { t = "Do King Mrgl-Mrgl's storylines in the Borean Tundra, Highmountain and Zul'Aman (expand the achievement)." },
        { t = "In the Borean Tundra, the Winterfin Retreat chain starts with Learning to Communicate; inside the cave, also take Escape from the Winterfin Caverns and Keymaster Urmgrgl." },
    },
}
G[63633] = {
    steps = {
        { t = "Finish the Coiled Isle storyline that starts with Olawu at Tokka's Landing; it unlocks the world quest.", at = { COILED, 58.5, 47.2 } },
        { t = "Complete the world quest Ki'clak Snack Attack five times." },
    },
    tips = { "Alts that have done the storyline can each do the world quest, so five max-level characters finish it in one day." },
}
G[63641] = {
    steps = {
        { t = "Expand the achievement: each optional Coiled Isle storyline has its own row." },
        { t = "Tokka's Crew is gated by Captain Tokka's reputation: later parts open at stages 3 and 4." },
        { t = "Fish with the crew to raise that reputation and finish the remaining storylines." },
    },
}

local treasures = function(extra)
    local steps = {
        { t = "Expand the achievement: every treasure has its spot, and tracking leads treasure to treasure." },
        { t = "Hover each treasure's row for its requirement; most need nothing, a few need a small task first." },
    }
    for _, t in ipairs(extra or {}) do steps[#steps + 1] = { t = t } end
    return { steps = steps }
end
G[61960] = treasures({
    "Rookery treasure: buy Tasty Meat from Farstrider Aerieminder and place it by the Mischievous Chick.",
    "Sunstrider Vessel treasure: click the vessel, catch 5 embers from the phoenixes and bring them back.",
})
G[62125] = treasures({ "The tower treasure needs four tower puzzles solved first." })
G[61263] = treasures({ "Sealed Gourd: combine the two ingredients the treasure's note names into the gourd's key item first." })
G[62126] = treasures({
    "The egg treasure is reached through a small minigame.",
    "The Forgotten Oubliette treasure: collect meat nearby and throw it in.",
    "One sits on top of a stone peak; another is inside a building.",
    "If the potion-based treasure doesn't work, relog after drinking it.",
})
local rares = function(note)
    return {
        steps = {
            { t = "Expand the achievement: every rare has its spot; tracking it patrols them and points at any that's up." },
            { t = "Kill each one; elite rares respawn in about 30 minutes, others in about 15." },
        },
        tips = note and { note } or nil,
    }
end
G[61507] = rares("Overfester Hydra lies dormant: walk on it or kill something nearby to wake it. Several rares path around their spot.")
G[61264] = rares("Each rare gives reputation on its first kill.")
G[62122] = rares("Respawn times vary from about 15 to 40 minutes; a loop of the zone usually finds several up.")
G[62130] = rares("Progress here isn't shared by your warband, so do it on one character.")
G[62185] = {
    steps = {
        { t = "Expand the achievement: each painter's easel in Eversong has its spot." },
        { t = "Click each easel. Light Consuming stands on a floating platform above the forest." },
    },
}
local peaks = function(zone)
    return {
        steps = {
            { t = "Expand the achievement: each of " .. zone .. "'s five telescopes has its spot (purple telescopes on high points)." },
            { t = "Fly to each and use it." },
            { t = "If the zone shows 5/5 without completing, go round again: one telescope may need using once more." },
        },
    }
end
G[62288] = peaks("Eversong's")
G[62289] = peaks("Zul'Aman's")
G[62290] = peaks("Harandar's")
G[62291] = peaks("Voidstorm's")
G[62261] = {
    steps = {
        { t = "Start The Party Must Go On right away: it takes four weeks." },
        { t = "Finish the other Eversong achievements listed (each has its own guide) while you wait." },
    },
}
G[62260] = {
    steps = {
        { t = "Start the weekly ones first: Legends Never Die (one relic a week per account) and the Haranir books." },
        { t = "Finish the other Harandar achievements listed (each has its own guide)." },
    },
    tips = { "The slowest of the four zone metas: at least seven weeks." },
}
G[62386] = {
    steps = {
        { t = "Finish the four zone metas: Forever Song, Making an Amani Out of You, That's Aln, Folks! and Yelling into the Voidstorm." },
        { t = "Start the timegated parts first: The Party Must Go On (four weeks) and Legends Never Die (seven weeks, once per account each week)." },
    },
}

G[63358] = {
    steps = {
        { t = "Expand the achievement: every Coiled Isle rare has its spot; tracking it patrols them." },
        { t = "Kill each one. Hisstara is inside a building; Ssa'alik patrols up and down a hill; Farthik the Plunderer appears when you open the Unguarded Chest; Coin-Eye Skully is underwater." },
    },
}
G[63359] = {
    steps = {
        { t = "Expand the achievement: every treasure has its spot; hover each row for its requirement." },
        { t = "Profane Ritual Spoils: click the Mysterious Objects while facing the altar in this order: upper right, upper left, bottom right, bottom left.", at = { COILED, 43.6, 67.4 } },
        { t = "Some treasures need a key or item found elsewhere first; the row's note says which." },
    },
}
G[63390] = {
    steps = {
        { t = "Curse Surges move between five spots every 45 minutes; the map's Events tab shows the current one." },
        { t = "Defeat each surge's boss: the Looming Mutagenitor, Ss'akrithos (Mlurkkr Massacre), the Malformed Leviathan, Vassti the Exalted Broodmother (the Broodmother's Nest) and Venom Lancer Ori'kassi (Siege at the Whispering Marsh)." },
    },
    crit = {
        ["Looming Mutagenitor"] = { t = "Curse Surge at The Forum", at = { { COILED, 26.7, 64.8 } } },
        ["Ss'akrithos"] = { t = "Curse Surge: Mlurkkr Massacre", at = { { COILED, 71.2, 31.3 } } },
        ["Malformed Leviathan"] = { t = "Curse Surge", at = { { COILED, 46.9, 62.2 } } },
        ["Vassti, the Exalted Broodmother"] = { t = "Curse Surge: the Broodmother's Nest", at = { { COILED, 45.2, 28.6 } } },
        ["Venom Lancer Ori'kassi"] = { t = "Curse Surge: Siege at the Whispering Marsh", at = { { COILED, 67.6, 77.8 } } },
    },
}
G[63610] = {
    steps = {
        { t = "Enter the Vaults of Atal'Utek.", at = { COILED, 45.4, 64.9 } },
        { t = "Expand the achievement: each Funerary Inscription has its spot inside the Vaults; read each one." },
    },
}
G[63630] = {
    steps = {
        { t = "Start the timegated parts at once: Oppose the Foes (one Ancient Foe a week, at least three weeks) and Fully Corroded (needs Renown 14 with Zul'jarra's Forces)." },
        { t = "Do the strike, incursion and patrol achievements on the days their events are up (each has its own guide)." },
    },
}
G[63662] = {
    steps = {
        { t = "Expand the achievement: each Coiled Isle lore object has its spot (some inside buildings)." },
        { t = "Read each one; the toy reward goes straight to your toy box." },
    },
}
G[61941] = {
    steps = {
        { t = "Do the Abundance tutorial with Dundun and Chel the Chip (it starts with the Abundance questline in Zul'Aman)." },
        { t = "Finish it to unlock Abundance events." },
    },
}
G[62268] = {
    steps = {
        { t = "Have a Midnight profession at 25 skill or more." },
        { t = "In an Abundance event, find a node marked Artisan for your profession and harvest it. Each spot has its own professions: Eversong (Enchanting, Jewelcrafting, Tailoring), Zul'Aman (Cooking, Leatherworking, Skinning), Harandar (Alchemy, Herbalism, Inscription), Voidstorm (Blacksmithing, Engineering, Mining)." },
    },
}
G[62337] = {
    steps = {
        { t = "Go to an Abundance spot that isn't busy (an empty one is easier), e.g. the den in Zul'Aman when the Abundant Harvest isn't running there." },
        { t = "Gather basic nodes all event long: skin the beasts there (no Skinning needed), or click the Floaret buds in the Harandar grotto's deep-pool section, which respawn fast." },
        { t = "Finish the event with 10,000 or more in Basic Nodes." },
    },
}
G[62338] = {
    steps = {
        { t = "Pick the Abundance spot with your profession's artisan nodes (see Professionals Only)." },
        { t = "Harvest artisan nodes all event long until Artisan Nodes reaches 10,000." },
    },
    tips = { "Players report this is very hard or impossible in one event (about 50 points per node); a double-harvest buff helps." },
}
G[62210] = {
    steps = {
        { t = "Start a dive with Depthdiver Tu'nakit.", at = { ZULAMAN, 68.2, 20.2 } },
        { t = "Collect each listed creature near the start: Finnows almost anywhere, Shallows Scamps (large fish), Brakpuffers near the floor, Zipperfish (small sharks), Porcofrills (spined fish) and an Axetooth Thresher (larger shark)." },
    },
}
G[62215] = { steps = { { t = "Catch each listed Shallows creature during dives." } }, tips = { "Players report this may not be implemented; it may not show in the achievement window." } }
G[62216] = { steps = { { t = "Catch each listed Trench creature during dives." } }, tips = { "Players report this may have been removed; it may not show in the achievement window." } }
G[62775] = {
    steps = {
        { t = "Collect Sunken Relics during dives and buy the first net upgrade (it can catch Barbed Crawlers and Thorny Seahorses)." },
        { t = "Catch the Mythic Champion of Pahk once, then buy the Triple-Thread Net." },
        { t = "With the net, right-click each listed small creature to capture it (the net isn't a button)." },
    },
}
G[63512] = {
    steps = {
        { t = "Raise Captain Tokka's reputation: each rank unlocks more of the fishing progression where these artifacts come from." },
        { t = "Fish in the Coiled Isle's venom waters, its pools and near its caves; each of the ten artifacts has its own source." },
    },
    tips = { "Players report catches by the cave rare, in open venom water and in pools from rank 3 (Cursed Angler) onward." },
}
G[63635] = {
    steps = {
        { t = "Finish the four Tokka achievements listed (each has its own guide)." },
        { t = "The Coiled Huntress: at rank 5 buy the pole from Second Mate Sluggs for 6,000 Voidlight Marl, equip it and talk to Captain Tokka.", at = { COILED, 51.6, 49.8 } },
    },
}

G[61521] = { steps = { { t = "Fly to the The Shining Span glyph; track the achievement and the arrow takes you there." }, { t = "Fly through it on a skyriding mount to collect it." } }, tips = { "You can fly through its spot even when the glyph itself isn't visible." } }
G[61526] = { steps = { { t = "Fly to the Suncrown Tree glyph; track the achievement and the arrow takes you there." }, { t = "Fly through it on a skyriding mount to collect it." } }, tips = { "It's not far up the tree: look near the lower part, not the top." } }
G[61527] = { steps = { { t = "Fly to the Fairbreeze Village glyph; track the achievement and the arrow takes you there." }, { t = "Fly through it on a skyriding mount to collect it." } }, tips = { "It sits in the tree, on one of the low, thick branches." } }
G[61529] = { steps = { { t = "Fly to the Dawnstar Spire glyph; track the achievement and the arrow takes you there." }, { t = "Fly through it on a skyriding mount to collect it." } }, tips = { "On the tower just east of the \"E\" of the village name on the map." } }
G[61533] = { steps = { { t = "Fly to the Temple of Akil'zon glyph; track the achievement and the arrow takes you there." }, { t = "Fly through it on a skyriding mount to collect it." } }, tips = { "Up at the temple." } }
G[61535] = { steps = { { t = "Fly to the Strait of Hexx'alor glyph; track the achievement and the arrow takes you there." }, { t = "Fly through it on a skyriding mount to collect it." } }, tips = { "Out on a piece of the broken bridge." } }
G[61536] = { steps = { { t = "Fly to the Witherbark Bluffs glyph; track the achievement and the arrow takes you there." }, { t = "Fly through it on a skyriding mount to collect it." } }, tips = { "Under the bridge." } }
G[61551] = { steps = { { t = "Fly to the Roots of Shaladrassil glyph; track the achievement and the arrow takes you there." }, { t = "Fly through it on a skyriding mount to collect it." } }, tips = { "It's nowhere near the roots of Shaladrassil; follow the arrow." } }
G[61556] = { steps = { { t = "Fly to the The Ingress glyph; track the achievement and the arrow takes you there." }, { t = "Fly through it on a skyriding mount to collect it." } }, tips = { "On top of the rock." } }
G[61564] = { steps = { { t = "Fly to the Hanaar Outpost glyph; track the achievement and the arrow takes you there." }, { t = "Fly through it on a skyriding mount to collect it." } }, tips = { "It's in Slayer's Rise, the PvP area in the north, which has its own map." } }

local dive = { t = "Start a dive with Depthdiver Tu'nakit off the Zul'Aman coast.", at = { ZULAMAN, 68.2, 20.2 } }
local bubbles = function(n, upgrade)
    local steps = {
        dive,
        { t = "Fish the Abyss Bubbles (vortex bubbles on the sea floor; click the bobber, not the bubble). Some bubbles never run out: the one near the start of the dive area and the one beside the big air vents on the right of the map are reliable." },
        { t = "Keep fishing until " .. n .. " fish in total; tracking the biggest count finishes the smaller ones too." },
    }
    if upgrade then steps[#steps + 1] = { t = "Buy the " .. upgrade .. " upgrade from Depthdiver Jeju." } end
    return { steps = steps }
end
G[62118] = bubbles(25, "Finnow Chum")
G[62119] = bubbles(50, "Murkskimmer Meat")
G[62772] = bubbles(100)
G[62209] = {
    steps = {
        dive,
        { t = "Stay near the start, turn around and spear anything that glows; you can catch about 100 per dive." },
        { t = "Keep going until 500 fish, then buy the Depth Grease upgrade." },
    },
    tips = { "Progress isn't added up across characters: only your best character's count counts." },
}
G[62208] = { steps = { dive, { t = "Catch at least 25 fish in one dive." }, { t = "Buy the Reinforced Joints upgrade from Depthdiver Jeju (relog if the criterion stays grey)." } } }
G[62211] = {
    steps = {
        dive,
        { t = "Collect each listed creature; most live around the ravines and the Champion of Pahk's area: Plecofin (small shark), Crustleech (in and near the ravines), Flitray (small manta), Cragback Sea Turtle (circles near the Champion), Dolphion (in packs), Kobiamora (small shark), Abyss Fangray and Seamare." },
        { t = "Have the Depthdiver's Used Tank first; then this upgrade unlocks." },
    },
}
G[62212] = {
    steps = {
        dive,
        { t = "Collect the deep creatures: Trench Crawlers (crabs on the ground), Murkskimmers, Sightless Skippers (fast mudskippers above the ravine), Umbramot Eels (far right ravine), Gemscale Nymphs (above the far right ravine) and a Depthbash Thresher (the shark guarding the Champion of Pahk)." },
        { t = "Have the Fathom-Tested Tank first." },
    },
}
local relics = function(what, n, eyeglass)
    return {
        steps = {
            eyeglass and { t = "First defeat the Champion of Pahk and buy the Pressurized Eyeglass: without it Ancient Relics can't be looted." } or dive,
            { t = "During dives, loot " .. what .. " from the sea floor; they move around and respawn after a few minutes. The giant skeleton area has many." },
            { t = "Keep going until " .. n .. "; relog if it doesn't pop at the count." },
        },
    }
end
G[62213] = relics("Sunken Relics", 50)
G[62214] = relics("Ancient Relics", 10, true)
G[62506] = {
    steps = {
        dive,
        { t = "Find the Champion of Pahk (99 scales) and spear it from straight above, far enough away that you can't see its counter; that keeps it from charging." },
        { t = "If it charges, rise with it and keep shooting. Get the last catch yourself: someone else landing the final shot doesn't count for you." },
    },
}
local points = function(n)
    return {
        steps = {
            dive,
            { t = "Loot Sunken and Ancient Relics around the giant skeleton; Ancient ones are worth 750 points (needs the Pressurized Eyeglass). Refill air at the vents when your breath runs low." },
            { t = "Good dives give about 50,000 points; keep going until " .. n .. " in total." },
        },
    }
end
G[62272] = points("250,000")
G[62761] = points("1,000,000")
G[62762] = { steps = { dive, { t = "Swim through schools of fish; an Inky Black potion makes them stand out." }, { t = "Keep going until 250 in total." } } }
G[62217] = {
    steps = {
        { t = "Finish each Abyss Anglers achievement listed (each has its own guide)." },
        { t = "The reward adds the Depths blessings to the Altar of Blessings." },
    },
}
G[62266] = { steps = { { t = "Take part in Abundance events; all harvest adds to your lifetime total." }, { t = "Keep going until 10,000,000." } }, tips = { "Players report this one not giving progress at times." } }
G[62332] = {
    steps = {
        { t = "Join the enhanced Abundance event in a raid group: the bar fills fast." },
        { t = "Each 10,000 fills one of five bonuses; keep going until all bonus achievements listed are done at every location." },
    },
}
G[63395] = {
    steps = {
        { t = "Expand the achievement: each of the Coiled Isle's eleven glyphs has its spot." },
        { t = "Fly through each on a skyriding mount." },
    },
}

G[62221] = {
    steps = {
        { t = "Start a dive with Depthdiver Tu'nakit.", at = { ZULAMAN, 68.2, 20.2 } },
        { t = "Swim through schools of fish (small underwater clouds with tiny fish inside); one floats above the rock formation near the start, and many sit in and around the right-hand ravine." },
        { t = "Get 25 in a single dive, then buy the Fresh Depth Nets upgrade." },
    },
}
G[62271] = {
    steps = {
        { t = "Start a dive with Depthdiver Tu'nakit.", at = { ZULAMAN, 68.2, 20.2 } },
        { t = "Catch fish during dives until 100 in total." },
    },
    tips = { "If the count sticks just short, players report finishing it on another character." },
}
G[62147] = {
    steps = {
        { t = "Do the campaign quest Den of Nalorakk: Unforgiven, or reach level 88 on any character." },
        { t = "If you ran the dungeon in follower mode, Zul'jarra isn't where the map marker shows: hand the quest in at 31.6, 83.9 in Zul'Aman.", at = { ZULAMAN, 31.57, 83.87 } },
    },
}
G[61380] = {
    steps = {
        { t = "Expand the achievement: each raid achievement of The Voidspire, The Dreamrift and March on Quel'Danas has its own step guide." },
        { t = "Easiest first: Nothing to See Here (walk off the map) and It's Treason Then (/kneel before the pull)." },
        { t = "Most need 10 or more players; do them on Normal." },
    },
}
G[61568] = {
    steps = {
        { t = "Finish each Midnight Mythic dungeon achievement listed (each has its own guide)." },
        { t = "Mythic difficulty is only open for dungeons in the current season's rotation, so some parts wait for a later season." },
    },
}
G[63237] = {
    steps = {
        { t = "Queue for Sporefall, a one-boss raid, or join a Normal group (Normal is easy)." },
        { t = "Defeat Rotmire." },
    },
}

local valeera = {
    steps = {
        { t = "Run delves with Valeera; every finished delve gives her experience." },
        { t = "Fast way: equip the Dundun's Favor curio on her, run the Ring of Glory's Open Night story, and ride around the arena picking up Mislaid Curiosities (outline mode on High makes them easy to see; avoid the floor traps)." },
        { t = "Repeat until she reaches the level." },
    },
}
G[63435] = valeera
G[63434] = valeera
G[61863] = {
    steps = {
        { t = "Enter Atal'Aman; all its chests are around the lake altar." },
        { t = "One is behind the eagle statue on the right when you face Akil'zon's shrine, one under the bridge in the water, and one against the wall by the southern waterfall." },
        { t = "Some only appear in particular stories; come back on other days for any missing." },
    },
}
G[63170] = {
    steps = {
        { t = "Enter Gnarldor Isle; each Sturdy Chest has its spot inside." },
        { t = "Open every chest; one of them gives a mount item." },
        { t = "Some chests only exist in particular stories; come back on other days for the rest." },
    },
}

G[62144] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for Magister Sunbreaker or Magistrix Emberlash; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62153] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for Senior Tinker Ozwold or L-N-0R the Recycler; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62154] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for Mordril Shadowfell or Deliah Gloomsong; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62155] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for Phaseblade Talasha or Nexus-Edge Hadim; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62156] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for Jo'zolo the Breaker or Zadu, Fist of Nalorakk; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62157] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for The Talon of Jan'alai or The Wing of Akil'zon; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62158] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for Ranger Swiftglade or Lieutenant Blazewing; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62159] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for Petyoll the Razorleaf or Lamyne of the Undercroft; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62160] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for High Vindicator Vureem or Crusader Luxia Maxwell; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62161] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for Praetor Singularis or Consul Nebulor; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62162] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for Executor Kaenius or Imperator Enigmalia; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62163] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for Knight-Errant Bloodshatter or Vylenna the Defector; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62164] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for Lost Theldrin or Neydra the Starving; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62165] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for Thornspeaker Edgath or Thorn-Witch Liset; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62166] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Hard difficulty (Hard unlocks at level 90 through Astalor's quests in the Prey headquarters)." },
        { t = "Pick the contract for Grothoz, the Burning Shadow or Dengzag, the Darkened Blaze; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62167] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for Magister Sunbreaker or Magistrix Emberlash; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62168] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for Senior Tinker Ozwold or L-N-0R the Recycler; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62169] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for Mordril Shadowfell or Deliah Gloomsong; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62173] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for Phaseblade Talasha or Nexus-Edge Hadim; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62174] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for Jo'zolo the Breaker or Zadu, Fist of Nalorakk; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62175] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for The Talon of Jan'alai or The Wing of Akil'zon; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62176] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for Ranger Swiftglade or Lieutenant Blazewing; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62177] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for Petyoll the Razorleaf or Lamyne of the Undercroft; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62178] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for High Vindicator Vureem or Crusader Luxia Maxwell; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62179] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for Praetor Singularis or Consul Nebulor; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62180] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for Executor Kaenius or Imperator Enigmalia; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62181] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for Knight-Errant Bloodshatter or Vylenna the Defector; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62182] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for Lost Theldrin or Neydra the Starving; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62183] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for Thornspeaker Edgath or Thorn-Witch Liset; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
G[62184] = {
    steps = {
        { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
        { t = "Choose Nightmare difficulty (unlocked after Hard)." },
        { t = "Pick the contract for Grothoz, the Burning Shadow or Dengzag, the Darkened Blaze; either one counts. Random hunts rarely offer a specific target." },
        { t = "Track your target down and defeat it; hand in the hunt." },
    },
    tips = { "Its reward item can be bought again later from Construct Ali'a near the hunt table." },
}
local preyMode = function(diff, how)
    return {
        steps = {
            { t = "Pick up hunts at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } },
            { t = "Choose " .. diff .. " difficulty" .. (diff == "Hard" and " (level 90; unlocked through Astalor's quests in the Prey headquarters)." or " (unlocked after Hard).") },
            { t = how },
        },
        tips = diff == "Nightmare" and { "Nightmare adds three mechanics from the start: copies of you that hurt if they reach you, ground effects to dodge, and more. Expect repair bills." } or nil,
    }
end
G[61389] = preyMode("Hard", "Defeat any one of the listed targets on Hard and hand in the hunt.")
G[61388] = preyMode("Hard", "Defeat 15 of the listed targets on Hard; contracts for a specific target are quicker than random hunts.")
G[42702] = preyMode("Hard", "Defeat every listed target on Hard.")
G[61392] = preyMode("Nightmare", "Defeat any one of the listed targets on Nightmare and hand in the hunt.")
G[61391] = preyMode("Nightmare", "Defeat 15 of the listed targets on Nightmare. Since the Coiled Isle, Nightmare often offers its snake targets, so older ones take longer.")
G[42703] = preyMode("Nightmare", "Defeat every listed target on Nightmare.")

local nightmareCoiled = function(who, n)
    return {
        steps = {
            { t = "Start a Nightmare hunt on the Coiled Isle, or turn on the Curse of the Isle (from the Image of Astalor Bloodworn at Tokka's Landing).", at = { COILED, 58.2, 48.72 } },
            { t = "Defeat " .. who .. (n and (", " .. n .. " times in all") or "") .. "." },
            { t = "If it doesn't pop on the kill, it does when you hand in the hunt." },
        },
    }
end
G[63451] = nightmareCoiled("Batani the Scaled or Kadani the Claw")
G[63452] = nightmareCoiled("Janoa the Fang or Kursak the Coiled")
G[63453] = nightmareCoiled("Ral'kala, Terror of the Isle")
G[63454] = nightmareCoiled("Ral'kala, Terror of the Isle", "fifty")
G[63644] = {
    steps = {
        { t = "Turn on the Curse of the Isle at the Image of Astalor Bloodworn in Tokka's Landing (after its quest you can toggle it any time), or run a Hard or Nightmare hunt.", at = { COILED, 58.2, 48.72 } },
        { t = "Kill enemies in the Coiled Isle's prey world quest areas (for example the Venomhide Burrows in the west): Venom-Bloated Pythons burst out of the corpses." },
        { t = "Kill 200 pythons; ones from other players' hunts count too." },
    },
}
local ritual = function(what)
    return {
        steps = {
            { t = "Go to the Ritual Site that's active (Broken Throne in south Zul'Aman or Daggerspine Point in Eversong; one at a time)." },
            { t = what },
            { t = "Finish the site by defeating its final boss; the achievement only pops then." },
        },
    }
end
G[62559] = ritual("Start it on Tier 5 with the Malevolent Boons challenge, and never destroy a dark obelisk. Adding Tendrils, Manifestations and Tainted Corpses keeps the paths clear of extra enemies so you can run straight to the minibosses.")
G[62560] = ritual("Start it on Tier 5 with the Embers challenge. Skip a few trash packs near the Ember Flames: embers fade as you kill empowered enemies, so leaving some keeps one burning to the end.")
G[62561] = ritual("Start it on Tier 5 with the Reinforced challenge and kill more than 50 enemies before the final boss. There's no counter, so count yourself or clear generously.")

G[62941] = {
    steps = {
        { t = "When Broken Throne is the active Ritual Site, run it on Tier 6 with all 8 challenges and kill the final boss." },
        { t = "Do the same at Daggerspine Point when it's the active site." },
    },
    tips = { "This becomes a Feat of Strength when Midnight ends, so finish it during the expansion." },
}
G[63182] = {
    steps = {
        { t = "Pick up the weekly Advanced Ritual Site Studies from Lady Darkglen in Silvermoon." },
        { t = "Run Ritual Sites with the challenges each week's study asks for, and hand it in." },
        { t = "Repeat for all six weeks." },
    },
}
G[62569] = {
    steps = {
        { t = "During Void Strikes and Incursions, loot the mysterious items some enemies drop; each starts or completes a criterion." },
        { t = "Seen so far: one from enemies in the first stage of While We're Down in Amani'Zar Village, one from Hal'hadar enemies in Battery Rush at the Broken Throne, one near the Temple of Jan'alai, and one at the Daggerspine Point site." },
        { t = "Hand in what each item asks; strikes rotate weekly between Eversong and Zul'Aman, so the rest come in their week." },
    },
}
local slugger = function(zone)
    return {
        steps = {
            { t = "When " .. zone .. " is the active showdown, wait by its rares: they spawn about every 20 minutes in three fixed groups of three." },
            { t = "Each group always spawns in the same order; once you know which group started, you know the next two." },
            { t = "Defeat six of the listed rares." },
        },
    }
end
G[62881] = slugger("Val")
G[62883] = slugger("Naigtal")
G[63348] = {
    steps = {
        { t = "Switch to Heroic World Tier; heroic kills also count for the Normal slugger achievements." },
        { t = "Kill 15 rares in Val or Naigtal; they spawn about every 20 minutes in groups of three." },
    },
}
G[62901] = {
    steps = {
        { t = "Switch to Heroic World Tier in Val or Naigtal." },
        { t = "Kill creatures with the listed affixes; rares and their followers carry them, so it usually completes while you farm rares." },
    },
}
local pertinax = function(heroic)
    return {
        steps = {
            heroic and { t = "Switch to Heroic World Tier." } or { t = "Val and Naigtal take turns as the active showdown each week." },
            { t = "In Val, a quest sends you through the portal in the middle of the map, down to its boss: defeat it." },
            { t = "In Naigtal, the other boss is a weekly kill: defeat it in a Naigtal week. Together they're Imperator Pertinax and Nexus-Captain Leth'ir." },
        },
        tips = { "After this, Zuronar in both zones sells three rewards for 150 Voidlight Marl each." },
    }
end
G[62905] = pertinax(false)
G[62909] = pertinax(true)
G[62917] = {
    steps = {
        { t = "When Val is active, do the Storm Mitigation bonus objective (kill the eight storm creatures)." },
        { t = "Trick: kill the first seven on Normal, then switch to Heroic for the last one; it counts for both." },
        { t = "Repeat five times." },
    },
}
G[62919] = {
    steps = {
        { t = "Switch to Heroic World Tier in Naigtal." },
        { t = "Complete the Subdue the Spore Storm bonus objective (kill ten spore-spewing mushrooms); it spawns at several places." },
        { t = "Repeat five times; alts can help." },
    },
}

G[63264] = {
    steps = {
        { t = "Finish the six Heroic showdown achievements listed (each has its own guide); all need Heroic World Tier." },
        { t = "Afterwards, Kifaan in the Naigtal and Val base camp sells a reward mount cheaply." },
    },
}
G[63323] = {
    steps = {
        { t = "Defeat a world boss in Naigtal or Val (they take turns weekly)." },
        { t = "In Val, its boss quest sends you through the portal in the middle of the map." },
    },
}
G[63383] = {
    steps = {
        { t = "Start the Naigtal and Val introduction in Silvermoon City (the quest is automatic; its giver is around 47.6, 51.0).", at = { SILVERMOON, 47.64, 50.94 } },
        { t = "Finish both introduction storylines on the same character; the two zones take turns weekly, so this spans two weeks." },
    },
}
G[63384] = {
    steps = {
        { t = "Do the listed preparation quests in Val and Naigtal; the teleporter unlock quests need one week of each zone." },
        { t = "Check back on the next rotation for any that weren't offered yet." },
    },
}
G[63385] = {
    steps = {
        { t = "Finish the Naigtal introduction first; the next storylines need it." },
        { t = "Do the Naigtal questlines listed; they're timegated, so a new part opens on each Naigtal week." },
    },
}
G[63386] = {
    steps = {
        { t = "Finish the Val introduction first." },
        { t = "Do the Val questlines listed; they're timegated (Victory Within Hindsight first, A Shot at the Dark on the next Val week, and so on)." },
    },
}
G[61226] = {
    steps = {
        { t = "At level 90, do each Slayer's Rise world quest listed ten times." },
        { t = "Overcoming the Unknown is a weekly world quest, so it takes ten weeks on one character; alts speed it up." },
    },
}
G[61230] = {
    steps = {
        { t = "Fly around Slayer's Rise in Voidstorm and loot the remains marked by small skulls (2-5 each)." },
        { t = "Hand 50 in to the collector at about 39, 82 on the Slayer's Rise map; repeat until you have done the Collecting Remains quest five times." },
    },
}
G[61227] = {
    steps = {
        { t = "Turn on War Mode and fly to Slayer's Rise, the world PvP zone in Voidstorm." },
        { t = "Get honorable kills there; kills in the 40v40 battleground of the same name don't count." },
    },
}
G[61228] = G[61227]
G[61229] = G[61227]
G[61238] = {
    steps = {
        { t = "Turn on War Mode in the Midnight zones." },
        { t = "Kill players with a bounty on their head (they show on the map) and loot the bounty; 20 in all." },
    },
    tips = { "Bounty holders often vanish quickly; be ready near busy world PvP areas." },
}

local flames = {
    { t = "During the Midsummer Fire Festival, honor the bonfire in Eversong Woods, just north of Tranquillien.", at = { EVERSONG, 48.9, 63.9 } },
    { t = "Silvermoon City's bonfire.", at = { SILVERMOON, 48.5, 81.0 } },
    { t = "Zul'Aman's bonfire.", at = { ZULAMAN, 54.4, 16.9 } },
    { t = "Harandar's bonfire.", at = { HARANDAR, 54.2, 51.6 } },
    { t = "Voidstorm's bonfire.", at = { VOIDSTORM, 53.7, 70.2 } },
}
G[61335] = { steps = flames, tips = { "Only during the Midsummer Fire Festival; the bonfires show an exclamation mark." } }
G[61336] = G[61335]
G[63253] = {
    steps = {
        { t = "During Brewfest, donate at each Bar Tab Barrel: Silvermoon.", at = { SILVERMOON, 54.77, 69.76 } },
        { t = "Tranquillien, Eversong.", at = { EVERSONG, 47.74, 67.72 } },
        { t = "The Arcantina.", at = { ARCANTINA, 60.87, 70.2 } },
        { t = "Har'athir, Harandar.", at = { HARANDAR, 69.05, 51.17 } },
        { t = "The Den, Harandar (inside the cave near the portal from Silvermoon)." },
        { t = "Locus Point, Voidstorm.", at = { VOIDSTORM, 41.64, 74.56 } },
        { t = "Amani'Zar, Zul'Aman.", at = { ZULAMAN, 45.37, 65.05 } },
        { t = "Witherbark Bluffs, Zul'Aman.", at = { ZULAMAN, 37.38, 22.86 } },
    },
    tips = { "Only during Brewfest." },
}
G[63400] = {
    steps = {
        { t = "During Hallow's End, visit the Candy Bucket in each Midnight inn: expand the achievement for the list (Arcantina, Silvermoon, Fairbreeze Village, Tranquillien, the Den, Har'alnor, Har'kuai, Har'athir, Har'mara, Amani'Zar, Witherbark Bluffs, Camp Stonewash, Slayer's Rise, Locus Point and the Ingress)." },
        { t = "Click each bucket; the Seasonal book's Hallow's End page marks every one." },
    },
}
G[61447] = {
    steps = {
        { t = "Turn on War Mode and join the Horde versus Alliance events in Slayer's Rise." },
        { t = "Credit depends on where you stand: in the pillar capture, be inside one of the three pillars; in the barrel and Domanaar escort events, be at the barrel turn-in spot (about 44.9, 61.5 on the Slayer's Rise map) when your side wins." },
        { t = "Win the event." },
    },
}
G[61448] = G[61447]
G[61449] = G[61447]
G[61336] = G[61335]
local tg = function(goal, extra)
    return {
        steps = {
            { t = "Open the PvP window and queue for Training Grounds (battlegrounds with AI teammates)." },
            { t = goal },
        },
        tips = extra and { extra } or nil,
    }
end
G[62108] = tg("Win each listed map without dying once; queue for each map on its own.", "Dying in a later match of a map you already have can take its credit away again.")
G[62111] = tg("Win 10 Arathi Basin matches while holding all five flags at once; easiest in a coordinated premade.")
G[62112] = tg("Win 10 Battle for Gilneas matches while holding all three flags at once.")
G[62113] = tg("Win 10 Silvershard Mines matches without the enemy capturing a mine cart.")
G[62114] = tg("Take 50 flags in Arathi Basin: you must be the one capturing.")
G[62115] = tg("Take 30 flags in Battle for Gilneas: you must be the one capturing.")
G[62116] = tg("Take control of 100 carts in Silvershard Mines: credit comes when you stand in a cart's circle as it turns to your side. Standing by the central depot where carts leave gets credit for each one.")
G[61883] = {
    steps = {
        { t = "Join Decor Duel as a hider." },
        { t = "Stay untagged for the first minute, then get caught (surviving the whole round doesn't count). Do this three times." },
    },
    tips = { "Don't use ability 4." },
}
G[61265] = {
    steps = {
        { t = "Turn on War Mode and go to Slayer's Rise in Voidstorm." },
        { t = "When a Spectral Battle Chest appears, capture and open it before the other side; it's contested." },
    },
}

G[61545] = {
    steps = {
        { t = "Progress the Harandar story until you've finished the quest Root Dash Delivery: before that the glyph vanishes as you approach." },
        { t = "Fly to the Roots of Teldrassil glyph and fly through it on a skyriding mount." },
    },
}
local roleSeason = function(role)
    return {
        steps = {
            { t = "Run every Midnight dungeon on Mythic or a keystone as a " .. role .. "; only your role on the final boss counts." },
            { t = "Mythic is only open for dungeons in the current season's rotation, so the rest wait for a season that includes them." },
        },
    }
end
G[62193] = roleSeason("damage dealer")
G[62194] = roleSeason("healer")
G[62195] = roleSeason("tank")
G[61567] = {
    steps = {
        { t = "Finish each Midnight Heroic dungeon achievement listed (queue for Heroic in the Group Finder)." },
        { t = "Some Heroic versions only open in a later season; check the Group Finder each season." },
    },
}
G[61368] = {
    steps = {
        { t = "Join a Heroic group for The Voidspire through the Premade Groups finder." },
        { t = "Defeat every boss on Heroic or Mythic; kills from different weeks count." },
    },
    tips = { "Players report the Lightblinded Vanguard criterion sometimes not ticking even after kills; a ticket or a later kill may be needed." },
}
G[62341] = {
    steps = {
        { t = "Finish each Abundance achievement listed (each has its own guide)." },
    },
    tips = { "Players have reported parts of it as not completable at times; check again after patches." },
}

local stories = function(tip)
    return {
        steps = {
            { t = "Click the delve's entrance on the map: the tier menu shows today's story." },
            { t = "If it's a story you still need (expand the achievement; each row explains the story), run it on any tier." },
            { t = "Come back on other days for the other stories; they change daily." },
        },
        tips = tip and { tip } or nil,
    }
end
G[61725] = stories("The entrance is around 48, 42: take the stairs down, not the closed-looking door to the west.")
G[61726] = stories("The map may call one story An Elementary Antidote while the achievement says Academic Antitoxin; they're the same.")
G[61727] = stories("The story Infiltrate and Ameliorate counts for the Basilisk Blitz criterion.")
G[61731] = stories("Sporasaur Special: stand in the green circles to bounce spores back at the dinosaur and break its shield.")
G[61732] = stories("The Gravitational Effect: 'swim' through the air to the hanging Singularity Coils; the microsingularity keeps you up as long as you don't go too far.")
G[63436] = stories("Game Day: kick the head into the four big obelisks; after the first goal, riders circle the obelisk, so time the second kick between them.")
G[63437] = stories("Minchi's Osseous Adventure starts with Minchi at the entrance; Odds and Ends starts with Tormunda.")
local chests = function(tip)
    return {
        steps = {
            { t = "Enter the delve; each Sturdy Chest has its spot inside, and the arrow leads chest to chest." },
            { t = "Open every chest you can reach in this run." },
            { t = "Some chests only exist in particular stories: come back on other days for the rest." },
        },
        tips = tip and { tip } or nil,
    }
end
G[61895] = chests("On the Leyline Technician story all three chests are in the main circular chamber just before the boss.")
G[61897] = chests("The chest on the mushroom can be looted from below the platform.")
G[61898] = chests("For the high chest, walk up the branch and click it from the top; don't jump.")
G[61899] = chests("Paste or follow positions only after teleporting to the Focal Point (the map has several levels). One chest is reached by dropping off a spike with a disengage or updraft.")
G[61900] = chests()
G[61893] = chests("These chests are there whatever the day's story.")
local roleTip = "Only the role on the final boss counts: hybrids can run the delve in any spec and switch before the last boss."
for _, id in ipairs({ 61711, 61712, 61713, 61714, 61715, 61716, 61717, 61718, 61719 }) do
    local tier = ({ [61711] = 4, [61712] = 8, [61713] = 11, [61714] = 4, [61715] = 8, [61716] = 11, [61717] = 4, [61718] = 8, [61719] = 11 })[id]
    local role = id <= 61713 and "damage dealer" or (id <= 61716 and "healer" or "tank")
    G[id] = {
        steps = {
            { t = "Check each delve's story on the tier menu and pick an easy one." },
            { t = "Finish every Midnight delve on Tier " .. tier .. (tier == 11 and "" or " or higher") .. " with lives left, as a " .. role .. "." },
            { t = "Expand the achievement to see which delves are left." },
        },
        tips = { roleTip, tier == 11 and "Tier 11 achievements only unlock in the tracker once the lower ones are done; you can still make progress." or nil },
    }
end
G[61722] = {
    steps = {
        { t = "Collect every curio available for Valeera; they come from delves (rank 4 ones only from Bountiful delves on Tier 7+)." },
        { t = "If all curios show as owned but nothing pops, relog; players report delays." },
    },
}

local UNLOCK = {
    ["Tainted Corpses"] = "Unlock it first: loot the Tainted Bone Pile inside the site. In Daggerspine Point it's at 66.7, 63.7; in the Broken Throne at 48.0, 36.5 (site map coordinates).",
    ["Patrols!"] = "Unlock it first through the quest Misappropriated Treasures, started by picking up one of its four items at the sites.",
}
local challenge = function(name, expert)
    return {
        steps = {
            { t = "Go to the Ritual Site that's active (Broken Throne in south Zul'Aman or Daggerspine Point in Eversong; one at a time)." },
            { t = UNLOCK[name] or ("If the " .. name .. " challenge isn't offered yet, it's unlocked by an item or quest found inside the sites.") },
            { t = "At the start, add the " .. name .. " challenge" .. (expert and " and choose Tier 5." or ".") },
            { t = "Finish the site by defeating its final boss; the achievement only pops then." },
        },
    }
end
local names = { "Tendrils", "Tainted Corpses", "Manifestations", "Patrols!", "Magical Alarm Bells", "Malevolent Boons", "Reinforced", "Embers" }
for i, n in ipairs(names) do
    G[62539 + i] = challenge(n)
    G[62547 + i] = challenge(n, true)
end
local strikes = function(zone, n)
    return {
        steps = {
            { t = "Watch the " .. zone .. " map for an active Void Strike event." },
            { t = "Complete " .. n .. " Void Strikes in " .. zone .. ". Only strikes count, not Incursions." },
        },
    }
end
G[62507] = strikes("Eversong", 5)
G[62508] = strikes("Eversong", 25)
G[62509] = strikes("Eversong", 50)
G[62510] = strikes("Zul'Aman", 5)
G[62511] = strikes("Zul'Aman", 25)
G[62512] = strikes("Zul'Aman", 50)
G[62607] = {
    steps = {
        { t = "Pick up Seeking Knowledge: Ritualized Arcana (part of the Omnium questline)." },
        { t = "Run Ritual Sites: the objective minibosses always drop what it needs, eight per run on any tier." },
        { t = "Hand in the quest." },
    },
}

G[62874] = {
    steps = {
        { t = "Expand the achievement: each part is its own achievement with a guide." },
        { t = "Run the Naigtal Showdown each time it's open and work through the parts." },
    },
    tips = { "It's time gated: it takes three rotations of Naigtal, about six weeks, so do it every time it's up." },
}
local power = function()
    return {
        steps = {
            { t = "Run the Showdowns on the harder difficulty; rares there can spawn with a random power buff." },
            { t = "Check each rare's buffs before you pull it. Kill one carrying each buff listed in the achievement." },
            { t = "Missing buffs just need more runs: the buff is random per spawn, and both Showdown zones can roll it." },
        },
    }
end
G[62896] = power()
G[62898] = power()
G[62899] = power()
G[62900] = power()
G[63325] = {
    steps = {
        { t = "Expand the achievement: each part is its own achievement with a guide; do them in any order." },
    },
    tips = { "Finishing it unlocks a reward sold for Omnium currency by the vendor in Silvermoon." },
    crit = {},
}
G[42795] = {
    steps = {
        { t = "Learn Midnight Cooking from the cooking trainer in Silvermoon." },
        { t = "Buy a large stack of butter and spice pouches from a Midnight cooking supplies vendor." },
        { t = "Cook Spiced Biscuits until the recipe turns grey and stops giving skill." },
        { t = "Turn the biscuits into Hearty Food and keep cooking that until you reach 100." },
    },
    tips = { "Everything comes from the vendor, so it's quick and cheap." },
}
local orders = function(prof, extra)
    return {
        steps = {
            { t = "Open the crafting orders table for " .. prof .. " and fill Midnight orders: patron, public and personal all count." },
            { t = "Keep going until you've filled 50." },
        },
        tips = { "Personal orders from your own alts count, so you can feed yourself cheap orders.", extra },
    }
end
G[62232] = orders("Blacksmithing")
G[62233] = orders("Enchanting", "One of the Enchanting weekly quests asks for orders; it opens at 25 Midnight Enchanting skill. Do it on more characters to speed up.")
G[62234] = orders("Engineering")
G[62235] = orders("Inscription")
G[62236] = orders("Jewelcrafting")
G[62237] = orders("Leatherworking")
G[62238] = orders("Tailoring")

for id, g in pairs(G) do
    if not ns.ACH_STEPS[id] then
        if g.steps then ns.ACH_STEPS[id] = g.steps end
        if g.tips or g.steps then ns.ACH_NOTES[id] = g.tips end
        if g.crit then
            ns.CRIT_NOTES[id] = ns.CRIT_NOTES[id] or {}
            for k, v in pairs(g.crit) do ns.CRIT_NOTES[id][k] = v end
        end
    end
end

-- Abundance: the four locations, on each per-location criterion
local ABUNDANCE_SPOTS = {
    ["Eversong: Wath'anan Crypts"] = { t = "Abundance location", at = { { EVERSONG, 56.78, 65.79 } } },
    ["Harandar: Floaret Grotto"] = { t = "Abundance location", at = { { HARANDAR, 66.14, 61.69 } } },
    ["Zul'Aman: Loaknit Den"] = { t = "Abundance location", at = { { ZULAMAN, 31.62, 26.14 } } },
    ["Abundant Voidburrow"] = { t = "Abundance location", at = { { VOIDSTORM, 38.82, 53.31 } } },
    ["Eversong Woods: Watha'nan Crypts"] = { t = "Abundance location", at = { { EVERSONG, 56.78, 65.79 } } },
    ["Voidstorm: Abundant Voidburrow"] = { t = "Abundance location", at = { { VOIDSTORM, 38.82, 53.31 } } },
}
for _, id in ipairs({ 62325, 62326, 62329, 62330, 62331, 61943 }) do
    ns.CRIT_NOTES[id] = ns.CRIT_NOTES[id] or {}
    for k, v in pairs(ABUNDANCE_SPOTS) do ns.CRIT_NOTES[id][k] = ns.CRIT_NOTES[id][k] or v end
end

-- Sojourner storylines: where each one starts
ns.CRIT_NOTES[61957] = ns.CRIT_NOTES[61957] or {}
ns.CRIT_NOTES[61957]["Fear and Fel"] = ns.CRIT_NOTES[61957]["Fear and Fel"] or { t = "Storyline starts here", at = { { 2393, 55.93, 63.77 } } }
ns.CRIT_NOTES[61957]["Sunbath, Take Me Away"] = ns.CRIT_NOTES[61957]["Sunbath, Take Me Away"] or { t = "Storyline starts here", at = { { 2395, 48.73, 76.7 } } }
ns.CRIT_NOTES[61957]["Lesser Evil"] = ns.CRIT_NOTES[61957]["Lesser Evil"] or { t = "Storyline starts here", at = { { 2393, 54.54, 61.65 } } }
ns.CRIT_NOTES[61957]["Far Striding"] = ns.CRIT_NOTES[61957]["Far Striding"] or { t = "Storyline starts here", at = { { 2395, 45.29, 45.86 } } }
ns.CRIT_NOTES[61957]["Blinding Sun"] = ns.CRIT_NOTES[61957]["Blinding Sun"] or { t = "Storyline starts here", at = { { 2395, 50.54, 78.19 } } }
ns.CRIT_NOTES[61957]["Paladin Rescue"] = ns.CRIT_NOTES[61957]["Paladin Rescue"] or { t = "Storyline starts here: Requires level 90", at = { { 2393, 53.23, 69.68 } } }
ns.CRIT_NOTES[61957]["Scootin' Through Silvermoon"] = ns.CRIT_NOTES[61957]["Scootin' Through Silvermoon"] or { t = "Storyline starts here", at = { { 2393, 35.78, 69.03 } } }
ns.CRIT_NOTES[61957]["The Drinking Debt"] = ns.CRIT_NOTES[61957]["The Drinking Debt"] or { t = "Storyline starts here", at = { { 2393, 57.72, 68.89 } } }
ns.CRIT_NOTES[61957]["Daggerspine Landing"] = ns.CRIT_NOTES[61957]["Daggerspine Landing"] or { t = "Storyline starts here", at = { { 2395, 38.99, 61.58 } } }
ns.CRIT_NOTES[61957]["Flowers for Amalthea"] = ns.CRIT_NOTES[61957]["Flowers for Amalthea"] or { t = "Storyline starts here", at = { { 2395, 37.51, 72.52 } } }
ns.CRIT_NOTES[61957]["Port Detective"] = ns.CRIT_NOTES[61957]["Port Detective"] or { t = "Storyline starts here", at = { { 2395, 46.89, 45.18 } } }
ns.CRIT_NOTES[61957]["One Adventurous Hatchling"] = ns.CRIT_NOTES[61957]["One Adventurous Hatchling"] or { t = "Storyline starts here", at = { { 2395, 56.81, 35.56 } } }
ns.CRIT_NOTES[61957]["Tailor Troubles"] = ns.CRIT_NOTES[61957]["Tailor Troubles"] or { t = "Storyline starts here", at = { { 2393, 48.31, 54.6 } } }
ns.CRIT_NOTES[61957]["Runestone Rumbles"] = ns.CRIT_NOTES[61957]["Runestone Rumbles"] or { t = "Storyline starts here", at = { { 2395, 50.17, 34.26 } } }
ns.CRIT_NOTES[61957]["How to Train Your Protege"] = ns.CRIT_NOTES[61957]["How to Train Your Protege"] or { t = "Storyline starts here", at = { { 2395, 42.57, 14.56 } } }
ns.CRIT_NOTES[61957]["Aspiring Academic"] = ns.CRIT_NOTES[61957]["Aspiring Academic"] or { t = "Storyline starts here", at = { { 2393, 33.2, 74.17 } } }
ns.CRIT_NOTES[61957]["Theft Tracking"] = ns.CRIT_NOTES[61957]["Theft Tracking"] or { t = "Storyline starts here", at = { { 2395, 41.13, 38.49 } } }
ns.CRIT_NOTES[61864] = ns.CRIT_NOTES[61864] or {}
ns.CRIT_NOTES[61864]["The Void Peers Back"] = ns.CRIT_NOTES[61864]["The Void Peers Back"] or { t = "Storyline starts here", at = { { 2405, 41.17, 61.55 } } }
ns.CRIT_NOTES[61864]["The Nethersent"] = ns.CRIT_NOTES[61864]["The Nethersent"] or { t = "Storyline starts here", at = { { 2405, 56.18, 71.85 } } }
ns.CRIT_NOTES[61864]["Pathogenic Problem"] = ns.CRIT_NOTES[61864]["Pathogenic Problem"] or { t = "Storyline starts here", at = { { 2405, 35.92, 48.25 } } }
ns.CRIT_NOTES[61864]["Shadowguard's Shadow"] = ns.CRIT_NOTES[61864]["Shadowguard's Shadow"] or { t = "Storyline starts here", at = { { 2444, 39.77, 84.1 } } }
ns.CRIT_NOTES[61864]["Breaking the Triad"] = ns.CRIT_NOTES[61864]["Breaking the Triad"] or { t = "Storyline starts here", at = { { 2444, 34.91, 80.23 } } }
ns.CRIT_NOTES[61864]["Secrets in the Dark"] = ns.CRIT_NOTES[61864]["Secrets in the Dark"] or { t = "Storyline starts here", at = { { 2405, 36.87, 58.57 } } }
ns.CRIT_NOTES[61864]["To Be Changed"] = ns.CRIT_NOTES[61864]["To Be Changed"] or { t = "Storyline starts here", at = { { 2405, 53.7, 69.93 } } }
ns.CRIT_NOTES[61864]["A Domanaar's Best Friend"] = ns.CRIT_NOTES[61864]["A Domanaar's Best Friend"] or { t = "Storyline starts here", at = { { 2405, 52.06, 67.47 } } }
ns.CRIT_NOTES[61864]["Shadow Puppets"] = ns.CRIT_NOTES[61864]["Shadow Puppets"] or { t = "Storyline starts here", at = { { 2405, 51.83, 71.96 } } }
ns.CRIT_NOTES[61864]["The Nightbreaker"] = ns.CRIT_NOTES[61864]["The Nightbreaker"] or { t = "Storyline starts here", at = { { 2405, 42.38, 75.37 } } }
ns.CRIT_NOTES[61864]["A Voice Inside"] = ns.CRIT_NOTES[61864]["A Voice Inside"] or { t = "Storyline starts here", at = { { 2405, 41.46, 74.02 } } }
ns.CRIT_NOTES[61864]["A Gift, Given Freely"] = ns.CRIT_NOTES[61864]["A Gift, Given Freely"] or { t = "Storyline starts here", at = { { 2444, 39.93, 84.14 } } }
ns.CRIT_NOTES[61864]["Go Low, Go Loud"] = ns.CRIT_NOTES[61864]["Go Low, Go Loud"] or { t = "Storyline starts here", at = { { 2405, 36.05, 59.81 } } }
ns.CRIT_NOTES[61864]["Oaths to Family"] = ns.CRIT_NOTES[61864]["Oaths to Family"] or { t = "Storyline starts here", at = { { 2405, 44.69, 68.58 } } }
ns.CRIT_NOTES[61864]["A Dance with the Devil"] = ns.CRIT_NOTES[61864]["A Dance with the Devil"] or { t = "Storyline starts here", at = { { 2405, 51.18, 68.43 } } }
ns.CRIT_NOTES[61864]["A More Potent Foe"] = ns.CRIT_NOTES[61864]["A More Potent Foe"] or { t = "Storyline starts here: Requires level 90 to see the starter", at = { { 2405, 53.25, 70.39 } } }
ns.CRIT_NOTES[61452] = ns.CRIT_NOTES[61452] or {}
ns.CRIT_NOTES[61452]["Healing the Spirit"] = ns.CRIT_NOTES[61452]["Healing the Spirit"] or { t = "Storyline starts here", at = { { 2437, 43.15, 67.93 } } }
ns.CRIT_NOTES[61452]["Sawdust to Sawdust"] = ns.CRIT_NOTES[61452]["Sawdust to Sawdust"] or { t = "Storyline starts here", at = { { 2437, 28.39, 27.28 } } }
ns.CRIT_NOTES[61452]["Between Two Trolls"] = ns.CRIT_NOTES[61452]["Between Two Trolls"] or { t = "Storyline starts here", at = { { 2437, 44.08, 66.21 } } }
ns.CRIT_NOTES[61452]["Sorrowing Kin"] = ns.CRIT_NOTES[61452]["Sorrowing Kin"] or { t = "Storyline starts here", at = { { 2437, 45.33, 69.7 } } }
ns.CRIT_NOTES[61452]["Unlikely Friends"] = ns.CRIT_NOTES[61452]["Unlikely Friends"] or { t = "Storyline starts here", at = { { 2437, 44.17, 33.63 } } }
ns.CRIT_NOTES[61452]["The Voice of Nalorakk"] = ns.CRIT_NOTES[61452]["The Voice of Nalorakk"] or { t = "Storyline starts here", at = { { 2437, 33.62, 78.82 } } }
ns.CRIT_NOTES[61452]["Reclaiming de Honor"] = ns.CRIT_NOTES[61452]["Reclaiming de Honor"] or { t = "Storyline starts here", at = { { 2437, 33.61, 78.79 } } }
ns.CRIT_NOTES[61452]["Vengeance for Tolbani"] = ns.CRIT_NOTES[61452]["Vengeance for Tolbani"] or { t = "Storyline starts here", at = { { 2437, 53.1, 62.86 } } }
ns.CRIT_NOTES[61452]["The Loa of Murlocs"] = ns.CRIT_NOTES[61452]["The Loa of Murlocs"] or { t = "Storyline starts here", at = { { 2437, 52.85, 60.22 } } }
ns.CRIT_NOTES[61452]["No Fear"] = ns.CRIT_NOTES[61452]["No Fear"] or { t = "Storyline starts here", at = { { 2437, 45.2, 69.76 } } }
ns.CRIT_NOTES[61452]["Bitter Honor"] = ns.CRIT_NOTES[61452]["Bitter Honor"] or { t = "Storyline starts here", at = { { 2437, 28.92, 33.45 } } }
ns.CRIT_NOTES[61452]["The Sound of Her Voice"] = ns.CRIT_NOTES[61452]["The Sound of Her Voice"] or { t = "Storyline starts here", at = { { 2437, 36.75, 25.12 } } }
ns.CRIT_NOTES[61452]["A Venomous History"] = ns.CRIT_NOTES[61452]["A Venomous History"] or { t = "Storyline starts here: Needs the second boss of the area killed first", at = { { 2437, 36.12, 24.8 } } }
ns.CRIT_NOTES[61452]["Beyond the Walls"] = ns.CRIT_NOTES[61452]["Beyond the Walls"] or { t = "Storyline starts here: First floor of the house", at = { { 2437, 45.54, 69.38 } } }
ns.CRIT_NOTES[61452]["Something Vile This Way Comes"] = ns.CRIT_NOTES[61452]["Something Vile This Way Comes"] or { t = "Storyline starts here", at = { { 2437, 38.54, 22.43 } } }
ns.CRIT_NOTES[61452]["River-Walkers of the Prowl"] = ns.CRIT_NOTES[61452]["River-Walkers of the Prowl"] or { t = "Storyline starts here", at = { { 2437, 45.88, 70.73 } } }
ns.CRIT_NOTES[61452]["Bloodstains"] = ns.CRIT_NOTES[61452]["Bloodstains"] or { t = "Storyline starts here", at = { { 2437, 45.77, 65.54 } } }
ns.CRIT_NOTES[61739] = ns.CRIT_NOTES[61739] or {}
ns.CRIT_NOTES[61739]["A Goblin in Harandar"] = ns.CRIT_NOTES[61739]["A Goblin in Harandar"] or { t = "Storyline starts here", at = { { 2413, 47.1, 45.77 } } }
ns.CRIT_NOTES[61739]["Late Bloomers"] = ns.CRIT_NOTES[61739]["Late Bloomers"] or { t = "Storyline starts here", at = { { 2413, 36.93, 25.98 } } }
ns.CRIT_NOTES[61739]["Peril Among Petals"] = ns.CRIT_NOTES[61739]["Peril Among Petals"] or { t = "Storyline starts here", at = { { 2413, 65.39, 22.68 } } }
ns.CRIT_NOTES[61739]["Harandar's Kitchen"] = ns.CRIT_NOTES[61739]["Harandar's Kitchen"] or { t = "Storyline starts here", at = { { 2413, 40.86, 23.18 } } }
ns.CRIT_NOTES[61739]["Cultivating Hope"] = ns.CRIT_NOTES[61739]["Cultivating Hope"] or { t = "Storyline starts here", at = { { 2413, 34.9, 24.99 } } }
ns.CRIT_NOTES[61739]["A Palette of Feelings"] = ns.CRIT_NOTES[61739]["A Palette of Feelings"] or { t = "Storyline starts here", at = { { 2413, 70.5, 51.2 } } }
ns.CRIT_NOTES[61739]["Bloomtown"] = ns.CRIT_NOTES[61739]["Bloomtown"] or { t = "Storyline starts here", at = { { 2413, 31.44, 64.93 } } }
ns.CRIT_NOTES[61739]["Trials of the Shul'ka"] = ns.CRIT_NOTES[61739]["Trials of the Shul'ka"] or { t = "Storyline starts here: Needs campaign progress", at = { { 2413, 52.18, 55.09 } } }
ns.CRIT_NOTES[61739]["The Legend of Aln'sharan"] = ns.CRIT_NOTES[61739]["The Legend of Aln'sharan"] or { t = "Storyline starts here", at = { { 2413, 67.73, 27.47 } } }
ns.CRIT_NOTES[61739]["The Greenspeaker's Vigil"] = ns.CRIT_NOTES[61739]["The Greenspeaker's Vigil"] or { t = "Storyline starts here: Needs campaign progress", at = { { 2413, 65.41, 28.08 } } }
ns.CRIT_NOTES[61739]["Haranir Never Say Die"] = ns.CRIT_NOTES[61739]["Haranir Never Say Die"] or { t = "Storyline starts here", at = { { 2413, 48.78, 44.35 } } }
ns.CRIT_NOTES[61739]["Silence at Fungara Village"] = ns.CRIT_NOTES[61739]["Silence at Fungara Village"] or { t = "Storyline starts here", at = { { 2413, 43.91, 71.73 } } }
ns.CRIT_NOTES[61739]["Hunter's Rights"] = ns.CRIT_NOTES[61739]["Hunter's Rights"] or { t = "Storyline starts here", at = { { 2413, 69.45, 52.79 } } }
ns.CRIT_NOTES[61739]["Predator Reintroduction"] = ns.CRIT_NOTES[61739]["Predator Reintroduction"] or { t = "Storyline starts here", at = { { 2413, 69.56, 50.64 } } }
ns.CRIT_NOTES[61739]["The Grudge Pit"] = ns.CRIT_NOTES[61739]["The Grudge Pit"] or { t = "Storyline starts here", at = { { 2413, 71.81, 64.01 } } }

-- Exploration routes for the Midnight zones (replace the generic explore steps)
ns.ACH_STEPS[61855] = {
    { t = "Open the world map: unexplored areas are still fogged. Fly low through each one until its name shows on screen." },
    { t = "Silvermoon City, the capital (its own map)." },
    { t = "Sunstrider Isle, the island in the north.", at = { EVERSONG, 42.91, 20.97 } },
    { t = "Fairbreeze Village, west of centre.", at = { EVERSONG, 46.57, 43.26 } },
    { t = "Brightwing Estate, north-east.", at = { EVERSONG, 62.96, 34.32 } },
    { t = "Goldenmist Village, west.", at = { EVERSONG, 39.36, 57.14 } },
    { t = "Suncrown Village, centre-south.", at = { EVERSONG, 52.41, 61.87 } },
    { t = "Tranquillien, south of centre.", at = { EVERSONG, 48.46, 63.39 } },
    { t = "Windrunner Spire, south-west.", at = { EVERSONG, 36.8, 79.79 } },
    { t = "Amani Pass, the far south.", at = { EVERSONG, 54.03, 81.16 } },
}
ns.CRIT_NOTES[61855] = ns.CRIT_NOTES[61855] or {}
ns.CRIT_NOTES[61855]["Sunstrider Isle"] = { t = "Fly over this area", at = { { EVERSONG, 42.91, 20.97 } } }
ns.CRIT_NOTES[61855]["Fairbreeze Village"] = { t = "Fly over this area", at = { { EVERSONG, 46.57, 43.26 } } }
ns.CRIT_NOTES[61855]["Brightwing Estate"] = { t = "Fly over this area", at = { { EVERSONG, 62.96, 34.32 } } }
ns.CRIT_NOTES[61855]["Goldenmist Village"] = { t = "Fly over this area", at = { { EVERSONG, 39.36, 57.14 } } }
ns.CRIT_NOTES[61855]["Suncrown Village"] = { t = "Fly over this area", at = { { EVERSONG, 52.41, 61.87 } } }
ns.CRIT_NOTES[61855]["Tranquillien"] = { t = "Fly over this area", at = { { EVERSONG, 48.46, 63.39 } } }
ns.CRIT_NOTES[61855]["Windrunner Spire"] = { t = "Fly over this area", at = { { EVERSONG, 36.8, 79.79 } } }
ns.CRIT_NOTES[61855]["Amani Pass"] = { t = "Fly over this area", at = { { EVERSONG, 54.03, 81.16 } } }
ns.ACH_STEPS[61856] = {
    { t = "Open the world map: unexplored areas are still fogged. Fly low through each one until its name shows on screen." },
    { t = "Amani'Zar Village, the hub.", at = { ZULAMAN, 45.63, 63.17 } },
    { t = "Strait of Hexx'alor, east of the hub.", at = { ZULAMAN, 53.27, 54.06 } },
    { t = "Temple of Akil'zon, south-east.", at = { ZULAMAN, 50.24, 76.42 } },
    { t = "Den of Nalorakk, south-west.", at = { ZULAMAN, 31.13, 82.34 } },
    { t = "Broken Throne, just north of the Den of Nalorakk.", at = { ZULAMAN, 28.48, 78.1 } },
    { t = "Maisara Deeps, centre.", at = { ZULAMAN, 42.4, 44.15 } },
    { t = "Temple of Halazzi, north-west.", at = { ZULAMAN, 30.9, 31.61 } },
    { t = "Atal'Aman, far north-west.", at = { ZULAMAN, 27.28, 24.2 } },
    { t = "Witherbark Bluffs, north.", at = { ZULAMAN, 38.09, 27.84 } },
    { t = "Temple of Jan'alai, north.", at = { ZULAMAN, 49.64, 24.58 } },
}
ns.CRIT_NOTES[61856] = ns.CRIT_NOTES[61856] or {}
ns.CRIT_NOTES[61856]["Amani'Zar Village"] = { t = "Fly over this area", at = { { ZULAMAN, 45.63, 63.17 } } }
ns.CRIT_NOTES[61856]["Strait of Hexx'alor"] = { t = "Fly over this area", at = { { ZULAMAN, 53.27, 54.06 } } }
ns.CRIT_NOTES[61856]["Temple of Akil'zon"] = { t = "Fly over this area", at = { { ZULAMAN, 50.24, 76.42 } } }
ns.CRIT_NOTES[61856]["Den of Nalorakk"] = { t = "Fly over this area", at = { { ZULAMAN, 31.13, 82.34 } } }
ns.CRIT_NOTES[61856]["Broken Throne"] = { t = "Fly over this area", at = { { ZULAMAN, 28.48, 78.1 } } }
ns.CRIT_NOTES[61856]["Maisara Deeps"] = { t = "Fly over this area", at = { { ZULAMAN, 42.4, 44.15 } } }
ns.CRIT_NOTES[61856]["Temple of Halazzi"] = { t = "Fly over this area", at = { { ZULAMAN, 30.9, 31.61 } } }
ns.CRIT_NOTES[61856]["Atal'Aman"] = { t = "Fly over this area", at = { { ZULAMAN, 27.28, 24.2 } } }
ns.CRIT_NOTES[61856]["Witherbark Bluffs"] = { t = "Fly over this area", at = { { ZULAMAN, 38.09, 27.84 } } }
ns.CRIT_NOTES[61856]["Temple of Jan'alai"] = { t = "Fly over this area", at = { { ZULAMAN, 49.64, 24.58 } } }
ns.ACH_STEPS[61520] = {
    { t = "Open the world map: unexplored areas are still fogged. Fly low through each one until its name shows on screen." },
    { t = "The Den, the hub in the middle (the hut above it is at 53.5, 53.2).", at = { HARANDAR, 53.5, 53.2 } },
    { t = "Blooming Lattice, north of the Den.", at = { HARANDAR, 54.65, 35.55 } },
    { t = "Fungara Village, south-west of the Den.", at = { HARANDAR, 44.55, 62.81 } },
    { t = "Har'athir, east.", at = { HARANDAR, 69.05, 51.17 } },
    { t = "The Grudge Pit, south-east.", at = { HARANDAR, 70.5, 64.9 } },
    { t = "Har'kuai, Har'alnor, Har'mara, Gloom Mire, the Rift of Aln, the Den of Echoes, the Vale of Mists and the Blinding Bloom: sweep the fogged parts of the map for any of these still missing." },
}
ns.CRIT_NOTES[61520] = ns.CRIT_NOTES[61520] or {}
ns.CRIT_NOTES[61520]["The Den"] = { t = "Fly over this area", at = { { HARANDAR, 53.5, 53.2 } } }
ns.CRIT_NOTES[61520]["Blooming Lattice"] = { t = "Fly over this area", at = { { HARANDAR, 54.65, 35.55 } } }
ns.CRIT_NOTES[61520]["Fungara Village"] = { t = "Fly over this area", at = { { HARANDAR, 44.55, 62.81 } } }
ns.CRIT_NOTES[61520]["Har'athir"] = { t = "Fly over this area", at = { { HARANDAR, 69.05, 51.17 } } }
ns.CRIT_NOTES[61520]["The Grudge Pit"] = { t = "Fly over this area", at = { { HARANDAR, 70.5, 64.9 } } }
ns.ACH_STEPS[61857] = {
    { t = "Open the world map: unexplored areas are still fogged. Fly low through each one until its name shows on screen." },
    { t = "The Ingress, west.", at = { VOIDSTORM, 35.67, 61.1 } },
    { t = "Shadowguard Point, north-west.", at = { VOIDSTORM, 36.08, 37.25 } },
    { t = "The Voidspire, the raid in the centre.", at = { VOIDSTORM, 51.34, 62.72 } },
    { t = "Obscurion Citadel, south-east.", at = { VOIDSTORM, 64.97, 71.9 } },
    { t = "Slayer's Rise, the PvP area in the north (its own map)." },
    { t = "Nexus-Point Antius, Nexus-Point Mid'Ar, Nexus-Point Xenas, Howling Ridge and Stormarion Citadel: sweep the fogged parts of the map for any still missing." },
}
ns.CRIT_NOTES[61857] = ns.CRIT_NOTES[61857] or {}
ns.CRIT_NOTES[61857]["The Ingress"] = { t = "Fly over this area", at = { { VOIDSTORM, 35.67, 61.1 } } }
ns.CRIT_NOTES[61857]["Shadowguard Point"] = { t = "Fly over this area", at = { { VOIDSTORM, 36.08, 37.25 } } }
ns.CRIT_NOTES[61857]["The Voidspire"] = { t = "Fly over this area", at = { { VOIDSTORM, 51.34, 62.72 } } }
ns.CRIT_NOTES[61857]["Obscurion Citadel"] = { t = "Fly over this area", at = { { VOIDSTORM, 64.97, 71.9 } } }
ns.ACH_STEPS[63640] = {
    { t = "Open the world map: unexplored areas are still fogged. Fly low through each one until its name shows on screen." },
    { t = "Tokka's Landing, the hub.", at = { COILED, 58.95, 48.91 } },
    { t = "The Serpent's Tail, north of the hub.", at = { COILED, 52.01, 38.4 } },
    { t = "Blistering Terrace, north-west.", at = { COILED, 42.9, 30.6 } },
    { t = "Gate of the Serpent's Eye, centre.", at = { COILED, 43.81, 44.19 } },
    { t = "Gate of the Eastern Fang, south of centre.", at = { COILED, 45.84, 64.94 } },
    { t = "The Forum, west.", at = { COILED, 26.62, 63.14 } },
    { t = "The Whispering Marsh, south-east.", at = { COILED, 64.13, 60.65 } },
    { t = "Wreck of Paku's Talon, east.", at = { COILED, 70.29, 48.16 } },
    { t = "Mlurkkr Mire, north-east.", at = { COILED, 71.2, 31.3 } },
    { t = "Gnarldor Isle, the islet in the south-east.", at = { COILED, 64.45, 77.73 } },
}
ns.CRIT_NOTES[63640] = ns.CRIT_NOTES[63640] or {}
ns.CRIT_NOTES[63640]["Tokka's Landing"] = { t = "Fly over this area", at = { { COILED, 58.95, 48.91 } } }
ns.CRIT_NOTES[63640]["The Serpent's Tail"] = { t = "Fly over this area", at = { { COILED, 52.01, 38.4 } } }
ns.CRIT_NOTES[63640]["Blistering Terrace"] = { t = "Fly over this area", at = { { COILED, 42.9, 30.6 } } }
ns.CRIT_NOTES[63640]["Gate of the Serpent's Eye"] = { t = "Fly over this area", at = { { COILED, 43.81, 44.19 } } }
ns.CRIT_NOTES[63640]["Gate of the Eastern Fang"] = { t = "Fly over this area", at = { { COILED, 45.84, 64.94 } } }
ns.CRIT_NOTES[63640]["The Forum"] = { t = "Fly over this area", at = { { COILED, 26.62, 63.14 } } }
ns.CRIT_NOTES[63640]["The Whispering Marsh"] = { t = "Fly over this area", at = { { COILED, 64.13, 60.65 } } }
ns.CRIT_NOTES[63640]["Wreck of Paku's Talon"] = { t = "Fly over this area", at = { { COILED, 70.29, 48.16 } } }
ns.CRIT_NOTES[63640]["Mlurkkr Mire"] = { t = "Fly over this area", at = { { COILED, 71.2, 31.3 } } }
ns.CRIT_NOTES[63640]["Gnarldor Isle"] = { t = "Fly over this area", at = { { COILED, 64.45, 77.73 } } }
