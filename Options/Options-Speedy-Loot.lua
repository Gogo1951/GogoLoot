--------------------------------------------------------------------------------
-- GogoLoot Options — Speedy Loot
--------------------------------------------------------------------------------

-- One switch, but a panel like every other feature, so the tree reads in the Features section's order.
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
			speedyLoot = ns.FeatureSwitch("speedyLoot", 3),
		},
	}
end
