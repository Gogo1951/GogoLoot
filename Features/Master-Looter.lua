--------------------------------------------------------------------------------
-- GogoLoot Master Loot Module
--------------------------------------------------------------------------------

--[[
    Master Loot configuration plumbing:
      * Loot method and threshold wrappers over Utilities' accessors, mapping
        between method strings and Enum.LootMethod values.
      * Eligibility check (WillAutoMasterLoot) for the distribution engine in
        Master-Looter-Distribution.lua.
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
    The loot method crosses the API boundary as an Enum.LootMethod number on the
    C_PartyInfo API and as a string on the legacy one, so one table owns the
    mapping in both directions.
]]
local LOOT_METHOD_BY_ENUM = {
	[Enum.LootMethod.Freeforall] = "freeforall",
	[Enum.LootMethod.Roundrobin] = "roundrobin",
	[Enum.LootMethod.Masterlooter] = "master",
	[Enum.LootMethod.Group] = "group",
	[Enum.LootMethod.Needbeforegreed] = "needbeforegreed",
}

local LOOT_METHOD_TO_ENUM = {}
for enumValue, methodName in pairs(LOOT_METHOD_BY_ENUM) do
	LOOT_METHOD_TO_ENUM[methodName] = enumValue
end

---@return string # one of freeforall / roundrobin / master / group / needbeforegreed
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

    Check "player" first: a party's unit ids run party1..partyN-1 and never
    include the player, so walking them alone misses a party the player leads,
    while a raid's raid1..raidN does include them.
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
    change; they can reassign from the standard ML window. The C_PartyInfo
    setter takes the numeric enum rather than the string, so the method is
    mapped on the way out (ns.SET_LOOT_METHOD_TAKES_ENUM, Utilities.lua).
]]
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
		ns.SetLootMethod(methodValue, UnitName("player"))
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

--[[
    The check the distribution engine (Master-Looter-Distribution.lua) makes
    before its LOOT_OPENED pass, also shown in the Diagnostics Loot Method
    report. Returns true when GogoLoot will own the next loot session. Speedy
    Loot stands down on the wider ns:AreWeMasterLooter instead.
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

--[[
    Every destination dropdown's choices: Loot Window, which leaves the quality
    in the loot window for the player, then Self, then the group.
]]
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

--[[
    Display order for the destination dropdowns: Loot Window, then Self, then
    group members alphabetically. The dropdown sorts by key otherwise, which
    would file those two somewhere among the lowercased names.
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
	table.insert(sorting, 1, ns.DESTINATION_LOOT_WINDOW)
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
		local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[quality]
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
    What a quality's destination dropdown shows: its player, or Loot Window
    while nobody is picked. Loot Window is never saved, so an unset quality and
    one sent back to the loot window are the same thing.
]]
---@param qualityKey string
---@return string
function ns:GetDestinationChoice(qualityKey)
	local destination = ns.db.profile.destinations[qualityKey]
	if not destination or destination == "" then
		return ns.DESTINATION_LOOT_WINDOW
	end
	return destination
end

-- Send All Loot To's reading: Loot Window while no quality has anybody, otherwise the shared player or blank.
---@return string|nil
function ns:GetSharedDestinationChoice()
	for quality = 0, 4 do
		local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[quality]
		if qualityKey and ns:GetDestinationChoice(qualityKey) ~= ns.DESTINATION_LOOT_WINDOW then
			return ns:GetSharedDestination()
		end
	end
	return ns.DESTINATION_LOOT_WINDOW
end

--[[
    Writes one destination to every tier and announces once, not once per tier.
    Loot Window clears every tier instead, and says nothing: nobody is holding
    anything for the group, and the loot window is where the master looter
    hands it out by hand.
]]
---@param targetPlayerName string
---@return nil
function ns:SetAllDestinations(targetPlayerName)
	local destination = targetPlayerName ~= ns.DESTINATION_LOOT_WINDOW and targetPlayerName or nil
	for quality = 0, 4 do
		local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[quality]
		if qualityKey then
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
		ns:GetDestinationDisplayName(targetPlayerName)
	)
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
    "self" is stored as a literal, so announcing it verbatim would tell the group
    that "Self" is holding the loot. Resolve it to the player's own name — which
    is also what makes switching BACK to yourself announceable at all: the group
    has already been told somebody else is holding loot, and silence would leave
    that standing.
]]
---@param targetPlayerName string
---@return string
function ns:GetDestinationDisplayName(targetPlayerName)
	if not IsNonSelfDestination(targetPlayerName) then
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
    An unset tier auto-distributes nothing and reads as Loot Window, so the
    next setup starts from a blank slate.
]]
local function ResetAllDestinations()
	for quality = 0, 4 do
		local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[quality]
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

	-- One line per leaver, naming every quality they held, rather than one per quality.
	local leavers, leaverOrder = {}, {}
	local tierCount = 0
	for quality = 0, 4 do
		local qualityKey = ns.RARITY_TO_CONFIGURATION_KEY[quality]
		if qualityKey then
			tierCount = tierCount + 1
			local targetPlayerName = ns.db.profile.destinations[qualityKey]
			if IsNonSelfDestination(targetPlayerName) then
				local targetLower = strlower(targetPlayerName)
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
    The Master Looter panel and the pop-up render the same rows, so a change made
    in either has to repaint both or the other keeps showing the stale value. The
    panel also redraws on its own inputs: the roster fills its destination
    dropdowns and the loot threshold decides which quality rows show.
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
    Changing zones is not one of those ways, though it reads like one: a zoning
    master looter reads as "not the master looter" and then as one again, which
    is indistinguishable from a promotion, and GROUP_ROSTER_UPDATE fires freely
    throughout. IsLootStateUnreadable keeps that gap out of the flag; see the
    Loading-Screen Guard above for why the reading is frozen rather than
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
    group's loot type clears them to unset. Carrying them across would leave
    a stale "everything goes to Bob" armed and invisible, ready to route the next
    session's loot at whoever was named for the last one.

    The comparison is against the last method GogoLoot OBSERVED, and every event
    that could coincide with a change refreshes that observation, not just
    PARTY_LOOT_METHOD_CHANGED. That event alone is not enough: it is the
    leader's action, so it need not reach every member, and where it does fire
    the loot API may not have caught up by the time the handler runs.
    GROUP_ROSTER_UPDATE fires far more freely, so whichever arrives first
    notices the new method and clears.

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

