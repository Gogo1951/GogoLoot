-- Data/Mainline/Lockbox-Skill-Levels-Mainline.lua
local _, ns = ...

--[[
    Required Lockpicking skill per locked container, for the tooltip line in
    Features/Lockbox-Tooltips.lua: one row for every ns.OPENABLE_ITEMS row
    whose lock a Rogue can pick. A locked item whose lock asks for something
    else, a key or another profession, has no row and so no tooltip line.

    Pulled from the Retail client's own tables on wago.tools, build
    12.1.0.69933: the item's ItemSparse LockID, then that
    Lock row's pick-lock entry (Type 2, Index 1), whose Skill is the number
    stored here.
    https://wago.tools/db2/Lock?build=12.1.0.69933

    Values are numbers and the tooltip formats them with %d, so a box with no
    number is absent from the table, never present with a stand-in value.

    -- TODO: Add SQL Query
]]
-- { [itemId] = requiredLockpickingSkill }
ns.LOCKBOX_SKILL_LEVELS = {
	[169475] = 50, -- Barnacled Lockbox
	[16882] = 15, -- Battered Junkbox
	[220376] = 75, -- Bismuth Lockbox
	[68729] = 30, -- Elementium Lockbox
	[5760] = 15, -- Eternium Lockbox
	[63349] = 30, -- Flame-Scarred Junkbox
	[198657] = 65, -- Forgotten Jewelry Box
	[43622] = 30, -- Froststeel Lockbox
	[88567] = 35, -- Ghost Iron Lockbox
	[4633] = 15, -- Heavy Bronze Lockbox
	[16885] = 15, -- Heavy Junkbox
	[4634] = 15, -- Iron Lockbox
	[106895] = 40, -- Iron-Bound Junkbox
	[13875] = 15, -- Ironbound Locked Chest
	[203743] = 15, -- Jostled Gurubashi Cache
	[31952] = 30, -- Khorium Lockbox
	[121331] = 45, -- Leystone Lockbox
	[186160] = 60, -- Locked Artifact Case
	[188787] = 60, -- Locked Broker Luggage
	[5758] = 15, -- Mithril Lockbox
	[4632] = 15, -- Ornate Bronze Lockbox
	[204307] = 15, -- Ornate Bronze Lockbox
	[180532] = 60, -- Oxxein Lockbox
	[180522] = 60, -- Phaedrum Lockbox
	[43575] = 30, -- Reinforced Junkbox
	[13918] = 15, -- Reinforced Locked Chest
	[4638] = 15, -- Reinforced Steel Lockbox
	[190954] = 65, -- Serevite Lockbox
	[6354] = 15, -- Small Locked Chest
	[180533] = 60, -- Solenium Lockbox
	[4637] = 15, -- Steel Lockbox
	[4636] = 15, -- Strong Iron Lockbox
	[29569] = 30, -- Strong Junkbox
	[16884] = 15, -- Sturdy Junkbox
	[6355] = 15, -- Sturdy Locked Chest
	[186161] = 60, -- Stygian Lockbox
	[179311] = 60, -- Synvir Lockbox
	[7209] = 1, -- Tazan's Satchel
	[12033] = 15, -- Thaurissan Family Jewels
	[5759] = 15, -- Thorium Lockbox
	[45986] = 30, -- Tiny Titanium Lockbox
	[43624] = 30, -- Titanium Lockbox
	[116920] = 40, -- True Steel Lockbox
	[264475] = 85, -- Umbral Tin Lockbox
	[88165] = 35, -- Vine-Cracked Junkbox
	[16883] = 15, -- Worn Junkbox
}
