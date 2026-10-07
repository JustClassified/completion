-- Completion: hand-written walkthrough notes, in our own words, from in-game testing and player reports.
--
-- ns.ACH_NOTES[achievementID]  = "how to approach the whole achievement" (tooltip, Walkthrough section)
-- ns.CRIT_NOTES[achievementID] = { ["type:asset" or criterion name] = { t = "what to do", at = { {uiMapID, x, y}, ... } } }
--   Hand notes win over the generated Data/Walkthroughs.lua; `at` may be left out to keep the generated spots.
-- ns.GROUP_NOTES[group]         = a line shown on every achievement of that feature group (Data/Achievements.lua)

local _, ns = ...

local EVERSONG, SILVERMOON, ZULAMAN, HARANDAR, VOIDSTORM, COILED = 2395, 2393, 2437, 2413, 2405, 2512

ns.ACH_NOTES = {
    [62556] = "Tier 5 site with Tendrils and Manifestations: step out of every green circle (pull mobs out of the water, where circles are hard to see) and keep an interrupt or stun "
        .. "for each Manifestation. Easier solo, and easier at Broken Throne (no water). Pets getting hit do not count.",
    [62558] = "On Tier 5 or higher, kill 3 challenge patrols: the Deeplurk Brinethrashers, marked with a red triangle on the minimap. It pops when the final boss dies.",
    [62534] = "Broken Throne, Tier 5, all 8 challenges, solo. Kill the empowered (blue fire) groups and every obelisk so the dragonhawk and the last boss get no boons; soak the dragonhawk's red pools.",
    [62535] = "Daggerspine Point, Tier 5, all 8 challenges, solo. Kill the empowered groups and obelisks so the bosses get no boons.",
    [62622] = "Ritual Sites renown 8. Every run gives reputation; higher tiers and more challenges give more.",
    [63349] = "Wait for the world quest Until It Is Done in western Val, then kill 100 enemies while driving the Ultradon Slayer. In a raid group the quest does not complete, so you can keep going.",
    [62880] = "8 different world quests in Val. Do them outside raid groups; Heroic ones also count toward the Heroic achievement.",
    [62882] = "8 different world quests in Naigtal. Do them outside raid groups; Heroic ones also count toward the Heroic achievement.",
    [62247] = "The Herbalism weekly quest unlocks at 25 Midnight Herbalism skill, from the week after you learn it. Four weeks, or use alts.",
    [62248] = "The Mining weekly quest unlocks at 25 Midnight Mining skill, from the week after you learn it. Four weeks, or use alts.",
    [62249] = "The Skinning weekly quest unlocks at 25 Midnight Skinning skill, from the week after you learn it. Four weeks, or use alts.",
    [62196] = "Every Midnight dungeon on Mythic or a keystone as tank, healer and damage dealer. Only dungeons in the current season's rotation can be done, so some parts wait for the next season.",
    [62383] = "Every Prey target on any difficulty. Targets rotate; a few only show up in random hunts, so mix those in.",
    [61911] = "Vaelgor & Ezzorak (The Voidspire): everyone breaks their Nullzone tether within 3 seconds of the first player. Count down 3-2-1 on voice. You only need one good round, so killing Vaelgor fast helps.",
    [62352] = "Walk out of bounds in The Voidspire or March on Quel'Danas and let the Devouring Host take you. Any difficulty, LFR included.",
    [63670] = "The Venomous Abyss: with the Ancient Amani mask (left alcove in the crypts before the tortollans), find and comfort every trapped spirit. A full clear is fine.",
    [61887] = "Every Decor Duel achievement (the housing hide-and-seek event). Kits and enhancements are bought from Gamesmaster Fleurian in Silvermoon.",
    [62325] = "Every 10,000 progress in an Abundance event rolls one of five bonuses; keep going until the Treasure Dundun bonus has fired once at each of the four locations.",
    [62326] = "Keep filling the 10,000 progress bar until the Golden Glow bonus has fired at each of the four Abundance locations.",
    [62329] = "Keep filling the 10,000 progress bar until the Runaways bonus has fired at each of the four Abundance locations.",
    [62330] = "Keep filling the 10,000 progress bar until the Gigantic Harvest bonus has fired at each of the four Abundance locations.",
    [62331] = "Keep filling the 10,000 progress bar until the Rain of Abundance bonus has fired at each location. The Voidburrow one has been reported as not counting at times.",
    [62324] = "Score in every category in one event: materials contributed, basic nodes, artisan nodes (needs a Midnight profession at skill 25), large orbs and bonus events.",
    [62333] = "10,000 in Materials Harvested in one event: pick up the orbs dropped by mobs and gathering. Easiest in Zul'Aman when the big corpse spawns and many people skin it.",
    [62340] = "10,000 in Large Orbs in one event: stand under the falling orbs (green circles). A busy raid group at an enhanced event makes it quick.",
    [62339] = "10,000 in Bonus Events in one event: stay for as many bonus triggers as you can, ideally in a big group.",
    [62570] = "Only the giant bosses of three Void Strikes count: Springclaw and Croaker (Eversong) and Grizzly! (Zul'Aman). Farm them in the weeks their strikes are up.",
    [62571] = "Rescue 50 captives in Void Strikes. Quickest: the Stillwhisper Pond stage of the Eversong incursion (toads and hawkstriders each count), or the Spiritpaw prisons in Zul'Aman.",
    [62572] = "During the Battery Rush strikes in Zul'Aman: pick up Ethereal Batteries and right-click a Siphoning Pylon to throw them. You cannot mount while carrying one.",
    [62573] = "During the Hive Extermination strikes (one in Eversong, two in Zul'Aman): fly through the swarming enemies. Falling jellies can be hit more than once.",
    [62518] = "Kill Apex-corrupted creatures during the Void Cleansing rifts: Tranquil Repose, Sunstrider Isle and South Eversong in Eversong, Bitter Bark in Zul'Aman.",
    [62903] = "When Val is the active showdown, watch its map for the Storm Mitigation bonus objective and kill the storm creatures in it. Five times. Heroic counts for both versions.",
    [62904] = "When Naigtal is the active showdown, watch its map for the Storm Mitigation bonus objective and clear it. Five times. Heroic counts for both versions.",
    [62138] = "Prey ambushes come roughly every 3-4 minutes while you are in combat on a hunt. Grinding mobs between hunt steps is the most reliable way to trigger them.",
    [62135] = "Finish a Nightmare hunt with War Mode on the whole time; switching it on at the end does not count, and random hunts do not count.",
    [62136] = "Kill 50 players while on a Nightmare hunt in War Mode. Slayer's Rise in Voidstorm is the place; any damage on a player who dies counts.",
    [62140] = "Cook 100 things during a Nightmare hunt. Any recipe works, even Spice Bread. Do it once the prey is revealed so fewer interruptions come.",
    [62141] = "Catch 100 fish during a Nightmare hunt. Do it once the prey is revealed. Fishing from the edge of a sanctuary lets you step in to clear the debuff.",
    [62142] = "After an ambush, a projectile marks red smoke on the ground: walk into it to reveal the prey and riposte. Training dummies are a quiet place to wait for ambushes.",
    [62143] = "With a hunt active in the zone, click traps (they show on the minimap) in the hunt's area.",
    [63642] = "Survive Toxic Snare barrages on Hard or Nightmare on the Coiled Isle. It comes while you are in combat, about once a minute; it happens passively over time.",
    [63643] = "Kill Pack Scouts on Hard or Nightmare on the Coiled Isle. Scouts from other players' hunts count too; the Ral'kala farm groups are the quickest.",
    [61723] = "Rank 4 curios only come from Bountiful delves at Tier 7 or higher.",
    [62601] = "Kill all five threats in the Underbelly strike of the Vaults of Atal'Utek. Three spawn as the strike objectives; Szarith the Fanged and Vserix the Sneaky are rarer. "
        .. "Players report progress resetting when a strike ends without all five dead, so try to get every kill in the same strike. Not available every day.",
    [62218] = "During a dive, do not use Surface! and let your breath run out.",
    [62219] = "At the start of a dive, turn around and swim out past the trench edge until you get the warning, then stay there.",
    [62220] = "During a dive, wait until your breath is below 10, then use Surface! (ability 3).",
    [62342] = "Catch a Mythic creature three times. The Mythic one is the Champion of Pahk (starts with 99 scales, 5-10 minute respawn); spamming the spear can land several catches per kill.",
    [62343] = "Catch a Mythic creature six times: the Champion of Pahk. A kill can count several times; use both air vents to last long enough solo.",
    [62776] = "Catch one fish of every rarity. The Champion of Pahk is Mythic; small seahorses and the Gemscale Nymph count as Legendary; the Sightless Skipper is Epic.",
    [62778] = "Needs the Murkskimmer Meat upgrade (from the chum achievements). Then fish Abyss Bubbles until an Epic fish comes up.",
    [62832] = "Finish a dive where every point came from Mythic catches. Hit the Champion of Pahk once when its armor is gone to catch it a single time, then Surface! straight away; more than one Mythic catch breaks it. Easier with a friend.",
    [62777] = "Buy every upgrade from Depthdiver Jeju. Some upgrades only appear after their achievement and a weekly reset; one is a limited-stock item.",
    [62829] = "Let one of the aggressive fish (Axetooth Thresher, Abyss Fangray or Depthbash Thresher, near 65, 25) grab you.",
    [62774] = "Swim through one of the two air vents during a dive.",
    [62222] = "Stay next to a Brakpuffer (small puffer fish, mid-depth) when the bomb over its head goes off.",
    [62207] = "Catch 3 fish in dives, then buy the Reinforced Joints upgrade from Depthdiver Jeju (may only appear after the next weekly reset).",
    [62759] = "Needs the Pressurized Eyeglass upgrade first. Loot 3 Ancient Relics in one dive; they move around and respawn after a few minutes.",
    [62763] = "250 Sunken or Ancient Treasures over time. The cluster in the ravine respawns fast, with an air vent close by.",
    [61855] = "Unexplored areas are the fogged parts of the zone on the world map; fly through each one (low enough for the area name to appear on screen). Expand this row to see which areas are still missing.",
    [61856] = "Unexplored areas are the fogged parts of the zone on the world map; fly through each one (low enough for the area name to appear on screen). Expand this row to see which areas are still missing.",
    [61520] = "Unexplored areas are the fogged parts of the zone on the world map; fly through each one (low enough for the area name to appear on screen). Expand this row to see which areas are still missing.",
    [61857] = "Unexplored areas are the fogged parts of the zone on the world map; fly through each one (low enough for the area name to appear on screen). Expand this row to see which areas are still missing.",
    [63640] = "Unexplored areas are the fogged parts of the zone on the world map; fly through each one (low enough for the area name to appear on screen). Expand this row to see which areas are still missing.",
    [61854] = "Explore Eversong Woods, Zul'Aman, Harandar and Voidstorm. Each zone's Explore achievement lists what is left.",
    [61859] = "Learn every Midnight flight path: talk to each flight master once. Expand the row: the arrow points at the nearest one still missing.",
    [62057] = "Meta of the four zone telescope achievements. If a zone sits at 5/5 without completing, go back around: a telescope can show as not placed again, and clicking it once more fixes it.",
    [62104] = "Lore objects across all four zones. The Ancient Tablet that counts is in Voidstorm (not the one in Nazmir some sites link).",
    [61387] = "Kill any one listed Prey target on Normal difficulty and hand in the hunt quest. Hard or Nightmare kills do not count for this one.",
    [61386] = "Kill Prey targets on Normal difficulty and hand in the hunt quests. Hard or Nightmare kills do not count.",
    [42701] = "Kill Prey targets on Normal difficulty and hand in the hunt quests. Hard or Nightmare kills do not count.",
    [62139] = "Finish one Prey hunt in every Midnight zone. Pick a contract for a zone you have not done yet at the hunt table.",
    [61943] = "Follow the Abundance questline in Zul'Aman; the achievement completes with it.",
    [61681] = "Harvest 1,000,000 Abundance over time. Usually done after one or two Abundant Harvest events.",
    [62336] = "Earn 10,000 Materials Contributed in one Abundance event: pick up the orbs dropped by mobs and deliver them to the altar yourself.",
    [62887] = "15 world quests in Val or Naigtal on Heroic World Tier. Some world quests there reportedly do not count; if one does not add progress, do another.",
    [61832] = "Any Tier 1 delve counts; players report older-expansion delves at high tiers can award these too.",
    [61441] = "Raise every Midnight primary profession to max skill. Progress is per profession, on any character.",
    [62521] = "Only one Ritual Site is active at a time; the Broken Throne site is in the south of Zul'Aman.",
    [62522] = "Only one Ritual Site is active at a time; check the map for Daggerspine Point.",
    [62873] = "Meta of six Void Assault storyline achievements (Naigtal and Val): time-gated, at least six weeks. It unlocks two cheap mounts from Kifaan. "
        .. "The storylines start from an NPC in Silvermoon City around 47.6, 51.0; expand the parts to follow their quests.",
    [62134] = "Five Prey Hunts with War Mode on. Having it on from the start is safest; players report it also counts if you switch it on before the last step, but not at the very end.",
    [61707] = "Clear every Midnight delve listed. Each delve's entrance is under Delves on its zone page.",
    [61901] = "Every Sturdy Chest in every Midnight delve. Some chests only exist in certain delve stories, so run each delve with different stories until they all show up.",
    [63631] = "Rank 5 (Bloodsworn Crew) with Captain Tokka on the Coiled Isle, through the Venom Fishing quests and daily fishing.",
    [62192] = "Max renown with each faction listed. The Reputation section of each zone shows how far you are.",
    [63510] = "Reach 2500 Anglin' Score in the Fishing Journal (warband-wide). 28 fish score up to 100 each at Trophy rank, so about three can be skipped. "
        .. "Fish in every Midnight zone, including the small one-fish areas in the Vaults; the journal shows each fish's score.",
    [63629] = "Catch every fish of the Coiled Isle. Turn on Find Fish tracking on the minimap to see pools. Spotted Killifish comes from open water by Tokka's small island; "
        .. "Ula'tek Snakehead from open water using the Renown 5 lure from Tokka's crew. Coiled Stargorger needs the rep-locked lure.",
    [63632] = "Get Trophy rank with each listed fish. Rank goes up when you land a higher quality catch, which is hidden, so it is simply a matter of fishing a lot "
        .. "in the Coiled Isle and the Vaults; keep the Fishing Journal open to watch the ranks.",
    [63634] = "Reach Bloodsworn Crew (rank 5) with Captain Tokka, buy The Coiled Huntress fishing pole from Second Mate Sluggs (6000 Voidlight Marl), equip it and talk to Captain Tokka. "
        .. "Do it on the character that started the Venom Fishing questline.",
    [61455] = "Five Shadowpine Songseekers across Zul'Aman. Jebanda walks between two spots. Baz'wa only appears after you finish the Zul'Aman campaign.",
    [61052] = "120 Glowing Moths in Harandar, unlocked by Hara'ti renown: 40 are collectable at Renown 1, 40 more at Renown 5 and the last 40 later "
        .. "(each set only shows on the map a few renown levels later). Each gives Luminous Dust for Mothkeeper Wew'tam, who sells two mounts and decor.",
    [62188] = "Five Haranir sit on the old world trees. Or'jan: Darkshore, on a rocky islet at the Twilight Shore. Chonon: on the tallest root of Nordrassil in Mount Hyjal "
        .. "(may need a Hyjal questline done to be visible). Fuunid: high on a branch of Bel'ameth's world tree. Kawayn: on top of the tree in Grizzly Hills. "
        .. "Zhakir: Val'sharah, by a small lake before the druid class hall. Druids can reach most of them through the Dreamway.",
    [61961] = "One runestone in Eversong is active at a time and they rotate. Hand in Latent Arcana until it is charged to 100%, then kill mobs and click objects around it "
        .. "until its named boss spawns, and defeat it.",
    [62117] = "Abyss Angler dives (Zul'Aman coast): fish the Abyss Bubbles at the bottom of the sea. Click the bobber, not the bubble. "
        .. "Tracking the 50-fish achievement finishes the 10, 25 and 50 ones in one session.",
    [61442] = "Start at Li Li Stormstout (book icon) in Silvermoon. Some objectives take a minute to appear; if a step shows nothing, wait or relog.",
    [61091] = "Capture every wild battle pet species of Eversong, Zul'Aman, Harandar and Voidstorm (Quel'Danas pets count too). Rare pets are marked in the steps. "
        .. "Turn on Track Pets on the minimap: it gets switched off by some patches.",
    [62492] = "Capture every wild pet of the Coiled Isle. The rare Caustic Writhling lives inside the Vaults of Atal'Utek and takes 3-4 hours to respawn.",
    [62370] = "Harvest 250 Thalassian Lumber (account-wide). Harandar has by far the most lumber; druids stay in travel form while chopping.",
    [60888] = "Place the Small Red Button (Silvermoon graveyard is ideal) and press it 10 times in a row without dying. It is pure luck. "
        .. "Take off your gear first and resurrect at the spirit healer each time to skip the timer.",
    [61586] = "Collect a full Midnight PvP Season 1 armor set (Honor or Conquest; the Warmonger set does not count). Equip the pieces to learn them.",
    [63608] = "Collect a full Midnight PvP Season 2 armor set (Honor or Conquest).",
    [42283] = "Meta of all Abundance achievements. Not warband-wide at the moment, so finish it on one character. "
        .. "Chel the Chip sells a toy that teleports you to Abundance for 3200 Unalloyed Abundance.",
    [62199] = "Three stops: talk to Chu'ke the possessed doll, then Kalika (tailoring trainer) at Witherbark Bluffs and press the Forgotten Button behind the jade statue near her, "
        .. "then meet Chu'ke again at the Possessed Dolls on the Funerary Coast. Talking to Chu'ke later transforms you again (almost anything cancels it).",
    [62200] = "Six notes from Bin Greenwrench, a stranded gnome, spread over Zul'Aman. Two are hidden: the Discarded Scroll is under a building and the Moldy Diary is under the hammock Da Piper sleeps in.",
    [62201] = "Target each princess frog and /kiss it. Princess Jakobu is in Atal'Aman. A macro that targets all five and then kisses saves hunting for them in the grass.",
    [63381] = "150 Curse Surges on the Coiled Isle. They rotate between five spots every 45 minutes (the map's Events tab shows the next one); join whatever group is there. A long grind by design.",
    [62267] = "Kill Kapara and Kapara pups in Zul'Aman over and over (they respawn); after the third angry warning Filo, Loa of Childhood, appears. "
        .. "Any Kapara in the zone counts; Feevra's pool is a good spot. Finish or abandon an active Prey hunt first or Filo will not show. Watch out: a Kapara can grow huge and hit hard.",
    [63653] = "250 Temple Patrols in the Vaults of Atal'Utek. Several are active at once and rotate every ~10 minutes; they also count in raid groups.",
    [63636] = "Earn all 20 Spirit Corrosion points for the Altar of Corrosion (account-wide). The last one needs Renown 14 with Zul'jarra's Forces. "
        .. "Points come from the sources in the steps below; tick each one off with a right-click on the arrow once you have it.",
    [63598] = "Temple Patrols rotate every ~10 minutes with several active at once, and the whole set swaps roughly every two weeks, so some only show up later. "
        .. "Hover the patrol icons on the Vaults map to see which are up. Raid groups work.",
    [63599] = "Temple Incursions in the Vaults of Atal'Utek rotate; do each one when it is up.",
    [63600] = "Temple Strikes rotate in sets of three roughly every half week; all six can be done within a week.",
    [63601] = "One Ancient Foe is active at a time, rotating weekly. Being in the raid group when it dies is enough.",
    [62190] = "Max every Silvermoon Court sub-faction (Blood Knights, Farstriders, Magisters, Shades of the Row) through the weekly party at Saltheril's Haven (see The Party Must Go On). "
        .. "Once a faction reaches its top rank it is locked there, so afterwards you can safely take options that lower it to push the others.",
    [62186] = "Four weeks minimum: you can invite one faction per week. Pick up the quest from Jonas Everdawn in Silvermoon, then talk to Lord Saltheril at Saltheril's Haven, "
        .. "talk to the vendors there and choose one faction for the week. Spend all three invitations on that same faction; splitting them wastes the week.",
    [62604] = "During the Cache of the Three incursion in the Vaults of Atal'Utek. Stand inside each stone's circle and /dance for a few seconds without being interrupted "
        .. "or targeting anything. Mobs jump anyone standing there alone, so it is far easier while a group is clearing that stone.",
    [62649] = "During the Earth and Sky event in the Vaults of Atal'Utek. Stand in the green circle at the Shrine of Sky, dismount and press the extra action button to become a bird, "
        .. "then fly around the raid entrance for a large, bright blue wandering Soul Globe. One is enough.",
    [63382] = "Cursed Surges rotate between five spots on the Coiled Isle every 45 minutes; you need the one at The Forum (Looming Mutagenitor). Check the map's Events tab for when it is up. "
        .. "Stand in the big green clouds until you get the Infestation debuff, then die with it (a fall from high up works). It also counts if you die later while it is still on you.",
    [62133] = "Fly very high anywhere in Voidstorm until the Hungering Presence comes for you. Then pitch slightly down and hold turn plus strafe to circle at full speed for 60 seconds. No abilities needed.",
    [61860] = "Fly straight up above the Den in the middle of Harandar and keep climbing until you are teleported.",
    [61861] = "A Roaming Shredclaw rests on a rock in Voidstorm. Tag it yourself (hit it; body pulls or a group member's tag do not count). An Opportunistic Harrower swoops in and grabs it: "
        .. "follow it to its nest where Screammaxa the Matriarch spawns.",
    [63596] = "Run over 1000 Insidious Snakes in the Vaults of Atal'Utek. They keep spawning next to the Altar of Fangs entrance: auto-run into the corner and they are stomped as they come. "
        .. "Standing still does not count. Two more spawn points nearby speed it up with friends.",
    [62120] = "Unlock all eight minor Loa at Du'gal's Altar of Blessings in Amani'Zar Village. Kulzi: finish the storyline that starts in Amani'Zar Village. "
        .. "Filo and Shadra: storylines starting at Witherbark Bluffs (Shadra's needs a Maisara Caverns run; follower mode works). Mot'amra: an item from the end chest of a Zul'Aman delve. "
        .. "Wila'ma: Renown 8 with the Amani Tribe. Dundun: an item from Chel the Chip (Abundance vendor) for 1600 Unalloyed Abundance. "
        .. "Oe: an item from the world boss Cragpine. Puul: a very rare fishing catch in any Midnight water (pools not needed).",
    [62121] = "Needs all eight minor Loa (Altar of Blessings: The Penitent Troll). Each blessing is one major Loa (top four circles) plus one minor Loa. "
        .. "Several trigger right at the altar; most of the rest trigger by fighting (a training-dummy toy next to the altar is the quickest). "
        .. "Two Dundun combos trigger on any gathering node. The travel ones need a Packpeddle mammoth (repair icon on the minimap; one near 40.3, 51.1): "
        .. "pick the combo, talk to it, fly back, swap the major Loa and repeat.",
    [62269] = "Unlock any Loa at the Altar of Blessings. Wila'ma unlocks by itself at Renown 8 with the Amani Tribe.",
    [62270] = "Take blessings from Du'gal the Altar Keeper in Amani'Zar Village.",
    [62202] = "Talk to Feevra, then to the Kapara Pup next to her to start the run (30 minute buff, you cannot mount). Reach the finish circle and land in it. "
        .. "If \"Spiritpaw Runner found\" did not tick, go back and talk to Feevra again.",
    [61912] = "Only counts inside the Stormarion Assault event in Voidstorm (not the Sunkiller Sanctum delve). Build each of the four defenses at least once. "
        .. "The Shadowtrade Mercenary unlocks at Renown 11 with The Singularity.",
    [61913] = "Finish all three waves of one Stormarion Assault. Some players report Wave 1 not counting the first time; running the event again from the start fixes it.",
    [61922] = "Finish a Stormarion Assault with the Singularity Anchor still at 90% health or more. Easiest with a full group guarding the anchor.",
    [63432] = "12.1, Coiled Isle. 1) Reach Renown 3 with Zul'jarra's Forces (Spoils of Coils perk) so the special treasures spawn. "
        .. "2) Do the intro quests at the Amani Foothold in the Vaults of Atal'Utek. 3) Looting one of those treasures gives an item that starts a quest: "
        .. "talk to Ofi the Sly in the swamp, then again at Tokka's Landing. 4) Open the bag Ofi gives you for 3 ingredients and offer them at Ofi's Cauldron: "
        .. "each offering type counts once. Since late August 2026 the daily is repeatable, so this can be finished in one day.",
    [61082] = "The visitors rotate weekly in the Arcantina: each pair comes back roughly every eight weeks. Check the side rooms, not only the map icons. "
        .. "Place the pair's optional decoration (see Highly Decorated) before you hand in their quest.",
    [61083] = "Each item is found in an old dungeon, raid or zone, then placed in the Arcantina. Several are tied to the weekly visitor quests (Old Soldiers), "
        .. "so they only become available in the right week.",
    [61344] = "The books only appear while you are on the matching Legends of the Haranir relic quest (one relic story per week). "
        .. "If you miss one you cannot go back for it on that character; an alt who has not done that relic can pick it up. Grab all three in each story before finishing it.",
    [63619] = "12.1 Arcantina visitors: finish the quest of each visiting pair when they are in (they rotate weekly).",
    [63620] = "Stormstout Brewery Lantern: in Stormstout Brewery just past the first boss, hanging in a doorway. Hang it over the doorway between the main room and the rear right room of the Arcantina (about 63.3, 44.8).",
    [62600] = "During the Temple Incursion: Summoning Ritual in the Vaults of Atal'Utek. Bring one of each offering to the main statue: "
        .. "Petrified Egg (west side), Spirit Urn (east side) and Venomous Ooze (kill a Venomous Giant in the middle area, it drops it). "
        .. "Carrying one gives a 10 minute buff and you can mount.",
    [61081] = "Buy Toasting Brews (10 silver each, you need one per race) from Bartender Bob in the Arcantina and use one on a player "
        .. "of each race. You can target yourself: an alt or a trial character of a missing race can toast itself, then log back. "
        .. "Mechagnome, Vulpera and Kul Tiran are the rare ones; camping the entrance right after the weekly reset helps. "
        .. "Mouse over a player and Completion tells you if you still need their race.",
    [62187] = "Only while the Special Assignment \"The Grand Magister's Drink\" is up in Eversong Woods (Fairbreeze area). "
        .. "Talk to each drink vendor below and ask for a tasting: the drink counts the moment you ask, not when you hand in the bottle. "
        .. "Solo you get three tastings per run of the assignment. Players report that in a raid group every tasting counts at once "
        .. "(still working in 12.1 for most). Warband-wide, so alts can finish the rest the same week.",
}

