-- Completion: the Options & About page (right page of the book, opened with the gear tab).
-- Developer, version, website, contact and the support Discord come from the TOC (## Author, ## Version,
-- ## X-Website, ## X-Contact, ## X-Discord), so a release only needs the TOC edited.

local _, ns = ...

local about, options   -- the gear tab's About and Options views
local checks = {}

-- A field from this addon's TOC, or nil when it is missing or empty.
local function Meta(field)
    local get = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    if not get then return end
    local ok, v = pcall(get, ns.ADDON, field)
    if ok and v and v ~= "" then return v end
end

-- A read-only box you can click and Ctrl+C from (links can't be opened from inside the game).
-- Typing is undone at once; set the text with e:SetValue.
local function CopyBox(parent, width)
    local e = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    e:SetSize(width, 20)
    e:SetAutoFocus(false)
    e:SetFontObject("GameFontHighlightSmall")
    e:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    e:SetScript("OnTextChanged", function(self, user) if user then self:SetText(self.value or "") ; self:HighlightText() end end)
    e:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    e:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    -- Sets the text and remembers it so edits can be reverted.
    function e:SetValue(v) self.value = v; self:SetText(v); self:SetCursorPosition(0) end
    return e
end

-- A labelled checkbox with a tooltip. get is read on every refresh, set gets the new boolean.
local function Check(parent, label, tip, get, set)
    local c = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    c:SetSize(24, 24)
    c.label = c:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    c.label:SetPoint("LEFT", c, "RIGHT", 2, 0)
    c.label:SetText(label)
    c:SetScript("OnClick", function(self) set(self:GetChecked() and true or false) end)
    c:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(label)
        GameTooltip:AddLine(tip, 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    c:SetScript("OnLeave", function() GameTooltip:Hide() end)
    c.get = get
    checks[#checks + 1] = c
    return c
end

-- A "label  -  100%  +" row for a scale setting. Steps by 0.1 and ignores clicks outside lo..hi.
local function Stepper(parent, label, get, set, lo, hi)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(200, 22)
    f.label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.label:SetPoint("LEFT", 4, 0)
    f.label:SetText(label)
    f.value = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.value:SetPoint("LEFT", 120, 0)
    f.value:SetWidth(44)
    f.value:SetJustifyH("CENTER")
    -- One of the two buttons; d is the change per click.
    local function btn(text, x, d)
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetSize(24, 20)
        b:SetPoint("LEFT", x, 0)
        b:SetText(text)
        b:SetScript("OnClick", function()
            local v = math.floor((get() + d) * 10 + 0.5) / 10
            if v >= lo and v <= hi then set(v) end
            f:Update()
        end)
    end
    btn("-", 94, -0.1)
    btn("+", 166, 0.1)
    -- Shows the current value as a percentage.
    function f:Update() self.value:SetText(math.floor(get() * 100 + 0.5) .. "%") end
    return f
end

-- A group heading on the Options page: gold text with a thin rule after it.
local function Group(parent, text, y, pageW)
    local t = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    t:SetPoint("TOPLEFT", 30, y)
    t:SetText(text)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(0.72, 0.56, 0.30, 0.45)
    line:SetHeight(1)
    line:SetPoint("LEFT", t, "RIGHT", 8, 0)
    line:SetPoint("RIGHT", parent, "LEFT", pageW - 30, 0)
    return t
end

-- A link-style button (gold text that lights up), for moving between the gear tab's views.
local function Link(parent, Text, label, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(140, 18)
    b.text = Text(b, "GameFontNormalSmall")
    b.text:SetPoint("LEFT")
    b.text:SetText(label)
    b:SetScript("OnClick", onClick)
    b:SetScript("OnEnter", function(self) self.text:SetTextColor(1, 1, 1) end)
    b:SetScript("OnLeave", function(self) self.text:SetTextColor(1, 0.82, 0) end)
    return b
end

-- Builds the gear tab's three views on the book's right page R: Options (the default, grouped switches,
-- sizes and buttons), About (version, developer, links, credits) and What Counts.
-- Header, Text and titleFont are the book's own widget helpers, passed in so the pages match.
function ns.BuildAbout(R, Header, Text, titleFont, pageW)
    local s = function() return ns.db.settings end

    ---------------- Options ----------------
    local opts = CreateFrame("Frame", nil, R)
    opts:SetAllPoints()
    opts:Hide()
    R.options = opts
    options = opts
    local head = Header(opts, pageW)
    head:SetPoint("TOP", 0, -14)
    head:Set("Options")

    local col1, col2 = 34, 238
    local groups = {
        { "Guide and arrow", {
            { "Show the arrow", "The guide arrow for whatever you track. Right-click the minimap button toggles it too.",
              function() return s().arrow end, function(v) s().arrow = v; ns.UpdateTarget() end },
            { "On-screen tracker", "A small list on screen with every step or criterion of what you track, ticked as you go, "
                .. "and your watch list.",
              function() return s().tracker ~= false end, function(v) s().tracker = v; ns.RefreshTracker() end },
            { "Map waypoint", "Also place Blizzard's map pin on the tracked spot.",
              function() return s().pin end, function(v) s().pin = v; ns.UpdateTarget(true) end },
            { "Waypoint addon", "Send what you track to WaypointUI or TomTom when one is installed.",
              function() return s().waypointAddon ~= false end, function(v) s().waypointAddon = v; ns.UpdateTarget(true) end },
            { "Follow tracked achievements", "Tracking an achievement in Blizzard's achievement window points the arrow at it.",
              function() return s().followTracked ~= false end, function(v) s().followTracked = v end },
        } },
        { "Maps and pins", {
            { "World map pins", "Show what is still missing on the big world map. Click a pin to track it.",
              function() return s().worldPins ~= "off" end,
              function(v) s().worldPins = v and "missing" or "off"; if ns.RefreshWorldPins then ns.RefreshWorldPins() end end },
            { "Minimap pins", "Show what is still missing around you on the minimap, Sturdy Chests inside delves included. "
                .. "The world map's pin checklist decides which kinds.",
              function() return s().minimapPins ~= false end,
              function(v) s().minimapPins = v; if ns.RefreshMinimapPins then ns.RefreshMinimapPins() end end },
            { "Holiday pins", "While a holiday is on, its guide steps and the achievement spots you still need (candy "
                .. "buckets, bonfires, elders) show on the world map and minimap.",
              function() return s().eventPins ~= false end,
              function(v) s().eventPins = v; if ns.RefreshWorldPins then ns.RefreshWorldPins() end; if ns.RefreshMinimapPins then ns.RefreshMinimapPins() end end },
            { "Minimap button", "Show the book button on the minimap.",
              function() return not s().minimap.hide end,
              function(v) s().minimap.hide = not v; if CompletionMinimapButton then CompletionMinimapButton:SetShown(v) end end },
            { "Hover hints", "Tooltips of rares, NPCs, objects and items say what they still count toward.",
              function() return s().tooltips end, function(v) s().tooltips = v end },
        } },
        { "Rares and farming", {
            { "Rare alerts", "During a rare patrol, a raid-warning style message and sound when a rare you still need comes up.",
              function() return s().rareAlerts ~= false end, function(v) s().rareAlerts = v end },
            { "Farm mode", "Killed rares that can still drop a mount, pet, toy or decor you don't have stay on the maps "
                .. "and in the patrol until you loot them for the day. Tooltips count your attempts.",
              function() return s().farm ~= false end, function(v) s().farm = v; if ns.Evaluate then ns.Evaluate() end end },
        } },
        { "Book", {
            { "Open on my zone", "Opening the book jumps to the zone you are standing in.",
              function() return s().follow end, function(v) s().follow = v end },
            { "Hide finished rows", "Lists only show what is still missing.",
              function() return s().hidedone end, function(v) s().hidedone = v; ns.RefreshUI() end },
            { "Count appearances", "Transmog appearances your class can learn count toward Collectibles.",
              function() return s().transmog end, function(v) s().transmog = v; if ns.Evaluate then ns.Evaluate() end end },
            { "Sound on completion", "Play a sound when something is finished.",
              function() return s().sound end, function(v) s().sound = v end },
            { "Chat messages", "Print a line in chat when something is finished.",
              function() return s().announce end, function(v) s().announce = v end },
            { "Every item of a look", "For completionists: an appearance counts only when you have it from that exact item, "
                .. "not from another item with the same look. Rares then stay on the map until every look they drop is yours.",
              function() return s().transmogSources end,
              function(v) s().transmogSources = v; ns.ResetCollectMemory(); ns.Build(); if ns.Evaluate then ns.Evaluate() end end },
            ns.DIFFICULTY_ENABLED and { "Difficulty tags", "Show Easy, Medium, Hard or Very hard on each row, and in tooltips why and roughly how long it takes. "
                .. "These are estimates.",
              function() return s().difficulty ~= false end, function(v) s().difficulty = v; ns.RefreshUI() end } or nil,
        } },
    }
    local y = -50
    for _, g in ipairs(groups) do
        Group(opts, g[1], y, pageW)
        y = y - 20
        for i, r in ipairs(g[2]) do
            local c = Check(opts, r[1], r[2], r[3], r[4])
            c:SetPoint("TOPLEFT", (i % 2 == 1) and col1 or col2, y - math.floor((i - 1) / 2) * 24)
        end
        y = y - math.ceil(#g[2] / 2) * 24 - 10
    end

    Group(opts, "Sizes", y, pageW)
    y = y - 22
    opts.bookSize = Stepper(opts, "Book size", function() return s().scale or 1 end,
        function(v) s().scale = v; if ns.main then ns.main:SetScale(v) end end, 0.6, 1.5)
    opts.bookSize:SetPoint("TOPLEFT", 36, y)
    opts.arrowSize = Stepper(opts, "Arrow size", function() return s().arrowScale or 1 end,
        function(v) s().arrowScale = v; if ns.arrow then ns.arrow:SetScale(v) end end, 0.5, 3)
    opts.arrowSize:SetPoint("TOPLEFT", 36, y - 26)

    local reset = CreateFrame("Button", nil, opts, "UIPanelButtonTemplate")
    reset:SetSize(130, 22)
    reset:SetPoint("TOPRIGHT", -34, y)
    reset:SetText("Reset positions")
    reset:SetScript("OnClick", function()
        ns.db.frames = {}
        if ns.main then ns.RestorePos(ns.main, "main", "CENTER", -30, 20) end
        if ns.arrow then ns.RestorePos(ns.arrow, "arrow", "TOP", 0, -140) end
    end)

    local scopeBtn = CreateFrame("Button", nil, opts, "UIPanelButtonTemplate")
    scopeBtn:SetSize(130, 22)
    scopeBtn:SetPoint("TOPRIGHT", -34, y - 26)
    scopeBtn:SetText("What counts...")
    scopeBtn:SetScript("OnClick", function() ns.aboutPage = "scope"; ns.RefreshAbout() end)

    local toAbout = Link(opts, Text, "About and credits >", function() ns.aboutPage = "about"; ns.RefreshAbout() end)
    toAbout:SetPoint("BOTTOMLEFT", 30, 12)

    ---------------- About ----------------
    about = CreateFrame("Frame", nil, R)
    about:SetAllPoints()
    about:Hide()
    R.about = about
    local ahead = Header(about, pageW)
    ahead:SetPoint("TOP", 0, -14)
    ahead:Set("About")
    local back = Link(about, Text, "< Options", function() ns.aboutPage = nil; ns.RefreshAbout() end)
    back:SetPoint("TOPLEFT", 12, -46)

    about.name = about:CreateFontString(nil, "OVERLAY")
    about.name:SetFontObject(titleFont)
    about.name:SetPoint("TOP", 0, -76)
    about.name:SetText("Completion")
    about.tag = Text(about, "GameFontHighlight")
    about.tag:SetPoint("TOP", about.name, "BOTTOM", 0, -4)
    about.tag:SetJustifyH("CENTER")
    about.tag:SetWidth(pageW - 60)
    about.tag:SetText("Every zone, to one hundred percent.")

    about.info = {}
    local iy = -150
    for i, key in ipairs({ "Version", "Developer", "Website", "Contact", "Discord" }) do
        local l = Text(about, "GameFontNormal")
        l:SetPoint("TOPLEFT", 40, iy - (i - 1) * 26)
        l:SetText(key)
        local v
        if key ~= "Version" and key ~= "Developer" then
            v = CopyBox(about, 250)
            v:SetPoint("TOPLEFT", 150, iy - (i - 1) * 26 + 4)
        else
            v = Text(about, "GameFontHighlight")
            v:SetPoint("TOPLEFT", 150, iy - (i - 1) * 26)
        end
        about.info[key] = { label = l, value = v }
    end

    about.credits = Text(about, "GameFontDisableSmall")
    about.credits:SetPoint("TOPLEFT", 40, iy - 5 * 26 - 10)
    about.credits:SetWidth(pageW - 80)
    about.credits:SetSpacing(2)
    about.credits:SetText("Locations and walkthroughs gathered with help from the WoW community. "
        .. "Achievements, criteria, collections and reputation are read live from the game.\n\n"
        .. "Found something missing or wrong? Use Report a gap at the top of any list and paste it on the Discord.")

    ns.BuildScope(R, Header, Text, pageW)
end

------------------------------------------------------------------------
-- What counts: which achievement groups make up 100%
------------------------------------------------------------------------

local scope
local scopeChecks = {}

-- Rebuilds the book so a changed scope takes effect at once.
local function ApplyScope()
    ns.Build()
    if ns.Evaluate then ns.Evaluate() end
end

-- Builds the What Counts page: a checkbox per achievement group, the hard modes switch and a reset.
function ns.BuildScope(R, Header, Text, pageW)
    scope = CreateFrame("Frame", nil, R)
    scope:SetAllPoints()
    scope:Hide()
    R.scope = scope
    local s = ns.db.settings

    local head = Header(scope, pageW)
    head:SetPoint("TOP", 0, -14)
    head:Set("What Counts")

    local back = CreateFrame("Button", nil, scope)
    back:SetSize(90, 18)
    back:SetPoint("TOPLEFT", 12, -46)
    back.text = Text(back, "GameFontNormalSmall")
    back.text:SetPoint("LEFT")
    back.text:SetText("< Options")
    back:SetScript("OnClick", function() ns.aboutPage = nil; ns.RefreshAbout() end)

    local intro = Text(scope, "GameFontHighlightSmall")
    intro:SetPoint("TOPLEFT", 34, -72)
    intro:SetWidth(pageW - 68)
    intro:SetSpacing(2)
    intro:SetText("Pick the achievement groups that make up 100%. Storylines, treasures, rares, "
        .. "reputation and collectibles always count. Changes apply at once.")

    local col1, col2, top = 34, 238, -112
    for i, group in ipairs(ns.SCOPE_ORDER or {}) do
        local c = CreateFrame("CheckButton", nil, scope, "UICheckButtonTemplate")
        c:SetSize(22, 22)
        c:SetPoint("TOPLEFT", (i % 2 == 1) and col1 or col2, top - math.floor((i - 1) / 2) * 24)
        c.label = c:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        c.label:SetPoint("LEFT", c, "RIGHT", 2, 0)
        c.label:SetText(group)
        c.group = group
        c:SetScript("OnClick", function(self)
            s.scope[self.group] = self:GetChecked() and true or false
            ApplyScope()
        end)
        scopeChecks[#scopeChecks + 1] = c
    end

    local rows = math.ceil(#(ns.SCOPE_ORDER or {}) / 2)
    local hy = top - rows * 24 - 14
    local hard = CreateFrame("CheckButton", nil, scope, "UICheckButtonTemplate")
    hard:SetSize(22, 22)
    hard:SetPoint("TOPLEFT", col1, hy)
    hard.label = hard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hard.label:SetPoint("LEFT", hard, "RIGHT", 2, 0)
    hard.label:SetText("Hard modes too")
    hard:SetScript("OnClick", function(self)
        s.hardmodes = self:GetChecked() and true or false
        ApplyScope()
    end)
    scope.hard = hard
    local hint = Text(scope, "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", col1 + 26, hy - 24)
    hint:SetWidth(pageW - 100)
    hint:SetText("Mythic raid and dungeon achievements, Glory metas, Nightmare Prey, and mounts that only drop on Mythic.")

    local reset = CreateFrame("Button", nil, scope, "UIPanelButtonTemplate")
    reset:SetSize(130, 22)
    reset:SetPoint("BOTTOMRIGHT", -34, 30)
    reset:SetText("Back to defaults")
    reset:SetScript("OnClick", function()
        s.scope = {}
        s.hardmodes = false
        ApplyScope()
    end)
end

-- Syncs the What Counts checkboxes with the saved settings.
local function RefreshScope()
    for _, c in ipairs(scopeChecks) do c:SetChecked(ns.Counts(c.group)) end
    scope.hard:SetChecked(ns.db.settings.hardmodes and true or false)
end

-- Shows whichever view ns.aboutPage asks for (nil = Options, "about", "scope") and fills it from the TOC
-- and settings. Website, Contact and Discord rows hide when the TOC has no value.
function ns.RefreshAbout()
    if not about then return end
    local page = ns.aboutPage
    options:SetShown(page == nil)
    about:SetShown(page == "about")
    scope:SetShown(page == "scope")
    if page == "scope" then RefreshScope(); return end
    if page == "about" then
        local info = about.info
        info.Version.value:SetText(Meta("Version") or "?")
        info.Developer.value:SetText(Meta("Author") or "?")
        for _, pair in ipairs({ { "Website", Meta("X-Website") }, { "Contact", Meta("X-Contact") },
                                { "Discord", Meta("X-Discord") } }) do
            local key, v = pair[1], pair[2]
            local row = info[key]
            row.label:SetShown(v ~= nil)
            row.value:SetShown(v ~= nil)
            if v then row.value:SetValue(v) end
        end
        return
    end
    for _, c in ipairs(checks) do c:SetChecked(c.get() and true or false) end
    options.bookSize:Update()
    options.arrowSize:Update()
end
