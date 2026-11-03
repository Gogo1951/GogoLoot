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

-- The Full Name: leads every printed line, and names the options panels, window titles and the mini-map header. A proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
-- The Short Name: closes every sent message and names the add-on on tooltip lines other than the mini-map header. A proper noun; keep it untranslated.
L["ADDON_SHORT_NAME"] = "GogoLoot"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"版本%s。设置（包括关闭此消息的选项）位于 选项 > 插件 > GogoLoot。喜欢这个插件吗？告诉朋友，在CurseForge上收藏，或在GitHub上点个Star吧。(="
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
--[[
    Standard Loot Messages taking the General tab's loot lines off, or putting
    them back. Arguments: the game's own names for its Item Loot and Money Loot
    chat settings, then for the General chat tab.
]]
L["MESSAGE_STANDARD_LOOT_MESSAGES_OFF"] =
	"拾取提示开启期间，已关闭%s和%s，作用于你的%s聊天标签。"
L["MESSAGE_STANDARD_LOOT_MESSAGES_ON"] = "已重新开启%s和%s，作用于你的%s聊天标签。"

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

-- The first feature panel, holding the one Speedy Loot switch.
L["TAB_SPEEDY_LOOT"] = "快速拾取"
L["TAB_AUTOMATED_ROLLS"] = "自动掷骰"
L["TAB_ITEM_OVERRIDES"] = "物品特例"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "角色规则"
-- The panel for everything GogoLoot posts to chat; also its row in the mini-map button's tooltip.
L["TAB_ANNOUNCEMENTS"] = "战利品通报"
-- Headers of the two sections on the Loot Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "交易通报"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "队长分配通报"
L["TAB_LOOT_TOASTS"] = "拾取提示"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "筛选"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "拾取音效"
L["TAB_AUTOMATED_OPENING"] = "自动开启"
-- A child panel of Automated Opening, beside the Openables List.
L["TAB_LOCKBOXES"] = "锁箱"
L["TAB_OPENABLE_ITEMS"] = "可开启物品列表"
-- Named for its switch, Enable Automated Master Looting. Roll Macro follows it.
L["TAB_MASTER_LOOTER"] = "自动队长分配"
-- Header of a section on the Automated Master Looting panel.
L["TAB_LOOT_DESTINATIONS"] = "战利品去向"
L["TAB_IGNORE_LIST"] = "忽略列表"
-- The panel after Automated Master Looting, named for its switch, Enable Roll Macro.
L["TAB_ROLL_MACRO"] = "掷骰宏"
-- The panel after Roll Macro, for the Loot Master and Loot Tracker windows; also the Loot Master window's title.
L["TAB_LOOT_MASTER"] = "战利品分配器"

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
    The tooltip titles each feature with its options-panel name, and gives
    each a description of its own, two lines at most: the panels' longer text
    doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "替你对符合条件、不高于所选品质的物品自动掷骰。"
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] = "开启背包中的蚌壳、板条箱、钱袋和已解锁的锁箱。"
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
L["MINIMAP_TOGGLE"] = "开关"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "已锁物品"
-- Under the list. Argument: the game's own name for the Rogue class.
L["MINIMAP_LOCKED_ITEMS_HINT"] = "%s可以帮你开锁。"
-- The same, shown to a Rogue. Argument: the game's own name for Pick Lock.
L["MINIMAP_LOCKED_ITEMS_HINT_ROGUE"] = "使用%s来开锁。"
L["MINIMAP_OPTIONS"] = "GogoLoot选项"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 中键点击"

-- Heads the items on the Roll List still on a trade clock, soonest first, under Locked Items.
L["MINIMAP_TRADABLE_LOOT"] = "可交易战利品"
-- Under the first few of them. Argument: how many more there are.
L["MINIMAP_TRADABLE_MORE"] = "还有%d件"
-- The loot windows' block: its title, how many items are on the Roll List, its description and its click.
L["MINIMAP_LOOT_WINDOWS"] = "战利品分配器和战利品追踪器"
L["MINIMAP_TO_HAND_OUT"] = "%d件待分配"
L["MINIMAP_LOOT_WINDOWS_DESCRIPTION"] = "通过掷骰分配仍可交易的物品，并关注每一次掷骰。"
L["MINIMAP_MIDDLE_CLICK"] = "中键点击"
L["MINIMAP_OPEN"] = "打开"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "手动"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "仅%s"
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
L["ITEM_LIST_ADD"] = "添加物品"
L["ITEM_LIST_ADD_DESCRIPTION"] = "输入物品ID或将物品拖到此处，即可将其添加到列表中。"
L["ITEM_LIST_ADD_PLACEHOLDER"] = "将物品拖到此处，或输入物品ID"
L["ITEM_LIST_ADD_BUTTON"] = "添加"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "筛选物品..."
L["ITEM_LIST_FILTER_DESCRIPTION"] = "只显示名称、物品ID、设置或标签中包含所输入内容的物品。"
L["ITEM_LIST_NO_MATCHES"] = "没有符合筛选条件的物品。"
-- Shown in place of the rows when the Ignore List or Item Overrides is empty, since both refill at login.
L["ITEM_LIST_EMPTY_REFILLS"] =
	"此列表为空，因此默认物品会在你下次登录时恢复。点击恢复默认可立即恢复。"

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

