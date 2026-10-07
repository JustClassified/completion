-- Completion: hover hints. Mouse over a rare, an NPC, a treasure or an item that still counts toward
-- something, and its tooltip says what. Nothing is shown for things you have already done.
--
-- Sources, built after each rebuild:
--   NPCs      rares and world bosses (Points), "kill <creature>" achievement criteria (type 0)
--   objects   "use <object>" achievement criteria (type 68), treasure names
--   items     collectibles still missing, items a guided treasure asks you to pick up

local _, ns = ...

local npcIndex, objIndex, nameIndex, itemIndex = {}, {}, {}, {}
local PlayerLines
local indexStamp = -1

-- Appends v to the list at t[k], creating it. A nil key is ignored.
local function push(t, k, v)
    if not k then return end
    t[k] = t[k] or {}
    table.insert(t[k], v)
end

-- Every row in the book, with the children of containers flattened in after their parent.
local function AllItems()
    local out = {}
    local pages = {}
    for _, z in ipairs(ns.ZONES) do pages[#pages + 1] = z end
    for _, z in ipairs(ns.EVENT_ZONES or {}) do pages[#pages + 1] = z end
    for _, z in ipairs(pages) do
        for _, s in ipairs(z.sectionDefs or ns.SECTIONS) do
            for _, it in ipairs(z.sections[s.key].items) do
                out[#out + 1] = it
                if it.kind == "container" then
                    for _, ch in ipairs(it.children) do out[#out + 1] = ch end
                end
            end
        end
    end
    return out
end

-- Rebuilds the four lookups (NPC ID, object ID, normalised name, item ID -> refs to rows).
-- A ref carries crit or step when it points at one criterion or one guide step.
local function BuildIndex()
    npcIndex, objIndex, nameIndex, itemIndex = {}, {}, {}, {}
    for _, it in ipairs(AllItems()) do
        if it.kind == "point" then
            if it.npc then push(npcIndex, it.npc, { it = it }) end
            if it.name then push(nameIndex, ns.norm(it.name), { it = it }) end
            for i, st in ipairs(it.steps or {}) do
                if type(st.item) == "number" then push(itemIndex, st.item, { it = it, step = i }) end
            end
        elseif it.kind == "ach" then
            local c = ns.Crits(it.id)
            for _, e in ipairs(c and c.list or {}) do
                if e.asset and e.asset > 0 then
                    if e.t == 0 then push(npcIndex, e.asset, { it = it, crit = e.index })
                    elseif e.t == 68 then push(objIndex, e.asset, { it = it, crit = e.index }) end
                end
                if e.name and e.name ~= "" and (e.t == 68 or e.t == 0) then
                    push(nameIndex, ns.norm(e.name:gsub("^%-%s*", "")), { it = it, crit = e.index })
                end
            end
        elseif it.kind == "collect" and it.itemID then
            push(itemIndex, it.itemID, { it = it })
        end
    end
    indexStamp = ns.buildStamp
end

-- True when the ref's criterion, or its whole achievement, is done.
local function CritDone(ref)
    local c = ns.Crits(ref.it.id)
    local e = c and c.list[ref.crit]
    return (e and e.done) or ns.AchDone(ref.it.id)
end

-- Tooltip text for the refs that are still open; refs may be nil.
local function Lines(refs)
    local out = {}
    for _, ref in ipairs(refs or {}) do
        local it = ref.it
        local zone = (it.parent or it).zone
        local where = zone and zone.short or ""
        if ref.crit then
            if not CritDone(ref) then
                local a = ns.Ach(it.id)
                out[#out + 1] = string.format("Counts toward %s", a and a.name or "an achievement")
            end
        elseif ref.step then
            if not it.done and not ns.StepDone(it, ref.step) then
                out[#out + 1] = string.format("Needed for %s (step %d)", it.name or "a treasure", ref.step)
            end
        elseif not it.done and (it.max or 0) > 0 then
            if it.kind == "collect" then
                out[#out + 1] = string.format("Missing %s  (%s)", (ns.TYPE_LABEL[it.ctype or ""] or "collectible"):lower(), where)
            elseif it.pkind == "rare" or it.pkind == "boss" then
                local a = it.groupAch and ns.Ach(it.groupAch)
                out[#out + 1] = a and string.format("Rare for %s", a.name) or string.format("Rare you haven't killed  (%s)", where)
            else
                out[#out + 1] = string.format("%s not done yet  (%s)", it.name or "This", where)
            end
        end
    end
    return out
end

-- Adds each distinct line to the tooltip under the addon's prefix.
local function Add(tooltip, lines)
    if #lines == 0 then return end
    local seen = {}
    for _, l in ipairs(lines) do
        if not seen[l] then
            seen[l] = true
            tooltip:AddLine("|cffe6c35cCompletion:|r " .. l, 0.9, 0.9, 0.9, true)
        end
    end
end

-- Only the main GameTooltip, only once the book is built and hints are on. Rebuilds the
-- index first if the book was rebuilt since.
local function Ready(tooltip)
    if tooltip ~= GameTooltip or not ns.built or not ns.db or not ns.db.settings.tooltips then return false end
    if indexStamp ~= ns.buildStamp then BuildIndex() end
    return true
end

-- The 6th field of a creature or game object GUID is its ID. GUIDs can be secret values in
-- restricted content on this client; those are left alone. Returns the GUID type and the ID.
local function IdFromGUID(guid)
    if not guid or (issecretvalue and issecretvalue(guid)) or type(guid) ~= "string" then return end
    local kind, _, _, _, _, id = strsplit("-", guid)
    return kind, tonumber(id)
end

-- Players: races still needed for Share a Drink (toast them with a Toasting Brew in the Arcantina).
local SHARE_A_DRINK = 61081
-- A line when this player's race is a Share a Drink criterion you haven't done yet.
PlayerLines = function(guid)
    if ns.AchDone(SHARE_A_DRINK) or not GetPlayerInfoByGUID then return {} end
    local ok, _, _, race = pcall(GetPlayerInfoByGUID, guid)
    if not ok or type(race) ~= "string" or (issecretvalue and issecretvalue(race)) then return {} end
    local c = ns.Crits(SHARE_A_DRINK)
    local want = ns.norm(race)
    for _, e in ipairs(c and c.list or {}) do
        if e.name and ns.norm(e.name) == want then
            if not e.done then return { "Share a Drink: you still need a " .. race .. "!" } end
            return {}
        end
    end
    return {}
end

-- Unit tooltips: creatures by NPC ID, players for Share a Drink.
local function OnUnit(tooltip, data)
    if not Ready(tooltip) then return end
    local guid = data and data.guid
    if not guid and tooltip.GetUnit then
        local ok, _, unit = pcall(tooltip.GetUnit, tooltip)
        if ok and unit then guid = UnitGUID(unit) end
    end
    local kind, id = IdFromGUID(guid)
    if (kind == "Creature" or kind == "Vehicle") and id then Add(tooltip, Lines(npcIndex[id])) end
    if kind == "Player" then Add(tooltip, PlayerLines(guid)) end
end

-- Game object tooltips: by object ID, else by the tooltip's title (treasures are matched by name).
local function OnObject(tooltip, data)
    if not Ready(tooltip) then return end
    local kind, id = IdFromGUID(data and data.guid)
    local lines = {}
    if kind == "GameObject" and id then lines = Lines(objIndex[id]) end
    if #lines == 0 and data and data.lines and data.lines[1] then
        local title = data.lines[1].leftText
        if type(title) == "string" and not (issecretvalue and issecretvalue(title)) then
            lines = Lines(nameIndex[ns.norm(title)])
        end
    end
    Add(tooltip, lines)
end

-- Item tooltips, by item ID.
local function OnItem(tooltip, data)
    if not Ready(tooltip) then return end
    local id = data and data.id
    if type(id) == "number" then Add(tooltip, Lines(itemIndex[id])) end
end

-- Each handler runs in pcall so a hint can never break someone else's tooltip.
if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
    local T = Enum.TooltipDataType
    if T.Unit then TooltipDataProcessor.AddTooltipPostCall(T.Unit, function(tt, d) pcall(OnUnit, tt, d) end) end
    if T.Object then TooltipDataProcessor.AddTooltipPostCall(T.Object, function(tt, d) pcall(OnObject, tt, d) end) end
    if T.Item then TooltipDataProcessor.AddTooltipPostCall(T.Item, function(tt, d) pcall(OnItem, tt, d) end) end
end
