-- Data/Wrath/Lockbox-Skill-Levels-Wrath.lua
local _, ns = ...

--[[
    Required Lockpicking skill per locked container, for the tooltip line in
    Features/Lockbox-Tooltips.lua: one row for every ns.OPENABLE_ITEMS row
    whose lock a Rogue can pick. A locked item whose lock asks for something
    else, a key or another profession, has no row and so no tooltip line.

    Pulled from the Wrath Classic client's own tables on wago.tools, build
    3.4.4.61581: the item's ItemSparse LockID, then that
    Lock row's pick-lock entry (Type 2, Index 1), whose Skill is the number
    stored here.
    https://wago.tools/db2/Lock?build=3.4.4.61581

    Values are numbers and the tooltip formats them with %d, so a box with no
    number is absent from the table, never present with a stand-in value.

    -- TODO: Add SQL Query
]]
-- { [itemId] = requiredLockpickingSkill }
ns.LOCKBOX_SKILL_LEVELS = {
	[16882] = 1, -- Battered Junkbox
	[5760] = 225, -- Eternium Lockbox
	[43622] = 375, -- Froststeel Lockbox
	[4633] = 25, -- Heavy Bronze Lockbox
	[16885] = 250, -- Heavy Junkbox
	[4634] = 70, -- Iron Lockbox
	[13875] = 175, -- Ironbound Locked Chest
	[31952] = 325, -- Khorium Lockbox
	[5758] = 225, -- Mithril Lockbox
	[4632] = 1, -- Ornate Bronze Lockbox
	[43575] = 350, -- Reinforced Junkbox
	[13918] = 250, -- Reinforced Locked Chest
	[4638] = 225, -- Reinforced Steel Lockbox
	[6354] = 1, -- Small Locked Chest
	[4637] = 175, -- Steel Lockbox
	[4636] = 125, -- Strong Iron Lockbox
	[29569] = 300, -- Strong Junkbox
	[16884] = 175, -- Sturdy Junkbox
	[6355] = 70, -- Sturdy Locked Chest
	[7209] = 1, -- Tazan's Satchel
	[12033] = 275, -- Thaurissan Family Jewels
	[5759] = 225, -- Thorium Lockbox
	[45986] = 400, -- Tiny Titanium Lockbox
	[43624] = 400, -- Titanium Lockbox
	[16883] = 70, -- Worn Junkbox
}
