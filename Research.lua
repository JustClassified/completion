-- Completion: "coming soon". An item we can't support properly yet stays in its list but is drawn greyed
-- with a line through it, and its tooltip says what's missing instead of showing anything unsure.
-- Hand-marked entries live in Data/Research.lua; items with no guide, quest list or source at all are
-- marked automatically.

local _, ns = ...

-- The research key of an item (see Data/Research.lua), or nil.
local function Key(it)
    local k = it.kind
    if k == "ach" then return "a:" .. tostring(it.id) end
    if k == "lore" then return "l:" .. tostring(it.ach) .. ":" .. tostring(it.crit and it.crit.id or it.order) end
    if k == "point" then return it.q and ("p:" .. it.q) end
    if k == "collect" then return it.itemID and ("i:" .. it.itemID) end
end

-- True when an achievement has any guidance at all: steps, notes, criterion notes, places or a lore page.
local function AchHasInfo(id)
    if (ns.ACH_STEPS and ns.ACH_STEPS[id]) or (ns.ACH_READ and ns.ACH_READ[id]) or (ns.ACH_NOTES and ns.ACH_NOTES[id])
        or (ns.CRIT_NOTES and ns.CRIT_NOTES[id]) or (ns.CRIT_GUIDE and ns.CRIT_GUIDE[id]) or (ns.LORE_ACH and ns.LORE_ACH[id]) then
        return true
    end
end

-- Why an item is "coming soon", or nil when it's fully supported. Finished items are never marked.
function ns.SoonReason(it)
    if not it or it.done then return end
    local key = Key(it)
    local hand = key and ns.RESEARCH and ns.RESEARCH[key]
    if hand then return hand end
    if it.kind == "ach" and it.id and not AchHasInfo(it.id) and not (it.spots and it.spots[1]) and not (it.points and it.points[1]) then
        return "A guide for this achievement is being written."
    end
    if it.kind == "lore" and it.crit and not (it.crit.chain and it.crit.chain[1]) and not it.crit.q then
        return "The quest list for this storyline is being researched."
    end
    if it.kind == "collect" and not (it.viaAch or it.source or it.dropSource or it.vendors or (it.spots and it.spots[1]) or it.sourceText) then
        return "Where this comes from is being researched."
    end
end

-- A quest note, unless the quest is marked for research (then its unsure note stays hidden).
function ns.QuestNote(questID)
    if ns.RESEARCH and ns.RESEARCH["q:" .. questID] then return end
    return ns.QUEST_NOTES and ns.QUEST_NOTES[questID]
end
