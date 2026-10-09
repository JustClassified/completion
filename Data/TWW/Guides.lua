-- Completion: step-by-step guides for War Within achievements, in our own words from players' experience.
-- Each guide is { steps = { { t = text, at = { uiMapID, x, y }, quest = id }, ... }, tips = { "...", ... } }.
--   steps: done in order; the arrow follows them one at a time. A step with `quest` ticks itself when that
--          quest is done; the others tick by hand (shift-click) or when the achievement completes.
--   tips:  short points shown under the steps ("Good to know"), or alone when there are no steps.
-- They replace the plain notes in Data/TWW/Notes.lua for the same achievement.

local _, ns = ...

local DORN, DORNOGAL, DEEPS, HALLOWFALL, AZJ, THREADS, LOWER, UNDERMINE, SIREN, KARESH, TAZAVESH =
    2248, 2339, 2214, 2215, 2255, 2213, 2216, 2346, 2369, 2371, 2472

local G = {}

------------------------------------------------------------------------
-- Isle of Dorn
------------------------------------------------------------------------

-- We're Here All Night: the Theater Troupe
G[40859] = {
    steps = {
        { t = "The Theater Troupe event on the Isle of Dorn starts every hour. Shows come in the same order as the list below, so work out when the one you need is due." },
        { t = "Go to the stage a little before the hour and finish the event; the show performed counts." },
        { t = "Repeat on other hours until every show is ticked." },
    },
    tips = {
        "The map tooltip often names the wrong show; trust the order instead.",
        "A missing tick sometimes appears after a later show.",
    },
}

-- A Star of Dorn: the four actor perks
G[40860] = {
    steps = {
        { t = "Council of Dornogal Renown 3: Elma at the Theater Troupe camp starts Attention-Getter.", at = { DORN, 56.6, 52.2 } },
        { t = "Renown 8: Wendeline, at the same camp, starts Quickchange Artist.", at = { DORN, 56.6, 52.2 } },
        { t = "Renown 14: Rabaan starts Authenticity in Dress.", at = { DORN, 56.6, 52.2 } },
        { t = "Renown 21: Burkhalt starts Resonant Performance.", at = { DORN, 56.6, 52.2 } },
    },
    tips = { "Each perk quest only appears once you reach its renown with the Council of Dornogal." },
}

-- Flat Earthen
G[40606] = {
    steps = {
        { t = "Go to the central forge in Dornogal, in front of the Blacksmithing trainer." },
        { t = "Stand right under the big press and wait for it to come down on you." },
    },
}

------------------------------------------------------------------------
-- Hallowfall
------------------------------------------------------------------------

-- Lost and Found: nine mementos over three weekly quests
G[40618] = {
    steps = {
        { t = "Pick up Memories of the Sky from Maera Ashyld.", at = { HALLOWFALL, 60.4, 60.0 }, quest = 80673 },
        { t = "Week 1 (Time Lost): give the Stuffed Lynx Toy to Phillip Taversil.", at = { HALLOWFALL, 43.2, 55.4 }, quest = 80679 },
        { t = "Week 1: leave the Tarnished Compass at the grave offering.", at = { HALLOWFALL, 43.46, 51.71 }, quest = 80680 },
        { t = "Week 1: give the Broken Bracelet to Keyrra Flamestonge.", at = { HALLOWFALL, 65.4, 32.2 }, quest = 80681 },
        { t = "Week 2 (Time Found, after the weekly reset): give the Filigreed Cleric to Kiera Horth.", at = { HALLOWFALL, 44.0, 49.8 }, quest = 82849 },
        { t = "Week 2: give the Dented Spearhead to Auralia Steelstrike.", at = { HALLOWFALL, 42.35, 55.02 }, quest = 82846 },
        { t = "Week 2: give the Ivory Tinderbox to Haverd Sunhart.", at = { HALLOWFALL, 41.6, 34.6 }, quest = 82845 },
        { t = "Week 3 (Time Borrowed, after the next reset): give the Calcified Journal to Lorel Ironglen.", at = { HALLOWFALL, 48.4, 38.8 }, quest = 82835 },
        { t = "Week 3: give the Wooden Figure to Barahl Lynflayme.", at = { HALLOWFALL, 69.2, 43.8 }, quest = 82832 },
        { t = "Week 3: give the Sturdy Locket to Amy Lychenstone; she walks around Mereldar.", at = { HALLOWFALL, 42.38, 49.51 }, quest = 82815 },
    },
    tips = {
        "Each week's quest unlocks after the weekly reset; if Maera has nothing new, it isn't reset day yet.",
        "Lost a memento? The small satchel next to Maera gives a replacement.",
    },
}

-- Life on the Farm: the Hillhelm family
G[40360] = {
    steps = {
        { t = "Seeds of Evil: from Aliya Hillhelm at the farm.", at = { HALLOWFALL, 61.2, 30.6 }, quest = 79108 },
        { t = "Follow Miral: unlocks after Seeds of Evil.", at = { HALLOWFALL, 61.2, 30.6 }, quest = 79109 },
        { t = "Save Tomothy: unlocks after Follow Miral.", at = { HALLOWFALL, 61.2, 30.6 }, quest = 79110 },
        { t = "Keep the Home Fires Burning: also from Aliya.", at = { HALLOWFALL, 61.2, 30.6 }, quest = 76247 },
        { t = "Eggs in One Basket: click the egg basket next to the farm.", at = { HALLOWFALL, 60.8, 27.9 }, quest = 80382 },
        { t = "Reach Renown 12 with the Hallowfall Arathi. From then on the family's lost items can drop." },
        { t = "Pull Shadowrooted Vines around the farm with an Invasive Lashroom targeted (alive or dead). Each lost item starts a quest; hand each one in.", at = { HALLOWFALL, 61.2, 30.6 } },
        { t = "In the Mycomancer Cavern delve, loot the Lost Shoe container for A Lost Shoe.", quest = 83278 },
        { t = "In the Mycomancer Cavern delve, loot an Egg Clutch for A Clutch of Eggs.", quest = 83282 },
    },
    tips = {
        "The vines give nothing unless a Lashroom is your target while you pull.",
        "Several lost items can only drop once a week, so the last few may take a couple of weeks.",
        "Expand the achievement to see which family quests are still missing.",
    },
}

------------------------------------------------------------------------
-- The Ringing Deeps
------------------------------------------------------------------------

-- I Only Need One Trip
G[40623] = {
    steps = {
        { t = "When the ore world quest is up, kill the enemies on the ramp and in the cave first, without looting them." },
        { t = "Pick up the ore bucket.", at = { DEEPS, 60.47, 63.78 } },
        { t = "Go down into the cave and click small or large ore piles until your buff shows 10 ore. Don't mount.", at = { DEEPS, 63.68, 61.90 } },
        { t = "Walk to the hand-in in one trip. Hold the extra button until the bar reaches its notch to steady yourself; stop and wait if you start to stumble.", at = { DEEPS, 57.42, 64.22 } },
    },
    tips = {
        "Dropped ore lies in yellow circles; walk over them to pick it up again.",
        "Druids can prowl the whole way; the steadying button doesn't break stealth.",
    },
}

-- For the Collective
G[40630] = {
    steps = {
        { t = "During the ore world quest, collect ore in the cave as usual.", at = { DEEPS, 63.68, 61.90 } },
        { t = "Give it to a Reclamation Machinist instead of handing it in (each takes up to 20 until its contraption is repaired).", at = { DEEPS, 59.44, 62.98 } },
        { t = "Second machinist.", at = { DEEPS, 59.87, 63.95 } },
        { t = "Third machinist.", at = { DEEPS, 60.12, 64.87 } },
        { t = "The machinist on the roof: place the wooden plank to make a ramp up to the scaffolding.", at = { DEEPS, 60.71, 64.48 } },
        { t = "Fourth machinist.", at = { DEEPS, 62.74, 64.25 } },
        { t = "Keep going on later visits until you've given 100 ore in total." },
    },
    tips = {
        "A repaired contraption takes no ore for two hours; its machinist's bar disappears. Try another shard or come back later.",
        "Progress is kept between visits, so this can be done over several world quest rotations.",
    },
}

-- It's Not Much, But It's Honest Work
G[40662] = {
    steps = {
        { t = "Pick up Gearing Up for Trouble from Gnawbles in Gundargaz.", at = { DEEPS, 43.4, 35.2 }, quest = 83333 },
        { t = "Talk to Speaker Kuldas to enter Awakening the Machine.", at = { DEEPS, 43.2, 32.0 } },
        { t = "Survive 20 waves while keeping the Keeper alive. Interrupt (or stun or knock back) any channelling enemy: it dies at once. Kill Nullbots quickly." },
        { t = "Every five waves you can rest as long as you like; talk to the Keeper when you're ready to go on." },
        { t = "Wave 20 is the Awakened Phalanx, a big elite. Kill it to earn the achievement." },
    },
    tips = {
        "From about wave 11, dead medbots leave green vials; step on them to heal you and the Keeper. They fade after a while.",
    },
}

-- Panhandled
G[40731] = {
    steps = {
        { t = "Go to the Deepforge area where the Overworked Cooks work.", at = { DEEPS, 54, 77 } },
        { t = "Kill an Overworked Cook; it drops a frying pan." },
        { t = "Use the pan to hit enemies 10 times. Your own target dummy toy works too. Grab another pan if it runs out." },
    },
}

