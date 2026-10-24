-- Completion: step-by-step guides for every holiday achievement, one holiday per block, written from each holiday's
-- full guide, the achievements' data and players' newest reports (own words). Loaded after EventGuides.lua: a
-- guide here replaces the shorter note there. Steps with side = "Alliance" or "Horde" only show for that faction.

local _, ns = ...
local S, N = ns.ACH_STEPS, ns.ACH_NOTES

-- map IDs
local ELWYNN, DUN_MOROGH, DARNASSUS, AZUREMYST, DARKSHORE = 37, 27, 89, 97, 62
local DUROTAR, THUNDER_BLUFF, EVERSONG_OLD, TIRISFAL, TEROKKAR = 1, 88, 94, 18, 108

-- Adds collectibles a holiday's generated list lacks: { itemID, how to get it }.
local function AddItems(key, list)
    local items = ns.EVENT_ITEMS and ns.EVENT_ITEMS[key]
    if not items then return end
    local have = {}
    for _, e in ipairs(items) do have[e.i] = e end
    for _, a in ipairs(list) do
        if have[a[1]] then have[a[1]].t = have[a[1]].t or a[2]
        else items[#items + 1] = { i = a[1], t = a[2] } end
    end
end

------------------------------------------------------------------------
-- Pilgrim's Bounty (checked 2026-10-22)
------------------------------------------------------------------------
do
    -- the bountiful tables at the capitals
    local T = {
        SW = { ELWYNN, 34.0, 51.5, "Stormwind: the table outside the city gate in Elwynn Forest" },
        IF = { DUN_MOROGH, 60.0, 34.2, "Ironforge: the table outside the gate in Dun Morogh" },
        DARN = { DARNASSUS, 61.6, 48.2, "Darnassus: the table in the city" },
        EXO = { AZUREMYST, 34.0, 45.0, "The Exodar: the table outside the entrance on Azuremyst Isle" },
        ORG = { DUROTAR, 46.2, 14.2, "Orgrimmar: the table outside the front gate in Durotar" },
        TB = { THUNDER_BLUFF, 30.0, 65.2, "Thunder Bluff: the table on the lower rise" },
        SMC = { EVERSONG_OLD, 55.4, 53.2, "Silvermoon City: the table outside the city in old Eversong Woods. Midnight rebuilt Silvermoon after the last Pilgrim's Bounty: if the table isn't there, talk to Zidormi at the Eastern Plaguelands border (53.8, 8.6) to see old Quel'Thalas" },
        BRILL = { TIRISFAL, 58.6, 51.4, "Undercity: use the table in Brill; players report the Ruins of Lordaeron table no longer counts" },
    }
    local function at(t, side, extra) return { side = side, t = t[4] .. "." .. (extra or ""), at = { t[1], t[2], t[3] } } end
    local ZID_TELDRASSIL = " Teldrassil burned in the Battle for Azeroth: talk to Zidormi in Darkshore (48.8, 24.5) first to see the old Darnassus."
    local ZID_TIRISFAL = " If it doesn't count, talk to Zidormi in Tirisfal Glades (69.4, 62.8) to see the zone before the Battle for Azeroth and sit again."
    local FEAST = "At each table, sit in all five chairs and eat five helpings of each dish until you get Spirit of Sharing."

    S[3556] = { at(T.SW), at(T.IF), at(T.DARN, nil, ZID_TELDRASSIL), at(T.EXO), { t = FEAST } }
    S[3557] = { at(T.ORG), at(T.TB), at(T.SMC), at(T.BRILL, nil, ZID_TIRISFAL), { t = FEAST } }
    N[3556] = { "Other players passing food to your chair speeds it up a lot.", "Only the capitals' tables count, not the small towns' ones." }
    N[3557] = N[3556]

    local CHEST = "Wear the Pilgrim's Dress, Robe or Attire (a daily quest reward; transmog doesn't count) and sit at the table."
    S[3580] = { { t = CHEST }, at(T.ORG), at(T.TB), at(T.SMC), at(T.BRILL, nil, ZID_TIRISFAL) }
    S[3581] = { { t = CHEST }, at(T.SW), at(T.IF), at(T.DARN, nil, ZID_TELDRASSIL), at(T.EXO, nil, " From the old Darnassus, players take the Exodar portal at the Rut'theran Village side.") }
    N[3580] = { "You only need to sit down, not eat.", "Sitting flags you for PvP and the guards are tough: go at a quiet hour, or bring friends." }
    N[3581] = N[3580]

    -- the dailies, at your faction's capitals
    S[3596] = {
        { t = "Caitrin Ironkettle outside Ironforge gives two of the dailies: Spice Bread Stuffing and Slow-Roasted Turkey.", at = { DUN_MOROGH, 60.0, 34.2 } },
        { t = "Ellen Moore and Jasper Moore by the Stormwind table give Cranberry Chutney and Candied Sweet Potato.", at = { ELWYNN, 33.8, 50.8 } },
        { t = "Mary Allerton at the Darnassus table gives Pumpkin Pie." .. ZID_TELDRASSIL, at = { DARNASSUS, 61.6, 46.8 } },
        { t = "Each one wants 20 of a dish. You can cook them or buy them; you don't need the cooking skill to turn them in." },
    }
    S[3597] = {
        { t = "Ondani Greatmill outside Orgrimmar gives two of the dailies: Spice Bread Stuffing and Slow-Roasted Turkey.", at = { DUROTAR, 46.4, 13.8 } },
        { t = "Mahara Goldwheat at the Thunder Bluff table gives Pumpkin Pie.", at = { THUNDER_BLUFF, 30.4, 69.0 } },
        { t = "Roberta Carter and William Mullins in the Ruins of Lordaeron give Cranberry Chutney and Candied Sweet Potato.", at = { TIRISFAL, 61.4, 67.4 } },
        { t = "Each one wants 20 of a dish. You can cook them or buy them; you don't need the cooking skill to turn them in." },
    }
    local DAILY = { "Each daily lets you pick a reward: take the five clothing pieces first (you need the hat and a chest for other achievements), then Turkey Shooters or the Pilgrim's Bounty satchel.",
                    "The satchel can hold the Silver-Plated Turkey Shooter toy, the Frightened Bush Chicken pet, the Fine Pilgrim's Hat and the four Bountiful Backpacks." }
    N[3596] = DAILY; N[3597] = DAILY

    local COOK = { t = "Buy the Bountiful Cookbook from a Pilgrim's Bounty vendor at a capital table and learn its five recipes. The cooking trainer there trains Classic cooking." }
    S[3576] = { COOK, { t = "Cook one of each dish: Spice Bread Stuffing (cooking 1), Pumpkin Pie (100), Cranberry Chutney (160), Candied Sweet Potato (220) and Slow-Roasted Turkey (280)." } }
    S[3577] = S[3576]
    N[3576] = { "The holiday's own recipes take Classic cooking from 1 to 300: cook them as you go.",
                "Spice Bread Stuffing needs Spice Bread, an ordinary recipe every cooking trainer teaches.",
                "Slow-Roasted Turkey needs Wild Turkey meat: kill Wild Turkeys in Elwynn Forest or Tirisfal Glades.",
                "Some ingredients are only sold at one capital's table (each capital's vendor sells its local crop)." }
    N[3577] = N[3576]

    S[3558] = { at(T.SW, "Alliance"), at(T.ORG, "Horde"), { t = "Sit in each of the five chairs in turn and use its pass button to pass the dish to another chair." } }
    N[3558] = { "You can pass to an empty chair: no other player needed.", "Players reported in 2025 that it sometimes didn't count; sit down again and pass once more." }
    S[3579] = { at(T.SW, "Alliance"), at(T.ORG, "Horde"), { t = "With another player at the table, keep passing your dish to them. Once they have as much as they can hold, the food bounces off their head." } }

    S[3578] = {
        { side = "Alliance", t = "Go to Elwynn Forest, where Wild Turkeys wander the fields during the holiday.", at = { ELWYNN, 42.0, 65.0 } },
        { side = "Horde", t = "Go to Tirisfal Glades, where Wild Turkeys wander the fields during the holiday.", at = { TIRISFAL, 55.0, 55.0 } },
        { t = "Kill 40 Wild Turkeys with no more than 30 seconds between kills. Every 10 kills the title over your head changes; at 40 you get Turkey Triumph." },
    }
    N[3578] = { "Make a /tar Wild Turkey macro, and use Track Beasts or Tracker Snacks if you have them.",
                "Use instant attacks: a long cast can let the 30 seconds run out.",
                "Turkeys you call with the Turkey Caller don't count. Go at a quiet hour: other players take the turkeys." }

    S[3559] = { { t = "Get Turkey Shooters (a daily quest reward, one use each) or the Silver-Plated Turkey Shooter toy from the Pilgrim's Bounty satchel, which you can use again and again." },
                { t = "Shoot a player rogue of each race listed in the achievement. They turn into a turkey." } }
    N[3559] = { "Use /who r-dwarf c-rogue (and so on for each race) to find the rogues you still need.",
                "A rogue sitting in a vehicle or a chair can't be shot." }

    S[3582] = { { t = "Wear the Pilgrim's Hat and the Pilgrim's Dress, Robe or Attire (daily quest rewards). Transmog doesn't count: they must be equipped." },
                { t = "Go to Sethekk Halls in Auchindoun, Terokkar Forest, and kill the last boss, Talon King Ikiss, while wearing them. Normal difficulty is fine." } }
    N[3582] = { "It works outside the holiday too, as long as you have the clothes.", "Forgot the hat? Talon King Ikiss can be killed again the next day." }

    AddItems("pilgrim", {
        { 46723, "A reward choice from the Pilgrim's Bounty dailies." },
        { 46800, "A reward choice from the Pilgrim's Bounty dailies." },
        { 44785, "A reward choice from the Pilgrim's Bounty dailies." },
        { 46824, "A reward choice from the Pilgrim's Bounty dailies." },
        { 44788, "A reward choice from the Pilgrim's Bounty dailies." },
        { 116401, "Can be in the Pilgrim's Bounty satchel, a reward choice from the dailies." },
        { 116403, "Can be in the Pilgrim's Bounty satchel, a reward choice from the dailies." },
        { 116400, "Can be in the Pilgrim's Bounty satchel, a reward choice from the dailies. Unlike the plain Turkey Shooter it can be used again and again." },
        { 44810, "The reward for the Pilgrim achievement (all of Pilgrim's Bounty)." },
        { 248716, "Can be in the Pilgrim's Bounty satchel, a reward choice from the dailies (new in 2025)." },
        { 248717, "Can be in the Pilgrim's Bounty satchel, a reward choice from the dailies (new in 2025)." },
        { 248718, "Can be in the Pilgrim's Bounty satchel, a reward choice from the dailies (new in 2025)." },
        { 248719, "Can be in the Pilgrim's Bounty satchel, a reward choice from the dailies (new in 2025)." },
    })
end

------------------------------------------------------------------------
-- Feast of Winter Veil (checked 2026-10-22)
------------------------------------------------------------------------
do
    local IRONFORGE, ORGRIMMAR, HILLSBRAD, STORMWIND, NSTV, DUSTWALLOW = 87, 85, 25, 84, 50, 70
    local UNDERCITY, BOREAN, ICECROWN, BLADES_EDGE, TANAAN, DALARAN_NR = 90, 114, 118, 105, 534, 125
    local VENDOR = {
        A = { side = "Alliance", t = "Wulmort Jinglepocket, the Smokywood Pastures vendor by Greatfather Winter in Ironforge's Commons.", at = { IRONFORGE, 33.0, 67.8 } },
        H = { side = "Horde", t = "Kaymard and Penney Copperpinch, the Smokywood Pastures vendors by Great-father Winter in Orgrimmar.", at = { ORGRIMMAR, 52.4, 77.0 } },
    }
    local REVELER = "Mistletoe, Fresh Holly and Handfuls of Snowflakes come from kissing a Winter Reveler (target one in any capital's inn and type /kiss), once an hour."
    local KISS_TIP = "Players reset the hour by entering a dungeon or using a hearthstone or portal, then kiss again."

    -- the Greench daily and its follow-up
    local GREENCH = {
        { side = "Alliance", t = "Take You're a Mean One... from Wulmort Jinglepocket in Ironforge (level 30 or higher).", at = { IRONFORGE, 33.0, 67.8 } },
        { side = "Horde", t = "Take You're a Mean One... from Kaymard Copperpinch in Orgrimmar (level 30 or higher).", at = { ORGRIMMAR, 52.4, 77.0 } },
        { t = "Go to Growless Cave in Hillsbrad Foothills, help kill the Abominable Greench, then free Metzen the Reindeer next to him.", at = { HILLSBRAD, 43.5, 39.5 } },
        { t = "Pick up the stolen treats by the cave and hand the quest back in." },
    }
    S[273] = GREENCH
    N[273] = { "You don't need to land the killing blow: once the Greench is down, Metzen stays for about two minutes and anyone can free him.",
               "The quest is a daily, and its reward, the Stolen Present, holds most of Winter Veil's toys and pets." }
    S[279] = { GREENCH[1], GREENCH[2], GREENCH[3], { t = "Hand in the treats, then take the follow-up, A Smokywood Pastures' Thank You!, and hand it in for the achievement." } }

    S[1255] = { VENDOR.A, { t = "Buy Snowballs there, then go to Thunder Bluff and throw one at Baine Bloodhoof.", at = { 88, 59.6, 51.6 } } }
    S[259] = { VENDOR.H, { t = "Buy Snowballs there, then go to Ironforge and throw one at Muradin Bronzebeard in the High Seat.", at = { IRONFORGE, 39.6, 55.6 } } }
    N[1255] = "Snowballs also come from the snow piles in Winterspring, Durotar and Hillsbrad during the holiday."
    N[259] = N[1255]

    S[277] = {
        { t = "Get three pieces of the Winter Garb: the Red or Green Winter Hat, the Red or Green Winter Clothes and the Winter Boots. They must be the real items, worn, not transmog or cosmetic copies (the set bonus counts)." },
        { t = "Hats drop during the holiday from bosses of old dungeons: Wrath heroics, Cataclysm and Warlords dungeons and Siege of Orgrimmar. The clothes are tailored (skill 250) and the boots leatherworked (skill 285); both are on the auction house." },
        { t = "Wearing all three, eat Graccu's Mince Meat Fruitcake: the Smokywood Pastures vendors sell it, and the Stolen Present can hold one." },
    }
    N[277] = { "Earthen characters can't eat, so they can't get this one." }

    S[1687] = { { t = REVELER }, { t = "Throw a Handful of Snowflakes at a player of each race and class pair the achievement lists, for example an orc death knight or a gnome mage." } }
    N[1687] = { "Capitals and battlegrounds have most of the pairs.", KISS_TIP }

    S[1688] = { VENDOR.A, VENDOR.H, { t = "Buy the recipes for the Gingerbread Cookie and Winter Veil Egg Nog there, and Hot Apple Cider (it needs about 300 Classic cooking; Greatfather Winter can also mail you that recipe)." },
                { t = "Cook one of each yourself: bought ones don't count." } }

    S[1690] = { { t = "Do the Greench daily (see On Metzen!): within a day the mail brings the Winter Veil Disguise Kit." },
                { t = "Use the kit (it takes a Snowball) to become a snowman, then /dance with another snowman in Dalaran in Northrend.", at = { DALARAN_NR, 50.0, 45.0 } } }
    N[1690] = { "Only Northrend's Dalaran works, not the Broken Isles one.", "If Dalaran looks empty, ask Chromie to set you to the current timeline." }

    S[252] = {
        { side = "Alliance", t = "Use the PX-238 Winter Wondervolt on the Trade District ramp to the flight master in Stormwind (others: Ironforge's gate, the Exodar, Menethil Harbor).", at = { STORMWIND, 62.0, 66.0 } },
        { side = "Horde", t = "Use the PX-238 Winter Wondervolt by the flight master in Orgrimmar (others: Silvermoon, Tirisfal, Booty Bay).", at = { ORGRIMMAR, 50.0, 62.0 } },
        { t = "The Little Helper costume lasts 30 minutes and stays on when you die. Earn 50 honorable kills wearing it." },
    }
    N[252] = { "A random epic battleground gets you there in one or two games.", "Kills add up over several costumes: renew it between games." }

    S[1282] = {
        { t = REVELER .. " Kiss until you get Fresh Holly; it can take a few days." },
        { t = "In Blade's Edge Mountains, unlock the Ogri'la bombing daily: Bomb Them Again! from Sky Sergeant Vanderlip at the Skyguard Outpost.", at = { BLADES_EDGE, 27.5, 52.8 } },
        { t = "Take the daily, switch to steady flight, use the Fresh Holly so your flying mount becomes a reindeer, and do the whole quest in that form until you hand it in." },
    }
    N[1282] = { "Only the daily version counts, not the first, one-time bombing quest.", "Reaching Bomb Them Again! takes a short Skyguard and Ogri'la quest chain first." }

    S[1686] = {
        { t = REVELER .. " Kiss until you have enough Mistletoe; use one on each brother." },
        { t = "Stormwind Cathedral: Brother Kristoff in Cathedral Square.", at = { STORMWIND, 55.4, 54.6 } },
        { t = "Brother Cassius, Brother Benjamin and Brother Joshua inside the cathedral.", at = { STORMWIND, 51.6, 46.0 } },
        { t = "Brother Crowley in the cathedral's basement.", at = { STORMWIND, 52.6, 43.6 } },
        { t = "Brother Wilhelm in Goldshire.", at = { ELWYNN, 41.0, 65.8 } },
        { t = "Brother Nimetz in Northern Stranglethorn.", at = { NSTV, 47.2, 11.0 } },
        { t = "Brother Karman in Theramore. If Theramore lies in ruins, talk to Zidormi in Dustwallow Marsh first to see the old town.", at = { DUSTWALLOW, 67.4, 47.4 } },
    }
    S[1685] = {
        { t = REVELER .. " Kiss until you have enough Mistletoe; use one on each brother." },
        { t = "Brother Malach, down in the Undercity. Talk to Zidormi in Tirisfal Glades (69.4, 62.8) first to see the old city; the Brother Malach in the Ruins of Lordaeron above doesn't count.", at = { UNDERCITY, 51.4, 22.0 } },
        { t = "Durkot Wolfbrother inside Warsong Hold in Borean Tundra, by the south-west entrance.", at = { BOREAN, 40.2, 55.0 } },
        { t = "Brother Keltan on the Horde gunship over Icecrown; the ship moves.", at = { ICECROWN, 69.4, 42.4 } },
    }
    N[1686] = { KISS_TIP }; N[1685] = { KISS_TIP }

    S[1689] = { { t = "From 25 December to 2 January, open a present under the Winter Veil tree in Ironforge or Orgrimmar." } }
    N[1689] = "Every character can take its presents; the year's new present has that year's toy or pet."

    -- carols in the enemy capitals
    local BOOK = "Buy the Winter Veil Chorus Book (a toy) from a Smokywood Pastures vendor and use it in each enemy capital listed."
    S[5853] = { VENDOR.A, { t = BOOK },
                { t = "Orgrimmar, Thunder Bluff and Silvermoon City: flying in and landing out of the guards' sight works." },
                { t = "Undercity: talk to Zidormi in Tirisfal Glades first (69.4, 62.8); players report singing by the old city gate worked.", at = { TIRISFAL, 65.3, 29.0 } } }
    S[5854] = { VENDOR.H, { t = BOOK },
                { t = "Stormwind and Ironforge: land on a roof or a quiet corner out of the guards' sight." },
                { t = "Darnassus: talk to Zidormi in Darkshore (48.8, 24.5) to see Teldrassil before the fire, fly across and land on any roof in Darnassus.", at = { DARKSHORE, 48.8, 24.5 } },
                { t = "The Exodar: take the portal at Rut'theran Village at the foot of Teldrassil and sing just inside the entrance tunnel." } }
    N[5853] = "Track the achievement to see each city tick off." ; N[5854] = N[5853]

    local RIFLE = { t = "Buy the Red Rider Air Rifle from a toy vendor: Craggle Wobbletop walks Stormwind's streets, Blax Bottlerocket walks Orgrimmar's, Jepetto Joybuzz is in Northrend's Dalaran." }
    S[4436] = { RIFLE, { t = "Shoot each Horde leader the achievement lists, from a few yards away (it has a dead zone up close)." },
                { t = "Eitrigg in Orgrimmar's Valley of Strength.", at = { ORGRIMMAR, 49.0, 72.8 } },
                { t = "Lady Sylvanas in the old Undercity: talk to Zidormi in Tirisfal Glades first.", at = { UNDERCITY, 57.8, 91.6 } } }
    S[4437] = { RIFLE, { t = "Shoot each Alliance leader the achievement lists, from a few yards away (it has a dead zone up close)." },
                { t = "Muradin Bronzebeard in Ironforge's High Seat.", at = { IRONFORGE, 39.6, 55.6 } },
                { t = "Tyrande in Darnassus: talk to Zidormi in Darkshore (48.8, 24.5) first to see the old Teldrassil.", at = { DARNASSUS, 43.0, 78.8 } } }
    local RIFLE_TIP = { "Hitting a leader makes them and their guards attack: players take their gear off first and come back after dying.",
                        "Doesn't need the holiday." }
    N[4436] = RIFLE_TIP; N[4437] = RIFLE_TIP

    S[1295] = { { t = "Get a Crashin' Thrashin' Racer controller: the blue one is sold by Jepetto Joybuzz in Northrend's Dalaran, and the Stolen Present can hold one.", at = { DALARAN_NR, 43.6, 45.4 } },
                { t = "During Winter Veil, summon the car where others race (Dalaran and the capitals) and ram 25 other cars." } }
    N[1295] = { "Aim into a group of cars: each one you hit counts.", "Resummon after a crash: it's quicker than waiting." }

    S[10353] = {
        { t = "Crashin' Thrashin' Flamer Controller: can be in the Stolen Present from the Greench daily." },
        { t = "Crashin' Thrashin' Killdozer Controller: 5 Merry Supplies from Izzy Hollyfizzle in your garrison during the holiday." },
        { t = "Crashin' Thrashin' Roller Controller: Drakum, a rare in eastern Tanaan Jungle.", at = { TANAAN, 83.9, 43.2 } },
        { t = "Crashin' Thrashin' Cannon Controller: Gondar, a rare nearby.", at = { TANAAN, 80.7, 56.1 } },
        { t = "Crashin' Thrashin' Mortar Controller: Smashum Grabb, a rare nearby.", at = { TANAAN, 87.5, 56.1 } },
    }
    N[10353] = "The three Tanaan rares drop their toy only sometimes, and four of the five are on the auction house."
    S[8699] = { { t = "Get the Crashin' Thrashin' Flyer Controller: it can be in the Stolen Present." },
                { t = "Find a second player with the flyer and shoot theirs down with yours." } }
    S[20511] = { { t = "Get the Box of Puntables, a toy from the 2024 present (now in the Stolen Present), and set it down." },
                 { t = "Click the creatures that come out to punt them, 30 in all." } }
    S[15181] = { { t = "Get the Rockin' Rollin' Racer toy (a 2021 present, now in the Stolen Present)." },
                 { t = "Summon it and press Lightning Nitro while Rockin' Tunes is playing (its third and fourth buttons)." } }
    N[1691] = "Eleven achievements for the title Merrymaker: expand it, each one has its guide. Several only work from 25 December, when the presents appear."

    -- collectibles: where each comes from
    local SP = "Can be in the Stolen Present, the reward of the daily You're a Mean One... (the Greench)."
    local PRESENT = function(year) return "A Winter Veil present from " .. year .. "; now it can be in the Stolen Present from the Greench daily." end
    AddItems("veil", {
        { 243304, "The 2025 present under the Winter Veil tree (from 25 December)." },
        { 245580, "The 2025 present under the Winter Veil tree (from 25 December)." },
        { 245544, "The 2025 present under the Winter Veil tree (from 25 December)." },
        { 232653, "The 2024 present under the Winter Veil tree (from 25 December)." },
        { 178530, PRESENT(2020) }, { 172222, PRESENT(2019) }, { 172223, PRESENT(2019) },
        { 162642, PRESENT(2018) }, { 162643, PRESENT(2018) }, { 162973, PRESENT(2018) },
        { 151343, PRESENT(2017) }, { 151344, PRESENT(2017) }, { 151348, PRESENT(2017) }, { 151349, PRESENT(2017) },
        { 139337, PRESENT(2016) }, { 128636, PRESENT(2016) }, { 108632, PRESENT(2015) }, { 128776, PRESENT(2015) },
        { 116763, PRESENT(2014) }, { 104318, PRESENT(2013) }, { 90883, PRESENT(2012) }, { 90888, PRESENT(2012) },
        { 46709, PRESENT(2010) }, { 37710, PRESENT(2008) },
        { 116456, SP }, { 116689, SP }, { 116690, SP }, { 116691, SP }, { 116692, SP }, { 232531, SP },
        { 73797, SP }, { 104317, SP }, { 34425, SP }, { 93625, SP }, { 117371, SP }, { 210432, SP },
        { 54436, SP .. " Toy vendors also sell it." }, { 54438, SP .. " Toy vendors also sell it." }, { 54437, SP .. " Toy vendors also sell it." },
        { 44606, SP .. " Toy vendors also sell it." }, { 45057, SP .. " Toy vendors also sell it." }, { 54343, SP .. " Jepetto Joybuzz in Northrend's Dalaran also sells it." },
        { 128649, "Can be in the Smokywood Pastures Special Gift or the Stolen Present." },
        { 118572, "Very rarely in the Smokywood Pastures Special Gift or the Stolen Present." },
        { 21301, "Can be in the Gaily Wrapped Present under the tree (from 25 December, level 20 or higher)." },
        { 21305, "Can be in the Gaily Wrapped Present under the tree (from 25 December, level 20 or higher)." },
        { 21308, "Can be in the Gaily Wrapped Present under the tree (from 25 December, level 20 or higher)." },
        { 21309, "Can be in the Gaily Wrapped Present under the tree (from 25 December, level 20 or higher)." },
        { 128650, "In the Carefully Wrapped Present under the tree (from 25 December)." },
        { 116448, "In the Carefully Wrapped Present under the tree (from 25 December)." },
        { 116450, "In the Carefully Wrapped Present under the tree (from 25 December)." },
        { 116451, "In the Carefully Wrapped Present under the tree (from 25 December)." },
        { 128770, "Loot the Snow Mounds around Grumpus in Frostfire Ridge (Draenor) during the holiday." },
        { 128671, "In the Savage Gift from Grumpus, the holiday rare in Frostfire Ridge (Draenor)." },
        { 108635, "5 Merry Supplies from Izzy Hollyfizzle in your garrison during the holiday." },
        { 17712, "Mailed to you within a day after the Greench daily." },
        { 188680, "Sold by the Smokywood Pastures vendors in the capitals." },
        { 70923, "Sold by the Smokywood Pastures vendors in the capitals." },
        { 21524, "Drops during the holiday from bosses of old dungeons (Wrath heroics, Cataclysm and Warlords dungeons, Siege of Orgrimmar)." },
        { 21525, "Drops during the holiday from bosses of old dungeons (Wrath heroics, Cataclysm and Warlords dungeons, Siege of Orgrimmar)." },
        { 139299, "Drops during the holiday from Legion and Battle for Azeroth dungeon bosses." },
        { 139300, "Drops during the holiday from Legion and Battle for Azeroth dungeon bosses." },
        { 151790, "Crafted by tailors (Pattern: Red Winter Clothes)." },
        { 151792, "Crafted by tailors (Pattern: Green Winter Clothes, sold by Eebee Jinglepocket in Shattrath)." },
    })
    for _, id in ipairs({ 234398, 234399, 234400, 234401, 234402, 234403, 234404, 234405, 234406, 234407, 234593, 234594, 234595, 234596, 234597, 234598 }) do
        AddItems("veil", { { id, "Sold by the Smokywood Pastures vendors in the capitals for gold (15 to 30)." } })
    end
end

------------------------------------------------------------------------
-- Lunar Festival elders (checked 2026-10-22 against an independent per-elder list): stray far-away spots replaced,
-- and the elders that need Zidormi or a dungeon say so.
------------------------------------------------------------------------
do
    local FIX = {
        [8635] = { { 66, 28.86, 62.56 }, { 67, 28.05, 33.62 }, { 68, 44.23, 77.21 }, { 281, 51.47, 93.73 } },
        [8642] = { { 48, 33.32, 46.54 } },
        [8643] = { { 26, 50, 48.04 } },
        [8644] = { { 33, 80.32, 40.27 }, { 252, 61.81, 40 }, { 36, 27.59, 25.44 } },
        [8645] = { { 21, 44.98, 41.14 } },
        [8646] = { { 37, 32.16, 52.76 } },
        [8647] = { { 17, 54.28, 49.49 } },
        [8649] = { { 37, 39.79, 63.67 } },
        [8650] = { { 23, 75.73, 54.56 } },
        [8653] = { { 27, 53.91, 49.91 } },
        [8654] = { { 81, 30.81, 13.32 } },
        [8671] = { { 71, 37.24, 79.06 } },
        [8672] = { { 83, 59.96, 49.94 } },
        [8673] = { { 7, 48.5, 53.24 } },
        [8674] = { { 210, 39.95, 72.5 } },
        [8678] = { { 7, 44.94, 23.23 }, { 88, 72.98, 23.38 } },
        [8679] = { { 69, 76.71, 37.89 } },
        [8680] = { { 10, 68.36, 69.96 } },
        [8681] = { { 78, 50.37, 76.16 } },
        [8682] = { { 64, 46.34, 51.01 } },
        [8717] = { { 10, 48.52, 59.27 } },
        [8718] = { { 89, 39.21, 31.85 }, { 57, 28.11, 43.67 } },
        [8719] = { { 81, 53.02, 35.48 } },
        [8720] = { { 76, 64.73, 79.34 } },
        [8721] = { { 62, 49.54, 18.94 } },
        [8723] = { { 77, 38.35, 52.85 } },
        [8724] = { { 64, 77.09, 75.61 } },
        [8725] = { { 63, 35.54, 48.91 } },
        [8866] = { { 27, 62.96, 21.94 }, { 87, 29.33, 17.15 } },
        [13019] = { { 115, 48.76, 78.18 } },
        [13021] = { { 114, 27.5, 25.98 }, { 129, 55.2, 64.71 } },
        [13032] = { { 120, 64.59, 51.34 } },
        [85931] = { { 2214, 44.76, 67.32 } },
        [85932] = { { 2214, 63.12, 52.97 } },
    }
    local ZID_TIRISFAL = "Talk to Zidormi in Tirisfal Glades (69.4, 62.8) first to see the zone before the Battle for Azeroth."
    local ZID_DARKSHORE = "Talk to Zidormi in Darkshore (48.8, 24.5) first to see the zone before the Battle for Azeroth."
    local NOTE = {
        [8647] = "Talk to Zidormi at the north end of the Blasted Lands (48.2, 7.2) first to see the zone before the invasion.",
        [8648] = "In the Undercity. " .. ZID_TIRISFAL, [8652] = "In Brill. " .. ZID_TIRISFAL,
        [8715] = "On Teldrassil. " .. ZID_DARKSHORE, [8718] = "In Darnassus. " .. ZID_DARKSHORE, [8721] = "In Lor'danel. " .. ZID_DARKSHORE,
        [8619] = "Inside Blackrock Depths.", [8635] = "Inside Maraudon, in Earthsong Falls.", [8644] = "Inside Lower Blackrock Spire.",
        [8676] = "Inside Zul'Farrak.", [8713] = "Inside the Sunken Temple.", [8727] = "Inside Stratholme.",
        [13017] = "Inside Utgarde Keep.", [13021] = "Inside the Nexus.", [13022] = "Inside Azjol-Nerub.", [13023] = "Inside Drak'Tharon Keep.",
        [13065] = "Inside Gundrak.", [13066] = "Inside the Halls of Stone.", [13067] = "Inside Utgarde Pinnacle.",
    }
    for _, a in ipairs({ 910, 911, 912, 914, 915, 1396, 6006, 17321, 41130 }) do
        local g = ns.CRIT_GUIDE and ns.CRIT_GUIDE[a]
        if g then
            for q, spots in pairs(FIX) do
                if g["27:" .. q] then g["27:" .. q].at = spots end
            end
            for q, text in pairs(NOTE) do
                if g["27:" .. q] then g["27:" .. q].t = "Speak to the elder. " .. text end
            end
        end
    end
end

------------------------------------------------------------------------
-- Lunar Festival (checked 2026-10-22)
------------------------------------------------------------------------
do
    local MOONGLADE = 80
    local VALADAR = { t = "Valadar Starsong on the platform over the lake in Nighthaven, Moonglade. Reach Moonglade with the Lunar Festival Invitation from your capital's festival camp (use it in the beam of moonlight).", at = { MOONGLADE, 54.0, 35.0 } }
    S[626] = { VALADAR, { t = "Buy any festive dress or pant suit from him with Coins of Ancestry." } }
    N[626] = "Each elder gives a Coin of Ancestry, and the coins never expire, so leftovers from earlier years work too."
    S[937] = { VALADAR, { t = "Take Elune's Blessing from him." },
               { t = "At the Stormrage Barrow Dens, south-east of the lake, fire rocket clusters from the launchers until the Minions of Omen and then Omen appear.", at = { MOONGLADE, 60.5, 65.5 } },
               { t = "Stand by Omen's body after he dies to get Elune's Blessing (you don't need to have hit him), then return to Valadar." } }
    N[937] = "Other players usually have Omen up: wait by the barrows and stay close when he falls."
    local FIRE = { t = "Buy fireworks from a Lunar Festival Vendor at your capital's festival camp or in Nighthaven." }
    S[1552] = { FIRE, { t = "Buy 10 Festival Firecrackers, put them on an action key and set off all 10 within 30 seconds." } }
    S[1281] = { FIRE, { t = "Buy 10 Red Rocket Clusters and fire all 10 from a Cluster Launcher (on the ground around the camps) within 25 seconds." } }
    N[1281] = "Put the clusters on an action key and stand right at the launcher before you start."
    N[913] = "The twelve achievements for the title Elder: expand it, each one has its guide. Track an elder achievement and the arrow takes you to the nearest elder you still need."

    AddItems("lunar", {
        { 169208, "From the quest Lunar Preservation (Myrael Lunarbloom in Moonglade): unlike the vendor crowns, it can be worn as transmog all year." },
        { 170205, "From the quest Lunar Preservation (Myrael Lunarbloom in Moonglade): unlike the vendor crowns, it can be worn as transmog all year." },
        { 170206, "From the quest Lunar Preservation (Myrael Lunarbloom in Moonglade): unlike the vendor crowns, it can be worn as transmog all year." },
        { 170207, "From the quest Lunar Preservation (Myrael Lunarbloom in Moonglade): unlike the vendor crowns, it can be worn as transmog all year." },
        { 21540, "The reward for Elune's Blessing (defeat Omen in Moonglade)." },
    })
end

------------------------------------------------------------------------
-- Love is in the Air (checked 2026-10-22). The Gala of Gifts stands outside Stormwind (Elwynn Forest) and
-- outside Orgrimmar (Durotar); a portal from Dornogal leads there too.
------------------------------------------------------------------------
do
    local G = {
        -- Love Tokens: candies, arrows, dress boxes, the permanent Peddlefeet
        main = { { side = "Alliance", t = "Kiera Torres at the Gala of Gifts outside Stormwind.", at = { ELWYNN, 32.2, 50.5 } },
                 { side = "Horde", t = "Lythianne Morningspear at the Gala of Gifts outside Orgrimmar.", at = { DUROTAR, 41.8, 17.2 } } },
        -- fireworks, Love Fools, the love prism
        fun = { { side = "Alliance", t = "Bang Sparknozzle at the Gala of Gifts outside Stormwind.", at = { ELWYNN, 33.5, 47.8 } },
                { side = "Horde", t = "Zikky at the Gala of Gifts outside Orgrimmar.", at = { DUROTAR, 41.0, 17.0 } } },
        choc = { { side = "Alliance", t = "Maurice Guichi, the chocolatier at the Gala of Gifts outside Stormwind.", at = { ELWYNN, 33.5, 50.0 } },
                 { side = "Horde", t = "Zin'boja, the chocolatier at the Gala of Gifts outside Orgrimmar.", at = { DUROTAR, 41.2, 18.0 } } },
        rose = { { side = "Alliance", t = "Sylandra Silverbreeze, the flower vendor at the Gala of Gifts outside Stormwind.", at = { ELWYNN, 34.2, 48.8 } },
                 { side = "Horde", t = "Hana Breezeheart, the flower vendor at the Gala of Gifts outside Orgrimmar.", at = { DUROTAR, 41.5, 17.8 } } },
    }
    local function at(key, rest) local out = { G[key][1], G[key][2] } for _, x in ipairs(rest) do out[#out + 1] = x end return out end
    local TOKENS = "Love Tokens come from the holiday's quests and dailies and vanish when it ends: spend them as you go."

    S[1701] = at("main", { { t = "Buy a Bag of Heart Candies (it has 10 candies) and eat them. You need all eight messages: Be mine!, I'm all yours!, I LOVE YOU, Hot lips., You're mine!, All yours., I'll follow you all around Azeroth. and You're the best!" } })
    N[1701] = { "The messages are random: it usually takes a few bags.", "Candies someone else gives you don't count: open the bag yourself.", TOKENS }
    S[1702] = at("choc", { { t = "Buy a Box of Chocolates and eat the four kinds: Buttermilk Delight, Dark Desire, Sweet Surprise and Very Berry Cream." } })
    N[1702] = "One box usually holds all four; buy another if one is missing."
    S[1188] = at("main", { { t = "Buy Silver Shafted Arrows and shoot 10 different players with them." } })
    N[1188] = "It fails on a player who already has a pet out: pick players without one."
    S[1699] = at("rose", { { t = "Buy Handfuls of Rose Petals (5 a stack) and throw them at each race and class pair the achievement lists, for example a gnome warlock or a troll rogue." } })
    N[1699] = "Capitals and battlegrounds have most of the pairs."
    S[1696] = at("fun", { { t = "Buy 10 Lovely Fireworks, put them on an action key and launch all 10 within 20 seconds." } })
    S[1704] = at("fun", { { t = "Buy Love Fools (or ask someone who has one). Place one and type /pity at it in each of the five places: Wintergrasp, the Arathi Basin blacksmith, Naxxramas, the ring of the Gurubashi Arena in Stranglethorn, and the Culling of Stratholme." } })
    N[1704] = "Another player's Love Fool counts too: /pity any Love Fool standing there."
    S[1291] = at("choc", { { t = "Buy a Box of Chocolates there (you need a Buttermilk Delight from it)." },
                           { t = "Get a Romantic Picnic Basket (a toy from the main gala vendor), go to Dalaran in Northrend, sit at a picnic (yours or another player's) and eat the Buttermilk Delight while sitting." } })
    S[1695] = { { side = "Alliance", t = "Take the Crushing the Crown daily from Inspector Snip Snagglebolt at the gala outside Stormwind.", at = { ELWYNN, 32.2, 50.0 } },
                { side = "Horde", t = "Take the Crushing the Crown daily from Detective Snap Snagglebolt in Orgrimmar.", at = { 85, 50.0, 65.0 } },
                { t = "Destroy a Crown Chemical wagon and defeat five of its workers, then hand it in." } }
    S[1703] = { { t = "During the holiday, bosses of older dungeons can drop a Bouquet of Red or Ebon Roses. Lord Godfrey in Shadowfang Keep is the easiest; others are listed in the achievement's text." } }
    N[1703] = "Players farm Shadowfang Keep on normal: it's quick and Godfrey is its last boss."
    S[4624] = { { t = "Queue for the holiday dungeon in the Dungeon Finder (level 10 or higher) and defeat Apothecary Hummel and his two helpers in Shadowfang Keep." } }
    N[4624] = "Your first kill each day gives the Heart-Shaped Box: the best chance at the X-45 Heartbreaker, the Love Witch's Sweeper and the Spring Butterfly."
    S[9389] = { S[4624][1], { t = "Loot the holiday necklace he drops and use it: it sets off heart fireworks." } }
    N[9389] = "One necklace drops per kill for the group; it can be traded to others in the group."
    local PRISM = { t = "Buy the Manufactured Love Prism from the fireworks vendor. Other players channel their prism on you; each Love Ray stays on you for a while." }
    S[9392] = at("fun", { PRISM, { t = "Have 10 Love Rays on you at once." } })
    S[9393] = at("fun", { PRISM, { t = "Have 25 Love Rays on you at once." } })
    S[9394] = at("fun", { PRISM, { t = "Have 50 Love Rays on you at once: form a raid, stand in a circle and all channel on the player in the middle, then switch." } })
    local RAYS = { "The prism has a cooldown, so it takes several players.", "Feign Death, Ice Block and changing zones remove the rays: stay put." }
    N[9392] = RAYS; N[9393] = RAYS; N[9394] = { RAYS[1], RAYS[2], "It rewards the True Love Prism toy." }
    S[1694] = at("main", { { t = "Buy Lovely Dress Boxes and open them until one holds the Lovely Black Dress." } })
    N[1694] = { "A dress bought from another player doesn't count.", "Not part of Fool For Love." }
    S[1700] = at("main", { { t = "Buy the Truesilver Shafted Arrow: having it in your bags counts." } })
    N[1700] = "You can sell it back to the vendor for your tokens once you have the achievement."
    S[19400] = { { side = "Alliance", t = "Donate to Galvus Ironhammer at the gala outside Stormwind.", at = { ELWYNN, 32.0, 49.7 } },
                 { side = "Horde", t = "Donate to Torgando Featherhoof at the gala outside Orgrimmar.", at = { DUROTAR, 42.3, 18.2 } },
                 { t = "Donate 10,000 gold once a day, five times: 50,000 gold in all." } }
    N[19400] = "Each donation sends you a small thank-you in the mail."
    S[19508] = { { t = "Do the scenic getaway daily in Feralas when it's offered (gift matching at the Steam Pools resort)." },
                 { t = "Give each guest their gift: Vernon Whitlock and Bront Axecrusher a sword, Angus Flagonshot the puppy, Halene Mistrunner and Bratley Graston a bouquet, Clarissa Buchannan the wine and Verilas Sunblood the scroll. Hug Theoderic Prescott, bow to Wilber Campbell and listen to Rizzi's story." } }
    N[19508] = "Not every gift appears each time: it takes the Feralas daily on a few different days."
    N[1693] = "The nine achievements for the title the Love Fool: expand it, each one has its guide."

    local BOX = "Can be in the Heart-Shaped Box from your first Apothecary Hummel kill of the day (the holiday dungeon)."
    AddItems("love", {
        { 232926, BOX .. " Only the first kill of the day, account-wide, and the chance grows each new day you kill him." },
        { 235658, BOX .. " New in 2026. Only the first kill of the day, account-wide, and the chance grows each new day you kill him." },
        { 211812, BOX },
        { 151767, "In a Lovely Dress Box from Kiera Torres or Lythianne Morningspear at the gala (Love Tokens)." },
        { 151768, "In a Lovely Dress Box from Kiera Torres or Lythianne Morningspear at the gala (Love Tokens)." },
        { 151769, "In a Lovely Dress Box from Kiera Torres or Lythianne Morningspear at the gala (Love Tokens)." },
        { 151764, "In a Dinner Suit Box from Kiera Torres or Lythianne Morningspear at the gala (Love Tokens)." },
        { 151765, "In a Dinner Suit Box from Kiera Torres or Lythianne Morningspear at the gala (Love Tokens)." },
        { 151766, "In a Dinner Suit Box from Kiera Torres or Lythianne Morningspear at the gala (Love Tokens)." },
        { 235150, "Part of the Spring Butterfly ensemble from Kiera Torres or Lythianne Morningspear (Love Tokens, new in 2026)." },
        { 235212, "Part of the Spring Butterfly ensemble from Kiera Torres or Lythianne Morningspear (Love Tokens, new in 2026)." },
        { 235214, "Part of the Spring Butterfly ensemble from Kiera Torres or Lythianne Morningspear (Love Tokens, new in 2026)." },
    })
end

------------------------------------------------------------------------
-- Noblegarden (checked 2026-10-22). Eggs hide in the eight starting towns, and since 2026 also in Silvermoon City.
------------------------------------------------------------------------
do
    local TELDRASSIL, MULGORE, UNGORO = 57, 7, 78
    local TOWN = {
        A = { { "Goldshire, Elwynn Forest", ELWYNN, 42.5, 65.8 }, { "Kharanos, Dun Morogh", DUN_MOROGH, 54.0, 50.8 },
              { "Dolanaar, Teldrassil (talk to Zidormi in Darkshore first, 48.8, 24.5)", TELDRASSIL, 55.6, 51.2 }, { "Azure Watch, Azuremyst Isle", AZUREMYST, 49.0, 51.2 } },
        H = { { "Razor Hill, Durotar", DUROTAR, 52.2, 41.5 }, { "Brill, Tirisfal Glades (talk to Zidormi in Tirisfal, 69.4, 62.8, first)", TIRISFAL, 61.4, 53.0 },
              { "Bloodhoof Village, Mulgore", MULGORE, 47.0, 59.8 }, { "Falconwing Square, old Eversong Woods", EVERSONG_OLD, 47.5, 46.0 } },
    }
    local function towns(text)
        local out = {}
        for _, side in ipairs({ "A", "H" }) do
            for _, w in ipairs(TOWN[side]) do
                out[#out + 1] = { side = side == "A" and "Alliance" or "Horde", t = text .. w[1] .. ".", at = { w[2], w[3], w[4] } }
            end
        end
        return out
    end
    local VENDOR = { { side = "Alliance", t = "The Noblegarden Vendor in Goldshire (every egg town has one).", at = { ELWYNN, 42.5, 65.8 } },
                     { side = "Horde", t = "The Noblegarden Merchant in Razor Hill (every egg town has one).", at = { DUROTAR, 52.2, 41.5 } } }
    local EGGS = "Brightly Colored Eggs hide on the ground around the egg towns. Each gives a Noblegarden Chocolate (the holiday's currency) and sometimes an outfit piece, the rabbit's foot or the flowers."
    local EGG_TIP = { "Collect first, buy second, eat last: eating chocolates spends them.", "Lower ground clutter and zoom out to spot eggs before the plants hide them." }

    S[2676] = { VENDOR[1], VENDOR[2], { t = EGGS .. " Loot one." } }
    S[2417] = { { t = EGGS }, { t = "Eat 25 Noblegarden Chocolates." } }; N[2417] = EGG_TIP
    S[2418] = { { t = EGGS }, { t = "Eat 100 Noblegarden Chocolates in total. Do it last, after buying everything you want." } }; N[2418] = EGG_TIP
    S[249] = { { t = EGGS }, { t = "Open eggs until one holds the Elegant Dress. Only one found in an egg counts, not one bought." } }
    S[248] = { { t = EGGS }, { t = "Open eggs until you have found both the White Tuxedo Shirt and the Black Tuxedo Pants. Only ones found in eggs count." } }
    N[249] = "A rare find: players report about one egg in two hundred. Not part of Noble Gardener."; N[248] = N[249]
    S[2576] = { VENDOR[1], VENDOR[2], { t = "Buy (or find in eggs) the White Tuxedo Shirt and Black Tuxedo Pants, put them on, and /kiss a player wearing the Elegant Dress." } }
    N[2576] = { "Only the player in the tuxedo gets it: take turns with a friend.", "The tailored tuxedo doesn't count, only the holiday one." }
    S[2422] = { VENDOR[1], VENDOR[2], { t = "Buy Spring Flowers (or find them in eggs) and use them to give bunny ears to a player of each race the achievement lists." } }
    N[2422] = "The flowers have a cooldown: a capital with many races in it is quickest."
    S[2436] = { VENDOR[1], VENDOR[2], { t = "Buy the Spring Florist's Pouch (a toy) and plant a flower anywhere in the Badlands, Silithus, Thousand Needles, Desolace and Tanaris." } }
    S[2416] = { { t = "Get turned into a Noblegarden bunny: easiest, a friend uses the bunny costume item on you; eggs can also turn you into one." },
                { t = "As a bunny, go to the Golakka Hot Springs in Un'Goro Crater and wait there until you lay an egg.", at = { UNGORO, 33.0, 49.0 } } }
    N[2416] = { "Damage breaks the bunny form: avoid fights on the way.", "Players set their hearthstone to Marshal's Stand in Un'Goro, turn into a bunny, hearth and run west." }
    S[2421] = { VENDOR[1], { side = "Alliance", t = "Buy a Noblegarden Egg and hide it anywhere in Stormwind." } }
    S[2420] = { VENDOR[2], { side = "Horde", t = "Buy a Noblegarden Egg and hide it anywhere in Silvermoon City." } }
    N[2421] = "Loot the egg you hid to get your chocolate back."; N[2420] = N[2421]
    S[2419] = towns("Summon your Spring Rabbit next to another player's Spring Rabbit in ")
    S[2497] = S[2419]
    N[2419] = "Get the Spring Rabbit from a Spring Rabbit's Foot (vendor or eggs). Wait a moment by the other rabbit and it counts."; N[2497] = N[2419]
    S[20209] = {
        { side = "Alliance", t = "Go to the Large Duck Nest south of Goldshire, in the south of Elwynn Forest.", at = { ELWYNN, 30.6, 90.8 } },
        { side = "Horde", t = "Go to the Large Duck Nest in Durotar.", at = { DUROTAR, 44.6, 35.6 } },
        { t = "Find the large Golden Egg nearby (it moves between a few spots close to the nest), roll it into the nest with the extra button, and defeat Daetan Swiftplume when he appears." },
    }
    N[20209] = "Either nest works for both factions. He can drop the Noble Flying Carpet, the duck colors and the Spring Reveler's Cornsilk pieces."
    N[2798] = "The eight achievements for the title the Noble: expand it, each one has its guide."

    local BOSS = "Can drop from Daetan Swiftplume, the holiday duck boss at the nests in Elwynn Forest and Durotar."
    AddItems("noble", {
        { 212599, BOSS },
        { 188698, "From the quest A Tisket, a Tasket, a Noblegarden Basket in your egg town." },
        { 216881, "From the quest Just a Waddle Away, the end of the duck story in your egg town." },
        { 216898, BOSS .. " The colors are shared by your warband (reset in 2026)." },
        { 216901, BOSS .. " The colors are shared by your warband (reset in 2026)." },
        { 216902, BOSS .. " The colors are shared by your warband (reset in 2026)." },
        { 216900, BOSS .. " The colors are shared by your warband (reset in 2026)." },
        { 212717, BOSS .. " New in 2026." }, { 212713, BOSS .. " New in 2026." }, { 212705, BOSS .. " New in 2026." },
        { 212706, BOSS .. " New in 2026." }, { 212987, BOSS .. " New in 2026." }, { 212707, BOSS .. " New in 2026." },
        { 212715, "In the Loot-Filled Basket from the holiday boss's quest." }, { 212711, "In the Loot-Filled Basket from the holiday boss's quest." },
        { 212698, "In the Loot-Filled Basket from the holiday boss's quest." }, { 212699, "In the Loot-Filled Basket from the holiday boss's quest." },
        { 212985, "In the Loot-Filled Basket from the holiday boss's quest." }, { 212701, "In the Loot-Filled Basket from the holiday boss's quest." },
    })
end

------------------------------------------------------------------------
-- Children's Week (checked 2026-10-22)
------------------------------------------------------------------------
do
    local SHATTRATH, DORNOGAL, HOWLING_FJORD = 111, 2339, 117
    local ORPHAN = {
        { side = "Alliance", t = "Take an orphan from Orphan Matron Nightingale at the Stormwind orphanage (the one-day quest Children's Week).", at = { 84, 56.4, 54.2 } },
        { side = "Horde", t = "Take an orphan from Orphan Matron Battlewail at the Orgrimmar orphanage (the one-day quest Children's Week).", at = { 85, 58.0, 57.5 } },
        { t = "Keep the orphan out with the whistle you get; if it leaves, use the whistle again." },
    }
    local function orphan(extra) local out = { ORPHAN[1], ORPHAN[2], ORPHAN[3] } for _, x in ipairs(extra) do out[#out + 1] = x end return out end
    S[1791] = orphan({ { t = "Use your Hearthstone (a hearthstone toy works too) with the orphan out." } })
    S[1789] = orphan({ { t = "Turn in five daily quests with the orphan out. You can call the orphan just before each turn-in." } })
    S[1790] = orphan({ { t = "Go to Utgarde Pinnacle in Howling Fjord (Normal or Heroic) and kill King Ymiron, the last boss, with the orphan out." } })
    S[1788] = orphan({ { t = "With the orphan out, eat each sweet the achievement lists. Aimee in Dalaran (Northrend) sells the Red Velvet Cupcake, Dalaran Doughnut, Dalaran Brownie and Lovely Cake (eat a slice). Tigule's Strawberry Ice Cream is sold by food vendors; the Tasty Cupcake and Delicious Chocolate Cake are cooked (or bought on the auction house)." } })
    N[1788] = { "Dalaran Doughnut, not Darkmoon Doughnut.", "Some of the sweets need level 28; Earthen characters can't eat them." }
    S[1792] = orphan({ { t = "Finish any orphan's quest line and choose a pet as the reward." } })
    N[1792] = "Any orphan works, including Shattrath's, Dalaran's, Boralus's or Dazar'alor's and the four Khaz Algar children from Ullna in Dornogal."
    S[1786] = orphan({ { t = "With the orphan out, in the battlegrounds: capture the flag in Eye of the Storm, assault a tower in Alterac Valley, assault a flag in Arathi Basin and return a fallen flag in Warsong Gulch." } })
    N[1786] = { "No longer needed for For the Children.", "Players do the three quick ones in one or two games each; Warsong Gulch's flag return takes patience." }
    S[275] = { { t = "Take Salandria or Dornaa from Orphan Matron Mercy in Shattrath's Lower City and finish their quest line. Its last quest offers Egbert's Egg, Sleepy Willy and the Elekk Training Collar: pick one you don't have yet.", at = { SHATTRATH, 74.6, 47.8 } },
               { t = "A character can do it once each Children's Week, so the three pets take three years on the same character." } }
    N[275] = "Buying the pets, or getting them from the vendor with a Well-loved Figurine, doesn't count: they must be quest rewards on this character."
    N[1793] = "Five achievements for the title Matron or Patron: expand it, each one has its guide."

    AddItems("children", {
        { 272287, "Sold by Jepetto Joybuzz in Silvermoon City during Children's Week for a Well-loved Figurine (choose the figurine as an orphan's reward)." },
        { 69895, "Sold by the toy vendors in Stormwind and Orgrimmar during Children's Week, or by the Children's Week vendors for a Well-loved Figurine." },
        { 69896, "Sold by the toy vendors in Stormwind and Orgrimmar during Children's Week, or by the Children's Week vendors for a Well-loved Figurine." },
    })
end

------------------------------------------------------------------------
-- Midsummer bonfires (checked 2026-10-22 against an independent per-bonfire list): spots that were off replaced.
------------------------------------------------------------------------
do
    local FIX = {
        [11580] = { { 21, 49.62, 38.66 } },
        [11581] = { { 52, 45.14, 62.44 } },
        [11732] = { { 14, 44.59, 46.27 } },
        [11745] = { { 37, 43.08, 62.85 } },
        [11749] = { { 48, 32.31, 40.09 } },
        [11755] = { { 26, 14.51, 49.87 } },
        [11766] = { { 15, 24.11, 37.22 } },
        [11786] = { { 18, 56.98, 51.76 } },
        [11808] = { { 17, 55.53, 14.88 } },
        [11816] = { { 37, 43.47, 62.63 } },
        [11821] = { { 107, 49.61, 69.46 } },
        [11834] = { { 83, 61.24, 47.25 } },
        [11839] = { { 83, 58.15, 47.51 } },
        [11842] = { { 15, 23.09, 37.45 } },
        [11851] = { { 100, 57.1, 42.11 } },
        [28929] = { { 51, 70.24, 15.73 } },
    }
    for _, a in ipairs({ 263, 271, 272, 1022, 1023, 1024, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034, 1035, 1036, 1037, 1038, 1039, 1145, 2144, 6007, 6008, 6009, 6010, 6011, 6012, 6013, 6014, 8042, 8043, 8044, 8045, 11276, 11277, 11278, 11279, 11280, 11282, 11283, 11284, 13340, 13341, 13342, 13343, 17737, 17738, 41631, 41632, 61335, 61336 }) do
        local g = ns.CRIT_GUIDE and ns.CRIT_GUIDE[a]
        if g then
            for q, spots in pairs(FIX) do
                if g["27:" .. q] then g["27:" .. q].at = spots end
            end
        end
    end
end

------------------------------------------------------------------------
-- Midsummer Fire Festival (checked 2026-10-22)
------------------------------------------------------------------------
do
    local CAMP = { { side = "Alliance", t = "The Midsummer camp in Stormwind (also Ironforge, Darnassus and the Exodar): the Festival Loremaster, the vendors and the Earthen Ring Elder." },
                   { side = "Horde", t = "The Midsummer camp in Orgrimmar (also Thunder Bluff, Silvermoon and the Undercity): the Festival Talespinner, the vendors and the Earthen Ring Elder." } }
    S[271] = { CAMP[1], CAMP[2], { t = "Buy the Mantle of the Fire Festival, Vestment of Summer and Sandals of Summer from a Midsummer vendor with Burning Blossoms and put all three on." },
               { t = "Right-click a ribbon pole next to any festival bonfire and keep dancing for a full minute." } }
    N[271] = "The Crown of the Fire Festival isn't needed."
    S[272] = { CAMP[1], CAMP[2], { t = "Buy at least 10 Juggling Torches from a Midsummer vendor." },
               { t = "In Dalaran (Northrend), juggle 40 torches within 15 seconds: put them on a key and keep throwing at the ground at your feet." } }
    S[263] = { { t = "Queue for The Frost Lord Ahune in the Dungeon Finder (level 10 or higher), or ask the Earthen Ring Elder at a main camp." },
               { t = "Defeat the naga guarding the Ice Stone, use the stone to call Ahune, kill his minions until he retreats, then destroy his Frozen Core." } }
    N[263] = "Your first kill each day gives the Satchel of Chilled Goods, and only that first kill (account-wide) can drop the Sun Festival's Painted Roc mount and Ahune's rarest weapons."
    S[1145] = { CAMP[1], CAMP[2], { t = "Take A Thief's Reward there, then go into each of the other faction's four capitals and click its festival flame to take a piece of it." },
                { t = "Hand the four flames back in for the quest; the achievement and the Crown of the Fire Festival come with it." } }
    N[1145] = { "The Exodar and Silvermoon can't be flown into: walk in.", "Taking an enemy flame flags you for PvP." }
    local DESECRATE = "Desecrating the other faction's bonfire flags you for PvP: go at a quiet hour or with friends."
    for _, id in ipairs({ 1028, 1029, 1030, 1031, 1032, 1033, 6007, 6010, 6013, 6014, 13342, 13343 }) do
        N[id] = N[id] or { "Track it: the arrow goes to the nearest bonfire you still need.", DESECRATE }
    end
    for _, id in ipairs({ 1022, 1023, 1024, 1025, 1026, 1027, 6008, 6009, 6011, 6012, 8044, 8045, 11280, 11282, 13340, 13341, 17737, 17738, 41631, 41632, 61335, 61336 }) do
        N[id] = N[id] or { "Track it: the arrow goes to the nearest bonfire you still need. Honoring a bonfire is a one-time quest at the fire." }
    end
    N[1038] = "Six achievements for the title Flame Warden: expand it, each one has its guide."
    N[1039] = "Six achievements for the title Flame Keeper: expand it, each one has its guide."

    local AHUNE = "Can drop from Ahune, the holiday boss (Dungeon Finder): only your first kill of the day, account-wide, and the chance grows each new day."
    AddItems("midsummer", {
        { 275464, AHUNE .. " New in 2026: the first Midsummer mount." },
        { 224163, AHUNE }, { 246570, AHUNE }, { 244423, AHUNE }, { 246571, AHUNE }, { 244422, AHUNE }, { 244356, AHUNE },
        { 275463, "Part of the Sun Festival's Flame Totems ensemble from the Midsummer vendors (Burning Blossoms, new in 2026)." },
        { 275462, "Part of the Sun Festival's Flame Totems ensemble from the Midsummer vendors (Burning Blossoms, new in 2026; tauren only)." },
    })
end

------------------------------------------------------------------------
-- Brewfest (checked 2026-10-22). The camps stand outside Ironforge (Dun Morogh) and Orgrimmar (Durotar).
------------------------------------------------------------------------
do
    local SILVERMOON, EVERSONG, ARCANTINA, ZULAMAN, HARANDAR, THE_DEN, VOIDSTORM = 2393, 2395, 2541, 2437, 2413, 2576, 2405
    local CAMP = { { side = "Alliance", t = "The Brewfest camp outside Ironforge.", at = { DUN_MOROGH, 55.6, 37.0 } },
                   { side = "Horde", t = "The Brewfest camp outside Orgrimmar.", at = { DUROTAR, 41.0, 17.5 } } }
    local function camp(rest) local out = { CAMP[1], CAMP[2] } for _, x in ipairs(rest) do out[#out + 1] = x end return out end
    S[1185] = camp({ { t = "Buy and eat the eight foods: The Golden Link, Succulent, Pickled, Savory, Dried and Spicy Smoked Sausage from the sausage vendor (Keiran Donoghue or Bron), Spiced Onion Cheese and The Essential Brewfest Pretzel from the food vendors next to them." } })
    N[1185] = "Coren Direbrew's loot sometimes has some of them too."
    S[2796] = camp({ { t = "Buy the Brew of the Month Club Membership Form from Belbi Quikswitch (Alliance) or Blix Fixwidget (Horde) with Brewfest Prize Tokens and use it." } })
    N[2796] = "From then on, a new beer arrives in the mail every month (that's what Brew of the Year counts)."
    S[295] = { { t = "Queue for Coren Direbrew in the Dungeon Finder and defeat him in the Grim Guzzler (Blackrock Depths)." } }
    N[295] = "Your first kill each day gives the Keg-Shaped Treasure Chest: the best chance at the Great Brewfest Kodo, the Swift Brewfest Ram and his rare cosmetics."
    S[1936] = camp({ { t = "Do the Brewfest quest that rewards the Wolpertinger's Tankard (Catch the Wild Wolpertinger!). On realms where that quest isn't offered, buy the Tankard from the pet vendor for Brewfest Prize Tokens instead." } })
    S[303] = camp({ { t = "Buy Fresh or Preserved Brewfest Hops from a Brewfest vendor and use them on your mount (or get the Brewfest Kodo or Ram from Coren Direbrew)." } })
    S[1260] = camp({ { t = "Get the free Synthebrew Goggles from Goldark Snipehunter (Alliance) or Glodrak Huntsniper (Horde) and wear them (the XL version doesn't count)." },
                    { t = "During Brewfest, fall at least 65 yards and survive: the same falls players use for the year-round Fall 65 yards achievement work." } })
    N[1260] = "Being completely smashed from Brewfest drinks also counts instead of the goggles."
    S[1183] = { { t = "Join the Brew of the Month club (see Brew of the Month)." },
                { t = "Drink each month's beer when it arrives in the mail: 12 different ones in all, so it takes a year." } }
    N[1183] = { "Each beer can only be bought during its month, so don't miss one.", "Not part of Brewmaster any more." }
    S[1184] = camp({ { t = "Buy and keep one of each Alliance brew the achievement lists: the Thunderbrew, Barleybrew and Gordok apprentices at the camp sell them." } })
    S[1203] = camp({ { t = "Buy and keep one of each Horde brew the achievement lists: the T'chali's Voodoo, Drohn's Distillery and Gordok apprentices at the camp sell them." } })
    S[293] = camp({ { t = "Buy three pieces of Brewfest clothing (a Brewfest hat, chest and boots) from the vendors and wear them." },
                   { t = "Get completely smashed on Brewfest drinks, then /dance in Dalaran (Northrend)." } })
    S[63253] = {
        { t = "During Brewfest, click the Bar Tab Barrel in each Midnight tavern and donate. Silvermoon City:", at = { SILVERMOON, 54.7, 69.9 } },
        { t = "The Arcantina.", at = { ARCANTINA, 59.2, 72.5 } },
        { t = "Tranquillien, Eversong Woods.", at = { EVERSONG, 47.8, 67.7 } },
        { t = "Amani'Zar, Zul'Aman.", at = { ZULAMAN, 45.4, 65.1 } },
        { t = "Witherbark Bluffs, Zul'Aman.", at = { ZULAMAN, 37.3, 22.9 } },
        { t = "The Den, Harandar (inside).", at = { THE_DEN, 64.2, 60.7 } },
        { t = "Har'athir, Harandar.", at = { HARANDAR, 69.1, 51.2 } },
        { t = "Locus Point, Voidstorm.", at = { VOIDSTORM, 41.7, 74.5 } },
    }
    N[63253] = "Each barrel's quest is a small gold donation; only during Brewfest."
    N[41212] = "During Brewfest, click the Bar Tab Barrel in each listed Khaz Algar tavern and donate: track it and the arrow goes to the next one."
    N[18579] = "During Brewfest, click the Bar Tab Barrel in each listed Dragon Isles tavern and donate: track it and the arrow goes to the next one."
    N[1683] = "Five achievements for the title Brewmaster: expand it, each one has its guide."

    local KEG = "Can be in the Keg-Shaped Treasure Chest from your first Coren Direbrew kill of the day."
    local BANQUET = "From the Bag of Brewfest Merchandise, a reward of the Brewfest Banquet event at the camps."
    AddItems("brewfest", {
        { 150922, KEG }, { 208742, KEG .. " Only the first kill of the day, account-wide, and the chance grows each new day." },
        { 245950, BANQUET }, { 246801, BANQUET }, { 246784, BANQUET }, { 245955, BANQUET }, { 245959, BANQUET },
        { 56836, "The reward of A New Supplier of Souvenirs, a Brewfest quest at the camp." },
    })
end

------------------------------------------------------------------------
-- Hallow's End, the rest (checked 2026-10-22 against the holiday's full guide)
------------------------------------------------------------------------
do
    -- the Den's candy bucket: the reference list's x was a typo (24.8); the bucket is by the Den's inn
    local m = ns.CRIT_NOTES and ns.CRIT_NOTES[63400]
    if m then
        m["Harandar, The Den"] = { t = "The candy bucket is inside the Den, by its inn.", at = { { 2576, 64.82, 63.82 }, { 2413, 51.2, 53.2 } } }
        m["Eversong Woods, Arcantina"] = { t = "The candy bucket is inside the Arcantina; its door is in Silvermoon City.", at = { { 2541, 62.73, 71.0 }, { 2393, 56.46, 70.86 } } }
    end
    AddItems("hallows", {
        { 71076, "The reward of The Creepy Crate, the last quest of the Fenlow sisters' story (Hallow's End); also sold by some pet vendors." },
        { 139133, "In the Hag's Belongings from the daily Under the Crooked Tree in Val'sharah (defeat Aria Sorrowheart)." },
        { 139134, "In the Hag's Belongings from the daily Under the Crooked Tree in Val'sharah (defeat Aria Sorrowheart)." },
        { 139135, "In the Hag's Belongings from the daily Under the Crooked Tree in Val'sharah (defeat Aria Sorrowheart)." },
        { 139136, "In the Hag's Belongings from the daily Under the Crooked Tree in Val'sharah (defeat Aria Sorrowheart)." },
        { 208680, "Can be in the Loot-Filled Pumpkin from your first Headless Horseman kill of the day." },
    })
end

------------------------------------------------------------------------
-- Day of the Dead (checked 2026-10-22): Catrina and Chapman stand by the graveyards.
------------------------------------------------------------------------
do
    local GRAVE = { { side = "Alliance", t = "Catrina and Chapman by the Stormwind graveyard (also outside Ironforge, in Darnassus and on Azuremyst Isle).", at = { 84, 47.0, 26.0 } },
                    { side = "Horde", t = "Catrina and Chapman by the graveyard outside Orgrimmar (also in Thunder Bluff, Eversong Woods and Tirisfal).", at = { DUROTAR, 47.2, 17.8 } } }
    S[3456] = { GRAVE[1], GRAVE[2], { t = "Target Catrina and type /dance: you turn into a skeleton for twelve hours and get the achievement." } }
    local CONTENDER = { t = "Buy a contender's costume toy from Chapman (10 gold) and use it: you get an action to fight other players in a costume." }
    S[9426] = { GRAVE[1], GRAVE[2], CONTENDER, { t = "Defeat one other costumed player." } }
    S[9427] = { GRAVE[1], GRAVE[2], CONTENDER, { t = "Defeat 20 other costumed players." } }
    S[9428] = { GRAVE[1], GRAVE[2], CONTENDER, { t = "Defeat 50 other costumed players." } }
    local DUEL = { "Only killing blows on other costumed players count.", "Players duel a friend inside an instance, both in costume: no corpse runs and no resurrection timer.", "The costumes are toys: once bought, they work all year." }
    N[9426] = DUEL; N[9427] = DUEL; N[9428] = DUEL
    AddItems("dead", { { 46831, "The reward of The Grateful Dead: use an Orange Marigold by your capital's graveyard and give the spirit Bread of the Dead (recipe from Chapman, cooking skill 1)." } })
end

------------------------------------------------------------------------
-- Pirates' Day (checked 2026-10-22)
------------------------------------------------------------------------
do
    S[3457] = { { t = "On Pirates' Day (19 September, one day), go up to the roof of the bank in Booty Bay: take the stairs up through Baron Revilgaz's room.", at = { 210, 40.0, 72.5 } },
                { t = "Talk to Dread Captain DeMeza and choose to drink with her: you join her crew (a pirate costume for 12 hours) and get the achievement." } }
end

------------------------------------------------------------------------
-- Darkmoon Faire, the rest (checked 2026-10-22 against the Faire's full guide)
------------------------------------------------------------------------
do
    local DMF = 407
    local GET_THERE = { { side = "Alliance", t = "During the Faire, a Darkmoon Faire Mystic Mage in Stormwind ports you to the Faire's portal in Elwynn Forest; take the portal to Darkmoon Island.", at = { 84, 62.2, 73.0 } },
                        { side = "Horde", t = "During the Faire, a Darkmoon Faire Mystic Mage in Orgrimmar ports you to the Faire's portal in Mulgore; take the portal to Darkmoon Island.", at = { 85, 48.2, 62.0 } } }
    S[6019] = { GET_THERE[1], GET_THERE[2], { t = "Arriving on Darkmoon Island is enough." } }
    S[6020] = { GET_THERE[1], GET_THERE[2], { t = "Play five different games: Whack-a-Gnoll, the cannon, the Shooting Gallery, Ring Toss and the Tonk Challenge (Firebird's Challenge doesn't count). Each game master gives a daily quest for it." } }
    S[6025] = { { t = "Go to the petting zoo by the boardwalk, then past it, away from the road, to the pony pen in the south-east. Click a pony to ride it.", at = { DMF, 57.0, 82.0 } } }
    S[6026] = { { t = "Buy and eat the 10 foods Stamp Thunderhorn sells at his stall.", at = { DMF, 52.6, 67.8 } },
                { t = "Buy and drink the 8 drinks Sylannia sells next to him.", at = { DMF, 50.6, 69.6 } } }
    N[6026] = { "Two of the drinks need level 85.", "Some also come from the Faire's fishing crates, but buying them is quicker." }
    S[6029] = { { t = "Keep the Darkmoon Adventurer's Guide in your bags and turn in all nine Darkmoon artifacts on the island: the five from dungeons, the three from battlegrounds and the Soothsayer's Runes." } }
    N[6029] = "All nine are sold on the auction house; players report several no longer drop for max-level characters."
    local FIREWORK = { t = "Buy Darkmoon Fireworks from Boomie Sparks at the Faire (10 Darkmoon Prize Tickets each); you need six. They only work while the Faire is on.", at = { DMF, 48.5, 71.8 } }
    S[6030] = { FIREWORK, { t = "Set one off in Stormwind, Ironforge, Darnassus, the Exodar, Shattrath and Dalaran (Northrend)." } }
    S[6031] = { FIREWORK, { t = "Set one off in Orgrimmar, Thunder Bluff, Silvermoon City, the Undercity (not the Ruins of Lordaeron), Shattrath and Dalaran (Northrend)." } }
    N[6030] = "Darnassus needs Zidormi in Darkshore (48.8, 24.5) to see the old Teldrassil."
    N[6031] = "The Undercity needs Zidormi in Tirisfal Glades (69.4, 62.8) to see the old city."
    S[6032] = { { t = "Do five of the Faire's profession quests (at skill 75 or higher in that profession): two for your main professions, plus the cooking, fishing and archaeology ones, which anyone can learn." } }
    N[6032] = "They don't need to be at the same Faire."
    S[6332] = { { t = "Wait for the Darkmoon Rabbit at the cave south-east of the Faire and kill it. It's a rare on a long timer.", at = { DMF, 77.8, 83.8 } } }
    N[6332] = "Easy to kill at max level; the wait is the hard part."
end

------------------------------------------------------------------------
-- Hallow's End, step by step (checked 2026-10-22)
------------------------------------------------------------------------
do
    local VEND = { { side = "Alliance", t = "Dorothy, the Hallow's End vendor outside Stormwind's gate (Tricky Treats).", at = { ELWYNN, 31.8, 50.0 } },
                   { side = "Horde", t = "Chub, the Hallow's End vendor by the Undercity entrance in Tirisfal Glades (Tricky Treats).", at = { TIRISFAL, 62.2, 66.4 } } }
    local function vend(rest) local out = { VEND[1], VEND[2] } for _, x in ipairs(rest) do out[#out + 1] = x end return out end
    local TREATS = "Tricky Treats come from candy buckets in inns and the holiday's quests."
    S[972] = { { t = "Click a candy bucket in any inn (every inn has one during Hallow's End)." } }
    S[981] = vend({ { t = "Buy a Tooth Pick there (treat bags can also have one) and use it." } })
    S[288] = vend({ { t = "Buy Tricky Treats or use the ones from candy buckets, and eat them until you get the Upset Tummy; usually fewer than five." } })
    S[283] = vend({ { t = "Buy Hallowed Wands there and use them on yourself or a friend, or ask other players to wand you: you need to be turned into each of the seven costumes the achievement lists (pirate, ninja, leper gnome, ghost, bat, skeleton, wisp)." } })
    N[283] = "The Random wand doesn't count: buy the specific ones you still need."
    S[292] = vend({ { t = "Get the Sinister Squashling pet and the Hallowed Helm: both can come from the Headless Horseman's loot, or buy each there for Tricky Treats." } })
    N[292] = { TREATS, "If you own the helm's look but never looted it on this character, buying it still counts; you can sell it back for the treats." }
    S[289] = {
        { side = "Alliance", t = "Go to Goldshire (or Kharanos, or Azure Watch). Take the water-bucket practice quest there.", at = { ELWYNN, 42.5, 65.8 } },
        { side = "Horde", t = "Go to Razor Hill (or Brill, or Falconwing Square). Take the water-bucket practice quest there.", at = { DUROTAR, 52.2, 41.5 } },
        { t = "When the Headless Horseman attacks the village (on the half hour), throw water at the fires with the other players until every fire is out." } }
    N[289] = "Join a group with the other players there: the fires go out faster."
    S[291] = { { t = "Get Weighted Jack-o'-Lanterns: they come from the Horseman's loot and the village fire quest's gift." },
               { t = "Throw one at a player of each race the achievement lists." } }
    S[1261] = { { t = "Get G.N.E.R.D.S. candy from the candy buckets in inns and eat one for the G.N.E.R.D. buff." },
                { t = "With the buff on, get 10 honorable kills: a battleground is the easiest place." } }
    N[1261] = "The buff ends when you die."
    local HORSEMAN = { t = "Queue for the Headless Horseman in the Dungeon Finder (the holiday dungeon in the Scarlet Monastery graveyard)." }
    S[18959] = { HORSEMAN, { t = "Defeat him. Your first kill each day gives the Loot-Filled Pumpkin." } }
    S[18962] = { HORSEMAN, { t = "Defeat him; any kill during the holiday counts." } }
    S[18960] = { HORSEMAN, { t = "Inside, talk to the wicker men before the fight to add their curses, then defeat the Horseman." } }
    S[10365] = { { side = "Alliance", t = "In your level 3 garrison in Shadowmoon Valley (Draenor), go to the graveyard in the south-west corner: Pepe in his scarecrow costume sits on a gravestone. Click him." },
                 { side = "Horde", t = "In your level 3 garrison in Frostfire Ridge (Draenor), go behind it to the stone with part of the Horde emblem carved in it: Pepe sits on it in his scarecrow costume. Click him." } }
    N[10365] = { "Only during Hallow's End, and only in a level 3 garrison. He can't be targeted: click him.", "Since 2026 it also gives Scarecrow Pepe for your house." }
    S[971] = { { t = "Finish Tricks and Treats of Eastern Kingdoms, of Kalimdor and of Outland (expand it: each one lists its inns, and the arrow goes to the next candy bucket)." } }
end

------------------------------------------------------------------------
-- New holiday activities the step lists didn't have yet (checked 2026-10-22)
------------------------------------------------------------------------
do
    local function addSteps(key, list)
        for _, def in ipairs(ns.EVENT_DEFS or {}) do
            if def.key == key then
                def.steps = def.steps or {}
                for _, st in ipairs(list) do def.steps[#def.steps + 1] = st end
            end
        end
    end
    addSteps("midsummer", {
        { "Ignite the Skies", group = "Skyriding (new in 2026)", q = { A = 92711, H = 92435 },
          note = "Aedh Firebeard at the Stormwind camp (Elder Sunhorn at the Orgrimmar camp for the Horde) starts a skyriding chain: fly through Airborne Sun Blossoms (small ones 1 point, large ones 3) across the Eastern Kingdoms and Kalimdor. Air streams lead the way; steady flight works too. It pays a lot of Burning Blossoms." },
        { "Ignite the Skies dailies", group = "Every day", daily = true, any = true, q = { 92836, 92839 },
          note = "Unlocked once you finish the first continent's Ignite the Skies quests." },
        { "The Frost Lord's introduction", group = "Get started", q = 92185,
          note = "Optional: the festival storyteller at the Stormwind or Orgrimmar camp offers it before your first Ahune kill, for extra gold." },
    })
    addSteps("children", {
        { "Nap Mat", group = "Rewards", npc = 264060, at = { 2393, 51.2, 76.2 },
          note = "Jepetto Joybuzz in Silvermoon City sells the Nap Mat toy for one Well-loved Figurine (choose the figurine as an orphan's reward)." },
    })
end

------------------------------------------------------------------------
-- WoW's Anniversary (new page, checked 2026-10-24): every November in Tanaris, outside the Caverns of Time. The
-- 22nd runs 17 November to 8 December 2026. The achievements are the ones from the 20th and 21st anniversaries.
------------------------------------------------------------------------
do
    local TANARIS, AZSHARA, DUSKWOOD, HINTERLANDS, BLASTED, ASHENVALE, FERALAS = 71, 76, 47, 26, 17, 63, 69
    ns.EVENT_DEFS[#ns.EVENT_DEFS + 1] = {
        key = "anniversary", id = 1808, ids = { 1500, 1501 }, name = "WoW's Anniversary", short = "Anniversary", iconAch = 40870,
        lootText = "From the anniversary vendors in Tanaris (Timewarped Badges) or the anniversary world bosses.",
        calendar = { "Anniversary" }, hub = TANARIS,
        dates = { { { 2026, 11, 17, 10 }, { 2026, 12, 8, 10 } } },
        desc = "Celebration grounds outside the Caverns of Time: games, stories, world bosses and a Blackrock Depths raid.",
        intro = "Three weeks each November. Most activities run on the hour at the grounds in Tanaris; the world bosses "
            .. "and the Blackrock Depths raid give the biggest rewards. Azeroth's Greatest Detective gives a title.",
        steps = {
            { "The celebration grounds", group = "Get started", at = { TANARIS, 63.0, 50.5 },
              note = "Outside the Caverns of Time in Tanaris. Portals in the capitals' portal rooms take you to the Caverns of Time." },
            { "Fashion Frenzy", group = "Every hour", ach = 40987, at = { TANARIS, 63.4, 49.1 },
              note = "Starts 10 minutes past the hour: dress to the theme (a free outfit change), then vote with the ribbon." },
            { "Lorewalker Cho's stories", group = "Every hour", ach = 40993, at = { TANARIS, 64.1, 51.8 },
              note = "Half past the hour. React with the buttons he offers; throwing things at the stage can be repeated." },
            { "Mount Mania", group = "Every hour", ach = 40985, note = "Copy the host's mount, close to the stage." },
            { "Balloons", group = "Any time", ach = 40990, at = { TANARIS, 64.2, 50.0 }, note = "Isaandrae sends out the balloons." },
            { "Pet Corner", group = "Any time", ach = 40989, at = { TANARIS, 62.0, 50.1 }, note = "The Pet Box gives the Pet Mirror." },
            { "Vista portals", group = "Any time", ach = 40988, at = { TANARIS, 62.4, 49.4 }, note = "Three blue portals to other zones; they change every day." },
            { "World bosses", group = "Every day", daily = true, ach = { 40995, 40997 }, note = "One loot per boss each day." },
        },
    }
    local G1, G2 = "Azeroth's Greatest Detective (meta)", "More achievements"
    ns.EVENT_ACHS = ns.EVENT_ACHS or {}
    ns.EVENT_ACHS.anniversary = {
        { 40870, 0, G1 }, { 40871, 0, G1 }, { 40872, 0, G1 }, { 40873, 0, G1 }, { 40979, 0, G1 },
        { 40995, 0, G2 }, { 40994, 0, G2 }, { 40997, 0, G2 }, { 40996, 0, G2 }, { 40999, 0, G2 }, { 41015, 0, G2 },
        { 41000, 0, G2 }, { 40998, 0, G2 }, { 40977, 0, G2 }, { 41013, 0, G2 }, { 41033, 0, G2 },
        { 40987, 0, G2 }, { 40984, 0, G2 }, { 40985, 0, G2 }, { 40986, 0, G2 }, { 40989, 0, G2 }, { 40661, 0, G2 },
        { 40990, 0, G2 }, { 40991, 0, G2 }, { 40992, 0, G2 }, { 40993, 0, G2 }, { 40988, 0, G2 },
    }

    local GROUNDS = { t = "Go to the celebration grounds outside the Caverns of Time in Tanaris during the anniversary.", at = { TANARIS, 63.0, 50.5 } }
    local function here(rest) local out = { GROUNDS } for _, x in ipairs(rest) do out[#out + 1] = x end return out end
    S[40995] = {
        { t = "Defeat each of the six old world bosses while the anniversary is on (one loot each day):" },
        { t = "Azuregos in Azshara.", at = { AZSHARA, 49.2, 83.0 } },
        { t = "Lord Kazzak in the Blasted Lands.", at = { BLASTED, 32.3, 49.6 } },
        { t = "Lethon in the Hinterlands.", at = { HINTERLANDS, 63.6, 27.2 } },
        { t = "Emeriss in Duskwood.", at = { DUSKWOOD, 44.8, 39.7 } },
        { t = "Taerar in Ashenvale.", at = { ASHENVALE, 93.8, 40.6 } },
        { t = "Ysondre in Feralas.", at = { FERALAS, 50.6, 12.1 } },
    }
    N[40995] = "If Lord Kazzak doesn't show, talk to Zidormi at the north of the Blasted Lands (48.2, 7.2) to see the zone before the invasion."
    S[40994] = { S[40995][1], S[40995][2], S[40995][3], S[40995][4], S[40995][5], S[40995][6], S[40995][7] }
    S[40994][1] = { t = "Defeat any one of the six old world bosses while the anniversary is on:" }
    S[40997] = {
        { t = "Defeat the three anniversary world bosses in Tanaris while the event is on:" },
        { t = "Doomwalker, by the celebration grounds.", at = { TANARIS, 62.7, 50.0 } },
        { t = "Sha of Anger, in the west of Tanaris.", at = { TANARIS, 33.6, 55.5 } },
        { t = "Archavon the Stone Watcher, in the north of Tanaris.", at = { TANARIS, 45.6, 29.4 } },
    }
    S[40996] = { { t = "Defeat any one of the three anniversary world bosses in Tanaris:" }, S[40997][2], S[40997][3], S[40997][4] }
    N[40997] = "Archavon can drop the Grand Black War Mammoth and the Sha of Anger the Heavenly Onyx Cloud Serpent."
    local BRD = { t = "Talk to Moira by the Dark Iron Mole Machine at the grounds and queue for the Blackrock Depths anniversary raid (Raid Finder works)." }
    S[40999] = here({ BRD, { t = "Defeat every boss the achievement lists, wing by wing. Phalanx is in the Grim Guzzler part of the second wing: go around the big circle." } })
    S[41015] = here({ BRD, { t = "After bosses and some big enemies die, a small glowing orb (a Temporal Missive from Moira) appears: click it. Find all thirteen across the three wings." } })
    N[41015] = "Anyone can click a missive and everyone nearby gets credit; it comes back after about ten seconds."
    N[40999] = "In 2025 only Raid Finder was offered; it counts."
    local TW = { t = "Queue for Classic Timewalking in the Dungeon Finder during the anniversary." }
    S[41000] = { TW, { t = "Finish all six: the Deadmines, both Dire Maul wings (Warpwood Quarters, Capital Gardens), Zul'Farrak and both Stratholme sides. You can't choose, so keep queueing." } }
    S[40998] = { TW, { t = "Finish any one Classic Timewalking dungeon." } }
    S[40977] = here({ { t = "Take Chromie's Codex quest at the grounds and queue for the scenario The Codex of Chromie: follow Chromie through the Gates of Ahn'Qiraj, about five minutes." } })
    local T2 = { t = "Buy an Eternal Tier 2 armor ensemble from Traeya in the middle of the grounds (Timewarped Badges).", at = { TANARIS, 63.0, 50.8 } }
    S[41013] = { T2 }
    S[41033] = { T2, { t = "Buy a second one. Any class's set counts, and you can sell it back for a full refund after the achievement." } }
    S[40987] = here({ { t = "At 10 minutes past the hour, join the Fashion Frenzy at the stage. Change into the theme when asked, then take a ribbon from the table and give it to another player.", at = { TANARIS, 63.4, 49.1 } } })
    S[40984] = here({ { t = "Give 20 ribbons over one or more Fashion Frenzies: each ribbon has five votes." , at = { TANARIS, 63.4, 49.1 } } })
    S[40985] = here({ { t = "Join Mount Mania by the stage: when the host shows a mount, summon the same one. Stay close to the stage or it doesn't count." } })
    S[40986] = here({ { t = "Match 20 mounts in Mount Mania; matches add up over several sessions." } })
    N[40985] = "A macro that copies your target's mount helps: target the host."; N[40986] = N[40985]
    S[40989] = here({ { t = "Click the Pet Box at Pet Corner for a Pet Mirror and use it: you look like your pet.", at = { TANARIS, 62.0, 50.1 } } })
    N[40989] = "Only the Pet Mirror from the box works, not other pet-disguise toys."
    S[40661] = here({ { t = "As a pet (Pet Mirror from the Pet Box), pick up Zoomy Treats on the ground: each gives four seconds of zoomies. Chain them for more than 20 seconds.", at = { TANARIS, 62.0, 50.1 } } })
    N[40661] = "Find three or four treats close together; they come back quickly."
    S[40990] = here({ { t = "Isaandrae near the Caverns of Time entrance sends out balloons: grab one and ride it for about half a minute.", at = { TANARIS, 64.2, 50.0 } } })
    S[40991] = here({ { t = "Ride all four balloons from Isaandrae: gold, bronze, dark blue and light blue.", at = { TANARIS, 64.2, 50.0 } } })
    S[40992] = here({ { t = "At half past the hour, watch Lorewalker Cho's story and react with the buttons he offers: 50 reactions in all.", at = { TANARIS, 64.1, 51.8 } } })
    N[40992] = "Throwing things at the stage can be pressed again and again."
    S[40993] = here({ { t = "Listen to all three of Lorewalker Cho's stories: the Heroes of the Scarab Wall, the Tragedy of Thassarian and the Mercy of Baine Bloodhoof. He picks one each time.", at = { TANARIS, 64.1, 51.8 } } })
    S[40988] = here({ { t = "Take the vista portals at the grounds: each sends you to a zone the achievement lists. Visit ten.", at = { TANARIS, 62.4, 49.4 } } })
    N[40988] = "The three portals change every day, so it takes a few days."
    local ALYX = { t = "Talk to Alyx in the big main tent at the grounds: she runs Guest Relations. New quests open every day during the event.", at = { TANARIS, 63.0, 50.3 } }
    S[40872] = here({ ALYX, { t = "Do the Guest Relations story: four chapters, one after another as they open." } })
    S[40871] = here({ ALYX, { t = "Solve each hidden local story (the achievement names them): each starts from a clue at the grounds and sends you around the world." } })
    S[40873] = here({ ALYX, { t = "Find and return 6 Celebration Crates: their clues come from the Guest Relations stories (the first is a ransom note on the board behind Alyx)." } })
    S[40979] = here({ ALYX, { t = "Find and return every Celebration Crate." } })
    N[40871] = { "Players report some clues didn't show at first in 2025; check again the next day.", "The clues are puzzles that change little from year to year." }
    N[40873] = "Some crates were missing in 2025 (Hyjal, Azsuna) according to players; check back later in the event."
    N[40870] = "Two of the four Guest Relations achievements give the title Azeroth's Greatest Detective."

    local BOSS = "During the anniversary: "
    ns.EVENT_ITEMS = ns.EVENT_ITEMS or {}
    ns.EVENT_ITEMS.anniversary = ns.EVENT_ITEMS.anniversary or {}
    AddItems("anniversary", {
        { 43959, BOSS .. "can drop from Archavon the Stone Watcher in Tanaris." },
        { 87771, BOSS .. "can drop from the Sha of Anger in Tanaris." },
        { 172022, "The reward of the Korrak's Revenge battleground quest (Alliance), during the anniversary." },
        { 172023, "The reward of the Korrak's Revenge battleground quest (Horde), during the anniversary." },
        { 231906, "The reward of I Saved the Party and All I Got Were These Lousy Hats (the Guest Relations story)." },
    })
end

------------------------------------------------------------------------
-- Turbulent Timeways (new page, checked 2026-10-24): a Timewalking event that comes back from time to time; the
-- calendar says when. Its achievement only counts while the event runs.
------------------------------------------------------------------------
do
    ns.EVENT_DEFS[#ns.EVENT_DEFS + 1] = {
        key = "timeways", id = 1425, name = "Turbulent Timeways", short = "Timeways", iconAch = 61463,
        lootText = "From Timewalking dungeons during the event.",
        calendar = { "Turbulent Timeways" },
        desc = "A run of Timewalking weeks: a different expansion's dungeons each week.",
        intro = "Each week of the event opens a different expansion's Timewalking. Finishing four Timewalking dungeons in a row "
            .. "turns Knowledge of Timeways into Mastery of Timeways. The calendar shows when the event is back.",
        steps = {
            { "Mastery of Timeways", group = "Every week", ach = 61463,
              note = "Queue for Timewalking in the Dungeon Finder. Four dungeons give four stacks of Knowledge of Timeways, which become Mastery of Timeways." },
        },
    }
    ns.EVENT_ACHS.timeways = { { 61463, 0, "More achievements" } }
    S[61463] = { { t = "While Turbulent Timeways is on, queue for Timewalking in the Dungeon Finder and finish four dungeons: Knowledge of Timeways becomes Mastery of Timeways." },
                 { t = "Get Mastery of Timeways in four different weeks of the event." } }
    N[61463] = { "The event lasts only a few weeks, so start in its first week.", "Players reported in 2026 that progress sometimes didn't count a week: track it in the achievement window to check." }
end
