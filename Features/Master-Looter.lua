--------------------------------------------------------------------------------
-- GogoLoot Master Loot Module
--------------------------------------------------------------------------------

--[[
    Master Loot configuration plumbing:
      * API wrappers for GetLootMethod / GetLootThreshold across Classic and
        modern clients.
      * Eligibility check (WillAutoMasterLoot) shared with Speedy-Loot.lua so
        Speedy Loot defers when this module owns the session.
      * Destination tracking — group roster cleanup when a destination player
        leaves, and the loot type / threshold readout used by the Options
        panel.

    The manual distribution hook and the automated LOOT_OPENED → GiveMasterLoot
    distribution engine (with its UI_ERROR_MESSAGE correlation and Pending
    Hand-out Registry) live in Master-Looter-Distribution.lua, which loads
    immediately after this file.

    All chat output to the group routes through ns:Announce, which
    pulls the body template from L[] and applies the target marker and
    add-on name for the channel. This module never calls SendChatMessage
    directly.
]]
local _, ns = ...
local L = ns.L
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--------------------------------------------------------------------------------
-- API Wrappers (Classic Compatibility)
--------------------------------------------------------------------------------

--[[
    The loot method crosses the API boundary as a number on modern clients and
    as a string on legacy ones, so one table owns the mapping in both
    directions. Enum.LootMethod does not exist on Classic Era, which makes these
    numbers the live values there rather than a fallback — see README-Technical.
]]
local LOOT_METHOD_BY_ENUM = {
	[0] = "freeforall",
	[1] = "roundrobin",
	[2] = "master",
	[3] = "group",
	[4] = "needbeforegreed",
}

local LOOT_METHOD_TO_ENUM = {}
for enumValue, methodName in pairs(LOOT_METHOD_BY_ENUM) do
	LOOT_METHOD_TO_ENUM[methodName] = enumValue
end

local ENUM_KEY_BY_METHOD = {
	freeforall = "FreeForAll",
	roundrobin = "RoundRobin",
	master = "MasterLoot",
	group = "GroupLoot",
	needbeforegreed = "NeedBeforeGreed",
}

---@return string # one of freeforall / roundrobin / master / group / needbeforegreed
function ns:SafeGetLootMethod()
	local method = ns:SafeCallLootMethod()
	if type(method) == "string" then
		return method
	end
	if type(method) == "number" then
		if Enum and Enum.LootMethod then
			for methodName, enumKey in pairs(ENUM_KEY_BY_METHOD) do
				if method == Enum.LootMethod[enumKey] then
					return methodName
				end
			end
		end
		return LOOT_METHOD_BY_ENUM[method] or "group"
	end
	return "group"
end

---@return number
function ns:SafeGetLootThreshold()
	if type(GetLootThreshold) == "function" then
		return GetLootThreshold()
	end
	if C_PartyInfo and type(C_PartyInfo.GetLootThreshold) == "function" then
		return C_PartyInfo.GetLootThreshold()
	end
	return 2
end

--[[
    Only the group leader may change the loot method and threshold, so the
    options dropdowns are editable only for them. UnitIsGroupLeader is the
    Classic surface; guard it in case a build lacks it.
]]
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

--[[
    Display name of whoever leads the group, the player included when that is
    them, or nil when solo.

    Checking "player" first is what makes the party case work at all: a party's
    unit ids run party1..partyN-1 and never include the player, so a party the
    player leads resolved to nil, while the raid path — whose raid1..raidN does
    include them — named them correctly. The two disagreed on the same question.
]]
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

--[[
    Setters, group-leader only (the game ignores the call otherwise). Selecting
    Master Loot needs a master looter, so default it to the leader who made the
    change; they can reassign from the standard ML window. Classic/TBC expose
    the legacy globals; guard in case a build lacks them.
]]
--[[
    The legacy SetLootMethod global follows GetLootMethod off the client: gone on
    1.15.9 while the threshold pair survives. Without the C_PartyInfo branch the
    guard returned silently and the dropdown looked broken — the method never
    changed and nothing said why.

    The modern call takes the numeric enum, not the string, so the value is
    mapped on the way out.
]]
---@param method string
---@return nil
function ns:SafeSetLootMethod(method)
	local masterLooterName = UnitName("player")

	if type(SetLootMethod) == "function" then
		if method == "master" then
			SetLootMethod("master", masterLooterName)
		else
			SetLootMethod(method)
		end
		return
	end

	if C_PartyInfo and type(C_PartyInfo.SetLootMethod) == "function" then
		local enumKey = ENUM_KEY_BY_METHOD[method]
		local enumValue = (Enum and Enum.LootMethod and enumKey and Enum.LootMethod[enumKey])
			or LOOT_METHOD_TO_ENUM[method]
		if not enumValue then
			return
		end
		if method == "master" then
			C_PartyInfo.SetLootMethod(enumValue, masterLooterName)
		else
			C_PartyInfo.SetLootMethod(enumValue)
		end
	end
