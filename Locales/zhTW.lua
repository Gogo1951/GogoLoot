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

-- The Full Name: leads every printed line, and names the options panels, window titles and the mini-map header. A proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
-- The Short Name: closes every sent message and names the add-on on tooltip lines other than the mini-map header. A proper noun; keep it untranslated.
L["ADDON_SHORT_NAME"] = "GogoLoot"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"版本 %s。設定(包括關閉此訊息的選項)位於 選項 > 插件 > GogoLoot。喜歡這個插件嗎？推薦給朋友、在 CurseForge 加入最愛，或在 GitHub 給個 Star。(="
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
L["MESSAGE_LOOT_LEFT_ON_CORPSE"] = "%s部分戰利品留在了屍體上。"
--[[
    Standard Loot Messages taking the General tab's loot lines off, or putting
    them back. Arguments: the game's own names for its Item Loot and Money Loot
    chat settings, then for the General chat tab.
]]
L["MESSAGE_STANDARD_LOOT_MESSAGES_OFF"] =
	"已關閉%s和%s在你%s聊天分頁中的顯示，拾取提示開啟期間有效。"
L["MESSAGE_STANDARD_LOOT_MESSAGES_ON"] = "已重新開啟%s和%s在你%s聊天分頁中的顯示。"

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

-- The first feature panel, holding the one Speedy Loot switch.
L["TAB_SPEEDY_LOOT"] = "快速拾取"
L["TAB_AUTOMATED_ROLLS"] = "自動擲骰"
L["TAB_ITEM_OVERRIDES"] = "指定物品擲骰"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "角色規則"
-- The panel for everything GogoLoot posts to chat; also its row in the mini-map button's tooltip.
L["TAB_ANNOUNCEMENTS"] = "戰利品通報"
-- Headers of the two sections on the Loot Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "交易通報"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "隊長分配通報"
L["TAB_LOOT_TOASTS"] = "拾取提示"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "篩選"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "拾取音效"
L["TAB_AUTOMATED_OPENING"] = "自動開啟"
-- A child panel of Automated Opening, beside the Openables List.
L["TAB_LOCKBOXES"] = "鎖箱"
L["TAB_OPENABLE_ITEMS"] = "可開啟清單"
-- Named for its switch, Enable Automated Master Looting. Roll Macro follows it.
L["TAB_MASTER_LOOTER"] = "自動隊長分配"
-- Header of a section on the Automated Master Looting panel.
L["TAB_LOOT_DESTINATIONS"] = "戰利品去向"
L["TAB_IGNORE_LIST"] = "忽略清單"
-- The panel after Automated Master Looting, named for its switch, Enable Roll Macro.
L["TAB_ROLL_MACRO"] = "擲骰巨集"
-- The panel after Roll Macro, for the Loot Master and Loot Tracker windows; also the Loot Master window's title.
L["TAB_LOOT_MASTER"] = "戰利品總管"

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
    The tooltip titles each feature with its options-panel name, and gives
    each a description of its own, two lines at most: the panels' longer text
    doesn't fit a tooltip.
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
L["MINIMAP_TOGGLE"] = "切換"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "已鎖物品"
-- Under the list. Argument: the game's own name for the Rogue class.
L["MINIMAP_LOCKED_ITEMS_HINT"] = "%s可以幫你開鎖。"
-- The same, shown to a Rogue. Argument: the game's own name for Pick Lock.
L["MINIMAP_LOCKED_ITEMS_HINT_ROGUE"] = "使用%s來開鎖。"
L["MINIMAP_OPTIONS"] = "GogoLoot 選項"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 中鍵點擊"

-- Heads the items on the Roll List still on a trade clock, soonest first, under Locked Items.
L["MINIMAP_TRADABLE_LOOT"] = "可交易戰利品"
-- Under the first few of them. Argument: how many more there are.
L["MINIMAP_TRADABLE_MORE"] = "還有 %d 件"
-- The loot windows' block: its title, how many items are on the Roll List, its description and its click.
L["MINIMAP_LOOT_WINDOWS"] = "戰利品總管與戰利品追蹤"
L["MINIMAP_TO_HAND_OUT"] = "%d 件待分配"
L["MINIMAP_LOOT_WINDOWS_DESCRIPTION"] = "以擲骰分配你仍可交易的物品，並關注每一次擲骰。"
L["MINIMAP_MIDDLE_CLICK"] = "中鍵點擊"
L["MINIMAP_OPEN"] = "開啟"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "手動"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "僅限%s"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s及以下"

-- How many of an item, after its link: on a toast, in a trade summary, in the mini-map's Locked Items and in Add from Bags. Argument: the count.
L["ITEM_QUANTITY"] = "x%d"
-- An item and how many, the way the game's own loot lines write it, in the loot windows and their chat lines. Arguments: the item's link, then the count.
L["ITEM_QUANTITY_LINK"] = "%sx%d"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List and Item Overrides bring text of their own), the hint the
    box shows while empty, and its button.
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
-- Shown in place of the rows when the Ignore List or Item Overrides is empty, since both refill at login.
L["ITEM_LIST_EMPTY_REFILLS"] =
	"此清單為空，因此預設物品會在你下次登入時恢復。點擊恢復預設可立即恢復。"

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

