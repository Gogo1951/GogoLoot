local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "zhTW")
if not L then
	return
end

--[[
    Translated from enUS.lua, the source locale any missing key falls back to.
    Translate the values only. Never change the L["KEY"] names or the %s / %d
    placeholders: code and other locales rely on them. Chat Messages print as
    "GogoLoot // <message>", so each ends with its own punctuation. Chat
    Announcement Templates and the ERROR_ keys are sent as
    "{rt4} <message> // GogoLoot", with the marker and name added by code, so
    they take no closing period or other end punctuation.
]]

--------------------------------------------------------------------------------
-- Add-on Identity
--------------------------------------------------------------------------------

-- Brands every printed line, sent message, options panel, and report. A proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"版本 %s。設定(包括關閉此訊息的選項)位於 選項 > 插件 > GogoLoot。喜歡這個插件嗎？推薦給朋友吧！(="
L["CHAT_OPTIONS_IN_COMBAT"] = "基於安全考量，戰鬥中無法開啟選項視窗。"
-- Argument: the game's own name for its Auto Loot setting.
L["MESSAGE_AUTO_LOOT_SETTING_ON"] = "已開啟遊戲的%s設定，快速拾取與自動開啟都需要它。"
-- Argument: the game's own word for Master Looter.
L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"] = "你目前不負責%s。"

-- Automated Opening. Argument: the number of free bag slots opening waits for.
L["MESSAGE_OPENING_PAUSED"] = "自動開啟已暫停，直到你至少有 %d 個空背包欄位。"
L["MESSAGE_OPENING_RESUMED"] = "自動開啟已恢復。"

-- Argument: the item's link.
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] = "%s 解鎖後將會自動開啟。"
L["MESSAGE_ITEM_IGNORED"] = "%s 設為忽略，自動開啟不會動它。"
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s 來自團隊首領或世界首領，自動開啟會保留它不開，讓你交易或出售。"
L["MESSAGE_ITEM_IGNORED_UNIQUE"] = "%s 可能含有唯一物品，自動開啟會留給你自己開啟。"
L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] = "%s 已留在拾取視窗中，讓你自行拾取。"
-- The Openables List's Add Item refusing gear or a bag. Argument: the item's link, or its ID while uncached.
L["MESSAGE_ITEM_NOT_OPENABLE"] = "%s 是用來裝備而非開啟的，無法加入可開啟清單。"

-- Automated Rolls' Print Item in Chat. Arguments: the game's word for the roll (Need or Greed), then the item's link.
L["MESSAGE_ROLL_PRINT"] = "你選擇了%s：%s。"
-- The same after a Pass. Argument: the item's link.
L["MESSAGE_ROLL_PASS_PRINT"] = "你放棄了：%s。"
--[[
    Hide Roll Messages' winner summary. Arguments: the winner, the item's link,
    then the winning roll as LOOT_TOASTS_ROLL_RESULT words it ("Greed 95"). The
    NO_ROLL forms are for a win whose roll wasn't seen; the YOU forms for the
    player's own win, without the winner.
]]
L["MESSAGE_ROLL_WON_PRINT"] = "%s 贏得了 %s，%s。"
L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"] = "%s 贏得了 %s。"
L["MESSAGE_ROLL_YOU_WON_PRINT"] = "你贏得了 %s，%s。"
L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"] = "你贏得了 %s。"

