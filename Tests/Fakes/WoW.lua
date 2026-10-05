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
--- the same: code reading the saved tables sees what the real library writes.
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
		unitRealms = {},
		-- Every AceConfigDialog:AddToBlizOptions call, in order.
		blizOptions = {},
		-- AceConfigDialog status tables by registry name.
		dialogStatus = {},
		itemNames = {},
		itemsNotOnClient = {},
		-- GetItemStats tables by item id, as { ITEM_MOD_STRENGTH_SHORT = 5 }; an item without one reports no stats.
		itemStats = {},
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
		--[[
		    Bags, by bag then slot: { itemId, link, count, locked }. A slot with
		    locked = true carries the client's LOCKED line in its tooltip, which
		    is how the add-on reads a lock. Every bag has bagSlotCount slots.
		]]
		bags = {},
		-- Links in the character's equipped slots, by inventory slot number.
		equipped = {},
		bagSlotCount = 4,
		-- Free general-purpose slots per bag, as GetContainerNumFreeSlots answers.
		freeSlotsPerBag = 4,
		-- Every C_Container.UseContainerItem call, in order: { bag, slot }.
		usedContainerItems = {},
		-- Every LootSlot call, in order, by slot index.
		lootedSlots = {},
		-- Every PlaySound / PlaySoundFile call, in order: { kind, sound }.
		sounds = {},
		-- Tooltip lines an item's hyperlink shows, by item id, for ItemStartsQuest.
		hyperlinkTooltipLines = {},
		-- Interaction windows (MerchantFrame, MailFrame, ...) currently open, by name.
		shownFrames = {},
		inCombat = false,
		inInstance = false,
		stealthed = false,
		-- The player's auras by spell id, as C_UnitAuras.GetPlayerAuraBySpellID answers: { spellId }.
		playerAuras = {},
		-- True while C_Secrets says an aura would read secret, as in a WoW Forever encounter or PvP match.
		secretAuras = false,
		-- True while C_Secrets says the player's casts would read secret, as WoW Forever can in an encounter or PvP.
		secretCasts = false,
		playerClassFile = "WARRIOR",
		playerLevel = 60,
		-- Every LibDataBroker object the add-on made, by name, so a test can click the button.
		brokerObjects = {},
		-- Every frame the add-on created, in order, so a test can find the toasts it drew.
		createdFrames = {},
		-- Every AceGUI widget type the add-on registered, by name, so a test can build one and drive it.
		widgetConstructors = {},
		-- Every error securecallfunction caught, for the suite to report as a failure.
		handlerErrors = {},
		-- Chat message filters the add-on added, by event, in order.
		chatFilters = {},
	}
	env.__state = state
	env._G = env

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
				local db = { profile = {}, global = {}, char = {} }
				--[[
				    A test can seed what an earlier version saved (state.savedProfile)
				    to drive the migrations, which read every profile through db.sv,
				    the saved table itself. As in AceDB, the active profile is the
				    same table there as db.profile.
				]]
				for key, value in pairs(state.savedProfile or {}) do
					db.profile[key] = value
				end
				copyDefaults(db.profile, defaults.profile or {})
				copyDefaults(db.global, defaults.global or {})
				copyDefaults(db.char, defaults.char or {})
				--[[
				    The character's own section is the same table under its key in
				    db.sv.char, as in AceDB, so another character's can sit beside it.
				]]
				db.keys = { char = "Aero - Realm" }
				db.sv = { profiles = { Default = db.profile }, char = { [db.keys.char] = db.char } }
				--[[
				    Callbacks are kept rather than dropped so a test can fire
				    OnProfileChanged the way AceDB would and exercise the real
				    handler. A method name resolves on the target, as it does in
				    CallbackHandler.
				]]
				db.RegisterCallback = function(target, event, handler)
					if type(handler) == "string" then
						local methodName = handler
						handler = function(...)
							return target[methodName](target, ...)
						end
					end
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
			--[[
			    Records every Settings-tree registration in order. The category ID
			    it hands back is unique per registry name, as the client's are, so
			    two panels sharing a title stay distinct.
			]]
			AddToBlizOptions = function(_, appName, name, parent)
				local categoryID = "category:" .. tostring(appName)
				table.insert(state.blizOptions, {
					appName = appName,
					name = name,
					parent = parent,
					categoryID = categoryID,
				})
				--[[
				    The panel frame, which keeps its script hooks so a test can
				    hide it the way the Settings window does.
				]]
				local panelFrame = { name = name, hooks = {} }
				function panelFrame:HookScript(scriptName, hook)
					self.hooks[scriptName] = self.hooks[scriptName] or {}
					table.insert(self.hooks[scriptName], hook)
				end
				state.blizOptions[#state.blizOptions].frame = panelFrame
				return panelFrame, categoryID
			end,
			-- One status table per registry name, as AceConfigDialog keeps them.
			GetStatusTable = function(_, appName)
				state.dialogStatus[appName] = state.dialogStatus[appName] or {}
				return state.dialogStatus[appName]
			end,
			Open = function() end,
			SetDefaultSize = function() end,
		},
		--[[
		    Records each widget type's constructor, and gives a widget it builds
		    the callbacks AceConfigDialog would hang on it, so a test can build
		    one and drive it. Anything else answers as a stub.
		]]
		["AceGUI-3.0"] = setmetatable({
			RegisterWidgetType = function(_, widgetType, constructor)
				state.widgetConstructors[widgetType] = constructor
			end,
			RegisterAsWidget = function(_, widget)
				widget.callbacks = {}
				function widget:SetCallback(event, handler)
					self.callbacks[event] = handler
				end
				function widget:Fire(event, ...)
					local handler = self.callbacks[event]
					if handler then
						handler(self, event, ...)
					end
				end
				function widget:SetHeight() end
				function widget:SetWidth() end
				return widget
			end,
		}, { __index = stub("AceGUI") }),
		["LibDataBroker-1.1"] = {
			NewDataObject = function(_, name, object)
				state.brokerObjects[name] = object
				return object
			end,
		},
		["LibDBIcon-1.0"] = stub("LibDBIcon"),
		["LibSharedMedia-3.0"] = {
			List = function()
				return { "Friz Quadrata TT" }
			end,
			IsValid = function()
				return false
			end,
			Fetch = function()
				return nil
			end,
		},
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
	env.unpack = table.unpack or unpack -- luacheck: ignore 143
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
	--[[
	    Both forms the client has: a global function by name, or a method on a
	    table (GameTooltip's SetBagItem). A method hook is kept on the table, and
	    the fake tooltip runs it after its own SetBagItem, as the client does.
	]]
	env.hooksecurefunc = function(target, methodOrHook, hook)
		state.hooks = state.hooks or {}
		if type(target) == "table" then
			local postHooks = rawget(target, "__postHooks") or {}
			postHooks[methodOrHook] = hook
			rawset(target, "__postHooks", postHooks)
			return
		end
		state.hooks[target] = methodOrHook
	end
	--[[
	    Like the client's, it hands a function's error to the error handler and
	    returns, so one event handler can't stop the next. Here the error handler
	    keeps the error, and the suite reports it as a failure.
	]]
	local function packResults(...)
		return { n = select("#", ...), ... }
	end
	env.securecallfunction = function(func, ...)
		local results = packResults(pcall(func, ...))
		if not results[1] then
			table.insert(state.handlerErrors, results[2])
			return
		end
		return env.unpack(results, 2, results.n)
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
		NewTimer = function(seconds, callback)
			local timer = { cancelled = false }
			timer.Cancel = function()
				timer.cancelled = true
			end
			table.insert(state.timers, {
				at = (state.now or 0) + seconds,
				callback = function()
					if not timer.cancelled then
						callback(timer)
					end
				end,
			})
			return timer
		end,
	}

	env.NUM_BAG_SLOTS = 4
	env.UnitLevel = function()
		return state.playerLevel
	end
	env.GetInventoryItemLink = function(_, slot)
		return state.equipped[slot]
	end
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

	    The second return is state.unitRealms: a realm on most flavors, a last
	    name on WoW Forever, which fills it for the player too.
	]]
	env.UnitName = function(unitIdentifier)
		local unit = unitIdentifier or "player"
		local name = state.unitNames[unit]
		if not name then
			return nil
		end
		return name, state.unitRealms[unit]
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
	env.SendChatMessage = function(message, channel, _, target)
		table.insert(state.chat, { message = message, channel = channel, target = target })
	end

	-- Loot window
	env.GetNumLootItems = function()
		return #state.lootSlots
	end
	env.GetLootSlotLink = function(slotIndex)
		local slot = state.lootSlots[slotIndex]
		return slot and slot.link or nil
	end
	-- A slot is an item (1) unless the test marks it money (slotType = 2).
	env.GetLootSlotType = function(slotIndex)
		local slot = state.lootSlots[slotIndex]
		return slot and slot.slotType or 1
	end
	env.LOOT_SLOT_ITEM = 1
	-- texture, name, quantity, currencyID, quality, locked: a test marks a slot still being rolled for with locked = true.
	env.GetLootSlotInfo = function(slotIndex)
		local slot = state.lootSlots[slotIndex]
		return nil, nil, 1, nil, nil, slot and slot.locked or false
	end
	env.LootSlot = function(slotIndex)
		table.insert(state.lootedSlots, slotIndex)
	end
	-- "Creature-0-...", "Item-0-...": the test sets a slot's source to model a corpse or a disenchant.
	env.GetLootSourceInfo = function(slotIndex)
		local slot = state.lootSlots[slotIndex]
		return slot and slot.source or nil
	end
	env.GetMasterLootCandidate = function(_, candidateIndex)
		return state.masterLootCandidates[candidateIndex]
	end
	-- A post-hook sees exactly the arguments the call was made with, as hooksecurefunc does.
	env.GiveMasterLoot = function(slotIndex, candidateIndex, isAutomated)
		table.insert(state.givenLoot, { slotIndex = slotIndex, candidateIndex = candidateIndex })
		if state.hooks and state.hooks.GiveMasterLoot then
			state.hooks.GiveMasterLoot(slotIndex, candidateIndex, isAutomated)
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
		GetAddOnMetadata = function(_, field)
			if field == "X-Flavor" then
				return "Vanilla"
			end
			return "2026.08.01.A"
		end,
		GetNumAddOns = function()
			return 1
		end,
		GetAddOnInfo = function()
			return "GogoLoot", "GogoLoot", "", true
		end,
		IsAddOnLoaded = function()
			return true
		end,
	}
	env.C_Seasons = {
		GetActiveSeason = function()
			return 0
		end,
	}
	local function bagSlot(bagIndex, slotIndex)
		local bag = state.bags[bagIndex]
		return bag and bag[slotIndex]
	end
	env.C_Container = {
		GetContainerNumFreeSlots = function()
			return state.freeSlotsPerBag, 0
		end,
		GetContainerNumSlots = function()
			return state.bagSlotCount
		end,
		GetContainerItemID = function(bagIndex, slotIndex)
			local slot = bagSlot(bagIndex, slotIndex)
			return slot and slot.itemId or nil
		end,
		GetContainerItemLink = function(bagIndex, slotIndex)
			local slot = bagSlot(bagIndex, slotIndex)
			return slot and slot.link or nil
		end,
		UseContainerItem = function(bagIndex, slotIndex)
			table.insert(state.usedContainerItems, { bag = bagIndex, slot = slotIndex })
		end,
		GetContainerItemInfo = function(bagIndex, slotIndex)
			local slot = bagSlot(bagIndex, slotIndex)
			return slot and { itemID = slot.itemId, stackCount = slot.count or 1, hyperlink = slot.link } or nil
		end,
	}
	--[[
	    Only the Enum tables the add-on reads with no fallback: SeasonID
	    (Data/Flavor.lua) and LootMethod (Features/Master-Looter.lua), with
	    Blizzard's own field names. The item tables Data/Data.lua prefers are
	    left out, so its numeric fallbacks are what the suite runs on. nil would
	    be wrong: the catch-all metatable would hand back a permissive stub, and
	    `Enum and Enum.X` would then be truthy.
	]]
	env.Enum = {
		SeasonID = { SeasonOfDiscovery = 2 },
		LootMethod = { Freeforall = 0, Roundrobin = 1, Masterlooter = 2, Group = 3, Needbeforegreed = 4 },
	}

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
			entry.minLevel or 0,
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
	-- The client's own enUS names for the item classes and the two subclasses the toast filters name.
	local ITEM_CLASS_NAMES = {
		[0] = "Consumable",
		[1] = "Container",
		[2] = "Weapon",
		[3] = "Gem",
		[4] = "Armor",
		[5] = "Reagent",
		[6] = "Projectile",
		[7] = "Trade Goods",
		[9] = "Recipe",
		[11] = "Quiver",
		[12] = "Quest",
		[13] = "Key",
		[15] = "Miscellaneous",
	}
	local ITEM_SUBCLASS_NAMES = { ["15:2"] = "Companion Pets", ["15:5"] = "Mount" }
	env.C_Item = {
		GetItemInfo = getItemInfo,
		GetItemClassInfo = function(classId)
			return ITEM_CLASS_NAMES[classId]
		end,
		GetItemSubClassInfo = function(classId, subclassId)
			return ITEM_SUBCLASS_NAMES[classId .. ":" .. subclassId]
		end,
		-- Answers only for an item a test gave an equipLocation or an item type; every other read stays nil as before.
		GetItemInfoInstant = function(identifier)
			local itemId = tonumber(tostring(identifier):match("item:(%d+)") or identifier)
			local entry = itemId and state.itemNames[itemId]
			if not entry or not (entry.equipLocation or entry.itemType) then
				return nil
			end
			return itemId,
				entry.itemType or "",
				entry.itemSubType or "",
				entry.equipLocation or "",
				0,
				entry.classId or 4,
				entry.subclassId or 0
		end,
		-- Every id exists unless a test lists it in state.itemsNotOnClient.
		DoesItemExistByID = function(itemId)
			return not state.itemsNotOnClient[itemId]
		end,
		RequestLoadItemDataByID = function() end,
		GetItemSpell = function()
			return nil
		end,
		GetItemStats = function(itemLink)
			local itemId = tonumber(tostring(itemLink):match("item:(%d+)"))
			return itemId and state.itemStats[itemId] or {}
		end,
		-- What state.bags holds of the item, each slot counting its `count`, or 1.
		GetItemCount = function(itemId)
			local carried = 0
			for _, bag in pairs(state.bags) do
				for _, slot in pairs(bag) do
					if slot.itemId == itemId then
						carried = carried + (slot.count or 1)
					end
				end
			end
			return carried
		end,
	}
	-- Skill line names by ID, as the skill list shows them; a test may rename one.
	state.skillLineNames = { [633] = "Lockpicking" }
	env.C_TradeSkillUI = {
		GetTradeSkillDisplayName = function(skillLineIdentifier)
			return state.skillLineNames[skillLineIdentifier]
		end,
	}
	env.C_Spell = {
		GetSpellName = function(spellIdentifier)
			return spellIdentifier == 921 and "Pick Pocket" or "Lockpicking"
		end,
		GetSpellInfo = function(spellId)
			return { name = "Lockpicking", spellID = spellId }
		end,
		DoesSpellExist = function()
			return true
		end,
		GetSpellDescription = function()
			return ""
		end,
		RequestLoadSpellData = function() end,
	}
	-- WoW Forever's shape: both getters, so ns.GetTooltipLines reads tooltip data rather than a scan tooltip.
	env.C_TooltipInfo = {
		GetItemByID = function(itemId)
			local entry = state.itemNames[itemId]
			if not entry then
				return nil
			end
			return { lines = { { leftText = entry.name } } }
		end,
		GetSpellByID = function(spellId)
			local info = env.C_Spell.GetSpellInfo(spellId)
			if not info then
				return nil
			end
			return { lines = { { leftText = info.name } } }
		end,
	}
	env.C_QuestLog = {}

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
		-- A roll's suffixId lands in the link's random-suffix field, as "of the Owl" gear's does.
		if roll.suffixId then
			return ("|Hitem:%d::::::%d|h[%s]|h"):format(roll.itemId, roll.suffixId, entry.name)
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

	--[[
	    Widgets the add-on creates and then positions and writes to answer like
	    objects: a catch-all that returns nil would error on the first chained
	    call. Methods nothing asserts on stay no-ops.
	]]
	--[[
	    Widget methods are PascalCase, and a real widget answers any other
	    unset key with nil, so the no-op catch-all covers method names only. A
	    catch-all for every key would make a plain field such as a pooled flag
	    read as set.
	]]
	local function noOpMethod(key)
		if type(key) == "string" and key:match("^%u") then
			return function() end
		end
		return nil
	end
	local function newObject(fields)
		return setmetatable(fields or {}, {
			__index = function(_, key)
				return noOpMethod(key)
			end,
		})
	end
	local function newFontString()
		return newObject({
			GetStringWidth = function()
				return 0
			end,
			SetText = function(self, text)
				self.text = text
			end,
			GetText = function(self)
				return self.text
			end,
		})
	end

	local frameMethods = {}
	function frameMethods:SetScript(key, handler)
		self.scripts[key] = handler
	end
	function frameMethods:GetScript(key)
		return self.scripts[key]
	end
	function frameMethods:HookScript(key, handler)
		self.scriptHooks[key] = handler
	end
	function frameMethods:RegisterEvent(event)
		self.events[event] = true
	end
	function frameMethods:RegisterUnitEvent(event, unit)
		self.events[event] = unit
	end
	function frameMethods:UnregisterEvent(event)
		self.events[event] = nil
	end
	-- Showing runs an OnShow hook, which is where Speedy Loot re-hides the loot window.
	function frameMethods:Show()
		self.shown = true
		if self.scriptHooks.OnShow then
			self.scriptHooks.OnShow(self)
		end
	end
	function frameMethods:Hide()
		self.shown = false
	end
	function frameMethods:IsShown()
		if self.frameName and state.shownFrames[self.frameName] ~= nil then
			return state.shownFrames[self.frameName]
		end
		return self.shown == true
	end
	function frameMethods:GetName()
		return self.frameName
	end
	-- An edit box's or a button's own text, kept apart from the `text` field code hangs a font string on.
	function frameMethods:SetText(text)
		self.textValue = text
	end
	function frameMethods:GetText()
		return self.textValue
	end
	function frameMethods:CreateFontString()
		return newFontString()
	end
	function frameMethods:CreateTexture()
		return newObject()
	end
	function frameMethods:CreateAnimationGroup()
		local parent = self
		local group = newObject({
			GetParent = function()
				return parent
			end,
		})
		group.CreateAnimation = function()
			return newObject()
		end
		return group
	end

	--[[
	    A GameTooltipTemplate tooltip keeps its lines as TextLeftN font strings
	    reachable only by the frame's name, so the fake publishes them on the
	    environment the same way. SetBagItem reads the fake bags: a locked slot
	    shows the client's LOCKED line.
	]]
	local tooltipMethods = {}
	function tooltipMethods:SetLines(lines)
		self.lines = lines
		for lineIndex, text in ipairs(lines) do
			if self.frameName then
				local fontString = newFontString()
				fontString.text = text
				env[self.frameName .. "TextLeft" .. lineIndex] = fontString
			end
		end
	end
	function tooltipMethods:NumLines()
		return #self.lines
	end
	function tooltipMethods:ClearLines()
		self:SetLines({})
	end
	function tooltipMethods:SetBagItem(bagIndex, slotIndex)
		local slot = bagSlot(bagIndex, slotIndex)
		local lines = {}
		if slot then
			lines[#lines + 1] = slot.name or "Item"
			if slot.locked then
				lines[#lines + 1] = env.LOCKED
			end
		end
		self:SetLines(lines)
		self.shown = true
		local postHooks = rawget(self, "__postHooks")
		local hook = postHooks and postHooks.SetBagItem
		if hook then
			hook(self, bagIndex, slotIndex)
		end
	end
	function tooltipMethods:SetHyperlink(link)
		local itemId = tonumber(tostring(link):match("item:(%d+)"))
		self:SetLines(state.hyperlinkTooltipLines[itemId] or { "Item" })
		self.shown = true
	end
	function tooltipMethods:SetItemByID(itemId)
		self:SetHyperlink("item:" .. itemId)
	end
	function tooltipMethods:AddLine(text)
		local lines = self.lines
		lines[#lines + 1] = text
		self:SetLines(lines)
	end
	function tooltipMethods:AddDoubleLine(left)
		self:AddLine(left)
	end
	function tooltipMethods:GetItem()
		return nil
	end

	env.CreateFrame = function(frameType, frameName)
		local frame = { scripts = {}, scriptHooks = {}, events = {}, frameName = frameName, lines = {} }
		table.insert(state.createdFrames, frame)
		local methods = frameMethods
		if frameType == "GameTooltip" then
			methods = setmetatable({}, { __index = frameMethods })
			for name, method in pairs(tooltipMethods) do
				methods[name] = method
			end
		end
		return setmetatable(frame, {
			__index = function(_, key)
				return methods[key] or noOpMethod(key)
			end,
		})
	end

	env.GameTooltip = env.CreateFrame("GameTooltip", "GameTooltip")
	env.LootFrame = env.CreateFrame("Frame", "LootFrame")
	-- The interaction windows opening waits on; hidden unless a test sets state.shownFrames[name].
	for _, frameName in ipairs({
		"MerchantFrame",
		"MailFrame",
		"TradeFrame",
		"BankFrame",
		"AuctionHouseFrame",
		"GossipFrame",
		"QuestFrame",
		"StaticPopup1",
	}) do
		env[frameName] = env.CreateFrame("Frame", frameName)
	end

	env.IsShiftKeyDown = function()
		return state.shiftDown == true
	end

	-- Player state the safety gates read.
	env.UnitAffectingCombat = function()
		return state.inCombat
	end
	env.UnitCastingInfo = function()
		return state.casting and "Casting" or nil
	end
	env.UnitChannelInfo = function()
		return nil
	end
	env.IsStealthed = function()
		return state.stealthed
	end
	env.IsInInstance = function()
		return state.inInstance
	end
	env.C_UnitAuras = {
		GetPlayerAuraBySpellID = function(spellIdentifier)
			return state.playerAuras[spellIdentifier]
		end,
	}
	env.C_Secrets = {
		ShouldSpellAuraBeSecret = function()
			return state.secretAuras
		end,
		ShouldUnitSpellCastingBeSecret = function()
			return state.secretCasts
		end,
	}
	env.UnitRace = function()
		return "Human", "Human"
	end
	env.UnitSex = function()
		return 2
	end
	env.UnitClass = function()
		return "Class", state.playerClassFile
	end
	-- The two classes the tests put in a group, in the client's own colorStr shape.
	env.RAID_CLASS_COLORS = {
		WARRIOR = { colorStr = "ffc69b6d" },
		ROGUE = { colorStr = "fffff468" },
	}
	env.PlaySound = function(sound)
		table.insert(state.sounds, { kind = "kit", sound = sound })
	end
	env.PlaySoundFile = function(sound)
		table.insert(state.sounds, { kind = "file", sound = sound })
	end

	-- The client strings the add-on reads the game's words through, in their enUS forms.
	env.LOCKED = "Locked"
	env.ITEM_STARTS_QUEST = "This Item Begins a Quest"
	env.ITEM_MIN_SKILL = "Requires %s (%d)"
	env.ChatFrameUtil = {
		AddMessageEventFilter = function(event, filter)
			state.chatFilters[event] = state.chatFilters[event] or {}
			table.insert(state.chatFilters[event], filter)
		end,
	}
	-- The General chat tab, listening for Item Loot as a fresh client's does.
	state.chatFrameGroups = { "SYSTEM", "LOOT", "MONEY" }
	env.ChatFrame1 = {
		isInitialized = 1,
		ContainsMessageGroup = function(_, group)
			for _, value in ipairs(state.chatFrameGroups) do
				if value == group then
					return true
				end
			end
			return false
		end,
		AddMessageGroup = function(_, group)
			table.insert(state.chatFrameGroups, group)
		end,
		RemoveMessageGroup = function(_, group)
			for index = #state.chatFrameGroups, 1, -1 do
				if state.chatFrameGroups[index] == group then
					table.remove(state.chatFrameGroups, index)
				end
			end
		end,
	}
	-- The loot-roll lines as the Classic Era client words them, the hidden [Loot] history link included.
	env.LOOT_ROLL_NEED = "|HlootHistory:%d|h[Loot]|h: %s has selected Need for: %s"
	env.LOOT_ROLL_NEED_SELF = "|HlootHistory:%d|h[Loot]|h: You have selected Need for: %s"
	env.LOOT_ROLL_GREED = "|HlootHistory:%d|h[Loot]|h: %s has selected Greed for: %s"
	env.LOOT_ROLL_GREED_SELF = "|HlootHistory:%d|h[Loot]|h: You have selected Greed for: %s"
	env.LOOT_ROLL_PASSED = "|HlootHistory:%d|h[Loot]|h: %s passed on: %s"
	env.LOOT_ROLL_PASSED_SELF = "|HlootHistory:%d|h[Loot]|h: You passed on: %s"
	env.LOOT_ROLL_ROLLED_NEED = "|HlootHistory:%d|h[Loot]|h: Need Roll - %d for %s by %s"
	env.LOOT_ROLL_ROLLED_GREED = "|HlootHistory:%d|h[Loot]|h: Greed Roll - %d for %s by %s"
	env.LOOT_ROLL_ROLLED_DE = "Disenchant Roll - %d for %s by %s"
	env.LOOT_ROLL_WON = "|HlootHistory:%d|h[Loot]|h: %s won: %s"
	env.LOOT_ROLL_YOU_WON = "|HlootHistory:%d|h[Loot]|h: You won: %s"
	env.LOOT_ROLL_WON_NO_SPAM_GREED = "|HlootHistory:%d|h[Loot]|h: %s won: %s |cff818181(Greed - %d)|r"
	env.LOOT_ROLL_YOU_WON_NO_SPAM_NEED = "|HlootHistory:%d|h[Loot]|h: You won: %s |cff818181(Need - %d)|r"
	env.LOOT_ROLL_ALL_PASSED = "|HlootHistory:%d|h[Loot]|h: Everyone passed on: %s"
	env.LOOT_ROLL_STARTED = "|HlootHistory:%d|h[Loot]|h: %s"
	env.NEED = "Need"
	env.GREED = "Greed"
	-- The stat names Character Rules captions its rows with and reads tooltips by, as Classic Era words them.
	env.ITEM_MOD_STRENGTH_SHORT = "Strength"
	env.ITEM_MOD_AGILITY_SHORT = "Agility"
	env.ITEM_MOD_INTELLECT_SHORT = "Intellect"
	env.ITEM_MOD_SPIRIT_SHORT = "Spirit"
	env.ITEM_MOD_STAMINA_SHORT = "Stamina"
	env.ITEM_MOD_SPELL_POWER_SHORT = "Spell Power"
	env.ITEM_MOD_SPELL_DAMAGE_DONE_SHORT = "Bonus Damage"
	env.ITEM_MOD_SPELL_HEALING_DONE_SHORT = "Bonus Healing"
	env.ITEM_MOD_ATTACK_POWER_SHORT = "Attack Power"
	env.ITEM_MOD_CRIT_RATING_SHORT = "Critical Strike"
	env.ITEM_MOD_CRIT_MELEE_RATING_SHORT = "Critical Strike (Melee)"
	env.ITEM_MOD_CRIT_RANGED_RATING_SHORT = "Critical Strike (Ranged)"
	env.ITEM_MOD_CRIT_SPELL_RATING_SHORT = "Critical Strike (Spell)"
	env.ITEM_MOD_HIT_RATING_SHORT = "Hit"
	env.ITEM_MOD_HIT_MELEE_RATING_SHORT = "Hit (Melee)"
	env.ITEM_MOD_HIT_RANGED_RATING_SHORT = "Hit (Ranged)"
	env.ITEM_MOD_HIT_SPELL_RATING_SHORT = "Hit (Spell)"
	env.ITEM_MOD_MANA_REGENERATION_SHORT = "Mana Regeneration"
	env.ITEM_MOD_POWER_REGEN0_SHORT = "Mana Per 5 Sec."
	-- The full stat-line formats the tooltip prints, which Character Rules matches tooltip lines against.
	env.ITEM_MOD_STRENGTH = "%c%d Strength"
	env.ITEM_MOD_AGILITY = "%c%d Agility"
	env.ITEM_MOD_STAMINA = "%c%d Stamina"
	env.ITEM_MOD_INTELLECT = "%c%d Intellect"
	env.ITEM_MOD_SPIRIT = "%c%d Spirit"
	env.ITEM_MOD_SPELL_POWER = "Increases spell power by %s."
	env.ITEM_MOD_SPELL_DAMAGE_DONE = "Increases damage done by magical spells and effects by up to %s."
	env.ITEM_MOD_SPELL_HEALING_DONE = "Increases healing done by magical spells and effects by up to %s."
	env.ITEM_MOD_ATTACK_POWER = "Increases attack power by %s."
	env.ITEM_MOD_CRIT_RATING = "Increases your critical strike by %s."
	env.ITEM_MOD_HIT_RATING = "Increases your hit by %s."
	env.ITEM_MOD_MANA_REGENERATION = "Restores %s mana per 5 sec."
	env.PASS = "Pass"
	env.LOCALIZED_CLASS_NAMES_MALE = { ROGUE = "Rogue", WARRIOR = "Warrior" }
	env.ITEM_QUALITY0_DESC = "Poor"
	env.ITEM_QUALITY1_DESC = "Common"
	env.ITEM_QUALITY2_DESC = "Uncommon"
	env.ITEM_QUALITY3_DESC = "Rare"
	env.ITEM_QUALITY4_DESC = "Epic"
	env.LOOT_METHOD = "Loot Method"
	env.LOOT_THRESHOLD = "Loot Threshold"
	env.LOOT_FREE_FOR_ALL = "Loot: Free for All"
	env.LOOT_ROUND_ROBIN = "Loot: Round Robin"
	env.LOOT_MASTER_LOOTER = "Loot: Master Looter"
	env.LOOT_GROUP_LOOT = "Loot: Group Loot"
	env.LOOT_NEED_BEFORE_GREED = "Loot: Need Before Greed"
	env.ERR_INV_FULL = "Inventory is full."
	env.WHISPER = "Whisper"
	-- Labels GogoLoot's own sentences name, filled in from the client.
	env.AUTO_LOOT_DEFAULT_TEXT = "Auto Loot"
	env.MASTER_LOOTER = "Master Looter"
	env.GENERAL = "General"
	env.ITEM_LOOT = "Item Loot"
	env.MONEY_LOOT = "Money Loot"
	env.ITEM_REQ_SKILL = "Requires %s"
	env.MONEY = "Money"
	env.ROLL_DISENCHANT = "Disenchant"
	env.PARTY = "Party"
	env.RAID = "Raid"
	env.LOOT_ITEM_SELF = "You receive loot: %s."
	env.LOOT_ITEM_SELF_MULTIPLE = "You receive loot: %sx%d."
	env.LOOT_ITEM_PUSHED_SELF = "You receive item: %s."
	env.LOOT_ITEM_PUSHED_SELF_MULTIPLE = "You receive item: %sx%d."
	env.LOOT_ITEM = "%s receives loot: %s."
	env.LOOT_ITEM_MULTIPLE = "%s receives loot: %sx%d."
	env.LOOT_ITEM_PUSHED = "%s receives item: %s."
	env.LOOT_ITEM_PUSHED_MULTIPLE = "%s receives item: %sx%d."
	env.GOLD_AMOUNT = "%d Gold"
	env.SILVER_AMOUNT = "%d Silver"
	env.COPPER_AMOUNT = "%d Copper"
	env.GOLD_AMOUNT_SYMBOL = "g"
	env.SILVER_AMOUNT_SYMBOL = "s"
	env.COPPER_AMOUNT_SYMBOL = "c"
	-- A number on every client, like the real one.
	env.LE_GAME_ERR_INV_FULL = 3

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
		LE_ITEM_CLASS_CONTAINER = true,
		LE_ITEM_CLASS_QUIVER = true,
		LE_ITEM_CLASS_KEY = true,
		LE_ITEM_CLASS_CONSUMABLE = true,
		LE_ITEM_CLASS_WEAPON = true,
		LE_ITEM_CLASS_GEM = true,
		LE_ITEM_CLASS_ARMOR = true,
		LE_ITEM_CLASS_REAGENT = true,
		LE_ITEM_CLASS_PROJECTILE = true,
		LE_ITEM_CLASS_TRADEGOODS = true,
		GetLootMethod = true,
		SetLootMethod = true,
		-- WoW Forever's shape: no skill-line API. A test that needs a rank defines both.
		GetNumSkillLines = true,
		GetSkillLineInfo = true,
		GuildBankFrame = true,
		AuctionFrame = true,
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
