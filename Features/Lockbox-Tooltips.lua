--------------------------------------------------------------------------------
-- GogoLoot Lockbox Tooltips
--------------------------------------------------------------------------------

--[[
    Adds the Lockpicking skill a locked container needs to its tooltip, and for
    a Rogue colors it by whether their skill is high enough. It answers the
    question the bag raises on its own: why is this box still sitting there, and
    what does it take to open it.

    Read-only: nothing here casts, sends chat or writes state.
]]
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Player Lockpicking Skill
--------------------------------------------------------------------------------

--[[
    The skill list shows skill-line names, so the rank is found by the skill
    line's own name, looked up from its ID. The Lockpicking spell's name is a
    different record and differs from it in some locales (esMX: "Forzar
    cerraduras" against "Ganzúa"), so it never stands in. The name only finds a
    rank on a client with a skill-line API; WoW Forever has none, so there the
    rank is always unknown, but the name still captions the tooltip block.

    THE TRAP: the tooltip is not a source for this name. Reading it off the
    tooltip's own "Requires Lockpicking (225)" line is circular: on a client that
    doesn't print that line, the name is never learned, the rank is always nil,
    and the requirement stays neutral white instead of green or red.
]]
local lockpickingSkillName

---@return string|nil
function ns.GetLockpickingSkillName()
	if not lockpickingSkillName then
		lockpickingSkillName = C_TradeSkillUI.GetTradeSkillDisplayName(ns.SKILL_LINE_IDS.LOCKPICKING)
	end
	return lockpickingSkillName
end

--[[
    A skill line's current rank, found by its localized name. WoW Forever has no
    skill-line API, so there this answers nil, which every caller already treats
    as unknown.
]]
---@param skillName string|nil
---@return number|nil
local function GetSkillLineRank(skillName)
	if not skillName or not GetNumSkillLines or not GetSkillLineInfo then
		return nil
	end
	for skillIndex = 1, GetNumSkillLines() do
		local lineName, isHeader, _, rank = GetSkillLineInfo(skillIndex)
		if not isHeader and lineName == skillName then
			return rank
		end
	end
	return nil
end

--[[
    Nil when the rank can't be read: a non-Rogue, an untrained Rogue, a client
    that hasn't named the skill line yet, or a client with no skill-line API at
    all (WoW Forever). Every caller treats nil as unknown and falls back to
    neutral coloring.
]]
---@return number|nil
function ns.GetPlayerLockpickingSkill()
	return GetSkillLineRank(ns.GetLockpickingSkillName())
end

--------------------------------------------------------------------------------
-- Tooltip Line
--------------------------------------------------------------------------------

--[[
    The client may print its own requirement line on some builds, and repeating
    it would be noise, so the pattern behind ITEM_MIN_SKILL decides which of the
    two shapes below to add. Matching the format rather than the skill's name
    keeps it precise: other add-ons print lines that name Lockpicking without
    stating a requirement, and a name match would read those as the client's.
]]
local requirementPattern = ns.BuildFormatPattern(ITEM_MIN_SKILL)

-- Each tooltip's left-line font-string names, built once per line index: the hover re-runs this.
local lineNamesByTooltip = {}

---@param tooltipName string
---@param lineIndex number
---@return string
local function LeftLineName(tooltipName, lineIndex)
	local names = lineNamesByTooltip[tooltipName]
	if not names then
		names = {}
		lineNamesByTooltip[tooltipName] = names
	end
	local name = names[lineIndex]
	if not name then
		name = tooltipName .. "TextLeft" .. lineIndex
		names[lineIndex] = name
	end
	return name
end

--[[
    One pass over a tooltip's lines for both questions the block asks: whether
    the block is already there, and whether the client states the requirement.
    The add-on title is matched as a substring, because our own lines carry a
    color escape the raw text doesn't.
]]
---@return boolean hasOurBlock
---@return boolean statesRequirement
local function ScanTooltipLines(tooltip)
	local tooltipName = tooltip:GetName()
	if not tooltipName then
		return false, false
	end
	local title = L["ADDON_TITLE"]
	local statesRequirement = false
	for lineIndex = 1, tooltip:NumLines() do
		local line = _G[LeftLineName(tooltipName, lineIndex)]
		local text = line and line:GetText()
		if text then
			if string.find(text, title, 1, true) then
				return true, statesRequirement
			end
			if requirementPattern and string.match(text, requirementPattern) then
				statesRequirement = true
			end
		end
	end
	return false, statesRequirement
end

local function LockboxTooltipsEnabled()
	return ns.db ~= nil and ns.db.profile.lockboxTooltips and ns.LockboxScopeAllows(ns.db.profile.lockboxTooltipsScope)
end

local function AddLockboxLine(tooltip, itemIdentifier)
	if not LockboxTooltipsEnabled() then
		return
	end
	local requiredSkill = itemIdentifier and ns.LOCKBOX_SKILL_LEVELS[itemIdentifier]
	if not requiredSkill then
		return
	end
	--[[
        The add-on title doubles as the "already added" mark: a tooltip can be
        re-processed without being cleared, and one check on the title covers
        every line the block adds below it.
    ]]
	local hasOurBlock, statesRequirement = ScanTooltipLines(tooltip)
	if hasOurBlock then
		return
	end
	local skillName = ns.GetLockpickingSkillName()
	if not skillName then
		return
	end

	local skill = ns.IsPlayerRogue() and ns.GetPlayerLockpickingSkill() or nil

	--[[
        Two shapes, never both. When the client already states the requirement,
        repeating it is noise, so the block adds the one thing the client won't:
        the player's own rank, colored by whether it clears the box. When the
        client says nothing, the requirement itself is the useful line.
    ]]
	local label, value, color
	if statesRequirement then
		if not skill then
			return
		end
		label, value = L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"]:format(skillName), skill
		color = skill >= requiredSkill and GetColor("ON") or GetColor("OFF")
	else
		label, value = ITEM_REQ_SKILL:format(skillName), requiredSkill
		color = GetColor("BODY")
		if skill then
			color = skill >= requiredSkill and GetColor("ON") or GetColor("OFF")
		end
	end

	--[[
        Its own block, set off from the client's lines: a blank separator, the
        add-on's name, then the label and its number as a double line so the
        number sits in the tooltip's right column.
    ]]
	tooltip:AddLine(" ")
	tooltip:AddLine(GetColor("TITLE") .. L["ADDON_TITLE"] .. "|r")
	tooltip:AddDoubleLine(color .. label .. "|r", color .. value .. "|r")
	tooltip:Show()
end

--------------------------------------------------------------------------------
-- Hook
--------------------------------------------------------------------------------

--[[
    THE BLOCK GOES LAST BY BEING LATE IN THE FRAME, NEVER BY BEING LATE TO IT.

    Where the block lands in a tooltip is decided by two things:

      - WHEN in the build it adds. A SetBagItem post-hook is about as late as a
        synchronous add can be: the client's lines are set, and every add-on that
        adds to the item tooltip while it is built has had its say.
      - WHERE it sits among other SetBagItem post-hooks, which run in the order
        they were registered. Hooking at PLAYER_LOGIN rather than while this file
        loads puts it behind every add-on that hooked while loading.

    A THIRD OPTION IS DELIBERATELY REJECTED. Deferring the add to the next frame
    with C_Timer.After(0) does put the block under everything, and it FLICKERS
    BADLY: a hovered bag button re-runs SetBagItem every frame, so the tooltip is
    rebuilt without the block, gets it a frame later, loses it again, and strobes
    for as long as the cursor rests on the item. Do not reintroduce it in any
    form that adds lines outside the build itself.

    So this is best effort by design: an add-on that hooks later, or rebuilds the
    tooltip on its own schedule, can still land below it. A row out of place
    beats a tooltip that strobes.

    SetBagItem is hooked unguarded: a widget method on all three clients, firing
    for the bag and bank slots the feature is about and nothing else.
]]
local hookInstalled = false

local function InstallTooltipHook()
	if hookInstalled then
		return
	end
	hookInstalled = true
	hooksecurefunc(GameTooltip, "SetBagItem", function(tooltip, bagIndex, slotIndex)
		AddLockboxLine(tooltip, C_Container.GetContainerItemID(bagIndex, slotIndex))
	end)
end

ns:RegisterModuleEvent("PLAYER_LOGIN", InstallTooltipHook)
