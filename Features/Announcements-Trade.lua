--------------------------------------------------------------------------------
-- GogoLoot Trade Announcements Module
--------------------------------------------------------------------------------

local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- State Management
--------------------------------------------------------------------------------

local tradeState = {
	player = nil,
	playerFullName = nil,
	playerClass = nil,
	ourItems = {},
	theirItems = {},
	ourEnchantDescription = nil,
	theirEnchantDescription = nil,
	ourMoney = 0,
	theirMoney = 0,
}

-- Wiped in place, so references to its tables stay valid across a reset.
local function ResetTradeState()
	tradeState.player = nil
	tradeState.playerFullName = nil
	tradeState.playerClass = nil
	wipe(tradeState.ourItems)
	wipe(tradeState.theirItems)
	tradeState.ourEnchantDescription = nil
	tradeState.theirEnchantDescription = nil
	tradeState.ourMoney = 0
	tradeState.theirMoney = 0
end

--------------------------------------------------------------------------------
-- API Helpers
--------------------------------------------------------------------------------

local function GetOurTradeSlotCount(slotIndex)
	if type(GetTradePlayerItemInfo) ~= "function" then
		return 1
	end
	local _, _, quantity = GetTradePlayerItemInfo(slotIndex)
	return quantity or 1
end

local function GetTheirTradeSlotCount(slotIndex)
	if type(GetTradeTargetItemInfo) ~= "function" then
		return 1
	end
	local _, _, quantity = GetTradeTargetItemInfo(slotIndex)
	return quantity or 1
end

--[[
    The two trade-info functions do NOT return the enchant text in the same
    position:

      GetTradePlayerItemInfo -> name, texture, numItems, quality,
                                ENCHANTMENT (5), canLoseTransmog (6)
      GetTradeTargetItemInfo -> name, texture, quantity,  quality,
                                isUsable (5),   ENCHANT (6)

    Never share one index between the two: every service on OUR item (Pick
    Lock on our lockbox, an enchant on our gear) would vanish.
]]
local TRADE_ENCHANT_RETURN_PLAYER = 5
local TRADE_ENCHANT_RETURN_TARGET = 6

local function SafeGetTradeEnchantName(getInfoFunction, slotIndex, enchantReturnIndex)
	if type(getInfoFunction) ~= "function" then
		return nil
	end
	local returnValues = { pcall(getInfoFunction, slotIndex) }
	if not returnValues[1] then
		return nil
	end
	-- returnValues[1] is pcall's success flag, so the Nth return sits at N + 1.
	local enchantName = returnValues[enchantReturnIndex + 1]
	if type(enchantName) == "string" and enchantName ~= "" then
		return enchantName
	end
	return nil
end

--------------------------------------------------------------------------------
-- Formatting
--------------------------------------------------------------------------------

local function FormatMoneyString(copperAmount)
	if not copperAmount or copperAmount <= 0 then
		return nil
	end
	local gold = math.floor(copperAmount / ns.COPPER_PER_GOLD)
	local silver = math.floor((copperAmount % ns.COPPER_PER_GOLD) / ns.COPPER_PER_SILVER)
	local copper = copperAmount % ns.COPPER_PER_SILVER
	local parts = {}
	if gold > 0 then
		table.insert(parts, gold .. GOLD_AMOUNT_SYMBOL)
	end
	if silver > 0 then
		table.insert(parts, silver .. SILVER_AMOUNT_SYMBOL)
	end
	if copper > 0 then
		table.insert(parts, copper .. COPPER_AMOUNT_SYMBOL)
	end
	return table.concat(parts, " ")
end

local function BuildItemListStrings(itemTable)
	local itemCounts = {}
	local itemOrder = {}
	local finalStrings = {}

	for slotIndex = 1, ns.TRADE_ITEM_SLOT_COUNT do
		local entry = itemTable[slotIndex]
		if entry and entry.link then
			local link = entry.link
			local count = entry.count or 1
			if not itemCounts[link] then
				itemCounts[link] = 0
				table.insert(itemOrder, link)
			end
			itemCounts[link] = itemCounts[link] + count
		end
	end

	for _, link in ipairs(itemOrder) do
		local count = itemCounts[link]
		if count > 1 then
			table.insert(finalStrings, link .. " " .. L["ITEM_QUANTITY"]:format(count))
		else
			table.insert(finalStrings, link)
		end
	end

	return finalStrings
end

-- Parts, not one string, so a long summary can split at part boundaries.
local function BuildTradeSummaryParts(itemTable, enchantDescription, moneyAmount)
	local summaryParts = BuildItemListStrings(itemTable)

	if enchantDescription and enchantDescription ~= "" then
		table.insert(summaryParts, enchantDescription)
	end

	local moneyString = FormatMoneyString(moneyAmount)
	if moneyString then
		table.insert(summaryParts, moneyString)
	end

	return summaryParts
end

---@param itemTable table # { link, count } by trade slot
---@param enchantDescription string|nil
---@param moneyAmount number # copper
---@return string
function ns.FormatTradeSummary(itemTable, enchantDescription, moneyAmount)
	return table.concat(BuildTradeSummaryParts(itemTable, enchantDescription, moneyAmount), ", ")
