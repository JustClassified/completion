-- Completion: step-by-step guides for Midnight achievements, in our own words.
-- Same shape as Data/TWW/Guides.lua:
--   G[id] = { steps = { { t = text, at = { uiMapID, x, y }, quest = id }, ... }, tips = { "...", ... } }
-- Steps are followed in order by the arrow; tips show under them ("Good to know"). A guide replaces the
-- plain note in Data/Notes.lua; steps given here replace the ones there.

local _, ns = ...

local EVERSONG, SILVERMOON, ZULAMAN, HARANDAR, VOIDSTORM, COILED, VAULTS, ARCANTINA =
    2395, 2393, 2437, 2413, 2405, 2512, 2509, 2541

local G = {}

------------------------------------------------------------------------
-- Silvermoon and Eversong
------------------------------------------------------------------------

-- The Party Must Go On: Saltheril's Haven
G[62186] = {
    steps = {
        { t = "Pick up the party quest from Jonas Everdawn in Silvermoon.", at = { SILVERMOON, 45.66, 62.58 } },
        { t = "Talk to Lord Saltheril at Saltheril's Haven, then to the vendors there.", at = { EVERSONG, 42.68, 47.31 } },
        { t = "Choose one faction for the week and spend all three invitations on it, then do its weekly quests." },
        { t = "Repeat each week with another faction: four weeks in all." },
    },
    tips = { "Splitting the invitations between factions wastes the week." },
}

-- All of the Silvermoon Court sub-factions at max
G[62190] = {
    steps = {
        { t = "Each week, run the party at Saltheril's Haven (see The Party Must Go On) for one of the four factions." },
        { t = "Keep rotating until the Blood Knights, Farstriders, Magisters and Shades of the Row are all at their top rank." },
    },
    tips = { "A faction at its top rank is locked there, so you can then pick options that lower it to push the others." },
}

-- The Grand Magister's Drink tastings
G[62187] = {
    steps = {
        { t = "Wait for the Special Assignment \"The Grand Magister's Drink\" in Eversong Woods (Fairbreeze area)." },
        { t = "Talk to each drink vendor and ask for a tasting. The drink counts the moment you ask, not when you hand in the bottle." },
        { t = "Solo you get three tastings per run; come back on later runs (or alts, it's warband-wide) for the rest." },
    },
    tips = { "Players report that in a raid group every tasting counts at once." },
}

-- The runestones of Eversong
G[61961] = {
    steps = {
        { t = "Find the runestone that's active right now in Eversong; they take turns." },
        { t = "Hand in Latent Arcana until it's charged to 100%." },
        { t = "Kill enemies and click objects around it until its named boss appears, then defeat it." },
        { t = "Repeat as the other runestones become active." },
    },
}

-- Lorewalking with Li Li
local function lorewalk(story, volumes, where)
    return {
        steps = {
            { t = "Talk to Assistant Lorewalker Li Li in Silvermoon, east of the Sanctum of Light (book icon).", at = { SILVERMOON, 58.7, 70.8 } },
            { t = "Ask what stories she can tell and choose " .. story .. "." },
            { t = "Play through all " .. volumes .. " volumes: " .. where .. "." },
        },
        tips = {
            "Some objectives take a minute to appear; if a step shows nothing, wait or relog.",
            "Only one saved Lorewalking story at a time: starting another deletes the saved one.",
        },
    }
end
G[61442] = lorewalk("the Loa", 4, "Zandalar, Zul'Drak, the Swamp of Sorrows and the Echo Isles")
G[61467] = lorewalk("the Elves of Quel'Thalas", 2, "the fall of Silvermoon and the Sunwell, then the Void Elves")

-- Small Red Button
G[60888] = {
    steps = {
        { t = "Take off your gear (no repair bills) and go to the Silvermoon graveyard." },
        { t = "Place the Small Red Button and press it." },
        { t = "If you die, resurrect at the spirit healer right there to skip the timer, and start again. You need 10 presses in a row without dying." },
    },
    tips = { "It's pure luck." },
}

------------------------------------------------------------------------
-- Zul'Aman
------------------------------------------------------------------------

-- Chu'ke the possessed doll (steps kept from Data/Notes.lua)
G[62199] = {
    tips = { "Talking to Chu'ke later transforms you again; almost anything cancels it." },
}

-- The Spiritpaw run (steps kept from Data/Notes.lua)
G[62202] = {
    tips = { "The run gives a 30-minute buff and you can't mount." },
}

-- Filo, Loa of Childhood
G[62267] = {
    steps = {
        { t = "Finish or abandon any Prey hunt you have running, or Filo won't show." },
        { t = "Kill Kapara and Kapara pups in Zul'Aman again and again; Feevra's pool is a good spot.", at = { ZULAMAN, 32.24, 22.31 } },
        { t = "After the third angry warning, Filo, Loa of Childhood, appears." },
    },
    tips = { "A Kapara can grow huge and hit hard." },
}

-- The eight minor Loa
G[62120] = {
    steps = {
        { t = "Kulzi: finish the storyline that starts in Amani'Zar Village." },
        { t = "Filo: the storyline that starts at Witherbark Bluffs." },
        { t = "Shadra: the other Witherbark Bluffs storyline; it needs a Maisara Caverns run (follower mode works)." },
        { t = "Mot'amra: an item from the end chest of a Zul'Aman delve." },
        { t = "Wila'ma: Renown 8 with the Amani Tribe." },
        { t = "Dundun: an item from Chel the Chip, the Abundance vendor, for 1600 Unalloyed Abundance." },
        { t = "Oe: an item from the world boss Cragpine." },
        { t = "Puul: a very rare fishing catch from any Midnight water; pools aren't needed." },
        { t = "Unlock each one at Du'gal's Altar of Blessings in Amani'Zar Village.", at = { ZULAMAN, 43.0, 69.2 } },
    },
}

-- The Penitent Troll: every blessing combination
G[62121] = {
    steps = {
        { t = "Unlock all eight minor Loa first (Altar of Blessings).", at = { ZULAMAN, 43.0, 69.2 } },
        { t = "Each blessing is one major Loa (top four circles) plus one minor Loa. Pick a combination at the altar." },
        { t = "Several trigger right at the altar. Most others trigger in combat: a training dummy toy next to the altar is the quickest." },
        { t = "Two Dundun combinations trigger on any gathering node." },
        { t = "The travel ones need a Packpeddle mammoth (repair icon on the minimap): pick the combination, talk to the mammoth, fly back, change the major Loa and repeat.", at = { ZULAMAN, 40.3, 51.1 } },
    },
}

