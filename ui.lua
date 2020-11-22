
-- announce messages. TODO: put these in their own file
local LOOT_TARGET_CHANGED = "{rt4} GogoLoot : Master Looter Active! %s Items > %s"


local AceGUI = LibStub("AceGUI-3.0")

local function capitalize(str)
    return (str:gsub("^%l", string.upper))
end

function GogoLoot:BuildUI()

    local render;

    if not GogoLoot_Config.ignoredItemsSolo then
        GogoLoot_Config.ignoredItemsSolo = {
            [4500] = true,
            [12811] = true
        }
        GogoLoot_Config.ignoredItemsMaster = {
            [21321] = true,
            [21218] = true,
            [21323] = true,
            [21324] = true
        }
    end
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("GogoLoot")
    frame:SetLayout("Fill")
    frame:SetWidth(500)
    frame:SetHeight(650)

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

    local function scrollFrame(widget)
        local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
        scrollcontainer:SetFullWidth(true)
        scrollcontainer:SetFullHeight(true)
        scrollcontainer:SetLayout("Fill")

        widget:AddChild(scrollcontainer)

        local scroll = AceGUI:Create("ScrollFrame")
        scroll:SetLayout("Flow")
        scrollcontainer:AddChild(scroll)

        return scroll
    end

    local function buildItemLink(widget, itemID)
        local container = AceGUI:Create("SimpleGroup")
        container:SetWidth(300)
        local label = AceGUI:Create("InteractiveLabel")
        local itemInfo = {GetItemInfo(itemID)}
        label:SetImage(itemInfo[10])
        label:SetWidth(300)
        label:SetImageSize(32,32)
        label:SetText(itemInfo[2])
        label:SetFontObject(GameFontHighlight)
        container:AddChild(label)
        widget:AddChild(container)
        
    end

    local function buildIgnoredFrame(widget, text, itemTable, group)
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

        local list = scrollFrame(widget)
        
        --[[for e=1,50 do
            --checkbox(list, "Test checkbox " .. tostring(e))
            buildItemLink(list, 8595)
            local button = AceGUI:Create("Button")
            button:SetWidth(85)
            button:SetText("Remove")
            list:AddChild(button)
            spacer(list)
        end]]

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

    end

    local function buildTypeDropdown(widget, filter, players, playerOrder)
        label(widget, "    "..GogoLoot.textToName[filter], 280)
        local dropdown = AceGUI:Create("Dropdown")
        dropdown:SetWidth(150) -- todo: align right
        dropdown:SetList(players, playerOrder)

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
            buildIgnoredFrame(widget, "Items in this list will always show up for manual need or greed rolls.", GogoLoot_Config.ignoredItemsSolo, group)
        end,
        ["ignoredMaster"] = function(widget, group)
            buildIgnoredFrame(widget, "Note that non-tradable Quest Items are always ignored and will appear in a Standard Loot Window.\n\nItems on this list will always show up in the Standard Loot Window.", GogoLoot_Config.ignoredItemsMaster, group)
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


            local autoAccept = checkbox(widget, "Suppress BoP Confirmation Popups (Auto Accept)")
            autoAccept:SetDisabled(true)
            local autoRoll = checkbox(widget, "Automatic Rolls on BoEs", nil, 280)
            autoRoll:SetCallback("OnValueChanged", function()
                GogoLoot_Config.autoRoll = speedyLoot:GetValue()--print("Callback!  " .. tostring(speedyLoot:GetValue()))
            end)
            autoRoll:SetDisabled(false)

            local dropdown = AceGUI:Create("Dropdown")
            dropdown:SetWidth(150) -- todo: align right
            dropdown:SetList({
                ["greed"]="Greed", ["need"]="Need"
            })
            dropdown:SetValue("greed")
            dropdown:SetCallback("OnValueChanged", function()
                GogoLoot_Config.autoRollThreshold = (dropdown:GetValue() == "greed") and 2 or 1
            end)
            dropdown:SetDisabled(false)
            widget:AddChild(dropdown)

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

            spacer(widget)
            local enabled = checkbox(widget, "Enable GogoLoot")
            enabled:SetValue(GogoLoot_Config.enabled)
            enabled:SetCallback("OnValueChanged", function()
                GogoLoot_Config.enabled = enabled:GetValue()
            end)
            spacer(widget)
            label(widget, "Loot Threshold", 280)
            local dropdown = AceGUI:Create("Dropdown")
            dropdown:SetWidth(150) -- todo: align right
            dropdown:SetList({
                ["gray"] = "|cff9d9d9dPoor|r",
                ["white"] = "|cffffffffCommon|r",
                ["green"] = "|cff1eff00Uncommon|r",
                ["blue"] = "|cff0070ddRare|r",
                ["purple"] = "|cffa335eeEpic|r",
            }, {"gray", "white", "green", "blue", "purple"})
            dropdown:SetValue(GogoLoot.rarityToText[GetLootThreshold()])
            dropdown:SetCallback("OnValueChanged", function()
                SetLootMethod("master", UnitName("Player"), GogoLoot.textToRarity[dropdown:GetValue()])
            end)
            widget:AddChild(dropdown)
            spacer(widget)
            local includeBOP = checkbox(widget, "Include BoP Items; note that some of these may not be tradable.")
            includeBOP:SetValue(not GogoLoot_Config.disableBOP)
            includeBOP:SetCallback("OnValueChanged", function()
                GogoLoot_Config.disableBOP = not includeBOP:GetValue()
            end)
            --includeBOP:SetDisabled(true)
            spacer2(widget)
            label(widget, "Loot Destinations")
            spacer(widget)

            local playerList = GogoLoot:GetGroupMemberNames()
            local playerOrder = {}
            for k in pairs(playerList) do
                tinsert(playerOrder, k)
            end
            table.sort(playerOrder)

            buildTypeDropdown(widget, "gray", playerList, playerOrder)
            buildTypeDropdown(widget, "white", playerList, playerOrder)
            buildTypeDropdown(widget, "green", playerList, playerOrder)
            buildTypeDropdown(widget, "blue", playerList, playerOrder)
            buildTypeDropdown(widget, "purple", playerList, playerOrder)

            --spacer2(widget)

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
            widget:AddChild(tabs)
        end
    }

    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetTabs({
        {
            text = "General Settings",
            value="general"
        },
        {
            text = "Master Looter Settings",
            value="ml"
        }
    })
    tabs:SetCallback("OnGroupSelected", function(widget, event, group) widget:ReleaseChildren() render[group](widget, group) end)
    tabs:SelectTab("general")
    frame:AddChild(tabs)


    frame:Show()
end
