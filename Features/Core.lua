--------------------------------------------------------------------------------
-- GogoLoot Core
--------------------------------------------------------------------------------
local ADDON_NAME, ns = ...

--------------------------------------------------------------------------------
-- Version
--------------------------------------------------------------------------------

local function GetVersion()
	local version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")
	if not version or version:find("@") then
		return "Dev"
	end
	return version
end

ns.Version = GetVersion()

--------------------------------------------------------------------------------
-- Default Ignore List Builders
--------------------------------------------------------------------------------

-- A row whose item this client doesn't have is skipped: saved, it could never load.
---@param rows table[] # { itemId, value? } rows from a flavor folder
---@param valueFor function # (row) -> the value to store for that item
---@return table
local function BuildListFromRows(rows, valueFor)
	local list = {}
	for _, row in ipairs(rows) do
		if C_Item.DoesItemExistByID(row[1]) then
			list[row[1]] = valueFor(row)
		end
	end
	return list
end

---@return table
function ns:BuildDefaultIgnoreListSolo()
	return BuildListFromRows(ns.DEFAULT_IGNORE_LIST_SOLO, function(row)
		return row[2]
	end)
end

---@return table
function ns:BuildDefaultIgnoreListMaster()
	return BuildListFromRows(ns.DEFAULT_IGNORE_LIST_MASTER, function()
		return true
	end)
end

--------------------------------------------------------------------------------
-- Saved Variables (AceDB-3.0)
--------------------------------------------------------------------------------

--[[
    Loot policy lives in ns.db.profile. Decisions about the client, the items
    and the screen live in ns.db.global, so a profile switch, reset or delete
    never touches them; per-character state lives in ns.db.char. AceDB applies
    ns.DATABASE_DEFAULTS: there is no manual defaults merge.
]]

-- Deliberate: an empty item list means "never configured" and is re-seeded.
local function RebuildEmptyItemLists()
	local profile = ns.db.profile
	if next(profile.ignoredItemsMaster) == nil then
		profile.ignoredItemsMaster = ns:BuildDefaultIgnoreListMaster()
	end
	if next(profile.ignoredItemsSolo) == nil then
		profile.ignoredItemsSolo = ns:BuildDefaultIgnoreListSolo()
	end
end

--[[
    The new profile's tables replace the old ones wholesale, so everything that
    caches or shows profile state repaints here. Each hook is nil-guarded: a
    file a flavor's TOC leaves out drops its repaint.
]]
---@return nil
function ns:ApplyProfile()
	RebuildEmptyItemLists()
	if ns.IsAutoLootNeeded and ns:IsAutoLootNeeded() then
		ns.EnsureAutoLoot()
	end
	if ns.ScheduleOpeningScan then
		ns.ScheduleOpeningScan(true)
	end
	if ns.ApplyLootToastSettings then
		ns.ApplyLootToastSettings()
	end
	if ns.ApplyMinimapButton then
		ns:ApplyMinimapButton()
	end
	if ns.SyncStandardLootMessages then
		ns.SyncStandardLootMessages()
	end
	if ns.SyncBlizzardRollWonWindow then
		ns.SyncBlizzardRollWonWindow()
	end
	if ns.SyncTradeCheckbox then
		ns:SyncTradeCheckbox()
	end
	if ns.RefreshTradableTints then
		ns:RefreshTradableTints()
	end
	ns.RefreshSettings()
end

--------------------------------------------------------------------------------
-- Event Dispatcher
--------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame", "GogoLootEventFrame", UIParent)
ns.eventHandlers = {}

--[[
    Every event the add-on registers, sorted. Diagnostics reads this list rather
    than the live handler table, so it also sees on-demand, self-unregistering
    events. RegisterModuleEvent warns on an event missing from here.
]]
ns.EVENT_NAMES = {
	"ADDON_LOADED",
	"BAG_NEW_ITEMS_UPDATED",
	"BAG_UPDATE_DELAYED",
	"BANKFRAME_CLOSED",
	"CANCEL_LOOT_ROLL",
	"CHAT_MSG_ADDON",
	"CHAT_MSG_CURRENCY",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_LOOT",
	"CHAT_MSG_MONEY",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_SYSTEM",
	"CONFIRM_LOOT_ROLL",
	"ENCOUNTER_END",
	"GET_ITEM_INFO_RECEIVED",
	"GOSSIP_CLOSED",
	"GROUP_ROSTER_UPDATE",
	"LOADING_SCREEN_DISABLED",
	"LOADING_SCREEN_ENABLED",
	"LOOT_CLOSED",
	"LOOT_OPENED",
	"LOOT_READY",
	"LOOT_SLOT_CLEARED",
	"MAIL_CLOSED",
	"MERCHANT_CLOSED",
	"PARTY_LOOT_METHOD_CHANGED",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_EQUIPMENT_CHANGED",
	"PLAYER_INTERACTION_MANAGER_FRAME_HIDE",
	"PLAYER_LEVEL_UP",
	"PLAYER_LOGIN",
	"PLAYER_REGEN_ENABLED",
	"QUEST_FINISHED",
	"START_LOOT_ROLL",
	"TRADE_ACCEPT_UPDATE",
	"TRADE_CLOSED",
	"TRADE_REQUEST_CANCEL",
	"TRADE_SHOW",
	"UI_ERROR_MESSAGE",
	"UI_INFO_MESSAGE",
	"UNIT_SPELLCAST_SUCCEEDED",
	"UPDATE_CHAT_WINDOWS",
	"UPDATE_STEALTH",
	"ZONE_CHANGED_NEW_AREA",
}