--[[
    A trade summary printed to the player alone (the trade Channel's Me Only):
    the Chat Announcement Templates below, printed, so each ends on its
    punctuation. Arguments as theirs: items, then the partner, then what came
    back.
]]
L["MESSAGE_GAVE_PRINT"] = "已將 %s 交給 %s。"
L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "已將 %s 交給 %s，收到 %s。"
L["MESSAGE_TRADE_RECEIVED_PRINT"] = "收到 %s，來自 %s。"

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "已將 %s 交給 %s"
L["MESSAGE_DESTINATION_SET"] = "%s 將為隊伍保管%s物品"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s 將為隊伍保管所有戰利品"
-- Arguments: the player who left, the master looter, then the qualities they held, joined by commas.
L["MESSAGE_DESTINATION_LEFT"] = "%s 已離開隊伍。%s 現在將為隊伍保管%s物品"
-- The same when they held every quality. Arguments: the player who left, then the master looter.
L["MESSAGE_DESTINATION_LEFT_ALL"] = "%s 已離開隊伍。%s 現在將為隊伍保管所有戰利品"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "已將 %s 交給 %s，收到 %s"
L["MESSAGE_TRADE_RECEIVED"] = "收到 %s，來自 %s"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "%s 的背包已滿：%s"
L["ERROR_MAX_COUNT"] = "%s 持有的數量已達上限：%s"
L["ERROR_OUT_OF_RANGE"] = "%s 距離太遠：%s"
L["ERROR_NOT_IN_GROUP"] = "%s 已不在隊伍或團隊中：%s"
L["ERROR_DISTRIBUTION_FAILED"] = "無法將戰利品交給 %s：%s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_AUTOMATED_ROLLS"] = "自動擲骰"
L["TAB_ITEM_OVERRIDES"] = "指定物品擲骰"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "角色規則"
-- The panel for everything GogoLoot posts to chat.
L["TAB_ANNOUNCEMENTS"] = "通報"
-- Headers of the two sections on the Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "交易通報"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "隊長分配通報"
L["TAB_LOOT_TOASTS"] = "拾取提示"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "篩選"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "拾取音效"
L["TAB_AUTOMATED_OPENING"] = "自動開啟"
-- Header of a section on the Automated Opening panel.
L["TAB_LOCKBOXES"] = "鎖箱"
L["TAB_OPENABLE_ITEMS"] = "可開啟清單"
L["TAB_MASTER_LOOTER"] = "隊長分配"
-- Header of a section on the Master Looter panel.
L["TAB_LOOT_DESTINATIONS"] = "戰利品去向"
L["TAB_IGNORE_LIST"] = "忽略清單"

-- A child panel's title where the Settings tree can't nest it: the parent's title, then its own.
L["TAB_NESTED_FORMAT"] = "%s: %s"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "已啟用"
L["STATUS_DISABLED"] = "已停用"
-- Automated Opening is on but waiting for empty bag slots.
L["STATUS_PAUSED"] = "已暫停"

--[[
    The tooltip titles each feature with its options-panel name (Automated
    Master Looting excepted, since its panel is titled Master Looter), and
    gives each a description of its own, two lines at most: the panels' longer
    text doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "替你對符合條件、不高於所選品質的物品擲骰。"
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] = "開啟背包中的蚌殼、箱子、錢袋與已開鎖的鎖箱。"
L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"] = "將交易摘要和隊長分配結果發送到聊天頻道。"
L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"] = "將戰利品分配給你為各品質指定的玩家。"
--[[
    The tooltip's read-back of each group context's roll, one line each under
    the description. Arguments: the game's own word for Party or Raid, the roll,
    then (all but Manual) the highest quality it rolls on.
]]
L["MINIMAP_ROLLS_SETTING"] = "%s: %s, %s"
L["MINIMAP_ROLLS_SETTING_MANUAL"] = "%s: %s"

L["MINIMAP_LEFT_CLICK"] = "左鍵點擊"
L["MINIMAP_RIGHT_CLICK"] = "右鍵點擊"
L["MINIMAP_SHIFT_LEFT_CLICK"] = "Shift + 左鍵點擊"
L["MINIMAP_SHIFT_RIGHT_CLICK"] = "Shift + 右鍵點擊"
-- The tooltip's title for the Automated Master Looting block, the feature its switch names.
L["MINIMAP_AUTOMATED_MASTER_LOOTING"] = "自動隊長分配"
L["MINIMAP_TOGGLE"] = "切換"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "已鎖物品"
L["MINIMAP_OPTIONS"] = "GogoLoot 選項"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 中鍵點擊"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "手動"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "僅限%s"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s及以下"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List brings text of its own), the hint the box shows while empty,
    and its button.
]]
L["ITEM_LIST_ADD"] = "新增物品"
L["ITEM_LIST_ADD_DESCRIPTION"] = "輸入物品 ID 或將物品拖曳到這裡，即可加入清單。"
L["ITEM_LIST_ADD_PLACEHOLDER"] = "將物品拖放至此，或輸入物品 ID"
L["ITEM_LIST_ADD_BUTTON"] = "新增"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "篩選物品..."
L["ITEM_LIST_FILTER_DESCRIPTION"] =
	"只顯示名稱、物品 ID、設定或標籤中包含你所輸入文字的物品。"
L["ITEM_LIST_NO_MATCHES"] = "沒有符合篩選條件的物品。"

