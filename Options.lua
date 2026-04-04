--------------------------------------------------------------------------------
-- GogoLoot Options — Registration, Helpers, General Settings
--------------------------------------------------------------------------------
local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local COLORS = GogoLoot.COLORS
local L = GogoLoot.L

--------------------------------------------------------------------------------
-- AceConfig Widget Helpers (shared by all Options-*.lua files)
--------------------------------------------------------------------------------

function GogoLoot:OptionsHeader(text, order)
    return {
        type = "header",
        name = COLORS.TITLE .. text .. "|r",
        order = order
    }
end

function GogoLoot:OptionsDesc(text, order)
    return {
        type = "description",
        name = text,
        fontSize = "medium",
        order = order
    }
end

function GogoLoot:OptionsSpacer(order)
    return {
        type = "description",
        name = " ",
        order = order
    }
end

function GogoLoot:OptionsSubHeader(text, order)
    return {
        type = "description",
        name = "\n" .. COLORS.TITLE .. text .. "|r",
        fontSize = "medium",
        order = order
    }
end

--------------------------------------------------------------------------------
-- Custom AceGUI Widget: GogoLoot_ItemLink
-- A lightweight label that shows the full item tooltip on hover.
-- Used via dialogControl on AceConfig "input" entries; the get() function
-- returns the item ID as a string, and SetText handles lookup + rendering.
--------------------------------------------------------------------------------

do
    local AceGUI = LibStub("AceGUI-3.0")
    local widgetType = "GogoLoot_ItemLink"
    local widgetVersion = 1

    local function OnEnter(frame)
        local self = frame.obj
        if not self.itemIdentifier then
            return
        end
        local _, itemLink = GogoLoot.GetItemInfo(self.itemIdentifier)
        if itemLink then
            GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(itemLink)
            GameTooltip:Show()
        end
    end

    local function OnLeave(frame)
        GameTooltip:Hide()
    end

    local methods = {}

    function methods:OnAcquire()
        self.itemIdentifier = nil
        self:SetHeight(20)
    end

    function methods:OnRelease()
        self.itemIdentifier = nil
    end

    function methods:SetText(text)
        local itemId = tonumber(text)
        if itemId then
            self.itemIdentifier = itemId
            self.label:SetText(GogoLoot:GetItemDisplayName(itemId))
        else
            self.label:SetText(text or "")
        end
    end

    function methods:GetText()
        return self.itemIdentifier and tostring(self.itemIdentifier) or ""
    end

    function methods:SetLabel(text)
    end
    function methods:SetMaxLetters(num)
    end
    function methods:SetDisabled(disabled)
    end

    local function Constructor()
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetHeight(20)
        frame:EnableMouse(true)
        frame:SetScript("OnEnter", OnEnter)
        frame:SetScript("OnLeave", OnLeave)

        local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetJustifyH("LEFT")
        label:SetPoint("TOPLEFT")
        label:SetPoint("BOTTOMRIGHT")

        local widget = {
            label = label,
            frame = frame,
            type = widgetType
        }

        for method, func in pairs(methods) do
            widget[method] = func
        end

        return AceGUI:RegisterAsWidget(widget)
    end

    AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion)
end

--------------------------------------------------------------------------------
-- Item Display Helper
--------------------------------------------------------------------------------

function GogoLoot:GetItemDisplayName(itemIdentifier)
    local itemName, itemLink = GogoLoot.GetItemInfo(itemIdentifier)
    local _, _, _, _, icon = GogoLoot.GetItemInfoInstant(itemIdentifier)

    if itemLink and icon then
        return "|T" .. icon .. ":16|t " .. itemLink
    elseif itemLink then
        return itemLink
    elseif icon then
        return "|T" .. icon .. ":16|t " .. COLORS.MUTED .. string.format(L["ITEM_LOADING"], itemIdentifier) .. "|r"
    end

    return COLORS.MUTED .. string.format(L["ITEM_LOADING"], itemIdentifier) .. "|r"
end

--------------------------------------------------------------------------------
-- Item Cache Warming
-- Calls GetItemInfo for every item in both lists on load; uncached items
-- trigger a server query. GET_ITEM_INFO_RECEIVED fires when they arrive,
-- and we debounce a NotifyChange so the options panel refreshes.
--------------------------------------------------------------------------------

local itemCacheRefreshTimer = nil

