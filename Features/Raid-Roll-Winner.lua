--------------------------------------------------------------------------------
-- GogoLoot Raid Roll Winner
--------------------------------------------------------------------------------

--[[
    Only CHAT_MSG_SYSTEM is read for a roll: anyone can type a roll's words in
    normal chat. So several GogoLoot users don't all post the same roll, each
    sends a claim with its roster place, waits ns.RAID_ROLL_CLAIM_WAIT, and
    posts only if no earlier place claimed. A claim with no place (an older
    GogoLoot, which claims only as it posts) holds everyone back.
]]
local _, ns = ...
local L = ns.L

-- The claim's first field, so it never reads as any other GogoLoot add-on message.
local CLAIM_KIND = "RAIDROLL"
local CLAIM_SEPARATOR = ":"
-- How long a claim is remembered; well past the wait.
local CLAIM_MEMORY_SECONDS = 30

-- [claim key] = { heardAt, place }: the earliest roster place heard claiming it, 0 for a claim with no place.
local claims = {}

--------------------------------------------------------------------------------
-- Roster
--------------------------------------------------------------------------------

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

local function ClaimKey(roller, roll, high)
	return table.concat({ ns:NormalizePlayerName(roller) or roller, roll, high }, CLAIM_SEPARATOR)
end

local function ForgetOldClaims(now)
	for key, claim in pairs(claims) do
		if now - claim.heardAt > CLAIM_MEMORY_SECONDS then
			claims[key] = nil
		end
	end
end

---@param key string
---@param place number
---@return nil
local function RecordClaim(key, place)
	local now = GetTime()
	ForgetOldClaims(now)
	local claim = claims[key]
	if not claim or place < claim.place then
		claims[key] = { heardAt = now, place = place }
	end
end

local function SendClaim(key, place)
	local channel = ns:GetGroupChatChannel()
	if channel and C_ChatInfo.SendAddonMessage then
		C_ChatInfo.SendAddonMessage(
			ns.ADDON_MESSAGE_PREFIX,
			table.concat({ CLAIM_KIND, place, key }, CLAIM_SEPARATOR),
			channel
		)
	end
end

-- The winner is read with the roll, so a roster change during the wait can't move it.
local function PostWhenUnclaimed(key, roller, roll, groupSize, winner)
	local ownPlace = RosterPlace(OwnName()) or 1
	SendClaim(key, ownPlace)
	ns:After("raidRollWinner:" .. key, ns.RAID_ROLL_CLAIM_WAIT, function()
		local claim = claims[key]
		if claim and claim.place < ownPlace then
			return
		end
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
local function OnChatMsgSystem(message)
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

-- The player's own claims echo back and are ignored.
local function OnChatMsgAddon(prefix, message, _, sender)
	-- A secret value can't be compared, so it's checked for before anything is.
	if ns.IsSecretValue(prefix) or ns.IsSecretValue(message) or ns.IsSecretValue(sender) then
		return
	end
	if prefix ~= ns.ADDON_MESSAGE_PREFIX or type(message) ~= "string" then
		return
	end
	local kindPrefix = CLAIM_KIND .. CLAIM_SEPARATOR
	if message:sub(1, #kindPrefix) ~= kindPrefix then
		return
	end
	if sender and ns:NormalizePlayerName(sender) == ns:NormalizePlayerName(OwnName()) then
		return
	end
	local body = message:sub(#kindPrefix + 1)
	local place, key = body:match("^(%d+)" .. CLAIM_SEPARATOR .. "(.+)$")
	if place then
		RecordClaim(key, tonumber(place))
	else
		RecordClaim(body, 0)
	end
end

-- Every login: the client forgets the prefix, and parked Roll Calls, which also registers it, isn't loaded.
local function OnPlayerLogin()
	if C_ChatInfo.RegisterAddonMessagePrefix then
		C_ChatInfo.RegisterAddonMessagePrefix(ns.ADDON_MESSAGE_PREFIX)
	end
end

ns:RegisterModuleEvent("PLAYER_LOGIN", OnPlayerLogin)
ns:RegisterModuleEvent("CHAT_MSG_SYSTEM", OnChatMsgSystem)
ns:RegisterModuleEvent("CHAT_MSG_ADDON", OnChatMsgAddon)