-- Gobblin' with Glublurp
G[40614] = {
    steps = {
        { t = "Pick up a Glimmering Crystal (small blue crystal) at the Shadowvein Extraction Site.", at = { DEEPS, 56.87, 40.45 } },
        { t = "Fly to the pond north-west of the site and catch an Ethereal Glimmerling (purple firefly).", at = { DEEPS, 53.95, 33.14 } },
        { t = "Switch to steady flight and bring it to Glublurp the frog at the Waterworks.", at = { DEEPS, 40.17, 50.23 } },
    },
    tips = {
        "Skyriding makes the glimmerling vanish: use steady flight for the trip.",
        "If no crystal is at the marked spot, look around the extraction site; several spawn there.",
    },
}


-- Light's Gambit Champion
G[40729] = {
    steps = {
        { t = "Talk to Rytr Paller at a table at Dunelle's Kindness and challenge him on the hardest formation.", at = { HALLOWFALL, 69.11, 45.66 } },
        { t = "Kill his cleric (the healing piece) first." },
        { t = "Move your pieces behind his castle and attack it from there; ignore his knight." },
        { t = "When the castle falls, finish off the knight." },
    },
}

-- The Derby Dash
G[40539] = {
    steps = {
        { t = "On a Saturday, pick up the Fishing Derby quest from Captain Oathmyt in Mereldar. You get the Derby buff.", at = { HALLOWFALL, 44.22, 61.59 } },
        { t = "While the buff lasts, fish the right pool types across Khaz Algar for each missing fish (expand the achievement for the list)." },
        { t = "Hand in the Derby quest before the time runs out. Progress carries over to next Saturday." },
    },
    tips = { "Fish only count while the Derby buff is on you." },
}

-- Super Size Snuffling
G[40585] = {
    steps = {
        { t = "Fly to north-east Hallowfall near the Hillhelm farm, where Disturbed Earth piles are common.", at = { HALLOWFALL, 61.9, 29.0 } },
        { t = "Loot every Disturbed Earth pile you see for Odd Globs of Wax until you have 100." },
    },
    tips = { "Outline mode in the graphics settings makes the piles easier to spot." },
}

-- Hallowfall Infirmary: one heal a day for 20 days
G[20594] = {
    steps = {
        { t = "Go to the Arathi Infirmary in Mereldar.", at = { HALLOWFALL, 43.0, 51.8 } },
        { t = "Heal one injured soldier with any heal; non-healers can use a bandage." },
        { t = "Come back the next day. It counts once a day per warband, 20 days in all." },
    },
}

-- Turning the Venom Tide: incursion quests
G[41998] = {
    steps = {
        { t = "Pick up the three blue daily incursion quests from Mylton Wyldbraun in Hallowfall.", at = { HALLOWFALL, 28, 56 } },
        { t = "Do them at the marked incursion areas in Hallowfall and Azj-Kahet and hand them in." },
        { t = "Repeat on alts or on later days until you've done 10." },
    },
}

-- Keyflames: Lesser Keyflame quests and the large Keyflame bonus events
G[40308] = {
    steps = {
        { t = "Collect Radiant Remnants; anything in Hallowfall can drop them." },
        { t = "Give 3 to a lesser Keyflame in north-east Hallowfall. A quest giver appears next to it." },
        { t = "Do the quest. Each giver offers one of its quests per week; expand the achievement to see which keyflame offers each missing quest." },
        { t = "Come back after the weekly reset for the quests that weren't offered." },
    },
    crit = {
        ["Right Between the Gyros-Optics"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 65.4, 28.1 } } },
        ["Seeds of Salvation"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 65.4, 28.1 } } },
        ["Tater Trawl"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 65.4, 28.1 } } },
        ["Web of Manipulation"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 63.3, 29.4 } } },
        ["Supply the Effort"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 63.3, 29.4 } } },
        ["Lost in Shadows"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 64.6, 30.6 } } },
        ["Sporadic Growth"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 64.6, 30.6 } } },
        ["Harvest Havoc"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 63.6, 33.6 } } },
        ["Squashing the Threat"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 63.6, 33.6 } } },
        ["The Sweet Eclipse"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 64.4, 30.9 } } },
        ["Shadows of Flavor"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 64.4, 30.9 } } },
        ["Blossoming Delight"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 64.4, 30.9 } } },
        ["Hose It Down"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 65.8, 24.4 } } },
        ["Chew On That"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 65.8, 24.4 } } },
        ["Lizard Looters"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 64.4, 18.7 } } },
        ["Glow in the Dark"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 64.4, 18.7 } } },
        ["Crab Grab"] = { t = "Light this lesser Keyflame (3 Radiant Remnants); its quest giver may offer this quest this week", at = { { HALLOWFALL, 61.5, 17.5 } } },
    },
}
G[40311] = {
    steps = {
        { t = "The eight large Keyflames stand in north-east Hallowfall. A bonus event only runs while its Keyflame is lit." },
        { t = "Light one with 20 Radiant Remnants (shared with other players), or with a Shadowed Ember from the roaming rare for 30 minutes." },
        { t = "Do its bonus event before the flame goes out. Each event can be done once a week." },
        { t = "Repeat for every event still missing (expand the achievement)." },
    },
    crit = {
        ["Bleak Sand"] = { t = "Bonus event at this large Keyflame, only while it is lit", at = { { HALLOWFALL, 61.97, 12.71 } } },
        ["Waters of War"] = { t = "Bonus event at this large Keyflame, only while it is lit", at = { { HALLOWFALL, 61.9, 16.96 } } },
        ["Lurking Below"] = { t = "Bonus event at this large Keyflame, only while it is lit", at = { { HALLOWFALL, 61.83, 32.05 } } },
        ["Bog Beast Banishment"] = { t = "Bonus event at this large Keyflame, only while it is lit", at = { { HALLOWFALL, 66.56, 23.94 } } },
        ["Glowing Harvest"] = { t = "Bonus event at this large Keyflame, only while it is lit", at = { { HALLOWFALL, 63.48, 28.4 } } },
        ["The Midnight Sentry"] = { t = "Bonus event at this large Keyflame, only while it is lit", at = { { HALLOWFALL, 63.9, 19.7 } } },
        ["Cutting Edge"] = { t = "Bonus event at this large Keyflame, only while it is lit", at = { { HALLOWFALL, 63.84, 32.04 } } },
        ["A Better Cabbage Smacker"] = { t = "Bonus event at this large Keyflame, only while it is lit", at = { { HALLOWFALL, 65.01, 29.34 } } },
    },
}

-- Worldsoul Memories
G[40251] = {
    steps = {
        { t = "Use a Radiant Echo, or join a Worldsoul Memory that's already running (they show on the zone maps)." },
        { t = "Fight until about a minute is left: a big enemy appears. Kill it; without that kill the memory doesn't count." },
        { t = "Cancel the Worldsoul Memory buff to leave, and repeat until you have 25." },
    },
    tips = { "Reign of the Old Gods (south Hallowfall) counts reliably; Descendants of Distant Waters sometimes misses the final kill." },
}

-- Alyza's kobyss hunt
G[40082] = {
    steps = {
        { t = "Go to the Hungering Pool while Alyza Bowblaze fights with you: during her storyline quest, or when the Hungering Pool world quest is up (she meets you there).", at = { HALLOWFALL, 50, 50 } },
        { t = "Kill kobyss with her beside you; kills keep counting after the quest's own count is full. Stay in the area." },
        { t = "Continue on later world quests until you have 50." },
    },
    tips = { "An alt doing her teddy bear quest at the pool can do it any time: just don't hand that quest in until you're done." },
}

------------------------------------------------------------------------
-- Azj-Kahet
------------------------------------------------------------------------

-- No Harm Ever Came From Reading A Book
G[40632] = {
    steps = {
        { t = "Enter the spider cave below the City of Threads.", at = { AZJ, 56.7, 85.1 } },
        { t = "Climb the wall where three tiny spiders crawl and drop through the hole at the top.", at = { LOWER, 66.77, 56.26 } },
        { t = "Read the book in the ritual circle by the void pond. Four copies of you appear and vanish. Leave through the Mysterious Portal." },
        { t = "Copy 1: inside the Rock Bottom Inn in Mmarl. Talk to it to send it back.", at = { AZJ, 78.04, 63.25 } },
        { t = "Copy 2: sitting on a rock at Faerin's Advance. Come in from the east side of the camp.", at = { AZJ, 58.70, 20.12 } },
        { t = "Copy 3: sitting by the pond at Wildcamp Or'lay.", at = { AZJ, 24.20, 52.75 } },
        { t = "Copy 4: by the stairs in the Weaver's Lair, walking around near the flight master.", at = { AZJ, 57.22, 44.29 }, quest = 83724 },
    },
    tips = {
        "Find the copies in this order; the next one only appears after the one before.",
        "\"Another you whispers: Did you find me?\" in chat means the copy is close. /target Another You helps.",
    },
}

-- The Unseeming
G[40633] = {
    steps = {
        { t = "Fly to the Maddening Deep in south-east Azj-Kahet.", at = { AZJ, 67, 83 } },
        { t = "Click the red Black Blood Extractors around the area; each gives several stacks of Unseeming Shift. Keep going until you reach 100." },
    },
    tips = { "Standing in the pools no longer gives stacks." },
}

-- You Can't Hang With Us
G[40634] = {
    steps = {
        { t = "In the City of Threads, find a guard with an eye symbol over its head.", at = { THREADS, 60.79, 25.85 } },
        { t = "Attack it. An eradicator appears and keeps casting on you." },
        { t = "Let it reach 10 stacks: you're thrown out of the city and earn the achievement." },
    },
}

