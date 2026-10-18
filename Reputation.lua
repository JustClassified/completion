-- Completion: Midnight reputations. Their reviewed data (Data/RepText.lua) says how each is earned and where its
-- quartermaster stands; the standing, the progress to the next rank and the rewards you still need are read live.

local _, ns = ...

-- Reputation earned toward the next rank, as "1,200 / 2,500", or nil when the game doesn't say.
local function NextRank(fid)
    if C_MajorFactions and C_MajorFactions.GetMajorFactionData then
        local ok, d = pcall(C_MajorFactions.GetMajorFactionData, fid)
        if ok and d and d.renownLevelThreshold and d.renownLevelThreshold > 0 then
            return d.renownReputationEarned or 0, d.renownLevelThreshold
        end
    end
    if C_GossipInfo and C_GossipInfo.GetFriendshipReputation then
        local ok, f = pcall(C_GossipInfo.GetFriendshipReputation, fid)
        if ok and f and f.friendshipFactionID and f.friendshipFactionID > 0 and f.nextThreshold then
            local base = f.reactionThreshold or 0
            return (f.standing or 0) - base, f.nextThreshold - base
        end
    end
end

-- Puts thousands separators into a number.
local function Num(n)
    local s = tostring(math.floor(n))
    while true do
        local t, k = s:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        s = t
        if k == 0 then return s end
    end
end

-- The mounts, pets and toys this faction gives (Data/CollectText.lua), lowest rank first: { itemID, rank }.
local function Rewards(fid)
    local out = {}
    for itemID, t in pairs(ns.COLLECT_INFO or {}) do
        local f, lvl = t.fac or t.needFac, t.lvl or t.needLvl
        if f == fid and lvl then out[#out + 1] = { itemID, lvl } end
    end
    table.sort(out, function(a, b) if a[2] ~= b[2] then return a[2] < b[2] end return a[1] < b[1] end)
    return out
end

-- The quartermaster's spot as an item spot, or nil.
function ns.RepSpot(fid)
    local info = ns.REP_INFO and ns.REP_INFO[fid]
    local at = info and info.qm and info.qm.at
    if at then return { map = at[1], x = at[2], y = at[3] } end
end

-- The tooltip for a reputation row: standing and progress, the rewards still to get, how to earn it, the
-- quartermaster and tips. Returns false when there's no reviewed data.
function ns.RepTooltip(it)
    local info = ns.REP_INFO and ns.REP_INFO[it.faction]
    if not info then return false end
    local tip, r = GameTooltip, it.rep
    if r then
        if r.done then tip:AddLine("Maxed: " .. r.text, 0.4, 0.9, 0.4, true)
        else tip:AddLine(r.text, 1, 0.82, 0.3, true) end
        local got, need = NextRank(it.faction)
        if not r.done and got and need then
            tip:AddLine(string.format("Next rank: %s / %s", Num(got), Num(need)), 0.8, 0.8, 0.8)
        end
    end
    -- rewards: what you still need and the rank it opens at
    local rewards, open = Rewards(it.faction), {}
    for _, e in ipairs(rewards) do
        local t, owned = ns.ItemCollect(e[1])
        if t and owned ~= true then open[#open + 1] = { e[1], e[2], t, r and r.cur and r.cur >= e[2] } end
    end
    if #open > 0 then
        tip:AddLine(" ")
        tip:AddLine("Rewards you still need", 1, 0.82, 0.3)
        for _, e in ipairs(open) do
            local name = ns.ItemName(e[1]) or ("item " .. e[1])
            local where = (r and r.renown) and ("renown " .. e[2]) or ("rank " .. e[2])
            if e[4] then
                tip:AddLine(string.format("%s (%s, %s)  |cff55ff55you can buy it now|r", name, ns.TYPE_LABEL[e[3]] or e[3], where), 0.9, 0.9, 0.9, true)
            else
                tip:AddLine(string.format("%s (%s, %s)", name, ns.TYPE_LABEL[e[3]] or e[3], where), 0.9, 0.9, 0.9, true)
            end
        end
    end
    tip:AddLine(" ")
    tip:AddLine("How to earn it", 1, 0.82, 0.3)
    for _, x in ipairs(info.how) do tip:AddLine("- " .. x, 0.9, 0.85, 0.7, true) end
    if info.qm then
        tip:AddLine(" ")
        if info.qm.at then
            local ok, mi = pcall(C_Map.GetMapInfo, info.qm.at[1])
            tip:AddLine(string.format("Quartermaster: %s, %s  %.1f, %.1f", info.qm.name, ok and mi and mi.name or "",
                info.qm.at[2], info.qm.at[3]), 0.6, 0.6, 0.6, true)
        else
            tip:AddLine("Quartermaster: " .. info.qm.name, 0.6, 0.6, 0.6, true)
        end
    end
    for _, x in ipairs(info.tips or {}) do tip:AddLine("- " .. x, 0.75, 0.75, 0.75, true) end
    if info.qm and info.qm.at then
        tip:AddLine(" ")
        tip:AddLine("Track it and the arrow leads to the quartermaster.", 0.5, 0.5, 0.5, true)
    end
    return true
end
