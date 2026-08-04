local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "zhTW")
if not L then
	return
end

--[[
    Translated from enUS.lua, the source locale any missing key falls back to.
    Translate the values only. Never change the L["KEY"] names, the %s / %d
    placeholders, or the {rt4} raid marker — code and enUS.lua rely on them.
]]

--------------------------------------------------------------------------------
-- Add-on Identity
--------------------------------------------------------------------------------

-- Brands every print, sent message, options panel, and report. A proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"版本 %s。設定（包含停用此訊息的選項）可以在 選項 > 插件 > GogoLoot 中找到。喜歡這個插件嗎？告訴你的朋友吧！(="
L["CHAT_OPTIONS_IN_COMBAT"] = "基於安全考量，戰鬥中無法開啟選項介面。"
L["MESSAGE_AUTO_LOOT_ENABLED"] = "自動拾取已啟用。快速拾取需要它才能運作。"
L["MESSAGE_NOT_MASTER_LOOTER"] = "您目前不是隊長分配者。"

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "將 %s 交給了 %s。"
L["MESSAGE_DESTINATION_SET"] = "%s 將接收所有的 %s 物品。"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s 將為隊伍保管所有戰利品。"
L["MESSAGE_DESTINATION_LEFT"] = "%s 離開了隊伍。%s 現在將接收所有的 %s 物品。"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "將 %s 交給了 %s，收到了 %s。"
L["MESSAGE_TRADE_RECEIVED"] = "收到了來自 %s 的 %s。"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "%s 的背包已滿：%s"
L["ERROR_MAX_COUNT"] = "%s 已經擁有太多：%s"
L["ERROR_OUT_OF_RANGE"] = "%s 距離過遠：%s"
L["ERROR_NOT_IN_GROUP"] = "%s 已不在隊伍或團隊中：%s"
L["ERROR_DISTRIBUTION_FAILED"] = "無法給予 %s：%s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "隊長分配"
L["TAB_AUTOMATED_ROLLS"] = "自動擲骰"
L["TAB_ANNOUNCEMENTS"] = "通報"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "已啟用"
L["STATUS_DISABLED"] = "已停用"

--[[
    The tooltip titles each feature with its options-panel name rather than
    keeping its own copy: Automated Rolls uses TAB_AUTOMATED_ROLLS, Speedy Loot
    uses SPEEDY_LOOT_HEADER and SPEEDY_LOOT_DESCRIPTION. Only the roll
    description below is unique to the tooltip, where the panel's longer text
    would not fit.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "替你對不高於所選品質的符合條件物品自動擲骰。"

L["MINIMAP_LEFT_CLICK"] = "左鍵點擊"
L["MINIMAP_RIGHT_CLICK"] = "右鍵點擊"
L["MINIMAP_TOGGLE"] = "切換"
L["MINIMAP_OPTIONS"] = "GogoLoot 選項"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 中鍵點擊"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- Quality Labels
L["QUALITY_POOR"] = "粗糙"
L["QUALITY_COMMON"] = "普通"
L["QUALITY_UNCOMMON"] = "優秀"
L["QUALITY_RARE"] = "精良"
L["QUALITY_EPIC"] = "史詩"

-- Roll Action Labels
L["ROLL_MANUAL"] = "手動"
L["ROLL_GREED"] = "貪婪"
L["ROLL_NEED"] = "需求"
L["ROLL_PASS"] = "放棄"

-- Loot Method Labels
L["LOOT_METHOD_FREE_FOR_ALL"] = "自由拾取"
L["LOOT_METHOD_ROUND_ROBIN"] = "輪流拾取"
L["LOOT_METHOD_MASTER"] = "隊長分配"
L["LOOT_METHOD_GROUP"] = "隊伍分配"
L["LOOT_METHOD_NEED_BEFORE_GREED"] = "需求優先"

-- Threshold Labels
L["THRESHOLD_POOR_ONLY"] = "僅限粗糙"
L["THRESHOLD_COMMON_LOWER"] = "普通及以下"
L["THRESHOLD_UNCOMMON_LOWER"] = "優秀及以下"
L["THRESHOLD_RARE_LOWER"] = "精良及以下"
L["THRESHOLD_EPIC_LOWER"] = "史詩及以下"

-- Shared by both item lists: the Master Looter ignore list and the Custom Roll List
L["ITEM_LIST_ADD"] = "新增物品"
L["ITEM_LIST_ADD_DESCRIPTION"] = "輸入物品 ID 或將物品拖曳至此以將其新增至列表。"

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "載入中... (ID: %d)"

-- Appended to both the Automated Master Looting and the Automated Rolls description.
L["SAFETY_SKIP_NOTE"] = "任務物品、配方、書籍、坐騎、寵物和傳說物品總是被略過。"

-- Version prefix in the options panel
L["VERSION_LABEL"] = "版本"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] =
	"透過自動隊長分配、自動擲骰和透明的通報收集裝備。任務物品、配方、坐騎、寵物和傳說物品始終安全。別讓拾取拖慢你的 zug！"
L["WELCOME_MESSAGE"] = "啟用歡迎訊息"
L["MINIMAP_BUTTON_ENABLE"] = "啟用小地圖按鈕"

L["OPTIONS_COMMANDS_HEADER"] = "/指令"
L["OPTIONS_COMMAND"] = "/gl"
L["OPTIONS_COMMAND_ALTERNATE"] = "/gogoloot"
L["OPTIONS_COMMAND_DESCRIPTION"] = "開啟此插件的選項介面。"

L["SPEEDY_LOOT_HEADER"] = "快速拾取"
L["SPEEDY_LOOT_DESCRIPTION"] = "隱藏拾取視窗，實現近乎瞬間的拾取。"
L["SPEEDY_LOOT_ENABLE"] = "啟用快速拾取"

L["FEEDBACK_SUPPORT"] = "回饋與支援"

-- CurseForge / GitHub / Discord / Wago are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"] = "你隊伍目前的拾取方式和品質門檻。"
L["MASTER_LOOTER_LOOT_METHOD"] = "拾取方式"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "拾取品質門檻"
L["MASTER_LOOTER_SET_BY"] = "(由 %s 設定)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "只有隊長可以變更拾取方式和品質門檻。"

L["MASTER_LOOTER_AUTO_HEADER"] = "自動隊長分配"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] = "當您是隊長分配者時，將戰利品分配給您指定的玩家。"
L["MASTER_LOOTER_AUTO_ENABLE"] = "在副本中啟用自動隊長分配"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "在副本外啟用自動隊長分配"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] = "警告：由於世界首領掉落無法交易，不建議使用此功能！"

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // 快速設定"
L["MASTER_LOOTER_POPUP_DESCRIPTION"] = "每當你成為戰利品分配者時，開啟一個設定戰利品的視窗。"
L["MASTER_LOOTER_POPUP_ENABLE"] = "啟用分配者視窗"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "戰利品目標"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "指定小隊成員接收每個品質級別的物品。"
L["MASTER_LOOTER_DESTINATION_SELF"] = "自己"
L["MASTER_LOOTER_SEND_ALL"] = "全部戰利品發送給"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] =
	"將所有品質發送給同一名玩家。可在下方單獨設定各品質以覆蓋。"
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "選擇誰接收 %s 物品。"

