-- Completion: step-by-step guides for War Within achievements, researched from players' tips (own words).
-- Same shape as the other Guides files; loaded after them, before the generated guides, so these win
-- over generated steps but never over an earlier hand-written guide of the same achievement.

local _, ns = ...

local DORN, DORNOGAL, DEEPS, HALLOWFALL, AZJ, THREADS, LOWER, UNDERMINE, SIREN, KARESH, TAZAVESH =
    2248, 2339, 2214, 2215, 2255, 2213, 2216, 2346, 2369, 2371, 2472

local G = {}

-- GUIDES

-- The Knife's Edge: the K'aresh story
G[41970] = {
    steps = {
        { t = "Pick up the K'aresh story in Dornogal (the quest giver near the north of the city).", at = { DORNOGAL, 42.15, 27.19 } },
        { t = "Follow it to Tazavesh, the Veiled Market: A Shadowy Invitation is the first storyline.", at = { TAZAVESH, 56.74, 73.22 } },
        { t = "Continue through Desert Power, The Light of K'aresh, Void Alliance and Shadows En Garde; the book's arrow follows each next quest." },
    },
}

-- Sojourner of K'aresh: where each optional storyline starts
G[42739] = {
    steps = {
        { t = "Expand the achievement: each storyline row has its starting point; do them in any order." },
        { t = "Several only appear once the K'aresh story has reached them; if a start isn't on your map, come back after the next story chapter." },
    },
    crit = {
        ["A Stranger's Gift"] = { t = "Starts with Stranger on the Steps", at = { { KARESH, 56.96, 57.37 } } },
        ["Of Boughs and Bonds"] = { t = "Starts with Bridge to Nowhere", at = { { KARESH, 54.48, 63.70 } } },
        ["In Search of Darkness"] = { t = "Starts with A Common Cause", at = { { KARESH, 60.90, 27.77 } } },
        ["Priest of the Old Ways"] = { t = "An Outcast's Request starts here (not always marked on the map)", at = { { KARESH, 77.67, 39.82 } } },
        ["Lost and Found Storage"] = { t = "Starts with A Lucrative Opportunity in Tazavesh", at = { { TAZAVESH, 47.97, 24.57 } } },
    },
}

G[61451] = {
    steps = {
        { t = "Expand the achievement: it lists the War Within metas needed (raids, delves, Flame's Radiance, Xal'atath's schemes...), each with its own guide." },
        { t = "Finish each of them; the reward is a mount and a decor piece." },
    },
}

-- Treasures with a twist
G[40434] = {
    steps = {
        { t = "Expand the achievement: every treasure has its spot, and tracking leads treasure to treasure." },
        { t = "Several need a small task first; hover each treasure's row for what to do." },
    },
    tips = {
        "Tree's Treasure: get the Crab-Guiding Branch from Freysworn Letitia in the cave, then chase six shellcrabs home.",
        "Magical Treasure Chest: push Lionel into the water, talk to him, then feed him five Plump Snapcrabs from the shore.",
        "The mushroom treasure: talk to U'llort on the big rock and find his hat in the forest nearby.",
    },
}
G[40724] = {
    steps = {
        { t = "Expand the achievement: every treasure has its spot (current positions)." },
        { t = "Kaja'Cola Machine: press the flavours in this order: Bluesberry Blast, Orange O-pocalypse, Oyster Outburst, Mangoro Mania." },
        { t = "Dusty Prospector's Chest: first collect the five gems scattered around the zone (each has its own spot), then open the chest." },
    },
}
G[40828] = {
    steps = {
        { t = "Expand the achievement: every treasure has its spot." },
        { t = "Hover each row for its requirement (some need threads collected first or sit high on webs: look up)." },
    },
    tips = { "Players reported a few treasures not counting at first; if one doesn't tick, try again later." },
}
G[40848] = {
    steps = {
        { t = "Expand the achievement: every treasure has its spot; hover each row for what to do." },
        { t = "Sunken cache: find the four airships flying over Hallowfall and talk to each captain; the cache then appears near the centre of the zone.", at = { HALLOWFALL, 45.9, 45.24 } },
        { t = "The treasure that needs an item: buy it at Dunelle's Kindness first, then hand it to the waiting NPC.", at = { HALLOWFALL, 69.25, 43.95 } },
    },
}

