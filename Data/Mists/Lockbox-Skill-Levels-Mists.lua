local _, ns = ...

-- { [itemId] = requiredLockpickingSkill }
ns.LOCKBOX_SKILL_LEVELS = {
	[16882] = 1, -- Battered Junkbox
	[68729] = 425, -- Elementium Lockbox
	[5760] = 225, -- Eternium Lockbox
	[63349] = 400, -- Flame-Scarred Junkbox
	[43622] = 375, -- Froststeel Lockbox
	[88567] = 450, -- Ghost Iron Lockbox
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
	[88165] = 450, -- Vine-Cracked Junkbox
	[16883] = 70, -- Worn Junkbox
}

--[[
How We Got the Data

Last Validated
	2026-11-03, MoP Classic 5.5.4.70631

Notes
	- The Lockpicking skill each locked container needs, for the line Lockbox Tooltips adds to its tooltip (Features/Lockbox-Tooltips.lua).
	- One row for every ns.OPENABLE_ITEMS row whose lock a Rogue can pick. A container whose lock asks for something else, a key or another profession, has no row and so no tooltip line.
	- Each number is the item's lock's Pick Lock entry: ItemSparse's LockID, then that Lock row's entry with Type 2 and Index 1, whose Skill is the number stored here.
	- Pulled from this client's own tables at build 5.5.4.69934.
	- Values are numbers and the tooltip formats them with %d, so a box with no number is absent from the table, never present with a stand-in value.
	- Every row here must also be an ns.OPENING_UNLOCKED row in Openable-Items-Mists.lua; a test holds every folder to it.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Lock?build=5.5.4.69934
	https://wago.tools/db2/ItemSparse?build=5.5.4.70631
	https://wago.tools/db2/Lock?build=5.5.4.70631

QuestieDB
	None.
]]
