--------------------------------------------------------------------------------
-- GogoLoot Options — Custom AceGUI Widget: GogoLoot_ItemLink
--
-- A lightweight label that shows the full item tooltip on hover. Used via
-- dialogControl on AceConfig "input" entries; the get() function returns
-- the item ID as a string, and SetText handles lookup + rendering via
-- GogoLoot:GetItemDisplayName (defined in Options.lua).
--------------------------------------------------------------------------------

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