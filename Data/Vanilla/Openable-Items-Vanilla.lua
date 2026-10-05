local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- { [itemId] = defaultAction }
ns.OPENABLE_ITEMS = {
	[10456] = ns.OPENING_OPEN, -- A Bulging Coin Purse
	[15902] = ns.OPENING_OPEN, -- A Crazy Grab Bag
	[11883] = ns.OPENING_OPEN, -- A Dingy Fanny Pack
	[5335] = ns.OPENING_IGNORE_UNIQUE, -- A Sack of Coins (unique: Old Moneybag)
	[6755] = ns.OPENING_IGNORE_UNIQUE, -- A Small Container of Gems (unique: Jewelry Box)
	[11107] = ns.OPENING_IGNORE_UNIQUE, -- A Small Pack (unique: Large Compass, Curled Map Parchment, Lion-headed Key, ...)
	[21509] = ns.OPENING_OPEN, -- Ahn'Qiraj War Effort Supplies
	[21510] = ns.OPENING_OPEN, -- Ahn'Qiraj War Effort Supplies
	[21511] = ns.OPENING_OPEN, -- Ahn'Qiraj War Effort Supplies
	[21512] = ns.OPENING_OPEN, -- Ahn'Qiraj War Effort Supplies
	[21513] = ns.OPENING_OPEN, -- Ahn'Qiraj War Effort Supplies
	[22152] = ns.OPENING_OPEN, -- Anthion's Pouch
	[20231] = ns.OPENING_OPEN, -- Arathor Advanced Care Package
	[20233] = ns.OPENING_OPEN, -- Arathor Basic Care Package
	[20236] = ns.OPENING_OPEN, -- Arathor Standard Care Package
	[11955] = ns.OPENING_OPEN, -- Bag of Empty Ooze Containers
	[20603] = ns.OPENING_OPEN, -- Bag of Spoils
	[6356] = ns.OPENING_OPEN, -- Battered Chest
	[16882] = ns.OPENING_UNLOCKED, -- Battered Junkbox
	[7973] = ns.OPENING_OPEN, -- Big-mouth Clam
	[6646] = ns.OPENING_OPEN, -- Bloated Albacore
	[6647] = ns.OPENING_OPEN, -- Bloated Catfish
	[21163] = ns.OPENING_OPEN, -- Bloated Firefin
	[6644] = ns.OPENING_OPEN, -- Bloated Mackerel
	[21243] = ns.OPENING_OPEN, -- Bloated Mightfish
	[6645] = ns.OPENING_OPEN, -- Bloated Mud Snapper
	[21162] = ns.OPENING_OPEN, -- Bloated Oily Blackmouth
	[13881] = ns.OPENING_OPEN, -- Bloated Redgill
	[21164] = ns.OPENING_OPEN, -- Bloated Rockscale Cod
	[13891] = ns.OPENING_OPEN, -- Bloated Salmon
	[6643] = ns.OPENING_OPEN, -- Bloated Smallfish
	[8366] = ns.OPENING_IGNORE, -- Bloated Trout (Bind on Pickup: Pendant of Myzrael)
	[17962] = ns.OPENING_IGNORE_RAID, -- Blue Sack of Gems (raid bosses: Azuregos, Onyxia, Nefarian, Lord Kazzak, ...)
	[21812] = ns.OPENING_OPEN, -- Box of Chocolates
	[10695] = ns.OPENING_IGNORE_UNIQUE, -- Box of Empty Vials (unique: Empty Vial Labeled #1, Empty Vial Labeled #2, Empty Vial Labeled #3, ...)
	[9541] = ns.OPENING_OPEN, -- Box of Goodies
	[9539] = ns.OPENING_OPEN, -- Box of Rations
	[9540] = ns.OPENING_OPEN, -- Box of Spells
	[6827] = ns.OPENING_OPEN, -- Box of Supplies
	[8502] = ns.OPENING_OPEN, -- Bronze Lotterybox
	[22746] = ns.OPENING_OPEN, -- Buccaneer's Uniform
	[16783] = ns.OPENING_OPEN, -- Bundle of Reports
	[21191] = ns.OPENING_OPEN, -- Carefully Wrapped Present
	[11887] = ns.OPENING_OPEN, -- Cenarion Circle Cache
	[20602] = ns.OPENING_OPEN, -- Chest of Spoils
	[21741] = ns.OPENING_OPEN, -- Cluster Rocket Recipes
	[21528] = ns.OPENING_OPEN, -- Colossal Bag of Loot
	[20808] = ns.OPENING_OPEN, -- Combat Assignment
	[15103] = ns.OPENING_OPEN, -- Corrupt Tested Sample
	[5738] = ns.OPENING_IGNORE_UNIQUE, -- Covert Ops Pack (unique: Remote Detonator (Red), Remote Detonator (Blue), NG-5 Explosives (Red), ...)
	[9265] = ns.OPENING_IGNORE_UNIQUE, -- Cuergo's Hidden Treasure (unique: Cuergo's Gold)
	[23022] = ns.OPENING_OPEN, -- Curmudgeon's Payoff
	[19422] = ns.OPENING_IGNORE_UNIQUE, -- Darkmoon Faire Fortune (unique: Sayge's Fortune #23, Sayge's Fortune #24, Sayge's Fortune #25, ...)
	[191656] = ns.OPENING_OPEN, -- Death's Essence
	[20469] = ns.OPENING_OPEN, -- Decoded True Believer Clippings
	[20228] = ns.OPENING_OPEN, -- Defiler's Advanced Care Package
	[20229] = ns.OPENING_OPEN, -- Defiler's Basic Care Package
	[20230] = ns.OPENING_OPEN, -- Defiler's Standard Care Package
	[12849] = ns.OPENING_OPEN, -- Demon Kissed Sack
	[6351] = ns.OPENING_OPEN, -- Dented Crate
	[8647] = ns.OPENING_IGNORE_UNIQUE, -- Egg Crate (unique: Extraordinary Egg, Fine Egg, Ordinary Egg, ...)
	[10752] = ns.OPENING_OPEN, -- Emerald Encrusted Chest
	[11617] = ns.OPENING_IGNORE_UNIQUE, -- Eridan's Supplies (unique: Book of Aquor, Irontree Heart)
	[5760] = ns.OPENING_UNLOCKED, -- Eternium Lockbox
	[11024] = ns.OPENING_OPEN, -- Evergreen Herb Casing
	[11937] = ns.OPENING_IGNORE, -- Fat Sack of Coins (Bind on Pickup: Fire Opal Necklace)
	[10834] = ns.OPENING_IGNORE_UNIQUE, -- Felhound Tracker Kit (unique: Fel Orb)
	[21363] = ns.OPENING_OPEN, -- Festive Gift
	[189421] = ns.OPENING_OPEN, -- Fire Resist Leather Gear
	[189419] = ns.OPENING_OPEN, -- Fire Resist Plate Gear
	[189420] = ns.OPENING_OPEN, -- Fire Resist Plate Gear
	[21131] = ns.OPENING_OPEN, -- Followup Combat Assignment
	[20805] = ns.OPENING_IGNORE_UNIQUE, -- Followup Logistics Assignment (unique: Logistics Task Briefing I, Logistics Task Briefing II, Logistics Task Briefing III, ...)
	[21386] = ns.OPENING_IGNORE_UNIQUE, -- Followup Logistics Assignment (unique: Logistics Task Briefing I, Logistics Task Briefing II, Logistics Task Briefing III, ...)
	[21133] = ns.OPENING_IGNORE_UNIQUE, -- Followup Tactical Assignment (unique: Tactical Task Briefing X, Tactical Task Briefing II, Tactical Task Briefing IV, ...)
	[8484] = ns.OPENING_OPEN, -- Gadgetzan Water Co. Care Package
	[21310] = ns.OPENING_OPEN, -- Gaily Wrapped Present
	[21270] = ns.OPENING_OPEN, -- Gently Shaken Gift
	[21271] = ns.OPENING_OPEN, -- Gently Shaken Gift
	[21979] = ns.OPENING_IGNORE, -- Gift of Adoration: Darnassus (Bind on Pickup: Box of Chocolates, Bag of Candies, Silver Shafted Arrow, ...)
	[21980] = ns.OPENING_IGNORE, -- Gift of Adoration: Ironforge (Bind on Pickup: Box of Chocolates, Bag of Candies, Silver Shafted Arrow, ...)
	[22164] = ns.OPENING_IGNORE, -- Gift of Adoration: Orgrimmar (Bind on Pickup: Box of Chocolates, Bag of Candies, Silver Shafted Arrow, ...)
	[21981] = ns.OPENING_IGNORE, -- Gift of Adoration: Stormwind (Bind on Pickup: Box of Chocolates, Bag of Candies, Silver Shafted Arrow, ...)
	[22165] = ns.OPENING_IGNORE, -- Gift of Adoration: Thunder Bluff (Bind on Pickup: Box of Chocolates, Bag of Candies, Silver Shafted Arrow, ...)
	[22166] = ns.OPENING_IGNORE, -- Gift of Adoration: Undercity (Bind on Pickup: Box of Chocolates, Bag of Candies, Silver Shafted Arrow, ...)
	[22167] = ns.OPENING_OPEN, -- Gift of Friendship: Darnassus
	[22168] = ns.OPENING_OPEN, -- Gift of Friendship: Ironforge
	[22169] = ns.OPENING_OPEN, -- Gift of Friendship: Orgrimmar
	[22170] = ns.OPENING_OPEN, -- Gift of Friendship: Stormwind
	[22171] = ns.OPENING_OPEN, -- Gift of Friendship: Thunder Bluff
	[22172] = ns.OPENING_OPEN, -- Gift of Friendship: Undercity
	[8049] = ns.OPENING_IGNORE_UNIQUE, -- Gnarlpine Necklace (unique: Tallonkai's Jewel)
	[11423] = ns.OPENING_OPEN, -- Gnome Engineer's Renewal Gift
	[5857] = ns.OPENING_OPEN, -- Gnome Prize Box
	[11422] = ns.OPENING_OPEN, -- Goblin Engineer's Renewal Gift
	[5858] = ns.OPENING_OPEN, -- Goblin Prize Box
	[17964] = ns.OPENING_IGNORE_RAID, -- Gray Sack of Gems (raid bosses: Azuregos, Onyxia, Nefarian, Lord Kazzak, ...)
	[19296] = ns.OPENING_OPEN, -- Greater Darkmoon Prize
	[17963] = ns.OPENING_IGNORE_RAID, -- Green Sack of Gems (raid bosses: Azuregos, Onyxia, Nefarian, Lord Kazzak, ...)
	[10773] = ns.OPENING_OPEN, -- Hakkari Urn
	[4633] = ns.OPENING_UNLOCKED, -- Heavy Bronze Lockbox
	[8503] = ns.OPENING_OPEN, -- Heavy Bronze Lotterybox
	[13874] = ns.OPENING_OPEN, -- Heavy Crate
	[8505] = ns.OPENING_OPEN, -- Heavy Iron Lotterybox
	[16885] = ns.OPENING_UNLOCKED, -- Heavy Junkbox
	[8507] = ns.OPENING_OPEN, -- Heavy Mithril Lotterybox
	[22648] = ns.OPENING_IGNORE_UNIQUE, -- Hive'Ashi Dossier (unique: Combat Task Briefing XII, Combat Task Briefing III, Combat Task Briefing I, ...)
	[22649] = ns.OPENING_IGNORE_UNIQUE, -- Hive'Regal Dossier (unique: Combat Task Briefing VIII, Combat Task Briefing IX, Combat Task Briefing X, ...)
	[22650] = ns.OPENING_IGNORE_UNIQUE, -- Hive'Zora Dossier (unique: Combat Task Briefing IV, Combat Task Briefing V, Combat Task Briefing VI, ...)
	[10569] = ns.OPENING_IGNORE_UNIQUE, -- Hoard of the Black Dragonflight (unique: Preserved Threshadon Meat, Preserved Pheromone Mixture)
	[20367] = ns.OPENING_OPEN, -- Hunting Gear
	[9529] = ns.OPENING_OPEN, -- Internal Warrior Equipment Kit L25
	[9532] = ns.OPENING_OPEN, -- Internal Warrior Equipment Kit L30
	[21150] = ns.OPENING_OPEN, -- Iron Bound Trunk
	[4634] = ns.OPENING_UNLOCKED, -- Iron Lockbox
	[8504] = ns.OPENING_OPEN, -- Iron Lotterybox
	[13875] = ns.OPENING_UNLOCKED, -- Ironbound Locked Chest
	[10479] = ns.OPENING_OPEN, -- Kovic's Trading Satchel
	[10595] = ns.OPENING_OPEN, -- Kum'isha's Junk
	[12122] = ns.OPENING_OPEN, -- Kum'isha's Junk
	[19035] = ns.OPENING_OPEN, -- Lard's Special Picnic Basket
	[21743] = ns.OPENING_OPEN, -- Large Cluster Rocket Recipes
	[21742] = ns.OPENING_OPEN, -- Large Rocket Recipes
	[19297] = ns.OPENING_OPEN, -- Lesser Darkmoon Prize
	[21132] = ns.OPENING_IGNORE_UNIQUE, -- Logistics Assignment (unique: Logistics Task Briefing X, Logistics Task Briefing IV, Logistics Task Briefing V, ...)
	[21266] = ns.OPENING_IGNORE_UNIQUE, -- Logistics Assignment (unique: Logistics Task Briefing IV, Logistics Task Briefing VI, Logistics Task Briefing VII, ...)
	[18804] = ns.OPENING_IGNORE_UNIQUE, -- Lord Grayson's Satchel (unique: Divination Scryer, Blessed Arcanite Barding)
	[21746] = ns.OPENING_OPEN, -- Lucky Red Envelope
	[21640] = ns.OPENING_OPEN, -- Lunar Festival Fireworks Pack
	[6307] = ns.OPENING_OPEN, -- Message in a Bottle
	[19298] = ns.OPENING_OPEN, -- Minor Darkmoon Prize
	[21228] = ns.OPENING_OPEN, -- Mithril Bound Trunk
	[5758] = ns.OPENING_UNLOCKED, -- Mithril Lockbox
	[8506] = ns.OPENING_OPEN, -- Mithril Lotterybox
	[189427] = ns.OPENING_OPEN, -- More Raid Consumables
	[22320] = ns.OPENING_OPEN, -- Mux's Quality Goods
	[19425] = ns.OPENING_OPEN, -- Mysterious Lockbox
	[21042] = ns.OPENING_OPEN, -- Narain's Special Kit
	[15876] = ns.OPENING_IGNORE_UNIQUE, -- Nathanos' Chest (unique: Rotten Apple)
	[9537] = ns.OPENING_OPEN, -- Neatly Wrapped Box
	[20768] = ns.OPENING_IGNORE_UNIQUE, -- Oozing Bag (unique: Disgusting Oozeling)
	[4632] = ns.OPENING_UNLOCKED, -- Ornate Bronze Lockbox
	[19153] = ns.OPENING_OPEN, -- Outrider Advanced Care Package
	[19154] = ns.OPENING_OPEN, -- Outrider Basic Care Package
	[19155] = ns.OPENING_OPEN, -- Outrider Standard Care Package
	[11912] = ns.OPENING_OPEN, -- Package of Empty Ooze Containers
	[9276] = ns.OPENING_IGNORE_UNIQUE, -- Pirate's Footlocker (unique: Captain's Key, Ship Schedule)
	[22155] = ns.OPENING_IGNORE, -- Pledge of Adoration: Darnassus (Bind on Pickup: Box of Chocolates, Bag of Candies, Silver Shafted Arrow, ...)
	[22154] = ns.OPENING_IGNORE, -- Pledge of Adoration: Ironforge (Bind on Pickup: Box of Chocolates, Bag of Candies, Silver Shafted Arrow, ...)
	[22156] = ns.OPENING_IGNORE, -- Pledge of Adoration: Orgrimmar (Bind on Pickup: Box of Chocolates, Bag of Candies, Silver Shafted Arrow, ...)
	[21975] = ns.OPENING_IGNORE, -- Pledge of Adoration: Stormwind (Bind on Pickup: Box of Chocolates, Bag of Candies, Silver Shafted Arrow, ...)
	[22158] = ns.OPENING_IGNORE, -- Pledge of Adoration: Thunder Bluff (Bind on Pickup: Box of Chocolates, Bag of Candies, Silver Shafted Arrow, ...)
	[22157] = ns.OPENING_IGNORE, -- Pledge of Adoration: Undercity (Bind on Pickup: Box of Chocolates, Bag of Candies, Silver Shafted Arrow, ...)
	[22159] = ns.OPENING_OPEN, -- Pledge of Friendship: Darnassus
	[22160] = ns.OPENING_OPEN, -- Pledge of Friendship: Ironforge
	[22161] = ns.OPENING_OPEN, -- Pledge of Friendship: Orgrimmar
	[22178] = ns.OPENING_OPEN, -- Pledge of Friendship: Stormwind
	[22162] = ns.OPENING_OPEN, -- Pledge of Friendship: Thunder Bluff
	[22163] = ns.OPENING_OPEN, -- Pledge of Friendship: Undercity
	[13247] = ns.OPENING_OPEN, -- Quartermaster Zigris' Footlocker
	[189426] = ns.OPENING_OPEN, -- Raid Consumables
	[17969] = ns.OPENING_IGNORE_RAID, -- Red Sack of Gems (raid bosses: Azuregos, Onyxia, Nefarian, Lord Kazzak, ...)
	[13918] = ns.OPENING_UNLOCKED, -- Reinforced Locked Chest
	[4638] = ns.OPENING_UNLOCKED, -- Reinforced Steel Lockbox
	[6715] = ns.OPENING_OPEN, -- Ruined Jumper Cables
	[18636] = ns.OPENING_OPEN, -- Ruined Jumper Cables XL
	[11938] = ns.OPENING_OPEN, -- Sack of Gems
	[20601] = ns.OPENING_OPEN, -- Sack of Spoils
	[21156] = ns.OPENING_OPEN, -- Scarab Bag
	[7190] = ns.OPENING_OPEN, -- Scorched Rocket Boots
	[20767] = ns.OPENING_IGNORE, -- Scum Covered Bag (Bind on Pickup: Plans: Wicked Mithril Blade)
	[22568] = ns.OPENING_OPEN, -- Sealed Craftsman's Writ
	[6357] = ns.OPENING_OPEN, -- Sealed Crate
	[19152] = ns.OPENING_OPEN, -- Sentinel Advanced Care Package
	[19150] = ns.OPENING_OPEN, -- Sentinel Basic Care Package
	[19151] = ns.OPENING_OPEN, -- Sentinel Standard Care Package
	[20766] = ns.OPENING_OPEN, -- Slimy Bag
	[5523] = ns.OPENING_OPEN, -- Small Barnacled Clam
	[15699] = ns.OPENING_OPEN, -- Small Brown-wrapped Package
	[6353] = ns.OPENING_OPEN, -- Small Chest
	[6354] = ns.OPENING_UNLOCKED, -- Small Locked Chest
	[21740] = ns.OPENING_OPEN, -- Small Rocket Recipes
	[11966] = ns.OPENING_OPEN, -- Small Sack of Coins
	[21216] = ns.OPENING_OPEN, -- Smokywood Pastures Extra-Special Gift
	[17727] = ns.OPENING_OPEN, -- Smokywood Pastures Gift Pack
	[17685] = ns.OPENING_OPEN, -- Smokywood Pastures Sampler
	[17726] = ns.OPENING_OPEN, -- Smokywood Pastures Special Gift
	[21315] = ns.OPENING_IGNORE_UNIQUE, -- Smokywood Satchel (unique: Pouch of Reindeer Dust, Metzen's Letters and Notes)
	[15874] = ns.OPENING_OPEN, -- Soft-shelled Clam
	[9363] = ns.OPENING_OPEN, -- Sparklematic-Wrapped Box
	[4637] = ns.OPENING_UNLOCKED, -- Steel Lockbox
	[11442] = ns.OPENING_OPEN, -- Stormwind Deputy Kit
	[4636] = ns.OPENING_UNLOCKED, -- Strong Iron Lockbox
	[16884] = ns.OPENING_UNLOCKED, -- Sturdy Junkbox
	[6355] = ns.OPENING_UNLOCKED, -- Sturdy Locked Chest
	[23224] = ns.OPENING_OPEN, -- Summer Gift Package
	[20809] = ns.OPENING_IGNORE_UNIQUE, -- Tactical Assignment (unique: Tactical Task Briefing IX, Tactical Task Briefing VI, Tactical Task Briefing VII, ...)
	[7209] = ns.OPENING_UNLOCKED, -- Tazan's Satchel
	[7870] = ns.OPENING_OPEN, -- Thaumaturgy Vessel Lockbox
	[12033] = ns.OPENING_UNLOCKED, -- Thaurissan Family Jewels
	[5524] = ns.OPENING_OPEN, -- Thick-shelled Clam
	[7868] = ns.OPENING_UNLOCKED, -- Thieven' Kit
	[5759] = ns.OPENING_UNLOCKED, -- Thorium Lockbox
	[21327] = ns.OPENING_OPEN, -- Ticking Present
	[20708] = ns.OPENING_OPEN, -- Tightly Sealed Trunk
	[11568] = ns.OPENING_IGNORE_UNIQUE, -- Torwa's Pouch (unique: Preserved Threshadon Meat, Preserved Pheromone Mixture)
	[20393] = ns.OPENING_OPEN, -- Treat Bag
	[15102] = ns.OPENING_OPEN, -- Un'Goro Tested Sample
	[12339] = ns.OPENING_IGNORE_UNIQUE, -- Vaelan's Gift (unique: Orb of Draconic Energy, Unforged Seal of Ascension)
	[6352] = ns.OPENING_IGNORE, -- Waterlogged Crate (Bind on Pickup: Hammer of the Vesper)
	[21113] = ns.OPENING_OPEN, -- Watertight Trunk
	[16883] = ns.OPENING_UNLOCKED, -- Worn Junkbox
	[17965] = ns.OPENING_IGNORE_RAID, -- Yellow Sack of Gems (raid bosses: Azuregos, Onyxia, Nefarian, Lord Kazzak, ...)
	[22137] = ns.OPENING_OPEN, -- Ysida's Satchel
}

--[[
How We Got the Data

Last Validated
	2026-10-04, Classic Era 1.15.9.70003

Notes
	- Every item this client can open, and what Automated Opening does with each by default. The player's own changes, and the items they added or removed, live in ns.db.global.openingActions (Features/Openable-Items.lua).
	- The rows are every item this client flags Openable (Flags_0 & 0x4, the flag behind "<Right Click to Open>"), less bags and equippable items (InventoryType set), and less test and placeholder items named "Test", "QATest", "[DNT]", "[PH]", "[NYI]", "(TEMP)" or "Deprecated". README-Technical, Openable Items Data, gives the exact test.
	- Pulled from this client's own tables at build 1.15.9.69722.
	- The Classic Era tables carry Season of Discovery's items too, so an ID first seen after build 1.14.4.51829, the last before Season of Discovery launched, is Data/Discovery's alone.
	- Each row's default follows the maintainer's rules, in this order: ns.OPENING_IGNORE_RAID for a container that drops only from raid or world bosses; ns.OPENING_UNLOCKED for one with a lock; ns.OPENING_IGNORE_UNIQUE for one holding a Unique item that isn't gear; ns.OPENING_IGNORE for one holding a Bind on Pickup item while it can itself be traded; ns.OPENING_OPEN for the rest.
	- No client table records what a container holds or drops from, so those come from the CMaNGOS Classic world DB (ClassicDB_1_12_1_z2815), and where it can't tell, the maintainer's earlier call stands. A note after a row's name gives the evidence for an Ignore: the Unique items it can hold, the raid bosses it drops from, or the Bind on Pickup items inside. README-Technical describes the method.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=1.15.9.69722
]]
