-- Completion: the on-screen tracker, like the quest tracker. It shows what the arrow is pointing at with all
-- its steps or criteria, ticked as they are done, so the book can stay closed:
--   achievement   its criteria (or the achievements a meta needs, with their own progress), done/left count
--   treasure      the steps of a multi-step treasure
--   storyline     the quest chain
--   delve         its Sturdy Chests and achievements
--   collectible   how to get it (source, vendor and price, attempts)
--   rare          where it spawns and what it drops
-- Below it, the watch list. Click a line to point the arrow there; Shift-click opens its page in the book;
-- right-click the title to stop tracking. Drag the title to move it; the - button folds it.

local _, ns = ...

local WIDTH, LINE_H, MAX_LINES = 280, 15, 14
local ICON_DONE = "Interface\\RaidFrame\\ReadyCheck-Ready"
local ICON_NOW = "Interface\\RaidFrame\\ReadyCheck-Waiting"
local ICON_OPEN = "Interface\\COMMON\\Indicator-Gray"

local frame

-- "320 yd" to a spot, or nil when there is no distance (another continent, an instance).
local function Yards(spot, pinst, pwx, pwy)
    local d = spot and pinst and ns.Distance(spot, pinst, pwx, pwy)
    return d and string.format("%d yd", math.floor(d)) or nil
end

