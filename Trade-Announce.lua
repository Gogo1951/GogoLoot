--------------------------------------------------------------------------------
-- GogoLoot Trade Module
--------------------------------------------------------------------------------
local L = GogoLoot.L

GogoLoot.tradeState = {
    player = nil,
    ourItems = {},
    theirItems = {},
    ourEnchantDescription = nil,
    theirEnchantDescription = nil,
    ourMoney = 0,
    theirMoney = 0,
    accepted = false
}

--------------------------------------------------------------------------------
-- State Management
--------------------------------------------------------------------------------

local function ResetTradeState()
    GogoLoot.tradeState = {
        player = nil,
        ourItems = {},
        theirItems = {},
        ourEnchantDescription = nil,
        theirEnchantDescription = nil,
        ourMoney = 0,
        theirMoney = 0,
        accepted = false
    }
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

    for slotIndex = 1, GogoLoot.TRADE_ITEM_SLOT_COUNT do
        local link = itemTable[slotIndex]
        if link then
            if not itemCounts[link] then
                itemCounts[link] = 0
                table.insert(itemOrder, link)
            end
            itemCounts[link] = itemCounts[link] + 1
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

local function BuildTradeSummary(itemTable, enchantDescription, moneyAmount)
    local parts = {}

    local itemStrings = BuildItemListStrings(itemTable)
    for _, itemString in ipairs(itemStrings) do
        table.insert(parts, itemString)
    end

    if enchantDescription and enchantDescription ~= "" then
        table.insert(parts, enchantDescription)
    end

    local moneyString = FormatMoneyString(moneyAmount)
    if moneyString then
        table.insert(parts, moneyString)
    end

    if #parts == 0 then
        return nil
    end
    return table.concat(parts, ", ")
end

--------------------------------------------------------------------------------
-- Announcement
--------------------------------------------------------------------------------

local function AnnounceTradeComplete()
    if not GogoLootDB.announceTrade then
        return
    end
    if not GogoLoot.tradeState.player then
        return
    end

    local condition = GogoLootDB.announceTradeCondition
    local output = GogoLootDB.announceTradeOutput

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
        whisperTarget = GogoLoot.tradeState.player
    elseif output == "raid" then
        if UnitInRaid("player") then
            chatChannel = "RAID"
        elseif IsInGroup() then
            chatChannel = "PARTY"
        else
            chatChannel = "WHISPER"
            whisperTarget = GogoLoot.tradeState.player
        end
    else
        chatChannel = GogoLoot:GetGroupChatChannel()
        if chatChannel == "SAY" then
            chatChannel = "WHISPER"
            whisperTarget = GogoLoot.tradeState.player
        end
    end

    if not chatChannel then
        return
    end

    local theirName = GogoLoot.tradeState.player

    local ourSummary =
        BuildTradeSummary(
        GogoLoot.tradeState.ourItems,
        GogoLoot.tradeState.ourEnchantDescription,
        GogoLoot.tradeState.ourMoney
    )
    local theirSummary =
        BuildTradeSummary(
        GogoLoot.tradeState.theirItems,
        GogoLoot.tradeState.theirEnchantDescription,
        GogoLoot.tradeState.theirMoney
    )

    if not ourSummary and not theirSummary then
        return
    end

    local body
    if ourSummary and theirSummary then
        body = "Gave " .. ourSummary .. " to " .. theirName .. ", received " .. theirSummary .. "."
    elseif ourSummary then
        body = "Gave " .. ourSummary .. " to " .. theirName .. "."
    else
        body = "Received " .. theirSummary .. " from " .. theirName .. "."
    end

    local message = GogoLoot.MESSAGE_PREFIX .. body .. GogoLoot.MESSAGE_SUFFIX
    SendChatMessage(message, chatChannel, nil, whisperTarget)
end

--------------------------------------------------------------------------------
-- Snapshot
--------------------------------------------------------------------------------

local function SafeGetTradeEnchantName(getInfoFunction, slotIndex)
    if type(getInfoFunction) ~= "function" then
        return nil
    end
    local success, _, _, _, _, _, enchantName = pcall(getInfoFunction, slotIndex)
    if success and type(enchantName) == "string" and enchantName ~= "" then
        return enchantName
    end
    return nil
end

