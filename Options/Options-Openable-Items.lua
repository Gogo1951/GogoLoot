--------------------------------------------------------------------------------
-- GogoLoot Options — Automated Opening: Openables List
--------------------------------------------------------------------------------

-- Ignore only keeps a container sealed: Speedy Loot takes it like any other item (maintainer, 2026-11-07).
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

--[[
    An item on the client that still can't join is gear or a bag, which using
    would equip, so the player is told why no row appeared.
]]
---@param itemIdentifier number
local function AddItem(itemIdentifier)
	if ns:AddOpeningItem(itemIdentifier) or not C_Item.DoesItemExistByID(itemIdentifier) then
		return
	end
	local _, itemLink = C_Item.GetItemInfo(itemIdentifier)
	ns:PrintMessage(L["MESSAGE_ITEM_NOT_OPENABLE"]:format(itemLink or tostring(itemIdentifier)))
end

-- The lowest ID this flavor's data sets to plain Ignore, so every client shows a real one of its own.
local exampleContainer = nil

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

local function IgnoreNotificationExample()
	local item = ns.OptionsExampleLink(ns.ExampleIgnoredContainer() or ns.SAMPLE_ITEM_IDS[2])
	return ns.OptionsPrintedLine(L["MESSAGE_ITEM_IGNORED"]:format(item))
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
		isDefault = function()
			return ns:AreOpeningActionsDefault()
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
		tagFor = function(itemIdentifier)
			return ns:GetOpeningTag(itemIdentifier)
		end,
	})

	local args = {
		description = Kit.Desc(L["OPENABLE_ITEMS_DESCRIPTION"], 1),
		spacerAfterDesc = Kit.Spacer(2),
	}
	local order = ns.AddFeatureOffLine(args, 3, "autoOpen")
	args.ignoreNotifications = {
		type = "toggle",
		name = L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"],
		desc = L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"],
		width = "full",
		order = order,
		get = Kit.Get("profile", "openingIgnoreNotifications"),
		set = Kit.Set("profile", "openingIgnoreNotifications"),
	}
	-- Leaves while Automated Opening is off, when there is nothing to leave alone.
	args.ignoreNotificationsExampleRow = Kit.Example(order + 1, function()
		return not (ns.db.profile.autoOpen and ns.db.profile.openingIgnoreNotifications)
	end, IgnoreNotificationExample)
	args.spacerAfterIgnoreNotifications = Kit.Spacer(order + 2)
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