-- Abyss Angler dives
G[62117] = {
    steps = {
        { t = "Start a dive with Depthdiver Tu'nakit off the Zul'Aman coast.", at = { ZULAMAN, 68.2, 20.2 } },
        { t = "Fish the Abyss Bubbles at the bottom of the sea. Click the bobber, not the bubble." },
    },
    tips = { "Track the 50-fish achievement: the 10, 25 and 50 ones finish in one session." },
}
G[62219] = {
    steps = {
        { t = "Start a dive and turn around at once." },
        { t = "Swim out past the trench edge until the warning appears, and stay there." },
    },
}
G[62207] = {
    steps = {
        { t = "Catch 3 fish in dives." },
        { t = "Buy the Reinforced Joints upgrade from Depthdiver Jeju. It may only appear after the next weekly reset." },
    },
}
G[62759] = {
    steps = {
        { t = "Buy the Pressurized Eyeglass upgrade first." },
        { t = "In one dive, loot 3 Ancient Relics. They move around and respawn after a few minutes." },
    },
}
G[62778] = {
    steps = {
        { t = "Get the Murkskimmer Meat upgrade (from the chum achievements)." },
        { t = "Fish Abyss Bubbles until an Epic fish comes up." },
    },
}
G[62832] = {
    steps = {
        { t = "Find the Champion of Pahk, the Mythic creature." },
        { t = "Hit it once when its armor is gone to catch it a single time." },
        { t = "Use Surface! straight away. More than one Mythic catch breaks it." },
    },
    tips = { "Easier with a friend." },
}

------------------------------------------------------------------------
-- Harandar
------------------------------------------------------------------------

-- Glowing Moths of Harandar
G[61052] = {
    steps = {
        { t = "Hara'ti Renown 1: the first 40 moths can be collected. Each shows on the map a few renown levels later, so the book's spots help." },
        { t = "Renown 5: 40 more moths." },
        { t = "Later renown: the last 40." },
        { t = "Spend the Luminous Dust at Mothkeeper Wew'tam for two mounts and decor." },
    },
}

-- The Haranir on the old world trees
G[62188] = {
    steps = {
        { t = "Or'jan: Darkshore, on a rocky islet at the Twilight Shore." },
        { t = "Chonon: on the tallest root of Nordrassil in Mount Hyjal (a Hyjal questline may be needed to see him)." },
        { t = "Fuunid: high on a branch of Bel'ameth's world tree." },
        { t = "Kawayn: on top of the tree in Grizzly Hills." },
        { t = "Zhakir: Val'sharah, by a small lake before the druid class hall." },
    },
    tips = { "Druids can reach most of them through the Dreamway." },
}

-- Legends of the Haranir books
G[61344] = {
    steps = {
        { t = "Start the week's Legends of the Haranir relic quest." },
        { t = "While on it, pick up all three books in that relic's story before finishing it." },
        { t = "Repeat with each week's relic story." },
    },
    tips = { "A missed book can't be fetched later on that character; an alt who hasn't done that relic can get it." },
}

-- Fly to the top above the Den
G[61860] = {
    steps = {
        { t = "Fly to the Den in the middle of Harandar." },
        { t = "Fly straight up and keep climbing until you're teleported." },
    },
}

------------------------------------------------------------------------
-- Voidstorm
------------------------------------------------------------------------

-- The Hungering Presence
G[62133] = {
    steps = {
        { t = "Fly very high anywhere in Voidstorm until the Hungering Presence comes for you." },
        { t = "Pitch slightly down and hold turn plus strafe to circle at full speed for 60 seconds. No abilities needed." },
    },
}

-- Screammaxa (steps kept from Data/Notes.lua)
G[61861] = {
    tips = { "Body pulls and other players' tags don't count: hit the Shredclaw yourself." },
}

-- Stormarion Assault
G[61912] = {
    steps = {
        { t = "Join a Stormarion Assault event in Voidstorm (not the Sunkiller Sanctum delve)." },
        { t = "Build each of the four defenses at least once. The Shadowtrade Mercenary needs Renown 11 with The Singularity." },
    },
}

-- Void Assault storylines
G[62873] = {
    steps = {
        { t = "Start the Void Assault storylines from the NPC in Silvermoon City.", at = { SILVERMOON, 47.6, 51.0 } },
        { t = "Follow the six storylines for Naigtal and Val; each part is time-gated, so this takes at least six weeks." },
        { t = "Buy the two mounts from Kifaan once it's done." },
    },
}

-- Until It Is Done
G[63349] = {
    steps = {
        { t = "Wait for the world quest Until It Is Done in western Val." },
        { t = "Join a raid group: the quest then stops completing and you can keep going." },
        { t = "Kill 100 enemies while driving the Ultradon Slayer." },
    },
}

------------------------------------------------------------------------
-- Prey
------------------------------------------------------------------------

-- Riposte
G[62142] = {
    steps = {
        { t = "On a hunt, fight until an ambush comes (about every 3-4 minutes in combat). Training dummies are a quiet place to wait." },
        { t = "After the ambush a projectile marks red smoke on the ground: walk into it to reveal the prey and riposte." },
    },
}

------------------------------------------------------------------------
-- Coiled Isle and the Vaults of Atal'Utek
------------------------------------------------------------------------

-- Ofi's Cauldron
G[63432] = {
    steps = {
        { t = "Reach Renown 3 with Zul'jarra's Forces (the Spoils of Coils perk) so the special treasures spawn." },
        { t = "Do the intro quests at the Amani Foothold in the Vaults of Atal'Utek." },
        { t = "Loot one of the special treasures: it gives an item that starts a quest." },
        { t = "Talk to Ofi the Sly in the swamp.", at = { COILED, 57.43, 48.68 } },
        { t = "Talk to Ofi again at Tokka's Landing.", at = { COILED, 61.26, 32.88 } },
        { t = "Open Ofi's bag for 3 ingredients and offer them at Ofi's Cauldron. Each offering type counts once; the daily is repeatable, so you can finish in one day." },
    },
}

-- The Coiled Huntress
G[63634] = {
    steps = {
        { t = "Reach Bloodsworn Crew (rank 5) with Captain Tokka, on the character that started the Venom Fishing questline." },
        { t = "Buy The Coiled Huntress fishing pole from Second Mate Sluggs (6000 Voidlight Marl)." },
        { t = "Equip it and talk to Captain Tokka." },
    },
}

