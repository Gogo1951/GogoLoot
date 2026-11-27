--------------------------------------------------------------------------------
-- GogoLoot Default Settings
--------------------------------------------------------------------------------
local _, ns = ...

--------------------------------------------------------------------------------
-- Default Configuration
--------------------------------------------------------------------------------

--[[
    AceDB-3.0 defaults (AceDB:New in Features/Core.lua). AceDB strips them
    from the saved table at logout, so there is no manual merge. The empty
    item lists are seeded by Core's refill-on-empty rule, never here.
]]

ns.DATABASE_DEFAULTS = {
	profile = {
		-- The mini-map button's position and its Enable Mini-map Button preference (hide), handed straight to LibDBIcon.
		minimap = {},
		-- The master switch over everything GogoLoot posts to chat.
		lootNotifications = true,
		announceDestinations = true,
		announceMasterLootAuto = true,
		announceMasterLootAutoThreshold = 3,
		-- Items the player hands out from the master looter menu, whatever their quality.
		announceMasterLootManual = true,
		announceTrade = true,
		announceTradeCondition = "always",
		-- "whisper" | "group" | "self" (printed to the player's own chat, sent to nobody)
		announceTradeOutput = "whisper",
		-- On, with each character's Character Rules deciding its gear (maintainer, 2026-11-07).
		autoGreed = true,
		-- The party pair applies whenever IsInRaid() is false, ungrouped included.
		autoRollActionParty = ns.GREED,
		autoRollThresholdParty = 2,
		autoRollActionRaid = ns.GREED,
		autoRollThresholdRaid = 2,
		-- Off: Bind on Pickup gear is left to the player; only Item Overrides roll on it.
		rollBindOnPickupParty = false,
		rollBindOnPickupRaid = false,
		-- On: the roll window closes the moment GogoLoot rolls, so this line is the only record.
		printRolledItems = true,
		-- On: a five-player roll prints about eleven lines. Who won and what they received stay in chat.
		hideRollMessages = true,
		-- With Hide Roll Messages on, one GogoLoot line per win in place of the game's won line.
		winnerSummary = "PRINT",
		-- On: a Need or Pass roll in a dungeon or raid gives away loot the player may have wanted.
		rollSafetyWarning = true,
		rollSafetyWarningSound = true,
		-- On: it reads anyone's raid roll, so it doesn't wait on the Roll Macro.
		raidRollWinner = true,
		raidRollOutput = "SELF",
		-- Off by default (maintainer, 2026-10-05), with no migration: a profile that never set it reads off after updating.
		autoMasterLoot = false,
		autoMasterLootOutsideInstances = false,
		--[[
            Off, and deliberately outside the always-skipped set: a quest item
            handed to someone not on the quest wastes the drop, so this suits
            only a recipient the same player controls.
        ]]
		autoMasterLootQuestItems = false,
		masterLooterPopup = true,
		-- On, and apart from Automated Master Looting, though it sits on that panel.
		tradableTintEnabled = true,
		tradableTintColor = { r = 1, g = 0, b = 128 / 255, a = 0.5 },
		customRollList = true,
		--[[
            Quality key -> recipient, deliberately empty: unset reads as Loot
            Window. A seeded "self" would be re-applied by AceDB at each login,
            so a cleared setup could never survive a reload.
        ]]
		destinations = {},
		ignoredItemsMaster = {},
		ignoredItemsSolo = {},
		autoOpen = true,
		-- "ALWAYS" | "OUTSIDE_INSTANCES"
		autoOpenWhere = "ALWAYS",
		-- "ALWAYS" | "SOLO_ONLY"
		autoOpenGroup = "ALWAYS",
		-- Off holds opening back while a fishing pole is in the main hand, so a clam can't break the fishing rhythm.
		autoOpenWithFishingPole = false,
		openingIgnoreNotifications = true,
		lockboxTooltips = true,
		-- "ROGUES" | "ALL"
		lockboxTooltipsScope = "ROGUES",
		lockboxNotifications = true,
		-- "ROGUES" | "ALL"
		lockboxNotificationsScope = "ROGUES",
		-- The Loot Sounds panel's master switch; lootSounds below is the chime alone.
		lootSoundsEnabled = true,
		lootSounds = true,
		lootSoundThreshold = 2,
		pickPocketSound = true,
		-- Off until the toasts are polished; players can turn them on to try them and give feedback (maintainer, 2026-10-05).
		lootToasts = false,
		-- With the toasts on, the game's Item Loot and Money Loot lines leave the General tab.
		standardLootMessages = "DISABLE",
		-- Off, so the stack ignores the mouse and leaves no hover dead spot over the world.
		lootToastTooltips = false,
		-- Off, so with the toasts on the game's own "You Won" window isn't a second copy of the win.
		lootToastBlizzardRollWon = false,
		-- Per profile on purpose: a new or reset profile should be introduced to the drag handle.
		lootToastsIntroSeen = false,
		--[[
            Mine: every row, every quality, since the stack stands in for the
            loot window Speedy Loot hides. The loot sound keeps Uncommon: a
            sound is an interruption, a row a record. Group: quest items and
            Uncommon-or-better gear the player might be waiting on. A row left
            out here is off.
        ]]
		lootToastMine = {
			ARMOR = true,
			WEAPON = true,
			GEM = true,
			TRADE_GOODS = true,
			COMPANION_PET = true,
			CONSUMABLE = true,
			CONTAINER = true,
			KEY = true,
			MISCELLANEOUS = true,
			MOUNT = true,
			PROJECTILE = true,
			QUEST = true,
			QUIVER = true,
			REAGENT = true,
			RECIPE = true,
			BIND_ON_PICKUP = true,
			OPENABLES = true,
			MONEY = true,
			CURRENCY = true,
		},
		lootToastGroup = {
			ARMOR = true,
			WEAPON = true,
			QUEST = true,
		},
		lootToastMineQuality = {
			ARMOR = 0,
			WEAPON = 0,
			GEM = 0,
			TRADE_GOODS = 0,
		},
		lootToastGroupQuality = {
			ARMOR = 2,
			WEAPON = 2,
			GEM = 2,
			TRADE_GOODS = 2,
		},
		-- Show Winning Roll: the roll an item was won with, on the winner's toast.
		lootToastWinningRollMine = true,
		lootToastWinningRollGroup = true,
		-- Show Bag Count: off, since a number on every stack only helps the player farming one.
		lootToastBagCount = false,
		lootToastDuration = 5,
		lootToastMaxVisible = 8,
		-- "UP" | "DOWN"
		lootToastGrowth = "UP",
		-- "LEFT" | "RIGHT"
		lootToastAlign = "LEFT",
		lootToastFont = "DEFAULT",
		lootToastFontSize = 16,
		-- One of ns.LOOT_TOAST_FONT_FLAGS.
		lootToastFontFlags = "OUTLINE",
		-- Loot Master and Loot Tracker: off while the windows are parked out of the TOCs.
		lootMaster = false,
		-- Seconds a roll stays open; one of ns.ROLL_LENGTHS.
		rollLength = 20,
		-- ns.ROLL_CHANNEL_RAID_WARNING | ns.ROLL_CHANNEL_GROUP, for calls, ties and pauses.
		rollChannel = "RAID_WARNING",
		rollWarnLastSeconds = true,
		-- A roll in the last few seconds adds a few more. Off: the timer is what was called.
		rollStretchLate = false,
		rollEndWhenAllRolled = false,
		rollRerollTies = true,
		-- Seconds Roll All waits between items; one of ns.ROLL_ALL_PAUSES.
		rollAllPause = 5,
		rollAnnounceNotCounted = true,
		lootMasterOpenOnTradable = true,
		tradeWarnLow = true,
		-- One of ns.TRADE_WARN_MINUTES.
		tradeWarnMinutes = 10,
		tradeAutoFill = true,
		floorLootDropWhenGone = true,
		floorLootClearOnLeave = false,
		lootTrackerOpenOnRoll = true,
		lootTrackerAutoClose = true,
		-- One of ns.DROPS_KEEP_RAIDS.
		dropsKeepRaids = 5,
	},
	-- Account-wide: a profile switch, reset or delete leaves it alone. The mini-map button and toasts' look are profile.
	global = {
		showWelcome = true,
		automatedRollsOnNoticeShown = false,
		-- Changes the client's loot window, not loot policy.
		speedyLoot = true,
		-- The Roll Macro is a General macro, shared by every character, so its switch is too.
		rollMacro = false,
		--[[
            { [itemId] = action }, only where it differs from the default, plus
            ns.OPENING_REMOVED for a listed item taken off, so new data reaches
            every player without a migration.
        ]]
		openingActions = {},
		-- Where things sit on screen: a decision about the screen, not the loot.
		lootToastPosition = {},
		lootWindowPositions = {},
	},
	char = {
		-- The General tab's message groups GogoLoot took off it, per character because chat settings are.
		lootGroupsHiddenByGogoLoot = {},
		-- The Loot Master's lists: what this character carries, kept across a mid-raid /reload.
		rollList = {},
		floorLoot = {},
		awarded = {},
		dropRaids = {},
		-- Item IDs picked up in the current instance, which Add from Bags lists first, and the instance they belong to.
		pickedUp = {},
		pickedUpInstance = "",
	},
}
