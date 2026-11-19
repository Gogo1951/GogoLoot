--------------------------------------------------------------------------------
-- GogoLoot Options — Utilities
--------------------------------------------------------------------------------

--[[
    What every Options panel shares beyond the Options-Kit (Options-Kit.lua,
    loaded first, the rows, lines, Examples, One Refresh and panel
    registration): ns.FEATURES, the feature-off status line, quality choices,
    and the sample players and items the Examples use. The watch that closes a
    dropdown scrolled out of view is Options-Utilities-Dropdown-Watch.lua. The
    item lists are built in
    Options-Utilities-Item-Lists.lua, over Options-Utilities-Item-Cache.lua and
    Options-Utilities-Item-List-Filter.lua.
]]
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

-- Every string the kit draws, in this client's language (Options-Kit.md → Strings).
Kit.SetText({
	example = L["SAMPLE_EXAMPLE"],
	loading = L["LOADING_ITEM"],
	inCombat = L["CHAT_OPTIONS_IN_COMBAT"],
	soundPreview = L["OPTIONS_SOUND_PREVIEW_DESCRIPTION"],
	reset = L["OPTIONS_RESET"],
})

--------------------------------------------------------------------------------
-- List and Filter Widths
--------------------------------------------------------------------------------

--[[
    The widths GogoLoot's own pieces take from the kit's grid, so they load
    after it.

    An item list's add box and its filter each take a line above the rows, in
    the label column: the add box first, sharing its line with Add from Bags in
    the control column, then the filter, sharing its line with the kind filter.
    The one width for both boxes stacks them in one column and keeps either from
    reading as the more important.
]]
ns.OPTIONS_ITEM_LIST_TOOL_WIDTH = Kit.LABEL_WIDTH

-- The Loot Toasts Filters grid's Mine and Group columns, and a rarity row's quality dropdown inside one.
ns.OPTIONS_FILTER_COLUMN_WIDTH = (Kit.ROW_WIDTH - ns.OPTIONS_FILTER_LABEL_WIDTH) / 2
ns.OPTIONS_FILTER_QUALITY_WIDTH = ns.OPTIONS_FILTER_COLUMN_WIDTH - ns.OPTIONS_FILTER_BOX_WIDTH

--------------------------------------------------------------------------------
-- Features
--------------------------------------------------------------------------------