ns.CRIT_NOTES = {
    [61455] = {
        ["Songseeker Ikaja"] = { t = "North of the map", at = { { ZULAMAN, 55.21, 18.11 } } },
        ["Songseeker Jebanda"] = { t = "Walks between these two spots", at = { { ZULAMAN, 31.60, 38.10 }, { ZULAMAN, 31.61, 46.52 } } },
        ["Songseeker Dova"] = { t = "Middle of the map", at = { { ZULAMAN, 39.20, 56.42 } } },
        ["Songseeker Far'lan"] = { t = "South of the map", at = { { ZULAMAN, 47.31, 81.92 } } },
        ["Songseeker Baz'wa"] = { t = "South; only after the Zul'Aman campaign", at = { { ZULAMAN, 52.71, 79.30 } } },
    },
    [61091] = {
        ["Akil Fledgling"] = { t = "Wild pet", at = { { ZULAMAN, 47.72, 87.29 } } },
        ["Ebon Snapling"] = { t = "Wild pet", at = { { ZULAMAN, 55.37, 85.02 } } },
        ["Gloom Toad"] = { t = "Wild pet", at = { { ZULAMAN, 37.56, 64.64 } } },
        ["Striped Snakebiter"] = { t = "Wild pet", at = { { ZULAMAN, 51.59, 67.01 } } },
        ["Dragonhawk Mosswing"] = { t = "Wild pet", at = { { ZULAMAN, 48.6, 23.6 } } },
        ["Pangolil"] = { t = "Rare wild pet", at = { { ZULAMAN, 47.60, 54.45 } } },
        ["Swamp Biter"] = { t = "Wild pet", at = { { ZULAMAN, 20.18, 77.32 }, { ZULAMAN, 44.68, 40.48 } } },
        ["Azure Sporebat"] = { t = "Wild pet", at = { { HARANDAR, 69.98, 64.46 }, { HARANDAR, 59.76, 31.95 } } },
        ["Rootling Nester"] = { t = "Wild pet", at = { { HARANDAR, 35.44, 63.83 } } },
        ["Mud Potadpole"] = { t = "Rare wild pet", at = { { HARANDAR, 69.07, 31.63 } } },
        ["Silkcrawler"] = { t = "Wild pet", at = { { HARANDAR, 57.66, 44.30 } } },
        ["Waddles"] = { t = "Wild pet", at = { { HARANDAR, 60.54, 21.06 } } },
        ["Devouring Runt"] = { t = "Wild pet", at = { { VOIDSTORM, 51.12, 77.29 }, { VOIDSTORM, 40.33, 37.47 } } },
        ["Voidcrawler"] = { t = "Wild pet", at = { { VOIDSTORM, 63.46, 59.51 } } },
        ["Blistercreepling"] = { t = "Wild pet", at = { { VOIDSTORM, 48.82, 73.44 } } },
        ["Riftblade Familiar"] = { t = "Rare wild pet (no War Mode needed)", at = { { VOIDSTORM, 62.26, 73.89 } } },
        ["Vibrant Manaling"] = { t = "Wild pet", at = { { EVERSONG, 46.29, 54.77 }, { EVERSONG, 60.11, 37.67 } } },
        ["Amber Treeflitter"] = { t = "Wild pet", at = { { EVERSONG, 50.39, 80.30 } } },
        ["Violet Chick"] = { t = "Wild pet", at = { { EVERSONG, 51.79, 37.33 } } },
        ["Nether Familiar"] = { t = "Wild pet (Isle of Quel'Danas)", at = { { 2424, 34.39, 15.54 } } },
        ["Wrathful Wyrm"] = { t = "Rare wild pet (Isle of Quel'Danas)", at = { { 2424, 46.10, 25.12 } } },
    },
    [62492] = {
        ["Cursed Spawn"] = { t = "Wild pet", at = { { COILED, 44.10, 46.55 }, { COILED, 48.90, 67.08 }, { COILED, 45.28, 34.50 } } },
        ["Steady Croakfrog"] = { t = "Wild pet", at = { { COILED, 64.88, 41.33 }, { COILED, 66.10, 56.00 }, { COILED, 65.40, 42.13 } } },
        ["Sleek Snakebiter"] = { t = "Wild pet", at = { { COILED, 65.76, 45.55 }, { COILED, 56.06, 51.44 }, { COILED, 60.62, 77.81 } } },
        ["Poisoned Parasite"] = { t = "Wild pet", at = { { COILED, 68.27, 75.79 }, { COILED, 65.32, 49.45 } } },
        ["Jaundiced Slitherer"] = { t = "Wild pet", at = { { COILED, 49.85, 55.68 }, { COILED, 53.53, 34.47 } } },
        ["Autumn Snapling"] = { t = "Wild pet", at = { { COILED, 65.10, 70.79 }, { COILED, 70.60, 78.80 } } },
        ["Nightfur Kapara"] = { t = "Rare wild pet", at = { { COILED, 61.40, 82.88 } } },
        ["Caustic Writhling"] = { t = "Rare wild pet inside the Vaults of Atal'Utek (3-4 hour respawn)", at = { { 2509, 42.7, 32.0 }, { 2509, 40.6, 36.0 }, { 2509, 37.3, 31.2 }, { 2509, 39.7, 27.7 }, { 2509, 42.6, 33.3 } } },
    },
    [61961] = {
        ["Elrendar River Runestone"] = { t = "Charge it with Latent Arcana, then beat the boss", at = { { EVERSONG, 47.36, 58.64 } } },
        ["Ath'ran Runestone"] = { t = "Charge it with Latent Arcana, then beat the boss", at = { { EVERSONG, 38.33, 55.53 } } },
        ["Dawnstar Spire Runestone"] = { t = "Charge it with Latent Arcana, then beat the boss", at = { { EVERSONG, 61.76, 61.72 } } },
        ["Sanctum of the Moon Runestone"] = { t = "Charge it with Latent Arcana, then beat the boss", at = { { EVERSONG, 41.15, 73.81 } } },
        ["Sunstrider Isle Runestone"] = { t = "Charge it with Latent Arcana, then beat the boss", at = { { EVERSONG, 40.46, 13.59 } } },
    },
    [62200] = {
        ["Message in a Bottle"] = { t = "Floating in the water", at = { { ZULAMAN, 54.87, 32.41 } } },
        ["Scrap of Singed Paper"] = { t = "On the ground", at = { { ZULAMAN, 54.32, 20.60 } } },
        ["Discarded Scroll"] = { t = "Under the building", at = { { ZULAMAN, 45.9, 66.0 } } },
        ["Hastily-Scribbled Note"] = { t = "Easy to miss, look closely", at = { { ZULAMAN, 46.37, 41.35 } } },
        ["Moldy Diary Found"] = { t = "Under the hammock Da Piper sleeps in", at = { { ZULAMAN, 35.69, 25.20 } } },
        ["Parting Note"] = { t = "On the ground", at = { { ZULAMAN, 34.79, 17.16 } } },
    },
    [62201] = {
        ["Princess Fita"] = { t = "Target the frog and /kiss", at = { { ZULAMAN, 31.70, 22.63 } } },
        ["Princess Gabiku"] = { t = "Target the frog and /kiss", at = { { ZULAMAN, 68.28, 19.31 } } },
        ["Princess Jakobu"] = { t = "Target the frog and /kiss (Atal'Aman)", at = { { 2536, 27.53, 40.05 } } },
        ["Princess Tafiki"] = { t = "Target the frog and /kiss", at = { { ZULAMAN, 53.94, 59.56 } } },
        ["Princess Zambina"] = { t = "Target the frog and /kiss", at = { { ZULAMAN, 29.81, 79.15 } } },
    },
    [63598] = {
        ["Broken Bonds"] = { t = "Temple Patrol (one of these spots when active)", at = { { 2509, 52.3, 38.9 }, { 2509, 42.2, 32.4 }, { 2509, 49.0, 38.0 }, { 2509, 49.3, 56.9 }, { 2509, 46.3, 51.6 }, { 2509, 52.9, 50.6 }, { 2509, 46.3, 36.2 }, { 2509, 42.7, 41.7 } } },
        ["Slay Children of Ula'tek"] = { t = "Temple Patrol (one of these spots when active)", at = { { 2509, 52.0, 32.0 }, { 2509, 42.7, 41.2 }, { 2509, 39.3, 35.8 }, { 2509, 45.2, 54.4 }, { 2509, 50.6, 40.0 }, { 2509, 44.7, 47.9 }, { 2509, 42.2, 32.5 } } },
        ["Scavenged Weapons"] = { t = "Temple Patrol (one of these spots when active)", at = { { 2509, 49.7, 55.3 }, { 2509, 42.73, 31.75 }, { 2509, 52.21, 40.14 } } },
        ["Congealed Venom"] = { t = "Temple Patrol (one of these spots when active)", at = { { 2509, 39.6, 17.3 }, { 2509, 49.5, 38.3 }, { 2509, 44.8, 47.9 }, { 2509, 47.7, 36.3 } } },
        ["Vengeance for the Dead"] = { t = "Temple Patrol (one of these spots when active)", at = { { 2509, 39.3, 35.8 }, { 2509, 45.3, 54.4 }, { 2509, 52.0, 32.7 }, { 2509, 45.3, 12.4 } } },
        ["Calming the Dead"] = { t = "Temple Patrol (one of these spots when active)", at = { { 2509, 48.3, 29.2 }, { 2509, 54.6, 38.1 }, { 2509, 44.1, 30.1 } } },
        ["Slay the Restless"] = { t = "Temple Patrol (one of these spots when active)", at = { { 2509, 52.9, 50.6 }, { 2509, 56.2, 34.5 }, { 2509, 55.4, 26.7 }, { 2509, 47.7, 56.6 }, { 2509, 53.7, 39.4 } } },
        ["Siphon Venom"] = { t = "Temple Patrol (one of these spots when active)", at = { { 2509, 45.8, 35.5 }, { 2509, 50.2, 25.8 }, { 2509, 48.6, 51.0 }, { 2509, 45.3, 40.6 } } },
        ["Breath and Bile"] = { t = "Temple Patrol (one of these spots when active)", at = { { 2509, 52.0, 32.6 }, { 2509, 42.8, 41.2 }, { 2509, 44.4, 53.1 } } },
        ["Dragged Below"] = { t = "Temple Patrol (one of these spots when active)", at = { { 2509, 44.1, 54.7 }, { 2509, 45.0, 10.4 } } },
        ["Ash to Ash"] = { t = "Temple Patrol (one of these spots when active)", at = { { 2509, 49.7, 31.2 }, { 2509, 40.2, 22.5 }, { 2509, 54.3, 39.5 }, { 2509, 42.2, 32.57 }, { 2509, 53.0, 50.76 } } },
        ["Laid to Rest"] = { t = "Temple Patrol (one of these spots when active)", at = { { 2509, 52.63, 45.58 }, { 2509, 50.13, 38.94 } } },
    },
    [62604] = {
        ["Many Faces Stone"] = { t = "Shrine of Serpents: /dance inside the circle for a few seconds", at = { { 2509, 52.7, 21.4 } } },
        ["Stone of Shackles"] = { t = "Shrine of Shackles: /dance inside the circle for a few seconds", at = { { 2509, 49.1, 35.1 } } },
        ["Poison Stone"] = { t = "Shrine of Venom: /dance inside the circle for a few seconds", at = { { 2509, 47.2, 46.2 } } },
    },
    [61083] = {
        ["Scarred Spear"] = { t = "Hellfire Ramparts dungeon, between the last two bosses upstairs. Place it in the right side room above the bench, under the tiki masks (67.0, 52.6)" },
        ["Ebon Banner"] = { t = "Icecrown Citadel raid, left side of Lady Deathwhisper's room. Place it in the centre room above the barrels (39.7, 49.7)" },
        ["Corrupted Lantern"] = { t = "Broken Shore, on the floor right behind the old portal. Place it in the right side room on a little bench (75.3, 40.2)", at = { { 646, 48.85, 55.34 } } },
        ["Ancient Zandalari Scroll"] = { t = "Throne of Thunder raid, first room after Jin'rokh, end of the hall on the right. Place it in the left hallway above a bookcase (25.7, 43.8)" },
        ["Evergreen Vine"] = { t = "Firelands raid, far north-west corner at the Circle of Thorns. Place it in the left side room behind a blue cauldron (36.2, 28.9)" },
        ["Pylon Fragment"] = { t = "Dire Maul West, left of the first boss (Tendris Warpwood). Place it in the left side room in front of the bookcase (25.2, 22.5)", at = { { 69, 60.33, 30.23 } } },
        ["Weathered Tome"] = { t = "In a hut in Nagrand (Outland). Place it in the right side hallway on a bookshelf beside a small chest (62.4, 45.0)", at = { { 107, 56.34, 34.32 } } },
        ["Heavy Anchor"] = { t = "Vol'dun, leaning on a boat. Place it in the centre room, leaning on a cannon (38.7, 73.4)", at = { { 864, 35.88, 36.09 } } },
        ["Sandy Tapestry"] = { t = "Vol'dun, between tree roots. Place it in the centre room on the wall beside the exit (45.8, 82.4)", at = { { 864, 58.65, 50.27 } } },
        ["Dried Roses"] = { t = "Gilneas City, on the outside of the building. Place it at the entry to the left side hallway (41.7, 48.2)", at = { { 217, 55.29, 52.78 } } },
        ["Clefthoof Hide"] = { t = "Burning Steppes, just inside the building. Place it on the wall behind Gidwin Goldbraids (37.5, 53.2)", at = { { 36, 31.91, 34.64 } } },
    },
    [61344] = {
        ["Laments of Wey'nan--Part 1: Finding Hope"] = { t = "During Wey'nan's Ward: inside the cave", at = { { HARANDAR, 43.24, 37.37 } } },
        ["Laments of Wey'nan--Part 2: Hunting Purpose"] = { t = "During Wey'nan's Ward: inside the cave", at = { { HARANDAR, 41.54, 35.83 } } },
        ["Laments of Wey'nan--Part 3: There Must Be More"] = { t = "During Wey'nan's Ward: up the ramp on the left", at = { { HARANDAR, 42.31, 35.52 } } },
        ["Echoes of Our Past--Part 1: Fading History"] = { t = "During The Cauldron of Echoes: inside the cave", at = { { HARANDAR, 60.0, 20.9 } } },
        ["Echoes of Our Past--Part 2: Alndust"] = { t = "During The Cauldron of Echoes: second floor, on top", at = { { HARANDAR, 59.76, 18.51 } } },
        ["Echoes of Our Past--Part 3: Dangerous Memories"] = { t = "During The Cauldron of Echoes", at = { { HARANDAR, 61.18, 16.03 } } },
        ["Words of Obayo--Part 1: The Flame"] = { t = "During The Echoless Flame: inside a cave", at = { { HARANDAR, 64.88, 38.42 } } },
        ["Words of Obayo--Part 2: The Rift"] = { t = "During The Echoless Flame", at = { { HARANDAR, 62.73, 34.49 } } },
        ["Words of Obayo--Part 3: The Silence"] = { t = "During The Echoless Flame", at = { { HARANDAR, 62.67, 35.90 } } },
        ["Seeker's Trail--Part 1: Call of Aln'hara"] = { t = "During Aln'hara's Bloom", at = { { HARANDAR, 53.44, 66.88 } } },
        ["Seeker's Trail--Part 2: Seeking Peace"] = { t = "During Aln'hara's Bloom", at = { { HARANDAR, 54.94, 66.71 } } },
        ["Seeker's Trail--Part 3: Unending Mission"] = { t = "During Aln'hara's Bloom: inside a cave", at = { { HARANDAR, 57.26, 66.37 } } },
        ["Tending the Lands--Part 1: The Conflict"] = { t = "During Russula's Outreach", at = { { HARANDAR, 63.43, 40.07 } } },
        ["Tending the Lands--Part 2: The Plan"] = { t = "During Russula's Outreach", at = { { HARANDAR, 61.05, 38.98 } } },
        ["Tending the Lands--Part 3: The Cycle"] = { t = "During Russula's Outreach", at = { { HARANDAR, 61.39, 37.14 } } },
        ["Ways of the Roots--Part 1: Serving"] = { t = "During Root of the World: inside the cave", at = { { HARANDAR, 40.83, 36.29 } } },
        ["Ways of the Roots--Part 2: Growing"] = { t = "During Root of the World: inside the cave", at = { { HARANDAR, 41.48, 34.16 } } },
        ["Ways of the Roots--Part 3: Pruning"] = { t = "During Root of the World, stage 4: follow the scent trail but turn left", at = { { HARANDAR, 40.51, 34.71 } } },
        ["Awe'ohna's Path--Part 1: Questions"] = { t = "During Sky's Hope: outside in the open", at = { { HARANDAR, 71.91, 58.93 } } },
        ["Awe'ohna's Path--Part 2: Answers"] = { t = "During Sky's Hope: inside the caves (entrance around 72.8, 57.7)", at = { { HARANDAR, 73.53, 58.23 } } },
        ["Awe'ohna's Path--Part 3: The Cradle"] = { t = "During Sky's Hope: on the ramp up to the second NPC", at = { { HARANDAR, 73.46, 57.43 } } },
    },
    [62600] = {
        ["Petrified Egg"] = { t = "West side of the ritual area; carry it back to the main statue", at = { { 2509, 42.0, 47.0 } } },
        ["Spirit Urn"] = { t = "East side of the ritual area; carry it back to the main statue", at = { { 2509, 54.0, 49.0 } } },
        ["Venomous Ooze"] = { t = "Kill a Venomous Giant in the middle area; it drops the ooze. Carry it to the main statue" },
    },
    [62187] = {
        ["Heron's Vision of Cloudwalking"] = { t = "Ask Heron Skygaze (food and drink) for a tasting", at = { { EVERSONG, 39.34, 60.17 } } },
        ["Kreynna's Khadgar's Imitation"] = { t = "Ask Kyrenna (cheese vendor) on the floating platform", at = { { EVERSONG, 40.74, 59.53 } } },
        ["Landraelanis' Muskmelon Draught"] = { t = "Ask Landraelanis (tradesman), upper floor", at = { { EVERSONG, 41.46, 61.31 } } },
        ["Duskwither's Dancing Merlot"] = { t = "Ask Magister Duskwither, outside the village towards the runestone", at = { { EVERSONG, 38.28, 58.38 } } },
        ["Quarelestra's Sanguine Affair"] = { t = "Ask Quarelestra (cooking trainer), outside", at = { { EVERSONG, 39.81, 60.91 } } },
        ["Vehn's Shimmerveil Blanc"] = { t = "Ask Vehn Sorrelstride (alchemical oddities), outside", at = { { EVERSONG, 39.25, 61.10 } } },
        ["Areyn's Elrendar Red"] = { t = "Ask Innkeeper Areyn", at = { { EVERSONG, 39.32, 61.37 } } },
        ["Lady Marilin's Arcwine Reserve"] = { t = "Ask Lady Marilin, middle floor", at = { { EVERSONG, 40.25, 61.18 } } },
        ["Limien's Arcane Infusion"] = { t = "Ask Limien Bountcask (fine vintages), outside", at = { { EVERSONG, 40.70, 60.11 } } },
        ["Nara's Essence of Butterfly"] = { t = "Ask Nara Fadebranch (forage goods)", at = { { EVERSONG, 39.59, 60.56 } } },
        ["Sheri's Laughing Rose"] = { t = "Ask Sheri (general goods) on the floating platform", at = { { EVERSONG, 40.83, 60.48 } } },
        ["Zalene's Twilight Claret"] = { t = "Ask Zalene Firstlight (food and drink)", at = { { EVERSONG, 40.28, 61.47 } } },
    },
}

