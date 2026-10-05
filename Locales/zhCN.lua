local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "zhCN")
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
	"版本%s。设置（包括关闭此消息的选项）位于 选项 > 插件 > GogoLoot。喜欢这个插件吗？推荐给你的朋友吧！(="
L["CHAT_OPTIONS_IN_COMBAT"] = "出于安全考虑，战斗中无法打开选项界面。"
-- Argument: the game's own name for its Auto Loot setting.
L["MESSAGE_AUTO_LOOT_SETTING_ON"] = "已开启游戏的%s设置，快速拾取和自动开启都需要用到它。"
-- Argument: the game's own word for Master Looter.
L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"] = "你当前不是%s。"

-- Automated Opening. Argument: the number of free bag slots opening waits for.
L["MESSAGE_OPENING_PAUSED"] = "自动开启已暂停，直到你至少有%d个空闲背包格。"
L["MESSAGE_OPENING_RESUMED"] = "自动开启已恢复。"

-- Argument: the item's link.
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] = "%s解锁后将自动开启。"
L["MESSAGE_ITEM_IGNORED"] = '%s被设为"忽略"，自动开启不会动它。'
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s来自团队首领或世界首领，自动开启会将其保持原封，留给你交易或出售。"
L["MESSAGE_ITEM_IGNORED_UNIQUE"] = "%s可能含有唯一物品，自动开启会留给你自己打开。"
L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] = "%s已留在拾取窗口中，供你自行拾取。"
-- The Openables List's Add Item refusing gear or a bag. Argument: the item's link, or its ID while uncached.
L["MESSAGE_ITEM_NOT_OPENABLE"] = "%s使用时会被装备而不是打开，因此无法加入可开启物品列表。"

-- Automated Rolls' Print Item in Chat. Arguments: the game's word for the roll (Need or Greed), then the item's link.
L["MESSAGE_ROLL_PRINT"] = "你选择了%s：%s。"
-- The same after a Pass. Argument: the item's link.
L["MESSAGE_ROLL_PASS_PRINT"] = "你放弃了：%s。"
--[[
    Hide Roll Messages' winner summary. Arguments: the winner, the item's link,
    then the winning roll as LOOT_TOASTS_ROLL_RESULT words it ("Greed 95"). The
    NO_ROLL forms are for a win whose roll wasn't seen; the YOU forms for the
    player's own win, without the winner.
]]
L["MESSAGE_ROLL_WON_PRINT"] = "%s赢得了%s，%s。"
L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"] = "%s赢得了%s。"
L["MESSAGE_ROLL_YOU_WON_PRINT"] = "你赢得了%s，%s。"
L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"] = "你赢得了%s。"

--[[
    A trade summary printed to the player alone (the trade Channel's Me Only):
    the Chat Announcement Templates below, printed, so each ends on its
    punctuation. Arguments as theirs: items, then the partner, then what came
    back.
]]
L["MESSAGE_GAVE_PRINT"] = "已将%s交给%s。"
L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "已将%s交给%s，收到%s。"
L["MESSAGE_TRADE_RECEIVED_PRINT"] = "收到%s，来自%s。"

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "已将%s交给%s"
L["MESSAGE_DESTINATION_SET"] = "%s将为队伍保管%s物品"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s将为队伍保管所有战利品"
-- Arguments: the player who left, the master looter, then the qualities they held, joined by commas.
L["MESSAGE_DESTINATION_LEFT"] = "%s已离开队伍。现由%s为队伍保管%s物品"
-- The same when they held every quality. Arguments: the player who left, then the master looter.
L["MESSAGE_DESTINATION_LEFT_ALL"] = "%s已离开队伍。现由%s为队伍保管所有战利品"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "已将%s交给%s，收到%s"
L["MESSAGE_TRADE_RECEIVED"] = "收到%s，来自%s"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "%s的背包已满：%s"
L["ERROR_MAX_COUNT"] = "%s持有的数量已达上限：%s"
L["ERROR_OUT_OF_RANGE"] = "%s距离太远：%s"
L["ERROR_NOT_IN_GROUP"] = "%s已不在队伍或团队中：%s"
L["ERROR_DISTRIBUTION_FAILED"] = "无法将战利品交给%s：%s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_AUTOMATED_ROLLS"] = "自动掷骰"
L["TAB_ITEM_OVERRIDES"] = "物品特例"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "角色规则"
-- The panel for everything GogoLoot posts to chat.
L["TAB_ANNOUNCEMENTS"] = "通报"
-- Headers of the two sections on the Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "交易通报"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "队长分配通报"
L["TAB_LOOT_TOASTS"] = "拾取提示"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "筛选"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "拾取音效"
L["TAB_AUTOMATED_OPENING"] = "自动开启"
-- Header of a section on the Automated Opening panel.
L["TAB_LOCKBOXES"] = "锁箱"
L["TAB_OPENABLE_ITEMS"] = "可开启物品列表"
L["TAB_MASTER_LOOTER"] = "队长分配"
-- Header of a section on the Master Looter panel.
L["TAB_LOOT_DESTINATIONS"] = "战利品去向"
L["TAB_IGNORE_LIST"] = "忽略列表"