local knownEventNames = {}
for _, eventName in ipairs(ns.EVENT_NAMES) do
	knownEventNames[eventName] = true
end
local warnedUnlistedEvents = {}

-- The unit filter each registered event went on with; nil for an ordinary event.
local eventUnits = {}
local warnedUnitConflicts = {}

-- ns:PrintMessage doesn't exist until Announcements.lua loads, after Core.
local function PrintDeveloperWarning(warning)
	if ns.PrintMessage then
		ns:PrintMessage(warning)
	else
		print(warning)
	end
end

--[[
    One frame carries one unit filter per event: every handler on a unit event
    hears the first registration's unit, and a different one warns once.

    An event this client doesn't have is dropped with its handler: RegisterEvent
    would error and stop the asking file mid-load. Diagnostics reports it.
]]
---@param eventName string
---@param handlerFunction function
---@param unit? string
---@return nil
function ns:RegisterModuleEvent(eventName, handlerFunction, unit)
	if not knownEventNames[eventName] and not warnedUnlistedEvents[eventName] then
		warnedUnlistedEvents[eventName] = true
		PrintDeveloperWarning(
			"Developer warning: event '"
				.. eventName
				.. "' is registered but missing from ns.EVENT_NAMES (Core.lua). Add it so Diagnostics stays in sync."
		)
	end
	if not C_EventUtils.IsEventValid(eventName) then
		return
	end
	if not ns.eventHandlers[eventName] then
		ns.eventHandlers[eventName] = {}
		eventUnits[eventName] = unit
		if unit then
			eventFrame:RegisterUnitEvent(eventName, unit)
		else
			eventFrame:RegisterEvent(eventName)
		end
	elseif eventUnits[eventName] ~= unit and not warnedUnitConflicts[eventName] then
		warnedUnitConflicts[eventName] = true
		PrintDeveloperWarning(
			"Developer warning: event '"
				.. eventName
				.. "' is registered with two different unit filters. Every handler hears the first one."
		)
	end
	table.insert(ns.eventHandlers[eventName], handlerFunction)
end

-- Never call from inside an event handler: OnEvent iterates the live list.
---@param eventName string
---@param handlerFunction function
---@return nil
function ns:UnregisterModuleEvent(eventName, handlerFunction)
	local handlers = ns.eventHandlers[eventName]
	if not handlers then
		return
	end
	for handlerIndex = #handlers, 1, -1 do
		if handlers[handlerIndex] == handlerFunction then
			table.remove(handlers, handlerIndex)
		end
	end
	if #handlers == 0 then
		ns.eventHandlers[eventName] = nil
		eventUnits[eventName] = nil
		eventFrame:UnregisterEvent(eventName)
	end
end

eventFrame:SetScript("OnEvent", function(self, eventName, ...)
	if ns.diagnostics.logging then
		ns:LogEvent(eventName, ...)
	end
	local handlers = ns.eventHandlers[eventName]
	if handlers then
		-- A handler's error goes to the error handler, and the handlers after it still run.
		for _, handlerFunction in ipairs(handlers) do
			securecallfunction(handlerFunction, ...)
		end
	end
end)

--[[
    Character Rules lists the account's characters from their char sections and
    colors each by the class saved here. It also keeps a character with no rules
    in that list: AceDB drops an empty char section at logout.
]]
local function RecordCharacterClass()
	local _, classFile = UnitClass("player")
	if classFile then
		ns.db.char.classFile = classFile
	end
end

--[[
    AceDB keys a character "Name - Realm" on realm clients and "First Last" on
    WoW Forever, so a key shaped the other way came from a copied WTF folder and
    is silently dropped, with its profile unless someone still uses it.
]]
local REALM_KEY_SEPARATOR = " - "

---@param characterKey any
---@param realmClient boolean
---@return boolean
local function IsOtherClientKey(characterKey, realmClient)
	if type(characterKey) ~= "string" then
		return true
	end
	return (characterKey:find(REALM_KEY_SEPARATOR, 1, true) ~= nil) ~= realmClient
end

