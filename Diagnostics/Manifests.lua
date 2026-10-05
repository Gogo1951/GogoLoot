local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

--[[
    Existence and shape checks only: read-only, no side effects, no protected
    calls. Kept aligned with the API guards in Features/Utilities.lua,
    Features/Core.lua, Features/Speedy-Loot.lua, Features/Master-Looter.lua,
    Features/Automated-Rolls.lua, and Features/Announcements-Trade.lua. Modern
    and legacy fallbacks are listed separately so the report shows exactly what
    each client provides. The two trade-result globals are the only strings
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

	-- Add-on metadata — Core.lua version lookup, Flavor.lua, and the Other Add-ons report
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

	-- Validate Data: Diagnostics/Validate-Data.lua, and the tooltip accessor in Utilities.lua
	{
		"C_Item.DoesItemExistByID",
		function()
			return type(C_Item) == "table" and type(C_Item.DoesItemExistByID) == "function"
		end,
	},
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

	-- Auto-loot CVar — Auto-Loot.lua / Utilities.lua; GetCVar is Diagnostics' own, for its CVar, Display and Taint reads
	{
		"C_CVar.GetCVarBool",
		function()
			return type(C_CVar) == "table" and type(C_CVar.GetCVarBool) == "function"
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
		"SendChatMessage",
		function()
			return type(SendChatMessage) == "function"
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

	-- The client's own formats, read back out of loot and money messages — Utilities.lua
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
        The roll lines, read back for the winning roll on a toast and kept out
        of chat by Hide Roll Messages — Utilities.lua. The core forms every
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
	-- Hide Roll Messages — Automated-Rolls.lua
	{ "ChatFrameUtil.AddMessageEventFilter", MemberIsFunction("ChatFrameUtil", "AddMessageEventFilter") },

	-- Loot Toasts — Loot-Toasts.lua
	{ "ITEM_STARTS_QUEST (string)", GlobalIsType("ITEM_STARTS_QUEST", "string") },
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

	-- Lockbox Tooltips — Lockbox-Tooltips.lua
	{ "ITEM_MIN_SKILL (string)", GlobalIsType("ITEM_MIN_SKILL", "string") },
	{ "C_Spell.GetSpellName", MemberIsFunction("C_Spell", "GetSpellName") },
	{ "C_TradeSkillUI.GetTradeSkillDisplayName", MemberIsFunction("C_TradeSkillUI", "GetTradeSkillDisplayName") },
	-- WoW Forever has no skill-line API, so a FAIL on the next two is expected there.
	{ "GetNumSkillLines", GlobalIsType("GetNumSkillLines", "function") },
	{ "GetSkillLineInfo", GlobalIsType("GetSkillLineInfo", "function") },

	-- Validate Data's spell kind
	{ "C_Spell.GetSpellInfo", MemberIsFunction("C_Spell", "GetSpellInfo") },
	{ "C_Spell.DoesSpellExist", MemberIsFunction("C_Spell", "DoesSpellExist") },
	{ "IsPlayerSpell", GlobalIsType("IsPlayerSpell", "function") },
	{ "IsSpellKnown", GlobalIsType("IsSpellKnown", "function") },

	-- Opening the options panel — Options.lua
	{ "Settings.OpenToCategory", MemberIsFunction("Settings", "OpenToCategory") },
	-- Closing it ends the item lists' New sections — Options.lua
	{ "SettingsPanel (frame)", GlobalIsType("SettingsPanel", "table") },
	-- Nested panels: the vendored AceConfigDialog finds a child panel's parent by its category ID
	{ "Settings.GetCategory", MemberIsFunction("Settings", "GetCategory") },
}

--------------------------------------------------------------------------------
-- Add-on Context Probes
--------------------------------------------------------------------------------

--[[
    The add-on's own example reports, appended to the shared Event Log intro,
    with the privacy warning a log of loot and money chat lines needs.
]]
ns.DiagnosticsStrings.EVENT_LOG_EXAMPLES =
	"Best for 'nothing got looted' or 'it never opened' reports. Combat and UI message spam GogoLoot doesn't act on is counted, not listed. It records loot and money chat lines, so review it before sharing."

--------------------------------------------------------------------------------
-- Loot Method
--------------------------------------------------------------------------------

--[[
    Live read of the loot-method APIs the master-looter path depends on. An
    existence check can't prove the APIs return the shapes GogoLoot's guards
    expect, so this prints the actual return values, the Enum.LootMethod
    constants the modern API is mapped onto (Master-Looter.lua SafeGetLootMethod),
    and how GogoLoot ultimately interprets them via AreWeMasterLooter and
    WillAutoMasterLoot. All calls are read-only.
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
-- Relevant CVars
--------------------------------------------------------------------------------

--[[
    autoLootDefault is the CVar GogoLoot enforces (Features/Auto-Loot.lua), and
    a player or another add-on turning it back off is the likeliest cause of
    "it stopped opening things": Speedy Loot and Automated Opening both need
    it. Read twice, raw and as the boolean the add-on tests, because those can
    disagree. Read-only; the taintLog button is the only CVar write here.
]]
---@return string
function ns:BuildCVarReport()
	local lines = { GetClientHeader(), "" }
	lines[#lines + 1] = string.format(
		"autoLootDefault = %s (as GogoLoot reads it: %s)",
		tostring(GetCVar("autoLootDefault")),
		tostring(ns:IsAutoLootCVarEnabled())
	)
	lines[#lines + 1] = string.format("taintLog = %s", tostring(GetCVar("taintLog")))
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

local IsPlayerSpellFunction = IsPlayerSpell

---@return string
function ns:BuildPlayerReport()
	local lines = { GetClientHeader(), "" }
	local className, classFile = UnitClass("player")
	lines[#lines + 1] = string.format(
		"Class: %s (%s) // Level: %s",
		tostring(className),
		tostring(classFile),
		tostring(UnitLevel("player"))
	)
	lines[#lines + 1] = ""
	for _, key in ipairs(ns.DIAGNOSTIC_SPELLS) do
		local spellIdentifier = ns.SPELLS[key]
		lines[#lines + 1] = string.format(
			"%s %s: name=%s IsPlayerSpell=%s",
			key,
			tostring(spellIdentifier),
			tostring(spellIdentifier and C_Spell.GetSpellName(spellIdentifier)),
			IsPlayerSpellFunction and tostring(IsPlayerSpellFunction(spellIdentifier)) or "n/a"
		)
	end
	lines[#lines + 1] = string.format(
		"LOCKPICKING skill line %s: name=%s",
		tostring(ns.SKILL_LINE_IDS.LOCKPICKING),
		tostring(C_TradeSkillUI.GetTradeSkillDisplayName(ns.SKILL_LINE_IDS.LOCKPICKING))
	)
	lines[#lines + 1] = ""
	local rank = ns.GetPlayerLockpickingSkill()
	lines[#lines + 1] = "Lockpicking rank as GogoLoot reads it: "
		.. (rank and tostring(rank) or "unavailable on this client (or not trained)")
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Locked Boxes
--------------------------------------------------------------------------------

-- An item link as copyable text: pipes escaped so it pastes rather than renders.
local function LinkCell(link)
	return link and (tostring(link):gsub("|", "||")) or ""
end

--[[
    Every openable item in the bags with the verdict Automated Opening acts on:
    its data default, reason included (UNLOCKED, IGNORE_RAID and the like), its
    action (nil for one the player removed), and whether the scan tooltip reads
    it as locked. The tooltip's line count is what separates a truly unlocked
    box from a scan tooltip that read nothing at all, since both answer "not
    locked". Read-only; nothing here opens anything.
]]
---@return string
function ns:BuildLockedBoxesReport()
	local lines = {
		GetClientHeader(),
		"",
		"BAG\tSLOT\tITEM_ID\tLINK\tDEFAULT\tACTION\tLOCKED\tTOOLTIP_LINES",
	}
	local found = 0
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagIndex) or 0 do
			local itemIdentifier = ns.GetBagItemIdentifier(bagIndex, slotIndex)
			local default = ns:GetOpeningDefault(itemIdentifier)
			if default or ns:GetOpeningAction(itemIdentifier) then
				found = found + 1
				local locked, lineCount = ns.IsItemLocked(bagIndex, slotIndex)
				lines[#lines + 1] = table.concat({
					bagIndex,
					slotIndex,
					itemIdentifier,
					LinkCell(C_Container.GetContainerItemLink(bagIndex, slotIndex)),
					tostring(default),
					tostring(ns:GetOpeningAction(itemIdentifier)),
					tostring(locked),
					tostring(lineCount),
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
    saw it: ITEM (GetItemStats), EQUIP_TABLE and SUFFIX_TABLE (the generated
    Item-Stats tables) and TOOLTIP ("+15 Intellect" lines).
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

---@param found table
---@param rules table|nil
---@return string
local function RuleCell(found, rules)
	local manual = {}
	for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
		if found[stat.key] and rules and rules[stat.key] == ns.MANUAL then
			manual[#manual + 1] = stat.key
		end
	end
	if #manual > 0 then
		return "MANUAL (" .. table.concat(manual, ", ") .. ")"
	end
	return "STANDARD"
end

--[[
    Every armor and weapon piece in the bags and on the character, with the
    stats Character Rules reads on it and where each came from, and what this
    character's rules do with it: MANUAL, naming the stats that leave it to the
    player, or STANDARD. The same read the roll makes, so a piece that rolled
    when it shouldn't have can be checked without waiting for another drop.
    Read-only; nothing here rolls.
]]
---@return string
function ns:BuildGearStatsReport()
	local rules = ns.db.char.characterRules
	local manualStats = {}
	for _, stat in ipairs(ns.CHARACTER_RULE_STATS) do
		if rules and rules[stat.key] == ns.MANUAL then
			manualStats[#manualStats + 1] = stat.key
		end
	end
	local lines = {
		GetClientHeader(),
		"",
		"Manual on " .. tostring(ns.db.keys and ns.db.keys.char) .. ": " .. (#manualStats > 0 and table.concat(
			manualStats,
			", "
		) or "nothing (every stat on Standard Automated Roll)"),
		"",
		"WHERE\tITEM_ID\tSUFFIX_ID\tLINK\tSTATS\tRULE",
	}

	local function AddRow(where, itemLink)
		if not IsGear(itemLink) then
			return
		end
		local itemIdentifier = tonumber(itemLink:match("item:(%d+)"))
		local found = ns.ReadCharacterRuleStats(itemLink, itemIdentifier)
		lines[#lines + 1] = table.concat({
			where,
			tostring(itemIdentifier),
			tostring(ns.GetLinkRandomSuffix(itemLink) or ""),
			LinkCell(itemLink),
			StatsCell(found),
			RuleCell(found, rules),
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
    keyed by item id, and maps keyed by name (spells, skill lines). dataColumns
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
				table = "SOUND_KIT_IDS",
				kind = "other",
				rowId = ValueIsId,
				dataColumns = { { "DATA_KEY", KeyValue } },
			},
		},
	},
	{
		label = "Item-Stats",
		sources = {
			{
				table = "ITEM_STAT_FLAGS",
				kind = "item",
				rowId = KeyIsId,
				dataColumns = { { "DATA_STAT_FLAGS", RowValue } },
			},
			{
				table = "RANDOM_SUFFIX_STAT_FLAGS",
				kind = "other",
				rowId = KeyIsId,
				dataColumns = { { "DATA_STAT_FLAGS", RowValue } },
			},
		},
	},
	{
		label = "Spells",
		sources = {
			{ table = "SPELLS", kind = "spell", rowId = ValueIsId, dataColumns = { { "DATA_KEY", KeyValue } } },
		},
	},
}
