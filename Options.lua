-------------------------------------------------------------------------------
-- GogoLoot Options & Configuration UI
-------------------------------------------------------------------------------
local AceGUI = LibStub("AceGUI-3.0")

-------------------------------------------------------------------------------
-- API Wrappers (Native Classic Handling)
-------------------------------------------------------------------------------
local function SafeGetLootMethod()
    if type(GetLootMethod) == "function" then 
        return GetLootMethod() 
    elseif C_PartyInfo and type(C_PartyInfo.GetLootMethod) == "function" then
        local method = C_PartyInfo.GetLootMethod()
        if Enum and Enum.LootMethod then
            if method == Enum.LootMethod.FreeForAll then return "freeforall" end
            if method == Enum.LootMethod.RoundRobin then return "roundrobin" end
            if method == Enum.LootMethod.MasterLoot then return "master" end
            if method == Enum.LootMethod.GroupLoot then return "group" end
            if method == Enum.LootMethod.NeedBeforeGreed then return "needbeforegreed" end
        end
        if method == 0 then return "freeforall" end
        if method == 1 then return "roundrobin" end
        if method == 2 then return "master" end
        if method == 3 then return "group" end
        if method == 4 then return "needbeforegreed" end
    end
    return "group"
end

local function SafeGetLootThreshold()
    if type(GetLootThreshold) == "function" then return GetLootThreshold() end
    if C_PartyInfo and type(C_PartyInfo.GetLootThreshold) == "function" then return C_PartyInfo.GetLootThreshold() end
    return 2
end

-------------------------------------------------------------------------------
-- UI Builder Helpers
-------------------------------------------------------------------------------
local function AddSpacer(parentWidget, height)
    local spacer = AceGUI:Create("Label")
    spacer:SetText(" ")
    spacer:SetFullWidth(true)
    spacer:SetHeight(height or 10)
    parentWidget:AddChild(spacer)
end

local function AddLargeLabel(parentWidget, text)
    local label = AceGUI:Create("Label")
    label:SetText(text)
    label:SetFontObject(GameFontNormalLarge)
    label:SetFullWidth(true)
    parentWidget:AddChild(label)
end

local function AddNormalLabel(parentWidget, text)
    local label = AceGUI:Create("Label")
    label:SetText(text)
    label:SetFullWidth(true)
    parentWidget:AddChild(label)
end

local function AddSectionHeader(parentWidget, text)
    AddSpacer(parentWidget, 20)
    local heading = AceGUI:Create("Heading")
    heading:SetText(text)
    heading:SetFullWidth(true)
    parentWidget:AddChild(heading)
    AddSpacer(parentWidget, 10)
end

local function AddCheckbox(parentWidget, labelText, tooltipText, initialValue, onChangeCallback)
    local checkbox = AceGUI:Create("CheckBox")
    checkbox:SetLabel(labelText)
    checkbox:SetValue(initialValue)
    checkbox:SetFullWidth(true)
    if tooltipText then checkbox:SetDescription(tooltipText) end
    checkbox:SetCallback("OnValueChanged", function(_, _, newValue) onChangeCallback(newValue) end)
    parentWidget:AddChild(checkbox)
    return checkbox
end

local function AddDropdown(parentWidget, labelText, optionsList, dropdownValue, onChangeCallback, colorHex)
    local dropdown = AceGUI:Create("Dropdown")
    if colorHex then
        dropdown:SetLabel("|c" .. colorHex .. labelText .. "|r")
    else
        dropdown:SetLabel(labelText)
    end
    dropdown:SetList(optionsList)
    dropdown:SetValue(dropdownValue)
    dropdown:SetWidth(250)
    dropdown:SetCallback("OnValueChanged", function(_, _, selectedKey) onChangeCallback(selectedKey) end)
    parentWidget:AddChild(dropdown)
    return dropdown
end

local function AddReadOnlyDropdown(parentWidget, labelText, optionsList, dropdownValue)
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetLabel(labelText)
    dropdown:SetList(optionsList)
    dropdown:SetValue(dropdownValue)
    dropdown:SetWidth(250)
    dropdown:SetDisabled(true)
    parentWidget:AddChild(dropdown)
    return dropdown
