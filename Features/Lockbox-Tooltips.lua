--------------------------------------------------------------------------------
-- GogoLoot Lockbox Tooltips
--------------------------------------------------------------------------------

-- Read-only: nothing here casts, sends chat or writes state.
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Player Lockpicking Skill
--------------------------------------------------------------------------------

--[[
    The skill line's own name, from its ID. Never the Lockpicking spell's name
    (a different record; esMX words it differently) and never the tooltip's
    "Requires Lockpicking" line: circular, so on a client that doesn't print it
    the rank is never found. WoW Forever has no skill-line API, so the name only
    captions the block; MoP Classic has no Lockpicking skill line, so nil.
]]
local lockpickingSkillName

---@return string|nil
function ns.GetLockpickingSkillName()
	local skillLineIdentifier = ns.SKILL_LINE_IDS.LOCKPICKING
	if not lockpickingSkillName and skillLineIdentifier then
		lockpickingSkillName = C_TradeSkillUI.GetTradeSkillDisplayName(skillLineIdentifier)
	end
	return lockpickingSkillName
end

-- Nil when unreadable (non-Rogue, untrained, skill line not named yet, WoW Forever); callers color neutrally.
---@return number|nil
function ns.GetPlayerLockpickingSkill()
	return ns.GetSkillLineRankByName(ns.GetLockpickingSkillName())
end

--------------------------------------------------------------------------------
-- Tooltip Line
--------------------------------------------------------------------------------

-- The format, not the skill's name: other add-ons print lines naming Lockpicking without stating a requirement.
local requirementPattern = ns.BuildFormatPattern(ITEM_MIN_SKILL)

-- Built once per line index: a hovered tooltip re-runs the scan every frame.
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

-- The Short Name is matched as a substring: our own lines carry a color escape.
---@return boolean hasOurBlock
---@return boolean statesRequirement
local function ScanTooltipLines(tooltip)
	local tooltipName = tooltip:GetName()
	if not tooltipName then
		return false, false
	end
	local title = L["ADDON_SHORT_NAME"]
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
	-- A tooltip can be re-processed without being cleared; the Short Name marks the block as added.
	local hasOurBlock, statesRequirement = ScanTooltipLines(tooltip)
	if hasOurBlock then
		return
	end
	local skillName = ns.GetLockpickingSkillName()
	if not skillName then
		return
	end

	local skill = ns.IsPlayerRogue() and ns.GetPlayerLockpickingSkill() or nil

	-- When the client states the requirement, add only the player's rank; otherwise the requirement itself.
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

	tooltip:AddLine(" ")
	tooltip:AddLine(GetColor("TITLE") .. L["ADDON_SHORT_NAME"] .. "|r")
	tooltip:AddDoubleLine(color .. label .. "|r", color .. value .. "|r")
	tooltip:Show()
end

--------------------------------------------------------------------------------
-- Hook
--------------------------------------------------------------------------------

--[[
    The block goes last by being late in the build, never late to it: post-hooks
    run in registration order, so hooking at PLAYER_LOGIN puts it behind every
    add-on that hooked while loading. Deferring the add (C_Timer.After(0))
    strobes, since a hovered bag button re-runs SetBagItem every frame: never add
    lines outside the build. Best effort by design; a later hook can still land
    below it.

    SetBagItem exists on every shipped client. The bank's own slots show through
    SetInventoryItem where the bank is container -1.
]]
local hookInstalled = false

---@param itemLink string|nil
---@return number|nil
local function LinkItemIdentifier(itemLink)
	return itemLink and tonumber(string.match(itemLink, "item:(%d+)")) or nil
end

local LINK_HOOKS = {
	{ tooltip = "GameTooltip", method = "SetLootItem", link = GetLootSlotLink },
	{ tooltip = "GameTooltip", method = "SetTradePlayerItem", link = GetTradePlayerItemLink },
	{ tooltip = "GameTooltip", method = "SetTradeTargetItem", link = GetTradeTargetItemLink },
	{
		tooltip = "ItemRefTooltip",
		method = "SetHyperlink",
		link = function(itemLink)
			return itemLink
		end,
	},
}

local function OnPlayerLogin()
	if hookInstalled then
		return
	end
	hookInstalled = true
	hooksecurefunc(GameTooltip, "SetBagItem", function(tooltip, bagIndex, slotIndex)
		AddLockboxLine(tooltip, C_Container.GetContainerItemID(bagIndex, slotIndex))
	end)
	if GameTooltip.SetInventoryItem then
		hooksecurefunc(GameTooltip, "SetInventoryItem", function(tooltip, unitIdentifier, slotIndex)
			AddLockboxLine(tooltip, LinkItemIdentifier(GetInventoryItemLink(unitIdentifier, slotIndex)))
		end)
	end
	for _, hook in ipairs(LINK_HOOKS) do
		local tooltipFrame = _G[hook.tooltip]
		if tooltipFrame and tooltipFrame[hook.method] and hook.link then
			hooksecurefunc(tooltipFrame, hook.method, function(tooltip, argument)
				AddLockboxLine(tooltip, LinkItemIdentifier(hook.link(argument)))
			end)
		end
	end
end

ns:RegisterModuleEvent("PLAYER_LOGIN", OnPlayerLogin)
