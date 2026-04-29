local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "zhCN")
if not L then return end

--------------------------------------------------------------------------------
-- Chat Messages (printed to local chat frame via PrintMessage)
--------------------------------------------------------------------------------

L["MSG_SETTINGS_RESET_UPDATE"] = "此更新已重置设置。使用 /gl 检查您的选项。"
L["MSG_SETTINGS_RESET_DEFAULTS"] = "所有设置均已重置为默认值。"
L["MSG_AUTO_LOOT_ENABLED"] = "GogoLoot 正常工作需要开启自动拾取。自动拾取已启用。"
L["MSG_NOT_MASTER_LOOTER"] = "您当前不是队长分配者。"

--------------------------------------------------------------------------------
-- Chat Announcement Templates (sent to other players via GogoLoot:Announce)
--------------------------------------------------------------------------------

L["MSG_PREFIX"] = "{rt4} "
L["MSG_SUFFIX"] = " // GogoLoot"

L["MSG_LOOT_ANNOUNCE"] = "将 %s 交给了 %s。"
L["MSG_DESTINATION_SET"] = "%s 将接收所有的 %s 物品。"
L["MSG_DESTINATION_LEFT"] = "%s 离开了队伍。%s 现在将接收所有的 %s 物品。"

L["MSG_TRADE_GAVE_RECEIVED"] = "将 %s 交给了 %s，收到了 %s。"
L["MSG_TRADE_GAVE"] = "将 %s 交给了 %s。"
L["MSG_TRADE_RECEIVED"] = "收到了来自 %s 的 %s。"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors (sent to group via GogoLoot:Announce)
--------------------------------------------------------------------------------

L["ERR_BAG_FULL"] = "您选择接收该物品的玩家背包已满。"
L["ERR_MAX_COUNT"] = "您选择接收该物品的玩家已经拥有太多该物品。"
L["ERR_OUT_OF_RANGE"] = "您选择接收该物品的玩家距离过远。"
L["ERR_NOT_IN_GROUP"] = "您选择接收该物品的玩家不再处于队伍或团队中。"

--------------------------------------------------------------------------------
-- Options Panel Tab Names
--------------------------------------------------------------------------------

L["TAB_GENERAL"] = "GogoLoot"
L["TAB_AUTOMATED_ROLLS"] = "自动掷骰"
L["TAB_MASTER_LOOTER"] = "队长分配"
L["TAB_TRADE_ANNOUNCEMENTS"] = "通报"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "已启用"
L["STATUS_DISABLED"] = "已停用"

L["MINIMAP_AUTO_GREED"] = "自动贪婪"
L["MINIMAP_AUTO_GREED_DESC"] = "对等于或低于所选品质阈值的符合条件的物品自动掷贪婪。"
L["MINIMAP_SPEEDY_LOOT"] = "快速拾取"
L["MINIMAP_SPEEDY_LOOT_DESC"] = "立即拾取战利品而不显示拾取窗口。"

L["MINIMAP_LEFT_CLICK"] = "左键单击"
L["MINIMAP_RIGHT_CLICK"] = "右键单击"
L["MINIMAP_TOGGLE"] = "切换"
L["MINIMAP_HINT"] = "其他设置可在 选项 > 插件 > GogoLoot 中找到。"

--------------------------------------------------------------------------------
-- Quality Labels
--------------------------------------------------------------------------------

L["QUALITY_POOR"] = "粗糙"
L["QUALITY_COMMON"] = "普通"
L["QUALITY_UNCOMMON"] = "优秀"
L["QUALITY_RARE"] = "精良"
L["QUALITY_EPIC"] = "史诗"

--------------------------------------------------------------------------------
-- Roll Action Labels
--------------------------------------------------------------------------------

L["ROLL_MANUAL"] = "手动掷骰"
L["ROLL_GREED"] = "贪婪"
L["ROLL_NEED"] = "需求"
L["ROLL_PASS"] = "放弃"

--------------------------------------------------------------------------------
-- Loot Method Labels
--------------------------------------------------------------------------------

L["LOOT_METHOD_FFA"] = "自由拾取"
L["LOOT_METHOD_ROUND_ROBIN"] = "轮流拾取"
L["LOOT_METHOD_MASTER"] = "队长分配"
L["LOOT_METHOD_GROUP"] = "队伍分配"
L["LOOT_METHOD_NBG"] = "需求优先"

--------------------------------------------------------------------------------
-- Threshold Labels
--------------------------------------------------------------------------------

