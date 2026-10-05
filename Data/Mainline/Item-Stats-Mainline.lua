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
	2026-10-05, Retail 12.1.0.69933

Notes
	- Retail gear carries every stat Character Rules reads as a real item stat, and GetItemStats reports it, so these tables stay empty.
	- Classic Era and TBC Anniversary are the clients that need these tables; see Data/Vanilla/Item-Stats-Vanilla.lua for how they are built.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	Not used.
]]
