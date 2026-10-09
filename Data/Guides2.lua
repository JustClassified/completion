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
