--------------------------------------------------------------------------------
-- GogoLoot Master Loot Module
--------------------------------------------------------------------------------

local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- API Wrappers (Classic Compatibility)
--------------------------------------------------------------------------------

-- An Enum.LootMethod number on C_PartyInfo, a string on the legacy API.
local LOOT_METHOD_BY_ENUM = {
	[Enum.LootMethod.Freeforall] = "freeforall",
	[Enum.LootMethod.Roundrobin] = "roundrobin",
	[Enum.LootMethod.Masterlooter] = "master",
	[Enum.LootMethod.Group] = "group",
	[Enum.LootMethod.Needbeforegreed] = "needbeforegreed",
}
-- MoP Classic only: Personal Loot, which would otherwise read as Group Loot.
if Enum.LootMethod.Personal then
	LOOT_METHOD_BY_ENUM[Enum.LootMethod.Personal] = "personal"
end

local LOOT_METHOD_TO_ENUM = {}
for enumValue, methodName in pairs(LOOT_METHOD_BY_ENUM) do
	LOOT_METHOD_TO_ENUM[methodName] = enumValue
end

---@return string # one of freeforall / roundrobin / master / group / needbeforegreed / personal (MoP Classic)
function ns:SafeGetLootMethod()
	local method = ns:SafeCallLootMethod()
	if type(method) == "string" then
		return method
	end
	return LOOT_METHOD_BY_ENUM[method] or "group"
end

---@return number
function ns:SafeGetLootThreshold()
	if not ns.GetLootThreshold then
		return 2
	end
	return ns.GetLootThreshold() or 2
end

---@return boolean
function ns:IsGroupLeader()
	if not IsInGroup() then
		return false
	end
	if type(UnitIsGroupLeader) == "function" then
		return UnitIsGroupLeader("player") and true or false
	end
	return false
end

-- "player" first: a party's unit ids never include the player, while a raid's do.
---@return string|nil
function ns:GetGroupLeaderName()
	if not IsInGroup() or type(UnitIsGroupLeader) ~= "function" then
		return nil
	end
	if UnitIsGroupLeader("player") then
		return ns:CapitalizeFirstLetter(ns:GetCleanUnitName("player"))
	end
	local memberCount = GetNumGroupMembers()
	if IsInRaid() then
		for memberIndex = 1, memberCount do
			local unitIdentifier = "raid" .. memberIndex
			if UnitIsGroupLeader(unitIdentifier) then
				return ns:CapitalizeFirstLetter(ns:GetCleanUnitName(unitIdentifier))
			end
		end
		return nil
	end
	for memberIndex = 1, memberCount - 1 do
		local unitIdentifier = "party" .. memberIndex
		if UnitIsGroupLeader(unitIdentifier) then
			return ns:CapitalizeFirstLetter(ns:GetCleanUnitName(unitIdentifier))
		end
	end
	return nil
end

-- Master Loot needs a master looter: the leader who made the change, who can reassign it.
---@param method string
---@return nil
function ns:SafeSetLootMethod(method)
	if not ns.SetLootMethod then
		return
	end

	local methodValue = method
	if ns.SET_LOOT_METHOD_TAKES_ENUM then
		methodValue = LOOT_METHOD_TO_ENUM[method]
		if not methodValue then
			return
		end
	end

	if method == "master" then
		ns.SetLootMethod(methodValue, ns:GetCleanUnitName("player"))
	else
		ns.SetLootMethod(methodValue)
	end
end

---@param threshold number
---@return nil
function ns:SafeSetLootThreshold(threshold)
	if ns.SetLootThreshold then
		ns.SetLootThreshold(threshold)
	end
end

--------------------------------------------------------------------------------
-- Distribution Eligibility
--------------------------------------------------------------------------------

---@return boolean
function ns:WillAutoMasterLoot()
	if not ns:AreWeMasterLooter() then
		return false
	end
	if not ns.db or not ns.db.profile.autoMasterLoot then
		return false
	end

	local _, instanceType = GetInstanceInfo()
	local isInsideInstance = (instanceType == "raid" or instanceType == "party")

	if isInsideInstance then
		return true
	end
	return ns.db.profile.autoMasterLootOutsideInstances == true
end

--------------------------------------------------------------------------------
-- Loading-Screen Guard
--------------------------------------------------------------------------------

--[[
    Around a loading screen the loot API answers the default, or nothing: a
    zoning master looter reads as demoted, the method as "group", the roster as
    empty. Such readings are ignored and deliberately NOT recorded, so the
    reading when the settle window ends still compares against the pre-zone
    state and catches a real change.
]]
local ZONE_SETTLE_SECONDS = 3
local ZONE_SETTLE_TIMER = "GogoLoot.MasterLooter.ZoneSettle"
local isZoneChangeSettling = false