-- Skittershaw Spin
G[40727] = {
    steps = {
        { t = "Wait at a Skittershaw stop in the High Hollows of the City of Threads.", at = { THREADS, 71.38, 49.95 } },
        { t = "Board the spider carriage when it arrives and ride it for a whole lap back to where you got on." },
    },
    tips = { "If the area is hostile, finish the City of Threads campaign quests first." },
}

------------------------------------------------------------------------
-- Siren Isle
------------------------------------------------------------------------

-- Siren's Squall: three quests during the storm
G[41185] = {
    steps = {
        { t = "Talk to Suzie Boltwrench to enter the storm version of Siren Isle.", at = { SIREN, 69.1, 49.0 } },
        { t = "Pick up Ricket's Special Delivery from the ground next to her (behind the Crawler Mine). Its extra button is needed for one quest and hits hard." },
        { t = "Do the two blue quests that now show on the map: Eggstinction and Shoreline Stand.", quest = 84241 },
        { t = "Finish the storm world quest, Special Assignment: Storm's a Brewin'. The blue quests already fill most of its bar; kill more enemies if needed.", quest = 85113 },
    },
    tips = { "If you die, the delivery item is gone; run back to grab another before the quest that needs it." },
}

------------------------------------------------------------------------
-- Undermine
------------------------------------------------------------------------

-- C.H.E.T.T. a Look
G[41626] = {
    steps = {
        { t = "Reach Renown 13 with the Cartels of Undermine." },
        { t = "Get a C.H.E.T.T. List from the machine on the second floor of the Incontinental Hotel, right of the stairs." },
        { t = "Do any four of the tasks on the list around Undermine." },
        { t = "Hand the list back in at the same machine." },
    },
    tips = { "After the first list, new ones come from C.H.E.T.T. Cards dropped by enemies in Undermine (a stack of them buys a list), plus one free list each week." },
}
G[41627] = { tips = { "Same as C.H.E.T.T. a Look, twice. Cards for a second list drop from enemies in Undermine." } }

-- Nine-Tenths of the Law: Muff's Auto-Lockers
G[40948] = {
    steps = {
        { t = "Auto-Locker 1: loot the Gorillion fork.", at = { UNDERMINE, 23.82, 45.38 } },
        { t = "Auto-Locker 2: loot the grease.", at = { UNDERMINE, 71.45, 85.94 } },
        { t = "Auto-Locker 3: loot the batteries.", at = { UNDERMINE, 75.14, 22.95 } },
        { t = "Auto-Locker 4: loot the engine.", at = { UNDERMINE, 56.67, 55.47 } },
        { t = "Auto-Locker 5: loot the chassis. The achievement comes with the fifth locker.", at = { UNDERMINE, 34.33, 82.86 } },
        { t = "Combine the five parts from your bags and hand in the quest for the battle pet.", at = { UNDERMINE, 35.40, 41.40 }, quest = 87406 },
    },
}

-- No Littering: S.C.R.A.P. jobs
G[41590] = {
    steps = {
        { t = "Find this hour's S.C.R.A.P. site (the map marks it) and talk to the job NPC." },
        { t = "Right-click trash piles to shovel; fill the bar to 500 in two minutes. 100 gold buys a helper robot." },
        { t = "Use the blue circles (double speed), dodge the green ones (knockback), walk over fires, click mines and break trash bags." },
        { t = "Repeat until you've done 10 jobs." },
    },
}
G[41593] = {
    steps = {
        { t = "Do a S.C.R.A.P. job at each of the seven sites. Only one is active at a time and it rotates; expand the achievement to see which sites are left." },
    },
}


-- Excavation Projects
G[41043] = {
    steps = {
        { t = "Collect at least 15 Flame-Blessed Iron on Siren Isle." },
        { t = "At the command map in the middle of the island, contribute to each of the three excavations once.", at = { SIREN, 69.48, 43.44 } },
    },
    tips = { "A full excavation takes no more; change shard or come back after it resets." },
}

------------------------------------------------------------------------
-- K'aresh
------------------------------------------------------------------------

-- Moonlighter, Bounty Seeker, Vigilante: warrants
G[41980] = {
    steps = {
        { t = "Each week, pick up that week's warrant quest in Tazavesh.", at = { TAZAVESH, 48.70, 57.70 } },
        { t = "Do its short chain: three quests that end with a key." },
        { t = "Use the key to summon the wanted rare and kill it." },
        { t = "One warrant a week; six in all. The mount arrives by mail." },
    },
    tips = { "The keys can be bought on the Auction House and still count, which skips the weekly wait." },
}
G[41978] = { tips = { "Two warrants: see Vigilante for the steps. Keys from the Auction House count." } }
G[41979] = { tips = { "Four warrants: see Vigilante for the steps. Keys from the Auction House count." } }

-- Jump, Jump, and Away!
G[42730] = {
    steps = {
        { t = "Get the What Lies Beyond power on the Reshii Wraps (rank 5) and reach K'aresh Trust Renown 11." },
        { t = "Go to the high ground above the Ruins of Yaathron.", at = { KARESH, 52, 72 } },
        { t = "Glide down onto the Ethereal Voidforged Container and loot it.", quest = 89378 },
    },
}

-- We've All Got Swords!
G[42738] = {
    steps = {
        { t = "Finish the K'aresh story until you have the Reshii Wraps." },
        { t = "Upgrade the wraps until you have What Lies Beyond; it lets you see the hidden treasures." },
        { t = "Enter the untethered space and loot both swords (expand the achievement for which is left)." },
    },
}

-- Phase-Lost-and-Found
G[61017] = {
    steps = {
        { t = "Upgrade the Reshii Wraps to rank 3 so you can use Phase Diving orbs." },
        { t = "Phase dive and look for orbs all over K'aresh and Tazavesh. Each orb serves one player." },
        { t = "About one orb in five gives a Phase-Lost weapon you don't have yet. Keep going until all six are collected." },
    },
}

-- Brokers Don't Care How You Win
G[41778] = {
    steps = {
        { t = "Wait for the Oasis challenge race quest; it changes on the Tuesday and Friday resets." },
        { t = "Optional: pick up an Untethered Xy'bucha (several spots around K'aresh) and use it just before the race starts." },
        { t = "Race and beat the Slateback Alpha, then the Zooming Necroray." },
    },
    tips = { "Players report that dropping and re-taking the quest mid-race can leave the rival stuck at the start." },
}


------------------------------------------------------------------------
-- Delves
------------------------------------------------------------------------

-- Raisin' Brann
G[40820] = {
    steps = {
        { t = "Set Brann to the damage role and give him the Rage-Filled Idol curio; it slowly hurts him in combat." },
        { t = "Run a delve until he falls unconscious." },
        { t = "Revive him." },
    },
    tips = { "Another way: in Earthcrawl Mines on a Precious Ores day, park him on the mine cart track." },
}

------------------------------------------------------------------------
-- Appearance sets from vendors
------------------------------------------------------------------------

G[40728] = {
    steps = {
        { t = "Go to the PvP armor vendor in Dornogal.", at = { DORNOGAL, 55.0, 76.5 } },
        { t = "Buy every piece of the season's honor set (or a forged set) for your armor type, cloak included." },
        { t = "Equip each piece so it can no longer be refunded; the achievement comes when the set is complete." },
    },
}
G[41595] = G[40728]
G[42800] = G[40728]
G[42316] = {
    steps = {
        { t = "Reach Renown 2 with the Manaforge Vandals." },
        { t = "Kill Loom'ithar in Manaforge Omega for Loombeast Silk (once a week per account)." },
        { t = "Buy the cloak with the silk from Ba'choso outside the raid, and the rest of the set from the PvP armor vendor in Dornogal.", at = { DORNOGAL, 55.0, 76.5 } },
        { t = "Equip every piece." },
    },
}


------------------------------------------------------------------------
-- Nerub-ar Palace (Normal or harder)
------------------------------------------------------------------------

-- Ulgrax: Taking It to Go? (the Spider Silk Grub)
G[40261] = {
    steps = {
        { t = "Find the Spider Silk Grub at the back right of the room as you enter, near the edge." },
        { t = "Click it before the pull, or it dies at once." },
        { t = "Pull the boss away from the grub. One player keeps herding it away from danger through phase 1." },
        { t = "The intermission is where it usually dies: skip it with high damage, or stand so the boss's charges don't cross the grub (side-on or far away). Kill the boss with it alive." },
    },
    tips = { "The grub can't be healed and dies to almost anything." },
}

-- Bloodbound Horror: the slimes downstairs
G[40260] = {
    steps = {
        { t = "Bring at least 10 players; with fewer the ooze never spawns." },
        { t = "When the frontal sends a group downstairs, every player steps on one of the slimes around the edges of the room (only visible down there)." },
        { t = "Stay alive until everyone has the slime debuff. Use as many downstairs phases as you need; hold damage on the boss." },
        { t = "Stack up to clear the debuffs. A Volatile Ooze appears a few seconds later: kill it." },
        { t = "Kill the boss only after the ooze is dead." },
    },
}

-- Sikran: every player hits her with a weapon
G[40255] = {
    steps = {
        { t = "On the way to Sikran (from Bloodbound Horror onward), players pick up the weapons from the racks; you get an extra button." },
        { t = "In the fight, walk up to Sikran and use the button facing her. You get a debuff (more damage taken) and the weapon drops to the floor." },
        { t = "The next player picks up the dropped weapon and does the same. Move the boss so dropped weapons are easy to see." },
        { t = "Once every player has the debuff, kill her." },
    },
    tips = { "Players who die keep the debuff; anyone who dies before their turn must be resurrected first." },
}