-- The header over what the player just added to an item list, at its top until they filter it or close the window.
L["ITEM_LIST_NEW"] = "新加入"

-- The kind filter beside every item list's search box: its first choice (the rest are the list's headers) and its tooltip.
L["ITEM_LIST_KIND_ALL"] = "顯示所有類別"
L["ITEM_LIST_KIND_DESCRIPTION"] = "顯示清單中的所有物品，或只顯示某一類別的物品。"

--[[
    The Add from Bags dropdown beside every item list's add box: its resting
    text and tooltip, then what it reads, greyed out, when everything carried
    is already on the list. The Openables List brings a tooltip of its own.
]]
L["ITEM_LIST_ADD_FROM_BAGS"] = "從背包新增"
L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"] = "將你身上的一件物品加入清單。"
L["ITEM_LIST_BAGS_EMPTY"] = "背包中沒有可新增的物品"
L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"] = "你身上的所有物品都已在清單中。"

-- The button at the foot of every item list; each list's tooltip and confirmation say what it restores.
L["ITEM_LIST_RESTORE"] = "恢復預設"

-- Placeholder shown in the item lists until the client caches an item's info.
L["ITEM_LOADING"] = "載入中...(ID：%d)"

--[[
    Appended to the Automated Rolls description. Item Overrides is the one way
    a Bind on Pickup or quest item gets rolled on; nothing ever rolls on the
    rest.
]]
L["SAFETY_SKIP_NOTE"] =
	"絕不會對配方、書籍、坐騎、寵物或傳說物品擲骰；拾取後綁定物品與任務物品只有列在指定物品擲骰中才會擲骰。"

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] = "配方、書籍、坐騎、寵物與傳說物品一律留給你處理。"

--[[
    Shown under each announcement's toggle, under Print Item in Chat and Hide
    Roll Messages, and under Enable Ignore Notifications. Argument: the
    message, as GogoLoot sends or prints it.
]]
L["OPTIONS_EXAMPLE"] = "範例：%s"

-- The muted version line at the foot of the General panel.
L["OPTIONS_VERSION"] = "版本 %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"快速拾取眨眼間就把屍體搜刮一空，自動擲骰與自動隊長分配決定誰拿什麼，自動開啟撬開每個蚌殼和箱子。拾取提示讓一切盡收眼底，任務物品、配方、坐騎、寵物和傳說物品都安然無恙。別讓戰利品拖慢你衝刺的腳步！"
L["WELCOME_MESSAGE"] = "啟用歡迎訊息"
L["WELCOME_MESSAGE_DESCRIPTION"] = "每次登入時顯示 GogoLoot 的版本，以及這些設定的位置。"
L["MINIMAP_BUTTON_ENABLE"] = "啟用小地圖按鈕"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"在小地圖上顯示 GogoLoot 按鈕。左鍵點擊切換自動擲骰，右鍵點擊切換自動開啟，Shift + 左鍵點擊切換通報，Shift + 右鍵點擊切換自動隊長分配。"

L["OPTIONS_COMMANDS_HEADER"] = "/指令"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "開啟此插件的選項視窗。"

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "功能"

L["SPEEDY_LOOT_ENABLE"] = "啟用快速拾取"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"打開屍體的瞬間就拾取一空，不顯示拾取視窗。拾取時按住 Shift 則照常顯示視窗。會開啟遊戲的%s設定，當你負責%s時則暫停運作。"

L["FEEDBACK_SUPPORT"] = "意見回饋與支援"

-- CurseForge / GitHub / Discord / Wago are proper nouns; do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "隊伍拾取設定"
L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"] = "設定隊伍戰利品的分配方式。只有隊長可以變更。"
L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"] =
	"設定拾取方式適用的最低物品品質。只有隊長可以變更。"

--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them, including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "這些設定由 %s 控制。"
-- Shown in the same place while solo, where the two dropdowns are greyed out.
L["MASTER_LOOTER_SOLO_NOTE"] = "加入隊伍後才能變更這些設定，且只有隊長可以變更。"