-- A child panel's title where the Settings tree can't nest it: the parent's title, then its own.
L["TAB_NESTED_FORMAT"] = "%s: %s"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "已启用"
L["STATUS_DISABLED"] = "已禁用"
-- Automated Opening is on but waiting for empty bag slots.
L["STATUS_PAUSED"] = "已暂停"

--[[
    The tooltip titles each feature with its options-panel name (Automated
    Master Looting excepted, since its panel is titled Master Looter), and
    gives each a description of its own, two lines at most: the panels' longer
    text doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "替你对符合条件、不高于所选品质的物品自动掷骰。"
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] = "打开背包里的蚌壳、板条箱、钱袋和已开锁的锁箱。"
L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"] = "将交易摘要和队长分配结果发到聊天频道。"
L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"] = "将战利品分配给你为各品质指定的玩家。"
--[[
    The tooltip's read-back of each group context's roll, one line each under
    the description. Arguments: the game's own word for Party or Raid, the roll,
    then (all but Manual) the highest quality it rolls on.
]]
L["MINIMAP_ROLLS_SETTING"] = "%s: %s, %s"
L["MINIMAP_ROLLS_SETTING_MANUAL"] = "%s: %s"

L["MINIMAP_LEFT_CLICK"] = "左键点击"
L["MINIMAP_RIGHT_CLICK"] = "右键点击"
L["MINIMAP_SHIFT_LEFT_CLICK"] = "Shift + 左键点击"
L["MINIMAP_SHIFT_RIGHT_CLICK"] = "Shift + 右键点击"
-- The tooltip's title for the Automated Master Looting block, the feature its switch names.
L["MINIMAP_AUTOMATED_MASTER_LOOTING"] = "自动队长分配"
L["MINIMAP_TOGGLE"] = "开关"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "已锁物品"
L["MINIMAP_OPTIONS"] = "GogoLoot选项"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 中键点击"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "手动"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "仅%s"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s及以下"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List brings text of its own), the hint the box shows while empty,
    and its button.
]]
L["ITEM_LIST_ADD"] = "添加物品"
L["ITEM_LIST_ADD_DESCRIPTION"] = "输入物品ID或将物品拖到此处，即可将其添加到列表中。"
L["ITEM_LIST_ADD_PLACEHOLDER"] = "将物品拖到此处，或输入物品ID"
L["ITEM_LIST_ADD_BUTTON"] = "添加"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "筛选物品..."
L["ITEM_LIST_FILTER_DESCRIPTION"] = "只显示名称、物品ID、设置或标签中包含所输入内容的物品。"
L["ITEM_LIST_NO_MATCHES"] = "没有符合筛选条件的物品。"

-- The header over what the player just added to an item list, at its top until they filter it or close the window.
L["ITEM_LIST_NEW"] = "新添加"

-- The kind filter beside every item list's search box: its first choice (the rest are the list's headers) and its tooltip.
L["ITEM_LIST_KIND_ALL"] = "显示所有类别"
L["ITEM_LIST_KIND_DESCRIPTION"] = "显示列表中的所有物品，或只显示某一类别的物品。"