end

-------------------------------------------------------------------------------
-- Custom Roll List Builder
-------------------------------------------------------------------------------
local function AddItemToSoloCustomList(itemIdentifierString)
    local numericIdentifier = tonumber(itemIdentifierString)
    if not numericIdentifier then
        local match = string.match(itemIdentifierString, "item:(%d+)")
        if match then numericIdentifier = tonumber(match) end
    end
    if numericIdentifier then
        GogoLoot_Configuration.ignoredItemsSolo[numericIdentifier] = GogoLoot.MANUAL
    end
end

local function AddItemToMasterIgnoreList(itemIdentifierString)
    local numericIdentifier = tonumber(itemIdentifierString)
    if not numericIdentifier then
        local match = string.match(itemIdentifierString, "item:(%d+)")
        if match then numericIdentifier = tonumber(match) end
    end
    if numericIdentifier then
        GogoLoot_Configuration.ignoredItemsMaster[numericIdentifier] = true
    end
end

local function RemoveItemFromList(listKey, itemIdentifier)
    if GogoLoot_Configuration[listKey][itemIdentifier] then
        GogoLoot_Configuration[listKey][itemIdentifier] = nil
    end
end

local function RestoreDefaultSoloCustomList()
    GogoLoot_Configuration.ignoredItemsSolo = GogoLoot:BuildDefaultIgnoreListSolo()
end

local function RestoreDefaultMasterIgnoreList()
    GogoLoot_Configuration.ignoredItemsMaster = GogoLoot:BuildDefaultIgnoreListMaster()
end