-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"] =
	"一打開拾取視窗，就把每件掉落物交給你為該品質指定的玩家，僅在你負責%s時運作。"
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "啟用自動隊長分配"
L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"] =
	'開啟或關閉自動分配。除非開啟"副本外也啟用"，否則只在地城與團隊副本內運作。'
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "副本外也啟用"
L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"在野外也分配戰利品。世界首領的掉落無法交易，因此不建議開啟。"
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "包含任務物品"
L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"] =
	"連任務物品也一併分配，方便帶自己的其他角色練等。只在拾取品質門檻為普通或以下時有效，且只適用於全隊只掉落一件的任務物品。不建議在團隊副本中使用。"

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // 快速設定"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_POPUP_TOOLTIP"] = "每當你接手%s時，以視窗開啟這些設定。"
L["MASTER_LOOTER_POPUP_ENABLE"] = "啟用隊長分配彈出視窗"

L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"選擇每種品質交給誰。沒有指定人選的品質會留在拾取視窗中給你處理。"
L["MASTER_LOOTER_DESTINATION_SELF"] = "自己"
-- The first choice in every destination dropdown: nobody picked, so that quality waits in the loot window.
L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"] = "拾取視窗"
L["MASTER_LOOTER_SEND_ALL"] = "全部戰利品交給"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] = "將下方所有品質都設為同一名玩家。"
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "設定由誰接收%s物品。"
-- Shown under Loot Destinations while Automated Master Looting is on and no quality has anybody picked.
L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] =
	"尚未指定任何人，因此所有戰利品都會留在拾取視窗中等你處理。"

L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"清單中的物品永遠不會被自動分配，而是留在拾取視窗中讓你自行分配。"
-- Shown on the Ignore List while Automated Master Looting is off.
L["MASTER_LOOTER_OFF_NOTE"] = "自動隊長分配已關閉，這些設定暫不生效。"
L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"] = "以你所在資料片的預設物品取代忽略清單。"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"這將以你所在資料片的預設物品取代你的忽略清單。是否繼續？"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "從忽略清單中移除此物品。"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_PANEL_DESCRIPTION"] =
	"在隊伍拾取時替你擲%s、%s或%s，最高到你所選的品質，隊伍與團隊可分開設定。"
L["ROLLS_ENABLE"] = "啟用自動擲骰"
L["ROLLS_ENABLE_DESCRIPTION"] = "開啟或關閉自動擲骰，包括指定物品擲骰與角色規則。"
L["ROLLS_IN_PARTY"] = "在隊伍中"
L["ROLLS_IN_RAID"] = "在團隊中"
-- The caption of the quality row under In Party and under In Raid, shown while that roll isn't Manual.
L["ROLLS_UP_TO_QUALITY"] = "最高品質"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s：GogoLoot 會擲骰的最高品質。"
L["ROLLS_ACTION_CHOOSE"] = "%s：GogoLoot 擲骰的選擇。手動則交由你自己擲骰。"
-- Section headers on the Automated Rolls panel.
L["ROLLS_LOOT_THRESHOLDS_HEADER"] = "拾取品質門檻"
L["ROLLS_MESSAGES_HEADER"] = "擲骰訊息"
L["ROLLS_PRINT_ITEM"] = "在聊天視窗顯示物品"
L["ROLLS_PRINT_ITEM_DESCRIPTION"] =
	"在你的聊天視窗中列出 GogoLoot 擲骰的每件物品，以及它做出的選擇。GogoLoot 一擲骰，擲骰視窗就會關閉，所以這就是你查看掉了什麼的紀錄。"
L["ROLLS_HIDE_MESSAGES"] = "隱藏擲骰訊息"
-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_HIDE_MESSAGES_TOOLTIP"] =
	"隱藏遊戲為每次擲骰顯示的聊天訊息：誰選了%s、%s或%s，以及擲出的每個點數。每位贏家拿到了什麼仍會留在聊天中。"
-- The dropdown beside Hide Roll Messages.
L["ROLLS_WINNER_SUMMARY_PRINT"] = "顯示贏家摘要"
L["ROLLS_WINNER_SUMMARY_NONE"] = "不顯示贏家摘要"
L["ROLLS_WINNER_SUMMARY_DESCRIPTION"] =
	"顯示贏家摘要會為每次獲勝在聊天中顯示一行，列出贏家、物品與獲勝擲骰，取代遊戲本身的那一行。不顯示贏家摘要則保留遊戲說明誰獲勝的那一行。"

--[[
    Item Overrides, under Automated Rolls: items with a roll action of their
    own.
]]
L["ITEM_OVERRIDES_DESCRIPTION"] =
	"為特定物品設定擲骰，優先於品質設定。這是 GogoLoot 對拾取後綁定物品或任務物品擲骰的唯一方式。"