-- Summoning Ritual offerings
G[62600] = {
    steps = {
        { t = "Wait for the Temple Incursion: Summoning Ritual in the Vaults of Atal'Utek." },
        { t = "Bring a Petrified Egg from the west side to the main statue." },
        { t = "Bring a Spirit Urn from the east side." },
        { t = "Kill a Venomous Giant in the middle area for a Venomous Ooze and bring it too." },
    },
    tips = { "Carrying an offering gives a 10-minute buff and you can mount." },
}

-- Cache of the Three: /dance at each stone
G[62604] = {
    steps = {
        { t = "Wait for the Cache of the Three incursion in the Vaults of Atal'Utek." },
        { t = "Stand inside a stone's circle and /dance for a few seconds without being interrupted or targeting anything." },
        { t = "Repeat at each stone, ideally while a group is clearing it (enemies jump anyone alone there)." },
    },
}

-- Earth and Sky: the blue Soul Globe
G[62649] = {
    steps = {
        { t = "Wait for the Earth and Sky event in the Vaults of Atal'Utek." },
        { t = "Stand in the green circle at the Shrine of Sky, dismount and press the extra button to become a bird." },
        { t = "Fly around the raid entrance for a large, bright blue wandering Soul Globe. One is enough." },
    },
}

-- Infestation: die with the debuff
G[63382] = {
    steps = {
        { t = "Check the map's Events tab for when the Cursed Surge is at The Forum (Looming Mutagenitor); surges move every 45 minutes." },
        { t = "Stand in the big green clouds until you get the Infestation debuff." },
        { t = "Die while it's on you; a fall from high up works." },
    },
}

-- 1000 Insidious Snakes
G[63596] = {
    steps = {
        { t = "Go to the entrance of the Altar of Fangs in the Vaults of Atal'Utek, where Insidious Snakes keep spawning." },
        { t = "Auto-run into the corner so you stomp them as they come. Standing still doesn't count." },
    },
    tips = { "Two more spawn points nearby speed it up with friends." },
}

------------------------------------------------------------------------
-- The Arcantina
------------------------------------------------------------------------

-- Visitors of the Arcantina
G[61082] = {
    steps = {
        { t = "Each week a pair of visitors comes to the Arcantina. Look in the side rooms too, not only at the map icons." },
        { t = "Before handing in their quest, place the pair's optional decoration (see Highly Decorated)." },
        { t = "Hand in their quest. Pairs return about every eight weeks, so come back for the ones you missed." },
    },
}
G[63619] = G[61082]

-- Highly Decorated
G[61083] = {
    steps = {
        { t = "Find each decoration in its old dungeon, raid or zone (expand the achievement for the list)." },
        { t = "Place it in the Arcantina. Several are tied to a weekly visitor pair and only appear in their week." },
    },
}

-- Stormstout Brewery Lantern
G[63620] = {
    steps = {
        { t = "In Stormstout Brewery, just past the first boss, take the lantern hanging in a doorway." },
        { t = "Hang it over the doorway between the Arcantina's main room and the back right room.", at = { ARCANTINA, 63.3, 44.8 } },
    },
}

-- Toasting Brews: one of every race
G[61081] = {
    steps = {
        { t = "Buy Toasting Brews from Bartender Bob in the Arcantina (10 silver each, one per race).", at = { ARCANTINA, 60.4, 66.4 } },
        { t = "Use one on a player of each race. Mouse over a player and Completion tells you if you still need their race." },
        { t = "For a race nobody brings, toast yourself on an alt or trial character of that race." },
    },
    tips = { "Mechagnome, Vulpera and Kul Tiran are the rare ones; the entrance right after the weekly reset is busiest." },
}

------------------------------------------------------------------------
-- Exploration and world
------------------------------------------------------------------------

local explore = function(zone)
    return {
        steps = {
            { t = "Open the world map of " .. zone .. ": the areas you haven't explored are still fogged." },
            { t = "Fly low through each fogged area until its name appears on screen." },
            { t = "Expand the achievement to see which areas are still missing; it completes with the last one." },
        },
    }
