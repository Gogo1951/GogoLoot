--------------------------------------------------------------------------------
-- GogoLoot Roll Calls
--------------------------------------------------------------------------------

--[[
    The roll engine behind the Loot Master and the Loot Tracker: one roll at a
    time, called by the player or by someone else in the group, with every
    /roll result checked against the same rules and kept, counted or not, with
    the reason.

    The rules: a plain /roll (1-100), each player's first roll of the round,
    from a group member, while the roll is open plus ns.ROLL_GRACE_SECONDS for
    lag. Rolls just before the call or just after the close show as not
    counted, so the raid sees why. A tie-break round only counts the tied
    players.

    A roll the player calls (session.isMine) is announced to the group and sent
    to the other GogoLoot users as add-on messages, so their Loot Trackers
    follow the loot master's rulings: disqualifications, tie-breaks, pauses and
    the winner. A roll called by someone without GogoLoot is spotted from the
    raid warning or group line that carries the item, and checked here by the
    same rules, with the caller keeping the final say.

    Only CHAT_MSG_SYSTEM is trusted for a roll: anyone can type "Aero rolls
    100 (1-100)" in normal chat. The line is read through the client's own
    RANDOM_ROLL_RESULT, so every locale works.
]]
local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

-- The roll in progress, or the last one, finished, until the next starts. Nil before any.
ns.currentRoll = nil
-- Finished rolls, newest first, for the Loot Tracker's Earlier tonight.
ns.rollHistory = {}

local rollsById = {}
local sessionCounter = 0

--------------------------------------------------------------------------------
-- Change Notification
--------------------------------------------------------------------------------

-- The two windows repaint through here; they define ns.RefreshLootWindows once they load.
local function Changed()
	if ns.RefreshLootWindows then
		ns.RefreshLootWindows()
	end
end

--------------------------------------------------------------------------------
-- Secret Values
--------------------------------------------------------------------------------

--[[
    WoW Forever can hand an add-on system chat as a secret value inside a
    dungeon or raid, as Retail does, and a secret string can't be matched.
    issecretvalue exists only where secrets do.
]]
local IsSecretValue = issecretvalue or function()
	return false
end

--------------------------------------------------------------------------------
-- Reading /roll
--------------------------------------------------------------------------------

local rollPattern, rollArgumentOrder = ns.BuildFormatPattern(RANDOM_ROLL_RESULT)
if rollPattern then
	rollPattern = "^" .. rollPattern .. "$"
end

--[[
    Who rolled, what they got, and the range they rolled in, from a
    CHAT_MSG_SYSTEM line; nil for any other line. The arguments are read in the
    format's own order, whatever order the translation prints them in.
]]
---@param message any
---@return string|nil playerName
---@return number|nil roll
---@return number|nil low
---@return number|nil high
function ns.ParseRandomRollMessage(message)
	if not rollPattern or type(message) ~= "string" or IsSecretValue(message) then
		return nil
	end
	if not string.find(message, rollPattern) then
		return nil
	end
	local captures = { string.match(message, rollPattern) }
	local byArgument = {}
	for index, argument in ipairs(rollArgumentOrder) do
		byArgument[argument] = captures[index]
	end
	local roll, low, high = tonumber(byArgument[2]), tonumber(byArgument[3]), tonumber(byArgument[4])
	if not byArgument[1] or not roll then
		return nil
	end
	return byArgument[1], roll, low, high
end

--------------------------------------------------------------------------------
-- Group Roster
--------------------------------------------------------------------------------

--[[
    Everyone who may roll, by the name key every comparison uses
    (ns:NormalizePlayerName), each with the name to show and the class to color
    it. The player is always in it, so a roll can be tried alone.
]]
---@return table # [nameKey] = { name, classFile }
function ns:GetRollRoster()
	local roster = {}
	local function AddUnit(unitIdentifier)
		local name = ns:GetCleanUnitName(unitIdentifier)
		local key = ns:NormalizePlayerName(name)
		if key then
			local _, classFile = UnitClass(unitIdentifier)
			roster[key] = { name = name, classFile = classFile }
		end
	end
	AddUnit("player")
	if IsInRaid() then
		for memberIndex = 1, GetNumGroupMembers() do
			AddUnit("raid" .. memberIndex)
		end
	elseif IsInGroup() then
		for memberIndex = 1, GetNumGroupMembers() - 1 do
			AddUnit("party" .. memberIndex)
		end
	end
	return roster
end

-- A name in its class color while the roster holds them, plain otherwise. For prints and windows, never sent chat.
---@param name string
---@param roster? table
---@return string
function ns:ColorRollName(name, roster)
	local member = (roster or ns:GetRollRoster())[ns:NormalizePlayerName(name) or ""]
	local color = member and ns.GetClassColor(member.classFile)
	return color and (color .. name .. "|r") or name
end

--------------------------------------------------------------------------------
-- Sending
--------------------------------------------------------------------------------

