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

for id, g in pairs(G) do
    if g.steps then ns.ACH_STEPS[id] = g.steps end
    if g.tips or g.steps then ns.ACH_NOTES[id] = g.tips end   -- steps replace the old plain note
    if g.crit then
        ns.CRIT_NOTES[id] = ns.CRIT_NOTES[id] or {}
        for k, v in pairs(g.crit) do ns.CRIT_NOTES[id][k] = v end
    end
end
