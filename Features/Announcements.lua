--------------------------------------------------------------------------------
-- GogoLoot Trade Module
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- State Management
-- tradeState is module-private. ResetTradeState wipes in place rather than
-- reallocating, so any reference held inside this file stays valid across
-- a reset (no need to re-read through a namespace handle).
--------------------------------------------------------------------------------

local tradeState = {
    player = nil,
    ourItems = {},
    theirItems = {},
    ourEnchantDescription = nil,
    theirEnchantDescription = nil,
    ourMoney = 0,
    theirMoney = 0,
    accepted = false
}

local function ResetTradeState()
    tradeState.player = nil
    wipe(tradeState.ourItems)
    wipe(tradeState.theirItems)
    tradeState.ourEnchantDescription = nil
    tradeState.theirEnchantDescription = nil
    tradeState.ourMoney = 0
    tradeState.theirMoney = 0
    tradeState.accepted = false
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
-- Snapshot
--------------------------------------------------------------------------------

local function SnapshotTradeItems()
    for slotIndex = 1, GogoLoot.TRADE_ITEM_SLOT_COUNT do
        local itemLink = GetTradePlayerItemLink(slotIndex)
        if itemLink then
            tradeState.ourItems[slotIndex] = {
                link = itemLink,
                count = GetOurTradeSlotCount(slotIndex)
            }
        else
            tradeState.ourItems[slotIndex] = nil
        end
    end
    for slotIndex = 1, GogoLoot.TRADE_ITEM_SLOT_COUNT do
        local itemLink = GetTradeTargetItemLink(slotIndex)
        if itemLink then
            tradeState.theirItems[slotIndex] = {
                link = itemLink,
                count = GetTheirTradeSlotCount(slotIndex)
            }
        else
            tradeState.theirItems[slotIndex] = nil
        end
    end

    local enchantSlot = GogoLoot.TRADE_ENCHANT_SLOT

    -- Our enchant slot has an item: they are performing a service on our item
    local ourEnchantSlotLink = GetTradePlayerItemLink(enchantSlot)
    if ourEnchantSlotLink then
        local enchantName = SafeGetTradeEnchantName(GetTradePlayerItemInfo, enchantSlot)
        if enchantName then
            tradeState.theirEnchantDescription = enchantName
        end
    end

    -- Their enchant slot has an item: we are performing a service on their item
    local theirEnchantSlotLink = GetTradeTargetItemLink(enchantSlot)
    if theirEnchantSlotLink then
        local enchantName = SafeGetTradeEnchantName(GetTradeTargetItemInfo, enchantSlot)
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

local function AnnounceTradeComplete()
    if not GogoLootDB.announceTrade then
        return
    end
    if not tradeState.player then
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
        whisperTarget = tradeState.player
    elseif output == "raid" then
        if UnitInRaid("player") then
            chatChannel = "RAID"
        elseif IsInGroup() then
            chatChannel = "PARTY"
        else
            chatChannel = "WHISPER"
            whisperTarget = tradeState.player
        end
    else
        chatChannel = GogoLoot:GetGroupChatChannel()
        if chatChannel == "SAY" then
            chatChannel = "WHISPER"
            whisperTarget = tradeState.player
        end
    end

    if not chatChannel then
        return
    end

    local theirName = tradeState.player

    local ourSummary =
        BuildTradeSummary(
        tradeState.ourItems,
        tradeState.ourEnchantDescription,
        tradeState.ourMoney
    )
    local theirSummary =
        BuildTradeSummary(
        tradeState.theirItems,
        tradeState.theirEnchantDescription,
        tradeState.theirMoney
    )

    if not ourSummary and not theirSummary then
        return
    end

    -- Pick the locale-aware template based on which side(s) of the trade had
    -- contents, then route through the central Announce helper which wraps
    -- the body in the localized prefix/suffix and sends.
    if ourSummary and theirSummary then
        GogoLoot:Announce(chatChannel, whisperTarget, "MSG_TRADE_GAVE_RECEIVED", ourSummary, theirName, theirSummary)
    elseif ourSummary then
        GogoLoot:Announce(chatChannel, whisperTarget, "MSG_TRADE_GAVE", ourSummary, theirName)
    else
        GogoLoot:Announce(chatChannel, whisperTarget, "MSG_TRADE_RECEIVED", theirSummary, theirName)
    end
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------

local function HandleTradeShow()
    ResetTradeState()
    tradeState.player = GogoLoot:GetCleanUnitName("npc")
end

local function HandleTradeAcceptUpdate(playerAccepted, targetAccepted)
    if playerAccepted == 1 or targetAccepted == 1 then
        SnapshotTradeItems()
        tradeState.accepted = true
    end
end

local function HandleTradeRequestCancel()
    ResetTradeState()
end

local function HandleUserInterfaceInfoMessage(_, informationMessage)
    if informationMessage == ERR_TRADE_CANCELLED then
        ResetTradeState()
    elseif informationMessage == ERR_TRADE_COMPLETE then
        AnnounceTradeComplete()
        ResetTradeState()
    end
end

local function HandleTradePlayerItemChanged(slotIndex)
    if slotIndex and slotIndex >= 1 and slotIndex <= GogoLoot.TRADE_ITEM_SLOT_COUNT then
        local itemLink = GetTradePlayerItemLink(slotIndex)
        if itemLink then
            tradeState.ourItems[slotIndex] = {
                link = itemLink,
                count = GetOurTradeSlotCount(slotIndex)
            }
        else
            tradeState.ourItems[slotIndex] = nil
        end
    end
end

local function HandleTradeTargetItemChanged(slotIndex)
    if slotIndex and slotIndex >= 1 and slotIndex <= GogoLoot.TRADE_ITEM_SLOT_COUNT then
        local itemLink = GetTradeTargetItemLink(slotIndex)
        if itemLink then
            tradeState.theirItems[slotIndex] = {
                link = itemLink,
                count = GetTheirTradeSlotCount(slotIndex)
            }
        else
            tradeState.theirItems[slotIndex] = nil
        end
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
            local ACR = LibStub("AceConfigRegistry-3.0", true)
            if ACR then
                ACR:NotifyChange("GogoLoot_TradeAnnouncements")
            end
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
            GogoLoot:AddTooltipLine(GameTooltip, GogoLoot:GetColor("INFO") .. "GogoLoot|r")
            GameTooltip:AddLine(" ")
            GogoLoot:AddTooltipLine(GameTooltip, L["TRADE_TOOLTIP_TITLE"], "TITLE")
            GogoLoot:AddTooltipLine(GameTooltip, L["TRADE_TOOLTIP_DESC"], "DESC", true)
            GameTooltip:AddLine(" ")
            GogoLoot:AddTooltipDoubleLine(GameTooltip, L["TRADE_TOOLTIP_OUTPUT"], currentOutput, "DESC", "TEXT")
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
