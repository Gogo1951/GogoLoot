local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "zhTW")
if not L then return end

--[[
    Source locale: every other locale falls back to these strings. Translate
    the values only. Never change the L["KEY"] names, the %s / %d placeholders,
    or the {rt4} raid marker — code and other locales rely on them.
]]

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "版本 %s。設定（包含停用此訊息的選項）可以在 選項 > 插件 > GogoLoot 中找到。喜歡這個插件嗎？告訴你的朋友吧！(="
L["MESSAGE_AUTO_LOOT_ENABLED"] = "GogoLoot 正常運作需要開啟自動拾取。自動拾取已啟用。"
L["MESSAGE_NOT_MASTER_LOOTER"] = "您目前不是隊長分配者。"

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

L["MESSAGE_LOOT_ANNOUNCE"] = "將 %s 交給了 %s。"
L["MESSAGE_DESTINATION_SET"] = "%s 將接收所有的 %s 物品。"
L["MESSAGE_DESTINATION_LEFT"] = "%s 離開了隊伍。%s 現在將接收所有的 %s 物品。"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "將 %s 交給了 %s，收到了 %s。"
L["MESSAGE_TRADE_GAVE"] = "將 %s 交給了 %s。"
L["MESSAGE_TRADE_RECEIVED"] = "收到了來自 %s 的 %s。"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "您選擇接收該物品的玩家背包已滿。"
L["ERROR_MAX_COUNT"] = "您選擇接收該物品的玩家已經擁有太多該物品。"
L["ERROR_OUT_OF_RANGE"] = "您選擇接收該物品的玩家距離過遠。"
L["ERROR_NOT_IN_GROUP"] = "您選擇接收該物品的玩家不再處於隊伍或團隊中。"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "隊長分配"
L["TAB_AUTOMATED_ROLLS"] = "自動擲骰"
L["TAB_ANNOUNCEMENTS"] = "通報"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- GogoLoot is a proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "Enabled"
L["STATUS_DISABLED"] = "Disabled"

L["MINIMAP_AUTO_GREED"] = "自動貪婪"
L["MINIMAP_AUTO_GREED_DESCRIPTION"] = "對等於或低於所選品質門檻的符合條件物品自動擲貪婪。關閉此選項後，將不會進行任何自動擲骰 — 包括自訂擲骰列表。"
L["MINIMAP_SPEEDY_LOOT"] = "快速拾取"
L["MINIMAP_SPEEDY_LOOT_DESCRIPTION"] = "立即拾取戰利品而不顯示拾取視窗。"

L["MINIMAP_LEFT_CLICK"] = "左鍵點擊"
L["MINIMAP_RIGHT_CLICK"] = "右鍵點擊"
L["MINIMAP_TOGGLE"] = "切換"
L["MINIMAP_OPTIONS"] = "GogoLoot Options"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Middle-Click"

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
L["ROLL_MANUAL"] = "手動擲骰"
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

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "載入中... (ID: %d)"

-- Version prefix in the options panel and minimap tooltip
L["VERSION_LABEL"] = "版本"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] = "透過自動隊長分配吸取裝備，對非拾取綁定掉落物自動擲需求或貪婪，並在聊天中透明地通報每筆交易。任務物品、配方、坐騎、寵物和傳說物品始終安全。別讓拾取拖慢你的腳步——Zug zug！"
L["WELCOME_MESSAGE"] = "啟用歡迎訊息"
L["MINIMAP_BUTTON_ENABLE"] = "Enable Minimap Button"

L["COMMANDS"] = "/指令"
L["COMMANDS_DESCRIPTION"] = "開啟 GogoLoot 選項介面。"

L["SPEEDY_LOOT_HEADER"] = "快速拾取"
L["SPEEDY_LOOT_DESCRIPTION"] = "立即拾取戰利品而不顯示拾取視窗，節省擊殺之間的時間。"
L["SPEEDY_LOOT_ENABLE"] = "啟用快速拾取"

L["FEEDBACK_SUPPORT"] = "回饋與支援"

-- CurseForge / GitHub / Discord are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

--------------------------------------------------------------------------------
-- Options: Profiles
--------------------------------------------------------------------------------

L["OPTIONS_RESET_ALL_PROFILES"] = "Reset All Profiles"
L["OPTIONS_RESET_ALL_PROFILES_DESCRIPTION"] = "Reset every profile on this account back to default settings."
L["OPTIONS_RESET_ALL_PROFILES_CONFIRM"] = "This will reset ALL profiles on your account back to default settings — every character. There is no undo. Continue?"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"] = "Your group's current loot method and loot threshold."
L["MASTER_LOOTER_LOOT_TYPE"] = "拾取方式（唯讀，透過遊戲選單更改）"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "分配品質（唯讀，透過遊戲選單更改）"
L["MASTER_LOOTER_SET_BY"] = "(Set by %s)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "Only the group leader can change the loot method and threshold."

