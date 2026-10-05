--------------------------------------------------------------------------------
-- GogoLoot Roll Messages
--------------------------------------------------------------------------------
local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Hide Roll Messages
--------------------------------------------------------------------------------

--[[
    Keeps the game's per-roll lines out of every chat frame: who picked Need,
    Greed or Pass, and each number rolled (ns.IsRollChatterMessage). What each
    winner received still prints. Who won prints too: as the game's own line,
    or, with the dropdown beside the toggle on Print Winner Summary, as
    GogoLoot's one line naming the winner, the item and the winning roll, which
    stands in for the game's.
    A chat filter only changes what the frames draw, so CHAT_MSG_LOOT still
    reaches every handler, the toasts' roll tracking included. It is part of
    Automated Rolls, so it hides nothing while the master switch is off, and
    the saved choice waits for the switch to come back on.
]]
---@return boolean
local function HidingRollMessages()
	local profile = ns.db and ns.db.profile
	return profile ~= nil and profile.autoGreed and profile.hideRollMessages or false
end

---@return boolean
local function PrintingWinnerSummary()
	return HidingRollMessages() and ns.db.profile.winnerSummary == ns.WINNER_SUMMARY_PRINT
end

local function FilterRollChatter(_, _, message)
	if not HidingRollMessages() then
		return false
	end
	if ns.IsRollChatterMessage(message) then
		return true
	end
	return PrintingWinnerSummary() and ns.ParseRollWonMessage(message) or false
end

--[[
    The winner summary, from the winning-roll tracking the loot toasts use
    (Loot-Toasts-Winning-Rolls.lua), which reads the game's roll lines whether
    or not they are drawn. winnerName is nil when the player won; rollText is
    the roll as the toasts show it ("Greed 95"), nil when none was recorded.
]]
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

ChatFrameUtil.AddMessageEventFilter("CHAT_MSG_LOOT", FilterRollChatter)