--[[
    Roll calls go out whatever Enable Announcements says: calling for rolls is
    what the Loot Master is for, so a switch meant to quiet trade summaries
    must not leave a raid waiting on a call that never came. Outside a group
    there is nobody to tell, so the line is printed instead, as a preview, and
    the whole flow can be tried alone.
]]
---@param channel string|nil
---@param message string|nil
---@return nil
local function SendLine(channel, message)
	if not message then
		return
	end
	if not channel then
		ns:PrintMessage(L["ROLL_CALL_SOLO_PREVIEW"]:format(message))
		return
	end
	C_ChatInfo.SendChatMessage(message, channel)
end

---@param channel string|nil
---@param formatKey string
---@param ... any
---@return nil
local function Send(channel, formatKey, ...)
	SendLine(channel, ns:BuildAnnounceMessage(formatKey, ...))
end

--[[
    A list (rolls that don't count, items up for roll, a boss's drops) packed
    into as few lines as fit the chat limit, split only between parts so no
    link is cut, the way ns:AnnounceParts does it for the trade summary.
    formatArguments(joinedParts) returns the template's arguments in order.
]]
---@param channel string|nil
---@param formatKey string
---@param parts string[]
---@param formatArguments function
---@return nil
function ns:SendRollParts(channel, formatKey, parts, formatArguments)
	local startIndex = 1
	while startIndex <= #parts do
		local endIndex = startIndex
		while endIndex < #parts do
			local candidate =
				ns:BuildAnnounceMessage(formatKey, formatArguments(table.concat(parts, ", ", startIndex, endIndex + 1)))
			if not candidate or #candidate > ns.CHAT_MESSAGE_MAX_LENGTH then
				break
			end
			endIndex = endIndex + 1
		end
		Send(channel, formatKey, formatArguments(table.concat(parts, ", ", startIndex, endIndex)))
		startIndex = endIndex + 1
	end
end

-- Where results go: the group's own chat.
---@return string|nil
function ns:GetRollResultChannel()
	return ns:GetGroupChatChannel()
end

--[[
    Where calls, ties and pauses go: Raid Warning when the panel says so and
    the player may send one (leader or assistant in a raid), the group's chat
    otherwise.
]]
---@return string|nil
function ns:GetRollCallChannel()
	local groupChannel = ns:GetGroupChatChannel()
	if
		groupChannel == "RAID"
		and ns.db.profile.rollChannel == ns.ROLL_CHANNEL_RAID_WARNING
		and (UnitIsGroupLeader("player") or (UnitIsGroupAssistant and UnitIsGroupAssistant("player")))
	then
		return "RAID_WARNING"
	end
	return groupChannel
end

--------------------------------------------------------------------------------
-- Add-on Messages
--------------------------------------------------------------------------------

local FIELD_SEPARATOR = "\t"

---@param ... any
---@return nil
local function Broadcast(...)
	local channel = ns:GetGroupChatChannel()
	if not channel or not C_ChatInfo.SendAddonMessage then
		return
	end
	local fields = { ... }
	for index, field in ipairs(fields) do
		fields[index] = tostring(field)
	end
	local message = table.concat(fields, FIELD_SEPARATOR)
	-- Add-on messages are cut at 255 bytes without a word; a message that can't fit is better unsent than wrong.
	if #message <= ns.CHAT_MESSAGE_MAX_LENGTH then
		C_ChatInfo.SendAddonMessage(ns.ADDON_MESSAGE_PREFIX, message, channel)
	end
end
ns.BroadcastLootMessage = Broadcast

local function OnPlayerLogin()
	if C_ChatInfo.RegisterAddonMessagePrefix then
		C_ChatInfo.RegisterAddonMessagePrefix(ns.ADDON_MESSAGE_PREFIX)
	end
end

ns:RegisterModuleEvent("PLAYER_LOGIN", OnPlayerLogin)

--------------------------------------------------------------------------------
-- Sessions
--------------------------------------------------------------------------------

---@param session table
---@return number
local function SecondsLeft(session)
	if session.pausedLeft then
		return session.pausedLeft
	end
	return math.max(0, session.endsAt - GetTime())
end
ns.GetRollSecondsLeft = SecondsLeft

---@param session table
---@param roll table
---@return boolean
local function CountsInRound(session, roll)
	return roll.round == session.round and not roll.reject
end

--[[
    A new session. `fields` carries the item, who called it, and for one
    called elsewhere, the id the caller gave it and whether it came with
    add-on messages (synced) or was spotted in chat.
]]
---@param fields table
---@return table
local function NewSession(fields)
	sessionCounter = sessionCounter + 1
	local playerKey = ns:NormalizePlayerName(ns:GetCleanUnitName("player")) or "?"
	local session = {
		-- The caller's id travels with every add-on message, so it only has to be unique to the caller.
		id = fields.id or (playerKey .. ":" .. sessionCounter .. ":" .. math.floor(GetTime())),
		itemLink = fields.itemLink,
		entryKey = fields.entryKey,
		caller = fields.caller,
		isMine = fields.isMine or false,
		synced = fields.synced or false,
		round = 1,
		eligible = nil,
		length = fields.length,
		startedAt = GetTime(),
		endsAt = GetTime() + fields.length,
		open = true,
		status = ns.ENTRY_ROLLING,
		rolls = {},
		passes = {},
		warned = false,
		lateUntil = nil,
	}
	rollsById[session.id] = session
	return session
