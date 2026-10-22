-- Completion: the Seasonal book's hand-written half. One entry per holiday, in the order of the tabs.
--
-- Event fields:
--   key, id (the game's holiday ID), name, short, iconAch (tab icon), calendar (title words to match the
--   in-game calendar), hub (map shown on the page: a uiMapID or { A = id, H = id }), currency (itemID shown
--   on the page) or currencyID, dates (fallback when the calendar can't be read), monthly (Darkmoon Faire),
--   desc (left page), intro (right page), lootText (source of collectibles that aren't sold), steps (the guide).
-- Step fields (all optional except the title, [1]):
--   note     what to do, shown under the arrow and in the tooltip
--   q        quest ID, list of quest IDs (all needed), or { A = ..., H = ... }; any = true: one of them is enough
--   npc/obj  where to go (positions come from Data/Events.lua); at = { uiMapID, x, y } overrides
--   ach      done when this achievement is (a { A, H } pair works too)
--   own      done when you own this collectible; item + count: done when your bags hold it
--   side     "A" or "H" for one faction only; daily = true for steps that come back every day
--   group    heading in the guide list
-- Walkthroughs for the holidays' achievements are added to ns.ACH_NOTES at the end.

local _, ns = ...

local ALLIANCE, HORDE = "A", "H"

ns.EVENT_DEFS = {
    ------------------------------------------------------------------------
    {
        key = "lunar", id = 327, name = "Lunar Festival", short = "Lunar", iconAch = 913,
        lootText = "From the Lunar Festival vendors in Nighthaven, or Elune's Blessing.",
        calendar = { "Lunar Festival" }, hub = 80, currency = 21100,
        dates = { { { 2027, 2, 2 }, { 2027, 2, 16 } } },
        desc = "Honor the elders across Azeroth for Coins of Ancestry, then spend them in Nighthaven, Moonglade.",
        intro = "Every elder you speak to gives one Coin of Ancestry, and the coins never expire. Start in your capital, "
            .. "take the invitation to Moonglade, then work through the elders zone by zone: the Achievements section points at "
            .. "every elder you still need. To Honor One's Elders gives the title Elder.",
        steps = {
            { "Meet the festival herald", group = "Get started", q = { A = { 8870, 8871, 8872, 73169 }, H = { 8873, 8874, 8875, 73170 } }, any = true,
              note = "A Lunar Festival herald or emissary in your capital sends you to the festival camp in the same city." },
            { "Lunar Fireworks", group = "Get started", q = 8867, npc = 15898,
              note = "Buy fireworks from the Lunar Festival Vendor at the camp. Launch 8 small fireworks, then 2 rocket clusters from a Cluster Launcher on the ground." },
            { "The Rocket's Red Glare", group = "Get started", ach = 1281, npc = 15898,
              note = "Buy 10 Red Rocket Clusters and fire all 10 from a Cluster Launcher within 25 seconds. Put them on an action bar first." },
            { "Frenzied Firecracker", group = "Get started", ach = 1552, npc = 15898,
              note = "Buy 10 Festival Firecrackers and set off all 10 within 30 seconds. Put them on a key and press it repeatedly." },
            { "Go to Moonglade", group = "Get started", q = 8883, npc = 15864,
              note = "Stand in the moonlight beam at the camp and use the Lunar Festival Invitation. In Nighthaven, speak to Valadar Starsong on the platform over the lake." },
            { "Elune's Blessing", group = "Moonglade", q = 8868, ach = 937, at = { 80, 70.0, 64.0 },
              note = "Valadar sends you after Omen, south-east of Lake Elune'ara by the Stormrage Barrow Dens. Fire rocket clusters from the launchers there until Omen appears; stand near his body after the kill for Elune's Blessing. No tag needed." },
            { "Lunar Preservation", group = "Moonglade", q = 56842,
              note = "Rite of the Moon at moonwells in Ashenvale, Felwood, Feralas, Moonglade, Stonetalon, Duskwood and Mount Hyjal. Keep the Blessing of the Moon buff up or start over. Rewards crowns and coins." },
            { "Elders of Kalimdor", group = "Honor the elders", ach = 911,
              note = "Every elder in Kalimdor. Track the achievement and the arrow takes you to the nearest elder you still need. Zidormi in Darkshore and Silithus shows the old versions where some elders stand." },
            { "Elders of Eastern Kingdoms", group = "Honor the elders", ach = 912,
              note = "Every elder in the Eastern Kingdoms. Zidormi in Tirisfal and the Blasted Lands shows the old versions where some elders stand." },
            { "Elders of the Alliance", group = "Honor the elders", ach = 915,
              note = "The elders in the Alliance capitals. Horde characters can reach them too." },
            { "Elders of the Horde", group = "Honor the elders", ach = 914,
              note = "The elders in the Horde capitals. Alliance characters can reach them too." },
            { "Elders of the Dungeons", group = "Honor the elders", ach = 910,
              note = "Elders inside old dungeons, usually by a boss room: run each dungeon and talk to the elder." },
            { "Elders of Northrend", group = "Honor the elders", ach = 1396 },
            { "Elders of Cataclysm", group = "Honor the elders", ach = 6006,
              note = "Two elders in Mount Hyjal, two in Uldum." },
            { "Elders of the Dragon Isles", group = "Honor the elders", ach = 17321 },
            { "Elders of Khaz Algar", group = "Honor the elders", ach = 41130 },
            { "Lunar Festival Finery", group = "Spend coins", ach = 626, npc = 15864,
              note = "Buy a festive dress or pant suit from Valadar Starsong (5 coins) and you have it." },
            { "Spend the rest", group = "Spend coins", npc = 15909,
              note = "Fariel Starsong (toys, patterns) and Valadar Starsong (pets, outfits, the Lunar Launcher mount) in Nighthaven. The Collectibles section lists every price." },
        },
    },
    ------------------------------------------------------------------------
    {
        key = "love", id = 423, name = "Love is in the Air", short = "Love", iconAch = 1693,
        lootText = "From the gala vendors, or the Heart-Shaped Box from Apothecary Hummel's daily kill.",
        calendar = { "Love is in the Air" }, hub = { A = 84, H = 85 }, currency = 49927,
        dates = { { { 2027, 2, 8 }, { 2027, 2, 22 } } },
        desc = "The Gala of Gifts outside Stormwind or Orgrimmar, the Crown Chemical plot and Apothecary Hummel.",
        intro = "Love Tokens vanish when the holiday ends, so spend them as you go. Do the one-time quests first, then the "
            .. "dailies every day: a scenic getaway, a self-care day and the holiday boss. Fool For Love gives the title the Love Fool.",
        steps = {
            { "Love is in the Air", group = "Get started", q = { A = 78329, H = 78981 },
              note = "A commoner in your capital sends you to the Gala of Gifts by the city gates." },
            { "Take a Look Around", group = "Get started", q = { A = 78328, H = 78980 },
              note = "Speak to each vendor at the gala. This opens the dailies." },
            { "I Smell Trouble", group = "Crushing the Crown", q = { A = 78332, H = 78982 },
              note = "Use the O.D.I.E. remote to sniff out three clues in the city." },
            { "An Unwelcome Gift", group = "Crushing the Crown", q = { A = 78337, H = 78983 } },
            { "Raising a Stink", group = "Crushing the Crown", q = { A = 78729, H = 78978 },
              note = "Meet at the entrance of Shadowfang Keep in Silverpine Forest." },
            { "Crushing the Crown", group = "Crushing the Crown", q = { A = 78369, H = 78984 },
              note = "Take Bon-Bombs from the chest and bomb the Crown workers in Pyrewood Village until the bar is full." },
            { "The Stench of Revenge", group = "Crushing the Crown", q = { A = 78379, H = 78985 },
              note = "Queue for the holiday dungeon in the Dungeon Finder and defeat Apothecary Hummel." },
            { "Scenic getaway", group = "Every day", daily = true, any = true, q = { A = { 78591, 78594, 78565 }, H = { 78987, 78988, 78986 } },
              note = "One of Nagrand (photos of four creatures), Feralas (gift matching at the beach resort) or Grizzly Hills (flowers)." },
            { "Self-care", group = "Every day", daily = true, any = true, q = { A = { 78727, 78724, 78726 }, H = { 78979, 78993, 78992 } },
              note = "A small set of errands around Goldshire or Razor Hill: a friendly duel, a treat, a nap at the inn and two gifts." },
            { "Apothecary Hummel", group = "Every day", daily = true, ach = 4624,
              note = "Queue for the holiday dungeon. The first kill each day gives a Heart-Shaped Box, the best chance at the mounts." },
            { "Be Mine! and Sweet Tooth", group = "Achievements", ach = { 1701, 1702 },
              note = "Buy Bags of Heart Candies and a Box of Chocolates from the gala vendors. Eat candies until you have all 8 messages; eat the 4 chocolates." },
            { "Fistful of Love", group = "Achievements", ach = 1699,
              note = "Throw Handfuls of Rose Petals at the 11 race and class pairs. Capitals and battlegrounds are the quickest places to find them." },
            { "Shafted!", group = "Achievements", ach = 1188,
              note = "Shoot 10 players with a Silver Shafted Arrow. Each player once; it fails on someone who already has a pet out." },
            { "The Rocket's Pink Glare", group = "Achievements", ach = 1696,
              note = "Buy 10 Lovely Fireworks and launch them all within 20 seconds." },
            { "Lonely?", group = "Achievements", ach = 1291,
              note = "In Dalaran (Northrend), use a Romantic Picnic Basket and eat a Buttermilk Delight from a Box of Chocolates while sitting at it." },
            { "I Pitied The Fool", group = "Achievements", ach = 1704,
              note = "Place a Love Fool and /pity it in Wintergrasp, the Arathi Basin blacksmith, Naxxramas, the Gurubashi Arena ring and the Culling of Stratholme." },
            { "My Love is Like a Red, Red Rose", group = "Achievements", ach = 1703,
              note = "A Bouquet of Red or Ebon Roses can drop from Lord Godfrey (Shadowfang Keep) and other listed dungeon bosses during the holiday." },
            { "Dangerous Love", group = "Achievements", ach = 1695, note = "Done with the first quest of the Crown chain." },
        },
    },
    ------------------------------------------------------------------------
    {
        key = "noble", id = 181, name = "Noblegarden", short = "Noblegarden", iconAch = 2798,
        lootText = "From the Noblegarden vendors, Brightly Colored Eggs, or Daetan Swiftplume's basket.",
        calendar = { "Noblegarden" }, hub = { A = 37, H = 1 }, currency = 44791,
        dates = { { { 2027, 3, 29 }, { 2027, 4, 5 } } },
        desc = "Egg hunts in the starting towns, chocolate to spend, and a duck with a golden egg.",
        intro = "Brightly Colored Eggs hide around Goldshire, Kharanos, Dolanaar and Azure Watch (Razor Hill, Brill, Bloodhoof Village "
            .. "and Falconwing Square for the Horde). Eggs give chocolate and sometimes the outfit pieces you need, so collect first, "
            .. "buy second and eat last. Noble Gardener gives the title the Noble.",
        steps = {
            { "Spring Collectors / Gatherers", group = "Get started", q = { A = 13484, H = 13483 },
              note = "A commoner in your capital points you to the egg town nearby." },
            { "A Tisket, a Tasket, a Noblegarden Basket", group = "Get started", q = { A = 13502, H = 13503 },
              note = "Fill the borrowed basket with 10 chocolates. You keep the basket appearance and toy." },
            { "I Found One!", group = "Achievements", ach = 2676, note = "Loot any Brightly Colored Egg." },
            { "What the Duck?", group = "The duck", q = { A = 79322, H = 79575 },
              note = "Scare 10 ducks around the egg town with the horn." },
            { "A Fowl Concoction", group = "The duck", q = { A = 79323, H = 79576 }, note = "The mage in the portal room has a potion for you." },
            { "Duck Tales", group = "The duck", q = { A = 79330, H = 79577 }, note = "Drink it and talk to five ducks." },
            { "Just a Waddle Away", group = "The duck", q = { A = 79331, H = 79578 },
              note = "Confront Daetan Swiftplume, then take his item by the large nest. Choose a Spring Reveler's piece as the reward." },
            { "Daetan Swiftplume", group = "Every day", daily = true, ach = 20209, at = { A = { 37, 30.6, 90.8 }, H = { 1, 44.6, 35.6 } },
              note = "Find the golden egg near the nest and roll it into the Large Duck Nest with the extra button; the boss spawns. His trinket starts Feathered Fiend for a basket with a chance at the flying carpet." },
            { "Feathered Fiend", group = "Every day", daily = true, q = { A = 73192, H = 79558 } },
            { "Quacking Down", group = "Every day", daily = true, q = { A = 78274, H = 79135 } },
            { "The Great Egg Hunt", group = "Every day", daily = true, q = { A = 13480, H = 13479 },
              note = "Bring 20 Brightly Colored Shell Fragments from the eggs." },
            { "Sunday's Finest and Dressed for the Occasion", group = "Achievements", ach = { 248, 249 },
              note = "The White Tuxedo Shirt, Black Tuxedo Pants and Elegant Dress drop from eggs, or buy them from the Noblegarden vendor." },
            { "Blushing Bride", group = "Achievements", ach = 2576,
              note = "Wear the tuxedo shirt and pants and /kiss someone wearing the Elegant Dress. Only the one in the tuxedo gets it." },
            { "Shake Your Bunny-Maker", group = "Achievements", ach = 2422,
              note = "Use Spring Flowers on players of 12 races (level 18 or higher) to give them bunny ears. 5 minute cooldown per target." },
            { "Spring Fling", group = "Achievements", ach = { A = 2419, H = 2497 },
              note = "Summon your Spring Rabbit next to another player's Spring Rabbit in each of your four egg towns." },
            { "Desert Rose", group = "Achievements", ach = 2436,
              note = "Use the Spring Florist's Pouch anywhere in the Badlands, Silithus, Thousand Needles, Desolace and Tanaris." },
            { "Hard Boiled", group = "Achievements", ach = 2416, at = { 78, 33.0, 49.0 },
              note = "As a Noblegarden bunny, lay an egg at the Golakka Hot Springs in Un'Goro Crater. Easiest: a friend uses the bunny costume item on you there." },
            { "Noble Garden", group = "Achievements", ach = { A = 2421, H = 2420 },
              note = "Buy a Brightly Colored Egg from the vendor and hide it in Stormwind (Silvermoon City for the Horde)." },
            { "Chocoholic", group = "Achievements", ach = 2418, note = "Eat 100 Noblegarden Chocolates in total. Do this last, after buying what you need." },
        },
    },
    ------------------------------------------------------------------------
    {
        key = "children", id = 201, name = "Children's Week", short = "Children", iconAch = 1793,
        lootText = "An orphan quest reward, or bought with a Well-loved Figurine.",
        calendar = { "Children's Week" }, hub = { A = 84, H = 85 }, currency = 241215,
        dates = { { { 2027, 5, 3 }, { 2027, 5, 10 } } },
        desc = "Take orphans on trips around the world for pets and Well-loved Figurines.",
        intro = "Each orphan's trip can be done once a year per character. Keep the orphan out (use its whistle) for the "
            .. "achievements. Figurines buy every Children's Week reward from the toy vendors. For the Children gives the title Matron or Patron.",
        steps = {
            { "Pick up your orphan", group = "Capital orphan", q = { A = 1468, H = 172 },
              note = "The Orphan Matron in Stormwind (Orgrimmar for the Horde) gives you an orphan and a whistle." },
            { "First trips", group = "Capital orphan", q = { A = { 29093, 54130, 29106 }, H = { 29146, 54146, 29176 } },
              note = "Three outings; the arrow shows the next quest's place while it is in your log." },
            { "Ice cream and a kite", group = "Capital orphan", q = { A = { 29119, 29117 }, H = { 29191, 29190 } } },
            { "Back to the matron", group = "Capital orphan", q = { A = 171, H = 5502 },
              note = "Buy the toy the orphan wants on the way and return. Pick a pet or a Well-loved Figurine." },
            { "Shattrath orphan", group = "Outland orphan", q = { A = 10943, H = 10942 },
              note = "Orphan Matron Mercy in Shattrath's Lower City." },
            { "Shattrath trips", group = "Outland orphan", q = { A = { 10950, 10954, 10952, 10956, 10968, 10962 }, H = { 10945, 10953, 10951, 11975, 10963 } } },
            { "Back to the orphanage", group = "Outland orphan", q = { A = 10966, H = 10967 } },
            { "Dalaran orphan", group = "Northrend orphan", q = { 13926, 13927 }, any = true,
              note = "Orphan Matron Aria in Dalaran (Northrend): Roo the oracle or Kekek the wolvar. You can pick only one each year." },
            { "Dalaran trips", group = "Northrend orphan", q = { 13959, 13960 }, any = true,
              note = "Five or six outings across Northrend, ending back in Dalaran." },
            { "Boralus or Dazar'alor orphan", group = "Battle for Azeroth orphan", q = { A = 53811, H = 53965 } },
            { "Trips with your orphan", group = "Battle for Azeroth orphan", q = { A = { 53859, 53861, 53862, 53863, 53864 }, H = { 53966, 53968, 53967, 53970, 53969 } } },
            { "Return to the orphanage", group = "Battle for Azeroth orphan", q = { A = 53865, H = 53971 } },
            { "Children's Week in Dornogal", group = "Khaz Algar orphans", q = 89317, note = "Ullna in Dornogal has four children for you, one at a time." },
            { "Bold for a Kobold", group = "Khaz Algar orphans", q = 89318, note = "Mereldar in Hallowfall: the bridge, the training grounds, the candle shop and the orphanage." },
            { "The Wondrous Weave", group = "Khaz Algar orphans", q = 89319, note = "The Weaver's Lair in Azj-Kahet. Speak to Widow Arak'nai unmounted." },
            { "The Eager Engineer", group = "Khaz Algar orphans", q = 89320, note = "Ride the rocket drill from Gutterville to Undermine." },
            { "Recreation for Rooks", group = "Khaz Algar orphans", q = 89321, note = "Around Dornogal. Place the Storm Glass carefully at the giant hammer." },
            { "A Brighter Tomorrow", group = "Khaz Algar orphans", q = 89322 },
            { "Aw, Isn't It Cute?", group = "Achievements", ach = 1792, note = "Get any pet from an orphan's reward." },
            { "Home Alone", group = "Achievements", ach = 1791, note = "Use your Hearthstone (or a hearthstone toy) with your orphan out." },
            { "Daily Chores", group = "Achievements", ach = 1789, note = "Turn in five daily quests with your orphan out." },
            { "Bad Example", group = "Achievements", ach = 1788, npc = 29548,
              note = "With your orphan out, eat the listed sweets. Most are sold by Aimee in Dalaran (Northrend)." },
            { "Hail To The King, Baby", group = "Achievements", ach = 1790, note = "Kill King Ymiron in Utgarde Pinnacle with your orphan out." },
            { "School of Hard Knocks", group = "Achievements", ach = 1786,
              note = "With your orphan out: capture the flag in Eye of the Storm, assault a flag in Arathi Basin, assault a tower in Alterac Valley, return a flag in Warsong Gulch." },
        },
    },
    ------------------------------------------------------------------------
    {
        key = "midsummer", id = 341, name = "Midsummer Fire Festival", short = "Midsummer", iconAch = { A = 1038, H = 1039 },
        lootText = "From the Midsummer vendors (Burning Blossoms), or Ahune's daily loot.",
        calendar = { "Midsummer Fire Festival" }, hub = { A = 84, H = 85 }, currency = 23247,
        dates = { { { 2027, 6, 21 }, { 2027, 7, 5 } } },
        desc = "Honor your side's bonfires, douse the other side's, steal the enemy capitals' flames and face Ahune.",
        intro = "Every bonfire can be honored or desecrated once a year, for Burning Blossoms. The Achievements section points "
            .. "at every fire you still need, zone by zone. Fire Festival Fury gives the title Flame Warden or Flame Keeper.",
        steps = {
            { "Fires of the Festival", group = "Get started", q = { A = 11970, H = 11971 },
              note = "A commoner in your capital sends you to the main festival fire." },
            { "The Tale of the Frost Lord", group = "Get started", q = 92185, note = "The festival lore keeper tells you about Ahune." },
            { "Ahune", group = "Every day", daily = true, ach = 263,
              note = "Queue for the holiday dungeon. The first kill each day gives the best loot. The first kill ever drops an item that starts a quest for a cloak." },
            { "Torch Tossing", group = "Every day", daily = true, q = { A = 82087, H = 82105 },
              note = "Hit the marked braziers with the Practice Torches. A macro helps: /use [@cursor] Practice Torches." },
            { "Torch Catching", group = "Every day", daily = true, q = { A = { 11657, 11924 }, H = { 11923, 11925 } }, any = true },
            { "Ignite the Skies", group = "Skyriding", q = { A = 92711, H = 92435 }, note = "The skyriding tour of the fires starts at your capital's camp." },
            { "Tour the first continent", group = "Skyriding", q = { A = { 92504, 92503 }, H = { 92106, 92420 } } },
            { "Tour the second continent", group = "Skyriding", q = { A = 92635, H = 92634 } },
            { "Reignite the Skies", group = "Every day", daily = true, q = { A = 92836, H = 92839 } },
            { "Steal the enemy flames", group = "King of the Fire Festival", ach = 1145,
              note = "Click the flame in each enemy capital: the quest starts from the flame itself. Then turn in A Thief's Reward at your own capital fire." },
            { "Fires of your side", group = "Bonfires", ach = { A = 1034, H = 1036 },
              note = "Honor your side's bonfire in every zone of Kalimdor, the Eastern Kingdoms, Outland, Northrend and Cataclysm. Track it and the arrow goes from fire to fire." },
            { "Douse the enemy fires", group = "Bonfires", ach = { A = 1035, H = 1037 },
              note = "Desecrate the other side's bonfires in the same zones." },
            { "Midnight bonfires", group = "Bonfires", ach = { A = 61336, H = 61335 },
              note = "Silvermoon, Tranquillien, Zul'Aman, Harandar and Voidstorm." },
            { "Burning Hot Pole Dance", group = "Achievements", ach = 271,
              note = "Wear the Midsummer shoulders, vest and sandals together and dance at a Ribbon Pole for 60 seconds." },
            { "Torch Juggler", group = "Achievements", ach = 272,
              note = "In Dalaran (Northrend), juggle 40 torches in 15 seconds. Buy Juggling Torches in stacks and spam them at your feet." },
        },
    },
    ------------------------------------------------------------------------
    {
        key = "pirates", id = 398, name = "Pirates' Day", short = "Pirates", iconAch = 3457,
        lootText = "From Dread Captain DeMeza or Ol' Eary in Booty Bay.",
        calendar = { "Pirates' Day" }, hub = 210,
        dates = { { { 2027, 9, 19, 0 }, { 2027, 9, 20, 0 } } },
        desc = "One day only, on the roof of the Booty Bay bank.",
        intro = "Pirates' Day lasts a single day. Speak to Dread Captain DeMeza on the roof of the bank in Booty Bay for the "
            .. "achievement, and watch for Ol' Eary in the harbour for his toy.",
        steps = {
            { "Drink with the Dread Captain", group = "Booty Bay", ach = 3457, npc = 28048,
              note = "Dread Captain DeMeza on the roof of the Booty Bay bank. Her drink gives a 12-hour pirate costume and the achievement." },
            { "Ol' Eary", group = "Booty Bay", npc = 108715,
              note = "A shark that shows up in Booty Bay about every half hour today. It always drops its toy." },
            { "DeMeza's wares", group = "Booty Bay", npc = 28048,
              note = "She sells a parrot, transmog and the skyriding armor; see Collectibles for prices." },
        },
    },
    ------------------------------------------------------------------------
    {
        key = "brewfest", id = 372, name = "Brewfest", short = "Brewfest", iconAch = 1683,
        lootText = "From the Brewfest vendors, or Coren Direbrew's daily keg.",
        calendar = { "Brewfest" }, hub = { A = 27, H = 1 }, currency = 37829,
        dates = { { { 2026, 9, 20 }, { 2026, 10, 6 } }, { { 2027, 9, 20 }, { 2027, 10, 6 } } },
        desc = "The brewers' camps outside Ironforge and Orgrimmar: ram racing, Coren Direbrew and Bar Tab barrels.",
        intro = "Brewfest Prize Tokens are warbound. Do the one-time quests and the Bar Tab barrels first (about 400 tokens), "
            .. "then the dailies. The Wolpertinger quests are not offered on European realms: buy the pet instead. "
            .. "Brewmaster gives the title.",
        steps = {
            { "Brewfest!", group = "Get started", q = { A = 11441, H = 11446 },
              note = "A commoner in your capital sends you to the camp outside Ironforge (Orgrimmar for the Horde)." },
            { "Brewfest Banquet kitchen", group = "Get started", q = { 90870, 91067, 90879, 91066, 90880, 91068 }, any = true,
              note = "Three short quests by the camp teach the Banquet event (gather, cook, serve). After that the Banquet runs at the top of every hour." },
            { "Ram racing lesson", group = "Ram racing", q = { A = 11318, H = 11409 },
              note = "Keep the ram at each speed for 8 seconds with the Ram Racing Reins (extra button). Apple barrels reset fatigue." },
            { "There and Back Again", group = "Ram racing", q = { A = 11122, H = 11412 },
              note = "Pick up three kegs along the road and bring them back before the ram runs out. Then the daily ram race opens." },
            { "A New Supplier of Souvenirs", group = "Ram racing", q = { A = 29397, H = 29396 } },
            { "Chug and Chuck!", group = "Get started", q = { A = 12022, H = 12191 },
              note = "Take a brew from the tables and throw it at the target dummy five times." },
            { "Brewfest Chowdown", group = "Get started", q = { A = 56764, H = 56748 },
              note = "Sit at the Chowdown table; you don't have to win." },
            { "Coren Direbrew", group = "Every day", daily = true, ach = 295,
              note = "Queue for the holiday dungeon. The first kill each day (warband-wide) gives the keg chest with the best chance at the mounts. Your first kill ever drops a quest for 40 tokens." },
            { "Direbrew's Dire Brew", group = "Get started", q = { A = 12491, H = 12492 }, note = "From Coren's first drop." },
            { "Bark for a brewery", group = "Every day", daily = true, any = true, q = { A = { 11293, 11294 }, H = { 11407, 11408 } },
              note = "Ride through the four checkpoints in your capital in time. No apple barrels on this route, so keep a steady trot." },
            { "Barreling Down", group = "Every day", daily = true, any = true, q = { A = { 87289, 77208 }, H = { 87341, 77208 } },
              note = "Ride a barrel downhill without spilling it. One version per day." },
            { "Bubbling Brews", group = "Every day", daily = true, any = true, q = { A = { 87347, 76591 }, H = { 87349, 76591 } },
              note = "Skyride through the bubbles until the bar is full." },
            { "Invasion of the camp", group = "Every day", daily = true, any = true, q = { A = { 56372, 56341, 56322 }, H = { 56715, 56716, 56714 } },
              note = "Every half hour something attacks the camp. Throw beer at them; loot what they leave behind for the quest. One per day." },
            { "Bar Tabs in Midnight", group = "Bar Tab barrels", ach = 63253,
              note = "Donate at the barrel in eight Midnight taverns. 10 tokens each." },
            { "Bar Tabs in Khaz Algar", group = "Bar Tab barrels", ach = 41212 },
            { "Bar Tabs on the Dragon Isles", group = "Bar Tab barrels", ach = 18579 },
            { "The Brewfest Diet", group = "Achievements", ach = 1185,
              note = "Eat the 8 Brewfest foods. The food vendors at the camp sell them all." },
            { "Strange Brew", group = "Achievements", ach = { A = 1184, H = 1203 }, note = "Drink each of your side's brews; the camp's apprentices sell them." },
            { "Brew of the Month", group = "Achievements", ach = 2796,
              note = "Buy the club membership (200 tokens) from the brew vendor at the camp." },
            { "Have Keg, Will Travel", group = "Achievements", ach = 303, note = "Buy Brewfest Hops (2 tokens) and use them on a mount." },
            { "Does Your Wolpertinger Linger?", group = "Achievements", ach = 1936, own = 32233,
              note = "On European realms buy Wolpertinger's Tankard (200 tokens); elsewhere it is a quest reward." },
            { "Disturbing the Peace", group = "Achievements", ach = 293,
              note = "Wear three Brewfest clothing pieces, get completely smashed and /dance in Dalaran (Northrend)." },
            { "Almost Blind Luck", group = "Achievements", ach = 1260,
              note = "Fall 65 yards without dying while wearing the free Synthebrew Goggles." },
        },
    },
    ------------------------------------------------------------------------
    {
        key = "hallows", id = 324, name = "Hallow's End", short = "Hallow's End", iconAch = 1656,
        lootText = "From the Hallow's End vendors (Tricky Treats), or the Headless Horseman's daily pumpkin.",
        calendar = { "Hallow's End" }, hub = { A = 84, H = 85 }, currency = 33226,
        dates = { { { 2026, 10, 19 }, { 2026, 11, 2 } }, { { 2027, 10, 18 }, { 2027, 11, 1 } } },
        desc = "Candy buckets in every inn, the Headless Horseman and fires to put out in the old villages.",
        intro = "Every inn has a candy bucket: one Trick or Treat per bucket per year, and Tricky Treats to spend. The "
            .. "Achievements section points at every bucket you still need, continent by continent. Hallowed Be Thy Name gives "
            .. "the title the Hallowed.",
        steps = {
            { "Treats for Jesper / Spoops", group = "Get started", q = { A = 8311, H = 8312 },
              note = "Do a trick at four city innkeepers: /flex, /train, /chicken and /dance, each at the one who asks." },
            { "Innkeeper tricks", group = "Get started", q = { A = { 8356, 8353, 8357, 8355 }, H = { 8359, 8354, 8360, 8358 } } },
            { "Trick or Treat!", group = "Achievements", ach = 972, note = "Click any candy bucket at an inn." },
            { "Out With It", group = "Achievements", ach = 288, note = "Eat Tricky Treats until you get an Upset Tummy; usually fewer than five." },
            { "That Sparkling Smile", group = "Achievements", ach = 981, note = "Use a Tooth Pick (sold by the candy vendor, or from treat bags)." },
            { "The Masquerade", group = "Achievements", ach = 283,
              note = "Be turned into the 7 costumes by Hallowed Wands: pirate, ninja, leper gnome, ghost, bat, skeleton, wisp. Other players can wand you too; the random one doesn't count." },
            { "Fire Brigade", group = "Village fires", ach = 289,
              note = "In Goldshire, Kharanos or Azure Watch (Razor Hill, Brill or Falconwing Square for the Horde): practice with a water bucket, then put out every fire when the Headless Horseman attacks on the half hour." },
            { "Headless Horseman", group = "Every day", daily = true, ach = 18959,
              note = "Queue for the holiday dungeon in the Scarlet Monastery graveyard. The first kill each day gives the pumpkin with the best chance at the Horseman's Reins, the Ghoulish Charger and Arfus, and a piece of the Ghoulish Collection you don't have yet." },
            { "Kickin' With the Wick", group = "Achievements", ach = 18960,
              note = "Inside the Horseman's dungeon, speak to the wicker men before the fight to add their curses." },
            { "Rotten Hallow", group = "Every day", daily = true, ach = { A = 1040, H = 1041 },
              note = "Four dailies at the Wickerman: a stink bomb run over the enemy city, cleaning stink bombs in your own, lighting your bonfire and dousing theirs." },
            { "Check Your Head", group = "Achievements", ach = 291,
              note = "Throw a Weighted Jack-o'-Lantern at players of 12 races. The lanterns come from the Horseman and the village quest gift." },
            { "Sinister Calling", group = "Achievements", ach = 292, note = "The Sinister Squashling pet and the Hallowed Helm: both drop from the Horseman's loot or can be bought with Tricky Treats." },
            { "Candy buckets: Eastern Kingdoms", group = "Candy buckets", ach = { A = 966, H = 967 } },
            { "Candy buckets: Kalimdor", group = "Candy buckets", ach = { A = 963, H = 965 } },
            { "Candy buckets: Outland", group = "Candy buckets", ach = { A = 969, H = 968 } },
            { "Candy buckets: Northrend", group = "Candy buckets", ach = { A = 5836, H = 5835 } },
            { "Candy buckets: Cataclysm", group = "Candy buckets", ach = { A = 5837, H = 5838 } },
            { "Candy buckets: Pandaria", group = "Candy buckets", ach = { A = 7601, H = 7602 } },
            { "Candy buckets: Dragon Isles", group = "Candy buckets", ach = 18360 },
            { "Candy buckets: Khaz Algar", group = "Candy buckets", ach = 40862 },
            { "Candy buckets: Midnight", group = "Candy buckets", ach = 63400 },
            { "Creepy Crate: the stolen heirlooms", group = "Pet questline", q = { A = { 29074, 29392, 29398, 29399, 29402, 29403, 29411, 29430 }, H = { 29400, 29415, 29416, 29425, 29426, 29427, 29428, 29431 } },
              note = "A short story from the Fenlow sisters; the last quest gives the Creepy Crate pet." },
            { "The Crooked Tree", group = "Every day", q = 43259, note = "Breadcrumb from Duroc Ironjaw in Legion Dalaran, then the hag in Val'sharah." },
            { "Under the Crooked Tree", group = "Every day", daily = true, q = 43162, note = "Drink from the cauldron and defeat Aria Sorrowheart: chance at the sisters' hats." },
        },
    },
    ------------------------------------------------------------------------
    {
        key = "dead", id = 409, name = "Day of the Dead", short = "Day of the Dead", iconAch = 3456,
        lootText = "From Chapman by the graveyard, or The Grateful Dead.",
        calendar = { "Day of the Dead" }, hub = { A = 84, H = 85 },
        dates = { { { 2026, 11, 1, 0 }, { 2026, 11, 3, 23 } }, { { 2027, 11, 1, 0 }, { 2027, 11, 3, 23 } } },
        desc = "Three days by the graveyards of the capitals: dance with Catrina and bake for the spirits.",
        intro = "Bring Simple Flour and Ice Cold Milk before you go: the spirit wants Bread of the Dead, and the recipe "
            .. "only needs cooking skill 1. The contender costumes are toys you can use all year for the duel achievements.",
        steps = {
            { "Dance with Catrina", group = "At the graveyard", ach = 3456, npc = 34383,
              note = "Target Catrina by your capital's graveyard and /dance." },
            { "Bake Bread of the Dead", group = "At the graveyard", npc = 34382,
              note = "Buy the recipe and an Orange Marigold from Chapman next to Catrina. Bread of the Dead needs Simple Flour and Ice Cold Milk." },
            { "The Grateful Dead", group = "At the graveyard", any = true, q = { A = { 13952, 14167, 14168, 14169, 14170, 27846, 14166, 14172, 14173 }, H = { 14174, 14175, 14176, 14177, 14171, 27841, 14166, 14172, 14173 } },
              note = "Use the marigold at the graveyard to see the spirit and give it the bread. Rewards the Macabre Marionette pet (once)." },
            { "Contender costumes", group = "All year", ach = 9426,
              note = "Buy a contender's costume toy from Chapman, then defeat other costumed players: 1, 20 and 50 wins. Works outside the holiday too." },
        },
    },
    ------------------------------------------------------------------------
    {
        key = "pilgrim", id = 404, name = "Pilgrim's Bounty", short = "Pilgrim's Bounty", iconAch = 3478,
        lootText = "A reward from the Pilgrim's Bounty dailies.",
        calendar = { "Pilgrim's Bounty" }, hub = { A = 84, H = 85 },
        dates = { { { 2026, 11, 22 }, { 2026, 11, 29 } } },
        desc = "Bountiful tables outside the capitals, cooking quests and a lot of turkey.",
        intro = "Every capital has a table with five chairs: eat five helpings of each dish for Spirit of Sharing. The cooking "
            .. "chain needs skill up to 280 in Classic cooking; the holiday's own recipes take you there. Pilgrim gives the "
            .. "title and a turkey pet.",
        steps = {
            { "Pilgrim's Bounty", group = "Get started", q = { A = 14022, H = 14036 } },
            { "Sharing a Bountiful Feast", group = "Get started", q = { A = 14064, H = 14065 },
              note = "Sit at a bountiful table and eat five helpings of all five dishes." },
            { "Cooking chain", group = "Cooking", q = { A = { 14023, 14024, 14028, 14030, 14033, 14035 }, H = { 14037, 14040, 14041, 14043, 14044, 14047 } },
              note = "Six deliveries between the capitals' tables. Buy the seasonal recipe book and ingredients from the holiday vendors." },
            { "Daily deliveries", group = "Every day", daily = true, q = { A = { 14048, 14051, 14053, 14054, 14055 }, H = { 14058, 14059, 14060, 14061, 14062 } },
              note = "Twenty of a dish to each cook. You may buy the dishes instead of cooking. Take the clothing rewards first, then Turkey Shooters." },
            { "Now We're Cookin'", group = "Achievements", ach = { A = 3576, H = 3577 }, note = "Cook one of each holiday dish." },
            { "Pilgrim's Paunch", group = "Achievements", ach = { A = 3556, H = 3557 }, note = "Spirit of Sharing at each of your four capitals' tables." },
            { "Sharing is Caring", group = "Achievements", ach = 3558, note = "Sit in each chair and pass its dish to someone." },
            { "\"FOOD FIGHT!\"", group = "Achievements", ach = 3579, note = "Keep passing food to a player who already has the most; it bounces off their head." },
            { "Pilgrim's Progress", group = "Achievements", ach = { A = 3596, H = 3597 }, note = "Do each of the five dailies once." },
            { "Pilgrim's Peril", group = "Achievements", ach = { A = 3580, H = 3581 },
              note = "Wear a Pilgrim's dress, robe or attire from the dailies and sit at each enemy capital's table." },
            { "Terokkar Turkey Time", group = "Achievements", ach = 3582,
              note = "Wearing the pilgrim hat and a pilgrim chest piece, kill Talon King Ikiss in Sethekk Halls." },
            { "The Turkinator", group = "Achievements", ach = 3578,
              note = "Kill 40 Wild Turkeys in Elwynn Forest or Tirisfal Glades, no more than 30 seconds apart." },
            { "Turkey Lurkey", group = "Achievements", ach = 3559,
              note = "Shoot a rogue of each listed race with a Turkey Shooter from the dailies." },
        },
    },
    ------------------------------------------------------------------------
    {
        key = "veil", id = 141, name = "Feast of Winter Veil", short = "Winter Veil", iconAch = 1691,
        lootText = "From the Stolen Present (the Greench daily), a present under the tree, or the Smokywood vendors.",
        calendar = { "Feast of Winter Veil", "Winter Veil" }, hub = { A = 87, H = 85 },
        dates = { { { 2026, 12, 15 }, { 2027, 1, 2 } } },
        desc = "Greatfather Winter in Ironforge and Orgrimmar, the Greench in Hillsbrad and presents from the 25th.",
        intro = "Kiss the Winter Revelers in inns once an hour for mistletoe, holly and snowflakes. Free Metzen from the "
            .. "Greench every day for the Stolen Present. From 25 December, open the presents under the tree on every "
            .. "character. Merrymaker gives the title.",
        steps = {
            { "Greatfather Winter is Here!", group = "Get started", any = true, q = { A = { 7022, 7023 }, H = { 6961, 7021, 7024 } },
              note = "A Smokywood Pastures vendor sends you to Greatfather Winter in Ironforge (Great-father Winter in Orgrimmar)." },
            { "Treats for Greatfather Winter", group = "Get started", q = { A = 7025, H = 6962 },
              note = "Five Gingerbread Cookies and an Ice Cold Milk. The cookie recipe is sold by the Smokywood vendors." },
            { "The Reason for the Season", group = "Get started", q = { A = { 7062, 7063 }, H = { 6964, 7061 } } },
            { "You're a Mean One...", group = "Every day", daily = true, q = { A = 7043, H = 6983 }, ach = 273,
              note = "Kill the Abominable Greench at Growless Cave in Hillsbrad (tag it), free Metzen, and bring back the stolen treats. A sleigh from your capital takes you there." },
            { "A Smokywood Pastures' Thank You!", group = "Get started", q = { A = 7045, H = 6984 }, ach = 279 },
            { "Presents under the tree", group = "From 25 December", ach = 1689, q = { 8744, 8767, 8768, 8769, 8803 }, any = true,
              note = "From 25 December to 2 January, every character can open the presents under the tree in Ironforge or Orgrimmar." },
            { "Winter's Presents", group = "From 25 December", q = { A = 8827, H = 8828 } },
            { "'Tis the Season", group = "Achievements", ach = 277,
              note = "Wear three pieces of winter clothing and eat Graccu's Mince Meat Fruitcake." },
            { "A Frosty Shake", group = "Achievements", ach = 1690, note = "Become a snowman with the snowman kit from the mail and /dance with another snowman in Dalaran." },
            { "Holiday Bromance", group = "Achievements", ach = { A = 1686, H = 1685 }, note = "Use Mistletoe (from kissing Winter Revelers) on each of the listed brothers." },
            { "Fa-la-la-la-Ogri'la", group = "Achievements", ach = 1282,
              note = "Do the Ogri'la bombing daily in Blade's Edge while your flying mount is a reindeer (Fresh Holly)." },
            { "Let It Snow", group = "Achievements", ach = 1687, note = "Throw Handfuls of Snowflakes at the 10 listed race and class pairs." },
            { "Scrooge", group = "Achievements", ach = { A = 1255, H = 259 }, note = "Throw a snowball at the other side's leader: Baine in Thunder Bluff or Muradin in Ironforge." },
            { "The Winter Veil Gourmet", group = "Achievements", ach = 1688, note = "Cook a Gingerbread Cookie, Winter Veil Egg Nog and Hot Apple Cider." },
            { "With a Little Helper from My Friends", group = "Achievements", ach = 252,
              note = "50 honorable kills while wearing the Little Helper costume from a Winter Wondervolt machine." },
        },
    },
    ------------------------------------------------------------------------
    {
        key = "darkmoon", id = 479, name = "Darkmoon Faire", short = "Darkmoon Faire", iconAch = 6019,
        lootText = "From the Faire's vendors (Prize Tickets), its games, or Moonfang.",
        calendar = { "Darkmoon Faire" }, hub = 407, currencyID = 515, monthly = true,
        desc = "Every month for a week on Darkmoon Island: games, races, prize tickets and two odd bosses.",
        intro = "The Faire opens on the first Sunday of each month for a week. Prize tickets are warband-wide. Each visit: "
            .. "the six games, the two pet tamers, the races and the profession quests; the Achievements section has the rest.",
        steps = {
            { "The Darkmoon Faire", group = "Get started", q = { A = 7905, H = 7926 }, ach = 6019,
              note = "A Darkmoon Faire Mystic Mage in your capital ports you to the portal (Goldshire or Mulgore). Keep the Darkmoon Adventurer's Guide in your bags." },
            { "Whack-a-Gnoll", group = "Games, every day", daily = true, q = 29463 },
            { "Human Cannonball", group = "Games, every day", daily = true, q = 29436, note = "Click off the wings over the target in the water. A bullseye is its own achievement." },
            { "Shooting Gallery", group = "Games, every day", daily = true, q = 29438 },
            { "Ring Toss", group = "Games, every day", daily = true, q = 29455 },
            { "Tonk Challenge", group = "Games, every day", daily = true, q = 29434 },
            { "Firebird's Challenge", group = "Games, every day", daily = true, q = 36481 },
            { "Welcome to the Darkmoon Races", group = "Races", q = 37819 },
            { "The Real Race", group = "Races", daily = true, q = 37910 },
            { "Pet tamers", group = "Games, every day", daily = true, q = { 32175, 36471 },
              note = "Jeremy Feasel and Christoph VonFeasel. Warband-wide: one character per day." },
            { "Faire Favors", group = "Once per Faire", ach = 6032,
              note = "Quests for your professions and the secondary ones: two crafting or gathering, plus cooking, fishing and archaeology." },
            { "Darkmoon artifacts", group = "Once per Faire", ach = 6029,
              note = "Keep the Adventurer's Guide in your bags: books drop in dungeons, raids and battlegrounds. Turn each in on the island." },
            { "Moonfang", group = "Once per Faire", q = 33354,
              note = "Kill the wolves north-west of the Faire until Moonfang comes; her drop starts a quest for 10 tickets." },
            { "Darkmoon Rabbit", group = "Achievements", ach = 6332, at = { 407, 77.8, 83.8 }, note = "A rare in the cave south-east of the Faire, on a long timer." },
            { "I Was Promised a Pony", group = "Achievements", ach = 6025, at = { 407, 57.0, 82.0 }, note = "Ride a pony in the pen by the petting zoo." },
            { "Fairegoer's Feast", group = "Achievements", ach = 6026, note = "Eat and drink everything the two food stalls sell." },
            { "Taking the Show on the Road", group = "Achievements", ach = { A = 6030, H = 6031 }, npc = 55278,
              note = "Buy Darkmoon Fireworks and set one off in each listed capital during the Faire." },
        },
    },
}

------------------------------------------------------------------------
-- walkthroughs for the holidays' achievements (tooltips and the book)
------------------------------------------------------------------------

ns.ACH_NOTES = ns.ACH_NOTES or {}
local NOTES = {
    -- Lunar Festival
    [913] = "Honor the elders of every region, plus Lunar Festival Finery, Elune's Blessing, both firework achievements. Elders give a Coin of Ancestry each.",
    [911] = "Elders across Kalimdor: speak to each one. Zidormi in Darkshore and Silithus shows the old zones where some of them stand.",
    [912] = "Elders across the Eastern Kingdoms. Zidormi in Tirisfal Glades and the Blasted Lands shows the old zones.",
    [910] = "Elders inside dungeons, usually near a boss room. Most need the old version of the dungeon via its normal entrance.",
    [626] = "Buy any festive dress or pant suit from Valadar Starsong in Nighthaven (5 coins).",
    [937] = "Defeat Omen by Lake Elune'ara and stand near his body for the blessing.",
    -- Love is in the Air
    [1693] = "Ten achievements; the slow ones are the random rose bouquet drops and Fistful of Love.",
    [1188] = "Silver Shafted Arrows on 10 different players. It fails on someone with a pet already out.",
    [1704] = "Love Fool from the gala novelty vendor; /pity it in each of the five listed places.",
    -- Noblegarden
    [2798] = "The eight Noblegarden achievements. Farm eggs first: they can contain the outfit you need.",
    [2576] = "You wear the White Tuxedo Shirt and Black Tuxedo Pants, the other player the Elegant Dress; you /kiss them.",
    -- Children's Week
    [1793] = "Five orphan achievements; keep the orphan summoned for every one of them.",
    -- Midsummer
    [1038] = "The Fires of Azeroth, Desecration of the Horde, King of the Fire Festival, Ice the Frost Lord, Burning Hot Pole Dance and Torch Juggler.",
    [1039] = "The Fires of Azeroth, Desecration of the Alliance, King of the Fire Festival, Ice the Frost Lord, Burning Hot Pole Dance and Torch Juggler.",
    [1145] = "Click the flame in each enemy capital (the quest starts from the flame), then turn in A Thief's Reward at your festival fire.",
    -- Brewfest
    [1683] = "Brewfest Diet, Direbrewfest, the Wolpertinger, Brew of the Month and a Brewfest mount (or Brewfest Hops on your own).",
    [1936] = "European realms can't do the Wolpertinger quest: buy Wolpertinger's Tankard from the pet vendor for 200 tokens.",
    -- Hallow's End
    [1656] = "Eleven achievements. Out With It, Trick or Treat and the Tooth Pick are quick; the Masquerade wands and Check Your Head need other players.",
    [283] = "Hallowed Wands from the wand vendor; other players can wand you. The Random wand doesn't count.",
    [291] = "Weighted Jack-o'-Lanterns come from the Horseman's loot and the village fire quest's gift.",
    -- Pilgrim's Bounty
    [3478] = "Nine achievements; plan Terokkar Turkey Time and the Turkinator, the rest come with the dailies.",
    -- Winter Veil
    [1691] = "Eleven achievements; the presents can only be opened from 25 December.",
    [277] = "Hat from holiday boss drops or the auction house, chest from tailoring, boots from leatherworking. The fruitcake comes in the mail after the Greench.",
    -- Darkmoon Faire
    [6020] = "Play five of the games: cannon, ring toss, Whack-a-Gnoll, shooting gallery and tonks.",
    [6332] = "The Darkmoon Rabbit is a rare in the cave south-east of the Faire.",
}
for id, text in pairs(NOTES) do
    if ns.ACH_NOTES[id] == nil then ns.ACH_NOTES[id] = text end
end

-- Criteria the generated data can't place (Midnight's candy buckets): the inn of each.
ns.CRIT_NOTES = ns.CRIT_NOTES or {}
local BUCKET = "The candy bucket is inside the inn."
ns.CRIT_NOTES[63400] = {
    -- checked 2026-10-22 against an independent per-bucket position list and players' reports
    ["Eversong Woods, Silvermoon"]       = { t = BUCKET, at = { { 2393, 55.82, 69.8 } } },
    ["Eversong Woods, Arcantina"]        = { t = "The candy bucket is in the Arcantina; the arrow points at its door in Silvermoon City.", at = { { 2393, 56.46, 70.86 } } },
    ["Eversong Woods, Tranquiillien"]    = { t = BUCKET, at = { { 2395, 48.98, 68.53 } } },
    ["Eversong Woods, Fairbreeze Village"] = { t = BUCKET, at = { { 2395, 46.42, 46.06 } } },
    ["Zul'Aman, Anami'Zar"]              = { t = BUCKET, at = { { 2437, 45.31, 65.14 } } },
    ["Zul'Aman, Witherbark Bluffs"]      = { t = BUCKET, at = { { 2437, 36.88, 23.43 } } },
    ["Zul'Aman, Camp Stonewash"]         = { t = BUCKET, at = { { 2437, 46.57, 25.85 } } },
    ["Harandar, The Den"]                = { t = "The candy bucket is inside the Den.", at = { { 2413, 51.2, 53.2 }, { 2576, 24.82, 63.82 } } },
    ["Harandar, Har'athir"]              = { t = BUCKET, at = { { 2413, 69.04, 51.7 } } },
    ["Harandar, Har'alnor"]              = { t = BUCKET, at = { { 2413, 30.92, 65.03 } } },
    ["Harandar, Har'kuai"]               = { t = BUCKET, at = { { 2413, 66.15, 24.5 } } },
    ["Harandar, Har'mara"]               = { t = BUCKET, at = { { 2413, 35.07, 22.8 } } },
    ["Voidstorm, Locus Point"]           = { t = BUCKET, at = { { 2405, 41.74, 74.62 } } },
    ["Voidstorm, Slayer's Rise"]         = { t = "Alliance: the bucket is at Grief Spire. Horde: at Hate Spire.", at = { { 2405, 63.4, 40.2 }, { 2405, 36.8, 29.4 } } },
    ["Voidstorm, The Ingress"]           = { t = BUCKET, at = { { 2405, 35.67, 58.6 } } },
}

-- Patch 12.1.5 holiday achievements the generated list (Data/Events.lua) doesn't have yet: the neighborhood candy
-- quests and ghost hunt of Hallow's End (guides below) and the tree defense of Winter Veil (coming soon,
-- Data/Research.lua, until players have done it).
for _, e in ipairs({
    { "hallows", 62500, "Sweet Tooth (meta)" }, { "hallows", 64160, "Sweet Tooth (meta)" },
    { "hallows", 64161, "Sweet Tooth (meta)" }, { "hallows", 64162, "Sweet Tooth (meta)" },
    { "hallows", 62501, "More achievements" }, { "veil", 62502, "More achievements" },
}) do
    local list = ns.EVENT_ACHS and ns.EVENT_ACHS[e[1]]
    if list then table.insert(list, { e[2], 0, e[3] }) end
