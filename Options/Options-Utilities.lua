--------------------------------------------------------------------------------
-- GogoLoot Options — Utilities
--------------------------------------------------------------------------------

--[[
    Shared infrastructure consumed by every Options panel: the AceConfig
    widget helper constructors, item-cache warming for the item lists,
    item-input parsing and item-name sorting, the shared item list builder,
    the item display helper, and the GogoLoot_ItemLink AceGUI widget.
]]
local _, ns = ...
local L = ns.L
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- AceConfig Widget Helpers
--------------------------------------------------------------------------------

--[[
    Shared by all Options-*.lua files. Defined with `.` (not `:`) — they
    don't use self, and dot definitions force dot invocation, matching the
    panel builder functions.
]]

---@param text string|function
---@param order number
---@param hidden? boolean|function
---@return table
function ns.OptionsHeader(text, order, hidden)
	return {
		type = "header",
		name = GetColor("TITLE") .. text .. "|r",
		order = order,
		hidden = hidden,
	}
end

---@param text string|function
---@param order number
---@return table
function ns.OptionsDesc(text, order)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		order = order,
	}
end

---@param order number
---@return table
function ns.OptionsSpacer(order)
	return {
		type = "description",
		name = " ",
		order = order,
	}
end

--[[
    The left half of a label-beside-control row. Pair it with a control whose
    own `name` is "" and whose width is ns.OPTIONS_CONTROL_WIDTH, ordered
    immediately after this cell, and the two flow onto one line instead of the
    control stacking under its own label.

    `text` may be a string or a function, exactly as AceConfig's `name` accepts,
    so a label that reads live state (the Master Looter panel's leader note,
    which names whoever controls the loot settings) works here unchanged.

    `width` overrides ns.OPTIONS_LABEL_WIDTH for the rare row whose control
    needs more room than the default split leaves it (the copyable URL boxes).
    Whatever it takes, give the control ns.OPTIONS_ROW_WIDTH minus that, so the
    row still ends where every other row does.
]]
---@param text string|function
---@param order number
---@param width? number
---@return table
function ns.OptionsRowLabel(text, order, width)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		width = width or ns.OPTIONS_LABEL_WIDTH,
		order = order,
	}
end

--[[
    A sub-option is a control that only means anything while the toggle above it
    is on, and it is marked two ways at once.

    The row leads with a blank indent cell, which moves the checkbox itself.
    Padding the label instead would indent only the caption — AceConfig pins a
    checkbox at the left edge of its own widget — leaving the box lined up with
    its parent's and the words drifting away from it.

    ns.OptionsSubLabel then colors the caption HELP silver against the parent's
    white, so the row reads as subordinate rather than merely shifted. Silver is
    the palette's secondary-text role and is well clear of the dimmer gray AceGUI
    paints a genuinely disabled label, so a sub-option that greys out with its
    parent still reads as disabled rather than as ordinary sub-option text.

    The whole row is wrapped in an inline group with no name, which AceConfig
    renders as a bare SimpleGroup — no border, no title, no padding — at "fill"
    width. That wrapper is load-bearing, not decoration. Laid out flat, the
    indent and its control are just two more widgets in the panel's flow, kept
    together only by their widths happening to fill the line; the pair after them
    then packs onto whatever space is left and its indent stops indenting
    anything. A fill widget always gets a line to itself, so one group per
    sub-option pins one row per sub-option no matter what the pane is doing.

    Inside the group the controls need slack rather than an exact fit: a row
    summing to the full pane width sits on the wrap boundary, where a pass that
    measures a control before its width is applied tips the control onto its own
    line and strands the indent above it.

    Hiding belongs on the group, never on the controls inside it — hiding only
    the control would leave its indent cell behind as a blank line.
]]
---@param order number
---@param hidden? boolean|function
---@param controls table[] # laid out left to right after the indent cell
---@param indentWidth? number # defaults to one step; notes pass the wider cell
---@return table
function ns.OptionsSubRow(order, hidden, controls, indentWidth)
	local args = {
		indent = {
			type = "description",
			name = " ",
			width = indentWidth or ns.OPTIONS_SUB_INDENT_WIDTH,
			order = 1,
		},
	}

	for index, control in ipairs(controls) do
		control.order = index + 1
		args["control" .. index] = control
	end

	return {
		type = "group",
		name = "",
		inline = true,
		order = order,
		hidden = hidden,
		args = args,
	}
end

---@param text string
---@return string
function ns.OptionsSubLabel(text)
	return GetColor("HELP") .. text .. "|r"