-- The lines for an item: { text, right, state = "done" | "now" | "open" | "info", it, key, item }.
-- Long lists keep the open lines (the current one first) and fold the rest into "+N more" and "N done".
local function Lines(it, child)
    local lines = {}
    local pinst, pwx, pwy = ns.PlayerWorld()
    local res = ns.Resolve(it, child)
    local rows = (it.kind == "ach" or it.kind == "container" or it.kind == "lore" or (it.kind == "point" and it.steps))
        and ns.Children(it) or {}
    for _, row in ipairs(rows) do
        local sub = row.item
        local done = sub and sub.done or row.done
        local text = sub and (sub.liveName or sub.name or "?") or row.name or "?"
        local right
        if sub and (sub.max or 0) > 1 and not done then right = string.format("%d/%d", sub.cur or 0, sub.max) end
        if not done and row.spot then right = Yards(row.spot, pinst, pwx, pwy) or right end
        if not done and row.sub and not right then right = row.sub end
        local now = not done and ((child and row.key == child) or row.current
            or (res.spot and row.spot and row.spot == res.spot))
        lines[#lines + 1] = { text = text, right = right,
                              state = row.extra and "info" or (done and "done" or (now and "now" or "open")),
                              it = sub or it, key = not sub and row.key or nil }
    end
    -- an achievement split over zones: one line per other zone with what is left there, so the whole
    -- achievement is in view (and the criteria no zone covers yet)
    local tail = {}
    if it.kind == "ach" and it.split then
        local parts, loose = ns.SplitParts(it)
        for i = 2, #parts do
            local p = parts[i]
            local left = {}
            for _, row in ipairs(ns.Children(p)) do
                if not row.done then left[#left + 1] = row.name end
            end
            local where = p.zone and p.zone.short or "?"
            tail[#tail + 1] = { text = #left == 0 and (where .. ": all done")
                                    or string.format("%s: %s", where, table.concat(left, ", ")),
                                full = where .. ": " .. (#left == 0 and "all done" or table.concat(left, ", ")),
                                right = (p.max or 0) > 0 and string.format("%d/%d", p.cur or 0, p.max) or nil,
                                state = #left == 0 and "done" or "open", it = p }
        end
        if #loose > 0 then
            local names = {}
            for _, e in ipairs(loose) do if not e.done then names[#names + 1] = e.name or "?" end end
            if #names > 0 then
                tail[#tail + 1] = { text = "No place known yet: " .. table.concat(names, ", "), state = "info" }
            end
        end
    end
    -- no rows: a short "how" for collectibles, rares and plain spots
    if #lines == 0 then
        local how = (it.kind == "collect" or it.kind == "point") and ns.HowToGet(it) or {}
        for i = 1, math.min(4, #how) do lines[#lines + 1] = { text = how[i][1], state = "info" } end
        if #lines == 0 and res.text then lines[1] = { text = res.text, state = "info" } end
        -- coordinates and distance, unless the lines above already say where
        if res.spot and #how == 0 then
            lines[#lines + 1] = { text = string.format("%.1f, %.1f", res.spot.x, res.spot.y),
                                  right = Yards(res.spot, pinst, pwx, pwy), state = "info" }
        end
    end
    if #lines + #tail <= MAX_LINES then
        for _, l in ipairs(tail) do lines[#lines + 1] = l end
        return lines
    end
    -- too many: the current line, then open lines in list order, then the rest as counts
    local out, hidden, done = {}, 0, 0
    for _, l in ipairs(lines) do if l.state == "now" then out[#out + 1] = l end end
    for _, l in ipairs(lines) do
        if l.state == "open" then
            if #out < MAX_LINES - 2 then out[#out + 1] = l else hidden = hidden + 1 end
        elseif l.state == "done" then
            done = done + 1
        end
    end
    if hidden > 0 then out[#out + 1] = { text = string.format("+%d more to do", hidden), state = "info" } end
    if done > 0 then out[#out + 1] = { text = string.format("%d done", done), state = "doneinfo" } end
    for _, l in ipairs(tail) do out[#out + 1] = l end
    return out
end

-- Line i of the pool: icon, text and a right-hand note; clicks track it, Shift-click opens the book.
local function Line(i)
    local b = frame.lines[i]
    if b then return b end
    b = CreateFrame("Button", nil, frame)
    b:SetHeight(LINE_H)
    b:SetPoint("LEFT", 6, 0)
    b:SetPoint("RIGHT", -6, 0)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b.hl = b:CreateTexture(nil, "HIGHLIGHT")
    b.hl:SetAllPoints()
    b.hl:SetColorTexture(1, 0.85, 0.5, 0.08)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetSize(11, 11)
    b.icon:SetPoint("LEFT", 2, 0)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.text:SetPoint("LEFT", 17, 0)
    b.text:SetPoint("RIGHT", -60, 0)
    b.text:SetJustifyH("LEFT")
    b.text:SetWordWrap(false)
    b.right = b:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    b.right:SetPoint("RIGHT", -2, 0)
    b:SetScript("OnClick", function(self, button)
        local l = self.l
        if not (l and l.it) then return end
        if button == "RightButton" then
            if l.watch then ns.WatchToggle(l.it, l.key) end
            return
        end
        if IsShiftKeyDown() then ns.Toggle(true); ns.JumpTo(l.it); return end
        if l.it.kind ~= "rep" and ns.StillWanted(l.it) then ns.Track(l.it, l.key) end
    end)
    b:SetScript("OnEnter", function(self)
        local l = self.l
        if not l then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(l.full or l.text, 1, 1, 1, true)
        if l.it then
            GameTooltip:AddLine(l.watch and "Click: track it. Right-click: take it off the watch list."
                or "Click: point the arrow here. Shift-click: open it in the book.", 0.7, 0.7, 0.7, true)
        end
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    frame.lines[i] = b
    return b
end

-- Fills line i and places it under the previous one.
local function Put(i, y, l)
    local b = Line(i)
    b.l = l
    b:ClearAllPoints()
    b:SetPoint("TOPLEFT", 6, y)
    b:SetPoint("RIGHT", frame, "RIGHT", -6, 0)
    local st = l.state
    if st == "done" or st == "doneinfo" then
        b.icon:SetTexture(ICON_DONE); b.icon:Show()
        b.text:SetTextColor(0.5, 0.75, 0.5)
    elseif st == "now" then
        b.icon:SetTexture(ICON_NOW); b.icon:Show()
        b.text:SetTextColor(1, 0.86, 0.45)
    elseif st == "open" then
        b.icon:SetTexture(ICON_OPEN); b.icon:Show()
        b.text:SetTextColor(0.93, 0.89, 0.8)
    else
        b.icon:Hide()
        b.text:SetTextColor(0.8, 0.78, 0.72)
    end
    b.text:SetPoint("LEFT", b.icon:IsShown() and 17 or 4, 0)
    b.text:SetText(l.text or "")
    b.right:SetText(l.right or "")
    b:Show()
end

-- How far along a goal is, as done, total; nil when it has no parts to count. An achievement counts its
-- criteria (the whole achievement when it is split over zones), a treasure its steps, a delve its contents.
local function Progress(it)
    if it.kind == "ach" then
        if it.split then
            local _, _, done, total = ns.SplitParts(it)
            if total > 1 then return done, total end
            return
        end
        local c = ns.Crits(it.id)
        local done, total = 0, 0
        for _, e in ipairs(c and c.list or {}) do
            if ns.InPart(it, e) then
                total = total + 1
                if e.done or it.done then done = done + 1 end
            end
        end
        if total > 1 then return done, total end
    elseif it.kind == "point" and it.steps then
        local done = 0
        for i = 1, #it.steps do if ns.StepDone(it, i) then done = done + 1 end end
        return done, #it.steps
    elseif (it.max or 0) > 1 then
        return it.cur or 0, it.max
    end
end

-- Redraws the tracker: the tracked goal with its lines, then the watch list. Hidden when there is nothing.
function ns.RefreshTracker()
    if not frame then return end
    if not (ns.built and ns.db and ns.db.settings.tracker ~= false) then frame:Hide(); return end
    local it, child = ns.TargetItem()
    local watch = ns.WatchEntries and ns.WatchEntries() or {}
    if not it and #watch == 0 then frame:Hide(); return end
    local collapsed = ns.db.settings.trackerCollapsed
    local n, y = 0, -32
    if it then
        local host = it
        local title = (ns.RouteActive() and ns.RouteLabel() or "") .. ns.PatrolLabel() .. (host.liveName or host.name or "?")
        frame.title:SetText(title)
        local done, total = Progress(host)
        frame.count:SetText(total and string.format("%d/%d", done, total) or "")
        -- the thin bar under the title: gold while under way, green when complete
        frame.bar:SetShown(total ~= nil)
        if total then
            frame.bar:SetMinMaxValues(0, total)
            frame.bar:SetValue(done)
            if done >= total then frame.bar:SetStatusBarColor(0.35, 0.8, 0.35) else frame.bar:SetStatusBarColor(0.95, 0.75, 0.3) end
        end
        if not collapsed then
            for _, l in ipairs(Lines(it, child)) do
                n = n + 1
                Put(n, y, l)
                y = y - LINE_H
            end
        end
    else
        frame.title:SetText("Watch list")
        frame.count:SetText("")
        frame.bar:Hide()
    end
    -- the watch list, without the goal already shown above
    if not collapsed then
        local first = true
        for _, e in ipairs(watch) do
            if not (it and e.it == it) then
                if first then
                    first = false
                    if it then
                        n = n + 1
                        Put(n, y - 4, { text = "|cffc8a060Watching|r", state = "info" })
                        y = y - LINE_H - 4
                    end
                end
                n = n + 1
                Put(n, y, { text = e.title or "?", right = e.d and string.format("%d yd", math.floor(e.d)) or nil,
                            state = "open", it = e.it, key = e.c, watch = true })
                y = y - LINE_H
            end
        end
    end
    for i = n + 1, #frame.lines do frame.lines[i]:Hide() end
    frame.fold:SetText(collapsed and "+" or "-")
    frame:SetHeight(-y + 6)
    frame:Show()
end

-- The tracker frame: a slim title bar you drag, a fold button, lines refreshed twice a second.
function ns.CreateTracker()
    frame = CreateFrame("Frame", "CompletionTracker", UIParent)
    frame:SetSize(WIDTH, 40)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    -- a faint background that firms up while the mouse is over the tracker
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0, 0, 0, 0.18)
    -- the header strip, like the quest tracker's: a dark band with a gold line under it
    frame.headBg = frame:CreateTexture(nil, "BORDER")
    frame.headBg:SetPoint("TOPLEFT")
    frame.headBg:SetPoint("TOPRIGHT")
    frame.headBg:SetHeight(22)
    frame.headBg:SetColorTexture(0.1, 0.08, 0.05, 0.75)
    frame.headLine = frame:CreateTexture(nil, "ARTWORK")
    frame.headLine:SetPoint("TOPLEFT", 0, -22)
    frame.headLine:SetPoint("TOPRIGHT", 0, -22)
    frame.headLine:SetHeight(1)
    frame.headLine:SetColorTexture(0.85, 0.68, 0.35, 0.7)
    -- progress under the header
    frame.bar = CreateFrame("StatusBar", nil, frame)
    frame.bar:SetPoint("TOPLEFT", 6, -26)
    frame.bar:SetPoint("TOPRIGHT", -6, -26)
    frame.bar:SetHeight(3)
    frame.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    frame.bar.bg = frame.bar:CreateTexture(nil, "BACKGROUND")
    frame.bar.bg:SetAllPoints()
    frame.bar.bg:SetColorTexture(0, 0, 0, 0.5)
    frame.bar:Hide()
    frame.lines = {}
    local head = CreateFrame("Button", nil, frame)
    head:SetPoint("TOPLEFT", 0, 0)
    head:SetPoint("TOPRIGHT", -22, 0)
    head:SetHeight(22)
    head:RegisterForDrag("LeftButton")
    head:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    head:SetScript("OnDragStart", function() frame:StartMoving() end)
    head:SetScript("OnDragStop", function() frame:StopMovingOrSizing(); ns.SavePos(frame, "tracker") end)
    head:SetScript("OnClick", function(_, button)
        local it = ns.TargetItem()
        if button == "RightButton" then ns.Track(nil)
        elseif it and IsShiftKeyDown() then ns.Toggle(true); ns.JumpTo(it) end
    end)
    head:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Completion tracker")
        GameTooltip:AddLine("Drag to move. Shift-click: open it in the book. Right-click: stop tracking.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    head:SetScript("OnLeave", function() GameTooltip:Hide() end)
    frame.title = head:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("LEFT", 6, 0)
    frame.title:SetPoint("RIGHT", -44, 0)
    frame.title:SetJustifyH("LEFT")
    frame.title:SetWordWrap(false)
    frame.count = head:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.count:SetPoint("RIGHT", -4, 0)
    frame.fold = CreateFrame("Button", nil, frame)
    frame.fold:SetSize(20, 20)
    frame.fold:SetPoint("TOPRIGHT", -2, -1)
    frame.fold:SetNormalFontObject(GameFontNormal)
    frame.fold:SetText("-")
    frame.fold:SetScript("OnClick", function()
        ns.db.settings.trackerCollapsed = not ns.db.settings.trackerCollapsed
        ns.RefreshTracker()
    end)
    ns.RestorePos(frame, "tracker", "TOPRIGHT", -330, -240)
    frame:Hide()
    frame.ticker = CreateFrame("Frame")
    frame.ticker:SetScript("OnUpdate", function(self, elapsed)
        self.acc = (self.acc or 0) + elapsed
        if self.acc < 0.5 then return end
        self.acc = 0
        ns.RefreshTracker()
        if frame:IsShown() then frame.bg:SetColorTexture(0, 0, 0, frame:IsMouseOver() and 0.45 or 0.18) end
    end)
end
