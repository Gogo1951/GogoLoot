--------------------------------------------------------------------------------
-- GogoLoot Options — Loot Sounds
--------------------------------------------------------------------------------

--[[
    A panel of its own, right after Loot Toasts: the chime with its minimum
    quality, then the Pick Pocket sound, each carrying a speaker that plays it
    (see Toggle Rows in Options-Utilities.lua). The sounds answer to their own switches alone, so
    the panel opens on its description and those two rather than one master
    switch, and nothing on it hides behind the toasts' toggle.

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

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildLootSoundOptions()
	local args = {
		description = ns.OptionsDesc(L["LOOT_SOUNDS_PANEL_DESCRIPTION"]:format(PickPocketName()), 1),
		spacerAfterDesc = ns.OptionsSpacer(2),
		lootSoundRow = ns.OptionsToggleRow(3, {
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
			preview = ns.OptionsSoundPreview(L["LOOT_SOUNDS_TEST"], function()
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
		spacerBeforePickPocket = ns.OptionsSpacer(4),
		pickPocketRow = ns.OptionsToggleRow(5, {
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
			preview = ns.OptionsSoundPreview(
				L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"]:format(PickPocketName()),
				function()
					PlaySound(ns.SOUND_KIT_IDS.PICK_POCKET, "Master")
				end
			),
		}),
	}

	return {
		type = "group",
		name = L["TAB_LOOT_SOUNDS"],
		args = args,
	}
end
