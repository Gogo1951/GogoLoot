--------------------------------------------------------------------------------
-- GogoLoot Options — Loot Master
--------------------------------------------------------------------------------

--[[
    A panel of its own after Master Looter, rather than a child of it: the
    Loot Master is for anyone holding tradable loot, and the Loot Tracker for
    every raider, not only the game's master looter.

    The switch, then four sections: how rolls are called, which rolls count,
    the trade clock, Floor Loot, and the Loot Tracker. Everything below the
    switch leaves the panel while it is off, as on Automated Opening.
]]
local _, ns = ...
local L = ns.L

local function LootMasterOff()
	return not ns.db.profile.lootMaster
end

-- The made-up player in the panel's example line.
local EXAMPLE_PLAYER = "Aero"
local EXAMPLE_ITEM_QUALITY = 4
local EXAMPLE_REPEAT_ROLL = 92

---@param numbers number[]
---@param formatKey string
---@return table values
---@return number[] sorting
local function NumberChoices(numbers, formatKey)
	local values, sorting = {}, {}
	for _, number in ipairs(numbers) do
		values[number] = L[formatKey]:format(number)
		sorting[#sorting + 1] = number
	end
	return values, sorting
end

---@param key string
---@param name string
---@param desc string
---@param order number
---@return table
local function Toggle(key, name, desc, order)
	return {
		type = "toggle",
		name = name,
		desc = desc,
		width = "full",
		order = order,
		hidden = LootMasterOff,
		get = function()
			return ns.db.profile[key]
		end,
		set = function(_, value)
			ns.db.profile[key] = value
			ns.RefreshLootWindows()
		end,
	}
end

---@param key string
---@param values table
---@param sorting number[]|string[]
---@param desc string
---@return table
local function Select(key, values, sorting, desc)
	return {
		type = "select",
		desc = desc,
		values = values,
		sorting = sorting,
		get = function()
			return ns.db.profile[key]
		end,
		set = function(_, value)
			ns.db.profile[key] = value
		end,
	}
end

local function NotCountedExample()
	return ns:BuildAnnounceMessage(
		"ROLL_CALL_NOT_COUNTED",
		ns.OptionsExampleItem(EXAMPLE_ITEM_QUALITY),
		L["ROLL_CALL_NOT_COUNTED_REPEAT"]:format(EXAMPLE_PLAYER, EXAMPLE_REPEAT_ROLL)
	) or ""
end

--------------------------------------------------------------------------------
-- Shared Switch
--------------------------------------------------------------------------------

---@return table
function ns.LootMasterSwitch()
	return {
		type = "toggle",
		name = L["LOOT_MASTER_ENABLE"],
		desc = L["LOOT_MASTER_ENABLE_DESCRIPTION"],
		get = function()
			return ns.db.profile.lootMaster
		end,
		set = function(_, value)
			ns.db.profile.lootMaster = value
			if value then
				ns:ScanTradableLoot()
			end
			ns.RefreshLootWindows()
		end,
	}
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildLootMasterOptions()
	local lengthValues, lengthSorting = NumberChoices(ns.ROLL_LENGTHS, "LOOT_MASTER_SECONDS")
	local pauseValues, pauseSorting = NumberChoices(ns.ROLL_ALL_PAUSES, "LOOT_MASTER_SECONDS")
	local warnValues, warnSorting = NumberChoices(ns.TRADE_WARN_MINUTES, "LOOT_MASTER_MINUTES")
	local keepValues, keepSorting = NumberChoices(ns.DROPS_KEEP_RAIDS, "LOOT_MASTER_KEEP_RAIDS")
	local channelValues = {
		[ns.ROLL_CHANNEL_RAID_WARNING] = RAID_WARNING,
		[ns.ROLL_CHANNEL_GROUP] = L["CHANNEL_GROUP_CHAT"],
	}
	local channelSorting = { ns.ROLL_CHANNEL_RAID_WARNING, ns.ROLL_CHANNEL_GROUP }

	local switch = ns.LootMasterSwitch()
	switch.width = "full"
	switch.order = 3

	local notCountedExample = ns.OptionsExampleRow(31, NotCountedExample)
	notCountedExample.hidden = LootMasterOff

	local tradeWarnRow = ns.OptionsToggleRow(41, {
		type = "toggle",
		name = L["LOOT_MASTER_TRADE_WARN"],
		desc = L["LOOT_MASTER_TRADE_WARN_DESCRIPTION"],
		get = function()
			return ns.db.profile.tradeWarnLow
		end,
		set = function(_, value)
			ns.db.profile.tradeWarnLow = value
		end,
	}, {
		control = Select("tradeWarnMinutes", warnValues, warnSorting, L["LOOT_MASTER_TRADE_WARN_WHEN"]),
	})
	tradeWarnRow.hidden = LootMasterOff

	return {
		type = "group",
		name = L["TAB_LOOT_MASTER"],
		args = {
			description = ns.OptionsDesc(L["LOOT_MASTER_PANEL_DESCRIPTION"], 1),
			spacerAfterDesc = ns.OptionsSpacer(2),
			lootMaster = switch,

			callingHeader = ns.OptionsHeader(L["LOOT_MASTER_CALLING_HEADER"], 10, LootMasterOff),
			rollLength = ns.OptionsSelectRow(
				11,
				LootMasterOff,
				L["LOOT_MASTER_ROLL_LENGTH"],
				Select("rollLength", lengthValues, lengthSorting, L["LOOT_MASTER_ROLL_LENGTH_DESCRIPTION"])
			),
			rollChannel = ns.OptionsSelectRow(
				12,
				LootMasterOff,
				L["LOOT_MASTER_ANNOUNCE_IN"],
				Select("rollChannel", channelValues, channelSorting, L["LOOT_MASTER_ANNOUNCE_IN_DESCRIPTION"])
			),
			rollChannelNote = {
				type = "description",
				name = ns.OptionsSubLabel(L["LOOT_MASTER_ANNOUNCE_IN_NOTE"]),
				fontSize = "medium",
				order = 13,
				hidden = LootMasterOff,
			},
			rollWarnLastSeconds = Toggle(
				"rollWarnLastSeconds",
				L["LOOT_MASTER_WARN_LAST_SECONDS"]:format(ns.ROLL_WARNING_SECONDS),
				L["LOOT_MASTER_WARN_LAST_SECONDS_DESCRIPTION"],
				14
			),
			rollStretchLate = Toggle(
				"rollStretchLate",
				L["LOOT_MASTER_STRETCH_LATE"]:format(ns.ROLL_STRETCH_SECONDS),
				L["LOOT_MASTER_STRETCH_LATE_DESCRIPTION"],
				15
			),
			rollEndWhenAllRolled = Toggle(
				"rollEndWhenAllRolled",
				L["LOOT_MASTER_END_EARLY"],
				L["LOOT_MASTER_END_EARLY_DESCRIPTION"],
				16
			),
			rollRerollTies = Toggle(
				"rollRerollTies",
				L["LOOT_MASTER_REROLL_TIES"],
				L["LOOT_MASTER_REROLL_TIES_DESCRIPTION"],
				17
			),
			rollAllPause = ns.OptionsSelectRow(
				18,
				LootMasterOff,
				L["LOOT_MASTER_ROLL_ALL_PAUSE"],
				Select("rollAllPause", pauseValues, pauseSorting, L["LOOT_MASTER_ROLL_ALL_PAUSE_DESCRIPTION"])
			),

			countingHeader = ns.OptionsHeader(L["LOOT_MASTER_COUNTING_HEADER"], 20, LootMasterOff),
			countingDescription = {
				type = "description",
				name = L["LOOT_MASTER_COUNTING_DESCRIPTION"]:format(ns.ROLL_GRACE_SECONDS),
				fontSize = "medium",
				order = 21,
				hidden = LootMasterOff,
			},
			rollAnnounceNotCounted = Toggle(
				"rollAnnounceNotCounted",
				L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED"],
				L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED_DESCRIPTION"],
				30
			),
			notCountedExample = notCountedExample,

			tradeHeader = ns.OptionsHeader(L["LOOT_MASTER_TRADE_HEADER"], 39, LootMasterOff),
			lootMasterOpenOnTradable = Toggle(
				"lootMasterOpenOnTradable",
				L["LOOT_MASTER_OPEN_ON_TRADABLE"],
				L["LOOT_MASTER_OPEN_ON_TRADABLE_DESCRIPTION"],
				40
			),
			tradeWarnRow = tradeWarnRow,
			tradeAutoFill = Toggle(
				"tradeAutoFill",
				L["LOOT_MASTER_TRADE_AUTO_FILL"],
				L["LOOT_MASTER_TRADE_AUTO_FILL_DESCRIPTION"],
				42
			),

			floorHeader = ns.OptionsHeader(L["LOOT_MASTER_FLOOR_HEADER"], 50, LootMasterOff),
			floorDescription = {
				type = "description",
				name = L["LOOT_MASTER_FLOOR_PANEL_DESCRIPTION"],
				fontSize = "medium",
				order = 51,
				hidden = LootMasterOff,
			},
			floorLootDropWhenGone = Toggle(
				"floorLootDropWhenGone",
				L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE"],
				L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE_DESCRIPTION"],
				52
			),
			floorLootClearOnLeave = Toggle(
				"floorLootClearOnLeave",
				L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE"],
				L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE_DESCRIPTION"],
				53
			),

			trackerHeader = ns.OptionsHeader(L["LOOT_TRACKER_TITLE"], 60, LootMasterOff),
			lootTrackerOpenOnRoll = Toggle(
				"lootTrackerOpenOnRoll",
				L["LOOT_TRACKER_OPEN_ON_ROLL"],
				L["LOOT_TRACKER_OPEN_ON_ROLL_DESCRIPTION"],
				61
			),
			lootTrackerAutoClose = Toggle(
				"lootTrackerAutoClose",
				L["LOOT_TRACKER_AUTO_CLOSE"],
				L["LOOT_TRACKER_AUTO_CLOSE_DESCRIPTION"],
				62
			),
			dropsKeepRaids = ns.OptionsSelectRow(
				63,
				LootMasterOff,
				L["LOOT_TRACKER_KEEP_DROPS"],
				Select("dropsKeepRaids", keepValues, keepSorting, L["LOOT_TRACKER_KEEP_DROPS_DESCRIPTION"])
			),
			spacerBeforeOpen = ns.OptionsSpacer(70, LootMasterOff),
			openRow = ns.OptionsRow(71, LootMasterOff, {
				{
					type = "execute",
					name = L["LOOT_MASTER_OPEN"],
					func = function()
						ns:ShowLootMaster()
					end,
				},
				{
					type = "execute",
					name = L["LOOT_TRACKER_OPEN"],
					func = function()
						ns:ShowLootTracker()
					end,
				},
			}),
		},
	}
end
