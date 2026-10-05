--------------------------------------------------------------------------------
-- GogoLoot Core
--------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

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

--[[
    A default row whose item this client doesn't have is never seeded. The
    flavor folders should hold no such row (Validate Data flags one as NOT ON
    CLIENT), and this is the check that keeps a slip there out of the saved
    list, where it could never load.
]]
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
    GogoLootDB is an AceDB-3.0 database: every profile is stored account-wide in
    GogoLootDB.profiles, each character's active profile choice in
    GogoLootDB.profileKeys, and loot policy lives inside the active profile
    (ns.db.profile). The three presentation keys (showWelcome, speedyLoot and
    minimap) live in ns.db.global instead, so switching, resetting, or deleting
    a profile never moves the button or turns them back on. So do the player's
    Openables List choices (openingActions) and where the loot toasts sit
    (lootToastPosition), which are decisions about the items and the screen
    rather than about a loot setup.

    Defaults come from ns.DATABASE_DEFAULTS in Data/Default-Settings.lua. There
    is no manual defaults merge anywhere in the add-on.
]]

--[[
    Deliberate refill-on-empty: an empty item list is treated as "never
    configured", so this client's default lists are re-seeded. Runs on load
    and again whenever the active profile changes or resets.
]]
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
    MIGRATION (remove after 2026-10-28): saved data from before the options
    rework. The Master Looter panel's tier rows always show now, so the toggle
    that collapsed them (global.showDestinationTiers) is gone. The Openables
    List's choices were Open, Open when Unlocked and three Ignores; they are
    Open and Ignore now, each keeping what it did, and a choice that lands on
    its item's default is dropped, since only changes are saved.
]]
local LEGACY_OPENING_ACTIONS = {
	UNLOCKED = ns.OPENING_OPEN,
	IGNORE_RAID = ns.OPENING_IGNORE,
	IGNORE_UNIQUE = ns.OPENING_IGNORE,
}

--[[
    MIGRATION (remove after 2026-11-03): the loot toast filters before the
    Mine and Group rows. Toasts took a minimum quality for the player's own
    loot, nine Always Show kinds that skipped it, and, under Whose Loot's Whole
    Group, one minimum quality for everyone else's. Each saved profile keeps
    what it showed: the old minimum becomes the quality on the rarity rows, a
    switched-off kind turns its rows off, and the item types that answered to
    the minimum alone, mostly whites and greys, turn off once it reached
    Uncommon. A Whole Group profile ticks the group's rarity rows at its old
    Group Quality, and every other item type too when that reached down to
    Common. A raw saved profile holds only what differed from the old defaults
    (Poor, Mine, Uncommon, every kind on), so an absent key is a default.
    Report Each Roll is gone.
]]
local LEGACY_ALWAYS_SHOW_ROWS = {
	lootToastBindOnPickup = { "BIND_ON_PICKUP" },
	lootToastQuestItems = { "QUEST" },
	lootToastRecipes = { "RECIPE" },
	lootToastMounts = { "MOUNT" },
	lootToastPets = { "COMPANION_PET" },
	lootToastKeys = { "KEY" },
	lootToastBags = { "CONTAINER", "QUIVER" },
	lootToastContainers = { "OPENABLES" },
}
local LEGACY_THRESHOLD_ONLY_ROWS = { "CONSUMABLE", "MISCELLANEOUS", "PROJECTILE", "REAGENT" }
local LEGACY_GROUP_DEFAULT_THRESHOLD = 2

local function MigrateLootToastFilters(profile)
	local mine, mineQuality = profile.lootToastMine or {}, profile.lootToastMineQuality or {}
	local threshold = profile.lootToastThreshold
	if threshold and threshold > 0 then
		for _, row in ipairs(ns.LOOT_TOAST_FILTER_ROWS) do
			if row.rarity then
				mineQuality[row.key] = threshold
			end
		end
		for legacyKey, rowKeys in pairs(LEGACY_ALWAYS_SHOW_ROWS) do
			if profile[legacyKey] == false then
				for _, rowKey in ipairs(rowKeys) do
					mine[rowKey] = false
				end
			end
		end
		if threshold >= LEGACY_GROUP_DEFAULT_THRESHOLD then
			for _, rowKey in ipairs(LEGACY_THRESHOLD_ONLY_ROWS) do
				mine[rowKey] = false
			end
		end
	end
	if profile.lootToastMoney == false then
		mine.MONEY = false
	end
	if next(mine) then
		profile.lootToastMine = mine
	end
	if next(mineQuality) then
		profile.lootToastMineQuality = mineQuality
	end

	if profile.lootToastSource == "GROUP" then
		local groupThreshold = profile.lootToastGroupThreshold or LEGACY_GROUP_DEFAULT_THRESHOLD
		local group, groupQuality = profile.lootToastGroup or {}, profile.lootToastGroupQuality or {}
		for _, row in ipairs(ns.LOOT_TOAST_FILTER_ROWS) do
			if row.rarity then
				group[row.key] = true
				groupQuality[row.key] = groupThreshold
			elseif row.classIdentifier and groupThreshold < LEGACY_GROUP_DEFAULT_THRESHOLD then
				group[row.key] = true
			end
		end
		profile.lootToastGroup = group
		profile.lootToastGroupQuality = groupQuality
	end

	profile.lootToastThreshold = nil
	profile.lootToastSource = nil
	profile.lootToastGroupThreshold = nil
	profile.lootToastMoney = nil
	for legacyKey in pairs(LEGACY_ALWAYS_SHOW_ROWS) do
		profile[legacyKey] = nil
	end
	profile.autoRollReport = nil
end

-- MIGRATION (remove after 2026-11-03): every saved profile's loot toast filters.
local function MigrateLootToastProfiles()
	for _, profile in pairs(ns.db.sv.profiles or {}) do
		MigrateLootToastFilters(profile)
	end
