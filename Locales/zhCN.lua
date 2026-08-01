local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "zhCN")
if not L then
	return
end

--[[
    Translated from enUS.lua, the source locale any missing key falls back to.
    Translate the values only. Never change the L["KEY"] names, the %s / %d
    placeholders, or the {rt4} raid marker — code and enUS.lua rely on them.
]]

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"版本 %s。设置（包括禁用此消息的选项）可以在 选项 > 插件 > GogoLoot 中找到。喜欢这个插件吗？告诉你的朋友吧！(="
L["MESSAGE_AUTO_LOOT_ENABLED"] = "自动拾取已启用。快速拾取需要它才能运作。"
L["MESSAGE_NOT_MASTER_LOOTER"] = "您当前不是队长分配者。"

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

L["MESSAGE_GAVE"] = "将 %s 交给了 %s。"
L["MESSAGE_DESTINATION_SET"] = "%s 将接收所有的 %s 物品。"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s 将为队伍保管所有战利品。"
L["MESSAGE_DESTINATION_LEFT"] = "%s 离开了队伍。%s 现在将接收所有的 %s 物品。"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "将 %s 交给了 %s，收到了 %s。"
L["MESSAGE_TRADE_RECEIVED"] = "收到了来自 %s 的 %s。"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "%s 的背包已满：%s"
L["ERROR_MAX_COUNT"] = "%s 已经拥有太多：%s"
L["ERROR_OUT_OF_RANGE"] = "%s 距离过远：%s"
L["ERROR_NOT_IN_GROUP"] = "%s 已不在队伍或团队中：%s"
L["ERROR_DISTRIBUTION_FAILED"] = "无法给予 %s：%s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "队长分配"
L["TAB_AUTOMATED_ROLLS"] = "自动掷骰"
L["TAB_ANNOUNCEMENTS"] = "通报"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- GogoLoot is a proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "已启用"
L["STATUS_DISABLED"] = "已禁用"

--[[
    The tooltip titles each feature with its options-panel name rather than
    keeping its own copy: Automated Rolls uses TAB_AUTOMATED_ROLLS, Speedy Loot
    uses SPEEDY_LOOT_HEADER and SPEEDY_LOOT_DESCRIPTION. Only the roll
    description below is unique to the tooltip, where the panel's longer text
    would not fit.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "替你对不高于所选品质的符合条件物品自动掷骰。"

L["MINIMAP_LEFT_CLICK"] = "左键单击"
L["MINIMAP_RIGHT_CLICK"] = "右键单击"
L["MINIMAP_TOGGLE"] = "切换"
L["MINIMAP_OPTIONS"] = "GogoLoot 选项"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 中键点击"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- Quality Labels
L["QUALITY_POOR"] = "粗糙"
L["QUALITY_COMMON"] = "普通"
L["QUALITY_UNCOMMON"] = "优秀"
L["QUALITY_RARE"] = "精良"
L["QUALITY_EPIC"] = "史诗"

-- Roll Action Labels
L["ROLL_MANUAL"] = "手动"
L["ROLL_GREED"] = "贪婪"
L["ROLL_NEED"] = "需求"
L["ROLL_PASS"] = "放弃"

-- Loot Method Labels
L["LOOT_METHOD_FREE_FOR_ALL"] = "自由拾取"
L["LOOT_METHOD_ROUND_ROBIN"] = "轮流拾取"
L["LOOT_METHOD_MASTER"] = "队长分配"
L["LOOT_METHOD_GROUP"] = "队伍分配"
L["LOOT_METHOD_NEED_BEFORE_GREED"] = "需求优先"

-- Threshold Labels
L["THRESHOLD_POOR_ONLY"] = "仅限粗糙"
L["THRESHOLD_COMMON_LOWER"] = "普通及以下"
L["THRESHOLD_UNCOMMON_LOWER"] = "优秀及以下"
L["THRESHOLD_RARE_LOWER"] = "精良及以下"
L["THRESHOLD_EPIC_LOWER"] = "史诗及以下"

-- Shared by both item lists: the Master Looter ignore list and the Custom Roll List
L["ITEM_LIST_ADD"] = "添加物品"
L["ITEM_LIST_ADD_DESCRIPTION"] = "输入物品 ID 或将物品拖到此处以将其添加到列表。"

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "加载中... (ID: %d)"

-- Version prefix in the options panel and minimap tooltip
L["VERSION_LABEL"] = "版本"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] =
	"通过自动队长分配、自动掷骰和透明的通报收集装备。任务物品、配方、坐骑、宠物和传说物品始终安全。别让拾取拖慢你的 zug！"
L["WELCOME_MESSAGE"] = "启用欢迎消息"
L["MINIMAP_BUTTON_ENABLE"] = "启用小地图按钮"

L["COMMANDS"] = "/命令"
L["COMMANDS_DESCRIPTION"] = "打开 GogoLoot 选项界面。"

L["SPEEDY_LOOT_HEADER"] = "快速拾取"
L["SPEEDY_LOOT_DESCRIPTION"] = "隐藏拾取窗口，实现近乎瞬间的拾取。"
L["SPEEDY_LOOT_ENABLE"] = "启用快速拾取"

L["FEEDBACK_SUPPORT"] = "反馈和支持"

-- CurseForge / GitHub / Discord / Wago are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"] = "你队伍当前的拾取方式和品质门限。"
L["MASTER_LOOTER_LOOT_METHOD"] = "拾取方式"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "拾取品质门槛"
L["MASTER_LOOTER_SET_BY"] = "(由 %s 设置)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "只有队长可以更改拾取方式和品质门限。"

L["MASTER_LOOTER_AUTO_HEADER"] = "自动队长分配"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] =
	"当您是队长分配者时，将战利品分配给您指定的玩家。任务物品、配方、书籍、坐骑、宠物和传说物品总是被跳过。"