--[[
    The Add from Bags dropdown beside every item list's add box: its resting
    text and tooltip, then what it reads, greyed out, when everything carried
    is already on the list. The Openables List brings a tooltip of its own.
]]
L["ITEM_LIST_ADD_FROM_BAGS"] = "从背包添加"
L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"] = "将你携带的一件物品添加到列表中。"
L["ITEM_LIST_BAGS_EMPTY"] = "背包中没有可添加的物品"
L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"] = "你携带的所有物品都已在列表中。"

-- The button at the foot of every item list; each list's tooltip and confirmation say what it restores.
L["ITEM_LIST_RESTORE"] = "恢复默认"

-- Placeholder shown in the item lists until the client caches an item's info.
L["ITEM_LOADING"] = "加载中...（ID：%d）"

--[[
    Appended to the Automated Rolls description. Item Overrides is the one way
    a Bind on Pickup or quest item gets rolled on; nothing ever rolls on the
    rest.
]]
L["SAFETY_SKIP_NOTE"] =
	"它从不对配方、书籍、坐骑、宠物或传说物品掷骰；拾取后绑定物品和任务物品只有在物品特例中时才会掷骰。"

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] = "配方、书籍、坐骑、宠物和传说物品始终留给你处理。"

--[[
    Shown under each announcement's toggle, under Print Item in Chat and Hide
    Roll Messages, and under Enable Ignore Notifications. Argument: the
    message, as GogoLoot sends or prints it.
]]
L["OPTIONS_EXAMPLE"] = "示例：%s"

-- The muted version line at the foot of the General panel.
L["OPTIONS_VERSION"] = "版本%s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"快速拾取眨眼间就把尸体搜刮一空，自动掷骰和自动队长分配决定谁拿什么，自动开启撬开每一个蚌壳和板条箱。拾取提示让一切尽收眼底，任务物品、配方、坐骑、宠物和传说物品都安然无恙。别让战利品拖慢你冲刺的脚步！"
L["WELCOME_MESSAGE"] = "启用欢迎消息"
L["WELCOME_MESSAGE_DESCRIPTION"] = "每次登录时显示GogoLoot的版本，以及这些设置的位置。"
L["MINIMAP_BUTTON_ENABLE"] = "启用小地图按钮"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"在小地图上显示GogoLoot按钮。左键点击切换自动掷骰，右键点击切换自动开启，Shift + 左键点击切换通报，Shift + 右键点击切换自动队长分配。"

L["OPTIONS_COMMANDS_HEADER"] = "/命令"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "打开此插件的选项界面。"

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "功能"

L["SPEEDY_LOOT_ENABLE"] = "启用快速拾取"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"打开尸体的瞬间即将其拾取一空，不显示拾取窗口。拾取时按住Shift可照常显示窗口。会开启游戏的%s设置，你是%s时则暂停工作。"

L["FEEDBACK_SUPPORT"] = "反馈与支持"

-- CurseForge / GitHub / Discord / Wago are proper nouns; do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "队伍拾取设置"
L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"] = "设置队伍战利品的分配方式。只有队长可以更改。"
L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"] =
	"设置拾取方式所适用的最低物品品质。只有队长可以更改。"

--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them, including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "这些设置由%s控制。"
-- Shown in the same place while solo, where the two dropdowns are greyed out.
L["MASTER_LOOTER_SOLO_NOTE"] = "加入队伍后才能更改这些设置，且只有队长可以更改。"

-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"] =
	"你是%s时，打开拾取窗口的瞬间就把每件掉落交给你为其品质指定的玩家。"
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "启用自动队长分配"
L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"] =
	'开启或关闭自动分配。除非开启了"副本外也启用"，否则只在地下城和团队副本中生效。'
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "副本外也启用"
L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"在野外也自动分配战利品。世界首领的战利品无法交易，因此不建议开启。"
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "包含任务物品"
L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"] =
	"同时分配任务物品，方便带练你自己操作的其他角色。只在拾取品质门槛为普通或更低时生效，且仅限全队只掉落一件的任务物品。不建议在团队中使用。"

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // 快捷设置"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_POPUP_TOOLTIP"] = "每当你成为%s时，在窗口中打开这些设置。"
L["MASTER_LOOTER_POPUP_ENABLE"] = "启用队长分配弹窗"

