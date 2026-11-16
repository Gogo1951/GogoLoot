--------------------------------------------------------------------------------
-- GogoLoot Raid Roll Winner
--------------------------------------------------------------------------------

--[[
    Whenever anyone in the group raid rolls (a plain /roll from 1 to exactly
    the number of players in the group), GogoLoot names the player the number
    lands on, counted down the raid or party list: in a raid the roll's place
    in the raid roster, in a party 1 for the player and 2 to 5 for party1 to
    party4, as the party frames list them.

    Me Only, the default, prints it to the player. Group Chat posts it instead,
    since the sent line shows in the player's own chat too. So several GogoLoot
    users in one group don't all post the same roll, each waits its roster
    place minus one times ns.RAID_ROLL_CLAIM_STEP, then posts only if no other
    GogoLoot user claimed that roll meanwhile, sending its own claim as an
    add-on message just before it posts. With Loot Announcements off, the
    master switch over everything GogoLoot posts, Group Chat prints instead.

    Only CHAT_MSG_SYSTEM is read for a roll (ns.ParseRandomRollMessage):
    anyone can type a roll's words in normal chat.

    Schema (ns.DATABASE_DEFAULTS.profile in Default-Settings.lua):
      raidRollWinner   - on by default
      raidRollOutput   - ns.RAID_ROLL_OUTPUT_SELF or ns.RAID_ROLL_OUTPUT_GROUP
]]
local _, ns = ...
local L = ns.L

-- The claim's first field, so it never reads as any other GogoLoot add-on message.
local CLAIM_KIND = "RAIDROLL"
local CLAIM_SEPARATOR = ":"
-- How long a claim is remembered; well past the last roster place's wait.
local CLAIM_MEMORY_SECONDS = 30

local claims = {}

--------------------------------------------------------------------------------
-- Roster
--------------------------------------------------------------------------------

--[[
    The player at a roster place: their name as the roster gives it and their
    class token. nil past the roster's end or for a place with no name yet.
]]
---@param place number
---@return string|nil name
---@return string|nil classFile
function ns.GetRaidRollPlayer(place)
	if IsInRaid() then
		local name, _, _, _, _, classFile = GetRaidRosterInfo(place)
		if not name or ns.IsSecretValue(name) then
			return nil
		end
		return name, classFile
	end
	local unitIdentifier = place == 1 and "player" or ("party" .. (place - 1))
	local name = ns:GetCleanUnitName(unitIdentifier)
	if not name then
		return nil
	end
	local _, classFile = UnitClass(unitIdentifier)
	return name, classFile
end

-- Where a player sits in the roster, by the name key every comparison uses; nil when they aren't in it.
---@param playerName string
---@return number|nil
local function RosterPlace(playerName)
	local wanted = ns:NormalizePlayerName(playerName)
	for place = 1, GetNumGroupMembers() do
		local name = ns.GetRaidRollPlayer(place)
		if name and ns:NormalizePlayerName(name) == wanted then
			return place
		end
	end
	return nil
end

local function OwnName()
	return ns:GetCleanUnitName("player")
end

--------------------------------------------------------------------------------
-- Reading a Raid Roll
--------------------------------------------------------------------------------

--[[
    A roll that counts: the feature on, the player grouped, the roller in the
    group, a range of exactly 1 to the group's size, and a roll inside it.
    Returns the roller's roster place.
]]
---@param roller string
---@param roll number
---@param low number|nil
---@param high number|nil
---@return number|nil rollerPlace
local function CountedRoll(roller, roll, low, high)
	if not ns.db.profile.raidRollWinner or not IsInGroup() then
		return nil
	end
	local groupSize = GetNumGroupMembers()
	if groupSize < 2 or low ~= 1 or high ~= groupSize or roll < 1 or roll > groupSize then
		return nil
	end
	return RosterPlace(roller)
end

-- A name in its class color, for the printed line.
local function ColoredName(name, classFile)
	local color = classFile and ns.GetClassColor(classFile)
	return color and (color .. name .. "|r") or name
end

