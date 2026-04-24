local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "zhTW")
if not L then return end

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["MSG_SETTINGS_RESET_UPDATE"] = "此更新已重設設定。使用 /gl 檢查您的選項。"
L["MSG_SETTINGS_RESET_DEFAULTS"] = "所有設定均已重設為預設值。"
L["MSG_CONFLICT_DETECTED"] = "偵測到衝突的拾取插件。"
L["MSG_CONFLICT_ADDON"] = "衝突的插件：%s"
L["MSG_AUTO_LOOT_ENABLED"] = "GogoLoot 正常運作需要開啟自動拾取。自動拾取已啟用。"
L["MSG_NOT_MASTER_LOOTER"] = "您目前不是隊長分配者。"

--------------------------------------------------------------------------------
-- Quality Labels
--------------------------------------------------------------------------------

L["QUALITY_POOR"] = "粗糙"
L["QUALITY_COMMON"] = "普通"
L["QUALITY_UNCOMMON"] = "優秀"
L["QUALITY_RARE"] = "精良"
L["QUALITY_EPIC"] = "史詩"

--------------------------------------------------------------------------------
-- Roll Action Labels
--------------------------------------------------------------------------------

L["ROLL_MANUAL"] = "手動擲骰"
L["ROLL_GREED"] = "貪婪"
L["ROLL_NEED"] = "需求"
L["ROLL_PASS"] = "放棄"

--------------------------------------------------------------------------------
-- Loot Method Labels
--------------------------------------------------------------------------------

L["LOOT_METHOD_FFA"] = "自由拾取"
L["LOOT_METHOD_ROUND_ROBIN"] = "輪流拾取"
L["LOOT_METHOD_MASTER"] = "隊長分配"
L["LOOT_METHOD_GROUP"] = "隊伍分配"
L["LOOT_METHOD_NBG"] = "需求優先"

--------------------------------------------------------------------------------
-- Threshold Labels
--------------------------------------------------------------------------------

L["THRESHOLD_POOR_ONLY"] = "僅限粗糙"
L["THRESHOLD_COMMON_LOWER"] = "普通及以下"
L["THRESHOLD_UNCOMMON_LOWER"] = "優秀及以下"
L["THRESHOLD_RARE_LOWER"] = "精良及以下"
L["THRESHOLD_EPIC_LOWER"] = "史詩及以下"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL"] = "一般"
L["GENERAL_DESC"] = "GogoLoot 啟用時適用的核心設定。"
L["SPEEDY_LOOT"] = "啟用快速拾取"
L["SPEEDY_LOOT_DESC"] = "立即拾取戰利品而不顯示拾取視窗，節省擊殺之間的時間。"

L["COMMANDS"] = "/指令"
L["COMMANDS_DESC_GL"] = "開啟 GogoLoot 選項介面。"
L["COMMANDS_DESC_GOGOLOOT"] = "開啟 GogoLoot 選項介面。"

L["RESET"] = "重設"
L["RESET_DESC"] = "清除所有 GogoLoot 設定並將每個選項恢復為其預設值。"
L["RESET_ALL"] = "重設所有 GogoLoot 選項"
L["RESET_CONFIRM"] = "這將把所有 GogoLoot 設定重設為預設值。此操作無法復原。是否繼續？"

L["FEEDBACK_SUPPORT"] = "回饋與支援"
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

L["ITEM_LOADING"] = "載入中... (ID: %d)"

--------------------------------------------------------------------------------
-- Options: Trade Announcements
--------------------------------------------------------------------------------

L["TRADE_DESC"] = "自動向聊天頻道發送已完成的交易摘要，包括交易的物品、附魔和金幣。"
L["TRADE_ENABLE"] = "啟用交易通報"
L["TRADE_ENABLE_DESC"] = "交易完成時發送交易摘要。"
L["TRADE_CONDITION"] = "在隊伍中時"
L["TRADE_CONDITION_DESC"] = "控制交易通報啟用的時間。"
L["TRADE_CONDITION_ALWAYS"] = "始終"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "僅在小隊或團隊中"
L["TRADE_CONDITION_RAID_ONLY"] = "僅在團隊中"
L["TRADE_OUTPUT"] = "訊息輸出"
L["TRADE_OUTPUT_DESC"] = "交易摘要發送到的位置。"
L["TRADE_OUTPUT_WHISPER"] = "密語"
L["TRADE_OUTPUT_GROUP"] = "小隊聊天"
L["TRADE_OUTPUT_RAID"] = "團隊聊天"
L["TRADE_EXAMPLE"] = "範例：{rt4} 將 [物品 X] x2，[物品 Y] 交給了 Fathom。// GogoLoot"