-- Rasha'nan: one Rolling Acid stack each
G[40262] = {
    steps = {
        { t = "When Rolling Acid targets two players, the one sending the wave left stands far left, the one sending it right stands a little left of the raid." },
        { t = "Both targets stand still and don't ride any wave." },
        { t = "The rest of the raid stands in the middle and gets hit by the right-hand wave only, running into it so it hits once." },
        { t = "Repeat for every Rolling Acid cast. The tracked achievement turns white when a wave went right; kill the boss with it white." },
    },
    tips = { "Immunities, blinks and dodges skip the debuff and break it." },
}

-- Broodtwister Ovi'nax: the Disheartened Worm
G[40263] = {
    steps = {
        { t = "Bring at least 10 players." },
        { t = "On the way to the boss, one player (a tank is ideal) picks up the orange Mysterious Glowing Egg and carries it into the fight; carrying slows you." },
        { t = "During the fight, the egg carrier stands where two Experimental Dosage circles hit them at the same time. The egg breaks and a Disheartened Worm appears." },
        { t = "Everyone targets the worm and types /love straight away (it hurts until it's loved). The Affectionate debuff shows who has done it." },
        { t = "Kill the boss." },
    },
    tips = { "The egg resets after a wipe, so you can retry." },
}

-- Nexus-Princess Ky'veza: Kill Streak
G[40264] = {
    steps = {
        { t = "On entering the room, one player reads the burning diary in the first brazier on the left. This pulls the boss and kills the reader; she gains Kill Streak." },
        { t = "Keep Kill Streak up: a player has to die before it runs out (about 45 seconds). Assign one player per set to walk into a rift." },
        { t = "Keep feeding deaths through the intermission and kill her with the buff still up." },
    },
}

-- The Silken Court: Love is in the Lair
G[40730] = {
    steps = {
        { t = "At the bottom of the stairs before the boss, pick up the Box of Candy from the railing on the left." },
        { t = "At the door to the Ky'veza path, pick up the Anub'arash Plushie on the left of the door frame." },
        { t = "In the boss room, throw the plushie at Anub'arash and the candy at Takazj with the extra buttons." },
        { t = "Pull without fighting any trash first, and keep the two bosses apart for the whole fight (stacked, they heal)." },
    },
    tips = { "Entering combat before the pull removes the buffs; the items come back a minute or two later." },
}

-- Queen Ansurek: the portals in phase 3
G[40266] = {
    steps = {
        { t = "Get to phase 3; players who died earlier count automatically." },
        { t = "When two players get the portal debuff, one drops theirs near the middle and the other far out on the opposite side of the boss. Mark the spots before the pull." },
        { t = "When the ring starts closing in, every living player takes a portal so they pass under the boss and come out safe." },
        { t = "The boss gains one stack per player; kill her." },
    },
}

------------------------------------------------------------------------
-- Liberation of Undermine (Normal or harder)
------------------------------------------------------------------------

-- Vexie and the Geargrinders: Hold My Gear!
G[41208] = {
    steps = {
        { t = "Note the five objects around the edge of the arena: a dumpster, a trash pile, a tire stack, a tool rack and a storage crate." },
        { t = "During the fight, players on bikes steer one bike into each object so it catches fire. Keep removing the boss's plating as usual." },
        { t = "When all five burn, kill the boss." },
    },
}

-- Cauldron of Carnage: the two fan achievements and The Splash Zone
G[41694] = {
    steps = {
        { t = "Talk to the fan NPC just outside the arena to become Flarendo's fan." },
        { t = "In the fight, kill Torq's lieutenant first; your buff changes to show you're Flarendo's biggest fan." },
        { t = "Finish the encounter with the buff (Flarendo himself doesn't need to die last)." },
    },
    tips = { "A wipe removes the buff; talk to the fan again." },
}
G[41695] = {
    steps = {
        { t = "Talk to the fan NPC just outside the arena to become Torq's fan." },
        { t = "In the fight, kill Flarendo's lieutenant first; your buff changes to show you're Torq's biggest fan." },
        { t = "Finish the encounter with the buff (Torq himself doesn't need to die last)." },
    },
    tips = { "A wipe removes the buff; talk to the fan again." },
}
G[41554] = {
    steps = {
        { t = "Buy both punch potions from the two vendors before the boss; take spares in case you die." },
        { t = "During the fight, drink one, then the other after the shared one-minute cooldown. Together they give you Hubris." },
        { t = "Have Hubris when the bosses die. It's personal: each player earns it for themselves." },
    },
    tips = { "The potions only work during the fight, so you can't drink them before the pull." },
}

-- Rik Reverb: Just /Dance
G[41338] = {
    steps = {
        { t = "Pick two players (immunities help), one for each side of the arena." },
        { t = "When Rik casts Hype Hustle in the intermission, each goes to the disco ball on their side and types /dance until it lights up." },
        { t = "Kill the boss." },
    },
}

-- Stix Bunkjunker: Garbage In, Garbage Out
G[41596] = {
    steps = {
        { t = "Bring extra healing: burning trash puts a stacking debuff on you." },
        { t = "Each time Stix throws out garbage, roll over or burn every pile before the next batch. He gains an Impressed buff (yellow mask) when it's all gone." },
        { t = "Repeat for every batch and kill him. Track the achievement: it turns white each time a batch is cleared." },
    },
}

-- Sprocketmonger Lockenstock: Conveyor Slayer
G[41711] = {
    tips = {
        "Don't get hit by Blazing Beam, Rocket Barrage, Mega Magnetize or the other listed abilities during the kill.",
        "Dying counts as fine, as long as you weren't hit before you died.",
    },
}

-- One-Armed Bandit: One Rank Higher and Best In Class
G[41119] = {
    steps = {
        { t = "In the casino area before the boss, pick up one casino chip from the floor. Red (fire rings to dodge) is the easiest." },
        { t = "Put it into its slot machine just outside the boss room." },
        { t = "Kill the boss with that extra mechanic active." },
    },
}
G[41122] = {
    steps = {
        { t = "Pick up all four casino chips in the casino area: red (fire rings), purple (healing reduction), blue (silences), gold (more boss health)." },
        { t = "Put each into its slot machine outside the boss room." },
        { t = "Kill the boss with all four mechanics. High item level and an extra healer make it far easier." },
    },
}

-- Mug'Zee: A Good Day to Dye Hard and Sleep with the Fishes
G[41211] = {
    steps = {
        { t = "Clear the raid up to and including the trash before the One-Armed Bandit, but don't kill him yet." },
        { t = "Clear the trash around the purple casino chip in the Gallagio, but don't loot the chip." },
        { t = "Everyone stacks on top of the chip and waits for the fountain's splash. You get a dye buff that lasts 20 minutes (the other side of the fountain gives green; just make sure everyone has the same colour)." },
        { t = "Without anyone dying, kill the One-Armed Bandit and then Mug'Zee before the buff runs out." },
    },
    tips = {
        "The buff can't be gained once the One-Armed Bandit is dead.",
        "It works with a small group too.",
    },
}
G[41337] = {
    steps = {
        { t = "At the entrance to Mug'Zee's room, take the teleport pad left of the door down to the aquarium." },
        { t = "Break the cement block holding Fish Stix down. He swims up to the boss room." },
        { t = "Talk to Fish Stix before pulling." },
        { t = "During the fight he throws Sleepy Fish in 1-health bubbles. Pop a bubble, stand on the fish and /sleep. Each player needs their own fish." },
        { t = "When everyone has Slept with the Fishes, kill the boss." },
    },
    tips = {
        "A wipe means freeing Fish Stix again.",
        "A macro helps: /target Sleepy Fish then /sleep. You must be right on top of the fish.",
    },
}

G[41120] = { tips = { "One-Armed Bandit with two casino chips in their slot machines (see One Rank Higher for where the chips are)." } }
G[41121] = { tips = { "One-Armed Bandit with three casino chips in their slot machines (see One Rank Higher for where the chips are)." } }

-- Chrome King Gallywix: Scheming on a Thing
G[41347] = {
    steps = {
        { t = "Hold damage so the boss doesn't reach 50% before his second set of bomb adds; the first set only opens one platform." },
        { t = "On the second set, three players each take a Giga Bomb to a different Giga Control and walk in together." },
        { t = "Throw the remaining bombs as usual to break the overloaded coil, then kill him." },
    },
}

------------------------------------------------------------------------
-- Manaforge Omega (Normal or harder)
------------------------------------------------------------------------

-- Plexus Sentinel: Of Mice and Manaforges
G[42118] = {
    steps = {
        { t = "Split the raid into three groups, one per run-back intermission." },
        { t = "In each intermission, that group runs over the mice in the corridor (mostly at the sides and the back). Each catch gives a debuff." },
        { t = "When every player has caught one, kill the boss. Dying after your catch is fine." },
    },
}

-- Loom'ithar: Time to Vote! Cute or Scary?
G[41613] = {
    steps = {
        { t = "Before the pull, every player targets Loom'ithar and types /cuddle or /cower. Anyone can pick either." },
        { t = "When everyone has voted, the boss gets the majority's buff. Pull and kill it." },
    },
}

-- Soulbinder Naazindhri: Mother of All Tantrums
G[41614] = {
    steps = {
        { t = "During the fight, click the small pads in the four corners of the room. Each releases a Little Unbound Soul." },
        { t = "Kill all four souls (they have little health), then kill the boss." },
    },
}