---@return boolean
local function IsLootStateUnreadable()
	return isZoneChangeSettling or ns:SafeCallLootMethod() == nil
end

--------------------------------------------------------------------------------
-- Destination Management
--------------------------------------------------------------------------------

---@return table
function ns:GetGroupMemberNames()
	local memberNames = {
		[ns.DESTINATION_LOOT_WINDOW] = L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"],
		["self"] = L["MASTER_LOOTER_DESTINATION_SELF"],
	}
	local playerName = ns:GetLowercaseUnitName("player")

	for memberIndex = 1, GetNumGroupMembers() do
		local unitIdentifier = IsInRaid() and ("raid" .. memberIndex) or ("party" .. memberIndex)
		local memberName = ns:GetLowercaseUnitName(unitIdentifier)
		if memberName and memberName ~= playerName then
			memberNames[memberName] = ns:FormatPlayerName(memberName)
		end
	end

	return memberNames
end

-- The dropdown sorts by key otherwise, filing Loot Window and Self among the names.
---@return table
function ns:GetGroupMemberSorting()
	local sorting = { "self" }
	local playerName = ns:GetLowercaseUnitName("player")

	for memberIndex = 1, GetNumGroupMembers() do
		local unitIdentifier = IsInRaid() and ("raid" .. memberIndex) or ("party" .. memberIndex)
		local memberName = ns:GetLowercaseUnitName(unitIdentifier)
		if memberName and memberName ~= playerName then
			sorting[#sorting + 1] = memberName
		end
	end

	table.sort(sorting, function(a, b)
		if a == "self" or b == "self" then
			return a == "self"
		end
		return a < b
	end)
	table.insert(sorting, 1, ns.DESTINATION_LOOT_WINDOW)
	return sorting
end

---@param quality number
---@return boolean
function ns:IsQualityReachable(quality)
	return quality >= ns:SafeGetLootThreshold()
end

-- nil when the reachable tiers disagree: Send All Loot To shows blank rather than one tier's answer.
---@return string|nil
function ns:GetSharedDestination()
	local shared
	local sawTier = false

	for quality = 0, 4 do
		local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[quality]
		if qualityKey and ns:IsQualityReachable(quality) then
			local destination = ns.db.profile.destinations[qualityKey]
			-- Unset is a value in its own right, so track whether a tier was seen, not whether `shared` is nil.
			if not sawTier then
				shared = destination
				sawTier = true
			elseif shared ~= destination then
				return nil
			end
		end
	end

	return shared
end

-- Loot Window is never saved: unset and sent back to the loot window are the same thing.
---@param qualityKey string
---@return string
function ns:GetDestinationChoice(qualityKey)
	local destination = ns.db.profile.destinations[qualityKey]
	if not destination or destination == "" then
		return ns.DESTINATION_LOOT_WINDOW
	end
	return destination
end

---@return string|nil
function ns:GetSharedDestinationChoice()
	for quality = 0, 4 do
		local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[quality]
		if
			qualityKey
			and ns:IsQualityReachable(quality)
			and ns:GetDestinationChoice(qualityKey) ~= ns.DESTINATION_LOOT_WINDOW
		then
			return ns:GetSharedDestination()
		end
	end
	return ns.DESTINATION_LOOT_WINDOW
end

---@param targetPlayerName string
---@return boolean
local function IsNonSelfDestination(targetPlayerName)
	if not targetPlayerName then
		return false
	end
	local targetLower = strlower(targetPlayerName)
	return targetLower ~= "self" and targetLower ~= "player"
end

--[[
    "self" is resolved to the player's name, which also makes switching BACK to
    yourself announceable: silence would leave the earlier announcement standing.
]]
---@param targetPlayerName string
---@return string
local function GetDestinationDisplayName(targetPlayerName)
	if not IsNonSelfDestination(targetPlayerName) then
		return ns:FormatPlayerName(ns:GetCleanUnitName("player"))
	end
	return ns:FormatPlayerName(targetPlayerName)
end

-- Announces once, not per tier. Loot Window clears every tier silently: nobody is holding anything.
---@param targetPlayerName string
---@return nil
function ns:SetAllDestinations(targetPlayerName)
	local destination = targetPlayerName ~= ns.DESTINATION_LOOT_WINDOW and targetPlayerName or nil
	for quality = 0, 4 do
		local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[quality]
		if qualityKey and (not destination or ns:IsQualityReachable(quality)) then
			ns.db.profile.destinations[qualityKey] = destination
		end
	end
	if not destination then
		return
	end

	if not IsInGroup() then
		return
	end
	if not ns.db.profile.announceDestinations then
		return
	end
	ns:Announce(
		ns:GetGroupChatChannel(),
		nil,
		"MESSAGE_DESTINATION_SET_ALL",
		GetDestinationDisplayName(targetPlayerName)
	)
end

---@param targetPlayerName string
---@param qualityKey string
---@return nil
function ns:AnnounceDestinationSet(targetPlayerName, qualityKey)
	if not IsInGroup() then
		return
	end
	if not ns.db.profile.announceDestinations then
		return
	end
	local displayName = GetDestinationDisplayName(targetPlayerName)
	local qualityLabel = ns.QUALITY_DISPLAY_NAMES[qualityKey] or ns:CapitalizeFirstLetter(qualityKey)
	ns:Announce(ns:GetGroupChatChannel(), nil, "MESSAGE_DESTINATION_SET", displayName, qualityLabel)
end

-- To unset, never Self: a leftover Self reads as a live instruction nobody chose.
local function ResetAllDestinations()
	for quality = 0, 4 do
		local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[quality]
		if qualityKey then
			ns.db.profile.destinations[qualityKey] = nil
		end
	end
end

--[[
    Nil when any member who is there can't be named: a name that reads secret
    (WoW Forever, in combat) or hasn't loaded would otherwise look like a
    player who left.
]]
---@return table<string, boolean>|nil
local function GetCurrentGroupMemberLookup()
	local groupMembers = {}
	local myName = ns:GetLowercaseUnitName("player")
	if not myName then
		return nil
	end
	groupMembers[myName] = true
	for memberIndex = 1, GetNumGroupMembers() do
		local unitIdentifier = IsInRaid() and ("raid" .. memberIndex) or ("party" .. memberIndex)
		local memberName = ns:GetLowercaseUnitName(unitIdentifier)
		if memberName then
			groupMembers[memberName] = true
		elseif UnitExists(unitIdentifier) then
			return nil
		end
	end
	return groupMembers
end

local function CheckDestinationsForLeavers()
	if IsLootStateUnreadable() then
		return
	end
	if not IsInGroup() then
		return
	end
	if not ns:AreWeMasterLooter() then
		return
	end

	local groupMembers = GetCurrentGroupMemberLookup()
	if not groupMembers then
		return
	end
	local myName = ns:GetCleanUnitName("player")
	local masterLooterDisplayName = ns:FormatPlayerName(myName)
	local chatChannel = ns:GetGroupChatChannel()

	--[[
        An unreachable quality is cleared unannounced, never set to Self:
        lowering the threshold later must not reveal a Self nobody chose.
    ]]
	local leavers, leaverOrder = {}, {}
	local tierCount = 0
	for quality = 0, 4 do
		local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[quality]
		local reachable = qualityKey and ns:IsQualityReachable(quality)
		if reachable then
			tierCount = tierCount + 1
		end
		if qualityKey then
			local targetPlayerName = ns.db.profile.destinations[qualityKey]
			if IsNonSelfDestination(targetPlayerName) and not reachable then
				if not groupMembers[ns:NormalizePlayerName(targetPlayerName)] then
					ns.db.profile.destinations[qualityKey] = nil
				end
			elseif IsNonSelfDestination(targetPlayerName) then
				local targetLower = ns:NormalizePlayerName(targetPlayerName)
				if not groupMembers[targetLower] then
					local leaver = leavers[targetLower]
					if not leaver then
						leaver = { displayName = ns:FormatPlayerName(targetPlayerName), qualityLabels = {} }
						leavers[targetLower] = leaver
						leaverOrder[#leaverOrder + 1] = targetLower
					end
					leaver.qualityLabels[#leaver.qualityLabels + 1] = ns.QUALITY_DISPLAY_NAMES[qualityKey]
						or ns:CapitalizeFirstLetter(qualityKey)
					ns.db.profile.destinations[qualityKey] = "self"
				end
			end
		end
	end

	if not ns.db.profile.announceDestinations then
		return
	end
	for _, targetLower in ipairs(leaverOrder) do
		local leaver = leavers[targetLower]
		if #leaver.qualityLabels == tierCount then
			ns:Announce(chatChannel, nil, "MESSAGE_DESTINATION_LEFT_ALL", leaver.displayName, masterLooterDisplayName)
		else
			ns:Announce(
				chatChannel,
				nil,
				"MESSAGE_DESTINATION_LEFT",
				leaver.displayName,
				masterLooterDisplayName,
				table.concat(leaver.qualityLabels, ", ")
			)
		end
	end
end

--------------------------------------------------------------------------------
-- Dynamic Event Hooks — Group Roster & Loot Method Changes
--------------------------------------------------------------------------------

local wasInGroup = IsInGroup()

--[[
    Starts false, so logging in as master looter counts as becoming one. Both
    events feed it: the role also falls to you when its holder leaves, on a
    GROUP_ROSTER_UPDATE no loot-method event accompanies.
]]
local wasMasterLooter = false

-- Zoning reads as demote-then-promote; IsLootStateUnreadable keeps that gap out of the flag.
local function CheckMasterLooterPopup()
	if not ns.db then
		return
	end
	if IsLootStateUnreadable() then
		return
	end

	local isMasterLooter = ns:AreWeMasterLooter()
	if isMasterLooter and not wasMasterLooter and ns.db.profile.masterLooterPopup then
		ns:ShowMasterLooterPopup()
	end
	wasMasterLooter = isMasterLooter
end

--[[
    Compared against the last method OBSERVED, refreshed by roster updates too:
    PARTY_LOOT_METHOD_CHANGED need not reach every member, and may beat the API.
    Tracking the method, not the event, keeps a master-looter reassignment from
    wiping a setup. Starts nil, so the first reading records rather than resets.
]]
local lastObservedLootMethod = nil

---@return nil
local function ClearDestinationsOnLootMethodChange()
	if not ns.db then
		return
	end
	if IsLootStateUnreadable() then
		return
	end

	local currentMethod = ns:SafeGetLootMethod()
	if lastObservedLootMethod ~= nil and currentMethod ~= lastObservedLootMethod then
		ResetAllDestinations()
	end
	lastObservedLootMethod = currentMethod
end

local function OnPartyLootMethodChanged()
	ClearDestinationsOnLootMethodChange()
	ns.RefreshSettings()
	CheckMasterLooterPopup()
end

--[[
    Every repaint closes an open dropdown, and GROUP_ROSTER_UPDATE fires for far
    more than the panels show, so a roster update repaints only when this
    changes.
]]
local lastPanelSignature = nil

---@return boolean
local function IsRosterOnScreen()
	return (ns.IsOptionsPanelOpen and ns.IsOptionsPanelOpen())
		or (ns.IsMasterLooterPopupShown and ns.IsMasterLooterPopupShown())
		or false
end

---@return string
local function PanelSignature()
	local names = {}
	local unitPrefix = IsInRaid() and "raid" or "party"
	for memberIndex = 1, GetNumGroupMembers() do
		names[#names + 1] = ns:GetLowercaseUnitName(unitPrefix .. memberIndex) or ""
	end
	table.sort(names)
	return table.concat(names, ",")
		.. "|"
		.. tostring(ns:GetGroupLeaderName())
		.. "|"
		.. tostring(ns:SafeGetLootMethod())
		.. "|"
		.. tostring(ns:SafeGetLootThreshold())
end

local function OnGroupRosterUpdate()
	local isCurrentlyInGroup = IsInGroup()

	if wasInGroup and not isCurrentlyInGroup then
		ResetAllDestinations()
		lastPanelSignature = nil
		ns.RefreshSettings()
		wasInGroup = false
		wasMasterLooter = false
		lastObservedLootMethod = nil
		return
	end

	wasInGroup = isCurrentlyInGroup

	ClearDestinationsOnLootMethodChange()
	CheckDestinationsForLeavers()
	if not IsRosterOnScreen() then
		lastPanelSignature = nil
	else
		local signature = PanelSignature()
		if signature ~= lastPanelSignature then
			lastPanelSignature = signature
			ns.RefreshSettings()
		end
	end
	CheckMasterLooterPopup()
end

local function BeginZoneChangeSettle()
	isZoneChangeSettling = true
	ns:After(ZONE_SETTLE_TIMER, ZONE_SETTLE_SECONDS, function()
		isZoneChangeSettling = false
		OnGroupRosterUpdate()
	end)
end

--[[
    A group left while logged out is never seen leaving, so a login that
    settles solo ends the setup too. Its own timer, outside the settle window,
    so the pop-up still answers at login.
]]
local LOGIN_SOLO_TIMER = "GogoLoot.MasterLooter.LoginSolo"

local function ClearDestinationsIfSoloAtLogin()
	if ns.db and not IsInGroup() then
		ResetAllDestinations()
		ns.RefreshSettings()
	end
end

--[[
    Login and /reload answer the pop-up from a standing start, and a /reload
    keeps the setup. Every other loading screen is a zone change.
]]
local function OnPlayerEnteringWorld(isInitialLogin, isReloadingUi)
	if isInitialLogin then
		ns:After(LOGIN_SOLO_TIMER, ZONE_SETTLE_SECONDS, ClearDestinationsIfSoloAtLogin)
		return
	end
	if isReloadingUi then
		return
	end
	BeginZoneChangeSettle()
end

-- A zone border crossed without a loading screen, which PLAYER_ENTERING_WORLD doesn't report.
local function OnZoneChangedNewArea()
	BeginZoneChangeSettle()
end

ns:RegisterModuleEvent("PARTY_LOOT_METHOD_CHANGED", OnPartyLootMethodChanged)
ns:RegisterModuleEvent("GROUP_ROSTER_UPDATE", OnGroupRosterUpdate)
ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
ns:RegisterModuleEvent("ZONE_CHANGED_NEW_AREA", OnZoneChangedNewArea)
