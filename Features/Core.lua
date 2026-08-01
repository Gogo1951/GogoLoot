--------------------------------------------------------------------------------
-- GogoLoot Core
--------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
local L = ns.L
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--------------------------------------------------------------------------------
-- Version
--------------------------------------------------------------------------------

local function GetVersion()
	local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
	local version = GetAddOnMetadata(ADDON_NAME, "Version")
	if not version or version:find("@") then
		return "Dev"
	end
	return version
end

ns.Version = GetVersion()

--------------------------------------------------------------------------------
-- Default Ignore List Builders
--------------------------------------------------------------------------------

---@return table
function ns:BuildDefaultIgnoreListSolo()
	local list = {}
	for identifier, data in pairs(ns.DEFAULT_IGNORE_LIST_SOLO) do
		if data[1] <= ns.currentExpansion then
			list[identifier] = ns.ROLL_OVERRIDE_FROM_INDEX[data[2]] or ns.MANUAL
		end
	end
	return list
end

---@return table
function ns:BuildDefaultIgnoreListMaster()
	local list = {}
	for identifier, data in pairs(ns.DEFAULT_IGNORE_LIST_MASTER) do
		if data[1] <= ns.currentExpansion then
			list[identifier] = true
		end
	end
	return list
end

--------------------------------------------------------------------------------
-- Saved Variables (AceDB-3.0)
--------------------------------------------------------------------------------

--[[
    GogoLootDB is an AceDB-3.0 database: every profile is stored account-wide in
    GogoLootDB.profiles, each character's active profile choice in
    GogoLootDB.profileKeys, and loot policy lives inside the active profile
    (ns.db.profile). The three presentation keys — showWelcome, speedyLoot, and
    minimap — live in ns.db.global instead, so switching, resetting, or deleting
    a profile never moves the button or turns them back on.

    Defaults come from ns.DATABASE_DEFAULTS in Data/Default-Settings.lua, and
    AceDB physically copies them into the saved table (copyDefaults via rawset)
    rather than resolving them through a metatable — only * / ** wildcard
    defaults do that. This is exactly why the migrations below rawget past the
    metatable to tell a genuinely stored value from a default. There is no
    manual defaults merge anywhere in the add-on.
]]