-- Forgeweaver Araz: Cheat Meal
G[41615] = {
    steps = {
        { t = "Kill the first Arcane Echo, but a tank picks up and holds the second one. Nobody damages it." },
        { t = "When the boss reaches 100 energy and opens the arcane beam in the middle, the tank drags the echo through the beam: it becomes a Forged Echo." },
        { t = "Don't push the boss below 25% before the echo is forged; if there is none at 25%, reset." },
        { t = "In the last phase, small void adds spawn as the boss pulls everyone in. Drag the echo over them until it turns into a Void Forged Echo." },
        { t = "Kill the echo quickly (it enrages), then kill the boss." },
    },
}

-- The Soul Hunters: I See... Absolutely Nothing
G[41616] = {
    steps = {
        { t = "Before the pull, pick up Adarus' spare blindfold from the floor near the tents on the right. You get an extra button." },
        { t = "During the fight, every player uses the blindfold at least once. For a minute you only see the bosses." },
        { t = "Kill the bosses." },
    },
    tips = { "Demon hunters barely notice the blindfold." },
}

-- Fractillus: Breaking the Fourth Wall
G[41617] = {
    steps = {
        { t = "Bring plenty of healers; the fight runs to the enrage. Number the six lanes with markers." },
        { t = "Each cycle: three players place walls, then the tank places one, then three more. Build lanes up to four walls deep, never five." },
        { t = "Then four players get knockbacks: each breaks the fourth wall of a lane. Every fourth wall broken counts." },
        { t = "Plan the lanes so each cycle leaves four lanes with a fourth wall to break. After about six cycles the counter is usually met (track the achievement); then kill the boss." },
    },
    tips = { "The hardest of the set. A sixth wall in one lane wipes the raid." },
}

-- Nexus-King Salhadaar: King's Ransom
G[41618] = {
    steps = {
        { t = "Before the pull, go to the far end of the bridge on the left, past the boss platform. Princess Ky'veza appears; one player talks to her." },
        { t = "Pull. She joins the fight throwing daggers (they hurt but don't kill; sidestep them)." },
        { t = "Kill the boss. After a wipe, talk to her again." },
    },
}

-- Dimensius: Defying Gravity
G[41619] = {
    steps = {
        { t = "Bring at least 10 players; with fewer it doesn't count." },
        { t = "On the first Reverse Gravity, everyone except the two Excess Mass players stands in the circles and gets knocked up." },
        { t = "On the next cycle, two other players take Excess Mass so the first two can be knocked up too." },
        { t = "When the whole raid has been hit, push to phase 2 and kill the boss." },
    },
}

------------------------------------------------------------------------
-- Revisited Horrific Visions
------------------------------------------------------------------------

local function vision(city, boss)
    return {
        steps = {
            { t = "Wait for the week the " .. city .. " vision is open (one city a week)." },
            { t = "Queue at the Portal to Horrific Visions in Dornogal, south of the Coreway tunnel." },
            { t = "In the starting room, talk to the Image of Wrathion to begin." },
            { t = "Defeat " .. boss .. ", the main objective, in the first area (skull on the map). This ends the vision." },
        },
    }
end
G[41853] = vision("Stormwind", "Alleria")
G[41875] = vision("Orgrimmar", "Thrall")

local function allObjectives(city)
    return {
        steps = {
            { t = "Buy Hourglass upgrades with Mementos first; more sanity and time make a full clear possible." },
            { t = "In the " .. city .. " vision, finish the four bonus objectives first: two in the Corrupted areas, then two in the harder Lost areas." },
            { t = "Sanity is your timer: grab Sanity Restoration Orbs, check each area's Madness on the map, and don't overpull." },
            { t = "Defeat the main boss in the first area last; killing it ends the vision." },
        },
    }
end
G[41854] = allObjectives("Stormwind")
G[41876] = allObjectives("Orgrimmar")

G[41873] = {
    steps = {
        { t = "In any vision, finish at least two bonus objectives (the Corrupted areas are the easier ones)." },
        { t = "Then defeat the main boss in the first area; it ends the vision." },
    },
}

-- the masks
G[41883] = {   -- Long Night
    steps = { { t = "Complete all five objectives in a single visit of either vision. The mask unlocks on the way out." } },
}
G[41881] = {   -- Burned Bridge
    steps = { { t = "With one mask on, complete the Valley of Wisdom objective in the Orgrimmar vision." } },
}
G[41882] = {   -- Daredevil
    steps = { { t = "With one mask on, complete the Valley of Honor objective in the Orgrimmar vision." } },
}
G[41856] = {   -- Pained
    steps = { { t = "With one mask on, complete the Old Town objective in the Stormwind vision." } },
}
G[41880] = {   -- Dark Imagination
    steps = { { t = "With one mask on, complete the Mage Quarter objective in the Stormwind vision." } },
}
G[41884] = {   -- Vengeance
    steps = {
        { t = "Put on one mask and enter the Stormwind vision." },
        { t = "Go to the canals between the Trade District and Old Town." },
        { t = "Defeat the Vengeful Voidspeakers revering the mask and loot the Faceless Mask of Vengeance." },
    },
}
G[41710] = {   -- Nemesis
    steps = {
        { t = "With one mask on, in the Stormwind vision: click Hogger's WANTED poster right of the Mage Quarter entrance, defeat him and loot his Nemesis Shard." },
        { t = "With one mask on, in the Orgrimmar vision: click Gamon's axe on the table on the right of the Broken Tusk inn's ground floor (Valley of Strength), defeat him and loot his Nemesis Shard." },
        { t = "Combine the two shards into the mask." },
    },
    tips = { "The two cities alternate weekly, so this takes at least two weeks." },
}
G[41885] = {   -- Multitudes
    steps = { { t = "With at least one mask on, complete every objective and kill every enemy in one visit." } },
    tips = { "The hardest mask to earn: plan a full route and bring a group." },
}
G[41889] = {
    steps = {
        { t = "Long Night first: all five objectives in one visit." },
        { t = "Wearing it, earn Burned Bridge and Daredevil (Orgrimmar weeks) and Pained, Dark Imagination and Vengeance (Stormwind weeks)." },
        { t = "Nemesis: Hogger's and Gamon's shards, one per city." },
        { t = "Multitudes last: every objective and every enemy in one visit." },
    },
    tips = { "Only one player in the group needs a mask for everyone to use it." },
}

G[41857] = { tips = { "Complete every objective in any vision with one mask on. Burned Bridge is a gentle first mask." } }
G[41890] = { tips = { "Every objective with two masks on. A good order to add masks: Burned Bridge, Dark Imagination, Nemesis, Vengeance, Daredevil, Long Night, Pained, Multitudes." } }
G[41891] = G[41890]
G[41893] = G[41890]
G[41874] = G[41890]
G[41858] = G[41890]
G[41894] = G[41890]
G[41895] = { tips = { "Every objective with all eight masks on: enemies have three times their health and damage. Full Hourglass upgrades and a practised group are a must." } }

local function mostHorrific(city, n)
    return {
        steps = {
            { t = "Earn at least " .. n .. " masks and buy the full Hourglass upgrades first." },
            { t = "In a " .. city .. " week, put on " .. n .. " masks in the starting room." },
            { t = "Finish the four bonus objectives, then the main boss last, in one visit." },
        },
    }
end
G[41855] = mostHorrific("Stormwind", 5)
G[41879] = mostHorrific("Orgrimmar", 5)
G[41964] = mostHorrific("Stormwind", 8)
G[41965] = mostHorrific("Orgrimmar", 8)

G[41725] = {
    steps = {
        { t = "Earn Displaced Corrupted Mementos from vision runs." },
        { t = "Buy Echoes of N'Zoth with them (limited each week) and research every item in the Hourglass of Horrific Visions. It takes at least three weeks." },
    },
}

-- Mementos
G[41859] = { tips = { "Displaced Corrupted Mementos come from every vision run; masks raise the amount by 20% each." } }
G[41896] = G[41859]
G[41897] = G[41859]
G[41898] = G[41859]
G[41983] = G[41859]

------------------------------------------------------------------------
-- Lorewalking
------------------------------------------------------------------------

local function lorewalk(story, volumes, where)
    return {
        steps = {
            { t = "Talk to Assistant Lorewalker Li Li on the Keeper's Terrace in Dornogal (she's also in Stormwind, Orgrimmar and Silvermoon).", at = { DORNOGAL, 49.7, 31.5 } },
            { t = "Ask what stories she can tell and choose " .. story .. "." },
            { t = "Play through all " .. volumes .. " volumes: " .. where .. "." },
        },
        tips = {
            "You can pause with the chat bubble on the Lorewalking panel and continue later from Li Li.",
            "Only one saved Lorewalking story at a time: starting another deletes the saved one.",
        },
    }
end
G[42187] = lorewalk("the Ethereals", 3, "Netherstorm and Dimensius, Alleria and Locus Walker in Legion, then the Brokers and Tazavesh in the Shadowlands")
G[42188] = lorewalk("Xal'atath", 3, "the blade in Legion, how she gained a body in Battle for Azeroth, and the Black Empire")
G[42189] = lorewalk("the Lich King", 2, "the Culling of Stratholme and Wrath of the Lich King, then playing as the Lich King")

------------------------------------------------------------------------
-- Delve system
------------------------------------------------------------------------

local brann = {
    steps = {
        { t = "Run delves with Brann (or your current delve companion); every finished delve gives him experience." },
        { t = "Higher tiers and bountiful delves give more. Enemies killed inside count too." },
    },
    tips = { "A quick boost: in the Dread Pit on a Smashing Skardyn day, stun and blow up the Skardyn packs; each gives about 10 companion experience." },
}
for _, id in ipairs({ 40455, 40450, 40451, 40456, 40457, 40461, 41537, 41723, 61342, 42676, 40538 }) do G[id] = brann end

