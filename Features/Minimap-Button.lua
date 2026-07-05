--------------------------------------------------------------------------------
-- GogoLoot Minimap Button
--------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
local L = ns.L
local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local GetColor = ns.GetColor

local brokerObject

--------------------------------------------------------------------------------
-- Icon State
--------------------------------------------------------------------------------

--[[
    The minimap icon reflects the Auto-Greed toggle: on/off swap. Called from
    the click handler here and from the matching Options toggle so the icon
    stays in sync no matter where the user flips it.
]]

function ns:UpdateMinimapIcon()
    if not brokerObject then
        return
    end

    local state = ns.db.profile.autoGreed and "on" or "off"
    brokerObject.icon = ns.MINIMAP_ICONS[state] or ns.MINIMAP_ICONS.off

    if ns.db.global.minimap then
        LibDBIcon:Refresh(ADDON_NAME, ns.db.global.minimap)
    end
end

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

local function GetStatusText(isEnabled)
    if isEnabled then
        return GetColor("ON") .. L["STATUS_ENABLED"] .. "|r"
    end
    return GetColor("OFF") .. L["STATUS_DISABLED"] .. "|r"
end

--------------------------------------------------------------------------------
-- Click Handlers
--------------------------------------------------------------------------------

local function ToggleAutoGreed()
    ns.db.profile.autoGreed = not ns.db.profile.autoGreed
    ns:UpdateMinimapIcon()
    AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.AutomatedRolls)
end

local function ToggleSpeedyLoot()
    ns.db.profile.speedyLoot = not ns.db.profile.speedyLoot
    AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.General)
end

--------------------------------------------------------------------------------
-- Tooltip
--------------------------------------------------------------------------------

local function ShowTooltip(anchor)
    local tooltip = GameTooltip
    tooltip:SetOwner(anchor, "ANCHOR_NONE")
    tooltip:SetPoint("TOPRIGHT", anchor, "BOTTOMLEFT")
    tooltip:ClearLines()

    -- Title and version
    tooltip:AddDoubleLine(
        GetColor("TITLE") .. L["ADDON_TITLE"] .. "|r",
        GetColor("MUTED") .. ns.Version .. "|r"
    )
    tooltip:AddLine(" ")
    tooltip:AddLine(" ")

    -- Auto-Greed
    tooltip:AddDoubleLine(
        GetColor("TITLE") .. L["MINIMAP_AUTO_GREED"] .. "|r",
        GetStatusText(ns.db.profile.autoGreed)
    )
    ns:AddTooltipLine(tooltip, L["MINIMAP_AUTO_GREED_DESCRIPTION"], "BODY", true)
    tooltip:AddDoubleLine(
        GetColor("INFO") .. L["MINIMAP_LEFT_CLICK"] .. "|r",
        GetColor("INFO") .. L["MINIMAP_TOGGLE"] .. "|r"
    )
    tooltip:AddLine(" ")

    -- Speedy Loot
    tooltip:AddDoubleLine(
        GetColor("TITLE") .. L["MINIMAP_SPEEDY_LOOT"] .. "|r",
        GetStatusText(ns.db.profile.speedyLoot)
    )
    ns:AddTooltipLine(tooltip, L["MINIMAP_SPEEDY_LOOT_DESCRIPTION"], "BODY", true)
    tooltip:AddDoubleLine(
        GetColor("INFO") .. L["MINIMAP_RIGHT_CLICK"] .. "|r",
        GetColor("INFO") .. L["MINIMAP_TOGGLE"] .. "|r"
    )
    tooltip:AddLine(" ")

    -- GogoLoot Options (Shift + Middle-Click opens the options panel)
    ns:AddTooltipLine(tooltip, L["MINIMAP_OPTIONS"], "TITLE")
    ns:AddTooltipLine(tooltip, L["MINIMAP_OPTIONS_KEYBIND"], "INFO")

    tooltip:Show()
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns:InitMinimap()
    local initialState = ns.db.profile.autoGreed and "on" or "off"

    brokerObject = LibDataBroker:NewDataObject(ADDON_NAME, {
        type = "launcher",
        label = L["ADDON_TITLE"],
        icon = ns.MINIMAP_ICONS[initialState],
        OnClick = function(self, button)
            if button == "MiddleButton" and IsShiftKeyDown() then
                if ns.OpenOptionsPanel then
                    ns:OpenOptionsPanel()
                end
                return
            end
            if button == "LeftButton" then
                ToggleAutoGreed()
            elseif button == "RightButton" then
                ToggleSpeedyLoot()
            end

            -- Re-render the tooltip in place so the status reflects the click
            if GameTooltip:GetOwner() == self then
                ShowTooltip(self)
            end
        end,
        OnEnter = function(self)
            ShowTooltip(self)
        end,
        OnLeave = function(self)
            GameTooltip:Hide()
        end
    })

    LibDBIcon:Register(ADDON_NAME, brokerObject, ns.db.global.minimap)
end