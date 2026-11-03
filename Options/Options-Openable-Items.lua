--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Opening: Openables List
--------------------------------------------------------------------------------

--[[
    A child panel of Automated Opening: every item this client's data lists as
    openable, less any the player removed, plus any they added, each with what
    Automated Opening does with it, Open or Ignore, and the reason its default
    carries as a tag (Locked, Sell Sealed, May Hold Unique). Restore Defaults
    puts the list back to the data's. Not hidden behind the Automated Opening
    switch, which would leave a child panel opening onto a blank page, and
    Ignore still matters to Speedy Loot with opening off; a line says so while
    the switch is off.

    Enable Ignore Notifications sits above the list and never hides, since
    Speedy Loot's notice prints with opening off too (maintainer, 2026-11-03).
    Its example follows the opening switch: the opening notice while it is on,
    Speedy Loot's left-in-the-window notice while it is off.

    The shape, order and widths come from ns:BuildItemListOptions; rows for
    items this client doesn't have are left out there.
]]
local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

--[[
    An item this client has that still can't join the list is gear or a bag,
    which using would equip rather than open, so the player is told why no row
    appeared. An ID the client doesn't have gets no row on any list, silently.
]]
---@param itemIdentifier number
local function AddItem(itemIdentifier)
	if ns:AddOpeningItem(itemIdentifier) or not C_Item.DoesItemExistByID(itemIdentifier) then
		return
	end
	local _, itemLink = C_Item.GetItemInfo(itemIdentifier)
	ns:PrintMessage(L["MESSAGE_ITEM_NOT_OPENABLE"]:format(itemLink or tostring(itemIdentifier)))
end

local function AutomatedOpeningOn()
	return ns.db.profile.autoOpen
end

--[[
    What Enable Ignore Notifications prints, drawn by ns.OptionsExampleRow
    (Message Examples in Options-Utilities.lua), run through its real template
    and drawn as printed. The container is the lowest item ID this flavor's
    data sets to plain Ignore, the default that notice is for, so every client
    shows a real one of its own.
]]
local exampleContainer = nil

-- Also warmed at login with the other example items (ns:WarmItemCache).
---@return number|nil
function ns.ExampleIgnoredContainer()
	if not exampleContainer then
		for itemIdentifier, default in pairs(ns.OPENABLE_ITEMS) do
			if default == ns.OPENING_IGNORE and (not exampleContainer or itemIdentifier < exampleContainer) then
				exampleContainer = itemIdentifier
			end
		end
	end
	return exampleContainer
end

--[[
    The lockbox Enable Lockbox Notifications' example names (Options-Lockboxes.lua),
    picked the same way: the lowest item ID this flavor's data sets to open once
    it is unlocked.
]]
local exampleLockedContainer = nil

-- Also warmed at login with the other example items (ns:WarmItemCache).
---@return number|nil
function ns.ExampleLockedContainer()
	if not exampleLockedContainer then
		for itemIdentifier, default in pairs(ns.OPENABLE_ITEMS) do
			if
				default == ns.OPENING_UNLOCKED
				and (not exampleLockedContainer or itemIdentifier < exampleLockedContainer)
			then
				exampleLockedContainer = itemIdentifier
			end
		end
	end
	return exampleLockedContainer
end

local function IgnoreNotificationExample()
	local item = ns.OptionsExampleLink(ns.ExampleIgnoredContainer() or ns.SAMPLE_ITEM_IDS[2])
	local template = AutomatedOpeningOn() and "MESSAGE_ITEM_IGNORED" or "MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"
	return ns.OptionsPrintedLine(L[template]:format(item))
end

---@return table
function ns.BuildOpenableItemsOptions()
	local listArgs = ns:BuildItemListOptions({
		getSourceTable = function()
			return ns:GetOpenableItemList()
		end,
		onRestore = function()
			ns:RestoreDefaultOpeningActions()
		end,
		onAdd = AddItem,
		canAdd = function(itemIdentifier)
			return ns:CanAddOpeningItem(itemIdentifier)
		end,
		onRemove = function(itemIdentifier)
			ns:RemoveOpeningItem(itemIdentifier)
		end,
		notifyKey = ns.OPTIONS_REGISTRY.OpenableItems,
		labels = {
			restoreDesc = L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"],
			restoreConfirm = L["OPENABLE_ITEMS_RESTORE_CONFIRM"],
			addDesc = L["OPENABLE_ITEMS_ADD_DESCRIPTION"],
			addName = L["ITEM_LIST_ADD"],
			addFromBagsDesc = L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"],
			removeDesc = L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"],
			removeConfirm = L["OPENABLE_ITEMS_REMOVE_CONFIRM"],
		},
		actionColumn = {
			desc = L["OPENABLE_ITEMS_ACTION_DESCRIPTION"],
			values = ns.OPENING_ACTION_LABELS,
			sorting = ns.OPENING_ACTION_ORDER,
			get = function(itemIdentifier)
				return ns:GetOpeningAction(itemIdentifier)
			end,
			set = function(itemIdentifier, value)
				ns:SetOpeningAction(itemIdentifier, value)
			end,
		},
		noteFor = function(itemIdentifier)
			return ns:GetOpeningNote(itemIdentifier)
		end,
		tagFor = function(itemIdentifier)
			return ns:GetOpeningTag(itemIdentifier)
		end,
	})

	local args = {
		description = ns.OptionsDesc(L["OPENABLE_ITEMS_DESCRIPTION"], 1),
		spacerAfterDesc = ns.OptionsSpacer(2),
	}
	-- Ignore still holds Speedy Loot back while Automated Opening is off, unless Speedy Loot is off too.
	local order = ns.AddFeatureOffNote(args, 3, function()
		return ns.db.global.speedyLoot and L["OPENABLE_ITEMS_OFF_NOTE"] or L["OPENABLE_ITEMS_ALL_OFF_NOTE"]
	end, AutomatedOpeningOn)
	args.ignoreNotifications = {
		type = "toggle",
		name = L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"],
		desc = L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"],
		width = "full",
		order = order,
		get = function()
			return ns.db.profile.openingIgnoreNotifications
		end,
		set = function(_, value)
			ns.db.profile.openingIgnoreNotifications = value
		end,
	}
	args.ignoreNotificationsExampleRow = ns.OptionsExampleRow(order + 1, IgnoreNotificationExample)
	args.spacerAfterIgnoreNotifications = ns.OptionsSpacer(order + 2)
	args.itemList = {
		type = "group",
		name = "",
		inline = true,
		order = order + 3,
		args = listArgs,
	}

	return {
		type = "group",
		name = L["TAB_OPENABLE_ITEMS"],
		args = args,
	}
end