-- Shown on Item Overrides while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "自動擲骰已關閉，這些設定暫不生效。"
L["ITEM_OVERRIDES_ENABLE"] = "啟用指定物品擲骰"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"使用下方設定的擲骰。關閉時，這些物品會和其他物品一樣依照品質設定。"
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] = "以你所在資料片的預設物品取代指定物品擲骰。"
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"這將以你所在資料片的預設物品取代你的指定物品擲骰。是否繼續？"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "設定此物品的自動擲骰。"
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "從指定物品擲骰中移除此物品。"
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "要從指定物品擲骰中移除此物品及其擲骰設定嗎？"

--[[
    Character Rules, under Automated Rolls: the stats whose gear each
    character leaves to the player. The stat names come from the game's own
    strings.
]]
-- Arguments: the game's own name for Intellect, then for the Warrior class, then Intellect again.
L["CHARACTER_RULES_PANEL_DESCRIPTION"] =
	"逐一角色將帶有你所選屬性的裝備留給你處理：例如將%s設為手動，你的%s遇到帶%s的裝備時就會保留擲骰視窗，其他物品則照常擲骰。指定物品擲骰仍然優先。"
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "主要屬性"
L["CHARACTER_RULES_SECONDARY"] = "次要屬性"
-- The first of the two choices in each stat's dropdown: no rule, so the rest of Automated Rolls decides.
L["CHARACTER_RULES_STANDARD"] = "標準自動擲骰"
L["CHARACTER_RULES_ACTION_DESCRIPTION"] =
	"%s：手動會在此角色上把帶有此屬性的裝備留給你，連同擲骰視窗。標準自動擲骰則像其他物品一樣擲骰。"

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"將交易摘要和隊長分配結果發送到聊天頻道，讓大家都知道戰利品的去向。"
L["ANNOUNCEMENTS_ENABLE"] = "啟用通報"
-- Also the tooltip of the same switch in the General panel's Features section, so it names no position on the panel.
L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"] =
	"開啟或關閉所有通報。關閉時，GogoLoot 不會向隊伍或交易對象發送任何訊息，連你自己分配的物品也不會。"

-- Trade Announcements
L["TRADE_DESCRIPTION"] = "發送每筆完成交易的摘要：物品、附魔與金錢。"
L["TRADE_ENABLE"] = "啟用交易通報"
L["TRADE_ENABLE_DESCRIPTION"] =
	'交易完成時發送摘要。交易視窗上的"通報"核取方塊就是這個開關。'
L["TRADE_CONDITION_DESCRIPTION"] =
	"選擇何時發送交易摘要：一律發送、在隊伍或團隊中時，或在團隊中時。"
L["TRADE_CONDITION_ALWAYS"] = "一律"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "在隊伍或團隊中時"
L["TRADE_CONDITION_RAID_ONLY"] = "在團隊中時"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "頻道"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	"%s會將每份摘要發給交易對象。隊伍頻道會發到你的隊伍或團隊，不在隊伍中時仍改用悄悄話發送。僅自己只顯示在你自己的聊天視窗，不發給任何人。"
-- The Channel dropdown's choices (Whisper is the client's WHISPER), and the trade window checkbox tooltip's Channel value.
L["TRADE_OUTPUT_GROUP"] = "隊伍頻道"
L["TRADE_OUTPUT_SELF"] = "僅自己"
L["TRADE_TOOLTIP_DESCRIPTION"] = "此交易完成時，將交易摘要發送到聊天頻道。"
L["TRADE_CHECKBOX_LABEL"] = "通報"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "告訴隊伍每種品質由誰保管，以及你分配了什麼。"

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "啟用戰利品去向通報"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"] =
	"每當你設定戰利品去向時，告訴隊伍每種品質由誰保管。"

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "啟用自動分配通報"
L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"] =
	"通報 GogoLoot 自動分配的每件物品，限達到你所選品質或以上者。"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"] = "低於此品質的自動分配不會通報。"

L["MASTER_LOOTER_ANNOUNCE_MANUAL"] = "啟用手動分配通報"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"] =
	"通報你從%s選單親自分配的每件物品，不論品質，措辭與自動分配相同。無論此項是否開啟，分配失敗都會回報。"

--------------------------------------------------------------------------------
-- Options: Loot Toasts and Loot Sounds
--------------------------------------------------------------------------------

