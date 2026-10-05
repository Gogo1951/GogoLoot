--------------------------------------------------------------------------------
-- GogoLoot Options — Item List Filter
--------------------------------------------------------------------------------

--[[
    How every item list is grouped and narrowed: the item kind sections, the
    New section, the filter text and the kind filter. All of it is kept per
    list for the session and never saved.
]]
local _, ns = ...
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--------------------------------------------------------------------------------
-- Item Kind Sections
--------------------------------------------------------------------------------

--[[
    Every item list groups its rows under headers naming the kind of item: the
    class the client files it under, such as Miscellaneous, Container or
    Quest, and not the subclass under it, which adds a word that rarely helps
    (almost every container files under Junk) and splits a few rows into
    headers of their own. The client names the class in the player's language,
    so the headers need no translating.

    One correction: an item the game binds as a quest item, whose tooltip reads
    "Quest Item", sits under Quest whatever its class, as Soft-shelled Clam
    (class Key) does. The bind comes from C_Item.GetItemInfo, so until the item
    loads it sits under its class and moves on the repaint that follows.

    The client knows an item's class without asking the server, so a row sits
    under its header even while its name is still loading. A row whose class
    the client can't give sits above the first header, under none.
]]

---@param itemIdentifier number
---@return string # "" when the client can't say
local function GetItemKindHeading(itemIdentifier)
	local _, itemKind, _, _, _, classIdentifier = C_Item.GetItemInfoInstant(itemIdentifier)
	if
		classIdentifier ~= ns.ITEM_CLASS_QUEST
		and select(14, C_Item.GetItemInfo(itemIdentifier)) == ns.BIND_QUEST_ITEM
	then
		return C_Item.GetItemClassInfo(ns.ITEM_CLASS_QUEST) or itemKind or ""
	end
	return itemKind or ""
end

--[[
    Splits a list already sorted by name into its sections, headers A to Z, each
    keeping the name order. The untyped rows' "" sorts ahead of every header.
]]
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
    New: what the player just added, gathered under a header of its own at
    the top of its list, newest first, so a row added by ID or from the bags
    doesn't land somewhere down a list hundreds of rows long. It lasts until
    the player filters that list, by text or by kind, or closes the Options
    window (ns.ForgetNewListItems), and the rows then go back under their
    kinds. Kept per list for the session and never saved.
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
    Every list the shared builder draws carries a filter above its rows: a
    magnifying glass and a box that narrows the rows to the items whose name,
    item ID, setting, or tag contains what the player types, case-insensitively.
    The text is kept per list for the session and never saved.

    Typing redraws the panel, and a redraw replaces every widget on it, the box
    included, which would take the keyboard away mid-word. So the redraw waits
    until typing pauses (FILTER_REFRESH_DELAY), and a box that loses the
    keyboard to a redraw hands it, cursor and all, to the box the redraw builds
    for the same list. The handover also covers a redraw somebody else asked
    for, such as the item cache filling in names while the player types.
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
		AceConfigRegistry:NotifyChange(registryName)
		return
	end
	ns:After(timerName, FILTER_REFRESH_DELAY, function()
		AceConfigRegistry:NotifyChange(registryName)
	end)
end
ns.SetItemListFilter = SetListFilter

--[[
    Case-folds text for a filter match. string.lower knows ASCII only, so a
    Russian or German player typing in lower case would miss a name that starts
    with a capital. The two-byte UTF-8 capitals of the client's Latin and
    Cyrillic locales are folded here too: Latin-1 À to Þ (not ×, which has no
    lower case), Cyrillic А to Я, and Ё. Korean and Chinese have no case.
]]
---@param text string
---@return string
function ns.FoldCase(text)
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

-- The list's filter, trimmed and case-folded, ready to find in a row; "" matches every row.
---@param registryName string
---@return string
local function GetFilterNeedle(registryName)
	local text = listFilters[registryName] or ""
	return ns.FoldCase((string.gsub(string.gsub(text, "^%s+", ""), "%s+$", "")))
end

--[[
    Beside the filter, every list carries a kind filter: a dropdown reading
    Show All Kinds of Items, which says it is a filter, then each header the
    list carries (see Item Kind Sections), in the same A to Z order. Picking a kind shows only its section.
    Kept per list for the session and never saved, like the filter text, by the
    header's text. A kind that leaves the list, its last row removed or
    restored away, puts the list back on Show All Kinds of Items, so an item of that kind
    added later doesn't narrow the list again unasked.
]]
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
	if itemName ~= "" and string.find(ns.FoldCase(itemName), needle, 1, true) then
		return true
	end
	if tag ~= nil and string.find(ns.FoldCase(tag), needle, 1, true) then
		return true
	end
	return settingLabel ~= nil and string.find(ns.FoldCase(settingLabel), needle, 1, true) ~= nil
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
