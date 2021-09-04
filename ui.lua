-- announce messages. TODO: put these in their own file
GogoLoot.LOOT_TARGET_MESSAGE = "{rt4} GogoLoot : Master Looter Active! %s items will go to %s!"
GogoLoot.LOOT_TARGET_DISABLED_MESSAGE = "{rt4} GogoLoot : Master Looter Active! %s items will use Standard Master Looter Window!"

GogoLoot.SOFTRES_ACTIVE = "{rt4} GogoLoot : SoftRes.It List Imported! %s Reserves across %s Items included."
GogoLoot.SOFTRES_URL = "{rt4} GogoLoot : Softres.it URL https://softres.it/raid/%s"
GogoLoot.SOFTRES_LOOT = "{rt4} GogoLoot : Per SoftRes.It List, %s goes to %s!"
GogoLoot.SOFTRES_LOOT_HARD = "{rt4} GogoLoot : Per SoftRes.It Hard Reserve, %s goes to %s!"
GogoLoot.SOFTRES_ROLL = "{rt4} GogoLoot : Per SoftRes.It List, %s will be rolled on by %s!"

GogoLoot.AUTO_ROLL_ENABLED = "{rt4} GogoLoot : Auto %s on BoEs Enabled!"
GogoLoot.AUTO_ROLL_DISABLED = "{rt4} GogoLoot : Auto %s on BoEs Disabled!"

GogoLoot.AUTO_NEED_WARNING = "{rt4} GogoLoot : WARNING! I'm Auto-Needing on %s!"

GogoLoot.OUT_OF_RANGE = "{rt4} GogoLoot : Tried to loot %s to %s, but %s was out of range."

GogoLoot.ADDON_CONFLICT = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4.png:0\124t GogoLoot : You have multiple addons running that are attempting to interact with the loot window. This will cause problems. If you don't disable your other loot addons you will experience issues with GogoLoot."

GogoLoot.TRADE_COMPLETE = "{rt4} GogoLoot : I gave %s to %s" -- no period, added by the logic so COMPLETE_RECEIVED can be appended cleanly
GogoLoot.TRADE_COMPLETE_RECEIVED = "{rt4} GogoLoot : I received %s from %s"
GogoLoot.TRADE_CANCELLED = "{rt4} GogoLoot : Trade with %s cancelled."
GogoLoot.TRADE_FAILED = "{rt4} GogoLoot : Trade with %s failed."

GogoLoot.API_WARNING = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4.png:0\124t GogoLoot : Due to a recent Blizzard API change, you may occasionally see a Loot Window if you attempt loot while in combat. Sorry!"

GogoLoot.conflicts = { -- name must match the .TOC filename
    "AutoDestroy",
    "AutoLootAssist",
    "AutoLooter", 
    "BetterAutoLoot",
    "CEPGP",
    "CommunityDKP",
    "KillTrack",
    "LootFast2",
    "RCLootCouncil_Classic",
    "SpeedyAutoLoot",
}

local AceGUI = LibStub("AceGUI-3.0")