--[[
    Deliberate refill-on-empty: an empty item list is treated as "never
    configured", so the expansion-filtered defaults are re-seeded. Runs on
    load and again whenever the active profile changes or resets.
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

-- MIGRATION (remove after 2026-08-15): fold pre-profile flat GogoLootDB keys into the Default profile
local function MigrateFlatSettingsToProfile()
	if GogoLootDB.speedyLoot == nil then
		return
	end
	for configurationKey in pairs(ns.DATABASE_DEFAULTS.profile) do
		if GogoLootDB[configurationKey] ~= nil then
			ns.db.profile[configurationKey] = GogoLootDB[configurationKey]
			GogoLootDB[configurationKey] = nil
		end
	end
	--[[
        Keys that have since left the profile defaults table are not carried by
        the loop above. Move them by hand so the migrations that run next can
        fold them into their new homes: autoGreedThreshold into the party/raid
        threshold pair, the rest into account-wide global scope.
    ]]
	for _, retiredKey in ipairs({ "autoGreedThreshold", "showWelcome", "speedyLoot" }) do
		if GogoLootDB[retiredKey] ~= nil then
			ns.db.profile[retiredKey] = GogoLootDB[retiredKey]
			GogoLootDB[retiredKey] = nil
		end
	end
end

--[[
    MIGRATION (remove after 2026-08-15): the minimap position moved from the
    profile into account-wide global scope so switching, resetting, or deleting
    a profile never moves the button. Runs per login for the active profile and
    from HandleProfileChanged for each profile as it is visited; fills only keys
    the global table doesn't already hold, so an established global position is
    never clobbered by a stale per-profile one.
]]
local function MigrateMinimapToGlobal()
	--[[
        rawget past AceDB's defaults metatable: read only what is actually
        stored in the profile, never a value the defaults could synthesize, so
        the migration fires solely for genuine stale per-profile data.
    ]]
	local profileMinimap = rawget(ns.db.profile, "minimap")
	if type(profileMinimap) ~= "table" then
		return
	end
	for positionKey, positionValue in pairs(profileMinimap) do
		if ns.db.global.minimap[positionKey] == nil then
			ns.db.global.minimap[positionKey] = positionValue
		end
	end
	ns.db.profile.minimap = nil
end

--[[
    MIGRATION (remove after 2026-08-15): the single autoGreedThreshold split
    into a per-context pair — party and raid each carry their own threshold and
    roll action. The old value seeds both thresholds so an upgrading profile
    keeps rolling exactly as it did; the actions stay at their Greed default,
    which is what the old code always did. Runs per login for the active
    profile and from HandleProfileChanged for each profile as it is visited.
]]
local function MigrateGreedThresholdToPerContext()
	--[[
        rawget past AceDB's defaults metatable: autoGreedThreshold is gone from
        the defaults, so this reads only a value genuinely stored in the profile.
    ]]
	local legacyThreshold = rawget(ns.db.profile, "autoGreedThreshold")
	if type(legacyThreshold) ~= "number" then
		return
	end
	ns.db.profile.autoRollThresholdParty = legacyThreshold
	ns.db.profile.autoRollThresholdRaid = legacyThreshold
	ns.db.profile.autoGreedThreshold = nil
end

--[[
    MIGRATION (remove after 2026-08-15): the presentation toggles moved from the
    profile into account-wide global scope, so switching or resetting a profile
    never turns the welcome message back on or re-enables Speedy Loot.

    adoptProfileValue is true only for the profile active at login: that
    character's stored choices become the account-wide ones. Profiles visited
    later through HandleProfileChanged pass false and merely drop their stale
    keys, so an old profile can never overwrite the values already in force. A
    "fill only when global is unset" test is impossible here — AceDB's
    copyDefaults rawsets scalar defaults into the saved table, so these keys
    always read as present on global.
]]
local ACCOUNT_WIDE_MIGRATED_KEYS = { "showWelcome", "speedyLoot" }

local function MigrateSettingsToGlobal(adoptProfileValue)
	for _, settingKey in ipairs(ACCOUNT_WIDE_MIGRATED_KEYS) do
		--[[
            rawget past AceDB's defaults metatable: these keys are gone from the
            profile defaults, so this reads only genuinely stored values.
        ]]
		local profileValue = rawget(ns.db.profile, settingKey)
		if profileValue ~= nil then
			if adoptProfileValue then
				ns.db.global[settingKey] = profileValue
			end
			ns.db.profile[settingKey] = nil
		end
	end
end

--[[
    Fired on OnProfileChanged / OnProfileCopied / OnProfileReset. The new
    profile's tables replace the old ones wholesale, so everything that
    caches or displays profile state is repainted here: the item lists re-seed
    if empty, the minimap icon re-reads autoGreed, the trade checkbox re-reads
    announceTrade, and every options panel repaints. The minimap position is
    account-wide (ns.db.global.minimap), so it is not re-pointed on a profile
    switch — the icon refresh only reflects the new profile's autoGreed state.
]]
local function HandleProfileChanged()
	MigrateMinimapToGlobal()
	MigrateSettingsToGlobal(false)
	MigrateGreedThresholdToPerContext()
	RebuildEmptyItemLists()
	if ns.UpdateMinimapIcon then
		ns:UpdateMinimapIcon()
	end
	if ns.SyncTradeCheckbox then
		ns:SyncTradeCheckbox()
	end
	for _, registryName in pairs(ns.OPTIONS_REGISTRY) do
		AceConfigRegistry:NotifyChange(registryName)
	end
end

--------------------------------------------------------------------------------
-- Initialization & Addon Setup
--------------------------------------------------------------------------------

--[[
    Speedy Loot cannot function without the game's Auto Loot setting, so the
    CVar is enforced while Speedy Loot is on, and the Speedy Loot toggle is the
    opt-out every enforced CVar write has to carry. The write only ever fires
    when the CVar is actually off, and always announces itself. Called at login
    when Speedy Loot is enabled, and whenever it is switched on.
]]
---@return nil
function ns.EnsureAutoLoot()
	if not ns:IsAutoLootCVarEnabled() then
		SetCVar("autoLootDefault", "1")
		ns:PrintMessage(L["MESSAGE_AUTO_LOOT_ENABLED"])
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
    Registration probe (Features/Diagnostics.lua) reads THIS list, so the probe
    can never drift from the events the add-on actually uses — including
    on-demand, self-unregistering ones like Options-Utilities'
    GET_ITEM_INFO_RECEIVED watcher, which would be absent from the live handler
    table at probe time. Update this list whenever a module starts registering a
    new event: RegisterModuleEvent prints a developer warning if handed an event
    missing from here. Kept sorted alphabetically.
]]
ns.EVENT_NAMES = {
	"ADDON_LOADED",
	"CANCEL_LOOT_ROLL",
	"CONFIRM_LOOT_ROLL",
	"GET_ITEM_INFO_RECEIVED",
	"GROUP_ROSTER_UPDATE",
	"LOOT_CLOSED",
	"LOOT_OPENED",
	"LOOT_READY",
	"LOOT_SLOT_CLEARED",
	"PARTY_LOOT_METHOD_CHANGED",
	"PLAYER_ENTERING_WORLD",
	"PLAYER_LOGIN",
	"START_LOOT_ROLL",
	"TRADE_ACCEPT_UPDATE",
	"TRADE_PLAYER_ITEM_CHANGED",
	"TRADE_REQUEST_CANCEL",
	"TRADE_SHOW",
	"TRADE_TARGET_ITEM_CHANGED",
	"UI_ERROR_MESSAGE",
	"UI_INFO_MESSAGE",
}