L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"选择每种品质由谁接收。未指定人选的品质会留在拾取窗口中由你处理。"
L["MASTER_LOOTER_DESTINATION_SELF"] = "自己"
-- The first choice in every destination dropdown: nobody picked, so that quality waits in the loot window.
L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"] = "拾取窗口"
L["MASTER_LOOTER_SEND_ALL"] = "全部战利品交给"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] = "将下方所有品质都设为同一名玩家。"
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "设置由谁接收%s物品。"
-- Shown under Loot Destinations while Automated Master Looting is on and no quality has anybody picked.
L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] =
	"尚未指定任何人，所有战利品都会留在拾取窗口中由你处理。"

L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"此列表中的物品永远不会被自动分配，而是留在拾取窗口中由你亲自分配。"
-- Shown on the Ignore List while Automated Master Looting is off.
L["MASTER_LOOTER_OFF_NOTE"] = "自动队长分配已关闭，这些设置暂不生效。"
L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"] = "用你所在资料片的默认物品替换忽略列表。"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"这将用你所在资料片的默认物品替换你的忽略列表。是否继续？"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "从忽略列表中移除此物品。"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_PANEL_DESCRIPTION"] =
	"在队伍拾取时替你对不高于所选品质的物品选择%s、%s或%s，队伍和团队可分别设置。"
L["ROLLS_ENABLE"] = "启用自动掷骰"
L["ROLLS_ENABLE_DESCRIPTION"] = "开启或关闭自动掷骰，包括物品特例和角色规则。"
L["ROLLS_IN_PARTY"] = "队伍中"
L["ROLLS_IN_RAID"] = "团队中"
-- The caption of the quality row under In Party and under In Raid, shown while that roll isn't Manual.
L["ROLLS_UP_TO_QUALITY"] = "最高品质"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s：GogoLoot会掷骰的最高品质。"
L["ROLLS_ACTION_CHOOSE"] = "%s：GogoLoot的掷骰选择。手动则由你自己掷骰。"
-- Section headers on the Automated Rolls panel.
L["ROLLS_LOOT_THRESHOLDS_HEADER"] = "拾取品质门槛"
L["ROLLS_MESSAGES_HEADER"] = "掷骰消息"
L["ROLLS_PRINT_ITEM"] = "在聊天框中显示物品"
L["ROLLS_PRINT_ITEM_DESCRIPTION"] =
	"在聊天框中显示GogoLoot掷骰的每件物品，以及它做出的掷骰选择。GogoLoot一掷骰，掷骰窗口就会关闭，所以这里就是你查看掉落了什么的记录。"
L["ROLLS_HIDE_MESSAGES"] = "隐藏掷骰消息"
-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_HIDE_MESSAGES_TOOLTIP"] =
	"隐藏游戏为每次掷骰发出的聊天信息：谁选择了%s、%s或%s，以及掷出的每个点数。每位获胜者得到了什么仍会显示在聊天中。"
-- The dropdown beside Hide Roll Messages.
L["ROLLS_WINNER_SUMMARY_PRINT"] = "显示获胜者摘要"
L["ROLLS_WINNER_SUMMARY_NONE"] = "不显示获胜者摘要"
L["ROLLS_WINNER_SUMMARY_DESCRIPTION"] =
	'"显示获胜者摘要"会为每次获胜在聊天中显示一行，写明获胜者、物品和获胜掷骰，取代游戏自己的那一行。"不显示获胜者摘要"则保留游戏自己说明谁获胜的那一行。'

--[[
    Item Overrides, under Automated Rolls: items with a roll action of their
    own.
]]
L["ITEM_OVERRIDES_DESCRIPTION"] =
	"为特定物品指定掷骰方式，优先于品质设置。这是让GogoLoot对拾取后绑定物品或任务物品掷骰的唯一方法。"