end
G[61855] = explore("Eversong Woods")
G[61856] = explore("Zul'Aman")
G[61520] = explore("Harandar")
G[61857] = explore("Voidstorm")
G[63640] = explore("the Coiled Isle")
G[61854] = {
    steps = {
        { t = "Finish Explore Eversong Woods, Explore Zul'Aman, Explore Harandar and Explore Voidstorm (each has its own guide)." },
        { t = "The meta completes with the last zone." },
    },
}
G[61859] = {
    steps = {
        { t = "Expand the achievement: the missing flight masters are listed, and the arrow points at the nearest." },
        { t = "Talk to each one once to learn its flight path." },
    },
}
G[62057] = {
    steps = {
        { t = "Finish each zone's Highest Peaks achievement: fly to every telescope and use it." },
        { t = "If a zone sits at 5/5 without completing, go round again: a telescope can show as not placed, and using it once more fixes it." },
    },
}
G[62104] = {
    steps = {
        { t = "Expand the achievement: every lore object in the four zones has its spot." },
        { t = "Click each to read it. The Ancient Tablet that counts is the one in Voidstorm." },
    },
}
G[61455] = {
    steps = {
        { t = "Finish the Zul'Aman campaign first: Baz'wa only appears after it." },
        { t = "Expand the achievement and visit each of the five Shadowpine Songseekers." },
        { t = "Jebanda walks between two spots; check both." },
    },
}
G[62200] = {
    steps = {
        { t = "Expand the achievement: each of Bin Greenwrench's six notes has its spot in Zul'Aman." },
        { t = "Pick up each note. The Discarded Scroll is under a building; the Moldy Diary is under the hammock Da Piper sleeps in." },
    },
}
G[62201] = {
    steps = {
        { t = "Expand the achievement: each princess frog has its spot (Princess Jakobu is in Atal'Aman)." },
        { t = "Target each frog and type /kiss." },
    },
    tips = { "A macro that targets the frog and then kisses saves hunting for them in the grass." },
}
G[62269] = {
    steps = {
        { t = "Go to Du'gal's Altar of Blessings in Amani'Zar Village.", at = { ZULAMAN, 43.0, 69.2 } },
        { t = "Unlock any Loa there (Wila'ma unlocks by itself at Renown 8 with the Amani Tribe)." },
    },
}
G[62270] = {
    steps = {
        { t = "Talk to Du'gal the Altar Keeper in Amani'Zar Village.", at = { ZULAMAN, 43.0, 69.2 } },
        { t = "Take blessings from the altar." },
    },
}
G[61913] = {
    steps = {
        { t = "Join a Stormarion Assault in Voidstorm." },
        { t = "Finish all three waves of the same assault." },
    },
    tips = { "If Wave 1 didn't count, run the event again from the start." },
}
G[61922] = {
    steps = {
        { t = "Join a Stormarion Assault in Voidstorm, ideally with a full group." },
        { t = "Guard the Singularity Anchor all the way: it must end with 90% health or more." },
    },
}
G[62601] = {
    steps = {
        { t = "Wait for the Underbelly strike in the Vaults of Atal'Utek (not every day)." },
        { t = "Kill the three threats that spawn as strike objectives." },
        { t = "Find and kill Szarith the Fanged and Vserix the Sneaky, the rarer two, in the same strike." },
    },
    tips = { "Players report progress resetting when a strike ends without all five dead." },
}
G[63381] = {
    steps = {
        { t = "Open the map's Events tab on the Coiled Isle to see where the next Curse Surge is; they move between five spots every 45 minutes." },
        { t = "Join the group there and finish the surge." },
        { t = "Repeat until 150. It's a long grind by design." },
    },
}
G[63598] = {
    steps = {
        { t = "In the Vaults of Atal'Utek, hover the patrol icons on the map to see which Temple Patrols are up (several at once, rotating about every 10 minutes)." },
        { t = "Finish each patrol you still need; raid groups work." },
        { t = "The whole set swaps about every two weeks, so some patrols only appear later." },
    },
}
G[63653] = {
    steps = {
        { t = "Do Temple Patrols in the Vaults of Atal'Utek; several are up at once and they rotate about every 10 minutes." },
        { t = "Keep going until 250; they count in raid groups too." },
    },
}
G[63599] = { steps = { { t = "Temple Incursions in the Vaults of Atal'Utek rotate; check the map." }, { t = "Do each incursion when it's up until all are done." } } }
G[63600] = { steps = { { t = "Temple Strikes rotate in sets of three about every half week." }, { t = "Do each of the six; all can be done within a week." } } }
G[63601] = { steps = { { t = "One Ancient Foe is active at a time and it changes weekly." }, { t = "Be in the raid group when it dies; repeat each week for the others." } } }

------------------------------------------------------------------------
-- Abundance
------------------------------------------------------------------------

local ABUNDANCE = "The four Abundance spots: Watha'nan Crypts (Eversong), Loaknit Den (Zul'Aman), Floaret Grotto (Harandar) and the Abundant Voidburrow (Voidstorm)."
local bonus = function(name, extra)
    return {
        steps = {
            { t = "Join an Abundance event: kill enemies, gather and bring the orbs to the altar." },
            { t = "Every 10,000 progress rolls one of five bonuses; keep filling the bar until " .. name .. " fires." },
            { t = "Do this at each of the four Abundance locations." },
        },
        tips = { ABUNDANCE, extra },
    }
end
G[62325] = bonus("the Treasure Dundun bonus")
G[62326] = bonus("the Golden Glow bonus")
G[62329] = bonus("the Runaways bonus")
G[62330] = bonus("the Gigantic Harvest bonus")
G[62331] = bonus("the Rain of Abundance bonus", "The Voidburrow one has been reported as not counting at times.")
G[61943] = { steps = { { t = "Start the Abundance questline in Zul'Aman." }, { t = "Follow it to the end; the achievement completes with it." } } }
G[61681] = {
    steps = {
        { t = "Take part in Abundance events; every bit of harvest adds to your total." },
        { t = "Keep going until 1,000,000; usually one or two Abundant Harvest events." },
    },
    tips = { ABUNDANCE },
}
G[62324] = {
    steps = {
        { t = "In a single Abundance event, score in every category: contribute materials, gather basic nodes, gather artisan nodes (needs a Midnight profession at skill 25), catch large orbs and take part in bonus events." },
        { t = "Stay until each category shows a score, then finish the event." },
    },
}
G[62333] = {
    steps = {
        { t = "In one Abundance event, pick up the orbs dropped by enemies and from gathering." },
        { t = "Reach 10,000 in Materials Harvested. Zul'Aman is easiest when the big corpse spawns and everyone skins it." },
    },
}
G[62336] = {
    steps = {
        { t = "In one Abundance event, pick up the orbs dropped by enemies." },
        { t = "Deliver them to the altar yourself until you reach 10,000 Materials Contributed." },
    },
}
G[62339] = {
    steps = {
        { t = "Join an Abundance event, ideally a busy one in a big group." },
        { t = "Stay for as many bonus triggers as you can until Bonus Events reaches 10,000." },
    },
}
G[62340] = {
    steps = {
        { t = "Join an Abundance event, ideally the enhanced one in a raid group." },
        { t = "Stand under the falling orbs (green circles) until Large Orbs reaches 10,000." },
    },
}
G[42283] = {
    steps = {
        { t = "Finish every Abundance achievement listed (each has its own guide)." },
        { t = "Do it all on one character: it isn't warband-wide." },
    },
    tips = { "Chel the Chip sells a toy that teleports you to Abundance for 3200 Unalloyed Abundance." },
}

------------------------------------------------------------------------
-- Abyss Anglers
------------------------------------------------------------------------

