local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

--[[
    Existence and shape checks only: read-only, no side effects, no protected
    calls. Modern and legacy fallbacks are separate rows, so a FAIL on one half
    shows which branch this client took.
]]
local function GlobalIsType(globalName, expectedType)
	return function()
		return type(_G[globalName]) == expectedType
	end
end

local function MemberIsFunction(namespaceName, memberName)
	return function()
		local namespace = _G[namespaceName]
		return type(namespace) == "table" and type(namespace[memberName]) == "function"
	end
end

ns.DIAGNOSTIC_API_CHECKS = {
	-- { label, testFunction }

	-- Add-on metadata — version, flavor, the Other Add-ons report, the Open Sesame check
	{
		"C_AddOns.GetAddOnMetadata",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnMetadata) == "function"
		end,
	},
	{ "C_AddOns.GetAddOnInfo", MemberIsFunction("C_AddOns", "GetAddOnInfo") },
	{ "C_AddOns.GetNumAddOns", MemberIsFunction("C_AddOns", "GetNumAddOns") },
	{ "C_AddOns.IsAddOnLoaded", MemberIsFunction("C_AddOns", "IsAddOnLoaded") },

	-- Season of Discovery detection — Flavor.lua
	{ "C_Seasons.GetActiveSeason", MemberIsFunction("C_Seasons", "GetActiveSeason") },
	{
		"Enum.SeasonID.SeasonOfDiscovery",
		function()
			return type(Enum) == "table" and type(Enum.SeasonID) == "table" and Enum.SeasonID.SeasonOfDiscovery ~= nil
		end,
	},

	-- Item info — Utilities.lua (SafeGetItemInfo, item parsing, list sorting)
	{
		"C_Item.GetItemInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemInfo) == "function"
		end,
	},
	{
		"C_Item.GetItemInfoInstant",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemInfoInstant) == "function"
		end,
	},
	-- Loot Toasts' Show Bag Count
	{ "C_Item.GetItemCount", MemberIsFunction("C_Item", "GetItemCount") },

	-- Core.lua's default-list seeding, the item lists' Add Item, and Validate Data
	{
		"C_Item.DoesItemExistByID",
		function()
			return type(C_Item) == "table" and type(C_Item.DoesItemExistByID) == "function"
		end,
	},
	-- Validate Data's loads and the item spell it reads: Diagnostics/Validate-Data.lua
	{
		"C_Item.RequestLoadItemDataByID",
		function()
			return type(C_Item) == "table" and type(C_Item.RequestLoadItemDataByID) == "function"
		end,
	},
	{
		"C_Item.GetItemSpell",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemSpell) == "function"
		end,
	},
	{
		"C_Spell.GetSpellDescription",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellDescription) == "function"
		end,
	},
	{
		"C_Spell.RequestLoadSpellData",
		function()
			return type(C_Spell) == "table" and type(C_Spell.RequestLoadSpellData) == "function"
		end,
	},
	{ "C_Spell.IsSpellDataCached", MemberIsFunction("C_Spell", "IsSpellDataCached") },
	-- ns.GetTooltipLines takes the data getters where the client ships both, else the hidden scan tooltip.
	{ "C_TooltipInfo.GetItemByID", MemberIsFunction("C_TooltipInfo", "GetItemByID") },
	{ "C_TooltipInfo.GetSpellByID", MemberIsFunction("C_TooltipInfo", "GetSpellByID") },
	{
		"Hidden scan tooltip (legacy)",
		function()
			return type(CreateFrame) == "function"
				and type(GameTooltip) == "table"
				and type(GameTooltip.SetHyperlink) == "function"
				and type(GameTooltip.NumLines) == "function"
		end,
	},
	-- Validate Data's other item reads; one a client lacks leaves its columns blank. ns.GetItemStats needs either half.
	{ "C_Item.GetDetailedItemLevelInfo", MemberIsFunction("C_Item", "GetDetailedItemLevelInfo") },
	{ "C_Item.GetItemStats", MemberIsFunction("C_Item", "GetItemStats") },
	{ "GetItemStats (legacy)", GlobalIsType("GetItemStats", "function") },
	-- Character Rules: suffix stats off the tooltip by link, and Gear Stats' equipped rows.
	{ "C_TooltipInfo.GetHyperlink", MemberIsFunction("C_TooltipInfo", "GetHyperlink") },
	{ "GetInventoryItemLink", GlobalIsType("GetInventoryItemLink", "function") },
	{ "C_Item.GetItemClassInfo", MemberIsFunction("C_Item", "GetItemClassInfo") },
	{ "C_Item.GetItemSubClassInfo", MemberIsFunction("C_Item", "GetItemSubClassInfo") },
	-- The "Equip:" opener the Equip-spell stat lines are matched behind; without it they match with no opener.
	{ "ITEM_SPELL_TRIGGER_ONEQUIP (string)", GlobalIsType("ITEM_SPELL_TRIGGER_ONEQUIP", "string") },

	-- Bag space — Speedy-Loot.lua free-slot budget
	{
		"C_Container.GetContainerNumFreeSlots",
		function()
			return type(C_Container) == "table" and type(C_Container.GetContainerNumFreeSlots) == "function"
		end,
	},
	{
		"NUM_BAG_SLOTS",
		function()
			return NUM_BAG_SLOTS ~= nil
		end,
	},

	-- Loot window — Speedy-Loot.lua / Master-Looter.lua
	{
		"GetNumLootItems",
		function()
			return type(GetNumLootItems) == "function"
		end,
	},
	{
		"GetLootSlotType",
		function()
			return type(GetLootSlotType) == "function"
		end,
	},
	{
		"LOOT_SLOT_ITEM",
		function()
			return LOOT_SLOT_ITEM ~= nil
		end,
	},
	{
		"GetLootSlotLink",
		function()
			return type(GetLootSlotLink) == "function"
		end,
	},
	{
		"GetLootSlotInfo",
		function()
			return type(GetLootSlotInfo) == "function"
		end,
	},
	{
		"LootSlot",
		function()
			return type(LootSlot) == "function"
		end,
	},
	{
		"IsModifiedClick",
		function()
			return type(IsModifiedClick) == "function"
		end,
	},
	-- Speedy Loot hides the window through this frame's OnShow hook; without it the window flashes.
	{ "LootFrame (frame)", GlobalIsType("LootFrame", "table") },
	-- Speedy Loot's bag-space budget: a bag's family, and the keyring where the client has one, each read either way.
	{ "C_Item.GetItemFamily", MemberIsFunction("C_Item", "GetItemFamily") },
	{ "GetItemFamily (legacy)", GlobalIsType("GetItemFamily", "function") },
	{ "KEYRING_CONTAINER (number)", GlobalIsType("KEYRING_CONTAINER", "number") },
	{ "IsKeyRingEnabled", GlobalIsType("IsKeyRingEnabled", "function") },
	{ "C_ActionBar.ShouldShowKeyring", MemberIsFunction("C_ActionBar", "ShouldShowKeyring") },

	-- Loot method & threshold — Utilities.lua / Master-Looter.lua master-loot guards
	{
		"GetLootMethod (legacy)",
		function()
			return type(GetLootMethod) == "function"
		end,
	},
	{
		"C_PartyInfo.GetLootMethod",
		function()
			return type(C_PartyInfo) == "table" and type(C_PartyInfo.GetLootMethod) == "function"
		end,
	},
	{
		"GetLootThreshold (legacy)",
		function()
			return type(GetLootThreshold) == "function"
		end,
	},
	{
		"C_PartyInfo.GetLootThreshold",
		function()
			return type(C_PartyInfo) == "table" and type(C_PartyInfo.GetLootThreshold) == "function"
		end,
	},
	{
		"SetLootMethod (legacy)",
		function()
			return type(SetLootMethod) == "function"
		end,
	},
	{
		"C_PartyInfo.SetLootMethod",
		function()
			return type(C_PartyInfo) == "table" and type(C_PartyInfo.SetLootMethod) == "function"
		end,
	},
	{
		"SetLootThreshold (legacy)",
		function()
			return type(SetLootThreshold) == "function"
		end,
	},
	{
		"C_PartyInfo.SetLootThreshold",
		function()
			return type(C_PartyInfo) == "table" and type(C_PartyInfo.SetLootThreshold) == "function"
		end,
	},
	{
		"Enum.LootMethod.Masterlooter",
		function()
			return type(Enum) == "table" and type(Enum.LootMethod) == "table" and Enum.LootMethod.Masterlooter ~= nil
		end,
	},

	-- Master loot distribution — Master-Looter.lua
	{
		"GetMasterLootCandidate",
		function()
			return type(GetMasterLootCandidate) == "function"
		end,
	},
	{
		"GiveMasterLoot",
		function()
			return type(GiveMasterLoot) == "function"
		end,
	},
	{
		"hooksecurefunc",
		function()
			return type(hooksecurefunc) == "function"
		end,
	},

	-- Need / Greed rolls — Automated-Rolls.lua
	{
		"GetLootRollItemInfo",
		function()
			return type(GetLootRollItemInfo) == "function"
		end,
	},
	{
		"GetLootRollItemLink",
		function()
			return type(GetLootRollItemLink) == "function"
		end,
	},
	{
		"RollOnLoot",
		function()
			return type(RollOnLoot) == "function"
		end,
	},
	{
		"ConfirmLootRoll",
		function()
			return type(ConfirmLootRoll) == "function"
		end,
	},

	-- Trade — Announcements-Trade.lua
	{
		"GetTradePlayerItemLink",
		function()
			return type(GetTradePlayerItemLink) == "function"
		end,
	},
	{
		"GetTradeTargetItemLink",
		function()
			return type(GetTradeTargetItemLink) == "function"
		end,
	},
	{
		"GetTradePlayerItemInfo",
		function()
			return type(GetTradePlayerItemInfo) == "function"
		end,
	},
	{
		"GetTradeTargetItemInfo",
		function()
			return type(GetTradeTargetItemInfo) == "function"
		end,
	},
	{
		"GetPlayerTradeMoney",
		function()
			return type(GetPlayerTradeMoney) == "function"
		end,
	},
	{
		"GetTargetTradeMoney",
		function()
			return type(GetTargetTradeMoney) == "function"
		end,
	},

	-- Group & instance state — multiple modules
	{
		"IsInGroup",
		function()
			return type(IsInGroup) == "function"
		end,
	},
	{
		"IsInRaid",
		function()
			return type(IsInRaid) == "function"
		end,
	},
	{
		"UnitInRaid",
		function()
			return type(UnitInRaid) == "function"
		end,
	},
	{
		"UnitIsGroupLeader",
		function()
			return type(UnitIsGroupLeader) == "function"
		end,
	},
	{
		"GetNumGroupMembers",
		function()
			return type(GetNumGroupMembers) == "function"
		end,
	},
	{
		"GetInstanceInfo",
		function()
			return type(GetInstanceInfo) == "function"
		end,
	},

	-- Auto-loot CVar — Auto-Loot.lua / Utilities.lua; SetCVar and GetCVar are Diagnostics' own
	{
		"C_CVar.GetCVarBool",
		function()
			return type(C_CVar) == "table" and type(C_CVar.GetCVarBool) == "function"
		end,
	},
	{
		"C_CVar.SetCVar",
		function()
			return type(C_CVar) == "table" and type(C_CVar.SetCVar) == "function"
		end,
	},
	{
		"SetCVar",
		function()
			return type(SetCVar) == "function"
		end,
	},
	{
		"GetCVar",
		function()
			return type(GetCVar) == "function"
		end,
	},

	-- Chat — Announcements.lua
	{
		"C_ChatInfo.SendChatMessage",
		function()
			return type(C_ChatInfo) == "table" and type(C_ChatInfo.SendChatMessage) == "function"
		end,
	},
	-- Raid Roll Winner's claim, sent and heard on the group's add-on channel — Raid-Roll-Winner.lua
	{ "C_ChatInfo.SendAddonMessage", MemberIsFunction("C_ChatInfo", "SendAddonMessage") },
	{ "C_ChatInfo.RegisterAddonMessagePrefix", MemberIsFunction("C_ChatInfo", "RegisterAddonMessagePrefix") },
	-- The /roll line it reads back, and the raid list it counts the winner down
	{ "RANDOM_ROLL_RESULT (string)", GlobalIsType("RANDOM_ROLL_RESULT", "string") },
	{ "GetRaidRosterInfo", GlobalIsType("GetRaidRosterInfo", "function") },

	-- Timers & events — Core.lua / Master-Looter.lua / Diagnostic Tools
	{
		"C_Timer.After",
		function()
			return type(C_Timer) == "table" and type(C_Timer.After) == "function"
		end,
	},
	{
		"C_Timer.NewTicker",
		function()
			return type(C_Timer) == "table" and type(C_Timer.NewTicker) == "function"
		end,
	},
	{
		"C_EventUtils.IsEventValid",
		function()
			return type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function"
		end,
	},
	-- Core.lua's dispatcher runs every handler through it, so one handler's error never stops the rest.
	{ "securecallfunction", GlobalIsType("securecallfunction", "function") },
	-- The group channel an announcement goes to — Announcements.lua
	{ "LE_PARTY_CATEGORY_INSTANCE (number)", GlobalIsType("LE_PARTY_CATEGORY_INSTANCE", "number") },

	-- Master-loot errors and trade results match on ids resolved through this; Loot Method shows which resolved.
	{
		"GetGameMessageInfo",
		function()
			return type(GetGameMessageInfo) == "function"
		end,
	},

	-- Trade result text — Announcements-Trade.lua, only for a client where neither constant resolved to an id
	{
		"ERR_TRADE_COMPLETE",
		function()
			return ERR_TRADE_COMPLETE ~= nil
		end,
	},
	{
		"ERR_TRADE_CANCELLED",
		function()
			return ERR_TRADE_CANCELLED ~= nil
		end,
	},

	-- Automated Opening — Automated-Opening.lua: the bag walk, the open, and the safety gates
	{ "C_Container.GetContainerNumSlots", MemberIsFunction("C_Container", "GetContainerNumSlots") },
	{ "C_Container.GetContainerItemID", MemberIsFunction("C_Container", "GetContainerItemID") },
	{ "C_Container.GetContainerItemLink", MemberIsFunction("C_Container", "GetContainerItemLink") },
	{ "C_Container.UseContainerItem", MemberIsFunction("C_Container", "UseContainerItem") },
	-- The item lists' Add from Bags counts a stack through it — Options-Utilities-Item-Lists.lua
	{ "C_Container.GetContainerItemInfo", MemberIsFunction("C_Container", "GetContainerItemInfo") },
	{ "C_UnitAuras.GetPlayerAuraBySpellID", MemberIsFunction("C_UnitAuras", "GetPlayerAuraBySpellID") },
	{ "C_Secrets.ShouldSpellAuraBeSecret", MemberIsFunction("C_Secrets", "ShouldSpellAuraBeSecret") },
	{ "C_Secrets.ShouldUnitSpellCastingBeSecret", MemberIsFunction("C_Secrets", "ShouldUnitSpellCastingBeSecret") },
	{ "UnitAffectingCombat", GlobalIsType("UnitAffectingCombat", "function") },
	-- The open tick waits these out: a spell waiting for its target, an item on the cursor, an item tooltip.
	{ "SpellIsTargeting", GlobalIsType("SpellIsTargeting", "function") },
	{ "CursorHasItem", GlobalIsType("CursorHasItem", "function") },
	{ "GameTooltip.GetItem", MemberIsFunction("GameTooltip", "GetItem") },
	-- The roll preview hooks through this where the client has it, else OnTooltipSetItem — Roll-Preview-Tooltip.lua
	{ "TooltipDataProcessor.AddTooltipPostCall", MemberIsFunction("TooltipDataProcessor", "AddTooltipPostCall") },
	{
		"Enum.TooltipDataType.Item",
		function()
			return type(Enum) == "table" and type(Enum.TooltipDataType) == "table" and Enum.TooltipDataType.Item ~= nil
		end,
	},
	-- The tooltip a clicked item link opens, the preview's other tooltip
	{ "ItemRefTooltip (frame)", GlobalIsType("ItemRefTooltip", "table") },
	{ "UnitCastingInfo", GlobalIsType("UnitCastingInfo", "function") },
	{ "UnitChannelInfo", GlobalIsType("UnitChannelInfo", "function") },
	{ "IsStealthed", GlobalIsType("IsStealthed", "function") },
	{ "IsInInstance", GlobalIsType("IsInInstance", "function") },
	{ "UnitRace", GlobalIsType("UnitRace", "function") },
	{ "UnitSex", GlobalIsType("UnitSex", "function") },
	{ "PlaySound", GlobalIsType("PlaySound", "function") },
	{ "PlaySoundFile", GlobalIsType("PlaySoundFile", "function") },
	-- A number on every target client, which is what ns.IsBagFullErrorID compares against.
	{ "LE_GAME_ERR_INV_FULL (number)", GlobalIsType("LE_GAME_ERR_INV_FULL", "number") },
	-- Speedy Loot also stops on a unique item already carried; a client without it never matches that error.
	{ "LE_GAME_ERR_ITEM_MAX_COUNT (number)", GlobalIsType("LE_GAME_ERR_ITEM_MAX_COUNT", "number") },
	-- Secret values exist only on WoW Forever and later clients, so a FAIL is expected on the others.
	{ "issecretvalue", GlobalIsType("issecretvalue", "function") },
	-- The scan tooltip reads this whole line to tell a locked box from an open one.
	{ "LOCKED (string)", GlobalIsType("LOCKED", "string") },

	-- Loot Sounds and Speedy Loot — the loot window's source and slot kinds
	{ "GetLootSourceInfo", GlobalIsType("GetLootSourceInfo", "function") },
	{
		"Enum.LootSlotType.Item (FAIL means LOOT_SLOT_ITEM is in use)",
		function()
			return type(Enum) == "table" and type(Enum.LootSlotType) == "table" and Enum.LootSlotType.Item ~= nil
		end,
	},

	-- The client's own formats, read back out of loot and money messages — Utilities-Chat-Lines.lua
	{ "LOOT_ITEM_SELF (string)", GlobalIsType("LOOT_ITEM_SELF", "string") },
	{ "LOOT_ITEM_SELF_MULTIPLE (string)", GlobalIsType("LOOT_ITEM_SELF_MULTIPLE", "string") },
	{ "LOOT_ITEM_PUSHED_SELF (string)", GlobalIsType("LOOT_ITEM_PUSHED_SELF", "string") },
	{ "LOOT_ITEM_PUSHED_SELF_MULTIPLE (string)", GlobalIsType("LOOT_ITEM_PUSHED_SELF_MULTIPLE", "string") },
	{ "LOOT_ITEM (string)", GlobalIsType("LOOT_ITEM", "string") },
	{ "LOOT_ITEM_MULTIPLE (string)", GlobalIsType("LOOT_ITEM_MULTIPLE", "string") },
	{ "LOOT_ITEM_PUSHED (string)", GlobalIsType("LOOT_ITEM_PUSHED", "string") },
	{ "LOOT_ITEM_PUSHED_MULTIPLE (string)", GlobalIsType("LOOT_ITEM_PUSHED_MULTIPLE", "string") },
	{ "GOLD_AMOUNT (string)", GlobalIsType("GOLD_AMOUNT", "string") },
	{ "SILVER_AMOUNT (string)", GlobalIsType("SILVER_AMOUNT", "string") },
	{ "COPPER_AMOUNT (string)", GlobalIsType("COPPER_AMOUNT", "string") },
	{ "GOLD_AMOUNT_SYMBOL (string)", GlobalIsType("GOLD_AMOUNT_SYMBOL", "string") },
	{ "SILVER_AMOUNT_SYMBOL (string)", GlobalIsType("SILVER_AMOUNT_SYMBOL", "string") },
	{ "COPPER_AMOUNT_SYMBOL (string)", GlobalIsType("COPPER_AMOUNT_SYMBOL", "string") },
	-- Currency toasts — Loot-Toasts-Money.lua. Currency arrived with Cataclysm, so a FAIL is expected before it.
	{ "CURRENCY_GAINED (string)", GlobalIsType("CURRENCY_GAINED", "string") },
	{ "CURRENCY_GAINED_MULTIPLE (string)", GlobalIsType("CURRENCY_GAINED_MULTIPLE", "string") },
	{ "CURRENCY_GAINED_MULTIPLE_BONUS (string)", GlobalIsType("CURRENCY_GAINED_MULTIPLE_BONUS", "string") },
	{ "C_CurrencyInfo.GetCurrencyInfo", MemberIsFunction("C_CurrencyInfo", "GetCurrencyInfo") },

	-- The core roll lines every client prints — Utilities-Chat-Lines.lua; a FAIL means that line goes unread there.
	{ "LOOT_ROLL_NEED (string)", GlobalIsType("LOOT_ROLL_NEED", "string") },
	{ "LOOT_ROLL_GREED (string)", GlobalIsType("LOOT_ROLL_GREED", "string") },
	{ "LOOT_ROLL_PASSED (string)", GlobalIsType("LOOT_ROLL_PASSED", "string") },
	{ "LOOT_ROLL_ROLLED_NEED (string)", GlobalIsType("LOOT_ROLL_ROLLED_NEED", "string") },
	{ "LOOT_ROLL_ROLLED_GREED (string)", GlobalIsType("LOOT_ROLL_ROLLED_GREED", "string") },
	{ "LOOT_ROLL_WON (string)", GlobalIsType("LOOT_ROLL_WON", "string") },
	{ "LOOT_ROLL_YOU_WON (string)", GlobalIsType("LOOT_ROLL_YOU_WON", "string") },
	-- Roll Audit lists a roll everyone passed on from this line — Roll-Audit.lua
	{ "LOOT_ROLL_ALL_PASSED (string)", GlobalIsType("LOOT_ROLL_ALL_PASSED", "string") },
	{ "NEED (string)", GlobalIsType("NEED", "string") },
	{ "GREED (string)", GlobalIsType("GREED", "string") },
	-- Hide Roll Messages — Roll-Messages.lua
	{ "ChatFrameUtil.AddMessageEventFilter", MemberIsFunction("ChatFrameUtil", "AddMessageEventFilter") },
	{ "ChatFrame_AddMessageEventFilter (legacy)", GlobalIsType("ChatFrame_AddMessageEventFilter", "function") },
	-- Standard Loot Messages flips the General tab's loot lines through its message groups.
	{ "ChatFrame1.ContainsMessageGroup", MemberIsFunction("ChatFrame1", "ContainsMessageGroup") },
	{ "ChatFrame1.AddMessageGroup", MemberIsFunction("ChatFrame1", "AddMessageGroup") },
	{ "ChatFrame1.RemoveMessageGroup", MemberIsFunction("ChatFrame1", "RemoveMessageGroup") },
	-- Blizzard Roll Winner Window off stops the game's own alert listening for a won roll — Standard-Loot-Messages.lua
	{ "AlertFrame.IsEventRegistered", MemberIsFunction("AlertFrame", "IsEventRegistered") },

	--[[
	    Tradable Gear Tint — Tint-Tradable-Gear.lua: the tooltip's trade clock
	    and the bag redraw it hooks, legacy or modern frames, so a FAIL on one
	    of that pair is expected.
	]]
	{ "BIND_TRADE_TIME_REMAINING (string)", GlobalIsType("BIND_TRADE_TIME_REMAINING", "string") },
	{ "INT_SPELL_DURATION_HOURS (string)", GlobalIsType("INT_SPELL_DURATION_HOURS", "string") },
	{ "INT_SPELL_DURATION_MIN (string)", GlobalIsType("INT_SPELL_DURATION_MIN", "string") },
	{ "INT_SPELL_DURATION_SEC (string)", GlobalIsType("INT_SPELL_DURATION_SEC", "string") },
	{ "ContainerFrame_Update", GlobalIsType("ContainerFrame_Update", "function") },
	{ "ContainerFrameCombinedBags.UpdateItems", MemberIsFunction("ContainerFrameCombinedBags", "UpdateItems") },
	{ "NUM_CONTAINER_FRAMES (number)", GlobalIsType("NUM_CONTAINER_FRAMES", "number") },
	{ "GetServerTime", GlobalIsType("GetServerTime", "function") },

	-- Automated Opening's Fishing Pole hold-off; Data.lua falls back to fixed numbers.
	{
		"Enum.ItemWeaponSubclass.Fishingpole",
		function()
			return type(Enum) == "table"
				and type(Enum.ItemWeaponSubclass) == "table"
				and Enum.ItemWeaponSubclass.Fishingpole ~= nil
		end,
	},
	{ "LE_ITEM_WEAPON_FISHINGPOLE (number)", GlobalIsType("LE_ITEM_WEAPON_FISHINGPOLE", "number") },
	{ "INVSLOT_MAINHAND (number)", GlobalIsType("INVSLOT_MAINHAND", "number") },

	-- The Loot Toasts Quest row's quest-starter read — Utilities-Scan-Tooltip.lua
	{ "ITEM_STARTS_QUEST (string)", GlobalIsType("ITEM_STARTS_QUEST", "string") },
	-- Data.lua's ns.ITEM_CLASS_*: Enum.ItemClass first, then the legacy globals, then a fixed number.
	{ "LE_ITEM_CLASS_ARMOR (number)", GlobalIsType("LE_ITEM_CLASS_ARMOR", "number") },
	{
		"Enum.ItemClass",
		function()
			return type(Enum) == "table" and type(Enum.ItemClass) == "table"
		end,
	},
	-- The bind types and the Mount and Companion Pets subclasses: the enum, else a fixed number.
	{
		"Enum.ItemBind",
		function()
			return type(Enum) == "table" and type(Enum.ItemBind) == "table"
		end,
	},
	{
		"Enum.ItemMiscellaneousSubclass",
		function()
			return type(Enum) == "table" and type(Enum.ItemMiscellaneousSubclass) == "table"
		end,
	},
	-- The group context names — Minimap-Menu.lua, Roll-Preview-Tooltip.lua
	{ "PARTY (string)", GlobalIsType("PARTY", "string") },
	{ "RAID (string)", GlobalIsType("RAID", "string") },
	-- A group member's name on a toast takes their class color from here; without it the name reads silver.
	{ "RAID_CLASS_COLORS (table)", GlobalIsType("RAID_CLASS_COLORS", "table") },
	-- The client's own labels the options and messages show — Data.lua, the Options panels, Automated-Opening.lua
	{ "ITEM_QUALITY0_DESC (string)", GlobalIsType("ITEM_QUALITY0_DESC", "string") },
	{ "ITEM_QUALITY1_DESC (string)", GlobalIsType("ITEM_QUALITY1_DESC", "string") },
	{ "ITEM_QUALITY2_DESC (string)", GlobalIsType("ITEM_QUALITY2_DESC", "string") },
	{ "ITEM_QUALITY3_DESC (string)", GlobalIsType("ITEM_QUALITY3_DESC", "string") },
	{ "ITEM_QUALITY4_DESC (string)", GlobalIsType("ITEM_QUALITY4_DESC", "string") },
	{ "PASS (string)", GlobalIsType("PASS", "string") },
	{ "LOOT_METHOD (string)", GlobalIsType("LOOT_METHOD", "string") },
	{ "LOOT_THRESHOLD (string)", GlobalIsType("LOOT_THRESHOLD", "string") },
	{ "LOOT_FREE_FOR_ALL (string)", GlobalIsType("LOOT_FREE_FOR_ALL", "string") },
	{ "LOOT_ROUND_ROBIN (string)", GlobalIsType("LOOT_ROUND_ROBIN", "string") },
	{ "LOOT_MASTER_LOOTER (string)", GlobalIsType("LOOT_MASTER_LOOTER", "string") },
	{ "LOOT_GROUP_LOOT (string)", GlobalIsType("LOOT_GROUP_LOOT", "string") },
	{ "LOOT_NEED_BEFORE_GREED (string)", GlobalIsType("LOOT_NEED_BEFORE_GREED", "string") },
	-- Personal Loot joins the Loot Method dropdown only where the client has both.
	{
		"Enum.LootMethod.Personal",
		function()
			return type(Enum) == "table" and type(Enum.LootMethod) == "table" and Enum.LootMethod.Personal ~= nil
		end,
	},
	{ "LOOT_PERSONAL_LOOT (string)", GlobalIsType("LOOT_PERSONAL_LOOT", "string") },
	{ "ERR_INV_FULL (string)", GlobalIsType("ERR_INV_FULL", "string") },
	{ "WHISPER (string)", GlobalIsType("WHISPER", "string") },
	{ "MONEY (string)", GlobalIsType("MONEY", "string") },
	-- The Rogue's class name in the Lockboxes text and the Locked reason
	{ "LOCALIZED_CLASS_NAMES_MALE (table)", GlobalIsType("LOCALIZED_CLASS_NAMES_MALE", "table") },
	--[[
	    Proves bindType's return position: a FAIL with the Hearthstone cached
	    means the Bind on Pickup reads take the wrong return on this client.
	]]
	{
		"C_Item.GetItemInfo bindType (14th return) on the Hearthstone",
		function()
			return select(14, C_Item.GetItemInfo(ns.ITEM_IDS.BIND_PROBE)) == ns.BIND_ON_PICKUP
		end,
	},
	{
		"LibSharedMedia-3.0 fonts",
		function()
			return #LibStub("LibSharedMedia-3.0"):List("font") > 0
		end,
	},
	{ "GetPhysicalScreenSize", GlobalIsType("GetPhysicalScreenSize", "function") },

	-- Lockbox Tooltips — Lockbox-Tooltips.lua: the hook, the client's requirement line, and the line it adds
	{ "GameTooltip.SetBagItem", MemberIsFunction("GameTooltip", "SetBagItem") },
	{ "ITEM_MIN_SKILL (string)", GlobalIsType("ITEM_MIN_SKILL", "string") },
	{ "ITEM_REQ_SKILL (string)", GlobalIsType("ITEM_REQ_SKILL", "string") },
	-- The Pick Pocket sound's caption on the Loot Sounds panel
	{ "C_Spell.GetSpellName", MemberIsFunction("C_Spell", "GetSpellName") },
	{ "C_TradeSkillUI.GetTradeSkillDisplayName", MemberIsFunction("C_TradeSkillUI", "GetTradeSkillDisplayName") },
	-- WoW Forever has no skill-line API, so a FAIL on the next two is expected there.
	{ "GetNumSkillLines", GlobalIsType("GetNumSkillLines", "function") },
	{ "GetSkillLineInfo", GlobalIsType("GetSkillLineInfo", "function") },

	-- Roll Macro — Roll-Macro.lua keeps the General macro, and waits out combat to change it
	{ "GetMacroIndexByName", GlobalIsType("GetMacroIndexByName", "function") },
	{ "GetMacroInfo", GlobalIsType("GetMacroInfo", "function") },
	{ "CreateMacro", GlobalIsType("CreateMacro", "function") },
	{ "EditMacro", GlobalIsType("EditMacro", "function") },
	{ "DeleteMacro", GlobalIsType("DeleteMacro", "function") },
	{ "InCombatLockdown", GlobalIsType("InCombatLockdown", "function") },
	-- What the macro's own text calls when it's clicked (ns.ROLL_MACRO_BODY)
	{ "GetMouseButtonClicked", GlobalIsType("GetMouseButtonClicked", "function") },
	{ "RandomRoll", GlobalIsType("RandomRoll", "function") },

	-- Opening the options panel — Options.lua
	{ "Settings.OpenToCategory", MemberIsFunction("Settings", "OpenToCategory") },
	-- Closing it ends the item lists' New sections — Options.lua
	{ "SettingsPanel (frame)", GlobalIsType("SettingsPanel", "table") },
	-- Nested panels: the vendored AceConfigDialog finds a child panel's parent by its category ID
	{ "Settings.GetCategory", MemberIsFunction("Settings", "GetCategory") },
	-- The item lists' drop box takes the item held on the cursor — Options-Utilities-Item-List-Widgets.lua
	{ "GetCursorInfo", GlobalIsType("GetCursorInfo", "function") },
	{ "ClearCursor", GlobalIsType("ClearCursor", "function") },
	-- The Example lines take the client's chat colors and line openers, else fixed fallbacks — Options-Utilities.lua
	{ "ChatTypeInfo (table)", GlobalIsType("ChatTypeInfo", "table") },
	{ "CHAT_PARTY_GET (string)", GlobalIsType("CHAT_PARTY_GET", "string") },
	{ "CHAT_WHISPER_GET (string)", GlobalIsType("CHAT_WHISPER_GET", "string") },
}

