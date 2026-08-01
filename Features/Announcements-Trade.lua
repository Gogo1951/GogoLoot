--------------------------------------------------------------------------------
-- GogoLoot Trade Announcements Module
--------------------------------------------------------------------------------

--[[
    Snapshots both sides of a trade and posts a summary when it completes —
    whispered to the trade partner by default, or sent to group chat per
    the announceTradeOutput setting. Also owns the trade window checkbox
    that mirrors the Enable Trade Announcements toggle. All chat output
    routes through ns:Announce (Announcements.lua).
]]
local _, ns = ...
local L = ns.L
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--------------------------------------------------------------------------------
-- State Management
--------------------------------------------------------------------------------

--[[
    ResetTradeState wipes tradeState in place rather than reallocating, so
    references held by the handlers below stay valid across a reset.
]]

local tradeState = {
	player = nil,
	playerFullName = nil,
	ourItems = {},
	theirItems = {},
	ourEnchantDescription = nil,
	theirEnchantDescription = nil,
	ourMoney = 0,
	theirMoney = 0,
}

local function ResetTradeState()
	tradeState.player = nil
	tradeState.playerFullName = nil
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

-- Returns the stack count for a trade slot on our side, defaulting to 1.
local function GetOurTradeSlotCount(slotIndex)
	if type(GetTradePlayerItemInfo) ~= "function" then
		return 1
	end
	local _, _, quantity = GetTradePlayerItemInfo(slotIndex)
	return quantity or 1
end

-- Returns the stack count for a trade slot on their side, defaulting to 1.
local function GetTheirTradeSlotCount(slotIndex)
	if type(GetTradeTargetItemInfo) ~= "function" then
		return 1
	end
	local _, _, quantity = GetTradeTargetItemInfo(slotIndex)
	return quantity or 1
end