local runs = { tips = { "Any delve on any tier counts. Bountiful delves (marked on the map) give the best rewards for the same time." } }
for _, id in ipairs({ 40436, 40460, 40462, 40463, 41095, 41096 }) do G[id] = runs end

G[40512] = { tips = { "Finish any Tier 2 delve (or higher). Each tier unlocks after the one below it." } }
G[40514] = { tips = { "Finish any Tier 3 delve (or higher)." } }

local keys = {
    steps = {
        { t = "Earn Restored Coffer Keys from weekly activities and world content; Coffer Key Shards combine into keys too." },
        { t = "Run a bountiful delve (gold icon on the map) and open the Bountiful Coffer at the end with a key." },
    },
}
for _, id in ipairs({ 40819, 40788, 40882, 40885 }) do G[id] = keys end

G[40817] = {
    steps = {
        { t = "Get a Delver's Bounty map; it drops inside delves (Tier 8 or higher is reported as most reliable)." },
        { t = "Use it inside a delve to reveal a Hidden Trove, and open the trove. Ten in all." },
    },
    tips = { "Some players go many runs without a map; it's luck." },
}
local curios = { tips = { "Mislaid Curiosities are small treasures hidden inside delves; loot every one you see. Higher tiers and some stories have more." } }
G[40763] = curios
G[41097] = curios
local puzzles = { tips = { "Some delve stories have a puzzle in them (for example the Dread Pit's Lost Gems story has one in the middle). Solving it counts." } }
for _, id in ipairs({ 40863, 40864, 41105 }) do G[id] = puzzles end
local flicker = { tips = { "Bountiful delves always have a Flickergate; Sanctified Banners and Dundun also count. Interact with each one you pass." } }
G[42778] = flicker
G[42779] = flicker
G[40458] = { tips = { "Strange disturbances are rare enemies that sometimes appear in delves. Defeat 10 of them; the more delves you run, the more you meet." } }
G[42771] = { tips = { "Archival Assault always uses one fixed story on Tiers 1 to 3: run it on Tier 4 or higher to see the other stories.", "In the drake rescue story, freed drakes can turn hostile; stay ready to fight." } }
G[40448] = { tips = { "Every War Within delve on Tier 8 or higher without running out of lives. Pick days with easy stories." } }
G[40438] = { tips = { "A seasonal meta: the Tier 8 and nemesis parts are tied to the season they came from, so check which parts can still be done." } }
G[41532] = {
    steps = { { t = "Buy the Delver's Gob-Trotter from Reno Jackson, the delve vendor in Dornogal, for 10,000 Resonance Crystals." } },
}

------------------------------------------------------------------------
-- World PvP and Deephaul Ravine
------------------------------------------------------------------------

G[40089] = {
    steps = {
        { t = "Turn on War Mode." },
        { t = "An Unbound Spoils chest appears four times a day, once in every six-hour window from the daily reset, in the open PvP area of one Khaz Algar zone (it shows on the map like an air drop)." },
        { t = "Capture it before the other faction does." },
    },
}
G[40090] = G[40089]
G[40091] = { tips = { "The Unbound Spoils spawn always at the same spot in each zone's free-for-all area; the zone changes every six hours. Capture one in each listed zone." } }
G[40466] = {
    steps = {
        { t = "With War Mode on, watch for a War Supply Crate plane (it shows on the map)." },
        { t = "Be the first to open the crate when it lands; looting a chest someone else opened doesn't count." },
    },
}
G[40467] = G[40466]
G[40464] = { tips = { "With War Mode on, kill 10 players in a row without dying to become an Assassin; killing an Assassin drops a bounty to loot.", "Players in your party don't count, nor do targets that give no honor." } }
G[40465] = G[40464]
G[40613] = { tips = { "In one Deephaul Ravine match, capture the crystal three times, never die all game, and win." } }
G[40616] = { tips = { "Kill players right after they leave an Earthen mine cart in Deephaul Ravine. Hard to arrange in random games; premade groups make it far easier." } }
local tour = { tips = { "Earn 1000 honor in this zone with War Mode on: kill players, world PvP quests and the air drops all give honor." } }
for _, id in ipairs({ 40083, 40084, 40085, 40086, 41522, 42131 }) do G[id] = tour end

------------------------------------------------------------------------
-- Reputation
------------------------------------------------------------------------

G[41997] = { tips = { "Flame's Radiance renown comes from the Nightfall scenario in Hallowfall (about 1000 reputation per run, and it can be run every hour) plus its three daily quests." } }
G[60939] = { tips = { "Gallagio Loyalty Rewards Club renown only comes from the Liberation of Undermine raid: about two renown per weekly clear, on any difficulty." } }
G[60940] = { tips = { "Manaforge Vandals renown comes from clearing Manaforge Omega each week." } }
G[42022] = { tips = { "The K'aresh Trust renown: K'aresh world quests, the weekly quests and the Oasis and phase diving activities." } }
G[41086] = { tips = { "Cartels of Undermine renown: Undermine world quests, weeklies, S.C.R.A.P. jobs and Undermine events." } }

------------------------------------------------------------------------
-- Quests and odd ones
------------------------------------------------------------------------

G[40309] = {
    steps = {
        { t = "Create a new earthen character and level it to 50." },
        { t = "Relog if the heritage armor quest doesn't appear." },
        { t = "Go to Dornogal (the Orgrimmar or Stormwind portal room has a portal) and upload your experience at the archives; the achievement pops then." },
    },
}
G[42736] = { tips = { "Loot Ixthar's Favorite Crystal and defeat Ixthar the Unblinking in K'aresh. You don't need cloak upgrades to see him; he has a long respawn timer." } }
G[40503] = { tips = { "Algari Anglerthread goes onto your fishing pole after the Algari Weaverline. The threads count per character." } }

-- Explore the Ringing Deeps (positions moved to the 11.1 map)
G[40825] = {
    tips = { "The Rumbling Wastes can still look fogged on the map after it counts; check the achievement instead." },
    crit = {
        ["The Earthenworks"] = { t = "Fly over this area", at = { { DEEPS, 42.95, 18.30 } } },
        ["Shadowvein Extraction Site"] = { t = "Fly over this area", at = { { DEEPS, 57.48, 41.82 } } },
        ["The Waterworks"] = { t = "Fly over this area", at = { { DEEPS, 41.73, 43.89 } } },
        ["The Living Grotto"] = { t = "Fly over this area", at = { { DEEPS, 51.48, 67.17 } } },
        ["The Hallowfall Gate"] = { t = "Fly over this area", at = { { DEEPS, 36.68, 23.80 } } },
        ["Lost Mines"] = { t = "Fly over this area", at = { { DEEPS, 55.17, 24.56 } } },
        ["The Rumbling Wastes"] = { t = "Fly over this area", at = { { DEEPS, 59.80, 51.80 } } },
        ["Taelloch"] = { t = "Fly over this area", at = { { DEEPS, 58.11, 60.25 } } },
        ["Opportunity Point"] = { t = "Fly over this area", at = { { DEEPS, 60.52, 78.21 } } },
        ["Gundargaz"] = { t = "Fly over this area", at = { { DEEPS, 42.90, 33.46 } } },
    },
}

-- A Choir of Citrines
G[41050] = {
    steps = {
        { t = "Do the Siren Isle story: Windsinger's Runed Citrine comes from the Reforged Anew questline (Angorla)." },
        { t = "Buy the vendor citrines at the island's camp; drops from enemies and chests also give them." },
        { t = "Run the island's events and excavations for the event citrines (see each gem below)." },
        { t = "Do the Siren Isle weekly quests for the last two gems." },
    },
    tips = { "If a gem you own doesn't count, keep a spare in your bags and hand in a weekly quest; that triggers the credit." },
    crit = {
        ["Windsinger's Runed Citrine"] = { t = "From the Reforged Anew questline (Angorla)" },
        ["Mariner's Hallowed Citrine"] = { t = "Drops from enemies and chests, or buy it from Apprentice Tanmar" },
        ["Roaring War-Queen's Citrine"] = { t = "Drops from enemies and chests, or buy it from Taljori" },
        ["Thunderlord's Crackling Citrine"] = { t = "Drops from enemies and chests, or buy it from Didi the Wrench" },
        ["Old Salt's Bardic Citrine"] = { t = "Weekly event reward (players got it from Nerathor in the Drowned Lair)" },
        ["Stormbringer's Runed Citrine"] = { t = "Weekly event reward (players got it from Stalagnarok in the Shuddering Hollow)" },
        ["Fathomdweller's Runed Citrine"] = { t = "Drops in island events (the Shuddering Hollow)" },
        ["Undersea Overseer's Citrine"] = { t = "Drops from a major excavation (the Drain)" },
        ["Storm Sewer's Citrine"] = { t = "Drops from the Drowned Lair excavation" },
        ["Squall Sailor's Citrine"] = { t = "Drops from the Drain excavation" },
        ["Seabed Leviathan's Citrine"] = { t = "From a Siren Isle weekly quest", quest = 84850 },
        ["Legendary Skipper's Citrine"] = { t = "From a Siren Isle weekly quest", quest = 84851 },
    },
}

-- Worm Theory
G[40869] = {
    steps = {
        { t = "Finish the Azj-Kahet campaign and choose a pact in the Weaver's Lair; that opens the zone's world quests." },
        { t = "Do the listed world quests as they come up: Grub Run in the north-west, the others in Rak-Ush in the south-east." },
    },
}

