--------------------------------------------------------------------------------
-- GogoLoot Options — Item Lists
--------------------------------------------------------------------------------

--[[
    The shared item list builder every list panel is built on (Item Overrides,
    the Master Looter Ignore List and the Openables List): Add from Bags, the
    rows and the builder itself; item-input parsing and item-name sorting are
    the Options-Kit's. The item
    cache lives in Options-Utilities-Item-Cache.lua, the kind sections and the
    filters in Options-Utilities-Item-List-Filter.lua, and the
    GogoLoot_ItemListFilter and GogoLoot_ItemListAdd AceGUI widgets in
    Options-Utilities-Item-List-Widgets.lua, which reaches what it shares
    through ns.SetItemListFilter, ns.ITEM_LIST_REMOVE_ICON and
    ns.MeasureCaptionPixels (Features/Utilities.lua). A row's item is the
    Options-Kit's Kit.ITEM_LINK_WIDGET.
]]
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Item Names
--------------------------------------------------------------------------------

--[[
    Typed input goes through Kit.ParseItem (a bare ID or a whole item link) and
    rows sort through Kit.SortItems (by name, uncached last, ties by ID), both
    the Options-Kit's. What stays here is the name each row is filtered by.

    Each name is read once and never for an item this client doesn't have.
    Reading an uncached item asks the server for it, and the list repaints
    often. A name the client has answered with is kept for the session, so a
    repaint only asks about the items still loading.
]]
local knownItemNames = {}

---@param identifiers number[]
---@return table # the name read for each identifier, "" where there is none yet
local function ReadItemNames(identifiers)
	local itemNames = {}
	for _, itemIdentifier in ipairs(identifiers) do
		local itemName = knownItemNames[itemIdentifier]
		if not itemName and ns.IsItemOnClient(itemIdentifier) then
			itemName = C_Item.GetItemInfo(itemIdentifier)
			if itemName and itemName ~= "" then
				knownItemNames[itemIdentifier] = itemName
			end
		end
		itemNames[itemIdentifier] = itemName or ""
	end
	return itemNames
end

--------------------------------------------------------------------------------
-- Add from Bags
--------------------------------------------------------------------------------

-- Add from Bags' own first choice, which it rests on: its caption, or the line saying the bags have nothing to add.
local BAGS_CAPTION = "CAPTION"

