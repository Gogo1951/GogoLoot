-- Data/Discovery/Lockbox-Skill-Levels-Discovery.lua
local _, ns = ...

if not ns.IS_DISCOVERY then
	return
end

--[[
    Required Lockpicking skill per locked container, for the tooltip line in
    Features/Lockbox-Tooltips.lua: one row for every ns.OPENABLE_ITEMS row
    whose lock a Rogue can pick. A locked item whose lock asks for something
    else, a key or another profession, has no row and so no tooltip line.

    Pulled from the Classic Era client's own tables on wago.tools, build
    1.15.9.69722: the item's ItemSparse LockID, then that
    Lock row's pick-lock entry (Type 2, Index 1), whose Skill is the number
    stored here.
    https://wago.tools/db2/Lock?build=1.15.9.69722

    Values are numbers and the tooltip formats them with %d, so a box with no
    number is absent from the table, never present with a stand-in value.

    -- TODO: Add SQL Query
]]
-- { [itemId] = requiredLockpickingSkill }
ns.LOCKBOX_SKILL_LEVELS = {
	[16882] = 1, -- Battered Junkbox
	[208838] = 1, -- Dark Iron Lockbox
	[5760] = 225, -- Eternium Lockbox
	[4633] = 25, -- Heavy Bronze Lockbox
	[16885] = 250, -- Heavy Junkbox
	[4634] = 70, -- Iron Lockbox
	[13875] = 175, -- Ironbound Locked Chest
	[5758] = 225, -- Mithril Lockbox
	[4632] = 1, -- Ornate Bronze Lockbox
	[227937] = 175, -- Puzzle Box
	[13918] = 250, -- Reinforced Locked Chest
	[4638] = 225, -- Reinforced Steel Lockbox
	[6354] = 1, -- Small Locked Chest
	[4637] = 175, -- Steel Lockbox
	[4636] = 125, -- Strong Iron Lockbox
	[16884] = 175, -- Sturdy Junkbox
	[6355] = 70, -- Sturdy Locked Chest
	[7209] = 1, -- Tazan's Satchel
	[12033] = 275, -- Thaurissan Family Jewels
	[5759] = 225, -- Thorium Lockbox
	[16883] = 70, -- Worn Junkbox
}
