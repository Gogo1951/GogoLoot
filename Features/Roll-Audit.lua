--------------------------------------------------------------------------------
-- GogoLoot Roll Audit
--------------------------------------------------------------------------------
local _, ns = ...

--[[
    Keyed by the roll's own "[Loot]" link, else the item link, so two copies
    rolled at once are two rolls. The group is noted at a roll's first line, so
    a member who never rolled reads No Roll and one who left keeps their class
    color. A roll that never ends (the loot window kept it) ages out.
]]
local OPEN_ROLL_SECONDS = 300

local KIND_ORDER = {
	[ns.ROLL_KIND_NEED] = 1,
	[ns.ROLL_KIND_GREED] = 2,
	[ns.ROLL_KIND_DISENCHANT] = 3,
	PASS = 4,
	NO_ROLL = 5,
}

local openRolls = {}
local finishedRolls = {} -- Oldest first
local lastInstanceID

--------------------------------------------------------------------------------
-- The Group
--------------------------------------------------------------------------------

local function PlayerKey()
	return ns:GetLowercaseUnitName("player") or ""
end

---@param unitIdentifier string
---@param members table
local function NoteMember(unitIdentifier, members)
	local name = ns:GetCleanUnitName(unitIdentifier)
	local key = ns:NormalizePlayerName(name)
	if key then
		local _, classFile = UnitClass(unitIdentifier)
		members[key] = { name = name, classFile = classFile }
	end
end

---@return table
local function GroupMembers()
	local members = {}
	NoteMember("player", members)
	if IsInRaid() then
		for memberIndex = 1, GetNumGroupMembers() do
			NoteMember("raid" .. memberIndex, members)
		end
	else
		for memberIndex = 1, GetNumGroupMembers() - 1 do
			NoteMember("party" .. memberIndex, members)
		end
	end
	return members
end

--------------------------------------------------------------------------------
-- Recording
--------------------------------------------------------------------------------

local function PruneOpenRolls()
	local now = GetTime()
	for key, roll in pairs(openRolls) do
		if now - roll.startedAt > OPEN_ROLL_SECONDS then
			openRolls[key] = nil
		end
	end
end

---@param itemLink string
---@param historyLink string|nil
---@return table
local function OpenRoll(itemLink, historyLink)
	local key = historyLink or itemLink
	local roll = openRolls[key]
	if not roll then
		roll = { itemLink = itemLink, members = GroupMembers(), picks = {}, startedAt = GetTime() }
		openRolls[key] = roll
	end
	return roll
end

---@param roll table
---@param playerName string|nil # nil for the player
---@param kind string
---@param number number|nil
local function NotePick(roll, playerName, kind, number)
	local key = playerName and ns:NormalizePlayerName(playerName) or PlayerKey()
	roll.picks[key] = { kind = kind, roll = number, name = playerName }
end