-- Shown on Item Overrides while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "自动掷骰已关闭，这些设置暂不生效。"
L["ITEM_OVERRIDES_ENABLE"] = "启用物品特例"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"使用下方设置的掷骰方式。关闭后，这些物品和其他物品一样遵循品质设置。"
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] = "用你所在资料片的默认物品替换物品特例。"
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"这将用你所在资料片的默认物品替换你的物品特例。是否继续？"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "设置此物品的自动掷骰方式。"
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "从物品特例中移除此物品。"
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "要从物品特例中移除此物品及其掷骰方式吗？"

--[[
    Character Rules, under Automated Rolls: the stats whose gear each
    character leaves to the player. The stat names come from the game's own
    strings.
]]
-- Arguments: the game's own name for Intellect, then for the Warrior class, then Intellect again.
L["CHARACTER_RULES_PANEL_DESCRIPTION"] =
	'按角色把带有所选属性的装备留给你自己处理：将%s设为"手动"，你的%s遇到%s装备时就会保留掷骰窗口，其余物品照常掷骰。物品特例仍然优先。'
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "主要属性"
L["CHARACTER_RULES_SECONDARY"] = "次要属性"
-- The first of the two choices in each stat's dropdown: no rule, so the rest of Automated Rolls decides.
L["CHARACTER_RULES_STANDARD"] = "标准自动掷骰"
L["CHARACTER_RULES_ACTION_DESCRIPTION"] =
	'%s："手动"会在此角色上把带有该属性的装备连同掷骰窗口一起留给你。"标准自动掷骰"则像其他物品一样掷骰。'

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"将交易摘要和队长分配结果发到聊天频道，让大家都知道战利品去了哪里。"
L["ANNOUNCEMENTS_ENABLE"] = "启用通报"
-- Also the tooltip of the same switch in the General panel's Features section, so it names no position on the panel.
L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"] =
	"开启或关闭所有通报。关闭时，GogoLoot不会向你的队伍或交易对象发送任何消息，连你亲手分配的物品也不会通报。"

-- Trade Announcements
L["TRADE_DESCRIPTION"] = "为每笔完成的交易发布摘要：物品、附魔和金币。"
L["TRADE_ENABLE"] = "启用交易通报"
L["TRADE_ENABLE_DESCRIPTION"] = '交易完成时发布摘要。交易窗口上的"通报"复选框就是这个开关。'
L["TRADE_CONDITION_DESCRIPTION"] =
	"选择何时发布交易摘要：始终、在队伍或团队中时，或在团队中时。"
L["TRADE_CONDITION_ALWAYS"] = "始终"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "在队伍或团队中时"
L["TRADE_CONDITION_RAID_ONLY"] = "在团队中时"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "频道"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	'"%s"将每条摘要发送给交易对象。"队伍聊天"将其发到队伍或团队频道，不在队伍中时仍以悄悄话发送。"仅自己"只显示在你自己的聊天框中，不发送给任何人。'
-- The Channel dropdown's choices (Whisper is the client's WHISPER), and the trade window checkbox tooltip's Channel value.
L["TRADE_OUTPUT_GROUP"] = "队伍聊天"
L["TRADE_OUTPUT_SELF"] = "仅自己"
L["TRADE_TOOLTIP_DESCRIPTION"] = "此交易完成时将交易摘要发到聊天频道。"
L["TRADE_CHECKBOX_LABEL"] = "通报"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "告诉队伍每种品质由谁保管，以及你分配了哪些物品。"

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "启用去向通报"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"] =
	"每当你设置去向时，告诉队伍每种品质由谁保管。"

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "启用自动分配通报"
L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"] =
	"通报GogoLoot自动分配的每件物品，仅限所选品质及以上。"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"] = "低于此品质的自动分配不会通报。"

L["MASTER_LOOTER_ANNOUNCE_MANUAL"] = "启用手动分配通报"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"] =
	"通报你通过%s菜单亲手分配的每件物品，无论品质，措辞与自动分配相同。无论此项是否开启，分配失败都会报告。"

--------------------------------------------------------------------------------
-- Options: Loot Toasts and Loot Sounds
--------------------------------------------------------------------------------