-- Argument: the game's own name for the General chat tab.
L["LOOT_TOASTS_PANEL_DESCRIPTION"] =
	"將你拾取的每件物品與錢幣在螢幕上顯示幾秒鐘，讓快速拾取隱藏拾取視窗時也不會漏看任何東西。開啟提示後，遊戲本身的拾取訊息就不必再出現在你的%s聊天分頁。"
L["LOOT_TOASTS_ENABLE"] = "啟用拾取提示"
-- Also the tooltip of the same switch in the General panel's Features section.
L["LOOT_TOASTS_SWITCH_DESCRIPTION"] = "依照篩選中的選擇，為你和隊伍拾取的戰利品顯示提示。"
-- The dropdown beside Enable Loot Toasts: the game's Item Loot and Money Loot chat settings for the General tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"] = "停用標準拾取訊息"
L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"] = "啟用標準拾取訊息"
-- Arguments: the game's own names for its Item Loot and Money Loot chat settings, then for the General chat tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"] =
	"停用標準拾取訊息會在拾取提示開啟時，關閉%s和%s在你%s聊天分頁中的顯示，關閉拾取提示則會恢復。這和該分頁設定中的選項相同，其他分頁各自保留自己的設定。"

-- The Loot Toasts panel's two section headers.
L["LOOT_TOASTS_STACK_HEADER"] = "堆疊"
L["LOOT_TOASTS_TEXT_HEADER"] = "文字"

--[[
    Filters: a row per item type, captioned with the game's own name for it,
    each with a Mine box and a Group box. Weapon, Armor, Trade Goods and Gem
    carry a quality dropdown beside each ticked box. Argument in each tooltip:
    the row's item type, as the client names it.
]]
-- Shown on the Filters panel while Loot Toasts is off.
L["LOOT_TOASTS_OFF_NOTE"] = "拾取提示已關閉，這些設定暫不生效。"
-- The Filters panel's description.
L["LOOT_TOASTS_FILTERS_CAPTION"] =
	"選擇哪些戰利品要顯示提示以及提示的內容，你自己的和隊伍的戰利品分開設定。隊伍的戰利品旁會顯示拾取者的名字。"
L["LOOT_TOASTS_FILTER_MINE"] = "我的"
L["LOOT_TOASTS_FILTER_GROUP"] = "隊伍"
L["LOOT_TOASTS_FILTER_MINE_DESCRIPTION"] = "顯示你拾取的%s物品。"
L["LOOT_TOASTS_FILTER_GROUP_DESCRIPTION"] =
	"顯示隊伍或團隊中任何人拾取的%s物品，並附上拾取者的名字。"
L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"] =
	"顯示你拾取的%s物品，限品質達到旁邊所選品質或以上者。"
L["LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION"] =
	"顯示隊伍或團隊中任何人拾取的%s物品，限品質達到旁邊所選品質或以上者，並附上拾取者的名字。"
L["LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION"] = "你拾取的%s物品中，會顯示提示的最低品質。"
L["LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION"] = "隊伍拾取的%s物品中，會顯示提示的最低品質。"

-- The three Filters rows after the item types, which aren't item types themselves: their captions (Money's is the client's MONEY) and their boxes' tooltips.
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP"] = "拾取後綁定"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION"] =
	"顯示你拾取的每件拾取後綁定物品，不論類型或品質。"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION"] =
	"顯示隊伍拾取的每件拾取後綁定物品，不論類型或品質。"
L["LOOT_TOASTS_FILTER_OPENABLES"] = "可開啟物品"
L["LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION"] =
	"顯示你拾取的、GogoLoot 能開啟的容器，包括鎖箱，不論品質。"
L["LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION"] =
	"顯示隊伍拾取的、GogoLoot 能開啟的容器，包括鎖箱，不論品質。"
