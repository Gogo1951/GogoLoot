local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

--[[
    Existence and shape checks only: read-only, no side effects, no protected
    calls. One row per API GogoLoot calls or guards, wherever it lives, plus the
    globals its core loop can't run without. Modern and legacy fallbacks are
    listed separately so the report shows exactly what each client provides,
    and Validate-Data.lua appends the readers its own export uses. The two trade-result globals are the only strings
    probed for that path: both the trade watcher and the master-loot error
    correlation match on numeric message ids resolved through
    GetGameMessageInfo, and read those globals only as a fallback for a client
    where the constants resolved to no id at all. Which constants did resolve
    is reported by Loot Method, since an existence check cannot show that.
]]
-- Builds the check for a global of one type, read by name so a client without it reads nil.
local function GlobalIsType(globalName, expectedType)
	return function()
		return type(_G[globalName]) == expectedType
	end
end

-- Builds the check for a function inside a namespace table.
local function MemberIsFunction(namespaceName, memberName)
	return function()
		local namespace = _G[namespaceName]
		return type(namespace) == "table" and type(namespace[memberName]) == "function"
	end
end

ns.DIAGNOSTIC_API_CHECKS = {
	-- { label, testFunction }

	-- Add-on metadata — Core.lua version lookup, Flavor.lua, the Other Add-ons report, and Automated Opening Context's Open Sesame check
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
	--[[
	    The tooltip-text pair ns.GetTooltipLines picks between: the data getters
	    where the client ships both, the hidden scan tooltip where it doesn't. A
	    FAIL on one half is the report working, since the pair says which branch
	    this client took.
	]]
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
	--[[
	    Validate Data's other item reads; one a client lacks leaves its columns
	    blank. The stat read goes through ns.GetItemStats, so a client needs
	    either C_Item.GetItemStats or the legacy GetItemStats.
	]]
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
	--[[
	    Speedy Loot's bag-space budget: a specialty bag's family through either
	    half of the family read, and the keyring where the client has one,
	    asked through whichever of the two keyring checks it ships. A FAIL on
	    one half of a pair is the report saying which this client took.
	]]
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

	-- Auto-loot CVar — Auto-Loot.lua / Utilities.lua; SetCVar and GetCVar are Diagnostics' own, for its Taint Log and its CVar, Display and Taint reads
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

	--[[
        Master-loot error correlation and trade-result detection both resolve
        constant names to this client's numeric ids through GetGameMessageInfo,
        so that one API is all there is to probe. Which constants actually
        resolved is reported by the Loot Method report, since an
        existence check can't show that.
    ]]
	{
		"GetGameMessageInfo",
		function()
			return type(GetGameMessageInfo) == "function"
		end,
	},

	--[[
        Trade result globals — Announcements-Trade.lua. These are only the
        fallback for a client where neither constant resolved to an id; the ids
        themselves are in the Loot Method report.
    ]]
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
	--[[
	    The player's own currency lines, read back for a currency toast, and the
	    currency's icon — Loot-Toasts-Money.lua. Currency arrived with
	    Cataclysm, so a FAIL is expected on the earlier clients.
	]]
	{ "CURRENCY_GAINED (string)", GlobalIsType("CURRENCY_GAINED", "string") },
	{ "CURRENCY_GAINED_MULTIPLE (string)", GlobalIsType("CURRENCY_GAINED_MULTIPLE", "string") },
	{ "CURRENCY_GAINED_MULTIPLE_BONUS (string)", GlobalIsType("CURRENCY_GAINED_MULTIPLE_BONUS", "string") },
	{ "C_CurrencyInfo.GetCurrencyInfo", MemberIsFunction("C_CurrencyInfo", "GetCurrencyInfo") },

	--[[
        The roll lines, read back for the winning roll on a toast and kept out
        of chat by Hide Roll Messages — Utilities-Chat-Lines.lua. The core forms every
        client prints; a FAIL means that line goes unread there. The others
        (Disenchant, the quiet won lines) are read only where the client has
        them.
    ]]
	{ "LOOT_ROLL_NEED (string)", GlobalIsType("LOOT_ROLL_NEED", "string") },
	{ "LOOT_ROLL_GREED (string)", GlobalIsType("LOOT_ROLL_GREED", "string") },
	{ "LOOT_ROLL_PASSED (string)", GlobalIsType("LOOT_ROLL_PASSED", "string") },
	{ "LOOT_ROLL_ROLLED_NEED (string)", GlobalIsType("LOOT_ROLL_ROLLED_NEED", "string") },
	{ "LOOT_ROLL_ROLLED_GREED (string)", GlobalIsType("LOOT_ROLL_ROLLED_GREED", "string") },
	{ "LOOT_ROLL_WON (string)", GlobalIsType("LOOT_ROLL_WON", "string") },
	{ "LOOT_ROLL_YOU_WON (string)", GlobalIsType("LOOT_ROLL_YOU_WON", "string") },
	{ "NEED (string)", GlobalIsType("NEED", "string") },
	{ "GREED (string)", GlobalIsType("GREED", "string") },
	-- Hide Roll Messages — Roll-Messages.lua
	{ "ChatFrameUtil.AddMessageEventFilter", MemberIsFunction("ChatFrameUtil", "AddMessageEventFilter") },
	-- Standard Loot Messages flips the General tab's loot lines through its message groups.
	{ "ChatFrame1.ContainsMessageGroup", MemberIsFunction("ChatFrame1", "ContainsMessageGroup") },
	{ "ChatFrame1.AddMessageGroup", MemberIsFunction("ChatFrame1", "AddMessageGroup") },
	{ "ChatFrame1.RemoveMessageGroup", MemberIsFunction("ChatFrame1", "RemoveMessageGroup") },

	-- The Loot Toasts Quest row's quest-starter read — Utilities-Scan-Tooltip.lua
	{ "ITEM_STARTS_QUEST (string)", GlobalIsType("ITEM_STARTS_QUEST", "string") },
	--[[
	    The item classes the Filters rows and the item lists' headers file
	    items under, Data.lua's ns.ITEM_CLASS_* constants: the legacy globals
	    first, then Enum.ItemClass, then a fixed number. A FAIL on one half is
	    the report saying which this client took.
	]]
	{ "LE_ITEM_CLASS_ARMOR (number)", GlobalIsType("LE_ITEM_CLASS_ARMOR", "number") },
	{
		"Enum.ItemClass",
		function()
			return type(Enum) == "table" and type(Enum.ItemClass) == "table"
		end,
	},
	-- The bind types and the Mount and Companion Pets subclasses, from the same kind of route: the enum, else a fixed number.
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
	-- The mini-map tooltip names each group context with these — Minimap-Button.lua
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
	{ "ERR_INV_FULL (string)", GlobalIsType("ERR_INV_FULL", "string") },
	{ "WHISPER (string)", GlobalIsType("WHISPER", "string") },
	{ "MONEY (string)", GlobalIsType("MONEY", "string") },
	-- The Rogue's class name in the Lockboxes text and the Locked reason
	{ "LOCALIZED_CLASS_NAMES_MALE (table)", GlobalIsType("LOCALIZED_CLASS_NAMES_MALE", "table") },
	--[[
        Proves bindType's return position rather than trusting it: the probe
        item is Bind on Pickup and in every bag, so a FAIL here with the
        Hearthstone cached means the Bind on Pickup toast option reads the wrong
        return on this client.
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
    The probes read feature state through the accessors the feature files
    export (ns:IsAutomatedOpeningPaused, ns:AreWeMasterLooter and the like), so
    a report shows the exact values the features act on rather than a copy of
    their logic. Where a feature keeps a gate to itself, the probe prints each
    input the gate reads instead.
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

-- The profile every switch below is read from, and the character whose own section Character Rules reads.
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

-- autoLootDefault, the one CVar GogoLoot reads and enforces (Features/Auto-Loot.lua), raw and as the add-on reads it.
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

-- Every bag slot's item link, bag 0 first.
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
    Live read of the loot-method APIs the master-looter path depends on. An
    existence check can't prove the APIs return the shapes GogoLoot's guards
    expect, so this prints the actual return values, the Enum.LootMethod
    constants the modern API is mapped onto (Master-Looter.lua SafeGetLootMethod),
    and how GogoLoot ultimately interprets them via AreWeMasterLooter and
    WillAutoMasterLoot, then every setting and destination Automated Master
    Looting reads. All calls are read-only.
]]

local function PackReturns(...)
	return select("#", ...), { ... }
end

--[[
    One "constant -> id on this client" block, sorted so two reports from
    different clients diff cleanly. `describe` turns the constant table's value
    into the trailing note, since the two tables carry different things: the
    loot table carries the locale key it announces, the trade table the result
    it means.
]]
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

-- The loading-screen guard's timer in Features/Master-Looter.lua, which ns:IsTimerPending reads by name.
local ZONE_SETTLE_TIMER = "GogoLoot.MasterLooter.ZoneSettle"

--[[
    What Automated Master Looting reads before it hands anything out: the group
    and instance it is in, its switches, and each quality's destination with
    whether the loot threshold lets that quality reach the master looter at
    all. An unset destination is Loot Window: nothing goes out automatically.
]]
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
    The names the game offers one loot slot to, keyed the way the distribution
    pass looks a destination up (BuildCandidateMap in
    Features/Master-Looter-Distribution.lua): lowercased, and normalized
    without a realm. The pass also drops a normalized name two candidates
    share, which this leaves in.
]]
local function SlotCandidates(slotIndex)
	local candidates, names = {}, {}
	for groupIndex = 1, GetNumGroupMembers() do
		local candidateName = GetMasterLootCandidate(slotIndex, groupIndex)
		if candidateName then
			names[#names + 1] = candidateName
			candidates[strlower(candidateName)] = true
			local normalizedName = ns:NormalizePlayerName(candidateName)
			if normalizedName then
				candidates[normalizedName] = true
			end
		end
	end
	return candidates, names
end

--[[
    The first check that keeps one slot from being handed out, in the order
    TryDistributeSlot in Features/Master-Looter-Distribution.lua makes them, or
    who it would go to.
]]
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

--[[
    The open loot window slot by slot: what each holds, who the game offers it
    to, and the verdict. Read while the window is open; with WillAutoMasterLoot
    false, nothing is handed out whatever a row says.
]]
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

	-- Raw API returns — legacy first, then modern, so the report shows what each client exposes.
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
		for _, key in ipairs({ "Freeforall", "Roundrobin", "Masterlooter", "Group", "Needbeforegreed" }) do
			lines[#lines + 1] = string.format("  %s = %s", key, tostring(Enum.LootMethod[key]))
		end
	else
		lines[#lines + 1] = "Enum.LootMethod: not available (legacy string API in use)"
	end

	--[[
	    How GogoLoot interprets the above. WillAutoMasterLoot additionally depends
	    on the Automated Master Looting setting and, outside instances, its override.
	]]
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
        Which message constants resolved to a numeric id on this client, for both
        the master-loot errors and the trade results. An existence check can't
        show this: the ids are per-flavor and are looked up by name through
        GetGameMessageInfo, so a constant that resolves to nothing here is a
        result this client will never report — a trade watcher that works on Era
        and is dead on Anniversary looks identical to one that works everywhere
        until this block is read.

        Both tables go through one walk. The scan is the entire cost of the
        lookup, and running it twice would only invite the two blocks to disagree
        about how many messages the client carries.
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

--[[
    What the Loot Sounds read beyond their switches: the open loot window's
    source (CurrentLootSource in Features/Loot-Sounds.lua chimes only for a
    corpse, chest or node, never for loot an item made), whether the player's
    casts read secret on WoW Forever (a secret Pick Pocket cast never arms its
    sound), and the game's own sound switch and master volume, which both
    sounds play through.
]]
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
    The space a Speedy Loot pass measures loot against (ReadBagSpace in
    Features/Speedy-Loot.lua): each bag's free slots and family, 0 for a
    general-purpose bag, and the keyring where the client has one, asked the
    way the feature asks. A herb or a key with no bag of its family left takes
    a general slot, so a full herb bag can strand loot while general slots
    read free.
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
    Every slot in the open loot window with what the pass reads on it, bottom
    first as the pass walks it: a LOCKED slot is skipped (still being rolled
    for, or not the player's yet), and a taken item whose bind type is Bind on
    Pickup, or nil because the client hasn't loaded it, keeps the window up.
    STACK, CARRIED and FAMILY are what the pass weighs to find the item room
    (TakeSpaceFor). Reading an item's info may ask the client to load it.
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
			local getFamily = C_Item.GetItemFamily or GetItemFamily
			family = getFamily and getFamily(itemLink)
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
    Speedy Loot (Features/Speedy-Loot.lua) acts on LOOT_READY only when its
    switch is on, the player isn't the master looter, and Auto Loot and the
    auto-loot modifier disagree (Auto Loot on and the key up, or off and the key
    held), and it keeps the window up when the bags run short. The Loot Sounds
    read the same loot window. The modifier's key comes from GetModifiedClick,
    which GogoLoot itself never calls, so it is read through _G and may be nil.
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
	--[[
	    The window the pass hides is ElvUI's or Tukui's where one is loaded,
	    else LootFrame, hidden through its Open method where the frame carries
	    one (WoW Forever) and through OnShow everywhere else.
	]]
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
    The windows Automated Opening waits out (IsInteractionActive in
    Features/Automated-Opening.lua), by their global names. A client lacks the
    auction house it doesn't use, which reads as closed. The loot window is
    whichever ns.GetLootWindow picks, ElvUI's or Tukui's ahead of LootFrame,
    as the opener reads it.
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

-- The open windows by name, or "none".
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
    Stealth and Shadowmeld as the opener reads them. On WoW Forever an aura or a
    cast can read secret, and a secret can't be tested, so each is asked of
    C_Secrets first and left unread when it would be secret, as the feature does.
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

-- The Openables List: the data's rows, the player's saved changes by kind, and what is listed now.
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
    Everything Automated Opening checks before an open (IsSafeToOpen and the
    open tick in Features/Automated-Opening.lua), each input as it reads now,
    then the list and lockbox settings behind which items it opens at all. The
    items it set aside after refused opens are held inside that file and don't
    show here; a /reload or a level-up clears them.
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

--[[
    What Automated Opening would do with one bag slot, read the way ShouldOpen
    in Features/Automated-Opening.lua reads it: not listed, set to Ignore,
    waiting for a level, waiting for its lock, or ready. An item set aside after
    refused opens still reads OPEN here.
]]
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
    Whether the client's own tooltip already states the Lockpicking
    requirement, matched as Lockbox Tooltips matches it (ITEM_MIN_SKILL). When
    it does, Lockbox Tooltips adds only your rank, and adds nothing at all
    where your rank can't be read.
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
    Every openable item in the bags with the verdict Automated Opening acts on:
    its data default, reason included (UNLOCKED, IGNORE_RAID and the like), its
    action (nil for one the player removed), the level it needs (blank while
    the item isn't cached), and whether the scan tooltip reads it as locked.
    The tooltip's line count is what separates a truly unlocked box from a scan
    tooltip that read nothing at all, since both answer "not locked". Then
    what Lockbox Tooltips reads on it: the Lockpicking it needs, blank for an
    item the data doesn't list (which gets no tooltip block), and whether the
    client's tooltip already states that. A lockbox off the Openables List
    still gets a row. Read-only; nothing here opens anything.
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
				local requiredLevel = select(5, C_Item.GetItemInfo(itemIdentifier))
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
    What decides a roll (EvaluateRoll in Features/Automated-Rolls.lua): the
    master switch, Item Overrides ahead of everything else, then Character
    Rules for anything that isn't a quest item, then the group context's
    setting, which only ever takes items that aren't Bind on Pickup.
    Legendaries, recipes, mounts and pets are never rolled on at all. Hide Roll
    Messages answers to the master switch too.

    A roll open now is checked as the roll handler checks it: whether its link
    has resolved, whether Need and Greed are open to the player (a Need with no
    Need open falls back to Greed, and nothing rolls without Greed), and
    whether its retry is still polling for an item the client hasn't loaded.
    The retry's timer name is ROLL_RETRY_TIMER_PREFIX in
    Features/Automated-Rolls.lua plus the roll id.
]]
local ROLL_RETRY_TIMER_PREFIX = "GogoLoot.RollRetry."

local function AppendOpenRolls(lines)
	local frameCount = type(_G.NUM_GROUP_LOOT_FRAMES) == "number" and _G.NUM_GROUP_LOOT_FRAMES or 4
	local open = 0
	for frameIndex = 1, frameCount do
		local frame = _G["GroupLootFrame" .. frameIndex]
		local rollIdentifier = frame and frame:IsShown() and frame.rollID
		if type(rollIdentifier) == "number" then
			open = open + 1
			local _, _, _, quality, bindOnPickup, canNeed, canGreed = GetLootRollItemInfo(rollIdentifier)
			lines[#lines + 1] = string.format(
				"  Roll %s: quality %s, Bind on Pickup %s, Need open %s, Greed open %s, retry polling %s, link %s",
				tostring(rollIdentifier),
				tostring(quality),
				YesNo(bindOnPickup),
				YesNo(canNeed),
				YesNo(canGreed),
				YesNo(ns:IsTimerPending(ROLL_RETRY_TIMER_PREFIX .. rollIdentifier)),
				LinkCell(GetLootRollItemLink(rollIdentifier)) ~= "" and LinkCell(GetLootRollItemLink(rollIdentifier))
					or "not resolved yet"
			)
		end
	end
	if open == 0 then
		lines[#lines + 1] = string.format("  No roll window open now (GroupLootFrame1 to %d).", frameCount)
	end
end

--[[
    How many of the Equip spells whose descriptions word the stat lines have
    loaded this session: one that hasn't builds no pattern, so its stat goes
    unseen on an Equip line. Read before Roll Verdicts and Gear Stats, which
    ask the client to load them.
]]
local function EquipSpellsLoaded()
	local loaded, total = 0, 0
	for spellIdentifier in pairs(ns.CHARACTER_RULE_EQUIP_SPELLS or {}) do
		total = total + 1
		local description = C_Spell.GetSpellDescription(spellIdentifier)
		if type(description) == "string" and description:find("%S") then
			loaded = loaded + 1
		end
	end
	return loaded, total
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
	lines[#lines + 1] = "  Party: " .. RollSettingText(profile.autoRollActionParty, profile.autoRollThresholdParty)
	lines[#lines + 1] = "  Raid: " .. RollSettingText(profile.autoRollActionRaid, profile.autoRollThresholdRaid)

	local byAction = {}
	for _, action in pairs(profile.ignoredItemsSolo) do
		byAction[action] = (byAction[action] or 0) + 1
	end
	lines[#lines + 1] = string.format(
		"Item Overrides: %s, %d items (need %d, greed %d, pass %d, manual %d)",
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
		"Character Rules on %s (%s): ticked %s",
		tostring(ns.db.keys and ns.db.keys.char),
		tostring(select(2, UnitClass("player"))),
		TickedBoxes() or "nothing"
	)
	lines[#lines + 1] = string.format(
		"  Everything Else: %s up to quality %s, Bind on Pickup %s",
		tostring(ns.CharacterRuleUnwanted(rules, "action")),
		tostring(ns.CharacterRuleUnwanted(rules, "threshold")),
		YesNo(ns.db.profile.rollBindOnPickup)
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
	lines[#lines + 1] = "Rolls open now:"
	AppendOpenRolls(lines)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Roll Verdicts
--------------------------------------------------------------------------------

--[[
    What Automated Rolls would do with one item if it dropped now, check by
    check in the order EvaluateRoll in Features/Automated-Rolls.lua makes them,
    under the group context's setting. A live roll also says whether Need or
    Greed is open to the player, which decides a Need that falls back to Greed;
    an item can't, so a NEED verdict may roll Greed.
]]
local function RollVerdict(profile, itemLink, itemIdentifier, rollAction, rollThreshold)
	if not profile.autoGreed then
		return "AUTOMATED ROLLS OFF"
	end
	local itemInformation = ns:SafeGetItemInfo(itemIdentifier)
	if not itemInformation then
		return "NOT CACHED (a live roll waits for it)"
	end
	if ns:IsNeverAutomatedItem(itemInformation) then
		return "NEVER AUTOMATED"
	end
	local override = profile.customRollList and profile.ignoredItemsSolo[itemIdentifier]
	if override then
		return "ITEM OVERRIDES: " .. string.upper(tostring(override))
	end
	if ns:IsQuestClassItem(itemInformation) then
		return "QUEST ITEM"
	end
	local verdict, group, row =
		ns.CharacterRuleVerdict(itemInformation, itemLink, ns.db.char.characterRules, select(2, UnitClass("player")))
	local where = type(group) == "table" and ns.CharacterRuleGearKey(group, row) or tostring(group)
	local rules = ns.db.char.characterRules
	local bindOk = itemInformation.bindType ~= ns.BIND_ON_PICKUP or ns.db.profile.rollBindOnPickup
	if
		verdict
		and bindOk
		and rollAction ~= ns.MANUAL
		and ns.IsLowLevelGear(rules, itemInformation.requiredLevel, UnitLevel("player"))
		and itemInformation.quality <= ns.CharacterRuleUnwanted(rules, "threshold")
	then
		return "CHARACTER RULES: LOW-LEVEL GEAR (REQUIRED LEVEL "
			.. tostring(itemInformation.requiredLevel)
			.. ", "
			.. where
			.. "), ROLLS GREED"
	end
	if verdict == ns.CHARACTER_RULE_WANTED then
		return "CHARACTER RULES: WANTED (" .. where .. "), ROLL WINDOW"
	end
	if verdict == ns.CHARACTER_RULE_UNWANTED and rollAction ~= ns.MANUAL then
		if ns.CharacterRuleUnwanted(rules, "action") == ns.MANUAL then
			return "CHARACTER RULES: NOT WANTED (" .. where .. "), EVERYTHING ELSE IS MANUAL, ROLL WINDOW"
		end
		if bindOk and itemInformation.quality <= ns.CharacterRuleUnwanted(rules, "threshold") then
			return "CHARACTER RULES: NOT WANTED ("
				.. where
				.. "), ROLLS "
				.. string.upper(tostring(ns.CharacterRuleUnwanted(rules, "action")))
		end
	end
	if itemInformation.bindType == ns.BIND_ON_PICKUP and not ns.db.profile.rollBindOnPickup then
		return "BIND ON PICKUP"
	end
	if rollAction == ns.MANUAL then
		return "SETTING IS MANUAL"
	end
	if itemInformation.quality > rollThreshold then
		return "ABOVE THRESHOLD"
	end
	return "ROLLS " .. string.upper(tostring(rollAction))
end

--[[
    One row per distinct item in the bags, with the verdict above, so "it
    didn't roll on this" can be checked against an item already won by hand.
    Read-only; nothing here rolls.
]]
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
				RollVerdict(profile, link, itemIdentifier, rollAction, rollThreshold),
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

-- What this character's rules say about one piece: WANTED or NOT WANTED, with the box it fell under, or NOT JUDGED.
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
    Every armor and weapon piece in the bags and on the character, with the
    stats Character Rules reads on it and where each came from, and what this
    character's rules say about it: WANTED or NOT WANTED, with the box it fell
    under (TYPELESS for a cloak, ring, neck or trinket). The same read the roll makes, so a piece that rolled
    when it shouldn't have can be checked without waiting for another drop.
    Read-only; nothing here rolls.
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

-- One side of a Filters row: off, on, or on from a quality.
local function FilterCell(shown, qualities, row)
	if not shown[row.key] then
		return "off"
	end
	if row.rarity then
		return "on from quality " .. tostring(qualities[row.key] or 0)
	end
	return "on"
end

--[[
    The General tab's message groups, as Standard Loot Messages reads them
    (Features/Standard-Loot-Messages.lua): it acts only once the client has
    initialized the frame, and only when the wanted state changes.
]]
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

--[[
    Everything that decides whether loot gets a toast and how it looks: the
    switch, the handle, the look, each Filters row for the player's loot and the
    group's (ns.IsLootToastWanted in Features/Loot-Toasts-Filters.lua), and the
    chat tab lines the toasts stand in for. Where the stack sits is in Display
    Context.
]]
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
		"Tooltips %s; Bag Count %s; Winning Roll: Mine %s, Group %s",
		OnOff(profile.lootToastTooltips),
		OnOff(profile.lootToastBagCount),
		OnOff(profile.lootToastWinningRollMine),
		OnOff(profile.lootToastWinningRollGroup)
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

-- One loot line built from the client's own format, or nil and the error when the format won't take the arguments.
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
    Each loot format, the arguments it takes in its English order (a
    translation that reorders them numbers its placeholders, and the client's
    format honors that), and what the parser should hand back.
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
    Whether a roll reader would take a loot line for its own: the toast
    handler hands a line to the roll records first and drops one they claim
    (ns.RecordRollLine), and Hide Roll Messages keeps roll chatter out of
    chat. Read through the parsers alone, never RecordRollLine, which stores
    what it reads. Nil when nothing claims it.
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

local EXAMPLE_ROLL = 77

--[[
    One roll line built from the client's own format. The arguments are filled
    by kind rather than by position, since the parsers read each capture by what
    it holds: a number is the roll (or, first in a line that opens on the
    "[Loot]" history link, that link's own id), the last text argument is the
    item and any other is the player.
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

-- One roll line's result: SKIP for a format this client doesn't have, ERROR for one that won't build.
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

--[[
    The roll lines, read back the way Winning Roll on a toast, Hide Roll
    Messages and the winner summary read them (Features/Utilities-Chat-Lines.lua).
]]
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
    Loot Toasts, Loot Sounds, Automated Opening's rescan and its notices all
    start from a CHAT_MSG_LOOT or CHAT_MSG_MONEY line read back through the
    client's own formats (Features/Utilities-Chat-Lines.lua). This builds each
    line the client would print, with a real link from the bags so the link's
    own shape is the client's, and runs it through the same parsers, then the
    roll lines the same way. A FAIL names a format this client's line no longer
    matches. Then what the toast filters make of that item. Builds strings only:
    nothing is printed to chat or shown on screen.
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
	--[[
	    What the Filters rows read on it (ns.IsLootToastWanted): its item class
	    and subclass, which pick its row, its bind type for the Bind on Pickup
	    and Quest rows, and whether its tooltip starts a quest.
	]]
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

--[[
    Everything GogoLoot sends goes through ns:Announce (Features/Announcements.lua),
    which sends nothing at all while Enable Loot Announcements is off, and to the
    group channel ns:GetGroupChatChannel resolves, nil when not grouped. Each
    sender then has its own switch.
]]
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
    Roll-Macro.lua keeps ns.ROLL_MACRO_NAME among the General macros while
    Enable Roll Macro is on: it makes it at each load when it's missing, puts
    its icon and text back when either differs, and can't make it while the
    General tab is full. Every change waits out combat. How full the tab is
    comes from GetNumMacros, which GogoLoot itself never calls, so it is read
    through _G; its size, MAX_ACCOUNT_MACROS, comes from the game's Macros
    window, so it reads nil until that window has loaded. The macro's
    middle-click rolls up to the group's size, which GetNumGroupMembers reads
    as 0 alone.
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
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Player & Spells
--------------------------------------------------------------------------------

--[[
    The spells the add-on gates on or listens for, as ns.SPELLS keys, in report
    order. Most "nothing happens" reports from a Rogue come down to a spell this
    client doesn't answer for, or a rank it can't read.
]]
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
    Every record GogoLoot shows or matches by the name this client gives it,
    for the Localization tab's Game Names report. Each row reads the name
    exactly as the features do. The client strings are Blizzard UI labels and
    formats, so each one's id is its own constant name: the loot, money and roll
    lines are the formats GogoLoot reads chat back with, and a NIL there is a
    line that goes unread on this client. Character Rules adds its captions
    and the full ITEM_MOD formats it matches tooltip lines with, below. A row
    whose name loads late (a spell) adds request, which the report calls and
    polls.
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
    The Character Rules panel's captions, for the stats and sections this
    client offers (ns.CHARACTER_RULE_STATS and ns.CHARACTER_RULE_GROUPS, already
    cut to Data/{Folder}/Character-Rule-Stats-{Folder}.lua at load): each
    stat's label as the panel shows it, and each section's game label, which
    WoW Forever and later have and the panel replaces with its own words where
    it reads NIL.
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

--[[
    The item types the Loot Toasts Filters rows and the item lists' headers are
    captioned with, by class (or class and subclass) id, as the panels read
    them (Options/Options-Loot-Toast-Filters.lua).
]]
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

--[[
    The saved tables GogoLoot fills in itself, which the Saved Variables dump
    prints as a row count: what was handed out, the drops by boss of the last
    few raids, and what was picked up this instance. A raid's worth of drops
    runs to hundreds of item links, more than the output box shows.
]]
ns.DIAGNOSTIC_SAVED_SUMMARY_KEYS = {
	awarded = true,
	dropRaids = true,
	pickedUp = true,
}

--------------------------------------------------------------------------------
-- Validate Data Sources
--------------------------------------------------------------------------------

--[[
    One entry per file in the flavor folders, and one report row per entry on
    the Data tab. Each entry's label is the table-name part of its file name,
    so ns.DataSourceFileName can name the file this client's folder built, and
    one manifest serves every flavor. Each source names the static table on ns
    (a name, not a reference, so a table this client's folder never built still
    gets a row) and its kind: "item", "spell", or "other" for ids no client
    API looks up. Ids are reached through rowId(key, row) over the table's
    pairs, since the tables come in three shapes: rows of { itemId, ... }, maps
    keyed by item id, and maps whose values are the ids (spells and skill lines
    by name, sample items by quality). dataColumns
    carries the shipped row's own values as { header, getter(key, row) }, so
    the export sets what the file says beside what the client says. Adding a data file adds an entry here, and the panel
    and the validator pick it up with no second list.
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
			{ table = "CHARACTER_RULE_SAMPLE_ITEMS", kind = "item", rowId = ValueIsId },
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