-- Membership set for the drift guard below, plus the events already warned about.
local knownEventNames = {}
for _, eventName in ipairs(ns.EVENT_NAMES) do
	knownEventNames[eventName] = true
end
local warnedUnlistedEvents = {}

---@param eventName string
---@param handlerFunction function
---@return nil
function ns:RegisterModuleEvent(eventName, handlerFunction)
	--[[
        Fail loud in dev when an event is registered without being added to
        ns.EVENT_NAMES, so the diagnostics probe never silently misses it. Once
        per event name. ns:PrintMessage isn't defined until Announcements.lua
        loads (after Core), so fall back to print for Core's own registrations.
    ]]
	if not knownEventNames[eventName] and not warnedUnlistedEvents[eventName] then
		warnedUnlistedEvents[eventName] = true
		local warning = "Developer warning: event '"
			.. eventName
			.. "' is registered but missing from ns.EVENT_NAMES (Core.lua) — add it so Diagnostics stays in sync."
		if ns.PrintMessage then
			ns:PrintMessage(warning)
		else
			print(warning)
		end
	end
	if not ns.eventHandlers[eventName] then
		ns.eventHandlers[eventName] = {}
		eventFrame:RegisterEvent(eventName)
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
		for _, handlerFunction in ipairs(handlers) do
			handlerFunction(...)
		end
	end
end)

local function OnAddonLoaded(loadedAddonName)
	if loadedAddonName ~= ADDON_NAME then
		return
	end

	ns.db = LibStub("AceDB-3.0"):New("GogoLootDB", ns.DATABASE_DEFAULTS, true)
	MigrateFlatSettingsToProfile()
	-- MIGRATION (remove after 2026-08-15): collapse announceTradeOutput "raid" into "group"
	if ns.db.profile.announceTradeOutput == "raid" then
		ns.db.profile.announceTradeOutput = "group"
	end
	MigrateMinimapToGlobal()
	MigrateSettingsToGlobal(true)
	MigrateGreedThresholdToPerContext()
	RebuildEmptyItemLists()
	ns.db.RegisterCallback(ns, "OnProfileChanged", HandleProfileChanged)
	ns.db.RegisterCallback(ns, "OnProfileCopied", HandleProfileChanged)
	ns.db.RegisterCallback(ns, "OnProfileReset", HandleProfileChanged)

	if ns.InitMinimap then
		ns:InitMinimap()
	end
	if ns.RegisterOptionsPanels then
		ns.RegisterOptionsPanels()
	end
end

ns:RegisterModuleEvent("ADDON_LOADED", OnAddonLoaded)

--[[
    Only enforce for a player actually running Speedy Loot. The one-shot flag is
    set when the check is scheduled rather than on the first fire, so turning
    Speedy Loot on later still gets its login-time enforcement on the next
    loading screen.
]]
local hasCheckedAutoLoot = false
ns:RegisterModuleEvent("PLAYER_ENTERING_WORLD", function()
	if hasCheckedAutoLoot then
		return
	end
	if not ns.db or not ns.db.global.speedyLoot then
		return
	end
	hasCheckedAutoLoot = true
	C_Timer.After(3, ns.EnsureAutoLoot)
end)
