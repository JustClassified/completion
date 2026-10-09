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

-- Li Li's questline
G[61442] = {
    steps = {
        { t = "Talk to Li Li Stormstout (book icon) in Silvermoon to start." },
        { t = "Follow her objectives. Some take a minute to appear; if a step shows nothing, wait or relog." },
    },
}

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

for id, g in pairs(G) do
    if g.steps then ns.ACH_STEPS[id] = g.steps end
    if g.tips or g.steps then ns.ACH_NOTES[id] = g.tips end   -- a guide replaces the old plain note
end
