-- Completion: "Report a gap". Opens a box of plain text, already selected, with everything a bug report needs:
-- addon and game version, language, where you stand, the book page you are on, what the arrow points at, and
-- the open achievements on that page that have no location or walkthrough yet. Players copy it (Ctrl+C) into a
-- comment or the Discord, which makes every report exact.

local _, ns = ...

local box

-- Open achievements on a zone page with nothing that says where or how: "Name (id)" strings.
function ns.AuditList(z)
    local bare = {}
    local function check(it)
        if it.kind ~= "ach" or it.done or it.hidden then return end
        local id = it.id
        if (ns.ACH_NOTES and ns.ACH_NOTES[id]) or (ns.ACH_STEPS and ns.ACH_STEPS[id]) or (ns.ACH_SPOTS and ns.ACH_SPOTS[id]) then return end
        for _, row in ipairs(ns.Children(it)) do if row.spot or row.how or row.note or row.item then return end end
        if ns.Resolve(it).spot then return end
        bare[#bare + 1] = string.format("%s (%d)", it.liveName or it.name or "?", id)
    end
    for _, sdef in ipairs(z.sectionDefs or ns.SECTIONS) do
        for _, it in ipairs(z.sections[sdef.key].items) do
            check(it)
            if it.kind == "container" then for _, ch in ipairs(it.children) do check(ch) end end
        end
    end
    return bare
end

-- The report text for the page the book is on (or the zone you are in).
local function ReportText()
    local lines = {}
    local function add(s) lines[#lines + 1] = s end
    local meta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    local version = meta and meta(ns.ADDON, "Version") or "?"
    local gameVersion, build = "?", "?"
    if GetBuildInfo then gameVersion, build = GetBuildInfo() end
    add(string.format("Completion %s report (game %s.%s, %s)", version, tostring(gameVersion), tostring(build),
        GetLocale and GetLocale() or "?"))
    local m = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if m then
        local info = C_Map.GetMapInfo and C_Map.GetMapInfo(m)
        local pos = C_Map.GetPlayerMapPosition and C_Map.GetPlayerMapPosition(m, "player")
        local x, y
        if pos then if pos.GetXY then x, y = pos:GetXY() else x, y = pos.x, pos.y end end
        add(string.format("Standing in: %s (map %d)%s", info and info.name or "?", m,
            x and string.format(" at %.1f, %.1f", x * 100, y * 100) or ""))
    end
    local z = (ns.BookPage and ns.BookPage()) or ns.zoneByKey[ns.cdb.lastZone or ""] or ns.PlayerZone() or ns.ZONES[1]
    local sec = ns.cdb.lastSection and z.sections[ns.cdb.lastSection]
    add("Book page: " .. z.name .. (sec and (" > " .. sec.name) or ""))
    local it, child = ns.TargetItem()
    if it then
        local res = ns.Resolve(it, child)
        add(string.format("Tracking: %s [%s]%s", res.title or it.name or "?", it.key,
            res.spot and string.format(" -> map %d at %.1f, %.1f", res.spot.map, res.spot.x, res.spot.y) or " -> no spot"))
    end
    local bare = ns.AuditList(z)
    add(string.format("Open achievements on %s without a location or walkthrough: %d", z.name, #bare))
    for i = 1, math.min(#bare, 40) do add("  " .. bare[i]) end
    add("")
    add("What is wrong or missing (write it here):")
    add("")
    return table.concat(lines, "\n")
end

-- The report window: a scrolling text box, selected so Ctrl+C copies it at once.
local function CreateBox()
    box = CreateFrame("Frame", "CompletionReport", UIParent, "BackdropTemplate")
    box:SetSize(520, 360)
    box:SetPoint("CENTER")
    box:SetFrameStrata("DIALOG")
    box:SetMovable(true)
    box:EnableMouse(true)
    box:RegisterForDrag("LeftButton")
    box:SetScript("OnDragStart", box.StartMoving)
    box:SetScript("OnDragStop", box.StopMovingOrSizing)
    if box.SetBackdrop then
        box:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
                          edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
                          tile = true, tileSize = 32, edgeSize = 32, insets = { left = 11, right = 12, top = 12, bottom = 11 } })
    end
    local title = box:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -18)
    title:SetText("Report a gap")
    local hint = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("TOP", title, "BOTTOM", 0, -4)
    hint:SetText("Press Ctrl+C to copy, add what is wrong, and paste it on the Discord or CurseForge.")
    local scroll = CreateFrame("ScrollFrame", nil, box, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 22, -58)
    scroll:SetPoint("BOTTOMRIGHT", -40, 48)
    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(450)
    edit:SetScript("OnEscapePressed", function() box:Hide() end)
    scroll:SetScrollChild(edit)
    box.edit = edit
    local close = CreateFrame("Button", nil, box, "UIPanelButtonTemplate")
    close:SetSize(100, 22)
    close:SetPoint("BOTTOM", 0, 18)
    close:SetText("Close")
    close:SetScript("OnClick", function() box:Hide() end)
    tinsert(UISpecialFrames, "CompletionReport")   -- Escape closes it
end

-- Opens the report for the current page, text selected.
function ns.ShowReport()
    if not ns.built then return end
    if not box then CreateBox() end
    box.edit:SetText(ReportText())
    box:Show()
    box.edit:SetFocus()
    box.edit:HighlightText()
end
