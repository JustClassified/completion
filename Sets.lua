-- Completion: Midnight appearance sets. Which sets exist for your class and whether you have them comes from the game
-- (C_TransmogSets); Data/Sets.lua only says where each set comes from, so the book can group them.

local _, ns = ...

-- headings in list order, by the source kind in Data/Sets.lua
local HEADINGS = {
    { "raid", "Raid sets" }, { "dungeon", "Dungeon sets" }, { "delve", "Delve sets" }, { "prey", "Prey sets" },
    { "renown", "Renown and court sets" }, { "assault", "Void Assault sets" }, { "wq", "World quest sets" },
    { "campaign", "Campaign sets" }, { "crafted", "Crafted and world sets" }, { "pvp", "PvP sets" },
}
local HEADING, ORDER = {}, {}
for i, h in ipairs(HEADINGS) do HEADING[h[1]] = h[2]; ORDER[h[1]] = i end

-- The game's info for one set, or nil.
function ns.SetInfo(setID)
    if not (C_TransmogSets and C_TransmogSets.GetSetInfo) then return end
    local ok, info = pcall(C_TransmogSets.GetSetInfo, setID)
    if ok and type(info) == "table" then return info end
end

-- How many of a set's pieces you have, and how many it has.
function ns.SetPieces(setID)
    if not (C_TransmogSets and C_TransmogSets.GetSetPrimaryAppearances) then return 0, 0 end
    local ok, list = pcall(C_TransmogSets.GetSetPrimaryAppearances, setID)
    if not ok or type(list) ~= "table" then return 0, 0 end
    local have = 0
    for _, a in ipairs(list) do if a.collected then have = have + 1 end end
    return have, #list
end

-- Midnight sets your character can collect, as { setID, title, heading, kind }, raid sets first, in the game's order.
-- which = "pve" (everything but PvP) or "pvp".
function ns.MidnightSets(which)
    if not (C_TransmogSets and C_TransmogSets.GetAllSets and ns.SET_KIND) then return {} end
    local ok, all = pcall(C_TransmogSets.GetAllSets)
    if not ok or type(all) ~= "table" then return {} end
    local out = {}
    for _, s in ipairs(all) do
        local kind = s.setID and ns.SET_KIND[s.setID]
        if kind and ((which == "pvp") == (kind == "pvp")) and s.validForCharacter ~= false then
            local title = s.name or ("Set " .. s.setID)
            if s.description and s.description ~= "" then title = title .. " (" .. s.description .. ")" end
            local heading = HEADING[kind]
            -- raid sets are listed per raid
            if kind == "raid" and s.label and s.label ~= "" then heading = heading .. ": " .. s.label end
            out[#out + 1] = { setID = s.setID, title = title, heading = heading, kind = kind, order = s.uiOrder or 0 }
        end
    end
    table.sort(out, function(a, b)
        if ORDER[a.kind] ~= ORDER[b.kind] then return ORDER[a.kind] < ORDER[b.kind] end
        if a.heading ~= b.heading then return a.heading < b.heading end
        if a.order ~= b.order then return a.order < b.order end
        return a.setID < b.setID
    end)
    return out
end

-- Tooltip lines for a set row: where it comes from and which pieces you still need.
function ns.SetTooltip(it)
    local info = ns.SetInfo(it.setID)
    local tip = GameTooltip
    if info then
        if info.label and info.label ~= "" then tip:AddLine(info.label .. (info.description and info.description ~= "" and (", " .. info.description) or ""), 0.8, 0.8, 0.8, true) end
        tip:AddLine(info.collected and "Collected" or "Not collected yet", info.collected and 0.4 or 1, info.collected and 0.9 or 0.5, info.collected and 0.4 or 0.3)
    end
    if C_TransmogSets and C_TransmogSets.GetSetPrimaryAppearances then
        local ok, list = pcall(C_TransmogSets.GetSetPrimaryAppearances, it.setID)
        if ok and type(list) == "table" and #list > 0 then
            local have = 0
            for _, a in ipairs(list) do if a.collected then have = have + 1 end end
            tip:AddLine(string.format("Pieces: %d of %d", have, #list), 1, 0.82, 0.3)
        end
    end
    tip:AddLine("Not part of 100%: an extra for completionists. Open the Appearances window (Sets tab) to see each piece.", 0.7, 0.7, 0.7, true)
end
