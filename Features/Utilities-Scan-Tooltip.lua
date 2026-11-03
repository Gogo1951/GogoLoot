--------------------------------------------------------------------------------
-- GogoLoot Utilities — Scan Tooltip
--------------------------------------------------------------------------------
local _, ns = ...

--------------------------------------------------------------------------------
-- Scan Tooltip
--------------------------------------------------------------------------------

--[[
    One hidden tooltip answers every question only a tooltip can: whether a bag
    slot's container is still locked (Automated Opening, the mini-map's Locked
    Items, Diagnostics' Locked Boxes), whether an item starts a quest (Loot
    Toasts), and an item's or spell's lines for Validate Data where the client
    has no C_TooltipInfo. Made on first use, since a session may never ask.

    THE OWNER IS SET ON EVERY CALL, not once, and that is load-bearing: hiding a
    tooltip drops its owner, and an unowned tooltip takes a SetBagItem without
    complaint and populates NOTHING, so every box would read as unlocked.
    Setting a tooltip also shows it, hence the Hide after every read: shown and
    hidden inside a single frame, it never renders.

    A GameTooltipTemplate tooltip's lines are only reachable through the frame's
    name.
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

--[[
    Matched against the WHOLE line, never as a substring: LOCKED is a short word,
    and other add-ons write lines that contain it without meaning it.
]]
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

--[[
    Whether a bag slot's container still waits on a lock. The second return is
    the tooltip's line count, for Diagnostics' Locked Boxes probe: zero lines
    means the tooltip read nothing, which also answers "not locked", and is the
    failure to look for on a client whose tooltips build differently.
]]
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

--[[
    A bag slot's tooltip as its left lines, color escapes left in, for the Loot
    Master's trade clock: the game says how long an item can still be traded
    nowhere else.
]]
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
    "Does this item begin a quest", which the client says in a tooltip and
    nowhere else: no API on any target client flags it, and the item's class does
    not give it away either, since quest starters are ordinary weapons, armor and
    trinkets as often as they are class 12. Read by hyperlink, because this is
    asked of loot, which may never reach the bags at all.

    The scan is the most expensive question Loot Toasts asks, so it is also the
    last one asked, and its answer is kept for the session: it never changes
    for an item. Only an item the client has loaded is kept, since a cold
    item's tooltip doesn't have the line yet and would read as "no".
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

--[[
    An item's or spell's tooltip as plain lines, for Validate Data, a right-hand
    column kept after " >> ". kind is "item" or "spell". C_TooltipInfo hands the
    lines over as data where the client ships both its GetItemByID and
    GetSpellByID getters (WoW Forever); elsewhere they are read off the scan
    tooltip. Color escapes are stripped so each line reads as its words. A read
    can throw on an odd id, so callers protect it.
]]
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

--[[
    An item's tooltip read from its whole link rather than its id, so a random
    suffix ("of the Owl") shows the stats it rolled, for Character Rules. Left
    lines only, color escapes stripped. C_TooltipInfo.GetHyperlink where the
    client has it (WoW Forever); the scan tooltip elsewhere.
]]
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