end

---@param threshold number
---@return nil
function ns:SafeSetLootThreshold(threshold)
	if type(SetLootThreshold) == "function" then
		SetLootThreshold(threshold)
		return
	end
	if C_PartyInfo and type(C_PartyInfo.SetLootThreshold) == "function" then
		C_PartyInfo.SetLootThreshold(threshold)
	end
end

--------------------------------------------------------------------------------
-- Distribution Eligibility
--------------------------------------------------------------------------------

--[[
    Single shared check used by the distribution engine below (to decide
    whether to run the LOOT_OPENED distribution pass) and by Speedy-Loot.lua
    (to decide whether to defer). Returns true when GogoLoot will own the
    next loot session.
]]

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
    A loading screen re-syncs the party's loot state, so for a moment the loot
    API answers with the default — or with nothing at all — before the real
    method lands. A zoning master looter reads as "not the master looter", in a
    group whose method reads "group", and then as both again.

    Every consumer of that state has to ignore the gap, because each mistakes it
    for a real event: the pop-up reads it as a promotion, the destination reset
    reads it as the leader changing the loot method, and the leaver sweep reads a
    transiently empty roster as the group having emptied.

    Readings taken while the state is unreadable are ignored outright and
    deliberately NOT recorded. Freezing rather than updating is what keeps a
    genuine change that lands mid-loading-screen: the first reading afterwards
    still compares against the state from before it, so the change is noticed a
    beat late instead of never.
]]
local ZONE_SETTLE_SECONDS = 3
local ZONE_SETTLE_TIMER = "GogoLoot.MasterLooter.ZoneSettle"
local isZoneChangeSettling = false

local function BeginZoneChangeSettle()
	isZoneChangeSettling = true
	ns:After(ZONE_SETTLE_TIMER, ZONE_SETTLE_SECONDS, function()
		isZoneChangeSettling = false
	end)
end

---@return boolean
local function IsLootStateUnreadable()
	return isZoneChangeSettling or ns:SafeCallLootMethod() == nil
end

--------------------------------------------------------------------------------
-- Destination Management
--------------------------------------------------------------------------------

---@return table
function ns:GetGroupMemberNames()
	local memberNames = { ["self"] = L["MASTER_LOOTER_DESTINATION_SELF"] }
	local playerName = ns:GetLowercaseUnitName("player")

	for memberIndex = 1, GetNumGroupMembers() do
		local unitIdentifier = IsInRaid() and ("raid" .. memberIndex) or ("party" .. memberIndex)
		local memberName = ns:GetLowercaseUnitName(unitIdentifier)
		if memberName and memberName ~= playerName then
			memberNames[memberName] = ns:CapitalizeFirstLetter(memberName)
		end
	end

	return memberNames
end

--[[
    Display order for the destination dropdowns: Self first, then group members
    alphabetically. AceConfig sorts a values table by its labels otherwise, which
    would bury Self somewhere in the middle of the roster.
]]
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
	return sorting
end

--[[
    The destination shared by every quality tier, or nil when they disagree.
    Backs the Send All Loot To dropdown, which shows blank rather than picking
    one tier's answer to stand for all of them.
]]
---@return string|nil
function ns:GetSharedDestination()
	local shared
	local sawTier = false

	for quality = 0, 4 do
		local qualityKey = ns.rarityToConfigurationKey[quality]
		if qualityKey then
			local destination = ns.db.profile.destinations[qualityKey]
			--[[
                An explicit "no destination" is a value in its own right, so the
                comparison tracks whether a tier has been seen rather than
                whether `shared` is still nil. Otherwise an unset tier followed
                by an assigned one would report the assigned player as the
                answer for all five.
            ]]
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

