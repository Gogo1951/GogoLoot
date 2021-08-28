
function GogoLoot:GetItemLink(data)
    local quan = data[3]
    local link = data[7]--"[" .. data[1] .. "]" -- item links are broken on ptr. Use data[7] if its fixed

    if quan == 1 then return link else return string.format("$s x$d", link, quan) end
end

function GogoLoot:GetGoldString(value)
    local g = math.floor(value / 10000)
    local s = math.floor(value / 100) % 100
    local c = value % 100

    local str = string.sub(string.format("%dG %dS %dC", g, s, c), 1, -2)

    return str
end

function GogoLoot:PrintTrade()
    if GogoLoot_Config.disableTradeAnnounce or (not GogoLoot.tradeState.player) then
        return
    end

    local sent = nil
    local received = nil

    if GogoLoot.tradeState.goldMe > 0 then
        sent = GogoLoot:GetGoldString(GogoLoot.tradeState.goldMe)
    end

    if GogoLoot.tradeState.goldThem > 0 then
        received = GogoLoot:GetGoldString(GogoLoot.tradeState.goldThem)
    end

    local sentLastIndex = 0
    local receivedLastIndex = 0

    for i=1,6 do
        if GogoLoot.tradeState.itemsMe[i][3] > 0 then
            sentLastIndex = i
        end
        if GogoLoot.tradeState.itemsThem[i][3] > 0 then
            receivedLastIndex = i
        end
    end

    if GogoLoot.tradeState.enchantThem[5] and string.len(GogoLoot.tradeState.enchantThem[5]) > 0 then
        receivedLastIndex = receivedLastIndex + 1
    end

    if GogoLoot.tradeState.enchantMe[5] and string.len(GogoLoot.tradeState.enchantMe[5]) > 0 then
        sentLastIndex = sentLastIndex + 1
    end

    for i=1,6 do
        if GogoLoot.tradeState.itemsMe[i][3] > 0 then
            local temp = nil
            if sent ~= nil then
                if i == sentLastIndex then
                    temp = ", and "
                else
                    temp = ", "
                end
            end
            sent = string.format("%s%s%s", sent, temp, GogoLoot:GetItemLink(GogoLoot.tradeState.itemsMe[i]))
        end
        if GogoLoot.tradeState.itemsThem[i][3] > 0 then
            local temp = nil
            if received ~= nil then
                if i == receivedLastIndex then
                    temp = ", and "
                else
                    temp = ", "
                end
            end
            received = string.format("%s%s%s", received, temp, GogoLoot:GetItemLink(GogoLoot.tradeState.itemsMe[i]))
        end
    end

    if GogoLoot.tradeState.enchantThem[5] and string.len(GogoLoot.tradeState.enchantThem[5]) > 0 then
        sent = string.format("%s and gave enchant [%s]", sent, GogoLoot.tradeState.enchantThem[5])
    end

    if GogoLoot.tradeState.enchantMe[5] and string.len(GogoLoot.tradeState.enchantMe[5]) > 0 then
        received = string.format("%s and received enchant [%s]", sent, GogoLoot.tradeState.enchantThem[5])
    end

    local message = nil
    if sent ~= nil then
        GogoLoot:GGLSendChatMessage(message, GogoLoot.tradeState.player)
        message = string.format(GogoLoot.TRADE_COMPLETE, sent, GogoLoot.tradeState.player)
    end
    if received ~= nil then
        GogoLoot:GGLSendChatMessage(message, GogoLoot.tradeState.player)
        message = string.format(GogoLoot.TRADE_COMPLETE_RECEIVED, received, GogoLoot.tradeState.player)
    end
end

function GogoLoot:GGLSendChatMessage(...) -- (message [, player])
    local message, player = ...
    string.gsub(message, "  ", " ")
    message = string.format("%s.", message)
    if IsInGroup() then
        SendChatMessage(message, UnitInRaid("Player") and "RAID" or "PARTY")
    else
        SendChatMessage(message, "WHISPER", nil, player)
    end
end

function GogoLoot:ResetTrade()
    GogoLoot.tradeState = {
        ["goldMe"] = 0,
        ["goldThem"] = 0,
        ["itemsMe"] = {},
        ["itemsThem"] = {},
        ["enchantMe"] = nil,
        ["enchantThem"] = nil,
        ["player"] = "",
    }
end

