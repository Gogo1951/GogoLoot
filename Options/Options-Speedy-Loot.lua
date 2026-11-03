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

--------------------------------------------------------------------------------
-- Shared Switch
--------------------------------------------------------------------------------

--[[
    Enable Speedy Loot, drawn on this panel and again in the Features section
    of the General panel. Built once here so the two can never drift; each
    caller sets its own order and width.
]]
---@return table
function ns.SpeedyLootSwitch()
	return {
		type = "toggle",
		name = L["SPEEDY_LOOT_ENABLE"],
		desc = L["SPEEDY_LOOT_SWITCH_DESCRIPTION"]:format(AUTO_LOOT_DEFAULT_TEXT, MASTER_LOOTER),
		get = function()
			return ns.db.global.speedyLoot
		end,
		set = function(_, value)
			ns.db.global.speedyLoot = value
			if value then
				ns.EnsureAutoLoot()
			end
		end,
	}
end

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

---@return table
function ns.BuildSpeedyLootOptions()
	local speedyLoot = ns.SpeedyLootSwitch()
	speedyLoot.width = "full"
	speedyLoot.order = 3

	return {
		type = "group",
		name = L["TAB_SPEEDY_LOOT"],
		args = {
			description = ns.OptionsDesc(L["SPEEDY_LOOT_DESCRIPTION"], 1),
			spacerAfterDesc = ns.OptionsSpacer(2),
			speedyLoot = speedyLoot,
		},
	}
end