--[[
    The two trade-info functions do NOT return the enchant slot's service
    description in the same position:

      GetTradePlayerItemInfo -> name, texture, numItems, quality,
                                ENCHANTMENT (5), canLoseTransmog (6)
      GetTradeTargetItemInfo -> name, texture, quantity,  quality,
                                isUsable (5),   ENCHANT (6)

    Reading a fixed sixth return for both — which this did — worked for their
    side and silently failed for ours: position 6 on our side is
    canLoseTransmog, a boolean, so the string check rejected it and every
    service performed on OUR item vanished from the summary. That is the
    lockbox case (the box sits in our own enchant slot while the rogue applies
    Pick Lock) and equally every enchant somebody else put on our gear.

    Each caller therefore passes the position for the function it is reading.
    Never share one index between the two.
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
	local gold = math.floor(copperAmount / 10000)
	local silver = math.floor((copperAmount % 10000) / 100)
	local copper = copperAmount % 100
	local parts = {}
	if gold > 0 then
		table.insert(parts, gold .. "g")
	end
	if silver > 0 then
		table.insert(parts, silver .. "s")
	end
	if copper > 0 then
		table.insert(parts, copper .. "c")
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
			table.insert(finalStrings, link .. " x" .. count)
		else
			table.insert(finalStrings, link)
		end
	end

	return finalStrings
end

--[[
    Returns the summary as a list of parts (item links with counts, then the
    enchant, then money) rather than one string, so the announcement step can
    split across messages at part boundaries when the total is too long.
]]
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

	--[[
        Our enchant slot has an item: they are performing a service on our item
        — an enchant on our gear, or Pick Lock on a lockbox we handed over.
    ]]
	local ourEnchantSlotLink = GetTradePlayerItemLink(enchantSlot)
	if ourEnchantSlotLink then
		local enchantName = SafeGetTradeEnchantName(GetTradePlayerItemInfo, enchantSlot, TRADE_ENCHANT_RETURN_PLAYER)
		if enchantName then
			tradeState.theirEnchantDescription = enchantName
		end
	end

	-- Their enchant slot has an item: we are performing a service on their item
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
    Sends one or more announcements for a summary parts list, packing as many
    parts into each message as fit within ns.CHAT_MESSAGE_MAX_LENGTH. Splits
    only at part boundaries — an item link broken mid-escape is rejected by
    the client — and repeats the same format template so every message reads
    as a complete announcement. A single part that exceeds the limit on its
    own is sent anyway; it cannot be shortened without destroying the link.
]]
local function AnnounceSummaryParts(chatChannel, whisperTarget, formatKey, summaryParts, partnerDisplayName)
	local startIndex = 1
	while startIndex <= #summaryParts do
		local endIndex = startIndex
		while endIndex < #summaryParts do
			local candidateSummary = table.concat(summaryParts, ", ", startIndex, endIndex + 1)
			local candidateMessage = ns:BuildAnnounceMessage(formatKey, candidateSummary, partnerDisplayName)
			if not candidateMessage or #candidateMessage > ns.CHAT_MESSAGE_MAX_LENGTH then
				break
			end
			endIndex = endIndex + 1
		end
		ns:Announce(
			chatChannel,
			whisperTarget,
			formatKey,
			table.concat(summaryParts, ", ", startIndex, endIndex),
			partnerDisplayName
		)
		startIndex = endIndex + 1
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

	-- Condition gate: should we announce at all?
	if condition == "party_or_raid" then
		if not IsInGroup() then
			return
		end
	elseif condition == "raid_only" then
		if not UnitInRaid("player") then
			return
		end
	end

	-- Determine chat channel from output setting
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

	local ourParts = BuildTradeSummaryParts(tradeState.ourItems, tradeState.ourEnchantDescription, tradeState.ourMoney)
	local theirParts =
		BuildTradeSummaryParts(tradeState.theirItems, tradeState.theirEnchantDescription, tradeState.theirMoney)

	if #ourParts == 0 and #theirParts == 0 then
		return
	end

	--[[
        Pick the locale-aware template based on which side(s) of the trade had
        contents, then route through the central Announce helper which applies
        the target marker and add-on name for the channel and sends. A
        two-sided summary that fits the chat limit goes out as a single
        message; one that does not is decomposed into the one-sided GAVE and
        RECEIVED templates, each split at part boundaries by
        AnnounceSummaryParts.
    ]]
	if #ourParts > 0 and #theirParts > 0 then
		local ourSummary = table.concat(ourParts, ", ")
		local theirSummary = table.concat(theirParts, ", ")
		local combinedMessage =
			ns:BuildAnnounceMessage("MESSAGE_TRADE_GAVE_RECEIVED", ourSummary, theirName, theirSummary)
		if combinedMessage and #combinedMessage <= ns.CHAT_MESSAGE_MAX_LENGTH then
			ns:Announce(chatChannel, whisperTarget, "MESSAGE_TRADE_GAVE_RECEIVED", ourSummary, theirName, theirSummary)
		else
			AnnounceSummaryParts(chatChannel, whisperTarget, "MESSAGE_GAVE", ourParts, theirName)
			AnnounceSummaryParts(chatChannel, whisperTarget, "MESSAGE_TRADE_RECEIVED", theirParts, theirName)
		end
	elseif #ourParts > 0 then
		AnnounceSummaryParts(chatChannel, whisperTarget, "MESSAGE_GAVE", ourParts, theirName)
	else
		AnnounceSummaryParts(chatChannel, whisperTarget, "MESSAGE_TRADE_RECEIVED", theirParts, theirName)
	end
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------

local function HandleTradeShow()
	ResetTradeState()
	tradeState.player = ns:FormatPlayerName(ns:GetCleanUnitName("npc"))

	--[[
        Keep the realm suffix for the whisper target: a cross-realm partner
        (possible in battlegrounds) is only routable as "Name-Realm", while the
        stripped tradeState.player is what the message templates display.
    ]]
	local partnerName, partnerRealm = UnitName("npc")
	if partnerRealm and partnerRealm ~= "" then
		tradeState.playerFullName = partnerName .. "-" .. partnerRealm
	else
		tradeState.playerFullName = partnerName
	end
end

local function HandleTradeAcceptUpdate(playerAccepted, targetAccepted)
	if playerAccepted == 1 or targetAccepted == 1 then
		SnapshotTradeItems()
	end
end

local function HandleTradeRequestCancel()
	ResetTradeState()
end

--[[
    UI_INFO_MESSAGE's first argument is a numeric message id, so the trade result
    is read from that rather than compared against the client's translated text.
    Matching on the id is what keeps this working where an ERR_* global is not
    bound as a string, the same reason the master-loot error correlation resolves
    ids (Master-Looter-Distribution.lua).
]]
local TRADE_RESULT_BY_CONSTANT = {
	ERR_TRADE_COMPLETE = "complete",
	ERR_TRADE_CANCELLED = "cancelled",
}