local dive = { t = "Start a dive with Depthdiver Tu'nakit off the Zul'Aman coast.", at = { ZULAMAN, 68.2, 20.2 } }
G[62218] = { steps = { dive, { t = "Don't use Surface!: let your breath run out." } } }
G[62220] = { steps = { dive, { t = "Wait until your breath drops below 10." }, { t = "Use Surface! (ability 3)." } } }
G[62222] = { steps = { dive, { t = "Find a Brakpuffer (small puffer fish, mid-depth)." }, { t = "Stay next to it until the bomb over its head goes off." } } }
G[62774] = { steps = { dive, { t = "Swim through one of the two air vents." } } }
G[62829] = { steps = { dive, { t = "Swim to the aggressive fish near 65, 25 (Axetooth Thresher, Abyss Fangray or Depthbash Thresher)." }, { t = "Let one of them grab you." } } }
G[62342] = {
    steps = {
        dive,
        { t = "Find the Champion of Pahk, the Mythic creature (starts with 99 scales, respawns in 5-10 minutes)." },
        { t = "Spear it again and again; several catches can count per kill. Three in all." },
    },
}
G[62343] = {
    steps = {
        dive,
        { t = "Catch the Champion of Pahk six times; a kill can count several times." },
        { t = "Use both air vents to last long enough solo." },
    },
}
G[62763] = {
    steps = {
        dive,
        { t = "Loot Sunken and Ancient Treasures; the cluster in the ravine respawns fast and has an air vent close by." },
        { t = "Keep going over many dives until 250." },
    },
}
G[62776] = {
    steps = {
        dive,
        { t = "Catch one fish of each rarity: Mythic (the Champion of Pahk), Legendary (small seahorses or the Gemscale Nymph), Epic (the Sightless Skipper) and the common ones on the way." },
    },
}
G[62777] = {
    steps = {
        { t = "Earn the dive upgrades' achievements as you go; some upgrades only appear after their achievement and a weekly reset." },
        { t = "Buy every upgrade from Depthdiver Jeju; one is a limited-stock item, so check back." },
    },
}

------------------------------------------------------------------------
-- Fishing
------------------------------------------------------------------------

G[63510] = {
    steps = {
        { t = "Open the Fishing Journal: it shows each fish's score (up to 100 at Trophy rank) and your Anglin' Score." },
        { t = "Fish in every Midnight zone, including the small one-fish areas in the Vaults." },
        { t = "Reach 2500; with 28 fish you can skip about three." },
    },
}
G[63629] = {
    steps = {
        { t = "Turn on Find Fish tracking on the minimap to see pools." },
        { t = "Fish the Coiled Isle pools for most of the list." },
        { t = "Spotted Killifish: open water by Tokka's small island." },
        { t = "Ula'tek Snakehead: open water, with the Renown 5 lure from Tokka's crew." },
        { t = "Coiled Stargorger: with the reputation-locked lure." },
    },
}
G[63632] = {
    steps = {
        { t = "Fish a lot in the Coiled Isle and the Vaults: rank goes up when you land a higher-quality catch (hidden)." },
        { t = "Keep the Fishing Journal open to watch each listed fish reach Trophy rank." },
    },
}

------------------------------------------------------------------------
-- Prey
------------------------------------------------------------------------

local huntTable = { t = "Pick up a hunt at the hunt table in Silvermoon City.", at = { SILVERMOON, 55.8, 66.0 } }
local normalPrey = {
    steps = {
        huntTable,
        { t = "Choose a listed Prey target on Normal difficulty (Hard and Nightmare kills don't count here)." },
        { t = "Track it down, kill it and hand in the hunt quest." },
    },
}
G[61387] = normalPrey
G[61386] = normalPrey
G[42701] = normalPrey
G[62139] = { steps = { huntTable, { t = "Pick a contract for a zone you haven't hunted in yet." }, { t = "Finish one hunt in each Midnight zone." } } }
G[62383] = {
    steps = {
        huntTable,
        { t = "Hunt every listed target on any difficulty; expand the achievement for which are left." },
        { t = "Targets rotate and a few only show up in random hunts, so mix those in." },
    },
}
G[62134] = {
    steps = {
        { t = "Turn on War Mode before you start (safest)." },
        huntTable,
        { t = "Finish five hunts with War Mode on." },
    },
}
G[62135] = {
    steps = {
        { t = "Turn on War Mode first and keep it on the whole time." },
        huntTable,
        { t = "Choose a Nightmare hunt (not a random one) and finish it." },
    },
}
G[62136] = {
    steps = {
        { t = "Turn on War Mode and start a Nightmare hunt." },
        { t = "Go to Slayer's Rise in Voidstorm and fight players; any damage on a player who dies counts." },
        { t = "Keep going until 50 kills." },
    },
}
G[62138] = {
    steps = {
        { t = "Start a hunt and stay in combat: ambushes come about every 3-4 minutes." },
        { t = "Grind enemies between hunt steps until the ambushes counted are done." },
    },
}
G[62140] = { steps = { { t = "Start a Nightmare hunt and wait until the prey is revealed (fewer interruptions)." }, { t = "Cook 100 things; any recipe works, even Spice Bread." } } }
G[62141] = { steps = { { t = "Start a Nightmare hunt and wait until the prey is revealed." }, { t = "Fish from the edge of a sanctuary (step in to clear the debuff) until 100 catches." } } }
G[62143] = { steps = { { t = "Start a hunt in a zone." }, { t = "Click the traps that show on the minimap in the hunt's area." } } }
G[63642] = { steps = { { t = "Start a Hard or Nightmare hunt on the Coiled Isle." }, { t = "Stay in combat: Toxic Snare barrages come about once a minute; survive them until the count is reached." } } }
G[63643] = { steps = { { t = "Start a Hard or Nightmare hunt on the Coiled Isle." }, { t = "Kill Pack Scouts; scouts from other players' hunts count too, and the Ral'kala farm groups are quickest." } } }

------------------------------------------------------------------------
-- Ritual Sites
------------------------------------------------------------------------

G[62521] = { steps = { { t = "Wait until Broken Throne in south Zul'Aman is the active Ritual Site (one at a time)." }, { t = "Finish a run there." } } }
G[62522] = { steps = { { t = "Wait until Daggerspine Point in Eversong is the active Ritual Site (check the map)." }, { t = "Finish a run there." } } }
G[62534] = {
    steps = {
        { t = "When Broken Throne is active, start it solo on Tier 5 with all 8 challenges." },
        { t = "Kill every empowered group (blue fire) and every obelisk so the dragonhawk and final boss get no boons." },
        { t = "Soak the dragonhawk's red pools, then kill the final boss." },
    },
}
G[62535] = {
    steps = {
        { t = "When Daggerspine Point is active, start it solo on Tier 5 with all 8 challenges." },
        { t = "Kill every empowered group and every obelisk so the bosses get no boons." },
        { t = "Kill the final boss." },
    },
}
G[62556] = {
    steps = {
        { t = "Start a Tier 5 site with the Tendrils and Manifestations challenges; solo at Broken Throne is easiest (no water)." },
        { t = "Step out of every green circle; pull enemies out of the water, where circles are hard to see." },
        { t = "Keep an interrupt or stun for each Manifestation. Kill the final boss." },
    },
    tips = { "Pets getting hit don't count." },
}
G[62558] = {
    steps = {
        { t = "Start a site on Tier 5 or higher." },
        { t = "Kill three challenge patrols: the Deeplurk Brinethrashers, marked with a red triangle on the minimap." },
        { t = "Kill the final boss; the achievement pops then." },
    },
}
G[62622] = { steps = { { t = "Run Ritual Sites; every run gives reputation, more on higher tiers and with more challenges." }, { t = "Keep going until renown 8." } } }

