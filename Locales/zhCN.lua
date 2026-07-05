local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "zhCN")
if not L then return end

--[[
    Source locale: every other locale falls back to these strings. Translate
    the values only. Never change the L["KEY"] names, the %s / %d placeholders,
    or the {rt4} raid marker — code and other locales rely on them.
]]

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "版本 %s。设置（包括禁用此消息的选项）可以在 选项 > 插件 > GogoLoot 中找到。喜欢这个插件吗？告诉你的朋友吧！(="
L["MESSAGE_AUTO_LOOT_ENABLED"] = "GogoLoot 正常工作需要开启自动拾取。自动拾取已启用。"
L["MESSAGE_NOT_MASTER_LOOTER"] = "您当前不是队长分配者。"

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

L["MESSAGE_LOOT_ANNOUNCE"] = "将 %s 交给了 %s。"
L["MESSAGE_DESTINATION_SET"] = "%s 将接收所有的 %s 物品。"
L["MESSAGE_DESTINATION_LEFT"] = "%s 离开了队伍。%s 现在将接收所有的 %s 物品。"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "将 %s 交给了 %s，收到了 %s。"
L["MESSAGE_TRADE_GAVE"] = "将 %s 交给了 %s。"
L["MESSAGE_TRADE_RECEIVED"] = "收到了来自 %s 的 %s。"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "您选择接收该物品的玩家背包已满。"
L["ERROR_MAX_COUNT"] = "您选择接收该物品的玩家已经拥有太多该物品。"
L["ERROR_OUT_OF_RANGE"] = "您选择接收该物品的玩家距离过远。"
L["ERROR_NOT_IN_GROUP"] = "您选择接收该物品的玩家不再处于队伍或团队中。"

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
L["STATUS_ENABLED"] = "Enabled"
L["STATUS_DISABLED"] = "Disabled"

L["MINIMAP_AUTO_GREED"] = "自动贪婪"
L["MINIMAP_AUTO_GREED_DESCRIPTION"] = "对等于或低于所选品质阈值的符合条件的物品自动掷贪婪。关闭此选项后，不会进行任何自动掷骰 — 包括自定义掷骰列表。"
L["MINIMAP_SPEEDY_LOOT"] = "快速拾取"
L["MINIMAP_SPEEDY_LOOT_DESCRIPTION"] = "立即拾取战利品而不显示拾取窗口。"

L["MINIMAP_LEFT_CLICK"] = "左键单击"
L["MINIMAP_RIGHT_CLICK"] = "右键单击"
L["MINIMAP_TOGGLE"] = "切换"
L["MINIMAP_OPTIONS"] = "GogoLoot Options"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Middle-Click"

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
L["ROLL_MANUAL"] = "手动掷骰"
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

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "加载中... (ID: %d)"

-- Version prefix in the options panel and minimap tooltip
L["VERSION_LABEL"] = "版本"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] = "通过自动队长分配吸取装备，对非拾取绑定掉落物自动掷需求或贪婪，并在聊天中透明地通报每笔交易。任务物品、配方、坐骑、宠物和传说物品始终安全。别让拾取拖慢你的脚步——Zug zug！"
L["WELCOME_MESSAGE"] = "启用欢迎消息"
L["MINIMAP_BUTTON_ENABLE"] = "Enable Minimap Button"

L["COMMANDS"] = "/命令"
L["COMMANDS_DESCRIPTION"] = "打开 GogoLoot 选项界面。"

L["SPEEDY_LOOT_HEADER"] = "快速拾取"
L["SPEEDY_LOOT_DESCRIPTION"] = "立即拾取战利品而不显示拾取窗口，节省击杀之间的时间。"
L["SPEEDY_LOOT_ENABLE"] = "启用快速拾取"

L["FEEDBACK_SUPPORT"] = "反馈和支持"

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
L["MASTER_LOOTER_LOOT_TYPE"] = "拾取方式（只读，通过游戏菜单更改）"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "分配品质（只读，通过游戏菜单更改）"
L["MASTER_LOOTER_SET_BY"] = "(Set by %s)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "Only the group leader can change the loot method and threshold."

L["MASTER_LOOTER_AUTO_HEADER"] = "自动队长分配"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] = "当您是队长分配者时，自动将战利品分配给指定的玩家。任务物品、书籍、配方、坐骑、宠物和传说物品总是被跳过，并出现在标准的拾取窗口中。"
L["MASTER_LOOTER_AUTO_ENABLE"] = "在副本中启用自动队长分配"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "在副本外启用自动队长分配"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] = "警告：由于世界首领掉落无法交易，不建议使用此功能！"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "战利品目标"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "指定小队成员接收每个品质级别的物品。"
L["MASTER_LOOTER_DESTINATION_SELF"] = "自己"
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "选择谁接收 %s 物品。"

