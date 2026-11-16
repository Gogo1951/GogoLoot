--------------------------------------------------------------------------------
-- GogoLoot Options — Speedy Loot
--------------------------------------------------------------------------------

--[[
    The first feature panel, so the Settings tree reads in the order of the
    General panel's Features section. Speedy Loot is one switch, but it gets a
    panel like every other feature: its description, then Enable Speedy Loot.

    Schema (ns.DATABASE_DEFAULTS.global in Default-Settings.lua):
      speedyLoot
        - account-wide; read by Speedy-Loot.lua, and Auto-Loot.lua keeps the
          game's Auto Loot setting on while it is set
]]
local _, ns = ...
local L = ns.L
local Kit = ns.OptionsKit

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildSpeedyLootOptions()
	return {
		type = "group",
		name = L["TAB_SPEEDY_LOOT"],
		args = {
			description = Kit.Desc(L["SPEEDY_LOOT_DESCRIPTION"], 1),
			spacerAfterDesc = Kit.Spacer(2),
			-- The same switch the GogoLoot page's Features section draws (ns.FEATURES).
			speedyLoot = ns.FeatureSwitch("speedyLoot", 3),
		},
	}
end