------------------------------------------------------------------------
-- Void Assaults
------------------------------------------------------------------------

G[62518] = {
    steps = {
        { t = "Wait for the Void Cleansing rifts: Tranquil Repose, Sunstrider Isle and South Eversong in Eversong, Bitter Bark in Zul'Aman." },
        { t = "Kill the Apex-corrupted creatures in them." },
    },
}
G[62570] = {
    steps = {
        { t = "Only the giant bosses of three Void Strikes count: Springclaw and Croaker (Eversong) and Grizzly! (Zul'Aman)." },
        { t = "Kill each in the weeks its strike is up." },
    },
}
G[62571] = {
    steps = {
        { t = "Join Void Strikes and rescue captives." },
        { t = "Quickest: the Stillwhisper Pond stage of the Eversong incursion (toads and hawkstriders each count), or the Spiritpaw prisons in Zul'Aman. Fifty in all." },
    },
}
G[62572] = {
    steps = {
        { t = "Join a Battery Rush strike in Zul'Aman." },
        { t = "Pick up Ethereal Batteries (you can't mount while carrying one)." },
        { t = "Right-click a Siphoning Pylon to throw them." },
    },
}
G[62573] = {
    steps = {
        { t = "Join a Hive Extermination strike (one in Eversong, two in Zul'Aman)." },
        { t = "Fly through the swarming enemies; falling jellies can be hit more than once." },
    },
}
local showdown = function(zone)
    return {
        steps = {
            { t = "Leave any raid group (world quests there don't count in one)." },
            { t = "Do eight different world quests in " .. zone .. "; Heroic ones also count toward the Heroic achievement." },
        },
    }
end
G[62880] = showdown("Val")
G[62882] = showdown("Naigtal")
G[62887] = {
    steps = {
        { t = "Switch to Heroic World Tier." },
        { t = "Do 15 world quests in Val or Naigtal; if one doesn't add progress, do another." },
    },
}
local storm = function(zone)
    return {
        steps = {
            { t = "When " .. zone .. " is the active showdown, watch its map for the Storm Mitigation bonus objective." },
            { t = "Clear it (kill the storm creatures in it)." },
            { t = "Repeat five times; Heroic counts for both versions." },
        },
    }
end
G[62903] = storm("Val")
G[62904] = storm("Naigtal")

------------------------------------------------------------------------
-- Raids, dungeons, delves
------------------------------------------------------------------------

G[61911] = {
    steps = {
        { t = "Vaelgor & Ezzorak in The Voidspire: agree a 3-2-1 countdown on voice." },
        { t = "When Nullzone tethers go out, everyone breaks theirs within 3 seconds of the first player." },
        { t = "One good round is enough; killing Vaelgor fast helps. Then kill the bosses." },
    },
}
G[62352] = { steps = { { t = "Enter The Voidspire or March on Quel'Danas on any difficulty (Raid Finder works)." }, { t = "Walk out of bounds and let the Devouring Host take you." } } }
G[63670] = {
    steps = {
        { t = "In The Venomous Abyss, pick up the Ancient Amani mask in the left alcove of the crypts before the tortollans." },
        { t = "With the mask, find and comfort every trapped spirit; a full clear is fine." },
    },
}
G[62196] = {
    steps = {
        { t = "Run every Midnight dungeon on Mythic or a keystone as tank, as healer and as damage dealer." },
        { t = "Only dungeons in the current season's rotation can be done, so some parts wait for the next season." },
    },
}
G[61707] = {
    steps = {
        { t = "Expand the achievement: each delve is under Delves on its zone page, with its entrance." },
        { t = "Clear each one once." },
    },
}
G[61723] = { steps = { { t = "Run Bountiful delves on Tier 7 or higher; only they give rank 4 curios." }, { t = "Collect every curio at rank 4." } } }
G[61832] = { steps = { { t = "Enter any delve on Tier 1." }, { t = "Finish it." } } }
G[61901] = {
    steps = {
        { t = "Finish each Midnight delve's Discoveries achievement; each chest has its spot inside." },
        { t = "Some chests only exist in certain stories, so run each delve with different stories until all show up." },
    },
}

------------------------------------------------------------------------
-- Professions, reputation, pets, collections, housing, events
------------------------------------------------------------------------

G[61441] = {
    steps = {
        { t = "Learn each Midnight primary profession (on any character: progress is per profession)." },
        { t = "Craft new recipes, gather and do the weekly profession quests until each is at max skill." },
    },
}
local gatherWeekly = function(p)
    return {
        steps = {
            { t = "Reach 25 Midnight " .. p .. " skill." },
            { t = "From the week after you learn it, pick up the " .. p .. " weekly quest and finish it." },
            { t = "Repeat for four weeks, or use alts." },
        },
    }
end
G[62247] = gatherWeekly("Herbalism")
G[62248] = gatherWeekly("Mining")
G[62249] = gatherWeekly("Skinning")
G[62192] = { steps = { { t = "Raise each listed faction to max renown; each zone's Reputation section shows how far you are." }, { t = "World quests, weeklies and zone events give renown." } } }
G[63631] = { steps = { { t = "Do Captain Tokka's Venom Fishing quests on the Coiled Isle." }, { t = "Fish daily until rank 5, Bloodsworn Crew." } } }
G[61091] = {
    steps = {
        { t = "Turn on Track Pets on the minimap (some patches switch it off)." },
        { t = "Expand the achievement: every species with its spot; rare ones are marked." },
        { t = "Capture each species in Eversong, Zul'Aman, Harandar and Voidstorm (Quel'Danas pets count too)." },
    },
}
G[62492] = {
    steps = {
        { t = "Turn on Track Pets on the minimap." },
        { t = "Capture every wild pet of the Coiled Isle." },
        { t = "The rare Caustic Writhling lives inside the Vaults of Atal'Utek and respawns every 3-4 hours." },
    },
}
G[61586] = { steps = { { t = "Buy a full Midnight PvP Season 1 armor set, Honor or Conquest (the Warmonger set doesn't count)." }, { t = "Equip every piece to learn it." } } }
G[63608] = { steps = { { t = "Buy a full Midnight PvP Season 2 armor set, Honor or Conquest." }, { t = "Equip every piece to learn it." } } }
G[62370] = { steps = { { t = "Chop Thalassian Lumber; Harandar has by far the most." }, { t = "Keep going until 250 (warband-wide). Druids can stay in travel form while chopping." } } }
G[61887] = {
    steps = {
        { t = "Buy kits and enhancements from Gamesmaster Fleurian in Silvermoon." },
        { t = "Play the Decor Duel housing hide-and-seek event and earn each of its achievements." },
    },
}

