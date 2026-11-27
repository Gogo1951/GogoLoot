--------------------------------------------------------------------------------
-- GogoLoot Loot Toasts: Winning Rolls
--------------------------------------------------------------------------------

local _, ns = ...
local L = ns.L

--[[
    Rolls are kept by the roll's own "[Loot]" link (two copies rolled at once
    are two rolls), else by item link, and by player until the won line; the
    winner's roll then waits for their loot line. Anything never claimed (an
    all-pass, a win the loot window kept) ages out.
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
	for rollKey, rolls in pairs(openRolls) do
		if rolls.recordedAt < oldest then
			openRolls[rollKey] = nil
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

---@param message any
---@return boolean
function ns.RecordRollLine(message)
	PruneRolls()
	local playerName, rollKind, roll, itemLink, historyLink = ns.ParseRollResultMessage(message)
	if itemLink then
		local rollKey = historyLink or itemLink
		local rolls = openRolls[rollKey] or {}
		rolls[ns:NormalizePlayerName(playerName) or ""] = { kind = rollKind, roll = roll }
		rolls.recordedAt = GetTime()
		openRolls[rollKey] = rolls
		return true
	end
	local isWon, winnerName, wonItemLink, wonKind, wonRoll, wonHistoryLink = ns.ParseRollWonMessage(message)
	if not isWon then
		return false
	end
	local name = winnerName or ns:GetCleanUnitName("player")
	local wonRollKey = wonHistoryLink or wonItemLink
	if not wonRoll then
		local rolls = openRolls[wonRollKey]
		local record = rolls and rolls[ns:NormalizePlayerName(name) or ""]
		if record then
			wonKind, wonRoll = record.kind, record.roll
		end
	end
	openRolls[wonRollKey] = nil
	local text = RollText(wonKind, wonRoll)
	if text then
		winningRolls[WinnerKey(name, wonItemLink)] = { text = text, recordedAt = GetTime() }
	end
	if ns.OnRollWon then
		ns.OnRollWon(winnerName, wonItemLink, text)
	end
	return true
end

---@param playerName string|nil
---@param itemLink string
---@return string|nil
function ns.ClaimWinningRoll(playerName, itemLink)
	local key = WinnerKey(playerName, itemLink)
	local entry = winningRolls[key]
	winningRolls[key] = nil
	return entry and entry.text
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

-- Roll lines are read whatever the toasts' switch says: Automated Rolls' winner summary needs them too.
local function OnChatMsgLoot(message)
	ns.RecordRollLine(message)
end

ns:RegisterModuleEvent("CHAT_MSG_LOOT", OnChatMsgLoot)
