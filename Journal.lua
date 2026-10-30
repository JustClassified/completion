-- Completion: the Blizzard-style window. Built only from the game's own templates and art, laid out like the
-- Adventure Guide: a portrait frame with a breadcrumb bar and search box, an expansion dropdown, Journeys-style
-- renown cards for each zone, and Traveler's Log style pages (a section list on the left, the rows on the right).
-- The bottom tabs are Progress, This Week, Warband and Options.
--
-- It shares everything but the drawing with the classic book (UI.lua): the same lines (ns.ListBuild), clicks
-- (ns.ListClick), row text (ns.LineInfo) and tooltips (ns.ItemTooltip). Options > Classic book switches between the two
-- (settings.ui = "book" for the classic book); only one of them is built per session.

local _, ns = ...

local W, H = 1200, 760                   -- the default size; drag the corner to resize
local MIN_W, MIN_H, MAX_W, MAX_H = 960, 620, 1800, 1150
local CARD_W, CARD_H = 374, 112          -- a Journeys renown card
local DETAIL_W = 340                     -- the detail panel on the right: 3D model and how to get it
local ITEM_H, CHILD_H, HEAD_H = 22, 19, 28   -- slim rows, close to the classic book's, so a page shows a lot at once
local INST_H = 38                            -- a dungeon or raid row with its small Adventure Guide picture
local MAP_W = DETAIL_W - 20

