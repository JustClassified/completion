-- Completion: things we can't support properly yet. Each one still shows in its list, greyed with a line
-- through it and a "Coming soon" tooltip, and none of our unsure text is shown for it.
-- Keys: "a:<achievementID>", "l:<achievementID>:<criterionID>", "q:<questID>", "p:<questID of a spot>",
-- "i:<itemID>". The value says what is missing. Every entry is also listed in Tools/RESEARCH.md.

local _, ns = ...

ns.RESEARCH = {
    -- War Within: Undermine car race whose start position isn't confirmed
    ["a:40924"] = "The start of Scrapshop Shot isn't confirmed yet.",
    ["a:40925"] = "The start of Scrapshop Shot isn't confirmed yet.",
    ["a:40926"] = "The start of Scrapshop Shot isn't confirmed yet.",
    ["a:40927"] = "The start of Scrapshop Shot isn't confirmed yet.",
    ["a:40928"] = "The start of Scrapshop Shot isn't confirmed yet.",
    ["a:40929"] = "The start of Scrapshop Shot isn't confirmed yet.",
    -- Midnight collectibles still being checked (Tools/db/collect.py SOON)
    ["i:264413"] = "Its Season 1 source (Nulling Nullaeus) has ended; whether it still drops is being checked.",
    ["i:263871"] = "Where this toy comes from is being researched.",
    ["i:270061"] = "Only one player report explains this pet so far; it's being checked.",
}