-- Achievements that happen in one place: where to go when the whole thing is tracked.
ns.ACH_SPOTS = {
    [62571] = { t = "Stillwhisper Pond (Eversong incursion stage)", at = { { EVERSONG, 53.61, 35.39 } } },
    [62572] = { t = "Battery Rush strikes", at = { { ZULAMAN, 47, 42 }, { ZULAMAN, 30, 36 } } },
    [62573] = { t = "Hive Extermination strikes", at = { { EVERSONG, 35, 77 }, { ZULAMAN, 54, 20 }, { ZULAMAN, 53, 81 } } },
    [62570] = { t = "Void Ritual strikes with giant bosses", at = { { EVERSONG, 53, 39.4 }, { EVERSONG, 56, 76.8 }, { ZULAMAN, 32, 71.6 } } },
    [62518] = { t = "Void Cleansing rifts", at = { { EVERSONG, 50, 51 }, { EVERSONG, 35, 53 }, { EVERSONG, 52, 81 }, { ZULAMAN, 31, 42 } } },
    [62136] = { t = "Slayer's Rise", at = { { VOIDSTORM, 58.8, 59.98 } } },
    [62142] = { t = "Training dummies (quiet spot to wait for ambushes)", at = { { VOIDSTORM, 40, 81.5 } } },
    [62143] = { t = "Trap areas (need an active hunt in that zone)", at = { { HARANDAR, 67.2, 34.4 }, { HARANDAR, 51.9, 37.0 }, { ZULAMAN, 41.1, 34.1 }, { ZULAMAN, 37.4, 82.3 }, { VOIDSTORM, 39.2, 66.8 }, { VOIDSTORM, 61.1, 55.8 }, { EVERSONG, 42.8, 55.7 }, { EVERSONG, 61.2, 65.9 } } },
    [62139] = { t = "The Prey hunt table", at = { { SILVERMOON, 55.8, 66.0 } } },
    [62134] = { t = "The Prey hunt table", at = { { SILVERMOON, 55.8, 66.0 } } },
    [62325] = { t = "Abundance locations", at = { { EVERSONG, 56.78, 65.79 }, { ZULAMAN, 31.62, 26.14 }, { HARANDAR, 66.14, 61.69 }, { VOIDSTORM, 38.82, 53.31 } } },
    [62326] = { t = "Abundance locations", at = { { EVERSONG, 56.78, 65.79 }, { ZULAMAN, 31.62, 26.14 }, { HARANDAR, 66.14, 61.69 }, { VOIDSTORM, 38.82, 53.31 } } },
    [62329] = { t = "Abundance locations", at = { { EVERSONG, 56.78, 65.79 }, { ZULAMAN, 31.62, 26.14 }, { HARANDAR, 66.14, 61.69 }, { VOIDSTORM, 38.82, 53.31 } } },
    [62330] = { t = "Abundance locations", at = { { EVERSONG, 56.78, 65.79 }, { ZULAMAN, 31.62, 26.14 }, { HARANDAR, 66.14, 61.69 }, { VOIDSTORM, 38.82, 53.31 } } },
    [62331] = { t = "Abundance locations", at = { { EVERSONG, 56.78, 65.79 }, { ZULAMAN, 31.62, 26.14 }, { HARANDAR, 66.14, 61.69 }, { VOIDSTORM, 38.82, 53.31 } } },
    [61937] = { t = "Watha'nan Crypts", at = { { EVERSONG, 56.78, 65.79 } } },
    [61938] = { t = "Loaknit Den", at = { { ZULAMAN, 31.62, 26.14 } } },
    [61939] = { t = "Floaret Grotto", at = { { HARANDAR, 66.14, 61.69 } } },
    [61940] = { t = "Abundant Voidburrow", at = { { VOIDSTORM, 38.82, 53.31 } } },
    [62601] = { t = "The Underbelly entrance in the Vaults of Atal'Utek", at = { { 2509, 47.21, 3.82 } } },
    [62219] = { t = "Swim out to the trench edge until the warning appears", at = { { ZULAMAN, 75.85, 13.31 } } },
    [62774] = { t = "Air vents on the sea floor and in the ravine", at = { { ZULAMAN, 67.0, 26.0 }, { ZULAMAN, 65.0, 18.0 } } },
    [62342] = { t = "Champion of Pahk", at = { { ZULAMAN, 65.0, 25.0 } } },
    [62343] = { t = "Champion of Pahk", at = { { ZULAMAN, 65.0, 25.0 } } },
    [62832] = { t = "Champion of Pahk", at = { { ZULAMAN, 65.0, 25.0 } } },
    [62829] = { t = "Aggressive fish around here", at = { { ZULAMAN, 65.0, 25.0 } } },
    [62222] = { t = "Brakpuffers swim here at mid-depth", at = { { ZULAMAN, 69.70, 24.64 } } },
    [62759] = { t = "Relic spots (they move around)", at = { { ZULAMAN, 73.15, 20.03 }, { ZULAMAN, 70.78, 19.07 }, { ZULAMAN, 70.31, 21.69 }, { ZULAMAN, 70.17, 24.68 }, { ZULAMAN, 62.95, 31.38 }, { ZULAMAN, 66.92, 25.85 }, { ZULAMAN, 65.47, 23.27 }, { ZULAMAN, 64.65, 24.30 } } },
    [62763] = { t = "Fast-respawning treasure cluster in the ravine", at = { { ZULAMAN, 64.00, 16.12 } } },
    [62521] = { t = "Broken Throne Ritual Site", at = { { ZULAMAN, 29.7, 78.2 } } },
    [63631] = { t = "Captain Tokka's crew at Tokka's Landing", at = { { COILED, 57.2, 48.6 } } },
    [63634] = { t = "Second Mate Sluggs sells The Coiled Huntress; then talk to Captain Tokka", at = { { COILED, 51.6, 49.8 }, { COILED, 57.2, 48.6 } } },
    [63629] = { t = "Open water by Tokka's small island (Spotted Killifish)", at = { { COILED, 51.5, 53.7 } } },
    [62117] = { t = "Abyss Bubbles at the bottom of the sea", at = { { ZULAMAN, 65.40, 26.86 }, { ZULAMAN, 66.7, 28.6 } } },
    [62118] = { t = "Abyss Bubbles at the bottom of the sea", at = { { ZULAMAN, 65.40, 26.86 }, { ZULAMAN, 66.7, 28.6 } } },
    [62119] = { t = "Abyss Bubbles at the bottom of the sea", at = { { ZULAMAN, 65.40, 26.86 }, { ZULAMAN, 66.7, 28.6 } } },
    [62772] = { t = "Abyss Bubbles at the bottom of the sea", at = { { ZULAMAN, 65.40, 26.86 }, { ZULAMAN, 66.7, 28.6 } } },
    [61442] = { t = "Li Li Stormstout (book icon) in Silvermoon", at = { { SILVERMOON, 58.6, 71.0 } } },
    [62370] = { t = "Harandar has the most Thalassian Lumber", at = { { HARANDAR, 50.0, 50.0 } } },
    [42283] = { t = "Chel the Chip, Abundance vendor", at = { { ZULAMAN, 31.6, 26.2 } } },
    [63381] = { t = "Curse Surge spots (one active at a time, 45 minutes each)", at = { { COILED, 70.5, 32.7 }, { COILED, 67.1, 77.5 }, { COILED, 46.7, 62.8 }, { COILED, 45.7, 29.6 }, { COILED, 26.4, 64.9 } } },
    [62267] = { t = "Feevra's Kapara pool (any Kapara in Zul'Aman counts)", at = { { ZULAMAN, 32.32, 22.39 } } },
    [62190] = { t = "Lord Saltheril, Saltheril's Haven", at = { { EVERSONG, 42.68, 47.31 } } },
    [62649] = { t = "Shrine of Sky: stand in the green circle, dismount, press the extra action button", at = { { 2509, 50.95, 16.28 } } },
    [63382] = { t = "The Forum: stand in the green clouds while its Cursed Surge is up", at = { { COILED, 26.7, 64.6 } } },
    [61860] = { t = "Fly straight up above the Den", at = { { HARANDAR, 51.20, 53.71 } } },
    [61861] = { t = "Tag the Roaming Shredclaw on the rock, then follow the Harrower to its nest (43.8, 51.7)", at = { { VOIDSTORM, 60.76, 56.90 } } },
    [63596] = { t = "Auto-run into this corner next to the Altar of Fangs entrance", at = { { 2509, 50.11, 67.02 }, { 2509, 42.92, 61.63 }, { 2509, 44.49, 64.34 } } },
    [62120] = { t = "Du'gal's Altar of Blessings, Amani'Zar Village", at = { { ZULAMAN, 43.0, 69.2 } } },
    [62121] = { t = "Du'gal's Altar of Blessings, Amani'Zar Village", at = { { ZULAMAN, 43.0, 69.2 } } },
    [62269] = { t = "Du'gal's Altar of Blessings, Amani'Zar Village", at = { { ZULAMAN, 43.0, 69.2 } } },
    [62270] = { t = "Du'gal the Altar Keeper, Amani'Zar Village", at = { { ZULAMAN, 43.0, 69.2 } } },
    [63432] = { t = "Ofi the Sly at Tokka's Landing (quests and the cauldron)", at = { { COILED, 57.43, 48.68 }, { COILED, 61.26, 32.88 } } },
    [61082] = { t = "The Arcantina: find this week's visitors", at = { { 2541, 50.0, 50.0 } } },
    [61083] = { t = "The Arcantina: place the decorations here", at = { { 2541, 50.0, 50.0 } } },
    [63619] = { t = "The Arcantina: find this week's visitors", at = { { 2541, 50.0, 50.0 } } },
    [61081] = { t = "Buy Toasting Brews from Bartender Bob in the Arcantina", at = { { 2541, 60.4, 66.4 } } },
}