end

-- Hallow's End drops the generated list (Data/Events.lua) is missing: the 2025 Headless Horseman rewards. All come from
-- the Loot-Filled Pumpkin he gives in the holiday dungeon (checked 2026-10-18 against the holiday guide).
do
    local HORSEMAN = 207438
    local DAILY = "Can come from the Headless Horseman's Loot-Filled Pumpkin in the holiday dungeon, only on your warband's "
        .. "first kill of the day; the chance grows each new day you beat him."
    local GHOULISH = "The Headless Horseman gives one piece of the Horseman's Ghoulish Collection you don't have yet each day, "
        .. "until you have all nine."
    local list = ns.EVENT_ITEMS and ns.EVENT_ITEMS.hallows
    if list then
        local have = {}
        for _, e in ipairs(list) do have[e.i] = true end
        local add = { { 247721, DAILY }, { 211271, DAILY } }
        for _, id in ipairs({ 247964, 247965, 247966, 247967, 247968, 247969, 247971, 247972, 250708 }) do
            add[#add + 1] = { id, GHOULISH }
        end
        for _, a in ipairs(add) do
            if not have[a[1]] then list[#list + 1] = { i = a[1], d = { HORSEMAN }, t = a[2] } end
        end
    end
end

-- Hallow's End guides, checked 2026-10-22 against the achievement and quest data and players' reports from this
-- year's event. The neighborhood quests (patch 12.1.5) start next to each other in your faction's neighborhood:
-- Founder's Point for the Alliance, Razorwind Shores for the Horde.
do
    local FOUNDERS, RAZORWIND, ELWYNN, TIRISFAL = 2352, 2351, 37, 18
    local YIN = "the Sugar Run quest from Yin Shuilan"
    -- the three candy quests of one neighborhood theme
    local function candy(theme, picks, extra)
        local steps = {
            { side = "Alliance", t = "Take " .. YIN .. " in Founder's Point. She offers it only on days your neighborhood's candy portal goes to " .. theme .. ".", at = { FOUNDERS, 53.8, 33.8 } },
            { side = "Horde", t = "Take " .. YIN .. " in Razorwind Shores. She offers it only on days your neighborhood's candy portal goes to " .. theme .. ".", at = { RAZORWIND, 51.8, 54.0 } },
            { t = "Take the portal next to her to " .. theme .. " and talk to Nomi. Pick one candy (one a day per character): " .. picks },
            { t = "Gather what the candy needs, bring it to Nomi, then take the finished candy back to the Wickerman Pinata in the neighborhood." },
        }
        local tips = {
            "Each neighborhood rolls its theme (Drustvar, Duskwood or Felwood) at random each day; the same one can come up several days in a row.",
            "Three characters can finish all three candies in one day, each picking a different one.",
            "Any neighborhood counts: if yours has the wrong theme, open the House Finder and visit another neighborhood that has the one you need.",
            "The portal back always takes you to your own faction's neighborhood; the candy still counts there.",
            "If the Wickerman Pinata is missing, visit an empty plot in another neighborhood with the House Finder and hand the candy in there.",
        }
        for _, x in ipairs(extra or {}) do tips[#tips + 1] = x end
        return steps, tips
    end
    local G = {}
    G[64162] = { candy("Drustvar", "Bewitched Berry Bites (15 Bewitched Berries from the thorny rose bushes), Witchbane Truffles (use the whistle and Arfus sniffs out truffles) or Hexed Honeycombs (8 Honeycombs).",
        { "Turn on object highlighting in the game's options to spot the berry bushes." }) }
    G[64160] = { candy("Duskwood", "Blighted Core Caramels (10 Sugar Beets), Twisted Vine Licorice (8 Twisted Vines) or Howling Honey Drops (8 Honey Drops).",
        { "Sugar Beets aren't always lit up: watch the ground for things the hand cursor shows on." }) }
    G[64161] = { candy("Felwood", "Blighted Bloom Bites (10 Blighted Blooms), Rotleaf Wafers (5 Rotleaves: the orange leaf piles on the ground, not the bushes) or Felroot Crunch (8 Soft Roots).",
        { "If Nomi won't take the finished quest, log out and back in." }) }
    for id, g in pairs(G) do ns.ACH_STEPS[id] = g[1]; ns.ACH_NOTES[id] = g[2] end
    ns.ACH_NOTES[62500] = "Finish the Drustvar, Duskwood and Felwood candy achievements (expand it: each has its own guide). "
        .. "The neighborhood's candy theme changes at random each day, so check other neighborhoods with the House Finder."
    ns.ACH_STEPS[62501] = {
        { side = "Alliance", t = "Take Specter Inspector from Alaric Duskwick in Founder's Point.", at = { FOUNDERS, 54.0, 33.8 } },
        { side = "Horde", t = "Take Specter Inspector from Nargok Ghostcleaver in Razorwind Shores.", at = { RAZORWIND, 51.6, 54.2 } },
        { t = "Use the Ghost Gear, then find the Hallow Drifter ghosts around the neighborhood (they stand in a glowing circle). Stand in the circle, press the extra action button and chase the ghost." },
        { t = "Catch 10 ghosts before you hand in: the quest only asks for 5, but the achievement needs 10 in one go. A buff counts them." },
    }
    ns.ACH_NOTES[62501] = {
        "Already handed in at 5? Click the Ghost Gear on the ground next to the quest giver and catch the rest; you can stop and come back later.",
        "Don't use the broom: it belongs to a different quest.",
        "A macro with /tar Hallow Drifter and /ping [@target] helps you spot the ghosts.",
    }
    -- masks: 24 for the achievement, any one for The Mask Task
    local MASKS = "Masks cost 2 Tricky Treats each from the mask vendor: Spanky outside Stormwind's gate, Farina at the Undercity entrance. They also drop from treat bags and Loot-Filled Pumpkins."
    ns.ACH_STEPS[284] = {
        { side = "Alliance", t = "Buy the masks you're missing from Spanky by Stormwind's gate, 2 Tricky Treats each.", at = { ELWYNN, 31.8, 50.0 } },
        { side = "Horde", t = "Buy the masks you're missing from Farina at the Undercity entrance, 2 Tricky Treats each.", at = { TIRISFAL, 62.2, 66.4 } },
        { t = "You need all 24: male and female masks of every race the vendor sells. Expand the achievement to see which ones you still need." },
    }
    ns.ACH_NOTES[284] = { "A mask counts once you've had it in your bags; you can use it or throw it away and keep the credit.", "Not part of Hallowed Be Thy Name." }
    ns.ACH_STEPS[979] = {
        { side = "Alliance", t = "Buy any mask from Spanky by Stormwind's gate for 2 Tricky Treats.", at = { ELWYNN, 31.8, 50.0 } },
        { side = "Horde", t = "Buy any mask from Farina at the Undercity entrance for 2 Tricky Treats.", at = { TIRISFAL, 62.2, 66.4 } },
    }
    ns.ACH_NOTES[979] = { MASKS }
    -- notes for the rest (their how-to also sits in the holiday's steps above)
    local HAL = {
        [10365] = "Visit your level 3 garrison in Draenor during Hallow's End: Pepe in his scarecrow costume sits on a gravestone in the garrison graveyard (Alliance, south-west corner) or by the outhouse at the back (Horde). Click him. He can't be targeted.",
        [18962] = "Defeat the Headless Horseman: queue for the holiday dungeon in the Dungeon Finder. Any kill during the event counts.",
        [18959] = "Defeat the Headless Horseman: queue for the holiday dungeon in the Dungeon Finder. Your first kill each day gives the Loot-Filled Pumpkin.",
        [18960] = "In the Horseman's holiday dungeon, talk to the wicker men before the fight to add their curses, then win.",
        [972] = "Click a candy bucket in any inn.",
        [981] = "Use a Tooth Pick. The candy vendor sells them, and treat bags can have them.",
        [288] = "Eat Tricky Treats until you get the Upset Tummy; it usually takes fewer than five.",
        [289] = "In Goldshire, Kharanos or Azure Watch (Razor Hill, Brill or Falconwing Square for the Horde), do the water bucket practice quest, then help put out every fire when the Headless Horseman attacks the village (on the half hour).",
        [292] = "Get the Sinister Squashling pet and the Hallowed Helm: from the Horseman's loot or 150 Tricky Treats each from the candy vendor. If you own the helm's look but haven't looted it on this character, buying it counts; you can sell it back for the treats.",
        [1261] = "Get 10 honorable kills while the G.N.E.R.D. buff is on you. The G.N.E.R.D.S. candy comes from the candy buckets in inns. The buff ends when you die; a battleground is the easiest place.",
        [971] = "Finish the candy bucket achievements of Eastern Kingdoms, Kalimdor and Outland (expand it: each one lists its inns).",
        [2144] = "The yearly holiday meta: finish the main achievement of every holiday (Lunar Festival, Love is in the Air, Noblegarden, Children's Week, Midsummer, Brewfest, Hallow's End, Pilgrim's Bounty and Winter Veil). It gives the Violet Proto-Drake.",
    }
    for id, text in pairs(HAL) do ns.ACH_NOTES[id] = text end
end

-- A holiday step that names an achievement and says how to do it is that achievement's note too, unless it
-- has its own (so the achievement rows aren't marked coming soon when the holiday guide covers them).
for _, def in ipairs(ns.EVENT_DEFS) do
    for _, st in ipairs(def.steps or {}) do
        local a = st.ach
        if a and st.note then
            if type(a) == "table" then a = { a.A, a.H } else a = { a } end
            for _, id in ipairs(a) do
                if id and ns.ACH_NOTES[id] == nil and not ns.ACH_STEPS[id] then ns.ACH_NOTES[id] = st.note end
            end
        end
    end
end

-- Candy bucket spots the generated data has wrong: stray spots far from the inn, which the arrow could pick as
-- "nearest" (Grove of Aessina pointed into the middle of Mount Hyjal). Checked 2026-10-22 against an
-- independent per-bucket position list; every bucket in the generated data was compared and these 27 replaced.
do
    local FIX = {
    [12336] = { { 37, 24.89, 40.13 }, { 84, 60.51, 75.32 } },
    [12340] = { { 52, 52.91, 53.74 } },
    [12366] = { { 85, 53.8, 78.8 } },
    [12376] = { { 25, 57.85, 47.27 } },
    [12382] = { { 50, 37.38, 51.78 } },
    [12384] = { { 51, 46.87, 56.92 } },
    [12396] = { { 10, 67.34, 74.66 } },
    [12397] = { { 210, 40.91, 73.72 } },
    [12400] = { { 83, 59.83, 51.22 } },
    [12402] = { { 23, 75.57, 52.3 } },
    [13448] = { { 120, 28.7, 74.3 } },
    [13472] = { { 127, 27.29, 41.36 }, { 125, 42.3, 56.8 }, { 126, 38.22, 59.59 } },
    [28967] = { { 51, 71.65, 14.1 } },
    [28999] = { { 198, 63.05, 24.15 } },
    [29000] = { { 198, 18.62, 37.32 } },
    [29016] = { { 249, 26.58, 7.24 } },
    [29017] = { { 249, 54.68, 33.01 } },
    [32020] = { { 418, 28.25, 50.74 } },
    [32022] = { { 391, 60.3, 66.3 }, { 392, 58.84, 78.32 }, { 390, 61.98, 16.26 } },
    [32034] = { { 418, 51.4, 77.29 } },
    [32036] = { { 418, 75.9, 6.87 } },
    [32047] = { { 418, 61.03, 25.14 } },
    [84568] = { { 2214, 55.29, 64.09 } },
    [84569] = { { 2214, 43.73, 32.09 } },
    [84570] = { { 2214, 59.27, 78.97 } },
    [84571] = { { 2214, 57.7, 46.25 } },
    [84577] = { { 2255, 51.4, 78.4 }, { 2216, 57.45, 38.5 } },
    }
    for _, a in ipairs({ 963, 965, 966, 967, 968, 969, 5835, 5836, 5837, 5838, 7601, 7602, 18360, 40862 }) do
        local g = ns.CRIT_GUIDE and ns.CRIT_GUIDE[a]
        if g then
            for q, spots in pairs(FIX) do
                if g["27:" .. q] then g["27:" .. q] = { at = spots } end
            end
        end
    end
end

-- Candy buckets hidden by phasing: since later expansions changed these zones, the bucket only shows in the zone's
-- old version (Zidormi switches it) or after a storyline. Checked 2026-10-22 against players' reports on every
-- bucket; only consistent, well-rated reports are used.
do
    local function zidormi(where, x, y, ago)
        return "Can't see the bucket? Talk to Zidormi in " .. where .. " (" .. x .. ", " .. y .. ") and ask to see the zone "
            .. ago .. "; the bucket only shows in the old version. Talk to her again afterwards to come back."
    end
    local ARATHI = zidormi("the south of Arathi Highlands", "38.2", "90.0", "before the Battle for Azeroth")
    local BLASTED = zidormi("the north of the Blasted Lands", "48.2", "7.2", "before the Iron Horde invasion")
    local ULDUM = zidormi("Ramkahen", "56.0", "35.2", "as it was during the Cataclysm")
    local PHASE = {
        [12380] = ARATHI, [28954] = ARATHI,
        [28959] = BLASTED, [28960] = BLASTED, [28961] = BLASTED,
        [29016] = ULDUM, [29017] = ULDUM,
        [12401] = zidormi("the north-east of Silithus", "78.8", "22.0", "before the Wound"),
        [32052] = zidormi("the east of the Vale of Eternal Blossoms", "80.5", "32.0", "before the assault") .. " The bucket is behind the innkeeper.",
        [32022] = "The bucket is upstairs in the inn.",
        [12367] = "If Thunder Bluff is under attack by shadowy invaders (the Highmountain Tauren unlock), the bucket is hidden until you finish that event.",
        [12373] = "Hidden while you are partway through the blood elf storyline in Quel'Thalas; finish it to see the bucket.",
        [13462] = "Hidden while you are partway through the Storm Peaks storyline at Bouldercrag's Refuge; finish that chain to see it.",
        [29019] = "Hidden until you have finished the Deepholm storyline.",
        [28974] = "Hidden for some Horde characters until the Twilight Highlands storyline is done.",
        [28981] = "The Deepmist Grotto inn only appears after enough of the Vashj'ir storyline.",
    }
    for _, a in ipairs({ 963, 965, 966, 967, 968, 969, 5835, 5836, 5837, 5838, 7601, 7602 }) do
        local g = ns.CRIT_GUIDE and ns.CRIT_GUIDE[a]
        if g then
            for q, text in pairs(PHASE) do
                local e = g["27:" .. q]
                if e then e.t = "The candy bucket is inside the inn. " .. text end
            end
        end
    end
end

-- Guides for the remaining holiday achievements, checked 2026-10-22 against each achievement's data and players'
-- reports (newest ones where the game has changed). Darkmoon Island is map 407.
do
    local DMF, ELWYNN, DUROTAR, SMV_DRAENOR, VALE, SURAMAR, TANAAN = 407, 37, 1, 539, 390, 680, 534
    local S, N = ns.ACH_STEPS, ns.ACH_NOTES

    ---------------- Darkmoon Faire: the races ----------------
    local RACE = "The Real Race: Malle Earnhard at the race start, south of the Faire, gives it once a day. Stand on the mount you want at the start, then run through the start banner."
    local BIG = "The Real Big Race: Patti Earnhard next to her sister gives it once a day; More Big Racing! from her repeats it with no reward, for practice. Stand on the mount you want at the start."
    local TOLLS = "Tolls are the race clock: fewer is faster. Each tier of a mount is its own achievement, so a Gold run also earns Silver and Bronze if their tolls are higher."
    local function race(id, big, mount, tolls, tip)
        S[id] = { { t = big and BIG or RACE, at = big and { DMF, 53.2, 87.8 } or { DMF, 49.0, 88.0 } },
                  { t = string.format("Finish on the %s within %d tolls.", mount, tolls) } }
        N[id] = { TOLLS, tip }
    end
    local STRIDER = "The Racing Strider is the plain mount you get by crossing the start without picking one. Players get the fastest runs by ignoring the banners and grabbing the speed boots."
    local ROCKET = "Rocketeer: right after the start gate, take a hard left; players say this one trick decides the Gold run."
    local POWER = "Powermonger: Battery stores the next power-up you hit; use it again to spend it when it helps most."
    local WANDER = "Wanderluster: its glider carries you over gaps; players pick up the Darkmoon Zeppelin's speed buff first."
    local BIGTIP = "On the way to the finish, don't fly over any of the Faire's game areas: you get slammed to the ground."
    race(9756, false, "Racing Strider", 25, STRIDER); race(9759, false, "Racing Strider", 20, STRIDER)
    race(9760, false, "Racing Strider", 15, STRIDER); race(9761, false, "Racing Strider", 11, STRIDER)
    race(9770, false, "Rocketeer", 25, ROCKET); race(9769, false, "Rocketeer", 20, ROCKET)
    race(9766, false, "Rocketeer", 15, ROCKET); race(9764, false, "Rocketeer", 11, ROCKET)
    race(9780, false, "Powermonger", 25, POWER); race(9781, false, "Powermonger", 20, POWER)
    race(9783, false, "Powermonger", 15, POWER); race(9785, false, "Powermonger", 11, POWER)
    race(9786, false, "Wanderluster", 25, WANDER); race(9787, false, "Wanderluster", 20, WANDER)
    race(9790, false, "Wanderluster", 15, WANDER); race(9792, false, "Wanderluster", 11, WANDER)
    race(9793, true, "Racing Strider", 40, BIGTIP); race(9794, true, "Racing Strider", 35, BIGTIP)
    race(9795, true, "Racing Strider", 30, "A friend standing on the cliff gives your strider's third ability a target to jump to.")
    race(9797, true, "Racing Strider", 25, BIGTIP); race(9799, true, "Racing Strider", 20, "The hardest race; players manage it solo, but expect many tries.")
    race(9800, true, "Rocketeer", 40, BIGTIP); race(9801, true, "Rocketeer", 30, BIGTIP)
    race(9803, true, "Rocketeer", 25, BIGTIP); race(9805, true, "Rocketeer", 20, "The springs and the rockets swap places along this track. " .. BIGTIP)
    race(9812, true, "Powermonger", 40, BIGTIP); race(9813, true, "Powermonger", 30, BIGTIP)
    race(9815, true, "Powermonger", 25, BIGTIP); race(9817, true, "Powermonger", 20, "Like the Rocketeer, the Powermonger can head straight for the first checkpoint. " .. BIGTIP)
    race(9806, true, "Wanderluster", 40, BIGTIP); race(9807, true, "Wanderluster", 30, BIGTIP)
    race(9809, true, "Wanderluster", 25, BIGTIP); race(9811, true, "Wanderluster", 20, BIGTIP)
    S[9755] = { { t = "Take Welcome to the Darkmoon Races (or The Real Race) from Malle Earnhard and run it on the plain Racing Strider: cross the start without standing on any other mount.", at = { DMF, 49.0, 88.0 } } }
    N[9755] = { "Players report it may not award if you finish on a different mount; do it on the plain strider." }
    S[9819] = { { t = "Stand on the Wanderluster at the race start, then glide for more than 10 seconds. Players jump off the hill where you arrive on the island; no race needed.", at = { DMF, 49.0, 88.0 } } }

    ---------------- Darkmoon Faire: games ----------------
    S[9250] = { { t = "Talk to Ziggie Sparks on the main path, next to the fireworks vendor, for Firebird's Challenge.", at = { DMF, 48.4, 71.4 } },
                { t = "Fly through 10 Blazing Rings in one flight." } }
    S[9251] = { S[9250][1], { t = "Fly through 25 Blazing Rings in one flight." } }
    S[9252] = { S[9250][1], { t = "Fly through 50 Blazing Rings in one flight. There are a few more than 50 around the island: plan a loop that takes them all." } }
    N[9252] = { "Players share a route that circles the island from the south up the east side and back; going fast matters more than any single ring." }
    S[9885] = { { t = "Talk to Finlay Coolshot for the Tonk Challenge and score 45 hits in one go.", at = { DMF, 50.2, 65.6 } } }
    N[9885] = { "Use the speed boost whenever it's ready and only shoot targets.", "Recent players report it's much easier than it used to be: more targets appear." }
    S[9983] = { { t = "Talk to Mola for Whack-a-Gnoll and score 45 points in one go.", at = { DMF, 53.0, 53.8 } } }
    N[9983] = { "Hogger is worth the most: always hit him first.", "Don't hit the gingerbread dolls: they stun you.", "Stay on the centre barrels and turn the camera to look down on them." }
    S[9894] = { { t = "Talk to Jessica Rogers for Ring Toss and land 10 rings on Dubenko the turtle in one go.", at = { DMF, 51.2, 77.4 } } }
    N[9894] = { "The ring takes a moment to land: throw just as the turtle turns back toward the middle." }
    S[6022] = { { t = "Talk to Rinling at the Shooting Gallery and hit a target the moment it lights up for a Quick Shot.", at = { DMF, 49.0, 60.0 } } }
    N[6022] = { "Keep aiming at one target and shoot when the green arrow lights over it." }
    S[6021] = { { t = "Talk to Maxima Blastenheimer, get shot from the cannon and land in the centre of the target in the water.", at = { DMF, 52.0, 56.4 } } }
    N[6021] = { "You don't need the daily quest.", "Players report pressing jump repeatedly as you hit the water makes a centre hit count." }

    ---------------- Darkmoon Faire: the dance game ----------------
    local SIMON = { t = "Talk to Simon Sezdans in front of the South Pavilion for Dance Dance Darkmoon and pick a difficulty.", at = { DMF, 51.2, 74.0 } }
    local DANCE = { "Repeat the dance your opponent shows: three moves on the easiest setting, four on medium, five on the hardest.",
                    "Each difficulty counts on its own: perfect scores on the hardest don't count for the easier ones.",
                    "A dance the crowd boos at the end doesn't count." }
    local function dance(id, text) S[id] = { SIMON, { t = text } }; N[id] = DANCE end
    dance(15212, "Finish one dance.")
    dance(15213, "Finish 30 dances (any difficulty, without being booed).")
    dance(15222, "Get a perfect score on the easiest difficulty.")
    dance(15223, "Get a perfect score on the easiest difficulty 10 times.")
    dance(15214, "Get a perfect score on medium.")
    dance(15215, "Get a perfect score on medium 10 times.")
    dance(15216, "Get a perfect score on the hardest difficulty.")
    dance(15217, "Get a perfect score on the hardest difficulty 10 times.")
    N[15221] = "Every dance achievement of the Darkmoon Faire (expand it: each one has its guide). It gives the Dance Dance Darkmoon reward."

    ---------------- Darkmoon Faire: the Blight Boar concert ----------------
    local BOAR = { t = "Go to the Cauldron of Rock, the stage north-west of the Faire. The Blight Boar concert starts every hour on the half hour.", at = { DMF, 35.2, 39.6 } }
    local IMMUNE = "Immunities such as Divine Shield, Ice Block or Cloak of Shadows remove your fan buff and lose you the credit."
    S[11918] = { BOAR, { t = "Stay until the very end: after the Death Metal Knight dies, keep catching the bolts of light until the band disappears." } }
    N[11918] = { IMMUNE }
    S[11921] = { BOAR, { t = "Kill the ghouls before any of them reaches Devlynn Styx on the stage." } }
    N[11921] = { "Hard alone: players bring a group of about five.", IMMUNE }
    S[11920] = { BOAR, { t = "Each of at least four players present has to earn a band role in the same concert (they don't need to be in your group)." } }
    N[11920] = { "Roles come from how you play the concert: avoid the banshee walls and catch the bolts of light.", IMMUNE }
    S[11919] = { BOAR, { t = "Earn each of the band's roles once; you keep one role from each concert, so it takes several." } }
    N[11919] = { "The best player for each style gets that role: no banshee hits and every bolt of light caught is the best one.", IMMUNE }

    ---------------- Darkmoon Faire: the Deathmatch and artifacts ----------------
    local PIT = { t = "Go to the Deathmatch pit by Korgol Crushskull. Every three hours (server time) a chest appears in the pit; whoever opens it gets a Pit Fighter trinket.", at = { DMF, 47.2, 79.6 } }
    S[6023] = { PIT, { t = "Open the chest and loot the Pit Fighter trinket." } }
    N[6023] = { "Turn off auto loot and take only the trinket: the chest stays up and others can loot one too, so a group can share it." }
    S[6024] = { PIT, { t = "Loot the trinket 12 times and turn them in for the Master Pit Fighter." } }
    N[6024] = { "The trinkets don't stack: keep 12 bag slots free.", "Turn off auto loot and take only the trinket so the chest stays up for others." }
    N[6027] = { "Keep the Darkmoon Adventurer's Guide in your bags: the five dungeon artifacts drop in old dungeons only while you carry it. Turn each one in on the island.",
                "Players report three of them don't drop for max-level characters any more; they're sold on the auction house." }
    N[6028] = { "The three battleground artifacts used to come from looting players in battlegrounds.",
                "Players report they can't be looted that way since Mists of Pandaria; check the auction house." }

    ---------------- Darkmoon Faire: reputation ----------------
    N[2336] = { "Six reputations: Honored with the Bloodsail Buccaneers, Exalted with Booty Bay, Everlook, Gadgetzan, Ratchet, the Darkmoon Faire and Ravenholdt.",
                "Gaining Bloodsail reputation lowers the four goblin towns, so players finish the goblins last, or keep going back to them.",
                "Darkmoon Faire reputation comes from the Faire's quests every month; Ravenholdt from Syndicate kills and, for rogues, lockbox junkboxes.",
                "One of the longest reputation grinds in the game: hours of kills for each faction." }

    ---------------- Lunar Festival ----------------
    local COINS = "Speak to Lunar Festival elders: each one gives a Coin of Ancestry once per festival. The elder achievements in this list point at every elder."
    N[605] = COINS; N[606] = COINS; N[607] = COINS; N[608] = COINS
    N[609] = { COINS, "There are more than 50 elders in the world, so one festival is enough if you visit them all." }

    ---------------- Love is in the Air ----------------
    N[1701] = { "Buy a Bag of Heart Candies (2 Love Tokens) from a Lovely Merchant in a capital and eat them: you need all eight messages.",
                "The messages are random and a bag has 10, so it usually takes a few bags. Candies traded or mailed to you don't count." }
    N[1702] = "Buy a Box of Chocolates (10 Love Tokens) from a Lovely Merchant and eat the four kinds: Buttermilk Delight, Sweet Surprise, Dark Desire and Very Berry Cream. One box usually has them all."
    local PRISM = { "You need the Manufactured Love Prism (40 Love Tokens). Others use their prism on you; each Love Ray lasts 5 minutes and the prism has a 30 second cooldown.",
                    "Feign Death, Ice Block and changing zones remove the rays: stay put and use no immunities." }
    N[9392] = { "Have 10 Love Rays on you at once. Two players with prisms can manage it.", PRISM[1], PRISM[2] }
    N[9393] = { "Have 25 Love Rays on you at once: bring a few friends with prisms.", PRISM[1], PRISM[2] }
    N[9394] = { "Have 50 Love Rays on you at once: a group with prisms takes turns on one player.", PRISM[1], PRISM[2] }
    N[9389] = "Queue for the Crown Chemical Co. holiday dungeon: Apothecary Hummel drops one holiday necklace for the group. Use it to earn the achievement; it can be traded to the next player in your group."
    N[1694] = "Buy Lovely Dress Boxes from a Lovely Merchant and open them until one has the Lovely Black Dress. A dress bought from another player doesn't count. Not part of the meta."
    N[1700] = "Buy a Truesilver Shafted Arrow (40 Love Tokens) from a Lovely Merchant: having it in your bags counts. You can sell it back to the vendor for your tokens."
    S[19400] = {
        { side = "Alliance", t = "Donate to Galvus Ironhammer for the Gala of Gifts, outside Stormwind's gate.", at = { ELWYNN, 32.0, 49.7 } },
        { side = "Horde", t = "Donate to Torgando Featherhoof for the Gala of Gifts, outside Orgrimmar's gate.", at = { DUROTAR, 42.3, 18.2 } },
        { t = "Donate 50,000 gold in total. You can donate once a day." },
    }

    ---------------- Noblegarden ----------------
    N[2417] = "Eat 25 Noblegarden Chocolates. They come from the Brightly Colored Eggs around the starting villages."
    N[249] = "Find the Elegant Dress in a Brightly Colored Egg. Buying it doesn't count. Players report about a 0.5% chance per egg. Not part of the meta."
    N[248] = "Find the White Tuxedo Shirt and the Black Tuxedo Pants in Brightly Colored Eggs. Buying them doesn't count. Each is rare (players report about 0.5% per egg). Not part of the meta."

    ---------------- Midsummer (Horde: put out the Alliance's bonfires) ----------------
    S[11277] = { { t = "Desecrate the Alliance bonfire in Embaari Village, Shadowmoon Valley (Draenor).", at = { SMV_DRAENOR, 42.0, 35.0 } } }
    S[8043] = { { t = "Desecrate the Alliance bonfire in front of Mogu'shan Palace in the Vale of Eternal Blossoms.", at = { VALE, 79.9, 37.2 } } }
    N[8043] = { "Can't see the bonfire? Talk to Zidormi on the upper level above the dungeon (79.9, 31.4) to see the Vale before the assault.", "Desecrating a bonfire flags you for PvP." }
    S[11279] = { { t = "Desecrate the Alliance bonfire on the western edge of Suramar, north-west of Felsoul Hold.", at = { SURAMAR, 22.85, 58.3 } } }

    ---------------- Brewfest ----------------
    N[1183] = { "Try 12 beers of the Brew of the Month club. Join with the club form (200 Brewfest Prize Tokens) and a new beer is mailed to you each month.",
                "Players report the brew vendor in Orgrimmar or Ironforge also sells them if the mail stops." }

    ---------------- Day of the Dead ----------------
    local CONTENDER = { "Buy a contender's costume from Chapman, the Day of the Dead vendor, and use it: you get an extra action to fight other players in a costume.",
                        "Only killing blows on other costumed players count.",
                        "Players team up and duel each other in costume; that's the quickest way." }
    N[9427] = { "Defeat 20 contenders.", CONTENDER[1], CONTENDER[2], CONTENDER[3] }
    N[9428] = { "Defeat 50 contenders.", CONTENDER[1], CONTENDER[2], CONTENDER[3] }

    ---------------- Feast of Winter Veil ----------------
    N[279] = "Do the daily You're a Mean One... in Ironforge or Orgrimmar; its follow-up returns Smokywood Pastures' stolen treats and earns the achievement."
    N[5854] = { "Open the presents under your capital's tree on 25 December for the Gaudy Winter Veil Sweater (it holds the carol book).",
                "Use it in each enemy capital listed. You can enter most without fighting the guards." }
    N[4437] = { "The Red Rider Air Rifle from the 25 December presents. Shoot each listed enemy faction leader with it.",
                "It does a little damage, so the leader and the guards attack you: players strip their gear first and run." }
    N[1295] = { "Get a Crashin' Thrashin' Racer controller: Jepetto Joybuzz, the toy vendor in Northrend's Dalaran, sells the blue one, and Stolen Presents can have it. Summon the car and ram 25 other cars.",
                "Aim at a cluster of cars: every one you hit counts. Your car can jump to avoid being hit." }
    N[20511] = { "The Box of Puntables, a 25 December present (2024), sets down creatures you can punt. Punt 30.",
                 "Progress is shared by your warband: switch characters for another box while one waits on its cooldown.",
                 "Players report the creatures stand still on water, so one box is enough there." }
    N[10353] = { "Collect the five Iron Armada toys: two come from Winter Veil presents, three drop from rares in eastern Tanaan Jungle.",
                 "Smashum Grabb (87.5, 56.1), Drakum (83.9, 43.2) and Gondar (80.7, 56.1) in Tanaan Jungle; each has a chance at its toy." }
    N[15181] = "The Rockin' Rollin' Racer toy from the 25 December presents. Summon it and use Lightning Nitro while Rockin' Tunes plays (its third and fourth buttons together)."
    N[8699] = "Needs a second player: both of you need the Crashin' Thrashin' Flyer (a past Winter Veil present). Shoot down their flyer with yours."
end
