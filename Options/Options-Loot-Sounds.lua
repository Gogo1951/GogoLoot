--------------------------------------------------------------------------------
-- GogoLoot Options — Loot Sounds
--------------------------------------------------------------------------------

--[[
    Pick Pocket is its own toggle, not a sub-option of the chime: the chime
    reports corpse loot by quality, this that a Pick Pocket landed at all
    (mostly coin).
]]
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

-- Nothing below Uncommon: a sound is an interruption and wants to be rare.
local SOUND_QUALITY_VALUES, SOUND_QUALITY_SORTING = ns.OptionsQualityChoices(2, "+")

-- Blank until the client has the spell name.
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
	-- On the row group, so the toggles still decide what rides on their own lines.
	args.lootSoundRow.hidden = LootSoundsOff
	args.pickPocketRow.hidden = LootSoundsOff

	return {
		type = "group",
		name = L["TAB_LOOT_SOUNDS"],
		args = args,
	}
end
