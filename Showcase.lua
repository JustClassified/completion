-- Completion: the showcase. Pick a mount, pet, appearance or rare in a list and the book's map turns into
-- a 3D model you can turn (drag) and zoom (mouse wheel). Toys and decor have no model; they show their icon.
-- Also builds the "How to get it" block for tooltips.

local _, ns = ...

------------------------------------------------------------------------
-- what to show for an item
------------------------------------------------------------------------

-- Creature display ID for a mount, falling back to the first of its display variants.
local function MountDisplay(mountID)
    if not (mountID and C_MountJournal and C_MountJournal.GetMountInfoExtraByID) then return end
    local ok, displayID = pcall(C_MountJournal.GetMountInfoExtraByID, mountID)
    if ok and displayID and displayID > 0 then return displayID end
    if C_MountJournal.GetMountAllCreatureDisplayInfoByID then
        local ok2, list = pcall(C_MountJournal.GetMountAllCreatureDisplayInfoByID, mountID)
        if ok2 and type(list) == "table" and list[1] then return list[1].creatureDisplayID end
    end
end

-- The item's own mountID (renown rewards), or the mount its item teaches.
local function MountIDFor(it)
    if it.mountID then return it.mountID end
    if it.itemID and C_MountJournal and C_MountJournal.GetMountFromItem then
        local ok, mid = pcall(C_MountJournal.GetMountFromItem, it.itemID)
        if ok then return mid end
    end
end

-- What the viewer shows for a collectible or a rare / world boss with an NPC ID:
-- { kind = "display" | "creature" | "tryon" | "icon", id, link, icon }, or nil when there is nothing.
function ns.ModelInfo(it)
    if not it then return end
    if it.kind == "point" and (it.pkind == "rare" or it.pkind == "boss") and it.npc then
        return { kind = "creature", id = it.npc }
    end
    if it.kind ~= "collect" then return end
    local t = it.ctype
    if t == "mount" then
        local d = MountDisplay(MountIDFor(it))
        if d then return { kind = "display", id = d } end
    elseif t == "pet" and it.itemID and C_PetJournal and C_PetJournal.GetPetInfoByItemID then
        local r = { pcall(C_PetJournal.GetPetInfoByItemID, it.itemID) }
        if r[1] and r[13] and r[13] > 0 then return { kind = "display", id = r[13] } end
        if r[1] and r[5] then return { kind = "creature", id = r[5] } end
    elseif t == "appearance" and it.itemID then
        return { kind = "tryon", link = "item:" .. it.itemID }
    end
    local icon = it.icon or (it.itemID and ns.ItemIcon(it.itemID))
    if icon then return { kind = "icon", icon = icon } end
end

------------------------------------------------------------------------
-- how to get it
------------------------------------------------------------------------

-- Map name for a uiMapID, or "" when the client doesn't know it.
local function MapName(mapID)
    local ok, info = pcall(C_Map.GetMapInfo, mapID)
    return ok and info and info.name or ""
end

-- "Map  x, y" for a spot (coordinates 0-100), or nil when there is no spot.
local function Where(spot)
    if not spot or not spot.x then return end
    return string.format("%s  %.1f, %.1f", MapName(spot.map), spot.x, spot.y)
end