L["THRESHOLD_POOR_ONLY"] = "仅限粗糙"
L["THRESHOLD_COMMON_LOWER"] = "普通及以下"
L["THRESHOLD_UNCOMMON_LOWER"] = "优秀及以下"
L["THRESHOLD_RARE_LOWER"] = "精良及以下"
L["THRESHOLD_EPIC_LOWER"] = "史诗及以下"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL"] = "常规"
L["GENERAL_DESC"] = "GogoLoot 激活时适用的核心设置。"
L["SPEEDY_LOOT"] = "启用快速拾取"
L["SPEEDY_LOOT_DESC"] = "立即拾取战利品而不显示拾取窗口，节省击杀之间的时间。"

L["COMMANDS"] = "/命令"
L["COMMANDS_DESC"] = "打开 GogoLoot 选项界面。"

L["RESET"] = "重置"
L["RESET_DESC"] = "清除所有 GogoLoot 设置并将每个选项恢复为其默认值。"
L["RESET_ALL"] = "重置所有 GogoLoot 选项"
L["RESET_CONFIRM"] = "这将把所有 GogoLoot 设置重置为默认值。此操作无法撤销。是否继续？"

L["FEEDBACK_SUPPORT"] = "反馈和支持"
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

L["ITEM_LOADING"] = "加载中... (ID: %d)"

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements

L["TRADE_HEADER"] = "交易通报"
L["TRADE_DESC"] = "自动向聊天频道发送完成的交易摘要，包括交易的物品、附魔和金币。"
L["TRADE_ENABLE"] = "启用交易通报"
L["TRADE_ENABLE_DESC"] = "交易完成时发送交易摘要。"
L["TRADE_CONDITION"] = "在队伍中时"
L["TRADE_CONDITION_DESC"] = "控制交易通报激活的时间。"
L["TRADE_CONDITION_ALWAYS"] = "始终"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "仅在小队或团队中"
L["TRADE_CONDITION_RAID_ONLY"] = "仅在团队中"
L["TRADE_OUTPUT"] = "消息输出"
L["TRADE_OUTPUT_DESC"] = "交易摘要发送到的位置。"
L["TRADE_OUTPUT_WHISPER"] = "密语"
L["TRADE_OUTPUT_GROUP"] = "小队聊天"
L["TRADE_OUTPUT_RAID"] = "团队聊天"
L["TRADE_EXAMPLE"] = "示例：{rt4} 将 [物品 X] x2，[物品 Y] 交给了 Fathom。// GogoLoot"

L["TRADE_TOOLTIP_TITLE"] = "交易通报"
L["TRADE_TOOLTIP_DESC"] = "此交易完成时将摘要发送到聊天频道。"
L["TRADE_TOOLTIP_OUTPUT"] = "当前输出"
L["TRADE_CHECKBOX_LABEL"] = "通报"

-- Master Looter Announcements

L["ML_ANNOUNCE_HEADER"] = "队长分配通报"
L["ML_ANNOUNCE_DESC"] = "将队长分配活动发送到队伍频道以保持透明。为自动和手动分配配置不同的阈值，这样常规的自动分配就不会刷屏，而手动的破例分配依然可见。"

L["ML_ANNOUNCE_DESTINATION"] = "启用队长分配设置提示"
L["ML_ANNOUNCE_DESTINATION_DESC"] = "在设置战利品目标或目标玩家离开队伍时进行通报。"
L["ML_ANNOUNCE_DESTINATION_EXAMPLE"] = "示例：{rt4} Aevala 将接收所有的 史诗 物品。 // GogoLoot"

L["ML_ANNOUNCE_AUTO"] = "启用自动分配通报"
L["ML_ANNOUNCE_AUTO_DESC"] = "通报由 GogoLoot 自动分配的物品。"
L["ML_ANNOUNCE_AUTO_THRESHOLD"] = "自动通报阈值"
L["ML_ANNOUNCE_AUTO_THRESHOLD_DESC"] = "仅通报不低于此品质的自动分配。"

L["ML_ANNOUNCE_MANUAL"] = "启用手动分配通报"
L["ML_ANNOUNCE_MANUAL_DESC"] = "通报通过下拉菜单手动分配的物品。默认阈值低于自动分配，以使未按规则的分配情况对队伍可见。"
L["ML_ANNOUNCE_MANUAL_THRESHOLD"] = "手动通报阈值"
L["ML_ANNOUNCE_MANUAL_THRESHOLD_DESC"] = "仅通报不低于此品质的手动分配。"

