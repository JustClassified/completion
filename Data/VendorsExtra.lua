-- Completion: vendors the generated list (Data/Vendors.lua) doesn't have yet, kept by hand. Same format.
-- Checked 2026-10-16 against the game's vendor data.

local _, ns = ...

-- Patch 12.1.5: the Aqir Research Enclave's vendor in Silvermoon City, and the Den's gold-sink mount vendor
ns.VENDOR_NPCS[266188] = { n = "Estelia Archtender", tag = "Aqir Researcher", at = { { 2393, 39.3, 80.3 } } }
ns.VENDOR_NPCS[274363] = { n = "Showena", tag = "Mounts and More", at = { { 2576, 61.8, 67.7 } } }

local MARL = 3316
ns.ITEM_VENDORS[274927] = { { 266188, { 0, { { MARL, 1000 } }, {} } } }   -- Aqir Wingreaver (Friendly)
ns.ITEM_VENDORS[274923] = { { 266188, { 0, { { MARL, 1000 } }, {} } } }   -- Aqir Scuttler (Honored)
ns.ITEM_VENDORS[276927] = { { 266188, { 0, { { MARL, 2000 } }, {} } } }   -- Aqir Razorwing (Revered)
ns.ITEM_VENDORS[276926] = { { 266188, { 0, { { MARL, 2500 } }, {} } } }   -- Corrupted Swarmer (Exalted)
ns.ITEM_VENDORS[275039] = { { 266188, { 0, { { MARL, 2500 } }, {} } } }   -- Curse of the Aqir (Exalted)
ns.ITEM_VENDORS[282414] = { { 274363, { 50000000000, {}, {} } } }        -- Sporebearer Fungal Strider (5,000,000 gold)