-- A vendor price as text. cost is { copper, { {currencyID, amount}, ... }, { {itemID, count}, ... } };
-- nil when it is not a table or comes to nothing.
local function CostText(cost)
    if type(cost) ~= "table" then return end
    local parts = {}
    local money = cost[1] or 0
    if money > 0 then
        parts[#parts + 1] = GetCoinTextureString and GetCoinTextureString(money) or string.format("%dg", math.floor(money / 10000))
    end
    for _, c in ipairs(cost[2] or {}) do
        local name, icon = "currency " .. c[1], nil
        if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
            local ok, info = pcall(C_CurrencyInfo.GetCurrencyInfo, c[1])
            if ok and info and info.name then name, icon = info.name, info.iconFileID end
        end
        parts[#parts + 1] = string.format("%s%s %s", icon and ("|T" .. icon .. ":0|t ") or "", BreakUpLargeNumbers and BreakUpLargeNumbers(c[2]) or c[2], name)
    end
    for _, c in ipairs(cost[3] or {}) do
        parts[#parts + 1] = string.format("%d x %s", c[2], ns.ItemName(c[1]) or ("item " .. c[1]))
    end
    if #parts > 0 then return table.concat(parts, " + ") end
end

ns.CostText = CostText

-- List of { text, r, g, b } lines explaining how to get a collectible (or kill / loot a spot).
function ns.HowToGet(it)
    local out = {}
    -- skips empty text; colour defaults to white
    local function add(text, r, g, b) if text and text ~= "" then out[#out + 1] = { text, r or 1, g or 1, b or 1 } end end
    if it.kind == "point" then
        local zone = it.zone and it.zone.name or ""
        add((it.pkind == "boss" and "World boss in " or "Rare in ") .. zone .. (it.wq and " (world quest)" or ""), 0.9, 0.85, 0.7)
        add(Where(it.spots and it.spots[1]), 0.7, 0.7, 0.7)
        if it.spots and #it.spots > 1 then add(string.format("(%d spawn points)", #it.spots), 0.6, 0.6, 0.6) end
        if it.groupAch then
            local a = ns.Ach(it.groupAch)
            if a then add("Counts for " .. a.name, 0.6, 0.8, 1) end
        end
        -- its collectible drops: which you have, and how often you have tried for the rest
        local drops = {}
        for _, l in ipairs(it.loot or {}) do
            if l[2] then
                local n = ns.ItemName(l[1])
                if n then
                    local _, owned = ns.ItemCollect(l[1], l[2])
                    local tries = ns.Attempts(l[1])
                    drops[#drops + 1] = n .. (owned == true and " |cff55ff55(have)|r"
                        or (tries > 0 and string.format(" |cffaaaaaa(%d %s)|r", tries, tries == 1 and "attempt" or "attempts") or ""))
                end
            end
        end
        if #drops > 0 then add("Drops " .. table.concat(drops, ", "), 0.6, 0.8, 1) end
        if it.done and ns.LootedToday(it) and #ns.FarmWants(it) > 0 then
            add("Looted today: worth another try after the daily reset", 0.7, 0.7, 0.7)
        elseif ns.FarmWanted(it) then
            add("Farm: killed already, but it still drops something you need", 1, 0.56, 0.25)
        end
        if it.note then add(it.note, 0.85, 0.8, 0.65) end
        return out
    end
    if it.vendors and not it.source then
        for i, v in ipairs(it.vendors) do
            if i > 2 then add(string.format("(+%d more vendors)", #it.vendors - 2), 0.6, 0.6, 0.6); break end
            add("Sold by |cffffffff" .. (v.name or "?") .. "|r" .. (v.tag and ("  <" .. v.tag .. ">") or ""), 0.9, 0.85, 0.7)
            add(Where(v.spots[1]), 0.7, 0.7, 0.7)
            local cost = CostText(v.cost)
            if cost then add("Costs " .. cost, 1, 0.82, 0.3) end
        end
    end
    local src = it.source
    if src then
        local zone = src.zone and src.zone.name or ""
        local group = src.groupAch and ns.Ach(src.groupAch)
        if it.shared and (src.pkind == "rare" or src.pkind == "boss") then
            add("Can drop from any rare" .. (group and (" of |cffffffff" .. group.name .. "|r") or "") .. " in " .. zone, 0.9, 0.85, 0.7)
            if src.name then add("For example: " .. src.name, 0.7, 0.7, 0.7) end
        elseif src.pkind == "rare" then add("Drops from the rare |cffffffff" .. (src.name or "?") .. "|r in " .. zone, 0.9, 0.85, 0.7)
        elseif src.pkind == "boss" then add("Drops from the world boss |cffffffff" .. (src.name or "?") .. "|r in " .. zone, 0.9, 0.85, 0.7)
        elseif src.pkind == "delve" then add("From a Sturdy Chest in " .. ((src.parent and src.parent.name) or "a delve"), 0.9, 0.85, 0.7)
        else add("Loot the treasure |cffffffff" .. (src.name or "?") .. "|r in " .. zone, 0.9, 0.85, 0.7) end
        add(Where(src.spots and src.spots[1]), 0.7, 0.7, 0.7)
        if src.spots and #src.spots > 1 then add(string.format("(%d spawn points)", #src.spots), 0.6, 0.6, 0.6) end
        if src.groupAch and not it.shared then
            local a = ns.Ach(src.groupAch)
            if a then add("Also counts for " .. a.name, 0.6, 0.8, 1) end
        end
        if src.steps then add(string.format("%d steps: track it and the arrow guides you through each one", #src.steps), 0.6, 0.8, 1) end
        if src.note then add(src.note, 0.85, 0.8, 0.65) end
    elseif it.renown then
        local r = ns.Rep(it.renown.faction)
        local fname = r and r.name or "the faction"
        add(string.format("Renown %d with |cffffffff%s|r", it.renown.level, fname), 0.9, 0.85, 0.7)
        if r then
            if r.cur >= it.renown.level then add("Unlocked: pick it up from the faction's quartermaster", 0.4, 0.9, 0.4)
            else add(string.format("You are at Renown %d (%d to go)", r.cur, it.renown.level - r.cur), 1, 0.6, 0.3) end
        end
    elseif it.dropSource and not (it.viaAch and it.dropSource.a) then
        add(it.dropSource.t, 0.9, 0.85, 0.7)
        if it.dropSource.at and #it.dropSource.at > 1 then add(string.format("(%d spots)", #it.dropSource.at), 0.6, 0.6, 0.6) end
        if it.sourceText and it.sourceText ~= "" and not it.sourceText:find("^Toy added") then
            for part in (it.sourceText .. "; "):gmatch("(.-);%s") do add(part, 0.7, 0.7, 0.7) end
        end
    elseif it.sourceText and it.sourceText ~= "" and not it.vendors then
        for part in (it.sourceText .. "; "):gmatch("(.-);%s") do add(part, 0.9, 0.85, 0.7) end
    end
    if it.kind == "collect" and it.spots and it.spots[1] and not src and not it.vendors then add(Where(it.spots[1]), 0.7, 0.7, 0.7) end
    if it.instance then
        add("Inside " .. (it.instance.name or "the instance") .. (it.instance.raid and " (raid)" or " (dungeon)") .. ": the arrow points at the entrance", 0.6, 0.8, 1)
    end
    if it.viaAch then
        add("Reward from the achievement |cffffffff" .. (it.viaAch.name or "?") .. "|r" .. (it.viaAch.done and " (done)" or ""), 0.6, 0.8, 1)
        if not it.viaAch.done then add("Track it and the arrow walks you through the achievement", 0.6, 0.8, 1) end
    end
    if it.kind == "collect" and it.itemID and not it.done and ns.Attempts(it.itemID) > 0 then
        add(string.format("Attempts so far: %d", ns.Attempts(it.itemID)), 0.8, 0.8, 0.8)
    end
    if #out == 0 then add("No source known yet", 0.6, 0.6, 0.6) end
    return out
end

-- Appends the "How to get it" block to GameTooltip.
function ns.AddHowToGet(it)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("How to get it", 1, 0.82, 0.3)
    for _, l in ipairs(ns.HowToGet(it)) do GameTooltip:AddLine(l[1], l[2], l[3], l[4], true) end
end

------------------------------------------------------------------------
-- the viewer
------------------------------------------------------------------------

-- Builds the viewer, hidden, sized w x h on parent. onBack runs from its "Show map" button.
function ns.CreateShowcase(parent, w, h, onBack)
    local sc = CreateFrame("Frame", nil, parent)
    sc:SetSize(w, h)
    sc:EnableMouse(true)
    sc:EnableMouseWheel(true)
    local bg = sc:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.04, 0.035, 0.03, 0.95)
    local glow = sc:CreateTexture(nil, "BORDER")
    glow:SetAllPoints()
    glow:SetColorTexture(1, 1, 1, 1)
    if CreateColor then
        pcall(glow.SetGradient, glow, "VERTICAL", CreateColor(0.03, 0.025, 0.02, 0.9), CreateColor(0.22, 0.16, 0.08, 0.6))
    else
        glow:SetColorTexture(0.12, 0.09, 0.05, 0.6)
    end

    -- one model for creatures/displays, one that can wear transmog
    sc.model = CreateFrame("PlayerModel", nil, sc)
    sc.model:SetPoint("TOPLEFT", 4, -4)
    sc.model:SetPoint("BOTTOMRIGHT", -4, 24)
    sc.dress = CreateFrame("DressUpModel", nil, sc)
    sc.dress:SetAllPoints(sc.model)
    sc.icon = sc:CreateTexture(nil, "ARTWORK")
    sc.icon:SetSize(96, 96)
    sc.icon:SetPoint("CENTER", 0, 10)

    sc.caption = sc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sc.caption:SetPoint("BOTTOMLEFT", 8, 6)
    sc.caption:SetPoint("BOTTOMRIGHT", -8, 6)
    sc.caption:SetJustifyH("CENTER")
    sc.caption:SetWordWrap(false)
    sc.hint = sc:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    sc.hint:SetPoint("TOPLEFT", 6, -5)
    sc.hint:SetText("Drag to turn, wheel to zoom")

    local back = CreateFrame("Button", nil, sc, "UIPanelButtonTemplate")
    back:SetSize(90, 20)
    back:SetPoint("TOPRIGHT", -4, -4)
    back:SetText("Show map")
    back:SetScript("OnClick", onBack)
    back:SetFrameLevel(sc.model:GetFrameLevel() + 5)

    sc.facing, sc.zoom, sc.spin = 0.5, 1, true
    -- the dress-up model while it shows an appearance, else the plain one
    local function active() return sc.dress:IsShown() and sc.dress or sc.model end
    -- pushes facing and zoom to the model on show; the dress-up model ignores zoom
    local function apply()
        local m = active()
        pcall(m.SetFacing, m, sc.facing)
        if m == sc.model then pcall(m.SetCamDistanceScale, m, sc.zoom) end
    end
    -- a left-button drag turns the model and stops the idle spin
    sc:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then self.dragX = GetCursorPosition(); self.spin = false end
    end)
    sc:SetScript("OnMouseUp", function(self) self.dragX = nil end)
    -- wheel up zooms in; camera distance scale stays between 0.4 and 3
    sc:SetScript("OnMouseWheel", function(self, delta)
        self.zoom = math.max(0.4, math.min(3, self.zoom - delta * 0.15))
        apply()
    end)
    -- follows the cursor while dragging, otherwise spins slowly until the first drag
    sc:SetScript("OnUpdate", function(self, elapsed)
        if self.dragX then
            local x = GetCursorPosition()
            self.facing = self.facing + (x - self.dragX) * 0.012
            self.dragX = x
            apply()
        elseif self.spin then
            self.facing = self.facing + elapsed * 0.35
            apply()
        end
    end)

    -- Shows an item with a fresh view. Returns false, leaving the current view alone, when there is
    -- nothing to show for it.
    function sc:Present(it)
        local info = ns.ModelInfo(it)
        if not info then return false end
        self.model:Hide(); self.dress:Hide(); self.icon:Hide()
        self.facing, self.zoom, self.spin = 0.5, 1, true
        if info.kind == "display" then
            self.model:Show()
            self.model:ClearModel()
            pcall(self.model.SetDisplayInfo, self.model, info.id)
        elseif info.kind == "creature" then
            self.model:Show()
            self.model:ClearModel()
            pcall(self.model.SetCreature, self.model, info.id)
        elseif info.kind == "tryon" then
            self.dress:Show()
            pcall(self.dress.SetUnit, self.dress, "player")
            pcall(self.dress.Undress, self.dress)
            pcall(self.dress.TryOn, self.dress, info.link)
        else
            self.icon:SetTexture(info.icon)
            self.icon:Show()
            self.spin = false
        end
        self.hint:SetShown(info.kind ~= "icon")
        local label = ns.TYPE_LABEL[it.ctype or ""] or (it.pkind == "boss" and "World boss") or "Rare"
        self.caption:SetText(string.format("%s  |cff9a927f%s%s|r", it.liveName or it.name or "?", label,
            it.done and "  - collected" or ""))
        apply()
        return true
    end
    sc:Hide()
    return sc
end