-- Ordered walkthroughs for achievements: the arrow follows them one step at a time. A step with
-- `quest` or `item` ticks by itself; right-click the arrow to tick one the game cannot see.
ns.ACH_STEPS = {
    [62199] = {
        { t = "Talk to Chu'ke, the possessed doll", at = { ZULAMAN, 59.24, 71.09 } },
        { t = "Talk to Kalika (tailoring trainer) at Witherbark Bluffs, then press the Forgotten Button behind the jade statue nearby", at = { ZULAMAN, 38.66, 23.78 } },
        { t = "Talk to Chu'ke again at the Possessed Dolls on the Funerary Coast", at = { ZULAMAN, 37.80, 90.11 } },
    },
    [62202] = {
        { t = "Talk to Feevra", at = { ZULAMAN, 32.31, 22.39 } },
        { t = "Talk to the Kapara Pup next to her to start the run (no mounting)", at = { ZULAMAN, 32.24, 22.31 } },
        { t = "Land in the big finish circle", at = { ZULAMAN, 51.52, 32.79 } },
        { t = "If \"Spiritpaw Runner found\" did not tick, talk to Feevra again", at = { ZULAMAN, 32.31, 22.39 } },
    },
    [62186] = {
        { t = "Pick up the party quest from Jonas Everdawn in Silvermoon", at = { SILVERMOON, 45.66, 62.58 } },
        { t = "Talk to Lord Saltheril at Saltheril's Haven, visit the vendors, choose this week's faction", at = { EVERSONG, 42.68, 47.31 } },
        { t = "Use all three invitations on that faction and do its weekly quests; repeat for four weeks" },
    },
    [61861] = {
        { t = "Hit the Roaming Shredclaw resting on the rock (you must tag it yourself)", at = { VOIDSTORM, 60.76, 56.90 } },
        { t = "Follow the Opportunistic Harrower to its nest", at = { VOIDSTORM, 43.79, 51.69 } },
    },
    [63636] = {
        { t = "Jan'sari the Watchful", at = { COILED, 58.78, 45.95 } },
        { t = "Er'inye (Vaults of Atal'Utek)", at = { 2509, 51.17, 62.80 } },
        { t = "Venom-Worn Coffer (Vaults)", at = { 2509, 53.90, 18.00 } },
        { t = "Eye of Szarith (the Underbelly)", at = { 2613, 68.60, 15.66 } },
        { t = "Jin'tal", at = { 2636, 48.08, 72.69 } },
        { t = "Faintly Glowing Gem (Vaults)", at = { 2509, 47.96, 51.82 } },
        { t = "Jin'tal's Reliquary", at = { 2638, 36.26, 23.70 } },
        { t = "Feather of Tokjara (Vaults)", at = { 2509, 48.50, 25.76 } },
        { t = "Spend the points at the Altar of Corrosion; the last one needs Renown 14 with Zul'jarra's Forces" },
    },
}