---@param roller string
---@param rollerClass string|nil
---@param roll number
---@param groupSize number
---@param winner string
---@param winnerClass string|nil
---@return string
function ns.BuildRaidRollPrint(roller, rollerClass, roll, groupSize, winner, winnerClass)
	return L["MESSAGE_RAID_ROLL_PRINT"]:format(
		ColoredName(roller, rollerClass),
		roll,
		groupSize,
		ColoredName(winner, winnerClass)
	)
end

-- The claim's key: who rolled what, out of how many.
local function ClaimKey(roller, roll, high)
	return table.concat({ ns:NormalizePlayerName(roller) or roller, roll, high }, CLAIM_SEPARATOR)
end

local function ForgetOldClaims(now)
	for key, heardAt in pairs(claims) do
		if now - heardAt > CLAIM_MEMORY_SECONDS then
			claims[key] = nil
		end
	end
end

-- Sends this player's claim on a roll, just before posting it, on the group's add-on channel.
local function SendClaim(key)
	local channel = ns:GetGroupChatChannel()
	if channel and C_ChatInfo.SendAddonMessage then
		C_ChatInfo.SendAddonMessage(ns.ADDON_MESSAGE_PREFIX, CLAIM_KIND .. CLAIM_SEPARATOR .. key, channel)
	end
end

--[[
    Group Chat: wait this player's roster place minus one steps, then post
    unless someone claimed the roll first. The winner's name is read now, when
    the roll is, so a roster change in the wait can't move it.
]]
local function PostWhenUnclaimed(key, roller, roll, groupSize, winner)
	local ownPlace = RosterPlace(OwnName()) or 1
	ns:After("raidRollWinner:" .. key, (ownPlace - 1) * ns.RAID_ROLL_CLAIM_STEP, function()
		if claims[key] then
			return
		end
		SendClaim(key)
		ns:Announce(
			ns:GetGroupChatChannel(),
			nil,
			"MESSAGE_RAID_ROLL",
			Ambiguate(roller, "short"),
			roll,
			groupSize,
			Ambiguate(winner, "short")
		)
	end)
end

---@param message any
---@return nil
local function OnSystemMessage(message)
	local roller, roll, low, high = ns.ParseRandomRollMessage(message)
	local rollerPlace = roller and CountedRoll(roller, roll, low, high)
	if not rollerPlace then
		return
	end
	local winner, winnerClass = ns.GetRaidRollPlayer(roll)
	if not winner then
		return
	end
	local groupSize = high
	if ns.db.profile.raidRollOutput == ns.RAID_ROLL_OUTPUT_GROUP and ns.db.profile.lootNotifications then
		PostWhenUnclaimed(ClaimKey(roller, roll, high), roller, roll, groupSize, winner)
		return
	end
	local _, rollerClass = ns.GetRaidRollPlayer(rollerPlace)
	ns:PrintMessage(ns.BuildRaidRollPrint(roller, rollerClass, roll, groupSize, winner, winnerClass))
end

-- Another GogoLoot user's claim on a roll; this player's own come back too, and are ignored.
local function OnAddonMessage(prefix, message, _, sender)
	if prefix ~= ns.ADDON_MESSAGE_PREFIX or type(message) ~= "string" or ns.IsSecretValue(message) then
		return
	end
	local kindPrefix = CLAIM_KIND .. CLAIM_SEPARATOR
	if message:sub(1, #kindPrefix) ~= kindPrefix then
		return
	end
	if sender and ns:NormalizePlayerName(sender) == ns:NormalizePlayerName(OwnName()) then
		return
	end
	local now = GetTime()
	ForgetOldClaims(now)
	claims[message:sub(#kindPrefix + 1)] = now
end

--[[
    The prefix is registered at every login: the client forgets it, and the
    parked Roll Calls, which registers it too, isn't loaded.
]]
local function OnPlayerLogin()
	if C_ChatInfo.RegisterAddonMessagePrefix then
		C_ChatInfo.RegisterAddonMessagePrefix(ns.ADDON_MESSAGE_PREFIX)
	end
end

ns:RegisterModuleEvent("PLAYER_LOGIN", OnPlayerLogin)
ns:RegisterModuleEvent("CHAT_MSG_SYSTEM", OnSystemMessage)
ns:RegisterModuleEvent("CHAT_MSG_ADDON", OnAddonMessage)
