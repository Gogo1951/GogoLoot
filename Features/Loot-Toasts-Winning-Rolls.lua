--------------------------------------------------------------------------------
-- GogoLoot Loot Toasts: Winning Rolls
--------------------------------------------------------------------------------

--[[
    The roll each item was won with, read off the game's roll lines and handed
    to the winner's loot toast (Features/Loot-Toasts.lua), which owns the
    CHAT_MSG_LOOT handler that feeds ns.RecordRollLine and asks
    ns.ClaimWinningRoll.
]]
local _, ns = ...
local L = ns.L

--[[
    Winning rolls, carried from the roll lines to the loot line that follows,
    and handed as each won line lands to ns.OnRollWon when something defines it
    (Automated Rolls' winner summary).
    While a roll is open the client prints each player's roll, then who won,
    then the winner's loot line; with its roll spam turned down, only a won line
    that carries the winning roll, then the loot line. Rolls are kept by item
    link and player until the won line names the winner, whose roll then waits
    for that player's loot line. Anything a loot line never claims (a roll the
    whole group passed, a win the loot window kept) ages out, so nothing
    collects over a long session.
]]
local ROLL_RECORD_SECONDS = 300

local ROLL_WORDS = {
	[ns.ROLL_KIND_NEED] = NEED,
	[ns.ROLL_KIND_GREED] = GREED,
	[ns.ROLL_KIND_DISENCHANT] = ROLL_DISENCHANT,
}

local openRolls = {}
local winningRolls = {}

local function WinnerKey(playerName, itemLink)
	return (ns:NormalizePlayerName(playerName) or "") .. "\n" .. itemLink
end

local function PruneRolls()
	local oldest = GetTime() - ROLL_RECORD_SECONDS
	for itemLink, rolls in pairs(openRolls) do
		if rolls.recordedAt < oldest then
			openRolls[itemLink] = nil
		end
	end
	for key, entry in pairs(winningRolls) do
		if entry.recordedAt < oldest then
			winningRolls[key] = nil
		end
	end
end

---@param rollKind string|nil
---@param roll number|nil
---@return string|nil
local function RollText(rollKind, roll)
	local word = rollKind and ROLL_WORDS[rollKind]
	if not word or not roll then
		return nil
	end
	return L["LOOT_TOASTS_ROLL_RESULT"]:format(word, roll)
end

-- True when the line was a roll line, which is never a loot line too.
---@param message any
---@return boolean
function ns.RecordRollLine(message)
	PruneRolls()
	local playerName, rollKind, roll, itemLink = ns.ParseRollResultMessage(message)
	if itemLink then
		local rolls = openRolls[itemLink] or {}
		rolls[ns:NormalizePlayerName(playerName) or ""] = { kind = rollKind, roll = roll }
		rolls.recordedAt = GetTime()
		openRolls[itemLink] = rolls
		return true
	end
	local isWon, winnerName, wonItemLink, wonKind, wonRoll = ns.ParseRollWonMessage(message)
	if not isWon then
		return false
	end
	local name = winnerName or ns:GetCleanUnitName("player")
	if not wonRoll then
		local rolls = openRolls[wonItemLink]
		local record = rolls and rolls[ns:NormalizePlayerName(name) or ""]
		if record then
			wonKind, wonRoll = record.kind, record.roll
		end
	end
	openRolls[wonItemLink] = nil
	local text = RollText(wonKind, wonRoll)
	if text then
		winningRolls[WinnerKey(name, wonItemLink)] = { text = text, recordedAt = GetTime() }
	end
	if ns.OnRollWon then
		ns.OnRollWon(winnerName, wonItemLink, text)
	end
	return true
end

--[[
    The roll an item was won with, as a toast shows it, taken once by the winner's
    loot line; nil when no roll was recorded for that player and item.
]]
---@param playerName string|nil
---@param itemLink string
---@return string|nil
function ns.ClaimWinningRoll(playerName, itemLink)
	local key = WinnerKey(playerName, itemLink)
	local entry = winningRolls[key]
	winningRolls[key] = nil
	return entry and entry.text
end