L["MASTER_LOOTER_IGNORE_HEADER"] = "忽略列表"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] = "清單中的物品跳過自動分配，留待手動分配。"
L["MASTER_LOOTER_IGNORE_RESTORE"] = "恢復預設忽略列表"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"這將使用您的資料片的預設物品取代您的隊長分配忽略列表。是否繼續？"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "從忽略列表中移除此物品。"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] =
	"在隊伍與團隊中，都會替你對不高於所選品質的非拾取綁定物品自動擲骰。"
L["ROLLS_ENABLE"] = "啟用自動擲骰"
L["ROLLS_THRESHOLD_HEADER"] = "門檻"
L["ROLLS_THRESHOLD_DESCRIPTION"] =
	"分別為隊伍與團隊設定品質上限，以及 GogoLoot 替你擲出的骰子。"
L["ROLLS_IN_PARTY"] = "在隊伍中"
L["ROLLS_IN_RAID"] = "在團隊中"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s：自動對該品質及以下的物品擲骰。"
L["ROLLS_ACTION_CHOOSE"] = "%s：GogoLoot 替你擲出的骰子，或是否交由你自己擲骰。"

L["ROLLS_CUSTOM_LIST"] = "自訂擲骰列表"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "為特定物品指定各自的擲骰動作，覆寫門檻。"
L["ROLLS_CUSTOM_LIST_ENABLE"] = "啟用自訂擲骰列表"
L["ROLLS_RESTORE_DEFAULTS"] = "恢復預設自訂擲骰列表"
L["ROLLS_RESTORE_CONFIRM"] =
	"這將使用您的資料片的預設物品取代您的自訂擲骰列表。是否繼續？"
L["ROLLS_CHOOSE_ACTION"] = "為該物品選擇自動擲骰動作。"
L["ROLLS_REMOVE_DESCRIPTION"] = "從自訂擲骰列表中移除此物品。"

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "交易通報"
L["TRADE_DESCRIPTION"] = "發布每筆完成交易的摘要：物品、附魔和金幣。"
L["TRADE_ENABLE"] = "啟用交易通報"
L["TRADE_CONDITION"] = "條件"
L["TRADE_CONDITION_ALWAYS"] = "始終"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "僅在小隊或團隊中"
L["TRADE_CONDITION_RAID_ONLY"] = "僅在團隊中"
L["TRADE_OUTPUT"] = "訊息輸出"
L["TRADE_OUTPUT_WHISPER"] = "密語"
L["TRADE_OUTPUT_GROUP"] = "小隊聊天"
L["TRADE_EXAMPLE"] = "範例：{rt4} GogoLoot // 將 [物品 X] x2，[物品 Y] 交給了 Fathom。"
L["TRADE_TOOLTIP_DESCRIPTION"] = "此交易完成時將摘要發送到聊天頻道。"
L["TRADE_TOOLTIP_OUTPUT"] = "目前輸出"
L["TRADE_CHECKBOX_LABEL"] = "通報"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] =
	"將隊長分配活動發送到隊伍頻道。自動分配使用品質門檻以避免洗頻；手動分配一律會通報。"

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "啟用戰利品歸屬訊息"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] =
	"範例：{rt4} GogoLoot // Aevala 將接收所有的 史詩 物品。"

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "啟用自動分配通報"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "自動通報門檻"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "範例：{rt4} GogoLoot // 將 [物品 X] 給了 Fathom。"

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] = "注意：手動分配的每件物品都會通報，無論品質如何。"
