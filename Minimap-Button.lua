--------------------------------------------------------------------------------
-- GogoLoot Minimap Button
--------------------------------------------------------------------------------
local ADDON_NAME = "GogoLoot"
local L = GogoLoot.L
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")
local ACR = LibStub("AceConfigRegistry-3.0")

local brokerObj

--------------------------------------------------------------------------------
-- Icon State
-- The minimap icon reflects the Auto-Greed toggle: on/off swap. Called from
-- the click handler here and from the matching Options toggle so the icon
-- stays in sync no matter where the user flips it.
--------------------------------------------------------------------------------

function GogoLoot:UpdateMinimapIcon()
    if not brokerObj then
        return
    end

    local state = GogoLootDB.autoGreed and "on" or "off"
    brokerObj.icon = GogoLoot.MINIMAP_ICONS[state] or GogoLoot.MINIMAP_ICONS.off

    if GogoLootDB.minimap then
        LDBIcon:Refresh(ADDON_NAME, GogoLootDB.minimap)
    end
end

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

local function GetStatusText(isEnabled)
    if isEnabled then
        return GogoLoot:GetColor("SUCCESS") .. L["STATUS_ENABLED"] .. "|r"
    end
    return GogoLoot:GetColor("DISABLED") .. L["STATUS_DISABLED"] .. "|r"
end

--------------------------------------------------------------------------------
-- Click Handlers
--------------------------------------------------------------------------------

local function ToggleAutoGreed()
    GogoLootDB.autoGreed = not GogoLootDB.autoGreed
    GogoLoot:UpdateMinimapIcon()
    ACR:NotifyChange("GogoLoot_AutomaticRolls")
end

local function ToggleSpeedyLoot()
    GogoLootDB.speedyLoot = not GogoLootDB.speedyLoot
    ACR:NotifyChange("GogoLoot")
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
        GogoLoot:GetColor("TITLE") .. L["ADDON_TITLE"] .. "|r",
        GogoLoot:GetColor("MUTED") .. GogoLoot.Version .. "|r"
    )
    tooltip:AddLine(" ")
    tooltip:AddLine(" ")

    -- Auto-Greed
    tooltip:AddDoubleLine(
        GogoLoot:GetColor("TITLE") .. L["MINIMAP_AUTO_GREED"] .. "|r",
        GetStatusText(GogoLootDB.autoGreed)
    )
    GogoLoot:AddTooltipLine(tooltip, L["MINIMAP_AUTO_GREED_DESC"], "DESC", true)
    tooltip:AddDoubleLine(
        GogoLoot:GetColor("INFO") .. L["MINIMAP_LEFT_CLICK"] .. "|r",
        GogoLoot:GetColor("INFO") .. L["MINIMAP_TOGGLE"] .. "|r"
    )
    tooltip:AddLine(" ")

    -- Speedy Loot
    tooltip:AddDoubleLine(
        GogoLoot:GetColor("TITLE") .. L["MINIMAP_SPEEDY_LOOT"] .. "|r",
        GetStatusText(GogoLootDB.speedyLoot)
    )
    GogoLoot:AddTooltipLine(tooltip, L["MINIMAP_SPEEDY_LOOT_DESC"], "DESC", true)
    tooltip:AddDoubleLine(
        GogoLoot:GetColor("INFO") .. L["MINIMAP_RIGHT_CLICK"] .. "|r",
        GogoLoot:GetColor("INFO") .. L["MINIMAP_TOGGLE"] .. "|r"
    )
    tooltip:AddLine(" ")

    -- Hint
    GogoLoot:AddTooltipLine(tooltip, L["MINIMAP_HINT"], "DESC", true)

    tooltip:Show()
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function GogoLoot:InitMinimap()
    local initialState = GogoLootDB.autoGreed and "on" or "off"

    brokerObj = LDB:NewDataObject(ADDON_NAME, {
        type = "launcher",
        label = L["ADDON_TITLE"],
        icon = GogoLoot.MINIMAP_ICONS[initialState],
        OnClick = function(self, button)
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

    LDBIcon:Register(ADDON_NAME, brokerObj, GogoLootDB.minimap)
end