local function RefreshOptionsAfterDelay()
    if itemCacheRefreshTimer then
        return
    end
    itemCacheRefreshTimer =
        C_Timer.NewTimer(
        0.3,
        function()
            itemCacheRefreshTimer = nil
            ACR:NotifyChange("GogoLoot_AutomaticRolls")
            ACR:NotifyChange("GogoLoot_MasterLooter")
        end
    )
end

local function WarmItemCache()
    local hasMissing = false

    for itemIdentifier in pairs(GogoLootDB.ignoredItemsSolo or {}) do
        local itemName = GogoLoot.GetItemInfo(itemIdentifier)
        if not itemName then
            hasMissing = true
        end
    end

    for itemIdentifier in pairs(GogoLootDB.ignoredItemsMaster or {}) do
        local itemName = GogoLoot.GetItemInfo(itemIdentifier)
        if not itemName then
            hasMissing = true
        end
    end

    if not hasMissing then
        return
    end

    C_Timer.After(1, RefreshOptionsAfterDelay)

    GogoLoot:RegisterModuleEvent(
        "GET_ITEM_INFO_RECEIVED",
        function()
            RefreshOptionsAfterDelay()
        end
    )
end

--------------------------------------------------------------------------------
-- General Options (main page)
--------------------------------------------------------------------------------

local function BuildGeneralOptions()
    return {
        type = "group",
        name = "GogoLoot",
        args = {
            header = GogoLoot:OptionsHeader(L["GENERAL"], 1),
            description = GogoLoot:OptionsDesc(L["GENERAL_DESC"], 2),
            spacerAfterDesc = GogoLoot:OptionsSpacer(3),
            speedyLoot = {
                type = "toggle",
                name = L["SPEEDY_LOOT"],
                desc = L["SPEEDY_LOOT_DESC"],
                width = "full",
                order = 4,
                get = function()
                    return GogoLootDB.speedyLoot
                end,
                set = function(_, value)
                    GogoLootDB.speedyLoot = value
                end
            },
            spacerCommands0 = GogoLoot:OptionsSpacer(5),
            headerCommands = GogoLoot:OptionsHeader(L["COMMANDS"], 6),
            spacerCommands1 = GogoLoot:OptionsSpacer(7),
            descCommands = GogoLoot:OptionsDesc(
                COLORS.INFO ..
                    "/gl|r" ..
                        "  " ..
                            L["COMMANDS_DESC_GL"] ..
                                "\n" .. COLORS.INFO .. "/gogoloot|r" .. "  " .. L["COMMANDS_DESC_GOGOLOOT"],
                8
            ),
            spacerResetSection = GogoLoot:OptionsSpacer(79),
            resetHeader = GogoLoot:OptionsHeader(L["RESET"], 80),
            resetDesc = GogoLoot:OptionsDesc(L["RESET_DESC"], 81),
            spacerBeforeReset = GogoLoot:OptionsSpacer(82),
            resetButton = {
                type = "execute",
                name = L["RESET_ALL"],
                width = "double",
                order = 83,
                confirm = true,
                confirmText = L["RESET_CONFIRM"],
                func = function()
                    GogoLootDB = {}
                    for configurationKey, defaultValue in pairs(GogoLoot.DEFAULT_CONFIGURATION) do
                        if type(defaultValue) == "table" then
                            GogoLootDB[configurationKey] = {}
                            for key, value in pairs(defaultValue) do
                                GogoLootDB[configurationKey][key] = value
                            end
                        else
                            GogoLootDB[configurationKey] = defaultValue
                        end
                    end
                    GogoLootDB.ignoredItemsMaster = GogoLoot:BuildDefaultIgnoreListMaster()
                    GogoLootDB.ignoredItemsSolo = GogoLoot:BuildDefaultIgnoreListSolo()
                    GogoLootDB.configVersion = GogoLoot.CONFIG_VERSION
                    ACR:NotifyChange("GogoLoot")
                    ACR:NotifyChange("GogoLoot_TradeAnnouncements")
                    ACR:NotifyChange("GogoLoot_AutomaticRolls")
                    ACR:NotifyChange("GogoLoot_MasterLooter")
                    GogoLoot:PrintMessage(L["MSG_SETTINGS_RESET_DEFAULTS"])
                end
            },
            spacerFeedbackSection = GogoLoot:OptionsSpacer(89),
            feedbackHeader = GogoLoot:OptionsHeader(L["FEEDBACK_SUPPORT"], 90),
            spacerAfterFeedback = GogoLoot:OptionsSpacer(91),
            curseforgeLabel = GogoLoot:OptionsDesc(COLORS.TITLE .. L["CURSEFORGE"] .. "|r", 92),
            curseforgeUrl = {
                type = "input",
                name = "",
                order = 93,
                width = "double",
                get = function()
                    return GogoLoot.URL_CURSEFORGE
                end,
                set = function()
                end
            },
            spacerBetweenLinks1 = GogoLoot:OptionsSpacer(94),
            githubLabel = GogoLoot:OptionsDesc(COLORS.TITLE .. L["GITHUB"] .. "|r", 95),
            githubUrl = {
                type = "input",
                name = "",
                order = 96,
                width = "double",
                get = function()
                    return GogoLoot.URL_GITHUB
                end,
                set = function()
                end
            },
            spacerBetweenLinks2 = GogoLoot:OptionsSpacer(97),
            discordLabel = GogoLoot:OptionsDesc(COLORS.TITLE .. L["DISCORD"] .. "|r", 98),
            discordUrl = {
                type = "input",
                name = "",
                order = 99,
                width = "double",
                get = function()
                    return GogoLoot.URL_DISCORD
                end,
                set = function()
                end
            }
        }
    }