end

--[[
    The label width for an indented label-beside-control row: one label column
    minus whatever cell indents the row. An indented row still owes the panel its
    shared right edge, so it pays for the indent out of its own label rather than
    carrying the control column right with it — which is what keeps an indented
    dropdown in the same column as the un-indented one it sits beneath.

    Derived from the indent rather than pinned to a constant because rows indent
    to two different depths (ns.OPTIONS_SUB_INDENT_WIDTH for a row inside a
    sub-option's block, the caption indent for prose) and both owe the same edge.
]]
---@param indentWidth number
---@return number
function ns.OptionsSubLabelWidth(indentWidth)
	return ns.OPTIONS_LABEL_WIDTH - indentWidth
end

--------------------------------------------------------------------------------
-- Item Cache Warming
--------------------------------------------------------------------------------

--[[
    GetItemInfo returns nil for items the client hasn't cached; querying it
    triggers a server request and GET_ITEM_INFO_RECEIVED fires when the data
    arrives. A debounced NotifyChange repaints the item lists as answers
    stream in. The watcher is registered on demand — at login when a saved
    list contains uncached items, or when the user adds an uncached item ID
    — and unregisters itself once every list item has resolved, so it does
    not keep running for the rest of the session.
]]

local itemCacheRefreshTimer = nil
local itemRefreshWatcherRegistered = false
local HandleItemInformationReceived

--[[
    Queries every list entry (re-requesting uncached ones) and reports
    whether anything is still missing from the client cache.
]]
local function QueryListItemsAndFindMissing()
	local hasMissing = false
	for itemIdentifier in pairs(ns.db.profile.ignoredItemsSolo or {}) do
		if not ns.GetItemInfo(itemIdentifier) then
			hasMissing = true
		end
	end
	for itemIdentifier in pairs(ns.db.profile.ignoredItemsMaster or {}) do
		if not ns.GetItemInfo(itemIdentifier) then
			hasMissing = true
		end
	end
	return hasMissing
end

local function RefreshOptionsAfterDelay()
	if itemCacheRefreshTimer then
		return
	end
	itemCacheRefreshTimer = C_Timer.NewTimer(0.3, function()
		itemCacheRefreshTimer = nil
		AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.AutomatedRolls)
		AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.MasterLooter)
		if itemRefreshWatcherRegistered and not QueryListItemsAndFindMissing() then
			itemRefreshWatcherRegistered = false
			ns:UnregisterModuleEvent("GET_ITEM_INFO_RECEIVED", HandleItemInformationReceived)
		end
	end)
end

HandleItemInformationReceived = function()
	RefreshOptionsAfterDelay()
end

local function EnsureItemRefreshWatcher()
	if itemRefreshWatcherRegistered then
		return
	end
	itemRefreshWatcherRegistered = true
	ns:RegisterModuleEvent("GET_ITEM_INFO_RECEIVED", HandleItemInformationReceived)
end

---@return nil
function ns:WarmItemCache()
	if not QueryListItemsAndFindMissing() then
		return
	end

	C_Timer.After(1, RefreshOptionsAfterDelay)
	EnsureItemRefreshWatcher()
end

--------------------------------------------------------------------------------
-- Item Input Parsing
--------------------------------------------------------------------------------

--[[
    Accepts a numeric item ID string or a full item link; returns the numeric
    item ID or nil. Shared by the Options panels that let users add items.
]]

---@param rawInput any
---@return number|nil
function ns:ParseItemInput(rawInput)
	if not rawInput or rawInput == "" then
		return nil
	end

	local numericIdentifier = tonumber(rawInput)
	if numericIdentifier then
		return numericIdentifier
	end

	local fromLink = string.match(rawInput, "item:(%d+)")
	if fromLink then
		return tonumber(fromLink)
	end

	return nil
end

--------------------------------------------------------------------------------
-- Item Identifier Sort
--------------------------------------------------------------------------------

--[[
    Sorts in place alphabetically by name, one flat A-Z list — quality is not a
    sort key. Each row still shows its item link, so the quality colour reads at
    a glance without also driving the order.

    Items whose info hasn't been cached yet have no name to sort on, so they
    fall to the bottom rather than clustering under an empty string at the top;
    they re-sort into place as GET_ITEM_INFO_RECEIVED repaints the list.

    Equal names tie-break on item ID, which makes the comparator a total order.
    Without it the nine identically-named Punctured Voodoo Dolls in the default
    roll list compare equal, and their rows reshuffle on every repaint.
]]