local function RenderSoloCustomList(scrollContainer)
    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    
    local restoreButton = AceGUI:Create("Button")
    restoreButton:SetText("Restore Default Custom Roll List")
    restoreButton:SetWidth(250)
    restoreButton:SetCallback("OnClick", function() 
        RestoreDefaultSoloCustomList()
        RenderGeneralSettings(scrollContainer)
    end)
    buttonGroup:AddChild(restoreButton)
    
    scrollContainer:AddChild(buttonGroup)
    AddSpacer(scrollContainer)

    local promptLabel = AceGUI:Create("Label")
    promptLabel:SetText("Enter Item ID, or Drag Item on to Input.")
    promptLabel:SetColor(1, 1, 1)
    promptLabel:SetFullWidth(true)
    scrollContainer:AddChild(promptLabel)

    local inputGroup = AceGUI:Create("SimpleGroup")
    inputGroup:SetLayout("Flow")
    inputGroup:SetFullWidth(true)

    local itemInput = AceGUI:Create("EditBox")
    itemInput:SetWidth(150)
    inputGroup:AddChild(itemInput)

    local addButton = AceGUI:Create("Button")
    addButton:SetText("Add Item")
    addButton:SetWidth(120)
    addButton:SetCallback("OnClick", function()
        AddItemToSoloCustomList(itemInput:GetText())
        itemInput:SetText("")
        RenderGeneralSettings(scrollContainer)
    end)
    inputGroup:AddChild(addButton)

    scrollContainer:AddChild(inputGroup)
    AddSpacer(scrollContainer)

    local rollOverrideOptions = GogoLoot.ROLL_OVERRIDE_LABELS

    for itemIdentifier, rollAction in pairs(GogoLoot_Configuration.ignoredItemsSolo) do
        local itemGroup = AceGUI:Create("SimpleGroup")
        itemGroup:SetLayout("Flow")
        itemGroup:SetFullWidth(true)

        local itemName, itemLink = GogoLoot.GetItemInfo(itemIdentifier)
        local _, _, _, _, icon = GogoLoot.GetItemInfoInstant(itemIdentifier)

        local itemLabel = AceGUI:Create("InteractiveLabel")
        itemLabel:SetWidth(250)
        if itemLink then
            itemLabel:SetText(itemLink)
        else
            itemLabel:SetText("Item ID: " .. itemIdentifier)
        end
        if icon then
            itemLabel:SetImage(icon)
            itemLabel:SetImageSize(16, 16)
        end
        itemLabel:SetCallback("OnEnter", function()
            if itemLink then
                GameTooltip:SetOwner(itemLabel.frame, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(itemLink)
                GameTooltip:Show()
            end
        end)
        itemLabel:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        itemGroup:AddChild(itemLabel)

        local rollDropdown = AceGUI:Create("Dropdown")
        rollDropdown:SetList(rollOverrideOptions)
        rollDropdown:SetValue(rollAction)
        rollDropdown:SetWidth(120)
        rollDropdown:SetCallback("OnValueChanged", function(_, _, selectedKey)
            GogoLoot_Configuration.ignoredItemsSolo[itemIdentifier] = selectedKey
        end)
        itemGroup:AddChild(rollDropdown)

        local removeButton = AceGUI:Create("Button")
        removeButton:SetText("X")
        removeButton:SetWidth(40)
        removeButton:SetCallback("OnClick", function() 
            RemoveItemFromList("ignoredItemsSolo", itemIdentifier)
            RenderGeneralSettings(scrollContainer)
        end)
        itemGroup:AddChild(removeButton)

        scrollContainer:AddChild(itemGroup)
    end
end

local function RenderMasterIgnoredItems(scrollContainer)
    local buttonGroup = AceGUI:Create("SimpleGroup")
    buttonGroup:SetLayout("Flow")
    buttonGroup:SetFullWidth(true)
    
    local restoreButton = AceGUI:Create("Button")
    restoreButton:SetText("Restore Default Master Looting Ignore List")
    restoreButton:SetWidth(290)
    restoreButton:SetCallback("OnClick", function() 
        RestoreDefaultMasterIgnoreList()
        if GogoLoot.optionsFrames and GogoLoot.optionsFrames.mlScroll then
            RenderMasterLooterSettings(GogoLoot.optionsFrames.mlScroll)
        end
    end)
    buttonGroup:AddChild(restoreButton)
    
    scrollContainer:AddChild(buttonGroup)
    AddSpacer(scrollContainer)

    local promptLabel = AceGUI:Create("Label")
    promptLabel:SetText("Enter Item ID, or Drag Item on to Input.")
    promptLabel:SetColor(1, 1, 1)
    promptLabel:SetFullWidth(true)
    scrollContainer:AddChild(promptLabel)

    local inputGroup = AceGUI:Create("SimpleGroup")
    inputGroup:SetLayout("Flow")
    inputGroup:SetFullWidth(true)

    local itemInput = AceGUI:Create("EditBox")
    itemInput:SetWidth(150)
    inputGroup:AddChild(itemInput)

    local addButton = AceGUI:Create("Button")
    addButton:SetText("Ignore Item")
    addButton:SetWidth(120)
    addButton:SetCallback("OnClick", function()
        AddItemToMasterIgnoreList(itemInput:GetText())
        itemInput:SetText("")
        if GogoLoot.optionsFrames and GogoLoot.optionsFrames.mlScroll then
            RenderMasterLooterSettings(GogoLoot.optionsFrames.mlScroll)
        end
    end)
    inputGroup:AddChild(addButton)

    scrollContainer:AddChild(inputGroup)
    AddSpacer(scrollContainer)

    for itemIdentifier, _ in pairs(GogoLoot_Configuration.ignoredItemsMaster) do
        local itemGroup = AceGUI:Create("SimpleGroup")
        itemGroup:SetLayout("Flow")
        itemGroup:SetFullWidth(true)

        local itemLabel = AceGUI:Create("InteractiveLabel")
        itemLabel:SetWidth(300)
        local itemName, itemLink = GogoLoot.GetItemInfo(itemIdentifier)
        local _, _, _, _, icon = GogoLoot.GetItemInfoInstant(itemIdentifier)

        if itemLink then
            itemLabel:SetText(itemLink)
        else
            itemLabel:SetText("Item ID: " .. itemIdentifier)
        end

        if icon then
            itemLabel:SetImage(icon)
            itemLabel:SetImageSize(16, 16)
        end

        itemLabel:SetCallback("OnEnter", function()
            if itemLink then
                GameTooltip:SetOwner(itemLabel.frame, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(itemLink)
                GameTooltip:Show()
            end
        end)
        itemLabel:SetCallback("OnLeave", function() GameTooltip:Hide() end)
        itemGroup:AddChild(itemLabel)

        local removeButton = AceGUI:Create("Button")
        removeButton:SetText("Remove")
        removeButton:SetWidth(100)
        removeButton:SetCallback("OnClick", function() 
            RemoveItemFromList("ignoredItemsMaster", itemIdentifier)
            if GogoLoot.optionsFrames and GogoLoot.optionsFrames.mlScroll then
                RenderMasterLooterSettings(GogoLoot.optionsFrames.mlScroll)
            end
        end)
        itemGroup:AddChild(removeButton)

        scrollContainer:AddChild(itemGroup)
    end
end

-------------------------------------------------------------------------------
-- Destination Management
-------------------------------------------------------------------------------
local function ResetAllDestinations()
    for quality = 0, 4 do
        local qualityKey = GogoLoot.rarityToConfigurationKey[quality]
        if qualityKey then
            GogoLoot_Configuration.destinations[qualityKey] = "self"
        end
    end
end

local function IsNonSelfDestination(targetPlayerName)
    if not targetPlayerName then return false end
    local targetLower = strlower(targetPlayerName)
    return targetLower ~= "self" and targetLower ~= "player"
end

local function AnnounceDestinationSet(targetPlayerName, qualityKey)
    if not IsInGroup() then return end
    local displayName = GogoLoot:CapitalizeFirstLetter(targetPlayerName)
    local qualityLabel = GogoLoot.QUALITY_DISPLAY_NAMES[qualityKey] or GogoLoot:CapitalizeFirstLetter(qualityKey)
    local message = string.format(GogoLoot.MESSAGE_DESTINATION_SET, displayName, qualityLabel)
    SendChatMessage(message, GogoLoot:GetGroupChatChannel())
end

local function GetCurrentGroupMemberLookup()
    local groupMembers = {}
    local myName = GogoLoot:GetLowercaseUnitName("player")
    if myName then groupMembers[myName] = true end
    for memberIndex = 1, GetNumGroupMembers() do
        local unitIdentifier = IsInRaid() and ("raid" .. memberIndex) or ("party" .. memberIndex)
        local memberName = GogoLoot:GetLowercaseUnitName(unitIdentifier)
        if memberName then groupMembers[memberName] = true end
    end
    return groupMembers
end

local function CheckDestinationsForLeavers()
    if not IsInGroup() then return end
    if not GogoLoot:AreWeMasterLooter() then return end

    local groupMembers = GetCurrentGroupMemberLookup()
    local myName = GogoLoot:GetCleanUnitName("player")
    local mlDisplayName = GogoLoot:CapitalizeFirstLetter(myName)
    local chatChannel = GogoLoot:GetGroupChatChannel()
    local anyChanged = false

    for quality = 0, 4 do
        local qualityKey = GogoLoot.rarityToConfigurationKey[quality]
        if qualityKey then
            local targetPlayerName = GogoLoot_Configuration.destinations[qualityKey]
            if IsNonSelfDestination(targetPlayerName) then
                local targetLower = strlower(targetPlayerName)
                if not groupMembers[targetLower] then
                    local leaverDisplayName = GogoLoot:CapitalizeFirstLetter(targetPlayerName)
                    local qualityLabel = GogoLoot.QUALITY_DISPLAY_NAMES[qualityKey] or GogoLoot:CapitalizeFirstLetter(qualityKey)
                    GogoLoot_Configuration.destinations[qualityKey] = "self"
                    local message = string.format(GogoLoot.MESSAGE_DESTINATION_LEFT, leaverDisplayName, mlDisplayName, qualityLabel)
                    SendChatMessage(message, chatChannel)
                    anyChanged = true
                end
            end
        end
    end

    if anyChanged and GogoLoot.optionsFrames and GogoLoot.optionsFrames.mlScroll then
        RenderMasterLooterSettings(GogoLoot.optionsFrames.mlScroll)
    end
end

-------------------------------------------------------------------------------
-- Options Logic
-------------------------------------------------------------------------------
local function GetGroupMemberNames()
    local memberNames = { ["self"] = "Self" }
    local playerName = GogoLoot:GetLowercaseUnitName("player")

    for memberIndex = 1, GetNumGroupMembers() do
        local unitIdentifier = IsInRaid() and ("raid" .. memberIndex) or ("party" .. memberIndex)
        local memberName = GogoLoot:GetLowercaseUnitName(unitIdentifier)
        if memberName and memberName ~= playerName then memberNames[memberName] = GogoLoot:CapitalizeFirstLetter(memberName) end
    end
    return memberNames
end

local function BuildFilteredThresholdOptions(minimumQuality)
    local filteredOptions = {}
    for quality = minimumQuality, 4 do
        local colorHex = GogoLoot.QUALITY_COLORS[quality]
        local rarityKey = GogoLoot.rarityToConfigurationKey[quality]
        local displayName = GogoLoot:CapitalizeFirstLetter(rarityKey) .. "+"
        filteredOptions[quality] = "|c" .. colorHex .. displayName .. "|r"
    end
    return filteredOptions
end

function RenderGeneralSettings(scrollContainer)
    scrollContainer:ReleaseChildren()

    AddLargeLabel(scrollContainer, "GogoLoot // General Settings")
    AddSpacer(scrollContainer, 10)

    local greedThresholdOptions = {
        [0] = "|c" .. GogoLoot.QUALITY_COLORS[0] .. "Poor Only|r",
        [1] = "|c" .. GogoLoot.QUALITY_COLORS[1] .. "Common & Lower|r",
        [2] = "|c" .. GogoLoot.QUALITY_COLORS[2] .. "Uncommon & Lower|r",
        [3] = "|c" .. GogoLoot.QUALITY_COLORS[3] .. "Rare & Lower|r",
        [4] = "|c" .. GogoLoot.QUALITY_COLORS[4] .. "Epic & Lower|r",
    }
    local tradeAnnounceOptions = { ["always"] = "Send Message", ["group_ml"] = "When in Group & Master Looter", ["group"] = "When in Group" }

    AddSectionHeader(scrollContainer, "Speedy Loot")
    AddNormalLabel(scrollContainer, "Instantly picks up loot without showing the loot window, saving time between kills.")
    AddSpacer(scrollContainer, 10)
    AddCheckbox(scrollContainer, "Enable Speedy Loot (No Loot Window)", "", GogoLoot_Configuration.speedyLoot, function(value) GogoLoot_Configuration.speedyLoot = value end)
    
    AddSectionHeader(scrollContainer, "Trade Announcements")
    AddNormalLabel(scrollContainer, "Automatically posts a summary of completed trades to chat, including items, enchants, and gold exchanged.")
    AddSpacer(scrollContainer, 10)
    AddCheckbox(scrollContainer, "Enable Trade Announce", "", GogoLoot_Configuration.announceTrade, function(value) GogoLoot_Configuration.announceTrade = value end)
    AddSpacer(scrollContainer, 10)
    AddDropdown(scrollContainer, "Trade Announce Condition", tradeAnnounceOptions, GogoLoot_Configuration.announceTradeCondition, function(value) GogoLoot_Configuration.announceTradeCondition = value end)
    AddNormalLabel(scrollContainer, "Example: {rt4} Gave [Item X] x2, [Item Y] to Fathom. // GogoLoot")

    AddSectionHeader(scrollContainer, "Automatic Rolls")
    AddNormalLabel(scrollContainer, "Automatically rolls Greed on non-BoP items at or below the selected quality. Quest Items, Books, Recipes, Mounts, Pets, and Legendaries are always skipped. BoP items are never auto-greeded by the threshold, but can be automated via the Custom Roll List below.")
    AddSpacer(scrollContainer, 10)
    AddCheckbox(scrollContainer, "Enable Automatic Greed Rolls", "", GogoLoot_Configuration.autoGreed, function(value) GogoLoot_Configuration.autoGreed = value end)
    AddSpacer(scrollContainer, 10)
    AddDropdown(scrollContainer, "Automatic Greed Threshold", greedThresholdOptions, GogoLoot_Configuration.autoGreedThreshold, function(value) GogoLoot_Configuration.autoGreedThreshold = value end)
    
    AddSectionHeader(scrollContainer, "Custom Roll List")
    AddNormalLabel(scrollContainer, "Items on this list have their own roll rule that overrides the threshold. This is the only way to automate BoP items like Scourgestones or Demonic Runes. Set each item to Manual Roll, Greed, Need, or Pass. Quest Items, Books, Recipes, Mounts, Pets, and Legendaries are always skipped regardless of setting.")
    AddSpacer(scrollContainer, 10)
    RenderSoloCustomList(scrollContainer)
end

function RenderMasterLooterSettings(scrollContainer)
    scrollContainer:ReleaseChildren()

    local currentLootMethod = SafeGetLootMethod() or "group"
    local currentThreshold = SafeGetLootThreshold()

    AddLargeLabel(scrollContainer, "GogoLoot // Master Looter Settings")
    AddSpacer(scrollContainer, 10)

    local lootTypeOptions = { ["freeforall"] = "Free for All", ["roundrobin"] = "Round Robin", ["master"] = "Master Looter", ["group"] = "Group Loot", ["needbeforegreed"] = "Need Before Greed" }

    AddReadOnlyDropdown(scrollContainer, "Loot Type (read-only, change via Game Menu)", lootTypeOptions, currentLootMethod)
    AddSpacer(scrollContainer, 10)

    local thresholdOptions = { 
        [4] = "|c" .. GogoLoot.QUALITY_COLORS[4] .. "Epic|r", 
        [3] = "|c" .. GogoLoot.QUALITY_COLORS[3] .. "Rare|r", 
        [2] = "|c" .. GogoLoot.QUALITY_COLORS[2] .. "Uncommon|r", 
        [1] = "|c" .. GogoLoot.QUALITY_COLORS[1] .. "Common|r", 
        [0] = "|c" .. GogoLoot.QUALITY_COLORS[0] .. "Poor|r" 
    }

    if GogoLoot.isBurningCrusadeClassic then
        thresholdOptions[1] = nil
        thresholdOptions[0] = nil
    end

    AddReadOnlyDropdown(scrollContainer, "Loot Threshold (read-only, change via Game Menu)", thresholdOptions, currentThreshold)
    AddSpacer(scrollContainer, 10)

    AddSectionHeader(scrollContainer, "Automated Master Looting")
    AddNormalLabel(scrollContainer, "Automatically distributes loot to designated players when you are the Master Looter. Quest Items, Books, Recipes, Mounts, Pets, and Legendaries are always skipped and will appear in a standard loot window.")
    AddSpacer(scrollContainer, 10)

    local enableCheckbox = AddCheckbox(scrollContainer, "Enable Automatic Looting when Master Looter", "", GogoLoot_Configuration.autoMasterLoot, function(value) GogoLoot_Configuration.autoMasterLoot = value end)
    enableCheckbox:SetCallback("OnClick", function() 
        if not GogoLoot:AreWeMasterLooter() then GogoLoot:PrintMessage("You are not currently the Master Looter.") end 
    end)
    AddSpacer(scrollContainer, 10)

    AddCheckbox(scrollContainer, "Enable Automated Looting Outside of Instances", "", GogoLoot_Configuration.autoMasterLootOutsideInstances, function(value) GogoLoot_Configuration.autoMasterLootOutsideInstances = value end)
    AddNormalLabel(scrollContainer, "Caution : Due to world boss loot not being tradable, this is not advised!")
    AddSpacer(scrollContainer, 10)

    local groupMembers = GetGroupMemberNames()

    local destinationRarities = {
        { quality = 4, key = "epic",     label = "Epic" },
        { quality = 3, key = "rare",     label = "Rare" },
        { quality = 2, key = "uncommon", label = "Uncommon" },
        { quality = 1, key = "common",   label = "Common" },
        { quality = 0, key = "poor",     label = "Poor" },
    }

    for _, entry in ipairs(destinationRarities) do
        if entry.quality >= currentThreshold then
            AddDropdown(scrollContainer, entry.label, groupMembers, GogoLoot_Configuration.destinations[entry.key], function(value)
                GogoLoot_Configuration.destinations[entry.key] = value
                if IsNonSelfDestination(value) and IsInGroup() then
                    AnnounceDestinationSet(value, entry.key)
                end
            end, GogoLoot.QUALITY_COLORS[entry.quality])
            AddSpacer(scrollContainer, 10)
        end
    end

    AddSectionHeader(scrollContainer, "Loot Announcements")
    AddNormalLabel(scrollContainer, "Posts a message to group chat when items are distributed via Master Loot. Manual distributions are always announced regardless of threshold.")
    AddSpacer(scrollContainer, 10)

    local announceThresholdOptions = BuildFilteredThresholdOptions(currentThreshold)

    local currentAnnounceThreshold = GogoLoot_Configuration.announceMasterLootThreshold
    if currentAnnounceThreshold < currentThreshold then
        currentAnnounceThreshold = currentThreshold
        GogoLoot_Configuration.announceMasterLootThreshold = currentThreshold
    end

    AddCheckbox(scrollContainer, "Enable Loot Announce when Master Looter", "", GogoLoot_Configuration.announceMasterLoot, function(value) GogoLoot_Configuration.announceMasterLoot = value end)
    AddSpacer(scrollContainer, 10)
    AddDropdown(scrollContainer, "Announce Threshold", announceThresholdOptions, currentAnnounceThreshold, function(value) GogoLoot_Configuration.announceMasterLootThreshold = value end)
    AddNormalLabel(scrollContainer, "Example: {rt4} Gave [Item X] to Gogowarrior. // GogoLoot")

    AddSectionHeader(scrollContainer, "Master Looting Ignore List")
    AddNormalLabel(scrollContainer, "Items on this list will not be automatically distributed and will appear in a standard loot window for manual assignment.")
    AddSpacer(scrollContainer, 10)
    RenderMasterIgnoredItems(scrollContainer)
end

-------------------------------------------------------------------------------
-- Interface Options Integration
-------------------------------------------------------------------------------
function GogoLoot:InitializeOptions()
    GogoLoot.optionsFrames = {}

    local mainPanel = CreateFrame("Frame", "GogoLootOptionsPanel", UIParent)
    mainPanel.name = "GogoLoot"
    
    local title = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("GogoLoot")
    
    local subtitle = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Don't Let Loot Slow Down Your Zug")

    if Settings and type(Settings.RegisterCanvasLayoutCategory) == "function" then
        local category = Settings.RegisterCanvasLayoutCategory(mainPanel, mainPanel.name)
        category.ID = mainPanel.name
        Settings.RegisterAddOnCategory(category)
        GogoLoot.optionsFrames.mainCategory = category
    elseif type(InterfaceOptions_AddCategory) == "function" then
        InterfaceOptions_AddCategory(mainPanel)
    end

    local generalPanel = AceGUI:Create("BlizOptionsGroup")
    generalPanel:SetName("General Settings", "GogoLoot")
    generalPanel:SetLayout("Fill")
    local scrollGeneral = AceGUI:Create("ScrollFrame")
    scrollGeneral:SetLayout("List")
    generalPanel:AddChild(scrollGeneral)
    RenderGeneralSettings(scrollGeneral)
    
    if Settings and type(Settings.RegisterCanvasLayoutSubcategory) == "function" and GogoLoot.optionsFrames.mainCategory then
        local subcategory = Settings.RegisterCanvasLayoutSubcategory(GogoLoot.optionsFrames.mainCategory, generalPanel.frame, "General Settings")
        subcategory.ID = "GogoLoot_General"
        GogoLoot.optionsFrames.generalCategory = subcategory
    elseif type(InterfaceOptions_AddCategory) == "function" then
        InterfaceOptions_AddCategory(generalPanel.frame)
    end

    GogoLoot.optionsFrames.generalScroll = scrollGeneral

    local mlPanel = AceGUI:Create("BlizOptionsGroup")
    mlPanel:SetName("Master Looter Settings", "GogoLoot")
    mlPanel:SetLayout("Fill")
    local scrollML = AceGUI:Create("ScrollFrame")
    scrollML:SetLayout("List")
    mlPanel:AddChild(scrollML)
    RenderMasterLooterSettings(scrollML)
    
    if Settings and type(Settings.RegisterCanvasLayoutSubcategory) == "function" and GogoLoot.optionsFrames.mainCategory then
        local subcategory = Settings.RegisterCanvasLayoutSubcategory(GogoLoot.optionsFrames.mainCategory, mlPanel.frame, "Master Looter Settings")
        subcategory.ID = "GogoLoot_MasterLooter"
        GogoLoot.optionsFrames.mlCategory = subcategory
    elseif type(InterfaceOptions_AddCategory) == "function" then
        InterfaceOptions_AddCategory(mlPanel.frame)
    end

    mlPanel.frame:HookScript("OnShow", function()
        RenderMasterLooterSettings(scrollML)
    end)

    GogoLoot.optionsFrames.mlScroll = scrollML

    GogoLoot.optionsFrames.main = mainPanel
    GogoLoot.optionsFrames.general = generalPanel.frame
    GogoLoot.optionsFrames.ml = mlPanel.frame
end

function GogoLoot:OpenOptionsPanel(targetTab)
    if not GogoLoot.optionsFrames then return end

    if Settings and type(Settings.OpenToCategory) == "function" then
        if targetTab == "masterlooter" and GogoLoot.optionsFrames.mlCategory then
            Settings.OpenToCategory(GogoLoot.optionsFrames.mlCategory.ID)
        else
            Settings.OpenToCategory(GogoLoot.optionsFrames.mainCategory.ID)
        end
    elseif type(InterfaceOptionsFrame_OpenToCategory) == "function" then
        InterfaceOptionsFrame_OpenToCategory(GogoLoot.optionsFrames.main.name)
        InterfaceOptionsFrame_OpenToCategory(GogoLoot.optionsFrames.main.name)
        if targetTab == "masterlooter" then
            InterfaceOptionsFrame_OpenToCategory(GogoLoot.optionsFrames.ml)
        end
    end
end

function GogoLoot:HandleSlashCommand(inputText)
    GogoLoot:OpenOptionsPanel()
end

-------------------------------------------------------------------------------
-- Dynamic Event Hooks
-------------------------------------------------------------------------------
local wasMasterLooter = false
local wasInGroup = IsInGroup() or false

local function CheckMasterLooterStatus()
    local isML = GogoLoot:AreWeMasterLooter()
    if isML and not wasMasterLooter then
        GogoLoot:OpenOptionsPanel("masterlooter")
    end
    wasMasterLooter = isML

    if GogoLoot.optionsFrames and GogoLoot.optionsFrames.mlScroll then
        RenderMasterLooterSettings(GogoLoot.optionsFrames.mlScroll)
    end
end

local function HandleGroupRosterUpdate()
    local isCurrentlyInGroup = IsInGroup()

    -- If we just left a group, reset all destinations to Self
    if wasInGroup and not isCurrentlyInGroup then
        ResetAllDestinations()
        wasMasterLooter = false
        if GogoLoot.optionsFrames and GogoLoot.optionsFrames.mlScroll then
            RenderMasterLooterSettings(GogoLoot.optionsFrames.mlScroll)
        end
        wasInGroup = false
        return
    end

    wasInGroup = isCurrentlyInGroup

    -- Still in group: check for individual leavers
    CheckDestinationsForLeavers()

    if GogoLoot.optionsFrames and GogoLoot.optionsFrames.mlScroll then
        RenderMasterLooterSettings(GogoLoot.optionsFrames.mlScroll)
    end
end

GogoLoot:RegisterModuleEvent("PARTY_LOOT_METHOD_CHANGED", CheckMasterLooterStatus)
GogoLoot:RegisterModuleEvent("GROUP_ROSTER_UPDATE", HandleGroupRosterUpdate)