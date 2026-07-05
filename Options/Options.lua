--------------------------------------------------------------------------------
-- GogoLoot Options — Registration, Helpers, General Settings
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L
local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local COLORS = GogoLoot.COLORS

--------------------------------------------------------------------------------
-- AceConfig Widget Helpers (shared by all Options-*.lua files)
-- Defined with `.` (not `:`) — these helpers don't use self, and a `.`
-- definition forces callers to use `.` invocation, which is consistent with
-- how GogoLoot.BuildAutomaticRollOptions / BuildMasterLooterOptions are
-- defined and called.
--------------------------------------------------------------------------------

function GogoLoot.OptionsHeader(text, order)
    return {
        type = "header",
        name = COLORS.TITLE .. text .. "|r",
        order = order
    }
end

function GogoLoot.OptionsDesc(text, order)
    return {
        type = "description",
        name = text,
        fontSize = "medium",
        order = order
    }
end

function GogoLoot.OptionsSpacer(order)
    return {
        type = "description",
        name = " ",
        order = order
    }
end

function GogoLoot.OptionsSubHeader(text, order)
    return {
        type = "description",
        name = "\n" .. COLORS.TITLE .. text .. "|r",
        fontSize = "medium",
        order = order
    }
end

--------------------------------------------------------------------------------
-- Shared Item List Builder
-- Used by both the Automated Rolls custom list and the Master Looter ignore
-- list. Handles the restore button, add-item input, sort, and per-item rows
-- with optional action dropdown. Pass in a spec table:
--
--   getSourceTable: function returning the DB table to iterate
--   onRestore:      function that replaces the source with defaults
--   onAdd:          function(itemId) that adds an item to the source
--   onRemove:       function(itemId) that removes an item from the source
--   notifyKey:      AceConfigRegistry table name to NotifyChange on edits
--   labels:         { restore, restoreConfirm, addDesc, addName, addTooltip,
--                     removeName, removeDesc }
--   actionColumn:   optional { desc, values, get, set }; when present each
--                   row gets an action dropdown and the item label is narrower
--------------------------------------------------------------------------------

function GogoLoot:BuildItemListOptions(spec)
    local labels = spec.labels
    local args = {}
    local order = 1

    args.restoreDefaults = {
        type = "execute",
        name = labels.restore,
        width = "double",
        order = order,
        confirm = true,
        confirmText = labels.restoreConfirm,
        func = function()
            spec.onRestore()
            ACR:NotifyChange(spec.notifyKey)
        end
    }
    order = order + 1

    args.spacerAfterRestore = GogoLoot.OptionsSpacer(order)
    order = order + 1

    args.addItemDesc = GogoLoot.OptionsDesc(labels.addDesc, order)
    order = order + 1

    args.addItemInput = {
        type = "input",
        name = labels.addName,
        desc = labels.addTooltip,
        order = order,
        get = function()
            return ""
        end,
        set = function(_, value)
            local itemIdentifier = GogoLoot:ParseItemInput(value)
            if not itemIdentifier then
                return
            end
            spec.onAdd(itemIdentifier)
            GogoLoot.GetItemInfo(itemIdentifier)
            ACR:NotifyChange(spec.notifyKey)
        end
    }
    order = order + 1

    args.spacerBeforeItems = GogoLoot.OptionsSpacer(order)
    order = order + 1

    local sortedIdentifiers = {}
    for itemIdentifier in pairs(spec.getSourceTable()) do
        table.insert(sortedIdentifiers, itemIdentifier)
    end
    GogoLoot:SortItemIdentifiersByRarity(sortedIdentifiers)

    local hasActionColumn = spec.actionColumn ~= nil
    local labelWidth = hasActionColumn and 1.3 or 2.0

    for _, itemIdentifier in ipairs(sortedIdentifiers) do
        local capturedId = itemIdentifier
        local rowArgs = {
            label = {
                type = "input",
                dialogControl = "GogoLoot_ItemLink",
                name = "",
                width = labelWidth,
                order = 1,
                get = function()
                    return tostring(capturedId)
                end,
                set = function()
                end
            }
        }

        if hasActionColumn then
            rowArgs.action = {
                type = "select",
                name = "",
                desc = spec.actionColumn.desc,
                values = spec.actionColumn.values,
                width = 0.7,
                order = 2,
                get = function()
                    return spec.actionColumn.get(capturedId)
                end,
                set = function(_, value)
                    spec.actionColumn.set(capturedId, value)
                end
            }
        end

        rowArgs.remove = {
            type = "execute",
            name = labels.removeName,
            desc = labels.removeDesc,
            width = 0.6,
            order = 3,
            func = function()
                spec.onRemove(capturedId)
                ACR:NotifyChange(spec.notifyKey)
            end
        }

        args["item_" .. capturedId] = {
            type = "group",
            name = "",
            inline = true,
            order = order,
            args = rowArgs
        }
        order = order + 1
    end

    return args
end

--------------------------------------------------------------------------------
-- Item Display Helper
-- Used by the GogoLoot_ItemLink AceGUI widget (defined in
-- Options-Item-Link-Widget.lua) to render the row label.
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
local itemCacheEventRegistered = false

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

    if not itemCacheEventRegistered then
        itemCacheEventRegistered = true
        GogoLoot:RegisterModuleEvent(
            "GET_ITEM_INFO_RECEIVED",
            function()
                RefreshOptionsAfterDelay()
            end
        )
    end
