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

local Suite = { passed = 0, failed = 0, failures = {}, currentTest = "" }

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

---@param name string
---@param body function
---@return nil
local function test(name, body)
	Suite.currentTest = name
	local ok, err = pcall(body)
	if not ok then
		Suite.failed = Suite.failed + 1
		table.insert(Suite.failures, ("%s: threw %s"):format(name, tostring(err)))
	end
end

--------------------------------------------------------------------------------
-- Add-on loading
--------------------------------------------------------------------------------

-- TOC order, Includes excluded (the Ace libraries are faked).
local FILES = {
	"Locales/enUS.lua",
	"Data/Data.lua",
	"Data/Default-Settings.lua",
	"Features/Core.lua",
	"Features/Utilities.lua",
	"Features/Announcements.lua",
	"Features/Announcements-Trade.lua",
	"Features/Speedy-Loot.lua",
	"Features/Master-Looter.lua",
	"Features/Master-Looter-Distribution.lua",
	"Features/Automated-Rolls.lua",
	"Features/Diagnostics.lua",
	"Features/Minimap-Button.lua",
	"Options/Options-Utilities.lua",
	"Options/Options-General.lua",
	"Options/Options-Master-Looter.lua",
	"Options/Options-Master-Looter-Popup.lua",
	"Options/Options-Automated-Rolls.lua",
	"Options/Options-Announcements.lua",
	"Options/Options-Profiles.lua",
	"Options/Options-Diagnostics.lua",
	"Options/Options.lua",
}

--- Loads the whole add-on into a fresh environment and fires ADDON_LOADED.
---@return table ns, table env
local function loadAddon()
	local env = Fake.newEnvironment()
	local ns = {}

	for _, relative in ipairs(FILES) do
		local path = ROOT .. relative
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

--- A master-loot session holding `count` identical-quality items.
local function openMasterLootSession(ns, env, count)
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
		state.itemNames[itemId] = { name = "Test Item " .. slotIndex, quality = 4, classId = 4, bindType = 2 }
		state.lootSlots[slotIndex] = { link = ("|Hitem:%d|h[Test Item %d]|h"):format(itemId, slotIndex) }
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

test("settings land in the right scope", function()
	local ns = loadAddon()
	check(ns.db.global.showWelcome ~= nil, "showWelcome is account-wide")
	check(ns.db.global.speedyLoot ~= nil, "speedyLoot is account-wide")
	check(rawget(ns.db.profile, "showWelcome") == nil, "showWelcome not left on the profile")
	check(ns.db.profile.autoGreed ~= nil, "roll settings stay per-profile")
end)

--[[
    The Auto Loot CVar is enforced, so the Speedy Loot toggle has to be the
    opt-out: a player who turned Speedy Loot off gets no login-time write.
]]
test("auto loot is enforced only while speedy loot is on", function()
	local ns, env = loadAddon()
	local pending = #env.__state.timers

	ns.db.global.speedyLoot = false
	fire(ns, "PLAYER_ENTERING_WORLD")
	checkEqual(pending, #env.__state.timers, "nothing scheduled while Speedy Loot is off")

	ns.db.global.speedyLoot = true
	fire(ns, "PLAYER_ENTERING_WORLD")
	checkEqual(pending + 1, #env.__state.timers, "the check is scheduled once Speedy Loot is on")

	fire(ns, "PLAYER_ENTERING_WORLD")
	checkEqual(pending + 1, #env.__state.timers, "and only once, not on every loading screen")
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

	ns:RegisterPendingLootAnnouncement(1, "|Hitem:1001|h[Test Item 1]|h", "Bob", true)
	fire(ns, "LOOT_CLOSED")

	check(chatContaining(env, "Test Item 1") ~= nil, "manual hand-out still announced")
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
	check(not evaluate(popupArgs.lootType.hidden), "the loot method itself stays visible")

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
	check(evaluate(popupArgs.lootType.disabled), "loot method greyed out for a member")
	check(evaluate(popupArgs.lootThreshold.disabled), "loot threshold greyed out for a member")
	check(not evaluate(popupArgs.sendAll.disabled), "the destination stays usable")
	check(evaluate(panelArgs.lootType.disabled), "the options panel greys the method out too")
	check(evaluate(panelArgs.lootThreshold.disabled), "and the threshold")

	state.leaderUnit = "player"
	check(not evaluate(popupArgs.lootType.disabled), "the leader can change the method")
	check(not evaluate(popupArgs.lootThreshold.disabled), "and the threshold")

	-- Solo there is no group to set a method for, so both stay greyed.
	state.inGroup = false
	check(evaluate(popupArgs.lootType.disabled), "greyed out again once solo")
	check(evaluate(popupArgs.lootThreshold.disabled), "threshold greyed out once solo")
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

	local popupArgs = ns.BuildMasterLooterPopupOptions().args

	state.lootMethod = 2
	check(not evaluate(popupArgs.sendAll.hidden), "shown under master loot")
	check(not evaluate(popupArgs.sendAllLabel.hidden), "and its label with it")

	state.lootMethod = 3
	check(evaluate(popupArgs.sendAll.hidden), "hidden under group loot")
	check(evaluate(popupArgs.sendAllLabel.hidden), "its label hidden with it")

	state.lootMethod = 0
	check(evaluate(popupArgs.sendAll.hidden), "hidden under free for all")

	-- The Loot Destinations block on the panel is deliberately always visible.
	local panelArgs = ns.BuildMasterLooterOptions().args
	check(not evaluate(panelArgs.sendAll.hidden), "the options panel keeps its row on show")
end)

--[[
    The trade watcher matches UI_INFO_MESSAGE on its numeric id, so these fire
    the id with no message text at all — the way a client that never bound the
    ERR_* global as a string would deliver it.
]]
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
	for key in io.open(ROOT .. "Locales/enUS.lua"):read("a"):gmatch('L%["([A-Z0-9_]+)"%]') do
		enUS[key] = true
	end

	for _, locale in ipairs({ "deDE", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW" }) do
		local body = io.open(ROOT .. "Locales/" .. locale .. ".lua"):read("a")
		local present = {}
		for key in body:gmatch('L%["([A-Z0-9_]+)"%]') do
			present[key] = true
		end
		for key in pairs(enUS) do
			check(present[key], ("%s is missing %s"):format(locale, key))
		end
	end
end)

--------------------------------------------------------------------------------
-- Report
--------------------------------------------------------------------------------

print(("GogoLoot tests: %d passed, %d failed"):format(Suite.passed, Suite.failed))
for _, failure in ipairs(Suite.failures) do
	print("  FAIL " .. failure)
end
os.exit(Suite.failed == 0 and 0 or 1)
