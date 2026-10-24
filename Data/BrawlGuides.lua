-- Completion: the Brawler's Guild (back since patch 11.2.7), checked 2026-10-24 against its full guide and players'
-- reports. Alliance fights in Bizmo's Brawlpub under the Deeprun Tram, the Horde in Brawl'gar Arena in Orgrimmar.

local _, ns = ...
local S, N = ns.ACH_STEPS, ns.ACH_NOTES

local STORMWIND, ORGRIMMAR, DORNOGAL, SILVERMOON = 84, 85, 2339, 2393
local INVITE = {
    { t = "Talk to the Babbling Brawler in Dornogal (also in Stormwind's Trade District and in Silvermoon City) for the Brawler's Guild starter quest.", at = { DORNOGAL, 51.0, 43.5 } },
    { side = "Alliance", t = "Follow it to Bizmo's Brawlpub: take the Deeprun Tram from Stormwind; the pub's entrance is under the first set of trains.", at = { STORMWIND, 66.5, 34.8 } },
    { side = "Horde", t = "Follow it to Brawl'gar Arena: the portal is in Orgrimmar's Valley of Honor, up from the auction house.", at = { ORGRIMMAR, 70.1, 31.5 } },
    { t = "Buy the Brawler's Guild invitation there (50 gold) and use it." },
}
local QUEUE = { t = "Talk to a bouncer around the ring to join the queue; when it's your turn you're put in the ring. Most fights have a 2-minute limit before the ring fills with fire." }
local BROKER = { t = "Talk to the Challenge Broker by the ring (Senna in Bizmo's Brawlpub, Guo in Brawl'gar Arena) and pick the gambit this achievement names before you queue." }
local RANK8 = { t = "Reach Rank 8 (four ranked fights per rank) to unlock Challenge Cards from the Card Trader; players do the gambits with Challenge Card: Dippy, an easy fight." }

S[61413] = { INVITE[1], INVITE[2], INVITE[4] }
S[61414] = { INVITE[1], INVITE[3], INVITE[4] }
N[61413] = "If you were invited in an earlier season, the quest chain skips ahead."; N[61414] = N[61413]
local function gambit(id, text)
    S[id] = { RANK8, BROKER, QUEUE, { t = text } }
end
gambit(61419, "Win a fight with the ice gambit: the floor turns to ice and you slide.")
gambit(61420, "Win without taking any damage.")
gambit(61421, "Win with the swamp gambit: you move slower and fire bursts from the floor.")
gambit(61422, "Win with the audience gambit: the crowd throws fruit and fish that knock you up.")
gambit(61423, "Win with the spring gambit: you bounce as you move.")
gambit(61424, "Win while giant: the gambit makes you huge.")
gambit(61425, "Win with the speed gambit: you can't stop running fast.")
gambit(61426, "Win with the no-weapon gambit (pick it at the broker; don't unequip your weapon yourself).")
N[61420] = { "Dippy is the easiest: he gets knocked back each time you hit him.", "Avoid trinkets or abilities that hurt you, and anything that spends your own health." }
N[61423] = "Players report Topps doesn't charge with this gambit and keeps interrupting casters: Dippy is easier."
N[61425] = "Walking (not running) makes it much easier to control. Evokers can't cast empowered spells under it."
N[61426] = "Classes with weaponless attacks, like a Beast Mastery hunter, have the easiest time."
N[61419] = "Leaps and charges can stop the ice from working: stay on foot."
N[61429] = { "All eight gambits: expand it, each one has its guide.", "A friend in your group gets credit for your wins too, even standing by." }
S[61466] = { RANK8, { t = "Buy Challenge Cards for the fights only cards offer (the achievement lists them) and win 15 of the 24." }, QUEUE }
N[61466] = { "Party members get credit for your kills: friends can share.", "Players rank them by difficulty: skip the hardest nine." }
