--------------------------------------------------------------------------------
-- GogoLoot Options — Loot Sounds
--------------------------------------------------------------------------------

--[[
    A panel of its own, right after Loot Toasts: its description, then Enable
    Loot Sounds, the master switch, then the chime with its minimum quality and
    the Pick Pocket sound, each carrying a speaker that plays it (Kit.ToggleRow). Everything below the master switch leaves
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
local Kit = ns.OptionsKit

--[[
    The chime starts at Uncommon and offers nothing lower: a sound is an
    interruption and wants to be rare. The toasts, a record, start at Poor.
]]
local SOUND_QUALITY_VALUES, SOUND_QUALITY_SORTING = ns.OptionsQualityChoices(2, "+")

-- The game's own name for Pick Pocket, read as the panel is built; blank until the client has it.
local function PickPocketName()
	return C_Spell.GetSpellName(ns.SPELLS.PICK_POCKET) or ""
end

local function LootSoundsOff()
	return not ns.db.profile.lootSoundsEnabled
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildLootSoundOptions()
	local args = {
		description = Kit.Desc(L["LOOT_SOUNDS_PANEL_DESCRIPTION"]:format(PickPocketName()), 1),
		spacerAfterDesc = Kit.Spacer(2),
		lootSoundsEnabled = ns.FeatureSwitch("lootSoundsEnabled", 3),
		spacerAfterSwitch = Kit.Spacer(4, LootSoundsOff),
		lootSoundRow = Kit.ToggleRow(5, {
			type = "toggle",
			name = L["LOOT_SOUNDS_ENABLE"],
			desc = L["LOOT_SOUNDS_ENABLE_DESCRIPTION"],
			get = Kit.Get("profile", "lootSounds"),
			set = Kit.Set("profile", "lootSounds"),
		}, {
			preview = Kit.SoundPreview(function()
				PlaySoundFile(ns.LOOT_SOUND_FILE, "Master")
			end),
			control = {
				type = "select",
				desc = L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"],
				values = SOUND_QUALITY_VALUES,
				sorting = SOUND_QUALITY_SORTING,
				get = Kit.Get("profile", "lootSoundThreshold"),
				set = Kit.Set("profile", "lootSoundThreshold"),
			},
		}),
		spacerBeforePickPocket = Kit.Spacer(6, LootSoundsOff),
		pickPocketRow = Kit.ToggleRow(7, {
			type = "toggle",
			name = L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"]:format(PickPocketName()),
			desc = L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"]:format(PickPocketName()),
			get = Kit.Get("profile", "pickPocketSound"),
			set = Kit.Set("profile", "pickPocketSound"),
		}, {
			preview = Kit.SoundPreview(function()
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