-- Argument: the game's own name for the General chat tab.
L["LOOT_TOASTS_PANEL_DESCRIPTION"] =
	"将你拾取的每件物品和金币在屏幕上显示几秒钟，这样即使快速拾取隐藏了拾取窗口，也不会错过任何东西。开启提示后，游戏自身的拾取消息可以不再显示在你的%s聊天标签中。"
L["LOOT_TOASTS_ENABLE"] = "启用拾取提示"
-- Also the tooltip of the same switch in the General panel's Features section.
L["LOOT_TOASTS_SWITCH_DESCRIPTION"] = '按照"筛选"中的选择，为你和队伍拾取的战利品显示提示。'
-- The dropdown beside Enable Loot Toasts: the game's Item Loot and Money Loot chat settings for the General tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"] = "禁用标准拾取消息"
L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"] = "启用标准拾取消息"
-- Arguments: the game's own names for its Item Loot and Money Loot chat settings, then for the General chat tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"] =
	'"禁用标准拾取消息"会在拾取提示开启期间关闭%s和%s，作用于你的%s聊天标签；关闭拾取提示后它们会恢复。这与该标签自身设置中的选项相同，其他标签各自保留自己的设置。'

-- The Loot Toasts panel's two section headers.
L["LOOT_TOASTS_STACK_HEADER"] = "堆叠"
L["LOOT_TOASTS_TEXT_HEADER"] = "文字"

--[[
    Filters: a row per item type, captioned with the game's own name for it,
    each with a Mine box and a Group box. Weapon, Armor, Trade Goods and Gem
    carry a quality dropdown beside each ticked box. Argument in each tooltip:
    the row's item type, as the client names it.
]]
-- Shown on the Filters panel while Loot Toasts is off.
L["LOOT_TOASTS_OFF_NOTE"] = "拾取提示已关闭，这些设置暂不生效。"
-- The Filters panel's description.
L["LOOT_TOASTS_FILTERS_CAPTION"] =
	"选择哪些战利品显示提示以及提示的内容，你自己的和队伍的战利品分别设置。队伍的战利品旁会显示拾取者的名字。"
L["LOOT_TOASTS_FILTER_MINE"] = "我的"
L["LOOT_TOASTS_FILTER_GROUP"] = "队伍"
L["LOOT_TOASTS_FILTER_MINE_DESCRIPTION"] = "显示你拾取的%s物品。"
L["LOOT_TOASTS_FILTER_GROUP_DESCRIPTION"] =
	"显示队伍或团队中任何人拾取的%s物品，并附上拾取者的名字。"
L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"] =
	"显示你拾取的%s物品，仅限品质不低于旁边所选品质的物品。"
L["LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION"] =
	"显示队伍或团队中任何人拾取的%s物品，仅限品质不低于旁边所选品质的物品，并附上拾取者的名字。"
L["LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION"] = "你拾取的%s物品中，会显示提示的最低品质。"
L["LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION"] = "队伍拾取的%s物品中，会显示提示的最低品质。"

-- The three Filters rows after the item types, which aren't item types themselves: their captions (Money's is the client's MONEY) and their boxes' tooltips.
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP"] = "拾取后绑定"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION"] =
	"显示你拾取的每件拾取后绑定物品，无论类型或品质。"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION"] =
	"显示队伍拾取的每件拾取后绑定物品，无论类型或品质。"
L["LOOT_TOASTS_FILTER_OPENABLES"] = "可开启物品"
L["LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION"] =
	"显示你拾取的、GogoLoot可以开启的容器，包括锁箱，无论品质。"
L["LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION"] =
	"显示队伍拾取的、GogoLoot可以开启的容器，包括锁箱，无论品质。"