-- The General's Salute and friends
G[40833] = {
    steps = {
        { t = "Reach rank 7 with the General (about Severed Threads renown 20)." },
        { t = "Pick up the breadcrumb from Anub'azal in the Weaver's Lair." },
        { t = "Do Demand Satisfaction, Duel of the Fates and The General's Conviction." },
    },
}
G[41812] = {
    steps = {
        { t = "Start the Oasis questline in K'aresh.", at = { KARESH, 39.57, 24.23 }, quest = 87290 },
        { t = "Continue with the quest givers at the Oasis.", at = { KARESH, 75.9, 34.2 } },
        { t = "Parts are weekly gated: each week, do every quest the map shows in the Oasis until the experts have joined." },
    },
}

------------------------------------------------------------------------
-- More quests, reputation and PvP
------------------------------------------------------------------------

local redDawn = {
    steps = {
        { t = "At level 80, find Faerin Lothar outside Stonelight Rest in Dornogal and pick up Trouble in the Highlands.", at = { DORNOGAL, 46.2, 50.1 } },
        { t = "Follow the Rise of the Red Dawn campaign in the Arathi Highlands to its end, Past Glory." },
    },
    tips = { "Finishing it on one faction also unlocks the other faction's title for your warband." },
}
G[41818] = redDawn
G[41820] = redDawn

G[41996] = {
    steps = {
        { t = "Join the Nightfall scenario in Hallowfall; a new run starts every hour (check the map)." },
        { t = "Complete one run." },
    },
    tips = { "Each run also gives a large amount of Flame's Radiance reputation." },
}
G[40250] = {
    steps = { { t = "Join any Worldsoul Memory in Khaz Algar and stay until its final enemy dies (about a minute before the end)." } },
}
G[42737] = {
    steps = {
        { t = "Finish the K'aresh story so the capstone Special Assignments unlock." },
        { t = "Complete Special Assignment: Overshadowed and Special Assignment: Aligned Views when they are up." },
    },
}
G[42742] = {
    steps = {
        { t = "Get the Reshii Wraps from the K'aresh story." },
        { t = "Upgrade them rank by rank with the materials from K'aresh activities (phase diving, world quests, the Oasis) until fully upgraded." },
    },
}
G[42677] = { tips = { "The Delver's Mana-Skimmer came from the delve questline of season 3. If it's no longer offered, check the delve vendors in Dornogal for it." } }
G[19414] = { tips = { "Raise Khaz Algar Cooking to 100: cook each recipe once for first-craft skill, and buy recipes from the cooking supplies vendor in Dornogal." } }

local renown = function(faction, rank)
    return { tips = { "Reach rank " .. rank .. " with " .. faction .. ": world quests, the zone's weekly quest and its events give renown. Progress is shared by your warband." } }
end
G[41161] = renown("the Council of Dornogal", 15)
G[41162] = renown("the Council of Dornogal", 25)
G[41165] = renown("the Assembly of the Deeps", 15)
G[41166] = renown("the Assembly of the Deeps", 25)
G[41167] = renown("the Hallowfall Arathi", 15)
G[41168] = renown("the Hallowfall Arathi", 25)
G[41149] = renown("the Severed Threads", 15)
G[41164] = renown("the Severed Threads", 25)
G[41349] = { tips = { "Honored with all four Undermine cartels. Pick a different cartel as your weekly choice so each one rises." } }

G[40087] = {
    steps = {
        { t = "Turn on War Mode." },
        { t = "Do each of the listed War Within world PvP world quests as they appear (expand the achievement to see which are left)." },
    },
}
G[40088] = { tips = { "Each listed world PvP world quest five times, with War Mode on. They rotate, so do every one you see." } }
local ravine = { tips = { "Deephaul Ravine is a random battleground. Queue for random battlegrounds or play it when it's the weekly featured one." } }
for _, id in ipairs({ 40211, 40215, 40608, 40612 }) do G[id] = ravine end

------------------------------------------------------------------------
-- Dungeons and raid wings
------------------------------------------------------------------------

local function dungeon(zone, ids)
    local g = { tips = {
        "The entrance is in " .. zone .. "; track the achievement and the arrow takes you there.",
        "Normal and Heroic can be queued in the dungeon finder; Mythic needs a group or a keystone.",
    } }
    for _, id in ipairs(ids) do G[id] = g end
end
dungeon("the Isle of Dorn", { 40361, 40363, 40366 })                     -- Cinderbrew Meadery
dungeon("the Isle of Dorn", { 40621, 40637, 40642 })                     -- The Rookery
dungeon("the Ringing Deeps", { 40643, 40644, 40648 })                    -- The Stonevault
dungeon("the Ringing Deeps", { 40427, 40428, 40429 })                    -- Darkflame Cleft
dungeon("Hallowfall", { 40590, 40592, 40596 })                           -- Priory of the Sacred Flame
dungeon("Hallowfall", { 40599, 40601, 40604 })                           -- The Dawnbreaker
dungeon("Azj-Kahet", { 40370, 40374, 40375 })                            -- Ara-Kara, City of Echoes
dungeon("the City of Threads in Azj-Kahet", { 40376, 40377, 40379 })    -- City of Threads
dungeon("Undermine", { 41339, 41340, 41341 })                            -- Operation: Floodgate
dungeon("K'aresh", { 42780, 42781, 42782 })                              -- Eco-Dome Al'dani

local function raid(name, ids)
    local g = { tips = {
        "Any difficulty counts, Raid Finder included: queue for the Raid Finder wing that holds these bosses.",
        "The raid entrance for " .. name .. " is marked when you track it.",
    } }
    for _, id in ipairs(ids) do G[id] = g end
end
raid("Nerub-ar Palace", { 40244, 40247, 40248, 40249 })
raid("the Liberation of Undermine", { 41222, 41225, 41226, 41227, 41228 })
raid("Manaforge Omega", { 41598, 41601, 41602, 41603 })

G[41587] = { tips = { "Unexplored parts of Undermine are fogged on the world map; fly low through each until its name shows on screen. Expand the achievement for what's left." } }