---@param identifiers number[]
---@return nil
function ns:SortItemIdentifiersByName(identifiers)
	table.sort(identifiers, function(a, b)
		local infoA = ns:SafeGetItemInfo(a)
		local infoB = ns:SafeGetItemInfo(b)
		local nameA = infoA and infoA.name or ""
		local nameB = infoB and infoB.name or ""
		if nameA == "" and nameB == "" then
			return a < b
		end
		if nameA == "" then
			return false
		end
		if nameB == "" then
			return true
		end
		if nameA == nameB then
			return a < b
		end
		return nameA < nameB
	end)
end

--------------------------------------------------------------------------------
-- Shared Item List Builder
--------------------------------------------------------------------------------

--[[
    Used by both the Automated Rolls custom list and the Master Looter ignore
    list. Handles the restore button, add-item input, sort, and per-item rows
    with optional action dropdown. Pass in a spec table:

      getSourceTable: function returning the DB table to iterate
      onRestore: function that replaces the source with defaults
      onAdd: function(itemId) that adds an item to the source
      onRemove: function(itemId) that removes an item from the source
      notifyKey: AceConfigRegistry table name to NotifyChange on edits
      labels: { restore, restoreConfirm, addDesc, addName, removeDesc }
      actionColumn: optional { desc, values, sorting, get, set }; when present
        each row gets an action dropdown and the item label is narrower.
        sorting is the AceConfig display order for values (optional)
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
local REMOVE_ICON_SIZE = 16

--[[
    The item label absorbs whatever the columns to its right leave behind, so an
    item row spends the same ns.OPTIONS_ROW_WIDTH every other row does.
]]

---@param spec table
---@return table
function ns:BuildItemListOptions(spec)
	local labels = spec.labels
	local args = {}
	local order = 1

	args.restoreDefaults = {
		type = "execute",
		name = labels.restore,
		width = "double",
		order = order,
		confirm = true,
		confirmText = labels.restoreConfirm,
		func = function()
			spec.onRestore()
			AceConfigRegistry:NotifyChange(spec.notifyKey)
		end,
	}
	order = order + 1

	args.spacerAfterRestore = ns.OptionsSpacer(order)
	order = order + 1

	args.addItemDesc = ns.OptionsDesc(labels.addDesc, order)
	order = order + 1

	args.addItemLabel = ns.OptionsRowLabel(labels.addName, order)
	order = order + 1

	args.addItemInput = {
		type = "input",
		name = "",
		width = ns.OPTIONS_CONTROL_WIDTH,
		order = order,
		get = function()
			return ""
		end,
		set = function(_, value)
			local itemIdentifier = ns:ParseItemInput(value)
			if not itemIdentifier then
				return
			end
			spec.onAdd(itemIdentifier)
			--[[
                Query the item now; if it isn't cached yet, watch for the
                server's answer so the row updates from "Loading…" in place.
            ]]
			if not ns.GetItemInfo(itemIdentifier) then
				EnsureItemRefreshWatcher()
			end
			AceConfigRegistry:NotifyChange(spec.notifyKey)
		end,
	}
	order = order + 1

	args.spacerBeforeItems = ns.OptionsSpacer(order)
	order = order + 1

	local sortedIdentifiers = {}
	for itemIdentifier in pairs(spec.getSourceTable()) do
		table.insert(sortedIdentifiers, itemIdentifier)
	end
	ns:SortItemIdentifiersByName(sortedIdentifiers)

	--[[
        Building the rows above queries each item, which requests any uncached
        one from the server. Arm the refresh watcher whenever a row is still
        cold so the panel repaints as the item info streams in (rather than
        staying on "Loading..." until the window is reopened). The watcher
        self-unregisters once every list entry has resolved (see WarmItemCache).
    ]]
	for _, itemIdentifier in ipairs(sortedIdentifiers) do
		if not ns.GetItemInfo(itemIdentifier) then
			EnsureItemRefreshWatcher()
			break
		end
	end

	local hasActionColumn = spec.actionColumn ~= nil
	local labelWidth = ns.OPTIONS_ROW_WIDTH - ns.OPTIONS_REMOVE_ICON_WIDTH
	if hasActionColumn then
		labelWidth = labelWidth - ns.ROLL_ACTION_DROPDOWN_WIDTH
	end

	for _, itemIdentifier in ipairs(sortedIdentifiers) do
		local capturedId = itemIdentifier
		local rowArgs = {
			label = {
				type = "input",
				dialogControl = ns.ITEM_LINK_WIDGET_TYPE,
				name = "",
				width = labelWidth,
				order = 1,
				get = function()
					return tostring(capturedId)
				end,
				set = function() end,
			},
		}

		if hasActionColumn then
			rowArgs.action = {
				type = "select",
				name = "",
				desc = spec.actionColumn.desc,
				values = spec.actionColumn.values,
				sorting = spec.actionColumn.sorting,
				width = ns.ROLL_ACTION_DROPDOWN_WIDTH,
				order = 2,
				get = function()
					return spec.actionColumn.get(capturedId)
				end,
				set = function(_, value)
					spec.actionColumn.set(capturedId, value)
				end,
			}
		end

		rowArgs.remove = {
			type = "execute",
			name = "",
			desc = labels.removeDesc,
			image = REMOVE_ICON,
			imageWidth = REMOVE_ICON_SIZE,
			imageHeight = REMOVE_ICON_SIZE,
			width = ns.OPTIONS_REMOVE_ICON_WIDTH,
			order = 3,
			func = function()
				spec.onRemove(capturedId)
				AceConfigRegistry:NotifyChange(spec.notifyKey)
			end,
		}

		args["item_" .. capturedId] = {
			type = "group",
			name = "",
			inline = true,
			order = order,
			args = rowArgs,
		}
		order = order + 1
	end

	return args
end

--------------------------------------------------------------------------------
-- Item Display Helper
--------------------------------------------------------------------------------

--[[
    Used by the GogoLoot_ItemLink AceGUI widget (registered in the next
    section) to render the row label.
]]

---@param itemIdentifier number
---@return string
function ns:GetItemDisplayName(itemIdentifier)
	local itemName, itemLink = ns.GetItemInfo(itemIdentifier)
	local _, _, _, _, icon = ns.GetItemInfoInstant(itemIdentifier)

	if itemLink and icon then
		return "|T" .. icon .. ":16|t " .. itemLink
	elseif itemLink then
		return itemLink
	elseif icon then
		return "|T" .. icon .. ":16|t " .. GetColor("MUTED") .. string.format(L["ITEM_LOADING"], itemIdentifier) .. "|r"
	end

	return GetColor("MUTED") .. string.format(L["ITEM_LOADING"], itemIdentifier) .. "|r"
end

--------------------------------------------------------------------------------
-- Custom AceGUI Widget: GogoLoot_ItemLink
--------------------------------------------------------------------------------

--[[
    A lightweight label that shows the full item tooltip on hover. Used via
    dialogControl on the AceConfig "input" entries built by
    BuildItemListOptions; the get() function returns the item ID as a
    string, and SetText handles lookup + rendering via ns:GetItemDisplayName
    (defined above).
]]

local AceGUI = LibStub("AceGUI-3.0")
local widgetType = ns.ITEM_LINK_WIDGET_TYPE
local widgetVersion = 1

local function OnItemLinkWidgetEnter(frame)
	local self = frame.obj
	if not self.itemIdentifier then
		return
	end
	local _, itemLink = ns.GetItemInfo(self.itemIdentifier)
	if itemLink then
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(itemLink)
		GameTooltip:Show()
	end
end

local function OnItemLinkWidgetLeave(frame)
	GameTooltip:Hide()
end

local widgetMethods = {}

function widgetMethods:OnAcquire()
	self.itemIdentifier = nil
	self:SetHeight(20)
end

function widgetMethods:OnRelease()
	self.itemIdentifier = nil
end

function widgetMethods:SetText(text)
	local itemId = tonumber(text)
	if itemId then
		self.itemIdentifier = itemId
		self.label:SetText(ns:GetItemDisplayName(itemId))
	else
		self.label:SetText(text or "")
	end
end

function widgetMethods:GetText()
	return self.itemIdentifier and tostring(self.itemIdentifier) or ""
end

function widgetMethods:SetLabel(text) end
function widgetMethods:SetMaxLetters(num) end
function widgetMethods:SetDisabled(disabled) end

local function ItemLinkWidgetConstructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetHeight(20)
	frame:EnableMouse(true)
	frame:SetScript("OnEnter", OnItemLinkWidgetEnter)
	frame:SetScript("OnLeave", OnItemLinkWidgetLeave)

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	label:SetJustifyH("LEFT")
	label:SetPoint("TOPLEFT")
	label:SetPoint("BOTTOMRIGHT")

	local widget = {
		label = label,
		frame = frame,
		type = widgetType,
	}

	for method, func in pairs(widgetMethods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(widgetType, ItemLinkWidgetConstructor, widgetVersion)