--[[
    Every feature's switch, in the mini-map menu's order: its blocks first
    (Automated Rolls, Automated Opening, Loot Announcements), then More
    Features. The root panel's Features section, each feature panel's Enable
    switch and the mini-map menu all build from these records (Options-Kit.md →
    Features), so the three can never drift. apply writes the value and its
    side effects; ns.RefreshSettings() follows every write.

    descArgs is GogoLoot's own: the values a description's %s slots take,
    read as the switch is drawn, since three name the game's own settings.
]]
ns.FEATURES = {
	{
		store = "profile",
		setting = "autoGreed",
		name = "TAB_AUTOMATED_ROLLS",
		caption = "ROLLS_ENABLE",
		desc = "ROLLS_ENABLE_DESCRIPTION",
		block = true,
		click = "LeftButton",
	},
	{
		store = "profile",
		setting = "autoOpen",
		name = "TAB_AUTOMATED_OPENING",
		caption = "AUTOMATED_OPENING_ENABLE",
		desc = "AUTOMATED_OPENING_SWITCH_DESCRIPTION",
		descArgs = function()
			return AUTO_LOOT_DEFAULT_TEXT
		end,
		block = true,
		click = "RightButton",
		apply = function(value)
			ns.db.profile.autoOpen = value
			if value then
				ns.EnsureAutoLoot()
			end
			ns.ScheduleOpeningScan(true)
		end,
	},
	{
		store = "profile",
		setting = "lootNotifications",
		name = "TAB_ANNOUNCEMENTS",
		caption = "ANNOUNCEMENTS_ENABLE",
		desc = "ANNOUNCEMENTS_ENABLE_DESCRIPTION",
		block = true,
		click = "ShiftLeftButton",
		apply = function(value)
			ns.db.profile.lootNotifications = value
			-- The trade window's checkbox and the pop-up's destination toggle leave and return with it.
			ns:SyncTradeCheckbox()
		end,
	},
	{
		store = "global",
		setting = "speedyLoot",
		name = "TAB_SPEEDY_LOOT",
		caption = "SPEEDY_LOOT_ENABLE",
		desc = "SPEEDY_LOOT_SWITCH_DESCRIPTION",
		descArgs = function()
			return AUTO_LOOT_DEFAULT_TEXT, MASTER_LOOTER
		end,
		apply = function(value)
			ns.db.global.speedyLoot = value
			if value then
				ns.EnsureAutoLoot()
			end
		end,
	},
	{
		store = "profile",
		setting = "lootToasts",
		name = "TAB_LOOT_TOASTS",
		caption = "LOOT_TOASTS_ENABLE",
		desc = "LOOT_TOASTS_SWITCH_DESCRIPTION",
		apply = function(value)
			ns.SetLootToastsEnabled(value)
		end,
	},
	{
		store = "profile",
		setting = "lootSoundsEnabled",
		name = "TAB_LOOT_SOUNDS",
		caption = "LOOT_SOUNDS_SWITCH",
		desc = "LOOT_SOUNDS_SWITCH_DESCRIPTION",
	},
	{
		store = "profile",
		setting = "autoMasterLoot",
		name = "TAB_MASTER_LOOTER",
		caption = "MASTER_LOOTER_AUTO_ENABLE",
		desc = "MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION",
		apply = function(value)
			ns.db.profile.autoMasterLoot = value
			if value and not ns:AreWeMasterLooter() then
				ns:PrintMessage(L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"]:format(MASTER_LOOTER))
			end
		end,
	},
	{
		store = "global",
		setting = "rollMacro",
		name = "TAB_ROLL_MACRO",
		caption = "ROLL_MACRO_ENABLE",
		desc = "ROLL_MACRO_SWITCH_DESCRIPTION",
		descArgs = function()
			return ns.ROLL_MACRO_NAME
		end,
		apply = function(value)
			ns.db.global.rollMacro = value
			ns.ApplyRollMacro()
		end,
	},
}

---@param setting string
---@return table|nil
function ns.GetFeature(setting)
	for _, feature in ipairs(ns.FEATURES) do
		if feature.setting == setting then
			return feature
		end
	end
end

-- A feature's switch description, its %s slots filled.
---@param feature table # an ns.FEATURES record
---@return string
function ns.FeatureDescription(feature)
	if feature.descArgs then
		return L[feature.desc]:format(feature.descArgs())
	end
	return L[feature.desc]
end

-- Kit.FeatureSwitch, with the description's slots filled.
---@param setting string
---@param order? number
---@param width? number|string
---@return table
function ns.FeatureSwitch(setting, order, width)
	local toggle = Kit.FeatureSwitch(setting, order, width)
	toggle.desc = ns.FeatureDescription(ns.GetFeature(setting))
	return toggle
end

--[[
    The root panel's Features section: Kit.FeatureSwitches, two to a line in
    ns.FEATURES order, with each switch's description slots filled. The kit
    lays the records out pair by pair, so the Nth record is the Nth switch.
]]
---@param order number
---@return table
function ns.FeatureSwitches(order)
	local group = Kit.FeatureSwitches(order)
	for index, feature in ipairs(ns.FEATURES) do
		local pair = group.args["pair" .. math.ceil(index / 2)]
		local toggle = pair and pair.args["cell" .. ((index - 1) % 2 + 1)]
		if toggle then
			toggle.desc = ns.FeatureDescription(feature)
		end
	end
	return group
end

--------------------------------------------------------------------------------
-- Feature-Off Status Line
--------------------------------------------------------------------------------

--[[
    A child panel's silver line while the feature it belongs to is off, naming
    the feature in gold and the page its switch is on (Style Guide → OPTIONS
    PANEL: a sub-panel opens with a silver status line naming the switch). Its
    trailing spacer comes with it, and both leave while the feature is on. The
    panel's own settings stay, so a player can set them up first. Returns the
    next free order.
]]
---@param args table
---@param order number
---@param setting string # the parent feature's ns.FEATURES setting
---@return number
function ns.AddFeatureOffLine(args, order, setting)
	local feature = ns.GetFeature(setting)
	local function FeatureOn()
		return Kit.Get(feature.store, feature.setting)()
	end
	args.featureOffNote = Kit.StatusLine(function()
		if FeatureOn() then
			return nil
		end
		local name = L[feature.name]
		return L["OPTIONS_FEATURE_OFF_STATUS"]:format(Kit.Color("TITLE", name), name)
	end, order)
	args.spacerAfterFeatureOffNote = Kit.Spacer(order + 1, FeatureOn)
	return order + 2
end

--------------------------------------------------------------------------------
-- Quality Choices
--------------------------------------------------------------------------------

--[[
    A quality dropdown's values from `lowest` up to Epic, each in the game's own
    quality color so the tiers read like the items themselves, and the order to
    show them in. `suffix` ("+") makes a threshold read as one where no caption
    says so.
]]
---@param lowest number
---@param suffix? string
---@return table values
---@return number[] sorting
function ns.OptionsQualityChoices(lowest, suffix)
	local values, sorting = {}, {}
	for quality = lowest, 4 do
		local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[quality]
		values[quality] = ns.GetQualityColor(quality) .. ns.QUALITY_DISPLAY_NAMES[qualityKey] .. (suffix or "") .. "|r"
		sorting[#sorting + 1] = quality
	end
	return values, sorting
end

--------------------------------------------------------------------------------
-- Example Samples
--------------------------------------------------------------------------------

--[[
    What the Examples fill their messages with (Kit.Example, Kit.PrintedLine,
    Kit.SentLine draw them). Everybody but "you" is from ns.SAMPLE_NAMES, and
    every item is a real link from ns.SAMPLE_ITEM_IDS or the flavor's data,
    which reads as loading until the client has it; the panel's function names
    fill it in on the next repaint.
]]

-- A roster player, in their class color, the way a printed line names a group member.
---@param classFile string
---@return string
function ns.OptionsExampleOther(classFile)
	return ns.GetClassColor(classFile) .. ns.SAMPLE_NAMES[classFile] .. "|r"
end

---@param itemIdentifier number
---@return string # the item's link, or the loading line until the client has it
function ns.OptionsExampleLink(itemIdentifier)
	local _, itemLink = C_Item.GetItemInfo(itemIdentifier)
	return itemLink or L["LOADING_ITEM"]:format(itemIdentifier)
end

-- What ns:PrintMessage prints for this text, as the player's own chat window shows it.
---@param text string
---@return string
function ns.OptionsPrintedLine(text)
	return Kit.PrintedLine(ns.BuildPrintMessage(text))
end