L["MASTER_LOOTER_AUTO_ENABLE"] = "在副本中启用自动队长分配"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "在副本外启用自动队长分配"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] = "警告：由于世界首领掉落无法交易，不建议使用此功能！"

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // 快速设置"
L["MASTER_LOOTER_POPUP_DESCRIPTION"] = "每当你成为战利品分配者时，打开一个设置战利品的窗口。"
L["MASTER_LOOTER_POPUP_ENABLE"] = "启用分配者窗口"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "战利品目标"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "指定小队成员接收每个品质级别的物品。"
L["MASTER_LOOTER_DESTINATION_SELF"] = "自己"
L["MASTER_LOOTER_SEND_ALL"] = "全部战利品发送给"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] =
	"将所有品质发送给同一名玩家。可在下方单独设置各品质以覆盖。"
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "选择谁接收 %s 物品。"

L["MASTER_LOOTER_IGNORE_HEADER"] = "忽略列表"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] = "列表中的物品跳过自动分配，留待手动分配。"
L["MASTER_LOOTER_IGNORE_RESTORE"] = "恢复默认忽略列表"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"这将使用您的资料片的默认物品替换您的队长分配忽略列表。是否继续？"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "从忽略列表中移除此物品。"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] =
	"在小队和团队中，都会替你对不高于所选品质的非拾取绑定物品自动掷骰。任务物品、配方、书籍、坐骑、宠物和传说物品总是被跳过。"
L["ROLLS_ENABLE"] = "启用自动掷骰"
L["ROLLS_THRESHOLD_HEADER"] = "阈值"
L["ROLLS_THRESHOLD_DESCRIPTION"] =
	"分别为小队和团队设置品质上限，以及 GogoLoot 替你投出的骰子。"
L["ROLLS_IN_PARTY"] = "在小队中"
L["ROLLS_IN_RAID"] = "在团队中"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s：自动对该品质及以下的物品掷骰。"
L["ROLLS_ACTION_CHOOSE"] = "%s：GogoLoot 替你投出的骰子，或是否交由你自己掷骰。"

L["ROLLS_CUSTOM_LIST"] = "自定义掷骰列表"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "为特定物品指定各自的掷骰操作，覆盖阈值。"
L["ROLLS_CUSTOM_LIST_ENABLE"] = "启用自定义掷骰列表"
L["ROLLS_RESTORE_DEFAULTS"] = "恢复默认自定义掷骰列表"
L["ROLLS_RESTORE_CONFIRM"] =
	"这将使用您的资料片的默认物品替换您的自定义掷骰列表。是否继续？"
L["ROLLS_CHOOSE_ACTION"] = "为该物品选择自动掷骰操作。"
L["ROLLS_REMOVE_DESCRIPTION"] = "从自定义掷骰列表中移除此物品。"

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "交易通报"
L["TRADE_DESCRIPTION"] = "发布每笔完成交易的摘要：物品、附魔和金币。"
L["TRADE_ENABLE"] = "启用交易通报"
L["TRADE_CONDITION"] = "时间"
L["TRADE_CONDITION_ALWAYS"] = "始终"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "仅在小队或团队中"
L["TRADE_CONDITION_RAID_ONLY"] = "仅在团队中"
L["TRADE_OUTPUT"] = "消息输出"
L["TRADE_OUTPUT_WHISPER"] = "密语"
L["TRADE_OUTPUT_GROUP"] = "小队聊天"
L["TRADE_EXAMPLE"] = "示例：{rt4} GogoLoot // 将 [物品 X] x2，[物品 Y] 交给了 Fathom。"
L["TRADE_TOOLTIP_DESCRIPTION"] = "此交易完成时将摘要发送到聊天频道。"
L["TRADE_TOOLTIP_OUTPUT"] = "当前输出"
L["TRADE_CHECKBOX_LABEL"] = "通报"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] =
	"将队长分配活动发送到队伍频道。自动分配使用品质阈值以避免刷屏；手动分配始终会通报。"

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "启用战利品归属消息"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] =
	"示例：{rt4} GogoLoot // Aevala 将接收所有的 史诗 物品。"

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "启用自动分配通报"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "自动通报阈值"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "示例：{rt4} GogoLoot // 将 [物品 X] 给了 Fathom。"

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] = "注意：手动分配的每件物品都会通报，无论品质如何。"
