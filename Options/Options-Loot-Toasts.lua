--------------------------------------------------------------------------------
-- GogoLoot Options — Loot Toasts
--------------------------------------------------------------------------------

--[[
    Everything GogoLoot shows for the loot the player and the group pick up,
    which stands in for the loot window Speedy Loot hides. What it plays lives
    on the Loot Sounds panel after it, and what it tells other players on the
    Announcements panel.

    Beside the toggle sits the dropdown that takes the game's own loot lines
    out of the General chat tab while the toasts are on (Standard Loot
    Messages in Loot-Toasts.lua). Below the toasts' toggle come the position buttons, then two sections
    under headers of their own, Stack (how many, how long, which way) and Text
    (face, size, outline), their rows at the panel's own level rather than
    indented under the toggle. All of it, headers and spacers included, leaves
    the panel while the toggle is off. Which loot gets a toast, and what it
    says, is the Filters panel under this one.
]]
local _, ns = ...
local L = ns.L

-- Bare numbers, so no locale needs a singular or plural form of "second".
local DURATION_VALUES = {}
for _, seconds in ipairs(ns.LOOT_TOAST_DURATIONS) do
	DURATION_VALUES[seconds] = tostring(seconds)
end

--[[
    The same bare numbers, with Unlimited last: it belongs at the "more" end of
    the scale, which is where a player reading down the list looks for it.
]]
local COUNT_VALUES = { [ns.LOOT_TOAST_UNLIMITED] = L["LOOT_TOASTS_UNLIMITED"] }
local COUNT_SORTING = {}
for _, count in ipairs(ns.LOOT_TOAST_COUNTS) do
	COUNT_VALUES[count] = tostring(count)
	COUNT_SORTING[#COUNT_SORTING + 1] = count
end
COUNT_SORTING[#COUNT_SORTING + 1] = ns.LOOT_TOAST_UNLIMITED

-- The client's own SetFont flag strings, captioned, in ns.LOOT_TOAST_FONT_FLAGS order.
local FONT_FLAG_VALUES = {
	NONE = L["LOOT_TOASTS_OUTLINE_NONE"],
	OUTLINE = L["LOOT_TOASTS_OUTLINE_OUTLINE"],
	THICKOUTLINE = L["LOOT_TOASTS_OUTLINE_THICK"],
	MONOCHROME = L["LOOT_TOASTS_OUTLINE_MONOCHROME"],
	MONOCHROMEOUTLINE = L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"],
}

--[[
    The position row: a blank caption cell, then two buttons wide enough for
    their captions. The caption cell takes what the buttons leave, so the row
    ends where every other row does.
]]
local POSITION_BUTTON_WIDTH = 0.85
local POSITION_LABEL_WIDTH = ns.OPTIONS_LABEL_WIDTH - (POSITION_BUTTON_WIDTH * 2 - ns.OPTIONS_CONTROL_WIDTH)

local function LootToastsOff()
	return not ns.db.profile.lootToasts
end

-- A Stack or Text dropdown: every change re-draws the preview, so the player sees it land.
local function SettingRow(captionKey, control, settingKey, afterSet)
	control.get = function()
		return ns.db.profile[settingKey]
	end
	control.set = function(_, value)
		ns.db.profile[settingKey] = value
		local refresh = afterSet or ns.RefreshLootToastSamples
		refresh()
	end
	return ns.OptionsSelectRow(0, nil, L[captionKey], control)
end

-- Font Size's steps, and a size saved between them, so it still reads back.
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
-- Shared Switch
--------------------------------------------------------------------------------

--[[
    Enable Loot Toasts, drawn on this panel and again in the Features section of
    the General panel. Built once here so the two can never drift; each caller
    sets its own order and width.
]]
---@return table
function ns.LootToastsSwitch()
	return {
		type = "toggle",
		name = L["LOOT_TOASTS_ENABLE"],
		desc = L["LOOT_TOASTS_SWITCH_DESCRIPTION"],
		get = function()
			return ns.db.profile.lootToasts
		end,
		set = function(_, value)
			ns.SetLootToastsEnabled(value)
		end,
	}
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildLootToastOptions()
	local args = {
		description = ns.OptionsDesc(L["LOOT_TOASTS_PANEL_DESCRIPTION"]:format(GENERAL), 1),
		spacerAfterDesc = ns.OptionsSpacer(2),
		lootToastsRow = ns.OptionsToggleRow(3, ns.LootToastsSwitch(), {
			control = {
				type = "select",
				desc = L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"]:format(ITEM_LOOT, MONEY_LOOT, GENERAL),
				style = "dropdown",
				values = {
					[ns.STANDARD_LOOT_MESSAGES_DISABLE] = L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"],
					[ns.STANDARD_LOOT_MESSAGES_ENABLE] = L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"],
				},
				sorting = { ns.STANDARD_LOOT_MESSAGES_DISABLE, ns.STANDARD_LOOT_MESSAGES_ENABLE },
				get = function()
					return ns.db.profile.standardLootMessages
				end,
				set = function(_, value)
					ns.db.profile.standardLootMessages = value
					ns.SyncStandardLootMessages()
				end,
			},
		}),
	}

	--[[
        Everything the toasts own goes through Add, which gives it the next
        order and hides it with the toggle, on top of any condition of its own,
        so nothing added later can be left standing on a switched-off panel.
    ]]
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
		Add(key, ns.OptionsSpacer(0))
	end
	local function AddHeader(key, titleKey)
		AddSpacer("spacerBefore_" .. key)
		Add(key, ns.OptionsHeader(L[titleKey], 0))
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

	--[[
        The position buttons come first, straight under the switch, since where
        the toasts sit is the first thing a player sets. They hide with the rest
        rather than greying out: two dead buttons under a switched-off toggle
        read as the feature being unfinished.
    ]]
	AddSpacer("spacerBeforePosition")
	Add(
		"positionRow",
		ns.OptionsRow(0, nil, {
			ns.OptionsRowLabel("", 0, POSITION_LABEL_WIDTH),
			{
				type = "execute",
				name = function()
					return ns.AreLootToastsUnlocked() and L["LOOT_TOASTS_LOCK"] or L["LOOT_TOASTS_UNLOCK"]
				end,
				desc = L["LOOT_TOASTS_LOCK_DESCRIPTION"],
				width = POSITION_BUTTON_WIDTH,
				func = function()
					-- Locking from here counts as having met the handle, as right-clicking it does.
					if ns.AreLootToastsUnlocked() then
						ns.DismissLootToastIntro()
					end
					ns.SetLootToastsUnlocked(not ns.AreLootToastsUnlocked())
				end,
			},
			{
				type = "execute",
				name = L["LOOT_TOASTS_RESET"],
				desc = L["LOOT_TOASTS_RESET_DESCRIPTION"],
				width = POSITION_BUTTON_WIDTH,
				func = function()
					ns.ResetLootToastPosition()
				end,
			},
		})
	)

	-- Stack: how many toasts, for how long, and which way they grow and line up.
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
			row = SettingRow("LOOT_TOASTS_ALIGN", {
				type = "select",
				desc = L["LOOT_TOASTS_ALIGN_DESCRIPTION"],
				values = { LEFT = L["LOOT_TOASTS_ALIGN_LEFT"], RIGHT = L["LOOT_TOASTS_ALIGN_RIGHT"] },
				sorting = { "LEFT", "RIGHT" },
			}, "lootToastAlign"),
		},
	})

	-- Text: the face, its size, then its outline.
	AddHeader("textHeader", "LOOT_TOASTS_TEXT_HEADER")
	AddSettingRows({
		{
			key = "fontRow",
			row = SettingRow("LOOT_TOASTS_FONT", {
				type = "select",
				desc = L["LOOT_TOASTS_FONT_DESCRIPTION"],
				--[[
                    Functions, not tables: the list depends on which faces
                    LibSharedMedia has by the time the dropdown opens, which
                    can grow as other add-ons register theirs.
                ]]
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