-- Delve stories: what each story asks, on its row in the Stories achievement
G[40525] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Lost Miners"] = { t = "Drop into the pit and free 10 captured earthen scouts, then defeat Spinshroom." },
        ["Explorer's Competition"] = { t = "Beat the five Explorer's League challenges (duels, fishing, a mirror test, a running pattern), then defeat Spinshroom." },
        ["Spreading Decay"] = { t = "Help Lethnal: pick up the Dispersal Crystal, use it on 5 decaying mushrooms, then defeat Spinshroom." },
        ["Oversparked Operation"] = { t = "Defend the gnome drill site from the Darkfuse: carry 9 batteries to power three drills, then defeat Maulspike." },
    },
}
G[40526] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Lost Keepsakes"] = { t = "Take an Enchanted Candle, talk to Kuvkel, take back 11 keepsakes from the kobolds and Kriegval's Helm, then defeat Tomb-Raider Drywhisker." },
        ["Dagran's Day Out"] = { t = "Talk to Dagran, collect 10 suspicious candles and the Gigantic Candle, beat the kobold swarm and two guardians, then Drywhisker." },
        ["Swarming Kobolds"] = { t = "Take an Enchanted Candle, kill the kobold invaders, survive the ambush in the central chamber, then defeat Drywhisker." },
        ["Corrupted Candles"] = { t = "Talk to Balga Wicksfix, defeat the Darkfuse and purify 6 candles, then defeat Torque Clankfire and Sprok." },
    },
}
G[40527] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Kidnapped Earthen"] = { t = "Talk to Foreman Pivk for the Webbed Hookshot, push the cart on, rescue 5 miners and beat the ambushes, then defeat Web General Ab'enar." },
        ["Fiery Grounds"] = { t = "Take the Holy Flamethrower Torch from Lamplighter Rathling, burn the webs, rescue 9 lamplighters, then defeat Web General Ab'enar." },
        ["Precious Ores"] = { t = "Recover 7 precious ores and feed 7 weakened miners, then defeat Web General Ab'enar. Mine carts on the track hurt anyone they hit." },
        ["Looking for Treasure"] = { t = "Ride Maklin Drillstab's mole machine: kill 3 haulers, find 8 lost treasures and dig 8 coal piles, then defeat Maklin." },
        ["Bugs and Grubs"] = { t = "Take the Grappling-Grabber from Exterminator Janx, rescue 7 webbed goblins, squish all the grubs, then slay The Biggest Bug." },
    },
}
G[40528] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Captured Engineers"] = { t = "Get the Air Totem from Foreman Bruknar, rescue 5 workers from the kobolds, then defeat Waxface." },
        ["Stomping Some Sense"] = { t = "Use the Stomping Shoes to restart the Air Purifier, stomp slain kobolds for 50 Lost Gear, then defeat Waxface." },
        ["Trust Issues"] = { t = "Get the Air Totem from Pagsly, find 4 treasure piles while defending him, then defeat Waxface." },
        ["Put a Wrench on It!"] = { t = "Take the Fix-It Wrench from Prospera Cogwail, clear the fungarians and fix 18 leaking valves, then defeat Shroomsprew." },
    },
}
G[40529] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Lost Gems"] = { t = "Recover the memory gems for Vant, kill 3 Gem Hoarders using the Magnetic Burst, then defeat Under-Lord Vik'tis. A puzzle in the middle counts for the puzzle achievements." },
        ["Kobold Kidnapping"] = { t = "Free Skurro and Luch, get tossed across the chasm, cut 10 kobolds out of cocoons, then defeat Under-Lord Vik'tis." },
        ["Smashing Skardyn"] = { t = "Rescue 5 Machine Speakers and use the Skardyn Lure, recover the repair kits, then defeat Under-Lord Vik'tis. Great for Brann experience." },
        ["Darkfuse Disruption"] = { t = "Meet Prospera Cogwail, blow up 30 Darkfuse supplies and switch off 3 power controls, then defeat Geargrave." },
    },
}
G[40530] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Dark Ritual"] = { t = "Destroy 11 Darkfire Braziers, then defeat Speaker Halven." },
        ["Signal Noise"] = { t = "Take the Signal Flare, rescue 5 captives and recover 7 stolen relics, then slay Speaker Davenruth." },
        ["Kyron's Assault"] = { t = "Talk to Great Kyron, launch across the chasm by ballista, recover the supplies, dispel 6 Shadow Barriers, then slay the cult leaders." },
        ["Aiming to get Even"] = { t = "Meet Nimsi Loosefire, reclaim 8 stockpiles and clear the enemies (an Arathi Cannon helps), then slay Speaker Wicke and the Reformed Fury." },
    },
}
G[40531] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Missing Pigs"] = { t = "Talk to Aliya Hillhelm, save 10 pigs, then defeat Bogpiper." },
        ["Mushroom Morsel"] = { t = "Defeat Bogpiper and take the mushroom from its head, help Alekk collect 5 fuel glyphs and beat 4 bad guys, then talk to his final form." },
        ["The Great Scavenger Hunt"] = { t = "For Chef Dinaire: 4 mussel crates underwater, 7 spice sacks, rescue the contestant, 4 pumpkins; bring them back, then defeat Bogpiper." },
    },
}
G[40532] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Illusory Rescue"] = { t = "Rescue 8 Arathi captives and destroy 12 illusory clones, then defeat Mirror Master Murkna." },
        ["Lurking Terror"] = { t = "Push in, slay 5 Leviathan Manipulators and destroy 7 Leviathan Bait, then defeat the Leviathan Caller." },
        ["Raen's Gambit"] = { t = "Talk to Raen Dawncavalyr, kill the kobyss and recover the stolen relics, then defeat Cragpie." },
        ["Orphan's Holiday"] = { t = "Talk to Alyza Bowblaze, collect her diving gear, clear the kobyss, then defeat Cragpie and recover her stewpot." },
    },
}
G[40533] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Old Rituals"] = { t = "Talk to Lamplighter Havrik Chayvn, kill the 3 Nerubian Ritualists and the Faceless Devotees, then defeat Nerl'athekk the Skulking." },
        ["Shadow Realm"] = { t = "Enter the void portal, recover the Light's Mantle, destroy 5 Shadow Totems, then defeat Nerl'athekk." },
        ["Renilash Beckons"] = { t = "Confront Speaker Xanventh, beat 3 ambushes, chase him, repel the Order of Night, then defeat him." },
        ["Relics of the Old Gods"] = { t = "Talk to Lamplighter Kaerter, clear the threats and seal 12 Dark-Tainted Relics, then defeat Nerl'athekk." },
    },
}
G[40534] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Torture Victims"] = { t = "Clear the 3 groups at the entrance, rescue 13 prisoners, then defeat Researcher Ven'kex." },
        ["Evolved Research"] = { t = "Confront the researcher, kill the Failed Ascended and 3 waves, chase him through the barrier field, then slay Researcher Xik'vik." },
        ["Third Party Operation"] = { t = "Talk to Madam Goya, fill the Black Blood Collector, then defeat Torque Clankfire and Sprok." },
        ["Weaver Rescue"] = { t = "Follow the objectives shown inside the delve, then defeat its boss." },
        ["Runaway Evolution"] = { t = "Read the Weaver's note, use the Strange Pheromone, collect 8 Volatile Pheromones, then weaken and kill the 3 Crazed Abominations." },
    },
}
G[40535] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Goblin Mischief"] = { t = "Collect 6 repair kits to fix the Kobyss Killer mech, smash the kobyss horde in it, then defeat the Undersea Abomination." },
        ["Pheromone Fury"] = { t = "Destroy every pheromone crate, then defeat the Undersea Abomination." },
        ["Niffen Napping"] = { t = "Talk to Vetiverian, rescue 5 niffen and kill 5 suspicious ones, then slay the Undersea Abomination." },
        ["Pump the Brakes"] = { t = "Talk to Pamsy, grab the dive gear, rescue her 3 crew, freeze 8 goblin pumps with the Chillburst, then defeat Vindle Snapcrank." },
    },
}
G[40536] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Tortured Hostages"] = { t = "Kill 6 nerubian groups and free 7 webbed hostages, then defeat Overseer Kaskel." },
        ["Strange Disturbances"] = { t = "Slay the Peculiar Nerubian, clear the treasure room's swarm, rescue 8 puppets, then defeat the Puppetmaster." },
        ["From the Weaver with Love"] = { t = "Read the Weaver's scroll, collect 6 explosives from nerubians, sabotage 35 supplies, then defeat Overseer Kaskel." },
        ["Down to Size"] = { t = "Get a Web Bomb from the nerubian scout and fire the ballista, kill 12 reinforcements and recover 15 artifacts, then slay Geargrave." },
    },
}
G[41098] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Lost Excavators"] = { t = "Wake Assessor McGravy, kill monsters and rescue the missing goblins, then defeat Xel'anegh the Many." },
        ["Rowdy Rifts"] = { t = "Close 7 Dark Tears by killing Old God forces, then defeat Harbinger Ul'thul." },
        ["Black Blood Profits"] = { t = "Talk to Craggle Fritzbrains, place and defend 6 extractors while collecting Black Blood, then defeat Craggle when he turns." },
    },
}
G[41099] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["All That Glitters"] = { t = "Destroy 4 enchanted gold piles and slay 7 Golden Shamans, then weaken and slay the Gold Elemental." },
        ["Teleporter Tantrums"] = { t = "Disrupt the Darkfuse and recover the Remote Teleporter, then slay Dr. Clavus Geargrave." },
        ["Mr. DELVER"] = { t = "Switch on Mr. DELVER to turn off the hazards, rescue 7 mechanics, then slay Vindle Snapcrank." },
    },
}
G[42771] = {
    tips = { "Today's story shows on the delve's tier menu (from Tier 4 up for Archival Assault); come back on other days for the rest." },
    crit = {
        ["Relic Retrieval"] = { t = "Talk to Vaultwarden Falnor and recover the artifacts (named ones give buffs), then defeat Captain Nil'hitan." },
        ["Smash and Jab"] = { t = "Talk to Vaultwarden Gandrus, smash energy coils and barrels, then slay 3 Ethereal Commanders." },
        ["Shadowed Wings"] = { t = "Talk to Xeronia, rescue 5 Siphoned Drakes, ride her and slay 100 reinforcements, then defeat Voidrider Challnax." },
        ["Waygate Wiles"] = { t = "Talk to Spymaster Casnegosa, recover 6 waygate parts and build the waygates, destroy 6 Field Dampeners, then defeat Portalmaster Halsan." },
    },
}

------------------------------------------------------------------------
-- Feature notes, shown on every War Within achievement of that group
------------------------------------------------------------------------

ns.GROUP_NOTES_EXP = ns.GROUP_NOTES_EXP or {}
ns.GROUP_NOTES_EXP.tww = {
    ["Delves"] = {
        "Tier achievements accept that tier or higher.",
        "A delve's story changes daily; the tier menu shows today's. Stories and chest achievements take several visits.",
        "Brann levels up from every delve you finish; the companion achievements follow his level.",
    },
    ["Skyriding"] = {
        "Every course has a normal, advanced and reverse version, each with bronze, silver and gold times.",
        "Tracking a race takes the arrow to its start; a zone's race metas list every course of that zone.",
    },
    ["Dungeons"] = {
        "Heroic and Mythic achievements need that difficulty or higher; Mythic Keystone counts as Mythic.",
        "Dungeon finder groups work for Normal and Heroic.",
    },
    ["Raids"] = {
        "Boss achievements count on Normal or higher unless the name says Heroic or Mythic.",
        "Most Glory achievements need 10 or more players; the steps say when.",
    },
    ["Reputation"] = {
        "Renown rises from world quests, weekly quests and zone events of that faction. Warband-wide reputation helps alts.",
    },
    ["Horrific Visions"] = {
        "Queue at the Portal to Horrific Visions in Dornogal, just south of the Coreway tunnel, after its short intro questline. Runs are unlimited.",
        "One city is open each week, Stormwind or Orgrimmar, for everyone. Groups of 1 to 5; Soridormi can join you as tank, healer or damage.",
        "Displaced Corrupted Mementos from each run buy permanent upgrades (the Hourglass) that make later runs and the mask achievements easier.",
        "Masks are chosen in the starting room before you talk to Wrathion; each one makes enemies 25% stronger.",
    },
    ["Pet Battles"] = {
        "Tamers can be fought again whenever they're up, even after their world quest is done.",
    },
    ["PvP"] = {
        "World PvP achievements need War Mode on (switch it in a rested area of Dornogal).",
    },
    ["Professions"] = {
        "Skill comes from first-time crafts, gathering and the weekly profession quests in Dornogal.",
    },
    ["Fishing"] = {
        "Turn on Find Fish on the minimap to see pools. Each pool type gives different fish.",
    },
}

------------------------------------------------------------------------

for id, g in pairs(G) do
    if g.steps then ns.ACH_STEPS[id] = g.steps end
    if g.tips or g.steps then ns.ACH_NOTES[id] = g.tips end   -- steps replace the old plain note
    if g.crit then
        ns.CRIT_NOTES[id] = ns.CRIT_NOTES[id] or {}
        for k, v in pairs(g.crit) do ns.CRIT_NOTES[id][k] = v end
    end
end