-- Rares with a twist
G[40435] = {
    steps = {
        { t = "Expand the achievement: every rare has its spot; tracking it patrols them and points at any that's up." },
        { t = "Defeat ten of them." },
    },
    tips = {
        "Zovex, Kereke and Rotfist share one spot and take turns.",
        "Kronolith sits on top of a mountain and can slam you off.",
    },
}
G[40837] = {
    steps = {
        { t = "Expand the achievement: every rare has its spot (current positions)." },
        { t = "Defeat ten of them." },
    },
    tips = {
        "Lurker of the Deeps is summoned by pulling five levers spread around the zone.",
        "Trungal: kill the Root of Trungal enemies by its cave to make it appear.",
        "Deathbound Husk is inside a cave; use the entrance just east of its spot.",
    },
}
G[41046] = {
    steps = {
        { t = "Siren Isle's rares change with the weekly invasion (vrykul, then naga, then pirates): this takes at least three weeks." },
        { t = "Expand the achievement and kill each rare of the current week; event bosses spawn from the island's events (the Drowned Lair, the Drain, the Shuddering Hollow)." },
        { t = "Come back each week for the next invasion's rares." },
    },
    tips = { "Rares turn grey when too many people tag them: a five-player party makes sure everyone gets credit." },
}

G[41188] = {
    steps = {
        { t = "Expand the achievement: it lists the Hallowfall achievements needed, each with its own guide." },
        { t = "Start the timegated ones first: Children's Entertainer needs the Work Hard, Play Hard world quest, and Lost and Found takes three weekly resets." },
        { t = "Fill in the rest while you wait." },
    },
    tips = { "Several level-capped alts help: each can do a few of the orphan games whenever the world quest is up." },
}
G[41186] = {
    steps = {
        { t = "Expand the achievement: it lists the Isle of Dorn achievements needed, each with its own guide." },
        { t = "Finish each of them." },
    },
    tips = { "It unlocks a decor item for purchase from the Dornogal vendor rather than giving it directly." },
}
G[41555] = {
    steps = {
        { t = "Expand the achievement: the Khaz Algar achievements needed are listed, each with its own guide." },
        { t = "Glyph Hunter, Lore Hunter and Flight Master can be done in about an hour of flying." },
        { t = "When it completes, relog if the new Earthen campsite (character-select background) doesn't show." },
    },
}
G[41586] = {
    steps = {
        { t = "First finish the first four chapters of the Undermine story (through Breaking the Shackles): several parts only appear after that." },
        { t = "Expand the achievement: each part has its own guide. Work round the city clockwise from Slam Central Station." },
        { t = "Leave Adventurer of Undermine (ten rares) for whenever rares are up." },
    },
    tips = { "That Can-Do Attitude: you can kick the same can several times." },
}
G[41588] = {
    steps = {
        { t = "Finish the Undermine story through chapter 4, Breaking the Shackles: the Undermine notes only appear after it (then they're marked on your map)." },
        { t = "Expand the achievement: each note has its spot. Two (the drill safety manuals) are in the Ringing Deeps, the rest in Undermine." },
        { t = "Several lie in sewers or caves: open the sewer grate at the marked spot and drop down." },
    },
}
G[42741] = {
    steps = {
        { t = "Finish the K'aresh story to get the Reshii Wraps." },
        { t = "Upgrade them to rank 4, What Lies Beyond, so you can see treasures while Phase Diving." },
        { t = "Expand the achievement: every treasure has its spot. Some are in the normal world, others only while Phase Diving or in untethered space (enter through the rifts around the map)." },
    },
}
G[42761] = {
    steps = {
        { t = "Expand the achievement: every rare has its spot; some are in the normal world, some only while Phase Diving or in untethered space." },
        { t = "Malek'ta: jump repeatedly on its spot until it bursts out of the ground." },
        { t = "Heka'tamos at the Oasis: click the four glowing objects around it for their buffs (3 minutes each), then use the Brazier of Elemental Union." },
        { t = "Two rares only come with a weekly warrant quest; check each week which warrant is up." },
    },
}
G[60890] = {
    steps = {
        { t = "Get the Reshii Wraps' Phase Diving: several lore objects can only be seen while phase diving." },
        { t = "Expand the achievement: every object has its spot, in K'aresh and Tazavesh. Read each one (each gives K'aresh Trust reputation)." },
    },
}
G[41200] = {
    steps = {
        { t = "Do the questline that ends with Grand, Gutsy Solutions." },
        { t = "Hand in the last quest; the achievement and a battle pet come with it." },
    },
}