L["ML_ANNOUNCE_EXAMPLE"] = "示例：{rt4} 将 [物品 X] 交给了 Gogowarrior。// GogoLoot"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESC"] = "对不高于所选品质的非拾取绑定物品（BoE）自动掷贪婪。任务物品、书籍、配方、坐骑、宠物和传说物品总是被跳过。拾取绑定物品（BoP）永远不会根据阈值自动掷贪婪，但可以通过下方的自定义掷骰列表进行自动化设置。"
L["ROLLS_ENABLE"] = "启用自动掷骰"
L["ROLLS_ENABLE_DESC"] = "对等于或低于该阈值的符合条件的物品自动掷贪婪。"
L["ROLLS_THRESHOLD"] = "自动贪婪阈值"
L["ROLLS_THRESHOLD_DESC"] = "不高于此品质的物品将被自动掷贪婪。"

L["ROLLS_CUSTOM_LIST"] = "自定义掷骰列表"
L["ROLLS_CUSTOM_LIST_DESC"] = "此列表中的物品具有覆盖阈值的独立掷骰规则。这是使天灾石或恶魔符文等拾取绑定物品自动化的唯一方法。将每个物品设置为手动掷骰、贪婪、需求或放弃。任务物品、书籍、配方、坐骑、宠物和传说物品无论设置如何总是会被跳过。"
L["ROLLS_RESTORE_DEFAULTS"] = "恢复默认自定义掷骰列表"
L["ROLLS_RESTORE_CONFIRM"] = "这将使用您的资料片的默认物品替换您的自定义掷骰列表。是否继续？"
L["ROLLS_ADD_ITEM_DESC"] = "输入物品 ID 或将物品拖到此处以将其添加到列表。"
L["ROLLS_ADD_ITEM"] = "添加物品"
L["ROLLS_ADD_ITEM_TOOLTIP"] = "在此处输入物品 ID 或拖放物品链接。"
L["ROLLS_CHOOSE_ACTION"] = "选择此物品的自动掷骰动作。"
L["ROLLS_REMOVE"] = "移除"
L["ROLLS_REMOVE_DESC"] = "从自定义掷骰列表中移除此物品。"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["ML_LOOT_TYPE"] = "拾取方式（只读，通过游戏菜单更改）"
L["ML_LOOT_THRESHOLD"] = "分配品质（只读，通过游戏菜单更改）"

L["ML_AUTO_HEADER"] = "自动队长分配"
L["ML_AUTO_DESC"] = "当您是队长分配者时，自动将战利品分配给指定的玩家。任务物品、书籍、配方、坐骑、宠物和传说物品总是被跳过，并出现在标准的拾取窗口中。"
L["ML_AUTO_ENABLE"] = "在副本中启用自动队长分配"
L["ML_AUTO_ENABLE_DESC"] = "将战利品自动分配给配置的目标。"
L["ML_AUTO_OUTSIDE"] = "在副本外启用自动队长分配"
L["ML_AUTO_OUTSIDE_CAUTION"] = "警告：由于世界首领掉落无法交易，不建议使用此功能！"

L["ML_DEST_HEADER"] = "战利品目标"
L["ML_DEST_DESC"] = "指定小队成员接收每个品质级别的物品。"
L["ML_DEST_SELF"] = "自己"
L["ML_DEST_CHOOSE"] = "选择谁接收 %s 物品。"

L["ML_IGNORE_HEADER"] = "忽略列表"
L["ML_IGNORE_DESC"] = "此列表中的物品将不会自动分配，并出现在标准的拾取窗口中以供手动分配。"
L["ML_IGNORE_RESTORE"] = "恢复默认忽略列表"
L["ML_IGNORE_RESTORE_CONFIRM"] = "这将使用您的资料片的默认物品替换您的队长分配忽略列表。是否继续？"
L["ML_IGNORE_ADD_DESC"] = "输入物品 ID 或粘贴物品链接以将其添加到忽略列表。"
L["ML_IGNORE_ADD"] = "添加物品"
L["ML_IGNORE_ADD_TOOLTIP"] = "输入物品 ID 或将物品拖到此处以将其添加到列表。"
L["ML_IGNORE_REMOVE"] = "移除"
L["ML_IGNORE_REMOVE_DESC"] = "从忽略列表中移除此物品。"