end

---@param session table
---@return nil
local function KeepInHistory(session)
	for _, kept in ipairs(ns.rollHistory) do
		if kept == session then
			return
		end
	end
	table.insert(ns.rollHistory, 1, session)
	while #ns.rollHistory > ns.ROLL_HISTORY_LIMIT do
		local dropped = table.remove(ns.rollHistory)
		rollsById[dropped.id] = nil
	end
end

---@param id string
---@return table|nil
function ns:GetRollSession(id)
	return id and rollsById[id]
end

---@return boolean
function ns:IsRollOpen()
	return ns.currentRoll ~= nil and ns.currentRoll.open
end

--[[
    Whether a roll of the player's own is open. A roll the player is only
    following never stops them calling one: their call wins, and the one they
    were following is put away (StopFollowing).
]]
---@return boolean
function ns:IsOwnRollOpen()
	return ns:IsRollOpen() and ns.currentRoll.isMine
end

--------------------------------------------------------------------------------
-- Counting a Roll
--------------------------------------------------------------------------------

--[[
    Recent rolls from group members, kept a few seconds so a roll made just
    before the call can show in the list as early rather than vanish.
]]
local recentRolls = {}

---@param session table
---@param roll table
---@return string|nil
local function RejectionFor(session, roll)
	if session.eligible and not session.eligible[roll.key] then
		return ns.ROLL_REJECT_NOT_TIED
	end
	if roll.low ~= ns.ROLL_LOW or roll.high ~= ns.ROLL_HIGH then
		return ns.ROLL_REJECT_RANGE
	end
	for _, earlier in ipairs(session.rolls) do
		if earlier.key == roll.key and CountsInRound(session, earlier) then
			return ns.ROLL_REJECT_REPEAT
		end
	end
	return nil
end

---@param session table
---@param roll table
---@return nil
local function AddRoll(session, roll)
	roll.round = session.round
	roll.order = #session.rolls + 1
	roll.reject = roll.reject or RejectionFor(session, roll)
	-- A player who passed and then rolls is rolling after all.
	session.passes[roll.key] = nil
	table.insert(session.rolls, roll)
end

---@param session table
---@return boolean
local function EveryoneHasAnswered(session)
	local roster = ns:GetRollRoster()
	-- The caller isn't waited on, calling the roll being their part, unless they're in its tie-break.
	local callerKey = not session.eligible and ns:NormalizePlayerName(session.caller)
	for key in pairs(session.eligible or roster) do
		if roster[key] and key ~= callerKey and not session.passes[key] then
			local answered = false
			for _, roll in ipairs(session.rolls) do
				if roll.key == key and CountsInRound(session, roll) then
					answered = true
					break
				end
			end
			if not answered then
				return false
			end
		end
	end
	return true
end

--------------------------------------------------------------------------------
-- Results
--------------------------------------------------------------------------------

