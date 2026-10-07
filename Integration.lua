-- Completion: the ways in from Blizzard's own UI.
--   Settings      an entry under Esc > Options > AddOns that opens the book's options
--   Compartment   the addon button by the minimap: click opens the book, right-click toggles the arrow
--   Key bindings  open the book, next, clear, route (Bindings.xml; names below)
--   Achievements  tracking an achievement in Blizzard's achievement window (its Track box) points the arrow at
--                 it when the book knows it; achievement links in chat get the book's walkthrough in their tooltip
--   Collections   a Completion button in the Mount Journal and the Pet Journal for the selected mount or pet:
--                 hover for how to get it, click to track it

local _, ns = ...

------------------------------------------------------------------------
-- key bindings (the bindings themselves are in Bindings.xml)
------------------------------------------------------------------------

BINDING_HEADER_COMPLETION = "Completion"
BINDING_NAME_COMPLETION_TOGGLE = "Open or close the book"
BINDING_NAME_COMPLETION_NEXT = "Track the next open thing (skip)"
BINDING_NAME_COMPLETION_CLEAR = "Stop tracking"
BINDING_NAME_COMPLETION_ROUTE = "Plan a route here"
BINDING_NAME_COMPLETION_WATCH = "Add what you track to the watch list"

------------------------------------------------------------------------
-- addon compartment (## AddonCompartmentFunc in the TOC)
------------------------------------------------------------------------

-- Click: open or close the book. Right-click: show or hide the arrow.
function Completion_OnAddonCompartmentClick(_, button)
    if button == "RightButton" then
        ns.db.settings.arrow = not ns.db.settings.arrow
        ns.UpdateTarget()
    else
        ns.Toggle()
    end
end

-- Hover text for the compartment entry: the zone you are in and its progress.
function Completion_OnAddonCompartmentEnter(_, frame)
    GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
    GameTooltip:AddLine("Completion")
    local z = ns.built and ns.PlayerZone()
    if z then
        local cur, max = ns.ZoneTotals(z)
        GameTooltip:AddDoubleLine(z.name, string.format("%d%%", ns.Pct(cur, max)), 1, 0.82, 0.5, 1, 1, 1)
    end
    GameTooltip:AddLine("Click: open the book. Right-click: show or hide the arrow.", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end

-- Hides the compartment hover text.
function Completion_OnAddonCompartmentLeave()
    GameTooltip:Hide()
end

------------------------------------------------------------------------
-- Esc > Options > AddOns
------------------------------------------------------------------------

-- A small page in Blizzard's settings that points to the book's own options.
local function CreateSettingsPage()
    if not (Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) then return end
    local f = CreateFrame("Frame")
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Completion")
    local text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    text:SetWidth(560)
    text:SetJustifyH("LEFT")
    text:SetText("Every option lives in the book itself, on its gear tab. Key bindings are under "
        .. "Key Bindings > AddOns > Completion. The minimap button and the addon compartment open the book.")
    local open = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    open:SetSize(200, 24)
    open:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -16)
    open:SetText("Open Completion options")
    open:SetScript("OnClick", function()
        if HideUIPanel and SettingsPanel then HideUIPanel(SettingsPanel) end
        ns.showAbout, ns.showPage, ns.aboutPage = true, nil, nil
        ns.Toggle(true)
        ns.RefreshUI()
    end)
    local category = Settings.RegisterCanvasLayoutCategory(f, "Completion")
    Settings.RegisterAddOnCategory(category)
end

------------------------------------------------------------------------
-- achievements
------------------------------------------------------------------------

-- Tracking an achievement in Blizzard's window: the arrow follows it too (option "Follow tracked achievements").
local function OnAchievementTracked(id, added)
    if not (ns.built and added and ns.db.settings.followTracked ~= false) then return end
    local it = ns.AchItem(id)
    if it and not it.done then
        ns.Track(it)
        ns.Print("Guiding you to " .. (it.liveName or it.name or "the achievement") .. ".")
    end
end

-- Achievement links (chat, the achievement window's links): the book's place and walkthrough under the tooltip.
local function OnHyperlink(tooltip, link)
    if not (ns.built and type(link) == "string") then return end
    local id = tonumber(link:match("achievement:(%d+)"))
    local it = id and ns.AchItem(id)
    if not it then return end
    local host = it.parent or it
    tooltip:AddLine(" ")
    local where = host.zone and (host.zone.name .. (host.sec and (" > " .. host.zone.sections[host.sec].name) or "")) or ""
    tooltip:AddLine("Completion: " .. where, 0.9, 0.82, 0.5)
    local note = ns.ACH_NOTES and ns.ACH_NOTES[id]
    if note then tooltip:AddLine(note, 0.9, 0.85, 0.7, true) end
    if ns.ACH_STEPS and ns.ACH_STEPS[id] then
        tooltip:AddLine(string.format("%d-step walkthrough in the book", #ns.ACH_STEPS[id]), 0.6, 0.8, 1)
    end
    tooltip:Show()
end

------------------------------------------------------------------------
-- Mount Journal and Pet Journal
------------------------------------------------------------------------

local byMount, byPet, indexStamp

-- Mount ID and pet species -> the book's collectible, once per build.
local function Index()
    if indexStamp == ns.buildStamp then return end
    indexStamp, byMount, byPet = ns.buildStamp, {}, {}
    for _, z in ipairs(ns.ZONES) do
        for _, it in ipairs(z.sections.collect.items) do
            if it.mountID then byMount[it.mountID] = byMount[it.mountID] or it end
            if it.itemID and C_MountJournal and C_MountJournal.GetMountFromItem then
                local ok, mid = pcall(C_MountJournal.GetMountFromItem, it.itemID)
                if ok and mid then byMount[mid] = byMount[mid] or it end
            end
            if it.itemID and C_PetJournal and C_PetJournal.GetPetInfoByItemID then
                local r = { pcall(C_PetJournal.GetPetInfoByItemID, it.itemID) }
                local species = r[1] and r[14]
                if species then byPet[species] = byPet[species] or it end
            end
        end
    end
end

-- A "Completion" button for one journal. find() returns the book item for what the journal has selected.
local function JournalButton(parent, anchor, find)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(108, 22)
    b:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -8, -8)
    b:SetText("Completion")
    b:SetFrameLevel(anchor:GetFrameLevel() + 20)
    b:Hide()
    b:SetScript("OnEnter", function(self)
        local it = self.it
        if not it then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(it.liveName or it.name or "Completion")
        if it.done then GameTooltip:AddLine("You have it", 0.4, 0.9, 0.4) end
        ns.AddHowToGet(it)
        if not it.done then GameTooltip:AddLine("Click: track it with the arrow.", 0.5, 0.5, 0.5) end
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    b:SetScript("OnClick", function(self)
        if self.it and not self.it.done then
            ns.Track(self.it)
            ns.Print("Tracking " .. (self.it.liveName or self.it.name or "it") .. ".")
        end
    end)
    -- the selection is read a few times a second while the journal is open
    b.ticker = CreateFrame("Frame", nil, parent)
    b.ticker:SetScript("OnUpdate", function(self, elapsed)
        self.acc = (self.acc or 0) + elapsed
        if self.acc < 0.3 then return end
        self.acc = 0
        if not ns.built then b:Hide(); return end
        Index()
        local it = find()
        b.it = it
        b:SetShown(it ~= nil)
    end)
    return b
end

local journalsDone = false

-- Adds the buttons once Blizzard's Collections window has loaded.
local function HookCollections()
    if journalsDone or not MountJournal then return end
    journalsDone = true
    local mountAnchor = MountJournal.MountDisplay or MountJournal
    JournalButton(MountJournal, mountAnchor, function()
        local id = MountJournal.selectedMountID
        return id and byMount[id]
    end)
    local card = PetJournalPetCard or (PetJournal and PetJournal.PetCard)
    if PetJournal and card then
        JournalButton(PetJournal, card, function()
            local species = card.speciesID
            return species and byPet[species]
        end)
    end
end

------------------------------------------------------------------------
-- events
------------------------------------------------------------------------

local f = CreateFrame("Frame")
for _, ev in ipairs({ "PLAYER_LOGIN", "ADDON_LOADED", "CONTENT_TRACKING_UPDATE", "TRACKED_ACHIEVEMENT_LIST_CHANGED" }) do
    pcall(f.RegisterEvent, f, ev)
end
f:SetScript("OnEvent", function(_, event, a1, a2, a3)
    if event == "PLAYER_LOGIN" then
        CreateSettingsPage()
        if GameTooltip then hooksecurefunc(GameTooltip, "SetHyperlink", OnHyperlink) end
        if ItemRefTooltip then hooksecurefunc(ItemRefTooltip, "SetHyperlink", OnHyperlink) end
        HookCollections()
    elseif event == "ADDON_LOADED" then
        if a1 == "Blizzard_Collections" then HookCollections() end
    elseif event == "CONTENT_TRACKING_UPDATE" then
        -- (type, id, isTracked); type 2 is an achievement
        local achType = Enum and Enum.ContentTrackingType and Enum.ContentTrackingType.Achievement or 2
        if a1 == achType then OnAchievementTracked(a2, a3) end
    elseif event == "TRACKED_ACHIEVEMENT_LIST_CHANGED" then
        OnAchievementTracked(a1, a2)
    end
end)
