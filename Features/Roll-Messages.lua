--------------------------------------------------------------------------------
-- GogoLoot Roll Messages
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Hide Roll Messages
--------------------------------------------------------------------------------

--[[
    A chat filter only changes what the frames draw, so CHAT_MSG_LOOT still
    reaches every handler, the toasts' roll tracking included. Part of Automated
    Rolls, so it hides nothing while the master switch is off.
]]
---@return boolean
local function HidingRollMessages()
	local profile = ns.db and ns.db.profile
	return profile ~= nil and profile.autoGreed and profile.hideRollMessages or false
end

-- Also what shows the winner summary's Example line on the Automated Rolls panel.
---@return boolean
local function PrintingWinnerSummary()
	return HidingRollMessages() and ns.db.profile.winnerSummary == ns.WINNER_SUMMARY_PRINT
end
ns.PrintingWinnerSummary = PrintingWinnerSummary

local function FilterRollChatter(_, _, message)
	if not HidingRollMessages() then
		return false
	end
	if ns.IsRollChatterMessage(message) then
		return true
	end
	return PrintingWinnerSummary() and ns.ParseRollWonMessage(message) or false
end

-- winnerName is nil when the player won; rollText ("Greed 95") is nil when none was recorded.
---@param winnerName string|nil
---@param itemLink string
---@param rollText string|nil
function ns.OnRollWon(winnerName, itemLink, rollText)
	if not PrintingWinnerSummary() then
		return
	end
	-- In their class color while the roster holds them; plain once it doesn't.
	local classColor = winnerName and ns:GetGroupMemberClassColor(winnerName)
	if classColor then
		winnerName = classColor .. winnerName .. "|r"
	end
	if winnerName and rollText then
		ns:PrintMessage(L["MESSAGE_ROLL_WON_PRINT"]:format(winnerName, itemLink, rollText))
	elseif winnerName then
		ns:PrintMessage(L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"]:format(winnerName, itemLink))
	elseif rollText then
		ns:PrintMessage(L["MESSAGE_ROLL_YOU_WON_PRINT"]:format(itemLink, rollText))
	else
		ns:PrintMessage(L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"]:format(itemLink))
	end
end

local AddMessageEventFilter = (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter) or ChatFrame_AddMessageEventFilter
if AddMessageEventFilter then
	AddMessageEventFilter("CHAT_MSG_LOOT", FilterRollChatter)
end
