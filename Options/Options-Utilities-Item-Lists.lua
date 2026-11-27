--------------------------------------------------------------------------------
-- GogoLoot Options — Item Lists
--------------------------------------------------------------------------------

-- The builder behind Item Overrides, the Master Looter Ignore List and the Openables List.
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Item Names
--------------------------------------------------------------------------------

--[[
    Reading an uncached name asks the server, and the list repaints often, so
    a name is kept for the session once read and never asked for an ID not on
    the client.
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

-- The first choice Add from Bags rests on: its caption, or the bags-empty line.
local BAGS_CAPTION = "CAPTION"

-- The bags close when Options opens, so this is how to add a carried item without dragging it in.
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
    ns:BuildItemListOptions spec:
      getSourceTable()   the table whose keys are the item IDs
      onRestore()        puts the list back to its defaults
      isDefault()        optional; Restore Defaults is gray while true
      onAdd(id)          optional; without it there is no add line
      canAdd(id)         optional; Add from Bags offers only these
      onRemove(id)       optional; without it there is no remove column
      notifyKey          registry name; keys the filter, New and the item watch
      startOrder         optional first order, so a page can seat its own head
      rowWidth           optional; Kit.TREE_ROW_WIDTH in a tree pane
      labels             { restoreDesc, restoreConfirm, addDesc, addName,
                           addFromBagsDesc, removeDesc, removeConfirm }
      actionColumn       optional { desc, values, sorting, get, set, width };
                         removing a row then confirms, as it has a setting
      tagFor(id)         optional short reason or nil; the filter matches it
      refillsWhenEmpty   optional; RebuildEmptyItemLists refills it at login

    An ID not on the client gets no row and no request; the saved list keeps it.
]]

--[[
    An icon, not a Button: Button insets its caption 15px a side, clipping it
    in a column this narrow. `name` stays empty; the label rides in `desc`.
]]
local REMOVE_ICON = "Interface/Buttons/UI-GroupLoot-Pass-Up"
ns.ITEM_LIST_REMOVE_ICON = REMOVE_ICON
local REMOVE_ICON_SIZE = 16

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

-- Each line is a bare inline group, which pins it to its line.
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

-- The kind filter's choices are read before this, so they still name every kind on the list.
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
    New skips both filters, or an add could land out of sight. The first header
    needs no space above it, having spacerBeforeItems.
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
	-- Kit.SortItems' order from the names in hand, so the comparator never queries.
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

	for _, itemIdentifier in ipairs(sortedIdentifiers) do
		if ns.IsItemOutstanding(itemIdentifier) then
			ns.EnsureItemRefreshWatcher()
			break
		end
	end

	local kindLabels, kindOrder = { [ns.ITEM_LIST_ALL_KINDS] = L["ITEM_LIST_KIND_ALL"] }, { ns.ITEM_LIST_ALL_KINDS }
	for _, section in ipairs(sections) do
		if section.heading ~= "" then
			kindLabels[section.heading] = section.heading
			kindOrder[#kindOrder + 1] = section.heading
		end
	end
	-- A picked kind that left the list is forgotten, so a later item of that kind doesn't narrow it again unasked.
	if not kindLabels[ns.GetItemListKind(spec.notifyKey)] then
		ns.SetItemListKind(spec.notifyKey, nil)
	end
	local chosenKind = ns.GetItemListKind(spec.notifyKey) or ns.ITEM_LIST_ALL_KINDS

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

	-- At the foot, caption-wide: a reset used once in a while shouldn't be the biggest button at the top.
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
			disabled = spec.isDefault,
			func = function()
				spec.onRestore()
				ns.RefreshSettings()
			end,
		},
	})

	return args
end
