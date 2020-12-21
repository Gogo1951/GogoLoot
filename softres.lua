local HARD_RESERVE_OFFSET = 16777215

local function sortWeightedMap(a, b)
    if not a or not b then return false end
    return a[2] > b[2]
end

function GogoLoot:BuildWeightedPlayerMap(jsonData) -- build a weighted player map for quicker lookups
    local map = {}

    local function insertReserve(table, reserve, modifier)
        if not reserve or not reserve.item or not reserve.name then -- should never happen
            print("Bad data softres in profile!")
            return
        end
        if not table[reserve.item] then
            table[reserve.item] = {}
        end
        tinsert(table[reserve.item], {reserve.name, modifier + (reserve.rollBonus or 0)})
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

function GogoLoot:HandleSoftresLoot(lootItemId, playerList)
    if not GogoLoot_Config.enableSoftres or not GogoLoot_Config.softres.profiles.weightedPlayerMap then
        return false -- no softres profile
    end

    local weightMap = GogoLoot_Config.softres.profiles.weightedPlayerMap[lootItemId]

    if not weightMap then
        return false -- no reserve for this item
    end

    if #weightMap == 1 then
        if weightMap[1][2] < 0 then
            return false -- already received item
        end
        SendChatMessage(string.format(GogoLoot.SOFTRES_LOOT, select(2, GetItemInfo(lootItemId)), weightMap[1][1]), UnitInRaid("Player") and "RAID" or "PARTY")
        weightMap[1][2] = -1
        return weightMap[1][1] -- only 1 player reserved
    end

    if weightMap[1][2] >= HARD_RESERVE_OFFSET then -- item is hard reserved
        SendChatMessage(string.format(GogoLoot.SOFTRES_LOOT_HARD, select(2, GetItemInfo(lootItemId)), weightMap[1][1]), UnitInRaid("Player") and "RAID" or "PARTY")
        
        weightMap[1][2] = -1 -- remove hard reserve if it drops again
        table.sort(weightMap, sortWeightedMap) -- re-sort players

        return weightMap[1][1] -- only 1 player can hard reserve? Otherwise we should combine like below
    end
    
    local weightMapClean = {} -- remove players that already got the item
    for _,reserve in pairs(weightMap) do
        if reserve[2] >= 0 then
            tinsert(weightMapClean, reserve)
        end
    end

    local targetList = ""
    for index, target in pairs(weightMapClean) do
        local targetBonus = ""
        if target[2] > 0 then
            targetBonus = "[+" .. tostring(target[2]) .. "]" -- add roll bonus behind name
        end
        if index == 1 then
            targetList = target[1] .. targetBonus
        elseif index == #weightMapClean then
            targetList = targetList .. ", and " .. target[1] .. targetBonus
        else
            targetList = targetList .. ", " .. target[1] .. targetBonus
        end
    end

    GogoLoot:showLootFrame("Softres loot conflict")
    SendChatMessage(string.format(GogoLoot.SOFTRES_ROLL, select(2, GetItemInfo(lootItemId)), targetList), UnitInRaid("Player") and "RAID" or "PARTY")

    return true -- players must roll
end