-- Shown under every setting that prints or sends a chat line. Argument: the message, drawn as it arrives in chat.
L["OPTIONS_EXAMPLE"] = "範例：%s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"快速拾取不必開啟拾取視窗就能搜空屍體，自動擲骰依品質選擇需求、貪婪或放棄，自動隊長分配替你分發戰利品。蚌殼、容器與已開鎖的鎖箱會自動開啟。拾取更快，開怪更早。"
L["WELCOME_MESSAGE"] = "啟用歡迎訊息"
L["WELCOME_MESSAGE_DESCRIPTION"] = "每次登入時顯示 GogoLoot 的版本，以及這些設定的位置。"
L["MINIMAP_BUTTON_ENABLE"] = "啟用小地圖按鈕"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"在小地圖上顯示 GogoLoot 按鈕。左鍵點擊切換自動擲骰，右鍵點擊切換自動開啟，Shift + 左鍵點擊切換戰利品通報，Shift + 右鍵點擊切換自動隊長分配。"

L["OPTIONS_COMMANDS_HEADER"] = "/指令"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "開啟此插件的選項視窗。"

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "功能"

-- The opening line of the Speedy Loot panel, above its switch.
L["SPEEDY_LOOT_DESCRIPTION"] = "打開屍體的瞬間就拿走所有東西，讓你永遠不必等待拾取視窗。"
L["SPEEDY_LOOT_ENABLE"] = "啟用快速拾取"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"打開屍體的瞬間就拾取一空，不顯示拾取視窗。拾取時按住 Shift 則照常顯示視窗。會開啟遊戲的%s設定，當你負責%s時則暫停運作。"

--[[
    The Roll Macro panel. %s is the macro's name, "- Roll", the same in every
    locale. General Macros is the tab of the game's Macros window that every
    character on the account shares; /macro is the game's command and stays
    English.
]]
L["ROLL_MACRO_DESCRIPTION"] =
	"在你的共用巨集中新增一個名為 %s、圖示為金幣的巨集，讓你帳號中的每個角色都能把它拖到快捷列上。"
--[[
    The three rows under it, each beside the game's name for a mouse button
    (MINIMAP_LEFT_CLICK and its neighbours). Right-click is the off-spec roll;
    a raid roll picks a number from 1 to the group's size.
]]
L["ROLL_MACRO_LEFT_CLICK"] = "擲骰 1-100"
L["ROLL_MACRO_RIGHT_CLICK"] = "擲骰 1-99"
L["ROLL_MACRO_MIDDLE_CLICK"] = "團隊擲骰"
L["ROLL_MACRO_ENABLE"] = "啟用擲骰巨集"
-- Under the three rows, in silver: what Middle-Click's raid roll is for and how to read it.
L["ROLL_MACRO_RAID_ROLL_NOTE"] =
	"團隊擲骰會將物品隨機交給某人。它會從 1 擲到你隊伍中的玩家人數，每個數字代表一名玩家：在團隊或隊伍名單中往下數到擲出的數字，就能找到贏家。單人時則擲 1-100。"
L["ROLL_MACRO_SWITCH_DESCRIPTION"] =
	"將 %s 巨集保留在你的共用巨集中：左鍵點擊擲 1-100，右鍵點擊擲 1-99，中鍵點擊進行團隊擲骰。關閉此選項會刪除它。"
--[[
    Printed to chat when Enable Roll Macro is switched on or off, or the macro
    can't be made. In ROLL_MACRO_ADDED the second %s is /m, the game's command
    for its Macros window, drawn in blue.
]]
L["ROLL_MACRO_ADDED"] = "%s 巨集已在你的共用巨集中。輸入 %s 並將它拖到快捷列上。"
L["ROLL_MACRO_REMOVED"] = "%s 巨集已刪除。"
L["ROLL_MACRO_FULL_LOADING"] =
	"無法新增 %s 巨集：你的共用巨集已滿。刪除一個後，下次載入畫面結束時就會加入。"

--------------------------------------------------------------------------------
-- Options: Feedback & Support Panel
--------------------------------------------------------------------------------

-- "Star" stays GitHub's English button label in every locale; Discord, CurseForge, Wago and GitHub stay as written.
L["OPTIONS_LEVEL_UP_TITLE"] = "幫助 GogoLoot 升級"
L["OPTIONS_LEVEL_UP_INTRO"] =
	"這個插件是由熱愛這款遊戲、希望讓每個人都玩得盡興的玩家打造的。我們絕不會要求捐款。真正的成就感，來自知道我們的成果讓你的遊戲體驗更好一點。如果真是如此，我們很樂意聽你說說！"
L["OPTIONS_LEVEL_UP_WAYS"] = "以下是幾種能幫助我們觸及更多玩家的方式。"
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• 分享意見：發現錯誤或有好點子嗎？到 Discord 告訴我們。你的意見能幫助我們改進插件，也隨時歡迎提交合併請求。"
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• 推薦給朋友：認識可能會喜歡這個插件的人嗎？告訴他們吧。口耳相傳能幫助更多玩家發現好插件。"
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• 在 CurseForge 加入最愛：開啟下方的 CurseForge 連結並登入，然後點擊下載按鈕下方的星號。加入最愛能幫助更多玩家發現這個插件。"
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• 在 GitHub 給個 Star：開啟下方的 GitHub 連結並登入，然後點擊右上角的 Star。Star 能幫助這個專案取得更多免費的開發者工具。"
L["OPTIONS_LEVEL_UP_THANKS"] = "感謝你選擇 GogoLoot！"

L["OPTIONS_FEEDBACK"] = "意見回饋與支援"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "意見回饋與支援連結"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "要複製連結，請點擊它的方塊，然後按 Ctrl+A 和 Ctrl+C。"
-- The version line at the foot of the Feedback & Support panel.
L["OPTIONS_VERSION"] = "版本 %s"

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