ns.GROUP_NOTES = {
    ["Prey"] = "Prey hunts are picked up at the hunt table in Silvermoon City (inside the building around 55.8, 66.0). A difficulty achievement only counts kills "
        .. "on that exact difficulty, and the hunt quest must be handed in. When your prey is revealed you can hold off the final fight: that is the calm time for the side goals.",
    ["Abundance"] = "Abundance events run at four spots: Watha'nan Crypts (Eversong, 56.8, 65.8), Loaknit Den (Zul'Aman, 31.6, 26.1), Floaret Grotto (Harandar, 66.1, 61.7) "
        .. "and the Abundant Voidburrow (Voidstorm, 38.8, 53.3). Kill mobs, gather orbs and materials and bring them to the altar. Every 10,000 progress triggers one of five bonuses. "
        .. "The enhanced location of the week, in a raid group, goes fastest. Chel the Chip sells the rewards and a teleport toy.",
    ["Abyss Anglers"] = "Abyss Angler dives start off the Zul'Aman coast with Depthdiver Tu'nakit (about 68.2, 20.2). Many of these are dive upgrades bought with Abyss Angler currency.",
    ["Ritual Sites"] = "One Ritual Site is active at a time (Broken Throne in Zul'Aman, Daggerspine Point in Eversong). Challenges can be added before you start: "
        .. "the challenge achievements need them present when you finish, and they only pop when the final boss dies. Weekly study quests come from Lady Darkglen in Silvermoon.",
    ["Void Assaults"] = "Void Strikes and Incursions rotate between Eversong and Zul'Aman week by week, plus the Naigtal and Val showdowns reached through the portals in Voidstorm. "
        .. "Several achievements only fit certain strikes, so check which strikes are up before farming. Achievements marked Heroic need Heroic World Tier.",
    ["Delves"] = "Tier achievements accept that tier or higher. Role achievements need a clear as Damage Dealer, Healer and Tank with lives remaining. "
        .. "Each delve's story variant changes daily (hover the delve on the map to see today's), so the Stories achievements take several visits. "
        .. "Rank 4 curios only come from Bountiful delves at Tier 7 or higher.",
    ["Skyriding"] = "Fly through each glyph; a single-glyph achievement points the arrow straight at its glyph.",
    ["Fishing"] = "Fishing on the Coiled Isle is tied to Captain Tokka's crew; turn on Find Fish tracking on the minimap.",
    ["Professions"] = "Profession goals: max skill, crafting orders and the Dedicated to the Craft knowledge goals, per profession.",
    ["Collections"] = "Set achievements need every piece of the set learned; equip pieces to learn them.",
    ["PvP"] = "PvP achievements: war mode world quests, battlegrounds, arenas and Slayer's Rise in Voidstorm.",
    ["World Events"] = "Only during the matching holiday or event.",
}