L["MASTER_LOOTER_AUTO_HEADER"] = "自動隊長分配"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] = "當您是隊長分配者時，自動將戰利品分配給指定的玩家。任務物品、書籍、配方、坐騎、寵物和傳說物品總是被略過，並出現在標準的拾取視窗中。"
L["MASTER_LOOTER_AUTO_ENABLE"] = "在副本中啟用自動隊長分配"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "在副本外啟用自動隊長分配"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] = "警告：由於世界首領掉落無法交易，不建議使用此功能！"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "戰利品目標"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "指定小隊成員接收每個品質級別的物品。"
L["MASTER_LOOTER_DESTINATION_SELF"] = "自己"
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "選擇誰接收 %s 物品。"

L["MASTER_LOOTER_IGNORE_HEADER"] = "忽略列表"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] = "此列表中的物品將不會自動分配，並出現在標準的拾取視窗中以供手動分配。"
L["MASTER_LOOTER_IGNORE_RESTORE"] = "恢復預設忽略列表"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] = "這將使用您的資料片的預設物品取代您的隊長分配忽略列表。是否繼續？"
L["MASTER_LOOTER_IGNORE_ADD_DESCRIPTION"] = "輸入物品 ID 或貼上物品連結以將其新增至忽略列表。"
L["MASTER_LOOTER_IGNORE_ADD"] = "新增物品"
L["MASTER_LOOTER_IGNORE_REMOVE"] = "移除"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "從忽略列表中移除此物品。"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] = "對不高於所選品質的非拾取綁定物品（BoE）自動擲貪婪。任務物品、書籍、配方、坐騎、寵物和傳說物品總是被略過。拾取綁定物品（BoP）永遠不會根據門檻自動擲貪婪，但可以透過下方的自訂擲骰列表進行自動化設定。自訂擲骰列表中的物品將遵循其需求、貪婪或放棄操作，而不是門檻。自動擲骰關閉時，將不會進行任何自動擲骰 — 包括自訂擲骰列表。"
L["ROLLS_ENABLE"] = "啟用自動擲骰"
L["ROLLS_THRESHOLD"] = "自動貪婪門檻"

L["ROLLS_CUSTOM_LIST"] = "自訂擲骰列表"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "此列表中的物品具有覆寫門檻的獨立擲骰規則。這是使天譴石或惡魔符文等拾取綁定物品自動化的唯一方法。將每個物品設定為手動擲骰、貪婪、需求或放棄。此列表僅在自動擲骰啟用時生效。任務物品、書籍、配方、坐騎、寵物和傳說物品無論設定為何總是會被略過。"
L["ROLLS_CUSTOM_LIST_ENABLE"] = "啟用自訂擲骰列表"
L["ROLLS_RESTORE_DEFAULTS"] = "恢復預設自訂擲骰列表"
L["ROLLS_RESTORE_CONFIRM"] = "這將使用您的資料片的預設物品取代您的自訂擲骰列表。是否繼續？"
L["ROLLS_ADD_ITEM_DESCRIPTION"] = "輸入物品 ID 或將物品拖曳至此處以將其新增至列表。"
L["ROLLS_ADD_ITEM"] = "新增物品"
L["ROLLS_CHOOSE_ACTION"] = "Choose the automatic roll action for this item."
L["ROLLS_REMOVE"] = "移除"
L["ROLLS_REMOVE_DESCRIPTION"] = "從自訂擲骰列表中移除此物品。"

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "交易通報"
L["TRADE_DESCRIPTION"] = "自動向聊天頻道發送已完成的交易摘要，包括交易的物品、附魔和金幣。"
L["TRADE_ENABLE"] = "啟用交易通報"
L["TRADE_CONDITION"] = "時間"
L["TRADE_CONDITION_ALWAYS"] = "始終"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "僅在小隊或團隊中"
L["TRADE_CONDITION_RAID_ONLY"] = "僅在團隊中"
L["TRADE_OUTPUT"] = "訊息輸出"
L["TRADE_OUTPUT_WHISPER"] = "密語"
L["TRADE_OUTPUT_GROUP"] = "小隊聊天"
L["TRADE_EXAMPLE"] = "範例：{rt4} 將 [物品 X] x2，[物品 Y] 交給了 Fathom。// GogoLoot"
L["TRADE_TOOLTIP_DESCRIPTION"] = "此交易完成時將摘要發送到聊天頻道。"
L["TRADE_TOOLTIP_OUTPUT"] = "目前輸出"
L["TRADE_CHECKBOX_LABEL"] = "通報"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "將隊長分配活動發送到隊伍頻道以保持透明。為自動和手動分配配置不同的門檻，這樣常規的自動分配就不會洗頻，而手動的例外分配依然可見。"

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "啟用隊長分配設定提示"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] = "範例：{rt4} GogoLoot // Aevala 將接收所有的 史詩 物品。"

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "啟用自動分配通報"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "自動通報門檻"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Example: {rt4} GogoLoot // Gave [Item X] to Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] = "Note: Every item distributed manually is always announced, regardless of quality."
