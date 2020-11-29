
local function unpackCSV(data)
    local ret = {}
    local errorCount = 0
    GogoLoot_Config.softres.reserveCount = 0
    GogoLoot_Config.softres.itemCount = 0
    local itemCounter = {}

    for line in string.gmatch(data .. "\n", "(.-)\n") do
        if line and string.len(line) > 4 then
            local itemId, name, class, note, plus = string.match(line, "(.-),(.-),(.-),(.-),(.-)$")

            local validId = tonumber(itemId)

            if not validId and itemId ~= "ItemId" then
                errorCount = errorCount + 1
            end

            if validId then
                if not itemCounter[validId] then
                    itemCounter[validId] = true
                    GogoLoot_Config.softres.itemCount = GogoLoot_Config.softres.itemCount + 1
                end
                GetItemInfo(validId) -- pre-cache the data (important!)
                if not ret[validId] then
                    ret[validId] = {}
                end
                tinsert(ret[validId], {["name"]=name, ["class"]=class, ["note"]=note, ["plus"]=plus})
                GogoLoot_Config.softres.reserveCount = GogoLoot_Config.softres.reserveCount + 1
            end
        end
    end

    return ret, errorCount
end

local function testUnpack()
    return unpackCSV("21503,Testname,Hunter,,2\n21499,Testname,Hunter,,2\n21494,Test,Druid,,1\n")
end

function GogoLoot:SetSoftresProfile(data)
    if data == GogoLoot_Config.softres.profiles._current_data then
        -- dont replace profile and overwrite removed (completed) reserves 
        return
    end
    if not data or string.len(data) < 4 then
        return -- invalid profile
    end
    local db, result = unpackCSV(data)
    if result == 0 then
        GogoLoot_Config.softres.profiles.current = db
        GogoLoot_Config.softres.profiles._current_data = data
        -- notify the party that softres.it profile is active
        --print("softres profile active")

    else
        -- notify user there were <result> errors parsing the data, and to try again
        --print("Error parsing softres profile")

        GogoLoot_Config.softres.profiles.current = nil
    end
end

function GogoLoot:HandleSoftresLoot(lootItemId, playerList)
    if GogoLoot_Config.enableSoftres and GogoLoot_Config.softres.profiles.current and GogoLoot_Config.softres.profiles.current[lootItemId] then

        local playerName = ""
        local playerCount = 0
        local lastIndex = 0

        for _, data in pairs(GogoLoot_Config.softres.profiles.current[lootItemId]) do
            -- todo: check that player is in the raid
            if playerList[strlower(data.name)] then
                lastIndex = lastIndex + 1
                playerName = data.name
            end
        end

        if lastIndex == 1 then
            GogoLoot_Config.softres.profiles.current[lootItemId] = nil -- remove reserve
            SendChatMessage(string.format(GogoLoot.SOFTRES_LOOT, select(2, GetItemInfo(lootItemId)), playerName), UnitInRaid("Player") and "RAID" or "PARTY")
            return playerName -- loot to this player
        else
            lastIndex = lastIndex - 2
            if lastIndex == 0 then -- hack
                lastIndex = 1
            end

            local targetList = ""
            for index, data in pairs(GogoLoot_Config.softres.profiles.current[lootItemId]) do
                -- todo: check that player is in the raid
                if index == lastIndex then
                    targetList = targetList .. data.name .. ", and "
                else
                    targetList = targetList .. data.name .. ", "
                end
                
            end
            targetList = string.sub(targetList, 1, -3)

            -- todo: watch for manual masterloot and remove player?
            GogoLoot:showLootFrame("Softres loot conflict")
            SendChatMessage(string.format(GogoLoot.SOFTRES_ROLL, select(2, GetItemInfo(lootItemId)), targetList), UnitInRaid("Player") and "RAID" or "PARTY")
            return true -- handled by softres (roll)
        end
        return false -- handled by softres but no valid players
    end
    return false -- no softres handling, fall back to normal distribution
end
