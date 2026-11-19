local _, ns = ...

--[[
    Character Rules' armor and weapon rows, what each class starts with ticked,
    and the Loot Roll Sanity Check's drops. Empty until this folder has a live
    client: Features/Character-Rules.lua offers no armor or weapon section, and
    the Sanity Check draws nothing.
]]

ns.CHARACTER_RULE_ARMOR_TYPES = {}
ns.CHARACTER_RULE_WEAPON_TYPES = {}
ns.CLASS_ARMOR_STARTER = {}
ns.CLASS_WEAPON_STARTER = {}
ns.CLASS_STAT_STARTER = {}
ns.SANITY_CHECK_TRASH = {}
ns.SANITY_CHECK_DUNGEON_BOSSES = {}
ns.SANITY_CHECK_RAID_BOSSES = {}

--[[
How We Got the Data

Last Validated
	Never.

Notes
	- Every table is empty: this folder has no live client yet.

SQL (CMaNGOS)
	None.

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
