--------------------------------------------------------------------------------
-- GogoLoot Options — Loot Sounds
--------------------------------------------------------------------------------

--[[
    A panel of its own, right after Loot Toasts: its description, then Enable
    Loot Sounds, the master switch, then the chime with its minimum quality and
    the Pick Pocket sound, each carrying a speaker that plays it (see Toggle
    Rows in Options-Utilities.lua). Everything below the master switch leaves
    the panel while it is off. Nothing on it hides behind the toasts' toggle:
    the sounds play with no toast on screen.

    Schema (ns.DATABASE_DEFAULTS.profile in Default-Settings.lua):
      lootSoundsEnabled
        - the master switch: Loot-Sounds.lua plays neither sound while it is off
      lootSounds + lootSoundThreshold
        - the chime and its minimum quality
      pickPocketSound
        - the Pick Pocket sound

    The Pick Pocket sound is its own toggle rather than a sub-option of the
    chime, because it answers a different question: the chime reports what came
    out of a corpse, filtered by quality; this reports that a Pick Pocket landed
    at all, which is mostly coin.
]]
local _, ns = ...
local L = ns.L

--[[
    The chime starts at Uncommon and offers nothing lower: a sound is an
    interruption and wants to be rare. The toasts, a record, start at Poor.
]]
local SOUND_QUALITY_VALUES, SOUND_QUALITY_SORTING = ns.OptionsQualityChoices(2, "+")

-- The game's own name for Pick Pocket, read as the panel is built; blank until the client has it.
local function PickPocketName()
	return C_Spell.GetSpellName(ns.SPELLS.PICK_POCKET) or ""
end

--[[
    A speaker that plays a sound: an execute carrying an image, which AceGUI
    draws as a bare icon, with its label in the tooltip. Control Freak's icon at
    Control Freak's size, so the two add-ons' sound rows match.
]]
local PREVIEW_ICON = "Interface\\COMMON\\VoiceChat-Speaker"
local PREVIEW_ICON_SIZE = 18

---@param desc string
---@param play function
---@return table
local function SoundPreview(desc, play)
	return {
		type = "execute",
		name = "",
		desc = desc,
		image = PREVIEW_ICON,
		imageWidth = PREVIEW_ICON_SIZE,
		imageHeight = PREVIEW_ICON_SIZE,
		width = ns.OPTIONS_SPEAKER_WIDTH,
		func = play,
	}
end

--------------------------------------------------------------------------------
-- Shared Switch
--------------------------------------------------------------------------------

--[[
    Enable Loot Sounds, drawn on this panel and again in the Features section
    of the General panel. Built once here so the two can never drift; each
    caller sets its own order and width.
]]
---@return table
function ns.LootSoundsSwitch()
	return {
		type = "toggle",
		name = L["LOOT_SOUNDS_SWITCH"],
		desc = L["LOOT_SOUNDS_SWITCH_DESCRIPTION"],
		get = function()
			return ns.db.profile.lootSoundsEnabled
		end,
		set = function(_, value)
			ns.db.profile.lootSoundsEnabled = value
		end,
	}
end

local function LootSoundsOff()
	return not ns.db.profile.lootSoundsEnabled
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildLootSoundOptions()
	local lootSoundsEnabled = ns.LootSoundsSwitch()
	lootSoundsEnabled.width = "full"
	lootSoundsEnabled.order = 3

	local args = {
		description = ns.OptionsDesc(L["LOOT_SOUNDS_PANEL_DESCRIPTION"]:format(PickPocketName()), 1),
		spacerAfterDesc = ns.OptionsSpacer(2),
		lootSoundsEnabled = lootSoundsEnabled,
		spacerAfterSwitch = ns.OptionsSpacer(4, LootSoundsOff),
		lootSoundRow = ns.OptionsToggleRow(5, {
			type = "toggle",
			name = L["LOOT_SOUNDS_ENABLE"],
			desc = L["LOOT_SOUNDS_ENABLE_DESCRIPTION"],
			get = function()
				return ns.db.profile.lootSounds
			end,
			set = function(_, value)
				ns.db.profile.lootSounds = value
			end,
		}, {
			preview = SoundPreview(L["LOOT_SOUNDS_TEST"], function()
				PlaySoundFile(ns.LOOT_SOUND_FILE, "Master")
			end),
			control = {
				type = "select",
				desc = L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"],
				values = SOUND_QUALITY_VALUES,
				sorting = SOUND_QUALITY_SORTING,
				get = function()
					return ns.db.profile.lootSoundThreshold
				end,
				set = function(_, value)
					ns.db.profile.lootSoundThreshold = value
				end,
			},
		}),
		spacerBeforePickPocket = ns.OptionsSpacer(6, LootSoundsOff),
		pickPocketRow = ns.OptionsToggleRow(7, {
			type = "toggle",
			name = L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"]:format(PickPocketName()),
			desc = L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"]:format(PickPocketName()),
			get = function()
				return ns.db.profile.pickPocketSound
			end,
			set = function(_, value)
				ns.db.profile.pickPocketSound = value
			end,
		}, {
			preview = SoundPreview(L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"]:format(PickPocketName()), function()
				PlaySound(ns.SOUND_KIT_IDS.PICK_POCKET, "Master")
			end),
		}),
	}
	-- The two sound rows leave with the master switch; their own toggles still decide what rides on their lines.
	args.lootSoundRow.hidden = LootSoundsOff
	args.pickPocketRow.hidden = LootSoundsOff

	return {
		type = "group",
		name = L["TAB_LOOT_SOUNDS"],
		args = args,
	}
end