---@param itemLink string
---@param historyLink string|nil
---@param winnerName string|nil # nil when the player won, or when everyone passed
---@param everyonePassed boolean
---@param wonKind string|nil
---@param wonRoll number|nil
local function FinishRoll(itemLink, historyLink, winnerName, everyonePassed, wonKind, wonRoll)
	local key = historyLink or itemLink
	local roll = openRolls[key] or { itemLink = itemLink, picks = {}, startedAt = GetTime() }
	openRolls[key] = nil
	roll.members = roll.members or GroupMembers()
	if not everyonePassed then
		roll.winner = winnerName and ns:NormalizePlayerName(winnerName) or PlayerKey()
		local pick = roll.picks[roll.winner]
		if wonKind and not pick then
			NotePick(roll, winnerName, wonKind, wonRoll)
		end
	end
	roll.everyonePassed = everyonePassed
	finishedRolls[#finishedRolls + 1] = roll
end

-- True when the line was a roll line Roll Audit reads.
---@param message any
---@return boolean
function ns.RecordRollAuditLine(message)
	PruneOpenRolls()
	local playerName, rollKind, number, itemLink, historyLink = ns.ParseRollResultMessage(message)
	if itemLink then
		local isPlayer = ns:NormalizePlayerName(playerName) == PlayerKey()
		local roll = OpenRoll(itemLink, historyLink)
		roll.printed = true
		NotePick(roll, not isPlayer and playerName or nil, rollKind, number)
		return true
	end
	-- Everyone passed first: the plain pass form would read "Everyone" as a name.
	local allPassedLink, allPassedHistory = ns.ParseRollAllPassedMessage(message)
	if allPassedLink then
		FinishRoll(allPassedLink, allPassedHistory, nil, true)
		return true
	end
	local isPass, passName, passLink, passHistory = ns.ParseRollPassMessage(message)
	if isPass then
		local roll = OpenRoll(passLink, passHistory)
		roll.printed = true
		NotePick(roll, passName, "PASS")
		return true
	end
	local isWon, winnerName, wonLink, wonKind, wonRoll, wonHistory = ns.ParseRollWonMessage(message)
	if isWon then
		local isPlayer = winnerName and ns:NormalizePlayerName(winnerName) == PlayerKey()
		FinishRoll(wonLink, wonHistory, not isPlayer and winnerName or nil, false, wonKind, wonRoll)
		return true
	end
	return false
end

--------------------------------------------------------------------------------
-- Reading
--------------------------------------------------------------------------------

-- A line's kind is an ns.ROLL_KIND_*, "PASS" or "NO_ROLL".
---@param roll table
---@return table[] # Needs highest first, then Greeds, then Pass and No Roll
local function Lines(roll)
	local lines, playerKey = {}, PlayerKey()
	local members = roll.members or {}
	for key, pick in pairs(roll.picks) do
		local member = members[key]
		lines[#lines + 1] = {
			isPlayer = key == playerKey,
			name = pick.name or (member and member.name),
			classFile = member and member.classFile,
			kind = pick.kind,
			roll = pick.roll,
		}
	end
	-- Only a roll whose picks were printed can say who never picked.
	if roll.printed then
		for key, member in pairs(members) do
			if not roll.picks[key] then
				lines[#lines + 1] = {
					isPlayer = key == playerKey,
					name = member.name,
					classFile = member.classFile,
					kind = "NO_ROLL",
				}
			end
		end
	end
	table.sort(lines, function(a, b)
		local orderA, orderB = KIND_ORDER[a.kind] or 6, KIND_ORDER[b.kind] or 6
		if orderA ~= orderB then
			return orderA < orderB
		end
		if (a.roll or -1) ~= (b.roll or -1) then
			return (a.roll or -1) > (b.roll or -1)
		end
		return (a.name or "") < (b.name or "")
	end)
	return lines
end

-- Newest first: { itemLink, everyonePassed, winner = a line or nil, lines }.
---@return table[]
function ns.GetRollAudit()
	local audit = {}
	local playerKey = PlayerKey()
	local _, playerClass = UnitClass("player")
	for index = #finishedRolls, 1, -1 do
		local roll = finishedRolls[index]
		local lines = Lines(roll)
		local winner
		for _, line in ipairs(lines) do
			if line.isPlayer then
				line.classFile = line.classFile or playerClass
			end
			if roll.winner and ns:NormalizePlayerName(line.name) == roll.winner then
				winner = line
			elseif roll.winner == playerKey and line.isPlayer then
				winner = line
			end
		end
		if roll.winner and not winner then
			winner =
				{ isPlayer = roll.winner == playerKey, classFile = roll.winner == playerKey and playerClass or nil }
		end
		audit[#audit + 1] = {
			itemLink = roll.itemLink,
			everyonePassed = roll.everyonePassed,
			winner = winner,
			lines = lines,
		}
	end
	return audit
end

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

local function OnChatMsgLoot(message)
	ns.RecordRollAuditLine(message)
end

-- Only a different instance starts the list over, so a corpse run keeps it.
local function OnPlayerEnteringWorld()
	local _, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()
	if instanceType == "none" or instanceID == nil then
		return
	end
	if instanceID ~= lastInstanceID then
		openRolls = {}
		finishedRolls = {}
	end
	lastInstanceID = instanceID
end

ns:RegisterModuleEvent("CHAT_MSG_LOOT", OnChatMsgLoot)
ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