end

-- MIGRATION (remove after 2026-10-28): the options rework's account-wide keys.
local function MigrateOptionsRework()
	ns.db.global.showDestinationTiers = nil
	local savedActions = ns.db.global.openingActions
	for itemIdentifier, action in pairs(savedActions) do
		local mapped = LEGACY_OPENING_ACTIONS[action]
		if mapped then
			if mapped == ns:GetDefaultOpeningAction(itemIdentifier) then
				savedActions[itemIdentifier] = nil
			else
				savedActions[itemIdentifier] = mapped
			end
		end
	end
end

--[[
    Fired on OnProfileChanged / OnProfileCopied / OnProfileReset. The new
    profile's tables replace the old ones wholesale, so everything that
    caches or displays profile state is repainted here: the item lists re-seed
    if empty, Auto Loot is enforced if the new profile opens containers, the
    opening queue is rebuilt under the new profile's rules, the loot toasts take
    the new profile's look, the minimap icon re-reads autoGreed, the General tab's loot lines follow a changed Loot Toasts setting, the trade
    checkbox re-reads announceTrade, and every options panel repaints. The
    minimap position is account-wide (ns.db.global.minimap), so it is not
    re-pointed on a profile switch; the icon refresh only reflects the new
    profile's autoGreed state.
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
	if ns.UpdateMinimapIcon then
		ns:UpdateMinimapIcon()
	end
	if ns.SyncStandardLootMessages then
		ns.SyncStandardLootMessages()
	end
	if ns.SyncTradeCheckbox then
		ns:SyncTradeCheckbox()
	end
	for _, registryName in pairs(ns.OPTIONS_REGISTRY) do
		AceConfigRegistry:NotifyChange(registryName)
	end
end

--------------------------------------------------------------------------------
-- Event Dispatcher
--------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame", "GogoLootEventFrame", UIParent)
ns.eventHandlers = {}

--[[
    The exported single source of truth for every event the add-on registers.
    Core's dispatcher fans out from ns.eventHandlers, and the diagnostics Event
    Registration probe (Diagnostics/Code-Reports.lua) reads THIS list, so the probe
    can never drift from the events the add-on actually uses — including
    on-demand, self-unregistering ones like the item lists'
    GET_ITEM_INFO_RECEIVED watcher, which would be absent from the live handler
    table at probe time. Update this list whenever a module starts registering a
    new event: RegisterModuleEvent prints a developer warning if handed an event
    missing from here. Kept sorted alphabetically.
]]
ns.EVENT_NAMES = {
	"ADDON_LOADED",
	"BAG_NEW_ITEMS_UPDATED",
	"BAG_UPDATE_DELAYED",
	"BANKFRAME_CLOSED",
	"CANCEL_LOOT_ROLL",
	"CHAT_MSG_LOOT",
	"CHAT_MSG_MONEY",
	"CONFIRM_LOOT_ROLL",
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

-- Membership set for the drift guard below, plus the events already warned about.
local knownEventNames = {}
for _, eventName in ipairs(ns.EVENT_NAMES) do
	knownEventNames[eventName] = true
end
local warnedUnlistedEvents = {}

-- The unit filter each registered event went on with; nil for an ordinary event.
local eventUnits = {}
local warnedUnitConflicts = {}

--[[
    ns:PrintMessage isn't defined until Announcements.lua loads (after Core), so
    Core's own registrations fall back to print.
]]
local function PrintDeveloperWarning(warning)
	if ns.PrintMessage then
		ns:PrintMessage(warning)
	else
		print(warning)
	end
end

--[[
    `unit` registers through RegisterUnitEvent, so the frame wakes only for that
    unit: UNIT_SPELLCAST_SUCCEEDED fires for every caster in range, and only the
    player's own casts matter. One frame carries one filter per event, so every
    handler on a unit event shares the first registration's unit; asking for a
    different one warns once rather than silently hearing the wrong unit.

    An event this client doesn't have is never registered: RegisterEvent errors
    on an unknown name, which would stop the file that asked partway through its
    load. Its handler is dropped with it, and the Event Registration probe in
    Diagnostics reports the name as invalid on this client.
]]
---@param eventName string
---@param handlerFunction function
---@param unit? string
---@return nil
function ns:RegisterModuleEvent(eventName, handlerFunction, unit)
	--[[
        Fail loud in dev when an event is registered without being added to
        ns.EVENT_NAMES, so the diagnostics probe never silently misses it. Once
        per event name.
    ]]
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

--[[
    Not safe to call from inside an event handler — OnEvent iterates the
    live handler list. Call it from timers or user-driven code paths.
]]
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
	-- Diagnostics event-log tap: boolean checks gate all work, so this costs nothing when logging is off.
	if ns.diagnostics and ns.diagnostics.logging then
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
    The character's class, saved in its own AceDB char section (ns.db.char),
    which is where Character Rules finds the account's characters: another
    character's name is drawn in the class color it saved at its last login.
    It also keeps a character with no rules yet in that list, since AceDB drops
    an empty char section at logout.
]]
local function RecordCharacterClass()
	local _, classFile = UnitClass("player")
	if classFile then
		ns.db.char.classFile = classFile
	end
end

local function OnAddonLoaded(loadedAddonName)
	if loadedAddonName ~= ADDON_NAME then
		return
	end

	ns.db = LibStub("AceDB-3.0"):New("GogoLootDB", ns.DATABASE_DEFAULTS, true)
	MigrateLootToastProfiles() -- MIGRATION (remove after 2026-11-03)
	MigrateOptionsRework() -- MIGRATION (remove after 2026-10-28)
	RebuildEmptyItemLists()
	RecordCharacterClass()
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