G[41081] = {
    steps = {
        { t = "The four Undermine car races (Sandy Scuttle, Breakneck Bolt, Junkyard Jaunt, Casino Cruise) are driven in your D.R.I.V.E. car, not flown." },
        { t = "Drive to each start (the arrow shows them) and finish each race forwards and in reverse; any time counts." },
        { t = "The Pozzix engine reward arrives by mail." },
    },
}
G[41084] = {
    steps = {
        { t = "Upgrade the D.R.I.V.E. car first: the engine from the bronze achievement, plus the parts sold for Engineering and dropped by rares (or bought on the Auction House)." },
        { t = "Earn gold in each car race, forwards and in reverse." },
        { t = "Trick: press the race's reset button right after passing the second-to-last ring; it teleports you to the last ring and still counts." },
    },
}
G[40537] = {
    steps = {
        { t = "Expand the achievement: it lists every delve's Stories achievement, each with its own guide." },
        { t = "Check today's stories without entering: they show on the delve's tier menu (and on the map since patch 11.2)." },
        { t = "Run the delves whose story you still need; come back on other days for the rest." },
    },
}
G[41115] = {
    steps = {
        { t = "Finish the three role achievements below: every Khaz Algar delve on Tier 4 or higher with lives left as damage, as healer and as tank." },
        { t = "Only your role on the final boss counts, so you can play any spec and switch before the last boss." },
    },
}
G[41116] = G[41115]
G[41597] = {
    steps = {
        { t = "Expand the achievement: each Manaforge Omega raid achievement has its own step guide." },
        { t = "Don't use the raid skip to Nexus-King: after Forgeweaver you can't get back from the soul hunters' area if you release after a wipe." },
        { t = "Bring a warlock to soulstone a healer on the long-walk fights (Fractillus, Forgeweaver). Of Mice and Manaforges and Breaking the Fourth Wall are the hard ones." },
    },
}
G[41966] = {
    steps = {
        { t = "Finish both Beyond the Most Horrific Vision achievements: every objective in Stormwind and in Orgrimmar with all eight masks." },
        { t = "These don't have to be soloed: bring a full group." },
    },
    tips = { "Players report much harder scaling since the Midnight pre-patch." },
}
G[40097] = {
    steps = {
        { t = "Keep War Mode on for everything; without it nothing counts." },
        { t = "Sparks of War (20 completions): each week, do Sparks of War for the zone it names; collect 100 sparks there from world quests (10 each), rares (7-9) and the zone's PvP objectives. Alts speed this up a lot." },
        { t = "Do the other parts as they come: World PvP world quests, Unbound Spoils, air-drop crates and bounties (each has its own guide)." },
    },
    tips = { "You can finish it without killing a single player." },
}
G[41551] = {
    steps = {
        { t = "Finish each Undermine family battler achievement below (beat the four Undermine tamers with a team of one family)." },
        { t = "The tamers: Precision Powerdrill, Baxx the Purveyor, Prezly Wavecutter and Creech, each marked on the Undermine map." },
    },
    tips = { "Player pet guide sites have step-by-step teams for every family." },
}

