--------------------------------------------------------------------------------
-- GogoLoot Trade Window Checkbox
--------------------------------------------------------------------------------

--[[
    Mirrors the "Enable Trade Announcements" toggle beside the trade window. It
    is parented to UIParent and only anchored to TradeFrame, so nothing is
    written to Blizzard's panel; it shows while a trade is open and leaves with
    TRADE_CLOSED. The summary itself is Features/Announcements-Trade.lua's.
]]
local _, ns = ...
local L = ns.L

local tradeAnnounceCheckbox = nil
local tradeWindowOpen = false

---@param tooltip table
---@param leftText any
---@param rightText any
---@param leftColorKey string|nil
---@param rightColorKey string|nil
---@return nil
local function AddTooltipDoubleLine(tooltip, leftText, rightText, leftColorKey, rightColorKey)
	local leftRed, leftGreen, leftBlue = ns.GetColorRGB(leftColorKey or "TEXT")
	local rightRed, rightGreen, rightBlue = ns.GetColorRGB(rightColorKey or "TEXT")
	tooltip:AddDoubleLine(leftText, rightText, leftRed, leftGreen, leftBlue, rightRed, rightGreen, rightBlue)
end

local function CreateTradeAnnounceCheckbox()
	if tradeAnnounceCheckbox then
		return
	end
	if not TradeFrame then
		return
	end

	local checkbox = CreateFrame("CheckButton", "GogoLootTradeAnnounceCheckbox", UIParent, "UICheckButtonTemplate")
	checkbox:Hide()
	checkbox:SetSize(32, 32)
	checkbox:SetPoint("BOTTOMLEFT", TradeFrame, "BOTTOMLEFT", 8, 4)

	local label = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
	label:SetText(L["TRADE_CHECKBOX_LABEL"])

	checkbox:SetScript("OnClick", function(self)
		ns.db.profile.announceTrade = self:GetChecked() and true or false
		ns.RefreshSettings()
	end)

	checkbox:SetScript("OnEnter", function(self)
		local currentOutput = ns.TRADE_OUTPUT_LABELS[ns.db.profile.announceTradeOutput] or WHISPER
		local currentCondition = ns.TRADE_CONDITION_LABELS[ns.db.profile.announceTradeCondition]
			or ns.TRADE_CONDITION_LABELS.always

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		ns:AddTooltipLine(GameTooltip, L["ADDON_SHORT_NAME"], "TITLE")
		GameTooltip:AddLine(" ")
		ns:AddTooltipLine(GameTooltip, L["TAB_TRADE_ANNOUNCEMENTS"], "TITLE")
		ns:AddTooltipLine(GameTooltip, L["TRADE_TOOLTIP_DESCRIPTION"], "BODY", true)
		GameTooltip:AddLine(" ")
		-- When comes first: a ticked box under When in Raid stays silent in a party, and this says why.
		AddTooltipDoubleLine(GameTooltip, L["TRADE_WHEN"], currentCondition, "BODY", "TEXT")
		AddTooltipDoubleLine(GameTooltip, L["TRADE_CHANNEL"], currentOutput, "BODY", "TEXT")
		GameTooltip:Show()
	end)

	checkbox:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	tradeAnnounceCheckbox = checkbox
end

--[[
    The checkbox leaves the trade window while Enable Announcements is off:
    the master switch silences trades too, so a ticked box there would promise a
    summary that never goes out.
]]
---@return nil
function ns:SyncTradeCheckbox()
	if not tradeAnnounceCheckbox then
		return
	end
	if tradeWindowOpen and ns.db.profile.lootNotifications then
		-- Drawn just above the trade window, whose level can change while it is open.
		tradeAnnounceCheckbox:SetFrameStrata(TradeFrame:GetFrameStrata())
		tradeAnnounceCheckbox:SetFrameLevel(TradeFrame:GetFrameLevel() + 10)
		tradeAnnounceCheckbox:Show()
	else
		tradeAnnounceCheckbox:Hide()
	end
	tradeAnnounceCheckbox:SetChecked(ns.db.profile.announceTrade)
end

local function OnTradeShow()
	tradeWindowOpen = true
	CreateTradeAnnounceCheckbox()
	ns:SyncTradeCheckbox()
end

local function OnTradeClosed()
	tradeWindowOpen = false
	ns:SyncTradeCheckbox()
end

ns:RegisterModuleEvent("TRADE_SHOW", OnTradeShow)
ns:RegisterModuleEvent("TRADE_CLOSED", OnTradeClosed)
