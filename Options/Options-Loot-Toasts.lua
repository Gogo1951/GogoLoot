--------------------------------------------------------------------------------
-- GogoLoot Options — Loot Toasts
--------------------------------------------------------------------------------

local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

-- Bare numbers, so no locale needs a singular or plural form of "second".
local DURATION_VALUES = {}
for _, seconds in ipairs(ns.LOOT_TOAST_DURATIONS) do
	DURATION_VALUES[seconds] = tostring(seconds)
end

-- Unlimited last, at the "more" end of the scale.
local COUNT_VALUES = { [ns.LOOT_TOAST_UNLIMITED] = L["LOOT_TOASTS_UNLIMITED"] }
local COUNT_SORTING = {}
for _, count in ipairs(ns.LOOT_TOAST_COUNTS) do
	COUNT_VALUES[count] = tostring(count)
	COUNT_SORTING[#COUNT_SORTING + 1] = count
end
COUNT_SORTING[#COUNT_SORTING + 1] = ns.LOOT_TOAST_UNLIMITED

-- Keyed by the client's own SetFont flag strings.
local FONT_FLAG_VALUES = {
	NONE = L["LOOT_TOASTS_OUTLINE_NONE"],
	OUTLINE = L["LOOT_TOASTS_OUTLINE_OUTLINE"],
	THICKOUTLINE = L["LOOT_TOASTS_OUTLINE_THICK"],
	MONOCHROME = L["LOOT_TOASTS_OUTLINE_MONOCHROME"],
	MONOCHROMEOUTLINE = L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"],
}

local function LootToastsOff()
	return not ns.db.profile.lootToasts
end

-- Every change redraws the samples, so the player sees it land.
local function SettingRow(captionKey, control, settingKey, afterSet)
	control.get = function()
		return ns.db.profile[settingKey]
	end
	control.set = function(_, value)
		ns.db.profile[settingKey] = value
		local refresh = afterSet or ns.RefreshLootToastSamples
		refresh()
		ns.RefreshSettings()
	end
	return Kit.LabelRow(0, nil, L[captionKey], control)
end

-- Includes a saved size between the steps, so it still reads back.
local function FontSizeSorting()
	local sorting = {}
	local saved = ns.db.profile.lootToastFontSize
	for _, size in ipairs(ns.LOOT_TOAST_FONT_SIZES) do
		if saved and saved < size and (#sorting == 0 or sorting[#sorting] < saved) then
			sorting[#sorting + 1] = saved
		end
		sorting[#sorting + 1] = size
	end
	if saved and saved > sorting[#sorting] then
		sorting[#sorting + 1] = saved
	end
	return sorting
end

local function FontSizeValues()
	local values = {}
	for _, size in ipairs(FontSizeSorting()) do
		values[size] = tostring(size)
	end
	return values
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildLootToastOptions()
	local args = {
		description = Kit.Desc(L["LOOT_TOASTS_PANEL_DESCRIPTION"]:format(GENERAL), 1),
		spacerAfterDesc = Kit.Spacer(2),
		lootToastsRow = Kit.ToggleRow(3, ns.FeatureSwitch("lootToasts"), {
			control = {
				type = "select",
				desc = L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"]:format(ITEM_LOOT, MONEY_LOOT, GENERAL),
				style = "dropdown",
				values = {
					[ns.STANDARD_LOOT_MESSAGES_DISABLE] = L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"],
					[ns.STANDARD_LOOT_MESSAGES_ENABLE] = L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"],
				},
				sorting = { ns.STANDARD_LOOT_MESSAGES_DISABLE, ns.STANDARD_LOOT_MESSAGES_ENABLE },
				get = Kit.Get("profile", "standardLootMessages"),
				set = function(_, value)
					ns.db.profile.standardLootMessages = value
					ns.SyncStandardLootMessages()
					ns.RefreshSettings()
				end,
			},
		}),
	}

	-- Add hides every entry with the switch, on top of its own condition, so nothing is left on a switched-off panel.
	local order = 3
	local function Add(key, entry)
		order = order + 1
		entry.order = order
		local ownHidden = entry.hidden
		if ownHidden then
			entry.hidden = function()
				return LootToastsOff() or ownHidden()
			end
		else
			entry.hidden = LootToastsOff
		end
		args[key] = entry
	end
	local function AddSpacer(key)
		Add(key, Kit.Spacer(0))
	end
	local function AddHeader(key, titleKey)
		AddSpacer("spacerBefore_" .. key)
		Add(key, Kit.Header(L[titleKey], 0))
		AddSpacer("spacerAfter_" .. key)
	end
	local function AddSettingRows(rows)
		for index, entry in ipairs(rows) do
			if index > 1 then
				AddSpacer("spacerBefore_" .. entry.key)
			end
			Add(entry.key, entry.row)
		end
	end

	AddSpacer("spacerBeforeTooltips")
	Add("tooltipsToggle", {
		type = "toggle",
		name = L["LOOT_TOASTS_TOOLTIPS_ENABLE"],
		desc = L["LOOT_TOASTS_TOOLTIPS_DESCRIPTION"],
		width = "full",
		get = Kit.Get("profile", "lootToastTooltips"),
		set = function(_, value)
			ns.db.profile.lootToastTooltips = value and true or false
			ns.ApplyLootToastTooltips()
			ns.RefreshSettings()
		end,
	})

	local blizzardRollWonSpacer = Kit.Spacer(0)
	blizzardRollWonSpacer.hidden = function()
		return not ns.HasBlizzardRollWonWindow()
	end
	Add("spacerBeforeBlizzardRollWon", blizzardRollWonSpacer)
	Add("blizzardRollWonToggle", {
		type = "toggle",
		name = L["LOOT_TOASTS_BLIZZARD_ROLL_WON_ENABLE"],
		desc = L["LOOT_TOASTS_BLIZZARD_ROLL_WON_DESCRIPTION"],
		width = "full",
		hidden = function()
			return not ns.HasBlizzardRollWonWindow()
		end,
		get = Kit.Get("profile", "lootToastBlizzardRollWon"),
		set = function(_, value)
			ns.db.profile.lootToastBlizzardRollWon = value and true or false
			ns.SyncBlizzardRollWonWindow()
			ns.RefreshSettings()
		end,
	})

	AddSpacer("spacerBeforePosition")
	Add(
		"positionRow",
		Kit.Row(0, nil, {
			Kit.Label(L["LOOT_TOASTS_POSITION"], nil, Kit.LABEL_WIDTH),
			{
				type = "execute",
				name = function()
					return ns.AreLootToastsUnlocked() and L["LOOT_TOASTS_LOCK"] or L["LOOT_TOASTS_UNLOCK"]
				end,
				desc = L["LOOT_TOASTS_LOCK_DESCRIPTION"],
				width = Kit.CONTROL_WIDTH,
				func = function()
					-- Locking from here counts as having met the handle, as right-clicking it does.
					if ns.AreLootToastsUnlocked() then
						ns.DismissLootToastIntro()
					end
					ns.SetLootToastsUnlocked(not ns.AreLootToastsUnlocked())
				end,
			},
		})
	)
	Add(
		"resetPositionRow",
		Kit.ResetRow(0, nil, L["LOOT_TOASTS_RESET"], L["LOOT_TOASTS_RESET_DESCRIPTION"], function()
			local saved = ns.db.global.lootToastPosition
			return not (saved and saved.point)
		end, ns.ResetLootToastPosition, L["LOOT_TOASTS_RESET_CONFIRM"])
	)

	AddHeader("stackHeader", "LOOT_TOASTS_STACK_HEADER")
	AddSettingRows({
		{
			key = "maxItemsRow",
			row = SettingRow("LOOT_TOASTS_MAX_ITEMS", {
				type = "select",
				desc = L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"],
				values = COUNT_VALUES,
				sorting = COUNT_SORTING,
			}, "lootToastMaxVisible", ns.ApplyLootToastLimit),
		},
		{
			key = "durationRow",
			row = SettingRow("LOOT_TOASTS_DURATION", {
				type = "select",
				desc = L["LOOT_TOASTS_DURATION_DESCRIPTION"],
				values = DURATION_VALUES,
				sorting = ns.LOOT_TOAST_DURATIONS,
			}, "lootToastDuration"),
		},
		{
			key = "growthRow",
			row = SettingRow("LOOT_TOASTS_GROWTH", {
				type = "select",
				desc = L["LOOT_TOASTS_GROWTH_DESCRIPTION"],
				values = { UP = L["LOOT_TOASTS_GROW_UP"], DOWN = L["LOOT_TOASTS_GROW_DOWN"] },
				sorting = { "UP", "DOWN" },
			}, "lootToastGrowth"),
		},
		{
			key = "alignRow",
			row = SettingRow("LOOT_TOASTS_ALIGN_TOASTS", {
				type = "select",
				desc = L["LOOT_TOASTS_ALIGN_TOASTS_DESCRIPTION"],
				values = { LEFT = L["LOOT_TOASTS_ALIGN_LEFT"], RIGHT = L["LOOT_TOASTS_ALIGN_RIGHT"] },
				sorting = { "LEFT", "RIGHT" },
			}, "lootToastAlign"),
		},
	})

	AddHeader("textHeader", "LOOT_TOASTS_TEXT_HEADER")
	AddSettingRows({
		{
			key = "fontRow",
			row = SettingRow("LOOT_TOASTS_FONT", {
				type = "select",
				desc = L["LOOT_TOASTS_FONT_DESCRIPTION"],
				-- Functions, not tables: LibSharedMedia's list grows as other add-ons register faces.
				values = function()
					return (ns.GetLootToastFontChoices())
				end,
				sorting = function()
					local _, sorting = ns.GetLootToastFontChoices()
					return sorting
				end,
			}, "lootToastFont"),
		},
		{
			key = "fontSizeRow",
			row = SettingRow("LOOT_TOASTS_FONT_SIZE", {
				type = "select",
				desc = L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"],
				values = FontSizeValues,
				sorting = FontSizeSorting,
			}, "lootToastFontSize"),
		},
		{
			key = "outlineRow",
			row = SettingRow("LOOT_TOASTS_OUTLINE", {
				type = "select",
				desc = L["LOOT_TOASTS_OUTLINE_DESCRIPTION"],
				values = FONT_FLAG_VALUES,
				sorting = ns.LOOT_TOAST_FONT_FLAGS,
			}, "lootToastFontFlags"),
		},
	})

	return {
		type = "group",
		name = L["TAB_LOOT_TOASTS"],
		args = args,
	}
end