L["MASTER_LOOTER_IGNORE_HEADER"] = "忽略列表"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] = "此列表中的物品将不会自动分配，并出现在标准的拾取窗口中以供手动分配。"
L["MASTER_LOOTER_IGNORE_RESTORE"] = "恢复默认忽略列表"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] = "这将使用您的资料片的默认物品替换您的队长分配忽略列表。是否继续？"
L["MASTER_LOOTER_IGNORE_ADD_DESCRIPTION"] = "输入物品 ID 或粘贴物品链接以将其添加到忽略列表。"
L["MASTER_LOOTER_IGNORE_ADD"] = "添加物品"
L["MASTER_LOOTER_IGNORE_REMOVE"] = "移除"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "从忽略列表中移除此物品。"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] = "对不高于所选品质的非拾取绑定物品（BoE）自动掷贪婪。任务物品、书籍、配方、坐骑、宠物和传说物品总是被跳过。拾取绑定物品（BoP）永远不会根据阈值自动掷贪婪，但可以通过下方的自定义掷骰列表进行自动化设置。自定义掷骰列表中的物品将遵循其需求、贪婪或放弃操作，而不是阈值。自动掷骰关闭时，不会进行任何自动掷骰 — 包括自定义掷骰列表。"
L["ROLLS_ENABLE"] = "启用自动掷骰"
L["ROLLS_THRESHOLD"] = "自动贪婪阈值"

L["ROLLS_CUSTOM_LIST"] = "自定义掷骰列表"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "此列表中的物品具有覆盖阈值的独立掷骰规则。这是使天灾石或恶魔符文等拾取绑定物品自动化的唯一方法。将每个物品设置为手动掷骰、贪婪、需求或放弃。此列表仅在自动掷骰启用时生效。任务物品、书籍、配方、坐骑、宠物和传说物品无论设置如何总是会被跳过。"
L["ROLLS_CUSTOM_LIST_ENABLE"] = "启用自定义掷骰列表"
L["ROLLS_RESTORE_DEFAULTS"] = "恢复默认自定义掷骰列表"
L["ROLLS_RESTORE_CONFIRM"] = "这将使用您的资料片的默认物品替换您的自定义掷骰列表。是否继续？"
L["ROLLS_ADD_ITEM_DESCRIPTION"] = "输入物品 ID 或将物品拖到此处以将其添加到列表。"
L["ROLLS_ADD_ITEM"] = "添加物品"
L["ROLLS_CHOOSE_ACTION"] = "Choose the automatic roll action for this item."
L["ROLLS_REMOVE"] = "移除"
L["ROLLS_REMOVE_DESCRIPTION"] = "从自定义掷骰列表中移除此物品。"

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "交易通报"
L["TRADE_DESCRIPTION"] = "自动向聊天频道发送完成的交易摘要，包括交易的物品、附魔和金币。"
L["TRADE_ENABLE"] = "启用交易通报"
L["TRADE_CONDITION"] = "时间"
L["TRADE_CONDITION_ALWAYS"] = "始终"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "仅在小队或团队中"
L["TRADE_CONDITION_RAID_ONLY"] = "仅在团队中"
L["TRADE_OUTPUT"] = "消息输出"
L["TRADE_OUTPUT_WHISPER"] = "密语"
L["TRADE_OUTPUT_GROUP"] = "小队聊天"
L["TRADE_EXAMPLE"] = "示例：{rt4} 将 [物品 X] x2，[物品 Y] 交给了 Fathom。// GogoLoot"
L["TRADE_TOOLTIP_DESCRIPTION"] = "此交易完成时将摘要发送到聊天频道。"
L["TRADE_TOOLTIP_OUTPUT"] = "当前输出"
L["TRADE_CHECKBOX_LABEL"] = "通报"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "将队长分配活动发送到队伍频道以保持透明。为自动和手动分配配置不同的阈值，这样常规的自动分配就不会刷屏，而手动的破例分配依然可见。"

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "启用队长分配设置提示"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] = "示例：{rt4} GogoLoot // Aevala 将接收所有的 史诗 物品。"

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "启用自动分配通报"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "自动通报阈值"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Example: {rt4} GogoLoot // Gave [Item X] to Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] = "Note: Every item distributed manually is always announced, regardless of quality."
