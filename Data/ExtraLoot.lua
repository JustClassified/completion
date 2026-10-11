-- Completion: drops the map data was missing, per rare (NPC ID -> item IDs).
-- Found by checking every rare's own drop list (2026-10-11). Hand-kept, so re-importing the spot data keeps them.
-- Non-collectible items are harmless here: the game decides what counts as a mount, pet, toy or look.

local _, ns = ...

ns.EXTRA_LOOT = {
    [206977] = { 221253 },   -- Parasidious
    [207780] = { 221255 },   -- Finclaw Bloodtide
    [221534] = { 221247 },   -- Lytfang the Lost
    [230793] = { 235300, 235315, 235322, 235351 },   -- The Junk-Wall
    [230800] = { 235310, 235320, 235327, 235347 },   -- Slugger the Smart
    [230828] = { 235300, 235315, 235322, 235351 },   -- Chief Foreman Gutso
    [230840] = { 235300, 235315, 235351 },   -- Flyboy Snooty
    [230940] = { 235310, 235327, 235347 },   -- Tally Doublespeak
    [230946] = { 235310, 235320 },   -- V.V. Goosworth
    [230951] = { 235320, 235327, 235347 },   -- Thwack
    [230979] = { 235300, 235322, 235351 },   -- S.A.L.
    [231012] = { 235310, 235320, 235327, 235347 },   -- Candy Stickemup
    [231229] = { 240117, 240118 },   -- Korgoth the Hungerer
    [231288] = { 235310, 235320, 235327, 235347 },   -- Swigs Farsight
    [231353] = { 234379 },   -- Tempest Talon
    [234480] = { 235315, 235322, 235351 },   -- M.A.G.N.O.
    [234499] = { 235327, 235347 },   -- Giovante
    [235087] = { 240111, 240112, 240114 },   -- The Harvester
    [235104] = { 240115, 240118, 240119, 240120 },   -- The Wallbreaker
    [241956] = { 239450, 239456, 239467, 239468, 239474 },   -- Arcana-Monger So'zer
    [262421] = { 276299 },   -- Atomus
    [263456] = { 280701 },   -- ?
    [263947] = { 275163 },   -- Interminable Uarn
    [264569] = { 275151 },   -- Auredar's Chassis
    [264865] = { 276299 },   -- Mercilus
    [265269] = { 274838, 274846 },   -- Shadowguard Destroyer
}
