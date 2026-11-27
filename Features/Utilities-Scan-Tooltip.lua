--------------------------------------------------------------------------------
-- GogoLoot Utilities — Scan Tooltip
--------------------------------------------------------------------------------
local _, ns = ...

--------------------------------------------------------------------------------
-- Scan Tooltip
--------------------------------------------------------------------------------

--[[
    THE OWNER IS SET ON EVERY CALL: hiding a tooltip drops its owner, and an
    unowned tooltip takes a SetBagItem silently and populates NOTHING, so every
    box would read as unlocked. Setting a tooltip also shows it, hence the Hide
    after every read: within one frame it never renders.
]]
local SCAN_TOOLTIP_NAME = "GogoLootScanTooltip"
local scanTooltip

---@return table
local function PrepareScanTooltip()
	if not scanTooltip then
		scanTooltip = CreateFrame("GameTooltip", SCAN_TOOLTIP_NAME, nil, "GameTooltipTemplate")
	end
	scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	scanTooltip:ClearLines()
	return scanTooltip
end

-- WHOLE line, never a substring: other add-ons write lines containing LOCKED without meaning it.
---@param needle string
---@return boolean
local function ScanTooltipHasLine(needle)
	for lineIndex = 1, scanTooltip:NumLines() do
		local line = _G[SCAN_TOOLTIP_NAME .. "TextLeft" .. lineIndex]
		if line and line:GetText() == needle then
			return true
		end
	end
	return false
end

-- Zero lines means the tooltip read nothing, which also answers "not locked": Diagnostics looks for it.
---@param bagIndex number
---@param slotIndex number
---@return boolean locked
---@return number lineCount
function ns.IsItemLocked(bagIndex, slotIndex)
	local tooltip = PrepareScanTooltip()
	tooltip:SetBagItem(bagIndex, slotIndex)
	local locked = ScanTooltipHasLine(LOCKED)
	local lineCount = tooltip:NumLines()
	tooltip:Hide()
	return locked, lineCount
end

-- Color escapes left in. The tooltip is the only place the game gives the trade clock.
---@param bagIndex number
---@param slotIndex number
---@return string[]
function ns.GetBagItemTooltipLines(bagIndex, slotIndex)
	local tooltip = PrepareScanTooltip()
	tooltip:SetBagItem(bagIndex, slotIndex)
	local lines = {}
	for lineIndex = 1, tooltip:NumLines() do
		local line = _G[SCAN_TOOLTIP_NAME .. "TextLeft" .. lineIndex]
		lines[#lines + 1] = line and line:GetText() or ""
	end
	tooltip:Hide()
	return lines
end

--[[
    Only the tooltip says it: quest starters are as often ordinary gear as
    class 12. Read by hyperlink, since loot may never reach the bags. Kept for
    the session, but only for a loaded item: a cold one's tooltip reads "no".
]]
local startsQuestByItem = {}

---@param itemIdentifier number|nil
---@return boolean
function ns.ItemStartsQuest(itemIdentifier)
	if not itemIdentifier then
		return false
	end
	local known = startsQuestByItem[itemIdentifier]
	if known ~= nil then
		return known
	end
	local tooltip = PrepareScanTooltip()
	tooltip:SetHyperlink("item:" .. itemIdentifier)
	local startsQuest = ScanTooltipHasLine(ITEM_STARTS_QUEST)
	tooltip:Hide()
	if C_Item.GetItemInfo(itemIdentifier) then
		startsQuestByItem[itemIdentifier] = startsQuest
	end
	return startsQuest
end

-- A read can throw on an odd id, so callers protect it.
local TOOLTIP_DATA_GETTERS = C_TooltipInfo
	and C_TooltipInfo.GetItemByID
	and C_TooltipInfo.GetSpellByID
	and { item = C_TooltipInfo.GetItemByID, spell = C_TooltipInfo.GetSpellByID }

---@param text any
---@return string|nil
local function PlainText(text)
	if type(text) ~= "string" then
		return nil
	end
	return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|cn[^:]*:", ""):gsub("|r", ""))
end

---@param left any
---@param right any
---@return string
local function JoinTooltipLine(left, right)
	left = PlainText(left) or ""
	right = PlainText(right)
	if right and right ~= "" then
		return left .. " >> " .. right
	end
	return left
end

---@param kind string
---@param identifier number
---@return string[]
local function ReadTooltipData(kind, identifier)
	local lines = {}
	local data = TOOLTIP_DATA_GETTERS[kind](identifier)
	for _, line in ipairs(data and data.lines or {}) do
		lines[#lines + 1] = JoinTooltipLine(line.leftText, line.rightText)
	end
	return lines
end

---@param kind string
---@param identifier number
---@return string[]
local function ReadScanTooltip(kind, identifier)
	local tooltip = PrepareScanTooltip()
	tooltip:SetHyperlink(kind .. ":" .. identifier)
	local lines = {}
	for lineIndex = 1, tooltip:NumLines() do
		local left = _G[SCAN_TOOLTIP_NAME .. "TextLeft" .. lineIndex]
		local right = _G[SCAN_TOOLTIP_NAME .. "TextRight" .. lineIndex]
		lines[#lines + 1] = JoinTooltipLine(left and left:GetText(), right and right:IsShown() and right:GetText())
	end
	tooltip:Hide()
	return lines
end

ns.GetTooltipLines = TOOLTIP_DATA_GETTERS and ReadTooltipData or ReadScanTooltip

-- Read from the whole link, not the id, so a random suffix ("of the Owl") shows the stats it rolled.
---@param itemLink string
---@return string[]
function ns.GetItemLinkTooltipLines(itemLink)
	local lines = {}
	if C_TooltipInfo and C_TooltipInfo.GetHyperlink then
		local data = C_TooltipInfo.GetHyperlink(itemLink)
		for _, line in ipairs(data and data.lines or {}) do
			lines[#lines + 1] = PlainText(line.leftText) or ""
		end
		return lines
	end
	local tooltip = PrepareScanTooltip()
	tooltip:SetHyperlink(itemLink)
	for lineIndex = 1, tooltip:NumLines() do
		local left = _G[SCAN_TOOLTIP_NAME .. "TextLeft" .. lineIndex]
		lines[#lines + 1] = PlainText(left and left:GetText()) or ""
	end
	tooltip:Hide()
	return lines
end

--------------------------------------------------------------------------------
-- Reading the Trade Clock
--------------------------------------------------------------------------------

-- nil when the tooltip has no trade clock: not Bind on Pickup, already Soulbound, or never tradable.
---@param bagIndex number
---@param slotIndex number
---@return number|nil
function ns.GetBagSlotTradeSeconds(bagIndex, slotIndex)
	for _, line in ipairs(ns.GetBagItemTooltipLines(bagIndex, slotIndex)) do
		local seconds = ns.ParseTradeTimeLine(line)
		if seconds then
			return seconds
		end
	end
	return nil
end
