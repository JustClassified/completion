-- Completion: hand-written walkthroughs for War Within achievements (own words), added to the same tables as
-- Data/Notes.lua: ns.ACH_NOTES[id] (the whole achievement) and ns.CRIT_NOTES[id][criterion name] = { t, at }.

local _, ns = ...

local ACH = {
}

local CRIT = {
}

for id, text in pairs(ACH) do ns.ACH_NOTES[id] = ns.ACH_NOTES[id] or text end
for id, list in pairs(CRIT) do
    ns.CRIT_NOTES[id] = ns.CRIT_NOTES[id] or {}
    for k, v in pairs(list) do ns.CRIT_NOTES[id][k] = ns.CRIT_NOTES[id][k] or v end
end