local DEEPS, HALLOW = 2214, 2215
local starts = function(map, list, dx)
    local c = {}
    for _, s in ipairs(list) do
        -- most rows already have their spot; only fill the missing ones
        c[s[1]] = { t = "Starts with " .. s[2] .. ".", at = s[5] and { { map, s[3] - (dx or 0), s[4] } } or nil }
    end
    return c
end
G[40799] = {
    steps = {
        { t = "Expand the achievement: each storyline row has its starting quest giver, and the arrow takes you to the nearest one you still need." },
        { t = "Pick up the first quest there and follow the chain to its end; the row ticks when the last quest is handed in." },
    },
    tips = { "Each storyline also gives a one-time warband bonus of Council of Dornogal reputation.", "If Rampage at Nibelgaz Mine is stuck, look for The Glittering Shard: it's a quest item dropped by Urthgrafr Riftcaller." },
    crit = starts(DEEPS, {
        { "The Caretaker of Brunwin's Terrace", "Batzvara", 51.2, 30.2 },
        { "Broken Tools", "Machinist Kittrin", 48.2, 33.4 },
        { "Routine Maintenance", "Danagh", 58.8, 64.2 },
        { "Dread in the Den", "Scrit", 62.7, 45.6 },
        { "Envenomed Invasion", "Nebb", 65.8, 42.6 },
        { "Fearbreaker", "Moira Thaurissan", 47.0, 34.0 },
        { "Into the Fog", "Noli Marlen", 58.4, 62.4 },
        { "Magma-nificence", "Foreman Duinth", 41.0, 21.4 },
        { "Kobold Culture and Integration", "Skitter", 47.0, 34.0 },
        { "Rampage at Nibelgaz Mine", "Orsenth", 51.0, 14.8, true },
        { "Abysmal Extraction", "Prospera Cogwail", 63.8, 79.2 },
        { "Revenge in the Rumbling Wastes", "Kagfritha", 62.2, 46.8 },
        { "Tired of Rest", "Haimaz", 60.4, 45.7 },
        { "Frolicking in the Fetid Grotto", "Hrandaz", 62.4, 48.0 },
    }, 4.2),
}
G[40844] = {
    steps = {
        { t = "Expand the achievement: each storyline row has its starting quest giver, and the arrow takes you to the nearest one you still need." },
        { t = "Pick up the first quest there and follow the chain to its end; the row ticks when the last quest is handed in." },
    },
    tips = {
        "It can't be done in one week. Memories of the Sky needs nine mementos and the quest giver hands out three a week.",
        "Striking Steel pauses when Auralia Steelstrike moves to 42.4, 55.0; the chain continues a day or a reset later.",
        "Lost in the Darkness needs its prerequisite achievement or adventure mode; Rest at Last and Memories of the Sky need level 80.",
        "The Priory's reputation bonus needs a run of the Priory of the Sacred Flame dungeon.",
    },
    crit = starts(HALLOW, {
        { "Light to Velhan's Claim", "Aegor Irynbawnd", 49.2, 41.0 },
        { "The Priory", "General Steelstrike", 40.6, 50.6 },
        { "Striking Steel", "Auralia Steelstrike", 41.2, 53.0 },
        { "Lost in the Darkness", "Aliya Hillhelm", 61.2, 30.4 },
        { "The Sky's the Limit", "Barahl Lynflayme", 69.2, 43.8 },
        { "Crushing Depths", "Joseph Brayvemarc", 42.5, 55.2 },
        { "The Last Mage of Hallowfall", "General Steelstrike", 40.6, 50.6 },
        { "The Weight of Duty", "Endiri Dawnsurge", 41.4, 52.4 },
        { "Apart for Purpose", "Orren Masyn", 49.0, 62.0 },
        { "Rest at Last", "Great Kyron", 43.0, 52.4 },
        { "An Orphan's Dilemma", "Alyza Bowblaze", 41.6, 55.6 },
        { "The Mysterious Chef", "Haelmut Aegisaxe", 48.4, 39.2 },
        { "What Grows in the Dark", "Captain Trueflame", 70.4, 44.8 },
        { "Suspicious Minds", "Lerrenai Fayn", 68.0, 44.2 },
        { "Memories of the Sky", "Maera Ashyld", 60.4, 60.0 },
    }),
}
G[40894] = {
    steps = {
        { t = "Expand the achievement: each storyline row leads the arrow to its next quest giver." },
        { t = "Do every Undermine storyline. The last, Hard Ways at the Gallagio, opens only after you defeat Gallywix in the Liberation of Undermine raid and finish the main story; then a long chain starts for it." },
    },
}
G[40900] = {
    steps = {
        { t = "Expand the achievement: each campaign chapter is a row, and the arrow leads to its next quest giver." },
        { t = "Play the chapters in order; some open only at a weekly reset." },
    },
    tips = { "Once it's done, alts can skip the Undermine campaign: talk to the innkeeper on the first floor of the Incontinental Hotel." },
}
G[40307] = {
    steps = {
        { t = "Expand the achievement: it's the War Within campaign plus three questlines, each row leading the arrow to its quest giver." },
        { t = "Finish all of them on any character; the Earthen allied race then unlocks for your account." },
    },
}
G[40231] = {
    steps = {
        { t = "Expand the achievement: each row is its own achievement or Renown goal with a guide; do them in any order." },
        { t = "When it's done you can fly with steady flight too: the Switch Flight Style spell is at the very end of the Skyriding section on the General tab of your spellbook." },
    },
}
G[41217] = {
    steps = {
        { t = "Expand the achievement: every treasure has its spot, and tracking it leads you treasure to treasure." },
        { t = "Loot each one; a few need a small task first, noted on the row." },
    },
    crit = { ["Blackened Dice"] = { t = "Climb the pipe and turn the valve; the dice appear on the platform of the building next to it." } },
}
G[60889] = {
    steps = {
        { t = "Expand the achievement: each part is a K'aresh achievement with its own guide." },
        { t = "Upgrade your Reshii Wraps fully and reach Renown 11 with the K'aresh Trust first: some treasures and rares are only visible while phase-diving." },
    },
}
G[41808] = {
    steps = {
        { t = "Expand the achievement: each part is a step of the Oasis ecology questline in K'aresh." },
        { t = "Go to the Oasis in K'aresh and take every quest that shows on the map there; they appear as they open, so no start spots are needed." },
        { t = "Some steps are weekly gated: come back after each reset and do the new quests and the daily ones it unlocks." },
    },
}
G[41815] = G[41808]
G[41928] = { steps = { { t = "Expand the achievement: each part is a Horrific Visions Revisited achievement with its own guide." }, { t = "Upgrade the Hourglass with Mementos as you go; each upgrade makes the next part easier." }, { t = "Do the parts as the weekly city allows: Stormwind and Orgrimmar alternate." } }, tips = { "It gives no reward if you already own Reek from the original vision achievement." } }
G[41929] = { steps = { { t = "Expand the achievement: each part is a Horrific Visions Revisited achievement with its own guide." }, { t = "Collect the masks first (Long Night, then the city masks on their weeks); the many-mask clears need them." }, { t = "Then clear both cities with more and more masks on, ending with the full set." } }, tips = { "A five-mask clear has sometimes not credited the five-mask achievement in the same run as the eight-mask one; repeat it if a row stays open." } }
G[40232] = { steps = { { t = "Expand the achievement: each part is a Nerub-ar Palace raid achievement with its own guide." }, { t = "Join or build a Normal or Heroic group that is doing the Glory achievements; most need the whole raid to cooperate." }, { t = "Do one or two per week as the guides describe; when every row is ticked, the mount is yours." } }, tips = { "You Can't See Me, Cowabunga and Would You Still /love Me need at least ten players in the raid to give credit." } }
G[40980] = { steps = { { t = "Expand the achievement: each row is one pet family achievement with its own guide." }, { t = "Level three pets of a family to 25 and beat every Khaz Algar tamer with only that family." }, { t = "Repeat for all ten families." } }, tips = { "Look up a team for each tamer before you start; most fights have a known safe strategy." } }
local elite = function(boss)
    return {
        steps = {
            { t = "Expand the achievement: any one of the rows gives it." },
            { t = "Pick the route that fits you: the PvP rating row, the Mythic+ rating row, or the Mythic raid kill." },
            { t = "Reach that goal; the achievement and its reward come at once." },
        },
        tips = { "It stays possible after the season ends through the Mythic " .. boss .. " kill." },
    }
