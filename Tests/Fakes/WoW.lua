--[[
    A stubbed WoW + Ace environment, good enough to load every GogoLoot file in
    TOC order and drive its event handlers.

    Namespaced APIs (C_Item, C_Container, Enum, ...) are CONCRETE rather than
    permissive stubs. A catch-all stub returns a table where the client returns a
    string or nil, which manufactures type errors the real client would never
    raise — a false failure costs more than the unstubbed global it saves.

    Not shipped in the TOC: these files never load in game.
]]

local Fake = {}

--- Indexable, callable, returns itself. Only for globals nothing asserts on.
---@param name string
---@return table
local function stub(name)
	return setmetatable({}, {
		__index = function()
			return stub(name)
		end,
		__call = function()
			return stub(name)
		end,
		__tostring = function()
			return "<stub " .. name .. ">"
		end,
	})
end
Fake.stub = stub

--- AceDB applies scalar and table defaults by copying them in, so the fake does
--- the same: migrations that rawget past the metatable must see what the real
--- library would have written.
---@param destination table
---@param source table
---@return nil
local function copyDefaults(destination, source)
	for key, value in pairs(source) do
		if type(value) == "table" then
			if rawget(destination, key) == nil then
				rawset(destination, key, {})
			end
			copyDefaults(destination[key], value)
		elseif rawget(destination, key) == nil then
			rawset(destination, key, value)
		end
	end
end