------------------------------------------------------------------------
-- Raids: The Voidspire, The Dreamrift, March on Quel'Danas (Normal or harder)
------------------------------------------------------------------------

-- Crown of the Cosmos: We Will, In Fact, See It Again
G[61346] = {
    steps = {
        { t = "Before the final boss, near the teleporting orb, stand in the small puddle until you have 10 stacks: you get a lump of flesh (extra button)." },
        { t = "Kill the first three minibosses; Alleria throws you up and pulls you to the centre." },
        { t = "Walk to the centre and throw your lump of flesh in. Once everyone has, a Fleshy Monstrosity spawns." },
        { t = "Kill the Monstrosity first (it can turn players against each other), then the boss." },
    },
}

-- Belo'ren: Eggsistential Crisis
G[61381] = {
    steps = {
        { t = "A tank picks up the Sunwell Egg to the left of the boss (about 42, 44 on the raid map)." },
        { t = "The Light tank holds the egg to fill it with Light, then hands it to the Void tank to fill it with Void." },
        { t = "When the tracked achievement turns white, kill the boss." },
    },
    tips = {
        "The egg is often bugged and can't be picked up. Teleporting the tanks out and summoning them back can fix it.",
        "A two-seat mount like the Mechano-Hog can carry the egg in the passenger seat; don't use abilities or you dismount.",
    },
}

-- Chimaerus: Falling Between The Quacks
G[61454] = {
    steps = {
        { t = "On the platform where you enter the Dreamrift, talk to Sergeant Quackers." },
        { t = "Clear the trash; he waits on the boss platform. Mark him so he's easy to see, then pull." },
        { t = "When half the raid is phased into the rift, Quackers is there too: every phased player clicks him to pluck a Corrupted Feather (a feather circles you when it worked)." },
        { t = "The other half does the same in the next rift phase. When everyone has, he escapes and joins the fight; kill the boss." },
    },
}

-- Fallen-King Salhadaar: It's Treason Then
G[61514] = {
    steps = {
        { t = "Before the pull, everyone types /kneel at Fallen-King Salhadaar." },
        { t = "You get a debuff: a shade of yourself spawns now and then; face it each time or you die." },
        { t = "Kill the boss with the mechanic active." },
    },
}

-- Lightblinded Vanguard: Aura Farming
G[61936] = {
    steps = {
        { t = "On the right side before the arena, every player clicks the small book on the ground for the Aura Farming debuff." },
        { t = "During the fight, the bosses create auras: everyone briefly stands in each to raise their aura level." },
        { t = "When everyone has absorbed all three auras (Maximum Aura), kill the bosses." },
    },
    tips = { "A higher aura stuns players with a lower one, so clear a path for those still catching up.", "Players report it needs at least 10 players." },
}

-- Vorasius: Hungry Hungry Hatchlings
G[62058] = {
    steps = {
        { t = "On the pull, a barrel of hatchlings appears on the right of the arena: every player, tanks included, grabs one (yours has a small beam of light over it)." },
        { t = "Kill the Blistercreep adds near the boss; their corpses feed the hatchlings." },
        { t = "Each hatchling falls asleep after eating 8 corpses. When everyone's is asleep, kill the boss." },
    },
}

-- Imperator Averzian: The Only Winning Move Is Not To Play
G[62106] = {
    steps = {
        { t = "Before the boss, three players each pick up one of the three glowing banners by running over them." },
        { t = "In the fight, soak two of each set of three Voidshapers so they despawn, as usual." },
        { t = "After a soak, place a banner on an empty spot. Place all three in a line, like tic-tac-toe; the achievement turns white." },
        { t = "Never leave three Voidshapers in a row (that wipes the raid). Kill the boss." },
    },
}

-- Midnight Falls: All the Things She Said
G[62406] = {
    steps = {
        { t = "On entering, one player clicks the void torch on the right." },
        { t = "In phase 3, after void covers part of the floor, images appear: interrupt (kick) each before it fades." },
        { t = "Kick 12 in all. Bring the boss low first: completing it makes the boss enrage. Then kill her." },
    },
}

------------------------------------------------------------------------
-- Raid: The Venomous Abyss (Normal or harder)
------------------------------------------------------------------------