L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"] =
	"為你拾取的錢幣顯示提示。遊戲不會回報其他玩家拾取的錢幣，因此沒有隊伍核取方塊。"

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast it follows the item
    (LOOT_TOASTS_WON_ROLL); on a group member's, their name
    (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "獲勝擲骰"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] = "在你贏得的物品的提示上加上獲勝擲骰，例如 (%s)。"
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"在隊友贏得的物品的提示上加上其獲勝擲骰，例如 (%s, %s)。"
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_WON_ROLL"] = "%s (%s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "背包數量"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"當你身上的數量多於提示本身的數量時，在你自己戰利品的提示上加上目前持有的總數，例如 x3 (27)。"
-- How many came, after the item on a toast. Argument: the count.
L["LOOT_TOASTS_QUANTITY"] = "x%d"
-- Bag Count, after the item and its count. Argument: how many the player carries.
L["LOOT_TOASTS_BAG_COUNT"] = "(%d)"

-- Stack
L["LOOT_TOASTS_MAX_ITEMS"] = "提示數量上限"
L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"] =
	"螢幕上同時顯示的最多提示數；最舊的會消失以騰出空間。"
L["LOOT_TOASTS_UNLIMITED"] = "無限制"
L["LOOT_TOASTS_DURATION"] = "顯示秒數"
L["LOOT_TOASTS_DURATION_DESCRIPTION"] = "每則提示在淡出前停留的秒數。"
L["LOOT_TOASTS_GROWTH"] = "延伸方向"
L["LOOT_TOASTS_GROWTH_DESCRIPTION"] = "較舊的提示往上或往下移動，遠離最新的一則。"
L["LOOT_TOASTS_GROW_UP"] = "向上延伸"
L["LOOT_TOASTS_GROW_DOWN"] = "向下延伸"
L["LOOT_TOASTS_ALIGN"] = "對齊方式"
L["LOOT_TOASTS_ALIGN_DESCRIPTION"] = "提示對齊在拖曳把手的哪一側。"
L["LOOT_TOASTS_ALIGN_LEFT"] = "靠左"
L["LOOT_TOASTS_ALIGN_RIGHT"] = "靠右"

-- Text
L["LOOT_TOASTS_FONT"] = "字型"
L["LOOT_TOASTS_FONT_DESCRIPTION"] = "提示文字使用的字型。"
L["LOOT_TOASTS_FONT_DEFAULT"] = "預設"
L["LOOT_TOASTS_FONT_SIZE"] = "字型大小"
L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"] = "提示文字的大小；圖示會跟著放大或縮小。"
L["LOOT_TOASTS_OUTLINE"] = "字型外框"
L["LOOT_TOASTS_OUTLINE_DESCRIPTION"] = "提示文字周圍的外框，讓文字在明亮的場景上也清晰易讀。"
L["LOOT_TOASTS_OUTLINE_NONE"] = "無"
L["LOOT_TOASTS_OUTLINE_OUTLINE"] = "外框"
L["LOOT_TOASTS_OUTLINE_THICK"] = "粗外框"
L["LOOT_TOASTS_OUTLINE_MONOCHROME"] = "單色"
L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"] = "單色外框"

-- Position
L["LOOT_TOASTS_UNLOCK"] = "解鎖位置"
L["LOOT_TOASTS_LOCK"] = "鎖定位置"
L["LOOT_TOASTS_RESET"] = "重設位置"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "顯示或隱藏用來將提示拖曳到新位置的把手。"
L["LOOT_TOASTS_RESET_DESCRIPTION"] = "將提示移回螢幕中央上方的預設位置。"

-- The drag handle: its title, the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_HANDLE_TITLE"] = "GogoLoot 拾取提示"
L["LOOT_TOASTS_CLICK_DRAG"] = "點擊 + 拖曳以調整位置"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "右鍵點擊以鎖定"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "停用拾取提示"
-- The stand-in item on the sample toasts, and in every Example line.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "範例物品"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"拾取達到你所選品質或以上的戰利品時播放提示音，%s 偷到東西時播放背包音效。"
L["LOOT_SOUNDS_ENABLE"] = "啟用拾取音效"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"從屍體或寶箱拾取達到你所選品質或以上的物品時播放提示音。"
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "會播放拾取音效的最低物品品質。"
L["LOOT_SOUNDS_TEST"] = "播放拾取音效。"
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "啟用%s音效"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "%s 真正偷到東西時播放背包音效。"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "播放%s音效。"

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"只要你至少有 %d 個空背包欄位，就替你開啟背包中的蚌殼、箱子、錢袋與已開鎖的鎖箱。"
L["AUTOMATED_OPENING_ENABLE"] = "啟用自動開啟"
-- Also the tooltip of the same switch in the General panel's Features section. Argument: the game's own name for its Auto Loot setting.
L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"] =
	"一次開啟一個容器，並在戰鬥中、施法中、潛行中，或開著商人、銀行、信箱、拍賣場或交易視窗時暫停。啟用時會開啟遊戲的%s設定。"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"] = "僅限副本外"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"在地城、團隊副本或戰場中時不開啟任何東西。"
L["AUTOMATED_OPENING_ONLY_SOLO"] = "僅限單人時"
L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"] = "在隊伍或團隊中時不開啟任何東西。"

-- Lockboxes
-- Arguments: the game's own name for the Rogue class, then for the Lockpicking skill.
L["LOCKBOXES_SECTION_DESCRIPTION"] =
	"鎖箱必須由%s開鎖後才能開啟。這些選項會顯示每個鎖箱所需的%s技能，並在有鎖箱等待開啟時提醒你。"
L["LOCKBOXES_TOOLTIPS_ENABLE"] = "啟用鎖箱滑鼠提示"
-- Argument: the game's own name for the Lockpicking skill.
L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"] = "在每個鎖箱的滑鼠提示中加上所需的%s技能。"
L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"] =
	"設定鎖箱滑鼠提示只對盜賊顯示，還是對所有角色顯示。"
L["LOCKBOXES_NOTIFICATIONS_ENABLE"] = "啟用鎖箱通知"
L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"當你拾取一個解鎖後就會開啟的鎖箱時，在聊天視窗中通知你。"
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] = "設定鎖箱通知只對盜賊顯示，還是對所有角色顯示。"
L["LOCKBOXES_FOR_ROGUES"] = "僅限盜賊"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "所有角色"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking" line (ITEM_REQ_SKILL), followed by a skill number. Argument:
    the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "你的%s"