function GogoLoot:UpdateTrade()
    GogoLoot.tradeState.goldMe = tonumber(GetPlayerTradeMoney())
    GogoLoot.tradeState.goldThem = tonumber(GetTargetTradeMoney())

    for i=1,6 do
        GogoLoot.tradeState.itemsMe[i] = {GetTradePlayerItemInfo(i)}
        GogoLoot.tradeState.itemsMe[i][7] = GetTradePlayerItemLink(i)
        GogoLoot.tradeState.itemsThem[i] = {GetTradeTargetItemInfo(i)}
        GogoLoot.tradeState.itemsThem[i][7] = GetTradeTargetItemLink(i)
    end

    GogoLoot.tradeState.enchantMe = {GetTradePlayerItemInfo(7)}
    GogoLoot.tradeState.enchantMe[7] = GetTradePlayerItemLink(7)
    GogoLoot.tradeState.enchantThem = {GetTradeTargetItemInfo(7)}
    GogoLoot.tradeState.enchantThem[7] = GetTradeTargetItemLink(7)

    -- fix param order (???)
    GogoLoot.tradeState.enchantThem[5] = GogoLoot.tradeState.enchantThem[6]

    GogoLoot.tradeState.player = UnitName("NPC")

end

function GogoLoot:HookTrades(events)
    events:RegisterEvent("TRADE_SHOW")
	events:RegisterEvent("TRADE_CLOSED")
	events:RegisterEvent("TRADE_REQUEST_CANCEL")
	events:RegisterEvent("TRADE_TARGET_ITEM_CHANGED")
	events:RegisterEvent("TRADE_ACCEPT_UPDATE")
	events:RegisterEvent("UI_INFO_MESSAGE")
	events:RegisterEvent("UI_ERROR_MESSAGE")
    events:RegisterEvent("ITEM_LOCKED")

    GogoLoot:ResetTrade()
    GogoLoot.lastTradeAnnounceTime = GetTime()

    local check = CreateFrame("CheckButton", "GogoLoot_AnnounceToggle", TradeFrame, "OptionsCheckButtonTemplate")
    GogoLoot_AnnounceToggleText:SetText("Announce Trades")
    check.tooltipText = "GogoLoot will announce trades to party or raid, or send a private message if you are not in a group."

    check:SetPoint("BOTTOMLEFT", "TradeFrame", "BOTTOMLEFT", 6, 4)
    check:SetWidth(26)
    check:SetHeight(26)

    check:SetChecked(true)

    check:SetScript("OnClick", function(self) GogoLoot_Config.disableTradeAnnounce = not self:GetChecked() end)

end

function GogoLoot:TradeEvent(evt, arg, message, a, b, c, ...)
    if evt == "UI_ERROR_MESSAGE" and (message == ERR_TRADE_BAG_FULL or message == ERR_TRADE_MAX_COUNT_EXCEEDED or message == ERR_TRADE_TARGET_BAG_FULL or message == ERR_TRADE_TARGET_MAX_COUNT_EXCEEDED) then
        -- trade failed
        if GogoLoot.tradeState.player then
            GogoLoot:GGLSendChatMessage(string.format(GogoLoot.TRADE_FAILED, GogoLoot.tradeState.player), GogoLoot.tradeState.player)
        end
    elseif evt == "TRADE_REQUEST_CANCEL" or (evt == "UI_INFO_MESSAGE" and message == ERR_TRADE_CANCELLED) then--elseif (evt == "UI_INFO_MESSAGE" and message == ERR_TRADE_CANCELLED) or evt == "TRADE_CLOSED" or evt == "TRADE_REQUEST_CANCEL" then
        -- trade cancelled
        if GogoLoot_Config.disableTradeAnnounce then
            return
        end

        local now = GetTime()
        if now - GogoLoot.lastTradeAnnounceTime > 0.1 and GogoLoot.tradeState.player then
            GogoLoot.lastTradeAnnounceTime = now
            GogoLoot:GGLSendChatMessage(string.format(GogoLoot.TRADE_CANCELLED, GogoLoot.tradeState.player), GogoLoot.tradeState.player)
        end
    elseif evt == "UI_INFO_MESSAGE" and message == ERR_TRADE_COMPLETE then
        GogoLoot:PrintTrade()
    elseif evt == "TRADE_PLAYER_ITEM_CHANGED" or evt == "TRADE_TARGET_ITEM_CHANGED" or evt == "TRADE_MONEY_CHANGED" or evt == "TRADE_ACCEPT_UPDATE" then
        -- trade has updated
        GogoLoot:UpdateTrade()
    elseif evt == "TRADE_SHOW" or evt == "ITEM_LOCKED" then
        GogoLoot:UpdateTrade()
    end
end