G[63250] = {
    steps = {
        { t = "Each Entombed Sentinel must heal for a total of 50% of its health over the intermissions." },
        { t = "Burn one Sentinel to 50% below the other, then solve the intermission's shape puzzle and let it heal back." },
        { t = "After the intermission, burn the other one 50% below, and let it heal in the next intermission." },
        { t = "When the tracked achievement turns white for both, kill them as normal." },
    },
    tips = { "Solving the shape puzzle ends the healing, so don't solve it too fast. It's cumulative: you can top up in a later intermission." },
}
G[63391] = {
    steps = {
        { t = "Light the small incense left of the door before the stairs down to Sszorak; the rings appear and the achievement turns white." },
        { t = "Pull. Each time the knock-back wind comes, three rings spawn: get knocked through each of them." },
        { t = "Kill the boss after the last set." },
    },
}
G[63397] = {
    steps = {
        { t = "When Vashnik casts Imbibe, adds spawn at the coloured altars." },
        { t = "Stack one add of each colour exactly on top of each other (grips and banish help hold them in place)." },
        { t = "The Solidified Snake Venom spawns; kill it, then kill the boss." },
    },
}
G[63418] = {
    steps = {
        { t = "At the raid entrance, buy Balm of Flies from the skeleton vendor on the left." },
        { t = "Run to Kupamanduka just before Nek'zali's room and use the balm on him so he can be picked up." },
        { t = "Carry him into the boss room. In the fight he hops around: kick him into the Soulcoil Well." },
        { t = "Kill the boss." },
    },
}
G[63609] = {
    steps = {
        { t = "The Greasy Hatchling egg sits on the upper left of the arena; walk through it to pick it up (a 20-second timer starts)." },
        { t = "When the timer ends or you touch the poison sea, it drops in a soak circle: another player stands in it to take it over." },
        { t = "Keep juggling it between 3-5 players on the main platform for the whole fight; if it's lost, reset." },
        { t = "Kill Ula'tek before the egg breaks." },
    },
}
G[63645] = {
    steps = {
        { t = "Before the fight, one player picks up the fish on the platform by the coffin." },
        { t = "Open the coffin and pull: Hoji joins as an invincible add that shoots at you." },
        { t = "Kill the Lost Explorers with Hoji still up." },
    },
}
G[63656] = {
    steps = {
        { t = "Pick four players to carry one slime each; picking one up gives a 60-minute buff and it follows you." },
        { t = "Sumptuous Soup: in a hole on the left after the first boss." },
        { t = "Jiggly Dessert: on a ledge on the right in the Twin Fangs room." },
        { t = "Tasty Blob: in the green fountain in the trash room before Sszorak and Vashnik." },
        { t = "Crunchy Appetizer: on a small island in the poison sea after the Lost Explorers." },
        { t = "In the fight, those four soak the big red group soak in the order the tracked achievement lists, one after another." },
        { t = "Kill the Twin Fangs." },
    },
    tips = { "The slimes respawn; if the buff runs out, go back and pick them up again." },
}
G[63669] = {
    steps = {
        { t = "Keep the raid at 20 players or fewer: above that, extra ghosts despawn." },
        { t = "In phase 2, ghosts spawn after breaking a mind-controlled player and fixate on players. Don't let the tank frontal destroy them; kite them into a corner and look at them to freeze them." },
        { t = "Collect ghosts until every player is fixated (phase 2's despawn on Normal when phase 3 starts, so build them in phase 3 too)." },
        { t = "Kill the Coiled Altar with everyone fixated." },
    },
}

------------------------------------------------------------------------
-- Researched odd ones
------------------------------------------------------------------------

G[61219] = {
    steps = {
        { t = "When the Harandar world quest Claw Enforcement is up, mount the Swift Grimlynx; it runs on its own until you dismount or finish.", at = { HARANDAR, 52.9, 52.3 } },
        { t = "Run over the vermin: each gives a stack of Predator's Pursuit (lasts 15 seconds)." },
        { t = "Keep chaining them and finish the quest with 15 or more stacks." },
    },
    tips = { "Don't do it grouped with someone else at the same time: shared kill credit splits the stacks." },
}
G[62105] = {
    steps = {
        { t = "Pick up the Voidstorm world quest Precision Excision." },
        { t = "Finish it without missing a shot: aim at the target's feet (where its selection circle would be), not its head." },
    },
}
G[62385] = {
    steps = {
        { t = "Go to the Research Console in Voidstorm.", at = { VOIDSTORM, 52.6, 72.82 } },
        { t = "Unlock every part of it; the mount reward can arrive by mail after a zone change." },
    },
}
G[62403] = {
    steps = {
        { t = "In the Prey headquarters in Silvermoon, pet Lord Viscera's cat on the table to the left of the main entrance until you get Cat Scratch.", at = { SILVERMOON, 56.01, 64.49 } },
        { t = "Within 30 minutes, run a Nightmare hunt and kill the prey (dying means petting the cat again)." },
        { t = "Don't hand in the quest at once: take the portal back, then hand it in to earn the achievement." },
    },
}
G[63457] = {
    steps = {
        { t = "Start the questline from the Prey headquarters in Silvermoon City; it leads to a daily quest that rewards 100 Ossified Relics." },
        { t = "Hand in that daily; the achievement completes with it." },
    },
    tips = { "Ossified Relics also drop from Coiled Isle world quests and enemies during Nightmare hunts or the Curse of the Isle." },
}
G[61916] = {
    steps = {
        { t = "On a level 80 Void Elf, fly to Magister Umbric at the Shan'dorah flight point in K'aresh (south-east corner of the large northern isle).", at = { 2371, 60.91, 27.71 } },
        { t = "Take his quest and follow the Rage of the Ren'dorei storyline to its end." },
    },
}
G[61942] = {
    steps = {
        { t = "Create a haranir character and level it to 50 (a level boost works)." },
        { t = "Pick up the Heritage of the Haranir quest and hand it in at the Den in Harandar for the heritage armor and the achievement." },
    },
}
G[61881] = {
    steps = {
        { t = "Join Decor Duel as a hider." },
        { t = "Be the very last untagged player before about 30 seconds remain (being one of several survivors doesn't count)." },
    },
    tips = { "Hard-to-reach hiding spots that need a bit of parkour help." },
}
G[61882] = {
    steps = {
        { t = "Buy the Eccentro-Magic Pulse enhancement from Gamesmaster Fleurian in Silvermoon." },
        { t = "As a hider, move away from the spawn as a prop; when you get Found, use the pulse to lose the Found status without being tagged." },
    },
}
G[61880] = {
    steps = {
        { t = "Join Decor Duel as a hider and pick a hiding spot away from the usual paths." },
        { t = "Stay unfound for a minute and a half in a row." },
    },
}
local seeker = function(class)
    return {
        steps = {
            { t = "Join Decor Duel; at the start of a round as a tagger, choose Seeker: " .. class .. "." },
            { t = "Tag hiders in that role until the achievement completes (players report five in a round)." },
        },
    }
end
G[61792] = seeker("Spellbreaker")
G[61878] = seeker("Arcane Ranger")
G[61793] = seeker("Nullifier")
G[61886] = { steps = { { t = "Earn Illusionary Coins by playing Decor Duel." }, { t = "Buy every kit upgrade from Gamesmaster Fleurian in Silvermoon (20 coins each)." } } }
G[62514] = {
    steps = {
        { t = "In Slayer's Rise, control Shenzar Refinery, both Bastions and both Gates at the same time." },
        { t = "Win while holding them all." },
    },
}

------------------------------------------------------------------------

for id, g in pairs(G) do
    if g.steps then ns.ACH_STEPS[id] = g.steps end
    if g.tips or g.steps then ns.ACH_NOTES[id] = g.tips end   -- a guide replaces the old plain note
end