--[[
    Diagnostics reads this to report which of these constants resolved to an id
    on this client, the same way Master-Looter-Distribution.lua exports its error
    constants. The ids are per-flavor, so a table that resolves on Era can come
    back empty on Anniversary and take the whole watcher down with it — an
    existence check on the ERR_* globals below would not show that.
]]
ns.TRADE_RESULT_CONSTANTS = TRADE_RESULT_BY_CONSTANT

--[[
    Resolved on first use, not at load: the walk costs a full table scan and
    nothing needs it until a trade actually ends. Runtime only, never persisted,
    so a client patch that renumbers the ids cannot be read back from stale data.
]]
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

local function HandleUserInterfaceInfoMessage(messageId, informationMessage)
	local tradeResult = GetTradeResult(messageId, informationMessage)
	if tradeResult == "cancelled" then
		ResetTradeState()
	elseif tradeResult == "complete" then
		AnnounceTradeComplete()
		ResetTradeState()
	end
end

local function HandleTradePlayerItemChanged(slotIndex)
	if slotIndex and slotIndex >= 1 and slotIndex <= ns.TRADE_ITEM_SLOT_COUNT then
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
end

local function HandleTradeTargetItemChanged(slotIndex)
	if slotIndex and slotIndex >= 1 and slotIndex <= ns.TRADE_ITEM_SLOT_COUNT then
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
end

ns:RegisterModuleEvent("TRADE_SHOW", HandleTradeShow)
ns:RegisterModuleEvent("TRADE_ACCEPT_UPDATE", HandleTradeAcceptUpdate)
ns:RegisterModuleEvent("TRADE_REQUEST_CANCEL", HandleTradeRequestCancel)
ns:RegisterModuleEvent("TRADE_PLAYER_ITEM_CHANGED", HandleTradePlayerItemChanged)
ns:RegisterModuleEvent("TRADE_TARGET_ITEM_CHANGED", HandleTradeTargetItemChanged)
ns:RegisterModuleEvent("UI_INFO_MESSAGE", HandleUserInterfaceInfoMessage)

--------------------------------------------------------------------------------
-- Trade Window Checkbox
--------------------------------------------------------------------------------

-- Mirrors the "Enable Trade Announcements" toggle directly on the trade frame.

local tradeAnnounceCheckbox = nil

local function CreateTradeAnnounceCheckbox()
	if tradeAnnounceCheckbox then
		return
	end
	if not TradeFrame then
		return
	end

	local checkbox = CreateFrame("CheckButton", "GogoLootTradeAnnounceCheckbox", TradeFrame, "UICheckButtonTemplate")
	checkbox:SetSize(26, 26)
	checkbox:SetPoint("BOTTOMLEFT", TradeFrame, "BOTTOMLEFT", 8, 4)

	local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
	label:SetText(L["TRADE_CHECKBOX_LABEL"])

	checkbox:SetScript("OnClick", function(self)
		ns.db.profile.announceTrade = self:GetChecked() and true or false
		AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.Announcements)
	end)

	checkbox:SetScript("OnEnter", function(self)
		local currentOutput = ns.TRADE_OUTPUT_LABELS[ns.db.profile.announceTradeOutput] or L["TRADE_OUTPUT_WHISPER"]

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		ns:AddTooltipLine(GameTooltip, L["ADDON_TITLE"], "TITLE")
		GameTooltip:AddLine(" ")
		ns:AddTooltipLine(GameTooltip, L["TRADE_HEADER"], "TITLE")
		ns:AddTooltipLine(GameTooltip, L["TRADE_TOOLTIP_DESCRIPTION"], "BODY", true)
		GameTooltip:AddLine(" ")
		ns:AddTooltipDoubleLine(GameTooltip, L["TRADE_TOOLTIP_OUTPUT"], currentOutput, "BODY", "TEXT")
		GameTooltip:Show()
	end)

	checkbox:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	tradeAnnounceCheckbox = checkbox
end

---@return nil
function ns:SyncTradeCheckbox()
	if tradeAnnounceCheckbox then
		tradeAnnounceCheckbox:SetChecked(ns.db.profile.announceTrade)
	end
end

ns:RegisterModuleEvent("TRADE_SHOW", function()
	CreateTradeAnnounceCheckbox()
	ns:SyncTradeCheckbox()
end)