--[[
    Beside every list's add box, a dropdown of what the player carries that the
    list doesn't hold yet, one choice per distinct item, A to Z by name, each
    with its icon, link and how many are carried. The bags close when the
    options open, so this is the way to add an item without dragging it in.
    The list's canAdd, where it has one, leaves out what it would refuse. Read
    afresh on every repaint, so it follows the bags.
]]
---@param sourceTable table
---@param canAdd function|nil
---@return table values
---@return number[] sorting
local function GetAddableBagItems(sourceTable, canAdd)
	local counts = {}
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) do
			local itemIdentifier = ns.GetBagItemIdentifier(bagIndex, slotIndex)
			if itemIdentifier and sourceTable[itemIdentifier] == nil and (not canAdd or canAdd(itemIdentifier)) then
				local info = C_Container.GetContainerItemInfo(bagIndex, slotIndex)
				counts[itemIdentifier] = (counts[itemIdentifier] or 0) + (info and info.stackCount or 1)
			end
		end
	end
	local sorting = {}
	for itemIdentifier in pairs(counts) do
		sorting[#sorting + 1] = itemIdentifier
	end
	Kit.SortItems(sorting)
	local values = {}
	for _, itemIdentifier in ipairs(sorting) do
		local count = counts[itemIdentifier]
		values[itemIdentifier] = ns:GetItemDisplayName(itemIdentifier)
			.. (count > 1 and (" " .. L["ITEM_QUANTITY"]:format(count)) or "")
	end
	return values, sorting
end

--------------------------------------------------------------------------------
-- Shared Item List Builder
--------------------------------------------------------------------------------

--[[
    Whether two item lists hold the same items with the same values: the saved
    list against a freshly built default one, for a spec's isDefault.
]]
---@param saved table
---@param defaults table
---@return boolean
function ns.ItemListsMatch(saved, defaults)
	for itemIdentifier, value in pairs(saved) do
		if defaults[itemIdentifier] ~= value then
			return false
		end
	end
	for itemIdentifier in pairs(defaults) do
		if saved[itemIdentifier] == nil then
			return false
		end
	end
	return true
end

--[[
    Used by every item list panel. Handles the lines holding the add box, Add
    from Bags, the filter and the kind filter, sort, the item kind headers, per-item
    rows with optional action dropdown, and Restore Defaults at the foot. Pass
    in a spec table:

      getSourceTable: function returning the table whose keys are the item IDs
      onRestore: function that puts the list back to its defaults
      isDefault: optional function returning whether the list already matches
        its defaults; Restore Defaults is gray while it does (ns.ItemListsMatch
        compares a saved list against a freshly built default one)
      onAdd: optional function(itemId) that adds an item to the source; without
        it the panel has no add line (the add box and Add from Bags)
      canAdd: optional function(itemId) returning whether the list would take
        an item; Add from Bags offers only those
      onRemove: optional function(itemId) that removes an item from the source;
        without it the rows have no remove column
      notifyKey: the list's AceConfigRegistry table name, which keys its
        filter, its New section and its item watch; every edit ends in
        ns.RefreshSettings()
      startOrder: optional first order, so a page can seat its own head above
      rowWidth: optional row width, Kit.TREE_ROW_WIDTH in a tree pane
      labels: { restoreDesc, restoreConfirm, addDesc, addName, addFromBagsDesc,
        removeDesc, removeConfirm }; addName and addDesc are the title and body
        of the add box's tooltip, addFromBagsDesc Add from Bags' tooltip, which
        defaults to the shared one. Every list's restore button reads Restore
        Defaults.
      actionColumn: optional { desc, values, sorting, get, set, width }; when
        present each row gets an action dropdown, the item label is narrower,
        and removing a row confirms with labels.removeConfirm, since the row
        carries a setting of its own.
        sorting is the AceConfig display order for values (optional)
        width defaults to ns.ROLL_ACTION_DROPDOWN_WIDTH
      tagFor: optional function(itemId) returning a short reason, or nil; every
        row then gets a silver tag column before its dropdown, empty where the
        item has none, and the filter finds rows by their tag too
      refillsWhenEmpty: optional true for a list that RebuildEmptyItemLists
        (Features/Core.lua) refills at login; with no rows and no filter text,
        a silver line says so

    The rows sit under the list's filter (Options-Utilities-Item-List-Filter.lua), which every list
    gets. An ID this client doesn't have is never loaded: it gets no row and no
    request goes out for it. That includes an item WoW Forever lists but its
    server refuses (IsItemOnClient), which drops out on the repaint that follows
    the refusal. The saved list itself is left as it is.
]]

--[[
    The remove column is an icon, not a labeled button. An execute carrying an
    `image` renders as an AceGUI Icon rather than the stock Button, and Button
    insets its font string 15px from each edge — in a column this narrow that
    leaves a caption almost no room and clips it to a sliver. The Icon has no
    such inset, and the group-loot pass texture is already the game's own
    "no, get rid of this" mark.

    `name` stays empty so the Icon draws no caption under the texture; the
    label rides in `desc`, which AceConfigDialog shows on hover.
]]
local REMOVE_ICON = "Interface/Buttons/UI-GroupLoot-Pass-Up"
ns.ITEM_LIST_REMOVE_ICON = REMOVE_ICON
local REMOVE_ICON_SIZE = 16

--[[
    One item's row: the item link, the optional reason tag, the optional action
    dropdown, and the remove icon, as an inline group of its own. The item label
    absorbs whatever the columns to its right leave behind, so an item row
    spends the same Kit.ROW_WIDTH every other row does.
]]
---@param args table
---@param spec table
---@param itemIdentifier number
---@param order number
---@param widths table # { label, tag, action }
---@param tag string|nil # spec.tagFor's answer, read once by the caller
---@return nil
local function AddItemRow(args, spec, itemIdentifier, order, widths, tag)
	local labels = spec.labels
	local rowArgs = {
		label = {
			type = "input",
			dialogControl = Kit.ITEM_LINK_WIDGET,
			name = "",
			width = widths.label,
			order = 1,
			get = function()
				return tostring(itemIdentifier)
			end,
			set = function() end,
		},
	}

	-- Blank where the item has no reason, so every row's dropdown stays in one column.
	if spec.tagFor then
		rowArgs.tag = {
			type = "description",
			name = tag and (GetColor("HELP") .. tag .. "|r") or " ",
			fontSize = "medium",
			width = widths.tag,
			order = 2,
		}
	end

	if spec.actionColumn then
		rowArgs.action = {
			type = "select",
			name = "",
			desc = spec.actionColumn.desc,
			values = spec.actionColumn.values,
			sorting = spec.actionColumn.sorting,
			width = widths.action,
			order = 3,
			get = function()
				return spec.actionColumn.get(itemIdentifier)
			end,
			set = function(_, value)
				spec.actionColumn.set(itemIdentifier, value)
				ns.RefreshSettings()
			end,
		}
	end

	if spec.onRemove then
		rowArgs.remove = {
			type = "execute",
			name = "",
			desc = labels.removeDesc,
			image = REMOVE_ICON,
			imageWidth = REMOVE_ICON_SIZE,
			imageHeight = REMOVE_ICON_SIZE,
			width = Kit.REMOVE_ICON_WIDTH,
			order = 4,
			func = function()
				spec.onRemove(itemIdentifier)
				ns.RefreshSettings()
			end,
		}
		if spec.actionColumn then
			rowArgs.remove.confirm = true
			rowArgs.remove.confirmText = labels.removeConfirm
		end
	end

	args["item_" .. itemIdentifier] = {
		type = "group",
		name = "",
		inline = true,
		order = order,
		args = rowArgs,
	}
end

--[[
    The add line and the blank line after it, for a list with onAdd. The tools
    take the lines above the rows, Connoisseur's Restocker's parts: adding
    first, since it is the first thing done with a list, then a blank line,
    then finding. The add line holds the add box with its hint and its Add
    button (see GogoLoot_ItemListAdd) in the label column, and Add from Bags in
    the control column. Each line is a bare group of its own, which pins it to
    its line.
]]
---@return number # the next free order
local function AddAddRow(args, order, spec)
	local labels = spec.labels
	local function AddItem(itemIdentifier)
		-- An ID this client lacks would be saved with no row to show it or remove it.
		if not C_Item.DoesItemExistByID(itemIdentifier) then
			return
		end
		-- An item already listed keeps its setting; it only comes to the top.
		if spec.getSourceTable()[itemIdentifier] == nil then
			spec.onAdd(itemIdentifier)
		end
		if spec.getSourceTable()[itemIdentifier] ~= nil then
			ns.RememberNewListItem(spec.notifyKey, itemIdentifier)
		end
		--[[
            Query the item now; if it isn't cached yet, watch for the
            server's answer so the row updates from "Loading…" in place.
        ]]
		if ns.IsItemOutstanding(itemIdentifier) then
			ns.EnsureItemRefreshWatcher()
		end
		ns.RefreshSettings()
	end
	local bagValues, bagSorting = GetAddableBagItems(spec.getSourceTable(), spec.canAdd)
	local bagsEmpty = #bagSorting == 0
	bagValues[BAGS_CAPTION] = GetColor("HELP")
		.. (bagsEmpty and L["ITEM_LIST_BAGS_EMPTY"] or L["ITEM_LIST_ADD_FROM_BAGS"])
		.. "|r"
	table.insert(bagSorting, 1, BAGS_CAPTION)
	args.addRow = {
		type = "group",
		name = "",
		inline = true,
		order = order,
		args = {
			addItemInput = {
				type = "input",
				dialogControl = ns.ITEM_LIST_ADD_WIDGET_TYPE,
				-- The tooltip's title only: the box draws no label, its hint and its Add button say what it is.
				name = labels.addName,
				desc = labels.addDesc,
				width = ns.OPTIONS_ITEM_LIST_TOOL_WIDTH,
				order = 1,
				get = function()
					return ""
				end,
				set = function(_, value)
					local itemIdentifier = Kit.ParseItem(value)
					if itemIdentifier then
						AddItem(itemIdentifier)
					end
				end,
			},
			addFromBags = {
				type = "select",
				name = "",
				desc = bagsEmpty and L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"]
					or labels.addFromBagsDesc
					or L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"],
				values = bagValues,
				sorting = bagSorting,
				disabled = bagsEmpty,
				width = Kit.CONTROL_WIDTH,
				order = 2,
				get = function()
					return BAGS_CAPTION
				end,
				set = function(_, itemIdentifier)
					if itemIdentifier ~= BAGS_CAPTION then
						AddItem(itemIdentifier)
					end
				end,
			},
		},
	}
	args.spacerAfterAddRow = Kit.Spacer(order + 1)
	return order + 2
end

--[[
    The filter line: the filter, as wide as the add box so the two boxes stack
    in one column, and the kind filter under Add from Bags, where every panel's
    dropdowns sit.
]]
---@return number # the next free order
local function AddFilterRow(args, order, spec, kindLabels, kindOrder)
	args.filterRow = {
		type = "group",
		name = "",
		inline = true,
		order = order,
		args = {
			itemFilter = {
				type = "input",
				dialogControl = ns.ITEM_LIST_FILTER_WIDGET_TYPE,
				name = "",
				desc = L["ITEM_LIST_FILTER_DESCRIPTION"],
				width = ns.OPTIONS_ITEM_LIST_TOOL_WIDTH,
				order = 1,
				-- AceConfigDialog hands arg to the widget's SetCustomData: which list this box filters.
				arg = { registryName = spec.notifyKey },
				get = function()
					return ns.GetItemListFilter(spec.notifyKey)
				end,
				set = function(_, value)
					ns.SetItemListFilter(spec.notifyKey, value, true)
				end,
			},
			kindFilter = {
				type = "select",
				name = "",
				desc = L["ITEM_LIST_KIND_DESCRIPTION"],
				values = kindLabels,
				sorting = kindOrder,
				width = Kit.CONTROL_WIDTH,
				order = 2,
				get = function()
					return ns.GetItemListKind(spec.notifyKey) or ns.ITEM_LIST_ALL_KINDS
				end,
				set = function(_, value)
					ns.SetItemListKind(spec.notifyKey, value)
					ns.ClearNewListItems(spec.notifyKey)
					ns.RefreshSettings()
				end,
			},
		},
	}
	return order + 1
end

--[[
    The New section leads the list, its rows taken out of their kinds'
    sections, and a section it empties goes. The kind filter's choices were
    read before this, so they still name every kind on the list.
]]
---@param spec table
---@param sections table[]
---@return table[]
local function WithNewSection(spec, sections)
	local newIdentifiers = {}
	local isNew = {}
	local sourceTable = spec.getSourceTable()
	for _, itemIdentifier in ipairs(ns.GetNewListItems(spec.notifyKey)) do
		if sourceTable[itemIdentifier] ~= nil and ns.IsItemOnClient(itemIdentifier) then
			newIdentifiers[#newIdentifiers + 1] = itemIdentifier
			isNew[itemIdentifier] = true
		end
	end
	if #newIdentifiers == 0 then
		return sections
	end
	local remaining = {}
	for _, section in ipairs(sections) do
		local kept = {}
		for _, itemIdentifier in ipairs(section.identifiers) do
			if not isNew[itemIdentifier] then
				kept[#kept + 1] = itemIdentifier
			end
		end
		if #kept > 0 then
			section.identifiers = kept
			remaining[#remaining + 1] = section
		end
	end
	table.insert(remaining, 1, { heading = L["ITEM_LIST_NEW"], identifiers = newIdentifiers, isNew = true })
	return remaining
end

--[[
    Each section's header, with the space above and below it that every
    panel's headers get, then its rows (see Item Kind Sections in
    Options-Utilities-Item-List-Filter.lua). With a kind
    picked, only its section shows, beside New: what the player just added
    shows whatever the kind and the filter text say, or an add could land out
    of sight. A section the filter empties loses its header too. The first header needs no space above it, having
    spacerBeforeItems.
]]
---@return number # the next free order
---@return number # how many rows the filter left showing
local function AddSectionRows(args, order, spec, sections, itemNames, chosenKind, widths, needle)
	-- A row's setting counts toward the filter as the player reads it, so "Need" or "Ignore" finds those rows.
	local settingLabels = spec.actionColumn and spec.actionColumn.values
	if type(settingLabels) == "function" then
		settingLabels = settingLabels()
	end

	local shownRows = 0
	for sectionIndex, section in ipairs(sections) do
		local matches, tags = {}, {}
		if section.isNew or chosenKind == ns.ITEM_LIST_ALL_KINDS or section.heading == chosenKind then
			for _, itemIdentifier in ipairs(section.identifiers) do
				local settingLabel = settingLabels and settingLabels[spec.actionColumn.get(itemIdentifier)]
				local tag = spec.tagFor and spec.tagFor(itemIdentifier)
				if
					section.isNew
					or ns.ItemListRowMatchesFilter(needle, itemIdentifier, itemNames[itemIdentifier], settingLabel, tag)
				then
					matches[#matches + 1] = itemIdentifier
					tags[itemIdentifier] = tag
				end
			end
		end
		if #matches > 0 and section.heading ~= "" then
			if shownRows > 0 then
				args["spacerBeforeSection" .. sectionIndex] = Kit.Spacer(order)
				order = order + 1
			end
			args["sectionHeader" .. sectionIndex] = Kit.Header(section.heading, order)
			order = order + 1
			args["spacerAfterSectionHeader" .. sectionIndex] = Kit.Spacer(order)
			order = order + 1
		end
		for _, itemIdentifier in ipairs(matches) do
			AddItemRow(args, spec, itemIdentifier, order, widths, tags[itemIdentifier])
			order = order + 1
		end
		shownRows = shownRows + #matches
	end
	return order, shownRows
end

---@param spec table
---@return table
function ns:BuildItemListOptions(spec)
	local labels = spec.labels
	local args = {}
	local order = spec.startOrder or 1
	local rowWidth = spec.rowWidth or Kit.ROW_WIDTH

	ns.WatchItemList(spec.notifyKey, spec.getSourceTable)

	local sortedIdentifiers = {}
	for itemIdentifier in pairs(spec.getSourceTable()) do
		if ns.IsItemOnClient(itemIdentifier) then
			table.insert(sortedIdentifiers, itemIdentifier)
		end
	end
	local itemNames = ReadItemNames(sortedIdentifiers)
	-- Kit.SortItems' order (A to Z, unnamed last, ties by ID), read from the names already in hand.
	table.sort(sortedIdentifiers, function(a, b)
		local nameA, nameB = itemNames[a], itemNames[b]
		if nameA == nameB then
			return a < b
		elseif nameA == "" then
			return false
		elseif nameB == "" then
			return true
		end
		return nameA < nameB
	end)
	local sections = ns.GroupItemListByKind(sortedIdentifiers)

	--[[
        Building the rows above queries each item, which requests any uncached
        one from the server. Arm the refresh watcher whenever a row is still
        cold so the panel repaints as the item info streams in (rather than
        staying on "Loading..." until the window is reopened). The watcher
        self-unregisters once every list entry has resolved (see
        RefreshOptionsAfterDelay in Options-Utilities-Item-Cache.lua).
    ]]
	for _, itemIdentifier in ipairs(sortedIdentifiers) do
		if ns.IsItemOutstanding(itemIdentifier) then
			ns.EnsureItemRefreshWatcher()
			break
		end
	end

	-- The kind filter's choices: Show All Kinds of Items, then every header the list carries, in the list's own order.
	local kindLabels, kindOrder = { [ns.ITEM_LIST_ALL_KINDS] = L["ITEM_LIST_KIND_ALL"] }, { ns.ITEM_LIST_ALL_KINDS }
	for _, section in ipairs(sections) do
		if section.heading ~= "" then
			kindLabels[section.heading] = section.heading
			kindOrder[#kindOrder + 1] = section.heading
		end
	end
	-- A kind picked earlier that has since left the list is forgotten, which puts the list back on Show All Kinds of Items.
	if not kindLabels[ns.GetItemListKind(spec.notifyKey)] then
		ns.SetItemListKind(spec.notifyKey, nil)
	end
	local chosenKind = ns.GetItemListKind(spec.notifyKey) or ns.ITEM_LIST_ALL_KINDS

	-- A list without onAdd has no add line and no blank line.
	if spec.onAdd then
		order = AddAddRow(args, order, spec)
	end
	order = AddFilterRow(args, order, spec, kindLabels, kindOrder)

	args.spacerBeforeItems = Kit.Spacer(order)
	order = order + 1

	local widths = { action = 0, tag = 0 }
	if spec.actionColumn then
		widths.action = spec.actionColumn.width or ns.ROLL_ACTION_DROPDOWN_WIDTH
	end
	if spec.tagFor then
		widths.tag = ns.OPTIONS_ITEM_TAG_WIDTH
	end
	widths.label = rowWidth - widths.action - widths.tag
	if spec.onRemove then
		widths.label = widths.label - Kit.REMOVE_ICON_WIDTH
	end

	local needle = ns.GetItemListFilterNeedle(spec.notifyKey)
	local shownRows
	order, shownRows =
		AddSectionRows(args, order, spec, WithNewSection(spec, sections), itemNames, chosenKind, widths, needle)

	-- A picked kind always has rows of its own, so only the filter's text can leave the list empty.
	if shownRows == 0 and needle ~= "" then
		args.noFilterMatches = Kit.Desc(GetColor("HELP") .. L["ITEM_LIST_NO_MATCHES"] .. "|r", order)
		order = order + 1
	elseif #sortedIdentifiers == 0 and spec.refillsWhenEmpty then
		args.emptyListNote = Kit.Desc(GetColor("HELP") .. L["ITEM_LIST_EMPTY_REFILLS"] .. "|r", order)
		order = order + 1
	end

	--[[
        Restore Defaults closes the list, right-aligned at the width of its
        caption: the top of a list is for finding and adding, and a reset used
        once in a while shouldn't be the biggest button there. It confirms, as
        every list's own restore undoes real work.
    ]]
	args.spacerBeforeRestore = Kit.Spacer(order)
	order = order + 1
	args.restoreRow = Kit.Row(order, nil, {
		Kit.Label("", 0, rowWidth - ns.OPTIONS_RESTORE_BUTTON_WIDTH),
		{
			type = "execute",
			name = L["ITEM_LIST_RESTORE"],
			desc = labels.restoreDesc,
			width = ns.OPTIONS_RESTORE_BUTTON_WIDTH,
			confirm = true,
			confirmText = labels.restoreConfirm,
			-- Gray while the list already matches its defaults, like every Reset with nothing to reset.
			disabled = spec.isDefault,
			func = function()
				spec.onRestore()
				ns.RefreshSettings()
			end,
		},
	})

	return args
end