--------------------------------------------------------------------------------
-- Add-on Context Probes
--------------------------------------------------------------------------------

--[[
    Probes read state through the feature files' own accessors, so a report
    shows the values the features act on; where a gate is private, they print
    its inputs.
]]

-- The add-on's own example reports, appended to the shared Event Log intro.
ns.DiagnosticsStrings.EVENT_LOG_EXAMPLES =
	"Best for 'nothing got looted' or 'it never opened' reports. Combat and UI message spam GogoLoot doesn't act on is counted, not listed."

local function OnOff(value)
	return value and "on" or "off"
end

local function YesNo(value)
	return value and "yes" or "no"
end

-- An item link as copyable text: pipes escaped so it pastes rather than renders.
local function LinkCell(link)
	return link and (tostring(link):gsub("|", "||")) or ""
end

local function AppendProfileLines(lines)
	lines[#lines + 1] = string.format(
		"Profile: %s // Character: %s",
		tostring(ns.db and ns.db.keys and ns.db.keys.profile),
		tostring(ns.db and ns.db.keys and ns.db.keys.char)
	)
	local _, classFile = UnitClass("player")
	local _, raceFile = UnitRace("player")
	lines[#lines + 1] = string.format(
		"Player: %s %s level %s, in combat: %s",
		tostring(raceFile),
		tostring(classFile),
		tostring(UnitLevel("player")),
		YesNo(InCombatLockdown())
	)