-- Shown under every setting that prints or sends a chat line. Argument: the message, drawn as it arrives in chat.
L["OPTIONS_EXAMPLE"] = "示例：%s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"快速拾取无需打开拾取窗口即可搜空尸体，自动掷骰按品质选择需求、贪婪或放弃，自动队长分配替你分发战利品。蚌壳、容器和已解锁的锁箱会自动打开。拾取更快，开怪更早。"
L["WELCOME_MESSAGE"] = "启用欢迎消息"
L["WELCOME_MESSAGE_DESCRIPTION"] = "每次登录时显示GogoLoot的版本，以及这些设置的位置。"
L["MINIMAP_BUTTON_ENABLE"] = "启用小地图按钮"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"在小地图上显示GogoLoot按钮。左键点击切换自动掷骰，右键点击切换自动开启，Shift + 左键点击切换战利品通报，Shift + 右键点击切换自动队长分配。"

L["OPTIONS_COMMANDS_HEADER"] = "/命令"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "打开此插件的选项界面。"

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "功能"

-- The opening line of the Speedy Loot panel, above its switch.
L["SPEEDY_LOOT_DESCRIPTION"] = "打开尸体的瞬间就拿走所有东西，让你再也不用等拾取窗口。"
L["SPEEDY_LOOT_ENABLE"] = "启用快速拾取"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"打开尸体的瞬间即将其拾取一空，不显示拾取窗口。拾取时按住Shift可照常显示窗口。会开启游戏的%s设置，你是%s时则暂停工作。"

--[[
    The Roll Macro panel. %s is the macro's name, "- Roll", the same in every
    locale. General Macros is the tab of the game's Macros window that every
    character on the account shares; /macro is the game's command and stays
    English.
]]
L["ROLL_MACRO_DESCRIPTION"] =
	"在你的通用宏中添加一个名为%s、以金币为图标的宏，账号中的每个角色都能把它拖到动作条上。"
--[[
    The three rows under it, each beside the game's name for a mouse button
    (MINIMAP_LEFT_CLICK and its neighbours). Right-click is the off-spec roll;
    a raid roll picks a number from 1 to the group's size.
]]
L["ROLL_MACRO_LEFT_CLICK"] = "掷骰 1-100"
L["ROLL_MACRO_RIGHT_CLICK"] = "掷骰 1-99"
L["ROLL_MACRO_MIDDLE_CLICK"] = "团队掷骰"
L["ROLL_MACRO_ENABLE"] = "启用掷骰宏"
-- Under the three rows, in silver: what Middle-Click's raid roll is for and how to read it.
L["ROLL_MACRO_RAID_ROLL_NOTE"] =
	"团队掷骰会把物品随机交给某个人。它从1掷到队伍中的玩家人数，每个数字代表一名玩家：在团队或小队列表中往下数到掷出的数字，就能找到获胜者。单人时则掷1-100。"
L["ROLL_MACRO_SWITCH_DESCRIPTION"] =
	"在你的通用宏中保留%s宏：左键点击掷1-100，右键点击掷1-99，中键点击进行团队掷骰。关闭此项会删除该宏。"
--[[
    Printed to chat when Enable Roll Macro is switched on or off, or the macro
    can't be made. In ROLL_MACRO_ADDED the second %s is /m, the game's command
    for its Macros window, drawn in blue.
]]
L["ROLL_MACRO_ADDED"] = "%s宏已在你的通用宏中。输入%s并将它拖到动作条上。"
L["ROLL_MACRO_REMOVED"] = "%s宏已被删除。"
L["ROLL_MACRO_FULL_LOADING"] =
	"无法添加%s宏：你的通用宏已满。删除一个后，下次载入画面结束时会自动添加。"

--------------------------------------------------------------------------------
-- Options: Feedback & Support Panel
--------------------------------------------------------------------------------

-- "Star" stays GitHub's English button label in every locale; Discord, CurseForge, Wago and GitHub stay as written.
L["OPTIONS_LEVEL_UP_TITLE"] = "帮助GogoLoot升级"
L["OPTIONS_LEVEL_UP_INTRO"] =
	"这个插件由热爱这款游戏的玩家打造，希望让每个人都玩得尽可能开心。我们永远不会请求捐款。真正的满足感来自知道我们的工作让你的游戏变得更好一点。如果确实如此，我们很想听你说说！"
L["OPTIONS_LEVEL_UP_WAYS"] = "以下几种方式可以帮助我们接触到更多玩家。"
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• 分享反馈：发现了错误或有新想法？请在Discord上告诉我们。你的反馈能帮助我们改进插件，也随时欢迎提交拉取请求。"
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• 告诉朋友：认识可能喜欢这个插件的人吗？告诉他们吧。口口相传能帮助更多玩家发现好插件。"
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• 在CurseForge上收藏：打开下方的CurseForge链接，登录后点击Download按钮下方的星标。收藏能帮助更多玩家发现这个插件。"
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• 在GitHub上点Star：打开下方的GitHub链接，登录后点击右上角的Star。Star能帮助项目获得更多免费开发者工具的资格。"
L["OPTIONS_LEVEL_UP_THANKS"] = "感谢选择GogoLoot！"

L["OPTIONS_FEEDBACK"] = "反馈与支持"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "反馈与支持链接"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "要复制链接，请点击其文本框，然后按Ctrl+A和Ctrl+C。"
-- The version line at the foot of the Feedback & Support panel.
L["OPTIONS_VERSION"] = "版本%s"

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

