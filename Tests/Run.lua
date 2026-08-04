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
-- Automated Rolls: Custom Roll List vs the type skips
--------------------------------------------------------------------------------

--[[
    Starts one live roll on `itemId` and returns the rolls the add-on issued.

    classId defaults to 12 (Quest) and bindType to 1 (BoP), which is what the
    Ahn'Qiraj and Zul'Gurub tokens the default list exists for actually report.
    That combination used to be the silent failure: correct ids, correct saved
    action, and a blanket type skip ahead of the list meant no roll ever went
    out. Every test below leans on it, so it is the default rather than
    something each one has to remember to spell.
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

test("a quest-class item on the Custom Roll List rolls the action it was given", function()
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

	checkEqual(0, #rolls, "the Custom Roll List cannot opt a legendary back in")
end)

test("a listed mount is still never rolled", function()
	local ns, env = loadAddon()
	ns.db.profile.ignoredItemsSolo[40003] = ns.NEED

	local rolls = startRoll(ns, env, 40003, { quality = 4, classId = ns.ITEM_CLASS_MISCELLANEOUS, subclassId = 5 })

	checkEqual(0, #rolls, "the Custom Roll List cannot opt a mount back in")
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

test("the master switch still silences the Custom Roll List", function()
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

test("master-loot distribution still skips quest items outright", function()
	local ns = loadAddon()

	local questItem = { quality = 2, classId = 12, subclassId = 0, bindType = 1 }
	check(ns:ShouldSkipItemByType(questItem), "the full skip still covers quest-class items")
	check(not ns:IsNeverAutomatedItem(questItem), "but they are not in the never-automated set")
end)

--------------------------------------------------------------------------------
-- War-effort token defaults and their migration
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

test("an established profile picks up the new tokens without losing its own choices", function()
	local ns, env = loadAddon()
	local rollList = ns.db.profile.ignoredItemsSolo

	--[[
	    Rewind to a profile seeded before the tokens shipped: the new ids
	    absent, the AQ40 idols still sitting at the Manual they used to
	    default to, and the migration marker cleared.
	]]
	ns.db.profile.ahnQirajTokenRollDefaultsApplied = nil
	for _, itemIdentifier in ipairs({ 20866, 20873, 21156, 21761, 21762, 22373, 22374, 22375, 22376 }) do
		rollList[itemIdentifier] = nil
	end
	for _, itemIdentifier in ipairs({ 20874, 20875, 20876, 20877, 20878, 20879, 20881, 20882 }) do
		rollList[itemIdentifier] = ns.MANUAL
	end
	-- ...except one idol the player had already decided about, and one they deleted.
	rollList[20882] = ns.PASS
	rollList[20858] = nil

	env.__state.dbCallbacks.OnProfileChanged()

	checkEqual(ns.NEED, rollList[20866], "Azure Idol was added at Need")
	checkEqual(ns.NEED, rollList[21761], "Scarab Coffer Key was added at Need")
	checkEqual(ns.MANUAL, rollList[22373], "Wartorn Leather Scrap was added at Manual")
	checkEqual(ns.NEED, rollList[20874], "Idol of the Sun moved off the old Manual default")
	checkEqual(ns.PASS, rollList[20882], "an idol the player had already set kept that action")
	checkEqual(nil, rollList[20858], "a scarab the player deleted stayed deleted")

	-- Second pass changes nothing: the marker makes it a one-shot per profile.
	rollList[20874] = ns.MANUAL
	env.__state.dbCallbacks.OnProfileChanged()
	checkEqual(ns.MANUAL, rollList[20874], "the migration did not fire twice")
end)

--------------------------------------------------------------------------------
-- Report
--------------------------------------------------------------------------------

print(("GogoLoot tests: %d passed, %d failed"):format(Suite.passed, Suite.failed))
for _, failure in ipairs(Suite.failures) do
	print("  FAIL " .. failure)
end
os.exit(Suite.failed == 0 and 0 or 1)