--[[
    Writes one destination to every tier and announces once, not once per tier.
]]
---@param targetPlayerName string
---@return nil
function ns:SetAllDestinations(targetPlayerName)
	for quality = 0, 4 do
		local qualityKey = ns.rarityToConfigurationKey[quality]
		if qualityKey then
			ns.db.profile.destinations[qualityKey] = targetPlayerName
		end
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
		ns:GetDestinationDisplayName(targetPlayerName)
	)
end

---@param targetPlayerName string
---@return boolean
function ns:IsNonSelfDestination(targetPlayerName)
	if not targetPlayerName then
		return false
	end
	local targetLower = strlower(targetPlayerName)
	return targetLower ~= "self" and targetLower ~= "player"
end

--[[
    "self" is stored as a literal, so announcing it verbatim would tell the group
    that "Self" is holding the loot. Resolve it to the player's own name — which
    is also what makes switching BACK to yourself announceable at all: the group
    has already been told somebody else is holding loot, and silence would leave
    that standing.
]]
---@param targetPlayerName string
---@return string
function ns:GetDestinationDisplayName(targetPlayerName)
	if not ns:IsNonSelfDestination(targetPlayerName) then
		return ns:FormatPlayerName(ns:GetCleanUnitName("player"))
	end
	return ns:FormatPlayerName(targetPlayerName)
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
	local displayName = ns:GetDestinationDisplayName(targetPlayerName)
	local qualityLabel = ns.QUALITY_DISPLAY_NAMES[qualityKey] or ns:CapitalizeFirstLetter(qualityKey)
	ns:Announce(ns:GetGroupChatChannel(), nil, "MESSAGE_DESTINATION_SET", displayName, qualityLabel)
end

--[[
    Clears every tier to unset, not to Self. "Self" is a deliberate choice the
    master looter makes; leaving it behind after a setup ends reads as a live
    instruction to vacuum everything, and hides that nothing was actually chosen.
    An unset tier auto-distributes nothing and shows an empty dropdown, so the
    next setup starts from a blank slate.
]]
local function ResetAllDestinations()
	for quality = 0, 4 do
		local qualityKey = ns.rarityToConfigurationKey[quality]
		if qualityKey then
			ns.db.profile.destinations[qualityKey] = nil
		end
	end
end

local function GetCurrentGroupMemberLookup()
	local groupMembers = {}
	local myName = ns:GetLowercaseUnitName("player")
	if myName then
		groupMembers[myName] = true
	end
	for memberIndex = 1, GetNumGroupMembers() do
		local unitIdentifier = IsInRaid() and ("raid" .. memberIndex) or ("party" .. memberIndex)
		local memberName = ns:GetLowercaseUnitName(unitIdentifier)
		if memberName then
			groupMembers[memberName] = true
		end
	end
	return groupMembers
end

local function CheckDestinationsForLeavers()
	--[[
	    A roster read taken while a loading screen settles can come back empty,
	    which would reassign every tier to Self and announce a group's worth of
	    leavers who never left.
	]]
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
	local myName = ns:GetCleanUnitName("player")
	local masterLooterDisplayName = ns:FormatPlayerName(myName)
	local chatChannel = ns:GetGroupChatChannel()

	for quality = 0, 4 do
		local qualityKey = ns.rarityToConfigurationKey[quality]
		if qualityKey then
			local targetPlayerName = ns.db.profile.destinations[qualityKey]
			if ns:IsNonSelfDestination(targetPlayerName) then
				local targetLower = strlower(targetPlayerName)
				if not groupMembers[targetLower] then
					local leaverDisplayName = ns:FormatPlayerName(targetPlayerName)
					local qualityLabel = ns.QUALITY_DISPLAY_NAMES[qualityKey] or ns:CapitalizeFirstLetter(qualityKey)
					ns.db.profile.destinations[qualityKey] = "self"
					if ns.db.profile.announceDestinations then
						ns:Announce(
							chatChannel,
							nil,
							"MESSAGE_DESTINATION_LEFT",
							leaverDisplayName,
							masterLooterDisplayName,
							qualityLabel
						)
					end
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Dynamic Event Hooks — Group Roster & Loot Method Changes
--------------------------------------------------------------------------------

local wasInGroup = IsInGroup()

