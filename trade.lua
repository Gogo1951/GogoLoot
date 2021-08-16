
function GogoLoot:GetItemLink(data)
    local quan = data[3]
    
    local link = data[7]--"[" .. data[1] .. "]" -- item links are broken on ptr. Use data[7] if its fixed


    return link .. "x" .. tostring(quan)
end

function GogoLoot:GetGoldString(value)
    local str = ""
    local g = math.floor(value / 10000)
    local s = math.floor(value / 100) % 100
    local c = value % 100
    if g > 0 then
        str = str .. g .. "g"
    end
    if s > 0 then
        str = str .. s .. "s"
    end
    if c > 0 then
        str = str .. c .. "c"
    end
    return str
end

function GogoLoot:PrintTrade()

    if (not IsInGroup()) or GogoLoot_Config.disableTradeAnnounce then
        return
    end

    local sent = ""
    local received = ""

    if GogoLoot.tradeState.goldMe > 0 then
        sent = sent .. GogoLoot:GetGoldString(GogoLoot.tradeState.goldMe)
    end

    if GogoLoot.tradeState.goldThem > 0 then
        received = received .. GogoLoot:GetGoldString(GogoLoot.tradeState.goldThem)
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

    for i=1,6 do
        if GogoLoot.tradeState.itemsMe[i][3] > 0 then
            if string.len(sent) > 0 then
                if i == sentLastIndex then
                    sent = sent .. ", and "
                else
                    sent = sent .. ", "
                end
                sent = sent .. GogoLoot:GetItemLink(GogoLoot.tradeState.itemsMe[i])
            end
        end
        if GogoLoot.tradeState.itemsThem[i][3] > 0 then
            if string.len(received) > 0 then
                if i == receivedLastIndex then
                    received = received .. ", and "
                else
                    received = received .. ", "
                end
                received = received .. GogoLoot:GetItemLink(GogoLoot.tradeState.itemsThem[i])
            end
        end
    end

    local message = string.format(GogoLoot.TRADE_COMPLETE, GogoLoot.tradeState.player, sent)

    if string.len(received) > 0 then
        message = message .. string.format(GogoLoot.TRADE_COMPLETE_RECEIVED, received) .. "."
    else
        message = message .. "."
    end

    --print(message)

    SendChatMessage(message, IsInGroup() and (UnitInRaid("Player") and "RAID" or "PARTY") or "SAY")

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

    GogoLoot.tradeState.player = UnitName("NPC")

end

function GogoLoot:TestThing()
    local itemid = select(5, string.find(GetTradePlayerItemLink(1), "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?"))
    local lnk = select(2, GetItemInfo(tonumber(itemid)))
    print(itemid)
    print(lnk)
    SendChatMessage(lnk, "WHISPER", "Orcish", "Testerg")
    SendChatMessage("test", "WHISPER", "Orcish", "Testerg")
end

function GogoLoot:HookTrades(events)
    events:RegisterEvent("TRADE_SHOW")
	events:RegisterEvent("TRADE_CLOSED")
	events:RegisterEvent("TRADE_REQUEST_CANCEL")
	--events:RegisterEvent("PLAYER_TRADE_MONEY")

	--events:RegisterEvent("TRADE_MONEY_CHANGED")
	events:RegisterEvent("TRADE_TARGET_ITEM_CHANGED")
	events:RegisterEvent("TRADE_ACCEPT_UPDATE")
	events:RegisterEvent("UI_INFO_MESSAGE")
	events:RegisterEvent("UI_ERROR_MESSAGE")

    GogoLoot:ResetTrade()
    GogoLoot.lastTradeAnnounceTime = GetTime()
end

function GogoLoot:TradeEvent(evt, arg, message, a, b, c, ...)
    if evt == "UI_ERROR_MESSAGE" and (message == ERR_TRADE_BAG_FULL or message == ERR_TRADE_MAX_COUNT_EXCEEDED or message == ERR_TRADE_TARGET_BAG_FULL or message == ERR_TRADE_TARGET_MAX_COUNT_EXCEEDED) then
        -- trade failed
        SendChatMessage(string.format(GogoLoot.TRADE_FAILED, GogoLoot.tradeState.player), UnitInRaid("Player") and "RAID" or "PARTY")
    elseif evt == "TRADE_REQUEST_CANCEL" or (evt == "UI_INFO_MESSAGE" and message == ERR_TRADE_CANCELLED) then--elseif (evt == "UI_INFO_MESSAGE" and message == ERR_TRADE_CANCELLED) or evt == "TRADE_CLOSED" or evt == "TRADE_REQUEST_CANCEL" then
        -- trade cancelled
        if (not IsInGroup()) or GogoLoot_Config.disableTradeAnnounce then
            return
        end

        local now = GetTime()
        if now - GogoLoot.lastTradeAnnounceTime > 0.1 then
            GogoLoot.lastTradeAnnounceTime = now
            SendChatMessage(string.format(GogoLoot.TRADE_CANCELLED, GogoLoot.tradeState.player), UnitInRaid("Player") and "RAID" or "PARTY")
        else
            --print("Too recent!")
        end
    elseif evt == "UI_INFO_MESSAGE" and message == ERR_TRADE_COMPLETE then
        GogoLoot:PrintTrade()
    elseif evt == "TRADE_PLAYER_ITEM_CHANGED" or evt == "TRADE_TARGET_ITEM_CHANGED" or evt == "TRADE_MONEY_CHANGED" or evt == "TRADE_ACCEPT_UPDATE" then
        -- trade has updated
        GogoLoot:UpdateTrade()
    elseif evt == "TRADE_SHOW" then
        GogoLoot:UpdateTrade()
    end
end