-- On the Automated Opening panel, below its switch.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "啟用忽略通知"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"當 GogoLoot 因為可開啟清單設為忽略而不開啟某個容器時，在聊天視窗中通知你並說明原因。"

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	"GogoLoot 認得的所有容器，以及自動開啟會如何處理它們。忽略會讓容器保持未開啟，快速拾取也會將它留在拾取視窗中給你。你的變更適用於你的所有角色。"
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] =
	"自動開啟已關閉時只會使用忽略：它仍會讓快速拾取略過這些物品。"
L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"] =
	"將清單恢復為預設：每件物品回到預設設定，移除的物品會回來，新增的物品會被移除。"
L["OPENABLE_ITEMS_RESTORE_CONFIRM"] =
	"要將清單恢復為預設嗎？你變更的每項設定，以及新增或移除的每件物品，都會被還原。"
L["OPENABLE_ITEMS_ADD_DESCRIPTION"] =
	"輸入物品 ID 或將物品拖曳到這裡，即可加入清單並設為開啟。裝備和背包無法加入，因為使用它們會直接裝備。"
L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"] =
	"將你身上的一件物品加入清單並設為開啟。裝備和背包不會列出，因為使用它們會直接裝備。"
L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"] =
	"將此物品從清單中移除。之後 GogoLoot 會將它視為一般物品：永不開啟，並像其他物品一樣拾取。"
L["OPENABLE_ITEMS_REMOVE_CONFIRM"] = "要從清單中移除此物品嗎？再次新增即可恢復。"
L["OPENABLE_ITEMS_ACTION_DESCRIPTION"] = "設定自動開啟如何處理此容器。"

-- The Openables List dropdown, one per item.
L["OPENING_ACTION_OPEN"] = "開啟"
L["OPENING_ACTION_IGNORE"] = "忽略"

--[[
    The reason an item's default carries, shown as a short silver tag on its
    Openables List row whatever it is set to. Sell Sealed covers both a raid
    boss drop and a container that can hold Bind on Pickup loot.
]]
L["OPENING_TAG_SEALED"] = "原封出售"
L["OPENING_TAG_UNIQUE"] = "可能含唯一"

--[[
    Each tag explained, under the item's tooltip on the Openables List. The
    item's own tooltip is directly above, so these never name the item.
]]
-- Argument: the game's own name for the Rogue class.
L["OPENING_REASON_LOCKED_CLASS"] = "需要%s開鎖。開鎖後就會像其他容器一樣開啟。"
L["OPENING_REASON_RAID"] =
	"由團隊首領或世界首領掉落。未開啟的容器仍可交易或出售，售價常常比裡面的東西還高。"
L["OPENING_REASON_BIND_ON_PICKUP"] =
	"可能含有拾取後綁定的戰利品。保持未開啟時仍可交易或出售。"
L["OPENING_REASON_UNIQUE"] =
	"可能含有唯一物品。若你身上已有一件，開啟時會失敗並出現錯誤。"
