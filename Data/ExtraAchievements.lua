-- Completion: achievements the generated lists missed, added by hand so a regeneration keeps them.
-- Found by comparing the lists with the game's own achievement table (2026-10-10). Patch 12.1.5 content
-- (Kindo'jan's Labyrinth, Kith'ix, The Promise of Tomorrow) is left out until it's live; the two in
-- Midnight categories are picked up by the in-game category scan anyway.

local _, ns = ...

local EXTRA = {
    midnight = {
        Characters = { 42328, 42329, 42330, 42331, 42332, 61678, 61679 },
    },
    tww = {
        Characters = { 19460, 19470, 19475, 19476, 19477 },
        Skyriding = { 40317, 40318, 40319, 40321, 40323, 40324, 40329, 40331, 40333, 40336, 40337, 40339, 40341,
            40342, 40343, 40344, 40346, 40347, 40349, 40350, 40351, 40354, 40938, 41083 },
        ["Pet Battles"] = { 40155, 40156, 40157, 40158, 41541, 41544, 41545, 41547, 41549, 41550 },
        PvP = { 40210, 40216, 40468, 40607, 40615 },
        Professions = { 19408 },
        Fishing = { 40484, 40485, 40487, 40489, 40490, 40491, 40495, 40497, 40499 },
        Collections = { 40469, 41525 },
        Dungeons = { 61565, 61566 },
    },
}

-- appends each id to its expansion's group, creating the group when that expansion has none
for exp, groups in pairs(EXTRA) do
    for name, ids in pairs(groups) do
        local target
        for _, g in ipairs(ns.ACH_GROUPS) do
            if g[1] == name and (g.exp or "midnight") == exp then target = g; break end
        end
        if not target then
            target = { name, {}, exp = exp ~= "midnight" and exp or nil }
            ns.ACH_GROUPS[#ns.ACH_GROUPS + 1] = target
        end
        for _, id in ipairs(ids) do target[2][#target[2] + 1] = id end
    end
end

-- the new group can be switched off like the others
table.insert(ns.SCOPE_ORDER, #ns.SCOPE_ORDER - 1, "Characters")
ns.SCOPE_DEFAULTS.Characters = true
