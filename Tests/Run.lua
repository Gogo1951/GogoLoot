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

--[[
    For the options-layout widths, which are sums and differences of fractions:
    0.115 + 0.14 + (1.3 - 0.255) is 1.3 in every sense that matters to a panel
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

test("auto loot is enforced only while speedy loot is on", function()
	local ns, env = loadAddon()

	ns.db.global.speedyLoot = false
	fire(ns, "PLAYER_ENTERING_WORLD")
	checkEqual(0, autoLootChecksScheduled(ns, env), "nothing scheduled while Speedy Loot is off")

	ns.db.global.speedyLoot = true
	fire(ns, "PLAYER_ENTERING_WORLD")
	checkEqual(1, autoLootChecksScheduled(ns, env), "the check is scheduled once Speedy Loot is on")

	fire(ns, "PLAYER_ENTERING_WORLD")
	checkEqual(1, autoLootChecksScheduled(ns, env), "and only once, not on every loading screen")
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
	check(not evaluate(popupArgs.lootThresholdRow.hidden), "threshold shown under master loot")
	check(not evaluate(popupArgs.lootThresholdRow.hidden), "and its label with it")

	state.lootMethod = 3 -- Group loot: the threshold still decides what rolls.
	check(not evaluate(popupArgs.lootThresholdRow.hidden), "threshold shown under group loot")

	state.lootMethod = 4 -- Need before greed: quality still decides what rolls.
	check(not evaluate(popupArgs.lootThresholdRow.hidden), "threshold shown under need before greed")

	state.lootMethod = 1 -- Round robin: whole drops in turn, quality ignored.
	check(evaluate(popupArgs.lootThresholdRow.hidden), "threshold hidden under round robin")

	state.lootMethod = 0 -- Free for all.
	check(evaluate(popupArgs.lootThresholdRow.hidden), "threshold hidden under free for all")
	check(evaluate(popupArgs.lootThresholdRow.hidden), "its label hidden with it, never orphaned")
	check(evaluate(popupArgs.spacerAfterLootType.hidden), "the paired spacer hidden too, so no double gap")
	check(not evaluate(popupArgs.lootTypeRow.hidden), "the loot method itself stays visible")

	check(evaluate(panelArgs.lootThresholdRow.hidden), "the options panel hides it on the same terms")
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
	check(evaluate(popupArgs.lootTypeRow.args.control2.disabled), "loot method greyed out for a member")
	check(evaluate(popupArgs.lootThresholdRow.args.control2.disabled), "loot threshold greyed out for a member")
	check(not evaluate(popupArgs.sendAllRow.args.control2.disabled), "the destination stays usable")
	check(evaluate(panelArgs.lootTypeRow.args.control2.disabled), "the options panel greys the method out too")
	check(evaluate(panelArgs.lootThresholdRow.args.control2.disabled), "and the threshold")

	state.leaderUnit = "player"
	check(not evaluate(popupArgs.lootTypeRow.args.control2.disabled), "the leader can change the method")
	check(not evaluate(popupArgs.lootThresholdRow.args.control2.disabled), "and the threshold")

	-- Solo there is no group to set a method for, so both stay greyed.
	state.inGroup = false
	check(evaluate(popupArgs.lootTypeRow.args.control2.disabled), "greyed out again once solo")
	check(evaluate(popupArgs.lootThresholdRow.args.control2.disabled), "threshold greyed out once solo")
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

	local popupArgs = ns.BuildMasterLooterPopupOptions().args

	state.lootMethod = 2
	check(not evaluate(popupArgs.sendAllRow.hidden), "shown under master loot")
	check(not evaluate(popupArgs.sendAllRow.hidden), "and its label with it")

	state.lootMethod = 3
	check(evaluate(popupArgs.sendAllRow.hidden), "hidden under group loot")
	check(evaluate(popupArgs.sendAllRow.hidden), "its label hidden with it")

	state.lootMethod = 0
	check(evaluate(popupArgs.sendAllRow.hidden), "hidden under free for all")

	-- The Loot Destinations block on the panel is deliberately always visible.
	local panelArgs = ns.BuildMasterLooterOptions().args
	check(not evaluate(panelArgs.sendAllRow.hidden), "the options panel keeps its row on show")
end)

--[[
    The sub-options under Automated Master Looting change nothing while the
    master switch above them is off — ns:WillAutoMasterLoot returns false
    outright then — so they grey out with it. The indent alone only implies the
    hierarchy; this is what states it.
]]
test("the master looter panel hides everything behind its master switch", function()
	local ns = loadAddon()
	local args = ns.BuildMasterLooterOptions().args

	local alwaysShown = {
		autoDesc = true,
		spacerAfterAutoDesc = true,
		autoMasterLoot = true,
	}

	ns.db.profile.autoMasterLoot = false
	for key, entry in pairs(args) do
		if alwaysShown[key] then
			check(not evaluate(entry.hidden), key .. " stays on show — it is the switch itself, or leads to it")
		else
			check(evaluate(entry.hidden), key .. " hides while automated master looting is off")
		end
	end
end)

--[[
    The sweep composes with whatever a row already answered to rather than
    replacing it: a threshold row still hides under Free for All, a tier row
    still hides below the loot threshold, and turning the master switch back on
    must not drag either of them into view.
]]
test("the master switch is an extra reason to hide, not a replacement", function()
	local ns, env = loadAddon()
	local state = env.__state
	local args = ns.BuildMasterLooterOptions().args

	ns.db.profile.autoMasterLoot = true
	ns.db.global.showDestinationTiers = true

	state.lootMethod = 0 -- Free for All: no threshold to apply.
	check(evaluate(args.lootThresholdRow.hidden), "the threshold row keeps its own reason to hide")

	state.lootMethod = 2
	check(not evaluate(args.lootThresholdRow.hidden), "and shows once that reason is gone")
	check(evaluate(args.destRow_poor.hidden), "a tier below the loot threshold stays hidden too")
	check(not evaluate(args.destRow_epic.hidden), "while one above it is drawn")
end)

--[[
    A sub-option is indented by the blank cell its row leads with, not by padding
    its caption: AceConfig pins a checkbox at the left edge of its own widget, so
    padding would move the words and leave the box lined up with its parent's.
    The row wrapper is what keeps the pair together on one line.
]]
test("sub-options are indented by a leading cell, not by padded captions", function()
	local ns = loadAddon()
	local args = ns.BuildMasterLooterOptions().args

	for _, key in ipairs({
		"outsideInstancesRow",
		"questItemsRow",
		"outsideInstancesCaution",
		"questItemsNote",
		"questItemsCaution",
		"setTiersIndividually",
		"destRow_epic",
	}) do
		local row = args[key]
		checkEqual("group", row.type, key .. " is a row wrapper")
		check(row.inline, key .. " renders as a bare SimpleGroup, so it takes a line of its own")
		checkEqual("", row.name, key .. " draws no title")
		check((row.args.indent.width or 0) > 0, key .. " leads with a blank indent cell")

		-- A caption may be a function, exactly as AceConfig's `name` accepts.
		local caption = row.args.control1.name
		if type(caption) == "function" then
			caption = caption()
		end
		check(not caption:find("^%s"), key .. " does not also pad its caption")
	end

	local noteIndent = args.questItemsNote.args.indent.width
	local optionIndent = args.questItemsRow.args.indent.width
	check(noteIndent > optionIndent, "a note clears the checkbox, so it aligns under the caption above it")
end)

--[[
    Both quest-item notes answer the question somebody asks BEFORE ticking the
    toggle — whether their threshold can reach a quest item at all, and whether
    this suits the group they are in — so neither may wait for it to be on.
]]
test("the quest item notes are readable before the toggle is ticked", function()
	local ns = loadAddon()
	local args = ns.BuildMasterLooterOptions().args

	for _, enabled in ipairs({ false, true }) do
		ns.db.profile.autoMasterLootQuestItems = enabled
		local state = enabled and "on" or "off"
		check(not evaluate(args.questItemsNote.hidden), "the note shows while quest items is " .. state)
		check(not evaluate(args.questItemsCaution.hidden), "and the caution with it, quest items " .. state)
	end

	check(args.spacerBetweenQuestItemNotes ~= nil, "a blank line separates the two")
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
    Poor below — enough to prove the collapse and the threshold rule are
    separate gates rather than one standing in for the other.
]]
test("the quality tier rows collapse behind their toggle", function()
	local ns = loadAddon()
	local args = ns.BuildMasterLooterOptions().args

	ns.db.global.showDestinationTiers = false
	check(evaluate(args.destRow_epic.hidden), "epic row hidden while collapsed")
	check(evaluate(args.spacer_dest_epic.hidden), "and its spacer, so no blank line is stranded")
	check(not evaluate(args.sendAllRow.hidden), "Send All Loot To stays on show")
	check(not evaluate(args.setTiersIndividually.hidden), "and so does the toggle that collapsed them")

	ns.db.global.showDestinationTiers = true
	check(not evaluate(args.destRow_epic.hidden), "epic row shown once expanded")
	check(evaluate(args.destRow_poor.hidden), "poor stays hidden — it is below the loot threshold")
end)

--[[
    A tier row is a control row, so it indents to the same cell as the toggle
    that reveals it — the two share a left edge and the block reads as one
    column, rather than the rows stepping in again under the toggle's caption.
    Its label is narrowed by exactly that cell, which is what keeps the dropdown
    beside it in the same column as Send All Loot To directly above.
]]
test("indenting a tier row leaves its dropdown in the panel's column", function()
	local ns = loadAddon()
	local args = ns.BuildMasterLooterOptions().args
	local row = args.destRow_epic

	--[[
	    A label lines up with a checkbox's visible square, not with the left edge
	    of its artwork, so a row under a toggle spends that toggle's indent plus
	    the inset the artwork hides behind.
	]]
	checkNear(
		args.setTiersIndividually.args.indent.width + ns.OPTIONS_CHECKBOX_INSET_WIDTH,
		row.args.indent.width,
		"the row lines up with the square of the toggle that reveals it"
	)
	checkEqual(ns.OPTIONS_CONTROL_WIDTH, row.args.control2.width, "the dropdown keeps the shared control width")
	checkNear(
		ns.OPTIONS_LABEL_WIDTH,
		row.args.indent.width + row.args.control1.width,
		"and the indent plus the label still spends exactly one label column, so the dropdown does not shift"
	)
	checkNear(
		ns.OPTIONS_ROW_WIDTH,
		row.args.indent.width + row.args.control1.width + row.args.control2.width,
		"leaving the whole row on the panel's shared right edge"
	)
end)

--[[
    Panel order, top to bottom: what GogoLoot does first, then the group's own
    loot settings it merely reads, then destinations, then the ignore list. The
    opening block carries no header of its own — the tab is already titled Master
    Looter and that block is what the title describes.
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
	check(order("questItemsCaution") < order("masterLooterPopup"), "then the pop-up toggle, below them")
	check(order("masterLooterPopup") < order("currentLootHeader"), "then Current Loot Settings")
	check(order("currentLootHeader") < order("leaderNote"), "which opens on who controls it")
	check(order("leaderNote") < order("lootTypeRow"), "then the loot method")
	check(order("lootTypeRow") < order("lootThresholdRow"), "then the threshold")
	check(order("lootThresholdRow") < order("destHeader"), "then Loot Destinations")
	check(order("destHeader") < order("ignoreHeader"), "and the Ignore List last")
end)

--[[
    One statement of who controls the loot settings, naming the leader whoever
    that is. It reads as a fact about whose group it is rather than as a
    complaint about a greyed control, so it stays up when the leader is you —
    and goes only while solo, where there is nobody to name.
]]
test("the leader note names whoever leads, the player included", function()
	local ns, env = loadAddon()
	local state = env.__state
	local args = ns.BuildMasterLooterOptions().args
	local note = args.leaderNote

	state.inGroup = false
	state.leaderUnit = nil
	check(evaluate(note.hidden), "nothing to say while solo")
	check(evaluate(args.spacerAfterLeaderNote.hidden), "and no blank line left behind")

	state.inGroup = true
	state.groupMembers = 2
	state.leaderUnit = "party1"
	state.unitNames.party1 = "Hippobob"
	check(not evaluate(note.hidden), "it appears once somebody else leads")
	check(note.name():find("Hippobob", 1, true) ~= nil, "and names them")
	check(evaluate(args.lootTypeRow.args.control2.disabled), "which is when the dropdowns are greyed")

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
	check(not evaluate(args.lootTypeRow.args.control2.disabled), "with the dropdowns live, since you control them")

	state.inRaid = true
	state.groupMembers = 5
	state.unitNames.raid1 = "Gogoshaman"
	check(not evaluate(note.hidden), "and in a raid you lead")
	check(note.name():find("Gogoshaman", 1, true) ~= nil, "naming you there too")
end)

--[[
    autoGreed is the master switch for every automated roll, the Custom Roll List
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
		spacerAfterToggle = true,
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
    The restore button is the first thing in the Custom Roll List group, so
    without a break it butts straight up against the toggle above and reads as
    part of it rather than as a control of its own.
]]
test("the custom roll list is separated from the toggle above it", function()
	local ns = loadAddon()
	local args = ns.BuildAutomatedRollOptions().args

	check(args.spacerBeforeCustomList ~= nil, "a break sits between the toggle and the list")
	check(args.customListEnable.order < args.spacerBeforeCustomList.order, "after the toggle")
	check(args.spacerBeforeCustomList.order < args.customList.order, "and before the list")
end)

--[[
    Everything on the Announcements panel except its three toggles belongs to one
    of them — a threshold that only applies while its toggle is on, an example of
    what that toggle posts — so each is drawn as a sub-option rather than as one
    of eight peers.
]]
test("the announcement rows are sub-options of the toggles they belong to", function()
	local ns = loadAddon()
	local args = ns.BuildAnnouncementOptions().args

	for _, key in ipairs({
		"destExample",
		"autoThresholdRow",
		"autoExample",
		"tradeConditionRow",
		"tradeOutputRow",
		"tradeExample",
	}) do
		local row = args[key]
		checkEqual("group", row.type, key .. " is a row wrapper")
		check(row.inline, key .. " takes a line of its own")
		checkNear(
			ns.OPTIONS_SUB_CAPTION_INDENT_WIDTH,
			row.args.indent.width,
			key .. " indents under the caption above it"
		)
	end
end)

--[[
    A dropdown configures something that isn't happening while its toggle is off,
    so it goes rather than greying out. The examples stay either way: they are
    what somebody reads to decide whether to turn the thing on, and a feature
    that shows you nothing until you enable it cannot be judged before you do.
]]
test("the announcement dropdowns go with the toggle above them, the examples stay", function()
	local ns = loadAddon()
	local args = ns.BuildAnnouncementOptions().args

	ns.db.profile.announceMasterLootAuto = true
	ns.db.profile.announceTrade = true
	check(not evaluate(args.autoThresholdRow.hidden), "the announce threshold shows while its toggle is on")
	check(not evaluate(args.tradeConditionRow.hidden), "and so does When")
	check(not evaluate(args.tradeOutputRow.hidden), "and Message Output")

	ns.db.profile.announceMasterLootAuto = false
	ns.db.profile.announceTrade = false
	check(evaluate(args.autoThresholdRow.hidden), "the threshold goes with its toggle")
	check(evaluate(args.tradeConditionRow.hidden), "When goes with the trade toggle")
	check(evaluate(args.tradeOutputRow.hidden), "and Message Output with it")

	-- The spacers that paired with them, or the gaps would double up.
	check(evaluate(args.spacerBeforeAutoExample.hidden), "the threshold's trailing spacer goes too")
	check(evaluate(args.spacerBetweenTradeDropdowns.hidden), "and the one between the trade dropdowns")
	check(evaluate(args.spacerBeforeTradeExample.hidden), "and the one before the trade example")

	for _, key in ipairs({ "destExample", "autoExample", "tradeExample", "manualNote" }) do
		check(not evaluate(args[key].hidden), key .. " stays on show whatever the toggles say")
	end
end)

--[[
    These hold short fixed labels rather than player names, so they take less
    than the shared control width. Their left edges still line up, because a row
    pays for its indent out of its label and never out of its control.
]]
test("the announcement dropdowns share a left edge without spending a full row", function()
	local ns = loadAddon()
	local args = ns.BuildAnnouncementOptions().args

	for _, key in ipairs({ "autoThresholdRow", "tradeConditionRow", "tradeOutputRow" }) do
		local row = args[key]
		check(row.args.control2.width < ns.OPTIONS_CONTROL_WIDTH, key .. " is narrower than a name dropdown")
		checkNear(
			ns.OPTIONS_LABEL_WIDTH,
			row.args.indent.width + row.args.control1.width,
			key .. " still spends one label column, so every dropdown starts in the same place"
		)
	end
end)

--[[
    The palette roles carry meaning: HELP is helper text, MUTED is metadata like
    a version number, INFO is a note worth reading. An example of what GogoLoot
    posts is helper text, and the manual-distribution line is a note.
]]
test("announcement examples read as helper text and the manual line as a note", function()
	local ns = loadAddon()
	local args = ns.BuildAnnouncementOptions().args

	for _, key in ipairs({ "destExample", "autoExample", "tradeExample" }) do
		local text = args[key].args.control1.name
		checkEqual(1, text:find(ns.GetColor("HELP"), 1, true), key .. " is helper text, not metadata")
	end

	local noteText = args.manualNote.args.control1.name
	checkEqual(1, noteText:find(ns.GetColor("INFO"), 1, true), "the manual note reads as a note")
end)

--[[
    The suffix speaks for exactly one state. Send All Loot To reads blank both
    when nothing is set and when the tiers disagree — honest about the first,
    silent about the second — so collapsed rows would otherwise hide a per-tier
    setup entirely. Everything the dropdown already says is left unsaid.
]]
test("the collapsed tier toggle reports only what the dropdown cannot", function()
	local ns = loadAddon()
	local args = ns.BuildMasterLooterOptions().args
	local label = args.setTiersIndividually.args.control1.name
	local baseLabel = ns.OptionsSubLabel(ns.L["MASTER_LOOTER_TIERS_INDIVIDUAL"])
	ns.db.global.showDestinationTiers = false

	ns.db.profile.destinations = {}
	checkEqual(baseLabel, label(), "nothing set says nothing — the blank dropdown covers it")

	ns:SetAllDestinations("bob")
	checkEqual(baseLabel, label(), "a shared destination is already named in the dropdown")

	ns.db.profile.destinations.epic = "carol"
	check(label():find("tiers differ", 1, true) ~= nil, "a divergent tier is surfaced")
	checkEqual(nil, ns:GetSharedDestination(), "which is exactly what Send All Loot To cannot show")

	ns.db.global.showDestinationTiers = true
	checkEqual(baseLabel, label(), "and no suffix once the rows say it themselves")
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

	for _, qualityKey in ipairs({ "poor", "common", "uncommon", "rare", "epic" }) do
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
	local ns = loadAddon()
	local questItem = { quality = 2, classId = 12, subclassId = 0, bindType = 1 }
	local questLegendary = { quality = 5, classId = 12, subclassId = 0, bindType = 1 }

	ns.db.profile.autoMasterLootQuestItems = true
	check(not ns:ShouldSkipItemForMasterLoot(questItem), "distribution stops skipping quest items")
	check(ns:ShouldSkipItemForMasterLoot(questLegendary), "the never-automated set is not opted out of")
	check(ns:IsQuestClassItem(questItem), "the roll path's own quest check reads the same as ever")

	ns.db.profile.autoMasterLootQuestItems = false
	check(ns:ShouldSkipItemForMasterLoot(questItem), "and the default still skips them")
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