--[[
    The panel and the pop-up render the same rows, so a change made in either
    has to repaint both or the other keeps showing the stale value.
]]
---@return nil
function ns:RefreshMasterLooterPanels()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.MasterLooter)
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.MasterLooterPopup)
end

--[[
    Pop the master looter window on every false-to-true transition, tracked from
    a starting assumption of false so logging in already master looter counts as
    becoming one. Both events that can change the answer route through here, and
    the flag makes repeat fires of the same state a no-op.

    There is more than one way to be handed the role and all of them belong
    here: the leader naming you master looter (PARTY_LOOT_METHOD_CHANGED), and
    the role falling to you because whoever held it left
    (GROUP_ROSTER_UPDATE, which no loot-method event accompanies). Narrowing the
    trigger to the loot-method event would silently drop that second case.
]]
local wasMasterLooter = false

--[[
    Changing zones is not one of those ways, and used to read as one: a zoning
    master looter reads as "not the master looter" and then as one again, which
    is indistinguishable from a promotion, and GROUP_ROSTER_UPDATE fires freely
    throughout. IsLootStateUnreadable is what keeps that gap out of the flag —
    see the Loading-Screen Guard above for why the reading is frozen rather than
    recorded.
]]
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
    Destinations are scoped to one master-loot setup, so any change to the
    group's loot type drops them back to Self. Carrying them across would leave
    a stale "everything goes to Bob" armed and invisible, ready to route the next
    session's loot at whoever was named for the last one.

    The comparison is against the last method GogoLoot OBSERVED, and every event
    that could coincide with a change refreshes that observation — not just
    PARTY_LOOT_METHOD_CHANGED. Hanging the reset off that one event was not
    enough in practice: it is the leader's action, so it need not reach every
    member, and where it does fire the loot API has not necessarily caught up by
    the time the handler runs. GROUP_ROSTER_UPDATE fires far more freely, so
    whichever arrives first notices the new method and clears.

    Tracking the method rather than resetting on every fire is what keeps a
    master-looter reassignment — which changes no method — from wiping a setup
    mid-run. It starts nil so the first reading after login records state instead
    of counting as a change.

    A reading taken while the loot state is unreadable is skipped and not
    recorded, so a loading screen cannot wipe a live setup: ns:SafeGetLootMethod
    maps the client's nil answer to "group", which against a stored "master"
    reads as the leader having changed the method mid-zone. Freezing rather than
    recording is what keeps a genuine change that lands mid-loading-screen — the
    first reading afterwards still compares against the pre-zone method.
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

local function HandleLootMethodChanged()
	ClearDestinationsOnLootMethodChange()
	ns:RefreshMasterLooterPanels()
	CheckMasterLooterPopup()
end

local function HandleGroupRosterUpdate()
	local isCurrentlyInGroup = IsInGroup()

	-- Leaving a group ends the setup too, so the destinations go with it.
	if wasInGroup and not isCurrentlyInGroup then
		ResetAllDestinations()
		ns:RefreshMasterLooterPanels()
		wasInGroup = false
		wasMasterLooter = false
		lastObservedLootMethod = nil
		return
	end

	wasInGroup = isCurrentlyInGroup

	ClearDestinationsOnLootMethodChange()
	CheckDestinationsForLeavers()
	ns:RefreshMasterLooterPanels()
	CheckMasterLooterPopup()
end

--[[
    Login and /reload are the two loading screens the pop-up is meant to answer
    from a standing start — wasMasterLooter begins false, so already holding the
    role counts as taking it. PLAYER_ENTERING_WORLD reports which case it is, and
    every other fire of it is a mid-session loading screen: a zone change.
]]
local function HandlePlayerEnteringWorld(isInitialLogin, isReloadingUi)
	if isInitialLogin or isReloadingUi then
		return
	end
	BeginZoneChangeSettle()
end

ns:RegisterModuleEvent("PARTY_LOOT_METHOD_CHANGED", HandleLootMethodChanged)
ns:RegisterModuleEvent("GROUP_ROSTER_UPDATE", HandleGroupRosterUpdate)
ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", HandlePlayerEnteringWorld)
-- Crossing a zone border without a loading screen, which PLAYER_ENTERING_WORLD does not report.
ns:RegisterModuleEvent("ZONE_CHANGED_NEW_AREA", BeginZoneChangeSettle)