end

local function AppendAutoLootLine(lines)
	lines[#lines + 1] = string.format(
		"Auto Loot (autoLootDefault CVar): raw %s, as GogoLoot reads it %s, enforced while Speedy Loot or Automated Opening is on: %s",
		tostring(GetCVar("autoLootDefault")),
		tostring(ns:IsAutoLootCVarEnabled()),
		YesNo(ns:IsAutoLootNeeded())
	)
end

local function AppendFreeSlotsLine(lines)
	lines[#lines + 1] = string.format(
		"Free general bag slots: %d (opening pauses below %d, and Speedy Loot keeps the loot window up below it)",
		ns.CountFreeBagSlots(),
		ns.MIN_FREE_SLOTS
	)
end

local function BagItemLinks()
	local links = {}
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) or 0 do
			local link = C_Container.GetContainerItemLink(bagIndex, slotIndex)
			if link then
				links[#links + 1] = link
			end
		end
	end
	return links
end

ns.DiagnosticBagItemLinks = BagItemLinks

--------------------------------------------------------------------------------
-- Loot Method
--------------------------------------------------------------------------------

--[[
    An existence check can't prove the loot-method APIs return the shapes
    GogoLoot's guards expect, so this prints their actual returns and how
    GogoLoot reads them. Read-only.
]]

local function PackReturns(...)
	return select("#", ...), { ... }
end

-- Sorted, so two clients' reports diff cleanly. `describe` gives each table's trailing note.
---@param lines table
---@param heading string
---@param constants table
---@param resolvedIds table
---@param describe function
---@return nil
local function AppendResolvedIdLines(lines, heading, constants, resolvedIds, describe)
	lines[#lines + 1] = heading

	local constantNames = {}
	for constantName in pairs(constants) do
		constantNames[#constantNames + 1] = constantName
	end
	table.sort(constantNames)

	for _, constantName in ipairs(constantNames) do
		lines[#lines + 1] = string.format(
			"  %s = %s (%s)",
			constantName,
			tostring(resolvedIds[constantName] or "NOT FOUND"),
			describe(constants[constantName])
		)
	end
end

-- Must match the timer names in Features/Master-Looter.lua: ns:IsTimerPending reads them by name.
local ZONE_SETTLE_TIMER = "GogoLoot.MasterLooter.ZoneSettle"
local LOGIN_SOLO_TIMER = "GogoLoot.MasterLooter.LoginSolo"

-- Tradable Gear Tint (Features/Tint-Tradable-Gear.lua). An alpha of 0 draws nothing; no trade clock means Soulbound.
local function AppendTradableTintLines(lines, profile)
	local color = profile.tradableTintColor or {}
	local hooked = ns.GetTradableTintAdapterNames and ns:GetTradableTintAdapterNames() or {}
	lines[#lines + 1] = string.format(
		"Tradable Gear Tint: %s, color r=%s g=%s b=%s a=%s, bag windows hooked: %s",
		OnOff(profile.tradableTintEnabled),
		tostring(color.r),
		tostring(color.g),
		tostring(color.b),
		tostring(color.a),
		#hooked > 0 and table.concat(hooked, ", ") or "none"
	)
	-- The slot's bound flag and quality first, as PaintButton reads them; an unloaded item gets no tint until it loads.
	local read = {}
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) or 0 do
			local slot = C_Container.GetContainerItemInfo(bagIndex, slotIndex)
			local link = slot and slot.hyperlink
			local canQualify = link
				and slot.isBound ~= false
				and not (slot.quality and slot.quality < ns.TRADABLE_MIN_QUALITY)
			local info = canQualify and ns:SafeGetItemInfo(link)
			local verdict
			if canQualify and not info then
				verdict = "not loaded yet, no tint"
			elseif info and (info.quality or 0) >= ns.TRADABLE_MIN_QUALITY and info.bindType == ns.BIND_ON_PICKUP then
				local seconds = ns.GetBagSlotTradeSeconds(bagIndex, slotIndex)
				verdict = seconds and string.format("trade clock %ds, gets the tint", seconds)
					or "no trade clock, no tint"
			end
			if verdict then
				read[#read + 1] = string.format(
					"  bag %d slot %d %s (isBound %s, quality %s): %s",
					bagIndex,
					slotIndex,
					LinkCell(link),
					tostring(slot.isBound),
					tostring(slot.quality),
					verdict
				)
			end
		end
	end
	lines[#lines + 1] = string.format(
		"  Bind on Pickup or not-yet-loaded items it reads in the bags (quality %d and up): %d",
		ns.TRADABLE_MIN_QUALITY,
		#read
	)
	for _, line in ipairs(read) do
		lines[#lines + 1] = line
	end
end

-- What Automated Master Looting reads before it hands anything out.
local function AppendMasterLootSettings(lines)
	local _, instanceType = GetInstanceInfo()
	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format(
		"Group: in group %s, in raid %s, %d members, you lead %s (leader: %s), instance type %s",
		YesNo(IsInGroup()),
		YesNo(IsInRaid()),
		GetNumGroupMembers(),
		YesNo(ns:IsGroupLeader()),
		tostring(ns:GetGroupLeaderName()),
		tostring(instanceType)
	)
	lines[#lines + 1] = string.format(
		"Loading-screen guard settling (loot state ignored for a moment): %s",
		YesNo(ns:IsTimerPending(ZONE_SETTLE_TIMER))
	)
	-- A login that settles solo clears every destination (ClearDestinationsIfSoloAtLogin in Features/Master-Looter.lua).
	lines[#lines + 1] = string.format(
		"Login solo check waiting (clears the destinations if you're still solo when it runs): %s",
		YesNo(ns:IsTimerPending(LOGIN_SOLO_TIMER))
	)

	local profile = ns.db and ns.db.profile
	if not profile then
		lines[#lines + 1] = "(saved variables not loaded)"
		return
	end
	lines[#lines + 1] = string.format(
		"Automated Master Looting: %s, outside instances %s, quest items %s, master looter pop-up %s",
		OnOff(profile.autoMasterLoot),
		OnOff(profile.autoMasterLootOutsideInstances),
		OnOff(profile.autoMasterLootQuestItems),
		OnOff(profile.masterLooterPopup)
	)
	AppendTradableTintLines(lines, profile)
	lines[#lines + 1] =
		string.format("Ignore List: %d items, never handed out automatically", CountKeys(profile.ignoredItemsMaster))
	lines[#lines + 1] = "Destinations (quality = recipient, reached by the loot threshold):"
	for quality = 0, 4 do
		local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[quality]
		local destination = profile.destinations[qualityKey]
		lines[#lines + 1] = string.format(
			"  %s = %s, reached %s",
			qualityKey,
			(destination == nil or destination == "") and "unset (Loot Window)" or tostring(destination),
			YesNo(ns:IsQualityReachable(quality))
		)
	end
end

--[[
    Keyed as BuildCandidateMap (Features/Master-Looter-Distribution.lua) keys
    them: the lowercased full name, plus the realm-stripped name only where
    one candidate carries it.
]]
local function SlotCandidates(slotIndex)
	local candidates, names, normalizedCounts = {}, {}, {}
	for groupIndex = 1, GetNumGroupMembers() do
		local candidateName = GetMasterLootCandidate(slotIndex, groupIndex)
		if candidateName then
			names[#names + 1] = candidateName
			candidates[strlower(candidateName)] = true
			local normalizedName = ns:NormalizePlayerName(candidateName)
			if normalizedName then
				normalizedCounts[normalizedName] = (normalizedCounts[normalizedName] or 0) + 1
			end
		end
	end
	for normalizedName, nameCount in pairs(normalizedCounts) do
		if nameCount == 1 then
			candidates[normalizedName] = true
		end
	end
	return candidates, names
end

-- Checks in TryDistributeSlot's order (Features/Master-Looter-Distribution.lua); keep the two in step.
local function MasterLootSlotVerdict(profile, itemInformation, itemIdentifier, candidates)
	if not itemInformation then
		return "NOT CACHED (the pass waits for it)"
	end
	if ns:IsNeverAutomatedItem(itemInformation) then
		return "NEVER AUTOMATED"
	end
	if not profile.autoMasterLootQuestItems and ns:IsQuestClassItem(itemInformation) then
		return "QUEST ITEM"
	end
	if profile.ignoredItemsMaster[itemIdentifier] then
		return "IGNORE LIST"
	end
	local _, instanceType = GetInstanceInfo()
	if itemInformation.bindType == ns.BIND_ON_PICKUP and instanceType ~= "raid" and instanceType ~= "party" then
		return "BIND ON PICKUP OUTSIDE AN INSTANCE"
	end
	local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[itemInformation.quality]
	if not qualityKey then
		return "QUALITY HAS NO DESTINATION"
	end
	if not ns:IsQualityReachable(itemInformation.quality) then
		return "BELOW LOOT THRESHOLD"
	end
	local destination = profile.destinations[qualityKey]
	if destination == nil or destination == "" then
		return "NO DESTINATION (Loot Window)"
	end
	local resolvedName = destination == "self" and ns:GetLowercaseUnitName("player") or destination
	local lookupKey = resolvedName and ns:NormalizePlayerName(resolvedName)
	if not (lookupKey and candidates[lookupKey]) and not (resolvedName and candidates[strlower(resolvedName)]) then
		return "DESTINATION " .. tostring(resolvedName) .. " NOT A CANDIDATE"
	end
	return "HANDS OUT TO " .. tostring(resolvedName)
end

-- With WillAutoMasterLoot false, nothing is handed out whatever a row says.
local function AppendOpenLootWindow(lines)
	local slotCount = GetNumLootItems()
	lines[#lines + 1] = ""
	if slotCount == 0 then
		lines[#lines + 1] = "Open loot window: none (open one as master looter and run this again to see each slot)"
		return
	end
	local profile = ns.db.profile
	lines[#lines + 1] = "SLOT\tLINK\tQUALITY\tCANDIDATES\tVERDICT"
	for slotIndex = 1, slotCount do
		local lootLink = GetLootSlotLink(slotIndex)
		local candidates, names = SlotCandidates(slotIndex)
		local verdict = "MONEY OR EMPTY (left to the game)"
		local quality = ""
		if lootLink then
			local itemIdentifier = tonumber(string.match(lootLink, "item:(%d+)"))
			local itemInformation = ns:SafeGetItemInfo(itemIdentifier)
			quality = itemInformation and tostring(itemInformation.quality) or ""
			verdict = MasterLootSlotVerdict(profile, itemInformation, itemIdentifier, candidates)
		end
		lines[#lines + 1] = table.concat({
			slotIndex,
			LinkCell(lootLink),
			quality,
			#names > 0 and table.concat(names, ", ") or "none",
			verdict,
		}, "\t")
	end
end

---@return string
function ns:BuildLootMethodReport()
	local lines = { GetClientHeader(), "" }

	-- Raw returns, legacy then modern, so the report shows what each client exposes.
	if type(GetLootMethod) == "function" then
		local count, values = PackReturns(GetLootMethod())
		lines[#lines + 1] = string.format("GetLootMethod() [legacy] -> %d value(s):", count)
		for index = 1, count do
			lines[#lines + 1] = string.format("  [%d] (%s) %s", index, type(values[index]), tostring(values[index]))
		end
	else
		lines[#lines + 1] = "GetLootMethod [legacy]: not available"
	end

	lines[#lines + 1] = ""
	if type(C_PartyInfo) == "table" and type(C_PartyInfo.GetLootMethod) == "function" then
		local count, values = PackReturns(C_PartyInfo.GetLootMethod())
		lines[#lines + 1] = string.format("C_PartyInfo.GetLootMethod() -> %d value(s):", count)
		for index = 1, count do
			lines[#lines + 1] = string.format("  [%d] (%s) %s", index, type(values[index]), tostring(values[index]))
		end
	else
		lines[#lines + 1] = "C_PartyInfo.GetLootMethod: not available"
	end

	-- Enum.LootMethod values the modern API is mapped onto.
	lines[#lines + 1] = ""
	if type(Enum) == "table" and type(Enum.LootMethod) == "table" then
		lines[#lines + 1] = "Enum.LootMethod:"
		for _, key in ipairs({ "Freeforall", "Roundrobin", "Masterlooter", "Group", "Needbeforegreed", "Personal" }) do
			lines[#lines + 1] = string.format("  %s = %s", key, tostring(Enum.LootMethod[key]))
		end
	else
		lines[#lines + 1] = "Enum.LootMethod: not available (legacy string API in use)"
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "GogoLoot interpretation:"
	lines[#lines + 1] =
		string.format("  SafeGetLootMethod() = %s", tostring(ns.SafeGetLootMethod and ns:SafeGetLootMethod()))
	lines[#lines + 1] = string.format(
		"  SafeGetLootThreshold() = %s (the game's Master Loot quality threshold)",
		tostring(ns.SafeGetLootThreshold and ns:SafeGetLootThreshold())
	)
	lines[#lines + 1] =
		string.format("  AreWeMasterLooter() = %s", tostring(ns.AreWeMasterLooter and ns:AreWeMasterLooter()))
	lines[#lines + 1] = string.format(
		"  WillAutoMasterLoot() = %s (true = GogoLoot auto-distributes the next loot session; requires an instance or the outside-instances setting)",
		tostring(ns.WillAutoMasterLoot and ns:WillAutoMasterLoot())
	)

	AppendMasterLootSettings(lines)
	if ns.db and ns.db.profile then
		AppendOpenLootWindow(lines)
	end

	--[[
	    Ids are per flavor and looked up by name, so a constant that resolves
	    to nothing here is a result this client never reports. One walk serves
	    both tables, so the two blocks can't disagree about the message count.
	]]
	lines[#lines + 1] = ""
	if type(ns.GetGameMessageInfo) ~= "function" then
		lines[#lines + 1] = "Game message ids: GetGameMessageInfo not available"
		lines[#lines + 1] = "  (neither loot errors nor trade results can be correlated on this client)"
		return table.concat(lines, "\n")
	end

	local wantedConstants = {}
	for constantName in pairs(ns.LOOT_ERROR_CONSTANTS) do
		wantedConstants[constantName] = true
	end
	for constantName in pairs(ns.TRADE_RESULT_CONSTANTS) do
		wantedConstants[constantName] = true
	end

	local resolved, scannedCount = ns:ResolveGameMessageIds(wantedConstants)
	local resolvedIds = {}
	for messageId, constantName in pairs(resolved) do
		resolvedIds[constantName] = messageId
	end

	AppendResolvedIdLines(
		lines,
		"Loot error message ids (constant -> id on this client):",
		ns.LOOT_ERROR_CONSTANTS,
		resolvedIds,
		function(localeKey)
			return "announces " .. tostring(localeKey)
		end
	)

	lines[#lines + 1] = ""
	AppendResolvedIdLines(
		lines,
		"Trade result message ids (constant -> id on this client):",
		ns.TRADE_RESULT_CONSTANTS,
		resolvedIds,
		function(tradeResult)
			return "read as " .. tostring(tradeResult)
		end
	)

	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("  (both blocks resolved from one walk of %d game messages)", scannedCount)

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Speedy Loot Context
--------------------------------------------------------------------------------

-- What the Loot Sounds read beyond their switches (CurrentLootSource in Features/Loot-Sounds.lua).
local function AppendLootSoundInputs(lines)
	local slotCount = GetNumLootItems()
	if slotCount > 0 then
		local sources = {}
		for slotIndex = 1, slotCount do
			local sourceGuid = GetLootSourceInfo(slotIndex)
			local guidType = sourceGuid and string.match(sourceGuid, "^(%a+)") or "none"
			sources[guidType] = (sources[guidType] or 0) + 1
		end
		local tallies = {}
		for guidType, count in pairs(sources) do
			tallies[#tallies + 1] = guidType .. " " .. count
		end
		table.sort(tallies)
		lines[#lines + 1] = string.format(
			"Loot window sources now: %s (the chime plays for Creature, Vehicle or GameObject, never Item)",
			table.concat(tallies, ", ")
		)
	else
		lines[#lines + 1] = "Loot window sources now: no loot window open"
	end
	lines[#lines + 1] = string.format(
		"Your casts read secret (C_Secrets), so Pick Pocket can't arm its sound: %s",
		YesNo(C_Secrets.ShouldUnitSpellCastingBeSecret("player"))
	)
	lines[#lines + 1] = string.format(
		"Game sound: Sound_EnableAllSound %s, Sound_MasterVolume %s",
		tostring(GetCVar("Sound_EnableAllSound")),
		tostring(GetCVar("Sound_MasterVolume"))
	)
end

--[[
    As ReadBagSpace (Features/Speedy-Loot.lua) reads it; family 0 is a general
    bag. An item with no bag of its family left takes a general slot.
]]
local function AppendBagSpaceLines(lines)
	local bags = {}
	for bagIndex = 0, NUM_BAG_SLOTS do
		local free, family = C_Container.GetContainerNumFreeSlots(bagIndex)
		bags[#bags + 1] = string.format("bag %d %s free family %s", bagIndex, tostring(free), tostring(family))
	end
	lines[#lines + 1] = "Bag space by bag: " .. table.concat(bags, "; ")
	local keyringEnabled = "unreadable"
	if type(IsKeyRingEnabled) == "function" then
		keyringEnabled = YesNo(IsKeyRingEnabled())
	elseif type(C_ActionBar) == "table" and type(C_ActionBar.ShouldShowKeyring) == "function" then
		keyringEnabled = YesNo(C_ActionBar.ShouldShowKeyring())
	end
	lines[#lines + 1] = string.format(
		"Keyring: KEYRING_CONTAINER %s, enabled %s, free %s",
		tostring(KEYRING_CONTAINER),
		keyringEnabled,
		KEYRING_CONTAINER and tostring(C_Container.GetContainerNumFreeSlots(KEYRING_CONTAINER)) or "n/a"
	)
end

--[[
    Bottom first, as the pass walks it. A LOCKED slot is skipped; a Bind on
    Pickup or not-yet-loaded item keeps the window up. STACK, CARRIED and
    FAMILY are what TakeSpaceFor weighs.
]]
local function AppendSpeedyLootSlots(lines)
	local slotCount = GetNumLootItems()
	if slotCount == 0 then
		return
	end
	lines[#lines + 1] = "SLOT\tTYPE\tQUANTITY\tLOCKED\tBIND_TYPE\tSTACK\tCARRIED\tFAMILY\tLINK"
	for slotIndex = slotCount, 1, -1 do
		local _, _, quantity, _, _, locked = GetLootSlotInfo(slotIndex)
		local itemLink = GetLootSlotLink(slotIndex)
		local itemIdentifier = itemLink and tonumber(string.match(itemLink, "item:(%d+)"))
		local stackSize, bindType, family, carried
		if itemLink then
			stackSize = select(8, C_Item.GetItemInfo(itemLink))
			bindType = select(14, C_Item.GetItemInfo(itemLink))
			-- As TakeSpaceFor reads it: a bag or quiver, or a client without GetItemFamily, takes a general slot.
			local classIdentifier = select(6, C_Item.GetItemInfoInstant(itemLink))
			local isBag = classIdentifier == ns.ITEM_CLASS_BAG or classIdentifier == ns.ITEM_CLASS_QUIVER
			family = not isBag and GetItemFamily and GetItemFamily(itemLink) or 0
			carried = itemIdentifier and C_Item.GetItemCount(itemIdentifier)
		end
		lines[#lines + 1] = table.concat({
			tostring(slotIndex),
			tostring(GetLootSlotType(slotIndex)),
			tostring(quantity),
			tostring(locked and true or false),
			itemLink and tostring(bindType) or "",
			itemLink and tostring(stackSize) or "",
			itemLink and tostring(carried) or "",
			itemLink and tostring(family) or "",
			LinkCell(itemLink),
		}, "\t")
	end
	lines[#lines + 1] = string.format(
		"(TYPE %s is an item; BIND_TYPE %s is Bind on Pickup, nil is not loaded yet)",
		tostring(ns.LOOT_SLOT_TYPE_ITEM),
		tostring(ns.BIND_ON_PICKUP)
	)
end

--[[
    Speedy Loot acts on LOOT_READY only with its switch on, not as master
    looter, and when Auto Loot and the auto-loot modifier disagree.
    GetModifiedClick is read through _G and may be nil: GogoLoot itself never
    calls it.
]]
function ns:BuildSpeedyLootContextReport()
	local lines = { GetClientHeader(), "" }
	AppendProfileLines(lines)
	local profile = ns.db and ns.db.profile
	if not profile then
		lines[#lines + 1] = "(saved variables not loaded)"
		return table.concat(lines, "\n")
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("Speedy Loot: %s", OnOff(ns.db.global.speedyLoot))
	AppendAutoLootLine(lines)
	local getModifiedClick = _G.GetModifiedClick
	local modifierHeld = IsModifiedClick("AUTOLOOTTOGGLE") and true or false
	lines[#lines + 1] = string.format(
		"Auto loot modifier (AUTOLOOTTOGGLE): key %s, held now %s, so Speedy Loot would act on a loot window now: %s",
		type(getModifiedClick) == "function" and tostring(getModifiedClick("AUTOLOOTTOGGLE")) or "unreadable",
		YesNo(modifierHeld),
		YesNo(ns:IsAutoLootCVarEnabled() ~= modifierHeld)
	)
	lines[#lines + 1] = string.format(
		"Master looter, so Speedy Loot stands down (AreWeMasterLooter): %s",
		YesNo(ns:AreWeMasterLooter())
	)
	AppendFreeSlotsLine(lines)
	AppendBagSpaceLines(lines)
	-- LootFrame is hidden through its Open method where it carries one (WoW Forever), else through OnShow.
	local lootWindow = ns.GetLootWindow()
	lines[#lines + 1] = string.format(
		"Loot window: %s, shown %s, slots now %d; LootFrame hidden through %s",
		lootWindow and tostring(lootWindow:GetName()) or "none",
		YesNo(ns.IsLootWindowShown()),
		GetNumLootItems(),
		(LootFrame and type(rawget(LootFrame, "Open")) == "function") and "Open" or "OnShow"
	)
	AppendSpeedyLootSlots(lines)

	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format(
		"Loot Sounds: switch %s; chime %s at quality %s (%s) and up, corpse and chest loot only; Pick Pocket sound %s, Pick Pocket known %s",
		OnOff(profile.lootSoundsEnabled),
		OnOff(profile.lootSounds),
		tostring(profile.lootSoundThreshold),
		tostring(ns.QUALITY_DISPLAY_NAMES[ns.RARITY_TO_CONFIGURATION_KEY[profile.lootSoundThreshold]]),
		OnOff(profile.pickPocketSound),
		YesNo(IsPlayerSpell(ns.SPELLS.PICK_POCKET))
	)
	AppendLootSoundInputs(lines)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Automated Opening Context
--------------------------------------------------------------------------------

--[[
    As IsInteractionActive (Features/Automated-Opening.lua) lists them; a frame
    the client lacks reads as closed. The loot window is added separately.
]]
local INTERACTION_FRAMES = {
	"MerchantFrame",
	"MailFrame",
	"TradeFrame",
	"BankFrame",
	"GuildBankFrame",
	"AuctionFrame",
	"AuctionHouseFrame",
	"GossipFrame",
	"QuestFrame",
}

local function OpenInteractionFrames()
	local shown = {}
	for _, frameName in ipairs(INTERACTION_FRAMES) do
		local frame = _G[frameName]
		if frame and frame:IsShown() then
			shown[#shown + 1] = frameName
		end
	end
	if ns.IsLootWindowShown() then
		shown[#shown + 1] = tostring(ns.GetLootWindow():GetName())
	end
	return #shown > 0 and table.concat(shown, ", ") or "none"
end

--[[
    On WoW Forever an aura or cast can read secret, and a secret can't be
    tested, so each is asked of C_Secrets first and left unread if secret.
]]
local function AppendStealthAndCastLines(lines)
	local auraSecret = C_Secrets.ShouldSpellAuraBeSecret(ns.SPELLS.SHADOWMELD) and true or false
	local shadowmeld = "secret, not read"
	if not auraSecret then
		shadowmeld = YesNo(C_UnitAuras.GetPlayerAuraBySpellID(ns.SPELLS.SHADOWMELD) ~= nil)
	end
	lines[#lines + 1] = string.format(
		"Stealth: stealthed %s, Shadowmeld aura secret %s, Shadowmeld up %s",
		YesNo(IsStealthed()),
		YesNo(auraSecret),
		shadowmeld
	)
	local castSecret = C_Secrets.ShouldUnitSpellCastingBeSecret("player") and true or false
	local casting, channeling = "secret, not read", "secret, not read"
	if not castSecret then
		casting = YesNo(UnitCastingInfo("player") ~= nil)
		channeling = YesNo(UnitChannelInfo("player") ~= nil)
	end
	lines[#lines + 1] =
		string.format("Casting: secret %s, casting %s, channeling %s", YesNo(castSecret), casting, channeling)
end

-- What the open tick waits out on its own, since no event reports any of it ending.
local function AppendWaitingOnPlayerLine(lines)
	local tooltipItem = false
	if GameTooltip:IsShown() then
		local itemName, itemLink = GameTooltip:GetItem()
		tooltipItem = (itemName or itemLink) and true or false
	end
	lines[#lines + 1] = string.format(
		"Waiting on you: confirmation pop-up %s, spell waiting for a target %s, item on the cursor %s, item tooltip shown %s",
		YesNo(StaticPopup1 and StaticPopup1:IsShown()),
		YesNo(SpellIsTargeting()),
		YesNo(CursorHasItem()),
		YesNo(tooltipItem)
	)
end

local function AppendOpenablesLines(lines)
	local changed, added, removed = 0, 0, 0
	for itemIdentifier, action in pairs(ns.db.global.openingActions) do
		if action == ns.OPENING_REMOVED then
			removed = removed + 1
		elseif ns:GetDefaultOpeningAction(itemIdentifier) then
			changed = changed + 1
		else
			added = added + 1
		end
	end
	lines[#lines + 1] = string.format(
		"Openables List: %d rows in this client's data, %d listed now; your changes: %d set away from their default, %d added, %d removed",
		CountKeys(ns.OPENABLE_ITEMS),
		CountKeys(ns:GetOpenableItemList()),
		changed,
		added,
		removed
	)
end

local function AppendLockboxLines(lines, profile)
	lines[#lines + 1] = string.format(
		"Notices: Ignore notice %s, active now %s (needs Automated Opening); lockbox notices %s (scope %s, shows for you %s); lockbox tooltips %s (scope %s, shows for you %s); you are a Rogue %s",
		OnOff(profile.openingIgnoreNotifications),
		YesNo(profile.autoOpen and profile.openingIgnoreNotifications),
		OnOff(profile.lockboxNotifications),
		tostring(profile.lockboxNotificationsScope),
		YesNo(ns.LockboxScopeAllows(profile.lockboxNotificationsScope)),
		OnOff(profile.lockboxTooltips),
		tostring(profile.lockboxTooltipsScope),
		YesNo(ns.LockboxScopeAllows(profile.lockboxTooltipsScope)),
		YesNo(ns.IsPlayerRogue())
	)
	local rank = ns.GetPlayerLockpickingSkill()
	lines[#lines + 1] = string.format(
		"Lockpicking: skill line name %s, rank %s, %d lockboxes with a skill level in this client's data",
		tostring(ns.GetLockpickingSkillName()),
		rank and tostring(rank) or "unavailable on this client (or not trained)",
		CountKeys(ns.LOCKBOX_SKILL_LEVELS)
	)
end

-- Open Sesame, which GogoLoot replaced, opens the same containers; with both loaded the two race.
local OPEN_SESAME_FOLDER = "Open-Sesame"

--[[
    IsSafeToOpen's inputs and the open tick's (Features/Automated-Opening.lua).
    Items set aside after refused opens stay private to that file and don't
    show here.
]]
function ns:BuildOpeningContextReport()
	local lines = { GetClientHeader(), "" }
	AppendProfileLines(lines)
	local profile = ns.db and ns.db.profile
	if not profile then
		lines[#lines + 1] = "(saved variables not loaded)"
		return table.concat(lines, "\n")
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format(
		"Automated Opening: %s, paused for bag space %s",
		OnOff(profile.autoOpen),
		YesNo(ns:IsAutomatedOpeningPaused())
	)
	lines[#lines + 1] = string.format(
		"Where: %s, in an instance %s // Group: %s, in a group %s",
		tostring(profile.autoOpenWhere),
		YesNo(IsInInstance()),
		tostring(profile.autoOpenGroup),
		YesNo(IsInGroup())
	)
	lines[#lines + 1] = string.format(
		"With Fishing Pole Equipped: %s, fishing pole equipped %s",
		OnOff(profile.autoOpenWithFishingPole),
		YesNo(ns.IsFishingPoleEquipped())
	)
	lines[#lines + 1] = string.format("In combat (UnitAffectingCombat): %s", YesNo(UnitAffectingCombat("player")))
	AppendStealthAndCastLines(lines)
	lines[#lines + 1] = "Open windows: " .. OpenInteractionFrames()
	AppendWaitingOnPlayerLine(lines)
	AppendFreeSlotsLine(lines)
	AppendAutoLootLine(lines)

	lines[#lines + 1] = ""
	AppendOpenablesLines(lines)
	AppendLockboxLines(lines, profile)
	lines[#lines + 1] = string.format(
		"Open Sesame: %s",
		C_AddOns.IsAddOnLoaded(OPEN_SESAME_FOLDER) and "LOADED (it opens the same containers)" or "not loaded"
	)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Locked Boxes
--------------------------------------------------------------------------------

-- As ShouldOpen (Features/Automated-Opening.lua) reads it; an item set aside after refused opens still reads OPEN.
local function OpeningVerdict(action, requiredLevel, locked)
	if action == nil then
		return "NOT LISTED"
	end
	if action ~= ns.OPENING_OPEN then
		return "IGNORED"
	end
	if requiredLevel and requiredLevel > UnitLevel("player") then
		return "WAITS FOR LEVEL"
	end
	if locked then
		return "WAITS FOR LOCK"
	end
	return "OPEN"
end

--[[
    Matched as Lockbox Tooltips matches it. When the client states the
    requirement, Lockbox Tooltips adds only your rank, or nothing if the rank
    can't be read.
]]
local function ClientStatesRequirement(bagIndex, slotIndex)
	local pattern = ns.BuildFormatPattern(ITEM_MIN_SKILL)
	if not pattern then
		return false
	end
	for _, text in ipairs(ns.GetBagItemTooltipLines(bagIndex, slotIndex)) do
		if string.match(text, pattern) then
			return true
		end
	end
	return false
end

--[[
    TOOLTIP_LINES separates a truly unlocked box from a scan tooltip that read
    nothing, since both answer "not locked". A lockbox off the Openables List
    still gets a row. Read-only.
]]
---@return string
function ns:BuildLockedBoxesReport()
	local lines = {
		GetClientHeader(),
		"",
		"BAG\tSLOT\tITEM_ID\tLINK\tDEFAULT\tACTION\tLOCKED\tTOOLTIP_LINES\tREQUIRED_LEVEL\tVERDICT\tSKILL_REQUIRED\tCLIENT_STATES_SKILL",
	}
	local found = 0
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) or 0 do
			local itemIdentifier = ns.GetBagItemIdentifier(bagIndex, slotIndex)
			local default = ns:GetOpeningDefault(itemIdentifier)
			local action = ns:GetOpeningAction(itemIdentifier)
			local requiredSkill = itemIdentifier and ns.LOCKBOX_SKILL_LEVELS[itemIdentifier]
			if default or action or requiredSkill then
				found = found + 1
				local locked, lineCount = ns.IsItemLocked(bagIndex, slotIndex)
				-- The flavor folder's level first, as Automated Opening reads it, so an uncached item still shows its wait.
				local requiredLevel = ns.OPENABLE_ITEM_LEVELS[itemIdentifier]
					or select(5, C_Item.GetItemInfo(itemIdentifier))
				lines[#lines + 1] = table.concat({
					bagIndex,
					slotIndex,
					itemIdentifier,
					LinkCell(C_Container.GetContainerItemLink(bagIndex, slotIndex)),
					tostring(default),
					tostring(action),
					tostring(locked),
					tostring(lineCount),
					requiredLevel and tostring(requiredLevel) or "",
					OpeningVerdict(action, requiredLevel, locked),
					requiredSkill and tostring(requiredSkill) or "",
					requiredSkill and tostring(ClientStatesRequirement(bagIndex, slotIndex)) or "",
				}, "\t")
			end
		end
	end
	if found == 0 then
		lines[#lines + 1] = "(no openable items in the bags)"
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Automated Rolls Context
--------------------------------------------------------------------------------

local function RollSettingText(action, threshold)
	if action == ns.MANUAL then
		return "Manual (left to you)"
	end
	return string.format(
		"%s, quality %s (%s)",
		tostring(action),
		tostring(threshold),
		tostring(ns.ROLL_THRESHOLD_LABELS[threshold])
	)
end

-- This character's ticked boxes, class starter list included, in panel order ("ARMOR_4, WEAPON_15, STAT_STRENGTH"), or nil.
local function TickedBoxes()
	local _, classFile = UnitClass("player")
	local rules = ns.db.char.characterRules
	local ticked = {}
	for _, group in ipairs(ns.CHARACTER_RULE_GEAR_GROUPS) do
		for _, row in ipairs(ns[group.types]) do
			if ns.CharacterRuleWantsGear(rules, classFile, group, row) then
				ticked[#ticked + 1] = ns.CharacterRuleGearKey(group, row)
			end
		end
	end
	for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
		if ns.CharacterRuleWantsStat(rules, classFile, stat.key) then
			ticked[#ticked + 1] = ns.CharacterRuleStatKey(stat.key)
		end
	end
	return #ticked > 0 and table.concat(ticked, ", ") or nil
end

-- What this character saved, A to Z ("wanted.ARMOR_2=true, unwanted.action=pass"), or nil for class defaults throughout.
local function SavedRules()
	local saved = {}
	for section, fields in pairs(ns.db.char.characterRules or {}) do
		if type(fields) == "table" then
			for field, value in pairs(fields) do
				saved[#saved + 1] = tostring(section) .. "." .. tostring(field) .. "=" .. tostring(value)
			end
		else
			saved[#saved + 1] = tostring(section) .. "=" .. tostring(fields)
		end
	end
	table.sort(saved)
	return #saved > 0 and table.concat(saved, ", ") or nil
end

--[[
    An open roll is checked as the roll handler checks it: a Need with no Need
    open falls back to Greed, and nothing rolls without Greed. Must match
    ROLL_RETRY_TIMER_PREFIX in Features/Automated-Rolls.lua.
]]
local ROLL_RETRY_TIMER_PREFIX = "GogoLoot.RollRetry."

-- Roll Verdicts' reading of one item (below), which each open roll gives too.
local RollVerdict

local function AppendOpenRolls(lines)
	local frameCount = type(_G.NUM_GROUP_LOOT_FRAMES) == "number" and _G.NUM_GROUP_LOOT_FRAMES or 4
	local open = 0
	for frameIndex = 1, frameCount do
		local frame = _G["GroupLootFrame" .. frameIndex]
		local rollIdentifier = frame and frame:IsShown() and frame.rollID
		if type(rollIdentifier) == "number" then
			open = open + 1
			local _, _, _, quality, bindOnPickup, canNeed, canGreed = GetLootRollItemInfo(rollIdentifier)
			local rollLink = GetLootRollItemLink(rollIdentifier)
			local parsed = rollLink and ns:ParseItemLink(rollLink)
			local verdict = "NOT RESOLVED YET (the retry waits for it)"
			if parsed and parsed.itemIdentifier then
				verdict = RollVerdict(rollLink, parsed.itemIdentifier, quality)
			elseif rollLink then
				verdict = "NOT AN ITEM LINK (left to the player)"
			end
			lines[#lines + 1] = string.format(
				"  Roll %s: quality %s, Bind on Pickup %s, Need open %s, Greed open %s, retry polling %s, verdict %s, link %s",
				tostring(rollIdentifier),
				tostring(quality),
				YesNo(bindOnPickup),
				YesNo(canNeed),
				YesNo(canGreed),
				YesNo(ns:IsTimerPending(ROLL_RETRY_TIMER_PREFIX .. rollIdentifier)),
				verdict,
				rollLink and LinkCell(rollLink) or "not resolved yet"
			)
		end
	end
	if open == 0 then
		lines[#lines + 1] = string.format("  No roll window open now (GroupLootFrame1 to %d).", frameCount)
	end
end

--[[
    An Equip spell not loaded yet builds no pattern, so its stat goes unseen
    on an Equip line. Read before Roll Verdicts and Gear Stats ask for them.
]]
local function EquipSpellsLoaded()
	local loaded, total = 0, 0
	local canRead = type(C_Spell) == "table" and type(C_Spell.GetSpellDescription) == "function"
	for spellIdentifier in pairs(ns.CHARACTER_RULE_EQUIP_SPELLS or {}) do
		total = total + 1
		local description = canRead and C_Spell.GetSpellDescription(spellIdentifier)
		if type(description) == "string" and description:find("%S") then
			loaded = loaded + 1
		end
	end
	return loaded, total
end

--[[
    CheckRollSafety (Features/Automated-Rolls.lua) also stays quiet on a
    /reload and on a return to the same instance with the same roll within
    half an hour, which this can't see.
]]
local SAFETY_WARNING_ROLLS = { [ns.NEED] = true, [ns.PASS] = true }

local function AppendRollSafetyLines(lines, profile)
	local _, instanceType = GetInstanceInfo()
	local action = IsInRaid() and profile.autoRollActionRaid or profile.autoRollActionParty
	local inInstance = instanceType == "party" or instanceType == "raid"
	lines[#lines + 1] = string.format(
		"Roll Safety Warning: %s, sound %s; here: instance type %s, roll %s, so zoning in here would warn: %s",
		OnOff(profile.rollSafetyWarning),
		OnOff(profile.rollSafetyWarningSound),
		tostring(instanceType),
		tostring(action),
		YesNo(profile.autoGreed and profile.rollSafetyWarning and inInstance and SAFETY_WARNING_ROLLS[action])
	)
end

-- The same hook test Features/Roll-Preview-Tooltip.lua makes at load.
local function AppendRollPreviewLine(lines, profile)
	local hasPostCall = TooltipDataProcessor
		and TooltipDataProcessor.AddTooltipPostCall
		and Enum
		and Enum.TooltipDataType
	lines[#lines + 1] = string.format(
		"Roll preview on item tooltips: shows now %s (needs Automated Rolls), hooked through %s",
		YesNo(profile.autoGreed),
		hasPostCall and "TooltipDataProcessor" or "OnTooltipSetItem"
	)
end

--[[
    Roll Audit (Features/Roll-Audit.lua), newest first. A roll still waiting
    on its won or everyone-passed line is private to that file and doesn't
    show here.
]]
local ROLL_AUDIT_SHOWN = 5

local function AppendRollAuditLines(lines)
	local audit = ns.GetRollAudit()
	local _, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()
	lines[#lines + 1] = string.format(
		"Roll Audit: %d rolls listed; here: instance type %s, instance ID %s",
		#audit,
		tostring(instanceType),
		tostring(instanceID)
	)
	for index = 1, math.min(#audit, ROLL_AUDIT_SHOWN) do
		local roll = audit[index]
		local winner = roll.winner
		local winnerText = "nobody"
		if winner then
			winnerText = winner.isPlayer and "you" or tostring(winner.name)
		end
		lines[#lines + 1] = string.format(
			"  %s: everyone passed %s, winner %s, %d players listed",
			LinkCell(roll.itemLink or "nil"),
			YesNo(roll.everyonePassed),
			winnerText,
			#roll.lines
		)
	end
	if #audit > ROLL_AUDIT_SHOWN then
		lines[#lines + 1] = string.format("  (%d older rolls not shown)", #audit - ROLL_AUDIT_SHOWN)
	end
end

function ns:BuildRollsContextReport()
	local lines = { GetClientHeader(), "" }
	AppendProfileLines(lines)
	local profile = ns.db and ns.db.profile
	if not profile then
		lines[#lines + 1] = "(saved variables not loaded)"
		return table.concat(lines, "\n")
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("Automated Rolls: %s", OnOff(profile.autoGreed))
	lines[#lines + 1] = string.format(
		"Group context now: %s, so the %s setting applies",
		IsInRaid() and "raid" or (IsInGroup() and "party" or "not grouped"),
		IsInRaid() and "raid" or "party"
	)
	lines[#lines + 1] = "  Party: "
		.. RollSettingText(profile.autoRollActionParty, profile.autoRollThresholdParty)
		.. ", Bind on Pickup "
		.. YesNo(ns.RollsBindOnPickup(false))
	lines[#lines + 1] = "  Raid: "
		.. RollSettingText(profile.autoRollActionRaid, profile.autoRollThresholdRaid)
		.. ", Bind on Pickup "
		.. YesNo(ns.RollsBindOnPickup(true))

	local byAction = {}
	for _, action in pairs(profile.ignoredItemsSolo) do
		byAction[action] = (byAction[action] or 0) + 1
	end
	lines[#lines + 1] = string.format(
		"Global Item Overrides: %s, %d items (need %d, greed %d, pass %d, manual %d)",
		OnOff(profile.customRollList),
		CountKeys(profile.ignoredItemsSolo),
		byAction[ns.NEED] or 0,
		byAction[ns.GREED] or 0,
		byAction[ns.PASS] or 0,
		byAction[ns.MANUAL] or 0
	)
	lines[#lines + 1] = string.format("Print Item in Chat: %s", OnOff(profile.printRolledItems))
	lines[#lines + 1] = string.format(
		"Hide Roll Messages: %s, active now %s (needs Automated Rolls), winner summary %s, printing now %s",
		OnOff(profile.hideRollMessages),
		YesNo(profile.autoGreed and profile.hideRollMessages),
		tostring(profile.winnerSummary),
		YesNo(ns.PrintingWinnerSummary())
	)
	local rules = ns.db.char.characterRules
	lines[#lines + 1] = string.format(
		"Character Overrides on %s (%s): ticked %s",
		tostring(ns.db.keys and ns.db.keys.char),
		tostring(select(2, UnitClass("player"))),
		TickedBoxes() or "nothing"
	)
	lines[#lines + 1] = string.format(
		"  Everything Else: %s up to the group context's quality, Bind on Pickup %s here",
		tostring(ns.CharacterRuleUnwanted(rules, "action")),
		YesNo(ns.RollsBindOnPickup(IsInRaid()))
	)
	lines[#lines + 1] = string.format(
		"  Low-level gear: Greeds gear whose required level is at least %s below yours (%s), whatever the boxes say; 0 is off",
		tostring(ns.CharacterRuleUnwanted(rules, "lowLevelGear")),
		tostring(UnitLevel("player"))
	)
	lines[#lines + 1] = "  Saved (anything not saved follows the class defaults): " .. (SavedRules() or "nothing")
	lines[#lines + 1] = "  Stats this client offers: " .. table.concat(ns.CHARACTER_RULE_STAT_KEYS, ", ")
	lines[#lines + 1] = string.format("  Equip-line stat spells loaded this session: %d of %d", EquipSpellsLoaded())
	lines[#lines + 1] = ""
	AppendRollSafetyLines(lines, profile)
	lines[#lines + 1] = string.format(
		"Automated Rolls on notice printed (once, at the first login with the switch on): %s",
		YesNo(ns.db.global.automatedRollsOnNoticeShown)
	)
	AppendRollPreviewLine(lines, profile)
	lines[#lines + 1] = ""
	AppendRollAuditLines(lines)
	lines[#lines + 1] = ""
	lines[#lines + 1] = "Rolls open now:"
	AppendOpenRolls(lines)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Roll Verdicts
--------------------------------------------------------------------------------

--[[
    Decided by the live roll's own ns.DecideRoll. Only a live roll knows
    whether Need is open, so a NEED verdict may still roll Greed.
]]
local ROLL_REASON_LABELS = {
	OFF = "AUTOMATED ROLLS OFF",
	NEVER = "NEVER AUTOMATED",
	OVERRIDE = "GLOBAL ITEM OVERRIDES",
	QUEST = "QUEST ITEM",
	LOW_LEVEL = "CHARACTER OVERRIDES: LOW-LEVEL GEAR",
	WANTED = "CHARACTER OVERRIDES: WANTED",
	EVERYTHING_ELSE = "CHARACTER OVERRIDES: NOT WANTED",
	BIND_ON_PICKUP = "BIND ON PICKUP",
	MANUAL = "SETTING IS MANUAL",
	QUALITY = "WITHIN THE QUALITY SETTING",
	ABOVE_QUALITY = "ABOVE THRESHOLD",
}

-- The Character Overrides box an item fell under, for the reasons that come from one.
local RULE_REASONS = { LOW_LEVEL = true, WANTED = true, EVERYTHING_ELSE = true }

-- A live roll passes the quality the roll window gives, as the live roll does; a bag item takes its own.
function RollVerdict(itemLink, itemIdentifier, quality)
	local itemInformation = ns:SafeGetItemInfo(itemIdentifier)
	if not itemInformation then
		return "NOT CACHED (a live roll waits for it)"
	end
	local rules = ns.db.char.characterRules
	local classFile = select(2, UnitClass("player"))
	local rollAction, reason = ns.DecideRoll(
		itemIdentifier,
		itemInformation,
		itemLink,
		quality or itemInformation.quality,
		rules,
		classFile,
		UnitLevel("player")
	)
	local label = ROLL_REASON_LABELS[reason] or tostring(reason)
	if RULE_REASONS[reason] then
		local _, group, row = ns.CharacterRuleVerdict(itemInformation, itemLink, rules, classFile)
		local where = type(group) == "table" and ns.CharacterRuleGearKey(group, row) or tostring(group)
		if reason == "LOW_LEVEL" then
			where = "REQUIRED LEVEL " .. tostring(itemInformation.requiredLevel) .. ", " .. where
		end
		label = label .. " (" .. where .. ")"
	end
	return label .. ", " .. (rollAction and ("ROLLS " .. string.upper(tostring(rollAction))) or "ROLL WINDOW")
end

-- So "it didn't roll on this" can be checked against an item already won by hand. Read-only.
---@return string
function ns:BuildRollVerdictsReport()
	local profile = ns.db and ns.db.profile
	if not profile then
		return GetClientHeader() .. "\n\n(saved variables not loaded)"
	end
	local inRaid = IsInRaid()
	local rollAction = inRaid and profile.autoRollActionRaid or profile.autoRollActionParty
	local rollThreshold = inRaid and profile.autoRollThresholdRaid or profile.autoRollThresholdParty
	local lines = {
		GetClientHeader(),
		"",
		string.format(
			"Automated Rolls: %s // %s setting: %s",
			OnOff(profile.autoGreed),
			inRaid and "Raid" or "Party",
			RollSettingText(rollAction, rollThreshold)
		),
		"",
		"ITEM_ID\tLINK\tQUALITY\tVERDICT",
	}
	local seen = {}
	for _, link in ipairs(BagItemLinks()) do
		local itemIdentifier = tonumber(string.match(link, "item:(%d+)"))
		if itemIdentifier and not seen[itemIdentifier] then
			seen[itemIdentifier] = true
			lines[#lines + 1] = table.concat({
				itemIdentifier,
				LinkCell(link),
				tostring(ns.GetLinkQuality(link)),
				RollVerdict(link, itemIdentifier),
			}, "\t")
		end
	end
	if not next(seen) then
		lines[#lines + 1] = "(no items in the bags)"
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Gear Stats
--------------------------------------------------------------------------------

-- The equipped slots, head (1) to tabard (19).
local FIRST_EQUIPPED_SLOT, LAST_EQUIPPED_SLOT = 1, 19

---@param itemLink string|nil
---@return boolean
local function IsGear(itemLink)
	if not itemLink then
		return false
	end
	local classId = select(6, C_Item.GetItemInfoInstant(itemLink))
	return classId == ns.ITEM_CLASS_ARMOR or classId == ns.ITEM_CLASS_WEAPON
end

--[[
    Every rule stat read on an item, in panel order, each with the sources that
    saw it: ITEM (GetItemStats) and TOOLTIP ("+15 Intellect" lines).
]]
---@param found table
---@return string
local function StatsCell(found)
	local cells = {}
	for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
		local sources = found[stat.key]
		if sources then
			cells[#cells + 1] = stat.key .. " (" .. table.concat(sources, ", ") .. ")"
		end
	end
	return #cells > 0 and table.concat(cells, "; ") or "none"
end

---@param itemLink string
---@param rules table|nil
---@return string
local function RuleCell(itemLink, rules)
	local itemInformation = ns:SafeGetItemInfo(itemLink)
	if not itemInformation then
		return "NOT CACHED"
	end
	local verdict, group, row =
		ns.CharacterRuleVerdict(itemInformation, itemLink, rules, select(2, UnitClass("player")))
	if not verdict then
		return "NOT JUDGED"
	end
	local where = type(group) == "table" and ns.CharacterRuleGearKey(group, row) or tostring(group)
	return (verdict == ns.CHARACTER_RULE_WANTED and "WANTED" or "NOT WANTED") .. " (" .. where .. ")"
end

--[[
    The same read the roll makes, so a piece that rolled when it shouldn't
    have can be checked without waiting for another drop. Read-only.
]]
---@return string
function ns:BuildGearStatsReport()
	local rules = ns.db.char.characterRules
	local lines = {
		GetClientHeader(),
		"",
		"Ticked on " .. tostring(ns.db.keys and ns.db.keys.char) .. ": " .. (TickedBoxes() or "nothing"),
		"",
		"WHERE\tITEM_ID\tSUFFIX_ID\tLINK\tSTATS\tRULE",
	}

	local function AddRow(where, itemLink)
		if not IsGear(itemLink) then
			return
		end
		local itemIdentifier = tonumber(itemLink:match("item:(%d+)"))
		local found = ns.ReadCharacterRuleStats(itemLink)
		lines[#lines + 1] = table.concat({
			where,
			tostring(itemIdentifier),
			tostring(ns.GetLinkRandomSuffix(itemLink) or ""),
			LinkCell(itemLink),
			StatsCell(found),
			RuleCell(itemLink, rules),
		}, "\t")
	end

	local headerCount = #lines
	for slot = FIRST_EQUIPPED_SLOT, LAST_EQUIPPED_SLOT do
		AddRow("EQUIPPED " .. slot, GetInventoryItemLink("player", slot))
	end
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) or 0 do
			AddRow("BAG " .. bagIndex .. "/" .. slotIndex, C_Container.GetContainerItemLink(bagIndex, slotIndex))
		end
	end
	if #lines == headerCount then
		lines[#lines + 1] = "(no armor or weapons in the bags or equipped)"
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Loot Toasts Context
--------------------------------------------------------------------------------

local function FilterCell(shown, qualities, row)
	if not shown[row.key] then
		return "off"
	end
	if row.rarity then
		return "on from quality " .. tostring(qualities[row.key] or 0)
	end
	return "on"
end

-- Standard Loot Messages acts only once the client has initialized ChatFrame1, and only on a change.
local function AppendStandardLootMessageLines(lines, profile)
	local wanted = not (profile.lootToasts and profile.standardLootMessages == ns.STANDARD_LOOT_MESSAGES_DISABLE)
	lines[#lines + 1] = string.format(
		"Standard Loot Messages: %s, so the game's loot and money lines belong on General: %s",
		tostring(profile.standardLootMessages),
		YesNo(wanted)
	)
	local chatFrame = ChatFrame1
	local initialized = chatFrame and chatFrame.isInitialized == 1
	lines[#lines + 1] = string.format(
		"General chat tab (ChatFrame1): initialized %s, LOOT group shown %s, MONEY group shown %s",
		YesNo(initialized),
		initialized and YesNo(chatFrame:ContainsMessageGroup("LOOT")) or "unread",
		initialized and YesNo(chatFrame:ContainsMessageGroup("MONEY")) or "unread"
	)
	local taken = {}
	for group in pairs(ns.db.char.lootGroupsHiddenByGogoLoot or {}) do
		taken[#taken + 1] = tostring(group)
	end
	table.sort(taken)
	lines[#lines + 1] = string.format(
		"This character: GogoLoot last set them hidden %s, groups it took off General: %s",
		tostring(ns.db.char.standardLootMessagesHidden),
		#taken > 0 and table.concat(taken, ", ") or "none"
	)
end

-- Where the stack sits is in Display Context.
function ns:BuildLootToastsContextReport()
	local lines = { GetClientHeader(), "" }
	AppendProfileLines(lines)
	local profile = ns.db and ns.db.profile
	if not profile then
		lines[#lines + 1] = "(saved variables not loaded)"
		return table.concat(lines, "\n")
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format(
		"Loot Toasts: %s, handle unlocked %s, introduction seen %s",
		OnOff(profile.lootToasts),
		YesNo(ns.AreLootToastsUnlocked()),
		YesNo(profile.lootToastsIntroSeen)
	)
	local font = profile.lootToastFont
	local registered = font == "DEFAULT" or LibStub("LibSharedMedia-3.0"):IsValid("font", font)
	lines[#lines + 1] = string.format(
		"Look: font %s (known %s), size %s, flags %s, grows %s, aligned %s, on screen %ss, at most %s rows",
		tostring(font),
		YesNo(registered),
		tostring(profile.lootToastFontSize),
		tostring(profile.lootToastFontFlags),
		tostring(profile.lootToastGrowth),
		tostring(profile.lootToastAlign),
		tostring(profile.lootToastDuration),
		profile.lootToastMaxVisible == ns.LOOT_TOAST_UNLIMITED and "unlimited" or tostring(profile.lootToastMaxVisible)
	)
	lines[#lines + 1] = string.format(
		"Tooltips %s; Blizzard Roll Winner Window %s%s; Bag Count %s; Winning Roll: Mine %s, Group %s",
		OnOff(profile.lootToastTooltips),
		OnOff(profile.lootToastBlizzardRollWon),
		ns.HasBlizzardRollWonWindow() and "" or " (no window on this client)",
		OnOff(profile.lootToastBagCount),
		OnOff(profile.lootToastWinningRollMine),
		OnOff(profile.lootToastWinningRollGroup)
	)
	-- The game's own won-roll window shows only while its alert listens; ns.SyncBlizzardRollWonWindow sets that at each loading screen.
	lines[#lines + 1] = string.format(
		"The game's won-roll alert listening now: %s",
		ns.HasBlizzardRollWonWindow() and YesNo(AlertFrame:IsEventRegistered("LOOT_ITEM_ROLL_WON")) or "n/a"
	)

	lines[#lines + 1] = ""
	lines[#lines + 1] = "Filters (row: Mine // Group):"
	for _, row in ipairs(ns.LOOT_TOAST_FILTER_ROWS) do
		if not row.minimumExpansion or ns.EXPANSION >= row.minimumExpansion then
			lines[#lines + 1] = string.format(
				"  %s: %s // %s",
				row.key,
				FilterCell(profile.lootToastMine, profile.lootToastMineQuality, row),
				row.mineOnly and "no Group box"
					or FilterCell(profile.lootToastGroup, profile.lootToastGroupQuality, row)
			)
		end
	end

	lines[#lines + 1] = ""
	AppendStandardLootMessageLines(lines, profile)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Loot Line Reading
--------------------------------------------------------------------------------

-- A made-up group member for the group lines (never a real player's name).
local EXAMPLE_LOOTER = "Aero"
local EXAMPLE_COUNT = 3

local function BuildLine(format, ...)
	if type(format) ~= "string" then
		return nil, "format missing on this client"
	end
	local ok, line = pcall(string.format, format, ...)
	if not ok then
		return nil, tostring(line)
	end
	return line, nil
end

--[[
    { constant, count }, arguments in English order: a translation that
    reorders them numbers its placeholders, which the client's format honors.
]]
local OWN_LINE_FORMATS = {
	{ "LOOT_ITEM_SELF", 1 },
	{ "LOOT_ITEM_SELF_MULTIPLE", EXAMPLE_COUNT },
	{ "LOOT_ITEM_PUSHED_SELF", 1 },
	{ "LOOT_ITEM_PUSHED_SELF_MULTIPLE", EXAMPLE_COUNT },
}

local GROUP_LINE_FORMATS = {
	{ "LOOT_ITEM", 1 },
	{ "LOOT_ITEM_MULTIPLE", EXAMPLE_COUNT },
	{ "LOOT_ITEM_PUSHED", 1 },
	{ "LOOT_ITEM_PUSHED_MULTIPLE", EXAMPLE_COUNT },
}

--[[
    Whether a roll reader would claim a loot line, which the toast handler
    would then drop. Read through the parsers alone, never RecordRollLine,
    which stores what it reads.
]]
local function RollClaim(line)
	if select(4, ns.ParseRollResultMessage(line)) then
		return "a roll result"
	end
	if ns.ParseRollWonMessage(line) then
		return "a won roll"
	end
	if ns.IsRollChatterMessage(line) then
		return "roll chatter"
	end
	return nil
end

local function AppendOwnLines(lines, link)
	for _, entry in ipairs(OWN_LINE_FORMATS) do
		local constant, count = entry[1], entry[2]
		local line, problem = BuildLine(_G[constant], link, count)
		if not line then
			lines[#lines + 1] = string.format("[ERROR] %s: %s", constant, problem)
		else
			local parsedLink, parsedCount = ns.ParseOwnLootMessage(line)
			local claim = RollClaim(line)
			local ok = parsedLink == link and parsedCount == count and not claim
			lines[#lines + 1] = string.format(
				"[%s] %s: read link %s, count %s, taken for %s",
				ok and "OK" or "FAIL",
				constant,
				parsedLink == link and "matches" or LinkCell(parsedLink or "nil"),
				tostring(parsedCount),
				claim or "no roll line"
			)
			if not ok then
				lines[#lines + 1] = "    " .. LinkCell(line)
			end
		end
	end
end

local function AppendGroupLines(lines, link)
	for _, entry in ipairs(GROUP_LINE_FORMATS) do
		local constant, count = entry[1], entry[2]
		local line, problem = BuildLine(_G[constant], EXAMPLE_LOOTER, link, count)
		if not line then
			lines[#lines + 1] = string.format("[ERROR] %s: %s", constant, problem)
		else
			local isOwn = ns.ParseOwnLootMessage(line) ~= nil
			local looter, parsedLink, parsedCount = ns.ParseGroupLootMessage(line)
			local claim = RollClaim(line)
			local ok = not isOwn
				and looter == EXAMPLE_LOOTER
				and parsedLink == link
				and parsedCount == count
				and not claim
			lines[#lines + 1] = string.format(
				"[%s] %s: read as your own %s, looter %s, link %s, count %s, taken for %s",
				ok and "OK" or "FAIL",
				constant,
				YesNo(isOwn),
				tostring(looter),
				parsedLink == link and "matches" or LinkCell(parsedLink or "nil"),
				tostring(parsedCount),
				claim or "no roll line"
			)
			if not ok then
				lines[#lines + 1] = "    " .. LinkCell(line)
			end
		end
	end
end

local EXAMPLE_GOLD, EXAMPLE_SILVER, EXAMPLE_COPPER = 1, 24, 7

local function AppendMoneyLine(lines)
	local gold, goldProblem = BuildLine(GOLD_AMOUNT, EXAMPLE_GOLD)
	local silver, silverProblem = BuildLine(SILVER_AMOUNT, EXAMPLE_SILVER)
	local copper, copperProblem = BuildLine(COPPER_AMOUNT, EXAMPLE_COPPER)
	if not (gold and silver and copper) then
		lines[#lines + 1] = "[ERROR] money: " .. tostring(goldProblem or silverProblem or copperProblem)
		return
	end
	local expected = EXAMPLE_GOLD * ns.COPPER_PER_GOLD + EXAMPLE_SILVER * ns.COPPER_PER_SILVER + EXAMPLE_COPPER
	local read = ns.ParseMoney(gold .. ", " .. silver .. ", " .. copper)
	lines[#lines + 1] = string.format(
		"[%s] GOLD_AMOUNT, SILVER_AMOUNT, COPPER_AMOUNT: read %d copper, expected %d",
		read == expected and "OK" or "FAIL",
		read,
		expected
	)
end

-- Made up, since the bags hold no currency.
local EXAMPLE_CURRENCY_LINK = "|cffffffff|Hcurrency:1|h[Example Currency]|h|r"

local CURRENCY_LINE_FORMATS = {
	{ "CURRENCY_GAINED", 1 },
	{ "CURRENCY_GAINED_MULTIPLE", EXAMPLE_COUNT },
	{ "CURRENCY_GAINED_MULTIPLE_BONUS", EXAMPLE_COUNT },
}

local function AppendCurrencyLines(lines)
	for _, entry in ipairs(CURRENCY_LINE_FORMATS) do
		local constant, count = entry[1], entry[2]
		local line, problem = BuildLine(_G[constant], EXAMPLE_CURRENCY_LINK, count)
		if not line then
			local status = type(_G[constant]) ~= "string" and "SKIP" or "ERROR"
			lines[#lines + 1] = string.format("[%s] %s: %s", status, constant, tostring(problem))
		else
			local readLink, readCount = ns.ParseCurrencyMessage(line)
			lines[#lines + 1] = string.format(
				"[%s] %s: read count %s, expected %d",
				readLink == EXAMPLE_CURRENCY_LINK and readCount == count and "OK" or "FAIL",
				constant,
				tostring(readCount),
				count
			)
		end
	end
end

local EXAMPLE_ROLL = 77

--[[
    Arguments filled by kind, not position, as the parsers read them: a
    number is the roll (or, first in a line opening on the "[Loot]" history
    link, that link's id), the last text is the item, any other the player.
]]
local function BuildRollLine(format, link)
	if type(format) ~= "string" then
		return nil
	end
	local kinds, nextIndex, lastText = {}, 1, nil
	for position, kind in string.gmatch((string.gsub(format, "%%%%", "")), "%%(%d*)%$?([sd])") do
		local index = tonumber(position)
		if not index then
			index = nextIndex
			nextIndex = nextIndex + 1
		end
		kinds[index] = kind
		if kind == "s" and (not lastText or index > lastText) then
			lastText = index
		end
	end
	local arguments, count = {}, 0
	for index, kind in pairs(kinds) do
		count = math.max(count, index)
		if kind == "d" then
			arguments[index] = (index == 1 and string.find(format, "^|H")) and 1 or EXAMPLE_ROLL
		else
			arguments[index] = index == lastText and link or EXAMPLE_LOOTER
		end
	end
	local ok, line = pcall(string.format, format, unpack(arguments, 1, count))
	if not ok then
		return false, tostring(line)
	end
	return line
end

-- Each player's roll and its number: { constant, roll kind }.
local ROLL_RESULT_FORMATS = {
	{ "LOOT_ROLL_ROLLED_NEED_ROLE_BONUS", ns.ROLL_KIND_NEED },
	{ "LOOT_ROLL_ROLLED_NEED", ns.ROLL_KIND_NEED },
	{ "LOOT_ROLL_ROLLED_GREED", ns.ROLL_KIND_GREED },
	{ "LOOT_ROLL_ROLLED_DE", ns.ROLL_KIND_DISENCHANT },
}

-- Who won: { constant, roll kind the line carries, true for the player's own }.
local ROLL_WON_FORMATS = {
	{ "LOOT_ROLL_YOU_WON_NO_SPAM_NEED", ns.ROLL_KIND_NEED, true },
	{ "LOOT_ROLL_YOU_WON_NO_SPAM_GREED", ns.ROLL_KIND_GREED, true },
	{ "LOOT_ROLL_YOU_WON_NO_SPAM_DE", ns.ROLL_KIND_DISENCHANT, true },
	{ "LOOT_ROLL_WON_NO_SPAM_NEED", ns.ROLL_KIND_NEED },
	{ "LOOT_ROLL_WON_NO_SPAM_GREED", ns.ROLL_KIND_GREED },
	{ "LOOT_ROLL_WON_NO_SPAM_DE", ns.ROLL_KIND_DISENCHANT },
	{ "LOOT_ROLL_YOU_WON", nil, true },
	{ "LOOT_ROLL_WON" },
}

-- Each pass as Roll Audit reads it: { constant, true for the player's own }.
local ROLL_PASS_FORMATS = {
	{ "LOOT_ROLL_PASSED_SELF", true },
	{ "LOOT_ROLL_PASSED_SELF_AUTO", true },
	{ "LOOT_ROLL_PASSED_AUTO" },
	{ "LOOT_ROLL_PASSED_AUTO_FEMALE" },
	{ "LOOT_ROLL_PASSED" },
}

-- The lines Hide Roll Messages keeps out of chat besides the rolls above: the roll opening and every pick.
local ROLL_CHATTER_FORMATS = {
	"LOOT_ROLL_STARTED",
	"LOOT_ROLL_NEED",
	"LOOT_ROLL_NEED_SELF",
	"LOOT_ROLL_NEED_SELF_OFF_SPEC",
	"LOOT_ROLL_GREED",
	"LOOT_ROLL_GREED_SELF",
	"LOOT_ROLL_DISENCHANT",
	"LOOT_ROLL_DISENCHANT_SELF",
	"LOOT_ROLL_PASSED",
	"LOOT_ROLL_PASSED_SELF",
	"LOOT_ROLL_PASSED_AUTO",
	"LOOT_ROLL_PASSED_AUTO_FEMALE",
	"LOOT_ROLL_PASSED_SELF_AUTO",
	"LOOT_ROLL_LOST_ROLL",
}

local function AppendRollLine(lines, constant, link, check)
	local line, problem = BuildRollLine(_G[constant], link)
	if line == nil then
		lines[#lines + 1] = string.format("[SKIP] %s: not on this client", constant)
	elseif not line then
		lines[#lines + 1] = string.format("[ERROR] %s: %s", constant, problem)
	else
		local ok, detail = check(line)
		lines[#lines + 1] = string.format("[%s] %s: %s", ok and "OK" or "FAIL", constant, detail)
		if not ok then
			lines[#lines + 1] = "    " .. LinkCell(line)
		end
	end
end

-- A pass must not read as everyone passing, which Roll Audit asks first.
local function AppendRollLines(lines, link)
	for _, entry in ipairs(ROLL_RESULT_FORMATS) do
		AppendRollLine(lines, entry[1], link, function(line)
			local player, rollKind, roll, parsedLink = ns.ParseRollResultMessage(line)
			local ok = player == EXAMPLE_LOOTER and rollKind == entry[2] and roll == EXAMPLE_ROLL and parsedLink == link
			return ok, string.format("read player %s, %s %s", tostring(player), tostring(rollKind), tostring(roll))
		end)
	end
	for _, entry in ipairs(ROLL_WON_FORMATS) do
		AppendRollLine(lines, entry[1], link, function(line)
			local isWon, winner, parsedLink, rollKind, roll = ns.ParseRollWonMessage(line)
			local ok = isWon
				and winner == (not entry[3] and EXAMPLE_LOOTER or nil)
				and parsedLink == link
				and rollKind == entry[2]
				and roll == (entry[2] and EXAMPLE_ROLL or nil)
			return ok,
				string.format(
					"read as won %s, winner %s, %s %s",
					YesNo(isWon),
					winner and tostring(winner) or "you",
					tostring(rollKind),
					tostring(roll)
				)
		end)
	end
	for _, entry in ipairs(ROLL_PASS_FORMATS) do
		AppendRollLine(lines, entry[1], link, function(line)
			local isPass, passer, parsedLink = ns.ParseRollPassMessage(line)
			local allPassed = ns.ParseRollAllPassedMessage(line) ~= nil
			local ok = isPass
				and not allPassed
				and passer == (not entry[2] and EXAMPLE_LOOTER or nil)
				and parsedLink == link
			return ok,
				string.format(
					"Roll Audit reads a pass %s, by %s, as everyone passing %s",
					YesNo(isPass),
					passer and tostring(passer) or "you",
					YesNo(allPassed)
				)
		end)
	end
	AppendRollLine(lines, "LOOT_ROLL_ALL_PASSED", link, function(line)
		local parsedLink = ns.ParseRollAllPassedMessage(line)
		local ok = parsedLink == link
		return ok, "Roll Audit reads everyone passed: " .. YesNo(ok)
	end)
	for _, constant in ipairs(ROLL_CHATTER_FORMATS) do
		AppendRollLine(lines, constant, link, function(line)
			local hidden = ns.IsRollChatterMessage(line)
			return hidden, "Hide Roll Messages would hide it: " .. YesNo(hidden)
		end)
	end
end

-- The link the lines are built with: the first item in the bags, else the Hearthstone once it is cached.
local function SampleLink()
	local link = BagItemLinks()[1]
	if link then
		return link, "the first item in your bags"
	end
	local _, hearthstoneLink = C_Item.GetItemInfo(ns.ITEM_IDS.BIND_PROBE)
	return hearthstoneLink, "the Hearthstone"
end

--[[
    Builds each line the client would print, with a real link from the bags so
    the link's shape is the client's, and runs it through the same parsers. A
    FAIL names a format this client's line no longer matches. Builds strings
    only: nothing is printed or shown.
]]
function ns:BuildLootLineReport()
	local lines = { GetClientHeader(), "" }
	local link, source = SampleLink()
	if not link then
		lines[#lines + 1] = "No item link to build with: put an item in your bags and run this again."
		return table.concat(lines, "\n")
	end
	lines[#lines + 1] = string.format("Built with %s: %s", source, LinkCell(link))
	lines[#lines + 1] = ""
	AppendOwnLines(lines, link)
	AppendGroupLines(lines, link)
	AppendMoneyLine(lines)
	AppendCurrencyLines(lines)
	lines[#lines + 1] = ""
	AppendRollLines(lines, link)

	local itemIdentifier = tonumber(string.match(link, "item:(%d+)"))
	local quality = ns.GetLinkQuality(link)
	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format(
		"This item: quality %s, Openables List action %s",
		tostring(quality),
		tostring(ns:GetOpeningAction(itemIdentifier))
	)
	local _, _, _, _, _, classIdentifier, subclassIdentifier = C_Item.GetItemInfoInstant(itemIdentifier)
	-- Nil while the client hasn't loaded the item.
	local bindType = select(14, C_Item.GetItemInfo(itemIdentifier))
	lines[#lines + 1] = string.format(
		"What the Filters read: item class %s, subclass %s, bind type %s (Bind on Pickup is %s, quest item %s), starts a quest %s",
		tostring(classIdentifier),
		tostring(subclassIdentifier),
		tostring(bindType),
		tostring(ns.BIND_ON_PICKUP),
		tostring(ns.BIND_QUEST_ITEM),
		YesNo(ns.ItemStartsQuest(itemIdentifier))
	)
	if ns.db and ns.db.profile then
		lines[#lines + 1] = string.format(
			"It would get a toast (with Loot Toasts on): yours %s, a group member's %s",
			YesNo(ns.IsLootToastWanted(quality, itemIdentifier, nil)),
			YesNo(ns.IsLootToastWanted(quality, itemIdentifier, EXAMPLE_LOOTER))
		)
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Loot Announcements Context
--------------------------------------------------------------------------------

-- ns:Announce sends nothing while Enable Loot Announcements is off; each sender then has its own switch.
function ns:BuildAnnouncementsContextReport()
	local lines = { GetClientHeader(), "" }
	AppendProfileLines(lines)
	local profile = ns.db and ns.db.profile
	if not profile then
		lines[#lines + 1] = "(saved variables not loaded)"
		return table.concat(lines, "\n")
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] =
		string.format("Enable Loot Announcements: %s (off sends nothing to anyone)", OnOff(profile.lootNotifications))
	lines[#lines + 1] = string.format(
		"Group chat channel now: %s (none when not grouped: a trade then whispers the partner, and master loot lines stay quiet)",
		tostring(ns:GetGroupChatChannel() or "none")
	)
	lines[#lines + 1] = string.format(
		"Trades: %s, when %s, sent to %s; in a group %s, in a raid %s; trade window frame present %s",
		OnOff(profile.announceTrade),
		tostring(profile.announceTradeCondition),
		tostring(profile.announceTradeOutput),
		YesNo(IsInGroup()),
		YesNo(UnitInRaid("player")),
		YesNo(TradeFrame ~= nil)
	)
	-- The trade window's own announce box, made at the first trade where the window exists, shown while Enable is on.
	local checkbox = _G.GogoLootTradeAnnounceCheckbox
	lines[#lines + 1] = string.format(
		"Trade window checkbox: created %s, shown %s",
		YesNo(checkbox ~= nil),
		YesNo(checkbox ~= nil and checkbox:IsShown())
	)
	lines[#lines + 1] = string.format(
		"Master loot: hand-outs %s from quality %s, manual hand-outs %s, destination changes %s",
		OnOff(profile.announceMasterLootAuto),
		tostring(profile.announceMasterLootAutoThreshold),
		OnOff(profile.announceMasterLootManual),
		OnOff(profile.announceDestinations)
	)
	lines[#lines + 1] = string.format("Target marker: %s", tostring(ns.TARGET_MARKER))
	lines[#lines + 1] = string.format("Welcome message at login: %s", OnOff(ns.db.global.showWelcome))
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Roll Macro Context
--------------------------------------------------------------------------------

--[[
    Raid Roll Winner counts only a /roll from 1 to the group's size, two or
    more, with roller and winner found by roster place. With Enable Loot
    Announcements off, Group output prints instead.
]]
local function AppendRaidRollLines(lines, groupSize)
	local profile = ns.db.profile
	local posts = profile.raidRollOutput == ns.RAID_ROLL_OUTPUT_GROUP and profile.lootNotifications
	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format(
		"Raid Roll Winner: %s, output %s, so a counted roll %s",
		OnOff(profile.raidRollWinner),
		tostring(profile.raidRollOutput),
		posts and string.format("posts to %s", tostring(ns:GetGroupChatChannel() or "no channel (not grouped)"))
			or "prints to you"
	)
	if IsInGroup() and groupSize >= 2 then
		lines[#lines + 1] = string.format(
			"  Counts now: a /roll 1-%d in this %d-player group: %s",
			groupSize,
			groupSize,
			YesNo(profile.raidRollWinner)
		)
	else
		lines[#lines + 1] = string.format(
			"  Counts now: nothing (grouped %s, %d members; a raid roll needs a group of 2 or more)",
			YesNo(IsInGroup()),
			groupSize
		)
	end
	local places, ownName = {}, ns:NormalizePlayerName(ns:GetCleanUnitName("player"))
	local ownPlace
	for place = 1, groupSize do
		local name = ns.GetRaidRollPlayer(place)
		places[#places + 1] = string.format("%d %s", place, name and Ambiguate(name, "short") or "nil")
		if name and ns:NormalizePlayerName(name) == ownName then
			ownPlace = place
		end
	end
	lines[#lines + 1] = string.format(
		"  Roster places as it reads them (a nil roller or winner stops it): %s",
		#places > 0 and table.concat(places, ", ") or "none"
	)
	lines[#lines + 1] =
		string.format("  Your own place: %s", ownPlace and tostring(ownPlace) or "not found (claims place 1)")
	local isRegistered = C_ChatInfo.IsAddonMessagePrefixRegistered
	lines[#lines + 1] = string.format(
		"  Add-on channel prefix %q registered: %s, claim wait %ss",
		ns.ADDON_MESSAGE_PREFIX,
		type(isRegistered) == "function" and YesNo(isRegistered(ns.ADDON_MESSAGE_PREFIX)) or "unreadable",
		tostring(ns.RAID_ROLL_CLAIM_WAIT)
	)
	local high = groupSize >= 2 and groupSize or 5
	local line, problem = BuildLine(RANDOM_ROLL_RESULT, EXAMPLE_LOOTER, 3, 1, high)
	if line then
		local roller, roll, low, top = ns.ParseRandomRollMessage(line)
		lines[#lines + 1] = string.format(
			"  Roll line %q read back as roller %s, roll %s, range %s-%s",
			(line:gsub("|", "||")),
			tostring(roller),
			tostring(roll),
			tostring(low),
			tostring(top)
		)
	else
		lines[#lines + 1] = "  Roll line: ERROR, " .. tostring(problem)
	end
end

--[[
    GetNumMacros is read through _G, since GogoLoot itself never calls it;
    MAX_ACCOUNT_MACROS comes from the Macros window, so it reads nil until
    that window has loaded.
]]
---@return string
function ns:BuildRollMacroContextReport()
	local lines = { GetClientHeader(), "" }
	AppendProfileLines(lines)
	if not ns.db then
		lines[#lines + 1] = "(saved variables not loaded)"
		return table.concat(lines, "\n")
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format(
		"Enable Roll Macro: %s (account-wide; a change asked for in combat waits for combat to end)",
		OnOff(ns.db.global.rollMacro)
	)
	local getNumMacros = _G.GetNumMacros
	local accountCount = type(getNumMacros) == "function" and getNumMacros() or "unreadable"
	local maxAccount = _G.MAX_ACCOUNT_MACROS
	lines[#lines + 1] = string.format(
		"General macros: %s used of %s",
		tostring(accountCount),
		maxAccount and tostring(maxAccount) or "unknown (the Macros window hasn't loaded)"
	)
	local index = GetMacroIndexByName(ns.ROLL_MACRO_NAME)
	if index and index > 0 then
		local _, icon, body = GetMacroInfo(index)
		lines[#lines + 1] = string.format(
			"Macro %q: found at %d, icon %s (%s), text %s",
			ns.ROLL_MACRO_NAME,
			index,
			tostring(icon),
			icon == ns.ROLL_MACRO_ICON and "matches" or ("differs, GogoLoot writes " .. ns.ROLL_MACRO_ICON),
			string.gsub(body or "", "%s+$", "") == ns.ROLL_MACRO_BODY and "matches"
				or "differs (put back at the next load while the switch is on)"
		)
	else
		lines[#lines + 1] = string.format(
			"Macro %q: not found%s",
			ns.ROLL_MACRO_NAME,
			ns.db.global.rollMacro and " (made at the next load or switch-on, unless the General tab is full)" or ""
		)
	end
	local groupSize = GetNumGroupMembers()
	lines[#lines + 1] = string.format(
		"Rolls now: left-click 1-100, right-click 1-99, middle-click 1-%d (group members %d)",
		groupSize > 0 and groupSize or 100,
		groupSize
	)
	AppendRaidRollLines(lines, groupSize)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Player & Spells
--------------------------------------------------------------------------------

-- The ns.SPELLS keys the add-on gates on or listens for, in report order.
ns.DIAGNOSTIC_SPELLS = { "PICK_LOCK", "PICK_POCKET", "SHADOWMELD" }

---@return string
function ns:BuildPlayerReport()
	local lines = { GetClientHeader(), "" }
	local className, classFile = UnitClass("player")
	local raceName, raceFile = UnitRace("player")
	lines[#lines + 1] = string.format(
		"Class: %s (%s) // Race: %s (%s), sex %s // Level: %s",
		tostring(className),
		tostring(classFile),
		tostring(raceName),
		tostring(raceFile),
		tostring(UnitSex("player")),
		tostring(UnitLevel("player"))
	)
	lines[#lines + 1] = string.format(
		"Inventory-full voice line: %s",
		(ns.SOUND_KIT_IDS.BAG_FULL_BY_RACE[raceFile] or {})[UnitSex("player")] and "this race's own"
			or "the fallback sound"
	)
	lines[#lines + 1] = ""
	for _, key in ipairs(ns.DIAGNOSTIC_SPELLS) do
		local spellIdentifier = ns.SPELLS[key]
		lines[#lines + 1] = string.format(
			"%s %s: name=%s IsPlayerSpell=%s",
			key,
			tostring(spellIdentifier),
			tostring(spellIdentifier and C_Spell.GetSpellName(spellIdentifier)),
			tostring(spellIdentifier and IsPlayerSpell(spellIdentifier))
		)
	end
	lines[#lines + 1] = string.format(
		"LOCKPICKING skill line %s: name=%s",
		tostring(ns.SKILL_LINE_IDS.LOCKPICKING),
		tostring(ns.GetLockpickingSkillName())
	)
	lines[#lines + 1] = ""
	local rank = ns.GetPlayerLockpickingSkill()
	lines[#lines + 1] = "Lockpicking rank as GogoLoot reads it: "
		.. (rank and tostring(rank) or "unavailable on this client (or not trained)")
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Name Lookups
--------------------------------------------------------------------------------

--[[
    The Game Names report: every name GogoLoot shows or matches, read exactly
    as the features read it. A NIL on a chat format is a line that goes unread
    on this client. A row whose name loads late (a spell) adds `request`,
    which the report calls and polls.
]]
local function UiLabel(constant)
	return {
		constant = constant,
		kind = "uiLabel",
		id = constant,
		lookup = function()
			return _G[constant]
		end,
	}
end

local UI_LABELS = {
	"AUTO_LOOT_DEFAULT_TEXT",
	"MASTER_LOOTER",
	"ITEM_LOOT",
	"MONEY_LOOT",
	"GENERAL",
	"MONEY",
	"WHISPER",
	"PARTY",
	"RAID",
	"NEED",
	"GREED",
	"PASS",
	"ROLL_DISENCHANT",
	"LOCKED",
	"ERR_INV_FULL",
	"ERR_TRADE_COMPLETE",
	"ERR_TRADE_CANCELLED",
	"ITEM_STARTS_QUEST",
	"ITEM_MIN_SKILL",
	"ITEM_REQ_SKILL",
	"ITEM_QUALITY0_DESC",
	"ITEM_QUALITY1_DESC",
	"ITEM_QUALITY2_DESC",
	"ITEM_QUALITY3_DESC",
	"ITEM_QUALITY4_DESC",
	"LOOT_METHOD",
	"LOOT_THRESHOLD",
	"LOOT_FREE_FOR_ALL",
	"LOOT_ROUND_ROBIN",
	"LOOT_MASTER_LOOTER",
	"LOOT_GROUP_LOOT",
	"LOOT_NEED_BEFORE_GREED",
	"RANDOM_ROLL_RESULT",
	"GOLD_AMOUNT",
	"SILVER_AMOUNT",
	"COPPER_AMOUNT",
	"GOLD_AMOUNT_SYMBOL",
	"SILVER_AMOUNT_SYMBOL",
	"COPPER_AMOUNT_SYMBOL",
	"LOOT_ITEM_SELF",
	"LOOT_ITEM_SELF_MULTIPLE",
	"LOOT_ITEM_PUSHED_SELF",
	"LOOT_ITEM_PUSHED_SELF_MULTIPLE",
	"LOOT_ITEM",
	"LOOT_ITEM_MULTIPLE",
	"LOOT_ITEM_PUSHED",
	"LOOT_ITEM_PUSHED_MULTIPLE",
	"LOOT_ROLL_STARTED",
	"LOOT_ROLL_NEED",
	"LOOT_ROLL_NEED_SELF",
	"LOOT_ROLL_NEED_SELF_OFF_SPEC",
	"LOOT_ROLL_GREED",
	"LOOT_ROLL_GREED_SELF",
	"LOOT_ROLL_DISENCHANT",
	"LOOT_ROLL_DISENCHANT_SELF",
	"LOOT_ROLL_PASSED",
	"LOOT_ROLL_PASSED_SELF",
	"LOOT_ROLL_PASSED_AUTO",
	"LOOT_ROLL_PASSED_AUTO_FEMALE",
	"LOOT_ROLL_PASSED_SELF_AUTO",
	"LOOT_ROLL_LOST_ROLL",
	"LOOT_ROLL_ALL_PASSED",
	"LOOT_ROLL_ROLLED_NEED",
	"LOOT_ROLL_ROLLED_NEED_ROLE_BONUS",
	"LOOT_ROLL_ROLLED_GREED",
	"LOOT_ROLL_ROLLED_DE",
	"LOOT_ROLL_WON",
	"LOOT_ROLL_YOU_WON",
	"LOOT_ROLL_WON_NO_SPAM_NEED",
	"LOOT_ROLL_WON_NO_SPAM_GREED",
	"LOOT_ROLL_WON_NO_SPAM_DE",
	"LOOT_ROLL_YOU_WON_NO_SPAM_NEED",
	"LOOT_ROLL_YOU_WON_NO_SPAM_GREED",
	"LOOT_ROLL_YOU_WON_NO_SPAM_DE",
	"CURRENCY",
	"CURRENCY_GAINED",
	"CURRENCY_GAINED_MULTIPLE",
	"CURRENCY_GAINED_MULTIPLE_BONUS",
	"ITEM_SPELL_TRIGGER_ONEQUIP",
	"CHAT_PARTY_GET",
	"CHAT_WHISPER_GET",
}

ns.DIAGNOSTIC_NAME_LOOKUPS = {
	-- { constant, kind, id, lookup, request }
}

local function AddNameLookup(row)
	ns.DIAGNOSTIC_NAME_LOOKUPS[#ns.DIAGNOSTIC_NAME_LOOKUPS + 1] = row
end

for _, constant in ipairs(UI_LABELS) do
	AddNameLookup(UiLabel(constant))
end

--[[
    The Character Rules captions this client offers (already cut to its
    folder at load). A section label reads NIL before WoW Forever, where the
    panel uses its own words.
]]
for _, group in ipairs(ns.CHARACTER_RULE_GROUPS) do
	AddNameLookup(UiLabel(group.labelGlobal))
end
-- The armor and weapon sections' game labels: Other's caption, and the held off-hand row's name.
for _, group in ipairs(ns.CHARACTER_RULE_GEAR_GROUPS) do
	if group.labelGlobal then
		AddNameLookup(UiLabel(group.labelGlobal))
	end
end
AddNameLookup(UiLabel("INVTYPE_HOLDABLE"))
-- Every other armor and weapon row, captioned with the client's own item subclass name as the panel reads it.
for _, group in ipairs(ns.CHARACTER_RULE_GEAR_GROUPS) do
	if group.classIdentifier then
		for _, rowIdentifier in ipairs(ns[group.types] or {}) do
			if not ns.CHARACTER_RULE_GEAR_ROW_LABELS[rowIdentifier] then
				AddNameLookup({
					constant = group.types .. "." .. tostring(rowIdentifier),
					kind = "itemSubclass",
					id = group.classIdentifier .. ":" .. tostring(rowIdentifier),
					lookup = function()
						return C_Item.GetItemSubClassInfo(group.classIdentifier, rowIdentifier)
					end,
				})
			end
		end
	end
end
for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
	AddNameLookup({
		constant = "CHARACTER_RULE_STATS." .. stat.key,
		kind = "statLabel",
		id = stat.key,
		lookup = function()
			return stat.label
		end,
	})
end

-- Every full format Character Rules matches a stat's tooltip lines with (StatLinePatterns in Features/Character-Rules.lua).
do
	local seen = {}
	for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
		for _, itemMod in ipairs(stat.itemMods) do
			local format = (itemMod:gsub("_SHORT$", ""))
			if not seen[format] then
				seen[format] = true
				AddNameLookup(UiLabel(format))
			end
		end
	end
end

-- The Rogue's class name in the Lockboxes text and the Locked reason, and the Warrior's in the Character Rules example.
for _, classToken in ipairs({ "ROGUE", "WARRIOR" }) do
	AddNameLookup({
		constant = "LOCALIZED_CLASS_NAMES_MALE." .. classToken,
		kind = "class",
		id = classToken,
		lookup = function()
			return LOCALIZED_CLASS_NAMES_MALE[classToken]
		end,
	})
end

-- Pick Pocket captions the Loot Sounds row; Pick Lock names the spell in the mini-map tooltip's Locked Items list.
for _, key in ipairs({ "PICK_POCKET", "PICK_LOCK" }) do
	AddNameLookup({
		constant = "SPELLS." .. key,
		kind = "spell",
		id = ns.SPELLS[key],
		lookup = function()
			return C_Spell.GetSpellName(ns.SPELLS[key])
		end,
		request = function()
			C_Spell.RequestLoadSpellData(ns.SPELLS[key])
		end,
	})
end

-- MoP Classic has no Lockpicking skill line, so its data carries no ID and there is no name to check.
if ns.SKILL_LINE_IDS.LOCKPICKING then
	AddNameLookup({
		constant = "SKILL_LINE_IDS.LOCKPICKING",
		kind = "skillLine",
		id = ns.SKILL_LINE_IDS.LOCKPICKING,
		lookup = ns.GetLockpickingSkillName,
	})
end

-- The item types the Loot Toasts Filters rows and the item lists' headers are captioned with.
for _, row in ipairs(ns.LOOT_TOAST_FILTER_ROWS) do
	if row.subclassIdentifier then
		AddNameLookup({
			constant = "LOOT_TOAST_FILTER_ROWS." .. row.key,
			kind = "itemSubclass",
			id = row.classIdentifier .. ":" .. row.subclassIdentifier,
			lookup = function()
				return C_Item.GetItemSubClassInfo(row.classIdentifier, row.subclassIdentifier)
			end,
		})
	elseif row.classIdentifier then
		AddNameLookup({
			constant = "LOOT_TOAST_FILTER_ROWS." .. row.key,
			kind = "itemClass",
			id = row.classIdentifier,
			lookup = function()
				return C_Item.GetItemClassInfo(row.classIdentifier)
			end,
		})
	end
end

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

-- Dumped as a row count: a raid's worth runs to hundreds of item links, more than the output box shows.
ns.DIAGNOSTIC_SAVED_SUMMARY_KEYS = {
	awarded = true,
	dropRaids = true,
	pickedUp = true,
}

--------------------------------------------------------------------------------
-- Validate Data Sources
--------------------------------------------------------------------------------

--[[
    One entry per flavor-folder file; `label` is the file stem. `table` is a
    name, not a reference, so a table this folder never built still gets a
    row. `kind` "other" is ids no client API looks up. rowId(key, row) copes
    with the three table shapes. dataColumns, { header, getter(key, row) },
    set the file's values beside the client's.
]]
local function FirstFieldIsId(_, row)
	return type(row) == "table" and row[1] or nil
end

local function SecondField(_, row)
	return type(row) == "table" and row[2] or nil
end

local function KeyIsId(key)
	return key
end

local function ValueIsId(_, value)
	return value
end

local function RowValue(_, value)
	return value
end

local function KeyValue(key)
	return key
end

ns.DIAGNOSTIC_DATA_SOURCES = {
	-- { label, sources = { { table, kind, rowId, dataColumns } } }
	{
		label = "Default-Item-Lists",
		sources = {
			{
				table = "DEFAULT_IGNORE_LIST_SOLO",
				kind = "item",
				rowId = FirstFieldIsId,
				dataColumns = { { "DATA_ROLL_ACTION", SecondField } },
			},
			{ table = "DEFAULT_IGNORE_LIST_MASTER", kind = "item", rowId = FirstFieldIsId },
		},
	},
	{
		label = "Lockbox-Skill-Levels",
		sources = {
			{
				table = "LOCKBOX_SKILL_LEVELS",
				kind = "item",
				rowId = KeyIsId,
				dataColumns = { { "DATA_REQUIRED_SKILL", RowValue } },
			},
		},
	},
	{
		label = "Openable-Items",
		sources = {
			{
				table = "OPENABLE_ITEMS",
				kind = "item",
				rowId = KeyIsId,
				dataColumns = { { "DATA_DEFAULT_ACTION", RowValue } },
			},
			-- The level each row above needs before Automated Opening uses it, held against the client's own.
			{
				table = "OPENABLE_ITEM_LEVELS",
				kind = "item",
				rowId = KeyIsId,
				dataColumns = { { "DATA_REQUIRED_LEVEL", RowValue } },
			},
		},
	},
	{
		label = "Game-IDs",
		sources = {
			{
				table = "SKILL_LINE_IDS",
				kind = "other",
				rowId = ValueIsId,
				dataColumns = { { "DATA_KEY", KeyValue } },
			},
			{
				table = "ITEM_IDS",
				kind = "item",
				rowId = ValueIsId,
				dataColumns = { { "DATA_KEY", KeyValue } },
			},
			{
				table = "SAMPLE_ITEM_IDS",
				kind = "item",
				rowId = ValueIsId,
				dataColumns = { { "DATA_KEY", KeyValue } },
			},
			{
				table = "SOUND_KIT_IDS",
				kind = "other",
				rowId = ValueIsId,
				dataColumns = { { "DATA_KEY", KeyValue } },
			},
		},
	},
	{
		label = "Character-Rule-Stats",
		sources = {
			{ table = "CHARACTER_RULE_STAT_KEYS", kind = "other", rowId = ValueIsId },
			-- The Equip spells whose descriptions word the stat lines; a folder whose client words none declares it empty.
			{
				table = "CHARACTER_RULE_EQUIP_SPELLS",
				kind = "spell",
				rowId = KeyIsId,
				dataColumns = {
					{
						"DATA_STATS",
						function(_, row)
							return table.concat(row, " ")
						end,
					},
				},
			},
		},
	},
	{
		label = "Character-Rule-Gear-Types",
		sources = {
			{ table = "CHARACTER_RULE_ARMOR_TYPES", kind = "other", rowId = ValueIsId },
			{ table = "CHARACTER_RULE_WEAPON_TYPES", kind = "other", rowId = ValueIsId },
			-- The Loot Roll Sanity Check's drops, each with its kind, to hold against its quality and binding in game.
			{
				table = "SANITY_CHECK_TRASH",
				kind = "item",
				rowId = FirstFieldIsId,
				dataColumns = { { "DATA_KIND", SecondField } },
			},
			{
				table = "SANITY_CHECK_DUNGEON_BOSSES",
				kind = "item",
				rowId = FirstFieldIsId,
				dataColumns = { { "DATA_KIND", SecondField } },
			},
			{
				table = "SANITY_CHECK_RAID_BOSSES",
				kind = "item",
				rowId = FirstFieldIsId,
				dataColumns = { { "DATA_KIND", SecondField } },
			},
			-- The boxes each class starts with, by class file: row counts, since a class file is no game id.
			{ table = "CLASS_ARMOR_STARTER", kind = "other", rowId = KeyIsId },
			{ table = "CLASS_WEAPON_STARTER", kind = "other", rowId = KeyIsId },
			{ table = "CLASS_STAT_STARTER", kind = "other", rowId = KeyIsId },
		},
	},
	{
		label = "Spells",
		sources = {
			{ table = "SPELLS", kind = "spell", rowId = ValueIsId, dataColumns = { { "DATA_KEY", KeyValue } } },
		},
	},
}
