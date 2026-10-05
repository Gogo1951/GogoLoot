local _, ns = ...

-- { [itemId] = requiredLockpickingSkill }
ns.LOCKBOX_SKILL_LEVELS = {
	[16882] = 1, -- Battered Junkbox
	[5760] = 225, -- Eternium Lockbox
	[4633] = 25, -- Heavy Bronze Lockbox
	[16885] = 250, -- Heavy Junkbox
	[4634] = 70, -- Iron Lockbox
	[13875] = 175, -- Ironbound Locked Chest
	[5758] = 225, -- Mithril Lockbox
	[4632] = 1, -- Ornate Bronze Lockbox
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

--[[
How We Got the Data

Last Validated
	2026-10-04, WoW Forever 1.60.1.70205

Notes
	- The Lockpicking skill each locked container needs, for the line Lockbox Tooltips adds to its tooltip (Features/Lockbox-Tooltips.lua).
	- One row for every ns.OPENABLE_ITEMS row whose lock a Rogue can pick. A container whose lock asks for something else, a key or another profession, has no row and so no tooltip line. Thieven' Kit is locked but has no pick-lock entry, so it has no row.
	- Each number is the item's lock's Pick Lock entry: ItemSparse's LockID, then that Lock row's entry with Type 2 and Index 1, whose Skill is the number stored here. Tazan's Satchel's lock also takes its key, Tazan's Key, and on this client its tooltip reads "Requires Open (0)" rather than naming Pick Lock.
	- Pulled from Forever's own tables at build 1.60.1.70009, falling back on Classic Era build 1.15.9.69722 where Forever's ItemSparse lacked the item. Every row here has its own Forever row, so none came from the fallback.
	- Values are numbers and the tooltip formats them with %d, so a box with no number is absent from the table, never present with a stand-in value.
	- Every row here must also be an ns.OPENING_UNLOCKED row in Openable-Items-Camelot.lua; a test holds every folder to it.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Lock?build=1.60.1.70009
]]