L["TRADE_TOOLTIP_TITLE"] = "交易通報"
L["TRADE_TOOLTIP_DESC"] = "此交易完成時將摘要發送到聊天頻道。"
L["TRADE_TOOLTIP_OUTPUT"] = "目前輸出"
L["TRADE_CHECKBOX_LABEL"] = "通報"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESC"] = "對不高於所選品質的非拾取綁定物品自動擲貪婪。任務物品、書籍、配方、坐騎、寵物和傳說物品總是被略過。拾取綁定物品永遠不會根據門檻自動擲貪婪，但可以透過下方的自訂擲骰列表進行自動化設定。"
L["ROLLS_ENABLE"] = "啟用自動擲骰"
L["ROLLS_ENABLE_DESC"] = "對等於或低於該門檻的符合條件物品自動擲貪婪。"
L["ROLLS_THRESHOLD"] = "自動貪婪門檻"
L["ROLLS_THRESHOLD_DESC"] = "不高於此品質的物品將被自動擲貪婪。"

L["ROLLS_CUSTOM_LIST"] = "自訂擲骰列表"
L["ROLLS_CUSTOM_LIST_DESC"] = "此列表中的物品具有覆寫門檻的獨立擲骰規則。這是使天譴石或惡魔符文等拾取綁定物品自動化的唯一方法。將每個物品設定為手動擲骰、貪婪、需求或放棄。任務物品、書籍、配方、坐騎、寵物和傳說物品無論設定為何總是會被略過。"
L["ROLLS_RESTORE_DEFAULTS"] = "恢復預設自訂擲骰列表"
L["ROLLS_RESTORE_CONFIRM"] = "這將使用您的資料片的預設物品取代您的自訂擲骰列表。是否繼續？"
L["ROLLS_ADD_ITEM_DESC"] = "輸入物品 ID 或貼上物品連結以將其新增至列表。"
L["ROLLS_ADD_ITEM"] = "新增物品"
L["ROLLS_ADD_ITEM_TOOLTIP"] = "在此處輸入物品 ID 或拖放物品連結。"
L["ROLLS_CHOOSE_ACTION"] = "選擇此物品的自動擲骰動作。"
L["ROLLS_REMOVE"] = "移除"
L["ROLLS_REMOVE_DESC"] = "從自訂擲骰列表中移除此物品。"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["ML_LOOT_TYPE"] = "拾取方式（唯讀，透過遊戲選單更改）"
L["ML_LOOT_THRESHOLD"] = "分配品質（唯讀，透過遊戲選單更改）"

L["ML_AUTO_HEADER"] = "自動隊長分配"
L["ML_AUTO_DESC"] = "當您是隊長分配者時，自動將戰利品分配給指定的玩家。任務物品、書籍、配方、坐騎、寵物和傳說物品總是被略過，並出現在標準的拾取視窗中。"
L["ML_AUTO_ENABLE"] = "在副本中啟用自動隊長分配"
L["ML_AUTO_ENABLE_DESC"] = "將戰利品自動分配給設定的目標。"
L["ML_AUTO_OUTSIDE"] = "在副本外啟用自動隊長分配"
L["ML_AUTO_OUTSIDE_CAUTION"] = "警告：由於世界首領掉落無法交易，不建議使用此功能！"

L["ML_DEST_HEADER"] = "戰利品目標"
L["ML_DEST_DESC"] = "指定小隊成員接收每個品質級別的物品。"
L["ML_DEST_SELF"] = "自己"
L["ML_DEST_CHOOSE"] = "選擇誰接收 %s 物品。"

L["ML_ANNOUNCE_HEADER"] = "戰利品通報"
L["ML_ANNOUNCE_DESC"] = "透過隊長分配分發物品時，向隊伍聊天頻道發送訊息。無論門檻為何，總是會通報手動分配。"
L["ML_ANNOUNCE_ENABLE"] = "啟用戰利品通報"
L["ML_ANNOUNCE_ENABLE_DESC"] = "在隊伍聊天頻道通報物品分配情況。"
L["ML_ANNOUNCE_THRESHOLD"] = "通報門檻"
L["ML_ANNOUNCE_THRESHOLD_DESC"] = "僅通報不低於此品質的物品。"
L["ML_ANNOUNCE_EXAMPLE"] = "範例：{rt4} 將 [物品 X] 交給了 Gogowarrior。// GogoLoot"

L["ML_IGNORE_HEADER"] = "忽略列表"
L["ML_IGNORE_DESC"] = "此列表中的物品將不會自動分配，並出現在標準的拾取視窗中以供手動分配。"
L["ML_IGNORE_RESTORE"] = "恢復預設忽略列表"
L["ML_IGNORE_RESTORE_CONFIRM"] = "這將使用您的資料片的預設物品取代您的隊長分配忽略列表。是否繼續？"
L["ML_IGNORE_ADD_DESC"] = "輸入物品 ID 或貼上物品連結以將其新增至忽略列表。"
L["ML_IGNORE_ADD"] = "新增物品"
L["ML_IGNORE_ADD_TOOLTIP"] = "在此處輸入物品 ID 或拖放物品連結。"
L["ML_IGNORE_REMOVE"] = "移除"
L["ML_IGNORE_REMOVE_DESC"] = "從忽略列表中移除此物品。"