-- The counted rolls of the session's round, highest first.
---@param session table
---@return table[]
function ns:GetCountedRolls(session)
	local counted = {}
	for _, roll in ipairs(session.rolls) do
		if CountsInRound(session, roll) then
			counted[#counted + 1] = roll
		end
	end
	table.sort(counted, function(a, b)
		if a.value ~= b.value then
			return a.value > b.value
		end
		return a.order < b.order
	end)
	return counted
end

-- How a roll that doesn't count reads in the "Not counted" line.
---@param roll table
---@return string
local function NotCountedPart(roll)
	if roll.reject == ns.ROLL_REJECT_EARLY then
		return L["ROLL_CALL_NOT_COUNTED_EARLY"]:format(roll.name, roll.value)
	elseif roll.reject == ns.ROLL_REJECT_RANGE then
		return L["ROLL_CALL_NOT_COUNTED_RANGE"]:format(roll.name, roll.value, roll.low, roll.high)
	elseif roll.reject == ns.ROLL_REJECT_NOT_TIED then
		return L["ROLL_CALL_NOT_COUNTED_NOT_TIED"]:format(roll.name, roll.value)
	end
	return L["ROLL_CALL_NOT_COUNTED_REPEAT"]:format(roll.name, roll.value)
end

---@param names string[]
---@return string
local function JoinNames(names)
	return table.concat(names, ", ")
end

local StartTieBreak, StartTicker, StopFollowing

---@param session table
---@return nil
local function Finish(session)
	session.open = false
	KeepInHistory(session)
	if ns.OnRollFinished then
		ns.OnRollFinished(session)
	end
	Changed()
end

--[[
    Decides the roll from the counted rolls of its round: nobody, a tie, or a
    winner. `changed` is a call after a disqualification or a restore moved a
    roll that already had a result, which the announcement words as a change.
]]
---@param session table
---@param changed boolean
---@return nil
local function Resolve(session, changed)
	local counted = ns:GetCountedRolls(session)
	local previousWinner = session.winner and session.winner.key

	if #counted == 0 then
		session.status = ns.ENTRY_NOBODY
		session.winner = nil
		if session.isMine then
			Send(ns:GetRollResultChannel(), changed and "ROLL_CALL_NOBODY_LEFT" or "ROLL_CALL_NOBODY", session.itemLink)
			Broadcast("END", session.id, "", "")
		end
		Finish(session)
		return
	end

	local top = counted[1].value
	local tied = {}
	for _, roll in ipairs(counted) do
		if roll.value == top then
			tied[#tied + 1] = roll
		end
	end

	if #tied > 1 then
		session.winner = nil
		-- A tie that turns up while another roll is open waits for the loot master's Re-roll Tied instead.
		local otherRollOpen = ns:IsOwnRollOpen() and ns.currentRoll ~= session
		if session.isMine and ns.db.profile.rollRerollTies and not otherRollOpen then
			StopFollowing()
			ns.currentRoll = session
			StartTieBreak(session, tied)
			StartTicker()
			return
		end
		session.status = ns.ENTRY_TIED
		session.tied = tied
		if session.isMine then
			local names = {}
			for _, roll in ipairs(tied) do
				names[#names + 1] = roll.name
			end
			Send(ns:GetRollResultChannel(), "ROLL_CALL_TIE_HELD", JoinNames(names), top, session.itemLink)
			Broadcast("END", session.id, "", "")
		end
		Finish(session)
		return
	end

	local winner = counted[1]
	session.status = ns.ENTRY_WON
	session.winner = winner
	if session.isMine then
		local isChange = changed and previousWinner ~= winner.key
		Send(
			ns:GetRollResultChannel(),
			isChange and "ROLL_CALL_NOW_WINS" or "ROLL_CALL_WINS",
			winner.name,
			session.itemLink,
			winner.value
		)
		if not changed or isChange then
			ns:PrintMessage(L["ROLL_CALL_WON_PRINT"]:format(ns:ColorRollName(winner.name), session.itemLink))
		end
		Broadcast("END", session.id, winner.name, winner.value)
	end
	Finish(session)
end

---@param session table
---@param tied table[]
---@return nil
StartTieBreak = function(session, tied)
	local names, eligible = {}, {}
	for _, roll in ipairs(tied) do
		names[#names + 1] = roll.name
		eligible[roll.key] = true
	end
	session.round = session.round + 1
	session.eligible = eligible
	session.tied = nil
	session.open = true
	session.status = ns.ENTRY_ROLLING
	session.warned = false
	session.pausedLeft = nil
	session.endsAt = GetTime() + session.length
	if session.isMine then
		Send(
			ns:GetRollCallChannel(),
			"ROLL_CALL_TIE",
			JoinNames(names),
			tied[1].value,
			session.itemLink,
			JoinNames(names),
			session.length
		)
		Broadcast("START", session.id, session.round, session.length, table.concat(names, ","), session.itemLink)
	end
	Changed()
end

---@param session table
---@return nil
local function Close(session)
	if not session.open then
		return
	end
	session.open = false
	session.lateUntil = GetTime() + ns.ROLL_LATE_SECONDS
	if session.isMine and ns.db.profile.rollAnnounceNotCounted then
		local parts = {}
		for _, roll in ipairs(session.rolls) do
			if
				roll.round == session.round
				and roll.reject
				and roll.reject ~= ns.ROLL_REJECT_MANUAL
				and not roll.told
			then
				roll.told = true
				parts[#parts + 1] = NotCountedPart(roll)
			end
		end
		if #parts > 0 then
			ns:SendRollParts(ns:GetRollResultChannel(), "ROLL_CALL_NOT_COUNTED", parts, function(list)
				return session.itemLink, list
			end)
		end
	end
	Resolve(session, false)
end

--------------------------------------------------------------------------------
-- Ticking
--------------------------------------------------------------------------------

--[[
    One ticker runs while a roll is open, and stops with it. A roll called
    elsewhere is closed a little after its time, so the caller's own result,
    which arrives as an add-on message, can land first.
]]
local ticker

local function StopTicker()
	if ticker then
		ticker:Cancel()
		ticker = nil
	end
end

local function Tick()
	local session = ns.currentRoll
	if not session or not session.open then
		StopTicker()
		return
	end
	if not session.isMine then
		--[[
		    A followed roll whose caller left the group, or that stayed on pause
		    far longer than it ran, will never hear its result: it is decided here.
		]]
		local callerGone = session.synced and not ns:GetRollRoster()[ns:NormalizePlayerName(session.caller) or ""]
		local stuck = session.pausedLeft and GetTime() > (session.pausedAt or GetTime()) + session.length * 3
		if callerGone or stuck then
			session.pausedLeft = nil
			Close(session)
			return
		end
	end
	if session.pausedLeft then
		return
	end
	local left = SecondsLeft(session)
	if session.isMine then
		if
			ns.db.profile.rollWarnLastSeconds
			and not session.warned
			and left <= ns.ROLL_WARNING_SECONDS
			and session.length > ns.ROLL_WARNING_SECONDS
		then
			session.warned = true
			Send(ns:GetRollResultChannel(), "ROLL_CALL_LAST_SECONDS", ns.ROLL_WARNING_SECONDS, session.itemLink)
		end
		if ns.db.profile.rollEndWhenAllRolled and EveryoneHasAnswered(session) then
			Close(session)
			return
		end
		if GetTime() >= session.endsAt + ns.ROLL_GRACE_SECONDS then
			Close(session)
		end
		return
	end
	-- Someone else's roll: wait a moment past the grace for their result before deciding it here.
	if GetTime() >= session.endsAt + ns.ROLL_GRACE_SECONDS + 2 then
		Close(session)
	end
end

---@return nil
StartTicker = function()
	if not ticker then
		ticker = C_Timer.NewTicker(ns.ROLL_TICK_SECONDS, Tick)
	end
end

--------------------------------------------------------------------------------
-- Starting a Roll
--------------------------------------------------------------------------------

---@param session table
---@return nil
local function TakeEarlyRolls(session)
	local cutoff = GetTime() - ns.ROLL_EARLY_SECONDS
	for _, recent in ipairs(recentRolls) do
		if recent.at >= cutoff then
			AddRoll(session, {
				name = recent.name,
				key = recent.key,
				value = recent.value,
				low = recent.low,
				high = recent.high,
				reject = ns.ROLL_REJECT_EARLY,
			})
		end
	end
	wipe(recentRolls)
end

-- Puts away a roll the player was only following, so a call of their own can start.
StopFollowing = function()
	local followed = ns.currentRoll
	if followed and followed.open and not followed.isMine then
		followed.open = false
		followed.lateUntil = nil
		KeepInHistory(followed)
	end
end

---@param session table
---@return nil
local function Begin(session)
	local previous = ns.currentRoll
	if previous and previous ~= session and not previous.open then
		KeepInHistory(previous)
	end
	ns.currentRoll = session
	TakeEarlyRolls(session)
	StartTicker()
	if ns.OnRollStarted then
		ns.OnRollStarted(session)
	end
	Changed()
end

--[[
    Calls for rolls on an item. Returns the session, or nil when a roll is
    already open: one at a time, so nobody's /roll can land on the wrong item.
]]
---@param itemLink string
---@param entryKey? string # the Roll List entry it belongs to
---@return table|nil
function ns:StartRoll(itemLink, entryKey)
	if ns:IsOwnRollOpen() then
		return nil
	end
	StopFollowing()
	local length = ns.db.profile.rollLength
	local session = NewSession({
		itemLink = itemLink,
		entryKey = entryKey,
		caller = ns:GetCleanUnitName("player"),
		isMine = true,
		synced = true,
		length = length,
	})
	Send(ns:GetRollCallChannel(), "ROLL_CALL_START", itemLink, length)
	Broadcast("START", session.id, 1, length, "", itemLink)
	Begin(session)
	return session
end

--------------------------------------------------------------------------------
-- The Loot Master's Controls
--------------------------------------------------------------------------------

---@param session table
---@return nil
function ns:ExtendRoll(session)
	if not session.open or not session.isMine then
		return
	end
	if session.pausedLeft then
		session.pausedLeft = session.pausedLeft + ns.ROLL_EXTEND_SECONDS
	else
		session.endsAt = session.endsAt + ns.ROLL_EXTEND_SECONDS
	end
	session.warned = false
	Send(ns:GetRollResultChannel(), "ROLL_CALL_EXTENDED", ns.ROLL_EXTEND_SECONDS, session.itemLink)
	Broadcast("EXTEND", session.id, math.floor(SecondsLeft(session)))
	Changed()
end

---@param session table
---@return nil
function ns:CloseRollNow(session)
	if session.open and session.isMine then
		session.endsAt = GetTime()
		session.pausedLeft = nil
		Close(session)
	end
end

---@param session table
---@return nil
function ns:PauseRoll(session)
	if not session.open or not session.isMine or session.pausedLeft then
		return
	end
	session.pausedLeft = SecondsLeft(session)
	Send(ns:GetRollCallChannel(), "ROLL_CALL_PAUSED", session.itemLink)
	Broadcast("PAUSE", session.id, math.floor(session.pausedLeft))
	Changed()
end

---@param session table
---@return nil
function ns:ResumeRoll(session)
	if not session.open or not session.isMine or not session.pausedLeft then
		return
	end
	local left = math.max(ns.ROLL_WARNING_SECONDS, session.pausedLeft)
	session.pausedLeft = nil
	session.endsAt = GetTime() + left
	Send(ns:GetRollCallChannel(), "ROLL_CALL_RESUMED", session.itemLink, math.floor(left))
	Broadcast("RESUME", session.id, math.floor(left))
	Changed()
end

---@param session table
---@return nil
function ns:CancelRoll(session)
	if not session.isMine then
		return
	end
	session.open = false
	session.status = ns.ENTRY_WAITING
	session.canceled = true
	Send(ns:GetRollCallChannel(), "ROLL_CALL_CANCELED", session.itemLink)
	Broadcast("CANCEL", session.id)
	if ns.currentRoll == session then
		ns.currentRoll = nil
	end
	rollsById[session.id] = nil
	if ns.OnRollFinished then
		ns.OnRollFinished(session)
	end
	Changed()
end

--[[
    Throws out every roll and calls the item again, as a new roll. The old one
    is dropped rather than kept, so Earlier tonight never shows a result that
    was voided.
]]
---@param session table
---@return table|nil
function ns:VoidRolls(session)
	if not session.isMine or (ns:IsOwnRollOpen() and ns.currentRoll ~= session) then
		return nil
	end
	StopFollowing()
	session.open = false
	session.voided = true
	rollsById[session.id] = nil
	for index, kept in ipairs(ns.rollHistory) do
		if kept == session then
			table.remove(ns.rollHistory, index)
			break
		end
	end
	Broadcast("CANCEL", session.id)
	ns.currentRoll = nil
	local length = ns.db.profile.rollLength
	local fresh = NewSession({
		itemLink = session.itemLink,
		entryKey = session.entryKey,
		caller = session.caller,
		isMine = true,
		synced = true,
		length = length,
	})
	Send(ns:GetRollCallChannel(), "ROLL_CALL_VOIDED", session.itemLink, length)
	Broadcast("START", fresh.id, 1, length, "", fresh.itemLink)
	Begin(fresh)
	return fresh
end

-- A held tie (Re-roll Ties Automatically off): the loot master calls the tie-break.
---@param session table
---@return nil
function ns:RerollTie(session)
	if session.isMine and session.status == ns.ENTRY_TIED and session.tied and not ns:IsOwnRollOpen() then
		StopFollowing()
		ns.currentRoll = session
		StartTieBreak(session, session.tied)
		StartTicker()
	end
end

--[[
    The disqualify line as the group sees it, also previewed in the Disqualify
    window; a picked reason gets the sentence that names it.
]]
---@param roll table
---@param itemLink string
---@param reasonKey string # one of ns.ROLL_DISQUALIFY_REASONS
---@return string|nil
function ns:BuildDisqualifyMessage(roll, itemLink, reasonKey)
	if reasonKey == "NONE" then
		return ns:BuildAnnounceMessage("ROLL_CALL_DISQUALIFIED_NO_REASON", roll.name, roll.value, itemLink)
	end
	return ns:BuildAnnounceMessage(
		"ROLL_CALL_DISQUALIFIED_BECAUSE",
		roll.name,
		roll.value,
		itemLink,
		L["ROLL_DISQUALIFY_REASON_" .. reasonKey]
	)
end

--[[
    Disqualifies a counted roll, says so in group chat, and when it was the
    winning roll of a finished one, decides the roll again from what is left.
]]
---@param session table
---@param roll table
---@param reasonKey string # one of ns.ROLL_DISQUALIFY_REASONS
---@return nil
function ns:DisqualifyRoll(session, roll, reasonKey)
	if not session.isMine or roll.reject then
		return
	end
	roll.reject = ns.ROLL_REJECT_MANUAL
	roll.reason = reasonKey
	SendLine(ns:GetRollResultChannel(), ns:BuildDisqualifyMessage(roll, session.itemLink, reasonKey))
	Broadcast("DQ", session.id, roll.order, reasonKey)
	if not session.open and roll.round == session.round and session.status == ns.ENTRY_WON then
		Resolve(session, true)
		return
	end
	Changed()
end

---@param session table
---@param roll table
---@return nil
function ns:RestoreRoll(session, roll)
	if not session.isMine or roll.reject ~= ns.ROLL_REJECT_MANUAL then
		return
	end
	roll.reject = nil
	roll.reason = nil
	Send(ns:GetRollResultChannel(), "ROLL_CALL_RESTORED", roll.name, roll.value, session.itemLink)
	Broadcast("RESTORE", session.id, roll.order)
	if
		not session.open
		and roll.round == session.round
		and (session.status == ns.ENTRY_WON or session.status == ns.ENTRY_NOBODY)
	then
		Resolve(session, true)
		return
	end
	Changed()
end

-- The winner, said again, for a raid that missed it.
---@param session table
---@return nil
function ns:AnnounceRollWinner(session)
	if session.isMine and session.winner then
		Send(ns:GetRollResultChannel(), "ROLL_CALL_WINS", session.winner.name, session.itemLink, session.winner.value)
	end
end

--------------------------------------------------------------------------------
-- Events: /roll and Passes
--------------------------------------------------------------------------------

local function OnSystemMessage(message)
	if not ns.db.profile.lootMaster then
		return
	end
	local playerName, value, low, high = ns.ParseRandomRollMessage(message)
	if not playerName then
		return
	end
	local key = ns:NormalizePlayerName(playerName)
	local roster = ns:GetRollRoster()
	if not roster[key] then
		return
	end
	local roll = { name = roster[key].name, key = key, value = value, low = low, high = high }

	local session = ns.currentRoll
	if session and session.open then
		AddRoll(session, roll)
		if
			session.isMine
			and ns.db.profile.rollStretchLate
			and not roll.reject
			and not session.pausedLeft
			and SecondsLeft(session) < ns.ROLL_STRETCH_SECONDS
		then
			session.endsAt = GetTime() + ns.ROLL_STRETCH_SECONDS
			Broadcast("EXTEND", session.id, ns.ROLL_STRETCH_SECONDS)
		end
		Changed()
		return
	end
	if session and session.lateUntil and GetTime() <= session.lateUntil then
		roll.reject = ns.ROLL_REJECT_LATE
		AddRoll(session, roll)
		Changed()
		return
	end
	roll.at = GetTime()
	table.insert(recentRolls, roll)
	while #recentRolls > 0 and recentRolls[1].at < GetTime() - ns.ROLL_EARLY_SECONDS do
		table.remove(recentRolls, 1)
	end
end

--[[
    "pass" in group chat, in the client's own word for it or in English, is a
    pass on the open roll: the player drops out of Hasn't rolled.
]]
local PASS_WORDS = { ["pass"] = true }
if type(PASS) == "string" then
	PASS_WORDS[string.lower(PASS)] = true
end

--[[
    Spotting a roll called without GogoLoot: an item link in a raid warning,
    or in group chat beside the word roll, from someone other than the player.
    GogoLoot's own lines are skipped: a caller running GogoLoot sends the roll
    as an add-on message, which carries the rulings too.
]]
local function IsRollCall(event, message)
	if not string.find(message, "|Hitem:", 1, true) then
		return false
	end
	if string.find(message, " // " .. L["ADDON_TITLE"], 1, true) then
		return false
	end
	if event == "CHAT_MSG_RAID_WARNING" then
		return true
	end
	local lowered = string.lower(message)
	return string.find(lowered, "roll", 1, true) ~= nil
		or string.find(lowered, string.lower(L["LOOT_TRACKER_ROLL_WORD"]), 1, true) ~= nil
end

local function OnGroupChat(event, message, author)
	if not ns.db.profile.lootMaster or type(message) ~= "string" or IsSecretValue(message) then
		return
	end
	local authorKey = ns:NormalizePlayerName(author)
	local playerKey = ns:NormalizePlayerName(ns:GetCleanUnitName("player"))
	local session = ns.currentRoll

	local trimmed = string.lower(string.match(message, "^%s*(.-)%s*$") or "")
	if PASS_WORDS[trimmed] then
		if session and session.open and authorKey and (not session.eligible or session.eligible[authorKey]) then
			session.passes[authorKey] = true
			Changed()
		end
		return
	end

	if authorKey == playerKey or (session and session.open) or not IsRollCall(event, message) then
		return
	end
	local itemLink = string.match(message, "|c[^|]+|Hitem:.-|h%[.-%]|h|r")
	if not itemLink then
		return
	end
	local spotted = NewSession({
		itemLink = itemLink,
		caller = author,
		isMine = false,
		synced = false,
		length = ns.db.profile.rollLength,
	})
	Begin(spotted)
end

for _, eventName in ipairs({
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
}) do
	ns:RegisterModuleEvent(eventName, function(message, author)
		OnGroupChat(eventName, message, author)
	end)
end
ns:RegisterModuleEvent("CHAT_MSG_SYSTEM", OnSystemMessage)

--------------------------------------------------------------------------------
-- Events: the Loot Master's Add-on Messages
--------------------------------------------------------------------------------

---@param session table
---@param order any
---@return table|nil
local function RollByOrder(session, order)
	order = tonumber(order)
	for _, roll in ipairs(session.rolls) do
		if roll.order == order then
			return roll
		end
	end
	return nil
end

local RECEIVERS = {}

-- A roll the loot master called, or a tie-break of one already followed.
function RECEIVERS.START(sender, id, round, length, eligibleNames, itemLink)
	round, length = tonumber(round) or 1, tonumber(length) or ns.db.profile.rollLength
	local session = rollsById[id]
	if not session then
		local current = ns.currentRoll
		if current and current.open and not current.isMine then
			current.open = false
		elseif current and current.open then
			return
		end
		session = NewSession({
			id = id,
			itemLink = itemLink,
			caller = sender,
			isMine = false,
			synced = true,
			length = length,
		})
	end
	session.round = round
	session.length = length
	session.endsAt = GetTime() + length
	session.pausedLeft = nil
	session.open = true
	session.status = ns.ENTRY_ROLLING
	session.eligible = nil
	if eligibleNames and eligibleNames ~= "" then
		session.eligible = {}
		for name in string.gmatch(eligibleNames, "[^,]+") do
			session.eligible[ns:NormalizePlayerName(name)] = true
		end
	end
	if ns.currentRoll ~= session then
		Begin(session)
	else
		StartTicker()
		Changed()
	end
end

function RECEIVERS.PAUSE(_, id, left)
	local session = rollsById[id]
	if session then
		session.pausedLeft = tonumber(left) or SecondsLeft(session)
		session.pausedAt = GetTime()
		Changed()
	end
end

function RECEIVERS.RESUME(_, id, left)
	local session = rollsById[id]
	if session then
		session.pausedLeft = nil
		session.endsAt = GetTime() + (tonumber(left) or 0)
		Changed()
	end
end

function RECEIVERS.EXTEND(_, id, left)
	local session = rollsById[id]
	if session and session.open then
		session.endsAt = GetTime() + (tonumber(left) or 0)
		Changed()
	end
end

function RECEIVERS.DQ(_, id, order, reasonKey)
	local session = rollsById[id]
	local roll = session and RollByOrder(session, order)
	if roll and not roll.reject then
		roll.reject = ns.ROLL_REJECT_MANUAL
		roll.reason = reasonKey
		Changed()
	end
end

function RECEIVERS.RESTORE(_, id, order)
	local session = rollsById[id]
	local roll = session and RollByOrder(session, order)
	if roll and roll.reject == ns.ROLL_REJECT_MANUAL then
		roll.reject = nil
		roll.reason = nil
		Changed()
	end
end

-- The caller's result, which settles the roll here whatever the local count said.
function RECEIVERS.END(_, id, winnerName, value)
	local session = rollsById[id]
	if not session then
		return
	end
	session.open = false
	session.lateUntil = GetTime() + ns.ROLL_LATE_SECONDS
	if winnerName and winnerName ~= "" then
		session.status = ns.ENTRY_WON
		local key = ns:NormalizePlayerName(winnerName)
		session.winner = { name = winnerName, key = key, value = tonumber(value) }
		for _, roll in ipairs(ns:GetCountedRolls(session)) do
			if roll.key == key then
				session.winner = roll
				break
			end
		end
	else
		local counted = ns:GetCountedRolls(session)
		session.status = #counted == 0 and ns.ENTRY_NOBODY or ns.ENTRY_TIED
		session.winner = nil
	end
	Finish(session)
end

function RECEIVERS.CANCEL(_, id)
	local session = rollsById[id]
	if session then
		session.open = false
		session.canceled = true
		rollsById[id] = nil
		if ns.currentRoll == session then
			ns.currentRoll = nil
		end
		Changed()
	end
end

local function OnAddonMessage(prefix, message, _, sender)
	if prefix ~= ns.ADDON_MESSAGE_PREFIX or type(message) ~= "string" or not ns.db.profile.lootMaster then
		return
	end
	local senderKey = ns:NormalizePlayerName(sender)
	if senderKey == ns:NormalizePlayerName(ns:GetCleanUnitName("player")) then
		return
	end
	local fields = {}
	for field in string.gmatch(message .. FIELD_SEPARATOR, "(.-)" .. FIELD_SEPARATOR) do
		fields[#fields + 1] = field
	end
	local kind = table.remove(fields, 1)
	local receiver = RECEIVERS[kind]
	if receiver then
		receiver(sender, unpack(fields))
	elseif ns.OnLootAddonMessage then
		ns.OnLootAddonMessage(kind, sender, fields)
	end
end

ns:RegisterModuleEvent("CHAT_MSG_ADDON", OnAddonMessage)

--------------------------------------------------------------------------------
-- Rows for the Windows
--------------------------------------------------------------------------------

--[[
    A roll's tag in the windows: why it doesn't count, or for a counted one,
    whether it leads or won. The disqualifications by hand carry their reason.
]]
---@param session table
---@param roll table
---@return string text
---@return string colorKey
function ns:GetRollTag(session, roll)
	if roll.reject == ns.ROLL_REJECT_MANUAL then
		local reason = roll.reason and roll.reason ~= "NONE" and L["ROLL_DISQUALIFY_REASON_" .. roll.reason]
		return reason and L["ROLL_TAG_DISQUALIFIED_BECAUSE"]:format(reason) or L["ROLL_TAG_DISQUALIFIED"], "OFF"
	elseif roll.reject then
		if roll.reject == ns.ROLL_REJECT_RANGE then
			return L["ROLL_TAG_RANGE"]:format(roll.low, roll.high), "MUTED"
		end
		return L["ROLL_TAG_" .. roll.reject], "MUTED"
	end
	if roll.round ~= session.round then
		return "", "TEXT"
	end
	local counted = ns:GetCountedRolls(session)
	if counted[1] and counted[1].value == roll.value then
		if session.winner and session.winner.key == roll.key then
			return L["ROLL_TAG_WINNER"], "ON"
		end
		if session.open then
			return L["ROLL_TAG_HIGHEST"], "ON"
		end
		return L["ROLL_TAG_TIED"], "ON"
	end
	return "", "TEXT"
end

--[[
    Who in the group hasn't rolled on the open round or passed: the tied
    players in a tie-break, everyone else otherwise. The caller isn't asked to
    roll on their own call.
]]
---@param session table
---@return string[]
function ns:GetRollWaitingNames(session)
	local roster = ns:GetRollRoster()
	local answered = {}
	for _, roll in ipairs(session.rolls) do
		if roll.round == session.round and not roll.reject then
			answered[roll.key] = true
		end
	end
	local callerKey = not session.eligible and ns:NormalizePlayerName(session.caller)
	local names = {}
	for key, member in pairs(roster) do
		local eligible = not session.eligible or session.eligible[key]
		if eligible and key ~= callerKey and not answered[key] and not session.passes[key] then
			names[#names + 1] = member.name
		end
	end
	table.sort(names)
	return names
end

-- The color a roll's tag key names, as an escape.
---@param colorKey string
---@return string
function ns:GetRollTagColor(colorKey)
	return GetColor(colorKey)
end
