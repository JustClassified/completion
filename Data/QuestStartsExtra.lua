-- Completion: where quests are picked up that the research database doesn't track (hand-kept, loaded after
-- Data/QuestStarts.lua). These are quests an achievement asks for, found with the in-game read; for a world quest
-- the spot is where it takes place. questID -> { uiMapID, x, y }.

local _, ns = ...

ns.QUEST_START = ns.QUEST_START or {}
local S = ns.QUEST_START
local HALLOWFALL, DEEPS, DORN, SIREN, KARESH, PERCH, VAL = 2215, 2214, 2248, 2369, 2371, 2444, 2599

for q, p in pairs({
    -- Hallowfall: Beacon of Hope, Sharing the Light, Sojourner of Hallowfall, Allied Races: Earthen
    [78590] = { HALLOWFALL, 63.8, 31.8 }, [78915] = { HALLOWFALL, 63.6, 33.8 }, [79168] = { HALLOWFALL, 43.2, 52.4 },
    [79173] = { HALLOWFALL, 63.2, 29.4 }, [79346] = { HALLOWFALL, 65.8, 24.4 }, [79380] = { HALLOWFALL, 67.2, 23.6 },
    [81574] = { HALLOWFALL, 64.6, 30.6 }, [81632] = { HALLOWFALL, 64.4, 18.8 }, [82223] = { HALLOWFALL, 43.8, 49.6 },
    [83503] = { HALLOWFALL, 36.0, 35.4 },
    -- The Ringing Deeps and the Isle of Dorn
    [78706] = { DEEPS, 68.4, 64.2 }, [81559] = { DEEPS, 58.4, 62.4 }, [83643] = { DORN, 61.6, 42.8 },
    -- Siren-ity Now!
    [83827] = { SIREN, 45.2, 67.8 }, [84001] = { SIREN, 48.4, 52.8 }, [84222] = { SIREN, 69.4, 42.8 },
    [84432] = { SIREN, 69.2, 42.8 }, [84680] = { SIREN, 69.2, 42.8 }, [84852] = { SIREN, 32.8, 73.6 },
    [85051] = { SIREN, 41.8, 68.2 },
    -- K'aresh special assignments (Capstoned), Slayer's Rise (Investigating the Rise), Val (Showdown Success)
    [89293] = { KARESH, 61.4, 28.0 }, [89294] = { KARESH, 77.2, 49.0 }, [89347] = { PERCH, 53.6, 28.2 },
    [95397] = { VAL, 48.4, 31.8 }, [95401] = { VAL, 41.1, 67.0 },
}) do
    if not S[q] then S[q] = p end
end