-- The pop-up's own title, which code joins with the add-on name: "Quick Settings // GogoLoot".
L["QUICK_SETTINGS_TITLE"] = "快速設定"
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
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] = "要以你所在資料片的預設物品取代你的忽略清單嗎？"
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
L["ROLLS_PARTY_AND_RAID_HEADER"] = "隊伍與團隊擲骰"
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
-- Shown on Item Overrides and Character Rules while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "自動擲骰已關閉，這些設定暫不生效。"
L["ITEM_OVERRIDES_ENABLE"] = "啟用指定物品擲骰"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"使用下方設定的擲骰。關閉時，這些物品會和其他物品一樣依照品質設定。"
-- Shown under Enable Item Overrides while it is off.
L["ITEM_OVERRIDES_OFF_NOTE"] = "指定物品擲骰已關閉，這些擲骰設定暫不生效。"
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] = "以你所在資料片的預設物品取代指定物品擲骰。"
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] = "要以你所在資料片的預設物品取代你的指定物品擲骰嗎？"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "設定此物品的自動擲骰。"
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "從指定物品擲骰中移除此物品。"
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "要從指定物品擲骰中移除此物品及其擲骰設定嗎？"
L["ITEM_OVERRIDES_ADD_DESCRIPTION"] =
	"輸入物品 ID 或將物品拖曳到這裡，即可加入清單，並設為手動。"

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
L["ANNOUNCEMENTS_ENABLE"] = "啟用戰利品通報"
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
-- The trade window checkbox tooltip's line naming when summaries are posted.
L["TRADE_WHEN"] = "時機"
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
-- The Container row is the bag class; clams, crates and lockboxes have the Openables row.
L["LOOT_TOASTS_FILTER_CONTAINER_MINE_DESCRIPTION"] =
	"顯示你拾取的背包。蚌殼、箱子和鎖箱在可開啟物品中。"
