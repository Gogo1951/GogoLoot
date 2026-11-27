--------------------------------------------------------------------------------
-- GogoLoot Options — Item List Filter
--------------------------------------------------------------------------------

-- Every item list's kind sections, New section, text and kind filters: per list, per session, never saved.
local _, ns = ...

--------------------------------------------------------------------------------
-- Item Kind Sections
--------------------------------------------------------------------------------

--[[
    Headers name the item's class, never the subclass (almost every container
    files under Junk). The class comes without a server question and in the
    player's language. A quest-bound item (Soft-shelled Clam, class Key) goes
    under Quest, but only once loaded, since the bind needs GetItemInfo; so a
    heading is cached only for a loaded item.
]]
local knownKindHeadings = {}

---@param itemIdentifier number
---@return string # "" when the client can't say
local function GetItemKindHeading(itemIdentifier)
	local knownHeading = knownKindHeadings[itemIdentifier]
	if knownHeading then
		return knownHeading
	end
	local _, itemKind, _, _, _, classIdentifier = C_Item.GetItemInfoInstant(itemIdentifier)
	local itemName, _, _, _, _, _, _, _, _, _, _, _, _, bindType = C_Item.GetItemInfo(itemIdentifier)
	local heading = itemKind or ""
	if classIdentifier ~= ns.ITEM_CLASS_QUEST and bindType == ns.BIND_QUEST_ITEM then
		heading = C_Item.GetItemClassInfo(ns.ITEM_CLASS_QUEST) or heading
	end
	if itemName and heading ~= "" then
		knownKindHeadings[itemIdentifier] = heading
	end
	return heading
end

-- Sections keep the name order; the untyped rows' "" sorts ahead of every header.
---@param sortedIdentifiers number[]
---@return table[] # { heading = string, identifiers = number[] }, in header order
local function GroupByItemKind(sortedIdentifiers)
	local sections, sectionsByHeading = {}, {}
	for _, itemIdentifier in ipairs(sortedIdentifiers) do
		local heading = GetItemKindHeading(itemIdentifier)
		local section = sectionsByHeading[heading]
		if not section then
			section = { heading = heading, identifiers = {} }
			sectionsByHeading[heading] = section
			sections[#sections + 1] = section
		end
		table.insert(section.identifiers, itemIdentifier)
	end
	table.sort(sections, function(a, b)
		return a.heading < b.heading
	end)
	return sections
end

--------------------------------------------------------------------------------
-- Item List Filter
--------------------------------------------------------------------------------

--[[
    New: just-added rows at the top, newest first, so they don't land deep in
    a long list. Ends when the list is filtered or Options closes.
]]
local newListItems = {}

---@param registryName string
---@param itemIdentifier number
local function RememberNewListItem(registryName, itemIdentifier)
	local identifiers = newListItems[registryName] or {}
	for index = #identifiers, 1, -1 do
		if identifiers[index] == itemIdentifier then
			table.remove(identifiers, index)
		end
	end
	table.insert(identifiers, 1, itemIdentifier)
	newListItems[registryName] = identifiers
end

---@return nil
function ns.ForgetNewListItems()
	wipe(newListItems)
end

--[[
    A redraw replaces every widget, the filter box included, so typing redraws
    only once it pauses; the widget hands focus to the rebuilt box.
]]
local FILTER_REFRESH_DELAY = 0.3
local FILTER_TIMER_PREFIX = "GogoLoot.ItemListFilter."

local listFilters = {}

---@param registryName string
---@param text string
---@param immediately? boolean
local function SetListFilter(registryName, text, immediately)
	listFilters[registryName] = text
	newListItems[registryName] = nil
	local timerName = FILTER_TIMER_PREFIX .. registryName
	if immediately then
		ns:CancelTimer(timerName)
		ns.RefreshSettings()
		return
	end
	ns:After(timerName, FILTER_REFRESH_DELAY, function()
		ns.RefreshSettings()
	end)
end
ns.SetItemListFilter = SetListFilter

--[[
    string.lower knows ASCII only. Also folds two-byte UTF-8 capitals: Latin-1
    À to Þ (not ×, which has no lower case), Cyrillic А to Я, and Ё.
]]
---@param text string
---@return string
local function FoldCase(text)
	local folded = string.lower(text)
	folded = string.gsub(folded, "\195([\128-\158])", function(secondByte)
		if secondByte == "\151" then
			return nil
		end
		return "\195" .. string.char(string.byte(secondByte) + 32)
	end)
	folded = string.gsub(folded, "\208([\144-\159])", function(secondByte)
		return "\208" .. string.char(string.byte(secondByte) + 32)
	end)
	folded = string.gsub(folded, "\208([\160-\175])", function(secondByte)
		return "\209" .. string.char(string.byte(secondByte) - 32)
	end)
	folded = string.gsub(folded, "\208\129", "\209\145")
	return folded
end

-- Trimmed and case-folded; "" matches every row.
---@param registryName string
---@return string
local function GetFilterNeedle(registryName)
	local text = listFilters[registryName] or ""
	return FoldCase((string.gsub(string.gsub(text, "^%s+", ""), "%s+$", "")))
end

-- Kind filter, keyed by header text, so it needs no translating.
local ALL_KINDS = "ALL"
local listKindFilters = {}

---@param needle string
---@param itemIdentifier number
---@param itemName string
---@param settingLabel string|nil # the row's dropdown value, as the player reads it
---@param tag string|nil # the row's reason tag, as the player reads it
---@return boolean
local function RowMatchesFilter(needle, itemIdentifier, itemName, settingLabel, tag)
	if needle == "" or string.find(tostring(itemIdentifier), needle, 1, true) then
		return true
	end
	if itemName ~= "" and string.find(FoldCase(itemName), needle, 1, true) then
		return true
	end
	if tag ~= nil and string.find(FoldCase(tag), needle, 1, true) then
		return true
	end
	return settingLabel ~= nil and string.find(FoldCase(settingLabel), needle, 1, true) ~= nil
end

--------------------------------------------------------------------------------
-- Builder Access
--------------------------------------------------------------------------------

ns.ITEM_LIST_ALL_KINDS = ALL_KINDS
ns.GroupItemListByKind = GroupByItemKind
ns.RememberNewListItem = RememberNewListItem
ns.ItemListRowMatchesFilter = RowMatchesFilter
ns.GetItemListFilterNeedle = GetFilterNeedle

---@param registryName string
---@return number[] # newest first; empty when the list has none
function ns.GetNewListItems(registryName)
	return newListItems[registryName] or {}
end

---@param registryName string
---@return nil
function ns.ClearNewListItems(registryName)
	newListItems[registryName] = nil
end

---@param registryName string
---@return string
function ns.GetItemListFilter(registryName)
	return listFilters[registryName] or ""
end

---@param registryName string
---@return string|nil # the kind picked, nil for every kind
function ns.GetItemListKind(registryName)
	return listKindFilters[registryName]
end

---@param registryName string
---@param kind string|nil
---@return nil
function ns.SetItemListKind(registryName, kind)
	listKindFilters[registryName] = kind
end
