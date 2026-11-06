--[[
    GogoLoot's test suite. Runs outside the game against the fakes in
    Tests/Fakes, so it can be run on every edit:

        lua Tests/Run.lua        (from the add-on folder)

    These files are deliberately NOT listed in the TOC — the Style Guide keeps
    real logic tests in the dev toolchain, never in the shipped Diagnostics
    panel. They never load in game.
]]

local ROOT = (arg and arg[0] or ""):match("^(.*)Tests/Run%.lua$") or "./"
package.path = ROOT .. "Tests/?.lua;" .. package.path

local Fake = require("Fakes.WoW")

--------------------------------------------------------------------------------
-- Assertions
--------------------------------------------------------------------------------

local Suite = { passed = 0, failed = 0, failures = {}, currentTest = "", environments = {} }

---@param condition any
---@param message string
---@return nil
local function check(condition, message)
	if condition then
		Suite.passed = Suite.passed + 1
		return
	end
	Suite.failed = Suite.failed + 1
	table.insert(Suite.failures, ("%s: %s"):format(Suite.currentTest, message))
end

local function checkEqual(expected, actual, message)
	check(expected == actual, ("%s (expected %s, got %s)"):format(message, tostring(expected), tostring(actual)))
end

--[[
    For the options-layout widths, which are sums and differences of fractions:
    0.115 + 0.14 + (2.1 - 0.255) is 2.1 in every sense that matters to a panel
    and not bit-identical to it in binary.
]]
local function checkNear(expected, actual, message)
	check(
		type(actual) == "number" and math.abs(expected - actual) < 1e-9,
		("%s (expected %s, got %s)"):format(message, tostring(expected), tostring(actual))
	)
end

---@param name string
---@param body function
---@return nil
local function test(name, body)
	Suite.currentTest = name
	Suite.environments = {}
	local ok, err = pcall(body)
	if not ok then
		Suite.failed = Suite.failed + 1
		table.insert(Suite.failures, ("%s: threw %s"):format(name, tostring(err)))
	end
	-- The dispatcher's securecallfunction keeps a handler's error from reaching the pcall above.
	for _, env in ipairs(Suite.environments) do
		for _, handlerError in ipairs(env.__state.handlerErrors) do
			Suite.failed = Suite.failed + 1
			table.insert(Suite.failures, ("%s: a handler threw %s"):format(name, tostring(handlerError)))
		end
	end
end

--------------------------------------------------------------------------------
-- Add-on loading
--------------------------------------------------------------------------------

-- TOC order, Includes excluded (the Ace libraries are faked).
local FILES = {
	"Locales/enUS.lua",
	"Data/Flavor.lua",
	"Data/Data.lua",
	"Data/Vanilla/Character-Rule-Stats-Vanilla.lua",
	"Data/Vanilla/Default-Item-Lists-Vanilla.lua",
	"Data/Vanilla/Lockbox-Skill-Levels-Vanilla.lua",
	"Data/Vanilla/Openable-Items-Vanilla.lua",
	"Data/Vanilla/Spells-Vanilla.lua",
	"Data/Vanilla/Game-IDs-Vanilla.lua",
	"Data/Discovery/Character-Rule-Stats-Discovery.lua",
	"Data/Discovery/Default-Item-Lists-Discovery.lua",
	"Data/Discovery/Lockbox-Skill-Levels-Discovery.lua",
	"Data/Discovery/Openable-Items-Discovery.lua",
	"Data/Discovery/Spells-Discovery.lua",
	"Data/Discovery/Game-IDs-Discovery.lua",
	"Data/Default-Settings.lua",
	"Features/Core.lua",
	"Features/Utilities.lua",
	"Features/Utilities-Scan-Tooltip.lua",
	"Features/Utilities-Chat-Lines.lua",
	"Features/Announcements.lua",
	"Features/Announcements-Trade.lua",
	"Features/Auto-Loot.lua",
	"Features/Openable-Items.lua",
	"Features/Loot-Sounds.lua",
	"Features/Speedy-Loot.lua",
	"Features/Automated-Opening.lua",
	"Features/Lockbox-Tooltips.lua",
	"Features/Loot-Toasts-Winning-Rolls.lua",
	"Features/Loot-Toasts-Filters.lua",
	"Features/Loot-Toasts.lua",
	"Features/Loot-Toasts-Handle.lua",
	"Features/Loot-Toasts-Money.lua",
	"Features/Standard-Loot-Messages.lua",
	"Features/Master-Looter.lua",
	"Features/Master-Looter-Distribution.lua",
	"Features/Character-Rules.lua",
	"Features/Roll-Messages.lua",
	"Features/Automated-Rolls.lua",
	"Features/Roll-Macro.lua",
	"Features/Roll-Calls.lua",
	"Features/Loot-Master.lua",
	"Features/Drops-By-Boss.lua",
	"Features/Loot-Windows.lua",
	"Features/Loot-Master-Window.lua",
	"Features/Loot-Tracker-Window.lua",
	"Features/Minimap-Button.lua",
	"Diagnostics/Diagnostics-Core.lua",
	"Diagnostics/Manifests.lua",
	"Diagnostics/Event-Log.lua",
	"Diagnostics/Code-Reports.lua",
	"Diagnostics/Settings-Reports.lua",
	"Diagnostics/Validate-Data.lua",
	"Diagnostics/Localization-Reports.lua",
	"Diagnostics/Report-Runner.lua",
	"Options/Options-Utilities.lua",
	"Options/Options-Utilities-Item-Cache.lua",
	"Options/Options-Utilities-Item-List-Filter.lua",
	"Options/Options-Utilities-Item-Lists.lua",
	"Options/Options-Utilities-Item-List-Widgets.lua",
	"Options/Options-General.lua",
	"Options/Options-Speedy-Loot.lua",
	"Options/Options-Automated-Rolls.lua",
	"Options/Options-Item-Overrides.lua",
	"Options/Options-Character-Rules.lua",
	"Options/Options-Master-Looter.lua",
	"Options/Options-Master-Looter-Ignore-List.lua",
	"Options/Options-Master-Looter-Popup.lua",
	"Options/Options-Roll-Macro.lua",
	"Options/Options-Loot-Master.lua",
	"Options/Options-Automated-Opening.lua",
	"Options/Options-Openable-Items.lua",
	"Options/Options-Lockboxes.lua",
	"Options/Options-Loot-Toasts.lua",
	"Options/Options-Loot-Toast-Filters.lua",
	"Options/Options-Loot-Sounds.lua",
	"Options/Options-Announcements.lua",
	"Options/Options-Profiles.lua",
	"Options/Options-Feedback-Support.lua",
	"Diagnostics/Options-Diagnostics.lua",
	"Options/Options.lua",
}

-- Parked out of the TOCs until they're tested in game; the harness still loads them so their tests keep running.
local PARKED_FILES = {
	["Features/Roll-Calls.lua"] = true,
	["Features/Loot-Master.lua"] = true,
	["Features/Drops-By-Boss.lua"] = true,
	["Features/Loot-Windows.lua"] = true,
	["Features/Loot-Master-Window.lua"] = true,
	["Features/Loot-Tracker-Window.lua"] = true,
	["Options/Options-Loot-Master.lua"] = true,
}

--- Loads the whole add-on into a fresh environment and fires ADDON_LOADED.
--- `beforeLoaded(ns, env)` runs after the files load and before ADDON_LOADED,
--- for a test that needs a load-time constant changed before registration reads it.
--- `beforeFiles(env)` runs before any file loads, for a client difference the
--- files read as they load (which events exist, say).
---@param beforeLoaded? function
---@param beforeFiles? function
---@return table ns, table env
local function loadAddon(beforeLoaded, beforeFiles)
	local env = Fake.newEnvironment()
	table.insert(Suite.environments, env)
	local ns = {}
	if beforeFiles then
		beforeFiles(env)
	end

	for _, relative in ipairs(FILES) do
		local flavorFiles = rawget(env, "__flavorFiles")
		local path = ROOT .. (flavorFiles and flavorFiles[relative] or relative)
		local chunk, err
		if setfenv then
			chunk, err = loadfile(path)
			if chunk then
				setfenv(chunk, env)
			end
		else
			chunk, err = loadfile(path, "t", env)
		end
		assert(chunk, ("%s failed to parse: %s"):format(relative, tostring(err)))
		local ok, runError = pcall(chunk, "GogoLoot", ns)
		assert(ok, ("%s failed to load: %s"):format(relative, tostring(runError)))
	end

	--[[
	    Toast tests push several rows at one fake instant and read them at once,
	    so rows enter together here; the one-at-a-time entry has its own test,
	    which puts the interval back.
	]]
	ns.LOOT_TOAST_ENTRY_INTERVAL = 0

	if beforeLoaded then
		beforeLoaded(ns, env)
	end

	local handlers = ns.eventHandlers and ns.eventHandlers.ADDON_LOADED
	assert(handlers, "no ADDON_LOADED handler registered")
	for _, handler in ipairs(handlers) do
		local ok, err = pcall(handler, "GogoLoot")
		assert(ok, ("ADDON_LOADED errored: %s"):format(tostring(err)))
	end

	return ns, env
end

---@param ns table
---@param event string
---@param ... any
---@return nil
local function fire(ns, event, ...)
	for _, handler in ipairs(ns.eventHandlers[event] or {}) do
		handler(...)
	end
end

--------------------------------------------------------------------------------
-- Fixtures
--------------------------------------------------------------------------------

--- A master-loot session holding `count` identical-quality items, named by
--- `itemNameFormat` (default "Test Item %d").
local function openMasterLootSession(ns, env, count, itemNameFormat)
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.lootMethod = 2 -- master, numeric like the real client
	state.masterLooterPartyIndex = 0
	state.masterLootCandidates = { "Bob" }
	state.lootSlots = {}
	state.itemNames = {}

	for slotIndex = 1, count do
		local itemId = 1000 + slotIndex
		local itemName = (itemNameFormat or "Test Item %d"):format(slotIndex)
		state.itemNames[itemId] = { name = itemName, quality = 4, classId = 4, bindType = 2 }
		state.lootSlots[slotIndex] = { link = ("|Hitem:%d|h[%s]|h"):format(itemId, itemName) }
	end

	ns.db.profile.destinations = {
		poor = "bob",
		common = "bob",
		uncommon = "bob",
		rare = "bob",
		epic = "bob",
	}
	ns.db.profile.autoMasterLoot = true
	ns.db.profile.announceMasterLootAuto = true
	ns.db.profile.announceMasterLootAutoThreshold = 0

	fire(ns, "LOOT_OPENED")
	return state
end

--[[
    Register a constant name and get its numeric id back. Ids must be assigned
    densely from 1: the real scan walks GetGameMessageInfo upward and stops at
    the first nil, so a sparse table would hide everything past the gap.
]]
---@param env table
---@param constantName string
---@return number
local function registerGameMessage(env, constantName)
	local messages = env.__state.gameMessages
	messages[#messages + 1] = constantName
	return #messages
end

local function chatContaining(env, needle)
	for _, entry in ipairs(env.__state.chat) do
		if entry.message:find(needle, 1, true) then
			return entry.message
		end
	end
	return nil
end

local function chatCount(env)
	return #env.__state.chat
end

--[[
    The fake builds every panel at registration, the Openables List panel
    included, so its hundreds of rows join the item-cache watcher in every test.
    In game they join only once the player opens that panel. A test about the
    watcher letting go caches them first, so they don't hold it open.
]]
local function cacheOpenableItems(ns, env)
	for itemIdentifier in pairs(ns.OPENABLE_ITEMS) do
		env.__state.itemNames[itemIdentifier] = env.__state.itemNames[itemIdentifier]
			or { name = "Container " .. itemIdentifier, quality = 1, classId = 15 }
	end
	-- The Example lines' items, which the cache watches from login.
	for quality, itemIdentifier in pairs(ns.SAMPLE_ITEM_IDS) do
		env.__state.itemNames[itemIdentifier] = env.__state.itemNames[itemIdentifier]
			or { name = "Sample " .. itemIdentifier, quality = quality }
	end
end

--[[
    AceConfig's `hidden` and `disabled` may each be a boolean or a function
    evaluated at paint time, so read one the way the dialog would.
]]
---@param field any
---@return boolean
local function evaluate(field)
	if type(field) == "function" then
		return field() and true or false
	end
	return field and true or false
end

--------------------------------------------------------------------------------
-- Tests
--------------------------------------------------------------------------------

test("add-on loads and initializes", function()
	local ns = loadAddon()
	check(ns.optionsFrames ~= nil, "options panels registered")
	check(ns.db ~= nil, "database created")
	check(type(ns.EnsureAutoLoot) == "function", "EnsureAutoLoot exposed")
end)

--[[
    The tree in display order: the root, then the feature panels in the order
    of the General panel's Features section, each with its children right
    after it, then Profiles, Feedback & Support and Diagnostic Tools last. A
    child nests under its parent's captured category ID, never under a title:
    nothing keeps titles unique.
]]
test("the settings tree nests each child panel under its parent", function()
	local ns, env = loadAddon()
	local registry = ns.OPTIONS_REGISTRY
	local root = ns.L["ADDON_TITLE"]
	local expected = {
		{ registry.General, nil },
		{ registry.SpeedyLoot, root },
		{ registry.AutomatedRolls, root },
		{ registry.ItemOverrides, "category:" .. registry.AutomatedRolls },
		{ registry.CharacterRules, "category:" .. registry.AutomatedRolls },
		{ registry.AutomatedOpening, root },
		{ registry.OpenableItems, "category:" .. registry.AutomatedOpening },
		{ registry.Lockboxes, "category:" .. registry.AutomatedOpening },
		{ registry.LootToasts, root },
		{ registry.LootToastFilters, "category:" .. registry.LootToasts },
		{ registry.LootSounds, root },
		{ registry.Announcements, root },
		{ registry.MasterLooter, root },
		{ registry.MasterLooterIgnoreList, "category:" .. registry.MasterLooter },
		{ registry.RollMacro, root },
		{ registry.LootMaster, root },
		{ registry.Profiles, root },
		{ registry.FeedbackSupport, root },
		{ registry.Diagnostics, root },
	}

	local registered = env.__state.blizOptions
	checkEqual(#expected, #registered, "every panel registered exactly once")
	for index, entry in ipairs(expected) do
		local actual = registered[index] or {}
		checkEqual(entry[1], actual.appName, ("panel %d is %s"):format(index, entry[1]))
		checkEqual(entry[2], actual.parent, entry[1] .. " sits under the right parent")
	end
	checkEqual(ns.L["TAB_ITEM_OVERRIDES"], registered[4].name, "a nested child keeps its own short title")
	checkEqual(
		"category:" .. registry.MasterLooterIgnoreList,
		ns.optionsFrames.categoryIDs.MasterLooterIgnoreList,
		"and every captured category ID is kept"
	)
end)

test("without nesting, a child panel follows its parent, titled Parent: Child", function()
	local ns, env = loadAddon(function(loadingNamespace)
		loadingNamespace.OPTIONS_NESTED_PANELS = false
	end)
	local L = ns.L
	local registry = ns.OPTIONS_REGISTRY
	local byRegistryName = {}
	for index, entry in ipairs(env.__state.blizOptions) do
		byRegistryName[entry.appName] = { index = index, name = entry.name, parent = entry.parent }
	end

	local child = byRegistryName[registry.ItemOverrides]
	checkEqual(L["ADDON_TITLE"], child.parent, "it sits directly under the add-on")
	checkEqual(L["TAB_AUTOMATED_ROLLS"] .. ": " .. L["TAB_ITEM_OVERRIDES"], child.name, "named for its parent first")
	checkEqual(byRegistryName[registry.AutomatedRolls].index + 1, child.index, "right after its parent")
	checkEqual(
		L["TAB_MASTER_LOOTER"] .. ": " .. L["TAB_IGNORE_LIST"],
		byRegistryName[registry.MasterLooterIgnoreList].name,
		"and every other child is named for its own parent"
	)
	checkEqual(#env.__state.blizOptions, byRegistryName[registry.Diagnostics].index, "Diagnostic Tools still last")
end)

--[[
    The General panel's Features section gathers every feature's switch, then
    /Commands, where the root panel ends: the Style Guide's Main Page Layout.
    The switches run in the order of the feature panels in the Settings tree.
]]
test("the General panel carries every feature's switch above /Commands", function()
	local ns = loadAddon()
	local args = ns.BuildGeneralOptions().args
	local features = args.features
	check(features ~= nil and features.type == "group" and features.inline, "the switches share one block")
	checkEqual(
		ns.L["OPTIONS_FEATURES_HEADER"],
		args.featuresHeader.name:match("|c%x%x%x%x%x%x%x%x(.-)|r"),
		"under Features"
	)
	check(features.order < args.headerCommands.order, "its section comes before /Commands")
	local lastOrder = 0
	for _, arg in pairs(args) do
		lastOrder = math.max(lastOrder, arg.order or 0)
	end
	checkEqual(args.descCommands.order, lastOrder, "and the panel ends at /Commands")

	local expectedOrder = {
		"speedyLoot",
		"autoGreed",
		"autoOpen",
		"lootToasts",
		"lootSoundsEnabled",
		"lootNotifications",
		"autoMasterLoot",
		"rollMacro",
	}
	for index, key in ipairs(expectedOrder) do
		local toggle = features.args[key]
		check(toggle ~= nil and toggle.type == "toggle", key .. " has a switch there")
		checkEqual(index, toggle and toggle.order, key .. " in its place")
	end
	checkEqual(ns.L["SPEEDY_LOOT_ENABLE"], features.args.speedyLoot.name, "Speedy Loot leads")
	checkEqual(ns.L["ROLL_MACRO_ENABLE"], features.args.rollMacro.name, "Roll Macro closes")

	local toggle = features.args.speedyLoot
	local enforced = 0
	ns.EnsureAutoLoot = function()
		enforced = enforced + 1
	end
	toggle.set(nil, false)
	checkEqual(false, toggle.get(), "switching it off is saved")
	checkEqual(0, enforced, "without touching Auto Loot")
	toggle.set(nil, true)
	checkEqual(true, ns.db.global.speedyLoot, "switching it on is saved account-wide")
	checkEqual(1, enforced, "and enforces Auto Loot")
end)

--[[
    Each feature's switch in the Features section is the one on its own panel,
    built by the same function: flipping either is flipping the other.
]]
--[[
    The Roll Macro ships off. Switching it on makes the General macro and says
    so; switching it off deletes it. While on, every load puts back a macro
    deleted or edited by hand, but a load with it off never touches a macro of
    the same name. A change asked for in combat waits for combat to end.
]]
test("the Roll Macro switch adds and deletes one General macro", function()
	local ns, env = loadAddon()
	local state = env.__state
	local inCombat = false
	env.InCombatLockdown = function()
		return inCombat
	end
	local panelArgs = ns.BuildRollMacroOptions().args
	local toggle = panelArgs.rollMacro
	local clickWidth
	for index, click in ipairs({ "MINIMAP_LEFT_CLICK", "MINIMAP_RIGHT_CLICK", "MINIMAP_MIDDLE_CLICK" }) do
		local row = panelArgs["clickRow" .. index]
		local name = row and row.args.control1
		check(name and name.name:find(ns.L[click], 1, true) ~= nil, click .. " heads its row")
		check(name and name.name:find(ns.COLORS.INFO, 1, true) ~= nil, click .. " in the tooltip's blue")
		clickWidth = clickWidth or (name and name.width)
		checkEqual(clickWidth, name and name.width, click .. " shares the column's width")
		checkNear(
			ns.OPTIONS_ROW_WIDTH,
			(name and name.width or 0) + (row and row.args.control2.width or 0),
			"the row fills"
		)
		check(row and row.order > toggle.order, "the rows come after the switch")
		check(row and row.order < panelArgs.raidRollNote.order, "and before the raid roll note")
	end
	local features = ns.BuildGeneralOptions().args.features.args
	checkEqual(toggle.name, features.rollMacro.name, "the General switch is the panel's")
	checkEqual(toggle.desc, features.rollMacro.desc, "with the same tooltip")
	checkEqual(false, ns.db.global.rollMacro, "off by default, account-wide")

	table.insert(state.macros, { name = ns.ROLL_MACRO_NAME, icon = 1, body = "/roll" })
	fire(ns, "PLAYER_ENTERING_WORLD")
	checkEqual("/roll", state.macros[1].body, "a load with it off leaves a same-named macro alone")
	state.macros = {}

	local printsBefore = #state.prints
	toggle.set(nil, true)
	checkEqual(true, ns.db.global.rollMacro, "switching it on is saved")
	checkEqual(1, #state.macros, "one macro made")
	local macro = state.macros[1] or {}
	checkEqual(ns.ROLL_MACRO_NAME, macro.name, "named - Roll")
	checkEqual(ns.ROLL_MACRO_ICON, macro.icon, "with the gold coins")
	checkEqual(ns.ROLL_MACRO_BODY, macro.body, "and the roll text")
	check(#ns.ROLL_MACRO_BODY <= 255, "the text fits a macro")
	checkEqual(printsBefore + 1, #state.prints, "and chat says so")

	toggle.set(nil, true)
	checkEqual(1, #state.macros, "switching it on again makes no second macro")

	state.macros[1].body = "/roll 50"
	fire(ns, "PLAYER_ENTERING_WORLD")
	checkEqual(ns.ROLL_MACRO_BODY, state.macros[1].body, "a load puts back text edited by hand")
	state.macros = {}
	fire(ns, "PLAYER_ENTERING_WORLD")
	checkEqual(1, #state.macros, "and a macro deleted by hand")

	inCombat = true
	toggle.set(nil, false)
	checkEqual(1, #state.macros, "switching it off in combat waits")
	inCombat = false
	fire(ns, "PLAYER_REGEN_ENABLED")
	checkEqual(0, #state.macros, "and deletes it when combat ends")

	state.macroLimit = 0
	printsBefore = #state.prints
	toggle.set(nil, true)
	checkEqual(0, #state.macros, "a full General tab makes nothing")
	checkEqual(printsBefore + 1, #state.prints, "and chat says why")
	check((state.prints[#state.prints] or ""):find(ns.ROLL_MACRO_NAME, 1, true) ~= nil, "naming the macro")
end)

test("a feature's switch on the General panel is the one on its own panel", function()
	local ns = loadAddon()
	local features = ns.BuildGeneralOptions().args.features.args
	local panels = {
		{ key = "autoGreed", toggle = ns.BuildAutomatedRollOptions().args.autoGreed },
		{ key = "autoMasterLoot", toggle = ns.BuildMasterLooterOptions().args.autoMasterLoot },
		{ key = "autoOpen", toggle = ns.BuildAutomatedOpeningOptions().args.autoOpen },
		{ key = "lootToasts", toggle = ns.BuildLootToastOptions().args.lootToastsRow.args.toggle },
		{ key = "lootSoundsEnabled", toggle = ns.BuildLootSoundOptions().args.lootSoundsEnabled },
		{ key = "lootNotifications", toggle = ns.BuildAnnouncementOptions().args.lootNotifications },
	}
	local speedyLoot = ns.BuildSpeedyLootOptions().args.speedyLoot
	checkEqual(speedyLoot.name, features.speedyLoot.name, "speedyLoot: the same caption")
	checkEqual(speedyLoot.desc, features.speedyLoot.desc, "speedyLoot: the same tooltip")
	features.speedyLoot.set(nil, false)
	checkEqual(false, speedyLoot.get(), "speedyLoot: its own panel reads the General switch, account-wide")

	for _, panel in ipairs(panels) do
		local hub = features[panel.key]
		checkEqual(panel.toggle.name, hub.name, panel.key .. ": the same caption")
		checkEqual(panel.toggle.desc, hub.desc, panel.key .. ": the same tooltip")
		hub.set(nil, false)
		checkEqual(false, ns.db.profile[panel.key], panel.key .. ": the General switch writes the setting")
		checkEqual(false, panel.toggle.get(), panel.key .. ": which its own panel reads")
		panel.toggle.set(nil, true)
		checkEqual(true, hub.get(), panel.key .. ": and the other way round")
	end
end)

--[[
    The switches sit two to a line only while every caption fits half a row, so
    a longer translated caption drops them to one per line rather than cutting
    it short.
]]
test("the feature switches sit two to a line only while every caption fits", function()
	local ns = loadAddon()
	for _, toggle in pairs(ns.BuildGeneralOptions().args.features.args) do
		checkNear(ns.OPTIONS_ROW_WIDTH / 2, toggle.width, toggle.name .. " takes half a row")
	end

	local longCaption = ns.L["SPEEDY_LOOT_ENABLE"]
	ns.OptionsToggleWidth = function(caption)
		return caption == longCaption and ns.OPTIONS_ROW_WIDTH or 1
	end
	for _, toggle in pairs(ns.BuildGeneralOptions().args.features.args) do
		checkEqual("full", toggle.width, "one long caption puts every switch on a line of its own")
	end
end)

test("settings land in the right scope", function()
	local ns = loadAddon()
	check(ns.db.global.showWelcome ~= nil, "showWelcome is account-wide")
	check(ns.db.global.speedyLoot ~= nil, "speedyLoot is account-wide")
	check(rawget(ns.db.profile, "showWelcome") == nil, "showWelcome not left on the profile")
	check(ns.db.profile.autoGreed ~= nil, "roll settings stay per-profile")
end)

--[[
    The Auto Loot CVar is enforced, so the Speedy Loot and Automated Opening
    toggles have to be the opt-out: a player who turned both off gets no
    login-time write.
]]
--[[
    Count the enforcement timer by its callback rather than counting every
    pending timer: PLAYER_ENTERING_WORLD reaches more than one module (the
    master looter pop-up arms its zone-change settle off the same event), so a
    bare total answers a different question than this test asks.
]]
local function autoLootChecksScheduled(ns, env)
	local scheduled = 0
	for _, timer in ipairs(env.__state.timers) do
		if timer.callback == ns.EnsureAutoLoot then
			scheduled = scheduled + 1
		end
	end
	return scheduled
end

test("auto loot is enforced only while speedy loot or automated opening is on", function()
	local ns, env = loadAddon()

	ns.db.global.speedyLoot = false
	ns.db.profile.autoOpen = false
	fire(ns, "PLAYER_ENTERING_WORLD")
	checkEqual(0, autoLootChecksScheduled(ns, env), "nothing scheduled while both are off")

	ns.db.profile.autoOpen = true
	fire(ns, "PLAYER_ENTERING_WORLD")
	checkEqual(1, autoLootChecksScheduled(ns, env), "the check is scheduled once Automated Opening is on")

	fire(ns, "PLAYER_ENTERING_WORLD")
	checkEqual(1, autoLootChecksScheduled(ns, env), "and only once, not on every loading screen")
end)

test("speedy loot on its own is enough to enforce auto loot", function()
	local ns, env = loadAddon()
	ns.db.global.speedyLoot = true
	ns.db.profile.autoOpen = false
	fire(ns, "PLAYER_ENTERING_WORLD")
	checkEqual(1, autoLootChecksScheduled(ns, env), "the check is scheduled for Speedy Loot alone")
end)

test("happy path announces each hand-out once", function()
	local ns, env = loadAddon()
	openMasterLootSession(ns, env, 3)

	checkEqual(3, #env.__state.givenLoot, "three items handed out")

	for slotIndex = 1, 3 do
		fire(ns, "LOOT_SLOT_CLEARED", slotIndex)
	end

	checkEqual(3, chatCount(env), "one announcement per item")
	check(chatContaining(env, "Test Item 2") ~= nil, "the second item was named")
end)

test("a mapped error is attributed to the oldest hand-out, not the newest", function()
	local ns, env = loadAddon()
	openMasterLootSession(ns, env, 3)
	local bagsFullId = registerGameMessage(env, "ERR_LOOT_MASTER_INV_FULL")

	-- Slots 2 and 3 succeed; slot 1 is the one still outstanding.
	fire(ns, "LOOT_SLOT_CLEARED", 2)
	fire(ns, "LOOT_SLOT_CLEARED", 3)
	env.__state.chat = {}

	fire(ns, "UI_ERROR_MESSAGE", bagsFullId, "irrelevant text")
	Fake.advance(env, 1)

	local message = chatContaining(env, "bags are full")
	check(message ~= nil, "a bag-full error was announced")
	if message then
		check(message:find("Test Item 1", 1, true) ~= nil, "named the outstanding item, not the newest")
	end
end)

test("repeat failures for one player collapse into a single message", function()
	local ns, env = loadAddon()
	openMasterLootSession(ns, env, 3)
	local bagsFullId = registerGameMessage(env, "ERR_LOOT_MASTER_INV_FULL")
	env.__state.chat = {}

	fire(ns, "UI_ERROR_MESSAGE", bagsFullId)
	fire(ns, "UI_ERROR_MESSAGE", bagsFullId)
	fire(ns, "UI_ERROR_MESSAGE", bagsFullId)
	Fake.advance(env, 1)

	checkEqual(1, chatCount(env), "three failures produced one grouped line")
	local message = chatContaining(env, "bags are full")
	if message then
		check(message:find("Test Item 1", 1, true) and message:find("Test Item 3", 1, true), "all items listed")
	end
end)

test("a failure still in its batch window is reported when the loot window closes", function()
	local ns, env = loadAddon()
	openMasterLootSession(ns, env, 1)
	local bagsFullId = registerGameMessage(env, "ERR_LOOT_MASTER_INV_FULL")
	env.__state.chat = {}

	fire(ns, "UI_ERROR_MESSAGE", bagsFullId)
	fire(ns, "LOOT_CLOSED")
	check(chatContaining(env, "bags are full") ~= nil, "the report went out as the window closed")

	Fake.advance(env, 1)
	checkEqual(1, chatCount(env), "and only once")
end)

test("a multi-item failure report splits at the chat limit", function()
	local ns, env = loadAddon()
	openMasterLootSession(ns, env, 6, "An Exceptionally Long Item Name For Overflow Testing %d")
	local bagsFullId = registerGameMessage(env, "ERR_LOOT_MASTER_INV_FULL")
	env.__state.chat = {}

	for _ = 1, 6 do
		fire(ns, "UI_ERROR_MESSAGE", bagsFullId)
	end
	Fake.advance(env, 1)

	check(chatCount(env) > 1, "six long links went out as more than one message")
	for _, entry in ipairs(env.__state.chat) do
		check(#entry.message <= ns.CHAT_MESSAGE_MAX_LENGTH, "each message fits the chat limit")
		check(entry.message:find("bags are full", 1, true) ~= nil, "each message repeats the template")
	end
	for slotIndex = 1, 6 do
		check(
			chatContaining(env, ("Overflow Testing %d]"):format(slotIndex)) ~= nil,
			("item %d is named"):format(slotIndex)
		)
	end
end)

test("unmapped errors are ignored", function()
	local ns, env = loadAddon()
	openMasterLootSession(ns, env, 1)
	env.__state.chat = {}

	registerGameMessage(env, "ERR_LOOT_MASTER_INV_FULL")
	fire(ns, "UI_ERROR_MESSAGE", 999, "You are out of range of your target.")
	Fake.advance(env, 1)

	checkEqual(0, chatCount(env), "an unrelated combat error announced nothing")
end)

--[[
    A failed hand-out is already marked distributed and is never re-attempted,
    so abandoning the retry ticker on the first error only stranded the slots
    still waiting on cold item info.
]]
test("one failed hand-out does not strand the slots whose item info was cold", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.lootMethod = 2
	state.masterLooterPartyIndex = 0
	state.masterLootCandidates = { "Bob" }
	state.lootSlots = {}
	state.itemNames = {}

	-- Slot 1 is cached when the window opens; slot 2 is still cold.
	state.itemNames[1001] = { name = "Warm Item", quality = 4, classId = 4, bindType = 2 }
	state.lootSlots[1] = { link = "|Hitem:1001|h[Warm Item]|h" }
	state.lootSlots[2] = { link = "|Hitem:1002|h[Cold Item]|h" }

	ns.db.profile.destinations = { poor = "bob", common = "bob", uncommon = "bob", rare = "bob", epic = "bob" }
	ns.db.profile.autoMasterLoot = true

	fire(ns, "LOOT_OPENED")
	checkEqual(1, #state.givenLoot, "only the cached item went out on the first pass")

	-- That hand-out fails, and the cold item's info arrives right behind it.
	local bagsFullId = registerGameMessage(env, "ERR_LOOT_MASTER_INV_FULL")
	fire(ns, "UI_ERROR_MESSAGE", bagsFullId)
	state.itemNames[1002] = { name = "Cold Item", quality = 4, classId = 4, bindType = 2 }

	Fake.advance(env, 0.2)
	checkEqual(2, #state.givenLoot, "the retry ticker still delivered the item that was only cold")
end)

test("the retry ticker keeps waiting on an item whose info arrives late", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.lootMethod = 2
	state.masterLooterPartyIndex = 0
	state.masterLootCandidates = { "Bob" }
	state.itemNames = {}
	state.lootSlots = { { link = "|Hitem:1002|h[Cold Item]|h" } }
	ns.db.profile.destinations = { poor = "bob", common = "bob", uncommon = "bob", rare = "bob", epic = "bob" }
	ns.db.profile.autoMasterLoot = true

	fire(ns, "LOOT_OPENED")
	for _ = 1, 4 do
		Fake.advance(env, 0.1)
	end
	checkEqual(0, #state.givenLoot, "nothing goes out while the item info is still cold")

	state.itemNames[1002] = { name = "Cold Item", quality = 4, classId = 4, bindType = 2 }
	Fake.advance(env, 0.1)
	checkEqual(1, #state.givenLoot, "the item went out on the fifth tick, past the quiet-tick count")
end)

test("a silent failure is reported when the slot still holds the item", function()
	local ns, env = loadAddon()
	openMasterLootSession(ns, env, 1)
	env.__state.chat = {}

	--[[
	    No LOOT_SLOT_CLEARED, no error: the server said nothing at all. The
	    fallback fires first and only then arms the batched report.
	]]
	Fake.advance(env, 2)
	Fake.advance(env, 1)

	check(chatContaining(env, "Test Item 1") ~= nil, "the stuck hand-out was reported")
end)

test("a silent success stays quiet", function()
	local ns, env = loadAddon()
	openMasterLootSession(ns, env, 1)
	env.__state.chat = {}

	-- Slot emptied, so the fallback must not treat it as a failure.
	fire(ns, "LOOT_SLOT_CLEARED", 1)
	env.__state.lootSlots[1] = nil
	env.__state.chat = {}
	Fake.advance(env, 2)

	checkEqual(0, chatCount(env), "nothing reported after a confirmed hand-out")
end)

test("closing the window flushes a manual hand-out", function()
	local ns, env = loadAddon()
	openMasterLootSession(ns, env, 1)
	env.__state.chat = {}

	-- The master looter hands the item out from the candidate dropdown: no automated flag.
	env.GiveMasterLoot(1, 1)
	fire(ns, "LOOT_CLOSED")

	check(chatContaining(env, "Test Item 1") ~= nil, "manual hand-out still announced")
end)

--[[
    Hand-outs made by hand have a toggle of their own. Off, an item handed out
    from the master looter menu posts nothing, whatever its quality, while one
    that fails is still reported: an item stuck on the corpse is news the group
    needs either way.
]]
test("with manual announcements off, a hand-out by hand posts nothing and a failure still does", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.lootMethod = 2
	state.masterLooterPartyIndex = 0
	state.masterLootCandidates = { "Hippobob" }
	state.itemNames = {
		[1001] = { name = "Quiet Item", quality = 4, classId = 4, bindType = 2 },
		[1002] = { name = "Stuck Item", quality = 4, classId = 4, bindType = 2 },
		[1003] = { name = "Loud Item", quality = 4, classId = 4, bindType = 2 },
	}
	state.lootSlots = {
		{ link = "|Hitem:1001|h[Quiet Item]|h" },
		{ link = "|Hitem:1002|h[Stuck Item]|h" },
		{ link = "|Hitem:1003|h[Loud Item]|h" },
	}
	ns.db.profile.autoMasterLoot = false
	check(ns.db.profile.announceMasterLootManual, "manual hand-outs are announced out of the box")
	ns.db.profile.announceMasterLootManual = false
	fire(ns, "LOOT_OPENED")
	state.chat = {}

	env.GiveMasterLoot(1, 1)
	fire(ns, "LOOT_SLOT_CLEARED", 1)
	checkEqual(0, chatCount(env), "the hand-out that went through posts nothing")

	env.GiveMasterLoot(2, 1)
	fire(ns, "UI_ERROR_MESSAGE", registerGameMessage(env, "ERR_LOOT_MASTER_INV_FULL"))
	Fake.advance(env, 1)
	check(chatContaining(env, "Stuck Item") ~= nil, "the one that failed is still reported")

	ns.db.profile.announceMasterLootManual = true
	state.chat = {}
	env.GiveMasterLoot(3, 1)
	fire(ns, "LOOT_SLOT_CLEARED", 3)
	check(chatContaining(env, "Loud Item") ~= nil, "switched back on, the next one is announced")
end)

--[[
    The toggle sits last in the Master Looter Announcements section, under the
    automated hand-outs' example, which shows the line both post.
]]
test("the manual hand-out toggle saves its setting", function()
	local ns = loadAddon()
	local toggle = ns.BuildAnnouncementOptions().args.manualAnnounce

	checkEqual("toggle", toggle.type, "it is a toggle")
	checkEqual(ns.L["MASTER_LOOTER_ANNOUNCE_MANUAL"], toggle.name, "named for manual hand-outs")
	toggle.set(nil, false)
	checkEqual(false, ns.db.profile.announceMasterLootManual, "it saves the setting the hook reads")
	check(not toggle.get(), "and reads it back")
end)

test("Send All Loot To reads and writes only the qualities the loot threshold reaches", function()
	local ns = loadAddon()
	local destinations = ns.db.profile.destinations
	destinations.uncommon, destinations.rare, destinations.epic = "hippobob", "hippobob", "hippobob"
	checkEqual("hippobob", ns:GetSharedDestination(), "three shown rows agreeing read as one player")
	checkEqual("hippobob", ns:GetSharedDestinationChoice(), "and the dropdown shows them")

	ns:SetAllDestinations("self")
	checkEqual(nil, destinations.poor, "Send All leaves Poor, below the threshold, alone")
	checkEqual(nil, destinations.common, "and Common")
	checkEqual("self", destinations.uncommon, "while every shown row takes the pick")

	ns:SetAllDestinations(ns.DESTINATION_LOOT_WINDOW)
	checkEqual(nil, destinations.epic, "Loot Window still clears every row")
end)

test("switching the destination back to yourself is announced", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	ns.db.profile.announceDestinations = true

	ns:SetAllDestinations("hippobob")
	check(chatContaining(env, "Hippobob") ~= nil, "handing loot to someone else announced")

	env.__state.chat = {}
	ns:SetAllDestinations("self")

	local message = chatContaining(env, "Tester")
	check(message ~= nil, "switching back to yourself announced by name")
	check(chatContaining(env, "Self") == nil, "did not announce the literal 'Self'")
	-- Bare character name: no realm suffix in chat.
	check(chatContaining(env, "-TestRealm") == nil, "no realm suffix in the announcement")
end)

--[[
    Every destination dropdown leads with Loot Window, which leaves a quality
    in the loot window: an unset quality reads as it, picking it clears the
    quality, and Send All Loot To on it clears them all, saying nothing.
]]
test("Loot Window sends a quality back to the loot window", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.unitNames.party1 = "Aero"
	ns.db.profile.autoMasterLoot = true
	ns.db.profile.announceDestinations = true
	local args = ns.BuildMasterLooterOptions().args
	local epic = args.destinationRow_epic.args.control2

	checkEqual(ns.DESTINATION_LOOT_WINDOW, ns:GetGroupMemberSorting()[1], "Loot Window leads every dropdown")
	checkEqual("self", ns:GetGroupMemberSorting()[2], "then Self")
	checkEqual(
		ns.L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"],
		ns:GetGroupMemberNames()[ns.DESTINATION_LOOT_WINDOW],
		"reading Loot Window"
	)
	checkEqual(ns.DESTINATION_LOOT_WINDOW, epic.get(), "an unset quality reads Loot Window")
	checkEqual(ns.DESTINATION_LOOT_WINDOW, args.sendAll.get(), "and so does Send All Loot To")

	epic.set(nil, "aero")
	checkEqual("aero", ns.db.profile.destinations.epic, "picking a player saves them")
	state.chat = {}
	epic.set(nil, ns.DESTINATION_LOOT_WINDOW)
	checkEqual(nil, ns.db.profile.destinations.epic, "Loot Window clears the quality")
	checkEqual(0, #state.chat, "and says nothing")

	ns:SetAllDestinations("aero")
	state.chat = {}
	args.sendAll.set(nil, ns.DESTINATION_LOOT_WINDOW)
	checkEqual(nil, next(ns.db.profile.destinations), "Send All Loot To on Loot Window clears every quality")
	checkEqual(0, #state.chat, "quietly")
end)

--[[
    The pop-up carries Enable Automated Master Looting under its own switch,
    and Send All Loot To leaves with it, as it does on the panel.
]]
test("the pop-up carries the automation switch, and Send All Loot To leaves with it", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.inGroup = true
	state.lootMethod = 2
	local args = ns.BuildMasterLooterPopupOptions().args

	check(args.masterLooterPopup.order < args.autoMasterLoot.order, "under the pop-up's own switch")
	check(args.autoMasterLoot.order < args.announceDestinations.order, "above the destination messages")
	checkEqual(ns.L["MASTER_LOOTER_AUTO_ENABLE"], args.autoMasterLoot.name, "the panel's own switch")
	ns.db.profile.autoMasterLoot = true
	check(not evaluate(args.sendAll.hidden), "Send All Loot To shows while it is on")
	args.autoMasterLoot.set(nil, false)
	check(evaluate(args.sendAll.hidden), "and leaves while it is off")
end)

--[[
    MIGRATION (remove after 2026-11-03): a profile saved before the Mine and
    Group rows keeps what it showed.
]]
test("saved loot toast filters carry over to the Mine and Group rows", function()
	local ns = loadAddon(nil, function(env)
		env.__state.savedProfile = {
			lootToastThreshold = 2,
			lootToastQuestItems = false,
			lootToastBags = false,
			lootToastMoney = false,
			lootToastSource = "GROUP",
			lootToastGroupThreshold = 3,
			autoRollReport = true,
		}
	end)
	local profile = ns.db.profile

	checkEqual(2, profile.lootToastMineQuality.ARMOR, "the old minimum lands on the rarity rows")
	checkEqual(2, profile.lootToastMineQuality.TRADE_GOODS, "every one of them")
	checkEqual(false, profile.lootToastMine.QUEST, "a switched-off kind turns its row off")
	checkEqual(false, profile.lootToastMine.CONTAINER, "Bags covered bags")
	checkEqual(false, profile.lootToastMine.QUIVER, "and quivers")
	checkEqual(false, profile.lootToastMine.MONEY, "and Money stays off")
	checkEqual(false, profile.lootToastMine.CONSUMABLE, "types that answered to the minimum alone go quiet at Uncommon")
	checkEqual(true, profile.lootToastMine.RECIPE, "a kind left on stays on")
	checkEqual(true, profile.lootToastGroup.TRADE_GOODS, "Whole Group ticks the group's rarity rows")
	checkEqual(3, profile.lootToastGroupQuality.WEAPON, "at its old Group Quality")
	checkEqual(true, profile.lootToastGroup.QUEST, "keeping the group's quest items on")
	for _, key in ipairs({
		"lootToastThreshold",
		"lootToastQuestItems",
		"lootToastBags",
		"lootToastMoney",
		"lootToastSource",
		"lootToastGroupThreshold",
		"autoRollReport",
	}) do
		checkEqual(nil, profile[key], key .. " is gone")
	end
end)

test("changing the loot method reaches the modern API", function()
	local ns, env = loadAddon()
	env.__state.inGroup = true

	ns:SafeSetLootMethod("master")
	checkEqual(1, #env.__state.setLootMethodCalls, "the setter was actually called")
	checkEqual(2, env.__state.setLootMethodCalls[1].method, "master loot mapped to its numeric enum")
	check(env.__state.setLootMethodCalls[1].masterLooter ~= nil, "master looter name supplied")

	ns:SafeSetLootMethod("group")
	checkEqual(3, env.__state.setLootMethodCalls[2].method, "group loot mapped to its numeric enum")
	checkEqual("group", ns:SafeGetLootMethod(), "the numeric value reads back as a method name")
end)

test("changing the group's loot type clears the destinations", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2

	ns:SetAllDestinations("hippobob")
	checkEqual("hippobob", ns:GetSharedDestination(), "destination set")

	-- First observation records the method rather than counting as a change.
	state.lootMethod = 2
	fire(ns, "PARTY_LOOT_METHOD_CHANGED")
	checkEqual("hippobob", ns:GetSharedDestination(), "login reading did not wipe the setup")

	-- Master looter reassigned, method unchanged: must not wipe either.
	fire(ns, "PARTY_LOOT_METHOD_CHANGED")
	checkEqual("hippobob", ns:GetSharedDestination(), "same method left the setup alone")

	-- Group loot: the setup is over.
	state.lootMethod = 3
	fire(ns, "PARTY_LOOT_METHOD_CHANGED")
	checkEqual(nil, ns:GetSharedDestination(), "loot type change cleared every tier")
end)

--[[
    The leader's method change need not raise PARTY_LOOT_METHOD_CHANGED on every
    member, so the roster event has to be able to notice it on its own.
]]
test("the roster event alone clears destinations when the method changed", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.unitNames.party1 = "Hippobob"
	state.lootMethod = 2

	fire(ns, "GROUP_ROSTER_UPDATE")
	ns:SetAllDestinations("hippobob")
	checkEqual("hippobob", ns:GetSharedDestination(), "destination set under master loot")

	-- Leader switches to group loot; only the roster event reaches us.
	state.lootMethod = 3
	fire(ns, "GROUP_ROSTER_UPDATE")

	checkEqual(nil, ns:GetSharedDestination(), "roster event noticed the new method and cleared")
end)

test("leaving the group clears the destinations", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.unitNames.party1 = "Hippobob"

	-- Join first: the handler only sees a departure against a remembered arrival.
	fire(ns, "GROUP_ROSTER_UPDATE")
	ns:SetAllDestinations("hippobob")
	checkEqual("hippobob", ns:GetSharedDestination(), "destination set while grouped")

	state.inGroup = false
	fire(ns, "GROUP_ROSTER_UPDATE")

	checkEqual(nil, ns:GetSharedDestination(), "dropping group cleared every tier")
end)

--[[
    Both windows build these rows from the same builders, so the rows are
    checked on the pop-up and the panel is checked for agreement rather than
    re-asserted case by case.
]]
test("the loot threshold row hides under free for all", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.leaderUnit = "player"

	local popupArgs = ns.BuildMasterLooterPopupOptions().args
	local panelArgs = ns.BuildMasterLooterOptions().args

	state.lootMethod = 2 -- Master loot.
	check(not evaluate(popupArgs.lootThreshold.hidden), "threshold shown under master loot")
	check(not evaluate(popupArgs.lootThresholdLabel.hidden), "and its label with it")

	state.lootMethod = 3 -- Group loot: the threshold still decides what rolls.
	check(not evaluate(popupArgs.lootThreshold.hidden), "threshold shown under group loot")

	state.lootMethod = 4 -- Need before greed: quality still decides what rolls.
	check(not evaluate(popupArgs.lootThreshold.hidden), "threshold shown under need before greed")

	state.lootMethod = 1 -- Round robin: whole drops in turn, quality ignored.
	check(evaluate(popupArgs.lootThreshold.hidden), "threshold hidden under round robin")

	state.lootMethod = 0 -- Free for all.
	check(evaluate(popupArgs.lootThreshold.hidden), "threshold hidden under free for all")
	check(evaluate(popupArgs.lootThresholdLabel.hidden), "its label hidden with it, never orphaned")
	check(evaluate(popupArgs.spacerAfterLootType.hidden), "the paired spacer hidden too, so no double gap")
	check(not evaluate(popupArgs.lootMethod.hidden), "the loot method itself stays visible")

	check(evaluate(panelArgs.lootThreshold.hidden), "the options panel hides it on the same terms")
	check(evaluate(panelArgs.spacerAfterLootType.hidden), "and hides its spacer too")
end)

--[[
    Only the leader can change the group's loot method or threshold. The
    destination is GogoLoot's own setting and stays usable by anyone.
]]
test("the loot method and threshold are greyed out for non-leaders", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.lootMethod = 2
	state.unitNames.party1 = "Hippobob"

	local popupArgs = ns.BuildMasterLooterPopupOptions().args
	local panelArgs = ns.BuildMasterLooterOptions().args

	state.leaderUnit = "party1"
	check(evaluate(popupArgs.lootMethod.disabled), "loot method greyed out for a member")
	check(evaluate(popupArgs.lootThreshold.disabled), "loot threshold greyed out for a member")
	check(not evaluate(popupArgs.sendAll.disabled), "the destination stays usable")
	check(evaluate(panelArgs.lootMethod.disabled), "the options panel greys the method out too")
	check(evaluate(panelArgs.lootThreshold.disabled), "and the threshold")

	state.leaderUnit = "player"
	check(not evaluate(popupArgs.lootMethod.disabled), "the leader can change the method")
	check(not evaluate(popupArgs.lootThreshold.disabled), "and the threshold")

	-- Solo there is no group to set a method for, so both stay greyed.
	state.inGroup = false
	check(evaluate(popupArgs.lootMethod.disabled), "greyed out again once solo")
	check(evaluate(popupArgs.lootThreshold.disabled), "threshold greyed out once solo")
end)

--[[
    The pop-up carries its own on/off switch, because the window you would most
    want to turn it off from is the one that just opened uninvited. Both surfaces
    build it from the same row builder, so neither can drift from the other.
]]
test("the pop-up carries the same on/off switch as the panel", function()
	local ns = loadAddon()
	local panelToggle = ns.BuildMasterLooterOptions().args.masterLooterPopup
	local popupToggle = ns.BuildMasterLooterPopupOptions().args.masterLooterPopup

	check(popupToggle ~= nil, "the pop-up has the toggle at all")
	checkEqual("toggle", popupToggle.type, "and it is a toggle")
	checkEqual(panelToggle.name, popupToggle.name, "reading the same as the panel's")
	checkEqual(1, popupToggle.order, "at the very top of the window")

	ns.db.profile.masterLooterPopup = true
	check(popupToggle.get(), "it reads the live setting")
	popupToggle.set(nil, false)
	check(not ns.db.profile.masterLooterPopup, "and writes it")
	check(not panelToggle.get(), "which the panel's copy reads back immediately")
end)

--[[
    The destination only means anything under master loot.
]]
test("send all loot to hides unless the method is master loot", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.leaderUnit = "player"
	ns.db.profile.autoMasterLoot = true

	local popupArgs = ns.BuildMasterLooterPopupOptions().args

	state.lootMethod = 2
	check(not evaluate(popupArgs.sendAll.hidden), "shown under master loot")
	check(not evaluate(popupArgs.sendAllLabel.hidden), "and its label with it")

	state.lootMethod = 3
	check(evaluate(popupArgs.sendAll.hidden), "hidden under group loot")
	check(evaluate(popupArgs.sendAllLabel.hidden), "its label hidden with it")

	state.lootMethod = 0
	check(evaluate(popupArgs.sendAll.hidden), "hidden under free for all")

	-- The Master Looter panel keeps its row on show whatever the method, while automation is on.
	local panelArgs = ns.BuildMasterLooterOptions().args
	check(not evaluate(panelArgs.sendAll.hidden), "the Master Looter panel keeps its row on show")
end)

--[[
    What tunes the automation hides with its switch: the two on/off choices and
    Loot Destinations change nothing while it is off, since ns:WillAutoMasterLoot
    returns false outright then. Group Loot Settings stays: the loot method and
    threshold are the group's, and the pop-up opens whenever the player becomes
    Master Looter, automation or not, so its switch has to be there to stop it.
]]
test("the master looter panel hides what tunes the automation, and keeps the group's settings", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.leaderUnit = "player"
	state.lootMethod = 2
	local args = ns.BuildMasterLooterOptions().args

	local alwaysShown = {
		autoDesc = true,
		spacerAfterAutoDesc = true,
		autoMasterLoot = true,
		spacerBeforeCurrentLoot = true,
		currentLootHeader = true,
		spacerAfterCurrentLootHeader = true,
		leaderNote = true,
		spacerAfterLeaderNote = true,
		lootMethodLabel = true,
		lootMethod = true,
		spacerAfterLootType = true,
		lootThresholdLabel = true,
		lootThreshold = true,
		spacerBeforePopupToggle = true,
		masterLooterPopup = true,
	}

	ns.db.profile.autoMasterLoot = false
	for key, entry in pairs(args) do
		if alwaysShown[key] then
			check(not evaluate(entry.hidden), key .. " stays on show while automated master looting is off")
		else
			check(evaluate(entry.hidden), key .. " hides while automated master looting is off")
		end
	end

	ns.db.profile.autoMasterLoot = true
	for _, key in ipairs({
		"outsideInstancesRow",
		"questItemsRow",
		"destinationsHeader",
		"sendAll",
		"destinationRow_epic",
	}) do
		check(not evaluate(args[key].hidden), key .. " comes back once it is on")
	end
end)

--[[
    The master switch composes with whatever a row already answered to rather
    than replacing it: a threshold row still hides under Free for All, a
    quality row below the loot threshold stays hidden, and turning the master
    switch back on must not drag any of them into view.
]]
test("the master switch is an extra reason to hide, not a replacement", function()
	local ns, env = loadAddon()
	local state = env.__state
	local args = ns.BuildMasterLooterOptions().args

	ns.db.profile.autoMasterLoot = true

	state.lootMethod = 0 -- Free for All: no threshold to apply.
	check(evaluate(args.lootThreshold.hidden), "the threshold row keeps its own reason to hide")

	state.lootMethod = 2
	check(not evaluate(args.lootThreshold.hidden), "and shows once that reason is gone")

	check(evaluate(args.destinationRow_poor.hidden), "a quality below the loot threshold stays hidden")
end)

--[[
    A child panel answers to its own gates, never to its parent's master switch:
    hidden behind it, the panel would open onto a blank page. It says so
    instead, in one red line that leaves once the parent is back on.
]]
test("child panels stay usable while their parent's switch is off, and say it is off", function()
	local ns = loadAddon()
	local L = ns.L
	ns.db.profile.autoMasterLoot = false
	ns.db.profile.autoGreed = false
	ns.db.profile.autoOpen = false

	local children = {
		{
			name = "the Master Looter Ignore List",
			args = ns.BuildMasterLooterIgnoreListOptions().args,
			list = "ignoreList",
			note = L["MASTER_LOOTER_OFF_NOTE"],
			switch = "autoMasterLoot",
		},
		{
			name = "Item Overrides",
			args = ns.BuildItemOverridesOptions().args,
			list = "itemOverrides",
			note = L["ROLLS_OFF_NOTE"],
			switch = "autoGreed",
		},
		{
			name = "the Openables List",
			args = ns.BuildOpenableItemsOptions().args,
			list = "itemList",
			note = L["OPENABLE_ITEMS_OFF_NOTE"],
			switch = "autoOpen",
		},
	}
	for _, child in ipairs(children) do
		local args = child.args
		check(not evaluate(args[child.list].hidden), child.name .. " still shows its list")
		check(not evaluate(args.featureOffNote.hidden), child.name .. " says its feature is off")
		local noteName = args.featureOffNote.name
		if type(noteName) == "function" then
			noteName = noteName()
		end
		checkEqual(ns.GetColor("OFF") .. child.note .. "|r", noteName, child.name .. ", in red")
		check(args.spacerAfterDesc.order < args.featureOffNote.order, child.name .. ": under the description")
		check(args.featureOffNote.order < args[child.list].order, child.name .. ": above the list")

		ns.db.profile[child.switch] = true
		check(evaluate(args.featureOffNote.hidden), child.name .. " drops the line once the feature is on")
		check(evaluate(args.spacerAfterFeatureOffNote.hidden), child.name .. " and its spacer with it")
	end
end)

--[[
    A sub-option is indented by the blank cell its row leads with, not by padding
    its caption: AceConfig pins a checkbox at the left edge of its own widget, so
    padding would move the words and leave the box lined up with its parent's.
    The row wrapper is what keeps the pair together on one line.
]]
test("sub-options are indented by a leading cell, not by padded captions", function()
	local ns = loadAddon()
	local masterLooterArgs = ns.BuildMasterLooterOptions().args
	local rollArgs = ns.BuildAutomatedRollOptions().args
	local announcementArgs = ns.BuildAnnouncementOptions().args

	for _, entry in ipairs({
		{ masterLooterArgs, "outsideInstancesRow" },
		{ masterLooterArgs, "questItemsRow" },
		{ masterLooterArgs, "destinationRow_epic" },
		{ rollArgs, "qualityRowParty" },
		{ announcementArgs, "tradeOutputRow" },
		{ announcementArgs, "tradeExampleRow" },
		{ announcementArgs, "destinationExampleRow" },
		{ announcementArgs, "autoExampleRow" },
		{ announcementArgs, "manualExampleRow" },
		{ ns.BuildAutomatedOpeningOptions().args, "outsideInstancesRow" },
		{ ns.BuildAutomatedOpeningOptions().args, "soloOnlyRow" },
		{ ns.BuildOpenableItemsOptions().args, "ignoreNotificationsExampleRow" },
		{ ns.BuildLockboxOptions().args, "notificationsExampleRow" },
	}) do
		local key = entry[2]
		local row = entry[1][key]
		checkEqual("group", row.type, key .. " is a row wrapper")
		check(row.inline, key .. " renders as a bare SimpleGroup, so it takes a line of its own")
		checkEqual("", row.name, key .. " draws no title")
		checkEqual(ns.OPTIONS_SUB_INDENT_WIDTH, row.args.indent.width, key .. " leads with the one sub-option indent")

		-- A caption may be a function, exactly as AceConfig's `name` accepts.
		local caption = row.args.control1.name
		if type(caption) == "function" then
			caption = caption()
		end
		check(not caption:find("^%s"), key .. " does not also pad its caption")
	end
end)

--[[
    A control explains itself once, in its tooltip: the quest-item caveats and
    the outside-instances caution ride in the toggles' desc, with no note rows
    under them.
]]
test("the master looter sub-options explain themselves in their tooltips", function()
	local ns = loadAddon()
	local args = ns.BuildMasterLooterOptions().args

	checkEqual(
		ns.L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"],
		args.questItemsRow.args.control1.desc,
		"the quest item toggle carries its whole explanation"
	)
	checkEqual(
		ns.L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"],
		args.outsideInstancesRow.args.control1.desc,
		"and so does the outside-instances toggle"
	)
	for _, key in ipairs({ "outsideInstancesCaution", "questItemsNote", "questItemsCaution" }) do
		checkEqual(nil, args[key], key .. " is gone from the panel")
	end
end)

--[[
    Hiding rides on the group rather than the control inside it — the tier rows
    depend on this, since hiding only the label and dropdown would leave five
    indent cells behind as blank lines.
]]
test("a hidden sub-row takes its indent cell with it", function()
	local ns = loadAddon()
	local row = ns.OptionsSubRow(1, function()
		return true
	end, { { type = "description", name = "text", width = 1 } })

	check(evaluate(row.hidden), "the group carries the hidden check")
	check(not evaluate(row.args.indent.hidden), "the indent cell has none of its own, so it hides with the group")
	check(not evaluate(row.args.control1.hidden), "and neither does the control")
end)

--[[
    The fake reports a loot threshold of Uncommon, so Epic sits above it and
    Poor below: every quality the threshold reaches gets its row, always, and
    the ones it can't reach never do. Each is captioned in its quality's color.
]]
test("the quality rows follow the loot threshold, each in its own color", function()
	local ns = loadAddon()
	local args = ns.BuildMasterLooterOptions().args
	ns.db.profile.autoMasterLoot = true

	for _, entry in ipairs({ { "epic", 4, true }, { "rare", 3, true }, { "uncommon", 2, true }, { "poor", 0, false } }) do
		local row = args["destinationRow_" .. entry[1]]
		local shown = not evaluate(row.hidden)
		checkEqual(entry[3], shown, entry[1] .. " row shown only at or above the loot threshold")
		checkEqual(
			shown,
			not evaluate(args["spacer_destination_" .. entry[1]].hidden),
			entry[1] .. " takes its spacer along"
		)
		check(
			row.args.control1.name:find(ns.GetQualityColor(entry[2]), 1, true) ~= nil,
			entry[1] .. " is captioned in its own quality's color"
		)
	end
	check(args.sendAll.order < args.destinationRow_epic.order, "Send All Loot To leads the rows")
	checkEqual(nil, args.setTiersIndividually, "and no toggle collapses them")
end)

--[[
    With automation on and nobody picked for any quality the threshold reaches,
    nothing is handed out, so a line says every drop waits in the loot window.
    One picked quality is enough to drop it: the blank rows speak for the rest.
]]
test("a line says loot waits for you while nobody is picked", function()
	local ns = loadAddon()
	local args = ns.BuildMasterLooterOptions().args
	local note = args.noDestinationNote
	ns.db.profile.autoMasterLoot = true
	ns.db.profile.destinations = {}

	check(not evaluate(note.hidden), "shown while nobody is picked")
	checkEqual(ns.GetColor("HELP") .. ns.L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] .. "|r", note.name, "in silver")
	check(args.destinationsDesc.order < note.order and note.order < args.sendAll.order, "under the description")

	ns.db.profile.destinations.poor = "self"
	check(not evaluate(note.hidden), "a quality below the threshold doesn't count")
	ns.db.profile.destinations.rare = "self"
	check(evaluate(note.hidden), "one picked quality drops it")
	check(evaluate(args.spacerAfterNoDestinationNote.hidden), "its spacer with it")

	ns.db.profile.destinations = {}
	ns.db.profile.autoMasterLoot = false
	check(evaluate(note.hidden), "and it leaves with the switch")
end)

--[[
    A dropdown sub-option pays for its indent out of its caption, never out of
    its dropdown, so every dropdown on a panel shares one column and one right
    edge, sub-option or not.
]]
test("a sub-option dropdown keeps the panel's control column", function()
	local ns = loadAddon()
	local row = ns.BuildMasterLooterOptions().args.destinationRow_epic

	checkEqual(ns.OPTIONS_CONTROL_WIDTH, row.args.control2.width, "a tier row keeps the shared control width")
	checkNear(
		ns.OPTIONS_LABEL_WIDTH,
		row.args.indent.width + row.args.control1.width,
		"it spends exactly one label column on indent and caption"
	)
	checkNear(
		ns.OPTIONS_ROW_WIDTH,
		row.args.indent.width + row.args.control1.width + row.args.control2.width,
		"and ends on the panel's shared right edge"
	)

	-- A roll's quality row, under its roll, keeps the column too.
	local qualityRow = ns.BuildAutomatedRollOptions().args.qualityRowParty
	checkEqual(ns.OPTIONS_CONTROL_WIDTH, qualityRow.args.control2.width, "the roll threshold keeps the control column")
	checkNear(
		ns.OPTIONS_ROW_WIDTH,
		qualityRow.args.indent.width + qualityRow.args.control1.width + qualityRow.args.control2.width,
		"and ends on the right edge"
	)
end)

--[[
    Panel order, top to bottom: what GogoLoot does first, with who receives each
    quality right under its switch, then the group's own loot settings it
    merely reads, closed by the pop-up that shows them. The Ignore List is a
    panel of its own beneath it. The opening block carries no header of its own
    — the tab is already titled Master Looter and that block is what the title
    describes.
]]
test("the master looter panel leads with what the add-on does", function()
	local ns = loadAddon()
	local args = ns.BuildMasterLooterOptions().args

	checkEqual(nil, args.autoHeader, "the opening block takes the panel's own title")
	checkEqual(1, args.autoDesc.order, "so the panel opens straight on its description")

	local function order(key)
		return args[key].order
	end
	check(order("autoDesc") < order("autoMasterLoot"), "description, then the master switch")
	check(order("autoMasterLoot") < order("questItemsRow"), "then its sub-options")
	check(order("questItemsRow") < order("destinationsHeader"), "then Loot Destinations")
	check(order("destinationsHeader") < order("sendAllLabel"), "which opens on Send All Loot To")
	check(order("sendAll") < order("destinationRow_epic"), "then a row per quality")
	check(order("destinationRow_poor") < order("currentLootHeader"), "then Group Loot Settings")
	checkEqual(
		ns.GetColor("TITLE") .. ns.L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] .. "|r",
		args.currentLootHeader.name,
		"under its own header"
	)
	check(order("currentLootHeader") < order("leaderNote"), "which opens on who controls it")
	check(order("leaderNote") < order("lootMethodLabel"), "then the loot method")
	check(order("lootMethodLabel") < order("lootMethod"), "its dropdown straight after its label")
	check(order("lootMethod") < order("lootThresholdLabel"), "then the threshold")
	check(order("lootThreshold") < order("masterLooterPopup"), "and the pop-up that shows them closes it")
	checkEqual(nil, args.ignoreList, "the Ignore List lives on a child panel, not here")
end)

--[[
    One statement of who controls the loot settings, naming the leader whoever
    that is. It reads as a fact about whose group it is rather than as a
    complaint about a greyed control, so it stays up when the leader is you.
    Solo, where there is nobody to name, a silver line says why both are
    greyed out and how to change them.
]]
test("the leader note names whoever leads, the player included", function()
	local ns, env = loadAddon()
	local state = env.__state
	local args = ns.BuildMasterLooterOptions().args
	local note = args.leaderNote

	state.inGroup = false
	state.leaderUnit = nil
	checkEqual(
		ns.GetColor("HELP") .. ns.L["MASTER_LOOTER_SOLO_NOTE"] .. "|r",
		note.name(),
		"solo, it says to join a group, in silver"
	)
	check(not evaluate(args.spacerAfterLeaderNote.hidden), "with its blank line after it")

	state.inGroup = true
	state.groupMembers = 2
	state.leaderUnit = "party1"
	state.unitNames.party1 = "Hippobob"
	check(not evaluate(note.hidden), "it appears once somebody else leads")
	check(note.name():find("Hippobob", 1, true) ~= nil, "and names them")
	check(evaluate(args.lootMethod.disabled), "which is when the dropdowns are greyed")

	--[[
	    The party case is the one that used to fail: a party's unit ids run
	    party1..partyN-1 and never include the player, so a party the player led
	    resolved to no leader at all while the raid path named them.
	]]
	state.leaderUnit = "player"
	state.unitNames.player = "Gogoshaman"
	check(not evaluate(note.hidden), "and stays up when the leader is you, in a party")
	check(note.name():find("Gogoshaman", 1, true) ~= nil, "naming you")
	check(not evaluate(args.spacerAfterLeaderNote.hidden), "its spacer with it")
	check(not evaluate(args.lootMethod.disabled), "with the dropdowns live, since you control them")

	state.inRaid = true
	state.groupMembers = 5
	state.unitNames.raid1 = "Gogoshaman"
	check(not evaluate(note.hidden), "and in a raid you lead")
	check(note.name():find("Gogoshaman", 1, true) ~= nil, "naming you there too")
end)

--[[
    autoGreed is the master switch for every automated roll, Item Overrides
    included, so with it off nothing else on that panel changes anything. All of
    it hides rather than sitting there inert — including the spacers, or the page
    would collapse to a toggle followed by a column of blank lines.
]]
test("the automated rolls panel hides everything behind its master switch", function()
	local ns = loadAddon()
	local args = ns.BuildAutomatedRollOptions().args

	local alwaysShown = {
		description = true,
		spacerAfterDesc = true,
		autoGreed = true,
	}

	ns.db.profile.autoGreed = false
	for key, entry in pairs(args) do
		if alwaysShown[key] then
			check(not evaluate(entry.hidden), key .. " stays on show — it is the switch itself, or leads to it")
		else
			check(evaluate(entry.hidden), key .. " hides while automated rolls are off")
		end
	end

	ns.db.profile.autoGreed = true
	for key, entry in pairs(args) do
		check(not evaluate(entry.hidden), key .. " comes back once automated rolls are on")
	end
end)

--[[
    Each group context is a caption with its roll beside it, and the quality
    that roll reaches on an indented row under it, which leaves while the roll
    is Manual: there is nothing for it to limit then. No captions sit over the
    dropdowns.
]]
test("each roll sits beside its context, with its quality under it until it is Manual", function()
	local ns = loadAddon()
	local args = ns.BuildAutomatedRollOptions().args
	ns.db.profile.autoGreed = true

	for _, suffix in ipairs({ "Party", "Raid" }) do
		local rollRow = args["rollRow" .. suffix]
		local qualityRow = args["qualityRow" .. suffix]
		checkEqual(
			ns.L["ROLLS_IN_" .. string.upper(suffix)],
			rollRow.args.control1.name,
			suffix .. ": the context captions its row"
		)
		checkEqual(ns.ROLL_OVERRIDE_LABELS, rollRow.args.control2.values, suffix .. ": the roll sits beside it")
		checkEqual(nil, rollRow.args.indent, suffix .. ": at the panel's own level")
		check(rollRow.order < qualityRow.order, suffix .. ": its quality comes under it")
		checkEqual(
			ns.OptionsSubLabel(ns.L["ROLLS_UP_TO_QUALITY"]),
			qualityRow.args.control1.name,
			suffix .. ": captioned Up to Quality, in silver"
		)

		ns.db.profile["autoRollAction" .. suffix] = ns.MANUAL
		check(evaluate(qualityRow.hidden), suffix .. ": Manual takes the quality row away")
		ns.db.profile["autoRollAction" .. suffix] = ns.GREED
		check(not evaluate(qualityRow.hidden), suffix .. ": and a roll brings it back")
	end
	checkEqual(nil, args.rollColumns, "no column captions over the dropdowns")
	checkEqual(nil, args.rollReportRow, "and Report Each Roll is gone")
end)

--[[
    Below the switch the panel reads as two sections: Loot Thresholds over the
    party and raid rows, then Roll Messages over Print Item in Chat, its
    example, and Hide Roll Messages.
]]
test("the automated rolls panel has a Party and Raid Rolls and a Roll Messages section", function()
	local ns, env = loadAddon()
	local args = ns.BuildAutomatedRollOptions().args
	local L = ns.L
	ns.db.profile.autoGreed = true

	check(
		args.partyAndRaidHeader.name:find(L["ROLLS_PARTY_AND_RAID_HEADER"], 1, true) ~= nil,
		"Party and Raid Rolls heads the rolls"
	)
	check(
		args.rollMessagesHeader.name:find(L["ROLLS_MESSAGES_HEADER"], 1, true) ~= nil,
		"Roll Messages heads the messages"
	)
	local inOrder = {
		args.autoGreed,
		args.partyAndRaidHeader,
		args.rollRowParty,
		args.rollRowRaid,
		args.rollMessagesHeader,
		args.printRolledItems,
		args.printRolledItemsExampleRow,
		args.spacerAfterPrintRolledItems,
		args.hideRollMessagesRow,
		args.winnerSummaryExampleRow,
	}
	for index = 2, #inOrder do
		check(inOrder[index - 1].order < inOrder[index].order, "row " .. index .. " comes after the one before it")
	end
	checkEqual(L["ROLLS_PRINT_ITEM"], args.printRolledItems.name, "Print Item in Chat")
	local example = args.printRolledItemsExampleRow.args.control1.name()
	check(
		example:find(ns.GetColor("TEXT") .. "You rolled " .. env.GREED .. " on ", 1, true) ~= nil
			and example:find(ns.GetColor("INFO") .. L["ADDON_TITLE"] .. "|r", 1, true) ~= nil,
		"its example is the printed line"
	)
end)

--[[
    The restore button is the first thing in the Item Overrides list, so without
    a break it butts straight up against the toggle above and reads as part of
    it rather than as a control of its own.
]]
test("the Item Overrides list is separated from the toggle above it", function()
	local ns = loadAddon()
	local args = ns.BuildItemOverridesOptions().args

	check(args.spacerBeforeItemOverrides ~= nil, "a break sits between the toggle and the list")
	check(args.itemOverridesEnable.order < args.spacerBeforeItemOverrides.order, "after the toggle")
	check(args.spacerBeforeItemOverrides.order < args.itemOverrides.order, "and before the list")
end)

--[[
    The rows that carry a toggle's one setting on the toggle's own line, each
    with the saved key its toggle reads.
]]
local function ToggleRowsWithSetting(ns)
	local announcementArgs = ns.BuildAnnouncementOptions().args
	local lockboxArgs = ns.BuildLockboxOptions().args
	return {
		{ key = "autoAnnounceRow", row = announcementArgs.autoAnnounceRow, setting = "announceMasterLootAuto" },
		{ key = "tradeRow", row = announcementArgs.tradeRow, setting = "announceTrade" },
		{ key = "lootSoundRow", row = ns.BuildLootSoundOptions().args.lootSoundRow, setting = "lootSounds" },
		{ key = "tooltipsRow", row = lockboxArgs.tooltipsRow, setting = "lockboxTooltips" },
		{ key = "notificationsRow", row = lockboxArgs.notificationsRow, setting = "lockboxNotifications" },
	}
end

--[[
    A toggle's one setting rides on the toggle's own line, in the control
    column, uncaptioned because the toggle already names it, and the line ends
    where every other row does.
]]
test("a toggle's setting rides on the toggle's own line", function()
	local ns = loadAddon()

	for _, entry in ipairs(ToggleRowsWithSetting(ns)) do
		local key, row = entry.key, entry.row
		local cells = row.args
		checkEqual("group", row.type, key .. " is a row wrapper")
		check(row.inline, key .. " takes a line of its own")
		checkEqual("", row.name, key .. " draws no title")
		checkEqual("toggle", cells.toggle.type, key .. " leads with its toggle")
		checkEqual(1, cells.toggle.order, key .. " puts the toggle first")
		checkEqual(nil, cells.controlRow, key .. " keeps the setting on the toggle's line")
		checkEqual("", cells.control.name, key .. " leaves the setting uncaptioned")
		checkEqual(ns.OPTIONS_CONTROL_WIDTH, cells.control.width, key .. " keeps the shared control width")
		check(cells.control.order > cells.toggle.order, key .. " puts the setting after the toggle")

		-- A sound's speaker is the one cell allowed past the edge, in the margin after the setting.
		local lineWidth = 0
		for cellKey, cell in pairs(cells) do
			if cellKey ~= "preview" then
				lineWidth = lineWidth + cell.width
			end
		end
		checkNear(ns.OPTIONS_ROW_WIDTH, lineWidth, key .. " ends on the panel's shared right edge")
	end
end)

--[[
    The setting configures something that isn't happening while its toggle is
    off, so it leaves the line, taking a sound's speaker after it along; the
    toggle and its row stay.
]]
test("a toggle's setting leaves its line while the toggle is off", function()
	local ns = loadAddon()

	for _, entry in ipairs(ToggleRowsWithSetting(ns)) do
		local key, row = entry.key, entry.row
		ns.db.profile[entry.setting] = true
		check(not evaluate(row.args.control.hidden), key .. " shows its setting while on")

		ns.db.profile[entry.setting] = false
		check(evaluate(row.args.control.hidden), key .. " hides its setting while off")
		if row.args.preview then
			check(evaluate(row.args.preview.hidden), key .. " and the speaker after it")
		end
		check(not evaluate(row.hidden), key .. " keeps its row")
		check(not evaluate(row.args.toggle.hidden), key .. " and its toggle")
	end
end)

--[[
    AceGUI draws a checkbox caption on one line and cuts a longer one short,
    and a translated caption can run half as long again as the English. One
    too long for the label column takes the whole line, and its setting drops
    to the line below: still in the control column, still leaving with the
    toggle.
]]
test("a caption too long to share its line sends the setting to the line below", function()
	local ns = loadAddon()
	ns.OptionsToggleWidth = function()
		return ns.OPTIONS_LABEL_WIDTH + 0.5
	end
	local cells = ns.BuildLockboxOptions().args.tooltipsRow.args

	checkEqual("full", cells.toggle.width, "the caption takes the whole line")
	checkEqual(nil, cells.control, "with nothing beside it")
	local below = cells.controlRow
	checkEqual("group", below.type, "the line below is a group, which always starts a line of its own")
	check(below.inline, "drawn inline")
	checkEqual("", below.name, "with no title")
	checkNear(ns.OPTIONS_LABEL_WIDTH, below.args.filler.width, "a filler spans the label column")
	checkEqual(ns.OPTIONS_CONTROL_WIDTH, below.args.control.width, "so the setting lands in the control column")
	check(below.args.filler.order < below.args.control.order, "filler first")

	ns.db.profile.lockboxTooltips = false
	check(evaluate(below.hidden), "the line leaves with the toggle")
	ns.db.profile.lockboxTooltips = true
	check(not evaluate(below.hidden), "and comes back with it")

	-- A sound's speaker drops with its setting, still after it.
	local soundCells = ns.BuildLootSoundOptions().args.lootSoundRow.args
	checkEqual("full", soundCells.toggle.width, "a long sound caption takes the whole line too")
	checkEqual(nil, soundCells.preview, "with nothing beside it")
	local soundBelow = soundCells.controlRow.args
	check(soundBelow.preview.order > soundBelow.control.order, "its speaker drops with its quality, after it")
end)

--[[
    A sound toggle carries its speaker the way Control Freak does: past the end
    of the row, after its dropdown, in the right margin. A sound with no
    dropdown gets a blank cell in the dropdown's place, so the two speakers line
    up. Each leaves with its toggle.
]]
test("a sound toggle's speaker sits after its dropdown and leaves with the toggle", function()
	local ns, env = loadAddon()
	local args = ns.BuildLootSoundOptions().args

	for _, key in ipairs({ "lootSoundRow", "pickPocketRow" }) do
		local cells = args[key].args
		checkEqual("execute", cells.preview.type, key .. " carries a speaker")
		check(cells.preview.image ~= nil, key .. " drawn as an icon")
		checkEqual("", cells.preview.name, key .. " with no caption of its own")
		check((cells.preview.desc or "") ~= "", key .. " saying what it plays in its tooltip")
		checkEqual(ns.OPTIONS_SPEAKER_WIDTH, cells.preview.width, key .. " sizes the speaker to its icon")
		checkEqual(ns.OPTIONS_LABEL_WIDTH, cells.toggle.width, key .. " gives its caption the label column")
		local beforeSpeaker = cells.control or cells.controlSpace
		checkEqual(ns.OPTIONS_CONTROL_WIDTH, beforeSpeaker.width, key .. " fills the control column")
		check(cells.preview.order > beforeSpeaker.order, key .. " puts the speaker after it, past the row's end")
	end
	checkEqual(nil, args.pickPocketRow.args.control, "the Pick Pocket sound has no setting of its own")
	checkEqual(" ", args.pickPocketRow.args.controlSpace.name, "so a blank cell holds its place")

	local sounds = env.__state.sounds
	args.lootSoundRow.args.preview.func()
	checkEqual("file", sounds[#sounds] and sounds[#sounds].kind, "the speaker plays the loot sound")
	checkEqual(ns.LOOT_SOUND_FILE, sounds[#sounds] and sounds[#sounds].sound, "the file the loot sound plays")
	args.pickPocketRow.args.preview.func()
	checkEqual(
		ns.SOUND_KIT_IDS.PICK_POCKET,
		sounds[#sounds] and sounds[#sounds].sound,
		"and the Pick Pocket one its own"
	)

	ns.db.profile.lootSounds = false
	ns.db.profile.pickPocketSound = false
	check(evaluate(args.lootSoundRow.args.preview.hidden), "the speaker leaves while its sound is off")
	check(evaluate(args.pickPocketRow.args.preview.hidden), "and so does Pick Pocket's")
	check(evaluate(args.pickPocketRow.args.controlSpace.hidden), "taking its blank cell along")
	ns.db.profile.lootSounds = true
	check(not evaluate(args.lootSoundRow.args.preview.hidden), "and it comes back with the toggle")
end)

--[[
    An on/off choice that belongs to a toggle sits indented under it with a
    silver caption and leaves the panel with it. Each keeps the saved string
    its feature reads, so turning a dropdown into a checkbox needed no
    migration.
]]
test("the sub-toggles keep the saved strings their features read", function()
	local ns = loadAddon()
	local profile = ns.db.profile

	local cases = {
		{
			row = ns.BuildAutomatedOpeningOptions().args.outsideInstancesRow,
			caption = "AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES",
			parent = "autoOpen",
			setting = "autoOpenWhere",
			on = "OUTSIDE_INSTANCES",
			off = "ALWAYS",
		},
		{
			row = ns.BuildAutomatedOpeningOptions().args.soloOnlyRow,
			caption = "AUTOMATED_OPENING_ONLY_SOLO",
			parent = "autoOpen",
			setting = "autoOpenGroup",
			on = "SOLO_ONLY",
			off = "ALWAYS",
		},
	}

	for _, case in ipairs(cases) do
		local toggle = case.row.args.control1
		local label = case.setting
		checkEqual(ns.OPTIONS_SUB_INDENT_WIDTH, case.row.args.indent.width, label .. " is indented under its toggle")
		checkEqual(ns.OptionsSubLabel(ns.L[case.caption]), toggle.name, label .. " carries a silver caption")

		toggle.set(nil, true)
		checkEqual(case.on, profile[case.setting], label .. " saves its on string")
		check(toggle.get(), label .. " and reads it back as on")
		toggle.set(nil, false)
		checkEqual(case.off, profile[case.setting], label .. " saves its off string")
		check(not toggle.get(), label .. " and reads it back as off")

		profile[case.parent] = false
		check(evaluate(case.row.hidden), label .. " leaves the panel with its toggle")
		profile[case.parent] = true
		check(not evaluate(case.row.hidden), label .. " and comes back with it")
	end
end)

--[[
    Where trade summaries go is a captioned dropdown under the toggle, Channel,
    writing the saved announceTradeOutput string the trade module and the trade
    window's tooltip read, and leaving the panel with the toggle.
]]
test("trade announcements pick whisper, group chat, or Me Only from a Channel dropdown", function()
	local ns = loadAddon()
	local profile = ns.db.profile
	local row = ns.BuildAnnouncementOptions().args.tradeOutputRow
	local caption, dropdown = row.args.control1, row.args.control2

	checkEqual(ns.OptionsSubLabel(ns.L["TRADE_CHANNEL"]), caption.name, "it is captioned Channel, in silver")
	checkEqual("select", dropdown.type, "it is a dropdown")
	checkEqual(ns.OPTIONS_CONTROL_WIDTH, dropdown.width, "in the shared control column")
	checkEqual("Whisper", dropdown.values.whisper, "offering the game's own Whisper")
	checkEqual(ns.L["TRADE_OUTPUT_GROUP"], dropdown.values.group, "Group Chat")
	checkEqual(ns.L["TRADE_OUTPUT_SELF"], dropdown.values.self, "and Me Only")
	checkEqual("whisper", dropdown.sorting[1], "Whisper first")
	checkEqual("self", dropdown.sorting[3], "Me Only last")

	dropdown.set(nil, "group")
	checkEqual("group", profile.announceTradeOutput, "it saves the string the trade module reads")
	checkEqual("group", dropdown.get(), "and reads it back")

	profile.announceTrade = false
	check(evaluate(row.hidden), "it leaves the panel with its toggle")
	profile.announceTrade = true
	check(not evaluate(row.hidden), "and comes back with it")
end)

--[[
    Everything below these switches belongs to them, the gaps between their
    sections included: with the switch off, the panel ends at the switch
    rather than trailing a column of blank lines.
]]
test("a panel below its switch leaves with it, gaps included", function()
	local ns = loadAddon()
	-- Whole Group, so Group Quality, which belongs to it, is on show with the rest.
	ns.db.profile.lootToastSource = "GROUP"

	for _, case in ipairs({
		{
			name = "Announcements",
			args = ns.BuildAnnouncementOptions().args,
			setting = "lootNotifications",
			alwaysShown = { description = true, spacerAfterDesc = true, lootNotifications = true },
		},
		{
			name = "Loot Toasts",
			args = ns.BuildLootToastOptions().args,
			setting = "lootToasts",
			alwaysShown = {
				description = true,
				spacerAfterDesc = true,
				lootToastsRow = true,
			},
		},
		{
			name = "Automated Opening",
			args = ns.BuildAutomatedOpeningOptions().args,
			setting = "autoOpen",
			alwaysShown = { description = true, spacerAfterDesc = true, autoOpen = true },
		},
	}) do
		ns.db.profile[case.setting] = false
		for key, entry in pairs(case.args) do
			if case.alwaysShown[key] then
				check(not evaluate(entry.hidden), case.name .. ": " .. key .. " stays on show")
			else
				check(evaluate(entry.hidden), case.name .. ": " .. key .. " leaves with the switch")
			end
		end

		ns.db.profile[case.setting] = true
		for key, entry in pairs(case.args) do
			check(not evaluate(entry.hidden), case.name .. ": " .. key .. " comes back with it")
		end
	end
end)

--[[
    Lockboxes is a child panel of Automated Opening rather than a section of
    it: its description, then its two toggles. It works with nothing opening,
    so nothing on it hides behind the Automated Opening switch.
]]
test("Lockboxes is a child panel of Automated Opening", function()
	local ns = loadAddon()
	local args = ns.BuildLockboxOptions().args

	checkEqual(ns.L["TAB_LOCKBOXES"], ns.BuildLockboxOptions().name, "titled Lockboxes")
	checkEqual(
		ns.L["LOCKBOXES_SECTION_DESCRIPTION"]:format("Rogue", "Lockpicking"),
		args.description.name,
		"with its description, in the game's own names"
	)
	check(args.description.order < args.tooltipsRow.order, "description first")
	check(args.tooltipsRow.order < args.notificationsRow.order, "then tooltips, then notifications")

	for key in pairs(ns.BuildAutomatedOpeningOptions().args) do
		check(
			not key:find("^lockbox") and key ~= "tooltipsRow",
			"the Automated Opening panel no longer carries " .. key
		)
	end

	ns.db.profile.autoOpen = false
	for key, entry in pairs(args) do
		check(not evaluate(entry.hidden), key .. " stays on show with opening off")
	end
end)

--[[
    The Ignore notice sits on the Openables List, above the list, and never
    hides: Speedy Loot gives its notice with opening off too (maintainer,
    2026-11-03). Automated Opening no longer carries it.
]]
test("the Ignore notice lives on the Openables List and never hides", function()
	local ns = loadAddon()
	local args = ns.BuildOpenableItemsOptions().args
	local toggle = args.ignoreNotifications

	checkEqual("toggle", toggle.type, "it is a checkbox")
	checkEqual("full", toggle.width, "at the panel's own level, not indented")
	checkEqual(ns.L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"], toggle.name, "Enable Ignore Notifications")
	check(toggle.order < args.itemList.order, "above the list")
	toggle.set(nil, false)
	checkEqual(false, ns.db.profile.openingIgnoreNotifications, "it writes the setting Speedy Loot and opening read")
	ns.db.profile.autoOpen = false
	check(not evaluate(toggle.hidden), "it stays on show with opening off")

	checkEqual(
		nil,
		ns.BuildAutomatedOpeningOptions().args.ignoreNotifications,
		"Automated Opening no longer carries it"
	)
end)

--[[
    Under the Ignore notice sits an example of what it prints: the plain
    notice's real template, drawn as printed with a real container from the
    data, and with no marker. It stays on show while its toggle is off, and
    while opening is off it shows Speedy Loot's left-in-the-window notice
    instead, the one that still prints then.
]]
test("the Ignore notice's example is its real printed line", function()
	local ns, env = loadAddon()
	local L = ns.L
	local args = ns.BuildOpenableItemsOptions().args
	local row = args.ignoreNotificationsExampleRow

	local container = ns.ExampleIgnoredContainer()
	checkEqual(ns.OPENING_IGNORE, ns.OPENABLE_ITEMS[container], "the container is one the data sets to Ignore")
	-- A stand-in template, so the example is seen to follow whatever the notice says.
	L["MESSAGE_ITEM_IGNORED"] = "<%s is ignored>"
	check(
		row.args.control1.name():find(L["ITEM_LOADING"]:format(container), 1, true) ~= nil,
		"it reads as loading until the client has the item"
	)
	env.__state.itemNames[container] = { name = "Sealed Box", quality = 1 }
	local text = row.args.control1.name()
	checkEqual(
		1,
		text:find(ns.GetColor("HELP") .. L["OPTIONS_EXAMPLE"]:format(""), 1, true),
		"it reads Example, in silver"
	)
	check(text:find(ns.GetColor("INFO") .. L["ADDON_TITLE"] .. "|r", 1, true) ~= nil, "the printed line, name first")
	check(
		text:find(ns.GetColor("TEXT") .. "<|Hitem:" .. container .. "|h[Sealed Box]|h is ignored>", 1, true) ~= nil,
		"the notice in the print's own body color, with the real link"
	)
	checkEqual(nil, text:find("UI-RaidTargetingIcon", 1, true), "with no marker, since nobody else sees it")

	check(args.ignoreNotifications.order < row.order, "it sits under its toggle")
	ns.db.profile.openingIgnoreNotifications = false
	check(not evaluate(row.hidden), "and stays on show with the notice off")
	ns.db.profile.autoOpen = false
	check(not evaluate(row.hidden), "and with opening off")
	L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] = "<%s stays behind>"
	check(
		row.args.control1.name():find("[Sealed Box]|h stays behind>", 1, true) ~= nil,
		"where it shows Speedy Loot's notice instead"
	)
end)

--[[
    Loot Sounds is a panel of its own, right after Loot Toasts: its description,
    then its master switch, then the chime with its quality and the Pick Pocket
    sound, each with a speaker. Both rows leave with the master switch, and
    nothing on it hides behind the toasts' toggle.
]]
test("Loot Sounds is a panel of its own, right after Loot Toasts", function()
	local ns = loadAddon()
	local options = ns.BuildLootSoundOptions()
	local args = options.args
	checkEqual(ns.L["TAB_LOOT_SOUNDS"], options.name, "titled Loot Sounds")
	checkEqual(
		ns.L["LOOT_SOUNDS_PANEL_DESCRIPTION"]:format("Pick Pocket"),
		args.description.name,
		"opening on its description, with the spell's own name"
	)
	checkEqual(ns.L["LOOT_SOUNDS_SWITCH"], args.lootSoundsEnabled.name, "then Enable Loot Sounds")
	checkEqual("full", args.lootSoundsEnabled.width, "on a line of its own")
	check(args.description.order < args.lootSoundsEnabled.order, "below the description")
	check(args.lootSoundsEnabled.order < args.lootSoundRow.order, "above the chime")
	check(args.lootSoundRow.order < args.pickPocketRow.order, "then the chime, then the Pick Pocket sound")
	ns.db.profile.lootToasts = false
	for key, entry in pairs(args) do
		check(not evaluate(entry.hidden), key .. " stays with the toasts off")
	end

	ns.db.profile.lootSoundsEnabled = false
	for _, key in ipairs({ "spacerAfterSwitch", "lootSoundRow", "spacerBeforePickPocket", "pickPocketRow" }) do
		check(evaluate(args[key].hidden), key .. " leaves with the master switch")
	end
	check(not evaluate(args.lootSoundsEnabled.hidden), "while the switch itself stays")
end)

--[[
    Announcements opens on its master switch, then holds two sections, each
    under its own header with its description: Trade Announcements, then Master
    Looter Announcements. The sounds, which only the player hears, live on the
    Loot Sounds panel.
]]
test("the announcements panel opens on its switch, then trades and master loot", function()
	local ns, env = loadAddon()
	local L = ns.L
	local options = ns.BuildAnnouncementOptions()
	local args = options.args
	checkEqual("Loot Announcements", L["TAB_ANNOUNCEMENTS"], "the panel is called Loot Announcements")
	checkEqual(L["TAB_ANNOUNCEMENTS"], options.name, "and titled so")
	checkEqual("toggle", args.lootNotifications.type, "it opens on its switch")
	checkEqual("full", args.lootNotifications.width, "on a line of its own")
	checkEqual(nil, args.lootSoundRow, "the loot sound lives on the Loot Sounds panel")
	checkEqual(nil, args.pickPocketRow, "and so does the Pick Pocket sound")

	for _, section in ipairs({
		{ header = "tradeHeader", title = "TAB_TRADE_ANNOUNCEMENTS", desc = "tradeDesc", text = "TRADE_DESCRIPTION" },
		{
			header = "masterLooterHeader",
			title = "TAB_MASTER_LOOTER_ANNOUNCEMENTS",
			desc = "masterLooterDesc",
			text = "MASTER_LOOTER_ANNOUNCE_DESCRIPTION",
		},
	}) do
		checkEqual("header", args[section.header].type, section.title .. " has a header")
		check(args[section.header].name:find(L[section.title], 1, true) ~= nil, section.title .. " is titled")
		checkEqual(L[section.text], args[section.desc].name, section.title .. " has its description")
	end

	local topToBottom = {
		"lootNotifications",
		"tradeHeader",
		"tradeRow",
		"tradeOutputRow",
		"tradeExampleRow",
		"masterLooterHeader",
		"announceDestinations",
		"destinationExampleRow",
		"autoAnnounceRow",
		"autoExampleRow",
		"manualAnnounce",
	}
	for index = 2, #topToBottom do
		local above, below = topToBottom[index - 1], topToBottom[index]
		check(args[above].order < args[below].order, above .. " comes before " .. below)
	end

	local treeName
	for _, entry in ipairs(env.__state.blizOptions) do
		if entry.appName == ns.OPTIONS_REGISTRY.Announcements then
			treeName = entry.name
		end
	end
	checkEqual(L["TAB_ANNOUNCEMENTS"], treeName, "and so is its entry in the settings tree")
end)

--[[
    Loot Toasts: the toggle, then the position buttons, then Stack (the four
    stack dropdowns) and Text (face, size, outline), each under a header.
    Filters is a panel of its own under it, and Loot Sounds one after it. The
    rows sit at the panel's own level, with no indent cell and no silver
    caption, and every dropdown keeps the shared control column and right edge.
]]
test("the loot toasts panel opens on its switch and position buttons, then Stack and Text", function()
	local ns = loadAddon()
	local args = ns.BuildLootToastOptions().args

	checkEqual("Loot Toasts", ns.BuildLootToastOptions().name, "the panel is titled Loot Toasts")
	checkEqual("header", args.stackHeader.type, "Stack has a header")
	checkEqual("header", args.textHeader.type, "and so does Text")
	check(args.stackHeader.name:find(ns.L["LOOT_TOASTS_STACK_HEADER"], 1, true) ~= nil, "and Stack")
	check(args.textHeader.name:find(ns.L["LOOT_TOASTS_TEXT_HEADER"], 1, true) ~= nil, "and Text")
	checkEqual(ns.OPTIONS_LABEL_WIDTH, args.lootToastsRow.args.toggle.width, "the toggle shares its line")
	checkEqual("select", args.lootToastsRow.args.control.type, "with the Standard Loot Messages dropdown beside it")

	local topToBottom = {
		"lootToastsRow",
		"positionRow",
		"stackHeader",
		"maxItemsRow",
		"durationRow",
		"growthRow",
		"alignRow",
		"textHeader",
		"fontRow",
		"fontSizeRow",
		"outlineRow",
	}
	for index = 2, #topToBottom do
		local above, below = topToBottom[index - 1], topToBottom[index]
		check(args[above].order < args[below].order, above .. " comes before " .. below)
	end
	for _, key in ipairs({
		"sourceRow",
		"groupQualityRow",
		"alwaysShowCaption",
		"alwaysShowGrid",
		"displayHeader",
		"bagCountToggle",
		"winningRollRow",
		"lootSoundsHeader",
		"lootSoundRow",
		"pickPocketRow",
		"filtersHeader",
		"filtersCaption",
		"filterRow_ARMOR",
	}) do
		checkEqual(nil, args[key], key .. " is gone")
	end

	for _, key in ipairs({
		"maxItemsRow",
		"durationRow",
		"growthRow",
		"alignRow",
		"fontRow",
		"outlineRow",
		"fontSizeRow",
	}) do
		local cells = args[key].args
		checkEqual(nil, cells.indent, key .. " has no indent cell")
		checkEqual(ns.OPTIONS_LABEL_WIDTH, cells.control1.width, key .. " gives its caption the label column")
		checkEqual(ns.OPTIONS_CONTROL_WIDTH, cells.control2.width, key .. " keeps the shared control width")
		checkEqual("", cells.control2.name, key .. " leaves its dropdown uncaptioned")
	end

	local position = args.positionRow.args
	checkEqual(nil, position.indent, "the position buttons have no indent cell either")
	checkNear(
		ns.OPTIONS_ROW_WIDTH,
		position.control1.width + position.control2.width + position.control3.width,
		"and end on the shared right edge"
	)
end)

--[[
    The Filters rows: the item types in three groups (the rarity rows, the
    other types A to Z by the client's own name, then GogoLoot's own three),
    each captioned, with a Mine box and a Group box in two columns. A rarity
    row's quality dropdown shows beside a ticked box, and a blank cell of the
    same width stands in while it is clear, so every Group box lines up. Gem
    waits for an expansion that has it, and Money has no Group box.
]]
test("every Filters row carries a Mine and a Group box, with a quality on the rarity rows", function()
	local ns = loadAddon()
	local profile = ns.db.profile
	local args = ns.BuildLootToastFilterOptions().args

	checkEqual(nil, args.filterRow_GEM, "Classic has no Gem row")
	check(args.filterRow_COMPANION_PET.order < args.filterRow_CONSUMABLE.order, "types run A to Z by name")
	check(args.filterRow_CONSUMABLE.order < args.filterRow_CONTAINER.order, "and on")
	check(args.filterRow_REAGENT.order < args.filterRow_RECIPE.order, "to the last type")

	local armor = args.filterRow_ARMOR.args
	checkEqual("Armor", armor.control1.name, "a type row is captioned with the client's own name")
	checkEqual(ns.OPTIONS_FILTER_LABEL_WIDTH, armor.control1.width, "in the narrow caption column")
	checkEqual(ns.L["LOOT_TOASTS_FILTER_MINE"], armor.control2.name, "then the Mine box")
	checkEqual(ns.L["LOOT_TOASTS_FILTER_GROUP"], armor.control5.name, "and the Group box")
	checkEqual(
		ns.L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"]:format("Armor"),
		armor.control2.desc,
		"naming the type"
	)
	checkNear(
		ns.OPTIONS_ROW_WIDTH,
		armor.control1.width + armor.control2.width + armor.control3.width + armor.control5.width + armor.control6.width,
		"a rarity row ends on the shared right edge"
	)
	checkNear(armor.control3.width, armor.control4.width, "its stand-in cell is the dropdown's width")

	-- Mine ships on at Poor+, Group at Uncommon+ for armor.
	check(armor.control2.get(), "Mine is ticked")
	check(not evaluate(armor.control3.hidden), "so its quality shows")
	check(evaluate(armor.control4.hidden), "and its stand-in doesn't")
	checkEqual(0, armor.control3.get(), "at Poor+")
	check(armor.control5.get(), "Group is ticked for armor too")
	checkEqual(2, armor.control6.get(), "at Uncommon+")

	armor.control5.set(nil, false)
	checkEqual(false, profile.lootToastGroup.ARMOR, "clearing the Group box saves it")
	check(evaluate(armor.control6.hidden), "and its quality leaves")
	check(not evaluate(armor.control7.hidden), "with the stand-in keeping the column")
	armor.control3.set(nil, 3)
	checkEqual(3, profile.lootToastMineQuality.ARMOR, "a quality saves to its side")

	local quest = args.filterRow_QUEST.args
	checkEqual("Quest", quest.control1.name, "a plain type row")
	checkEqual(ns.OPTIONS_FILTER_COLUMN_WIDTH, quest.control2.width, "its box takes the whole column")
	checkEqual(nil, quest.control4, "and it carries no quality")
	check(quest.control3.get(), "Group shows the group's quest items by default")
	check(not args.filterRow_CONSUMABLE.args.control3.get(), "and not their consumables")

	checkEqual(ns.L["TAB_LOOT_TOAST_FILTERS"], ns.BuildLootToastFilterOptions().name, "the panel is titled Filters")
	checkEqual(ns.L["LOOT_TOASTS_FILTERS_CAPTION"], args.description.name, "opening on what it is for")
	profile.lootToasts = false
	check(not evaluate(args.featureOffNote.hidden), "with Loot Toasts off, a red line says so")
	check(not evaluate(args.filterRow_ARMOR.hidden), "and the rows stay to edit")
	profile.lootToasts = true
	check(evaluate(args.featureOffNote.hidden), "the line leaves once it is on")

	local money = args.filterRow_MONEY.args
	checkEqual("Money", money.control1.name, "Money is the game's own word")
	checkEqual(nil, money.control3, "with no Group box")
	checkEqual(ns.L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"], money.control2.desc, "saying why")
end)

--[[
    Bag Count and Winning Roll close the Filters grid, in its own columns: a
    box per side, lined up under the item types' boxes. Bag Count reads the
    player's own bags, so it has a Mine box only.
]]
test("Bag Count and Winning Roll sit in the Filters grid, under its columns", function()
	local ns = loadAddon()
	local args = ns.BuildLootToastFilterOptions().args
	local bagCount = args.filterRow_BAG_COUNT.args
	local winningRoll = args.filterRow_WINNING_ROLL.args
	local quest = args.filterRow_QUEST.args

	checkEqual(ns.L["LOOT_TOASTS_FILTER_BAG_COUNT"], bagCount.control1.name, "captioned Bag Count")
	checkEqual(ns.L["LOOT_TOASTS_WINNING_ROLL"], winningRoll.control1.name, "and Winning Roll")
	checkEqual(quest.control1.width, bagCount.control1.width, "in the grid's caption column")
	checkEqual(quest.control2.width, winningRoll.control2.width, "with its Mine column")
	checkEqual(quest.control3.width, winningRoll.control3.width, "and its Group column")
	checkEqual(nil, bagCount.control3, "Bag Count has no Group box")
	checkEqual(ns.L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"], bagCount.control2.desc, "explaining itself")

	checkEqual(false, bagCount.control2.get(), "Bag Count ships off")
	bagCount.control2.set(nil, true)
	checkEqual(true, ns.db.profile.lootToastBagCount, "and saves the setting the toasts read")
	check(winningRoll.control2.get() and winningRoll.control3.get(), "both Winning Roll boxes ship ticked")
	winningRoll.control3.set(nil, false)
	checkEqual(false, ns.db.profile.lootToastWinningRollGroup, "the Group box saves its own setting")
end)

--[[
    Font Size is a dropdown in steps of two, like the rows around it, and a
    size saved between the steps still reads back.
]]
test("Font Size is a dropdown in steps of two", function()
	local ns = loadAddon()
	local dropdown = ns.BuildLootToastOptions().args.fontSizeRow.args.control2
	checkEqual("select", dropdown.type, "a dropdown, not a slider")
	checkEqual("8, 10, 12, 14, 16, 18, 20, 22, 24", table.concat(dropdown.sorting(), ", "), "in steps of two")
	checkEqual(16, dropdown.get(), "on 16 by default")
	ns.db.profile.lootToastFontSize = 17
	checkEqual(
		"16, 17, 18",
		table.concat(dropdown.sorting(), ", "):match("16, 17, 18"),
		"a size saved between steps is offered"
	)
	checkEqual("17", dropdown.values()[17], "and reads back")
end)

--[[
    Each Announcements control explains itself in its tooltip. What an
    announcement posts is shown under its toggle instead, so no tooltip repeats
    it.
]]
test("the announcements controls explain themselves in their tooltips", function()
	local ns, env = loadAddon()
	local L = ns.L
	local args = ns.BuildAnnouncementOptions().args

	checkEqual(L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"], args.lootNotifications.desc, "the master switch")
	checkEqual(L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"], args.announceDestinations.desc, "destinations")
	checkEqual(L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"], args.autoAnnounceRow.args.toggle.desc, "automated")
	checkEqual(
		L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"],
		args.autoAnnounceRow.args.control.desc,
		"the automated hand-outs' threshold"
	)
	checkEqual(
		L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"]:format(env.MASTER_LOOTER),
		args.manualAnnounce.desc,
		"manual hand-outs"
	)
	checkEqual(L["TRADE_ENABLE_DESCRIPTION"], args.tradeRow.args.toggle.desc, "trade")
	checkEqual(L["TRADE_CONDITION_DESCRIPTION"], args.tradeRow.args.control.desc, "when it posts")
	checkEqual(L["TRADE_CHANNEL_TOOLTIP"]:format(env.WHISPER), args.tradeOutputRow.args.control2.desc, "where it posts")
	for _, key in ipairs({
		"TRADE_ENABLE_DESCRIPTION",
		"MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION",
		"MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION",
	}) do
		checkEqual(nil, L[key]:find(ns.TARGET_MARKER, 1, true), key .. " leaves its example to the panel")
	end
end)

--[[
    Each announcement shows what it posts under its toggle: its real template,
    with the real marker and name around it, drawn as party chat from the
    player's own character, so a change to a message shows in its example too.
    The raid marker is drawn as the icon chat shows. The trade example follows
    where the summary goes: a whisper as the partner receives it, party chat,
    or for Me Only the printed line.
]]
test("each announcement's example is its real message", function()
	local ns, env = loadAddon()
	local L = ns.L
	local state = env.__state
	local args = ns.BuildAnnouncementOptions().args
	local function example(key)
		return args[key].args.control1.name()
	end
	for quality, itemIdentifier in pairs(ns.SAMPLE_ITEM_IDS) do
		state.itemNames[itemIdentifier] = { name = "Sample " .. quality, quality = quality }
	end
	local function link(quality)
		return ("|Hitem:%d|h[Sample %d]|h"):format(ns.SAMPLE_ITEM_IDS[quality], quality)
	end
	local you = ns.GetClassColor("WARRIOR") .. "Tester|r"

	-- Stand-in templates, so the examples are seen to follow whatever the messages say.
	L["MESSAGE_DESTINATION_SET"] = "<%s holds %s>"
	L["MESSAGE_GAVE"] = "<gave %s to %s>"
	L["MESSAGE_TRADE_GAVE_RECEIVED"] = "<gave %s to %s for %s>"

	local destination = example("destinationExampleRow")
	check(destination:find("<Aero holds Epic>", 1, true) ~= nil, "the destination example runs its template")
	local handOut = example("autoExampleRow")
	check(
		handOut:find("<gave " .. link(3) .. " to Aero>", 1, true) ~= nil,
		"the hand-out example's item is the threshold's quality"
	)
	ns.db.profile.announceMasterLootAutoThreshold = 4
	check(example("autoExampleRow"):find(link(4), 1, true) ~= nil, "and follows it when it changes")
	ns.db.profile.announceTradeOutput = "group"
	local trade = example("tradeExampleRow")
	check(
		trade:find("<gave " .. link(2) .. " x2 to Aero for 5g>", 1, true) ~= nil,
		"the trade example gives two of an item for 5 gold"
	)

	for name, text in pairs({ destination = destination, trade = trade, handOut = handOut }) do
		checkEqual(
			1,
			text:find(ns.GetColor("HELP") .. L["OPTIONS_EXAMPLE"]:format(""), 1, true),
			name .. " reads Example, in silver"
		)
		check(
			text:find(L["OPTIONS_EXAMPLE"]:format("|cffAAAAFF[Party] [" .. you .. "|cffAAAAFF]: "), 1, true) ~= nil,
			name .. " is party chat from the player's own character, in party color"
		)
		check(text:find("UI-RaidTargetingIcon_4", 1, true) ~= nil, name .. " draws the marker as its icon")
		checkEqual(nil, text:find(ns.TARGET_MARKER, 1, true), name .. " rather than printing it")
		check(text:find(L["ADDON_TITLE"], 1, true) ~= nil, name .. " carries the add-on's name, as posted")
	end

	ns.db.profile.announceTradeOutput = "whisper"
	check(
		example("tradeExampleRow"):find("|cffFF80FF[" .. you .. "|cffFF80FF] whispers: ", 1, true) ~= nil,
		"a whispered summary is drawn as the whisper the partner receives"
	)

	-- Me Only prints the summary, so its example is the printed line: name first, no marker.
	L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "<printed %s to %s for %s>"
	ns.db.profile.announceTradeOutput = "self"
	local printed = example("tradeExampleRow")
	check(
		printed:find(ns.GetColor("INFO") .. L["ADDON_TITLE"] .. "|r", 1, true) ~= nil,
		"the Me Only example is the printed line, name first"
	)
	check(
		printed:find("<printed " .. link(2) .. " x2 to " .. ns.GetClassColor("DRUID") .. "Aero|r", 1, true) ~= nil,
		"naming the partner in their class color"
	)
	checkEqual(nil, printed:find("UI-RaidTargetingIcon", 1, true), "with no marker, since nobody else sees it")
end)

--[[
    The three forms an Example line is drawn in, each in the colors of where it
    goes: the player's recolored chat colors win over the fallbacks, and the
    line's color comes back after every |r a link or name closes with.
]]
test("the Example renderers draw each form in its chat colors", function()
	local ns, env = loadAddon()
	local you = ns.GetClassColor("WARRIOR") .. "Tester|r"
	local closed = "|cff112233[Link]|r"

	local printed = ns.OptionsPrintedLine("body " .. closed .. " tail")
	checkEqual(
		1,
		printed:find(ns.GetColor("TEXT") .. ns.GetColor("INFO") .. ns.L["ADDON_TITLE"] .. "|r", 1, true),
		"printed: the print helper's line"
	)
	check(printed:find(ns.GetColor("TEXT") .. "body " .. closed, 1, true) ~= nil, "printed: the body in its color")
	check(
		printed:find(closed .. ns.GetColor("TEXT") .. " tail", 1, true) ~= nil,
		"printed: body color back after a link"
	)

	env.ChatTypeInfo = { PARTY = { r = 1, g = 0, b = 0 }, WHISPER = { r = 0, g = 1, b = 0 } }
	local party = ns.OptionsSentLine("PARTY", "{rt4} hi " .. closed .. " tail")
	checkEqual(
		1,
		party:find("|cffff0000[Party] [" .. you .. "|cffff0000]: ", 1, true),
		"party: the player's party color"
	)
	check(party:find(closed .. "|cffff0000 tail", 1, true) ~= nil, "party: its color back after a link")
	check(party:find("UI-RaidTargetingIcon_4", 1, true) ~= nil, "party: the marker as its icon")

	local whisper = ns.OptionsSentLine("WHISPER", "hi")
	checkEqual(1, whisper:find("|cff00ff00[" .. you .. "|cff00ff00] whispers: hi", 1, true), "whisper: as received")
end)

--------------------------------------------------------------------------------
-- The master looter pop-up trigger
--------------------------------------------------------------------------------

--[[
    Spy on ns:ShowMasterLooterPopup rather than the AceConfigDialog fake: it is
    the seam every trigger path shares, and counting opens is the whole question
    here — one per genuine promotion, none for anything else.
]]
local function watchPopup(ns)
	local opened = { count = 0 }
	ns.ShowMasterLooterPopup = function()
		opened.count = opened.count + 1
	end
	return opened
end

--- In a group that is NOT master looting, with the pop-up enabled.
local function joinGroupWithoutMasterLoot(ns, env)
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 3
	state.lootMethod = 3
	state.masterLooterPartyIndex = nil
	ns.db.profile.masterLooterPopup = true
	fire(ns, "GROUP_ROSTER_UPDATE")
	return state
end

local function becomeMasterLooter(state)
	state.lootMethod = 2
	state.masterLooterPartyIndex = 0
end

test("being made master looter opens the pop-up", function()
	local ns, env = loadAddon()
	local opened = watchPopup(ns)
	local state = joinGroupWithoutMasterLoot(ns, env)

	becomeMasterLooter(state)
	fire(ns, "PARTY_LOOT_METHOD_CHANGED")

	checkEqual(1, opened.count, "the window opened on the promotion")
end)

--[[
    The role can also fall to you because whoever held it left, and no
    loot-method event accompanies that — only the roster update. Narrowing the
    trigger to PARTY_LOOT_METHOD_CHANGED would drop this case silently.
]]
test("inheriting master looter when its holder leaves opens the pop-up", function()
	local ns, env = loadAddon()
	local opened = watchPopup(ns)
	local state = joinGroupWithoutMasterLoot(ns, env)

	becomeMasterLooter(state)
	state.groupMembers = 2
	fire(ns, "GROUP_ROSTER_UPDATE")

	checkEqual(1, opened.count, "the roster path still opens the window")
end)

--[[
    The reported bug. A loading screen re-syncs the party's loot state, so the
    method reads as the default for a moment and then as master loot again —
    both readings arriving on GROUP_ROSTER_UPDATE, which fires freely throughout.
]]
test("changing zones never opens the pop-up", function()
	local ns, env = loadAddon()
	local opened = watchPopup(ns)
	local state = joinGroupWithoutMasterLoot(ns, env)
	becomeMasterLooter(state)
	fire(ns, "PARTY_LOOT_METHOD_CHANGED")
	checkEqual(1, opened.count, "opened once on the genuine promotion")

	fire(ns, "PLAYER_ENTERING_WORLD")
	state.lootMethod = 3
	state.masterLooterPartyIndex = nil
	fire(ns, "GROUP_ROSTER_UPDATE")
	becomeMasterLooter(state)
	fire(ns, "GROUP_ROSTER_UPDATE")
	Fake.advance(env, 5)
	fire(ns, "GROUP_ROSTER_UPDATE")

	checkEqual(1, opened.count, "still once — the zone change opened nothing")
end)

test("crossing a zone border without a loading screen opens nothing either", function()
	local ns, env = loadAddon()
	local opened = watchPopup(ns)
	local state = joinGroupWithoutMasterLoot(ns, env)
	becomeMasterLooter(state)
	fire(ns, "PARTY_LOOT_METHOD_CHANGED")

	fire(ns, "ZONE_CHANGED_NEW_AREA")
	state.lootMethod = 3
	state.masterLooterPartyIndex = nil
	fire(ns, "GROUP_ROSTER_UPDATE")
	becomeMasterLooter(state)
	fire(ns, "GROUP_ROSTER_UPDATE")
	Fake.advance(env, 5)
	fire(ns, "GROUP_ROSTER_UPDATE")

	checkEqual(1, opened.count, "no second window from the border crossing")
end)

--[[
    Freezing the tracked state through the settle window rather than updating it
    is what keeps this case: the first reading afterwards still compares against
    the state from before the loading screen.
]]
test("a promotion that lands mid-loading-screen opens the window once it settles", function()
	local ns, env = loadAddon()
	local opened = watchPopup(ns)
	local state = joinGroupWithoutMasterLoot(ns, env)

	fire(ns, "PLAYER_ENTERING_WORLD")
	becomeMasterLooter(state)
	fire(ns, "GROUP_ROSTER_UPDATE")
	checkEqual(0, opened.count, "nothing while the zone change is settling")

	Fake.advance(env, 5)
	fire(ns, "GROUP_ROSTER_UPDATE")

	checkEqual(1, opened.count, "the window opens a beat late rather than never")
end)

--[[
    Login and /reload are loading screens too, and are the two the pop-up is
    meant to answer from a standing start. PLAYER_ENTERING_WORLD's own arguments
    are what tell them apart from a zone change.
]]
test("logging in or reloading already master looter still opens the pop-up", function()
	for _, entry in ipairs({
		{ label = "login", isInitialLogin = true, isReloadingUi = false },
		{ label = "reload", isInitialLogin = false, isReloadingUi = true },
	}) do
		local ns, env = loadAddon()
		local opened = watchPopup(ns)
		local state = env.__state
		state.inGroup = true
		state.groupMembers = 3
		ns.db.profile.masterLooterPopup = true
		becomeMasterLooter(state)

		fire(ns, "PLAYER_ENTERING_WORLD", entry.isInitialLogin, entry.isReloadingUi)
		fire(ns, "GROUP_ROSTER_UPDATE")

		checkEqual(1, opened.count, entry.label .. " is a standing start, not a zone change")
	end
end)

--[[
    The same false-then-true shape can arrive without any zone change at all,
    whenever the loot API simply has no answer yet.
]]
test("a loot method the client cannot answer for is not a demotion", function()
	local ns, env = loadAddon()
	local opened = watchPopup(ns)
	local state = joinGroupWithoutMasterLoot(ns, env)
	becomeMasterLooter(state)
	fire(ns, "PARTY_LOOT_METHOD_CHANGED")

	state.lootMethod = nil
	state.masterLooterPartyIndex = nil
	fire(ns, "GROUP_ROSTER_UPDATE")
	becomeMasterLooter(state)
	fire(ns, "GROUP_ROSTER_UPDATE")

	checkEqual(1, opened.count, "the gap in the API opened no second window")
end)

test("the pop-up toggle still turns the window off", function()
	local ns, env = loadAddon()
	local opened = watchPopup(ns)
	local state = joinGroupWithoutMasterLoot(ns, env)
	ns.db.profile.masterLooterPopup = false

	becomeMasterLooter(state)
	fire(ns, "PARTY_LOOT_METHOD_CHANGED")

	checkEqual(0, opened.count, "no window while the toggle is off")
end)

--------------------------------------------------------------------------------
-- The loading-screen guard, past the pop-up
--------------------------------------------------------------------------------

--[[
    The same transient the pop-up freezes against reaches two more consumers.
    ns:SafeGetLootMethod maps the client's nil answer to "group", so a zoning
    master-loot group is observed as master -> group and the destination reset
    fires; the leaver sweep reads the same window's empty roster as everyone
    having left. Both must ignore it, and neither may record it.
]]
local function masterLootSetupWithDestinations(ns, env)
	-- Becoming master looter opens the window; stub it out as the pop-up tests do.
	watchPopup(ns)
	local state = joinGroupWithoutMasterLoot(ns, env)
	-- Bob is really in the group, or the leaver sweep would reassign him on sight.
	state.unitNames.party1 = "Bob"
	becomeMasterLooter(state)
	fire(ns, "PARTY_LOOT_METHOD_CHANGED")
	ns:SetAllDestinations("bob")
	return state
end

--- Everything a loading screen does to the loot state, start to finish.
local function zoneThrough(ns, state)
	fire(ns, "PLAYER_ENTERING_WORLD")
	state.lootMethod = 3
	state.masterLooterPartyIndex = nil
	fire(ns, "GROUP_ROSTER_UPDATE")
	state.lootMethod = nil
	fire(ns, "GROUP_ROSTER_UPDATE")
	becomeMasterLooter(state)
	fire(ns, "GROUP_ROSTER_UPDATE")
end

test("changing zones never wipes the loot destinations", function()
	local ns, env = loadAddon()
	local state = masterLootSetupWithDestinations(ns, env)
	checkEqual("bob", ns.db.profile.destinations.epic, "the setup starts assigned")

	zoneThrough(ns, state)
	Fake.advance(env, 5)
	fire(ns, "GROUP_ROSTER_UPDATE")

	-- The fakes' loot threshold is Uncommon, so Send All set the three qualities it reaches.
	for _, qualityKey in ipairs({ "uncommon", "rare", "epic" }) do
		checkEqual("bob", ns.db.profile.destinations[qualityKey], qualityKey .. " survived the loading screen")
	end
end)

test("a genuine loot method change still clears the destinations", function()
	local ns, env = loadAddon()
	local state = masterLootSetupWithDestinations(ns, env)

	state.lootMethod = 3 -- The leader really did switch to Group Loot.
	state.masterLooterPartyIndex = nil
	fire(ns, "PARTY_LOOT_METHOD_CHANGED")

	checkEqual(nil, ns.db.profile.destinations.epic, "the setup is scoped to one master-loot session")
end)

--[[
    Frozen, not swallowed: the reading during the window is discarded WITHOUT
    being recorded, so the first one afterwards still compares against the
    pre-zone method and the change lands a beat late rather than never.
]]
test("a loot method change made mid-loading-screen lands once it settles", function()
	local ns, env = loadAddon()
	local state = masterLootSetupWithDestinations(ns, env)

	fire(ns, "PLAYER_ENTERING_WORLD")
	state.lootMethod = 3
	state.masterLooterPartyIndex = nil
	fire(ns, "GROUP_ROSTER_UPDATE")
	checkEqual("bob", ns.db.profile.destinations.epic, "nothing acted on while the state was unreadable")

	Fake.advance(env, 5)
	fire(ns, "GROUP_ROSTER_UPDATE")

	checkEqual(nil, ns.db.profile.destinations.epic, "and the change was noticed on the first good reading")
end)

test("a player who leaves mid-loading-screen is caught once it settles", function()
	local ns, env = loadAddon()
	local state = masterLootSetupWithDestinations(ns, env)
	env.__state.chat = {}

	fire(ns, "PLAYER_ENTERING_WORLD")
	state.unitNames.party1 = nil -- Bob really does leave, mid-loading-screen.
	state.groupMembers = 2
	fire(ns, "GROUP_ROSTER_UPDATE")
	checkEqual("bob", ns.db.profile.destinations.epic, "no tier reassigned while the roster is unreadable")
	checkEqual(0, chatCount(env), "and nobody announced as having left")

	Fake.advance(env, 5)
	fire(ns, "GROUP_ROSTER_UPDATE")

	checkEqual("self", ns.db.profile.destinations.epic, "the genuine leaver is caught on the first good reading")
	check(chatContaining(env, "has left the group") ~= nil, "and announced then")
end)

test("a player holding every quality who leaves is announced once", function()
	local ns, env = loadAddon()
	local state = masterLootSetupWithDestinations(ns, env)
	env.__state.chat = {}

	state.unitNames.party1 = nil
	state.groupMembers = 2
	fire(ns, "GROUP_ROSTER_UPDATE")

	checkEqual(1, chatCount(env), "one line for one leaver, not one per quality")
	check(chatContaining(env, "all loot") ~= nil, "naming all loot rather than a list of qualities")
	for _, qualityKey in ipairs({ "uncommon", "rare", "epic" }) do
		checkEqual("self", ns.db.profile.destinations[qualityKey], qualityKey .. " still moves to the master looter")
	end
end)

test("a player holding some qualities who leaves is announced once, with each quality named", function()
	local ns, env = loadAddon()
	local state = masterLootSetupWithDestinations(ns, env)
	ns.db.profile.destinations.epic = "self"
	env.__state.chat = {}

	state.unitNames.party1 = nil
	state.groupMembers = 2
	fire(ns, "GROUP_ROSTER_UPDATE")

	checkEqual(1, chatCount(env), "one line for one leaver")
	local message = chatContaining(env, "has left the group") or ""
	check(
		message:find(env.ITEM_QUALITY2_DESC .. ", " .. env.ITEM_QUALITY3_DESC, 1, true) ~= nil,
		"naming the qualities"
	)
end)

test("a leaver who held only a quality below the threshold goes unannounced", function()
	local ns, env = loadAddon()
	local state = masterLootSetupWithDestinations(ns, env)
	ns:SetAllDestinations("self")
	ns.db.profile.destinations.poor = "bob"
	env.__state.chat = {}

	state.unitNames.party1 = nil
	state.groupMembers = 2
	fire(ns, "GROUP_ROSTER_UPDATE")

	checkEqual(0, chatCount(env), "the panel never showed Poor, so nobody is told about it")
	checkEqual("self", ns.db.profile.destinations.poor, "though it still falls back to the master looter")
end)

--[[
    The trade watcher matches UI_INFO_MESSAGE on its numeric id, so these fire
    the id with no message text at all — the way a client that never bound the
    ERR_* global as a string would deliver it.
]]
--[[
    The marker leads and the name trails on every flavor. WoW Forever blocks
    raid markers only in /say and public channels, which GogoLoot never uses.
]]
test("sent messages lead with the marker and end with the add-on name", function()
	local ns = loadAddon()
	local expected = ("%s Gave [Item] to Bob // %s"):format(ns.TARGET_MARKER, ns.L["ADDON_TITLE"])
	for _, flavor in ipairs({ "Vanilla", "TBC", "Camelot" }) do
		ns.FLAVOR = flavor
		checkEqual(expected, ns:BuildAnnounceMessage("MESSAGE_GAVE", "[Item]", "Bob"), flavor .. " uses the one format")
	end
end)

--[[
    " // GogoLoot" follows every sent message, so a template ending in a
    period would read "... for the group. // GogoLoot". A printed line ends on
    its message, which closes like any sentence; CHAT_LOADED is the welcome
    line's mandated copy, which closes on "(=".
]]
local SENT_TEMPLATES = {
	MESSAGE_GAVE = true,
	MESSAGE_DESTINATION_SET = true,
	MESSAGE_DESTINATION_SET_ALL = true,
	MESSAGE_DESTINATION_LEFT = true,
	MESSAGE_DESTINATION_LEFT_ALL = true,
	MESSAGE_TRADE_GAVE_RECEIVED = true,
	MESSAGE_TRADE_RECEIVED = true,
}

test("sent templates end bare and printed lines end on punctuation", function()
	local ns = loadAddon()
	for key, text in pairs(ns.L) do
		if SENT_TEMPLATES[key] or key:find("^ERROR_") then
			check(not text:find("[%.!?]$"), key .. " ends without end punctuation")
		elseif (key:find("^MESSAGE_") or key:find("^CHAT_")) and key ~= "CHAT_LOADED" then
			check(text:find("[%.!?]$") ~= nil, key .. " ends with end punctuation")
		end
	end
end)

test("local prints lead with the add-on name", function()
	local ns, env = loadAddon()
	ns:PrintMessage("Hello.")
	local printed = env.__state.prints[#env.__state.prints] or ""
	local plainText = printed:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	checkEqual(ns.L["ADDON_TITLE"] .. " // Hello.", plainText, "the name first, the information after")
end)

--[[
    WoW Forever names are "First Last". Its UnitName returns the last name where
    other flavors return the realm, the player included, while the loot window's
    candidates read "Hippobob Bramblefoot". A destination picked from the roster
    has to match that, and has to survive the roster check for players who left.
]]
test("a WoW Forever destination matches the loot window's First Last name", function()
	local ns, env = loadAddon()
	ns.FLAVOR = "Camelot"
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.lootMethod = 2
	state.masterLooterPartyIndex = 0
	state.unitNames = { player = "Gogohunter", party1 = "Hippobob" }
	state.unitRealms = { player = "Classic", party1 = "Bramblefoot" }
	state.masterLootCandidates = { "Gogohunter Classic", "Hippobob Bramblefoot" }
	state.itemNames = { [1001] = { name = "Frayed Pants", quality = 2, classId = 4, bindType = 2 } }
	state.lootSlots = { { link = "|Hitem:1001|h[Frayed Pants]|h" } }
	ns.db.profile.autoMasterLoot = true
	ns.db.profile.announceDestinations = true
	ns.db.profile.announceMasterLootAuto = true
	ns.db.profile.announceMasterLootAutoThreshold = 0
	ns.db.profile.masterLooterPopup = false

	local memberNames = ns:GetGroupMemberNames()
	checkEqual("Hippobob Bramblefoot", memberNames["hippobob bramblefoot"], "the dropdown offers the whole name")
	ns:SetAllDestinations("hippobob bramblefoot")
	check(chatContaining(env, "Hippobob Bramblefoot will be holding") ~= nil, "the setup names them in full")

	fire(ns, "GROUP_ROSTER_UPDATE")
	checkEqual("hippobob bramblefoot", ns.db.profile.destinations.uncommon, "the roster check still finds them")

	fire(ns, "LOOT_OPENED")
	checkEqual(2, state.givenLoot[1] and state.givenLoot[1].candidateIndex, "the item went to Hippobob Bramblefoot")
	fire(ns, "LOOT_SLOT_CLEARED", 1)
	check(chatContaining(env, "to Hippobob Bramblefoot") ~= nil, "and the hand-out names them in full")

	fire(ns, "LOOT_CLOSED")
	state.givenLoot = {}
	ns.db.profile.destinations.uncommon = "self"
	fire(ns, "LOOT_OPENED")
	checkEqual(1, state.givenLoot[1] and state.givenLoot[1].candidateIndex, "Self finds the player's whole name too")
end)

test("elsewhere the second half of a name is a realm and is dropped", function()
	local ns, env = loadAddon()
	ns.FLAVOR = "Vanilla"
	env.__state.unitNames.party1 = "Bob"
	env.__state.unitRealms.party1 = "OtherRealm"

	checkEqual("bob", ns:GetLowercaseUnitName("party1"), "the roster keys the bare name")
	checkEqual("Bob", ns:FormatPlayerName("Bob-OtherRealm"), "and chat shows it without the realm")
end)

test("a WoW Forever trade whispers the partner's whole name", function()
	local ns, env = loadAddon()
	ns.FLAVOR = "Camelot"
	local state = env.__state
	state.unitNames.npc = "Hippobob"
	state.unitRealms.npc = "Bramblefoot"
	state.tradePlayerItems[1] = { link = "|Hitem:2001|h[Given Item]|h", count = 1 }
	local completeId = registerGameMessage(env, "ERR_TRADE_COMPLETE")

	fire(ns, "TRADE_SHOW")
	fire(ns, "TRADE_ACCEPT_UPDATE", 1, 1)
	state.chat = {}
	fire(ns, "UI_INFO_MESSAGE", completeId)

	local whisper = state.chat[1]
	checkEqual("WHISPER", whisper and whisper.channel, "the trade went out as a whisper")
	checkEqual("Hippobob Bramblefoot", whisper and whisper.target, "to the partner's whole name")
	check(chatContaining(env, "Hippobob Bramblefoot") ~= nil, "and the message names them in full")
end)

test("a completed trade announces from the message id alone", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.unitNames.npc = "Hippobob"
	state.tradePlayerItems[1] = { link = "|Hitem:2001|h[Given Item]|h", count = 1 }
	state.tradeTargetItems[1] = { link = "|Hitem:2002|h[Taken Item]|h", count = 1 }

	local completeId = registerGameMessage(env, "ERR_TRADE_COMPLETE")

	fire(ns, "TRADE_SHOW")
	fire(ns, "TRADE_ACCEPT_UPDATE", 1, 1)
	state.chat = {}
	fire(ns, "UI_INFO_MESSAGE", completeId)

	check(chatContaining(env, "Given Item") ~= nil, "the item we handed over was named")
	check(chatContaining(env, "Taken Item") ~= nil, "and the one we received")
	check(chatContaining(env, "Hippobob") ~= nil, "along with the trade partner")
end)

test("a trade summary writes coin in the client's own symbols", function()
	local ns, env = loadAddon()
	local state = env.__state
	env.GOLD_AMOUNT_SYMBOL, env.SILVER_AMOUNT_SYMBOL, env.COPPER_AMOUNT_SYMBOL = "po", "pa", "pc"
	state.unitNames.npc = "Hippobob"
	state.tradePlayerItems[1] = { link = "|Hitem:2001|h[Given Item]|h", count = 1 }
	state.tradeTargetMoney = 50203
	local completeId = registerGameMessage(env, "ERR_TRADE_COMPLETE")

	fire(ns, "TRADE_SHOW")
	fire(ns, "TRADE_ACCEPT_UPDATE", 1, 1)
	state.chat = {}
	fire(ns, "UI_INFO_MESSAGE", completeId)

	check(chatContaining(env, "5po 2pa 3pc") ~= nil, "gold, silver and copper take the client's own symbols")
end)

--[[
    The order WoW Forever sends: our item goes in, we accept, and then, as the
    trade executes, our slot empties again just before the result arrives.
]]
test("what we gave survives the window emptying as the trade completes", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.unitNames.npc = "Hippobob"
	state.tradeTargetItems[1] = { link = "|Hitem:2002|h[Taken Item]|h", count = 1 }
	local completeId = registerGameMessage(env, "ERR_TRADE_COMPLETE")

	fire(ns, "TRADE_SHOW")
	fire(ns, "TRADE_TARGET_ITEM_CHANGED", 1)
	state.tradePlayerItems[1] = { link = "|Hitem:2001|h[Given Item]|h", count = 1 }
	fire(ns, "TRADE_PLAYER_ITEM_CHANGED", 1)
	fire(ns, "TRADE_ACCEPT_UPDATE", 1, 0)
	state.tradePlayerItems[1] = nil
	fire(ns, "TRADE_PLAYER_ITEM_CHANGED", 1)
	state.chat = {}
	fire(ns, "UI_INFO_MESSAGE", completeId, "Trade complete.")

	check(chatContaining(env, "Given Item") ~= nil, "what we gave is still in the summary")
	check(chatContaining(env, "Taken Item") ~= nil, "alongside what we received")
end)

test("an enchant taken back out before the trade completes is left out of the summary", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.unitNames.npc = "Hippobob"
	state.tradeTargetItems[1] = { link = "|Hitem:2002|h[Taken Item]|h", count = 1 }
	local completeId = registerGameMessage(env, "ERR_TRADE_COMPLETE")

	fire(ns, "TRADE_SHOW")
	state.tradePlayerItems[ns.TRADE_ENCHANT_SLOT] =
		{ link = "|Hitem:4632|h[Ornate Bronze Lockbox]|h", count = 1, enchant = "Pick Lock" }
	fire(ns, "TRADE_ACCEPT_UPDATE", 1, 0)
	state.tradePlayerItems[ns.TRADE_ENCHANT_SLOT] = nil
	fire(ns, "TRADE_ACCEPT_UPDATE", 1, 1)
	state.chat = {}
	fire(ns, "UI_INFO_MESSAGE", completeId, "Trade complete.")

	check(chatContaining(env, "Taken Item") ~= nil, "the trade is still announced")
	checkEqual(nil, chatContaining(env, "Pick Lock"), "without the enchant that was taken back out")
end)

test("a cancelled trade announces nothing and drops the snapshot", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.unitNames.npc = "Hippobob"
	state.tradePlayerItems[1] = { link = "|Hitem:2001|h[Given Item]|h", count = 1 }

	local completeId = registerGameMessage(env, "ERR_TRADE_COMPLETE")
	local cancelledId = registerGameMessage(env, "ERR_TRADE_CANCELLED")

	fire(ns, "TRADE_SHOW")
	fire(ns, "TRADE_ACCEPT_UPDATE", 1, 1)
	state.chat = {}
	fire(ns, "UI_INFO_MESSAGE", cancelledId)
	checkEqual(0, chatCount(env), "a cancel announced nothing")

	-- The snapshot went with it, so a stray completion has nothing left to post.
	fire(ns, "UI_INFO_MESSAGE", completeId)
	checkEqual(0, chatCount(env), "and left no snapshot behind to announce later")
end)

--[[
    Me Only prints the summary in the player's own chat, name first as every
    print reads, and sends nothing. It answers to Enable Announcements like the
    summaries that are sent.
]]
test("a Me Only trade summary is printed and sent to nobody", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.unitNames.npc = "Hippobob"
	state.tradePlayerItems[1] = { link = "|Hitem:2001|h[Given Item]|h", count = 1 }
	state.tradeTargetItems[1] = { link = "|Hitem:2002|h[Taken Item]|h", count = 1 }
	local completeId = registerGameMessage(env, "ERR_TRADE_COMPLETE")
	ns.db.profile.announceTradeOutput = "self"

	local function trade()
		fire(ns, "TRADE_SHOW")
		fire(ns, "TRADE_ACCEPT_UPDATE", 1, 1)
		state.chat, state.prints = {}, {}
		fire(ns, "UI_INFO_MESSAGE", completeId)
		local printed = (state.prints[#state.prints] or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
		return printed
	end

	local printed = trade()
	checkEqual(0, chatCount(env), "nothing is sent")
	checkEqual(
		ns.L["ADDON_TITLE"]
			.. " // "
			.. ns.L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"]:format(
				"|Hitem:2001|h[Given Item]|h",
				"Hippobob",
				"|Hitem:2002|h[Taken Item]|h"
			),
		printed,
		"the summary is printed, name first"
	)

	state.tradeTargetItems[1] = nil
	check(
		trade():find(ns.L["MESSAGE_GAVE_PRINT"]:format("|Hitem:2001|h[Given Item]|h", "Hippobob"), 1, true) ~= nil,
		"a gift prints on its own line"
	)

	ns.db.profile.lootNotifications = false
	checkEqual("", trade(), "and with announcements off, nothing is printed either")
end)

--[[
    The Loot Method report is the only place a tester can see whether the trade
    constants resolved on this flavor, so it has to print a constant the client
    doesn't carry as plainly as one it does.
]]
test("the loot method report prints resolved ids for loot errors and trade results", function()
	local ns, env = loadAddon()
	local tooFarId = registerGameMessage(env, "ERR_LOOT_TOO_FAR")
	local completeId = registerGameMessage(env, "ERR_TRADE_COMPLETE")

	local report = ns:BuildLootMethodReport()

	check(report:find("Loot error message ids", 1, true) ~= nil, "the loot error block is present")
	check(report:find("Trade result message ids", 1, true) ~= nil, "the trade result block is present")
	check(report:find(("ERR_LOOT_TOO_FAR = %d"):format(tooFarId), 1, true) ~= nil, "a loot error reports its id")
	check(report:find(("ERR_TRADE_COMPLETE = %d"):format(completeId), 1, true) ~= nil, "a trade result reports its id")
	check(
		report:find("ERR_TRADE_CANCELLED = NOT FOUND", 1, true) ~= nil,
		"a constant this client doesn't carry reads NOT FOUND"
	)

	-- One walk covers both blocks, so the scan count is reported exactly once.
	checkEqual(1, select(2, report:gsub("game messages", "")), "the scan count printed once for both blocks")
end)

--[[
    The event log's message-id filter. UI_ERROR_MESSAGE and UI_INFO_MESSAGE
    fire for every combat error and info line, not just loot, so a grinding
    session used to bury the 500-entry ring buffer in "Ability is not ready
    yet." and evict the loot signal. Only ids the add-on correlates are logged
    as lines; the rest are counted per id so the report still shows what was
    spamming without the wall.
]]
test("the event log lists correlated message ids and counts the combat spam", function()
	local ns, env = loadAddon()
	local bagsFullId = registerGameMessage(env, "ERR_LOOT_MASTER_INV_FULL")
	local cooldownId = registerGameMessage(env, "ERR_ABILITY_COOLDOWN")

	ns:StartEventLog()
	ns:LogEvent("LOOT_OPENED", true)
	ns:LogEvent("UI_ERROR_MESSAGE", bagsFullId, "Bob's bags are full.")
	for _ = 1, 40 do
		ns:LogEvent("UI_ERROR_MESSAGE", cooldownId, "Ability is not ready yet.")
	end
	local report = ns:BuildEventLogReport()

	check(report:find("LOOT_OPENED", 1, true) ~= nil, "loot events still logged")
	check(
		report:find(("UI_ERROR_MESSAGE(%d,"):format(bagsFullId), 1, true) ~= nil,
		"a correlated error id logged as a full line"
	)
	check(report:find("x40", 1, true) ~= nil, "the spam collapsed to one counted row")
	local _, spamTextCount = report:gsub("Ability is not ready yet", "")
	checkEqual(1, spamTextCount, "the spam text appears once, not forty times")
end)

test("a trade result id is logged while unrelated info spam is counted", function()
	local ns, env = loadAddon()
	local completeId = registerGameMessage(env, "ERR_TRADE_COMPLETE")
	local questId = registerGameMessage(env, "ERR_QUEST_OBJECTIVE_COMPLETE_S")

	ns:StartEventLog()
	ns:LogEvent("UI_INFO_MESSAGE", completeId, "Trade complete.")
	ns:LogEvent("UI_INFO_MESSAGE", questId, "Objective Complete.")
	ns:LogEvent("UI_INFO_MESSAGE", questId, "Objective Complete.")
	local report = ns:BuildEventLogReport()

	check(
		report:find(("UI_INFO_MESSAGE(%d,"):format(completeId), 1, true) ~= nil,
		"the trade result stayed a full line"
	)
	check(report:find("x2", 1, true) ~= nil, "the quest spam collapsed to a counted row")
end)

test("a message event with no numeric id is logged verbatim", function()
	local ns = loadAddon()

	ns:StartEventLog()
	ns:LogEvent("UI_ERROR_MESSAGE", "an odd build with no numeric id")
	local report = ns:BuildEventLogReport()

	check(report:find("an odd build with no numeric id", 1, true) ~= nil, "unclassifiable events stay signal")
end)

test("removing a row with a roll action confirms, a plain Ignore List row does not", function()
	local ns = loadAddon()

	local rollRow = ns.BuildItemOverridesOptions().args.itemOverrides.args["item_20873"]
	local ignoreRow = ns.BuildMasterLooterIgnoreListOptions().args.ignoreList.args["item_12662"]

	checkEqual(true, rollRow and rollRow.args.remove.confirm, "the Automated Rolls row asks first")
	check(
		rollRow and rollRow.args.remove.confirmText == ns.L["ITEM_OVERRIDES_REMOVE_CONFIRM"],
		"with its own list's text"
	)
	checkEqual(nil, ignoreRow and ignoreRow.args.remove.confirm, "the Master Looter row removes on one click")
end)

test("an item id the client lacks never holds the cache watcher open", function()
	local ns, env = loadAddon()
	local state = env.__state
	cacheOpenableItems(ns, env)
	state.itemsNotOnClient[999001] = true
	state.itemsNotOnClient[999002] = true
	ns.db.profile.ignoredItemsSolo = { [999001] = ns.MANUAL }
	ns.db.profile.ignoredItemsMaster = { [999002] = true }

	fire(ns, "GET_ITEM_INFO_RECEIVED", 12345)
	Fake.advance(env, 2)

	checkEqual(nil, ns.eventHandlers.GET_ITEM_INFO_RECEIVED, "the watcher unregistered")
	checkEqual(
		nil,
		ns.BuildItemOverridesOptions().args.itemOverrides.args["item_999001"],
		"and the item is never loaded into a row"
	)
end)

--[[
    A default row this client doesn't have is never seeded: a slip in a flavor
    folder must not reach the saved list, where it could never load.
]]
test("seeding skips a default item this client doesn't have", function()
	local ns, env = loadAddon()
	env.__state.itemsNotOnClient[5002] = true
	ns.DEFAULT_IGNORE_LIST_MASTER = { { 5001 }, { 5002 } }

	local seeded = ns:BuildDefaultIgnoreListMaster()
	checkEqual(true, seeded[5001], "an item the client has is seeded")
	checkEqual(nil, seeded[5002], "one it doesn't is left out")
end)

--[[
    WoW Forever reports some later-expansion items as existing but never serves
    them: the item query comes back with success = false. That answer, not
    DoesItemExistByID, is what settles the row.
]]
test("an item the server says it doesn't have stops holding the cache watcher open", function()
	local ns, env = loadAddon()
	cacheOpenableItems(ns, env)
	ns.db.profile.ignoredItemsSolo = { [23572] = ns.MANUAL }
	ns.db.profile.ignoredItemsMaster = { [34845] = true }

	fire(ns, "GET_ITEM_INFO_RECEIVED", 23572, false)
	fire(ns, "GET_ITEM_INFO_RECEIVED", 34845, false)
	Fake.advance(env, 2)

	checkEqual(nil, ns.eventHandlers.GET_ITEM_INFO_RECEIVED, "the watcher unregistered")
	checkEqual(
		nil,
		ns.BuildMasterLooterIgnoreListOptions().args.ignoreList.args["item_34845"],
		"and the refused item drops out of the list"
	)
end)

--[[
    Reading an uncached item asks the server for it, so a refused item read on
    every repaint is a request on every repaint. Two items, so the name sort
    has something to compare.
]]
test("a refused item is never asked for again when the list repaints", function()
	local ns, env = loadAddon()
	local refused = { [34845] = true, [34846] = true }
	local requests = 0
	local fakeGetItemInfo = env.C_Item.GetItemInfo
	env.C_Item.GetItemInfo = function(identifier)
		if refused[identifier] then
			requests = requests + 1
			return nil
		end
		return fakeGetItemInfo(identifier)
	end
	ns.db.profile.ignoredItemsMaster = { [34845] = true, [34846] = true }

	fire(ns, "GET_ITEM_INFO_RECEIVED", 34845, false)
	fire(ns, "GET_ITEM_INFO_RECEIVED", 34846, false)
	Fake.advance(env, 2)
	requests = 0

	for _ = 1, 3 do
		ns.BuildMasterLooterIgnoreListOptions()
		ns:GetItemDisplayName(34845)
		ns:GetItemDisplayName(34846)
	end
	Fake.advance(env, 2)

	checkEqual(0, requests, "no repaint asked the server again")
end)

--[[
    Runs one Validate Data file to the end and returns its report, its STATUS
    tallies, and any error, as the report runner's callback receives them.
]]
local function RunValidation(ns, env, fileIndex)
	local result = {}
	ns:StartDataValidation(fileIndex, function(text, counts, problem)
		result.text, result.counts, result.problem = text, counts, problem
	end)
	for _ = 1, 80 do
		if result.text or result.problem then
			break
		end
		Fake.advance(env, 0.5)
	end
	return result.text or "", result.counts or {}, result.problem
end

local function DataSourceIndex(ns, label)
	for index, entry in ipairs(ns.DIAGNOSTIC_DATA_SOURCES) do
		if entry.label == label then
			return index
		end
	end
end

test("validate data flags each row with its status", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.itemNames[5001] = { name = "Known Item", quality = 2 }
	state.itemsNotOnClient[5002] = true
	ns.DEFAULT_IGNORE_LIST_SOLO = { { 5001, ns.NEED } }
	ns.DEFAULT_IGNORE_LIST_MASTER = { { 5002 } }

	local report, counts, problem = RunValidation(ns, env, DataSourceIndex(ns, "Default-Item-Lists"))

	checkEqual(nil, problem, "the run finishes without an error")
	check(report:find("Flavor Vanilla // Data Vanilla", 1, true) ~= nil, "the header names the flavor and folder")
	check(report:find("STATUS\tSOURCE\tITEM_ID\tNAME", 1, true) ~= nil, "the item block opens with its header row")
	check(report:find("OK\tDEFAULT_IGNORE_LIST_SOLO\t5001\tKnown Item", 1, true) ~= nil, "a loaded item reads OK")
	check(
		report:find("NOT ON CLIENT\tDEFAULT_IGNORE_LIST_MASTER\t5002", 1, true) ~= nil,
		"an id the client lacks is flagged"
	)
	checkEqual(1, counts.OK, "the tally counts the OK row")
	checkEqual(1, counts["NOT ON CLIENT"], "and the flagged one")
end)

test("validate data reports a table this client never built", function()
	local ns, env = loadAddon()
	ns.LOCKBOX_SKILL_LEVELS = nil

	local report, counts = RunValidation(ns, env, DataSourceIndex(ns, "Lockbox-Skill-Levels"))

	check(report:find("TABLE MISSING\tLOCKBOX_SKILL_LEVELS", 1, true) ~= nil, "the missing table gets a row")
	checkEqual(1, counts["TABLE MISSING"], "and a tally")
end)

test("a validate data report is titled by the file this client loaded", function()
	local ns = loadAddon()
	local entry = ns.DIAGNOSTIC_DATA_SOURCES[DataSourceIndex(ns, "Openable-Items")]
	checkEqual("Vanilla/Openable-Items-Vanilla.lua", ns.DataSourceFileName(entry), "the file in the Vanilla folder")
end)

test("stopping the event log keeps what it captured", function()
	local ns = loadAddon()
	ns:SetDiagnosticsEnabled(true)

	ns:StartEventLog()
	ns:LogEvent("LOOT_OPENED", true)
	ns:StopEventLog()
	local report = ns:BuildEventLogReport()

	check(report:find("LOOT_OPENED", 1, true) ~= nil, "the captured event survives Stop")
end)

test("turning diagnostics off releases the event log", function()
	local ns = loadAddon()
	ns:SetDiagnosticsEnabled(true)
	ns:StartEventLog()
	ns:LogEvent("LOOT_OPENED", true)

	ns:SetDiagnosticsEnabled(false)

	checkEqual(nil, ns.diagnostics.log, "the buffer is released")
	checkEqual(false, ns.diagnostics.logging, "and capture has stopped")
end)

test("named timers replace rather than stack", function()
	local ns, env = loadAddon()
	local runs = 0
	ns:After("test.timer", 1, function()
		runs = runs + 1
	end)
	ns:After("test.timer", 1, function()
		runs = runs + 1
	end)
	Fake.advance(env, 2)
	checkEqual(1, runs, "the superseded timer did not fire")

	ns:After("test.cancelled", 1, function()
		runs = runs + 1
	end)
	ns:CancelTimer("test.cancelled")
	Fake.advance(env, 2)
	checkEqual(1, runs, "the cancelled timer did not fire")
end)

--[[
    Cancelling forgets the identifier, so the timer scheduled next under that
    same name must not inherit the cancelled one's generation.
]]
test("a cancelled timer cannot fire in place of its replacement", function()
	local ns, env = loadAddon()
	local ran = {}

	ns:After("reused", 1, function()
		table.insert(ran, "cancelled")
	end)
	ns:CancelTimer("reused")
	ns:After("reused", 5, function()
		table.insert(ran, "replacement")
	end)

	Fake.advance(env, 2)
	checkEqual(0, #ran, "the cancelled callback stayed dead inside the replacement's window")

	Fake.advance(env, 4)
	checkEqual(1, #ran, "exactly one callback ran")
	checkEqual("replacement", ran[1], "and it was the replacement")
end)

test("every locale carries the same keys as enUS", function()
	local enUS = {}
	for key in io.open(ROOT .. "Locales/enUS.lua"):read("*a"):gmatch('L%["([A-Z0-9_]+)"%]') do
		enUS[key] = true
	end

	for _, locale in ipairs({ "deDE", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW" }) do
		local body = io.open(ROOT .. "Locales/" .. locale .. ".lua"):read("*a")
		local present = {}
		for key in body:gmatch('L%["([A-Z0-9_]+)"%]') do
			present[key] = true
		end
		for key in pairs(enUS) do
			check(present[key], ("%s is missing %s"):format(locale, key))
		end
	end
end)

--[[
    The /Commands line names every literal the options command answers to, in
    registration order (Style Guide: Slash Commands). Every locale carries its
    own copy of that line, so one left behind would show its players a command
    that no longer exists.
]]
test("every locale's /Commands line shows the registered command", function()
	local _, env = loadAddon()
	-- rawget: the fake environment answers every other global with a stub.
	local literals = {}
	while rawget(env, "SLASH_GOGOLOOT" .. (#literals + 1)) do
		literals[#literals + 1] = rawget(env, "SLASH_GOGOLOOT" .. (#literals + 1))
	end
	local command = table.concat(literals, ", ")
	checkEqual("/gogo", command, "the options command answers to /gogo alone")
	checkEqual("function", type(env.SlashCmdList.GOGOLOOT), "and it is wired")

	for _, locale in ipairs({ "enUS", "deDE", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW" }) do
		local body = io.open(ROOT .. "Locales/" .. locale .. ".lua"):read("*a")
		local shown = body:match('L%["OPTIONS_COMMAND"%]%s*=%s*"([^"]*)"')
		-- A locale without its own copy falls back to enUS's.
		if shown or locale == "enUS" then
			checkEqual(command, shown, locale .. " shows the registered command")
		end
	end
end)

--------------------------------------------------------------------------------
-- Automated Rolls: Item Overrides vs the type skips
--------------------------------------------------------------------------------

--[[
    Starts one live roll on `itemId` and returns the rolls the add-on issued.

    classId defaults to 12 (Quest) and bindType to 1 (BoP), which is what the
    Ahn'Qiraj and Zul'Gurub tokens the default list exists for actually report.
    That combination is the trap: a blanket type skip ahead of the list leaves
    correct ids and a correct saved action with no roll ever going out. Every
    test below leans on it, so it is the default rather than something each
    one has to remember to spell.
]]
local function startRoll(ns, env, itemId, description)
	local state = env.__state
	description = description or {}
	state.itemNames[itemId] = {
		name = description.name or ("Item " .. itemId),
		quality = description.quality or 2,
		classId = description.classId or 12,
		subclassId = description.subclassId or 0,
		bindType = description.bindType or 1,
	}
	state.lootRolls[7] = { itemId = itemId, canNeed = description.canNeed, canGreed = description.canGreed }
	state.rollsPerformed = {}

	ns.db.profile.autoGreed = true
	fire(ns, "START_LOOT_ROLL", 7)
	return state.rollsPerformed
end

test("a quest-class item on Item Overrides rolls the action it was given", function()
	local ns, env = loadAddon()

	-- Stone Scarab, straight out of the shipped defaults.
	local rolls = startRoll(ns, env, 20858, { name = "Stone Scarab" })

	checkEqual(1, #rolls, "the scarab produced exactly one roll")
	checkEqual(ns.ROLL_ACTION_NEED, rolls[1] and rolls[1].action, "it rolled Need")
end)

test("a quest-class item the list does not mention is left alone by the threshold path", function()
	local ns, env = loadAddon()

	--[[
	    Uncommon and BoE, so it clears the threshold and the BoP guard both —
	    the only thing that can stop it is the quest-class skip, which is the
	    point. Without it, the list becoming reachable would have quietly
	    turned every quest token in the game into a Greed.
	]]
	local rolls = startRoll(ns, env, 40001, { quality = 2, bindType = 2 })

	checkEqual(0, #rolls, "an unlisted quest item never rolled")
end)

test("a listed legendary is still never rolled", function()
	local ns, env = loadAddon()
	ns.db.profile.ignoredItemsSolo[40002] = ns.NEED

	local rolls = startRoll(ns, env, 40002, { quality = 5 })

	checkEqual(0, #rolls, "Item Overrides cannot opt a legendary back in")
end)

test("a listed mount is still never rolled", function()
	local ns, env = loadAddon()
	ns.db.profile.ignoredItemsSolo[40003] = ns.NEED

	local rolls = startRoll(ns, env, 40003, { quality = 4, classId = ns.ITEM_CLASS_MISCELLANEOUS, subclassId = 5 })

	checkEqual(0, #rolls, "Item Overrides cannot opt a mount back in")
end)

test("a listed item set to Manual is left to the player", function()
	local ns, env = loadAddon()

	-- Wartorn Leather Scrap ships listed, at Manual, on purpose.
	local rolls = startRoll(ns, env, 22373, { name = "Wartorn Leather Scrap" })

	checkEqual(0, #rolls, "a Manual entry rolled nothing")
end)

test("Need falls back to Greed when the client will not allow Need", function()
	local ns, env = loadAddon()

	local rolls = startRoll(ns, env, 20858, { canNeed = false, canGreed = true })

	checkEqual(1, #rolls, "the roll still went out")
	checkEqual(ns.ROLL_ACTION_GREED, rolls[1] and rolls[1].action, "it fell back to Greed")
end)

--[[
    Print Item in Chat: the roll window closes the moment GogoLoot rolls, so a
    line names the item and the roll actually made, a fallen-back Need reading
    as Greed and a Pass as a pass. It ships on, and off it prints nothing.
]]
test("an automated roll prints the item and the roll it made", function()
	local ns, env = loadAddon()
	local state = env.__state
	local L = ns.L
	local function lastPrint()
		return (state.prints[#state.prints] or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	end

	checkEqual(true, ns.db.profile.printRolledItems, "it ships on")

	state.prints = {}
	startRoll(ns, env, 20858, { name = "Stone Scarab" })
	checkEqual(1, #state.prints, "one line goes to chat")
	check(
		lastPrint():find(L["ADDON_TITLE"] .. " // You rolled " .. env.NEED .. " on ", 1, true) ~= nil,
		"naming the roll, name first"
	)
	check(lastPrint():find("Stone Scarab", 1, true) ~= nil, "and the item")

	state.prints = {}
	startRoll(ns, env, 20858, { name = "Stone Scarab", canNeed = false, canGreed = true })
	check(
		lastPrint():find("You rolled " .. env.GREED .. " on ", 1, true) ~= nil,
		"a Need that fell back reads as Greed"
	)

	ns.db.profile.ignoredItemsSolo[20858] = ns.PASS
	state.prints = {}
	startRoll(ns, env, 20858, { name = "Stone Scarab" })
	check(lastPrint():find("You passed on ", 1, true) ~= nil, "a Pass reads as a pass")

	ns.db.profile.printRolledItems = false
	state.prints = {}
	startRoll(ns, env, 20858, { name = "Stone Scarab" })
	checkEqual(1, #state.rollsPerformed, "switched off, the roll still goes out")
	checkEqual(0, #state.prints, "and nothing is printed")
end)

-- A roll GogoLoot leaves alone prints nothing: the player still has the roll window.
test("a roll GogoLoot leaves alone prints nothing", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.prints = {}
	startRoll(ns, env, 99001, { name = "Unlisted Quest Thing", classId = 12 })
	checkEqual(0, #state.rollsPerformed, "no roll went out")
	checkEqual(0, #state.prints, "and nothing was printed")
end)

test("the master switch still silences Item Overrides", function()
	local ns, env = loadAddon()
	local state = env.__state

	state.itemNames[20858] = { name = "Stone Scarab", quality = 2, classId = 12, subclassId = 0, bindType = 1 }
	state.lootRolls[7] = { itemId = 20858 }
	state.rollsPerformed = {}

	ns.db.profile.autoGreed = false
	fire(ns, "START_LOOT_ROLL", 7)

	checkEqual(0, #state.rollsPerformed, "Automated Rolls off means nothing rolls")
end)

--[[
    The cache race the war-effort tokens actually hit in AQ20 and Zul'Gurub: a
    token's first drop of the session starts its roll before the client's item
    query has answered, so the link and item info both read nil. The old code
    took the nil link for a dead roll and never retried — no roll, no error —
    and even the retried path gave up after five seconds while the roll window
    had most of its minute left.
]]
test("a listed token whose item is uncached at roll start still rolls once it resolves", function()
	local ns, env = loadAddon()
	local state = env.__state

	-- Stone Scarab drops, entirely cold: no itemNames entry means no link, no info.
	state.lootRolls[7] = { itemId = 20858 }
	state.rollsPerformed = {}
	ns.db.profile.autoGreed = true
	fire(ns, "START_LOOT_ROLL", 7)

	checkEqual(0, #state.rollsPerformed, "nothing rolled while the item was unresolved")

	-- The item query answers mid-roll; the next retry tick must pick it up.
	Fake.advance(env, 1)
	state.itemNames[20858] = { name = "Stone Scarab", quality = 1, classId = 12, subclassId = 0, bindType = 1 }
	Fake.advance(env, 1)

	checkEqual(1, #state.rollsPerformed, "the roll went out once the info resolved")
	checkEqual(
		ns.ROLL_ACTION_NEED,
		state.rollsPerformed[1] and state.rollsPerformed[1].action,
		"with the listed action"
	)
end)

test("the retry outlives a slow item query instead of giving up at five seconds", function()
	local ns, env = loadAddon()
	local state = env.__state

	state.lootRolls[7] = { itemId = 19708 }
	state.rollsPerformed = {}
	ns.db.profile.autoGreed = true
	fire(ns, "START_LOOT_ROLL", 7)

	-- Twelve retry ticks with the info still cold: past the old ten-attempt cap.
	for _ = 1, 12 do
		Fake.advance(env, 1)
	end
	checkEqual(0, #state.rollsPerformed, "still nothing while the item stays unresolved")

	state.itemNames[19708] = { name = "Blue Hakkari Bijou", quality = 3, classId = 12, subclassId = 0, bindType = 1 }
	Fake.advance(env, 1)

	checkEqual(1, #state.rollsPerformed, "the roll still went out after the old cap would have quit")
end)

test("a cancelled roll stops the cold-item poll for good", function()
	local ns, env = loadAddon()
	local state = env.__state

	state.lootRolls[7] = { itemId = 20858 }
	state.rollsPerformed = {}
	ns.db.profile.autoGreed = true
	fire(ns, "START_LOOT_ROLL", 7)

	-- The roll ends before the item ever resolves; the poll must die with it.
	fire(ns, "CANCEL_LOOT_ROLL", 7)
	state.lootRolls[7] = nil
	state.itemNames[20858] = { name = "Stone Scarab", quality = 1, classId = 12, subclassId = 0, bindType = 1 }
	Fake.advance(env, 10)

	checkEqual(0, #state.rollsPerformed, "no roll fired after the roll was cancelled")
end)

--[[
    Quest items are the one skip Automated Master Looting can be talked out of.
    Both ways an item reads as quest-class are covered: the AQ and ZG tokens
    carry classId 12 with an ordinary bind type, while an ordinary quest drop
    is the quest bind type instead.
]]
local function openQuestItemLootSession(ns, env)
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.lootMethod = 2
	state.masterLooterPartyIndex = 0
	state.masterLootCandidates = { "Bob" }
	state.lootSlots = {}
	state.itemNames = {}

	state.itemNames[2001] = { name = "Quest Class Item", quality = 1, classId = 12, subclassId = 0, bindType = 2 }
	state.itemNames[2002] = { name = "Quest Bound Item", quality = 1, classId = 4, subclassId = 0, bindType = 4 }
	state.lootSlots[1] = { link = "|Hitem:2001|h[Quest Class Item]|h" }
	state.lootSlots[2] = { link = "|Hitem:2002|h[Quest Bound Item]|h" }

	ns.db.profile.destinations = { poor = "bob", common = "bob", uncommon = "bob", rare = "bob", epic = "bob" }
	ns.db.profile.autoMasterLoot = true
	return state
end

test("master-loot distribution skips quest items until the player opts in", function()
	local ns, env = loadAddon()
	local state = openQuestItemLootSession(ns, env)

	fire(ns, "LOOT_OPENED")
	Fake.advance(env, 1)

	checkEqual(0, #state.givenLoot, "nothing handed out while the quest-item toggle is off")
end)

test("the quest-item opt-in hands out both kinds of quest item", function()
	local ns, env = loadAddon()
	local state = openQuestItemLootSession(ns, env)
	ns.db.profile.autoMasterLootQuestItems = true

	fire(ns, "LOOT_OPENED")

	checkEqual(2, #state.givenLoot, "the quest-class item and the quest-bound one both went out")
end)

test("the quest-item opt-in reaches nothing but the quest-class skip", function()
	local ns, env = loadAddon()
	local state = openQuestItemLootSession(ns, env)
	state.itemNames[2003] = { name = "Quest Legendary", quality = 5, classId = 12, subclassId = 0, bindType = 1 }
	state.lootSlots[3] = { link = "|Hitem:2003|h[Quest Legendary]|h" }
	ns.db.profile.autoMasterLootQuestItems = true

	fire(ns, "LOOT_OPENED")

	local givenSlots = {}
	for _, given in ipairs(state.givenLoot) do
		givenSlots[given.slotIndex] = true
	end
	check(givenSlots[1] and givenSlots[2], "distribution stops skipping quest items")
	check(not givenSlots[3], "the never-automated set is not opted out of")

	local questItem = { quality = 2, classId = 12, subclassId = 0, bindType = 1 }
	check(ns:IsQuestClassItem(questItem), "the roll path's own quest check reads the same as ever")
	check(not ns:IsNeverAutomatedItem(questItem), "quest items are not in the never-automated set")
end)

test("the quest-item opt-in does not make Automated Rolls roll on quest items", function()
	local ns, env = loadAddon()
	local state = env.__state

	-- Unlisted, so nothing but the threshold path could pick it up.
	state.itemNames[2001] = { name = "Quest Class Item", quality = 2, classId = 12, subclassId = 0, bindType = 2 }
	state.lootRolls[7] = { itemId = 2001 }
	state.rollsPerformed = {}
	ns.db.profile.autoGreed = true
	ns.db.profile.autoMasterLootQuestItems = true

	fire(ns, "START_LOOT_ROLL", 7)
	Fake.advance(env, 1)

	checkEqual(0, #state.rollsPerformed, "the roll path kept its own quest-class skip")
end)

--------------------------------------------------------------------------------
-- Automated Rolls: Character Rules
--------------------------------------------------------------------------------

--[[
    A roll on gear for Character Rules: an Uncommon, Bind on Equip plate piece
    the default In Party setting Greeds on, with `stats` as GetItemStats would
    report them, and the player's rules set to `rules`.
]]
--[[
    The add-on as a client with the given X-Flavor loads it. Classic Era is the
    default; the secondary stats only exist from WoW Forever on.
]]
local function loadFlavorAddon(flavor)
	return loadAddon(nil, function(env)
		-- The flavor folder's stat list in place of Vanilla's, as that flavor's TOC loads it.
		env.__flavorFiles = {
			["Data/Vanilla/Character-Rule-Stats-Vanilla.lua"] = ("Data/%s/Character-Rule-Stats-%s.lua"):format(
				flavor,
				flavor
			),
		}
		local readMetadata = env.C_AddOns.GetAddOnMetadata
		env.C_AddOns.GetAddOnMetadata = function(addonName, field)
			if field == "X-Flavor" then
				return flavor
			end
			return readMetadata(addonName, field)
		end
	end)
end

local function startRuleRoll(ns, env, rules, description)
	local state = env.__state
	description = description or {}
	local itemId = description.itemId or 4001
	state.itemStats[itemId] = description.stats or {}
	state.itemNames[itemId] = {
		name = "Rule Item",
		quality = 2,
		classId = 4,
		subclassId = 4,
		bindType = 2,
	}
	state.lootRolls[7] = { itemId = itemId, suffixId = description.suffixId }
	state.rollsPerformed = {}
	ns.db.char.characterRules = rules
	ns.db.profile.autoGreed = true
	fire(ns, "START_LOOT_ROLL", 7)
	return state.rollsPerformed
end

test("a stat set to Manual leaves gear with it to the player, and other gear rolls as usual", function()
	local ns, env = loadAddon()
	local rules = { INTELLECT = ns.MANUAL }

	local rolls =
		startRuleRoll(ns, env, rules, { stats = { ITEM_MOD_INTELLECT_SHORT = 8, ITEM_MOD_STRENGTH_SHORT = 8 } })
	checkEqual(0, #rolls, "Intellect gear keeps its roll window")

	rolls = startRuleRoll(ns, env, rules, { stats = { ITEM_MOD_STRENGTH_SHORT = 8 } })
	checkEqual(ns.ROLL_ACTION_GREED, rolls[1] and rolls[1].action, "Strength gear Greeds as the quality settings say")

	rolls = startRuleRoll(ns, env, nil, { stats = { ITEM_MOD_INTELLECT_SHORT = 8 } })
	checkEqual(ns.ROLL_ACTION_GREED, rolls[1] and rolls[1].action, "and with no rules, so does Intellect gear")
end)

test("Classic Era and TBC offer only the primary attributes, and a secondary rule saved there does nothing", function()
	for _, flavor in ipairs({ "Vanilla", "TBC" }) do
		local ns, env = loadFlavorAddon(flavor)
		local keys = {}
		for index, stat in ipairs(ns.CHARACTER_RULE_STATS) do
			keys[index] = stat.key
		end
		checkEqual("STRENGTH AGILITY STAMINA INTELLECT SPIRIT", table.concat(keys, " "), flavor .. " lists the five")
		checkEqual(1, #ns.CHARACTER_RULE_GROUPS, flavor .. " has one section")

		local rolls = startRuleRoll(
			ns,
			env,
			{ SPELL_POWER = ns.MANUAL },
			{ stats = { ITEM_MOD_SPELL_DAMAGE_DONE_SHORT = 12 } }
		)
		checkEqual(1, #rolls, flavor .. " rolls on spell damage gear despite an old Spell Power rule")
	end

	local ns = loadFlavorAddon("Camelot")
	checkEqual(11, #ns.CHARACTER_RULE_STATS, "WoW Forever keeps every stat")
end)

test("Hit and Mana Per 5 count from the item on WoW Forever", function()
	local ns, env = loadFlavorAddon("Camelot")
	local rolls = startRuleRoll(ns, env, { HIT = ns.MANUAL }, { stats = { ITEM_MOD_HIT_SPELL_RATING_SHORT = 10 } })
	checkEqual(0, #rolls, "spell hit rating is Hit gear")

	rolls = startRuleRoll(ns, env, { MP5 = ns.MANUAL }, { stats = { ITEM_MOD_MANA_REGENERATION_SHORT = 4 } })
	checkEqual(0, #rolls, "mana regeneration is Mana Per 5 gear")
end)

test("a suffix's stats are read off the tooltip in the game's own words where no table has them", function()
	local ns, env = loadAddon()
	-- What a suffix line looks like on the scan tooltip: color-wrapped and newline-terminated.
	env.__state.hyperlinkTooltipLines[4001] = { "Rule Item", "|cffffffff+15 Intellect|r\n", "+9 Stamina" }
	local rolls = startRuleRoll(ns, env, { INTELLECT = ns.MANUAL }, { suffixId = 99999 })
	checkEqual(0, #rolls, "+15 Intellect on the tooltip is Intellect gear")
end)

test("a stat the gear lowers isn't a stat it carries", function()
	local ns, env = loadAddon()
	env.__state.hyperlinkTooltipLines[4001] = { "Rule Item", "-10 Spirit", "+9 Stamina" }
	local rolls = startRuleRoll(ns, env, { SPIRIT = ns.MANUAL }, { suffixId = 99999 })
	checkEqual(1, #rolls, "-10 Spirit doesn't make it Spirit gear, so it still rolls")
end)

test("Spell Power on a later client counts as healing gear too", function()
	local ns, env = loadFlavorAddon("Camelot")
	local rolls = startRuleRoll(ns, env, { HEALING_POWER = ns.MANUAL }, { stats = { ITEM_MOD_SPELL_POWER_SHORT = 20 } })
	checkEqual(0, #rolls, "a Manual healing stat keeps Spell Power gear's roll window")
end)

test("Item Overrides beat Character Rules", function()
	local ns, env = loadAddon()
	ns.db.profile.ignoredItemsSolo[4001] = ns.NEED
	local rolls = startRuleRoll(ns, env, { STRENGTH = ns.MANUAL }, { stats = { ITEM_MOD_STRENGTH_SHORT = 12 } })
	checkEqual(ns.ROLL_ACTION_NEED, rolls[1] and rolls[1].action, "the item's override decided")
end)

test("a Need or Greed saved before the rules went to two choices does nothing", function()
	local ns, env = loadAddon()
	local rolls = startRuleRoll(ns, env, { STRENGTH = ns.NEED }, { stats = { ITEM_MOD_STRENGTH_SHORT = 12 } })
	checkEqual(ns.ROLL_ACTION_GREED, rolls[1] and rolls[1].action, "the gear rolls as the quality settings say")

	local select = ns.BuildCharacterRulesOptions().args["Aero - Realm"].args.ruleSTRENGTH.args.control2
	checkEqual(ns.CHARACTER_RULE_STANDARD, select.get(), "and the dropdown reads Standard Automated Roll")
end)

test("the Character Rules panel lists every character in its class color and edits the one picked", function()
	local ns, env = loadFlavorAddon("Camelot")
	env.__state.playerClassFile = "WARRIOR"
	ns.db.sv.char["Hippo - Realm"] = { classFile = "ROGUE" }

	local panel = ns.BuildCharacterRulesOptions()
	checkEqual("tree", panel.childGroups, "characters down the left, rules on the right")
	local mine, alt = panel.args["Aero - Realm"], panel.args["Hippo - Realm"]
	check(mine ~= nil and alt ~= nil, "both characters are listed")
	checkEqual("|cffC69B6DAero - Realm|r", mine and mine.name, "the player in their class color")
	checkEqual("|cffFFF468Hippo - Realm|r", alt and alt.name, "another character in the color it saved")
	check(mine.order < alt.order, "sorted by name")

	local strengthSelect = alt.args.ruleSTRENGTH.args.control2
	checkEqual(ns.CHARACTER_RULE_STANDARD, strengthSelect.get(), "every stat starts on Standard Automated Roll")
	checkEqual(2, #strengthSelect.sorting, "with Manual the only other choice")
	checkEqual(
		ns.OPTIONS_TREE_ROW_WIDTH,
		alt.args.ruleSTRENGTH.args.control1.width + strengthSelect.width,
		"a row fits the pane"
	)

	strengthSelect.set(nil, ns.MANUAL)
	checkEqual(ns.MANUAL, ns.db.sv.char["Hippo - Realm"].characterRules.STRENGTH, "the rule lands on that character")
	checkEqual(nil, ns.db.char.characterRules, "not on the one being played")

	strengthSelect.set(nil, ns.CHARACTER_RULE_STANDARD)
	checkEqual(nil, ns.db.sv.char["Hippo - Realm"].characterRules, "Standard saves no rule, and an empty set goes")

	--[[
	    The pane top to bottom: Primary Attributes in the character sheet's
	    order, a blank line, then Secondary Attributes A to Z.
	]]
	local layout = {}
	for key, entry in pairs(alt.args) do
		layout[#layout + 1] = { key = key, order = entry.order }
	end
	table.sort(layout, function(left, right)
		return left.order < right.order
	end)
	local keys = {}
	for index, entry in ipairs(layout) do
		keys[index] = entry.key
	end
	checkEqual(
		table.concat({
			"spacerBeforePRIMARY",
			"headerPRIMARY",
			"spacerAfterPRIMARY",
			"ruleSTRENGTH",
			"ruleAGILITY",
			"ruleSTAMINA",
			"ruleINTELLECT",
			"ruleSPIRIT",
			"spacerBeforeSECONDARY",
			"headerSECONDARY",
			"spacerAfterSECONDARY",
			-- The test client's words: Attack Power, Bonus Healing, Critical Strike, Hit, Mana Per 5 Sec., Spell Power.
			"ruleATTACK_POWER",
			"ruleHEALING_POWER",
			"ruleCRIT",
			"ruleHIT",
			"ruleMP5",
			"ruleSPELL_POWER",
		}, " "),
		table.concat(keys, " "),
		"Primary in the character sheet's order, then Secondary A to Z by the client's own names"
	)
end)

test("Character Rules opens on the character being played, every time it's shown", function()
	local ns, env = loadAddon()
	local registryName = ns.OPTIONS_REGISTRY.CharacterRules
	local status = env.__state.dialogStatus[registryName]
	checkEqual("Aero - Realm", status and status.groups and status.groups.selected, "picked at registration")

	status.groups.selected = "Hippo - Realm"
	local panelFrame
	for _, entry in ipairs(env.__state.blizOptions) do
		if entry.appName == registryName then
			panelFrame = entry.frame
		end
	end
	for _, hook in ipairs(panelFrame.hooks.OnHide or {}) do
		hook()
	end
	checkEqual("Aero - Realm", status.groups.selected, "and picked again once the panel hides")
end)

test("each character saves its class for the list's colors", function()
	local ns = loadAddon(nil, function(loadingEnv)
		loadingEnv.__state.playerClassFile = "PRIEST"
	end)
	checkEqual("PRIEST", ns.db.char.classFile, "the class is saved at load")
end)

--------------------------------------------------------------------------------
-- War-effort token defaults
--------------------------------------------------------------------------------

-- Every id the war-effort roll list covers, by the action it should ship with.
local WAR_EFFORT_NEED_IDENTIFIERS = {
	-- Zul'Gurub bijous
	19707,
	19708,
	19709,
	19710,
	19711,
	19712,
	19713,
	19714,
	19715,
	-- Zul'Gurub coins
	19698,
	19699,
	19700,
	19701,
	19702,
	19703,
	19704,
	19705,
	19706,
	-- Ahn'Qiraj scarabs
	20858,
	20859,
	20860,
	20861,
	20862,
	20863,
	20864,
	20865,
	-- AQ20 idols
	20866,
	20867,
	20868,
	20869,
	20870,
	20871,
	20872,
	20873,
	-- AQ40 idols (20880 is not a live item id)
	20874,
	20875,
	20876,
	20877,
	20878,
	20879,
	20881,
	20882,
	-- Scarab Bag and both coffer keys
	21156,
	21761,
	21762,
}

local WARTORN_SCRAP_IDENTIFIERS = { 22373, 22374, 22375, 22376 }

test("the shipped defaults cover every war-effort token with the intended action", function()
	local ns = loadAddon()
	local rollList = ns.db.profile.ignoredItemsSolo

	for _, itemIdentifier in ipairs(WAR_EFFORT_NEED_IDENTIFIERS) do
		checkEqual(ns.NEED, rollList[itemIdentifier], ("%d ships at Need"):format(itemIdentifier))
	end
	for _, itemIdentifier in ipairs(WARTORN_SCRAP_IDENTIFIERS) do
		checkEqual(ns.MANUAL, rollList[itemIdentifier], ("%d ships at Manual"):format(itemIdentifier))
	end
end)

--------------------------------------------------------------------------------
-- Merged Features: Shared Helpers
--------------------------------------------------------------------------------

--[[
    Item ids from this client's container data (Data/Vanilla), each chosen for
    the default it carries: a clam opens on sight, the junkbox and the two
    lockboxes wait on a lock, the gem sack is a raid drop, the footlocker holds
    unique quest items, and the crate holds a Bind on Pickup weapon. CUSTOM_BOX
    is in no data at all, for the items a player adds.
]]
local CLAM = 7973 -- Big-mouth Clam
local BATTERED_JUNKBOX = 16882 -- skill 1
local IRON_LOCKBOX = 4634 -- skill 70
local ORNATE_BRONZE_LOCKBOX = 4632 -- skill 1
local BLUE_SACK_OF_GEMS = 17962 -- default Ignore - Raid Boss
local PIRATES_FOOTLOCKER = 9276 -- default Ignore - Contains Unique
local WATERLOGGED_CRATE = 6352 -- default Ignore
local CUSTOM_BOX = 900001

local function itemLink(itemIdentifier, name, colorHex)
	return ("|cff%s|Hitem:%d::::::::60:::::|h[%s]|h|r"):format(colorHex or "ffffff", itemIdentifier, name)
end

local function putInBag(env, bagIndex, slotIndex, itemIdentifier, name, fields)
	local state = env.__state
	state.bags[bagIndex] = state.bags[bagIndex] or {}
	local slot = { itemId = itemIdentifier, name = name, link = itemLink(itemIdentifier, name) }
	for key, value in pairs(fields or {}) do
		slot[key] = value
	end
	state.bags[bagIndex][slotIndex] = slot
	return slot
end

local function printedContaining(env, needle)
	for _, line in ipairs(env.__state.prints) do
		if line:find(needle, 1, true) then
			return line
		end
	end
	return nil
end

local function printCount(env, needle)
	local count = 0
	for _, line in ipairs(env.__state.prints) do
		if line:find(needle, 1, true) then
			count = count + 1
		end
	end
	return count
end

local function soundsPlayed(env, kind, sound)
	local count = 0
	for _, entry in ipairs(env.__state.sounds) do
		if entry.kind == kind and entry.sound == sound then
			count = count + 1
		end
	end
	return count
end

-- Runs a forced scan, then the first open tick.
--[[
    Automated Opening scans nothing until ns.WORLD_LOAD_DELAY after a login or
    reload, so a test first plays the login through, once per environment.
]]
local function finishWorldLoad(ns, env)
	if env.__state.worldLoaded then
		return
	end
	env.__state.worldLoaded = true
	fire(ns, "PLAYER_ENTERING_WORLD", true, false)
	Fake.advance(env, ns.WORLD_LOAD_DELAY)
end

local function scanAndTick(ns, env)
	finishWorldLoad(ns, env)
	ns.ScheduleOpeningScan(true)
	Fake.advance(env, ns.OPEN_TICK_INTERVAL)
end

--------------------------------------------------------------------------------
-- Merged Features: Openable Items
--------------------------------------------------------------------------------

--[[
    An item's action is Open or Ignore. Its data default also carries a reason,
    which belongs to the item rather than to the setting: it shows as the row's
    tag, explained under the item's tooltip, whatever the player sets it to.
]]
test("each openable item starts from its data's default, and keeps its reason as a tag", function()
	local ns = loadAddon()
	local L = ns.L
	checkEqual(ns.OPENING_OPEN, ns:GetOpeningAction(CLAM), "a clam opens on sight")
	checkEqual(ns.OPENING_OPEN, ns:GetOpeningAction(IRON_LOCKBOX), "a lockbox is set to Open, and waits for its lock")
	checkEqual(ns.OPENING_IGNORE, ns:GetOpeningAction(BLUE_SACK_OF_GEMS), "a raid gem sack is ignored")
	checkEqual(ns.OPENING_IGNORE, ns:GetOpeningAction(PIRATES_FOOTLOCKER), "so is the footlocker with its unique items")
	checkEqual(ns.OPENING_IGNORE, ns:GetOpeningAction(WATERLOGGED_CRATE), "and the crate with its Bind on Pickup loot")
	checkEqual(nil, ns:GetOpeningAction(6948), "nothing outside the data is openable at all")

	local reasons = {
		{
			IRON_LOCKBOX,
			ns.OPENING_UNLOCKED,
			"Locked",
			"Needs a Rogue to pick it. Once it's picked, it opens like any other container.",
			"a lockbox",
		},
		{ BLUE_SACK_OF_GEMS, ns.OPENING_IGNORE_RAID, "OPENING_TAG_SEALED", "OPENING_REASON_RAID", "a raid drop" },
		{ WATERLOGGED_CRATE, ns.OPENING_IGNORE, "OPENING_TAG_SEALED", "OPENING_REASON_BIND_ON_PICKUP", "a crate" },
		{
			PIRATES_FOOTLOCKER,
			ns.OPENING_IGNORE_UNIQUE,
			"OPENING_TAG_UNIQUE",
			"OPENING_REASON_UNIQUE",
			"the footlocker",
		},
	}
	for _, reason in ipairs(reasons) do
		local itemIdentifier, default, tag, note, name = reason[1], reason[2], reason[3], reason[4], reason[5]
		checkEqual(default, ns:GetOpeningDefault(itemIdentifier), name .. " keeps its data default, reason and all")
		checkEqual(L[tag] or tag, ns:GetOpeningTag(itemIdentifier), name .. " is tagged with its reason")
		checkEqual(L[note] or note, ns:GetOpeningNote(itemIdentifier), name .. " explains it under its tooltip")
	end
	checkEqual(nil, ns:GetOpeningTag(CLAM), "a row with no reason has no tag")
	checkEqual(nil, ns:GetOpeningNote(CLAM), "and no note")

	ns:SetOpeningAction(BLUE_SACK_OF_GEMS, ns.OPENING_OPEN)
	checkEqual(L["OPENING_TAG_SEALED"], ns:GetOpeningTag(BLUE_SACK_OF_GEMS), "a tag stays whatever the item is set to")
end)

test("every kind of Ignore leaves an item alone", function()
	local ns, env = loadAddon()
	for _, itemIdentifier in ipairs({ BLUE_SACK_OF_GEMS, PIRATES_FOOTLOCKER, WATERLOGGED_CRATE }) do
		check(ns:IsOpeningIgnored(itemIdentifier), ("%d counts as ignored"):format(itemIdentifier))
	end
	check(not ns:IsOpeningIgnored(CLAM), "a container set to Open doesn't")
	putInBag(env, 0, 1, BLUE_SACK_OF_GEMS, "Blue Sack of Gems")
	putInBag(env, 0, 2, PIRATES_FOOTLOCKER, "Pirate's Footlocker")
	putInBag(env, 0, 3, WATERLOGGED_CRATE, "Waterlogged Crate")
	scanAndTick(ns, env)
	checkEqual(0, #env.__state.usedContainerItems, "none of the three is opened")
end)

test("only the player's changes are saved, so new data reaches them", function()
	local ns = loadAddon()
	ns:SetOpeningAction(BLUE_SACK_OF_GEMS, ns.OPENING_OPEN)
	checkEqual(ns.OPENING_OPEN, ns.db.global.openingActions[BLUE_SACK_OF_GEMS], "a change is saved")
	checkEqual(ns.OPENING_OPEN, ns:GetOpeningAction(BLUE_SACK_OF_GEMS), "and read back")

	ns:SetOpeningAction(BLUE_SACK_OF_GEMS, ns.OPENING_IGNORE)
	checkEqual(nil, ns.db.global.openingActions[BLUE_SACK_OF_GEMS], "setting it back to its default saves nothing")

	ns:SetOpeningAction(IRON_LOCKBOX, ns.OPENING_OPEN)
	checkEqual(nil, ns.db.global.openingActions[IRON_LOCKBOX], "a lockbox's default is Open, so Open saves nothing")

	ns:SetOpeningAction(CLAM, ns.OPENING_IGNORE)
	ns:SetOpeningAction(IRON_LOCKBOX, ns.OPENING_IGNORE)
	ns:RestoreDefaultOpeningActions()
	checkEqual(nil, next(ns.db.global.openingActions), "Restore Defaults clears every change")

	ns:SetOpeningAction(6948, ns.OPENING_OPEN)
	checkEqual(nil, ns.db.global.openingActions[6948], "and an item off the list can't be set to open")
	ns:SetOpeningAction(CLAM, ns.OPENING_REMOVED)
	checkEqual(nil, ns.db.global.openingActions[CLAM], "nor can a dropdown remove an item")
	for _, reason in ipairs({ ns.OPENING_UNLOCKED, ns.OPENING_IGNORE_RAID, ns.OPENING_IGNORE_UNIQUE }) do
		ns:SetOpeningAction(CLAM, reason)
		checkEqual(nil, ns.db.global.openingActions[CLAM], "nor set a reason, which belongs to the data: " .. reason)
	end
end)

test("an item the data lacks can be added, and joins set to open", function()
	local ns, env = loadAddon()
	check(ns:AddOpeningItem(CUSTOM_BOX), "it joins the list")
	checkEqual(ns.OPENING_OPEN, ns:GetOpeningAction(CUSTOM_BOX), "set to Open")
	check(ns:GetOpenableItemList()[CUSTOM_BOX], "and is listed")
	putInBag(env, 0, 1, CUSTOM_BOX, "Custom Box")
	scanAndTick(ns, env)
	checkEqual(1, #env.__state.usedContainerItems, "Automated Opening opens it")

	ns:SetOpeningAction(CUSTOM_BOX, ns.OPENING_IGNORE)
	checkEqual(ns.OPENING_IGNORE, ns.db.global.openingActions[CUSTOM_BOX], "its setting is saved")
	check(ns:AddOpeningItem(CUSTOM_BOX), "adding it again")
	checkEqual(ns.OPENING_IGNORE, ns:GetOpeningAction(CUSTOM_BOX), "leaves its setting as it was")

	ns:RemoveOpeningItem(CUSTOM_BOX)
	checkEqual(nil, ns.db.global.openingActions[CUSTOM_BOX], "removing it leaves nothing saved")
	checkEqual(nil, ns:GetOpeningAction(CUSTOM_BOX), "and takes it off the list")
end)

test("a listed item the player removes is an ordinary item until added back", function()
	local ns, env = loadAddon()
	ns:RemoveOpeningItem(CLAM)
	checkEqual(ns.OPENING_REMOVED, ns.db.global.openingActions[CLAM], "the removal is saved")
	checkEqual(nil, ns:GetOpeningAction(CLAM), "it is off the list")
	check(not ns:GetOpenableItemList()[CLAM], "so it gets no row")
	putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
	scanAndTick(ns, env)
	checkEqual(0, #env.__state.usedContainerItems, "and is never opened")

	ns:RemoveOpeningItem(BLUE_SACK_OF_GEMS)
	check(not ns:IsOpeningIgnored(BLUE_SACK_OF_GEMS), "a removed Ignore row no longer holds Speedy Loot back")

	check(ns:AddOpeningItem(CLAM), "adding it back")
	checkEqual(nil, ns.db.global.openingActions[CLAM], "clears the removal")
	checkEqual(ns.OPENING_OPEN, ns:GetOpeningAction(CLAM), "and its default returns")
end)

test("gear and bags can't be added, since using one equips it", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.itemNames[900002] = { name = "Shiny Sword", equipLocation = "INVTYPE_WEAPON" }
	state.itemNames[900003] = { name = "Small Pack", equipLocation = "INVTYPE_BAG" }
	state.itemNames[900004] = { name = "Some Box", equipLocation = "INVTYPE_NON_EQUIP_IGNORE" }
	state.itemsNotOnClient[900005] = true
	check(not ns:AddOpeningItem(900002), "a weapon is refused")
	check(not ns:AddOpeningItem(900003), "so is a bag")
	checkEqual(nil, ns:GetOpeningAction(900002), "and neither joins the list")
	check(ns:AddOpeningItem(900004), "an unequippable item on a Retail-engine client joins")
	check(not ns:AddOpeningItem(900005), "and an item this client lacks can't")
	checkEqual(nil, ns.db.global.openingActions[900005], "nor is it saved")
end)

test("Restore Defaults brings removed items back and sends added ones away", function()
	local ns = loadAddon()
	ns:AddOpeningItem(CUSTOM_BOX)
	ns:RemoveOpeningItem(CLAM)
	ns:SetOpeningAction(IRON_LOCKBOX, ns.OPENING_IGNORE)
	ns:RestoreDefaultOpeningActions()
	checkEqual(nil, ns:GetOpeningAction(CUSTOM_BOX), "the added item is gone")
	checkEqual(ns.OPENING_OPEN, ns:GetOpeningAction(CLAM), "the removed one is back at its default")
	checkEqual(ns.OPENING_OPEN, ns:GetOpeningAction(IRON_LOCKBOX), "and the changed one too")
end)

test("the openable items panel adds, removes and sets items, each with its own dropdown", function()
	local ns, env = loadAddon()
	env.__state.itemsNotOnClient[CLAM] = true
	local function ListArgs()
		return ns.BuildOpenableItemsOptions().args.itemList.args
	end
	local listArgs = ListArgs()
	local addItem = listArgs.addRow.args.addItemInput
	check(addItem ~= nil, "there is an add box")
	local row = listArgs["item_" .. IRON_LOCKBOX]
	check(row ~= nil, "a lockbox has a row")
	checkEqual(ns.OPENING_OPEN, row.args.action.get(), "its dropdown shows its default, Open")
	checkEqual(2, #ns.OPENING_ACTION_ORDER, "the dropdown offers two choices")
	for _, action in ipairs({ ns.OPENING_OPEN, ns.OPENING_IGNORE }) do
		check(row.args.action.values[action] ~= nil, "the dropdown offers " .. action)
	end
	checkEqual(ns.ROLL_ACTION_DROPDOWN_WIDTH, row.args.action.width, "as narrow as the Item Overrides dropdowns")
	check(row.args.tag.name:find("Locked", 1, true) ~= nil, "the row is tagged Locked")
	check(row.args.tag.name:find(ns.GetColor("HELP"), 1, true) ~= nil, "in silver")
	check(row.args.label.order < row.args.tag.order, "after the item")
	check(row.args.tag.order < row.args.action.order, "before the dropdown")
	checkEqual(ns:GetOpeningNote(IRON_LOCKBOX), row.args.label.desc, "and the reason rides the item's tooltip")
	checkEqual(" ", listArgs["item_" .. ORNATE_BRONZE_LOCKBOX] and " " or nil, "every listed row gets a tag cell")
	check(row.args.remove ~= nil, "each row has a remove icon")
	check(row.args.remove.confirm, "which confirms, since the row carries a setting")
	checkNear(
		ns.OPTIONS_ROW_WIDTH,
		row.args.label.width + row.args.tag.width + row.args.action.width + row.args.remove.width,
		"and the row spends the full width"
	)
	checkEqual(nil, listArgs["item_" .. CLAM], "an item this client doesn't have gets no row")
	check(listArgs["item_" .. BLUE_SACK_OF_GEMS].args.label.desc ~= nil, "a raid drop's note rides its tooltip")

	row.args.action.set(nil, ns.OPENING_IGNORE)
	checkEqual(ns.OPENING_IGNORE, ns:GetOpeningAction(IRON_LOCKBOX), "the dropdown sets the item's action")
	check(ListArgs()["item_" .. IRON_LOCKBOX].args.tag.name:find("Locked", 1, true) ~= nil, "tag and all")

	addItem.set(nil, ("|Hitem:%d|h[Custom Box]|h"):format(CUSTOM_BOX))
	check(ListArgs()["item_" .. CUSTOM_BOX] ~= nil, "a dragged-in item gets a row")

	row.args.remove.func()
	checkEqual(nil, ListArgs()["item_" .. IRON_LOCKBOX], "and a removed one loses its row")

	env.__state.itemNames[900002] = { name = "Shiny Sword", equipLocation = "INVTYPE_WEAPON" }
	addItem.set(nil, "900002")
	checkEqual(nil, ListArgs()["item_900002"], "a weapon gets no row")
	check(printedContaining(env, "Shiny Sword") ~= nil, "and the player is told why")
end)

--------------------------------------------------------------------------------
-- Merged Features: Automated Opening
--------------------------------------------------------------------------------

test("automated opening opens a container set to open", function()
	local ns, env = loadAddon()
	putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
	scanAndTick(ns, env)
	checkEqual(1, #env.__state.usedContainerItems, "the clam was opened")
	checkEqual(1, env.__state.usedContainerItems[1].slot, "from its own slot")
end)

test("an item set to ignore is never opened", function()
	local ns, env = loadAddon()
	putInBag(env, 0, 1, BLUE_SACK_OF_GEMS, "Blue Sack of Gems")
	scanAndTick(ns, env)
	checkEqual(0, #env.__state.usedContainerItems, "the gem sack stays shut")
end)

test("opening waits out an item under the cursor, then carries on by itself", function()
	local ns, env = loadAddon()
	local hovering = true
	env.GameTooltip.IsShown = function()
		return hovering
	end
	env.GameTooltip.GetItem = function()
		if hovering then
			return "Linen Cloth", "|Hitem:2589|h[Linen Cloth]|h"
		end
		return nil
	end
	putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
	scanAndTick(ns, env)
	Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	checkEqual(0, #env.__state.usedContainerItems, "nothing opens while the player looks at an item")

	hovering = false
	Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	checkEqual(1, #env.__state.usedContainerItems, "the clam opens once the tooltip hides, with no bag event")
end)

test("a scan during a cast still starts the tick, which opens once the cast ends", function()
	local ns, env = loadAddon()
	env.__state.casting = true
	putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
	scanAndTick(ns, env)
	Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	checkEqual(0, #env.__state.usedContainerItems, "nothing opens mid-cast")

	env.__state.casting = false
	Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	checkEqual(1, #env.__state.usedContainerItems, "the clam opens once the cast ends, with no bag event")
end)

test("opening waits out a spell held for its target, then carries on by itself", function()
	local ns, env = loadAddon()
	env.__state.spellTargeting = true
	putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
	scanAndTick(ns, env)
	Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	checkEqual(0, #env.__state.usedContainerItems, "nothing opens while a spell waits for its target")

	env.__state.spellTargeting = false
	Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	checkEqual(1, #env.__state.usedContainerItems, "the clam opens once the spell is cast or cancelled")
end)

test("with automated opening off nothing opens", function()
	local ns, env = loadAddon()
	ns.db.profile.autoOpen = false
	putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
	scanAndTick(ns, env)
	checkEqual(0, #env.__state.usedContainerItems, "the clam stays shut")
end)

test("a container above the player's level waits for the level, then opens on the level-up", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.itemNames[CLAM] = { name = "Big-mouth Clam", minLevel = 30 }
	state.playerLevel = 12
	putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
	scanAndTick(ns, env)
	Fake.advance(env, 5)
	checkEqual(0, #state.usedContainerItems, "a level 30 container is never tried at level 12")

	state.playerLevel = 30
	fire(ns, "PLAYER_LEVEL_UP", 30)
	Fake.advance(env, ns.SCAN_DEBOUNCE)
	Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	checkEqual(1, #state.usedContainerItems, "and it opens once the player reaches it")
end)

test("a container the game keeps refusing is set aside after three tries, until a level-up", function()
	local ns, env = loadAddon()
	local state = env.__state
	-- The fake bag never empties and no loot window answers, as when the game refuses the open.
	putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
	scanAndTick(ns, env)
	for _ = 1, 40 do
		Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	end
	checkEqual(ns.OPEN_REFUSAL_LIMIT, #state.usedContainerItems, "it is tried three times, a second apart")

	ns.ScheduleOpeningScan(true)
	Fake.advance(env, 5)
	checkEqual(ns.OPEN_REFUSAL_LIMIT, #state.usedContainerItems, "and a later scan leaves it alone")

	fire(ns, "PLAYER_LEVEL_UP", 61)
	Fake.advance(env, ns.SCAN_DEBOUNCE)
	Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	checkEqual(ns.OPEN_REFUSAL_LIMIT + 1, #state.usedContainerItems, "a level-up gives it another try")
end)

test("an open the game takes is never counted as refused", function()
	local ns, env = loadAddon()
	local state = env.__state
	local useContainerItem = env.C_Container.UseContainerItem
	env.C_Container.UseContainerItem = function(bagIndex, slotIndex)
		useContainerItem(bagIndex, slotIndex)
		fire(ns, "LOOT_OPENED", true)
	end
	putInBag(env, 0, 1, CLAM, "Big-mouth Clam", { count = 20 })
	scanAndTick(ns, env)
	for _ = 1, 20 do
		Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	end
	check(#state.usedContainerItems > ns.OPEN_REFUSAL_LIMIT + 1, "a stack keeps opening while each open is answered")
end)

test("a locked box waits for its lock whatever it is set to, then opens once picked", function()
	local ns, env = loadAddon()
	local slot = putInBag(env, 0, 1, BATTERED_JUNKBOX, "Battered Junkbox", { locked = true })
	ns:SetOpeningAction(BATTERED_JUNKBOX, ns.OPENING_OPEN)
	scanAndTick(ns, env)
	checkEqual(0, #env.__state.usedContainerItems, "a locked box set to Open is not tried")

	slot.locked = false
	fire(ns, "UNIT_SPELLCAST_SUCCEEDED", "player", "cast", ns.SPELLS.PICK_LOCK)
	Fake.advance(env, ns.PICK_LOCK_RESCAN_DELAY)
	Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	checkEqual(1, #env.__state.usedContainerItems, "the picked box opens after the lock settles")
end)

test("opening pauses below the free-slot line and says so, then resumes", function()
	local ns, env = loadAddon()
	local state = env.__state
	-- A login with full bags pauses without a line; this is the bags filling up later.
	finishWorldLoad(ns, env)
	putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
	state.freeSlotsPerBag = 0
	scanAndTick(ns, env)
	checkEqual(0, #state.usedContainerItems, "nothing opens with the bags full")
	check(ns:IsAutomatedOpeningPaused(), "opening reports itself paused")
	check(
		printedContaining(env, ns.L["MESSAGE_OPENING_PAUSED"]:format(ns.MIN_FREE_SLOTS)) ~= nil,
		"and names the free slots it waits for"
	)

	state.freeSlotsPerBag = 4
	scanAndTick(ns, env)
	check(not ns:IsAutomatedOpeningPaused(), "room again lifts the pause")
	check(printedContaining(env, ns.L["MESSAGE_OPENING_RESUMED"]) ~= nil, "and says so")
	checkEqual(1, #state.usedContainerItems, "and the clam opens")
end)

test("opening waits out the login delay, even when bag events fire first", function()
	local ns, env = loadAddon()
	putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
	fire(ns, "PLAYER_ENTERING_WORLD", true, false)
	fire(ns, "BAG_UPDATE_DELAYED")
	Fake.advance(env, 1)
	checkEqual(0, #env.__state.usedContainerItems, "nothing opens in the first seconds after login")
	Fake.advance(env, ns.WORLD_LOAD_DELAY)
	Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	checkEqual(1, #env.__state.usedContainerItems, "and the clam opens once the delay has passed")
end)

test("a pause line the loading screen held back still goes out", function()
	local ns, env = loadAddon()
	local state = env.__state
	finishWorldLoad(ns, env)
	putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
	state.freeSlotsPerBag = 0
	fire(ns, "LOADING_SCREEN_DISABLED")
	ns.ScheduleOpeningScan(true)
	local pausedLine = ns.L["MESSAGE_OPENING_PAUSED"]:format(ns.MIN_FREE_SLOTS)
	checkEqual(nil, printedContaining(env, pausedLine), "nothing prints inside the quiet window")
	Fake.advance(env, 5)
	ns.ScheduleOpeningScan(true)
	check(printedContaining(env, pausedLine) ~= nil, "the next scan after it says opening is paused")
end)

test("each hold-off keeps containers shut", function()
	local cases = {
		{
			"inside an instance with Where set to Outside Instances",
			function(ns, state)
				ns.db.profile.autoOpenWhere = "OUTSIDE_INSTANCES"
				state.inInstance = true
			end,
		},
		{
			"in a group with Group set to Solo Only",
			function(ns, state)
				ns.db.profile.autoOpenGroup = "SOLO_ONLY"
				state.inGroup = true
			end,
		},
		{
			"in combat",
			function(_, state)
				state.inCombat = true
			end,
		},
		{
			"while stealthed",
			function(_, state)
				state.stealthed = true
			end,
		},
		{
			"while Shadowmelded",
			function(ns, state)
				state.playerAuras[ns.SPELLS.SHADOWMELD] = { spellId = ns.SPELLS.SHADOWMELD }
			end,
		},
		{
			"while auras read secret, so Shadowmeld can't be ruled out",
			function(_, state)
				state.secretAuras = true
			end,
		},
		{
			"while casts read secret, so a cast can't be ruled out",
			function(_, state)
				state.secretCasts = true
			end,
		},
		{
			"while a vendor window is open",
			function(_, state)
				state.shownFrames.MerchantFrame = true
			end,
		},
		{
			"while WoW Forever's auction house is open",
			function(_, state)
				state.shownFrames.AuctionHouseFrame = true
			end,
		},
		{
			"while a loot window is open",
			function(_, state)
				state.shownFrames.LootFrame = true
			end,
		},
	}
	for _, case in ipairs(cases) do
		local ns, env = loadAddon()
		putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
		case[2](ns, env.__state)
		scanAndTick(ns, env)
		checkEqual(0, #env.__state.usedContainerItems, "nothing opens " .. case[1])
	end
end)

test("opening waits for an open loot window and resumes once it closes", function()
	local ns, env = loadAddon()
	local state = env.__state
	putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
	state.shownFrames.LootFrame = true
	scanAndTick(ns, env)
	checkEqual(0, #state.usedContainerItems, "nothing opens while the loot window is up")

	state.shownFrames.LootFrame = false
	fire(ns, "LOOT_CLOSED")
	-- A corpse's window only schedules the debounced scan; an open's own window rescans at once.
	Fake.advance(env, ns.SCAN_DEBOUNCE)
	Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	checkEqual(1, #state.usedContainerItems, "and the clam opens once it closes, without waiting on a bag event")
end)

test("a full bag hit by GogoLoot's own open pauses opening once, with the character's own voice line", function()
	local ns, env = loadAddon()
	fire(ns, "UI_ERROR_MESSAGE", env.LE_GAME_ERR_INV_FULL, "Inventory is full.")
	checkEqual(0, printCount(env, env.ERR_INV_FULL), "a full bag with no open in flight is the game's to report")
	checkEqual(0, soundsPlayed(env, "kit", ns.SOUND_KIT_IDS.BAG_FULL_BY_RACE.Human[2]), "so no voice line either")

	putInBag(env, 0, 1, CLAM, "Big-mouth Clam")
	scanAndTick(ns, env)
	fire(ns, "UI_ERROR_MESSAGE", env.LE_GAME_ERR_INV_FULL, "Inventory is full.")
	check(ns:IsAutomatedOpeningPaused(), "opening pauses")
	checkEqual(1, printCount(env, env.ERR_INV_FULL), "the player is told, in the game's own words")
	checkEqual(1, soundsPlayed(env, "kit", ns.SOUND_KIT_IDS.BAG_FULL_BY_RACE.Human[2]), "in their race's voice")

	fire(ns, "UI_ERROR_MESSAGE", env.LE_GAME_ERR_INV_FULL, "Inventory is full.")
	checkEqual(1, printCount(env, env.ERR_INV_FULL), "and not again inside the cooldown")

	fire(ns, "UI_ERROR_MESSAGE", 999, "Something else.")
	checkEqual(
		1,
		soundsPlayed(env, "kit", ns.SOUND_KIT_IDS.BAG_FULL_BY_RACE.Human[2]),
		"another error is not a full bag"
	)
end)

test("locked items lists the waiting boxes by name, one row per box", function()
	local ns, env = loadAddon()
	putInBag(env, 0, 1, IRON_LOCKBOX, "Iron Lockbox", { locked = true })
	putInBag(env, 0, 2, BATTERED_JUNKBOX, "Battered Junkbox", { locked = true })
	putInBag(env, 1, 1, BATTERED_JUNKBOX, "Battered Junkbox", { locked = true })
	putInBag(env, 1, 2, ORNATE_BRONZE_LOCKBOX, "Ornate Bronze Lockbox")
	putInBag(env, 1, 3, BLUE_SACK_OF_GEMS, "Blue Sack of Gems", { locked = true })

	local rows = ns.GetLockedBoxes()
	checkEqual(2, #rows, "two kinds of box wait; unlocked and ignored ones don't")
	checkEqual("Battered Junkbox", rows[1].name, "sorted by name")
	checkEqual(2, rows[1].count, "with a count per kind")
	checkEqual("Iron Lockbox", rows[2].name, "then the next name")
end)

test("looting a lockbox says it will open once unlocked, for a rogue by default", function()
	local ns, env = loadAddon()
	local link = itemLink(BATTERED_JUNKBOX, "Battered Junkbox")
	local expected = ns.L["MESSAGE_ITEM_WILL_AUTO_OPEN"]:format(link)

	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(link))
	checkEqual(nil, printedContaining(env, expected), "a warrior isn't told by default")

	env.__state.playerClassFile = "ROGUE"
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(link))
	check(printedContaining(env, expected) ~= nil, "a rogue is")

	ns.db.profile.autoOpen = false
	env.__state.prints = {}
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(link))
	checkEqual(nil, printedContaining(env, expected), "and nobody is promised an opening that's switched off")
end)

test("looting an ignored container says so once, and never for someone else's loot", function()
	local ns, env = loadAddon()
	local link = itemLink(WATERLOGGED_CRATE, "Waterlogged Crate")
	local expected = ns.L["MESSAGE_ITEM_IGNORED"]:format(link)

	fire(ns, "CHAT_MSG_LOOT", "Hippobob receives loot: " .. link .. ".")
	checkEqual(0, printCount(env, expected), "someone else's loot is not ours")

	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(link))
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(link))
	checkEqual(1, printCount(env, expected), "one notice inside the cooldown")
end)

test("with Automated Opening off, looting an ignored container says nothing", function()
	local ns, env = loadAddon()
	ns.db.profile.autoOpen = false
	local link = itemLink(WATERLOGGED_CRATE, "Waterlogged Crate")
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(link))
	checkEqual(
		0,
		printCount(env, ns.L["MESSAGE_ITEM_IGNORED"]:format(link)),
		"no notice speaks for a feature that's off"
	)
end)

test("the Openables List's off note tells the truth about Speedy Loot", function()
	local ns = loadAddon()
	ns.db.profile.autoOpen = false
	local function Note()
		local name = ns.BuildOpenableItemsOptions().args.featureOffNote.name
		return type(name) == "function" and name() or name
	end
	check(Note():find(ns.L["OPENABLE_ITEMS_OFF_NOTE"], 1, true) ~= nil, "Ignore still holds Speedy Loot back")
	ns.db.global.speedyLoot = false
	check(Note():find(ns.L["OPENABLE_ITEMS_ALL_OFF_NOTE"], 1, true) ~= nil, "until Speedy Loot is off too")
end)

test("each Ignore that gives a reason says it when its container is looted", function()
	local ns, env = loadAddon()
	local sackLink = itemLink(BLUE_SACK_OF_GEMS, "Blue Sack of Gems")
	local footlockerLink = itemLink(PIRATES_FOOTLOCKER, "Pirate's Footlocker")
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(sackLink))
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(footlockerLink))
	check(
		printedContaining(env, ns.L["MESSAGE_ITEM_IGNORED_RAID"]:format(sackLink)) ~= nil,
		"a raid boss container says it stays unopened to trade or sell"
	)
	check(
		printedContaining(env, ns.L["MESSAGE_ITEM_IGNORED_UNIQUE"]:format(footlockerLink)) ~= nil,
		"a container of a unique item says so"
	)
	checkEqual(0, printCount(env, ns.L["MESSAGE_ITEM_IGNORED"]:format(sackLink)), "neither gets the plain notice")

	ns.db.profile.openingIgnoreNotifications = false
	env.__state.prints = {}
	Fake.advance(env, ns.ITEM_ANNOUNCE_COOLDOWN + 1)
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(sackLink))
	checkEqual(0, printCount(env, sackLink), "and the Ignore Notifications switch silences them all")
end)

--------------------------------------------------------------------------------
-- Merged Features: Speedy Loot
--------------------------------------------------------------------------------

local function openLootWindow(env, slots)
	env.__state.lootSlots = slots
end

test("speedy loot takes everything and keeps the window from flashing", function()
	local ns, env = loadAddon()
	env.__state.itemNames[2589] = { name = "Linen Cloth", quality = 1 }
	openLootWindow(env, {
		{ link = itemLink(2589, "Linen Cloth") },
		{ slotType = 2 },
	})
	fire(ns, "LOOT_READY")
	checkEqual(2, #env.__state.lootedSlots, "both slots were looted")
	checkEqual(2, env.__state.lootedSlots[1], "bottom slot first")

	env.LootFrame:Show()
	check(not env.LootFrame:IsShown(), "the default UI's show is undone")

	fire(ns, "LOOT_CLOSED")
	env.LootFrame:Show()
	check(env.LootFrame:IsShown(), "and the next window is not hidden on this one's say-so")
end)

--[[
    WoW Forever's loot frame (LootFrameMixin) shows itself partway through
    Open() and marks itself open after. A hide from OnShow left it hidden but
    marked open, and Blizzard later re-showed it as an empty window. The hide
    has to wait for Open to return and close the frame Blizzard's own way.
]]
test("speedy loot closes Forever's loot frame after Open, so it can't come back empty", function()
	local ns, env = loadAddon(nil, function(clientEnv)
		local frame = clientEnv.LootFrame
		rawset(frame, "Open", function(self)
			self:Show()
			self.isOpen = true
		end)
		rawset(frame, "Close", function(self)
			self.isOpen = false
		end)
		rawset(frame, "StopAllAnimations", function(self)
			self.animationsStopped = true
		end)
		clientEnv.HideUIPanel = function(panel)
			panel:Hide()
		end
	end)
	-- The fake's hooksecurefunc records post-hooks rather than wrapping, so Open runs them by hand.
	local function blizzardOpen()
		env.LootFrame:Open()
		rawget(env.LootFrame, "__postHooks").Open(env.LootFrame)
	end
	env.__state.itemNames[2589] = { name = "Linen Cloth", quality = 1 }
	openLootWindow(env, { { link = itemLink(2589, "Linen Cloth") } })
	fire(ns, "LOOT_READY")

	env.LootFrame:Show()
	check(env.LootFrame:IsShown(), "the show inside Open is left alone, so Open finishes on a shown frame")

	blizzardOpen()
	check(not env.LootFrame:IsShown(), "once Open returns, the window is hidden")
	check(env.LootFrame.isOpen == false, "and marked closed, so Blizzard has nothing to re-show")
	check(env.LootFrame.animationsStopped, "with its open animation stopped")

	fire(ns, "LOOT_CLOSED")
	blizzardOpen()
	check(env.LootFrame:IsShown() and env.LootFrame.isOpen, "and the next window opens normally")
end)

--[[
    Bag space is measured per item: one that stacks onto a stack already
    carried needs no slot at all, but only as much as the stack has room for,
    counting what the same corpse has already sent.
]]
test("speedy loot stacks onto what the player carries, even with no free slot", function()
	local ns, env = loadAddon()
	env.__state.itemNames[2589] = { name = "Linen Cloth", quality = 1, stackCount = 20 }
	env.__state.freeSlotsPerBag = 0
	putInBag(env, 0, 1, 2589, "Linen Cloth", { count = 15 })
	openLootWindow(env, {
		{ link = itemLink(2589, "Linen Cloth"), quantity = 3 },
		{ link = itemLink(2589, "Linen Cloth"), quantity = 3 },
		{ slotType = 2 },
	})
	fire(ns, "LOOT_READY")
	checkEqual(2, #env.__state.lootedSlots, "the coin and the first cloth are taken")
	checkEqual(3, env.__state.lootedSlots[1], "coin first, from the bottom")
	checkEqual(2, env.__state.lootedSlots[2], "then the cloth that fits the stack's 5 of room")
	env.LootFrame:Show()
	check(env.LootFrame:IsShown(), "the second cloth, with only 2 of room left, keeps the window up")
end)

test("speedy loot puts arrows in a quiver, but never a bag in a profession bag", function()
	local ns, env = loadAddon()
	env.__state.freeSlotsByBag = { [0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 6 }
	env.__state.bagFamilies = { [4] = 1 }
	env.__state.itemNames[2512] = { name = "Rough Arrow", quality = 1, stackCount = 200, family = 1 }
	openLootWindow(env, { { link = itemLink(2512, "Rough Arrow"), quantity = 20 } })
	fire(ns, "LOOT_READY")
	checkEqual(1, #env.__state.lootedSlots, "the arrows go in the quiver")

	local bagNs, bagEnv = loadAddon()
	bagEnv.__state.freeSlotsByBag = { [0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 6 }
	bagEnv.__state.bagFamilies = { [4] = 32 }
	-- A Herb Pouch's own family names what it holds (herbs), not where it can go.
	bagEnv.__state.itemNames[22250] =
		{ name = "Herb Pouch", quality = 1, family = 32, classId = 1, itemType = "Container" }
	openLootWindow(bagEnv, { { link = itemLink(22250, "Herb Pouch") } })
	fire(bagNs, "LOOT_READY")
	checkEqual(0, #bagEnv.__state.lootedSlots, "the pouch has nowhere to go and stays in the window")
	bagEnv.LootFrame:Show()
	check(bagEnv.LootFrame:IsShown(), "which stays up")
end)

--[[
    A pickup the server refuses after the pass closed the loot: the window is
    gone, so the player is told in chat with the client's own reason, and hears
    the inventory-full line, once per cooldown and only right after such a pass.
]]
test("a pickup refused after speedy loot closed the window is reported once", function()
	local ns, env = loadAddon()
	env.__state.itemNames[2589] = { name = "Linen Cloth", quality = 1 }
	openLootWindow(env, { { link = itemLink(2589, "Linen Cloth") } })
	fire(ns, "LOOT_READY")
	env.LootFrame:Show()
	check(not env.LootFrame:IsShown(), "the pass took everything and closed the window")

	local soundsBefore = #env.__state.sounds
	fire(ns, "UI_ERROR_MESSAGE", env.LE_GAME_ERR_INV_FULL, "Inventory is full.")
	check(printedContaining(env, "Inventory is full. Some loot was left behind on the corpse."), "chat says why")
	checkEqual(soundsBefore + 1, #env.__state.sounds, "and the inventory-full line plays")

	env.__state.prints = {}
	fire(ns, "UI_ERROR_MESSAGE", env.LE_GAME_ERR_INV_FULL, "Inventory is full.")
	check(not printedContaining(env, "left behind"), "a second refusal from the same pass says nothing more")

	fire(ns, "LOOT_CLOSED")
	Fake.advance(env, ns.BAG_FULL_COOLDOWN + 1)
	fire(ns, "UI_ERROR_MESSAGE", env.LE_GAME_ERR_INV_FULL, "Inventory is full.")
	check(not printedContaining(env, "left behind"), "and long after a pass, a refusal is the game's to report")
end)

--[[
    ElvUI and Tukui put their own loot windows in place of the game's, built at
    login after GogoLoot loads. Speedy Loot hides and shows whichever is in
    use, and Automated Opening waits on it.
]]
test("speedy loot hides and shows ElvUI's and Tukui's loot windows", function()
	for _, frameName in ipairs({ "ElvLootFrame", "TukuiLootFrame" }) do
		local ns, env = loadAddon()
		local window = env.CreateFrame("Button", frameName)
		rawset(env, frameName, window)
		env.__state.itemNames[2589] = { name = "Linen Cloth", quality = 1 }
		openLootWindow(env, { { link = itemLink(2589, "Linen Cloth") } })
		fire(ns, "LOOT_READY")
		window:Show()
		check(not window:IsShown(), frameName .. ": its show is undone once the pass took everything")

		fire(ns, "LOOT_CLOSED")
		Fake.advance(env, 1)
		-- An item the client hasn't loaded may be Bind on Pickup, so it keeps the window up.
		openLootWindow(env, { { link = itemLink(9999, "Unknown Item") } })
		fire(ns, "LOOT_READY")
		check(window:IsShown(), frameName .. ": it is the window shown for loot left behind")
		check(not env.LootFrame:IsShown(), frameName .. ": and the game's own stays shut")
		check(ns.IsLootWindowShown(), frameName .. ": Automated Opening sees it open")
	end
end)

test("speedy loot leaves an item still being rolled for alone", function()
	local ns, env = loadAddon()
	openLootWindow(env, {
		{ link = itemLink(2589, "Linen Cloth") },
		{ link = itemLink(1001, "Rolled Sword"), locked = true },
	})
	fire(ns, "LOOT_READY")
	checkEqual(1, #env.__state.lootedSlots, "only the unlocked slot was taken")
	checkEqual(1, env.__state.lootedSlots[1], "the cloth's slot")
end)

test("speedy loot leaves an ignored container in the window and says so", function()
	local ns, env = loadAddon()
	local sackLink = itemLink(BLUE_SACK_OF_GEMS, "Blue Sack of Gems")
	openLootWindow(env, {
		{ link = sackLink },
		{ link = itemLink(2589, "Linen Cloth") },
	})
	fire(ns, "LOOT_READY")
	checkEqual(1, #env.__state.lootedSlots, "only the cloth was taken")
	checkEqual(2, env.__state.lootedSlots[1], "the cloth's slot")
	check(env.LootFrame:IsShown(), "the window stays up for the container")
	check(
		printedContaining(env, ns.L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"]:format(sackLink)) ~= nil,
		"and the player is told"
	)
end)

test("speedy loot still says so while Automated Opening is off", function()
	local ns, env = loadAddon()
	ns.db.profile.autoOpen = false
	ns.db.profile.openingIgnoreNotifications = true
	local sackLink = itemLink(BLUE_SACK_OF_GEMS, "Blue Sack of Gems")
	openLootWindow(env, {
		{ link = sackLink },
		{ link = itemLink(2589, "Linen Cloth") },
	})
	fire(ns, "LOOT_READY")
	checkEqual(1, #env.__state.lootedSlots, "the container is still left in the window")
	check(
		printedContaining(env, ns.L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"]:format(sackLink)) ~= nil,
		"and the player is told, since the notice's toggle never hides"
	)
end)

test("speedy loot leaves an ignored container quietly while Ignore notices are off", function()
	local ns, env = loadAddon()
	ns.db.profile.openingIgnoreNotifications = false
	local sackLink = itemLink(BLUE_SACK_OF_GEMS, "Blue Sack of Gems")
	openLootWindow(env, {
		{ link = sackLink },
		{ link = itemLink(2589, "Linen Cloth") },
	})
	fire(ns, "LOOT_READY")
	checkEqual(1, #env.__state.lootedSlots, "the container is still left in the window")
	check(
		printedContaining(env, ns.L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"]:format(sackLink)) == nil,
		"and nothing is printed"
	)
end)

test("speedy loot keeps the window up when the bags are nearly full", function()
	local ns, env = loadAddon()
	env.__state.freeSlotsPerBag = 1
	openLootWindow(env, {
		{ link = itemLink(2589, "Linen Cloth") },
		{ link = itemLink(2592, "Wool Cloth") },
	})
	fire(ns, "LOOT_READY")
	checkEqual(2, #env.__state.lootedSlots, "it still takes what fits")
	env.LootFrame:Show()
	check(env.LootFrame:IsShown(), "but leaves the window up in case something bounces")
end)

test("speedy loot keeps the window up for a Bind on Pickup item, so its bind question can be answered", function()
	local ns, env = loadAddon()
	env.__state.itemNames[900003] = { name = "Bound Ring", quality = 3, bindType = ns.BIND_ON_PICKUP }
	openLootWindow(env, {
		{ link = itemLink(900003, "Bound Ring", "0070dd") },
		{ link = itemLink(2589, "Linen Cloth") },
	})
	fire(ns, "LOOT_READY")
	checkEqual(2, #env.__state.lootedSlots, "the Bind on Pickup item is still looted, so the client asks")
	env.LootFrame:Show()
	check(env.LootFrame:IsShown(), "and the window stays up while it does")
end)

test("speedy loot keeps the window up for an item the client hasn't loaded yet", function()
	local ns, env = loadAddon()
	openLootWindow(env, {
		{ link = itemLink(900004, "Unloaded Ring", "0070dd") },
	})
	fire(ns, "LOOT_READY")
	checkEqual(1, #env.__state.lootedSlots, "the item is still looted")
	env.LootFrame:Show()
	check(env.LootFrame:IsShown(), "and the window stays up, since it may be Bind on Pickup")
end)

test("speedy loot stands down for the master looter", function()
	local ns, env = loadAddon()
	env.__state.lootMethod = 2
	env.__state.masterLooterPartyIndex = 0
	openLootWindow(env, { { link = itemLink(2589, "Linen Cloth") } })
	fire(ns, "LOOT_READY")
	checkEqual(0, #env.__state.lootedSlots, "nothing was looted")
end)

test("the loot sounds read the window before speedy loot empties it", function()
	local ns, env = loadAddon()
	local order = {}
	local stamp, pickPocket = ns.StampWorldLoot, ns.PlayPickPocketSound
	ns.StampWorldLoot = function()
		table.insert(order, "stamp")
		stamp()
	end
	ns.PlayPickPocketSound = function()
		table.insert(order, "pick pocket")
		pickPocket()
	end
	env.LootSlot = function()
		table.insert(order, "loot")
	end
	openLootWindow(env, { { link = itemLink(2589, "Linen Cloth") } })
	fire(ns, "LOOT_READY")
	checkEqual("stamp", order[1], "the world-loot stamp goes first")
	checkEqual("pick pocket", order[2], "then the Pick Pocket sound")
	checkEqual("loot", order[3], "and only then is anything taken")
end)

--------------------------------------------------------------------------------
-- Merged Features: Loot Sounds
--------------------------------------------------------------------------------

test("the loot chime plays for corpse loot at the chosen quality, not for disenchants", function()
	local ns, env = loadAddon()
	local green = itemLink(2589, "Green Thing", "1eff00")
	env.__state.lootSlots = { { link = green, source = "Creature-0-1-2-3-4-5" } }
	fire(ns, "LOOT_OPENED")
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(green))
	checkEqual(1, soundsPlayed(env, "file", ns.LOOT_SOUND_FILE), "an uncommon from a corpse chimes")

	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(itemLink(2590, "White Thing")))
	checkEqual(1, soundsPlayed(env, "file", ns.LOOT_SOUND_FILE), "a common one doesn't")

	env.__state.lootSlots = { { link = green, source = "Item-0-1-2-3-4-5" } }
	fire(ns, "LOOT_OPENED")
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(green))
	checkEqual(1, soundsPlayed(env, "file", ns.LOOT_SOUND_FILE), "and item-made loot stays silent")
end)

test("the loot chime waits for a corpse item taken while its window stays open", function()
	local ns, env = loadAddon()
	local green = itemLink(2589, "Green Thing", "1eff00")
	env.__state.lootSlots = { { link = green, source = "Creature-0-1-2-3-4-5" } }
	fire(ns, "LOOT_OPENED")
	Fake.advance(env, 5)
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(green))
	checkEqual(1, soundsPlayed(env, "file", ns.LOOT_SOUND_FILE), "a Bind on Pickup confirmed seconds later chimes")

	fire(ns, "LOOT_CLOSED")
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(green))
	checkEqual(2, soundsPlayed(env, "file", ns.LOOT_SOUND_FILE), "a line landing just after the close still chimes")

	Fake.advance(env, ns.LOOT_SOUND_WINDOW + 1)
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(green))
	checkEqual(2, soundsPlayed(env, "file", ns.LOOT_SOUND_FILE), "a roll win long after the close stays silent")
end)

test("the pick pocket sound plays once for pockets that held something", function()
	local ns, env = loadAddon()
	fire(ns, "UNIT_SPELLCAST_SUCCEEDED", "player", "cast", ns.SPELLS.PICK_POCKET)
	env.__state.lootSlots = { { slotType = 2 } }
	fire(ns, "LOOT_READY")
	fire(ns, "LOOT_OPENED")
	checkEqual(1, soundsPlayed(env, "kit", ns.SOUND_KIT_IDS.PICK_POCKET), "one cast, one sound")

	fire(ns, "UNIT_SPELLCAST_SUCCEEDED", "player", "cast", ns.SPELLS.PICK_POCKET)
	env.__state.lootSlots = {}
	fire(ns, "LOOT_OPENED")
	checkEqual(1, soundsPlayed(env, "kit", ns.SOUND_KIT_IDS.PICK_POCKET), "empty pockets make no sound")
end)

--[[
    Enable Loot Sounds, the panel's master switch, silences both sounds while it
    is off, whatever their own toggles say.
]]
test("Enable Loot Sounds silences the chime and the Pick Pocket sound", function()
	local ns, env = loadAddon()
	local green = itemLink(2589, "Green Thing", "1eff00")
	ns.db.profile.lootSoundsEnabled = false
	env.__state.lootSlots = { { link = green, source = "Creature-0-1-2-3-4-5" } }
	fire(ns, "LOOT_OPENED")
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(green))
	checkEqual(0, soundsPlayed(env, "file", ns.LOOT_SOUND_FILE), "an uncommon from a corpse stays silent")

	fire(ns, "UNIT_SPELLCAST_SUCCEEDED", "player", "cast", ns.SPELLS.PICK_POCKET)
	env.__state.lootSlots = { { slotType = 2 } }
	fire(ns, "LOOT_READY")
	fire(ns, "LOOT_OPENED")
	checkEqual(
		0,
		soundsPlayed(env, "kit", ns.SOUND_KIT_IDS.PICK_POCKET),
		"and so does a Pick Pocket that took something"
	)

	ns.db.profile.lootSoundsEnabled = true
	env.__state.lootSlots = { { link = green, source = "Creature-0-1-2-3-4-5" } }
	fire(ns, "LOOT_OPENED")
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(green))
	checkEqual(1, soundsPlayed(env, "file", ns.LOOT_SOUND_FILE), "switched back on, the chime plays again")
end)

test("a cast that reads secret is never compared, so it neither arms a sound nor rescans", function()
	local ns, env = loadAddon()
	env.__state.secretCasts = true
	fire(ns, "UNIT_SPELLCAST_SUCCEEDED", "player", "cast", ns.SPELLS.PICK_POCKET)
	env.__state.lootSlots = { { slotType = 2 } }
	fire(ns, "LOOT_OPENED")
	checkEqual(0, soundsPlayed(env, "kit", ns.SOUND_KIT_IDS.PICK_POCKET), "the pick pocket sound isn't armed")

	local slot = putInBag(env, 0, 1, BATTERED_JUNKBOX, "Battered Junkbox", { locked = true })
	ns:SetOpeningAction(BATTERED_JUNKBOX, ns.OPENING_OPEN)
	slot.locked = false
	fire(ns, "UNIT_SPELLCAST_SUCCEEDED", "player", "cast", ns.SPELLS.PICK_LOCK)
	Fake.advance(env, ns.PICK_LOCK_RESCAN_DELAY)
	Fake.advance(env, ns.OPEN_TICK_INTERVAL)
	checkEqual(0, #env.__state.usedContainerItems, "and nothing opens while casts read secret")
end)

--------------------------------------------------------------------------------
-- Loot Notifications: the master switch
--------------------------------------------------------------------------------

--[[
    Enable Announcements is a real master switch: with it off, nothing GogoLoot
    would post reaches chat, whoever asks, the hand-outs with no toggle of their
    own included. The sounds are the player's alone and answer to their own
    toggles on the Loot Sounds panel, so they still play.
]]
test("with announcements off, nothing is posted, and the sounds still play", function()
	local ns, env = loadAddon()
	local state = env.__state
	ns.db.profile.lootNotifications = false
	state.chat = {}

	ns:Announce("PARTY", nil, "MESSAGE_GAVE", "[Thing]", "Hippobob")
	ns:AnnounceParts("RAID", nil, "MESSAGE_GAVE", { "[Thing]" }, function(itemList)
		return itemList, "Hippobob"
	end)
	checkEqual(0, chatCount(env), "no announcement goes out, whoever calls")

	state.unitNames.npc = "Hippobob"
	state.tradePlayerItems[1] = { link = "|Hitem:2001|h[Given Item]|h", count = 1 }
	local completeId = registerGameMessage(env, "ERR_TRADE_COMPLETE")
	fire(ns, "TRADE_SHOW")
	fire(ns, "TRADE_ACCEPT_UPDATE", 1, 1)
	fire(ns, "UI_INFO_MESSAGE", completeId)
	checkEqual(0, chatCount(env), "not even a finished trade")

	local green = itemLink(2589, "Green Thing", "1eff00")
	state.lootSlots = { { link = green, source = "Creature-0-1-2-3-4-5" } }
	fire(ns, "LOOT_OPENED")
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(green))
	checkEqual(1, soundsPlayed(env, "file", ns.LOOT_SOUND_FILE), "the loot chime still plays")
	fire(ns, "UNIT_SPELLCAST_SUCCEEDED", "player", "cast", ns.SPELLS.PICK_POCKET)
	state.lootSlots = { { slotType = 2 } }
	fire(ns, "LOOT_READY")
	fire(ns, "LOOT_OPENED")
	checkEqual(1, soundsPlayed(env, "kit", ns.SOUND_KIT_IDS.PICK_POCKET), "and so does Pick Pocket's")

	ns.db.profile.lootNotifications = true
	ns:Announce("PARTY", nil, "MESSAGE_GAVE", "[Thing]", "Hippobob")
	checkEqual(1, chatCount(env), "switched back on, announcements go out again")
end)

--[[
    What would offer an announcement the switch has silenced leaves with it: the
    trade window's Announce checkbox, and the destination toggle in the master
    looter pop-up.
]]
test("the trade window checkbox and the pop-up's toggle leave with announcements", function()
	local ns, env = loadAddon()
	local toggle = ns.BuildAnnouncementOptions().args.lootNotifications
	local popupArgs = ns.BuildMasterLooterPopupOptions().args
	fire(ns, "TRADE_SHOW")
	local checkbox
	for _, frame in ipairs(env.__state.createdFrames) do
		if rawget(frame, "frameName") == "GogoLootTradeAnnounceCheckbox" then
			checkbox = frame
		end
	end
	check(checkbox ~= nil and checkbox:IsShown(), "the trade window carries the checkbox")
	check(not evaluate(popupArgs.announceDestinations.hidden), "and the pop-up its destination toggle")

	toggle.set(nil, false)
	check(checkbox and not checkbox:IsShown(), "switching notifications off takes the checkbox away")
	check(evaluate(popupArgs.announceDestinations.hidden), "and the pop-up's toggle")

	toggle.set(nil, true)
	check(checkbox and checkbox:IsShown(), "switching them back on returns the checkbox")
	check(not evaluate(popupArgs.announceDestinations.hidden), "and the toggle")

	fire(ns, "TRADE_CLOSED")
	check(checkbox and not checkbox:IsShown(), "closing the trade takes the checkbox with it")
	check(checkbox and checkbox.parent == env.UIParent, "which sits on UIParent, never on the trade window")
end)

--------------------------------------------------------------------------------
-- Merged Features: Loot Toasts
--------------------------------------------------------------------------------

local function visibleToastTexts(env)
	local texts = {}
	-- rawget: a fake frame answers every other key with a no-op method.
	for _, frame in ipairs(env.__state.createdFrames) do
		local text = rawget(frame, "text")
		if rawget(frame, "shown") and rawget(frame, "fade") and text and text.text then
			texts[#texts + 1] = text.text
		end
	end
	return texts
end

local function toastShowing(env, needle)
	for _, text in ipairs(visibleToastTexts(env)) do
		if text:find(needle, 1, true) then
			return true
		end
	end
	return false
end

--[[
    An item the toast filters can read: a name, a quality and the class the
    client files it under. The fake answers GetItemInfoInstant only for an item
    given a type, as the real client does for every item it has.
]]
local function knownItem(env, identifier, name, quality, classId, fields)
	local entry = { name = name, quality = quality or 1, classId = classId or 7, itemType = "Type", bindType = 2 }
	for key, value in pairs(fields or {}) do
		entry[key] = value
	end
	env.__state.itemNames[identifier] = entry
end

test("the Mine boxes decide which of the player's own loot gets a toast", function()
	local ns, env = loadAddon()
	local profile = ns.db.profile
	profile.lootToasts = true
	profile.lootToastsIntroSeen = true
	knownItem(env, 2601, "Green Helm", 2, ns.ITEM_CLASS_ARMOR)
	knownItem(env, 2602, "Blue Helm", 3, ns.ITEM_CLASS_ARMOR)
	knownItem(env, 2603, "Linen Cloth", 1, ns.ITEM_CLASS_TRADE_GOODS)
	knownItem(env, 2604, "Soulbound Blade", 1, ns.ITEM_CLASS_WEAPON, { bindType = 1 })
	knownItem(env, CLAM, "Big-mouth Clam", 1, ns.ITEM_CLASS_MISCELLANEOUS)
	-- Whether this pickup put up a toast of its own, whatever earlier toasts are still showing.
	local function iLoot(identifier, name, colorHex)
		local before = #visibleToastTexts(env)
		fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(itemLink(identifier, name, colorHex)))
		return #visibleToastTexts(env) > before
	end

	check(iLoot(2603, "Linen Cloth"), "out of the box every pickup shows")
	check(not toastShowing(env, "[Linen Cloth]"), "the link's brackets are dropped")

	profile.lootToastMineQuality.ARMOR = 3
	check(not iLoot(2601, "Green Helm", "1eff00"), "armor below its quality stays quiet")
	check(iLoot(2602, "Blue Helm", "0070dd"), "armor at it shows")

	profile.lootToastMine.TRADE_GOODS = false
	check(not iLoot(2603, "Linen Cloth"), "a cleared type shows nothing")

	profile.lootToastMine.WEAPON = false
	check(iLoot(2604, "Soulbound Blade"), "Bind on Pickup reaches across a cleared type")
	profile.lootToastMine.MISCELLANEOUS = false
	check(iLoot(CLAM, "Big-mouth Clam"), "and so do Openables")
	profile.lootToastMine.OPENABLES = false
	profile.lootToastMine.BIND_ON_PICKUP = false
	check(not iLoot(2604, "Soulbound Blade") and not iLoot(CLAM, "Big-mouth Clam"), "until they are cleared too")
end)

test("a stack of loot shows its count, and coin gets its own toast", function()
	local ns, env = loadAddon()
	ns.db.profile.lootToasts = true
	ns.db.profile.lootToastsIntroSeen = true
	knownItem(env, 2589, "Linen Cloth")
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF_MULTIPLE:format(itemLink(2589, "Linen Cloth"), 3))
	check(toastShowing(env, "Linen Cloth|h|r x3"), "the count follows the name")
	fire(ns, "CHAT_MSG_MONEY", "You loot 1 Gold, 2 Silver, 3 Copper")
	check(toastShowing(env, "02"), "coin shows, padded below its largest unit")

	local quietNs, quietEnv = loadAddon()
	quietNs.db.profile.lootToasts = true
	quietNs.db.profile.lootToastsIntroSeen = true
	quietNs.db.profile.lootToastMine.MONEY = false
	fire(quietNs, "CHAT_MSG_MONEY", "You loot 1 Gold, 2 Silver, 3 Copper")
	checkEqual(0, #visibleToastTexts(quietEnv), "with Money cleared, coin shows nothing")
end)

--[[
    An item toast shows the item's tooltip on hover and holds its fade while it
    does; a coin toast has no item behind it, so it never takes the pointer.
]]
test("hovering an item toast shows the item's tooltip and holds its fade", function()
	local ns, env = loadAddon()
	ns.db.profile.lootToasts = true
	ns.db.profile.lootToastsIntroSeen = true
	knownItem(env, 2589, "Linen Cloth")
	env.__state.hyperlinkTooltipLines[2589] = { "Linen Cloth", "Trade Goods" }
	local link = itemLink(2589, "Linen Cloth")
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(link))
	fire(ns, "CHAT_MSG_MONEY", "You loot 3 Copper")

	local itemToast, coinToast
	for _, frame in ipairs(env.__state.createdFrames) do
		local text = rawget(frame, "text")
		if rawget(frame, "shown") and rawget(frame, "fade") and text and text.text then
			if text.text:find("Linen Cloth", 1, true) then
				itemToast = frame
			else
				coinToast = frame
			end
		end
	end
	check(itemToast ~= nil and coinToast ~= nil, "both toasts are up")
	checkEqual(false, ns.db.profile.lootToastTooltips, "tooltips ship off")
	checkEqual(false, rawget(itemToast.hover, "mouseMotionEnabled"), "so even the item row lets the pointer through")
	itemToast.hover.scripts.OnEnter(itemToast.hover)
	check(not env.GameTooltip:IsOwned(itemToast.hover), "and shows no tooltip")

	ns.BuildLootToastOptions().args.tooltipsToggle.set(nil, true)
	checkEqual(true, ns.db.profile.lootToastTooltips, "the panel's checkbox turns them on")
	checkEqual(true, rawget(itemToast.hover, "mouseMotionEnabled"), "the item row already up takes the pointer")
	checkEqual(false, rawget(coinToast.hover, "mouseMotionEnabled"), "the coin row doesn't")

	local paused, resumed = false, false
	itemToast.fade.Pause = function()
		paused = true
	end
	itemToast.fade.Play = function()
		resumed = true
	end
	itemToast.hover.scripts.OnEnter(itemToast.hover)
	check(env.GameTooltip:IsOwned(itemToast.hover), "hovering opens the tooltip on the row")
	checkEqual("Linen Cloth", env.GameTooltip.lines[1], "showing the looted item")
	check(paused, "and holds the fade")
	itemToast.hover.scripts.OnLeave(itemToast.hover)
	check(not env.GameTooltip:IsOwned(itemToast.hover), "leaving closes it")
	check(resumed, "and lets the fade run on")

	itemToast.hover.scripts.OnEnter(itemToast.hover)
	ns.ReleaseLootToast(itemToast)
	check(not env.GameTooltip:IsOwned(itemToast.hover), "a row that goes while hovered takes its tooltip with it")
	checkEqual(false, rawget(itemToast.hover, "mouseMotionEnabled"), "and stops taking the pointer in the pool")

	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(link))
	local again
	for _, frame in ipairs(env.__state.createdFrames) do
		local text = rawget(frame, "text")
		if
			rawget(frame, "shown")
			and rawget(frame, "fade")
			and text
			and text.text
			and text.text:find("Linen Cloth", 1, true)
		then
			again = frame
		end
	end
	again.hover.scripts.OnEnter(again.hover)
	ns.BuildLootToastOptions().args.tooltipsToggle.set(nil, false)
	check(not env.GameTooltip:IsOwned(again.hover), "turning them off closes a tooltip being read")
	checkEqual(false, rawget(again.hover, "mouseMotionEnabled"), "and the row lets the pointer through again")
end)

--[[
    A burst of loot enters one row at a time, each new row starting every row
    already up over on its time, and an Epic or better row flashes.
]]
test("toasts enter one at a time and keep the stack up while loot arrives", function()
	local ns, env = loadAddon()
	ns.LOOT_TOAST_ENTRY_INTERVAL = 0.15
	ns.db.profile.lootToasts = true
	ns.db.profile.lootToastsIntroSeen = true
	knownItem(env, 2589, "Linen Cloth", 1, ns.ITEM_CLASS_TRADE_GOODS)
	knownItem(env, 2592, "Wool Cloth", 1, ns.ITEM_CLASS_TRADE_GOODS)
	knownItem(env, 2601, "Purple Helm", 4, ns.ITEM_CLASS_ARMOR)
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(itemLink(2589, "Linen Cloth")))
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(itemLink(2592, "Wool Cloth")))
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(itemLink(2601, "Purple Helm", "a335ee")))
	checkEqual(1, #visibleToastTexts(env), "the first row enters at once")

	local firstToast
	for _, frame in ipairs(env.__state.createdFrames) do
		local text = rawget(frame, "text")
		if rawget(frame, "shown") and text and text.text and text.text:find("Linen Cloth", 1, true) then
			firstToast = frame
		end
	end
	local restarted = 0
	firstToast.fade.Play = function()
		restarted = restarted + 1
	end
	check(rawget(firstToast, "flashColor") == nil, "a Common row doesn't flash")

	Fake.advance(env, 0.15)
	checkEqual(2, #visibleToastTexts(env), "the second follows one interval later")
	checkEqual(1, restarted, "and starts the first row's time over")
	Fake.advance(env, 0.15)
	checkEqual(3, #visibleToastTexts(env), "then the third")

	local epicToast
	for _, frame in ipairs(env.__state.createdFrames) do
		local text = rawget(frame, "text")
		if rawget(frame, "shown") and text and text.text and text.text:find("Purple Helm", 1, true) then
			epicToast = frame
		end
	end
	check(epicToast and rawget(epicToast, "flashColor") ~= nil, "the Epic row flashes")
end)

test("a row under the pointer keeps its paused fade when new loot arrives", function()
	local ns, env = loadAddon()
	ns.db.profile.lootToasts = true
	ns.db.profile.lootToastTooltips = true
	ns.db.profile.lootToastsIntroSeen = true
	knownItem(env, 2589, "Linen Cloth", 1, ns.ITEM_CLASS_TRADE_GOODS)
	knownItem(env, 2592, "Wool Cloth", 1, ns.ITEM_CLASS_TRADE_GOODS)
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(itemLink(2589, "Linen Cloth")))
	local hovered
	for _, frame in ipairs(env.__state.createdFrames) do
		local text = rawget(frame, "text")
		if rawget(frame, "shown") and text and text.text and text.text:find("Linen Cloth", 1, true) then
			hovered = frame
		end
	end
	hovered.hover.scripts.OnEnter(hovered.hover)
	local restarted = 0
	hovered.fade.Play = function()
		restarted = restarted + 1
	end
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(itemLink(2592, "Wool Cloth")))
	checkEqual(0, restarted, "its fade stays paused for the tooltip")
end)

--[[
    Currency (MoP Classic's Justice and Valor Points) gets a toast from the
    game's currency line, answering to the Currency row's Mine box.
]]
test("currency gets its own toast, with its count", function()
	local ns, env = loadAddon()
	ns.db.profile.lootToasts = true
	ns.db.profile.lootToastsIntroSeen = true
	env.__state.currencies = { [395] = { iconFileID = 463446, quality = 3 } }
	local link = "|cff0070dd|Hcurrency:395:30|h[Justice Points]|h|r"
	fire(ns, "CHAT_MSG_CURRENCY", env.CURRENCY_GAINED_MULTIPLE:format(link, 30))
	check(toastShowing(env, "Justice Points"), "the currency shows")
	check(toastShowing(env, "x30"), "with how many came")
	check(not toastShowing(env, "[Justice Points]"), "without the link's brackets")

	local parsedLink, count = ns.ParseCurrencyMessage(env.CURRENCY_GAINED:format(link))
	checkEqual(link, parsedLink, "a single currency line reads its link")
	checkEqual(1, count, "and counts one")
	local _, bonusCount = ns.ParseCurrencyMessage(env.CURRENCY_GAINED_MULTIPLE_BONUS:format(link, 12))
	checkEqual(12, bonusCount, "the bonus form keeps its count")

	ns.db.profile.lootToastMine.CURRENCY = false
	local before = #visibleToastTexts(env)
	fire(ns, "CHAT_MSG_CURRENCY", env.CURRENCY_GAINED:format(link))
	checkEqual(before, #visibleToastTexts(env), "with Currency cleared, nothing more shows")
end)

--[[
    At the default font size every row measure is a step of the 2, 4, 8, 16,
    32 scale: a 32 row the framed icon fills, 8 to the text, 8 between rows,
    so 40 from one row to the next.
]]
test("toast rows sit on the 2, 4, 8, 16, 32 grid at the default font size", function()
	local ns, env = loadAddon()
	ns.db.profile.lootToasts = true
	ns.db.profile.lootToastsIntroSeen = true
	checkEqual(16, ns.db.profile.lootToastFontSize, "the default font size is the grid's")
	knownItem(env, 2589, "Linen Cloth", 1, ns.ITEM_CLASS_TRADE_GOODS)
	knownItem(env, 2592, "Wool Cloth", 1, ns.ITEM_CLASS_TRADE_GOODS)
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(itemLink(2589, "Linen Cloth")))
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(itemLink(2592, "Wool Cloth")))
	local older, newer
	for _, frame in ipairs(env.__state.createdFrames) do
		local text = rawget(frame, "text")
		if rawget(frame, "shown") and text and text.text then
			if text.text:find("Linen Cloth", 1, true) then
				older = frame
			elseif text.text:find("Wool Cloth", 1, true) then
				newer = frame
			end
		end
	end
	checkEqual(32, rawget(newer, "height"), "a row is 32 tall")
	checkEqual(32 + 8 + 16 * 32, rawget(newer, "width"), "the framed icon, the 8 gap, then room for the name")
	checkEqual(0, newer.lastPoint[5], "the newest row sits at the anchor")
	checkEqual(40, math.abs(older.lastPoint[5]), "the one before it 40 away: the 32 row and 8 between")
end)

test("the toast cap retires the oldest, and unlimited never retires any", function()
	local ns, env = loadAddon()
	ns.db.profile.lootToasts = true
	ns.db.profile.lootToastsIntroSeen = true
	ns.db.profile.lootToastMaxVisible = 2
	for index = 1, 3 do
		knownItem(env, 3000 + index, "Thing " .. index)
		fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(itemLink(3000 + index, "Thing " .. index)))
	end
	checkEqual(2, #visibleToastTexts(env), "two toasts on screen")
	check(not toastShowing(env, "Thing 1"), "the oldest one left")

	local unlimitedNs, unlimitedEnv = loadAddon()
	unlimitedNs.db.profile.lootToasts = true
	unlimitedNs.db.profile.lootToastsIntroSeen = true
	unlimitedNs.db.profile.lootToastMaxVisible = unlimitedNs.LOOT_TOAST_UNLIMITED
	for index = 1, 3 do
		knownItem(unlimitedEnv, 3000 + index, "Thing " .. index)
		fire(
			unlimitedNs,
			"CHAT_MSG_LOOT",
			unlimitedEnv.LOOT_ITEM_SELF:format(itemLink(3000 + index, "Thing " .. index))
		)
	end
	checkEqual(3, #visibleToastTexts(unlimitedEnv), "Unlimited keeps them all")
end)

--[[
    The Group boxes decide the rest of the group's loot, each toast naming its
    looter in class color. Out of the box that is their quest items and their
    Uncommon-or-better weapons and armor, and none of their cloth.
]]
test("the Group boxes add the group's loot with its looter", function()
	local ns, env = loadAddon()
	local profile = ns.db.profile
	profile.lootToasts = true
	profile.lootToastsIntroSeen = true
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.unitNames.party1 = "Aero"
	state.playerClassFile = "ROGUE"
	knownItem(env, 2589, "Linen Cloth", 1, ns.ITEM_CLASS_TRADE_GOODS)
	knownItem(env, 2590, "Wool Cloth", 1, ns.ITEM_CLASS_TRADE_GOODS)
	knownItem(env, 2594, "Gnoll Paw", 1, ns.ITEM_CLASS_QUEST)
	knownItem(env, 2595, "Green Axe", 2, ns.ITEM_CLASS_WEAPON)
	knownItem(env, 2596, "White Axe", 1, ns.ITEM_CLASS_WEAPON)
	knownItem(env, 2592, "Runecloth", 1, ns.ITEM_CLASS_TRADE_GOODS)
	local function theyLoot(name, identifier, colorHex, looter)
		fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM:format(looter or "Aero", itemLink(identifier, name, colorHex)))
		return toastShowing(env, name .. "|h|r (")
	end

	check(not theyLoot("Linen Cloth", 2589), "their cloth stays quiet")
	check(theyLoot("Gnoll Paw", 2594), "their quest item shows")
	check(not theyLoot("White Axe", 2596), "a white weapon stays under Uncommon+")
	check(theyLoot("Green Axe", 2595, "1eff00"), "a green one shows")
	check(toastShowing(env, "Green Axe|h|r (|cffFFF468Aero|r)"), "naming them, in class color")

	profile.lootToastGroup.TRADE_GOODS = true
	profile.lootToastGroupQuality.TRADE_GOODS = 0
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_MULTIPLE:format("Aero", itemLink(2590, "Wool Cloth"), 4))
	check(toastShowing(env, "Wool Cloth|h|r x4 ("), "a ticked type shows, a stack's count before the name")
	check(theyLoot("Linen Cloth", 2589, nil, "Stranger"), "a name the roster doesn't hold")
	check(toastShowing(env, "(" .. ns.GetColor("HELP") .. "Stranger|r)"), "reads silver")

	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(itemLink(2592, "Runecloth")))
	check(toastShowing(env, "Runecloth|h|r"), "the player's own loot still shows")
	check(not toastShowing(env, "Runecloth|h|r ("), "with no name after it")
end)

--[[
    Show Bag Count adds how many the player now carries, read live: the bags
    may take the item before the loot line prints or after, so the count is
    read as the toast goes up and again whenever the bags settle.
]]
test("Show Bag Count adds what the player now carries, landing once the bags settle", function()
	local ns, env = loadAddon()
	local profile = ns.db.profile
	profile.lootToasts = true
	profile.lootToastsIntroSeen = true
	knownItem(env, 2589, "Linen Cloth")
	knownItem(env, 2590, "Wool Cloth")
	local cloth = itemLink(2589, "Linen Cloth")
	local stack = putInBag(env, 0, 1, 2589, "Linen Cloth", { count = 24 })

	checkEqual(false, profile.lootToastBagCount, "it ships off")
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF_MULTIPLE:format(cloth, 3))
	check(toastShowing(env, "Linen Cloth|h|r x3"), "so the toast shows")
	check(not toastShowing(env, "x3 ("), "reading as before")

	profile.lootToastBagCount = true
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF_MULTIPLE:format(cloth, 3))
	check(toastShowing(env, "Linen Cloth|h|r x3 (24)"), "on, it reads the bags as the toast goes up")
	stack.count = 27
	fire(ns, "BAG_UPDATE_DELAYED")
	check(toastShowing(env, "Linen Cloth|h|r x3 (27)"), "and lands on the true count once they settle")

	putInBag(env, 0, 2, 2590, "Wool Cloth", { count = 3 })
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF_MULTIPLE:format(itemLink(2590, "Wool Cloth"), 3))
	check(toastShowing(env, "Wool Cloth|h|r x3"), "a first stack shows")
	check(not toastShowing(env, "Wool Cloth|h|r x3 ("), "with no count that only repeats its own")

	profile.lootToastGroup.TRADE_GOODS = true
	profile.lootToastGroupQuality.TRADE_GOODS = 0
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM:format("Aero", itemLink(2589, "Linen Cloth")))
	fire(ns, "BAG_UPDATE_DELAYED")
	check(toastShowing(env, "Aero"), "the group member's toast is up")
	for _, text in ipairs(visibleToastTexts(env)) do
		if text:find("Aero", 1, true) then
			checkEqual(nil, text:find("27", 1, true), "a group member's loot carries no count: their bags aren't ours")
		end
	end
end)

--[[
    An item won on a roll says how it was won, after the looter or straight
    after the item when it was the player's: from the roll lines and the won
    line that follow a roll, or, with the game's roll spam turned down, from the
    won line alone. Show Winning Roll turns it off per side.
]]
test("a won item's toast carries the winning roll", function()
	local ns, env = loadAddon()
	local profile = ns.db.profile
	profile.lootToasts = true
	profile.lootToastsIntroSeen = true
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 2
	state.unitNames.party1 = "Aero"
	knownItem(env, 15259, "Hefty Battlehammer", 2, ns.ITEM_CLASS_WEAPON)
	local hammer = itemLink(15259, "Hefty Battlehammer", "1eff00")
	local function rollRound(winner, kind, roll)
		fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_ROLLED_GREED:format(11, 12, hammer, "Tester"))
		fire(ns, "CHAT_MSG_LOOT", env["LOOT_ROLL_ROLLED_" .. kind]:format(11, roll, hammer, winner))
		if winner == "Tester" then
			fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_YOU_WON:format(11, hammer))
			fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(hammer))
		else
			fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_WON:format(11, winner, hammer))
			fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM:format(winner, hammer))
		end
	end

	rollRound("Aero", "NEED", 87)
	check(toastShowing(env, "Aero|r, " .. ns.GetColor("HELP") .. "Need 87|r)"), "a group member's win names the roll")
	rollRound("Tester", "GREED", 54)
	check(
		toastShowing(env, "Hefty Battlehammer|h|r (You Won, " .. ns.GetColor("HELP") .. "Greed 54|r)"),
		"and so does the player's"
	)

	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_WON_NO_SPAM_GREED:format(12, "Aero", hammer, 33))
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM:format("Aero", hammer))
	check(toastShowing(env, "Greed 33|r)"), "with roll spam turned down, the won line alone carries it")

	profile.lootToastWinningRollGroup = false
	rollRound("Aero", "NEED", 91)
	check(not toastShowing(env, "Need 91"), "Show Winning Roll's Group box takes it off their toasts")
	profile.lootToastWinningRollMine = false
	rollRound("Tester", "GREED", 72)
	check(not toastShowing(env, "Greed 72"), "and its Mine box off the player's")

	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM:format("Aero", hammer))
	check(toastShowing(env, "Hefty Battlehammer|h|r (|"), "loot nobody rolled for reads as before")
end)

--[[
    Hide Roll Messages keeps every pick and every number out of the chat
    frames, never who won or what they received. It is part of Automated
    Rolls, so with the master switch off it hides nothing, and the saved
    choice is kept for when the switch comes back.
]]
test("Hide Roll Messages keeps the picks and numbers out of chat, never who won", function()
	local ns, env = loadAddon()
	local filters = env.__state.chatFilters.CHAT_MSG_LOOT or {}
	checkEqual(1, #filters, "one chat filter is added for loot lines")
	local function hidden(message)
		return filters[1] and filters[1](nil, "CHAT_MSG_LOOT", message) and true or false
	end
	local hammer = itemLink(15259, "Hefty Battlehammer", "1eff00")

	checkEqual(true, ns.db.profile.hideRollMessages, "it ships on")
	ns.db.profile.autoGreed = false
	check(not hidden(env.LOOT_ROLL_GREED:format(11, "Aero", hammer)), "with Automated Rolls off, nothing is hidden")
	checkEqual(true, ns.db.profile.hideRollMessages, "and the choice is kept")
	ns.db.profile.autoGreed = true
	check(hidden(env.LOOT_ROLL_GREED:format(11, "Aero", hammer)), "a pick is hidden")
	check(hidden(env.LOOT_ROLL_NEED_SELF:format(11, hammer)), "the player's own pick too")
	check(hidden(env.LOOT_ROLL_PASSED:format(11, "Aero", hammer)), "and a pass")
	check(hidden(env.LOOT_ROLL_ROLLED_NEED:format(11, 87, hammer, "Aero")), "a number is hidden")
	check(hidden(env.LOOT_ROLL_STARTED:format(11, hammer)), "and the line opening the roll")
	checkEqual(ns.WINNER_SUMMARY_PRINT, ns.db.profile.winnerSummary, "the winner summary ships on")
	check(hidden(env.LOOT_ROLL_WON:format(11, "Aero", hammer)), "so the game's won line gives way to it")
	check(hidden(env.LOOT_ROLL_WON_NO_SPAM_GREED:format(11, "Aero", hammer, 33)), "in either form")
	check(hidden(env.LOOT_ROLL_YOU_WON:format(11, hammer)), "the player's own too")
	ns.db.profile.winnerSummary = ns.WINNER_SUMMARY_NONE
	check(not hidden(env.LOOT_ROLL_WON:format(11, "Aero", hammer)), "without the summary, who won stays")
	check(not hidden(env.LOOT_ROLL_WON_NO_SPAM_GREED:format(11, "Aero", hammer, 33)), "in either form")
	check(not hidden(env.LOOT_ITEM:format("Aero", hammer)), "and so does what they received")
	check(not hidden(env.LOOT_ITEM_SELF:format(hammer)), "and the player's own loot")

	ns.db.profile.hideRollMessages = false
	check(not hidden(env.LOOT_ROLL_GREED:format(11, "Aero", hammer)), "switched off, nothing is hidden")
end)

--[[
    Standard Loot Messages: the dropdown beside Enable Loot Toasts takes the
    General tab's own Item Loot and Money Loot lines away while the toasts are
    on, and gives back only what it took when either changes. An ordinary
    login changes nothing, so a box ticked back in Blizzard's window sticks.
]]
local function chatGroupCount(state, wanted)
	local found = 0
	for _, group in ipairs(state.chatFrameGroups) do
		if group == wanted then
			found = found + 1
		end
	end
	return found
end

test("Loot Toasts takes the standard loot lines out of General, and gives them back", function()
	local ns, env = loadAddon()
	local state = env.__state
	local switch = ns.LootToastsSwitch()
	local dropdown = ns.BuildLootToastOptions().args.lootToastsRow.args.control

	checkEqual(false, ns.db.profile.lootToasts, "the toasts ship off")
	ns.SyncStandardLootMessages()
	checkEqual(1, chatGroupCount(state, "LOOT"), "so a first login leaves General alone")
	checkEqual(ns.STANDARD_LOOT_MESSAGES_DISABLE, dropdown.get(), "the dropdown ships on Disable")
	switch.set(nil, true)
	checkEqual(0, chatGroupCount(state, "LOOT"), "turning the toasts on takes Item Loot off General")
	checkEqual(0, chatGroupCount(state, "MONEY"), "and Money Loot")
	check(env.ChatFrame1:ContainsMessageGroup("SYSTEM"), "and nothing else")

	switch.set(nil, false)
	checkEqual(1, chatGroupCount(state, "LOOT"), "turning the toasts off brings Item Loot back")
	checkEqual(1, chatGroupCount(state, "MONEY"), "and Money Loot")
	switch.set(nil, true)
	checkEqual(0, chatGroupCount(state, "LOOT"), "turning them on takes it away again")

	dropdown.set(nil, ns.STANDARD_LOOT_MESSAGES_ENABLE)
	checkEqual(1, chatGroupCount(state, "LOOT"), "Enable on the dropdown brings it back with the toasts on")
	dropdown.set(nil, ns.STANDARD_LOOT_MESSAGES_DISABLE)
	checkEqual(0, chatGroupCount(state, "LOOT"), "and Disable takes it away")

	env.ChatFrame1:AddMessageGroup("LOOT")
	ns.SyncStandardLootMessages()
	checkEqual(1, chatGroupCount(state, "LOOT"), "an ordinary login leaves a hand-ticked Item Loot alone")
end)

test("taking the loot lines off General, or giving them back, says so once", function()
	local ns, env = loadAddon()
	local state = env.__state
	local switch = ns.LootToastsSwitch()
	state.prints = {}

	switch.set(nil, true)
	checkEqual(1, printCount(env, "Turned off"), "taking them off is printed once")
	check(printedContaining(env, env.ITEM_LOOT) ~= nil, "naming the game's own setting")
	ns.SyncStandardLootMessages()
	checkEqual(1, printCount(env, "Turned off"), "and a sync that changes nothing prints nothing")

	switch.set(nil, false)
	checkEqual(1, printCount(env, "back on"), "giving them back is printed once too")
end)

test("the dropdown sits beside Enable Loot Toasts and leaves with it", function()
	local ns = loadAddon()
	local row = ns.BuildLootToastOptions().args.lootToastsRow
	local dropdown = row.args.control
	checkEqual("select", dropdown.type, "a dropdown")
	checkEqual(
		ns.L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"],
		dropdown.values[ns.STANDARD_LOOT_MESSAGES_DISABLE],
		"Disable"
	)
	checkEqual(
		ns.L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"],
		dropdown.values[ns.STANDARD_LOOT_MESSAGES_ENABLE],
		"Enable"
	)
	ns.db.profile.lootToasts = false
	check(dropdown.hidden(), "it leaves while the toasts are off")
end)

test("Loot Toasts never brings back loot lines it didn't take", function()
	local ns, env = loadAddon()
	local state = env.__state
	ns.db.profile.lootToasts = true
	env.ChatFrame1:RemoveMessageGroup("LOOT")
	ns.SyncStandardLootMessages()
	ns.LootToastsSwitch().set(nil, false)
	checkEqual(0, chatGroupCount(state, "LOOT"), "General stays without Item Loot, as the player had it")
	checkEqual(1, chatGroupCount(state, "MONEY"), "while the Money Loot it took comes back")
end)

test("nothing changes before the General tab has loaded", function()
	local ns, env = loadAddon()
	local state = env.__state
	ns.db.profile.lootToasts = true
	env.ChatFrame1.isInitialized = 0
	ns.SyncStandardLootMessages()
	checkEqual(1, chatGroupCount(state, "LOOT"), "Item Loot is untouched")
	checkEqual(nil, ns.db.char.standardLootMessagesHidden, "and the sync waits for the tab")
end)

--[[
    Print Winner Summary: one GogoLoot line per win, the winner, the item and
    the winning roll, read off the game's roll lines whether or not they are
    drawn. It needs Hide Roll Messages, and the toasts needn't be on.
]]
test("two copies of one item rolled at once keep their own winning rolls", function()
	local ns, env = loadAddon()
	local profile = ns.db.profile
	profile.lootToasts = true
	profile.lootToastsIntroSeen = true
	local state = env.__state
	state.inGroup = true
	state.groupMembers = 3
	state.unitNames.party1 = "Aero"
	state.unitNames.party2 = "Bram"
	knownItem(env, 15259, "Hefty Battlehammer", 2, ns.ITEM_CLASS_WEAPON)
	local hammer = itemLink(15259, "Hefty Battlehammer", "1eff00")

	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_ROLLED_NEED:format(21, 87, hammer, "Aero"))
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_ROLLED_NEED:format(22, 64, hammer, "Bram"))
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_ROLLED_NEED:format(22, 12, hammer, "Aero"))
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_WON:format(21, "Aero", hammer))
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM:format("Aero", hammer))
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_WON:format(22, "Bram", hammer))
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM:format("Bram", hammer))

	check(toastShowing(env, "Need 87|r)"), "the first copy keeps its winner's roll")
	check(toastShowing(env, "Need 64|r)"), "and the second copy keeps its own")
end)

test("the winner summary names the winner, the item and the winning roll", function()
	local ns, env = loadAddon()
	local state = env.__state
	local L = ns.L
	ns.db.profile.autoGreed = true
	checkEqual(false, ns.db.profile.lootToasts, "with the toasts off")
	local hammer = itemLink(15259, "Hefty Battlehammer", "1eff00")
	local function lastPrint()
		return (state.prints[#state.prints] or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
	end

	state.prints = {}
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_ROLLED_GREED:format(11, 95, hammer, "Aero"))
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_ROLLED_GREED:format(11, 40, hammer, "Tester"))
	checkEqual(0, #state.prints, "nothing prints while the roll is open")
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_WON:format(11, "Aero", hammer))
	checkEqual(1, #state.prints, "one line when it's won")
	check(lastPrint():find(L["ADDON_TITLE"] .. " // Aero won ", 1, true) ~= nil, "naming the winner, name first")
	check(lastPrint():find("Hefty Battlehammer", 1, true) ~= nil, "the item")
	check(lastPrint():find(", " .. env.GREED .. " 95.", 1, true) ~= nil, "and the winning roll, not another")

	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_WON_NO_SPAM_GREED:format(12, "Aero", hammer, 33))
	check(lastPrint():find(", " .. env.GREED .. " 33.", 1, true) ~= nil, "the spam-free won line carries its own roll")

	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_YOU_WON:format(13, hammer))
	check(lastPrint():find(L["ADDON_TITLE"] .. " // You won ", 1, true) ~= nil, "the player's own win")
	check(lastPrint():sub(-1) == ".", "with no roll seen, it ends on the item")

	state.prints = {}
	ns.db.profile.winnerSummary = ns.WINNER_SUMMARY_NONE
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_WON:format(14, "Aero", hammer))
	checkEqual(0, #state.prints, "Don't Print Winner Summary prints nothing")
	ns.db.profile.winnerSummary = ns.WINNER_SUMMARY_PRINT
	ns.db.profile.hideRollMessages = false
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_WON:format(15, "Aero", hammer))
	checkEqual(0, #state.prints, "nor does it with Hide Roll Messages off")
	ns.db.profile.hideRollMessages = true
	ns.db.profile.autoGreed = false
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_WON:format(16, "Aero", hammer))
	checkEqual(0, #state.prints, "or with Automated Rolls off")
end)

test("the winner summary names a group member in their class color", function()
	local ns, env = loadAddon()
	local state = env.__state
	ns.db.profile.autoGreed = true
	state.inGroup = true
	state.groupMembers = 2
	state.unitNames.party1 = "Aero"
	state.playerClassFile = "ROGUE"
	local hammer = itemLink(15259, "Hefty Battlehammer", "1eff00")
	state.prints = {}
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_WON_NO_SPAM_GREED:format(11, "Aero", hammer, 95))
	check((state.prints[1] or ""):find("|cffFFF468Aero|r won ", 1, true) ~= nil, "Aero, in Rogue yellow")
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ROLL_WON_NO_SPAM_GREED:format(12, "Stranger", hammer, 95))
	check((state.prints[2] or ""):find("Stranger won ", 1, true) ~= nil, "a name the roster doesn't hold reads plain")
end)

test("the winner summary sits beside Hide Roll Messages, its example under it", function()
	local ns, env = loadAddon()
	local args = ns.BuildAutomatedRollOptions().args
	ns.db.profile.autoGreed = true
	local dropdown = args.hideRollMessagesRow.args.control
	checkEqual("select", dropdown.type, "a dropdown beside the toggle")
	checkEqual(ns.L["ROLLS_WINNER_SUMMARY_PRINT"], dropdown.values[ns.WINNER_SUMMARY_PRINT], "Print Winner Summary")
	checkEqual(ns.L["ROLLS_WINNER_SUMMARY_NONE"], dropdown.values[ns.WINNER_SUMMARY_NONE], "Don't Print Winner Summary")
	ns.db.profile.hideRollMessages = false
	check(dropdown.hidden(), "it leaves while Hide Roll Messages is off")
	local row = args.winnerSummaryExampleRow
	check(row.hidden(), "and so does its example, since nothing prints")
	ns.db.profile.hideRollMessages = true
	check(not row.hidden(), "the example shows while the summary prints")
	local example = row.args.control1.name()
	check(
		example:find(ns.GetColor("INFO") .. ns.L["ADDON_TITLE"] .. "|r", 1, true) ~= nil,
		"the example is the printed line"
	)
	check(example:find(ns.GetClassColor("DRUID") .. "Aero|r", 1, true) ~= nil, "naming Aero in Druid orange")
	check(example:find(", " .. env.GREED .. " 95.", 1, true) ~= nil, "with its roll")
	ns.db.profile.winnerSummary = ns.WINNER_SUMMARY_NONE
	check(row.hidden(), "and leaves when the dropdown says not to print")
end)

--[[
    The roll lines read back out of the client's own formats, the hidden
    [Loot] link dropped, the captures read by what they hold.
]]
test("roll lines give the player, the roll and the item", function()
	local ns, env = loadAddon()
	local hammer = itemLink(15259, "Hefty Battlehammer", "1eff00")
	local name, kind, roll, link = ns.ParseRollResultMessage(env.LOOT_ROLL_ROLLED_GREED:format(9, 54, hammer, "Aero"))
	checkEqual("Aero", name, "the player")
	checkEqual(ns.ROLL_KIND_GREED, kind, "the kind of roll")
	checkEqual(54, roll, "the number, not the history link's")
	checkEqual(hammer, link, "the item")
	name, kind, roll = ns.ParseRollResultMessage(env.LOOT_ROLL_ROLLED_DE:format(12, hammer, "Aero"))
	checkEqual("Aero", name, "a line with no history link names the player")
	checkEqual(ns.ROLL_KIND_DISENCHANT, kind, "and the kind")
	checkEqual(12, roll, "with its number")

	local isWon, winner, wonLink, wonKind = ns.ParseRollWonMessage(env.LOOT_ROLL_WON:format(9, "Aero", hammer))
	check(
		isWon and winner == "Aero" and wonLink == hammer and wonKind == nil,
		"who won, with no roll on the plain line"
	)
	isWon, winner = ns.ParseRollWonMessage(env.LOOT_ROLL_YOU_WON:format(9, hammer))
	check(isWon and winner == nil, "the player's own win names nobody")
	local wonRoll
	isWon, winner, wonLink, wonKind, wonRoll =
		ns.ParseRollWonMessage(env.LOOT_ROLL_YOU_WON_NO_SPAM_NEED:format(9, hammer, 87))
	check(isWon and winner == nil and wonLink == hammer, "the quiet form names the item")
	check(wonKind == ns.ROLL_KIND_NEED and wonRoll == 87, "and carries the roll")
	checkEqual(nil, ns.ParseRollWonMessage(env.LOOT_ITEM:format("Aero", hammer)), "a loot line is no win")
	checkEqual(nil, ns.ParseRollResultMessage(env.LOOT_ITEM:format("Aero", hammer)), "nor a roll")
end)

--[[
    WoW Forever and Retail print the player's own loot lines without the full
    stop Era's carry, and color links by named quality. The patterns come from
    the client's own formats, so that shape reads the same.
]]
test("own loot reads on a client whose formats drop the full stop", function()
	local ns, env = loadAddon(nil, function(clientEnv)
		clientEnv.LOOT_ITEM_SELF = "You receive loot: %s"
		clientEnv.LOOT_ITEM_SELF_MULTIPLE = "You receive loot: %sx%d"
		clientEnv.LOOT_ITEM_PUSHED_SELF = "You receive item: %s"
		clientEnv.LOOT_ITEM_PUSHED_SELF_MULTIPLE = "You receive item: %sx%d"
	end)
	ns.db.profile.lootToasts = true
	ns.db.profile.lootToastsIntroSeen = true
	knownItem(env, 117, "Tough Jerky", 1, ns.ITEM_CLASS_CONSUMABLE)
	local link = "|cnIQ1:|Hitem:117::::::::3:1491:::::::::|h[Tough Jerky]|h|r"

	local parsedLink, quantity = ns.ParseOwnLootMessage(env.LOOT_ITEM_SELF:format(link))
	checkEqual(link, parsedLink, "a single item")
	checkEqual(1, quantity, "counts one")
	parsedLink, quantity = ns.ParseOwnLootMessage(env.LOOT_ITEM_SELF_MULTIPLE:format(link, 5))
	checkEqual(link, parsedLink, "a stack keeps its link")
	checkEqual(5, quantity, "and its count")

	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(link))
	check(toastShowing(env, "Tough Jerky"), "and it toasts")
end)

test("toasts introduce themselves once per profile", function()
	local ns = loadAddon()
	ns.db.profile.lootToasts = true
	fire(ns, "PLAYER_LOGIN")
	check(ns.AreLootToastsUnlocked(), "a profile that hasn't met the handle is shown it")
	ns.DismissLootToastIntro()
	ns.SetLootToastsUnlocked(false)
	fire(ns, "PLAYER_LOGIN")
	check(not ns.AreLootToastsUnlocked(), "and not again once it has been put away")

	ns.SetLootToastsEnabled(false)
	check(not ns.db.profile.lootToasts, "the handle's Disable button turns the feature off")
end)

--------------------------------------------------------------------------------
-- Merged Features: Lockbox Tooltips
--------------------------------------------------------------------------------

local function tooltipHasLine(tooltip, needle)
	for _, line in ipairs(tooltip.lines) do
		if type(line) == "string" and line:find(needle, 1, true) then
			return true
		end
	end
	return false
end

test("a lockbox tooltip names the skill it needs, for a rogue by default", function()
	-- The skill-line API resolves once at load, so it is faked before; the skill list starts empty.
	local ns, env = loadAddon(nil, function(env)
		env.GetNumSkillLines = function()
			return env.__state.skillLineCount or 0
		end
		env.GetSkillLineInfo = function()
			return "Lockpicking", false, nil, 100
		end
	end)
	fire(ns, "PLAYER_LOGIN")
	putInBag(env, 0, 1, IRON_LOCKBOX, "Iron Lockbox", { locked = true })

	env.GameTooltip:SetBagItem(0, 1)
	check(not tooltipHasLine(env.GameTooltip, env.ITEM_REQ_SKILL:format("Lockpicking")), "not for a warrior")

	env.__state.playerClassFile = "ROGUE"
	env.GameTooltip:SetBagItem(0, 1)
	check(tooltipHasLine(env.GameTooltip, env.ITEM_REQ_SKILL:format("Lockpicking")), "for a rogue")

	env.__state.skillLineCount = 1
	env.GameTooltip:SetBagItem(0, 1)
	check(tooltipHasLine(env.GameTooltip, ns.GetColor("ON")), "a rogue who can pick it sees it in green")

	putInBag(env, 0, 2, CLAM, "Big-mouth Clam")
	env.GameTooltip:SetBagItem(0, 2)
	check(not tooltipHasLine(env.GameTooltip, ns.L["ADDON_TITLE"]), "and a clam gets no block at all")
end)

test("WoW Forever never reads a skill rank, even with skill-line globals put back", function()
	local ns = loadAddon(nil, function(env)
		local readMetadata = env.C_AddOns.GetAddOnMetadata
		env.C_AddOns.GetAddOnMetadata = function(addonName, field)
			if field == "X-Flavor" then
				return "Camelot"
			end
			return readMetadata(addonName, field)
		end
		env.GetNumSkillLines = function()
			return 1
		end
		env.GetSkillLineInfo = function()
			return "Lockpicking", false, nil, 100
		end
	end)
	checkEqual(nil, ns.GetSkillLineRankByName("Lockpicking"), "the rank stays unknown")
end)

test("a skill count that isn't a number reads as unknown", function()
	local ns = loadAddon(nil, function(env)
		env.GetNumSkillLines = function()
			return nil
		end
		env.GetSkillLineInfo = function()
			return "Lockpicking", false, nil, 100
		end
	end)
	checkEqual(nil, ns.GetSkillLineRankByName("Lockpicking"), "rather than throwing")
end)

--[[
    The skill list shows skill-line names, and in esMX the Lockpicking spell
    ("Forzar cerraduras") and skill line ("Ganzúa") are named differently: the
    rank is found by the skill line's name, never the spell's.
]]
test("a rogue's lockpicking rank is found by the skill line's name, not the spell's", function()
	local ns, env = loadAddon(nil, function(env)
		env.__state.skillLineNames[633] = "Ganzúa"
		env.GetNumSkillLines = function()
			return 1
		end
		env.GetSkillLineInfo = function()
			return "Ganzúa", false, nil, 100
		end
	end)
	fire(ns, "PLAYER_LOGIN")
	putInBag(env, 0, 1, IRON_LOCKBOX, "Iron Lockbox", { locked = true })
	env.__state.playerClassFile = "ROGUE"
	env.C_Spell.GetSpellName = function()
		return "Forzar cerraduras"
	end
	env.GameTooltip:SetBagItem(0, 1)
	checkEqual(100, ns.GetPlayerLockpickingSkill(), "the rank reads off the skill line")
	check(tooltipHasLine(env.GameTooltip, env.ITEM_REQ_SKILL:format("Ganzúa")), "and the block names the skill line")
end)

--------------------------------------------------------------------------------
-- Merged Features: Mini-map Button
--------------------------------------------------------------------------------

test(
	"the mini-map's clicks: rolls, opening, then announcements and master looting with Shift, and the options",
	function()
		local ns, env = loadAddon()
		local button = env.__state.brokerObjects.GogoLoot
		check(button ~= nil, "the button exists")
		local opened = 0
		ns.OpenOptionsPanel = function()
			opened = opened + 1
		end
		local profile = ns.db.profile
		local function snapshot()
			return { profile.autoGreed, profile.autoOpen, profile.lootNotifications, profile.autoMasterLoot }
		end
		local function changed(before)
			local after, flipped = snapshot(), {}
			for index, name in ipairs({ "rolls", "opening", "announcements", "master looting" }) do
				if before[index] ~= after[index] then
					flipped[#flipped + 1] = name
				end
			end
			return table.concat(flipped, ", ")
		end

		local before = snapshot()
		button.OnClick({}, "LeftButton")
		checkEqual("rolls", changed(before), "left-click flips Automated Rolls alone")
		before = snapshot()
		button.OnClick({}, "RightButton")
		checkEqual("opening", changed(before), "right-click flips Automated Opening alone")

		env.__state.shiftDown = true
		before = snapshot()
		button.OnClick({}, "LeftButton")
		checkEqual("announcements", changed(before), "shift + left-click flips Announcements alone")
		before = snapshot()
		button.OnClick({}, "RightButton")
		checkEqual("master looting", changed(before), "shift + right-click flips Automated Master Looting alone")

		before = snapshot()
		button.OnClick({}, "MiddleButton")
		checkEqual(1, opened, "shift + middle-click opens the options")
		checkEqual("", changed(before), "without toggling anything")
		env.__state.shiftDown = false
		profile.lootMaster = true
		local lootWindows = 0
		ns.ToggleLootTracker = function()
			lootWindows = lootWindows + 1
		end
		button.OnClick({}, "MiddleButton")
		checkEqual(1, opened, "a plain middle-click doesn't open the options")
		checkEqual(1, lootWindows, "it opens the Loot Tracker, with nothing to hand out")
		checkEqual("", changed(before), "and toggles nothing")
		checkEqual(true, ns.db.global.speedyLoot, "and no click reaches Speedy Loot")
	end
)

test("the mini-map tooltip leads with the boxes still waiting on a lock", function()
	local ns, env = loadAddon()
	putInBag(env, 0, 1, IRON_LOCKBOX, "Iron Lockbox", { locked = true })
	env.__state.brokerObjects.GogoLoot.OnEnter({})
	checkEqual(ns.L["MINIMAP_LOCKED_ITEMS"], env.GameTooltip.lines[4], "Locked Items follows the title")
	check(tooltipHasLine(env.GameTooltip, "Iron Lockbox"), "and lists the box")
	check(tooltipHasLine(env.GameTooltip, ns.L["TAB_AUTOMATED_OPENING"]), "Automated Opening has its block")
end)

-- Parked out of the TOCs, the loot windows' files never load; the button and /gogo must not reach for them.
test("with the loot windows unloaded, the mini-map and /gogo leave them out", function()
	local ns, env = loadAddon()
	ns.db.profile.lootMaster = true
	for _, name in ipairs({
		"GetRollListEntries",
		"ShowLootMaster",
		"ShowLootTracker",
		"ToggleLootMaster",
		"ToggleLootTracker",
		"PrintDrops",
	}) do
		ns[name] = nil
	end
	local opened = 0
	ns.OpenOptionsPanel = function()
		opened = opened + 1
	end
	local button = env.__state.brokerObjects.GogoLoot
	local ok = pcall(button.OnEnter, {})
	check(ok, "the tooltip shows")
	check(not tooltipHasLine(env.GameTooltip, ns.L["MINIMAP_LOOT_WINDOWS"]), "without a Loot Windows block")
	check(pcall(button.OnClick, {}, "MiddleButton"), "a plain middle-click does nothing")
	check(pcall(env.SlashCmdList.GOGOLOOT, "master"), "/gogo master doesn't throw")
	checkEqual(1, opened, "and opens the options instead")
end)

--[[
    The feature blocks in the order of their clicks, Automated Rolls on
    left-click, Automated Opening on right-click, Announcements on Shift +
    left-click and Automated Master Looting on Shift + right-click, then the
    options line. Speedy Loot simply stays on, so it has no block.
]]
test("the mini-map tooltip lists its blocks in click order, and no Speedy Loot", function()
	local ns, env = loadAddon()
	local L = ns.L
	env.__state.brokerObjects.GogoLoot.OnEnter({})
	local lines = env.GameTooltip.lines
	local function firstLineWith(needle, after)
		for index = (after or 0) + 1, #lines do
			local line = lines[index]
			if type(line) == "string" and line:find(needle, 1, true) then
				return index
			end
		end
		return nil
	end

	local blocks = {
		{ L["TAB_AUTOMATED_ROLLS"], L["MINIMAP_LEFT_CLICK"] },
		{ L["TAB_AUTOMATED_OPENING"], L["MINIMAP_RIGHT_CLICK"] },
		{ L["TAB_ANNOUNCEMENTS"], L["MINIMAP_SHIFT_LEFT_CLICK"] },
		{ L["TAB_MASTER_LOOTER"], L["MINIMAP_SHIFT_RIGHT_CLICK"] },
	}
	local previous = 0
	for _, block in ipairs(blocks) do
		local title = firstLineWith(block[1], previous)
		check(title ~= nil, block[1] .. " has a block, after the one before it")
		local click = title and firstLineWith(block[2], title)
		check(click ~= nil and click <= title + 4, block[1] .. " answers to " .. block[2])
		previous = click or previous
	end
	check((firstLineWith(L["MINIMAP_OPTIONS"]) or 0) > previous, "and the options line closes it")
	checkEqual(nil, firstLineWith("Speedy Loot"), "Speedy Loot has no block")
end)

--[[
    Under Automated Rolls' description, a line per group context reads back
    what it rolls, set in by two spaces and named with the game's own word for
    the context; a Manual context says only that.
]]
test("the mini-map tooltip reads back what Automated Rolls rolls in each context", function()
	local ns, env = loadAddon()
	local L = ns.L
	ns.db.profile.autoRollActionParty = ns.GREED
	ns.db.profile.autoRollThresholdParty = 2
	ns.db.profile.autoRollActionRaid = ns.MANUAL
	env.__state.brokerObjects.GogoLoot.OnEnter({})
	local lines = env.GameTooltip.lines
	local rolls
	for index, line in ipairs(lines) do
		if type(line) == "string" and line:find(L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"], 1, true) then
			rolls = index
		end
	end
	checkEqual(
		"  " .. L["MINIMAP_ROLLS_SETTING"]:format("Party", "Greed", L["THRESHOLD_AND_LOWER"]:format("Uncommon")),
		rolls and lines[rolls + 1],
		"the party line names its roll and quality"
	)
	checkEqual(
		"  " .. L["MINIMAP_ROLLS_SETTING_MANUAL"]:format("Raid", L["ROLL_MANUAL"]),
		rolls and lines[rolls + 2],
		"and a Manual raid says only Manual"
	)
end)

--------------------------------------------------------------------------------
-- Merged Features: Client Strings and Registration
--------------------------------------------------------------------------------

test("a loot line whose translation numbers its arguments is still read by argument", function()
	local ns = loadAddon(nil, function(env)
		env.LOOT_ITEM = "%2$s goes to %1$s."
		env.LOOT_ITEM_MULTIPLE = "%2$sx%3$d goes to %1$s."
	end)
	local link = itemLink(2589, "Linen Cloth")
	local looter, item, count = ns.ParseGroupLootMessage(link .. " goes to Aero.")
	checkEqual("Aero", looter, "the looter is the first argument, though printed last")
	checkEqual(link, item, "the item is the second")
	checkEqual(1, count, "one came")
	looter, item, count = ns.ParseGroupLootMessage(link .. "x4 goes to Aero.")
	checkEqual("Aero", looter, "a counted line too")
	checkEqual(link, item, "its item")
	checkEqual(4, count, "and its count")
end)

test("a roll line whose translation numbers its arguments is still read", function()
	local ns = loadAddon(nil, function(env)
		env.LOOT_ROLL_ROLLED_NEED = "|HlootHistory:%1$d|h[Loot]|h: %4$s würfelt Bedarf %2$d für %3$s"
	end)
	local link = itemLink(15259, "Hefty Battlehammer", "1eff00")
	local playerName, rollKind, roll, item =
		ns.ParseRollResultMessage("|HlootHistory:7|h[Loot]|h: Aero würfelt Bedarf 87 für " .. link)
	checkEqual("Aero", playerName, "the player")
	checkEqual(ns.ROLL_KIND_NEED, rollKind, "the kind of roll")
	checkEqual(87, roll, "the numbered roll")
	checkEqual(link, item, "and the item")
end)

test("own loot lines are read whole, with their counts", function()
	local ns, env = loadAddon()
	local link = itemLink(2589, "Linen Cloth")
	local parsedLink, quantity = ns.ParseOwnLootMessage(env.LOOT_ITEM_SELF:format(link))
	checkEqual(link, parsedLink, "a single item")
	checkEqual(1, quantity, "counts one")
	parsedLink, quantity = ns.ParseOwnLootMessage(env.LOOT_ITEM_SELF_MULTIPLE:format(link, 4))
	checkEqual(link, parsedLink, "a stack keeps its link")
	checkEqual(4, quantity, "and its count")
	parsedLink = ns.ParseOwnLootMessage(env.LOOT_ITEM_PUSHED_SELF:format(link))
	checkEqual(link, parsedLink, "a pushed item is ours too")
	checkEqual(nil, ns.ParseOwnLootMessage("Hippobob receives loot: " .. link .. "."), "someone else's isn't")
	checkEqual(nil, ns.ParseOwnLootMessage(nil), "nor is nothing")
end)

test("a group member's loot lines give the looter, the item and the count", function()
	local ns, env = loadAddon()
	local link = itemLink(2589, "Linen Cloth")
	local looterName, parsedLink, quantity = ns.ParseGroupLootMessage(env.LOOT_ITEM:format("Hippobob", link))
	checkEqual("Hippobob", looterName, "the looter")
	checkEqual(link, parsedLink, "the item")
	checkEqual(1, quantity, "one of it")

	looterName, parsedLink, quantity =
		ns.ParseGroupLootMessage(env.LOOT_ITEM_MULTIPLE:format("Hippobob Bramblefoot", link, 3))
	checkEqual("Hippobob Bramblefoot", looterName, "a WoW Forever name whole")
	checkEqual(link, parsedLink, "a stack keeps its link")
	checkEqual(3, quantity, "and its count")

	looterName = ns.ParseGroupLootMessage(env.LOOT_ITEM_PUSHED:format("Hippobob-Stormrage", link))
	checkEqual("Hippobob-Stormrage", looterName, "a pushed item is a group member's too, realm and all")
	checkEqual(nil, ns.ParseGroupLootMessage(env.LOOT_ITEM_SELF:format(link)), "the player's own line isn't")
	checkEqual(nil, ns.ParseGroupLootMessage(nil), "nor is nothing")
end)

test("coin and quality come back out of the client's own formats", function()
	local ns = loadAddon()
	checkEqual(10203, ns.ParseMoney("You loot 1 Gold, 2 Silver, 3 Copper"), "gold, silver and copper")
	checkEqual(7, ns.ParseMoney("You loot 7 Copper"), "a unit the message leaves out is none")
	checkEqual(0, ns.ParseMoney(nil), "and no message is no coin")
	checkEqual(4, ns.GetLinkQuality(itemLink(1, "Epic Thing", "a335ee")), "a hex quality color")
	checkEqual(3, ns.GetLinkQuality("|cnIQ3:|Hitem:1::|h[Rare Thing]|h|r"), "a named quality color")
	local pattern = "^" .. ns.BuildFormatPattern("You receive loot: %sx%d.") .. "$"
	local itemText, count = ("You receive loot: [Linen Cloth]x2."):match(pattern)
	checkEqual("[Linen Cloth]", itemText, "a format becomes a pattern that captures the item")
	checkEqual("2", count, "and the count")
	checkEqual(nil, ("You receive loot: [Linen Cloth]x2!"):match(pattern), "with its punctuation matched literally")
end)

local function eventFrameOf(env)
	for _, frame in ipairs(env.__state.createdFrames) do
		if frame.frameName == "GogoLootEventFrame" then
			return frame
		end
	end
	return nil
end

test("a unit event is registered for its unit, and an event the client lacks not at all", function()
	local ns, env = loadAddon(nil, function(loadingEnv)
		loadingEnv.C_EventUtils.IsEventValid = function(eventName)
			return eventName ~= "PLAYER_INTERACTION_MANAGER_FRAME_HIDE"
		end
	end)
	local eventFrame = eventFrameOf(env)
	checkEqual("player", eventFrame.events.UNIT_SPELLCAST_SUCCEEDED, "only the player's own casts are heard")
	checkEqual(true, eventFrame.events.LOOT_READY, "an ordinary event carries no unit")
	checkEqual(nil, eventFrame.events.PLAYER_INTERACTION_MANAGER_FRAME_HIDE, "an event the client lacks is skipped")
	checkEqual(nil, ns.eventHandlers.PLAYER_INTERACTION_MANAGER_FRAME_HIDE, "and so is its handler")
	check(ns.eventHandlers.MERCHANT_CLOSED ~= nil, "while the rest still register")
end)

test("one handler's error doesn't stop the handlers after it", function()
	local ns, env = loadAddon()
	local laterHandlerRan = false
	ns:RegisterModuleEvent("PLAYER_REGEN_ENABLED", function()
		error("a broken handler")
	end)
	ns:RegisterModuleEvent("PLAYER_REGEN_ENABLED", function()
		laterHandlerRan = true
	end)
	local eventFrame = eventFrameOf(env)
	eventFrame.scripts.OnEvent(eventFrame, "PLAYER_REGEN_ENABLED")
	check(laterHandlerRan, "the handler after the broken one still runs")
	checkEqual(1, #env.__state.handlerErrors, "and the error still reaches the error handler")
	env.__state.handlerErrors = {}
end)

test("every registered event is listed for diagnostics, and the list is sorted", function()
	local ns, env = loadAddon()
	for index = 2, #ns.EVENT_NAMES do
		check(ns.EVENT_NAMES[index - 1] < ns.EVENT_NAMES[index], ns.EVENT_NAMES[index] .. " is in order")
	end
	for _, line in ipairs(env.__state.prints) do
		check(not line:find("Developer warning", 1, true), "no module registered an unlisted event: " .. line)
	end
end)

-- Builds one flavor folder's tables into a bare namespace carrying the constants its rows read.
local function LoadDataFolder(folder, constants)
	local ns = { IS_DISCOVERY = folder == "Discovery" }
	for key, value in pairs(constants) do
		ns[key] = value
	end
	for _, tableName in ipairs({ "Default-Item-Lists", "Lockbox-Skill-Levels", "Openable-Items", "Spells" }) do
		local chunk = assert(loadfile(ROOT .. ("Data/%s/%s-%s.lua"):format(folder, tableName, folder)))
		chunk("GogoLoot", ns)
	end
	return ns
end

-- The Data.lua constants a flavor folder's rows name: the roll actions and the opening actions.
local function DataFolderConstants()
	local loaded = loadAddon()
	local constants = { NEED = loaded.NEED, MANUAL = loaded.MANUAL, GREED = loaded.GREED, PASS = loaded.PASS }
	for key, value in pairs(loaded) do
		if type(key) == "string" and key:find("^OPENING_") then
			constants[key] = value
		end
	end
	return constants, loaded
end

test("every data folder declares every table, and the container data holds together", function()
	local constants, loaded = DataFolderConstants()
	-- A row's default is an action, or an action with its reason: never anything the code can't read.
	local dataDefaults = {
		[loaded.OPENING_OPEN] = true,
		[loaded.OPENING_IGNORE] = true,
		[loaded.OPENING_UNLOCKED] = true,
		[loaded.OPENING_IGNORE_RAID] = true,
		[loaded.OPENING_IGNORE_UNIQUE] = true,
	}
	for _, folder in ipairs({ "Vanilla", "Discovery", "TBC", "Camelot", "Wrath", "Mists", "Mainline" }) do
		local ns = LoadDataFolder(folder, constants)
		for _, key in ipairs({
			"DEFAULT_IGNORE_LIST_SOLO",
			"DEFAULT_IGNORE_LIST_MASTER",
			"OPENABLE_ITEMS",
			"LOCKBOX_SKILL_LEVELS",
			"SPELLS",
		}) do
			check(type(ns[key]) == "table", ("%s declares %s"):format(folder, key))
		end
		checkEqual(nil, ns.DEFAULT_IGNORE_LIST_OPENING, folder .. " keeps its Ignore defaults on the rows themselves")
		for itemIdentifier, default in pairs(ns.OPENABLE_ITEMS or {}) do
			check(
				dataDefaults[default],
				("%s: row %d defaults to a value the code reads"):format(folder, itemIdentifier)
			)
		end
		for itemIdentifier, skill in pairs(ns.LOCKBOX_SKILL_LEVELS or {}) do
			check(
				ns.OPENABLE_ITEMS[itemIdentifier] == loaded.OPENING_UNLOCKED,
				("%s: skill row %d is a lockbox"):format(folder, itemIdentifier)
			)
			check(type(skill) == "number", ("%s: skill row %d is a number"):format(folder, itemIdentifier))
		end
	end
end)

test("each folder holds only the containers its own client can open", function()
	local constants = DataFolderConstants()
	local folders = {}
	for _, folder in ipairs({ "Vanilla", "Discovery", "TBC", "Camelot", "Wrath", "Mists", "Mainline" }) do
		folders[folder] = LoadDataFolder(folder, constants).OPENABLE_ITEMS
	end
	local TWILIGHT_SET = 227372 -- a Season of Discovery set box
	check(folders.Discovery[TWILIGHT_SET] ~= nil, "Season of Discovery has its own set boxes")
	checkEqual(nil, folders.Vanilla[TWILIGHT_SET], "Classic Era doesn't, though its client knows the id")
	checkEqual(nil, folders.Camelot[TWILIGHT_SET], "and neither does WoW Forever")
	local ZIGRIS_FOOTLOCKER = 22233 -- flagged openable, but a 16 slot bag
	for folder, rows in pairs(folders) do
		checkEqual(nil, rows[ZIGRIS_FOOTLOCKER], folder .. " leaves out a bag, which using would equip")
	end
	for _, folder in ipairs({ "Vanilla", "Discovery", "TBC", "Camelot" }) do
		check(folders[folder][CLAM] ~= nil, folder .. " opens clams through the loot flag")
	end
	for _, folder in ipairs({ "Wrath", "Mists", "Mainline" }) do
		checkEqual(nil, folders[folder][CLAM], folder .. " opens clams through a spell, which an add-on can't cast")
	end
end)

test("the test harness loads exactly what the Vanilla TOC loads", function()
	local listed = {}
	for line in io.lines(ROOT .. "GogoLoot_Vanilla.toc") do
		-- Git stores the TOCs with LF, but a working copy can hold CRLF, which the game reads fine.
		line = line:gsub("\r$", "")
		local isOtherLocale = line:match("^Locales/") and line ~= "Locales/enUS.lua"
		if line:match("^[%w].*%.lua$") and not line:match("^Includes/") and not isOtherLocale then
			listed[#listed + 1] = line
		end
	end
	local loaded = {}
	for _, file in ipairs(FILES) do
		if not PARKED_FILES[file] then
			loaded[#loaded + 1] = file
		end
	end
	checkEqual(#listed, #loaded, "the same number of files")
	for index, file in ipairs(listed) do
		checkEqual(file, loaded[index], ("file %d"):format(index))
	end
end)

--[[
    One TOC per flavor, matching the Vanilla TOC line for line but for its
    Interface and X-Flavor fields and its data folder: its own folder's files in
    place of Data/Vanilla's, and no Data/Discovery, which only the Classic Era
    client can need.
]]
test("every flavor TOC loads the Vanilla TOC's files, with its own data folder", function()
	local function ReadToc(flavor)
		local fields, files = {}, {}
		for line in io.lines(ROOT .. ("GogoLoot_%s.toc"):format(flavor)) do
			line = line:gsub("\r$", "") -- CRLF in a working copy, as above
			local key, value = line:match("^## ([%w%-]+): (.*)$")
			if key then
				fields[key] = value
			elseif line:match("^[%w].*%.lua$") or line:match("^[%w].*%.xml$") then
				files[#files + 1] = line
			end
		end
		return fields, files
	end

	local vanillaFields, vanillaFiles = ReadToc("Vanilla")
	checkEqual("Vanilla", vanillaFields["X-Flavor"], "the Vanilla TOC names its flavor")
	for _, flavor in ipairs({ "TBC", "Camelot", "Mists" }) do
		local fields, files = ReadToc(flavor)
		checkEqual(flavor, fields["X-Flavor"], flavor .. " names its own flavor")
		for key, value in pairs(vanillaFields) do
			if key ~= "Interface" and key ~= "X-Flavor" then
				checkEqual(value, fields[key], ("%s carries the same %s"):format(flavor, key))
			end
		end
		local expected = {}
		for _, file in ipairs(vanillaFiles) do
			if not file:match("^Data/Discovery/") then
				local ownFile =
					file:gsub("^Data/Vanilla/(.-)%-Vanilla%.lua$", ("Data/%s/%%1-%s.lua"):format(flavor, flavor))
				expected[#expected + 1] = ownFile
			end
		end
		checkEqual(#expected, #files, flavor .. " lists as many files")
		for index, file in ipairs(expected) do
			checkEqual(file, files[index], ("%s file %d"):format(flavor, index))
		end
	end
end)

--------------------------------------------------------------------------------
-- Merged Features: Diagnostics
--------------------------------------------------------------------------------

test("an inventory-full error stays in the event log as a full line", function()
	local ns, env = loadAddon()
	ns:StartEventLog()
	ns:LogEvent("UI_ERROR_MESSAGE", env.LE_GAME_ERR_INV_FULL, "Inventory is full.")
	local report = ns:BuildEventLogReport()
	check(
		report:find(("UI_ERROR_MESSAGE(%d, Inventory is full.)"):format(env.LE_GAME_ERR_INV_FULL), 1, true) ~= nil,
		"the error Automated Opening pauses on is logged, not counted as noise"
	)
end)

test("the locked boxes report gives each openable item its action and lock verdict", function()
	local ns, env = loadAddon()
	putInBag(env, 0, 1, IRON_LOCKBOX, "Iron Lockbox", { locked = true })
	putInBag(env, 0, 2, 2589, "Linen Cloth")
	local report = ns:BuildLockedBoxesReport()
	check(report:find(("0\t1\t%d\t"):format(IRON_LOCKBOX), 1, true) ~= nil, "the lockbox has a row")
	check(
		report:find("\tUNLOCKED\tOPEN\ttrue\t2", 1, true) ~= nil,
		"with its default, reason and all, then its action, verdict and line count"
	)
	check(report:find("2589", 1, true) == nil, "and a bag slot that isn't openable has none")
end)

test("Gear Stats lists the gear in the bags and on the character, each stat's sources, and the rule", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.itemNames[14152] = { name = "Robe of the Archmage", quality = 4, classId = 4, itemType = "Armor" }
	state.itemNames[4001] = { name = "Owl Robe", quality = 2, classId = 4, itemType = "Armor" }
	state.itemNames[2589] = { name = "Linen Cloth", quality = 1, classId = 7, itemType = "Trade Goods" }
	state.itemStats[14152] = { ITEM_MOD_INTELLECT_SHORT = 10 }
	putInBag(env, 0, 1, 4001, "Owl Robe", { link = "|Hitem:4001::::::754|h[Owl Robe]|h" })
	state.hyperlinkTooltipLines[4001] = { "Owl Robe of the Owl", "+5 Intellect", "+5 Spirit" }
	putInBag(env, 0, 2, 2589, "Linen Cloth")
	state.equipped[5] = "|Hitem:14152|h[Robe of the Archmage]|h"
	ns.db.char.characterRules = { SPIRIT = ns.MANUAL }

	local report = ns:BuildGearStatsReport()
	check(
		report:find("Manual on Aero - Realm: SPIRIT", 1, true) ~= nil,
		"the header names this character's Manual stats"
	)
	check(
		report:find(
			"EQUIPPED 5\t14152\t\t||Hitem:14152||h[Robe of the Archmage]||h\t" .. "INTELLECT (ITEM)\tSTANDARD",
			1,
			true
		) ~= nil,
		"the equipped robe shows its item stat, and rolls as usual"
	)
	check(
		report:find("BAG 0/1\t4001\t754\t", 1, true) ~= nil
			and report:find("INTELLECT (TOOLTIP); SPIRIT (TOOLTIP)\tMANUAL (SPIRIT)", 1, true) ~= nil,
		"the of the Owl piece shows its suffix and its stats, and is left to the player"
	)
	check(report:find("2589", 1, true) == nil, "and what isn't gear has no row")
end)

-- Validate Data resolves its spell reads once at load, so the test swaps them in before the files load.
test("validate data checks spells too, each in its own block", function()
	local SHADOWMELD = 20580
	local ns, env = loadAddon(nil, function(env)
		env.C_Spell.DoesSpellExist = function(spellIdentifier)
			return spellIdentifier ~= SHADOWMELD
		end
		env.C_Spell.GetSpellName = function()
			return "Some Spell"
		end
	end)
	checkEqual(SHADOWMELD, ns.SPELLS.SHADOWMELD, "the Vanilla data's Shadowmeld id")

	local report = RunValidation(ns, env, DataSourceIndex(ns, "Spells"))

	check(report:find("STATUS\tSOURCE\tSPELL_ID\tNAME", 1, true) ~= nil, "the spell block has its own header")
	check(report:find("ITEM_ID", 1, true) == nil, "and no item block, with no item in the file")
	check(
		report:find(("OK\tSPELLS\t%d\tSome Spell"):format(ns.SPELLS.PICK_LOCK), 1, true) ~= nil,
		"a spell the client has reads OK"
	)
	check(
		report:find(("NOT ON CLIENT\tSPELLS\t%d"):format(ns.SPELLS.SHADOWMELD), 1, true) ~= nil,
		"and one it lacks is flagged"
	)
	check(report:find("PICK_LOCK", 1, true) ~= nil, "with the row's own key beside it")
end)

--[[
    The panel's tabs exist only while the gate is on, left out rather than
    hidden, since hidden tabs still draw an empty bordered frame.
]]
test("the diagnostic tabs are left out of the panel until it is enabled", function()
	local ns = loadAddon()
	local off = ns.BuildDiagnosticsOptions()
	checkEqual(nil, off.args.runTests, "no Run Tests tab while off")
	checkEqual(nil, off.args.settings, "and no report tabs")

	ns:SetDiagnosticsEnabled(true)
	local on = ns.BuildDiagnosticsOptions()
	check(on.args.runTests ~= nil, "Run Tests appears once enabled")
	for _, section in ipairs(ns.DIAGNOSTIC_SECTIONS) do
		check(on.args[section.key] ~= nil, section.key .. " appears too")
	end
	checkEqual(#ns.DIAGNOSTIC_DATA_SOURCES, #ns:GetDiagnosticSection("data").reports, "one Data row per data file")
end)

test("a tab's Run All prints the header once and a block per report", function()
	local ns, env = loadAddon()
	ns:SetDiagnosticsEnabled(true)

	ns:RunDiagnosticSection("code")
	for _ = 1, 20 do
		Fake.advance(env, 0.1)
	end

	local output = ns.diagnostics.outputs.code or ""
	local _, headerCount = output:gsub("Flavor Vanilla // Data Vanilla", "")
	checkEqual(1, headerCount, "the client header prints once")
	for _, title in ipairs({ "Event Registration", "API Endpoints", "Library Versions" }) do
		check(output:find("---- " .. title .. " ----", 1, true) ~= nil, title .. " has its block")
	end
	checkEqual(nil, ns.diagnostics.running, "and the run is over")
	checkEqual("done", ns:GetDiagnosticReportStatus("api"), "each report reads Done")
end)

test("turning diagnostics off stops a run and clears every report", function()
	local ns, env = loadAddon()
	ns:SetDiagnosticsEnabled(true)
	ns:RunDiagnosticSection("settings")

	ns:SetDiagnosticsEnabled(false)
	Fake.advance(env, 2)

	checkEqual(nil, ns.diagnostics.running, "the run stopped")
	checkEqual(nil, next(ns.diagnostics.outputs), "the boxes are empty")
	checkEqual(nil, next(ns.diagnostics.status), "and no report keeps a state")
end)

test("every Settings report builds without an error", function()
	local ns, env = loadAddon()
	ns:SetDiagnosticsEnabled(true)

	ns:RunDiagnosticSection("settings")
	for _ = 1, 30 do
		Fake.advance(env, 0.1)
	end

	local output = ns.diagnostics.outputs.settings or ""
	check(output:find("ERROR:", 1, true) == nil, "no report threw: " .. (output:match("ERROR:[^\n]*") or ""))
	check(output:find("---- Loot Method ----", 1, true) ~= nil, "Loot Method ran")
	check(output:find("---- Saved Variables ----", 1, true) ~= nil, "Saved Variables ran")
end)

--------------------------------------------------------------------------------
-- Item List Filter
--------------------------------------------------------------------------------

-- The item IDs a built list shows a row for, in ID order.
local function ListedItems(listArgs)
	local listed = {}
	for key in pairs(listArgs) do
		local itemIdentifier = key:match("^item_(%d+)$")
		if itemIdentifier then
			listed[#listed + 1] = tonumber(itemIdentifier)
		end
	end
	table.sort(listed)
	return listed
end

-- A built list top to bottom: "# " and the text of each type header, and each row's item ID.
local function ListLayout(listArgs)
	local entries = {}
	for key, option in pairs(listArgs) do
		local itemIdentifier = key:match("^item_(%d+)$")
		if itemIdentifier then
			entries[#entries + 1] = { order = option.order, text = itemIdentifier }
		elseif key:find("^sectionHeader") then
			local heading = option.name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
			entries[#entries + 1] = { order = option.order, text = "# " .. heading }
		end
	end
	table.sort(entries, function(a, b)
		return a.order < b.order
	end)
	local texts = {}
	for index, entry in ipairs(entries) do
		texts[index] = entry.text
	end
	return table.concat(texts, ", ")
end

--[[
    The tools take the lines above the rows: the add box and Add from Bags
    first, then a blank line, then the filter and the kind filter. The boxes
    sit in the label column, one width, stacked in one column, and the two
    dropdowns in the control column. Restore Defaults closes the list, below
    its last row.
]]
test("every item list opens with its add line, a blank line, then the filter line", function()
	local ns = loadAddon()
	local L = ns.L
	for _, entry in ipairs({
		{ "Item Overrides", ns.BuildItemOverridesOptions().args.itemOverrides.args },
		{ "the Master Looter Ignore List", ns.BuildMasterLooterIgnoreListOptions().args.ignoreList.args },
		{ "Openables List", ns.BuildOpenableItemsOptions().args.itemList.args },
	}) do
		local listName, listArgs = entry[1], entry[2]
		local filterRow, addRow = listArgs.filterRow, listArgs.addRow
		for _, line in ipairs({ { "the filter's line", filterRow }, { "the add box's line", addRow } }) do
			local lineName, group = line[1], line[2]
			checkEqual(
				"group",
				group.type,
				listName .. ": " .. lineName .. " is a group, which takes a line of its own"
			)
			check(group.inline and group.name == "", listName .. ": " .. lineName .. " is drawn bare, with no title")
		end
		check(addRow.order < listArgs.spacerAfterAddRow.order, listName .. ": the add line comes first")
		check(listArgs.spacerAfterAddRow.order < filterRow.order, listName .. ": then a blank line, then the filter's")

		local filter, kindFilter = filterRow.args.itemFilter, filterRow.args.kindFilter
		local addItem, addFromBags = addRow.args.addItemInput, addRow.args.addFromBags
		checkEqual(ns.ITEM_LIST_FILTER_WIDGET_TYPE, filter.dialogControl, listName .. " draws the filter box")
		checkEqual("select", kindFilter.type, listName .. " and the kind filter")
		checkEqual(ns.ITEM_LIST_ADD_WIDGET_TYPE, addItem.dialogControl, listName .. " and the add box")
		checkEqual("select", addFromBags.type, listName .. " and Add from Bags")
		check(filter.order < kindFilter.order, listName .. ": the filter, then the kind filter")
		check(addItem.order < addFromBags.order, listName .. ": the add box, then Add from Bags")
		checkNear(ns.OPTIONS_LABEL_WIDTH, filter.width, listName .. "'s filter takes the label column")
		checkNear(ns.OPTIONS_CONTROL_WIDTH, kindFilter.width, listName .. "'s kind filter the control column")
		checkNear(ns.OPTIONS_CONTROL_WIDTH, addFromBags.width, listName .. "'s Add from Bags too")
		checkNear(
			ns.OPTIONS_ROW_WIDTH,
			filter.width + kindFilter.width,
			listName .. ": the filter's line ends on the shared right edge"
		)
		checkNear(filter.width, addItem.width, listName .. "'s add box is as wide as the filter")
		checkEqual(L["ITEM_LIST_ADD"], addItem.name, listName .. ": the add box's tooltip is titled Add Item")
		check((addItem.desc or "") ~= "", listName .. ": and says what it takes")
		checkEqual(L["ITEM_LIST_KIND_DESCRIPTION"], kindFilter.desc, listName .. ": the kind filter explains itself")
		local resting = kindFilter.values[kindFilter.get()]
		checkEqual(L["ITEM_LIST_KIND_ALL"], resting, listName .. ": it starts on Show All Kinds of Items")

		local restore = listArgs.restoreRow
		checkEqual(nil, listArgs.restoreDefaults, listName .. ": no Restore Defaults button above the rows")
		checkEqual(L["ITEM_LIST_RESTORE"], restore.args.control2.name, listName .. ": it reads Restore Defaults")
		check(restore.args.control2.confirm, listName .. ": and confirms")
		checkNear(
			ns.OPTIONS_ROW_WIDTH,
			restore.args.control1.width + restore.args.control2.width,
			listName .. ": right-aligned on the shared right edge"
		)
		for key, option in pairs(listArgs) do
			if key:find("^item_") then
				check(addRow.order < option.order, listName .. ": the tools sit above " .. key)
				check(option.order < restore.order, listName .. ": and Restore Defaults below " .. key)
			end
		end
	end
end)

--[[
    The kind filter offers Show All Kinds of Items, then the headers the list carries, in the
    list's A to Z order, and a kind picked shows only
    its section. Each list keeps its own kind, it works alongside the filter,
    and a kind that leaves the list puts it back on Show All Kinds of Items.
]]
test("the kind filter offers the list's own headers and shows only the one picked, on every list", function()
	local ns, env = loadAddon()
	local L = ns.L
	local state = env.__state
	state.itemNames[5101] = { name = "Zesty Clam", itemType = "Trade Goods", itemSubType = "Other" }
	state.itemNames[5102] = { name = "Heavy Junkbox", itemType = "Miscellaneous", itemSubType = "Junk" }
	state.itemNames[5103] = { name = "Bundle of Reports", itemType = "Quest", itemSubType = "Quest" }
	state.itemNames[5104] = { name = "Apple Crate", itemType = "Miscellaneous", itemSubType = "Junk" }
	state.itemNames[5105] = { name = "Worn Reports", itemType = "Quest", itemSubType = "Quest" }

	--[[
        Each list holds the four typed items, and the Openables List its
        defaults too, which the fake client can't type: they sit under no
        header and offer no kind.
    ]]
	ns.db.profile.ignoredItemsSolo = { [5101] = ns.NEED, [5102] = ns.NEED, [5103] = ns.NEED, [5104] = ns.NEED }
	ns.db.profile.ignoredItemsMaster = { [5101] = true, [5102] = true, [5103] = true, [5104] = true }
	for itemIdentifier = 5101, 5104 do
		ns:AddOpeningItem(itemIdentifier)
	end
	local lists = {
		{
			name = "Item Overrides",
			build = function()
				return ns.BuildItemOverridesOptions().args.itemOverrides.args
			end,
		},
		{
			name = "the Master Looter Ignore List",
			build = function()
				return ns.BuildMasterLooterIgnoreListOptions().args.ignoreList.args
			end,
		},
		{
			name = "the Openables List",
			build = function()
				return ns.BuildOpenableItemsOptions().args.itemList.args
			end,
		},
	}

	-- Each list keeps its own kind.
	lists[1].build().filterRow.args.kindFilter.set(nil, "Quest")
	checkEqual(
		"ALL",
		lists[2].build().filterRow.args.kindFilter.get(),
		"picking one list's kind leaves the others alone"
	)
	lists[1].build().filterRow.args.kindFilter.set(nil, "ALL")

	for _, list in ipairs(lists) do
		local listArgs = list.build()
		local kindFilter = listArgs.filterRow.args.kindFilter
		checkEqual(
			"ALL, Miscellaneous, Quest, Trade Goods",
			table.concat(kindFilter.sorting, ", "),
			list.name .. ": Show All Kinds of Items, then its headers A to Z, the kind alone"
		)
		checkEqual(
			L["ITEM_LIST_KIND_ALL"],
			kindFilter.values.ALL,
			list.name .. ": the first reads Show All Kinds of Items"
		)
		for index = 2, #kindFilter.sorting do
			local heading = kindFilter.sorting[index]
			checkEqual(heading, kindFilter.values[heading], list.name .. ": the others read as their headers do")
		end
		local all = #ListedItems(listArgs)

		kindFilter.set(nil, "Miscellaneous")
		listArgs = list.build()
		checkEqual("Miscellaneous", listArgs.filterRow.args.kindFilter.get(), list.name .. ": the pick holds")
		checkEqual(
			"# Miscellaneous, 5104, 5102",
			ListLayout(listArgs),
			list.name .. ": a kind picked shows its section alone, header and all"
		)

		listArgs.filterRow.args.itemFilter.set(nil, "apple")
		checkEqual("# Miscellaneous, 5104", ListLayout(list.build()), list.name .. ": the filter narrows it further")
		list.build().filterRow.args.itemFilter.set(nil, "reports")
		checkEqual(0, #ListedItems(list.build()), list.name .. ": the filter finds nothing of that kind")
		check(list.build().noFilterMatches ~= nil, list.name .. ": and the list says so")
		list.build().filterRow.args.itemFilter.set(nil, "")

		list.build().filterRow.args.kindFilter.set(nil, "ALL")
		checkEqual(all, #ListedItems(list.build()), list.name .. ": Show All Kinds of Items brings every row back")
		checkEqual(nil, list.build().noFilterMatches, list.name .. ": without the no-match line")
	end

	-- A kind that leaves the list puts it back on Show All Kinds of Items, and an item of that kind returning doesn't narrow it again.
	local overrides = lists[1]
	overrides.build().filterRow.args.kindFilter.set(nil, "Quest")
	overrides.build().item_5103.args.remove.func()
	local listArgs = overrides.build()
	checkEqual(
		"ALL",
		listArgs.filterRow.args.kindFilter.get(),
		"the list's last quest item gone, it reads Show All Kinds of Items"
	)
	checkEqual(3, #ListedItems(listArgs), "and shows every row left")
	checkEqual(nil, listArgs.filterRow.args.kindFilter.values.Quest, "with Quest no longer offered")
	ns.db.profile.ignoredItemsSolo[5105] = ns.NEED
	checkEqual(4, #ListedItems(overrides.build()), "a quest item added later shows among every row")
end)

--[[
    Add from Bags offers what the player carries that the list doesn't hold,
    one choice per item, A to Z, with the count carried, resting on its own
    caption. Picking one adds it. The Openables List leaves out what it would
    refuse, and with nothing left to offer the dropdown greys out and says so.
]]
test("Add from Bags offers what the bags hold that the list doesn't", function()
	local ns, env = loadAddon()
	local L = ns.L
	local state = env.__state
	state.itemNames[5201] = { name = "Zebra Hide", itemType = "Trade Goods" }
	state.itemNames[5202] = { name = "Apple", itemType = "Consumable" }
	state.itemNames[5203] = { name = "Iron Helm", itemType = "Armor", equipLocation = "INVTYPE_HEAD" }
	putInBag(env, 0, 1, 5201, "Zebra Hide", { count = 3 })
	putInBag(env, 0, 2, 5201, "Zebra Hide", { count = 2 })
	putInBag(env, 0, 3, 5202, "Apple")
	putInBag(env, 1, 1, 5203, "Iron Helm")
	ns.db.profile.ignoredItemsSolo = { [5202] = ns.NEED }
	local function addFromBags()
		return ns.BuildItemOverridesOptions().args.itemOverrides.args.addRow.args.addFromBags
	end

	local dropdown = addFromBags()
	checkEqual("CAPTION, 5203, 5201", table.concat(dropdown.sorting, ", "), "its caption, then the bags' items A to Z")
	check(dropdown.values.CAPTION:find(L["ITEM_LIST_ADD_FROM_BAGS"], 1, true) ~= nil, "resting on Add from Bags")
	checkEqual("CAPTION", dropdown.get(), "which it reads")
	check(dropdown.values[5201]:find("x5$") ~= nil, "a carried stack counts every slot")
	checkEqual(nil, dropdown.values[5202], "an item already on the list isn't offered")
	check(not evaluate(dropdown.disabled), "and it can be opened")

	dropdown.set(nil, 5201)
	check(ns.db.profile.ignoredItemsSolo[5201] ~= nil, "picking an item adds it")
	dropdown.set(nil, "CAPTION")
	checkEqual(nil, ns.db.profile.ignoredItemsSolo.CAPTION, "picking the caption adds nothing")

	local openables = ns.BuildOpenableItemsOptions().args.itemList.args.addRow.args.addFromBags
	checkEqual(nil, openables.values[5203], "the Openables List doesn't offer gear")
	checkEqual(L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"], openables.desc, "and says why in its tooltip")

	ns.db.profile.ignoredItemsSolo[5203] = ns.NEED
	dropdown = addFromBags()
	check(evaluate(dropdown.disabled), "with nothing left to offer, it greys out")
	check(dropdown.values.CAPTION:find(L["ITEM_LIST_BAGS_EMPTY"], 1, true) ~= nil, "and says so")
	checkEqual(L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"], dropdown.desc, "in its tooltip too")
end)

--[[
    What the player just added, by ID or from the bags, leads its list under
    a New header, newest first, until they filter that list or close the
    Options window, when it goes back under its kind.
]]
test("an item just added sits under New at the top until the list is filtered or the window closes", function()
	local ns, env = loadAddon()
	local L = ns.L
	local state = env.__state
	state.itemNames[5301] = { name = "Apple", itemType = "Consumable" }
	state.itemNames[5302] = { name = "Zebra Hide", itemType = "Trade Goods" }
	state.itemNames[5303] = { name = "Bread", itemType = "Consumable" }
	putInBag(env, 0, 1, 5302, "Zebra Hide")
	ns.db.profile.ignoredItemsSolo = { [5301] = ns.NEED }
	local function listArgs()
		return ns.BuildItemOverridesOptions().args.itemOverrides.args
	end

	listArgs().addRow.args.addFromBags.set(nil, 5302)
	listArgs().addRow.args.addItemInput.set(nil, "5303")
	checkEqual(
		"# " .. L["ITEM_LIST_NEW"] .. ", 5303, 5302, # Consumable, 5301",
		ListLayout(listArgs()),
		"the new rows lead under New, newest first, out of their kinds"
	)
	check(listArgs().filterRow.args.kindFilter.values["Trade Goods"] ~= nil, "the kind filter still offers their kinds")
	checkEqual(
		"",
		ListLayout(ns.BuildMasterLooterIgnoreListOptions().args.ignoreList.args):find(L["ITEM_LIST_NEW"], 1, true)
				and "New"
			or "",
		"another list has no New section"
	)

	listArgs().filterRow.args.itemFilter.set(nil, "")
	checkEqual(
		"# Consumable, 5301, 5303, # Trade Goods, 5302",
		ListLayout(listArgs()),
		"filtering puts them back under their kinds"
	)

	listArgs().addRow.args.addItemInput.set(nil, "5301")
	check(ListLayout(listArgs()):find(L["ITEM_LIST_NEW"], 1, true) ~= nil, "adding again brings New back")
	listArgs().filterRow.args.kindFilter.set(nil, "ALL")
	checkEqual(nil, ListLayout(listArgs()):find(L["ITEM_LIST_NEW"], 1, true), "and the kind filter ends it too")

	listArgs().addRow.args.addItemInput.set(nil, "5303")
	ns.ForgetNewListItems()
	checkEqual(nil, ListLayout(listArgs()):find(L["ITEM_LIST_NEW"], 1, true), "as does closing the window")
end)

--[[
    Adding never depends on knowing to press Enter: the box reads "Drop item
    here, or type item ID" while it is empty, its Add button hands over what
    was typed, and an item dropped on the box is added as it lands. Each way in
    fires OnEnterPressed, which AceConfigDialog hands to the entry's set.
]]
test("the add box adds from its Add button, from Enter, and from a dropped item", function()
	local ns, env = loadAddon()
	local widget = env.__state.widgetConstructors[ns.ITEM_LIST_ADD_WIDGET_TYPE]()
	local added = {}
	widget:SetCallback("OnEnterPressed", function(_, _, value)
		added[#added + 1] = value
	end)
	checkEqual(ns.L["ITEM_LIST_ADD_PLACEHOLDER"], widget.placeholder.text, "the empty box carries its hint")
	checkEqual(ns.L["ITEM_LIST_ADD_BUTTON"], widget.button:GetText(), "and an Add button beside it")

	widget.editbox:SetText("12345")
	widget.button:GetScript("OnClick")(widget.button)
	checkEqual("12345", added[1], "Add hands over what was typed, no Enter needed")
	checkEqual("", widget.editbox:GetText(), "and empties the box")
	widget.button:GetScript("OnClick")(widget.button)
	checkEqual(1, #added, "an empty box adds nothing")

	widget.editbox:SetText("67890")
	widget.editbox:GetScript("OnEnterPressed")(widget.editbox)
	checkEqual("67890", added[2], "Enter does the same")

	local droppedLink = "|Hitem:2589|h[Linen Cloth]|h"
	env.GetCursorInfo = function()
		return "item", 2589, droppedLink
	end
	widget.editbox:GetScript("OnReceiveDrag")(widget.editbox)
	checkEqual(droppedLink, added[3], "a dropped item is added as it lands")
end)

test("adding a listed item keeps its setting, and a bad ID is never saved", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.itemNames[5001] = { name = "Demonic Rune" }
	ns.db.profile.ignoredItemsSolo = { [5001] = ns.GREED }
	local function AddItem(value)
		ns.BuildItemOverridesOptions().args.itemOverrides.args.addRow.args.addItemInput.set(nil, value)
	end

	AddItem("5001")
	checkEqual(ns.GREED, ns.db.profile.ignoredItemsSolo[5001], "a listed item keeps its roll")

	state.itemsNotOnClient[5009] = true
	for _, value in ipairs({ "0", "1.5", "-3", "0x10", "5009" }) do
		AddItem(value)
	end
	local saved = 0
	for _ in pairs(ns.db.profile.ignoredItemsSolo) do
		saved = saved + 1
	end
	checkEqual(1, saved, "zero, fractions, negatives, hex and an ID the client lacks are all refused")

	AddItem(" 5002 ")
	checkEqual(ns.MANUAL, ns.db.profile.ignoredItemsSolo[5002], "a real ID still joins, set to Manual")
end)

test("an item added while one kind is picked still shows, under New", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.itemNames[5101] = { name = "Rusty Sword", itemType = "Weapon", classId = 2 }
	state.itemNames[5102] = { name = "Linen Cloth", itemType = "Trade Goods", classId = 7 }
	state.itemNames[5103] = { name = "Wool Cloth", itemType = "Trade Goods", classId = 7 }
	ns.db.profile.ignoredItemsSolo = { [5101] = ns.GREED, [5102] = ns.GREED }
	local function ListArgs()
		return ns.BuildItemOverridesOptions().args.itemOverrides.args
	end

	ListArgs().filterRow.args.kindFilter.set(nil, "Weapon")
	ListArgs().addRow.args.addItemInput.set(nil, "5103")
	check(ListArgs()["item_5103"] ~= nil, "the cloth just added shows with Weapon picked")
	checkEqual(nil, ListArgs()["item_5102"], "while the rest of the cloth stays filtered out")
end)

test("the filter narrows a list by name, item ID or setting, whatever the case", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.itemNames[5001] = { name = "Demonic Rune" }
	state.itemNames[5002] = { name = "Dark Rune" }
	state.itemNames[5003] = { name = "Onyxia Hide Backpack" }
	ns.db.profile.ignoredItemsSolo = { [5001] = ns.NEED, [5002] = ns.MANUAL, [5003] = ns.GREED }
	local function ListArgs()
		return ns.BuildItemOverridesOptions().args.itemOverrides.args
	end
	local filter = ListArgs().filterRow.args.itemFilter

	checkEqual(3, #ListedItems(ListArgs()), "an empty filter shows every row")
	filter.set(nil, "RUNE")
	checkEqual(2, #ListedItems(ListArgs()), "a name matches whatever its case")
	checkEqual("RUNE", filter.get(), "and the box keeps what was typed")
	filter.set(nil, "5003")
	checkEqual(5003, ListedItems(ListArgs())[1], "an item ID matches")
	filter.set(nil, "need")
	checkEqual(1, #ListedItems(ListArgs()), "a row's setting matches as the dropdown reads it")
	checkEqual(5001, ListedItems(ListArgs())[1], "that row alone")
	filter.set(nil, "  onyxia  ")
	checkEqual(5003, ListedItems(ListArgs())[1], "surrounding spaces don't count")
	filter.set(nil, "zzz")
	checkEqual(0, #ListedItems(ListArgs()), "nothing matches")
	check(ListArgs().noFilterMatches ~= nil, "and the list says so")
	filter.set(nil, "")
	checkEqual(3, #ListedItems(ListArgs()), "clearing it brings every row back")
	checkEqual(nil, ListArgs().noFilterMatches, "without the no-match line")
end)

test("each list keeps a filter of its own", function()
	local ns = loadAddon()
	ns.BuildItemOverridesOptions().args.itemOverrides.args.filterRow.args.itemFilter.set(nil, "zzz")
	checkEqual(
		"",
		ns.BuildMasterLooterIgnoreListOptions().args.ignoreList.args.filterRow.args.itemFilter.get(),
		"filtering one list leaves the others alone"
	)
end)

--------------------------------------------------------------------------------
-- Item Kind Sections
--------------------------------------------------------------------------------

test("item list rows sit under the kind of item, A to Z", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.itemNames[5101] = { name = "Zesty Clam", itemType = "Trade Goods", itemSubType = "Other" }
	state.itemNames[5102] = { name = "Heavy Junkbox", itemType = "Miscellaneous", itemSubType = "Junk" }
	state.itemNames[5103] = { name = "Bundle of Reports", itemType = "Quest", itemSubType = "Quest" }
	state.itemNames[5104] = { name = "Apple Crate", itemType = "Miscellaneous", itemSubType = "Junk" }
	state.itemNames[5105] = { name = "Care Package", itemType = "Consumable", itemSubType = "Other" }
	state.itemNames[5106] = { name = "Mystery Box" }
	ns.db.profile.ignoredItemsSolo = {}
	for itemIdentifier = 5101, 5106 do
		ns.db.profile.ignoredItemsSolo[itemIdentifier] = ns.NEED
	end
	local function ListArgs()
		return ns.BuildItemOverridesOptions().args.itemOverrides.args
	end

	checkEqual(
		"5106, # Consumable, 5105, # Miscellaneous, 5104, 5102, # Quest, 5103, # Trade Goods, 5101",
		ListLayout(ListArgs()),
		"headers A to Z, the kind alone, with the rows A to Z under each, and a row the client can't type above them all"
	)
	local listArgs = ListArgs()
	for key, option in pairs(listArgs) do
		local sectionIndex = key:match("^sectionHeader(%d+)$")
		if sectionIndex then
			checkEqual("header", option.type, key .. " is a header")
			checkEqual(
				option.order - 1,
				listArgs["spacerBeforeSection" .. sectionIndex].order,
				key .. " has space above"
			)
			checkEqual(
				option.order + 1,
				listArgs["spacerAfterSectionHeader" .. sectionIndex].order,
				key .. " and below"
			)
		end
	end

	ListArgs().filterRow.args.itemFilter.set(nil, "junk")
	checkEqual("# Miscellaneous, 5102", ListLayout(ListArgs()), "a section the filter empties loses its header")
	ListArgs().filterRow.args.itemFilter.set(nil, "")

	ns.db.profile.ignoredItemsSolo[5106] = nil
	listArgs = ListArgs()
	checkEqual(nil, listArgs.spacerBeforeSection1, "a header that leads the list takes no extra space above it")
	checkEqual(listArgs.spacerBeforeItems.order + 1, listArgs.sectionHeader1.order, "and follows the list's own spacer")
end)

--[[
    An item the game binds as a quest item reads "Quest Item" in its tooltip,
    so it sits under Quest whatever its class: Soft-shelled Clam is a Key.
]]
test("an item bound as a quest item sits under Quest, whatever its class", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.itemNames[5401] = { name = "Soft-shelled Clam", itemType = "Key", classId = 13, bindType = 4 }
	state.itemNames[5402] = { name = "Skeleton Key", itemType = "Key", classId = 13, bindType = 1 }
	state.itemNames[5403] = { name = "Gnoll Paw", itemType = "Quest", classId = 12, bindType = 4 }
	ns.db.profile.ignoredItemsSolo = { [5401] = ns.NEED, [5402] = ns.NEED, [5403] = ns.NEED }
	checkEqual(
		"# Key, 5402, # Quest, 5403, 5401",
		ListLayout(ns.BuildItemOverridesOptions().args.itemOverrides.args),
		"the quest-bound key joins Quest, and the other key stays under Key"
	)
end)

test("the Quest box takes an item bound as a quest item, whatever its class", function()
	local ns, env = loadAddon()
	local profile = ns.db.profile
	profile.lootToasts = true
	profile.lootToastsIntroSeen = true
	profile.lootToastMine.KEY = false
	knownItem(env, 5401, "Soft-shelled Clam", 1, ns.ITEM_CLASS_KEY, { bindType = 4 })
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(itemLink(5401, "Soft-shelled Clam")))
	check(toastShowing(env, "Soft-shelled Clam"), "with Key cleared, Quest still shows it")
	profile.lootToastMine.QUEST = false
	knownItem(env, 5404, "Hard-shelled Clam", 1, ns.ITEM_CLASS_KEY, { bindType = 4 })
	fire(ns, "CHAT_MSG_LOOT", env.LOOT_ITEM_SELF:format(itemLink(5404, "Hard-shelled Clam")))
	check(not toastShowing(env, "Hard-shelled Clam"), "and with both cleared, nothing does")
end)

test("every item list carries the kind headers", function()
	local ns, env = loadAddon()
	local state = env.__state
	state.itemNames[5102] = { name = "Heavy Junkbox", itemType = "Miscellaneous", itemSubType = "Junk" }
	state.itemNames[5104] = { name = "Apple Crate", itemType = "Miscellaneous", itemSubType = "Junk" }
	ns.db.profile.ignoredItemsSolo = { [5102] = ns.NEED, [5104] = ns.NEED }
	ns.db.profile.ignoredItemsMaster = { [5102] = true, [5104] = true }
	ns:AddOpeningItem(5102)
	ns:AddOpeningItem(5104)
	for _, entry in ipairs({
		{ "Item Overrides", ns.BuildItemOverridesOptions().args.itemOverrides.args },
		{ "the Master Looter Ignore List", ns.BuildMasterLooterIgnoreListOptions().args.ignoreList.args },
		{ "Openables List", ns.BuildOpenableItemsOptions().args.itemList.args },
	}) do
		check(
			ListLayout(entry[2]):find("# Miscellaneous, 5104, 5102", 1, true) ~= nil,
			entry[1] .. " heads its rows by kind"
		)
	end
end)

test("case folding reaches Latin and Cyrillic capitals", function()
	local ns = loadAddon()
	local function Matches(typed, itemName)
		ns.SetItemListFilter("caseFoldingTest", typed, true)
		return ns.ItemListRowMatchesFilter(ns.GetItemListFilterNeedle("caseFoldingTest"), 1, itemName, nil, nil)
	end
	check(Matches("идол", "ИДОЛ"), "Cyrillic")
	check(Matches("ёж", "ЁЖ"), "including Ё")
	check(Matches("ärger élan", "ÄRGER ÉLAN"), "Latin-1 accents")
	check(Matches("×", "×"), "and × is left alone")
	check(not Matches("÷", "×"), "without turning into another character")
end)

--------------------------------------------------------------------------------
-- Loot Master: Roll Calls
--------------------------------------------------------------------------------

-- The loot windows ship off while they're parked out of the TOCs; their tests switch them on.
local function loadLootWindows(beforeLoaded, beforeFiles)
	local ns, env = loadAddon(beforeLoaded, beforeFiles)
	ns.db.profile.lootMaster = true
	return ns, env
end

-- A raid of the player ("Tester", raid1) and the named members, raid2 onward.
local function joinRaid(env, names)
	local state = env.__state
	state.inGroup, state.inRaid = true, true
	state.groupMembers = #names + 1
	state.unitNames.raid1 = "Tester"
	for index, name in ipairs(names) do
		state.unitNames["raid" .. (index + 1)] = name
	end
	state.leaderUnit = "player"
	-- An ordinary raid, not an instance group: the fake's IsInGroup otherwise answers yes to every category.
	env.IsInGroup = function(category)
		return state.inGroup and category == nil
	end
end

local function rollLine(env, name, value, low, high)
	return env.RANDOM_ROLL_RESULT:format(name, value, low or 1, high or 100)
end

local function roll(ns, env, name, value, low, high)
	fire(ns, "CHAT_MSG_SYSTEM", rollLine(env, name, value, low, high))
end

local STRIKERS_MARK = itemLink(17069, "Striker's Mark", "a335ee")

local function rollFor(session, name)
	for _, entry in ipairs(session.rolls) do
		if entry.name == name and not entry.reject then
			return entry
		end
	end
	return nil
end

test("a /roll line is read in the client's own words, and nothing else is", function()
	local ns, env = loadLootWindows()
	local name, value, low, high = ns.ParseRandomRollMessage(rollLine(env, "Aero", 57))
	checkEqual("Aero", name, "the player")
	checkEqual(57, value, "the roll")
	checkEqual(1, low, "the low end")
	checkEqual(100, high, "the high end")
	check(ns.ParseRandomRollMessage("Aero rolls a lot") == nil, "an ordinary line isn't a roll")
	check(ns.ParseRandomRollMessage(nil) == nil, "nor is nothing")
end)

test("only a plain first /roll from the group counts, and the rest stay listed with the reason", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Aero", "Bob" })
	local session = ns:StartRoll(STRIKERS_MARK)
	check(session ~= nil, "the roll starts")
	check(chatContaining(env, "Roll for " .. STRIKERS_MARK .. " with /roll, 20 seconds") ~= nil, "and is called")
	checkEqual("RAID_WARNING", env.__state.chat[1].channel, "in a raid warning, as leader")
	roll(ns, env, "Aero", 88)
	roll(ns, env, "Aero", 92)
	roll(ns, env, "Bob", 640, 1, 1000)
	roll(ns, env, "Stranger", 99)
	checkEqual(3, #session.rolls, "a stranger's roll is ignored outright")
	local counted = ns:GetCountedRolls(session)
	checkEqual(1, #counted, "only one roll counts")
	checkEqual(88, counted[1].value, "Aero's first")
	checkEqual(ns.ROLL_REJECT_REPEAT, session.rolls[2].reject, "Aero's second is an extra roll")
	checkEqual(ns.ROLL_REJECT_RANGE, session.rolls[3].reject, "Bob's 1-1000 is the wrong range")
	check(ns:StartRoll(STRIKERS_MARK) == nil, "and a second roll can't start while this one is open")
end)

test("a roll closes on time, says what didn't count, then names the winner in group chat", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Aero", "Bob" })
	local session = ns:StartRoll(STRIKERS_MARK)
	roll(ns, env, "Aero", 88)
	roll(ns, env, "Aero", 92)
	roll(ns, env, "Bob", 41)
	Fake.advance(env, 15)
	check(chatContaining(env, "5 seconds left on") ~= nil, "the last-call warning goes out")
	Fake.advance(env, 7)
	check(not session.open, "the roll closes after its time and the grace")
	local notCounted = chatContaining(env, "Not counted on")
	check(notCounted ~= nil and notCounted:find("Aero's extra roll (92)", 1, true) ~= nil, "the extra roll is named")
	local wins = chatContaining(env, "Aero wins " .. STRIKERS_MARK .. " with 88")
	check(wins ~= nil, "the winner is announced")
	for _, entry in ipairs(env.__state.chat) do
		if entry.message == wins then
			checkEqual("RAID", entry.channel, "in raid chat, not a raid warning")
		end
	end
	checkEqual(ns.ENTRY_WON, session.status, "and the roll is won")
end)

test("a tie re-rolls among the tied players only", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Aero", "Bob", "Carl" })
	local session = ns:StartRoll(STRIKERS_MARK)
	roll(ns, env, "Aero", 50)
	roll(ns, env, "Bob", 50)
	roll(ns, env, "Carl", 10)
	Fake.advance(env, 22)
	check(session.open, "a tie-break opens")
	checkEqual(2, session.round, "as a second round")
	check(chatContaining(env, "Aero, Bob tied at 50") ~= nil, "the tie is called")
	roll(ns, env, "Carl", 99)
	checkEqual(ns.ROLL_REJECT_NOT_TIED, session.rolls[#session.rolls].reject, "Carl isn't in the tie-break")
	roll(ns, env, "Aero", 70)
	roll(ns, env, "Bob", 20)
	Fake.advance(env, 22)
	checkEqual("Aero", session.winner and session.winner.name, "Aero wins the tie-break")
end)

test("disqualifying the winner hands the win on and says so, and restoring hands it back", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Aero", "Bob" })
	local session = ns:StartRoll(STRIKERS_MARK)
	roll(ns, env, "Aero", 90)
	roll(ns, env, "Bob", 80)
	Fake.advance(env, 22)
	local aero = rollFor(session, "Aero")
	ns:DisqualifyRoll(session, aero, "NOT_ELIGIBLE")
	check(
		chatContaining(env, "I disqualified Aero's roll of 90 on " .. STRIKERS_MARK .. ": Not eligible for this item")
			~= nil,
		"the disqualification is announced with its reason"
	)
	check(chatContaining(env, "Bob now wins " .. STRIKERS_MARK .. " with 80") ~= nil, "and the new winner")
	checkEqual("Bob", session.winner.name, "Bob holds the win")
	ns:RestoreRoll(session, aero)
	check(chatContaining(env, "I restored Aero's roll of 90 on") ~= nil, "the restore is announced")
	check(chatContaining(env, "Aero now wins") ~= nil, "and the win goes back")
	checkEqual("Aero", session.winner.name, "Aero holds it again")
end)

test("a roll made just before the call shows as early and doesn't count", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Aero" })
	roll(ns, env, "Aero", 99)
	Fake.advance(env, 2)
	local session = ns:StartRoll(STRIKERS_MARK)
	checkEqual(1, #session.rolls, "the early roll is kept")
	checkEqual(ns.ROLL_REJECT_EARLY, session.rolls[1].reject, "as early")
	roll(ns, env, "Aero", 12)
	checkEqual(12, ns:GetCountedRolls(session)[1].value, "and Aero's roll inside the window counts")
end)

test("pause holds the clock, and resume gives the time back", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Aero" })
	local session = ns:StartRoll(STRIKERS_MARK)
	Fake.advance(env, 5)
	ns:PauseRoll(session)
	check(chatContaining(env, "Hold your rolls. " .. STRIKERS_MARK .. " is on pause") ~= nil, "the pause is called")
	Fake.advance(env, 60)
	check(session.open, "a paused roll stays open")
	ns:ResumeRoll(session)
	check(
		chatContaining(env, "Rolls back on for " .. STRIKERS_MARK .. ", 15 seconds left") ~= nil,
		"resume says what's left"
	)
	Fake.advance(env, 17)
	check(not session.open, "and it closes once that time is up")
end)

test("outside a group, a call goes nowhere and is printed instead", function()
	local ns, env = loadLootWindows()
	ns:StartRoll(STRIKERS_MARK)
	checkEqual(0, chatCount(env), "nothing is sent")
	check(printedContaining(env, "Roll for " .. STRIKERS_MARK) ~= nil, "the line is printed as a preview")
end)

test("a raider follows the loot master's roll from its add-on messages", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Leader", "Aero" })
	env.__state.leaderUnit = "raid2"
	fire(ns, "CHAT_MSG_ADDON", "GogoLoot", "START\tleader:1:5\t1\t20\t\t" .. STRIKERS_MARK, "RAID", "Leader")
	local session = ns.currentRoll
	check(session ~= nil and session.open and not session.isMine, "the roll opens here, as someone else's")
	check(session and session.synced, "followed through add-on messages")
	roll(ns, env, "Aero", 77)
	roll(ns, env, "Tester", 30)
	fire(ns, "CHAT_MSG_ADDON", "GogoLoot", "DQ\tleader:1:5\t1\tALREADY_WON", "RAID", "Leader")
	checkEqual(ns.ROLL_REJECT_MANUAL, session.rolls[1].reject, "the loot master's disqualification lands")
	fire(ns, "CHAT_MSG_ADDON", "GogoLoot", "END\tleader:1:5\tTester\t30", "RAID", "Leader")
	checkEqual("Tester", session.winner and session.winner.name, "and so does their result")
	checkEqual(0, chatCount(env), "a raider sends nothing")
end)

test("a raid warning with an item, from someone without GogoLoot, opens a roll to follow", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Leader", "Aero" })
	fire(ns, "CHAT_MSG_RAID_WARNING", "roll " .. STRIKERS_MARK .. " go", "Leader")
	local session = ns.currentRoll
	check(session ~= nil and session.open and not session.synced, "a roll is spotted")
	fire(ns, "CHAT_MSG_RAID", "pass", "Aero")
	check(session.passes.aero, "and pass in raid chat is a pass")
end)

test("with the Loot Master off, no roll is read", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Aero" })
	ns.db.profile.lootMaster = false
	fire(ns, "CHAT_MSG_RAID_WARNING", "roll " .. STRIKERS_MARK, "Aero")
	check(ns.currentRoll == nil, "nothing opens")
end)

test("a roll spotted in chat never stops the loot master calling one of their own", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Aero" })
	fire(ns, "CHAT_MSG_RAID_WARNING", "roll " .. STRIKERS_MARK, "Aero")
	local spotted = ns.currentRoll
	check(spotted ~= nil and spotted.open, "a roll is spotted")
	local mine = ns:StartRoll(STRIKERS_MARK)
	check(mine ~= nil, "the loot master's call still starts")
	check(not spotted.open, "and the spotted one is put away")
end)

test("a followed roll whose caller leaves the group is decided where it stands", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Leader", "Aero" })
	fire(ns, "CHAT_MSG_ADDON", "GogoLoot", "START\tleader:1:5\t1\t20\t\t" .. STRIKERS_MARK, "RAID", "Leader")
	fire(ns, "CHAT_MSG_ADDON", "GogoLoot", "PAUSE\tleader:1:5\t12", "RAID", "Leader")
	local session = ns.currentRoll
	env.__state.unitNames.raid2 = nil
	env.__state.groupMembers = 2
	env.__state.unitNames.raid2 = "Aero"
	Fake.advance(env, 1)
	check(not session.open, "the roll closes rather than waiting on a pause nobody will lift")
end)

test("in a tie-break the caller is one of the tied, End Early waits for them too", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Aero" })
	ns.db.profile.rollEndWhenAllRolled = true
	local session = ns:StartRoll(STRIKERS_MARK)
	roll(ns, env, "Aero", 50)
	roll(ns, env, "Tester", 50)
	Fake.advance(env, 1)
	checkEqual(2, session.round, "a tie-break opens between Aero and the caller")
	roll(ns, env, "Aero", 40)
	Fake.advance(env, 1)
	check(session.open, "the tie-break waits for the caller's roll")
	roll(ns, env, "Tester", 60)
	Fake.advance(env, 1)
	checkEqual("Tester", session.winner and session.winner.name, "and the caller can win it")
end)

test("a roll saved mid-way goes back to waiting after a /reload", function()
	local ns = loadLootWindows()
	ns.db.char.rollList = {
		{
			key = "floor:17011",
			link = itemLink(17011, "Lava Core"),
			itemId = 17011,
			count = 2,
			source = ns.LOOT_SOURCE_FLOOR,
			status = ns.ENTRY_ROLLING,
			sessionId = "gone",
		},
	}
	fire(ns, "PLAYER_LOGIN")
	checkEqual(ns.ENTRY_WAITING, ns:GetRollListEntries()[1].status, "it waits for a roll again")
end)

test("disqualifying a winner moves the win on the Drops tab too", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Aero", "Bob" })
	knownItem(env, 17069, "Striker's Mark", 4, 2)
	fire(ns, "ENCOUNTER_END", 664, "Magmadar", 9, 40, 1)
	env.__state.lootSlots = { { link = STRIKERS_MARK, source = "Creature-0-1-2-3-11982-0" } }
	fire(ns, "LOOT_OPENED")
	local session = ns:StartRoll(STRIKERS_MARK)
	roll(ns, env, "Aero", 90)
	roll(ns, env, "Bob", 80)
	Fake.advance(env, 22)
	local drop = ns:GetDropRaids()[1].bosses[1].items[1]
	checkEqual("Aero", drop.winner, "the drop names the winner")
	ns:DisqualifyRoll(session, rollFor(session, "Aero"), "NONE")
	checkEqual("Bob", drop.winner, "and the new one after a disqualification")
	checkEqual(80, drop.value, "with their roll")
end)

--------------------------------------------------------------------------------
-- Loot Master: Trade Clock, Roll List, Floor Loot, Drops
--------------------------------------------------------------------------------

test("the trade clock is read off the tooltip in the client's own words", function()
	local ns, env = loadLootWindows()
	local function seconds(duration)
		return ns.ParseTradeTimeLine(env.BIND_TRADE_TIME_REMAINING:format(duration))
	end
	checkEqual(6120, seconds("1 hour 42 min"), "hours and minutes")
	checkEqual(7500, seconds("2 hrs 5 min"), "the plural form")
	checkEqual(2520, seconds("42 min"), "minutes alone")
	check(ns.ParseTradeTimeLine("Soulbound") == nil, "another line is no clock")
end)

local function putTradable(env, bagIndex, slotIndex, itemIdentifier, name, duration)
	knownItem(env, itemIdentifier, name, 4, 2, { bindType = 1 })
	return putInBag(env, bagIndex, slotIndex, itemIdentifier, name, {
		tooltipLines = { duration and env.BIND_TRADE_TIME_REMAINING:format(duration) or "Soulbound" },
	})
end

test("tradable Bind on Pickup loot joins the Roll List with its clock, and leaves with the item", function()
	local ns, env = loadLootWindows()
	putTradable(env, 0, 1, 17069, "Striker's Mark", "1 hour 30 min")
	putTradable(env, 0, 2, 17073, "Earthshaker", nil)
	ns:ScanTradableLoot()
	local entries = ns:GetRollListEntries()
	checkEqual(1, #entries, "only the item still on a clock joins")
	checkEqual(5400, ns:GetEntrySecondsLeft(entries[1]), "with its time left")
	env.__state.bags[0][1] = nil
	ns:ScanTradableLoot()
	checkEqual(0, #ns:GetRollListEntries(), "and it leaves once the bags no longer hold it")
end)

test("the low-time warning prints once, and a clock that runs out turns the item soulbound", function()
	local ns, env = loadLootWindows()
	putTradable(env, 0, 1, 17069, "Striker's Mark", "11 min")
	ns:ScanTradableLoot()
	fire(ns, "PLAYER_LOGIN")
	env.__state.serverTime = 1700000000 + 61
	Fake.advance(env, 1)
	check(printedContaining(env, "can be traded for 10 more minutes") ~= nil, "the warning prints")
	env.__state.serverTime = 1700000000 + 700
	Fake.advance(env, 1)
	checkEqual(ns.ENTRY_EXPIRED, ns:GetRollListEntries()[1].status, "and the item reads as soulbound now")
end)

test("Roll All works down the Roll List in order and says when it's done", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Aero" })
	putTradable(env, 0, 1, 17069, "Striker's Mark", "1 hour")
	putTradable(env, 0, 2, 17073, "Earthshaker", "1 hour")
	ns:ScanTradableLoot()
	local first, second = ns:GetRollListEntries()[1], ns:GetRollListEntries()[2]
	ns:MoveRollListEntry(second, -1)
	checkEqual(second, ns:GetRollListEntries()[1], "an entry moves up")
	ns:StartRollAll()
	check(chatContaining(env, "Rolling these off in order:") ~= nil, "the order is posted")
	Fake.advance(env, 5)
	checkEqual(
		second.key,
		ns.currentRoll and ns.currentRoll.entryKey,
		"the first in the player's order is called first"
	)
	roll(ns, env, "Aero", 60)
	Fake.advance(env, 22)
	checkEqual(ns.ENTRY_WON, second.status, "it is won")
	Fake.advance(env, 6)
	checkEqual(first.key, ns.currentRoll and ns.currentRoll.entryKey, "then the next is called")
	Fake.advance(env, 22)
	checkEqual(ns.ENTRY_NOBODY, first.status, "nobody rolled on it")
	Fake.advance(env, 6)
	check(printedContaining(env, "Roll All is done") ~= nil, "and Roll All says it's done")
	check(not ns.rollAll.running, "and stops")
end)

test("a winner's trade gets what they won put in, and the trade moves it to Awarded", function()
	local ns, env = loadLootWindows()
	joinRaid(env, { "Aero" })
	putTradable(env, 0, 1, 17069, "Striker's Mark", "1 hour")
	ns:ScanTradableLoot()
	local entry = ns:GetRollListEntries()[1]
	ns:RollEntry(entry)
	roll(ns, env, "Aero", 60)
	Fake.advance(env, 22)
	env.__state.unitNames.npc = "Aero"
	fire(ns, "TRADE_SHOW")
	Fake.advance(env, 1)
	checkEqual(1, env.__state.pickedUpItems and #env.__state.pickedUpItems or 0, "the item is picked up from the bags")
	checkEqual(1, env.__state.tradeClicks and env.__state.tradeClicks[1], "into the first trade slot")
	check(printedContaining(env, "in the trade window for") ~= nil, "and the player is told")
	ns.OnLootMasterTradeCompleted("Aero", { [1] = { link = entry.link, count = 1 } })
	checkEqual(0, #ns:GetRollListEntries(), "the traded item leaves the Roll List")
	checkEqual("Aero", ns:GetAwarded()[1].winner, "for Awarded")
end)

test("Floor Loot starts empty and rolls a whole stack", function()
	local ns, env = loadLootWindows()
	knownItem(env, 17011, "Lava Core", 3, 7)
	putInBag(env, 0, 1, 17011, "Lava Core", { count = 3 })
	putInBag(env, 0, 2, 17011, "Lava Core", { count = 1 })
	checkEqual(0, #ns:GetFloorLoot(), "nothing is on it to start")
	checkEqual(17011, ns:ResolveFloorLootInput("lava"), "a name finds the item in the bags")
	check(ns:AddFloorLoot(17011), "it is added")
	check(not ns:AddFloorLoot(17011), "only once")
	local entry = ns:AddFloorLootToRollList(17011)
	checkEqual(4, entry and entry.count, "one roll for everything the bags hold")
	checkEqual(entry, ns:GetFloorLootEntry(17011), "and the list knows it's on the Roll List")
end)

test("drops go under the boss that was killed, trash under Trash, and print as one line each", function()
	local ns, env = loadLootWindows()
	knownItem(env, 16805, "Felheart Gloves", 4, 4)
	knownItem(env, 17011, "Lava Core", 3, 7)
	fire(ns, "ENCOUNTER_END", 663, "Lucifron", 9, 40, 1)
	env.__state.lootSlots =
		{ { link = itemLink(16805, "Felheart Gloves", "a335ee"), source = "Creature-0-1-2-3-12118-0" } }
	fire(ns, "LOOT_OPENED")
	env.__state.lootSlots = { { link = itemLink(17011, "Lava Core", "0070dd"), source = "Creature-0-1-2-3-11666-0" } }
	fire(ns, "LOOT_OPENED")
	local raid = ns:GetDropRaids()[1]
	checkEqual("Lucifron", raid.bosses[1].name, "the boss is recorded")
	checkEqual(1, #raid.bosses[1].items, "with its drop")
	checkEqual(1, #raid.bosses[2].items, "and the other corpse's drop goes under Trash")
	ns:PrintDrops()
	check(printedContaining(env, "Lucifron: ") ~= nil, "the boss prints as a line of its own")
	check(printedContaining(env, "Trash: ") ~= nil, "and so does the trash")
end)

--------------------------------------------------------------------------------
-- Report
--------------------------------------------------------------------------------

print(("GogoLoot tests: %d passed, %d failed"):format(Suite.passed, Suite.failed))
for _, failure in ipairs(Suite.failures) do
	print("  FAIL " .. failure)
end
os.exit(Suite.failed == 0 and 0 or 1)