end

--------------------------------------------------------------------------------
-- Snapshot
--------------------------------------------------------------------------------

local function SnapshotTradeItems()
	for slotIndex = 1, ns.TRADE_ITEM_SLOT_COUNT do
		local itemLink = GetTradePlayerItemLink(slotIndex)
		if itemLink then
			tradeState.ourItems[slotIndex] = {
				link = itemLink,
				count = GetOurTradeSlotCount(slotIndex),
			}
		else
			tradeState.ourItems[slotIndex] = nil
		end
	end
	for slotIndex = 1, ns.TRADE_ITEM_SLOT_COUNT do
		local itemLink = GetTradeTargetItemLink(slotIndex)
		if itemLink then
			tradeState.theirItems[slotIndex] = {
				link = itemLink,
				count = GetTheirTradeSlotCount(slotIndex),
			}
		else
			tradeState.theirItems[slotIndex] = nil
		end
	end

	local enchantSlot = ns.TRADE_ENCHANT_SLOT
	-- Each snapshot reads the enchant slots afresh: one emptied since the last accept carries no enchant.
	tradeState.theirEnchantDescription = nil
	tradeState.ourEnchantDescription = nil

	-- Crossed: an item in OUR enchant slot means THEY perform the service, and vice versa.
	local ourEnchantSlotLink = GetTradePlayerItemLink(enchantSlot)
	if ourEnchantSlotLink then
		local enchantName = SafeGetTradeEnchantName(GetTradePlayerItemInfo, enchantSlot, TRADE_ENCHANT_RETURN_PLAYER)
		if enchantName then
			tradeState.theirEnchantDescription = enchantName
		end
	end

	local theirEnchantSlotLink = GetTradeTargetItemLink(enchantSlot)
	if theirEnchantSlotLink then
		local enchantName = SafeGetTradeEnchantName(GetTradeTargetItemInfo, enchantSlot, TRADE_ENCHANT_RETURN_TARGET)
		if enchantName then
			tradeState.ourEnchantDescription = enchantName
		end
	end

	if type(GetPlayerTradeMoney) == "function" then
		tradeState.ourMoney = GetPlayerTradeMoney() or 0
	end
	if type(GetTargetTradeMoney) == "function" then
		tradeState.theirMoney = GetTargetTradeMoney() or 0
	end
end

--------------------------------------------------------------------------------
-- Announcement
--------------------------------------------------------------------------------