local frame, inset, nav, search, bookDrop, filterDrop
local views = {}          -- home, zone, page, options, empty
local tabs = {}
local sectionButtons = {}
local homeBox, homeBar, rowBox, rowBar
local headerTitle, headerSub, progress
local pageHost, optionsHost
local detail              -- the panel with the 3D model

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
            if sec == "rare" and ns.StartFarmPatrol then
                root:CreateButton("Farm route: every rare, killed or not", function() ns.StartFarmPatrol(z); Refresh() end)
            end
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
    c.sub = Font(c, "GameFontHighlightSmall")
    c.sub:SetTextColor(0.75, 0.72, 0.65)
    c.sub:SetSize(270, 14)
    c.sub:SetWordWrap(false)
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
        c.level:SetText(max > 0 and string.format("%d%% complete  |cffc8c0a8%d / %d|r", pct, cur, max) or "Nothing to count yet")
        -- what is still left, biggest first
        local left = {}
        for _, d in ipairs(ns.ListSectionDefs(z)) do
            local sec = z.sections[d.key]
            if sec and (sec.max or 0) > sec.cur then left[#left + 1] = { sec.max - sec.cur, d.name } end
        end
        table.sort(left, function(a, b) return a[1] > b[1] end)
        local parts = {}
        for i = 1, math.min(3, #left) do parts[i] = left[i][1] .. " " .. left[i][2]:lower() end
        c.sub:SetText(#parts > 0 and ("Left: " .. table.concat(parts, ", ")) or "")
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
        local cols = 3
        if homeBox and homeBox.GetWidth then
            local w = homeBox:GetWidth() or 0
            if w > 0 then cols = math.max(1, math.min(4, math.floor(w / (CARD_W + 4)))) end
        end
        for i = 1, #list, cols do
            local row = { kind = "cards", list = {} }
            for j = 0, cols - 1 do row.list[j + 1] = list[i + j] end
            data[#data + 1] = row
        end
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
    b:SetSize(204, 24)
    b:SetPoint("TOPLEFT", 10, -10 - (i - 1) * 26)
    b.barBg = b:CreateTexture(nil, "ARTWORK")
    b.barBg:SetHeight(2)
    b.barBg:SetPoint("BOTTOMLEFT", 8, 1)
    b.barBg:SetPoint("BOTTOMRIGHT", -8, 1)
    b.barBg:SetColorTexture(0, 0, 0, 0.5)
    b.barFill = b:CreateTexture(nil, "OVERLAY")
    b.barFill:SetHeight(2)
    b.barFill:SetPoint("BOTTOMLEFT", b.barBg, "BOTTOMLEFT")
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
                b.barFill:SetWidth(math.max(0.001, 188 * sec.cur / sec.max))
                if full then b.barFill:SetColorTexture(0.35, 0.75, 0.35, 0.9) else b.barFill:SetColorTexture(0.85, 0.62, 0.22, 0.9) end
                b.barFill:Show(); b.barBg:Show()
            else
                b.count:SetText("")
                b.barFill:Hide(); b.barBg:Hide()
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
    if InstanceArt(ln.it) then return INST_H end
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
    r.divider:SetHeight(6)
    r.expand = r:CreateTexture(nil, "OVERLAY")
    r.expand:SetSize(18, 18)
    r.status = r:CreateTexture(nil, "OVERLAY")
    r.status:SetSize(14, 13)
    r.sep = r:CreateTexture(nil, "BORDER")
    r.sep:SetHeight(1)
    r.sep:SetPoint("BOTTOMLEFT", 4, 0)
    r.sep:SetPoint("BOTTOMRIGHT", -4, 0)
    r.sep:SetColorTexture(1, 0.9, 0.7, 0.07)
    r.icon = r:CreateTexture(nil, "OVERLAY")
    r.icon:SetSize(18, 18)
    r.track = r:CreateTexture(nil, "OVERLAY")
    r.track:SetSize(14, 14)
    r.track:SetTexture("Interface\\AddOns\\" .. (ns.ADDON or "Completion") .. "\\Textures\\arrow")
    r.text = Font(r, "GameFontHighlight")
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
    for _, k in ipairs({ "bg", "art", "artFrame", "divider", "expand", "status", "icon", "track", "strike", "sep" }) do r[k]:Hide() end
    r.hl:SetTexture(nil)
    r.text:ClearAllPoints(); r.right:ClearAllPoints(); r.status:ClearAllPoints(); r.icon:ClearAllPoints()
    r.expand:ClearAllPoints(); r.track:ClearAllPoints()
    r.text:SetFontObject("GameFontHighlight")
    if ln.header then
        -- a heading: like the Journeys "Renowns" heading, with the divider under it
        r.text:SetFontObject("GameFontNormalMed2")
        r.text:SetPoint("LEFT", 8, 3)
        r.text:SetPoint("RIGHT", r.right, "LEFT", -8, 3)
        r.text:SetText(ln.text or "")
        r.text:SetTextColor(1, 0.82, 0)
        r.right:SetPoint("RIGHT", -10, 3)
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
    local left = 6 + (ln.depth or 0) * 16
    if not child then
        -- a top-level row: a thin line under it and the options list's hover light
        r.sep:Show()
        if not Atlas(r.hl, "Options_List_Hover", false) then r.hl:SetColorTexture(1, 0.82, 0.3, 0.12) end
        r.hl:SetAlpha(1)
        if info.done then r.bg:SetColorTexture(0.3, 0.6, 0.3, 0.06); r.bg:Show() end
        -- a dungeon or raid gets its small Adventure Guide picture at the left
        local art = InstanceArt(ln.it)
        if art then
            r.art:ClearAllPoints()
            r.art:SetPoint("LEFT", 6, 0)
            r.art:SetSize(56, 31)
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
        r.text:SetFontObject("GameFontHighlightSmall")
    end
    if not child and InstanceArt(ln.it) then left = 70 end
    if info.canExpand then
        r.expand:SetSize(14, 14)
        r.expand:SetPoint("LEFT", left, 0)
        Atlas(r.expand, info.expanded and "campaign_headericon_open" or "campaign_headericon_closed", false)
        r.expand:Show()
        left = left + 15
    end
    r.status:SetPoint("LEFT", left, 0)
    if info.done then Atlas(r.status, "activities-icon-checkmark-small-yellow", false); r.status:SetSize(13, 11); r.status:Show()
    elseif info.upNow then r.status:SetTexture("Interface\\COMMON\\Indicator-Green"); r.status:SetSize(12, 12); r.status:Show()
    elseif info.current then r.status:SetTexture("Interface\\RaidFrame\\ReadyCheck-Waiting"); r.status:SetSize(12, 12); r.status:Show() end
    left = left + 15
    if info.icon then
        r.icon:SetTexture(info.icon)
        r.icon:SetSize(child and 14 or 17, child and 14 or 17)
        r.icon:SetPoint("LEFT", left, 0)
        r.icon:Show()
        left = left + (child and 17 or 21)
    end
    r.right:SetPoint("RIGHT", info.tracked and -24 or -8, 0)
    r.right:SetWidth(child and 170 or 210)
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
    if info.tracked then r.track:SetPoint("RIGHT", -6, 0); r.track:Show() end
end

------------------------------------------------------------------------
-- scroll lists (the game's ScrollBox with its minimal scroll bar)
------------------------------------------------------------------------

-- A ScrollBox list with a minimal scroll bar, anchored from (x, y) to (right, bottom) of its parent;
-- height(data) sizes each element, init(frame, data) fills it.
-- Returns the box, or nil when the client has no ScrollBox (then nothing is drawn).
local function MakeList(parent, x, y, right, bottom, height, init)
    if not (CreateScrollBoxListLinearView and ScrollUtil and ScrollUtil.InitScrollBoxListWithScrollBar) then return end
    local box = CreateFrame("Frame", nil, parent, "WowScrollBoxList")
    box:SetPoint("TOPLEFT", x, y)
    box:SetPoint("BOTTOMRIGHT", right, bottom)
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
-- detail panel: the zone's map with what is still missing, or the 3D model of a picked mount, pet,
-- appearance or rare in the map's place, with how to get it underneath
------------------------------------------------------------------------

local tilePool, pinPool = {}, {}

-- Lays a map's art tiles onto the panel's map canvas, MAP_W wide; returns the map's height at that width.
local function DrawMap(mapID)
    local canvas = detail.map.canvas
    for _, t in ipairs(tilePool) do t:Hide() end
    if not (mapID and C_Map and C_Map.GetMapArtLayers and C_Map.GetMapArtLayerTextures) then return MAP_W * 2 / 3 end
    local ok, layers = pcall(C_Map.GetMapArtLayers, mapID)
    local ok2, textures = pcall(C_Map.GetMapArtLayerTextures, mapID, 1)
    if not ok or not ok2 or type(layers) ~= "table" or not layers[1] or type(textures) ~= "table" then return MAP_W * 2 / 3 end
    local l = layers[1]
    local cols = math.ceil(l.layerWidth / l.tileWidth)
    local scale = MAP_W / l.layerWidth
    local tw, th = l.tileWidth * scale, l.tileHeight * scale
    for i, tex in ipairs(textures) do
        local t = tilePool[i]
        if not t then t = canvas:CreateTexture(nil, "ARTWORK"); tilePool[i] = t end
        local r, c = math.floor((i - 1) / cols), (i - 1) % cols
        t:SetTexture(tex)
        t:SetSize(tw, th)
        t:ClearAllPoints()
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", c * tw, -r * th)
        t:Show()
    end
    return l.layerHeight * scale
end

-- Sets a pin's icon by kind, the same icons as the classic book's map.
local function PinAtlas(pin, kind)
    local atlas = ({ vendor = "banker", treasure = "VignetteLoot", rare = "VignetteKill", boss = "VignetteKillElite", achv = "VignetteEvent",
                     lore = "QuestNormal", step = "QuestNormal", container = "Dungeon", delve = "delves-regular" })[kind] or "VignetteLoot"
    local ok = pcall(pin.tex.SetAtlas, pin.tex, atlas)
    if not ok or not (pin.tex.GetAtlas and pin.tex:GetAtlas()) then pin.tex:SetTexture("Interface\\COMMON\\Indicator-Yellow") end
end

-- Map pin i from the pool; hover shows the item's tooltip, a click tracks it.
local function GetPin(i)
    local p = pinPool[i]
    if p then return p end
    p = CreateFrame("Button", nil, detail.map.canvas)
    p:SetSize(13, 13)
    p.tex = p:CreateTexture(nil, "OVERLAY")
    p.tex:SetAllPoints()
    p:SetScript("OnEnter", function(self) ns.ItemTooltip(self, self.it, self.row) end)
    p:SetScript("OnLeave", function() GameTooltip:Hide() end)
    p:SetScript("OnClick", function(self) ns.Track(self.it, self.row and self.row.key) end)
    pinPool[i] = p
    return p
end

-- Pins what is still missing on the map: the open section's items, else treasures, rares and knowledge
-- treasures as the pin filter allows (250 at most), then the route.
local function PlacePins(z)
    for _, p in ipairs(pinPool) do p:Hide() end
    local canvas = detail.map.canvas
    if not z.map then return end
    local secKey = ns.ListSection()
    local wanted = secKey and { [secKey] = true }
                   or (z.event and { guide = true, achv = true })
                   or { treasure = ns.PinOn("treasure") or nil, rare = ns.PinOn("rare") or nil, prof = ns.PinOn("prof") or nil }
    local target = ns.TargetItem and ns.TargetItem()
    local h = canvas:GetHeight()
    local n = 0
    local function add(it, row, spot, kind)
        if n >= 250 or not spot or not spot.x then return end
        local x, y = ns.MapPosOn(spot, z.map)
        if not x then return end
        n = n + 1
        local p = GetPin(n)
        p.it, p.row = it, row
        PinAtlas(p, kind)
        local big = (target and target.key == it.key) or ns.upNow[it.key] ~= nil
        p:SetSize(big and 19 or 12, big and 19 or 12)
        p:SetFrameLevel(canvas:GetFrameLevel() + (big and 5 or 2))
        p:ClearAllPoints()
        p:SetPoint("CENTER", canvas, "TOPLEFT", x * MAP_W, -y * h)
        p:Show()
    end
    for key in pairs(wanted) do
        local sec = z.sections[key]
        for _, it in ipairs(sec and sec.items or {}) do
            if (not it.done or ns.FarmWanted(it) or (it.pkind == "rare" and ns.PatrolFarming and ns.PatrolFarming())) and not it.hidden then
                if it.kind == "point" then
                    for _, sp in ipairs(it.spots) do add(it, nil, sp, it.pkind) end
                elseif it.kind == "ach" then
                    local any = false
                    for _, row in ipairs(ns.Children(it)) do
                        if not row.done and row.spot then add(it, row, row.spot, "achv"); any = true end
                    end
                    if not any then
                        local res = ns.Resolve(it)
                        if res.spot then add(it, nil, res.spot, "achv") end
                    end
                elseif it.kind == "container" then
                    for _, sp in ipairs(it.spots) do add(it, nil, sp, it.ctype) end
                elseif it.kind == "lore" and ns.ListExpanded[it.key] then
                    local res = ns.Resolve(it)
                    if res.spot then add(it, nil, res.spot, "lore") end
                elseif it.kind == "collect" then
                    local sp = it.spots and it.spots[1]
                    if sp then add(it, nil, sp, it.source and it.source.pkind or "vendor") end
                elseif it.kind == "step" then
                    for _, sp in ipairs(it.spots) do add(it, nil, sp, "step") end
                end
            end
        end
    end
    if ns.DrawRoute then ns.DrawRoute(canvas, MAP_W, h, z.map, 1) end
    return n
end

-- Moves the player arrow on the panel's map; hidden off this page's map.
local function UpdatePlayerDot()
    local z = detail.zone
    local dot = detail.map.player
    if not (z and z.map and detail.map:IsVisible() and C_Map and C_Map.GetPlayerMapPosition) then dot:Hide(); return end
    local ok, pos = pcall(C_Map.GetPlayerMapPosition, z.map, "player")
    if not ok or not pos then dot:Hide(); return end
    local x, y
    if pos.GetXY then x, y = pos:GetXY() else x, y = pos.x, pos.y end
    if not x or x <= 0 or y <= 0 or x >= 1 or y >= 1 then dot:Hide(); return end
    dot:ClearAllPoints()
    dot:SetPoint("CENTER", detail.map.canvas, "TOPLEFT", x * MAP_W, -y * detail.map.canvas:GetHeight())
    local facing = GetPlayerFacing and GetPlayerFacing()
    if facing then dot.tex:SetRotation(facing) end
    dot:Show()
end

-- Redraws the detail panel: the model of the picked item and how to get it, or the page's map.
local function RefreshDetail(z)
    if not detail then return end
    detail.zone = z
    local sel = ns.selected
    if sel and ns.ModelInfo and ns.ModelInfo(sel) then
        if detail.presented ~= sel then
            detail.presented = sel
            detail.show:Present(sel)
        end
        detail.show:Show()
        detail.map:Hide()
        local parts = {}
        for _, l in ipairs(ns.HowToGet and ns.HowToGet(sel) or {}) do
            parts[#parts + 1] = string.format("|cff%02x%02x%02x%s|r", math.floor(l[2] * 255), math.floor(l[3] * 255), math.floor(l[4] * 255), l[1])
        end
        detail.howHead:SetText(sel.done and "Collected" or "How to get it")
        detail.how:SetText(table.concat(parts, "\n\n"))
        detail.howHead:ClearAllPoints()
        detail.howHead:SetPoint("TOPLEFT", detail.show, "BOTTOMLEFT", 4, -10)
        return
    end
    detail.presented = nil
    detail.show:Hide()
    detail.map:Show()
    local h = MAP_W * 2 / 3
    if z and z.map then
        if detail.drawn ~= z.map then detail.drawn = z.map; detail.mapH = DrawMap(z.map) end
        h = detail.mapH or h
    else
        detail.drawn = nil
        for _, t in ipairs(tilePool) do t:Hide() end
    end
    detail.map:SetHeight(h)
    detail.map.canvas:SetSize(MAP_W, h)
    local n = z and PlacePins(z) or 0
    detail.map.empty:SetShown(not (z and z.map))
    detail.howHead:ClearAllPoints()
    detail.howHead:SetPoint("TOPLEFT", detail.map, "BOTTOMLEFT", 4, -10)
    if z and z.map then
        local sec = ns.ListSection()
        local what = sec and z.sections[sec] and z.sections[sec].name or (z.event and "Holiday spots" or "Treasures and rares")
        detail.howHead:SetText(string.format("%s still missing: %d", what, n))
        detail.how:SetText("|cffc8c0a8Hover a pin to see what it is; click it to track it. Click the map to open the big map. Click a mount, pet, appearance or rare in the list to see it here in 3D.|r")
    else
        detail.howHead:SetText(z and z.name or "Search")
        detail.how:SetText("|cffc8c0a8Click a mount, pet, appearance or rare in the list to see it here in 3D. Drag to turn it, scroll to zoom.|r")
    end
end

-- Builds the detail panel on the zone view's right side.
local function BuildDetail(parent)
    detail = CreateFrame("Frame", nil, parent)
    detail:SetWidth(DETAIL_W)
    detail:SetPoint("TOPRIGHT", -10, -96)
    detail:SetPoint("BOTTOMRIGHT", -10, 10)
    local bg = detail:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    if not Atlas(bg, "activities-container", false) then bg:SetColorTexture(0, 0, 0, 0.3) end

    -- the map: tiles, pins, route and the player arrow live on map.canvas
    local map = CreateFrame("Frame", nil, detail)
    map:SetPoint("TOPLEFT", 10, -10)
    map:SetSize(MAP_W, MAP_W * 2 / 3)
    map:SetClipsChildren(true)
    local mbg = map:CreateTexture(nil, "BACKGROUND")
    mbg:SetAllPoints()
    mbg:SetColorTexture(0, 0, 0, 0.6)
    map.canvas = CreateFrame("Frame", nil, map)
    map.canvas:SetPoint("TOPLEFT")
    map.canvas:SetSize(MAP_W, MAP_W * 2 / 3)
    map.player = CreateFrame("Frame", nil, map.canvas)
    map.player:SetSize(18, 18)
    map.player:SetFrameLevel(map.canvas:GetFrameLevel() + 10)
    map.player.tex = map.player:CreateTexture(nil, "OVERLAY")
    map.player.tex:SetAllPoints()
    map.player.tex:SetTexture("Interface\\WorldMap\\WorldMapArrow")
    map.player:Hide()
    map.empty = Font(map, "GameFontDisable")
    map.empty:SetPoint("CENTER")
    map.empty:SetText("No map for this page")
    map:EnableMouse(true)
    map:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" and detail.zone and detail.zone.map then ns.OpenWorldMap(detail.zone.map) end
    end)
    map:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Click to open the big map")
        GameTooltip:AddLine("Everything still missing is pinned there. Click a pin to track it.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    map:SetScript("OnLeave", function() GameTooltip:Hide() end)
    if ns.MakePinButton then
        map.filter = ns.MakePinButton(map, 22)
        map.filter.zoneFor = function() local z = detail.zone; return z and not z.overview and z end
        map.filter:SetPoint("TOPRIGHT", -4, -4)
        map.filter:SetFrameLevel(map.canvas:GetFrameLevel() + 20)
    end
    local tick = 0
    map:SetScript("OnUpdate", function(_, elapsed)
        tick = tick + elapsed
        if tick < 0.25 then return end
        tick = 0
        UpdatePlayerDot()
    end)
    detail.map = map

    -- the 3D model takes the map's place; its Close button brings the map back
    detail.show = ns.CreateShowcase(detail, MAP_W, 300, function()
        ns.selected = nil
        Refresh()
    end, CLOSE or "Close")
    detail.show:ClearAllPoints()
    detail.show:SetPoint("TOPLEFT", 10, -10)
    detail.show:SetSize(MAP_W, 300)

    detail.howHead = Font(detail, "GameFontNormalLarge")
    detail.howHead:SetPoint("TOPLEFT", map, "BOTTOMLEFT", 4, -10)
    detail.howHead:SetWidth(MAP_W - 8)
    detail.how = Font(detail, "GameFontHighlight")
    detail.how:SetJustifyV("TOP")
    detail.how:SetPoint("TOPLEFT", detail.howHead, "BOTTOMLEFT", 0, -8)
    detail.how:SetPoint("BOTTOMRIGHT", detail, "BOTTOMRIGHT", -16, 12)
    detail.how:SetSpacing(2)
end

-- Puts the rows between the section list (when shown) and the detail panel.
local function PlaceRows(withList)
    if not (rowBox and rowBox.ClearAllPoints) then return end
    rowBox:ClearAllPoints()
    rowBox:SetPoint("TOPLEFT", views.zone, "TOPLEFT", withList and 244 or 14, -96)
    rowBox:SetPoint("BOTTOMRIGHT", views.zone, "BOTTOMRIGHT", -(DETAIL_W + 40), 10)
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
        PlaceRows(false)
        RefreshDetail(nil)
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
    PlaceRows(true)
    RefreshDetail(z)
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
    progress:SetPoint("TOP", 0, -48)
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
    homeBox = MakeList(views.home, 20, -92, -34, 10, function(data) return data.kind == "head" and 44 or CARD_H + 8 end,
        function(row, data)
            if not row.cards then
                row.cards = {}
                for i = 1, 4 do
                    row.cards[i] = MakeCard(row)
                    if i == 1 then row.cards[i]:SetPoint("LEFT", 0, 0)
                    else row.cards[i]:SetPoint("LEFT", row.cards[i - 1], "RIGHT", 4, 0) end
                end
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
                for _, c in ipairs(row.cards) do c:Hide() end
            else
                for i, c in ipairs(row.cards) do FillCard(c, data.list[i]) end
            end
        end)

    -- zone view: the section list and the rows
    views.zone = CreateFrame("Frame", nil, inset)
    views.zone:SetAllPoints()
    views.zone.list = CreateFrame("Frame", nil, views.zone)
    views.zone.list:SetWidth(224)
    views.zone.list:SetPoint("TOPLEFT", 8, -96)
    views.zone.list:SetPoint("BOTTOMLEFT", 8, 10)
    local lbg = views.zone.list:CreateTexture(nil, "BACKGROUND")
    lbg:SetAllPoints()
    if not Atlas(lbg, "activities-container", false) then lbg:SetColorTexture(0, 0, 0, 0.3) end
    rowBox, rowBar = MakeList(views.zone, 244, -96, -(DETAIL_W + 40), 10, LineHeight, FillRow)
    if not rowBox then rowBox = CreateFrame("Frame", nil, views.zone); rowBox:SetSize(560, 500) end
    BuildDetail(views.zone)

    -- the hosted pages: This Week and Warband (Pages.lua), Options (About.lua)
    views.page = CreateFrame("Frame", nil, inset)
    views.page:SetAllPoints()
    pageHost = CreateFrame("Frame", nil, views.page)
    pageHost:SetSize(560, H - 140)
    pageHost:SetPoint("TOP", 0, -44)
    views.options = CreateFrame("Frame", nil, inset)
    views.options:SetAllPoints()
    -- the options are taller than the window: they scroll, with the game's minimal scroll bar
    local okS, sf = pcall(CreateFrame, "ScrollFrame", nil, views.options, "ScrollFrameTemplate")
    if not okS or not sf then sf = CreateFrame("ScrollFrame", nil, views.options, "UIPanelScrollFrameTemplate") end
    sf:SetWidth(580)
    sf:SetPoint("TOP", 0, -44)
    sf:SetPoint("BOTTOM", 0, 8)
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

    -- resizing: drag the bottom-right corner; the size is kept between sessions
    local size = ns.db.frames and ns.db.frames.journalSize
    if size and size.w and size.h then
        frame:SetSize(math.max(MIN_W, math.min(MAX_W, size.w)), math.max(MIN_H, math.min(MAX_H, size.h)))
    end
    frame:SetResizable(true)
    if frame.SetResizeBounds then frame:SetResizeBounds(MIN_W, MIN_H, MAX_W, MAX_H)
    elseif frame.SetMinResize then frame:SetMinResize(MIN_W, MIN_H); frame:SetMaxResize(MAX_W, MAX_H) end
    local grip = CreateFrame("Button", nil, frame)
    grip:SetSize(16, 16)
    grip:SetPoint("BOTTOMRIGHT", -3, 3)
    grip:SetFrameLevel(inset:GetFrameLevel() + 20)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip:SetScript("OnMouseDown", function(_, button) if button == "LeftButton" then frame:StartSizing("BOTTOMRIGHT") end end)
    grip:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        if ns.db.frames then ns.db.frames.journalSize = { w = frame:GetWidth(), h = frame:GetHeight() } end
        if ns.SavePos then ns.SavePos(frame, "journal") end
        Refresh()
    end)
    frame.grip = grip
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
                   SelectSection = SelectSection, homeBox = homeBox, rowBox = rowBox, nav = nav, search = search,
                   detail = detail }
end