L["LOOT_TOASTS_FILTER_CONTAINER_GROUP_DESCRIPTION"] =
	"顯示隊伍或團隊中任何人拾取的背包，並附上拾取者的名字。蚌殼、箱子和鎖箱在可開啟物品中。"

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
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast "You Won" takes the
    looter's place (LOOT_TOASTS_YOU_WON_ROLL: the item, the roll); on a group
    member's, their name (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "獲勝擲骰"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"在你贏得的物品的提示上加上獲勝擲骰，例如 (你贏了, %s)。"
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"在隊友贏得的物品的提示上加上其獲勝擲骰，例如 (%s, %s)。"
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_YOU_WON_ROLL"] = "%s (你贏了, %s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "背包數量"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"當你身上的數量多於提示本身的數量時，在你自己戰利品的提示上加上目前持有的總數，例如 x3 (27)。"
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
L["LOOT_TOASTS_ALIGN_TOASTS"] = "提示對齊"
L["LOOT_TOASTS_ALIGN_TOASTS_DESCRIPTION"] = "提示對齊在拖曳把手的哪一側。"
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
L["LOOT_TOASTS_RESET_CONFIRM"] = "要將拾取提示移回預設位置嗎？"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "顯示或隱藏用來將提示拖曳到新位置的把手。"
L["LOOT_TOASTS_RESET_DESCRIPTION"] = "將提示移回螢幕中央上方的預設位置。"

-- The drag handle, titled "Loot Toasts // GogoLoot" by code: the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_CLICK_DRAG"] = "點擊 + 拖曳以調整位置"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "右鍵點擊以鎖定"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "停用拾取提示"
-- The stand-in item on the sample toasts the position preview shows; Example lines link real items.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "範例物品"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"拾取達到你所選品質或以上的戰利品時播放提示音，%s 偷到東西時播放背包音效。"
-- The Loot Sounds panel's master switch, also in the General panel's Features section; its tooltip names no position on either.
L["LOOT_SOUNDS_SWITCH"] = "啟用拾取音效"
L["LOOT_SOUNDS_SWITCH_DESCRIPTION"] = "開啟或關閉 GogoLoot 的所有拾取音效。"
-- The chime's own toggle, under the master switch.
L["LOOT_SOUNDS_ENABLE"] = "啟用拾取提示音"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"從屍體或寶箱拾取達到你所選品質或以上的物品時播放提示音。"
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "會播放拾取提示音的最低物品品質。"
L["LOOT_SOUNDS_TEST"] = "播放拾取提示音。"
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
-- Shown under Enable Lockbox Notifications while it is on and Automated Opening is off.
L["LOCKBOXES_NOTIFICATIONS_OFF_NOTE"] = "自動開啟已關閉，鎖箱通知暫不生效。"
L["LOCKBOXES_FOR_ROGUES"] = "僅限盜賊"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "所有角色"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking (225)" line (ITEM_MIN_SKILL), or under GogoLoot's own
    ITEM_REQ_SKILL line where the client prints none, followed by a skill
    number. Argument: the game's own name for the Lockpicking skill.
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
-- The same while Speedy Loot is off too.
L["OPENABLE_ITEMS_ALL_OFF_NOTE"] = "自動開啟與快速拾取都已關閉，這些設定暫不生效。"
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

--------------------------------------------------------------------------------
-- Roll Calls: Sent to the Group
--------------------------------------------------------------------------------

--[[
    What the Loot Master sends when it calls a roll, in the sent format: no
    closing period, since the add-on name follows. Item arguments are links.
    Calls, ties and pauses go to Raid Warning where the player can send one;
    results go to group chat.
]]
-- Arguments: the item, then the roll's length in seconds.
L["ROLL_CALL_START"] = "請用 /roll 擲骰：%s，限時 %d 秒"
-- Arguments: the seconds left, then the item.
L["ROLL_CALL_LAST_SECONDS"] = "剩餘 %d 秒：%s"
-- +10 Seconds. Arguments: the seconds added, then the item.
L["ROLL_CALL_EXTENDED"] = "延長 %d 秒：%s"
-- Arguments: the item, then the rolls that didn't count, each one of the four lines below, joined by commas.
L["ROLL_CALL_NOT_COUNTED"] = "%s 不計入的擲骰：%s"
-- Arguments: the player, then their roll.
L["ROLL_CALL_NOT_COUNTED_EARLY"] = "%s 提早擲骰 (%d)"
L["ROLL_CALL_NOT_COUNTED_REPEAT"] = "%s 重複擲骰 (%d)"
-- Arguments: the player, their roll, then the range they rolled in.
L["ROLL_CALL_NOT_COUNTED_RANGE"] = "%s 的 %d (%d-%d)"
L["ROLL_CALL_NOT_COUNTED_NOT_TIED"] = "%s 的 %d (未參加平手加骰)"
-- Arguments: the tied players, the roll they tied at, the item, the tied players again, then the seconds.
L["ROLL_CALL_TIE"] = "%s 以 %d 平手：%s。僅限 %s 再次 /roll，限時 %d 秒"
-- With Re-roll Ties off. Arguments: the tied players, the roll they tied at, then the item.
L["ROLL_CALL_TIE_HELD"] = "%s 以 %d 平手：%s。稍後進行平手加骰"
-- Arguments: the winner, the item, then the winning roll.
L["ROLL_CALL_WINS"] = "%s 贏得 %s，點數 %d"
-- After a disqualification or a restore changed who won. Arguments as above.
L["ROLL_CALL_NOW_WINS"] = "改由 %s 贏得 %s，點數 %d"
-- Argument: the item.
L["ROLL_CALL_NOBODY"] = "沒有人對 %s 擲骰，暫時留在我的清單上"
L["ROLL_CALL_NOBODY_LEFT"] = "%s 已無有效擲骰，放回我的清單"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_DISQUALIFIED_NO_REASON"] = "我取消了 %s 擲出的 %d 的資格：%s"
-- The same with a reason. Arguments: the player, their roll, the item, then one of the ROLL_DISQUALIFY_REASON_ lines.
L["ROLL_CALL_DISQUALIFIED_BECAUSE"] = "我取消了 %s 擲出的 %d 的資格：%s，原因：%s"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_RESTORED"] = "我恢復了 %s 擲出的 %d：%s"
-- Arguments: the item, then the seconds.
L["ROLL_CALL_VOIDED"] = "我作廢了 %s 的所有擲骰。請用 /roll 重擲，限時 %d 秒"
-- Argument: the item.
L["ROLL_CALL_CANCELED"] = "%s 的擲骰已取消，先別擲骰"
L["ROLL_CALL_PAUSED"] = "先別擲骰，%s 已暫停"
-- Arguments: the item, then the seconds left.
L["ROLL_CALL_RESUMED"] = "%s 恢復擲骰，剩餘 %d 秒"
-- Each argument: items, joined by commas.
L["ROLL_CALL_ROLL_ALL"] = "依序擲骰：%s"
L["ROLL_CALL_UP_FOR_ROLL"] = "開放擲骰：%s"
L["ROLL_CALL_FLOOR_LOOT"] = "地板戰利品開放擲骰：%s"
-- Drops by boss posted to the group, a line per boss. Arguments: the boss, then its drops, joined by commas.
L["DROPS_POST_LINE"] = "%s: %s"

--------------------------------------------------------------------------------
-- Roll Calls: Printed
--------------------------------------------------------------------------------

-- Outside a group there's nobody to send to. Argument: the line a group would have seen.
L["ROLL_CALL_SOLO_PREVIEW"] = "你不在隊伍中，因此這則訊息沒有發給任何人：%s"
-- Arguments: the winner, then the item.
L["ROLL_CALL_WON_PRINT"] = "%s 贏得了 %s。與對方開啟交易，GogoLoot 就會把它放進交易視窗。"

--------------------------------------------------------------------------------
-- Roll Tags and Reasons
--------------------------------------------------------------------------------

-- Beside a roll in the loot windows: why it doesn't count, or where it stands.
L["ROLL_TAG_EARLY"] = "在開骰前擲骰"
L["ROLL_TAG_LATE"] = "在截止後擲骰"
L["ROLL_TAG_REPEAT"] = "重複擲骰，不計入"
-- Arguments: the range the player rolled in.
L["ROLL_TAG_RANGE"] = "範圍錯誤 (%d-%d)"
L["ROLL_TAG_NOT_TIED"] = "未參加平手加骰"
L["ROLL_TAG_DISQUALIFIED"] = "已取消資格"
-- Argument: one of the reasons below.
L["ROLL_TAG_DISQUALIFIED_BECAUSE"] = "已取消資格：%s"
L["ROLL_TAG_WINNER"] = "贏家"
L["ROLL_TAG_HIGHEST"] = "目前最高"
L["ROLL_TAG_TIED"] = "平手"

-- The reasons offered when the loot master disqualifies a roll, also sent after ROLL_CALL_DISQUALIFIED_BECAUSE's colon.
L["ROLL_DISQUALIFY_REASON_NOT_ELIGIBLE"] = "不符合此物品的資格"
L["ROLL_DISQUALIFY_REASON_ALREADY_WON"] = "今晚已贏得一件物品"
L["ROLL_DISQUALIFY_REASON_FOR_SOMEONE_ELSE"] = "替別人擲骰"
L["ROLL_DISQUALIFY_REASON_NONE"] = "未提供原因"

--------------------------------------------------------------------------------
-- Loot Master Window
--------------------------------------------------------------------------------

-- The tabs. Argument: how many items each holds.
L["LOOT_MASTER_TAB_ROLL_LIST"] = "擲骰清單 (%d)"
L["LOOT_MASTER_TAB_FLOOR_LOOT"] = "地板戰利品 (%d)"
L["LOOT_MASTER_TAB_AWARDED"] = "已分配 (%d)"
L["LOOT_MASTER_TAB_SOFT_RESERVES"] = "軟預約"

-- The Roll List's buttons.
L["LOOT_MASTER_ROLL"] = "擲骰"
L["LOOT_MASTER_ROLL_AGAIN"] = "重新擲骰"
L["LOOT_MASTER_ROLL_ALL"] = "全部擲骰"
L["LOOT_MASTER_PAUSE"] = "暫停"
L["LOOT_MASTER_RESUME"] = "繼續"
L["LOOT_MASTER_STOP"] = "停止"
L["LOOT_MASTER_LIST_IN_RAID"] = "在團隊中列出"
L["LOOT_MASTER_MOVE_UP"] = "上移"
L["LOOT_MASTER_MOVE_DOWN"] = "下移"
-- Argument: the seconds added.
L["LOOT_MASTER_EXTEND"] = "+%d 秒"
L["LOOT_MASTER_CLOSE_NOW"] = "立即截止"
L["LOOT_MASTER_VOID"] = "作廢所有擲骰"
L["LOOT_MASTER_CANCEL_ROLL"] = "取消擲骰"
L["LOOT_MASTER_TAKE_OFF"] = "移出清單"
-- Argument: the winner.
L["LOOT_MASTER_GIVE"] = "交給 %s"
L["LOOT_MASTER_TRADE"] = "與 %s 交易"
L["LOOT_MASTER_ANNOUNCE_WINNER"] = "通報贏家"
L["LOOT_MASTER_HANDED_OUT"] = "標記為已分配"
L["LOOT_MASTER_REROLL_TIED"] = "平手重擲"
L["LOOT_MASTER_DISQUALIFY"] = "取消資格"
L["LOOT_MASTER_RESTORE"] = "恢復"

-- A row's trade clock, where it has none to show.
L["LOOT_MASTER_ON_CORPSE"] = "在屍體上"
L["LOOT_MASTER_CORPSE_CLOSED"] = "屍體已關閉"
L["LOOT_MASTER_BOUND"] = "已綁定"
L["LOOT_MASTER_NO_LIMIT"] = "無時限"

-- A row's state. Argument: how many rolls have landed.
L["LOOT_MASTER_STATUS_ROLLING"] = "擲骰中，%d 次擲骰"
L["LOOT_MASTER_STATUS_TIE_BREAK"] = "平手加骰，%d 次擲骰"
L["LOOT_MASTER_STATUS_ON_HOLD"] = "暫停中，%d 次擲骰"
-- STATUS_TIED and STATUS_NOBODY also title a finished roll in the Loot Tracker.
L["LOOT_MASTER_STATUS_TIED"] = "平手"
L["LOOT_MASTER_STATUS_NOBODY"] = "無人擲骰"
L["LOOT_MASTER_STATUS_SOULBOUND"] = "已靈魂綁定"
L["LOOT_MASTER_STATUS_UP_NEXT"] = "下一個"

-- The first line of an opened row.
L["LOOT_MASTER_HEADLINE_ROLLING"] = "擲骰中，剩餘 %d 秒。"
L["LOOT_MASTER_HEADLINE_ON_HOLD"] = "暫停中，剩餘 %d 秒。"
-- Arguments: the tied players, then the seconds left.
L["LOOT_MASTER_HEADLINE_TIE_BREAK"] = "%s 的平手加骰，剩餘 %d 秒。"
-- Arguments: the winner, then the winning roll.
L["LOOT_MASTER_HEADLINE_WON"] = "%s 以 %d 獲勝。"
-- Arguments: the tied players, then the roll they tied at.
L["LOOT_MASTER_HEADLINE_TIED"] = "%s 以 %d 平手。"
L["LOOT_MASTER_HEADLINE_SOULBOUND"] = "已靈魂綁定，無法再交易。"
-- Argument: the boss. Also under the game's own trade line on a bag item's tooltip while it is on the Roll List.
L["LOOT_MASTER_LOOTED_FROM"] = "拾取自 %s。"
L["LOOT_MASTER_FROM_FLOOR_LOOT"] = "來自地板戰利品。"
-- After the line above. Argument: how long, in the game's own words for time.
L["LOOT_MASTER_TRADABLE_FOR"] = "還可交易 %s。"
-- Headings over a row's rolls; ROUND_SO_FAR also heads an open roll in the Loot Tracker.
L["LOOT_MASTER_ROUND_SO_FAR"] = "目前的擲骰"
L["LOOT_MASTER_ROUND_ROLLS"] = "擲骰"
L["LOOT_MASTER_ROUND_FIRST"] = "第一輪擲骰"
L["LOOT_MASTER_ROUND_TIE_BREAK"] = "平手加骰"
-- Arguments: how many, then their names. Also in the Loot Tracker.
L["LOOT_MASTER_HASNT_ROLLED"] = "尚未擲骰 (%d)：%s"

L["LOOT_MASTER_EMPTY"] =
	"還沒有要分配的物品。你拾取的可交易戰利品會自動出現在這裡；Alt + 點擊其他背包物品即可加入。"
-- The line beside the Roll List's buttons.
L["LOOT_MASTER_STATE_PAUSED"] = "已暫停。"
L["LOOT_MASTER_STATE_ROLL_ALL"] = "全部擲骰：還剩 %d 件。"
L["LOOT_MASTER_STATE_ONE_AT_A_TIME"] = "一次擲一件。"
L["LOOT_MASTER_STATE_WAITING"] = "%d 件等待擲骰。"
-- The foot of the Roll List. Arguments: how many items, then the time left on the soonest trade clock.
L["LOOT_MASTER_FOOTER"] = "%d 件待分配。"
L["LOOT_MASTER_FOOTER_CLOCK"] = "%d 件待分配，下一件的交易時限剩 %s。"
L["LOOT_MASTER_ALT_CLICK_HINT"] = "Alt + 點擊背包物品即可加入"

-- The Disqualify window.
L["LOOT_MASTER_DISQUALIFY_TITLE"] = "取消擲骰資格"
-- Arguments: the player, their roll, then the item.
L["LOOT_MASTER_DISQUALIFY_BODY"] = "要取消 %s 擲出的 %d 角逐 %s 的資格嗎？之後仍可恢復。"
L["LOOT_MASTER_DISQUALIFY_REASON"] = "原因"
L["LOOT_MASTER_DISQUALIFY_TELLS"] = "GogoLoot 會告訴隊伍："
-- Argument: the item.
L["LOOT_MASTER_VOID_CONFIRM"] = "要作廢 %s 的所有擲骰並重新開骰嗎？"

-- Printed by the Loot Master.
L["LOOT_MASTER_ROLL_ALL_DONE"] = "全部擲骰已完成。擲骰清單上的每件物品都已擲過骰。"
L["LOOT_MASTER_ROLL_ALL_PAUSED"] = "全部擲骰已暫停。在你按下繼續之前，不會開始新的擲骰。"
L["LOOT_MASTER_ROLL_ALL_RESUMED"] = "全部擲骰已繼續。"
L["LOOT_MASTER_ROLL_ALL_STOPPED"] = "全部擲骰已停止。進行中的擲骰仍會完成。"
-- Arguments: the item, then the whole minutes left.
L["LOOT_MASTER_TRADE_TIME_LOW"] = "%s 還可交易 %d 分鐘。"
-- Argument: the item.
L["LOOT_MASTER_TRADE_TIME_OVER"] = "%s 已無法再交易。"
-- Arguments: the item, the winner, then their winning roll.
L["LOOT_MASTER_TRADE_FILLED"] = "已將 %s 放入交易視窗，交給 %s，對方以 %d 點贏得。"
-- Arguments: the winner, then the item.
L["LOOT_MASTER_NOT_A_CANDIDATE"] = "無法從這具屍體交給 %s：%s。"
-- Argument: the item.
L["LOOT_MASTER_ADDED"] = "%s 已加入擲骰清單。"
L["LOOT_MASTER_NOT_TRADABLE"] = "%s 無法交易，因此不能加入擲骰清單。"
-- Argument: how many joined.
L["LOOT_MASTER_FLOOR_ADDED"] = "地板戰利品已加入擲骰清單：%d 件。"
L["LOOT_MASTER_OFF"] = "戰利品總管已關閉。請在 選項 > 插件 > GogoLoot > 戰利品總管 中開啟。"

-- A bag item's tooltip, under the game's own trade line, while it is on the Roll List.
L["LOOT_MASTER_TOOLTIP_ON_ROLL_LIST"] = "在擲骰清單上。"
-- Arguments: the winner, then their winning roll.
L["LOOT_MASTER_TOOLTIP_WON_BY"] = "由 %s 以 %d 贏得。"

-- Floor Loot. The add box, filter and Add from Bags use the item lists' own words (ITEM_LIST_*).
L["LOOT_MASTER_FLOOR_DESCRIPTION"] =
	"沒有交易時限、但你想擲骰分配的戰利品：材料、配方、裝備後綁定的裝備。清單一開始是空的，只有你加入的物品才會擲骰。每一疊擲一次骰。"
L["LOOT_MASTER_FLOOR_EMPTY"] =
	'這裡還沒有東西。從"從背包新增"挑選，或將物品拖放到上方的方塊。'
-- Argument: how many the bags hold.
L["LOOT_MASTER_FLOOR_IN_BAGS"] = "背包中 %d 件"
L["LOOT_MASTER_FLOOR_ON_ROLL_LIST"] = "在擲骰清單上"
L["LOOT_MASTER_FLOOR_REMOVE"] = "將此物品從地板戰利品移除。"
-- The heading for an item whose kind the game hasn't said yet.
L["LOOT_MASTER_FLOOR_OTHER"] = "其他"
L["LOOT_MASTER_FLOOR_ADD_ALL"] = "全部加入擲骰清單"
-- Add from Bags' two headings.
L["LOOT_MASTER_FLOOR_MENU_PICKED_UP"] = "在此副本中拾取"
L["LOOT_MASTER_FLOOR_MENU_BAGS"] = "也在你的背包中"
-- Argument: what was typed.
L["LOOT_MASTER_FLOOR_NOT_FOUND"] = '背包中沒有符合"%s"的可交易物品。'

-- Awarded.
L["LOOT_MASTER_AWARDED_EMPTY"] =
	"還沒有分配任何物品。贏得的物品交到贏家手上後，就會出現在這裡。"
-- Arguments: the winning roll, then the time it was handed out.
L["LOOT_MASTER_AWARDED_ROLLED"] = "擲出 %d，%s"
-- Argument: the time it was handed out.
L["LOOT_MASTER_AWARDED_GIVEN"] = "分配於 %s"
L["LOOT_MASTER_AWARDED_CLEAR"] = "清除"

-- Soft Reserves, a placeholder for now.
L["LOOT_MASTER_SOFT_RESERVES_DESCRIPTION"] =
	"在此貼上軟預約字串，即可查看誰預約了什麼。即將推出：此分頁目前只是預留位置。"
L["LOOT_MASTER_SOFT_RESERVES_PLACEHOLDER"] = "軟預約匯入功能尚未完成。"
L["LOOT_MASTER_SOFT_RESERVES_IMPORT"] = "匯入"

--------------------------------------------------------------------------------
-- Loot Tracker Window
--------------------------------------------------------------------------------

L["LOOT_TRACKER_TITLE"] = "戰利品追蹤"
L["LOOT_TRACKER_TAB_ROLLS"] = "擲骰"
L["LOOT_TRACKER_TAB_DROPS"] = "掉落"
L["LOOT_TRACKER_NO_ROLL"] = "今晚還沒有擲骰。"
-- Argument: who called the roll.
L["LOOT_TRACKER_CALLED_BY"] = "由 %s 開骰"
L["LOOT_TRACKER_SPOTTED"] = "從 %s 的聊天訊息中偵測到"
-- Argument: whole seconds left.
L["LOOT_TRACKER_SECONDS_LEFT"] = "剩 %d 秒"
-- A roll called without GogoLoot. Argument: who called it.
L["LOOT_TRACKER_UNSYNCED_NOTE"] =
	"%s 沒有使用 GogoLoot，因此這些是從聊天中看到的擲骰，依一般規則檢查：1-100，只計第一次擲骰。最終由開骰者決定。"
L["LOOT_TRACKER_ON_HOLD"] = "暫停中。請等待重新擲骰的通知。"
L["LOOT_TRACKER_TIE_BREAK_ROLLS"] = "平手加骰"
-- Arguments: the winner, then the winning roll.
L["LOOT_TRACKER_WON_WITH"] = "%s 以 %d 獲勝"
L["LOOT_TRACKER_CLOSED"] = "已截止"
-- The sort buttons.
L["LOOT_TRACKER_SORT_HIGH"] = "最高"
L["LOOT_TRACKER_SORT_TIME"] = "依擲骰順序"
L["LOOT_TRACKER_ROLL"] = "擲骰 (1-100)"
-- Beside the player's own roll, and the line beside the Roll and Pass buttons.
L["LOOT_TRACKER_YOU"] = "你"
L["LOOT_TRACKER_YOU_ROLLED"] = "你擲出了 %d。"
L["LOOT_TRACKER_YOU_PASSED"] = "你放棄了。"
L["LOOT_TRACKER_NOT_ROLLED"] = "你還沒擲骰。"
L["LOOT_TRACKER_NOT_IN_TIE_BREAK"] = "現在只有平手的玩家擲骰。"
L["LOOT_TRACKER_EARLIER"] = "今晚稍早"
--[[
    The word, in lower case, that marks a group chat line with an item link as
    a call for rolls by someone without GogoLoot. "roll" is always read too.
]]
L["LOOT_TRACKER_ROLL_WORD"] = "骰"

-- Drops.
L["LOOT_TRACKER_SHOW_WINNERS"] = "顯示誰拿到什麼"
L["LOOT_TRACKER_DROPS_EMPTY"] =
	"還沒看到掉落。擊敗首領並拾取屍體後，掉落物就會顯示在這裡。"
L["LOOT_TRACKER_DROPS_NOTHING_SEEN"] = "還沒有使用 GogoLoot 的人拾取它。"
L["LOOT_TRACKER_NOT_HANDED_OUT"] = "尚未分配"
L["LOOT_TRACKER_PRINT"] = "顯示於聊天"
L["LOOT_TRACKER_POST"] = "發送到團隊"
L["LOOT_TRACKER_COPY"] = "複製"
L["LOOT_TRACKER_COPY_TITLE"] = "以 Ctrl+C 複製"

-- Drops by boss, printed and copied.
L["DROPS_TRASH"] = "小怪"
L["DROPS_NONE"] = "尚未記錄任何掉落。"
-- Argument: the instance.
L["DROPS_PRINT_HEADER"] = "%s 的掉落："
-- Arguments: the boss, then its drops, joined by commas.
L["DROPS_PRINT_LINE"] = "%s: %s."
-- An item and who got it. Arguments: the item, then the winner (with their roll, below).
L["DROPS_WINNER"] = "%s (%s)"
-- Arguments: the winner, then their winning roll.
L["DROPS_WINNER_ROLL"] = "%s %d"

--------------------------------------------------------------------------------
-- Options: Loot Master
--------------------------------------------------------------------------------

L["LOOT_MASTER_PANEL_DESCRIPTION"] =
	"以擲骰分配你仍可交易的物品，每件物品都會顯示交易時限，並在戰利品追蹤中關注每一次擲骰。中鍵點擊小地圖按鈕，或輸入 /gogo master 或 /gogo tracker。"
L["LOOT_MASTER_ENABLE"] = "啟用戰利品總管"
L["LOOT_MASTER_ENABLE_DESCRIPTION"] =
	"追蹤你仍可交易的戰利品並為它開骰。關閉時，戰利品總管與戰利品追蹤都不會開啟，也不會讀取任何擲骰。"
L["LOOT_MASTER_OPEN"] = "開啟戰利品總管"
L["LOOT_TRACKER_OPEN"] = "開啟戰利品追蹤"
-- A dropdown choice. Argument: the number.
L["LOOT_MASTER_SECONDS"] = "%d 秒"
L["LOOT_MASTER_MINUTES"] = "%d 分鐘"
L["LOOT_MASTER_KEEP_RAIDS"] = "%d"

L["LOOT_MASTER_CALLING_HEADER"] = "開骰"
L["LOOT_MASTER_ROLL_LENGTH"] = "擲骰時間"
L["LOOT_MASTER_ROLL_LENGTH_DESCRIPTION"] = "擲骰開放多久。"
L["LOOT_MASTER_ANNOUNCE_IN"] = "通報頻道"
L["LOOT_MASTER_ANNOUNCE_IN_DESCRIPTION"] = "開骰、平手與暫停的訊息要發送到哪裡。"
L["LOOT_MASTER_CHANNEL_GROUP"] = "隊伍頻道"
L["LOOT_MASTER_ANNOUNCE_IN_NOTE"] =
	"當你不是隊長或助理時，團隊警告會改用隊伍頻道。贏家一律發送到隊伍頻道。"
-- Argument: the seconds.
L["LOOT_MASTER_WARN_LAST_SECONDS"] = "剩餘 %d 秒時提醒"
L["LOOT_MASTER_WARN_LAST_SECONDS_DESCRIPTION"] = "擲骰即將截止時告訴隊伍。"
-- Argument: the seconds.
L["LOOT_MASTER_STRETCH_LATE"] = "有人晚擲時增加 %d 秒"
L["LOOT_MASTER_STRETCH_LATE_DESCRIPTION"] =
	"在最後幾秒內的擲骰會讓擲骰再開放一下，避免有人因為延遲被截掉。"
L["LOOT_MASTER_END_EARLY"] = "所有人都擲骰或放棄後提前結束"
L["LOOT_MASTER_END_EARLY_DESCRIPTION"] = "當每位隊伍成員都已擲骰或輸入 pass 時，立即截止擲骰。"
L["LOOT_MASTER_REROLL_TIES"] = "平手的玩家之間重擲"
L["LOOT_MASTER_REROLL_TIES_DESCRIPTION"] =
	"立即為平手的玩家開啟平手加骰。關閉時，平手會等你按下平手重擲。"
L["LOOT_MASTER_ROLL_ALL_PAUSE"] = "全部擲骰的物品間隔"
L["LOOT_MASTER_ROLL_ALL_PAUSE_DESCRIPTION"] = "全部擲骰在一次擲骰結束後，要等多久才開下一個。"

L["LOOT_MASTER_COUNTING_HEADER"] = "有效的擲骰"
-- Argument: the seconds of grace.
L["LOOT_MASTER_COUNTING_DESCRIPTION"] =
	"來自你隊伍、在擲骰開放期間的一般 /roll (1-100)，每位玩家只計第一次 (延遲寬限 %d 秒)。不計入的擲骰仍會留在清單中，並註明原因。"
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED"] = "通報不計入的擲骰"
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED_DESCRIPTION"] =
	"擲骰截止時，以一行列出不計入的擲骰及原因。你取消資格的擲骰一律會通報。"

L["LOOT_MASTER_TRADE_HEADER"] = "可交易戰利品"
L["LOOT_MASTER_OPEN_ON_TRADABLE"] = "拾取可交易物品時開啟"
L["LOOT_MASTER_OPEN_ON_TRADABLE_DESCRIPTION"] =
	"在隊伍中時，若仍可交易的拾取後綁定戰利品進入你的背包，就開啟戰利品總管。"
L["LOOT_MASTER_TRADE_WARN"] = "交易時間快結束時提醒我"
L["LOOT_MASTER_TRADE_WARN_DESCRIPTION"] =
	"擲骰清單上的物品即將靈魂綁定時，在聊天中提醒你一次。"
L["LOOT_MASTER_TRADE_WARN_WHEN"] = "提醒你時剩餘的交易時間。"
L["LOOT_MASTER_TRADE_AUTO_FILL"] = "將贏得的物品放入交易視窗"
L["LOOT_MASTER_TRADE_AUTO_FILL_DESCRIPTION"] =
	"當你與贏家開啟交易時，會替你放入對方贏得的物品。你仍需自己按下交易。"

L["LOOT_MASTER_FLOOR_HEADER"] = "地板戰利品"
L["LOOT_MASTER_FLOOR_PANEL_DESCRIPTION"] =
	"地板戰利品一開始是空的，只包含你加入的物品。從背包新增會優先列出你在此副本中拾取的物品。"
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE"] = "物品離開背包後移出"
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE_DESCRIPTION"] =
	"當你身上已沒有該物品時 (交易、賣掉或用掉)，將它從地板戰利品移除。"
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE"] = "離開團隊時清空地板戰利品"
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE_DESCRIPTION"] = "每次團隊都以空的地板戰利品清單開始。"

L["LOOT_TRACKER_OPEN_ON_ROLL"] = "有人開骰時開啟"
L["LOOT_TRACKER_OPEN_ON_ROLL_DESCRIPTION"] =
	"當隊伍中有人透過 GogoLoot 或團隊警告開骰時，開啟戰利品追蹤。"
L["LOOT_TRACKER_AUTO_CLOSE"] = "擲骰結束後自動關閉"
L["LOOT_TRACKER_AUTO_CLOSE_DESCRIPTION"] =
	"自動開啟的戰利品追蹤會在擲骰結束 30 秒後關閉，除非你的滑鼠停在上面。"
L["LOOT_TRACKER_KEEP_DROPS"] = "掉落保留的團隊數"
L["LOOT_TRACKER_KEEP_DROPS_DESCRIPTION"] = "掉落分頁要記住幾次團隊。"
