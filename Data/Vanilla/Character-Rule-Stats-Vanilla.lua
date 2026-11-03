local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- { statKey }
ns.CHARACTER_RULE_STAT_KEYS = {
	"STRENGTH",
	"AGILITY",
	"STAMINA",
	"INTELLECT",
	"SPIRIT",
}

--[[
How We Got the Data

Last Validated
	2026-11-03, Classic Era 1.15.9.70576

Notes
	- The stat keys Character Rules offers on this client, from ns.CHARACTER_RULE_STATS (Data/Data.lua); Features/Character-Rules.lua drops the rest, and any section left empty, at load.
	- The five primary attributes only. This client's secondary stats (spell power, healing, attack power, crit, hit and mana regeneration) are "Equip:" spells, which neither GetItemStats nor the tooltip's stat lines read, and GogoLoot carries no item table to cover them. A rule saved for a secondary stat is never read.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.

QuestieDB
	None.
]]