-- Delve entrances, used when the game's delve markers are not loaded yet.
ns.DELVE_ENTRANCES = {
    ["Collegiate Calamity"] = { SILVERMOON, 40.76, 54.06 },
    ["The Darkway"] = { SILVERMOON, 39.3, 32.1 },
    ["The Shadow Enclave"] = { EVERSONG, 45.4, 86.0 },
    ["Atal'Aman"] = { ZULAMAN, 24.8, 53.0 },
    ["Twilight Crypts"] = { ZULAMAN, 25.4, 84.3 },
    ["The Grudge Pit"] = { HARANDAR, 70.5, 64.9 },
    ["The Gulf of Memory"] = { HARANDAR, 36.3, 49.2 },
    ["Sunkiller Sanctum"] = { VOIDSTORM, 54.8, 47.0 },
    ["Shadowguard Point"] = { VOIDSTORM, 37.38, 47.7 },
    ["Parhelion Plaza"] = { 2424, 47.74, 41.58 },
    ["Venomfall Deeps"] = { COILED, 51.23, 31.01 },
    ["The Ring of Glory"] = { COILED, 71.2, 56.5 },   -- inside the small building outside the arena
    ["Gnarldor Isle"] = { COILED, 64.45, 77.73 },
}

-- Notes shown in a delve's tooltip.
ns.DELVE_NOTES = {
    ["Venomfall Deeps"] = "The Season 2 Nemesis delve, where you face Azta'rec. It has no Sturdy Chests or Discoveries "
        .. "achievement; Let Me Solo Him: Azta'rec only counts with hard modes on. The door at the entrance opens once "
        .. "you have finished the An Island of Fangs chapter of the campaign.",
}
