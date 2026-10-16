-- Completion: delves the shared delve list (Data/Delves.lua, generated) doesn't have yet, kept by hand.
-- Same fields as Data/Delves.lua; stories is left out for a delve without story variants.

local _, ns = ...

-- Patch 12.1.5: the first Labyrinth, a nine-chamber "mega-delve" north of the Amani Pass. It has no story variants.
ns.DELVE_INFO["Labyrinth of Kindo'jan"] = {
    map = 2647, chests = 63717, zone = "eversong",
    at = { 2395, 63.00, 72.20 },
    notes = {},
}