local function SnapshotTradeItems()
    for slotIndex = 1, GogoLoot.TRADE_ITEM_SLOT_COUNT do
        local itemLink = GetTradePlayerItemLink(slotIndex)
        if itemLink then
            GogoLoot.tradeState.ourItems[slotIndex] = itemLink
        end
    end
    for slotIndex = 1, GogoLoot.TRADE_ITEM_SLOT_COUNT do
        local itemLink = GetTradeTargetItemLink(slotIndex)
        if itemLink then
            GogoLoot.tradeState.theirItems[slotIndex] = itemLink
        end
    end

    local enchantSlot = GogoLoot.TRADE_ENCHANT_SLOT

    -- Our enchant slot has an item: they are performing a service on our item
    local ourEnchantSlotLink = GetTradePlayerItemLink(enchantSlot)
    if ourEnchantSlotLink then
        local enchantName = SafeGetTradeEnchantName(GetTradePlayerItemInfo, enchantSlot)
        if enchantName then
            GogoLoot.tradeState.theirEnchantDescription = enchantName
        end
    end

    -- Their enchant slot has an item: we are performing a service on their item
    local theirEnchantSlotLink = GetTradeTargetItemLink(enchantSlot)
    if theirEnchantSlotLink then
        local enchantName = SafeGetTradeEnchantName(GetTradeTargetItemInfo, enchantSlot)
        if enchantName then
            GogoLoot.tradeState.ourEnchantDescription = enchantName
        end
    end

    if type(GetPlayerTradeMoney) == "function" then
        GogoLoot.tradeState.ourMoney = GetPlayerTradeMoney() or 0
    end
    if type(GetTargetTradeMoney) == "function" then
        GogoLoot.tradeState.theirMoney = GetTargetTradeMoney() or 0
    end
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------

local function HandleTradeShow(eventName)
    ResetTradeState()
    GogoLoot.tradeState.player = GogoLoot:GetCleanUnitName("npc") or UnitName("npc")
end

local function HandleTradeAcceptUpdate(eventName, playerAccepted, targetAccepted)
    if playerAccepted == 1 or targetAccepted == 1 then
        SnapshotTradeItems()
        GogoLoot.tradeState.accepted = true
    end
end

local function HandleTradeRequestCancel(eventName)
    ResetTradeState()
end

local function HandleUserInterfaceInfoMessage(eventName, errorType, informationMessage)
    if informationMessage == ERR_TRADE_CANCELLED then
        HandleTradeRequestCancel(eventName)
    elseif informationMessage == ERR_TRADE_COMPLETE then
        AnnounceTradeComplete()
        ResetTradeState()
    end
end

local function HandleTradePlayerItemChanged(eventName, slotIndex)
    if slotIndex and slotIndex >= 1 and slotIndex <= GogoLoot.TRADE_ITEM_SLOT_COUNT then
        GogoLoot.tradeState.ourItems[slotIndex] = GetTradePlayerItemLink(slotIndex)
    end
end

local function HandleTradeTargetItemChanged(eventName, slotIndex)
    if slotIndex and slotIndex >= 1 and slotIndex <= GogoLoot.TRADE_ITEM_SLOT_COUNT then
        GogoLoot.tradeState.theirItems[slotIndex] = GetTradeTargetItemLink(slotIndex)
    end
end

GogoLoot:RegisterModuleEvent("TRADE_SHOW", HandleTradeShow)
GogoLoot:RegisterModuleEvent("TRADE_ACCEPT_UPDATE", HandleTradeAcceptUpdate)
GogoLoot:RegisterModuleEvent("TRADE_REQUEST_CANCEL", HandleTradeRequestCancel)
GogoLoot:RegisterModuleEvent("TRADE_PLAYER_ITEM_CHANGED", HandleTradePlayerItemChanged)
GogoLoot:RegisterModuleEvent("TRADE_TARGET_ITEM_CHANGED", HandleTradeTargetItemChanged)
GogoLoot:RegisterModuleEvent("UI_INFO_MESSAGE", HandleUserInterfaceInfoMessage)

--------------------------------------------------------------------------------
-- Trade Window Checkbox
-- Mirrors the "Enable Trade Announcements" toggle directly on the trade frame.
--------------------------------------------------------------------------------

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

    checkbox:SetScript(
        "OnClick",
        function(self)
            GogoLootDB.announceTrade = self:GetChecked() and true or false
        end
    )

    checkbox:SetScript(
        "OnEnter",
        function(self)
            local outputLabels = {
                ["whisper"] = L["TRADE_OUTPUT_WHISPER"],
                ["group"] = L["TRADE_OUTPUT_GROUP"],
                ["raid"] = L["TRADE_OUTPUT_RAID"]
            }
            local currentOutput = outputLabels[GogoLootDB.announceTradeOutput] or L["TRADE_OUTPUT_WHISPER"]

            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(GogoLoot.COLORS.INFO .. "GogoLoot|r", 1, 1, 1)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L["TRADE_TOOLTIP_TITLE"], 1, 0.82, 0)
            GameTooltip:AddLine(L["TRADE_TOOLTIP_DESC"], 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(L["TRADE_TOOLTIP_OUTPUT"], currentOutput, 0.8, 0.8, 0.8, 1, 1, 1)
            GameTooltip:Show()
        end
    )

    checkbox:SetScript(
        "OnLeave",
        function()
            GameTooltip:Hide()
        end
    )

    tradeAnnounceCheckbox = checkbox
end

function GogoLoot:SyncTradeCheckbox()
    if tradeAnnounceCheckbox then
        tradeAnnounceCheckbox:SetChecked(GogoLootDB.announceTrade)
    end
end

GogoLoot:RegisterModuleEvent(
    "TRADE_SHOW",
    function()
        CreateTradeAnnounceCheckbox()
        GogoLoot:SyncTradeCheckbox()
    end
)