StaticPopupDialogs["GOGOLOOT_THRESHOLD_ERROR"] = {
    text = "GogoLoot is unable to change loot threshold during combat.",
    button1 = "Ok",
    OnAccept = function()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

GogoLoot.creators = {
    [1] = { -- NA
        ["Horde"] = {
            ["Mankrik"] = {
                Gogobank = true, -- Gogo
                Gogodruid = true, -- Gogo
                Gogohunter = true, -- Gogo
                Gogomage = true, -- Gogo
                Gogopaladin = true, -- Gogo
                Gogopriest = true, -- Gogo
                Gogorogue = true, -- Gogo
                Gogoshaman = true, -- Gogo
                Gogowarlock = true, -- Gogo
                Gogowarrior = true, -- Gogo
            },
            ["Earthfury"] = {
                Aevala = true, -- Aevala
                Astraia = true, -- Aevala
                Astraya = true, -- Aevala
                Calliste = true, -- Aevala
                Maizee = true, -- Aevala
                Melidere = true, -- Aevala
                Wew = true, -- Aero
            }
        },
    },
    -- 2: korea
    [3] = { -- EU

    }
    -- 4: tiwan
    -- 5: china
}

local function _get(t, ...)
    for _, v in pairs({...}) do
        if type(t) ~= "table" then
            return nil
        end
        t = t[v]
    end
    return t
end

function GogoLoot:IsCreator(name, faction)
    return _get(GogoLoot.creators, GetCurrentRegion(), faction, GetRealmName(), name)
end

local function capitalize(str)
    return (str:gsub("^%l", string.upper))
end

function GogoLoot:BuildUI()

    if GogoLoot._frame and GogoLoot._frame.frame:IsShown() then -- already showing
        -- redraw currently shown frame
        if GogoLoot._frame._redraw then
            GogoLoot._frame._redraw()
            GogoLoot._frame._update_tabs()
        end
        return
    end

    local render;
    
    local frame = AceGUI:Create("Frame")
    frame.frame:SetFrameStrata("DIALOG")
    GogoLoot._frame = frame
    frame:SetTitle("GogoLoot")
    frame:SetLayout("Fill")
    frame:SetWidth(565)
    frame:SetHeight(650)

    local wasAutoRollEnabled = GogoLoot_Config.autoRoll -- bit of a hack

    local function StringHash(text)
        local counter = 1
        local len = string.len(text)
        for i = 1, len, 3 do 
          counter = math.fmod(counter*8161, 4294967279) +  -- 2^32 - 17: Prime!
              (string.byte(text,i)*16776193) +
              ((string.byte(text,i+1) or (len-i+256))*8372226) +
              ((string.byte(text,i+2) or (len-i+256))*3932164)
        end
        return math.fmod(counter, 4294967291) -- 2^32 - 5: Prime (and different from the prime in the loop)
    end

    local TableHash = nil

    local function ObjectHash(data, seed)
        if type(data) == "table" then
            return TableHash(data, seed)
        elseif type(data) == "number" then
            return (seed or 0) + data
        elseif type(data) == "string" then
            return (seed or 0) + StringHash(data)
        end
        return seed
    end

    TableHash = function(data, seed)
        for k,v in pairs(data) do
            if k ~= "configHash" and k ~= "softres" then
                seed = ObjectHash(k, seed)
                seed = ObjectHash(v, seed)
            end
        end
        return seed
    end

    frame:SetCallback("OnClose", function()
        -- temporary hack
        --print("Config Hash: " .. tostring(TableHash(GogoLoot_Config, 0)))
        if (GogoLoot_Config.enabled and GogoLoot:areWeMasterLooter()) or GogoLoot_Config.speedyLoot then
            if not GogoLoot_Config.oldAutoLootSetting then
                GogoLoot_Config.oldAutoLootSetting = GetCVar("autoLootDefault")
            end
            SetCVar("autoLootDefault", "1")
        else
            if GogoLoot_Config.oldAutoLootSetting then
                SetCVar("autoLootDefault", GogoLoot_Config.oldAutoLootSetting)
                GogoLoot_Config.oldAutoLootSetting = nil
            end
        end
        if GogoLoot:areWeMasterLooter() then
            GogoLoot:SetSoftresProfile(GogoLoot_Config.softres.lastInput)

            local playerLoots = {}

            for r, rarity in pairs(GogoLoot.rarityToText) do
                if r >= GetLootThreshold() and r < 5 then -- less than orange
                    local name = strlower(GogoLoot_Config.players[rarity] or GogoLoot:UnitName("Player"))

                    --print(rarity)
                    if GogoLoot.textToLink[rarity] then
                        if not playerLoots[name] then
                            playerLoots[name] = {}
                        end
                        tinsert(playerLoots[name], capitalize(rarity))
                    end
                end
            end

            local configHashNow = TableHash(GogoLoot_Config, 0)
            if configHashNow ~= GogoLoot_Config.configHash or true then
                GogoLoot_Config.configHash = configHashNow

                local toSend = {}

                for player, targets in pairs(playerLoots) do
                    local targetCount = #targets
                    table.sort(targets)
                    
                    if targetCount > 0 then
                        local targetList = ""
                        local score = 0

                        -- hack
                        local scores = {
                            ["White"] = 1,
                            ["Green"] = 2,
                            ["Blue"] = 4,
                            ["Purple"] = 8
                        }

                        for index, target in pairs(targets) do
                            score = score + (scores[target] or 0)
                            if index == 1 then
                                targetList = target
                            elseif index == targetCount then
                                targetList = targetList .. ", and " .. target
                            else
                                targetList = targetList .. ", " .. target
                            end
                        end
                        tinsert(toSend, {string.format(player == "standardlootwindow" and GogoLoot.LOOT_TARGET_DISABLED_MESSAGE or GogoLoot.LOOT_TARGET_MESSAGE, targetList, capitalize(player)), score})
                        --SendChatMessage(string.format(player == "standardlootwindow" and GogoLoot.LOOT_TARGET_DISABLED_MESSAGE or GogoLoot.LOOT_TARGET_MESSAGE, targetList, capitalize(player)), UnitInRaid("Player") and "RAID" or "PARTY")
                    end
                end

                table.sort(toSend, function(a, b)
                    return a[2] < b[2]
                end)

                for _, v in pairs(toSend) do
                    SendChatMessage(v[1], UnitInRaid("Player") and "RAID" or "PARTY")
                end

                --[[for player, targets in pairs(playerLoots) do
                    local targetList = ""
                    local lastIndex = #targets - 2
                    if lastIndex == 0 then -- hack
                        lastIndex = 1
                    end
                    
                    for index, target in pairs(targets) do
                        if target ~= "orange" then
                            if index == lastIndex then
                                targetList = targetList .. capitalize(target) .. ", and "
                            else
                                targetList = targetList .. capitalize(target) .. ", "
                            end
                        end
                    end
                    targetList = string.sub(targetList, 1, -3)

                    SendChatMessage(string.format(GogoLoot.LOOT_TARGET_MESSAGE, targetList, capitalize(player)), UnitInRaid("Player") and "RAID" or "PARTY")
                end]]

                if GogoLoot_Config.enableSoftres and GogoLoot_Config.softres.profiles.current then
                    SendChatMessage(string.format(GogoLoot.SOFTRES_ACTIVE, tostring(GogoLoot_Config.softres.reserveCount), tostring(GogoLoot_Config.softres.itemCount)), UnitInRaid("Player") and "RAID" or "PARTY")
                    local urlString = string.format(GogoLoot.SOFTRES_URL, tostring(GogoLoot_Config.softres.profiles.current.id))
                    SendChatMessage(urlString, UnitInRaid("Player") and "RAID" or "PARTY")
                    if GogoLoot_Config.softres.profiles.current.discord and string.len(GogoLoot_Config.softres.profiles.current.discord) > 0 then
                        SendChatMessage("{rt4} GogoLoot : Discord " .. GogoLoot_Config.softres.profiles.current.discord, UnitInRaid("Player") and "RAID" or "PARTY")
                    end
                    
                end
            end
        elseif GetLootMethod() == "group" then
            -- find all types that we are need-rolling on (if any)
            GogoLoot:AnnounceNeeds()

        --[[elseif GetLootMethod() == "group" and GogoLoot_Config.autoRoll and (not wasAutoRollEnabled) and 1 == GogoLoot_Config.autoRollThreshold then
            SendChatMessage(string.format(GogoLoot.AUTO_ROLL_ENABLED, 1 == GogoLoot_Config.autoRollThreshold and "Need" or "Greed"), UnitInRaid("Player") and "RAID" or "PARTY")
        elseif GetLootMethod() == "group" and (not GogoLoot_Config.autoRoll) and wasAutoRollEnabled and 1 == GogoLoot_Config.autoRollThreshold then
            SendChatMessage(string.format(GogoLoot.AUTO_ROLL_DISABLED, 1 == GogoLoot_Config.autoRollThreshold and "Need" or "Greed"), UnitInRaid("Player") and "RAID" or "PARTY")]]
        end
        -- /run c=CharacterWristSlot;op = {c:GetPoint()};op[4] = op[4] + 230;op[5]=op[5]-50;c:SetPoint(unpack(op))c:Show()

        -- un f=function(a) return a:GetScript("OnClick") end StaticPopup1Button1:HookScript("OnClick",function() c=CraftCreateButton;w=CharacterWristSlot; f(c)(c) f(w)(w) print("enchanting") end)
        --[[for _, rarity in pairs(GogoLoot.rarityToText) do
            local name = GogoLoot_Config.players[rarity] or UnitName("Player")
            --print(rarity)
            if GogoLoot.textToLink[rarity] then
                print(string.format(LOOT_TARGET_MESSAGE, GogoLoot.textToLink[rarity], capitalize(name)))
                SendChatMessage(string.format(LOOT_TARGET_MESSAGE, GogoLoot.textToLink[rarity], capitalize(name)), "PARTY")
            end
        end]]
    end)

    local function checkbox(widget, text, callback, width)
        local box = AceGUI:Create("CheckBox")
        box:SetLabel(text)
        if width then
            box:SetWidth(width)
        else
            box:SetFullWidth(true)
        end
        widget:AddChild(box)
        return box
    end

    local function label(widget, text, width)
        local label = AceGUI:Create("Label")
        label:SetFontObject(GameFontHighlight)
        label:SetText(text)
        if width then
            label:SetWidth(width)
        else
            label:SetFullWidth(true)
        end
        widget:AddChild(label)
    end

    local function labelNormal(widget, text, width)
        local label = AceGUI:Create("Label")
        label:SetFontObject(GameFontNormal)
        label:SetText(text)
        if width then
            label:SetWidth(width)
        else
            label:SetFullWidth(true)
        end
        widget:AddChild(label)
    end

    local function labelLarge(widget, text, width)
        local label = AceGUI:Create("Label")
        label:SetFontObject(GameFontHighlightLarge)
        label:SetText(text)
        if width then
            label:SetWidth(width)
        else
            label:SetFullWidth(true)
        end
        widget:AddChild(label)
    end

    local function spacer(widget, width) -- todo make this not bad
        local label = AceGUI:Create("Label")
        label:SetFullWidth(true)
        label:SetFontObject(GameFontHighlight)
        widget:AddChild(label)
    end

    local function spacer2(widget) -- todo make this not bad
        local label = AceGUI:Create("Label")
        label:SetFullWidth(true)
        label:SetFontObject(GameFontHighlight)
        label:SetText(" ")
        widget:AddChild(label)
    end

    local function scrollFrame(widget, height)
        local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
        scrollcontainer:SetFullWidth(true)
        if height then
            scrollcontainer:SetHeight(height)
        else
            scrollcontainer:SetFullHeight(true)
        end
        scrollcontainer:SetLayout("Fill")

        widget:AddChild(scrollcontainer)

        local scroll = AceGUI:Create("ScrollFrame")
        scroll:SetLayout("Flow")
        scrollcontainer:AddChild(scroll)

        return scroll
    end

    local function buildItemLink(widget, itemID, disableIcon, width)
        local label = AceGUI:Create("InteractiveLabel")
        local itemInfo = {GetItemInfo(itemID)}

        if not disableIcon then
            label:SetImage(itemInfo[10])
            label:SetImageSize(32,32)
        end

        label:SetWidth(width or 300)

        label:SetText(itemInfo[2])
        label:SetFontObject(GameFontHighlight)

        if disableIcon then
            widget:AddChild(label)
        else
            local container = AceGUI:Create("SimpleGroup")
            container:SetWidth(width or 300)
            container:AddChild(label)
            widget:AddChild(container)
        end
        
    end

    local function buildIgnoredFrame(widget, text, itemTable, group, height)
        spacer(widget)
        label(widget, text, nil)

        local box = AceGUI:Create("EditBox")
        box:DisableButton(true)
        box:SetWidth(150)
        --box:SetDisabled(true)

        spacer(widget)
        spacer(widget)
        widget:AddChild(box)

        local button = AceGUI:Create("Button")
        button:SetWidth(120)
        button:SetText("Ignore Item")
        button:SetCallback("OnClick", function()
            local input = box:GetText()
            local itemID = nil
            if GetItemInfoInstant(input) == nil or GetItemInfoInstant(input) == "" then print(" |cFF00FF00GogoLoot|r : Invalid item specified: " .. input) return end
            if tonumber(input) then
                itemID = tonumber(input)
            else
                local _, link = GetItemInfo(input)
                local data = {string.find(link or input,"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")};
                itemID = tonumber(data[5])
            end
            if itemID then
                --print(" |cFF00FF00GogoLoot|r : Ignoring item: " .. input) 
                itemTable[itemID] = true
                widget:ReleaseChildren()
                --print("Re-rendering " .. group)
                render[group](widget, group)
            end
        end)
        --button:SetDisabled(true)
        
        widget:AddChild(button)
        spacer(widget)

        local list = scrollFrame(widget, height)
        
        --[[for e=1,50 do
            --checkbox(list, "Test checkbox " .. tostring(e))
            buildItemLink(list, 8595)
            local button = AceGUI:Create("Button")
            button:SetWidth(85)
            button:SetText("Remove")
            list:AddChild(button)
            spacer(list)
        end]]

        local sortedList = {}
        local sortLookup = {}

        local badInfo = false

        for id in pairs(itemTable) do
            local n = GetItemInfo(tonumber(id))
            if not n then 
                badInfo = true
                break
            end
            tinsert(sortedList, n)
            sortLookup[n] = id
        end
        
        table.sort(sortedList)

        if badInfo then
            for id in pairs(itemTable) do
                buildItemLink(list, id)
                local button = AceGUI:Create("Button")
                button:SetWidth(85)
                button:SetText("Remove")
                button:SetCallback("OnClick", function()
                    itemTable[id] = nil
                    widget:ReleaseChildren()
                    render[group](widget, group)
                end)
                list:AddChild(button)
                spacer(list)
            end
        else
            for _,name in pairs(sortedList) do
                local id = sortLookup[name]
    
                buildItemLink(list, id)
                local button = AceGUI:Create("Button")
                button:SetWidth(85)
                button:SetText("Remove")
                button:SetCallback("OnClick", function()
                    itemTable[id] = nil
                    widget:ReleaseChildren()
                    render[group](widget, group)
                end)
                list:AddChild(button)
                spacer(list)
            end
        end
        --for id in pairs(itemTable) do
        

    end

    local function buildTypeDropdown(widget, filter, players, playerOrder, disabled)
        -- dont draw at all
        if disabled then return end

        label(widget, "    "..GogoLoot.textToName[filter], 200)
        local dropdown = AceGUI:Create("Dropdown")
        dropdown:SetWidth(150) -- todo: align right
        dropdown:SetList(players, playerOrder)
        dropdown:SetDisabled(disabled)
        dropdown:SetWidth(230)

        if GogoLoot_Config.players[filter] and GogoLoot_Config.players[filter] ~= "standardLootWindow" and not players[strlower(GogoLoot_Config.players[filter])] then -- the player is no longer in the party
            GogoLoot_Config.players[filter] = strlower(GogoLoot:UnitName("Player")) -- set filter to the master looter
        end

        if GogoLoot_Config.players[filter] then
            dropdown:SetValue(GogoLoot_Config.players[filter])
        else
            dropdown:SetValue(strlower(GogoLoot:UnitName("Player")))
        end

        dropdown:SetCallback("OnValueChanged", function()
            if dropdown:GetValue() == "---" then
                dropdown:SetValue(GogoLoot_Config.players[filter] or strlower(GogoLoot:UnitName("Player")))
            else
                GogoLoot_Config.players[filter] = dropdown:GetValue()
            end
            --SendChatMessage(string.format(LOOT_TARGET_CHANGED, capitalize(filter), capitalize(dropdown:GetValue())), UnitInRaid("Player") and "RAID" or "PARTY")
        end)

        dropdown:SetItemDisabled("---", true)

        widget:AddChild(dropdown)
    end

    render = {
        ["ignoredBase"] = function(widget, group)
            buildIgnoredFrame(widget, "Enter Item ID, or Drag Item on to Input.", GogoLoot_Config.ignoredItemsSolo, group)
        end,
        ["ignoredMaster"] = function(widget, group)
            buildIgnoredFrame(widget, "NOTE: All |cFFFF8000Legendary Quality|r items, as well as non-tradable Quest Items, are always ignored and will appear in a Standard Loot Window.\n\nItems on this list will always show up in the Standard Loot Window.\n\nEnter Item ID, or Drag Item on to Input.", GogoLoot_Config.ignoredItemsMaster, group, 200)
        end,
        ["general"] = function(widget, group)
            local speedyLoot = checkbox(widget, "Speedy Loot (No Loot Window)")
            speedyLoot:SetValue(true == GogoLoot_Config.speedyLoot)
            speedyLoot:SetCallback("OnValueChanged", function()
                GogoLoot_Config.speedyLoot = speedyLoot:GetValue()--print("Callback!  " .. tostring(speedyLoot:GetValue()))
                if GogoLoot_Config.speedyLoot then
                    LootFrame:UnregisterEvent('LOOT_OPENED')
                else
                    LootFrame:RegisterEvent('LOOT_OPENED')
                end
            end)

            local tradeAnnounce = checkbox(widget, "Announce Trades when in Group")
            tradeAnnounce:SetValue(not GogoLoot_Config.disableTradeAnnounce)
            tradeAnnounce:SetCallback("OnValueChanged", function()
                GogoLoot_Config.disableTradeAnnounce = not tradeAnnounce:GetValue()--print("Callback!  " .. tostring(speedyLoot:GetValue()))
            end)

            --[[
            local autoAccept = checkbox(widget, "Speedy Confirm (Auto Confirm BoP Loot)")
            autoAccept:SetCallback("OnValueChanged", function()
                GogoLoot_Config.autoConfirm = autoAccept:GetValue()
            end)
            autoAccept:SetDisabled(false)
            autoAccept:SetValue(true == GogoLoot_Config.autoConfirm)]]





            --local professionRoll = checkbox(widget, "Manual Roll on All Profession Items (Such as Patterns and Recipes)")
            --professionRoll:SetCallback("OnValueChanged", function()
            --    GogoLoot_Config.professionRollDisable = not professionRoll:GetValue()--print("Callback!  " .. tostring(speedyLoot:GetValue()))
            --end)
            --professionRoll:SetDisabled(false)
            --professionRoll:SetValue(not GogoLoot_Config.professionRoll)


            --[[
            local autoRoll = checkbox(widget, "Automatic Rolls on BoEs", nil, 280)
            autoRoll:SetCallback("OnValueChanged", function()
                GogoLoot_Config.autoRoll = autoRoll:GetValue()--print("Callback!  " .. tostring(speedyLoot:GetValue()))
            end)
            autoRoll:SetDisabled(false)
            autoRoll:SetValue(true == GogoLoot_Config.autoRoll)
            ]]

            local function buildDropdown(varName)
                local dropdown = AceGUI:Create("Dropdown")
                dropdown:SetWidth(200) -- todo: align right
                dropdown:SetList({
                    ["!manual"]="Manual Rolls", ["greed"]="Automatic Rolls - Greed", ["need"]="Automatic Rolls - Need"
                })
                dropdown:SetValue(GogoLoot_Config[varName] or "!manual")
                dropdown:SetCallback("OnValueChanged", function()
                    GogoLoot_Config[varName] = dropdown:GetValue() -- (dropdown:GetValue() == "greed") and 2 or 1
                end)
                dropdown:SetDisabled(false)
                widget:AddChild(dropdown)
            end
            
            spacer2(widget)

            labelLarge(widget, "Automatic Rolls")
            label(widget, "Rolls on |cff1eff00Green BoE Items|r", 250)
            buildDropdown("autoGreenRolls")

            label(widget, "Rolls on |cff0070ddBlue BoE Items|r", 250)
            buildDropdown("autoBlueRolls")

            label(widget, "Rolls on |cffa335eePurple BoE Items|r", 250)
            buildDropdown("autoPurpleRolls")


            spacer2(widget)
            labelLarge(widget, "Manual Roll List")

            label(widget, "• |cffff8000Orange Items")
            label(widget, "• Recipes")
            label(widget, "• Mounts")
            label(widget, "• Pets")
            spacer2(widget)
            label(widget, "Additionally, Items on this list will always show up for manual rolls.")
            spacer(widget)



            if WOW_PROJECT_ID ~= WOW_PROJECT_BURNING_CRUSADE_CLASSIC then -- the function requires a hardware event in TBC
                local autoGray = checkbox(widget, "Automatic Destroy Gray Items on Loot", nil, nil)
                autoGray:SetCallback("OnValueChanged", function()
                    GogoLoot_Config.enableAutoGray = autoGray:GetValue()--print("Callback!  " .. tostring(speedyLoot:GetValue()))
                end)
                autoGray:SetValue(true == GogoLoot_Config.enableAutoGray)
            end

            local tabs = AceGUI:Create("SimpleGroup")--AceGUI:Create("TabGroup")
            tabs:SetLayout("Flow")
            --[[tabs:SetTabs({
                {
                    text = "Ignored Items",
                    value="ignoredBase"
                },
            })]]
            tabs:SetFullWidth(true)
            tabs:SetFullHeight(true)
            --tabs:SetCallback("OnGroupSelected", function(widget, event, group) 
            --    widget:ReleaseChildren() render[group](widget, group)
            --end)
            render["ignoredBase"](tabs, "ignoredBase")
            --tabs:SelectTab("ignoredBase")
            widget:AddChild(tabs)
        end,
        ["ml"] = function(widget, group)
            local sf = widget
            if true then -- do scroll frame inside master loot
                sf = scrollFrame(widget)
            end

            label(sf, "GogoLoot will only attempt to Master Loot BOP items that are tradable, such as those found inside a Raid Instance. GogoLoot will not attempt to automate looting for BOP items that drop from World Bosses, as those are not tradable items.", nil)

            spacer(sf)
            local enabled = checkbox(sf, "Enable Automatic Looting for Master Looters")
            enabled:SetValue(GogoLoot_Config.enabled)
            enabled:SetCallback("OnValueChanged", function()
                GogoLoot_Config.enabled = enabled:GetValue()
            end)
            spacer(sf)
            label(sf, "Loot Threshold", 280)
            local dropdown = AceGUI:Create("Dropdown")
            dropdown:SetWidth(150) -- todo: align right
            if not UnitIsGroupLeader("Player") then
                dropdown:SetDisabled(true)
                dropdown:SetList({
                    ["gray"] = "Poor",
                    ["white"] = "Common",
                    ["green"] = "Uncommon",
                    ["blue"] = "Rare",
                    ["purple"] = "Epic",
                }, {"gray", "white", "green", "blue", "purple"})
            else
                dropdown:SetList({
                    ["gray"] = "|cff9d9d9dPoor|r",
                    ["white"] = "|cffffffffCommon|r",
                    ["green"] = "|cff1eff00Uncommon|r",
                    ["blue"] = "|cff0070ddRare|r",
                    ["purple"] = "|cffa335eeEpic|r",
                }, {"gray", "white", "green", "blue", "purple"})
            end
            
            dropdown:SetValue(GogoLoot.rarityToText[GetLootThreshold()])
            dropdown:SetCallback("OnValueChanged", function()
                SetLootMethod("master", GogoLoot:UnitName("Player"), GogoLoot.textToRarity[dropdown:GetValue()])
                -- validate 
                if GetLootThreshold() ~= GogoLoot.textToRarity[dropdown:GetValue()] then
                    --dropdown:SetValue(GogoLoot.rarityToText[GetLootThreshold()])
                    --StaticPopup_Show ("GOGOLOOT_THRESHOLD_ERROR")
                    widget:ReleaseChildren() -- redraw
                    render[group](widget, group)
                else
                    widget:ReleaseChildren() -- redraw
                    render[group](widget, group)
                end
            end)
            
            sf:AddChild(dropdown)
            spacer(sf)
            local includeBOP = checkbox(sf, "Include BoP Items (Not Advised for 5-man Content)")
            includeBOP:SetValue(not GogoLoot_Config.disableBOP)
            includeBOP:SetCallback("OnValueChanged", function()
                GogoLoot_Config.disableBOP = not includeBOP:GetValue()
            end)
            --includeBOP:SetDisabled(true)
            spacer2(sf)
            label(sf, "Loot Destinations")
            spacer(sf)

            local playerList = GogoLoot:GetGroupMemberNames()
            local playerOrder2 = {}
            for k in pairs(playerList) do
                tinsert(playerOrder2, k)
            end
            table.sort(playerOrder2)
            local playerOrder = {}
            tinsert(playerOrder, "standardLootWindow")
            tinsert(playerOrder, "---")
            for _, v in pairs(playerOrder2) do
                tinsert(playerOrder, v)
            end


            playerList["standardLootWindow"] = "Use Standard Master Looter Window"
            playerList["---"] = ""
            --tinsert(playerOrder, "standardLootWindow")

            local threshold = GetLootThreshold()

            buildTypeDropdown(sf, "gray", playerList, playerOrder, threshold > 0)
            buildTypeDropdown(sf, "white", playerList, playerOrder, threshold > 1)
            buildTypeDropdown(sf, "green", playerList, playerOrder, threshold > 2)
            buildTypeDropdown(sf, "blue", playerList, playerOrder, threshold > 3)
            buildTypeDropdown(sf, "purple", playerList, playerOrder, threshold > 4)

            --spacer2(widget)

            spacer(sf)

            --[[local fallbackLabel = AceGUI:Create("Label")
            fallbackLabel:SetFullWidth(true)
            fallbackLabel:SetFontObject(GameFontHighlight)
            fallbackLabel:SetText("Fallback Option")

            sf:AddChild(fallbackLabel)
            spacer(sf)]]

            if false then -- do softres in ML tab
                spacer2(sf)

                local importMessage = AceGUI:Create("Label")
                importMessage:SetFullWidth(true)
                importMessage:SetFontObject(GameFontNormal)
                importMessage:SetText("GogoLoot supports SoftRes.It! Just copy and paste the code from SoftRes.It website here to enable automatic distribution for this raid.")

                sf:AddChild(importMessage)

                local importEditBox = AceGUI:Create("MultiLineEditBox")
                importEditBox:SetFullWidth(true)
                importEditBox:SetHeight(64)
                importEditBox:DisableButton(true)
                importEditBox:SetLabel("")--("Status: Inactive")
                if GogoLoot_Config.softres.lastInput then
                    importEditBox:SetText(GogoLoot_Config.softres.lastInput)
                end
                importEditBox:SetCallback("OnTextChanged", function()
                    GogoLoot_Config.softres.lastInput = importEditBox:GetText()
                end)

                sf:AddChild(importEditBox)
            end

            local tabs = AceGUI:Create("TabGroup")
            tabs:SetLayout("Flow") 
            tabs:SetTabs({
                {
                    text = "Ignored Items",
                    value="ignoredMaster"
                },
            })
            tabs:SetFullWidth(true)
            tabs:SetFullHeight(true)
            tabs:SetCallback("OnGroupSelected", function(widget, event, group) widget:ReleaseChildren() render[group](widget, group) end)
            tabs:SelectTab("ignoredMaster")
            sf:AddChild(tabs)
        end,
        ["softres"] = function(widget, group)

            local importMessage = AceGUI:Create("Label")
            importMessage:SetFullWidth(true)
            importMessage:SetFontObject(GameFontNormal)
            importMessage:SetText("GogoLoot supports SoftRes.It; just copy and paste the code from SoftRes.It website here to enable automatic distribution for this raid.")

            
            local softres = checkbox(widget, "Enable SoftRes.It List Automation for Master Looter")
            softres:SetDisabled(not GogoLoot:areWeMasterLooter())
            softres:SetValue(GogoLoot_Config.enableSoftres and GogoLoot:areWeMasterLooter())
            softres:SetCallback("OnValueChanged", function()
                GogoLoot_Config.enableSoftres = softres:GetValue()
            end)
            spacer2(widget)
            widget:AddChild(importMessage)

            spacer(widget)

            local importEditBox = AceGUI:Create("MultiLineEditBox")
            importEditBox:SetFullWidth(true)
            importEditBox:SetFullHeight(true)
            importEditBox:DisableButton(true)
            importEditBox:SetLabel("")--("Status: Inactive")
            if GogoLoot_Config.softres.lastInput then
                importEditBox:SetText(GogoLoot_Config.softres.lastInput)
            end
            importEditBox:SetCallback("OnTextChanged", function()
                GogoLoot_Config.softres.lastInput = importEditBox:GetText()
            end)

            widget:AddChild(importEditBox)

            spacer2(widget)

            --[[
            local list = scrollFrame(widget)

            for _,id in pairs({}) do
                buildItemLink(list, id, true, 250)
                label(list, "Someplayer" .. tostring(_), 100)
            end
            ]]


        end,
        ["about"] = function(widget, group)
            widget = scrollFrame(widget)
            labelLarge(widget, "Don't Let Loot Slow Down Your Zug!")
    
            spacer(widget)

            label(widget, "GogoLoot was designed to help speed up the looting process by automating some of the Master Looter and Group Loot settings.")
            
            spacer2(widget)
            
            labelLarge(widget, "Tips & Tricks")
            
            spacer(widget)
            
            labelNormal(widget, "• Hold Shift while looting to disable GogoLoot for that corpse.")
            labelNormal(widget, "• To keep momentum during a raid, have your Master Looter come with empty bags so they can scoop up all the gear and hand it out at the end.")
            labelNormal(widget, "• For faster raid clears, set the threshold to gray (poor). This will allow your raiders to focus on moving in one direction towards the next boss, not having to run back randomly when they see sparkles.")

            spacer2(widget)
            
            labelNormal(widget, "Macro to Delete Grays")
            labelNormal(widget, "• Blizzard has removed the ability for add-ons to automatically delete gray items, however you can still use this macro to do it.")
            --labelNormal(widget, "Macro to Delete Grays")
            local box = AceGUI:Create("EditBox")
            box:DisableButton(true)
            box:SetFullWidth(true)
            box:SetText("/run for b=0,4 do for s=1,GetContainerNumSlots(b) do l=GetContainerItemLink(b,s) if l then _,_,r=GetItemInfo(l) if (r==0) then PickupContainerItem(b,s) DeleteCursorItem() end end end end")
            widget:AddChild(box)
            spacer2(widget)

            labelLarge(widget, "Feedback")

            spacer(widget)
 
            labelNormal(widget, "If you have feedback, feel free to share it on Discord.")
            --labelNormal(widget, "https://discord.gg/GegY9JMuKQ")
            local box = AceGUI:Create("EditBox")
            box:DisableButton(true)
            box:SetFullWidth(true)
            box:SetText("https://discord.gg/GegY9JMuKQ")
            widget:AddChild(box)
            spacer2(widget)

            labelNormal(widget, "If you find any bugs, please report them on GitHub.")
            --labelNormal(widget, "https://github.com/Gogo1951/GogoLoot/issues/")
            local box = AceGUI:Create("EditBox")
            box:DisableButton(true)
            box:SetFullWidth(true)
            box:SetText("https://github.com/Gogo1951/GogoLoot/issues/")
            widget:AddChild(box)

            spacer2(widget)
            
            labelLarge(widget, "Creators")

            spacer(widget)

            labelNormal(widget, "• Gogo (Mankrik-US).")
            labelNormal(widget, "• Aero (Earthfury-US). Aero was also the creator of Questie.")
            spacer2(widget)
            
            labelLarge(widget, "Special Thanks")

            spacer(widget)
            
            labelNormal(widget, "• Codzima (Stonespine-EU). Codzima was also the creator of SoftRes.It.")
            labelNormal(widget, "• Aevala (Earthfury-US).")
        end
    }

    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    frame._update_tabs = function()
        if GogoLoot:areWeMasterLooter() then
            tabs:SetTabs({
                {
                    text = "General Settings",
                    value = "general"
                },
                {
                    text = "Master Looter Settings",
                    value = "ml"
                },
                {
                    text = "SoftRes.It Settings",
                    value = "softres"
                },
                {
                    text = "About",
                    value = "about"
                }
            })
        else
            tabs:SetTabs({
                {
                    text = "General Settings",
                    value = "general"
                },
                {
                    text = "Master Looter Settings",
                    value = "ml",
                    disabled = true,
                },
                {
                    text = "SoftRes.It Settings",
                    value = "softres",
                    --disabled = true,
                },
                {
                    text = "About",
                    value = "about"
                }
            })
        end
    end
    frame._update_tabs()
    tabs:SetCallback("OnGroupSelected", function(widget, event, group) 
        frame._redraw = function()
            widget:ReleaseChildren() render[group](widget, group)      
        end
        frame._redraw()
    end)
    tabs:SelectTab("general")
    frame:AddChild(tabs)
    frame:Show()
end


function unpackCSV(data)
    local ret = {}
    local errorCount = 0

    for line in string.gmatch(data .. "\n", "(.-)\n") do
        if line and string.len(line) > 4 then
            local itemId, name, class, note, plus = string.match(line, "(.-),(.-),(.-),(.-),(.-)$")

            local validId = tonumber(itemId)

            if not validId and itemId ~= "ItemId" then
                errorCount = errorCount + 1
            end

            if validId then
                ret[validId] = {name, class, note, plus}
            end
        end
    end

    return ret, errorCount
end

function testUnpack()
    return unpackCSV("21503,Testname,Hunter,,2\n21499,Testname,Hunter,,2\n21494,Test,Druid,,1\n")
end