--[[
    Me Only: a print has no 255-byte ceiling, so each list goes out whole. It
    reads Enable Announcements itself, since it bypasses ns:Announce.
]]
local function PrintTradeSummary()
	if not ns.db.profile.lootNotifications then
		return
	end
	local ourParts = BuildTradeSummaryParts(tradeState.ourItems, tradeState.ourEnchantDescription, tradeState.ourMoney)
	local theirParts =
		BuildTradeSummaryParts(tradeState.theirItems, tradeState.theirEnchantDescription, tradeState.theirMoney)
	local ourSummary, theirSummary = table.concat(ourParts, ", "), table.concat(theirParts, ", ")
	-- Printed only, so the partner takes their class color; a sent summary keeps the plain name.
	local theirName = tradeState.player
	local classColor = ns.GetClassColor(tradeState.playerClass)
	if classColor then
		theirName = classColor .. theirName .. "|r"
	end

	if #ourParts > 0 and #theirParts > 0 then
		ns:PrintMessage(L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"]:format(ourSummary, theirName, theirSummary))
	elseif #ourParts > 0 then
		ns:PrintMessage(L["MESSAGE_GAVE_PRINT"]:format(ourSummary, theirName))
	elseif #theirParts > 0 then
		ns:PrintMessage(L["MESSAGE_TRADE_RECEIVED_PRINT"]:format(theirSummary, theirName))
	end
end

local function AnnounceTradeComplete()
	if not ns.db.profile.announceTrade then
		return
	end
	if not tradeState.player then
		return
	end

	local condition = ns.db.profile.announceTradeCondition
	local output = ns.db.profile.announceTradeOutput

	if condition == "party_or_raid" then
		if not IsInGroup() then
			return
		end
	elseif condition == "raid_only" then
		if not UnitInRaid("player") then
			return
		end
	end

	if output == "self" then
		PrintTradeSummary()
		return
	end

	local chatChannel, whisperTarget
	if output == "whisper" then
		chatChannel = "WHISPER"
		whisperTarget = tradeState.playerFullName
	else
		chatChannel = ns:GetGroupChatChannel()
		if not chatChannel then
			chatChannel = "WHISPER"
			whisperTarget = tradeState.playerFullName
		end
	end

	if not chatChannel then
		return
	end

	local theirName = tradeState.player

	local function SummaryThenPartner(summary)
		return summary, theirName
	end

	local ourParts = BuildTradeSummaryParts(tradeState.ourItems, tradeState.ourEnchantDescription, tradeState.ourMoney)
	local theirParts =
		BuildTradeSummaryParts(tradeState.theirItems, tradeState.theirEnchantDescription, tradeState.theirMoney)

	if #ourParts == 0 and #theirParts == 0 then
		return
	end

	-- A two-sided summary over the chat limit splits into the one-sided GAVE and RECEIVED templates.
	if #ourParts > 0 and #theirParts > 0 then
		local ourSummary = table.concat(ourParts, ", ")
		local theirSummary = table.concat(theirParts, ", ")
		local combinedMessage =
			ns:BuildAnnounceMessage("MESSAGE_TRADE_GAVE_RECEIVED", ourSummary, theirName, theirSummary)
		if combinedMessage and #combinedMessage <= ns.CHAT_MESSAGE_MAX_LENGTH then
			ns:Announce(chatChannel, whisperTarget, "MESSAGE_TRADE_GAVE_RECEIVED", ourSummary, theirName, theirSummary)
		else
			ns:AnnounceParts(chatChannel, whisperTarget, "MESSAGE_GAVE", ourParts, SummaryThenPartner)
			ns:AnnounceParts(chatChannel, whisperTarget, "MESSAGE_TRADE_RECEIVED", theirParts, SummaryThenPartner)
		end
	elseif #ourParts > 0 then
		ns:AnnounceParts(chatChannel, whisperTarget, "MESSAGE_GAVE", ourParts, SummaryThenPartner)
	else
		ns:AnnounceParts(chatChannel, whisperTarget, "MESSAGE_TRADE_RECEIVED", theirParts, SummaryThenPartner)
	end
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------

local function BeginTrade()
	ResetTradeState()
	tradeState.player = ns:FormatPlayerName(ns:GetCleanUnitName("npc"))
	tradeState.playerClass = select(2, UnitClass("npc"))

	--[[
        A cross-realm partner is only whisperable as "Name-Realm". On WoW
        Forever the second half is a last name, and the whisper goes to
        "First Last".
    ]]
	local partnerName, partnerRealm = UnitName("npc")
	if ns.FLAVOR == "Camelot" then
		tradeState.playerFullName = ns:GetCleanUnitName("npc")
	elseif partnerRealm and partnerRealm ~= "" then
		tradeState.playerFullName = partnerName .. "-" .. partnerRealm
	else
		tradeState.playerFullName = partnerName
	end
end

--[[
    Any change clears both acceptances, so the last accept reads the final
    window. The per-slot change events are deliberately not followed: WoW
    Forever empties our side just before "Trade complete.".
]]
local function OnTradeAcceptUpdate(playerAccepted, targetAccepted)
	if playerAccepted == 1 or targetAccepted == 1 then
		SnapshotTradeItems()
	end
end

local function OnTradeRequestCancel()
	ResetTradeState()
end

local TRADE_RESULT_BY_CONSTANT = {
	ERR_TRADE_COMPLETE = "complete",
	ERR_TRADE_CANCELLED = "cancelled",
}

-- For Diagnostics: ids are per flavor, and an existence check on the ERR_* globals wouldn't show a miss.
ns.TRADE_RESULT_CONSTANTS = TRADE_RESULT_BY_CONSTANT

-- Resolved on first use, never saved: a patch may renumber the ids.
local tradeResultById

local function GetTradeResult(messageId, informationMessage)
	if not tradeResultById then
		tradeResultById = {}
		for messageIdentifier, constantName in pairs(ns:ResolveGameMessageIds(TRADE_RESULT_BY_CONSTANT)) do
			tradeResultById[messageIdentifier] = TRADE_RESULT_BY_CONSTANT[constantName]
		end
	end

	local result = messageId and tradeResultById[messageId]
	if result then
		return result
	end

	-- Fallback for a client where neither constant resolved to an id.
	if informationMessage == ERR_TRADE_CANCELLED then
		return "cancelled"
	elseif informationMessage == ERR_TRADE_COMPLETE then
		return "complete"
	end
	return nil
end

local function OnUiInfoMessage(messageId, informationMessage)
	-- Every quest update and discovery lands here too; only an open trade has a result to read.
	if not tradeState.player then
		return
	end
	local tradeResult = GetTradeResult(messageId, informationMessage)
	if tradeResult == "cancelled" then
		ResetTradeState()
	elseif tradeResult == "complete" then
		AnnounceTradeComplete()
		if ns.OnLootMasterTradeCompleted then
			ns.OnLootMasterTradeCompleted(tradeState.player, tradeState.ourItems)
		end
		ResetTradeState()
	end
end

ns:RegisterModuleEvent("TRADE_ACCEPT_UPDATE", OnTradeAcceptUpdate)
ns:RegisterModuleEvent("TRADE_REQUEST_CANCEL", OnTradeRequestCancel)
ns:RegisterModuleEvent("UI_INFO_MESSAGE", OnUiInfoMessage)

local function OnTradeShow()
	BeginTrade()
end

ns:RegisterModuleEvent("TRADE_SHOW", OnTradeShow)