local function OnPartyLootMethodChanged()
	ClearDestinationsOnLootMethodChange()
	ns:RefreshMasterLooterPanels()
	CheckMasterLooterPopup()
end

--[[
    What the panels draw from the roster: its names, the leader, the loot
    method and threshold. GROUP_ROSTER_UPDATE fires for far more than that
    (members going offline, changing subgroups), and every repaint closes a
    dropdown the master looter has open, so a roster update repaints only
    when this changes.
]]
local lastPanelSignature = nil

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

	-- Leaving a group ends the setup too, so the destinations go with it.
	if wasInGroup and not isCurrentlyInGroup then
		ResetAllDestinations()
		lastPanelSignature = nil
		ns:RefreshMasterLooterPanels()
		wasInGroup = false
		wasMasterLooter = false
		lastObservedLootMethod = nil
		return
	end

	wasInGroup = isCurrentlyInGroup

	ClearDestinationsOnLootMethodChange()
	CheckDestinationsForLeavers()
	local signature = PanelSignature()
	if signature ~= lastPanelSignature then
		lastPanelSignature = signature
		ns:RefreshMasterLooterPanels()
	end
	CheckMasterLooterPopup()
end

--[[
    Login and /reload are the two loading screens the pop-up is meant to answer
    from a standing start — wasMasterLooter begins false, so already holding the
    role counts as taking it. PLAYER_ENTERING_WORLD reports which case it is, and
    every other fire of it is a mid-session loading screen: a zone change.
]]
local function OnPlayerEnteringWorld(isInitialLogin, isReloadingUi)
	if isInitialLogin or isReloadingUi then
		return
	end
	BeginZoneChangeSettle()
end

-- Crossing a zone border without a loading screen, which PLAYER_ENTERING_WORLD does not report.
local function OnZoneChangedNewArea()
	BeginZoneChangeSettle()
end

ns:RegisterModuleEvent("PARTY_LOOT_METHOD_CHANGED", OnPartyLootMethodChanged)
ns:RegisterModuleEvent("GROUP_ROSTER_UPDATE", OnGroupRosterUpdate)
ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
ns:RegisterModuleEvent("ZONE_CHANGED_NEW_AREA", OnZoneChangedNewArea)
