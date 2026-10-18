-- Completion: the Blizzard-style window. Built only from the game's own templates and art, laid out like the
-- Adventure Guide: a portrait frame with a breadcrumb bar and search box, an expansion dropdown, Journeys-style
-- renown cards for each zone, and Traveler's Log style pages (a section list on the left, the rows on the right).
-- The bottom tabs are Progress, This Week, Warband and Options.
--
-- It shares everything but the drawing with the classic book (UI.lua): the same lines (ns.ListBuild), clicks
-- (ns.ListClick), row text (ns.LineInfo) and tooltips (ns.ItemTooltip). Options > Look switches between the two
-- (settings.ui = "book" for the classic book); only one of them is built per session.

local _, ns = ...

local W, H = 800, 496                    -- the Adventure Guide's size; its inner art is 786 x 425
local CARD_W, CARD_H = 374, 112          -- a Journeys renown card
local ROW_W = 521                        -- a Traveler's Log row
local ITEM_H, CHILD_H, HEAD_H = 48, 24, 36

local frame, inset, nav, search, bookDrop, filterDrop
local views = {}          -- home, zone, page, options, empty
local tabs = {}
local sectionButtons = {}
local homeBox, homeBar, rowBox, rowBar
local headerTitle, headerSub, progress
local pageHost, optionsHost

------------------------------------------------------------------------
-- small helpers
------------------------------------------------------------------------

-- Plays a SOUNDKIT sound by key; unknown keys stay silent.
local function Sound(key)
    local id = SOUNDKIT and SOUNDKIT[key]
    if id then pcall(PlaySound, id) end
end

-- Sets an atlas on a texture when the game has it; returns true when it did.
local function Atlas(tex, name, useSize)
    if not (tex and name and tex.SetAtlas) then return false end
    local ok = pcall(tex.SetAtlas, tex, name, useSize and true or false)
    return ok
end

-- A font string in one of the game's fonts.
local function Font(parent, template, layer)
    local fs = parent:CreateFontString(nil, layer or "OVERLAY", template or "GameFontNormal")
    fs:SetJustifyH("LEFT")
    return fs
end

-- The open book: "midnight", "tww", "pvp" or "seasonal".
local function Book() return ns.cdb.lastExpansion or "midnight" end

