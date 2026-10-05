--------------------------------------------------------------------------------
-- GogoLoot Default Settings
--------------------------------------------------------------------------------
local _, ns = ...

--------------------------------------------------------------------------------
-- Default Configuration
--------------------------------------------------------------------------------

--[[
    AceDB-3.0 defaults table, passed to AceDB:New in Features/Core.lua. Loot
    policy lives in the active profile (ns.db.profile), and with it the
    Automated Opening, lockbox, loot sound and loot toast settings; the
    presentation keys and the two account-wide records live in global, per the
    comment on that table below, and the chat tab state Loot Toasts changes
    lives in char, per character. AceDB physically copies
    these defaults into the saved table rather than resolving them through a
    metatable, so there is no manual merge anywhere. The empty
    ignoredItemsMaster / ignoredItemsSolo lists are seeded from this client's
    Data/{Folder}/Default-Item-Lists-{Folder}.lua by Core's refill-on-empty
    rule, never here.
]]

ns.DATABASE_DEFAULTS = {
	profile = {
		-- Enable Announcements: the master switch over everything GogoLoot posts to chat.
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
		autoGreed = false,
		--[[
            Automated rolls are configured per group context: the party pair
            applies whenever IsInRaid() is false, the raid pair whenever it is
            true. Action values are the ns.MANUAL / ns.PASS / ns.GREED / ns.NEED
            strings; MANUAL means "leave that context alone".
        ]]
		autoRollActionParty = ns.GREED,
		autoRollThresholdParty = 2,
		autoRollActionRaid = ns.GREED,
		autoRollThresholdRaid = 2,
		--[[
            Print Item in Chat: on, since the roll window closes the moment
            GogoLoot rolls, and this line is the only record of what came up
            and which roll was made.
        ]]
		printRolledItems = true,
		--[[
            Hide Roll Messages: on, since a five-player roll prints about eleven
            lines and the winner's toast now carries the result. Who won and
            what they received stay in chat.
        ]]
		hideRollMessages = true,
		-- With Hide Roll Messages on, one GogoLoot line per win in place of the game's won line.
		winnerSummary = "PRINT",
		-- Off by default (maintainer, 2026-10-05).
		autoMasterLoot = false,
		autoMasterLootOutsideInstances = false,
		--[[
            Off by default, and deliberately not part of the always-skipped set
            it opts out of: handing a quest item to somebody who isn't on the
            quest wastes the drop, so this is only worth turning on when the
            recipient is a character the same player controls.
        ]]
		autoMasterLootQuestItems = false,
		masterLooterPopup = true,
		customRollList = true,
		--[[
            Quality key -> recipient, and deliberately empty: an absent tier is
            "nobody chosen yet", which auto-distributes nothing and reads as
            Loot Window. Seeding every tier with "self" would make AceDB
            re-apply it at each login, so a cleared setup could never survive a
            reload, and a destination nobody picked would look like one they had.
        ]]
		destinations = {},
		ignoredItemsMaster = {},
		ignoredItemsSolo = {},
		autoOpen = true,
		-- "ALWAYS" | "OUTSIDE_INSTANCES"
		autoOpenWhere = "ALWAYS",
		-- "ALWAYS" | "SOLO_ONLY"
		autoOpenGroup = "ALWAYS",
		-- Tells the player when Automated Opening or Speedy Loot leaves an item set to Ignore alone.
		openingIgnoreNotifications = true,
		lockboxTooltips = true,
		-- "ROGUES" | "ALL"
		lockboxTooltipsScope = "ROGUES",
		lockboxNotifications = true,
		-- "ROGUES" | "ALL"
		lockboxNotificationsScope = "ROGUES",
		lootSounds = true,
		lootSoundThreshold = 2,
		-- Rogues only in practice; nothing else can cast Pick Pocket.
		pickPocketSound = true,
		-- Off until the toasts are polished; players can turn them on to try them and give feedback (maintainer, 2026-10-05).
		lootToasts = false,
		--[[
            With the toasts on, the game's Item Loot and Money Loot lines leave
            the General tab: the toasts carry the same loot.
        ]]
		standardLootMessages = "DISABLE",
		--[[
            Whether this profile has been shown the drag handle and put it away.
            Per profile on purpose: a new or reset profile is one that has not
            been introduced to the feature, and should be.
        ]]
		lootToastsIntroSeen = false,
		--[[
            Filters: which of ns.LOOT_TOAST_FILTER_ROWS get a toast, for the
            player's own loot (Mine) and the rest of the group's (Group), each
            keyed by the row's key.

            Mine ships with every row on and every quality at Poor: the toast
            stack stands in for the loot window Speedy Loot hides, and a window
            shows what was picked up whatever its color. The loot SOUND keeps its
            Uncommon threshold, because a sound is an interruption and a row is a
            record: one wants to be rare, the other wants to be complete.

            Group ships with quest items and Uncommon-or-better weapons and armor:
            what a group member picks up that the player might be waiting on or
            rolling for, and none of their cloth and greys. A row left out here is
            off, and AceDB saves only what the player changes.
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
	},
	--[[
		Account-wide: how GogoLoot presents itself and what it does to the
		client, which never varies by loot context. A profile switch, reset, or
		delete leaves all of it alone. Everything in profile above is loot
		policy, which is exactly what a second profile is for.
	]]
	global = {
		showWelcome = true,
		speedyLoot = true,
		minimap = {},
		--[[
            The player's Openables List changes, { [itemId] = action }: the
            listed items set differently from their default (ns.OPENING_OPEN or
            ns.OPENING_IGNORE), the items they added, and ns.OPENING_REMOVED for
            the listed items they took off.
            Account-wide because which containers a player hoards is a decision
            about the items, not about a loot setup, and saving only the changes
            is what lets new data reach every player without a migration.
        ]]
		openingActions = {},
		-- Where the loot toasts sit on screen: a decision about the screen, not the loot.
		lootToastPosition = {},
	},
	char = {
		-- The General tab's message groups GogoLoot took off it, per character because chat settings are.
		lootGroupsHiddenByGogoLoot = {},
	},
}