-- The pop-up's own title, which code joins with the add-on name: "Quick Settings // GogoLoot".
L["QUICK_SETTINGS_TITLE"] = "快捷设置"
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
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] = "要用你所在资料片的默认物品替换你的忽略列表吗？"
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
L["ROLLS_PARTY_AND_RAID_HEADER"] = "队伍与团队掷骰"
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
-- Shown on Item Overrides and Character Rules while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "自动掷骰已关闭，这些设置暂不生效。"
L["ITEM_OVERRIDES_ENABLE"] = "启用物品特例"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"使用下方设置的掷骰方式。关闭后，这些物品和其他物品一样遵循品质设置。"
-- Shown under Enable Item Overrides while it is off.
L["ITEM_OVERRIDES_OFF_NOTE"] = "物品特例已关闭，这些掷骰设置暂不生效。"
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] = "用你所在资料片的默认物品替换物品特例。"
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] = "要用你所在资料片的默认物品替换你的物品特例吗？"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "设置此物品的自动掷骰方式。"
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "从物品特例中移除此物品。"
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "要从物品特例中移除此物品及其掷骰方式吗？"
L["ITEM_OVERRIDES_ADD_DESCRIPTION"] =
	"输入物品ID或将物品拖到此处，即可将其添加到列表中，并设为手动。"

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
L["ANNOUNCEMENTS_ENABLE"] = "启用战利品通报"
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
-- The trade window checkbox tooltip's line naming when summaries are posted.
L["TRADE_WHEN"] = "时机"
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
-- The Container row is the bag class; clams, crates and lockboxes have the Openables row.
L["LOOT_TOASTS_FILTER_CONTAINER_MINE_DESCRIPTION"] =
	"显示你拾取的背包。蚌壳、板条箱和锁箱在可开启物品中。"