-- The books the dropdown offers, in order: the expansions with data, the PvP book, the holidays.
local function Books()
    local out = {}
    for i = #(ns.EXPANSIONS or {}), 1, -1 do
        local e = ns.EXPANSIONS[i]
        if e.ready then out[#out + 1] = e end
    end
    return out
end

-- The book entry for a key.
local function BookInfo(key)
    for _, e in ipairs(ns.EXPANSIONS or {}) do if e.key == key then return e end end
end

-- The pages of a book: its zones (overview first for an expansion), or the holidays.
local function BookPages(key)
    if key == "seasonal" then return ns.EVENT_ZONES or {} end
    local pages = {}
    for _, z in ipairs(ns.ZONES) do
        if (z.exp or "midnight") == key and z.overview then pages[#pages + 1] = z end
    end
    for _, z in ipairs(ns.ZONES) do
        if (z.exp or "midnight") == key and not z.overview then pages[#pages + 1] = z end
    end
    return pages
end

-- Done and total for a page, and the percentage.
local function Totals(z)
    local cur, max = 0, 0
    if ns.ZoneTotals then cur, max = ns.ZoneTotals(z) else cur, max = z.cur or 0, z.max or 0 end
    local pct = (ns.Pct and ns.Pct(cur, max)) or (max > 0 and math.floor(cur / max * 100) or 0)
    return cur, max, pct
end

-- The emblem of a page: its first renown faction's emblem (the Journeys art), else its achievement icon.
local function Emblem(z)
    for _, fid in ipairs(z.factions or {}) do
        if C_MajorFactions and C_MajorFactions.GetMajorFactionData then
            local ok, d = pcall(C_MajorFactions.GetMajorFactionData, fid)
            if ok and d and d.textureKit then
                return "atlas", "majorfactions_icons_" .. tostring(d.textureKit):lower() .. "512",
                    d.factionFontColor and d.factionFontColor.color
            end
        end
    end
    local id = z.iconAch
    if id and GetAchievementInfo then
        local ok, _, _, _, _, _, _, _, _, _, icon = pcall(GetAchievementInfo, id)
        if ok and icon then return "file", icon end
    end
    return "file", "Interface\\Icons\\INV_Misc_Book_09"
end

-- Puts an emblem on a texture.
local function SetEmblem(tex, z)
    local kind, value = Emblem(z)
    if kind == "atlas" and Atlas(tex, value, false) then return end
    tex:SetTexture(kind == "file" and value or "Interface\\Icons\\INV_Misc_Book_09")
end

-- The view the Progress tab shows: the book's cards, or one page.
local function OnHome() return ns.cdb.journalView ~= "zone" end

------------------------------------------------------------------------
-- frame, breadcrumb, search, dropdowns, tabs
------------------------------------------------------------------------

local Refresh   -- defined below

-- Opens a book on its cards.
local function OpenBook(key)
    ns.cdb.lastExpansion = key
    ns.cdb.journalView = "home"
    ns.showAbout, ns.showPage = false, nil
    Refresh()
end

-- Opens a page (a zone or a holiday) on the given section, or its first section with something left.
local function OpenPage(z, secKey)
    if not z then return end
    if z.event then ns.cdb.lastExpansion = "seasonal"; ns.cdb.lastEvent = z.key
    else ns.cdb.lastExpansion = z.exp or "midnight"; ns.cdb.lastZone = z.key end
    if not secKey then
        for _, s in ipairs(ns.ListSectionDefs(z)) do
            local sec = z.sections[s.key]
            if sec and (sec.max or 0) > 0 and (sec.cur or 0) < sec.max then secKey = s.key; break end
        end
        if not secKey then
            for _, s in ipairs(ns.ListSectionDefs(z)) do
                if #z.sections[s.key].items > 0 then secKey = s.key; break end
            end
        end
    end
    ns.cdb.lastSection = secKey
    ns.cdb.journalView = "zone"
    ns.showAbout, ns.showPage = false, nil
    Sound("IG_CHARACTER_INFO_TAB")
    Refresh()
end

-- Rebuilds the breadcrumb: Home > book > page.
local function RefreshNav()
    if not (nav and NavBar_Reset and NavBar_AddButton) then return end
    NavBar_Reset(nav)
    local key = Book()
    local info = BookInfo(key)
    if ns.showAbout or ns.showPage then
        NavBar_AddButton(nav, { name = ns.showAbout and "Options" or (ns.showPage == "week" and "This Week" or "Warband"),
                                OnClick = function() end })
        return
    end
    NavBar_AddButton(nav, { name = info and info.name or key, OnClick = function() OpenBook(key) end })
    if not OnHome() then
        local z = ns.ListZone()
        if z and not (z.overview and #BookPages(key) == 1) then
            NavBar_AddButton(nav, { name = z.name, OnClick = function() OpenPage(z, ns.ListSection()) end })
        end
    end
end

-- Fills the book dropdown: one radio per book.
local function SetupBookDrop()
    if not (bookDrop and bookDrop.SetupMenu) then return end
    bookDrop:SetupMenu(function(_, root)
        for _, e in ipairs(Books()) do
            root:CreateRadio(e.name, function() return Book() == e.key end, function() OpenBook(e.key) end)
        end
    end)
end

-- Fills the list options dropdown (the funnel): hide done, sort, route.
local function SetupFilterDrop()
    if not (filterDrop and filterDrop.SetupMenu) then return end
    local s = ns.db.settings
    filterDrop:SetupMenu(function(_, root)
        root:CreateCheckbox("Hide done", function() return s.hidedone end,
            function() s.hidedone = not s.hidedone; Refresh() end)
        root:CreateCheckbox("Sort: nearest first", function() return s.sortNearest end,
            function() s.sortNearest = not s.sortNearest; if s.sortNearest then s.sortEasy = false end; Refresh() end)
        if ns.DIFFICULTY_ENABLED then
            root:CreateCheckbox("Sort: easiest first", function() return s.sortEasy end,
                function() s.sortEasy = not s.sortEasy; if s.sortEasy then s.sortNearest = false end; Refresh() end)
        end
        local z = ns.ListZone()
        local sec = ns.ListSection()
        if ns.RouteActive and ns.RouteActive() then
            root:CreateDivider()
            root:CreateButton("Stop the route", function() ns.StopRoute(); Refresh() end)
        elseif z and sec and not z.overview and not z.event and ns.PlanRouteForSection then
            root:CreateDivider()
            root:CreateButton("Route: a loop through what is left here", function() ns.PlanRouteForSection(z, sec); Refresh() end)
        end
        if z and z.map and OpenWorldMap then
            root:CreateButton("Show on the world map", function() pcall(OpenWorldMap, z.map) end)
        end
    end)
end

-- Selects bottom tab i (1 Progress, 2 This Week, 3 Warband, 4 Options).
local function SelectTab(i)
    ns.showAbout = i == 4
    ns.showPage = (i == 2 and "week") or (i == 3 and "warband") or nil
    if i == 4 then ns.aboutPage = nil end
    Sound("IG_CHARACTER_INFO_TAB")
    Refresh()
end

-- Creates a bottom tab like the Adventure Guide's.
local function MakeTab(i, text)
    local t = CreateFrame("Button", "CompletionJournalTab" .. i, frame, "PanelTabButtonTemplate")
    t:SetID(i)
    t:SetText(text)
    if PanelTemplates_TabResize then pcall(PanelTemplates_TabResize, t, 0) end
    if i == 1 then t:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 11, 2)
    else t:SetPoint("LEFT", tabs[i - 1], "RIGHT", 3, 0) end
    t:SetScript("OnClick", function(self) SelectTab(self:GetID()) end)
    tabs[i] = t
    return t
end

------------------------------------------------------------------------
-- home view: Journeys-style cards
------------------------------------------------------------------------

-- Sets a card's progress ring (the Journeys radial bar, filled by a cooldown swipe like Blizzard's).
local function SetRing(card, pct, color)
    local cd = card.ring
    if not cd then return end
    if C_Texture and C_Texture.GetAtlasInfo and cd.SetSwipeTexture then
        local info = C_Texture.GetAtlasInfo("ui-journeys-renown-radial-fill")
        if info then
            pcall(cd.SetSwipeTexture, cd, info.file or info.filename)
            if cd.SetTexCoordRange then
                pcall(cd.SetTexCoordRange, cd, { x = info.leftTexCoord, y = info.topTexCoord },
                    { x = info.rightTexCoord, y = info.bottomTexCoord })
            end
        end
    end
    if cd.SetSwipeColor then
        if color and color.GetRGB then cd:SetSwipeColor(color:GetRGB()) else cd:SetSwipeColor(1, 0.82, 0.25) end
    end
    if CooldownFrame_SetDisplayAsPercentage then pcall(CooldownFrame_SetDisplayAsPercentage, cd, (pct or 0) / 100) end
end

-- Builds one card (a renown card from the Journeys tab) inside a pooled row frame.
local function MakeCard(parent)
    local c = CreateFrame("Button", nil, parent)
    c:SetSize(CARD_W, CARD_H)
    c:SetNormalAtlas("ui-journeys-renown-button")
    c:SetPushedAtlas("ui-journeys-renown-button-pressed")
    c:SetHighlightAtlas("ui-journeys-renown-button", "ADD")
    if c.GetHighlightTexture and c:GetHighlightTexture() then c:GetHighlightTexture():SetAlpha(0.25) end
    c.iconFrame = CreateFrame("Frame", nil, c)
    c.iconFrame:SetSize(60, 60)
    c.iconFrame:SetPoint("LEFT", 20, 0)
    c.border = c.iconFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    c.border:SetSize(60, 60)
    c.border:SetPoint("CENTER")
    Atlas(c.border, "ui-journeys-renown-radial-bar", false)
    c.icon = c.iconFrame:CreateTexture(nil, "OVERLAY")
    c.icon:SetSize(40, 40)
    c.icon:SetPoint("CENTER")
    local ok, cd = pcall(CreateFrame, "Cooldown", nil, c)
    if ok and cd then
        cd:SetSize(60, 60)
        cd:SetPoint("CENTER", c.iconFrame)
        if cd.SetReverse then cd:SetReverse(true) end
        if cd.SetHideCountdownNumbers then cd:SetHideCountdownNumbers(true) end
        if cd.SetRotation then pcall(cd.SetRotation, cd, math.rad(180)) end
        if cd.SetDrawEdge then cd:SetDrawEdge(false) end
        if cd.SetDrawBling then cd:SetDrawBling(false) end
        cd:SetFrameLevel(c:GetFrameLevel() + 5)
        c.ring = cd
    end
    c.name = Font(c, "GameFontHighlightMed2")
    c.name:SetSize(260, 20)
    c.name:SetPoint("LEFT", c.iconFrame, "RIGHT", 8, 12)
    c.level = Font(c, "GameFontNormalMed2")
    c.level:SetSize(260, 16)
    c.level:SetPoint("TOPLEFT", c.name, "BOTTOMLEFT", 0, -2)
    c.sub = Font(c, "GameFontDisableSmall")
    c.sub:SetSize(260, 14)
    c.sub:SetPoint("TOPLEFT", c.level, "BOTTOMLEFT", 0, -3)
    c:SetScript("OnClick", function(self) if self.page then OpenPage(self.page) end end)
    c:SetScript("OnEnter", function(self)
        if not self.page then return end
        local cur, max, pct = Totals(self.page)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(self.page.name, 1, 1, 1)
        GameTooltip:AddLine(string.format("%d of %d done (%d%%)", cur, max, pct), 1, 0.82, 0.3)
        if self.page.desc then GameTooltip:AddLine(self.page.desc, 0.8, 0.8, 0.8, true) end
        GameTooltip:AddLine(" ")
        for _, s in ipairs(ns.ListSectionDefs(self.page)) do
            local sec = self.page.sections[s.key]
            if sec and (sec.max or 0) > 0 then
                local full = sec.cur >= sec.max
                GameTooltip:AddDoubleLine(s.name, string.format("%d/%d", sec.cur, sec.max), 0.9, 0.9, 0.9,
                    full and 0.4 or 1, full and 0.9 or 0.82, full and 0.4 or 0.3)
            end
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click to open.", 0.5, 0.5, 0.5)
        GameTooltip:Show()
    end)
    c:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return c
end

-- Fills a card for one page.
local function FillCard(c, z)
    c.page = z
    if not z then c:Hide(); return end
    c:Show()
    SetEmblem(c.icon, z)
    local cur, max, pct = Totals(z)
    local _, _, color = Emblem(z)
    c.name:SetText(z.name)
    if z.event then
        c.level:SetText(ns.EventStatusText and ns.EventStatusText(z) or "")
        c.sub:SetText(max > 0 and string.format("%d / %d", cur, max) or "")
    elseif max > 0 and cur >= max then
        c.level:SetText("Complete")
        c.sub:SetText(string.format("%d / %d", cur, max))
    else
        c.level:SetText(string.format("%d%% complete", pct))
        c.sub:SetText(max > 0 and string.format("%d / %d", cur, max) or "Nothing to count yet")
    end
    SetRing(c, max > 0 and (cur / max * 100) or 0, color)
end

-- The home view's elements: a heading per group, then the cards two to a row.
local function HomeData()
    local key = Book()
    local data = {}
    local pages = BookPages(key)
    local function group(title, list)
        if #list == 0 then return end
        data[#data + 1] = { kind = "head", text = title }
        for i = 1, #list, 2 do data[#data + 1] = { kind = "cards", a = list[i], b = list[i + 1] } end
    end
    if key == "seasonal" then
        local on, rest = {}, {}
        for _, z in ipairs(pages) do
            local state = ns.EventWhen and ns.EventWhen(z)
            if state == "on" then on[#on + 1] = z else rest[#rest + 1] = z end
        end
        group("On now", on)
        group("Holidays", rest)
    else
        local overview, zones = {}, {}
        for _, z in ipairs(pages) do if z.overview then overview[#overview + 1] = z else zones[#zones + 1] = z end end
        group("Zones", zones)
        group(key == "pvp" and "Player vs. Player" or "Expansion-wide", overview)
    end
    return data
end

------------------------------------------------------------------------
-- zone view: Traveler's Log style section list and rows
------------------------------------------------------------------------

-- Selects a section of the open page.
local function SelectSection(key)
    ns.cdb.lastSection = key
    Sound("IG_MAINMENU_OPTION_CHECKBOX_ON")
    Refresh()
end

-- One button of the section list (the Traveler's Log filter list).
local function SectionButton(i)
    local b = sectionButtons[i]
    if b then return b end
    b = CreateFrame("Button", nil, views.zone.list)
    b:SetSize(200, 22)
    b:SetPoint("TOPLEFT", 10, -10 - (i - 1) * 23)
    b.bg = b:CreateTexture(nil, "BACKGROUND")
    b.bg:SetAllPoints()
    b.hl = b:CreateTexture(nil, "HIGHLIGHT")
    b.hl:SetAllPoints()
    Atlas(b.hl, "Options_List_Hover", false)
    b.label = Font(b, "GameFontNormal")
    b.label:SetPoint("LEFT", 10, 0)
    b.count = Font(b, "GameFontHighlightSmall")
    b.count:SetJustifyH("RIGHT")
    b.count:SetPoint("RIGHT", -8, 0)
    b:SetScript("OnClick", function(self) SelectSection(self.key) end)
    sectionButtons[i] = b
    return b
end

-- The section list of the open page, with counts; the open one lit like the Traveler's Log selection.
local function RefreshSections(z)
    local cur = ns.ListSection()
    local n = 0
    for _, s in ipairs(ns.ListSectionDefs(z)) do
        local sec = z.sections[s.key]
        if sec and #sec.items > 0 then
            n = n + 1
            local b = SectionButton(n)
            b.key = s.key
            b.label:SetText(s.name)
            if (sec.max or 0) > 0 then
                local full = sec.cur >= sec.max
                b.count:SetText(string.format("%d/%d", sec.cur, sec.max))
                b.count:SetTextColor(full and 0.4 or 0.9, full and 0.9 or 0.9, full and 0.4 or 0.9)
            else
                b.count:SetText("")
            end
            if s.key == cur then Atlas(b.bg, "Options_List_Active", false); b.bg:Show(); b.label:SetTextColor(1, 1, 1)
            else b.bg:Hide(); b.label:SetTextColor(1, 0.82, 0) end
            b:Show()
        end
    end
    for i = n + 1, #sectionButtons do sectionButtons[i]:Hide() end
end

-- The game's instance art for a dungeon or raid row (the Adventure Guide tile), or nil.
local function InstanceArt(it)
    if not (it and it.kind == "container" and it.ctype == "instance" and EJ_GetInstanceInfo) then return end
    local id = it.instID
    if not id and ns.InstanceInfo then local _, jid = ns.InstanceInfo(it); id = jid end
    if not id then return end
    local ok, _, _, _, buttonImage = pcall(EJ_GetInstanceInfo, id)
    if ok and buttonImage then return buttonImage end
end

-- The height of one list line.
local function LineHeight(ln)
    if ln.header then return HEAD_H end
    if ln.depth and ln.depth > 0 or ln.row then return CHILD_H end
    if InstanceArt(ln.it) then return 72 end
    return ITEM_H
end

-- Builds the regions of a pooled row button once.
local function BuildRow(r)
    if r.built then return end
    r.built = true
    r.bg = r:CreateTexture(nil, "BACKGROUND")
    r.bg:SetAllPoints()
    r.art = r:CreateTexture(nil, "BORDER")
    r.art:SetPoint("TOPLEFT", 4, -4)
    r.art:SetPoint("BOTTOMRIGHT", -4, 4)
    -- the Adventure Guide's tile frame around a dungeon picture
    r.artFrame = r:CreateTexture(nil, "ARTWORK")
    r.artFrame:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
    r.artFrame:SetTexCoord(0.00195313, 0.34179688, 0.42871094, 0.52246094)
    r.hl = r:CreateTexture(nil, "HIGHLIGHT")
    r.hl:SetAllPoints()
    r.hl:SetBlendMode("ADD")
    r.divider = r:CreateTexture(nil, "ARTWORK")
    r.divider:SetPoint("BOTTOMLEFT", 6, 2)
    r.divider:SetPoint("BOTTOMRIGHT", -6, 2)
    r.divider:SetHeight(8)
    r.expand = r:CreateTexture(nil, "OVERLAY")
    r.expand:SetSize(18, 18)
    r.status = r:CreateTexture(nil, "OVERLAY")
    r.status:SetSize(16, 14)
    r.icon = r:CreateTexture(nil, "OVERLAY")
    r.icon:SetSize(24, 24)
    r.track = r:CreateTexture(nil, "OVERLAY")
    r.track:SetSize(18, 18)
    r.track:SetTexture("Interface\\AddOns\\" .. (ns.ADDON or "Completion") .. "\\Textures\\arrow")
    r.text = Font(r, "GameFontHighlightMed2")
    r.text:SetWordWrap(false)
    r.right = Font(r, "GameFontNormalSmall")
    r.right:SetJustifyH("RIGHT")
    r.right:SetWordWrap(false)
    r.strike = r:CreateTexture(nil, "OVERLAY")
    r.strike:SetColorTexture(0.6, 0.58, 0.54, 0.9)
    r.strike:SetHeight(1)
    r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    r:SetScript("OnClick", function(self, button)
        if self.line then
            ns.ListClick(self.line, button)
            Refresh()
        end
    end)
    r:SetScript("OnEnter", function(self)
        local ln = self.line
        if not ln then return end
        if ln.header then
            if ln.ach and ns.ListHeaderTooltip then ns.ListHeaderTooltip(self, ln) end
            return
        end
        if ln.it then ns.ItemTooltip(self, ln.it, ln.row) end
    end)
    r:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

-- Draws one list line into a pooled row button.
local function FillRow(r, ln)
    BuildRow(r)
    r.line = ln
    for _, k in ipairs({ "bg", "art", "artFrame", "divider", "expand", "status", "icon", "track", "strike" }) do r[k]:Hide() end
    r.hl:SetTexture(nil)
    r.text:ClearAllPoints(); r.right:ClearAllPoints(); r.status:ClearAllPoints(); r.icon:ClearAllPoints()
    r.expand:ClearAllPoints(); r.track:ClearAllPoints()
    r.text:SetFontObject("GameFontHighlightMed2")
    if ln.header then
        -- a heading: like the Journeys "Renowns" heading, with the divider under it
        r.text:SetFontObject("GameFontNormalLarge")
        r.text:SetPoint("LEFT", 10, 4)
        r.text:SetPoint("RIGHT", r.right, "LEFT", -8, 4)
        r.text:SetText(ln.text or "")
        r.text:SetTextColor(1, 0.82, 0)
        r.right:SetPoint("RIGHT", -14, 4)
        r.right:SetText((ln.max or 0) > 0 and string.format("%d/%d", ln.cur, ln.max) or (ln.leftOut and tostring(ln.leftOut) or ""))
        local full = (ln.max or 0) > 0 and ln.cur >= ln.max
        r.right:SetTextColor(full and 0.4 or 1, full and 0.9 or 0.82, full and 0.4 or 0)
        if Atlas(r.divider, "ui-journeys-renown-divider", false) then r.divider:Show() end
        return
    end
    if ln.info or ln.outInfo then
        -- a game category with its count, or a reason items are left out
        r.text:SetFontObject("GameFontHighlight")
        r.text:SetPoint("LEFT", 24, 0)
        r.text:SetPoint("RIGHT", r.right, "LEFT", -8, 0)
        r.text:SetText(ln.text or "")
        local full = ln.info and (ln.max or 0) > 0 and ln.cur >= ln.max
        r.text:SetTextColor(ln.outInfo and 0.6 or 0.95, ln.outInfo and 0.58 or 0.95, ln.outInfo and 0.54 or 0.95)
        r.right:SetPoint("RIGHT", -14, 0)
        r.right:SetText(ln.outInfo and tostring(#ln.outInfo.ids) or string.format("%d/%d", ln.cur or 0, ln.max or 0))
        r.right:SetTextColor(full and 0.4 or 0.8, full and 0.9 or 0.8, full and 0.4 or 0.8)
        if full then r.status:SetPoint("LEFT", 6, 0); Atlas(r.status, "activities-icon-checkmark-small-yellow", false); r.status:Show() end
        return
    end
    local info = ns.LineInfo(ln)
    local child = (ln.depth or 0) > 0 or ln.row ~= nil
    local left = 12 + (ln.depth or 0) * 18
    if not child then
        -- a top-level row: the Traveler's Log row art, lit when done
        Atlas(r.bg, info.done and "activities-complete" or "activities-incomplete", false)
        r.bg:Show()
        Atlas(r.hl, info.done and "activities-complete" or "activities-incomplete", false)
        r.hl:SetAlpha(0.3)
        -- a dungeon or raid gets its Adventure Guide picture behind the name
        local art = InstanceArt(ln.it)
        if art then
            r.art:ClearAllPoints()
            r.art:SetPoint("LEFT", 8, 0)
            r.art:SetSize(116, 64)
            r.art:SetTexture(art)
            r.art:SetTexCoord(0, 0.68359375, 0, 0.7421875)
            r.art:Show()
            r.artFrame:ClearAllPoints()
            r.artFrame:SetPoint("TOPLEFT", r.art, -2, 2)
            r.artFrame:SetPoint("BOTTOMRIGHT", r.art, 2, -2)
            r.artFrame:Show()
        end
    else
        r.hl:SetColorTexture(1, 0.82, 0.3, 0.12)
        r.hl:SetAlpha(1)
        r.text:SetFontObject("GameFontHighlight")
    end
    if not child and InstanceArt(ln.it) then left = 132 end
    if info.canExpand then
        r.expand:SetPoint("LEFT", left, 0)
        Atlas(r.expand, info.expanded and "campaign_headericon_open" or "campaign_headericon_closed", false)
        r.expand:Show()
        left = left + 20
    end
    r.status:SetPoint("LEFT", left, 0)
    if info.done then Atlas(r.status, "activities-icon-checkmark-small-yellow", false); r.status:SetSize(15, 13); r.status:Show()
    elseif info.upNow then r.status:SetTexture("Interface\\COMMON\\Indicator-Green"); r.status:SetSize(14, 14); r.status:Show()
    elseif info.current then r.status:SetTexture("Interface\\RaidFrame\\ReadyCheck-Waiting"); r.status:SetSize(14, 14); r.status:Show() end
    left = left + 18
    if info.icon then
        r.icon:SetTexture(info.icon)
        r.icon:SetSize(child and 18 or 26, child and 18 or 26)
        r.icon:SetPoint("LEFT", left, 0)
        r.icon:Show()
        left = left + (child and 22 or 30)
    end
    r.right:SetPoint("RIGHT", info.tracked and -34 or -16, 0)
    r.right:SetWidth(child and 150 or 190)
    r.right:SetText(info.sub or "")
    r.right:SetTextColor(0.85, 0.8, 0.65)
    r.text:SetPoint("LEFT", left, 0)
    r.text:SetPoint("RIGHT", r.right, "LEFT", -8, 0)
    r.text:SetText(info.name or "?")
    if info.soon then r.text:SetTextColor(0.6, 0.58, 0.54)
    elseif info.done then r.text:SetTextColor(0.55, 0.8, 0.5)
    elseif info.current then r.text:SetTextColor(1, 0.82, 0)
    else r.text:SetTextColor(child and 0.92 or 1, child and 0.9 or 1, child and 0.85 or 1) end
    r.text:SetAlpha(info.faded and 0.6 or 1)
    if info.soon then
        r.strike:SetPoint("LEFT", r.text, "LEFT", 0, 0)
        r.strike:SetWidth(math.max(1, math.min(r.text:GetStringWidth() or 0, r.text:GetWidth() or 0)))
        r.strike:Show()
    end
    if info.tracked then r.track:SetPoint("RIGHT", -12, 0); r.track:Show() end
end

------------------------------------------------------------------------
-- scroll lists (the game's ScrollBox with its minimal scroll bar)
------------------------------------------------------------------------

-- A ScrollBox list with a minimal scroll bar; height(data) sizes each element, init(frame, data) fills it.
-- Returns the box, or nil when the client has no ScrollBox (then nothing is drawn).
local function MakeList(parent, w, h, x, y, height, init)
    if not (CreateScrollBoxListLinearView and ScrollUtil and ScrollUtil.InitScrollBoxListWithScrollBar) then return end
    local box = CreateFrame("Frame", nil, parent, "WowScrollBoxList")
    box:SetSize(w, h)
    box:SetPoint("TOPLEFT", x, y)
    local bar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
    bar:SetPoint("TOPLEFT", box, "TOPRIGHT", 8, -6)
    bar:SetPoint("BOTTOMLEFT", box, "BOTTOMRIGHT", 8, 6)
    local view = CreateScrollBoxListLinearView()
    view:SetElementExtentCalculator(function(_, data) return height(data) end)
    view:SetElementInitializer("Button", init)
    ScrollUtil.InitScrollBoxListWithScrollBar(box, bar, view)
    return box, bar
end

-- Puts a list of elements into a ScrollBox, keeping the scroll position.
local function SetData(box, list)
    if not (box and CreateDataProvider) then return end
    local keep = ScrollBoxConstants and ScrollBoxConstants.RetainScrollPosition
    box:SetDataProvider(CreateDataProvider(list), keep)
end

------------------------------------------------------------------------
-- header: title, subtitle and the Traveler's Log progress bar
------------------------------------------------------------------------

-- Sets the progress bar (the Traveler's Log threshold bar) to cur of max.
local function SetProgress(cur, max, label)
    if not progress then return end
    progress.bar:SetMinMaxValues(0, math.max(1, max))
    progress.bar:SetValue(math.min(cur, max))
    progress.label:SetText(label or "Progress")
    progress.value:SetText(max > 0 and string.format("%d / %d  (%d%%)", cur, max, math.floor(cur / max * 100 + 0.0001)) or "")
    progress:Show()
end

------------------------------------------------------------------------
-- refresh
------------------------------------------------------------------------

-- Redraws the window for the open tab, book and page.
Refresh = function()
    if not (frame and frame:IsShown()) then return end
    if not ns.built then return end
    local tab = ns.showAbout and 4 or (ns.showPage == "week" and 2) or (ns.showPage and 3) or 1
    if PanelTemplates_SetTab then pcall(PanelTemplates_SetTab, frame, tab) end
    for _, v in pairs(views) do v:Hide() end
    progress:Hide()
    RefreshNav()
    search:SetShown(tab == 1)
    filterDrop:SetShown(tab == 1 and not OnHome())
    bookDrop:SetShown(tab == 1)
    if tab == 4 then
        views.options:Show()
        headerTitle:SetText("Options")
        headerSub:SetText("How the book counts and looks.")
        if ns.RefreshAbout then ns.RefreshAbout() end
        return
    end
    if tab == 2 or tab == 3 then
        views.page:Show()
        headerTitle:SetText(tab == 2 and "This Week" or "Warband")
        headerSub:SetText(tab == 2 and "What is up now and what repeats." or "What your other characters still have to do.")
        if ns.RefreshPage then ns.RefreshPage() end
        return
    end
    local key = Book()
    local info = BookInfo(key)
    if bookDrop.SetDefaultText then bookDrop:SetDefaultText(info and info.name or key) end
    if bookDrop.GenerateMenu then pcall(bookDrop.GenerateMenu, bookDrop) end
    -- a book with a single page (PvP) opens straight on it
    local pages = BookPages(key)
    if OnHome() and #pages == 1 and ns.ListSearch() == "" then ns.cdb.journalView = "zone"; ns.cdb.lastZone = pages[1].key end
    -- searching from the cards searches the whole book
    if OnHome() and ns.ListSearch() ~= "" then
        local saved = ns.cdb.lastSection
        ns.cdb.lastSection = nil
        views.zone:Show()
        views.zone.list:Hide()
        rowBox:ClearAllPoints(); rowBox:SetPoint("TOPLEFT", views.zone, "TOPLEFT", 20, -60); rowBox:SetWidth(730)
        headerTitle:SetText("Search")
        headerSub:SetText(string.format("Everything in the book matching \"%s\".", ns.ListSearch()))
        local data = {}
        for i, ln in ipairs(ns.ListBuild()) do data[i] = ln end
        SetData(rowBox, data)
        ns.cdb.lastSection = saved
        return
    end
    if OnHome() then
        views.home:Show()
        headerTitle:SetText(info and info.name or key)
        local cur, max = 0, 0
        for _, z in ipairs(pages) do
            if not z.overview or #pages == 1 then local c, m = Totals(z); cur, max = cur + c, max + m end
        end
        -- an expansion's overview page holds the whole expansion's total
        for _, z in ipairs(pages) do if z.overview and not z.event then cur, max = Totals(z) end end
        headerSub:SetText(key == "seasonal" and "Every holiday, with what is on right now." or "Pick a zone to see what is left there.")
        if key ~= "seasonal" then SetProgress(cur, max, "Book progress") end
        SetData(homeBox, HomeData())
        return
    end
    -- one page: sections on the left, rows on the right
    local z = ns.ListZone()
    views.zone:Show()
    views.zone.list:Show()
    rowBox:ClearAllPoints(); rowBox:SetPoint("TOPRIGHT", views.zone, "TOPRIGHT", -30, -96); rowBox:SetWidth(ROW_W)
    headerTitle:SetText(z.name)
    headerSub:SetText(z.event and (ns.EventStatusText and ns.EventStatusText(z) or "") or (z.desc or ""))
    local cur, max = Totals(z)
    SetProgress(cur, max, z.overview and "Expansion progress" or "Zone progress")
    RefreshSections(z)
    SetupFilterDrop()
    local data = {}
    for i, ln in ipairs(ns.ListBuild()) do data[i] = ln end
    if #data == 0 then data[1] = { header = true, text = "Nothing here yet", cur = 0, max = 0 } end
    SetData(rowBox, data)
end

------------------------------------------------------------------------
-- the frame
------------------------------------------------------------------------

-- A heading for the pages hosted from About.lua and Pages.lua: the Journeys heading font with its divider.
local function Header(parent, width)
    local h = CreateFrame("Frame", nil, parent)
    h:SetSize(width or 400, 30)
    h.text = Font(h, "GameFontNormalLarge2")
    h.text:SetJustifyH("CENTER")
    h.text:SetPoint("TOP", 0, 0)
    h.line = h:CreateTexture(nil, "ARTWORK")
    h.line:SetPoint("TOPLEFT", h, "TOPLEFT", 10, -22)
    h.line:SetPoint("TOPRIGHT", h, "TOPRIGHT", -10, -22)
    h.line:SetHeight(10)
    Atlas(h.line, "ui-journeys-renown-divider", false)
    function h:Set(t) self.text:SetText(t) end
    return h
end

-- A left-justified font string for the hosted pages; size, if given, changes the size and keeps the face.
local function Text(parent, font, size)
    local fs = parent:CreateFontString(nil, "OVERLAY", font or "GameFontHighlight")
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    if size then
        local face, _, flags = fs:GetFont()
        if face then fs:SetFont(face, size, flags) end
    end
    return fs
end

-- Creates the window and everything in it, hidden. Called once from Main.lua instead of the classic book.
function ns.CreateJournal()
    frame = CreateFrame("Frame", "CompletionJournal", UIParent, "PortraitFrameTemplate")
    frame:SetSize(W, H)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); if ns.SavePos then ns.SavePos(self, "journal") end end)
    if frame.SetTitle then frame:SetTitle("Completion") end
    if frame.SetPortraitToAsset then pcall(frame.SetPortraitToAsset, frame, "Interface\\Icons\\INV_Misc_Book_16") end

    -- the breadcrumb bar and the search box, where the Adventure Guide has them
    local okNav, n = pcall(CreateFrame, "Frame", "CompletionJournalNavBar", frame, "NavBarTemplate")
    if okNav and n and NavBar_Initialize then
        nav = n
        nav:SetSize(500, 34)
        nav:SetPoint("TOPLEFT", 61, -22)
        pcall(NavBar_Initialize, nav, "NavButtonTemplate",
            { name = HOME or "Home", OnClick = function() OpenBook(Book()) end }, nav.home, nav.overflow)
    end
    search = CreateFrame("EditBox", "CompletionJournalSearch", frame, "SearchBoxTemplate")
    search:SetSize(210, 20)
    search:SetPoint("TOPRIGHT", -10, -32)
    search:HookScript("OnTextChanged", function(self, user)
        if not user then return end
        local t = self:GetText() or ""
        if #t == 1 then return end   -- one letter matches everything
        ns.ListSetSearch(t)
        Refresh()
    end)
    search:HookScript("OnEditFocusLost", function(self) if (self:GetText() or "") == "" then ns.ListSetSearch(""); Refresh() end end)
    if search.clearButton then search.clearButton:HookScript("OnClick", function() ns.ListSetSearch(""); Refresh() end) end

    -- the inset and its background (the Traveler's Log art)
    inset = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    inset:SetPoint("TOPRIGHT", -4, -60)
    inset:SetPoint("BOTTOMLEFT", 4, 5)
    local bg = inset:CreateTexture(nil, "BACKGROUND", nil, 1)
    bg:SetPoint("TOPLEFT", 3, -1)
    bg:SetPoint("BOTTOMRIGHT", -3, 3)
    if not Atlas(bg, "activities-background", false) then bg:SetColorTexture(0.05, 0.04, 0.03, 0.9) end
    inset.bg = bg

    -- header inside the inset: title and line, the book dropdown, the list options
    headerTitle = Font(inset, "GameFontNormalLarge2")
    headerTitle:SetPoint("TOPLEFT", 20, -16)
    headerSub = Font(inset, "GameFontHighlightMed2")
    headerSub:SetPoint("LEFT", headerTitle, "RIGHT", 16, 0)
    headerSub:SetPoint("RIGHT", inset, "RIGHT", -250, 0)
    headerSub:SetWordWrap(false)
    local okDrop, d = pcall(CreateFrame, "DropdownButton", nil, inset, "WowStyle1DropdownTemplate")
    if okDrop and d then
        bookDrop = d
        bookDrop:SetWidth(160)
        bookDrop:SetPoint("TOPRIGHT", -14, -10)
        SetupBookDrop()
    else
        bookDrop = CreateFrame("Frame", nil, inset)
    end
    local okF, f = pcall(CreateFrame, "DropdownButton", nil, inset, "WowStyle1FilterDropdownTemplate")
    if okF and f then
        filterDrop = f
        filterDrop:SetWidth(90)
        if filterDrop.SetText then filterDrop:SetText(FILTER or "Filter") end
        filterDrop:SetPoint("RIGHT", bookDrop, "LEFT", -6, 0)
    else
        filterDrop = CreateFrame("Frame", nil, inset)
    end

    -- the progress bar (the Traveler's Log threshold bar)
    progress = CreateFrame("Frame", nil, inset)
    progress:SetSize(663, 33)
    progress:SetPoint("TOPLEFT", 46, -48)
    progress.back = progress:CreateTexture(nil, "BACKGROUND")
    progress.back:SetPoint("CENTER")
    Atlas(progress.back, "activities-bar-background", true)
    progress.bar = CreateFrame("StatusBar", nil, progress)
    progress.bar:SetAllPoints()
    local fill = progress.bar:CreateTexture(nil, "ARTWORK")
    if not Atlas(fill, "activities-bar-fill", false) then fill:SetTexture("Interface\\TargetingFrame\\UI-StatusBar") end
    progress.bar:SetStatusBarTexture(fill)
    progress.border = progress.bar:CreateTexture(nil, "OVERLAY")
    progress.border:SetPoint("CENTER", 0, -2)
    Atlas(progress.border, "activities-bar-border", true)
    progress.label = Font(progress.bar, "GameFontHighlight")
    progress.label:SetPoint("LEFT", 15, 0)
    progress.value = Font(progress.bar, "GameFontHighlight")
    progress.value:SetJustifyH("RIGHT")
    progress.value:SetPoint("RIGHT", -30, 0)

    -- home view: the cards
    views.home = CreateFrame("Frame", nil, inset)
    views.home:SetAllPoints()
    homeBox = MakeList(views.home, 748, 320, 14, -92, function(data) return data.kind == "head" and 40 or CARD_H + 6 end,
        function(row, data)
            if not row.cardA then
                row.cardA = MakeCard(row); row.cardA:SetPoint("LEFT", 0, 0)
                row.cardB = MakeCard(row); row.cardB:SetPoint("LEFT", row.cardA, "RIGHT", 0, 0)
                row.head = Font(row, "GameFontHighlightLarge")
                row.head:SetPoint("TOPLEFT", 10, -6)
                row.line = row:CreateTexture(nil, "ARTWORK")
                row.line:SetPoint("TOPLEFT", 14, -26)
                row.line:SetPoint("TOPRIGHT", -31, -26)
                row.line:SetHeight(16)
                Atlas(row.line, "ui-journeys-renown-divider", false)
            end
            local head = data.kind == "head"
            row.head:SetShown(head); row.line:SetShown(head)
            if head then
                row.head:SetText(data.text)
                row.cardA:Hide(); row.cardB:Hide()
            else
                FillCard(row.cardA, data.a)
                FillCard(row.cardB, data.b)
            end
        end)

    -- zone view: the section list and the rows
    views.zone = CreateFrame("Frame", nil, inset)
    views.zone:SetAllPoints()
    views.zone.list = CreateFrame("Frame", nil, views.zone)
    views.zone.list:SetSize(224, 320)
    views.zone.list:SetPoint("TOPLEFT", 5, -96)
    local lbg = views.zone.list:CreateTexture(nil, "BACKGROUND")
    lbg:SetAllPoints()
    if not Atlas(lbg, "activities-container", false) then lbg:SetColorTexture(0, 0, 0, 0.3) end
    rowBox, rowBar = MakeList(views.zone, ROW_W, 320, 250, -96, LineHeight, FillRow)
    if not rowBox then rowBox = CreateFrame("Frame", nil, views.zone); rowBox:SetSize(ROW_W, 320) end

    -- the hosted pages: This Week and Warband (Pages.lua), Options (About.lua)
    views.page = CreateFrame("Frame", nil, inset)
    views.page:SetAllPoints()
    pageHost = CreateFrame("Frame", nil, views.page)
    pageHost:SetSize(560, 360)
    pageHost:SetPoint("TOP", 0, -44)
    views.options = CreateFrame("Frame", nil, inset)
    views.options:SetAllPoints()
    -- the options are taller than the window: they scroll, with the game's minimal scroll bar
    local okS, sf = pcall(CreateFrame, "ScrollFrame", nil, views.options, "ScrollFrameTemplate")
    if not okS or not sf then sf = CreateFrame("ScrollFrame", nil, views.options, "UIPanelScrollFrameTemplate") end
    sf:SetPoint("TOPLEFT", 100, -44)
    sf:SetPoint("BOTTOMRIGHT", -110, 8)
    optionsHost = CreateFrame("Frame", nil, sf)
    optionsHost:SetSize(560, 620)
    sf:SetScrollChild(optionsHost)
    views.options.scroll = sf
    if ns.BuildPages then ns.BuildPages(pageHost, Header, Text, 560) end
    if ns.BuildAbout then ns.BuildAbout(optionsHost, Header, Text, GameFontNormalHuge, 560) end

    -- the bottom tabs
    MakeTab(1, "Progress")
    MakeTab(2, "This Week")
    MakeTab(3, "Warband")
    MakeTab(4, "Options")
    frame.Tabs = tabs
    if PanelTemplates_SetNumTabs then pcall(PanelTemplates_SetNumTabs, frame, #tabs) end

    if ns.RestorePos then ns.RestorePos(frame, "journal", "CENTER", 0, 20) end
    frame:SetScale(ns.db.settings.scale or 1)
    frame:SetScript("OnShow", function()
        Sound("IG_CHARACTER_INFO_OPEN")
        if ns.OnShow then ns.OnShow() end
        Refresh()
    end)
    frame:SetScript("OnHide", function() Sound("IG_CHARACTER_INFO_CLOSE") end)
    tinsert(UISpecialFrames, "CompletionJournal")   -- Escape closes it
    frame:Hide()
    ns.main = frame

    -- this window answers the calls the rest of the addon makes
    ns.RefreshUI = Refresh
    ns.RefreshList = Refresh
    ns.Toggle = function(show)
        if show == nil then show = not frame:IsShown() end
        if show then frame:Show() else frame:Hide() end
    end
    ns.IsShown = function() return frame:IsShown() end
    ns.ShowZone = function(z)
        if z then OpenPage(z, ns.ListSection()) else Refresh() end
    end
    ns.JumpTo = function(it)
        if not it then return end
        local host = it.parent or it
        if not host.zone then return end
        if it.parent and ns.ListExpanded then ns.ListExpanded[it.parent.key] = true end
        ns.ListSetSearch("")
        search:SetText("")
        OpenPage(host.zone, host.sec)
        -- bring the item's row into view
        if rowBox and rowBox.ScrollToElementDataByPredicate then
            pcall(rowBox.ScrollToElementDataByPredicate, rowBox, function(data) return data.it == it and not data.row end,
                ScrollBoxConstants and ScrollBoxConstants.AlignCenter)
        end
    end
    ns.Journal = { frame = frame, Refresh = Refresh, OpenPage = OpenPage, OpenBook = OpenBook, SelectTab = SelectTab,
                   SelectSection = SelectSection, homeBox = homeBox, rowBox = rowBox, nav = nav, search = search }
end
