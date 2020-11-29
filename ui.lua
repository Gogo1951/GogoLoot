
-- announce messages. TODO: put these in their own file
GogoLoot.LOOT_TARGET_MESSAGE = "{rt4} GogoLoot : Master Looter Active! %s items will go to %s!"

GogoLoot.SOFTRES_ACTIVE = "{rt4} GogoLoot : SoftRes.It List Imported! %s Reserves across %s Items included."
GogoLoot.SOFTRES_LOOT = "{rt4} GogoLoot : Per SoftRes.It List, %s goes to %s!"
GogoLoot.SOFTRES_ROLL = "{rt4} GogoLoot : Per SoftRes.It List, %s will be rolled on by %s!"

GogoLoot.AUTO_ROLL_ENABLED = "{rt4} GogoLoot : Auto %s on BoEs Enabled!"
GogoLoot.AUTO_ROLL_DISABLED = "{rt4} GogoLoot : Auto %s on BoEs Disabled!"

GogoLoot.OUT_OF_RANGE = "{rt4} GogoLoot : Tried to loot %s to %s, but %s was out of range."

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

local AceGUI = LibStub("AceGUI-3.0")

local function capitalize(str)
    return (str:gsub("^%l", string.upper))
end

function GogoLoot:BuildUI()

    if GogoLoot._frame and GogoLoot._frame:IsShown() then -- already showing
        return
    end

    local render;
    
    local frame = AceGUI:Create("Frame")
    frame.frame:SetFrameStrata("DIALOG")
    GogoLoot._frame = frame.frame
    frame:SetTitle("GogoLoot")
    frame:SetLayout("Fill")
    frame:SetWidth(520)
    frame:SetHeight(650)

    local wasAutoRollEnabled = GogoLoot_Config.autoRoll -- bit of a hack

    frame:SetCallback("OnClose", function()
        -- temporary hack
        SetCVar("autoLootDefault", "1")
        if GogoLoot:areWeMasterLooter() then
            GogoLoot:SetSoftresProfile(GogoLoot_Config.softres.lastInput)

            local playerLoots = {}

            for r, rarity in pairs(GogoLoot.rarityToText) do
                if r >= GetLootThreshold() then
                    local name = strlower(GogoLoot_Config.players[rarity] or UnitName("Player"))

                    --print(rarity)
                    if GogoLoot.textToLink[rarity] then
                        if not playerLoots[name] then
                            playerLoots[name] = {}
                        end
                        tinsert(playerLoots[name], rarity)
                    end
                end
            end

            for player, targets in pairs(playerLoots) do
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
            end

            if GogoLoot_Config.enableSoftres and GogoLoot_Config.softres.profiles.current then
                SendChatMessage(string.format(GogoLoot.SOFTRES_ACTIVE, tostring(GogoLoot_Config.softres.reserveCount), tostring(GogoLoot_Config.softres.itemCount)), UnitInRaid("Player") and "RAID" or "PARTY")
            end

        elseif GetLootMethod() == "group" and GogoLoot_Config.autoRoll and (not wasAutoRollEnabled) then
            SendChatMessage(string.format(GogoLoot.AUTO_ROLL_ENABLED, 1 == GogoLoot_Config.autoRollThreshold and "Need" or "Greed"), UnitInRaid("Player") and "RAID" or "PARTY")
        elseif GetLootMethod() == "group" and (not GogoLoot_Config.autoRoll) and wasAutoRollEnabled then
            SendChatMessage(string.format(GogoLoot.AUTO_ROLL_DISABLED, 1 == GogoLoot_Config.autoRollThreshold and "Need" or "Greed"), UnitInRaid("Player") and "RAID" or "PARTY")
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
            else
                print(" |cFF00FF00GogoLoot|r : Invalid item specified: " .. input)
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
        __slu = sortLookup

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
        label(widget, "    "..GogoLoot.textToName[filter], 280)
        local dropdown = AceGUI:Create("Dropdown")
        dropdown:SetWidth(150) -- todo: align right
        dropdown:SetList(players, playerOrder)
        dropdown:SetDisabled(disabled)

        if GogoLoot_Config.players[filter] then
            dropdown:SetValue(GogoLoot_Config.players[filter])
        else
            dropdown:SetValue(strlower(UnitName("Player")))
        end

        dropdown:SetCallback("OnValueChanged", function()
            GogoLoot_Config.players[filter] = dropdown:GetValue()
            --SendChatMessage(string.format(LOOT_TARGET_CHANGED, capitalize(filter), capitalize(dropdown:GetValue())), UnitInRaid("Player") and "RAID" or "PARTY")
        end)

        widget:AddChild(dropdown)
    end

    render = {
        ["ignoredBase"] = function(widget, group)
            buildIgnoredFrame(widget, "Items in this list will always show up for manual need or greed rolls.\n\nEnter Item ID, or Drag Item on to Input.", GogoLoot_Config.ignoredItemsSolo, group)
        end,
        ["ignoredMaster"] = function(widget, group)
            buildIgnoredFrame(widget, "Note that non-tradable Quest Items are always ignored and will appear in a Standard Loot Window.\n\nItems on this list will always show up in the Standard Loot Window.\n\nEnter Item ID, or Drag Item on to Input.", GogoLoot_Config.ignoredItemsMaster, group, 200)
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


            --local autoAccept = checkbox(widget, "Speedy Confirm (Auto Confirm BoP Loot)")
            --autoAccept:SetDisabled(true)
            local autoRoll = checkbox(widget, "Automatic Rolls on BoEs", nil, 280)
            autoRoll:SetCallback("OnValueChanged", function()
                GogoLoot_Config.autoRoll = autoRoll:GetValue()--print("Callback!  " .. tostring(speedyLoot:GetValue()))
            end)
            autoRoll:SetDisabled(false)
            autoRoll:SetValue(true == GogoLoot_Config.autoRoll)

            local dropdown = AceGUI:Create("Dropdown")
            dropdown:SetWidth(150) -- todo: align right
            dropdown:SetList({
                ["greed"]="Greed", ["need"]="Need"
            })
            dropdown:SetValue(1 == GogoLoot_Config.autoRollThreshold and "need" or "greed")
            dropdown:SetCallback("OnValueChanged", function()
                GogoLoot_Config.autoRollThreshold = (dropdown:GetValue() == "greed") and 2 or 1
            end)
            dropdown:SetDisabled(false)
            widget:AddChild(dropdown)

            local autoGray = checkbox(widget, "Automatic Destroy Gray Items on Loot", nil, nil)
            autoGray:SetCallback("OnValueChanged", function()
                GogoLoot_Config.enableAutoGray = autoGray:GetValue()--print("Callback!  " .. tostring(speedyLoot:GetValue()))
            end)
            autoGray:SetValue(true == GogoLoot_Config.enableAutoGray)

            local tabs = AceGUI:Create("TabGroup")
            tabs:SetLayout("Flow")
            tabs:SetTabs({
                {
                    text = "Ignored Items",
                    value="ignoredBase"
                },
            })
            tabs:SetFullWidth(true)
            tabs:SetFullHeight(true)
            tabs:SetCallback("OnGroupSelected", function(widget, event, group) widget:ReleaseChildren() render[group](widget, group) end)
            tabs:SelectTab("ignoredBase")
            widget:AddChild(tabs)
        end,
        ["ml"] = function(widget, group)
            local sf = widget
            if true then -- do scroll frame inside master loot
                sf = scrollFrame(widget)
            end
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
                SetLootMethod("master", UnitName("Player"), GogoLoot.textToRarity[dropdown:GetValue()])
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
            local includeBOP = checkbox(sf, "Include BoP Items (Not Advised for 5-man Content")
            includeBOP:SetValue(not GogoLoot_Config.disableBOP)
            includeBOP:SetCallback("OnValueChanged", function()
                GogoLoot_Config.disableBOP = not includeBOP:GetValue()
            end)
            --includeBOP:SetDisabled(true)
            spacer2(sf)
            label(sf, "Loot Destinations")
            spacer(sf)

            local playerList = GogoLoot:GetGroupMemberNames()
            local playerOrder = {}
            for k in pairs(playerList) do
                tinsert(playerOrder, k)
            end
            table.sort(playerOrder)

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
                importMessage:SetText("GogoLoot supports SoftRes.It! Just paste the CSV export from SoftRes.It website here to enable automatic distribution for this raid.")

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
            importMessage:SetText("GogoLoot supports SoftRes.It; paste CSV code from website here to enable automatic distribution for this raid.")

            
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
            spacer(widget)
            label(widget, "GogoLoot was designed to help speed up the looting process by automating some of the Master Looter and Group Loot settings.")
            spacer2(widget)
            spacer2(widget)
            labelLarge(widget, "Tips & Tricks")
            spacer(widget)
            labelNormal(widget, "    • Hold Shift while looting to disable GogoLoot for that corpse.")
            labelNormal(widget, "    • To keep momentum during a raid, have your Master Looter come with empty bags so they can scoop up all the gear and hand it out at the end.")
            labelNormal(widget, "    • For faster raid clears, set the threshold to gray (poor). This will allow your raiders to focus on moving in one direction towards the next boss, not having to run back randomly when they see sparkles. (Most instances don't have more than 5-10g worth of grays total; makes a good donation to your flask fund.)")
            labelNormal(widget, "    • When getting boosted, or power-leveled, turn \"destroy grays\" to avoid clutter.")

            spacer2(widget)
            spacer2(widget)
            labelLarge(widget, "Creators")
            labelNormal(widget, "    • Gogo (Earthfury-US).")
            labelNormal(widget, "    • Aero (Earthfury-US). Aero was also the creator of Questie.")
            labelNormal(widget, "    • Special thanks to Codzima (Stonespine-EU). Codzima was also the creator of SoftRes.It.")
            spacer2(widget)
            spacer2(widget)

            labelNormal(widget, "If you have any suggestions, or find any bugs, please add them to GitHub.")
            --labelNormal(widget, "https://github.com/Gogo1951/GogoLoot/issues/")
            local box = AceGUI:Create("EditBox")
            box:DisableButton(true)
            box:SetFullWidth(true)
            box:SetText("https://github.com/Gogo1951/GogoLoot/issues/")
            widget:AddChild(box)
        end
    }

    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
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
    tabs:SetCallback("OnGroupSelected", function(widget, event, group) widget:ReleaseChildren() render[group](widget, group) end)
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