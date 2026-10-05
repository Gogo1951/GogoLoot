local _, ns = ...

--[[
    Gear whose stats the item itself doesn't report, for Character Rules
    (Features/Automated-Rolls.lua). Empty on this client: see the notes below.
]]

-- { [itemId] = statFlags }
ns.ITEM_STAT_FLAGS = {}

-- { [suffixId] = statFlags }, the id as the item link carries it
ns.RANDOM_SUFFIX_STAT_FLAGS = {}

--[[
How We Got the Data

Last Validated
	2026-10-05, WoW Forever 1.60.1.70205

Notes
	- WoW Forever runs the Retail engine: its gear carries spell power, healing, attack power and crit as real item stats (ItemSparse stat types 45, 41, 38 and 32 on Dreamweave Gloves, Robe of the Archmage and Choker of the Fire Lord, where Classic Era has Equip: spells), and the client ships no ItemRandomProperties table, so GetItemStats reports everything Character Rules reads and these tables stay empty.
	- Classic Era and TBC Anniversary are the clients that need these tables; see Data/Vanilla/Item-Stats-Vanilla.lua for how they are built.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	Not used.
]]