---@return table
function Fake.newEnvironment()
	local env = {}
	local state = {
		localeTable = {},
		timers = {},
		lootSlots = {},
		masterLootCandidates = {},
		gameMessages = {},
		chat = {},
		prints = {},
		givenLoot = {},
		inGroup = false,
		inRaid = false,
		groupMembers = 0,
		-- Which unit leads ("player", "party1", ...). Nil means nobody does.
		leaderUnit = nil,
		-- Numeric, matching what C_PartyInfo.GetLootMethod returns on Classic Era.
		lootMethod = 3,
		masterLooterPartyIndex = nil,
		setLootMethodCalls = {},
		unitNames = { player = "Tester" },
		itemNames = {},
		-- [rollId] = { itemId, canNeed, canGreed }; canNeed/canGreed default true.
		lootRolls = {},
		-- Every RollOnLoot the add-on issued, in order.
		rollsPerformed = {},
		-- AceDB profile callbacks, by event name, as registered by Core.
		dbCallbacks = {},
		-- Trade slots hold { link, count, quality, enchant }; an unset slot reads nil.
		tradePlayerItems = {},
		tradeTargetItems = {},
		tradePlayerMoney = 0,
		tradeTargetMoney = 0,
	}
	env.__state = state

	local libraries = {
		["AceLocale-3.0"] = {
			NewLocale = function(_, _, locale)
				return locale == "enUS" and state.localeTable or nil
			end,
			GetLocale = function()
				return state.localeTable
			end,
		},
		["AceDB-3.0"] = {
			New = function(_, _, defaults)
				local db = { profile = {}, global = {} }
				copyDefaults(db.profile, defaults.profile or {})
				copyDefaults(db.global, defaults.global or {})
				--[[
				    Callbacks are kept rather than dropped so a test can fire
				    OnProfileChanged the way AceDB would and exercise the real
				    handler — the profile migrations only ever run from there
				    and from login, so a no-op here would leave them untestable.
				]]
				db.RegisterCallback = function(_, event, handler)
					state.dbCallbacks[event] = handler
				end
				db.ResetProfile = function() end
				db.ResetDB = function() end
				return db
			end,
		},
		["AceDBOptions-3.0"] = {
			GetOptionsTable = function()
				return { type = "group", name = "Profiles", args = {} }
			end,
		},
		["AceConfigRegistry-3.0"] = {
			RegisterOptionsTable = function(_, name, builder)
				if builder == nil then
					error("RegisterOptionsTable got nil builder for " .. tostring(name), 2)
				end
				--[[
				    Build immediately, the way AceConfig does on first open, so a
				    broken options table fails here instead of silently in game.
				]]
				if type(builder) == "function" then
					builder()
				end
			end,
			NotifyChange = function() end,
		},
		["AceConfigDialog-3.0"] = {
			AddToBlizOptions = function(_, name)
				return { name = name }, "categoryID:" .. tostring(name)
			end,
			Open = function() end,
			SetDefaultSize = function() end,
		},
		["AceGUI-3.0"] = stub("AceGUI"),
		["LibDataBroker-1.1"] = {
			NewDataObject = function(_, _, object)
				return object
			end,
		},
		["LibDBIcon-1.0"] = stub("LibDBIcon"),
		["CallbackHandler-1.0"] = stub("CallbackHandler"),
	}

	env.LibStub = setmetatable({
		IterateLibraries = function()
			return function() end
		end,
		minors = {},
	}, {
		__call = function(_, name)
			local library = libraries[name]
			if library == nil then
				error("LibStub asked for unstubbed library: " .. tostring(name), 2)
			end
			return library
		end,
	})

	-- Lua standard library
	env.pairs, env.ipairs, env.type, env.tostring, env.tonumber = pairs, ipairs, type, tostring, tonumber
	env.string, env.table, env.math, env.select, env.pcall = string, table, math, select, pcall
	env.rawget, env.rawset, env.setmetatable, env.getmetatable = rawget, rawset, setmetatable, getmetatable
	env.error, env.next, env.assert = error, next, assert
	env.unpack = table.unpack or unpack
	env.print = function(...)
		table.insert(state.prints, table.concat({ ... }, " "))
	end

	-- WoW helpers
	env.wipe = function(t)
		for key in pairs(t) do
			t[key] = nil
		end
		return t
	end
	env.strlower, env.strupper = string.lower, string.upper
	env.hooksecurefunc = function(name, hook)
		state.hooks = state.hooks or {}
		state.hooks[name] = hook
	end

	--[[
	    Timers are collected rather than run, so a test advances time explicitly
	    and asserts on what fired. Real elapsed time would make the suite flaky.
	]]
	env.GetTime = function()
		return state.now or 0
	end
	--[[
	    A ticker re-arms itself after each fire, so a retry loop driven by one
	    actually retries under Fake.advance. Its next due time is one interval
	    past the clock the advance moved to, so a ticker fires once per advance
	    call rather than spinning the whole interval budget in a single step.
	]]
	local function scheduleTicker(seconds, callback)
		local ticker = { cancelled = false }
		ticker.Cancel = function()
			ticker.cancelled = true
		end

		local entry = {}
		entry.at = (state.now or 0) + seconds
		entry.callback = function()
			if ticker.cancelled then
				return
			end
			callback(ticker)
			if not ticker.cancelled then
				entry.at = (state.now or 0) + seconds
				table.insert(state.timers, entry)
			end
		end

		table.insert(state.timers, entry)
		return ticker
	end

	env.C_Timer = {
		After = function(seconds, callback)
			table.insert(state.timers, { at = (state.now or 0) + seconds, callback = callback })
		end,
		NewTicker = scheduleTicker,
		NewTimer = function()
			return { Cancel = function() end }
		end,
	}

	env.WOW_PROJECT_ID, env.WOW_PROJECT_CLASSIC, env.WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 2, 2, 5
	env.NUM_BAG_SLOTS = 4
	env.GogoLootDB = {}
	env.SlashCmdList = {}

	env.IsInGroup = function()
		return state.inGroup
	end
	env.IsInRaid = function()
		return state.inRaid
	end
	env.GetNumGroupMembers = function()
		return state.groupMembers
	end
	--[[
	    True only for the unit that actually leads, so the options rows can tell
	    a leader from a member. Answering true for everything would hide the
	    non-leader path the way a single UnitName once hid the roster walk.
	]]
	env.UnitIsGroupLeader = function(unitIdentifier)
		return state.inGroup and state.leaderUnit ~= nil and unitIdentifier == state.leaderUnit
	end
	--[[
	    Per-unit, not one name for everything: the roster helpers walk party1..N
	    and compare against the player, so a fake that answers "Tester" for every
	    unit makes every group member look like the player.
	]]
	env.UnitName = function(unitIdentifier)
		local name = state.unitNames[unitIdentifier or "player"]
		if not name then
			return nil
		end
		return name, nil
	end
	env.GetRealmName = function()
		return "Test Realm"
	end
	env.GetInstanceInfo = function()
		return "Test", state.instanceType or "raid"
	end
	env.GetLootMethod = nil
	env.C_PartyInfo = {
		GetLootMethod = function()
			return state.lootMethod, state.masterLooterPartyIndex, nil
		end,
	}
	env.GetLootThreshold = function()
		return 2
	end
	-- Legacy setter absent on 1.15.9, exactly like the getter.
	env.SetLootMethod = nil
	env.C_PartyInfo.SetLootMethod = function(enumValue, masterLooterName)
		table.insert(state.setLootMethodCalls, { method = enumValue, masterLooter = masterLooterName })
		state.lootMethod = enumValue
	end
	env.SendChatMessage = function(message, channel)
		table.insert(state.chat, { message = message, channel = channel })
	end

	-- Loot window
	env.GetNumLootItems = function()
		return #state.lootSlots
	end
	env.GetLootSlotLink = function(slotIndex)
		local slot = state.lootSlots[slotIndex]
		return slot and slot.link or nil
	end
	env.GetLootSlotType = function()
		return 1
	end
	env.LOOT_SLOT_ITEM = 1
	env.LootSlot = function() end
	env.GetMasterLootCandidate = function(_, candidateIndex)
		return state.masterLootCandidates[candidateIndex]
	end
	env.GiveMasterLoot = function(slotIndex, candidateIndex)
		table.insert(state.givenLoot, { slotIndex = slotIndex, candidateIndex = candidateIndex })
		if state.hooks and state.hooks.GiveMasterLoot then
			state.hooks.GiveMasterLoot(slotIndex, candidateIndex, true)
		end
	end

	--[[
	    Trade window. The two info functions really do return the service
	    description in different positions: ours at 5 with canLoseTransmog at 6,
	    theirs at 6 with isUsable at 5. The fake keeps that asymmetry so sharing
	    one index between them fails here rather than silently in game.
	]]
	env.GetTradePlayerItemLink = function(slotIndex)
		local slot = state.tradePlayerItems[slotIndex]
		return slot and slot.link or nil
	end
	env.GetTradeTargetItemLink = function(slotIndex)
		local slot = state.tradeTargetItems[slotIndex]
		return slot and slot.link or nil
	end
	env.GetTradePlayerItemInfo = function(slotIndex)
		local slot = state.tradePlayerItems[slotIndex]
		if not slot then
			return nil
		end
		return slot.name or "Traded Item", 0, slot.count or 1, slot.quality or 2, slot.enchant, false
	end
	env.GetTradeTargetItemInfo = function(slotIndex)
		local slot = state.tradeTargetItems[slotIndex]
		if not slot then
			return nil
		end
		return slot.name or "Traded Item", 0, slot.count or 1, slot.quality or 2, true, slot.enchant
	end
	env.GetPlayerTradeMoney = function()
		return state.tradePlayerMoney or 0
	end
	env.GetTargetTradeMoney = function()
		return state.tradeTargetMoney or 0
	end

	--[[
	    GetGameMessageInfo maps a numeric id to its constant name; the error
	    correlation resolves names to ids through it, so the fake owns that table
	    and tests fire errors by constant name.
	]]
	env.GetGameMessageInfo = function(index)
		return state.gameMessages[index]
	end

	env.IsModifiedClick = function()
		return false
	end
	env.GetCVar = function()
		return "1"
	end
	env.SetCVar = function() end
	env.C_CVar = {
		GetCVarBool = function()
			return true
		end,
	}
	env.GetBuildInfo = function()
		return "1.15.9", "68940", nil, 11509
	end
	env.GetLocale = function()
		return "enUS"
	end
	env.C_EventUtils = {
		IsEventValid = function()
			return true
		end,
	}
	env.C_AddOns = {
		GetAddOnMetadata = function()
			return "2026.08.01.A"
		end,
	}
	env.C_Container = {
		GetContainerNumFreeSlots = function()
			return 4, 0
		end,
	}
	--[[
	    Era HAS an Enum table but no Enum.LootMethod / ItemBind / ItemClass, so an
	    empty table is the faithful shape. nil is wrong twice over: the catch-all
	    metatable would hand back a permissive stub, and `Enum and Enum.X` would
	    then be truthy, skipping the numeric paths that are live on this flavor.
	]]
	env.Enum = {}

	local function getItemInfo(identifier)
		local itemId = tonumber(tostring(identifier):match("item:(%d+)") or identifier)
		local entry = itemId and state.itemNames[itemId]
		if not entry then
			return nil
		end
		return entry.name,
			("|Hitem:%d|h[%s]|h"):format(itemId, entry.name),
			entry.quality or 2,
			0,
			0,
			"",
			"",
			1,
			"",
			0,
			0,
			entry.classId or 4,
			entry.subclassId or 0,
			entry.bindType or 2
	end
	env.GetItemInfo = getItemInfo
	env.GetItemInfoInstant = function()
		return nil
	end
	env.C_Item = {
		GetItemInfo = getItemInfo,
		GetItemInfoInstant = function()
			return nil
		end,
	}

	--[[
	    Loot rolls. A roll's quality and BoP flag are read back out of
	    state.itemNames rather than stored on the roll, so a test describes an
	    item once and GetLootRollItemInfo and GetItemInfo cannot disagree about
	    it — EvaluateRoll consults both in turn, and a fake that let them drift
	    would be testing a client state that cannot occur.

	    A roll whose item has no itemNames entry is an UNCACHED item, and reads
	    exactly like the real client's: nil link here, nil name from
	    GetLootRollItemInfo, nil from GetItemInfo. A test models the item query
	    answering by filling in state.itemNames mid-flight — which is how the
	    war-effort-token cache race is reproduced.
	]]
	env.GetLootRollItemLink = function(rollIdentifier)
		local roll = state.lootRolls[rollIdentifier]
		if not roll then
			return nil
		end
		local entry = state.itemNames[roll.itemId]
		if not entry then
			return nil
		end
		return ("|Hitem:%d|h[%s]|h"):format(roll.itemId, entry.name)
	end

	env.GetLootRollItemInfo = function(rollIdentifier)
		local roll = state.lootRolls[rollIdentifier]
		if not roll then
			return nil
		end
		local entry = state.itemNames[roll.itemId] or {}
		local canNeed = roll.canNeed
		if canNeed == nil then
			canNeed = true
		end
		local canGreed = roll.canGreed
		if canGreed == nil then
			canGreed = true
		end
		-- texture, name, count, quality, bindOnPickUp, canNeed, canGreed, canDisenchant
		return "texture", entry.name, 1, entry.quality or 2, (entry.bindType or 2) == 1, canNeed, canGreed, false
	end

	env.RollOnLoot = function(rollIdentifier, rollAction)
		table.insert(state.rollsPerformed, { rollIdentifier = rollIdentifier, action = rollAction })
	end

	env.CreateFrame = function()
		local frame = { scripts = {}, events = {} }
		function frame:SetScript(key, handler)
			self.scripts[key] = handler
		end
		function frame:GetScript(key)
			return self.scripts[key]
		end
		function frame:RegisterEvent(event)
			self.events[event] = true
		end
		function frame:UnregisterEvent(event)
			self.events[event] = nil
		end
		--[[
		    A font string is an object the caller then positions and writes to, so
		    it answers like one. The catch-all below returns nil, which would error
		    on the first SetPoint (the trade window's checkbox label).
		]]
		function frame:CreateFontString()
			return setmetatable({}, {
				__index = function()
					return function() end
				end,
			})
		end
		return setmetatable(frame, {
			__index = function()
				return function() end
			end,
		})
	end

	--[[
	    Globals Classic Era genuinely does not have, which the catch-all below
	    must therefore NOT manufacture. A stub is truthy, so it wins the
	    `LE_ITEM_CLASS_x or Enum.ItemClass.x or <number>` chain in Data.lua and
	    leaves ns.ITEM_CLASS_QUEST holding a table no classId can ever equal —
	    which silently disables every class-based skip for the whole suite.
	    Same reasoning as the header note about namespaced APIs: a permissive
	    stub in the wrong place buys nothing and hides real failures.
	]]
	local absentGlobals = {
		LE_ITEM_CLASS_RECIPE = true,
		LE_ITEM_CLASS_QUESTITEM = true,
		LE_ITEM_CLASS_MISCELLANEOUS = true,
	}

	-- Anything not named above resolves to a permissive stub.
	setmetatable(env, {
		__index = function(_, key)
			if absentGlobals[key] then
				return nil
			end
			return stub(key)
		end,
	})

	return env
end

--- Run every timer due at or before `seconds` from now, in schedule order.
---@param env table
---@param seconds number
---@return number # how many callbacks ran
function Fake.advance(env, seconds)
	local state = env.__state
	state.now = (state.now or 0) + seconds

	local ran = 0
	local guard = 0
	while guard < 100 do
		guard = guard + 1
		local dueIndex
		for index, timer in ipairs(state.timers) do
			if timer.at <= state.now then
				dueIndex = index
				break
			end
		end
		if not dueIndex then
			break
		end
		local timer = table.remove(state.timers, dueIndex)
		timer.callback()
		ran = ran + 1
	end
	return ran
end

return Fake