end

--------------------------------------------------------------------------------
-- Initialization & Registration
--------------------------------------------------------------------------------

function GogoLoot:InitializeOptions()
    ACR:RegisterOptionsTable("GogoLoot", BuildGeneralOptions)

    if GogoLoot.BuildTradeAnnouncementOptions then
        ACR:RegisterOptionsTable("GogoLoot_TradeAnnouncements", GogoLoot.BuildTradeAnnouncementOptions)
    end

    if GogoLoot.BuildAutomaticRollOptions then
        ACR:RegisterOptionsTable("GogoLoot_AutomaticRolls", GogoLoot.BuildAutomaticRollOptions)
    end

    if GogoLoot.BuildMasterLooterOptions then
        ACR:RegisterOptionsTable("GogoLoot_MasterLooter", GogoLoot.BuildMasterLooterOptions)
    end

    local mainPanel = ACD:AddToBlizOptions("GogoLoot", "GogoLoot")
    GogoLoot.optionsFrames = {main = mainPanel}

    if GogoLoot.BuildTradeAnnouncementOptions then
        GogoLoot.optionsFrames.trade =
            ACD:AddToBlizOptions("GogoLoot_TradeAnnouncements", "Trade Announcements", "GogoLoot")
    end

    if GogoLoot.BuildAutomaticRollOptions then
        GogoLoot.optionsFrames.rolls = ACD:AddToBlizOptions("GogoLoot_AutomaticRolls", "Automated Rolls", "GogoLoot")
    end

    if GogoLoot.BuildMasterLooterOptions then
        GogoLoot.optionsFrames.ml = ACD:AddToBlizOptions("GogoLoot_MasterLooter", "Master Looter", "GogoLoot")
    end

    WarmItemCache()
end

--------------------------------------------------------------------------------
-- Panel Navigation
--------------------------------------------------------------------------------

function GogoLoot:OpenOptionsPanel(targetTab)
    if not GogoLoot.optionsFrames then
        return
    end

    if Settings and Settings.OpenToCategory then
        local categoryName = "GogoLoot"
        if targetTab == "masterlooter" then
            categoryName = "Master Looter"
        end

        local category = Settings.GetCategory and Settings.GetCategory(categoryName)
        if category then
            Settings.OpenToCategory(category.ID)
            return
        end

        category = Settings.GetCategory and Settings.GetCategory("GogoLoot")
        if category then
            Settings.OpenToCategory(category.ID)
            return
        end
    end

    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(GogoLoot.optionsFrames.main)
        -- Called twice for Classic compatibility
        InterfaceOptionsFrame_OpenToCategory(GogoLoot.optionsFrames.main)
        return
    end

    ACD:Open("GogoLoot")
end

--------------------------------------------------------------------------------
-- Slash Command
--------------------------------------------------------------------------------

function GogoLoot:HandleSlashCommand(inputText)
    GogoLoot:OpenOptionsPanel()
end