---@param sv table # the saved table, or one of its namespaces
---@param realmClient boolean
---@param profilesInUse table<string, boolean>
---@return nil
local function PruneSavedTable(sv, realmClient, profilesInUse)
	local pruned = {}
	for _, section in ipairs({ "char", "profileKeys" }) do
		local characters = sv[section]
		if type(characters) == "table" then
			for characterKey in pairs(characters) do
				if IsOtherClientKey(characterKey, realmClient) then
					characters[characterKey] = nil
					pruned[characterKey] = true
				end
			end
		end
	end
	if type(sv.profiles) == "table" then
		for characterKey in pairs(pruned) do
			if not profilesInUse[characterKey] then
				sv.profiles[characterKey] = nil
			end
		end
	end
end

---@return nil
local function PruneOtherClientCharacters()
	local currentKey = ns.db.keys and ns.db.keys.char
	local sv = ns.db.sv
	if type(currentKey) ~= "string" or type(sv) ~= "table" then
		return
	end
	local realmClient = currentKey:find(REALM_KEY_SEPARATOR, 1, true) ~= nil
	local profilesInUse = { [ns.db.keys.profile or ""] = true }
	for characterKey, profileName in pairs(sv.profileKeys or {}) do
		if not IsOtherClientKey(characterKey, realmClient) then
			profilesInUse[profileName] = true
		end
	end
	PruneSavedTable(sv, realmClient, profilesInUse)
	for _, namespace in pairs(sv.namespaces or {}) do
		if type(namespace) == "table" then
			PruneSavedTable(namespace, realmClient, profilesInUse)
		end
	end
end

--[[
    MIGRATION (remove after 2026-12-16): the mini-map button's position and
    its Enable Mini-map Button preference moved from ns.db.global.minimap to
    ns.db.profile.minimap, since GogoLoot keeps the Simple save model (Style
    Guide → MINIMAP BUTTON → Building the Button). The old table is copied to
    every saved profile that has none of its own, so no button moves, then
    dropped; with it gone, this does nothing on later loads.
]]
---@return nil
local function MoveMinimapPositionToProfile()
	local sv = ns.db.sv
	local old = sv and type(sv.global) == "table" and sv.global.minimap
	if type(old) ~= "table" then
		return
	end
	local current = ns.db.profile.minimap
	if next(current) == nil then
		for key, value in pairs(old) do
			current[key] = value
		end
	end
	for _, profile in pairs(sv.profiles or {}) do
		if type(profile) == "table" and profile.minimap == nil then
			local copy = {}
			for key, value in pairs(old) do
				copy[key] = value
			end
			profile.minimap = copy
		end
	end
	sv.global.minimap = nil
end

--[[
    MIGRATION (remove after 2026-12-16): Include Bind on Pickup split from one
    switch, rollBindOnPickup, into one per group context, rollBindOnPickupParty
    and rollBindOnPickupRaid. Every saved profile that set the old switch gets
    its value in both, so nothing rolls differently, and the old key is
    dropped; with it gone, this does nothing on later loads.
]]
---@return nil
local function SplitBindOnPickupByContext()
	local sv = ns.db.sv
	for _, profile in pairs(sv and sv.profiles or {}) do
		--[[
		    The old key survives only on a profile never split, so the new keys
		    hold nothing the player chose: on the active profile they are
		    AceDB's defaults, already written into the table by the time this
		    runs. Copy unconditionally.
		]]
		if type(profile) == "table" and profile.rollBindOnPickup ~= nil then
			profile.rollBindOnPickupParty = profile.rollBindOnPickup
			profile.rollBindOnPickupRaid = profile.rollBindOnPickup
			profile.rollBindOnPickup = nil
		end
	end
end

local function OnAddonLoaded(loadedAddonName)
	if loadedAddonName ~= ADDON_NAME then
		return
	end

	ns.db = LibStub("AceDB-3.0"):New("GogoLootDB", ns.DATABASE_DEFAULTS, true)
	PruneOtherClientCharacters()
	RebuildEmptyItemLists()
	RecordCharacterClass()
	ns.DropOldCharacterRules() -- MIGRATION (remove after 2026-12-07)
	ns.DropRetiredCharacterRuleKeys() -- MIGRATION (remove after 2026-12-16)
	MoveMinimapPositionToProfile() -- MIGRATION (remove after 2026-12-16)
	SplitBindOnPickupByContext() -- MIGRATION (remove after 2026-12-16)
	for _, msg in ipairs({ "OnProfileChanged", "OnProfileReset", "OnProfileCopied" }) do
		ns.db.RegisterCallback(ns, msg, "ApplyProfile")
	end

	if ns.InitMinimap then
		ns:InitMinimap()
	end
	if ns.RegisterOptionsPanels then
		ns.RegisterOptionsPanels()
	end
end

ns:RegisterModuleEvent("ADDON_LOADED", OnAddonLoaded)
