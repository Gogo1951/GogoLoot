local HARD_RESERVE_OFFSET = 16777215

local function sortWeightedMap(a, b)
    if not a or not b then return false end
    return a[2] > b[2]
end

function GogoLoot:BuildWeightedPlayerMap(jsonData) -- build a weighted player map for quicker lookups
    local map = {}
    local reserveCountItems = 0
    local reserveCountTotal = 0

    local function insertReserve(table, reserve, modifier)
        if not reserve or not reserve.item or not reserve.name then -- should never happen
            print("Bad data softres in profile!")
            return
        end
        if not table[reserve.item] then
            table[reserve.item] = {}
            reserveCountItems = reserveCountItems + 1
        end
        tinsert(table[reserve.item], {reserve.name, modifier + (reserve.rollBonus or 0)})
        reserveCountTotal = reserveCountTotal + 1
    end

    if jsonData.hardreserves then
        for _, reserve in pairs(jsonData.hardreserves) do -- ensure hardreserves are above regular reserves
            insertReserve(map, reserve, HARD_RESERVE_OFFSET)
        end
    end

    if jsonData.softreserves then
        for _, reserve in pairs(jsonData.softreserves) do
            insertReserve(map, reserve, 0)
        end
    end

    for _, weightMap in pairs(map) do
        -- sort players by their weight
        table.sort(weightMap, sortWeightedMap)
    end

    --print("Loaded Softres.it profile, " .. tostring(reserveCountItems) .. " items, " .. tostring(reserveCountTotal) .. " reserves.")
    GogoLoot_Config.softres.itemCount = reserveCountItems
    GogoLoot_Config.softres.reserveCount = reserveCountTotal

    return map
end

function GogoLoot:SetSoftresProfile(data)
    if data == GogoLoot_Config.softres.profiles._current_data then
        -- dont replace profile and overwrite removed (completed) reserves 
        return
    end
    if not data or string.len(data) < 4 then
        return -- invalid profile
    end

    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local function decodeBase64(data)
        data = string.gsub(data, '[^'..b..'=]', '')
        return (data:gsub('.', function(x)
            if (x == '=') then return '' end
            local r,f='',(b:find(x)-1)
            for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
            return r;
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if (#x ~= 8) then return '' end
            local c=0
            for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
                return string.char(c)
        end))
    end

    data = decodeBase64(data)
    data = LibStub:GetLibrary("LibDeflate"):DecompressZlib(data)
    --print("json data: " .. data)

    local decoded = GogoLoot.json.decode(data)
    if decoded then
        GogoLoot_Config.softres.profiles.current = decoded
        GogoLoot_Config.softres.profiles.weightedPlayerMap = GogoLoot:BuildWeightedPlayerMap(decoded)
        GogoLoot_Config.softres.profiles._current_data = data
    else
        GogoLoot_Config.softres.profiles.current = nil
        GogoLoot_Config.softres.profiles.weightedPlayerMap = nil
        GogoLoot_Config.softres.profiles._current_data = nil
    end
end

GogoLoot.softresRemoveQueue = {}
GogoLoot.softresRemoveRoll = {}

function GogoLoot:HandleSoftresLooted(slot)
    
    local id = GogoLoot.softresRemoveQueue[slot]
    if id then
        local map = GogoLoot_Config.softres.profiles.weightedPlayerMap[id]
        if map then
            --print("Removed softres for " .. slot)
            map[1][2] = -1
            table.sort(map, sortWeightedMap) -- re-sort players
        end
        GogoLoot.softresRemoveQueue[slot] = nil -- this should probably be in the above if, but if this went wrong we should fail here and not more catastrophically later
    end
end

function GogoLoot:HandleSoftresRollWin(player, id)
    local weights = GogoLoot_Config.softres.profiles.weightedPlayerMap[id]
    if weights then
        for index, target in pairs(weights) do
            if strlower(target[1]) == player then
                target[2] = -1
                break
            end
        end
        table.sort(weights, sortWeightedMap)
    end
end

function GogoLoot:MirrorServerNames(playerList)
    local newList = {}
    for player, id in pairs(playerList) do
        if string.find(player, "-") then -- player is cross-realm
            newList[string.sub(player, 1, string.find(player, "-")-1)] = id
        end
        newList[player] = id
    end
    return newList
end

-- list of mobs / loot slots that have already been announced this session
local _announced_mobs = {}

function GogoLoot:HandleSoftresLoot(lootItemId, playerList, slot, mobGUID)
    if not GogoLoot_Config.enableSoftres or not GogoLoot_Config.softres.profiles.weightedPlayerMap then
        return false -- no softres profile
    end

    playerList = GogoLoot:MirrorServerNames(playerList)

    local weightMap = GogoLoot_Config.softres.profiles.weightedPlayerMap[lootItemId]

    if not weightMap then
        return false -- no reserve for this item
    end

    local weightMapClean = {} -- remove players that already got the item and players that arent in the group
    for _,reserve in pairs(weightMap) do
        if reserve[2] >= 0 and playerList[strlower(reserve[1])] then
            tinsert(weightMapClean, reserve)
        end
    end

    weightMap = weightMapClean

    if #weightMap == 0 then
        return false -- no valid reserve for this item
    elseif #weightMap == 1 then
        if weightMap[1][2] < 0 then
            return false -- already received item
        end
        if GogoLoot.softresRemoveQueue[slot] ~= lootItemId then
            SendChatMessage(string.format(GogoLoot.SOFTRES_LOOT, select(2, GetItemInfo(lootItemId)), weightMap[1][1]), UnitInRaid("Player") and "RAID" or "PARTY")
            GogoLoot.softresRemoveQueue[slot] = lootItemId
        end
        
        return weightMap[1][1] -- only 1 player reserved
    end

    if weightMap[1][2] >= HARD_RESERVE_OFFSET then -- item is hard reserved
        if GogoLoot.softresRemoveQueue[slot] ~= lootItemId then
            SendChatMessage(string.format(GogoLoot.SOFTRES_LOOT_HARD, select(2, GetItemInfo(lootItemId)), weightMap[1][1]), UnitInRaid("Player") and "RAID" or "PARTY")
            GogoLoot.softresRemoveQueue[slot] = lootItemId
        end

        return weightMap[1][1] -- only 1 player can hard reserve? Otherwise we should combine like below
    end
    
    local targetList = ""
    local targetTable = {}

    for index, target in pairs(weightMap) do
        local targetBonus = ""
        if target[2] > 0 then
            targetBonus = "[+" .. tostring(target[2]) .. "]" -- add roll bonus behind name
        end
        tinsert(targetTable, target[1])
        if index == 1 then
            targetList = target[1] .. targetBonus
        elseif index == #weightMap then
            targetList = targetList .. ", and " .. target[1] .. targetBonus
        else
            targetList = targetList .. ", " .. target[1] .. targetBonus
        end
    end

    GogoLoot:showLootFrame("Softres loot conflict")

    local lootKey = (mobGUID or "") .. "-" .. tostring(slot or 0) .. "-" .. tostring(lootItemId or 0)
    if not _announced_mobs[lootKey] then
        _announced_mobs[lootKey] = true -- prevent announcing the roll more than once, even if the events are fired multiple times (addon conflict?)
        SendChatMessage(string.format(GogoLoot.SOFTRES_ROLL, select(2, GetItemInfo(lootItemId)), targetList), UnitInRaid("Player") and "RAID" or "PARTY")
    end

    return targetTable -- players must roll
end
