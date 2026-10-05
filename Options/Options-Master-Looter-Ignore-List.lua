--------------------------------------------------------------------------------
-- GogoLoot Options — Master Looter: Ignore List
--------------------------------------------------------------------------------

--[[
    A child panel of Master Looter: items Automated Master Looting skips and
    leaves for the player to hand out. Not hidden behind the Master Looter
    switch, which would leave a child panel opening onto a blank page; a line
    says so while the switch is off.
]]
local _, ns = ...
local L = ns.L

local function AutomatedMasterLootingOn()
	return ns.db.profile.autoMasterLoot
end

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
		onAdd = function(itemIdentifier)
			ns.db.profile.ignoredItemsMaster[itemIdentifier] = true
		end,
		onRemove = function(itemIdentifier)
			ns.db.profile.ignoredItemsMaster[itemIdentifier] = nil
		end,
		notifyKey = ns.OPTIONS_REGISTRY.MasterLooterIgnoreList,
		labels = {
			restoreDesc = L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"],
			restoreConfirm = L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"],
			addDesc = L["ITEM_LIST_ADD_DESCRIPTION"],
			addName = L["ITEM_LIST_ADD"],
			removeDesc = L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"],
		},
	})

	local args = {
		description = ns.OptionsDesc(L["MASTER_LOOTER_IGNORE_DESCRIPTION"], 1),
		spacerAfterDesc = ns.OptionsSpacer(2),
	}
	local order = ns.AddFeatureOffNote(args, 3, L["MASTER_LOOTER_OFF_NOTE"], AutomatedMasterLootingOn)
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