end
G[40723] = elite("Queen Ansurek")
G[41665] = elite("Gallywix")
G[42325] = { steps = { { t = "Expand the achievement: any one of the rows gives it." }, { t = "Pick the route that fits you: the PvP rating row, the Mythic+ rating row, or the raid row." }, { t = "Reach that goal; the achievement and its reward come at once." } }, tips = { "It rewards a K'areshi Voidstone, which unlocks transmog appearances." } }

-- Khaz Algar race tiers the lists had missed
local RACE_TIPS = {
    bronze = "Fly through every ring to the finish; any time counts.",
    silver = "Finish under the silver time: save vigor for the climbs and use Surge Forward on the straights.",
    gold = "Gold needs a clean run: learn the line on a practice lap, never miss a ring (a miss costs time), and keep Whirling Surge and Second Wind for the long stretches.",
}
local race = function(kind, medal)
    return {
        steps = {
            { t = "Expand the achievement: it lists every " .. kind .. " race it needs, each with its start." },
            { t = "Fly to a race start and talk to the race NPC or step into the start ring; pick the " .. kind .. " version." },
            { t = "Earn " .. medal .. " in each one: " .. RACE_TIPS[medal] },
            { t = "Repeat for every race in the list; the arrow moves to the next start." },
        },
        tips = { "Your best time per race is kept, so you can come back to a single race later." },
    }