L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"] =
	'为你拾取的金币显示提示。游戏不会报告其他玩家拾取的金币，因此没有"队伍"复选框。'

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast it follows the item
    (LOOT_TOASTS_WON_ROLL); on a group member's, their name
    (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "获胜掷骰"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] = "在你赢得的物品的提示上附上获胜掷骰，例如 (%s)。"
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"在队友赢得的物品的提示上附上其获胜掷骰，例如 (%s, %s)。"
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_WON_ROLL"] = "%s (%s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "背包数量"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"当你携带的数量多于提示本身的数量时，在你自己战利品的提示上附上当前携带总数，例如 x3 (27)。"
-- How many came, after the item on a toast. Argument: the count.
L["LOOT_TOASTS_QUANTITY"] = "x%d"
-- Bag Count, after the item and its count. Argument: how many the player carries.
L["LOOT_TOASTS_BAG_COUNT"] = "(%d)"

-- Stack
L["LOOT_TOASTS_MAX_ITEMS"] = "最多提示数"
L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"] =
	"屏幕上同时显示的最多提示数量；最旧的提示会让出位置。"
L["LOOT_TOASTS_UNLIMITED"] = "不限"
L["LOOT_TOASTS_DURATION"] = "显示秒数"
L["LOOT_TOASTS_DURATION_DESCRIPTION"] = "每条提示在淡出前停留的秒数。"
L["LOOT_TOASTS_GROWTH"] = "增长方向"
L["LOOT_TOASTS_GROWTH_DESCRIPTION"] = "较旧的提示向上还是向下移动，远离最新的一条。"
L["LOOT_TOASTS_GROW_UP"] = "向上"
L["LOOT_TOASTS_GROW_DOWN"] = "向下"
L["LOOT_TOASTS_ALIGN"] = "对齐方式"
L["LOOT_TOASTS_ALIGN_DESCRIPTION"] = "提示在拖动手柄的哪一侧对齐。"
L["LOOT_TOASTS_ALIGN_LEFT"] = "左"
L["LOOT_TOASTS_ALIGN_RIGHT"] = "右"

-- Text
L["LOOT_TOASTS_FONT"] = "字体"
L["LOOT_TOASTS_FONT_DESCRIPTION"] = "提示文字所用的字体。"
L["LOOT_TOASTS_FONT_DEFAULT"] = "默认"
L["LOOT_TOASTS_FONT_SIZE"] = "字体大小"
L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"] = "提示文字的大小；图标会随之放大或缩小。"
L["LOOT_TOASTS_OUTLINE"] = "字体描边"
L["LOOT_TOASTS_OUTLINE_DESCRIPTION"] =
	"提示文字周围的描边，让文字在明亮的场景中依然清晰可读。"
L["LOOT_TOASTS_OUTLINE_NONE"] = "无"
L["LOOT_TOASTS_OUTLINE_OUTLINE"] = "描边"
L["LOOT_TOASTS_OUTLINE_THICK"] = "粗描边"
L["LOOT_TOASTS_OUTLINE_MONOCHROME"] = "单色"
L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"] = "单色描边"

-- Position
L["LOOT_TOASTS_UNLOCK"] = "解锁位置"
L["LOOT_TOASTS_LOCK"] = "锁定位置"
L["LOOT_TOASTS_RESET"] = "重置位置"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "显示或隐藏用于将提示拖到新位置的手柄。"
L["LOOT_TOASTS_RESET_DESCRIPTION"] = "将提示移回屏幕中央上方的默认位置。"

-- The drag handle: its title, the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_HANDLE_TITLE"] = "GogoLoot拾取提示"
L["LOOT_TOASTS_CLICK_DRAG"] = "点击并拖动以调整位置"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "右键点击以锁定"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "禁用拾取提示"
-- The stand-in item on the sample toasts, and in every Example line.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "示例物品"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"拾取达到或高于所选品质的战利品时播放提示音，%s偷到东西时播放背包音效。"
L["LOOT_SOUNDS_ENABLE"] = "启用拾取音效"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"从尸体或宝箱中拾取达到或高于所选品质的物品时播放提示音。"
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "播放拾取音效的最低物品品质。"
L["LOOT_SOUNDS_TEST"] = "播放拾取音效。"
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "启用%s音效"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "%s真正偷到东西时播放背包音效。"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "播放%s音效。"

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"只要你至少有%d个空闲背包格，就自动替你打开背包里的蚌壳、板条箱、钱袋和已开锁的锁箱。"
L["AUTOMATED_OPENING_ENABLE"] = "启用自动开启"
-- Also the tooltip of the same switch in the General panel's Features section. Argument: the game's own name for its Auto Loot setting.
L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"] =
	"每次只开启一个容器，在战斗中、施法中、潜行中，或打开商人、银行、邮箱、拍卖行或交易窗口时暂停。启用时会开启游戏的%s设置。"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"] = "仅在副本外"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"你在地下城、团队副本或战场中时，暂停开启任何物品。"
L["AUTOMATED_OPENING_ONLY_SOLO"] = "仅在单人时"
L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"] = "你在队伍或团队中时，暂停开启任何物品。"

-- Lockboxes
-- Arguments: the game's own name for the Rogue class, then for the Lockpicking skill.
L["LOCKBOXES_SECTION_DESCRIPTION"] =
	"锁箱需要%s撬开后才能打开。这些选项会显示每个锁箱所需的%s技能，并在有锁箱等待开启时提醒你。"
L["LOCKBOXES_TOOLTIPS_ENABLE"] = "启用锁箱鼠标提示"
-- Argument: the game's own name for the Lockpicking skill.
L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"] = "在每个锁箱的鼠标提示中加入其所需的%s技能。"
L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"] =
	"设置锁箱鼠标提示仅对潜行者显示，还是对所有角色显示。"
L["LOCKBOXES_NOTIFICATIONS_ENABLE"] = "启用锁箱通知"
L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"拾取到解锁后即会自动开启的锁箱时，在聊天框中提醒你。"
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] =
	"设置锁箱通知仅对潜行者显示，还是对所有角色显示。"
