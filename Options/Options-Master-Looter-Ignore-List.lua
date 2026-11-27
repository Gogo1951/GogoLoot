--------------------------------------------------------------------------------
-- GogoLoot Options — Master Looter: Ignore List
--------------------------------------------------------------------------------

local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildMasterLooterIgnoreListOptions()
	local listArgs = ns:BuildItemListOptions({
		getSourceTable = function()
			return ns.db.profile.ignoredItemsMaster
		end,
		onRestore = function()
			ns.db.profile.ignoredItemsMaster = ns:BuildDefaultIgnoreListMaster()
		end,
		isDefault = function()
			return ns.ItemListsMatch(ns.db.profile.ignoredItemsMaster, ns:BuildDefaultIgnoreListMaster())
		end,
		onAdd = function(itemIdentifier)
			ns.db.profile.ignoredItemsMaster[itemIdentifier] = true
		end,
		onRemove = function(itemIdentifier)
			ns.db.profile.ignoredItemsMaster[itemIdentifier] = nil
		end,
		notifyKey = ns.OPTIONS_REGISTRY.MasterLooterIgnoreList,
		refillsWhenEmpty = true,
		labels = {
			restoreDesc = L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"],
			restoreConfirm = L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"],
			addDesc = L["ITEM_LIST_ADD_DESCRIPTION"],
			addName = L["ITEM_LIST_ADD"],
			removeDesc = L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"],
		},
	})

	local args = {
		description = Kit.Desc(L["MASTER_LOOTER_IGNORE_DESCRIPTION"], 1),
		spacerAfterDesc = Kit.Spacer(2),
	}
	local order = ns.AddFeatureOffLine(args, 3, "autoMasterLoot")
	args.ignoreList = {
		type = "group",
		name = "",
		inline = true,
		order = order,
		args = listArgs,
	}

	return {
		type = "group",
		name = L["TAB_IGNORE_LIST"],
		args = args,
	}
end