end
G[40317] = race("normal", "silver")
G[40318] = race("normal", "gold")
G[40319] = race("advanced", "bronze")
G[40321] = race("advanced", "gold")
G[40323] = race("reverse", "silver")
G[40324] = race("reverse", "gold")
G[40329] = race("advanced", "silver")
G[40331] = race("reverse", "bronze")
G[40333] = race("reverse", "gold")
G[40336] = race("normal", "gold")
G[40337] = race("advanced", "bronze")
G[40339] = race("advanced", "gold")
G[40341] = race("reverse", "silver")
G[40342] = race("reverse", "gold")
G[40343] = race("normal", "bronze")
G[40344] = race("normal", "silver")
G[40346] = race("advanced", "bronze")
G[40347] = race("advanced", "silver")
G[40349] = race("reverse", "bronze")
G[40350] = race("reverse", "silver")
G[40351] = race("reverse", "gold")
G[40354] = {
    steps = {
        { t = "Expand the achievement: it's every Khaz Algar race tier at gold, one row per zone achievement." },
        { t = "Work through the zone gold achievements one at a time; each has its own guide." },
    },
    tips = { RACE_TIPS.gold },
}
local car = function(kind, medal)
    return {
        steps = {
            { t = "Get the G-99 Breakneck from the Undermine questline and use it; these races need the car, not a flying mount." },
            { t = "Expand the achievement: it lists every " .. kind .. " race in Undermine, each with its start." },
            { t = "Drive to a start, begin the race and earn " .. medal .. ". Use boosts on the straights and stay on the road; the walls cost the most time." },
            { t = "Repeat for every race in the list." },
        },
    }
end
G[40938] = car("Skyrocketing", "gold")
G[41083] = car("Breakneck", "silver")

-- pet battle families the lists had missed
local family = function(kind, where)
    return {
        steps = {
            { t = "Level a team of three " .. kind .. " pets to 25." },
            { t = "Expand the achievement: every " .. where .. " has its spot." },
            { t = "Fight each one with only " .. kind .. " pets; they can be fought again whenever they're up, even after their world quest." },
        },
        tips = { "Look up a team for each fight before you go; most have a known safe strategy." },
    }