L["LOCKBOXES_FOR_ROGUES"] = "仅潜行者"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "所有角色"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking" line (ITEM_REQ_SKILL), followed by a skill number. Argument:
    the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "你的%s"

-- On the Automated Opening panel, below its switch.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "启用忽略通知"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	'当GogoLoot因可开启物品列表设为"忽略"而不动某个容器时，在聊天框中告诉你并说明原因。'

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	'GogoLoot认识的所有容器，以及自动开启会如何处理它们。"忽略"会让容器保持原封，快速拾取也会把它留在拾取窗口中给你。你的更改对你的所有角色生效。'
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] =
	'自动开启已关闭时，只有"忽略"仍在生效：它仍会让快速拾取跳过这些物品。'
L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"] =
	"将列表恢复为默认：每件物品恢复默认设置，已移除的物品会回来，已添加的物品会被移除。"
L["OPENABLE_ITEMS_RESTORE_CONFIRM"] =
	"要将列表恢复为默认吗？你更改的所有设置，以及添加或移除的所有物品，都将被撤销。"
L["OPENABLE_ITEMS_ADD_DESCRIPTION"] =
	'输入物品ID或将物品拖到此处，即可将其添加到列表并设为"开启"。装备和背包无法添加，因为使用它们会将其装备上。'
L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"] =
	'将你携带的一件物品添加到列表并设为"开启"。装备和背包不会列出，因为使用它们会将其装备上。'
L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"] =
	"将此物品从列表中移除。之后GogoLoot会把它当作普通物品：从不开启，并像其他物品一样拾取。"
L["OPENABLE_ITEMS_REMOVE_CONFIRM"] = "要从列表中移除此物品吗？再次添加即可恢复。"
L["OPENABLE_ITEMS_ACTION_DESCRIPTION"] = "设置自动开启如何处理此容器。"

-- The Openables List dropdown, one per item.
L["OPENING_ACTION_OPEN"] = "开启"
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
L["OPENING_REASON_LOCKED_CLASS"] = "需要%s撬开。撬开后，它会像其他容器一样被开启。"
L["OPENING_REASON_RAID"] =
	"由团队首领或世界首领掉落。未开启的容器仍可交易或出售，售价往往高于里面的东西。"
L["OPENING_REASON_BIND_ON_PICKUP"] = "可能含有拾取后绑定的物品。保持原封时仍可交易或出售。"
L["OPENING_REASON_UNIQUE"] = "可能含有唯一物品。如果你已携带一件，开启时会出错失败。"
