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