end
G[40155] = family("beast", "Khaz Algar tamer")
G[40156] = family("critter", "Khaz Algar tamer")
G[40157] = family("dragonkin", "Khaz Algar tamer")
G[40158] = family("elemental", "Khaz Algar tamer")
G[41541] = family("critter", "Undermine elite pet and tamer")
G[41544] = family("dragonkin", "Undermine elite pet and tamer")
G[41545] = family("elemental", "Undermine elite pet and tamer")
G[41547] = family("humanoid", "Undermine elite pet and tamer")
G[41549] = family("mechanical", "Undermine elite pet and tamer")
G[41550] = family("undead", "Undermine elite pet and tamer")

-- Deephaul Ravine
local ravine = function(goal, tip)
    return {
        steps = {
            { t = "Open the PvP window and queue for random battlegrounds, or for Deephaul Ravine when it's the featured battleground." },
            { t = goal },
        },
        tips = tip and { tip } or nil,
    }
end
G[40210] = ravine("Win one Deephaul Ravine match.")
G[40216] = ravine("Win a match in under 7 minutes: the fastest way is to reach the score limit with crystal captures and carts, so join a group that plays the objective hard.", "Premade groups win fast far more often than a random queue.")
G[40607] = ravine("Pick up the Deephaul Crystal and carry it until it's captured for your team, once.")
G[40615] = ravine("Wait near where the Earthen Mine Carts drop players off and kill an enemy right after they step out.")
G[40468] = {
    steps = {
        { t = "Turn on War Mode (in a capital, from the talents window)." },
        { t = "Watch the Khaz Algar zones for a War Supply Crate: a plane drops it about every 15 minutes, and it shows on the map." },
        { t = "Get there first and loot it. Repeat until you've opened 5." },
    },
    tips = { "Quiet zones and off-peak hours make it much easier." },
}

-- professions, fishing, appearances, dungeon metas, leveling
G[19408] = {
    steps = {
        { t = "Pick one primary profession and learn its Khaz Algar skill from the trainer in Dornogal." },
        { t = "Raise it to the maximum: craft or gather for skill, and do the weekly profession quests and treasures for knowledge." },
    },
    tips = { "Any one primary profession at maximum Khaz Algar skill is enough." },
}
local thread = function(name)
    return {
        steps = {
            { t = "Attach an Algari Weaverline to your fishing pole first (the Aqirite Fisherfriend is the best pole for it)." },
            { t = "Then attach each " .. name .. " you collect to the same pole until you reach the count." },
        },
        tips = { "The threads count per character, so stay on one fisher." },
    }
end
for _, id in ipairs({ 40484, 40485, 40487, 40489, 40490, 40491 }) do G[id] = thread("Algari Seekerthread") end
for _, id in ipairs({ 40495, 40497, 40499 }) do G[id] = thread("Algari Anglerthread") end
G[40469] = {
    steps = {
        { t = "Run Nerub-ar Palace on any difficulty and collect the armor pieces for your class." },
        { t = "Any one full set (all its pieces, one difficulty's look) completes it." },
    },
}
G[41525] = {
    steps = {
        { t = "Run the Liberation of Undermine on any difficulty and collect the armor pieces for your class." },
        { t = "Any one full set completes it." },
    },
}
G[61565] = {
    steps = {
        { t = "Expand the achievement: it lists the Heroic achievement of every War Within dungeon." },
        { t = "Queue for Heroic dungeons in the Dungeon Finder, or pick each one with Specific Dungeons; finish each to its last boss." },
    },
}
G[61566] = {
    steps = {
        { t = "Expand the achievement: it lists the Mythic dungeon achievements, each with its own guide." },
        { t = "Form or join a Mythic group for each; most need a specific task done before or during a boss." },
    },
}
local mentor = function(n)
    return {
        steps = {
            { t = "Reach level 80 on " .. (n == 1 and "a character" or (n .. " characters")) .. "." },
            { t = "Any way of leveling counts: story, side quests, dungeons or delves. Warband-bound gear and experience bonuses speed up alts." },
        },
    }
end
G[19470] = mentor(1)
G[19460] = mentor(2)
G[19475] = mentor(3)
G[19476] = mentor(4)
G[19477] = mentor(5)

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