L["LOOT_TOASTS_FILTER_CONTAINER_GROUP_DESCRIPTION"] =
	"显示队伍或团队中任何人拾取的背包，并附上拾取者的名字。蚌壳、板条箱和锁箱在可开启物品中。"

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
	'为你拾取的金币显示提示。游戏不会报告其他玩家拾取的金币，所以没有"队伍"复选框。'

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast "You Won" takes the
    looter's place (LOOT_TOASTS_YOU_WON_ROLL: the item, the roll); on a group
    member's, their name (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "获胜掷骰"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"在你赢得的物品的提示上附上获胜掷骰，例如 (你获胜, %s)。"
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"在队友赢得的物品的提示上附上其获胜掷骰，例如 (%s, %s)。"
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_YOU_WON_ROLL"] = "%s (你获胜, %s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "背包数量"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"当你携带的数量多于提示本身的数量时，在你自己战利品的提示上附上当前携带总数，例如 x3 (27)。"
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
L["LOOT_TOASTS_ALIGN_TOASTS"] = "提示对齐"
L["LOOT_TOASTS_ALIGN_TOASTS_DESCRIPTION"] = "提示在拖动手柄的哪一侧对齐。"
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
L["LOOT_TOASTS_RESET_CONFIRM"] = "要将拾取提示移回默认位置吗？"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "显示或隐藏用于将提示拖到新位置的手柄。"
L["LOOT_TOASTS_RESET_DESCRIPTION"] = "将提示移回屏幕中央上方的默认位置。"

-- The drag handle, titled "Loot Toasts // GogoLoot" by code: the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_CLICK_DRAG"] = "点击并拖动以调整位置"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "右键点击以锁定"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "禁用拾取提示"
-- The stand-in item on the sample toasts the position preview shows; Example lines link real items.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "示例物品"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"拾取达到或高于所选品质的战利品时播放提示音，%s偷到东西时播放背包音效。"
-- The Loot Sounds panel's master switch, also in the General panel's Features section; its tooltip names no position on either.
L["LOOT_SOUNDS_SWITCH"] = "启用拾取音效"
L["LOOT_SOUNDS_SWITCH_DESCRIPTION"] = "开启或关闭GogoLoot的所有拾取音效。"
-- The chime's own toggle, under the master switch.
L["LOOT_SOUNDS_ENABLE"] = "启用拾取提示音"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"从尸体或宝箱中拾取达到或高于所选品质的物品时播放提示音。"
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "会播放拾取提示音的最低物品品质。"
L["LOOT_SOUNDS_TEST"] = "播放拾取提示音。"
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "启用%s音效"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "%s真正偷到东西时播放背包音效。"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "播放%s音效。"

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"替你开启背包中的蚌壳、板条箱、钱袋和已解锁的锁箱，前提是你至少有%d个空闲背包格。"
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
-- Shown under Enable Lockbox Notifications while it is on and Automated Opening is off.
L["LOCKBOXES_NOTIFICATIONS_OFF_NOTE"] = "自动开启已关闭，锁箱通知暂不生效。"
L["LOCKBOXES_FOR_ROGUES"] = "仅潜行者"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "所有角色"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking (225)" line (ITEM_MIN_SKILL), or under GogoLoot's own
    ITEM_REQ_SKILL line where the client prints none, followed by a skill
    number. Argument: the game's own name for the Lockpicking skill.
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
-- The same while Speedy Loot is off too.
L["OPENABLE_ITEMS_ALL_OFF_NOTE"] = "自动开启和快速拾取都已关闭，这些设置暂不生效。"
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
L["ROLL_CALL_START"] = "/roll掷骰：%s，限时%d秒"
-- Arguments: the seconds left, then the item.
L["ROLL_CALL_LAST_SECONDS"] = "还剩%d秒：%s"
-- +10 Seconds. Arguments: the seconds added, then the item.
L["ROLL_CALL_EXTENDED"] = "延长%d秒：%s"
-- Arguments: the item, then the rolls that didn't count, each one of the four lines below, joined by commas.
L["ROLL_CALL_NOT_COUNTED"] = "%s的无效掷骰：%s"
-- Arguments: the player, then their roll.
L["ROLL_CALL_NOT_COUNTED_EARLY"] = "%s提前掷骰(%d)"
L["ROLL_CALL_NOT_COUNTED_REPEAT"] = "%s重复掷骰(%d)"
-- Arguments: the player, their roll, then the range they rolled in.
L["ROLL_CALL_NOT_COUNTED_RANGE"] = "%s掷出%d(范围%d-%d)"
L["ROLL_CALL_NOT_COUNTED_NOT_TIED"] = "%s掷出%d(不在平局重掷中)"
-- Arguments: the tied players, the roll they tied at, the item, the tied players again, then the seconds.
L["ROLL_CALL_TIE"] = "%s以%d点平局：%s。仅限%s再次/roll，限时%d秒"
-- With Re-roll Ties off. Arguments: the tied players, the roll they tied at, then the item.
L["ROLL_CALL_TIE_HELD"] = "%s以%d点平局：%s。稍后进行平局重掷"
-- Arguments: the winner, the item, then the winning roll.
L["ROLL_CALL_WINS"] = "%s赢得%s，点数%d"
-- After a disqualification or a restore changed who won. Arguments as above.
L["ROLL_CALL_NOW_WINS"] = "现由%s赢得%s，点数%d"
-- Argument: the item.
L["ROLL_CALL_NOBODY"] = "无人对%s掷骰，暂时保留在我的列表中"
L["ROLL_CALL_NOBODY_LEFT"] = "%s已无有效掷骰，重新放回我的列表"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_DISQUALIFIED_NO_REASON"] = "我已取消%s的%d点掷骰：%s"
-- The same with a reason. Arguments: the player, their roll, the item, then one of the ROLL_DISQUALIFY_REASON_ lines.
L["ROLL_CALL_DISQUALIFIED_BECAUSE"] = "我已取消%s的%d点掷骰：%s，原因：%s"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_RESTORED"] = "我已恢复%s的%d点掷骰：%s"
-- Arguments: the item, then the seconds.
L["ROLL_CALL_VOIDED"] = "我已作废%s的所有掷骰，请重新/roll，限时%d秒"
-- Argument: the item.
L["ROLL_CALL_CANCELED"] = "%s的掷骰已取消，请勿掷骰"
L["ROLL_CALL_PAUSED"] = "请暂停掷骰，%s已暂停"
-- Arguments: the item, then the seconds left.
L["ROLL_CALL_RESUMED"] = "%s恢复掷骰，剩余%d秒"
-- Each argument: items, joined by commas.
L["ROLL_CALL_ROLL_ALL"] = "依次掷骰：%s"
L["ROLL_CALL_UP_FOR_ROLL"] = "待掷骰：%s"
L["ROLL_CALL_FLOOR_LOOT"] = "散件战利品待掷骰：%s"
-- Drops by boss posted to the group, a line per boss. Arguments: the boss, then its drops, joined by commas.
L["DROPS_POST_LINE"] = "%s: %s"

--------------------------------------------------------------------------------
-- Roll Calls: Printed
--------------------------------------------------------------------------------

-- Outside a group there's nobody to send to. Argument: the line a group would have seen.
L["ROLL_CALL_SOLO_PREVIEW"] = "你不在队伍中，所以这条消息没有发给任何人：%s"
-- Arguments: the winner, then the item.
L["ROLL_CALL_WON_PRINT"] = "%s赢得了%s。与对方开启交易，GogoLoot会把它放进交易窗口。"

--------------------------------------------------------------------------------
-- Roll Tags and Reasons
--------------------------------------------------------------------------------

-- Beside a roll in the loot windows: why it doesn't count, or where it stands.
L["ROLL_TAG_EARLY"] = "在发起前掷骰"
L["ROLL_TAG_LATE"] = "在结束后掷骰"
L["ROLL_TAG_REPEAT"] = "重复掷骰，不计入"
-- Arguments: the range the player rolled in.
L["ROLL_TAG_RANGE"] = "范围错误（%d-%d）"
L["ROLL_TAG_NOT_TIED"] = "不在平局重掷中"
L["ROLL_TAG_DISQUALIFIED"] = "已取消资格"
-- Argument: one of the reasons below.
L["ROLL_TAG_DISQUALIFIED_BECAUSE"] = "已取消资格：%s"
L["ROLL_TAG_WINNER"] = "获胜者"
L["ROLL_TAG_HIGHEST"] = "目前最高"
L["ROLL_TAG_TIED"] = "平局"

-- The reasons offered when the loot master disqualifies a roll, also sent after ROLL_CALL_DISQUALIFIED_BECAUSE's colon.
L["ROLL_DISQUALIFY_REASON_NOT_ELIGIBLE"] = "无权获得此物品"
L["ROLL_DISQUALIFY_REASON_ALREADY_WON"] = "今晚已赢得过物品"
L["ROLL_DISQUALIFY_REASON_FOR_SOMEONE_ELSE"] = "替他人掷骰"
L["ROLL_DISQUALIFY_REASON_NONE"] = "未说明原因"

--------------------------------------------------------------------------------
-- Loot Master Window
--------------------------------------------------------------------------------

-- The tabs. Argument: how many items each holds.
L["LOOT_MASTER_TAB_ROLL_LIST"] = "掷骰列表（%d）"
L["LOOT_MASTER_TAB_FLOOR_LOOT"] = "散件战利品（%d）"
L["LOOT_MASTER_TAB_AWARDED"] = "已分配（%d）"
L["LOOT_MASTER_TAB_SOFT_RESERVES"] = "软预定"

-- The Roll List's buttons.
L["LOOT_MASTER_ROLL"] = "掷骰"
L["LOOT_MASTER_ROLL_AGAIN"] = "重新掷骰"
L["LOOT_MASTER_ROLL_ALL"] = "全部掷骰"
L["LOOT_MASTER_PAUSE"] = "暂停"
L["LOOT_MASTER_RESUME"] = "继续"
L["LOOT_MASTER_STOP"] = "停止"
L["LOOT_MASTER_LIST_IN_RAID"] = "在团队中列出"
L["LOOT_MASTER_MOVE_UP"] = "上移"
L["LOOT_MASTER_MOVE_DOWN"] = "下移"
-- Argument: the seconds added.
L["LOOT_MASTER_EXTEND"] = "+%d秒"
L["LOOT_MASTER_CLOSE_NOW"] = "立即结束"
L["LOOT_MASTER_VOID"] = "作废所有掷骰"
L["LOOT_MASTER_CANCEL_ROLL"] = "取消掷骰"
L["LOOT_MASTER_TAKE_OFF"] = "移出列表"
-- Argument: the winner.
L["LOOT_MASTER_GIVE"] = "交给%s"
L["LOOT_MASTER_TRADE"] = "与%s交易"
L["LOOT_MASTER_ANNOUNCE_WINNER"] = "通报获胜者"
L["LOOT_MASTER_HANDED_OUT"] = "标记为已分配"
L["LOOT_MASTER_REROLL_TIED"] = "平局重掷"
L["LOOT_MASTER_DISQUALIFY"] = "取消资格"
L["LOOT_MASTER_RESTORE"] = "恢复"

-- A row's trade clock, where it has none to show.
L["LOOT_MASTER_ON_CORPSE"] = "在尸体上"
L["LOOT_MASTER_CORPSE_CLOSED"] = "尸体已关闭"
L["LOOT_MASTER_BOUND"] = "已绑定"
L["LOOT_MASTER_NO_LIMIT"] = "无限制"

-- A row's state. Argument: how many rolls have landed.
L["LOOT_MASTER_STATUS_ROLLING"] = "掷骰中，已掷%d次"
L["LOOT_MASTER_STATUS_TIE_BREAK"] = "平局重掷，已掷%d次"
L["LOOT_MASTER_STATUS_ON_HOLD"] = "已暂停，已掷%d次"
-- STATUS_TIED and STATUS_NOBODY also title a finished roll in the Loot Tracker.
L["LOOT_MASTER_STATUS_TIED"] = "平局"
L["LOOT_MASTER_STATUS_NOBODY"] = "无人掷骰"
L["LOOT_MASTER_STATUS_SOULBOUND"] = "已灵魂绑定"
L["LOOT_MASTER_STATUS_UP_NEXT"] = "下一个"

-- The first line of an opened row.
L["LOOT_MASTER_HEADLINE_ROLLING"] = "掷骰中，剩余%d秒。"
L["LOOT_MASTER_HEADLINE_ON_HOLD"] = "已暂停，剩余%d秒。"
-- Arguments: the tied players, then the seconds left.
L["LOOT_MASTER_HEADLINE_TIE_BREAK"] = "%s平局重掷中，剩余%d秒。"
-- Arguments: the winner, then the winning roll.
L["LOOT_MASTER_HEADLINE_WON"] = "%s以%d点获胜。"
-- Arguments: the tied players, then the roll they tied at.
L["LOOT_MASTER_HEADLINE_TIED"] = "%s以%d点平局。"
L["LOOT_MASTER_HEADLINE_SOULBOUND"] = "已灵魂绑定，无法再交易。"
-- Argument: the boss. Also under the game's own trade line on a bag item's tooltip while it is on the Roll List.
L["LOOT_MASTER_LOOTED_FROM"] = "拾取自%s。"
L["LOOT_MASTER_FROM_FLOOR_LOOT"] = "来自散件战利品。"
-- After the line above. Argument: how long, in the game's own words for time.
L["LOOT_MASTER_TRADABLE_FOR"] = "还可交易%s。"
-- Headings over a row's rolls; ROUND_SO_FAR also heads an open roll in the Loot Tracker.
L["LOOT_MASTER_ROUND_SO_FAR"] = "目前的掷骰"
L["LOOT_MASTER_ROUND_ROLLS"] = "掷骰"
L["LOOT_MASTER_ROUND_FIRST"] = "首次掷骰"
L["LOOT_MASTER_ROUND_TIE_BREAK"] = "平局重掷"
-- Arguments: how many, then their names. Also in the Loot Tracker.
L["LOOT_MASTER_HASNT_ROLLED"] = "未掷骰（%d）：%s"

L["LOOT_MASTER_EMPTY"] =
	"还没有要分配的物品。你拾取的可交易战利品会自动出现在这里；Alt+点击背包中的其他物品即可添加。"
-- The line beside the Roll List's buttons.
L["LOOT_MASTER_STATE_PAUSED"] = "已暂停。"
L["LOOT_MASTER_STATE_ROLL_ALL"] = "全部掷骰：还剩%d件。"
L["LOOT_MASTER_STATE_ONE_AT_A_TIME"] = "一次只进行一个掷骰。"
L["LOOT_MASTER_STATE_WAITING"] = "%d件等待掷骰。"
-- The foot of the Roll List. Arguments: how many items, then the time left on the soonest trade clock.
L["LOOT_MASTER_FOOTER"] = "%d件待分配。"
L["LOOT_MASTER_FOOTER_CLOCK"] = "%d件待分配，最早的交易期限将在%s后结束。"
L["LOOT_MASTER_ALT_CLICK_HINT"] = "Alt+点击背包物品即可添加"

-- The Disqualify window.
L["LOOT_MASTER_DISQUALIFY_TITLE"] = "取消掷骰资格"
-- Arguments: the player, their roll, then the item.
L["LOOT_MASTER_DISQUALIFY_BODY"] = "要取消%s的%d点掷骰对%s的资格吗？之后可以恢复。"
L["LOOT_MASTER_DISQUALIFY_REASON"] = "原因"
L["LOOT_MASTER_DISQUALIFY_TELLS"] = "GogoLoot将告知队伍："
-- Argument: the item.
L["LOOT_MASTER_VOID_CONFIRM"] = "要作废%s的所有掷骰并重新发起掷骰吗？"

-- Printed by the Loot Master.
L["LOOT_MASTER_ROLL_ALL_DONE"] = "全部掷骰已完成。掷骰列表中的每件物品都已掷骰。"
L["LOOT_MASTER_ROLL_ALL_PAUSED"] = '全部掷骰已暂停。按下"继续"之前不会开始新的掷骰。'
L["LOOT_MASTER_ROLL_ALL_RESUMED"] = "全部掷骰已继续。"
L["LOOT_MASTER_ROLL_ALL_STOPPED"] = "全部掷骰已停止。进行中的掷骰仍会完成。"
-- Arguments: the item, then the whole minutes left.
L["LOOT_MASTER_TRADE_TIME_LOW"] = "%s还可交易%d分钟。"
-- Argument: the item.
L["LOOT_MASTER_TRADE_TIME_OVER"] = "%s已无法再交易。"
-- Arguments: the item, the winner, then their winning roll.
L["LOOT_MASTER_TRADE_FILLED"] = "已将%s放入交易窗口，%s以%d点赢得了它。"
-- Arguments: the winner, then the item.
L["LOOT_MASTER_NOT_A_CANDIDATE"] = "%s无法从这具尸体获得%s。"
-- Argument: the item.
L["LOOT_MASTER_ADDED"] = "%s已加入掷骰列表。"
L["LOOT_MASTER_NOT_TRADABLE"] = "%s无法交易，因此不能加入掷骰列表。"
-- Argument: how many joined.
L["LOOT_MASTER_FLOOR_ADDED"] = "已加入掷骰列表的散件战利品：%d件。"
L["LOOT_MASTER_OFF"] =
	"战利品分配器已关闭。请在 选项 > 插件 > GogoLoot > 战利品分配器 中开启。"

-- A bag item's tooltip, under the game's own trade line, while it is on the Roll List.
L["LOOT_MASTER_TOOLTIP_ON_ROLL_LIST"] = "在掷骰列表中。"
-- Arguments: the winner, then their winning roll.
L["LOOT_MASTER_TOOLTIP_WON_BY"] = "%s以%d点赢得。"

-- Floor Loot. The add box, filter and Add from Bags use the item lists' own words (ITEM_LIST_*).
L["LOOT_MASTER_FLOOR_DESCRIPTION"] =
	"没有交易倒计时、但你想拿来掷骰的战利品：材料、配方、装备后绑定的装备。初始为空，只有你添加的物品才会掷骰。每堆只掷一次。"
L["LOOT_MASTER_FLOOR_EMPTY"] =
	'这里还没有物品。从"从背包添加"中挑选，或将物品拖到上方的框中。'
-- Argument: how many the bags hold.
L["LOOT_MASTER_FLOOR_IN_BAGS"] = "背包中%d个"
L["LOOT_MASTER_FLOOR_ON_ROLL_LIST"] = "在掷骰列表中"
L["LOOT_MASTER_FLOOR_REMOVE"] = "将此物品移出散件战利品。"
-- The heading for an item whose kind the game hasn't said yet.
L["LOOT_MASTER_FLOOR_OTHER"] = "其他"
L["LOOT_MASTER_FLOOR_ADD_ALL"] = "全部加入掷骰列表"
-- Add from Bags' two headings.
L["LOOT_MASTER_FLOOR_MENU_PICKED_UP"] = "在此副本中拾取"
L["LOOT_MASTER_FLOOR_MENU_BAGS"] = "背包中的其他物品"
-- Argument: what was typed.
L["LOOT_MASTER_FLOOR_NOT_FOUND"] = '背包中没有与"%s"匹配的可交易物品。'

-- Awarded.
L["LOOT_MASTER_AWARDED_EMPTY"] = "还没有分配任何物品。获胜者拿到物品后，它会出现在这里。"
-- Arguments: the winning roll, then the time it was handed out.
L["LOOT_MASTER_AWARDED_ROLLED"] = "掷出%d，%s"
-- Argument: the time it was handed out.
L["LOOT_MASTER_AWARDED_GIVEN"] = "分配于%s"
L["LOOT_MASTER_AWARDED_CLEAR"] = "清除"

-- Soft Reserves, a placeholder for now.
L["LOOT_MASTER_SOFT_RESERVES_DESCRIPTION"] =
	"在此粘贴软预定字符串，查看谁预定了什么。即将推出：此标签页目前只是占位。"
L["LOOT_MASTER_SOFT_RESERVES_PLACEHOLDER"] = "软预定导入功能尚未就绪。"
L["LOOT_MASTER_SOFT_RESERVES_IMPORT"] = "导入"

--------------------------------------------------------------------------------
-- Loot Tracker Window
--------------------------------------------------------------------------------

L["LOOT_TRACKER_TITLE"] = "战利品追踪器"
L["LOOT_TRACKER_TAB_ROLLS"] = "掷骰"
L["LOOT_TRACKER_TAB_DROPS"] = "掉落"
L["LOOT_TRACKER_NO_ROLL"] = "今晚还没有掷骰。"
-- Argument: who called the roll.
L["LOOT_TRACKER_CALLED_BY"] = "由%s发起"
L["LOOT_TRACKER_SPOTTED"] = "发现于%s的聊天消息"
-- Argument: whole seconds left.
L["LOOT_TRACKER_SECONDS_LEFT"] = "剩余%d秒"
-- A roll called without GogoLoot. Argument: who called it.
L["LOOT_TRACKER_UNSYNCED_NOTE"] =
	"%s没有运行GogoLoot，所以这些是从聊天中看到的掷骰，按通常规则检查：1-100，仅限首次掷骰。最终由发起者决定。"
L["LOOT_TRACKER_ON_HOLD"] = "已暂停。请等待重新掷骰的通知。"
L["LOOT_TRACKER_TIE_BREAK_ROLLS"] = "平局重掷"
-- Arguments: the winner, then the winning roll.
L["LOOT_TRACKER_WON_WITH"] = "%s以%d点获胜"
L["LOOT_TRACKER_CLOSED"] = "已结束"
-- The sort buttons.
L["LOOT_TRACKER_SORT_HIGH"] = "最高"
L["LOOT_TRACKER_SORT_TIME"] = "按掷骰顺序"
L["LOOT_TRACKER_ROLL"] = "掷骰（1-100）"
-- Beside the player's own roll, and the line beside the Roll and Pass buttons.
L["LOOT_TRACKER_YOU"] = "你"
L["LOOT_TRACKER_YOU_ROLLED"] = "你掷出了%d。"
L["LOOT_TRACKER_YOU_PASSED"] = "你放弃了。"
L["LOOT_TRACKER_NOT_ROLLED"] = "你还没有掷骰。"
L["LOOT_TRACKER_NOT_IN_TIE_BREAK"] = "现在只有平局的玩家掷骰。"
L["LOOT_TRACKER_EARLIER"] = "今晚早些时候"
--[[
    The word, in lower case, that marks a group chat line with an item link as
    a call for rolls by someone without GogoLoot. "roll" is always read too.
]]
L["LOOT_TRACKER_ROLL_WORD"] = "掷骰"

-- Drops.
L["LOOT_TRACKER_SHOW_WINNERS"] = "显示谁拿了什么"
L["LOOT_TRACKER_DROPS_EMPTY"] =
	"还没有看到掉落。首领被击杀、尸体被拾取后，掉落会显示在这里。"
L["LOOT_TRACKER_DROPS_NOTHING_SEEN"] = "还没有装GogoLoot的人拾取过它。"
L["LOOT_TRACKER_NOT_HANDED_OUT"] = "尚未分配"
L["LOOT_TRACKER_PRINT"] = "显示"
L["LOOT_TRACKER_POST"] = "发到团队"
L["LOOT_TRACKER_COPY"] = "复制"
L["LOOT_TRACKER_COPY_TITLE"] = "按Ctrl+C复制"

-- Drops by boss, printed and copied.
L["DROPS_TRASH"] = "小怪"
L["DROPS_NONE"] = "尚未记录任何掉落。"
-- Argument: the instance.
L["DROPS_PRINT_HEADER"] = "%s的掉落："
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
	"通过掷骰分配仍可交易的物品，每件物品都显示交易倒计时，并在战利品追踪器中关注每一次掷骰。中键点击小地图按钮，或输入/gogo master或/gogo tracker。"
L["LOOT_MASTER_ENABLE"] = "启用战利品分配器"
L["LOOT_MASTER_ENABLE_DESCRIPTION"] =
	"追踪你仍可交易的战利品，并为其发起掷骰。关闭后，战利品分配器和战利品追踪器都不会打开，也不会读取任何掷骰。"
L["LOOT_MASTER_OPEN"] = "打开战利品分配器"
L["LOOT_TRACKER_OPEN"] = "打开战利品追踪器"
-- A dropdown choice. Argument: the number.
L["LOOT_MASTER_SECONDS"] = "%d秒"
L["LOOT_MASTER_MINUTES"] = "%d分钟"
L["LOOT_MASTER_KEEP_RAIDS"] = "%d"

L["LOOT_MASTER_CALLING_HEADER"] = "发起掷骰"
L["LOOT_MASTER_ROLL_LENGTH"] = "掷骰时长"
L["LOOT_MASTER_ROLL_LENGTH_DESCRIPTION"] = "一次掷骰保持开放的时间。"
L["LOOT_MASTER_ANNOUNCE_IN"] = "通报频道"
L["LOOT_MASTER_ANNOUNCE_IN_DESCRIPTION"] = "掷骰通知、平局和暂停发往何处。"
L["LOOT_MASTER_CHANNEL_GROUP"] = "队伍聊天"
L["LOOT_MASTER_ANNOUNCE_IN_NOTE"] =
	"你不是团长或助理时，团队通知会改发到队伍聊天。获胜者总是发到队伍聊天。"
-- Argument: the seconds.
L["LOOT_MASTER_WARN_LAST_SECONDS"] = "剩余%d秒时提醒"
L["LOOT_MASTER_WARN_LAST_SECONDS_DESCRIPTION"] = "掷骰即将结束时告知队伍。"
-- Argument: the seconds.
L["LOOT_MASTER_STRETCH_LATE"] = "有人迟掷时延长%d秒"
L["LOOT_MASTER_STRETCH_LATE_DESCRIPTION"] =
	"最后几秒内有人掷骰，会让掷骰多开放一会儿，以免有人因延迟被截断。"
L["LOOT_MASTER_END_EARLY"] = "所有人掷骰或放弃后提前结束"
L["LOOT_MASTER_END_EARLY_DESCRIPTION"] = "每位队员都掷骰或输入pass后，立即结束掷骰。"
L["LOOT_MASTER_REROLL_TIES"] = "平局玩家之间重掷"
L["LOOT_MASTER_REROLL_TIES_DESCRIPTION"] =
	'立即为平局玩家发起平局重掷。关闭后，平局会等待你按下"平局重掷"。'
L["LOOT_MASTER_ROLL_ALL_PAUSE"] = "全部掷骰的物品间隔"
L["LOOT_MASTER_ROLL_ALL_PAUSE_DESCRIPTION"] = "全部掷骰在一次掷骰结束后等待多久再发起下一次。"

L["LOOT_MASTER_COUNTING_HEADER"] = "有效掷骰"
-- Argument: the seconds of grace.
L["LOOT_MASTER_COUNTING_DESCRIPTION"] =
	"掷骰开放期间队伍成员的普通/roll（1-100），每人仅首次有效（为延迟留出%d秒宽限）。无效的掷骰会连同原因留在列表中。"
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED"] = "通报无效掷骰"
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED_DESCRIPTION"] =
	"掷骰结束时，用一行列出无效的掷骰及原因。你取消资格的掷骰总会通报。"

L["LOOT_MASTER_TRADE_HEADER"] = "可交易战利品"
L["LOOT_MASTER_OPEN_ON_TRADABLE"] = "拾取可交易物品时打开"
L["LOOT_MASTER_OPEN_ON_TRADABLE_DESCRIPTION"] =
	"你在队伍中时，若仍可交易的拾取后绑定战利品进入背包，就打开战利品分配器。"
L["LOOT_MASTER_TRADE_WARN"] = "交易时间不足时提醒我"
L["LOOT_MASTER_TRADE_WARN_DESCRIPTION"] =
	"掷骰列表中的物品即将变为灵魂绑定时，在聊天框中提醒你一次。"
L["LOOT_MASTER_TRADE_WARN_WHEN"] = "提醒时剩余的交易时间。"
L["LOOT_MASTER_TRADE_AUTO_FILL"] = "将赢得的物品放入交易窗口"
L["LOOT_MASTER_TRADE_AUTO_FILL_DESCRIPTION"] =
	'当你与获胜者开启交易时，自动放入其赢得的物品。你仍需点击"交易"。'

L["LOOT_MASTER_FLOOR_HEADER"] = "散件战利品"
L["LOOT_MASTER_FLOOR_PANEL_DESCRIPTION"] =
	'散件战利品初始为空，只包含你添加的物品。"从背包添加"会优先列出你在此副本中拾取的物品。'
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE"] = "物品离开背包后移除"
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE_DESCRIPTION"] =
	"当你身上不再有某件物品（已交易、出售或使用）时，将其从散件战利品中移除。"
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE"] = "离开团队时清空散件战利品"
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE_DESCRIPTION"] = "每次团队都从空的散件战利品列表开始。"

L["LOOT_TRACKER_OPEN_ON_ROLL"] = "有人发起掷骰时打开"
L["LOOT_TRACKER_OPEN_ON_ROLL_DESCRIPTION"] =
	"当队伍中有人通过GogoLoot或团队通知发起掷骰时，打开战利品追踪器。"
L["LOOT_TRACKER_AUTO_CLOSE"] = "掷骰结束后自动关闭"
L["LOOT_TRACKER_AUTO_CLOSE_DESCRIPTION"] =
	"自动打开的战利品追踪器会在掷骰结束30秒后关闭，除非鼠标悬停在上面。"
L["LOOT_TRACKER_KEEP_DROPS"] = "掉落记录保留的团队数"
L["LOOT_TRACKER_KEEP_DROPS_DESCRIPTION"] = "掉落标签页记住多少次团队。"