end

--------------------------------------------------------------------------------
-- General Options (main page)
--------------------------------------------------------------------------------

local function BuildGeneralOptions()
    return {
        type = "group",
        name = L["TAB_GENERAL"],
        args = {
            header = GogoLoot.OptionsHeader(L["GENERAL"], 1),
            description = GogoLoot.OptionsDesc(L["GENERAL_DESC"], 2),
            spacerAfterDesc = GogoLoot.OptionsSpacer(3),
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
            spacerCommands0 = GogoLoot.OptionsSpacer(5),
            headerCommands = GogoLoot.OptionsHeader(L["COMMANDS"], 6),
            spacerCommands1 = GogoLoot.OptionsSpacer(7),
            descCommandGl = GogoLoot.OptionsDesc(COLORS.INFO .. "/gl|r" .. "  " .. L["COMMANDS_DESC"], 8),
            spacerBetweenCommands = GogoLoot.OptionsSpacer(9),
            descCommandGogoloot = GogoLoot.OptionsDesc(COLORS.INFO .. "/gogoloot|r" .. "  " .. L["COMMANDS_DESC"], 10),
            spacerResetSection = GogoLoot.OptionsSpacer(79),
            resetHeader = GogoLoot.OptionsHeader(L["RESET"], 80),
            resetDesc = GogoLoot.OptionsDesc(L["RESET_DESC"], 81),
            spacerBeforeReset = GogoLoot.OptionsSpacer(82),
            resetButton = {
                type = "execute",
                name = L["RESET_ALL"],
                width = "double",
                order = 83,
                confirm = true,
                confirmText = L["RESET_CONFIRM"],
                func = function()
                    GogoLoot:ResetAllSettings()
                    ACR:NotifyChange("GogoLoot")
                    ACR:NotifyChange("GogoLoot_TradeAnnouncements")
                    ACR:NotifyChange("GogoLoot_AutomaticRolls")
                    ACR:NotifyChange("GogoLoot_MasterLooter")
                    GogoLoot:PrintMessage(L["MSG_SETTINGS_RESET_DEFAULTS"])
                end
            },
            spacerFeedbackSection = GogoLoot.OptionsSpacer(89),
            feedbackHeader = GogoLoot.OptionsHeader(L["FEEDBACK_SUPPORT"], 90),
            spacerAfterFeedback = GogoLoot.OptionsSpacer(91),
            curseforgeLabel = GogoLoot.OptionsDesc(COLORS.TITLE .. L["CURSEFORGE"] .. "|r", 92),
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
            spacerBetweenLinks1 = GogoLoot.OptionsSpacer(94),
            githubLabel = GogoLoot.OptionsDesc(COLORS.TITLE .. L["GITHUB"] .. "|r", 95),
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
            spacerBetweenLinks2 = GogoLoot.OptionsSpacer(97),
            discordLabel = GogoLoot.OptionsDesc(COLORS.TITLE .. L["DISCORD"] .. "|r", 98),
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
--
-- AceConfigRegistry table names (first arg to RegisterOptionsTable / first
-- arg to AddToBlizOptions) are stable identifiers and intentionally NOT
-- localized — they're used by NotifyChange calls across modules.
--
-- The user-facing display names passed as the SECOND arg to
-- AddToBlizOptions, and the parent reference (THIRD arg), are localized
-- via the TAB_* locale keys. The parent reference must match the display
-- name registered for the parent panel exactly, so OpenOptionsPanel below
-- looks up Settings categories by the same TAB_* keys.
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

    local mainPanel = ACD:AddToBlizOptions("GogoLoot", L["TAB_GENERAL"])
    GogoLoot.optionsFrames = {main = mainPanel}

    -- Child-panel display order in Blizzard's settings UI is the order of
    -- AddToBlizOptions calls: Master Looter, Automated Rolls, Announcements.

    if GogoLoot.BuildMasterLooterOptions then
        GogoLoot.optionsFrames.ml =
            ACD:AddToBlizOptions("GogoLoot_MasterLooter", L["TAB_MASTER_LOOTER"], L["TAB_GENERAL"])
    end

    if GogoLoot.BuildAutomaticRollOptions then
        GogoLoot.optionsFrames.rolls =
            ACD:AddToBlizOptions("GogoLoot_AutomaticRolls", L["TAB_AUTOMATED_ROLLS"], L["TAB_GENERAL"])
    end

    if GogoLoot.BuildTradeAnnouncementOptions then
        GogoLoot.optionsFrames.trade =
            ACD:AddToBlizOptions("GogoLoot_TradeAnnouncements", L["TAB_TRADE_ANNOUNCEMENTS"], L["TAB_GENERAL"])
    end

    WarmItemCache()
end

--------------------------------------------------------------------------------
-- Panel Navigation
--------------------------------------------------------------------------------

function GogoLoot:OpenOptionsPanel()
    if not GogoLoot.optionsFrames then
        return
    end

    if Settings and Settings.OpenToCategory then
        local category = Settings.GetCategory and Settings.GetCategory(L["TAB_GENERAL"])
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
-- Slash Commands
--------------------------------------------------------------------------------

SLASH_GOGOLOOT1 = "/gl"
SLASH_GOGOLOOT2 = "/gogoloot"
SlashCmdList["GOGOLOOT"] = function()
    GogoLoot:OpenOptionsPanel()
end
