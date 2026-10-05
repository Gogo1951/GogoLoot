local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "ruRU")
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
	"Версия %s. Настройки (в том числе отключение этого сообщения) находятся в меню Настройки > Модификации > GogoLoot. Нравится аддон? Расскажите о нем друзьям! (="
L["CHAT_OPTIONS_IN_COMBAT"] =
	"В целях безопасности окно настроек нельзя открыть в бою."
-- Argument: the game's own name for its Auto Loot setting.
L["MESSAGE_AUTO_LOOT_SETTING_ON"] =
	'Включена игровая настройка "%s", нужная для Быстрого сбора и Автооткрытия.'
-- Argument: the game's own word for Master Looter.
L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"] = 'Сейчас у вас нет роли "%s".'

-- Automated Opening. Argument: the number of free bag slots opening waits for.
L["MESSAGE_OPENING_PAUSED"] =
	"Автооткрытие приостановлено: свободных ячеек в сумках должно быть не меньше %d."
L["MESSAGE_OPENING_RESUMED"] = "Автооткрытие возобновлено."

-- Argument: the item's link.
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] = "%s откроется автоматически после взлома."
L["MESSAGE_ITEM_IGNORED"] =
	'%s: выбрано "Игнорировать", поэтому Автооткрытие его не трогает.'
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s: добыча с рейдового или мирового босса, поэтому Автооткрытие оставит его закрытым, чтобы его можно было передать или продать."
L["MESSAGE_ITEM_IGNORED_UNIQUE"] =
	"%s: может содержать уникальный предмет, поэтому Автооткрытие оставит его, чтобы вы открыли сами."
L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] =
	"%s: оставлено в окне добычи, чтобы вы забрали сами."
-- The Openables List's Add Item refusing gear or a bag. Argument: the item's link, or its ID while uncached.
L["MESSAGE_ITEM_NOT_OPENABLE"] =
	'%s: этот предмет надевается, а не открывается, поэтому его нельзя добавить в "Список контейнеров".'

-- Automated Rolls' Print Item in Chat. Arguments: the game's word for the roll (Need or Greed), then the item's link.
L["MESSAGE_ROLL_PRINT"] = 'Вы выбрали "%s" для предмета %s.'
-- The same after a Pass. Argument: the item's link.
L["MESSAGE_ROLL_PASS_PRINT"] = "Вы отказались от предмета %s."
--[[
    Hide Roll Messages' winner summary. Arguments: the winner, the item's link,
    then the winning roll as LOOT_TOASTS_ROLL_RESULT words it ("Greed 95"). The
    NO_ROLL forms are for a win whose roll wasn't seen; the YOU forms for the
    player's own win, without the winner.
]]
L["MESSAGE_ROLL_WON_PRINT"] = "%s выигрывает %s (%s)."
L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"] = "%s выигрывает %s."
L["MESSAGE_ROLL_YOU_WON_PRINT"] = "Вы выиграли %s (%s)."
L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"] = "Вы выиграли %s."

--[[
    A trade summary printed to the player alone (the trade Channel's Me Only):
    the Chat Announcement Templates below, printed, so each ends on its
    punctuation. Arguments as theirs: items, then the partner, then what came
    back.
]]
L["MESSAGE_GAVE_PRINT"] = "Передано %s игроку %s."
L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "Передано %s игроку %s, получено %s."
L["MESSAGE_TRADE_RECEIVED_PRINT"] = "Получено %s от игрока %s."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "Передано %s игроку %s"
L["MESSAGE_DESTINATION_SET"] = "%s хранит для группы предметы качества: %s"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s хранит для группы всю добычу"
-- Arguments: the player who left, the master looter, then the qualities they held, joined by commas.
L["MESSAGE_DESTINATION_LEFT"] =
	"%s больше не в группе. Теперь %s хранит для группы предметы качества: %s"
-- The same when they held every quality. Arguments: the player who left, then the master looter.
L["MESSAGE_DESTINATION_LEFT_ALL"] =
	"%s больше не в группе. Теперь %s хранит для группы всю добычу"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Передано %s игроку %s, получено %s"
L["MESSAGE_TRADE_RECEIVED"] = "Получено %s от игрока %s"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "Сумки игрока %s заполнены: %s"
L["ERROR_MAX_COUNT"] = "У игрока %s уже слишком много: %s"
L["ERROR_OUT_OF_RANGE"] = "Игрок %s слишком далеко: %s"
L["ERROR_NOT_IN_GROUP"] = "Игрок %s уже не в группе или рейде: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "Не удалось передать добычу игроку %s: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_AUTOMATED_ROLLS"] = "Автоброски"
L["TAB_ITEM_OVERRIDES"] = "Особые предметы"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "Правила персонажей"
-- The panel for everything GogoLoot posts to chat.
L["TAB_ANNOUNCEMENTS"] = "Оповещения"
-- Headers of the two sections on the Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Оповещения об обмене"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Оповещения ответственного"
L["TAB_LOOT_TOASTS"] = "Уведомления о добыче"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Фильтры"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Звуки добычи"
L["TAB_AUTOMATED_OPENING"] = "Автооткрытие"
-- Header of a section on the Automated Opening panel.
L["TAB_LOCKBOXES"] = "Запертые ящики"
L["TAB_OPENABLE_ITEMS"] = "Список контейнеров"
L["TAB_MASTER_LOOTER"] = "Ответственный за добычу"
-- Header of a section on the Master Looter panel.
L["TAB_LOOT_DESTINATIONS"] = "Получатели добычи"
L["TAB_IGNORE_LIST"] = "Список исключений"

-- A child panel's title where the Settings tree can't nest it: the parent's title, then its own.
L["TAB_NESTED_FORMAT"] = "%s: %s"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Включено"
L["STATUS_DISABLED"] = "Отключено"
-- Automated Opening is on but waiting for empty bag slots.
L["STATUS_PAUSED"] = "Приостановлено"

--[[
    The tooltip titles each feature with its options-panel name (Automated
    Master Looting excepted, since its panel is titled Master Looter), and
    gives each a description of its own, two lines at most: the panels' longer
    text doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] =
	"Бросает кубики за вас на подходящие предметы вплоть до выбранного качества."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] =
	"Открывает моллюсков, ящики, кошельки и взломанные запертые ящики в сумках."
L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"] =
	"Публикует в чате итоги обменов и раздачу добычи."
L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"] =
	"Раздает добычу игрокам, выбранным для каждого качества."
--[[
    The tooltip's read-back of each group context's roll, one line each under
    the description. Arguments: the game's own word for Party or Raid, the roll,
    then (all but Manual) the highest quality it rolls on.
]]
L["MINIMAP_ROLLS_SETTING"] = "%s: %s, %s"
L["MINIMAP_ROLLS_SETTING_MANUAL"] = "%s: %s"

L["MINIMAP_LEFT_CLICK"] = "Левый клик"
L["MINIMAP_RIGHT_CLICK"] = "Правый клик"
L["MINIMAP_SHIFT_LEFT_CLICK"] = "Shift + левый клик"
L["MINIMAP_SHIFT_RIGHT_CLICK"] = "Shift + правый клик"
-- The tooltip's title for the Automated Master Looting block, the feature its switch names.
L["MINIMAP_AUTOMATED_MASTER_LOOTING"] = "Автораздача"
L["MINIMAP_TOGGLE"] = "Переключить"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Запертые предметы"
L["MINIMAP_OPTIONS"] = "Настройки GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + средний клик"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Вручную"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "Только %s"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s и ниже"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List brings text of its own), the hint the box shows while empty,
    and its button.
]]
L["ITEM_LIST_ADD"] = "Добавить предмет"
L["ITEM_LIST_ADD_DESCRIPTION"] =
	"Введите ID предмета или перетащите предмет сюда, чтобы добавить его в список."
L["ITEM_LIST_ADD_PLACEHOLDER"] = "Перетащите предмет или введите ID"
L["ITEM_LIST_ADD_BUTTON"] = "Добавить"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "Фильтр предметов..."
L["ITEM_LIST_FILTER_DESCRIPTION"] =
	"Показывает только предметы, чье название, ID, настройка или метка содержат введенный текст."
L["ITEM_LIST_NO_MATCHES"] = "Нет предметов, подходящих под фильтр."

-- The header over what the player just added to an item list, at its top until they filter it or close the window.
L["ITEM_LIST_NEW"] = "Новые"

-- The kind filter beside every item list's search box: its first choice (the rest are the list's headers) and its tooltip.
L["ITEM_LIST_KIND_ALL"] = "Все виды предметов"
L["ITEM_LIST_KIND_DESCRIPTION"] =
	"Показывает все предметы из списка или только предметы одного вида."

--[[
    The Add from Bags dropdown beside every item list's add box: its resting
    text and tooltip, then what it reads, greyed out, when everything carried
    is already on the list. The Openables List brings a tooltip of its own.
]]
L["ITEM_LIST_ADD_FROM_BAGS"] = "Добавить из сумок"
L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"] =
	"Добавляет в список предмет из ваших сумок."
L["ITEM_LIST_BAGS_EMPTY"] = "В сумках нечего добавить"
L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"] =
	"Все предметы из ваших сумок уже есть в списке."

-- The button at the foot of every item list; each list's tooltip and confirmation say what it restores.
L["ITEM_LIST_RESTORE"] = "Восстановить по умолчанию"

-- Placeholder shown in the item lists until the client caches an item's info.
L["ITEM_LOADING"] = "Загрузка... (ID: %d)"

--[[
    Appended to the Automated Rolls description. Item Overrides is the one way
    a Bind on Pickup or quest item gets rolled on; nothing ever rolls on the
    rest.
]]
L["SAFETY_SKIP_NOTE"] =
	'Никогда не бросает на рецепты, книги, транспорт, питомцев и легендарные предметы, а на предметы, персональные при поднятии, и предметы для заданий бросает, только если они есть в списке "Особые предметы".'

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] =
	"Рецепты, книги, транспорт, питомцы и легендарные предметы всегда остаются вам."

--[[
    Shown under each announcement's toggle, under Print Item in Chat and Hide
    Roll Messages, and under Enable Ignore Notifications. Argument: the
    message, as GogoLoot sends or prints it.
]]
L["OPTIONS_EXAMPLE"] = "Пример: %s"

-- The muted version line at the foot of the General panel.
L["OPTIONS_VERSION"] = "Версия %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Быстрый сбор опустошает трупы в мгновение ока, Автоброски и Автораздача решают, кому что достанется, а Автооткрытие вскрывает каждого моллюска и каждый ящик. Уведомления о добыче покажут все, а предметы для заданий, рецепты, транспорт, питомцы и легендарные предметы останутся в сохранности. Пусть добыча вас не тормозит!"
L["WELCOME_MESSAGE"] = "Включить приветствие"
L["WELCOME_MESSAGE_DESCRIPTION"] =
	"При каждом входе в игру показывает версию GogoLoot и где найти эти настройки."
L["MINIMAP_BUTTON_ENABLE"] = "Включить кнопку у миникарты"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Показывает кнопку GogoLoot у миникарты. Левый клик включает и выключает Автоброски, правый клик делает то же с Автооткрытием, Shift + левый клик с оповещениями, а Shift + правый клик с Автораздачей."

L["OPTIONS_COMMANDS_HEADER"] = "/Команды"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Открывает окно настроек этого аддона."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Функции"

L["SPEEDY_LOOT_ENABLE"] = "Включить Быстрый сбор"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	'Забирает всю добычу с трупа сразу, не показывая окно добычи. Удерживайте Shift при сборе, чтобы увидеть окно. Включает игровую настройку "%s" и не срабатывает, пока у вас роль "%s".'

L["FEEDBACK_SUPPORT"] = "Отзывы и поддержка"

-- CurseForge / GitHub / Discord / Wago are proper nouns; do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "Настройки добычи группы"
L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"] =
	"Определяет, как делится добыча вашей группы. Изменить это может только лидер группы."
L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"] =
	"Задает самое низкое качество предметов, к которому применяется способ дележа. Изменить его может только лидер группы."

--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them, including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "Этими настройками управляет: %s."
-- Shown in the same place while solo, where the two dropdowns are greyed out.
L["MASTER_LOOTER_SOLO_NOTE"] =
	"Вступите в группу, чтобы изменить эти настройки. Изменить их может только лидер группы."

-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"] =
	'Сразу при открытии окна добычи отдает каждый предмет игроку, выбранному для его качества, пока у вас роль "%s".'
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "Включить Автораздачу"
L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"] =
	'Включает и выключает автоматическую раздачу. Она работает только в подземельях и рейдах, если не включена опция "Также вне подземелий".'
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Также вне подземелий"
L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Раздает добычу и в открытом мире. Добычу с мировых боссов нельзя передать, поэтому это не рекомендуется."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "Включая предметы для заданий"
L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"] =
	'Раздает и предметы для заданий, чтобы прокачивать персонажа, за которого вы играете сами. Работает только при пороге качества "Обычное" или ниже и только для предметов, которые выпадают один раз на всю группу. Не рекомендуется в рейдах.'

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Быстрые настройки"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_POPUP_TOOLTIP"] =
	'Открывает эти настройки в отдельном окне, когда вы получаете роль "%s".'
L["MASTER_LOOTER_POPUP_ENABLE"] = "Включить окно ответственного"

L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"Выберите, кто получает предметы каждого качества. Если для качества никто не выбран, предметы остаются вам в окне добычи."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Себе"
-- The first choice in every destination dropdown: nobody picked, so that quality waits in the loot window.
L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"] = "Окно добычи"
L["MASTER_LOOTER_SEND_ALL"] = "Вся добыча игроку"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] =
	"Назначает одного игрока для всех качеств ниже."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] =
	"Выбирает, кто получает предметы качества: %s."
-- Shown under Loot Destinations while Automated Master Looting is on and no quality has anybody picked.
L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] =
	"Никто еще не выбран, поэтому вся добыча ждет вас в окне добычи."

L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Предметы из этого списка никогда не раздаются автоматически. Они ждут в окне добычи, чтобы вы раздали их сами."
-- Shown on the Ignore List while Automated Master Looting is off.
L["MASTER_LOOTER_OFF_NOTE"] =
	"Пока Автораздача выключена, эти настройки не используются."
L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"] =
	"Заменяет Список исключений стандартными предметами для вашего дополнения."
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"Ваш Список исключений будет заменен стандартными предметами для вашего дополнения. Продолжить?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] =
	"Удаляет этот предмет из Списка исключений."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_PANEL_DESCRIPTION"] =
	'Выбирает за вас "%s", "%s" или "%s" для групповой добычи, вплоть до выбранного качества, с отдельными настройками для группы и рейда.'
L["ROLLS_ENABLE"] = "Включить Автоброски"
L["ROLLS_ENABLE_DESCRIPTION"] =
	"Включает и выключает автоматические броски, в том числе Особые предметы и Правила персонажей."
L["ROLLS_IN_PARTY"] = "В группе"
L["ROLLS_IN_RAID"] = "В рейде"
-- The caption of the quality row under In Party and under In Raid, shown while that roll isn't Manual.
L["ROLLS_UP_TO_QUALITY"] = "До качества"
L["ROLLS_THRESHOLD_CHOOSE"] =
	"%s: самое высокое качество, на которое бросает GogoLoot."
L["ROLLS_ACTION_CHOOSE"] =
	'%s: какой бросок делает GogoLoot. "Вручную" оставляет бросок вам.'
-- Section headers on the Automated Rolls panel.
L["ROLLS_LOOT_THRESHOLDS_HEADER"] = "Пороги добычи"
L["ROLLS_MESSAGES_HEADER"] = "Сообщения о бросках"
L["ROLLS_PRINT_ITEM"] = "Выводить предмет в чат"
L["ROLLS_PRINT_ITEM_DESCRIPTION"] =
	"Выводит в ваш чат каждый предмет, на который бросает GogoLoot, и сделанный бросок. Окно розыгрыша закрывается сразу после броска GogoLoot, так что по этой записи видно, что выпадало."
L["ROLLS_HIDE_MESSAGES"] = "Скрывать сообщения о бросках"
-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_HIDE_MESSAGES_TOOLTIP"] =
	'Скрывает игровые строки чата о каждом броске: кто выбрал "%s", "%s" или "%s" и какие числа выпали. Что получил каждый победитель, по-прежнему видно в чате.'
-- The dropdown beside Hide Roll Messages.
L["ROLLS_WINNER_SUMMARY_PRINT"] = "Выводить итоги розыгрыша"
L["ROLLS_WINNER_SUMMARY_NONE"] = "Не выводить итоги розыгрыша"
L["ROLLS_WINNER_SUMMARY_DESCRIPTION"] =
	'"Выводить итоги розыгрыша" выводит в чат одну строку на каждую победу с победителем, предметом и победным броском вместо игровой строки. "Не выводить итоги розыгрыша" оставляет игровую строку о том, кто выиграл.'

--[[
    Item Overrides, under Automated Rolls: items with a roll action of their
    own.
]]
L["ITEM_OVERRIDES_DESCRIPTION"] =
	"Задает бросок для отдельных предметов в обход настроек качества. Только так GogoLoot будет бросать на предметы, персональные при поднятии, и на предметы для заданий."
-- Shown on Item Overrides while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] =
	"Пока Автоброски выключены, эти настройки не используются."
L["ITEM_OVERRIDES_ENABLE"] = "Включить Особые предметы"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"Использует броски, заданные ниже. Если выключено, эти предметы следуют настройкам качества, как и все остальные."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] =
	"Заменяет ваши Особые предметы стандартными предметами для вашего дополнения."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"Ваши Особые предметы будут заменены стандартными предметами для вашего дополнения. Продолжить?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] =
	"Задает автоматический бросок для этого предмета."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "Удаляет этот предмет из Особых предметов."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] =
	"Удалить этот предмет и его бросок из Особых предметов?"

--[[
    Character Rules, under Automated Rolls: the stats whose gear each
    character leaves to the player. The stat names come from the game's own
    strings.
]]
-- Arguments: the game's own name for Intellect, then for the Warrior class, then Intellect again.
L["CHARACTER_RULES_PANEL_DESCRIPTION"] =
	'Оставляет вам снаряжение с выбранными характеристиками, отдельно для каждого персонажа: выберите "Вручную" для характеристики "%s" у персонажа класса "%s", и для снаряжения с характеристикой "%s" будет открываться окно розыгрыша, а на все остальное броски пойдут как обычно. Особые предметы по-прежнему имеют приоритет.'
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "Основные характеристики"
L["CHARACTER_RULES_SECONDARY"] = "Вторичные характеристики"
-- The first of the two choices in each stat's dropdown: no rule, so the rest of Automated Rolls decides.
L["CHARACTER_RULES_STANDARD"] = "Стандартный автобросок"
L["CHARACTER_RULES_ACTION_DESCRIPTION"] =
	'%s: "Вручную" оставляет вам снаряжение с этой характеристикой на этом персонаже вместе с окном розыгрыша. "Стандартный автобросок" бросает на него, как на любой другой предмет.'

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"Публикует в чате итоги обменов и раздачу добычи, чтобы все знали, куда ушла добыча."
L["ANNOUNCEMENTS_ENABLE"] = "Включить оповещения"
-- Also the tooltip of the same switch in the General panel's Features section, so it names no position on the panel.
L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"] =
	"Включает и выключает все оповещения. Когда они выключены, GogoLoot ничего не отправляет ни группе, ни партнерам по обмену, даже о предметах, которые вы раздаете сами."

-- Trade Announcements
L["TRADE_DESCRIPTION"] =
	"Публикует итоги каждого завершенного обмена: предметы, чары и золото."
L["TRADE_ENABLE"] = "Включить оповещения об обмене"
L["TRADE_ENABLE_DESCRIPTION"] =
	'Публикует итоги, когда обмен завершен. Флажок "Оповестить" в окне обмена управляет этой же настройкой.'
L["TRADE_CONDITION_DESCRIPTION"] =
	"Когда публиковать итоги обмена: всегда, в группе или рейде, или только в рейде."
L["TRADE_CONDITION_ALWAYS"] = "Всегда"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "В группе или рейде"
L["TRADE_CONDITION_RAID_ONLY"] = "В рейде"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "Канал"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	'"%s" отправляет итоги партнеру по обмену. "Чат группы" публикует их в группе или рейде, а вне группы все равно отправляет шепотом. "Только мне" выводит их только в ваш чат и никому не отправляет.'
-- The Channel dropdown's choices (Whisper is the client's WHISPER), and the trade window checkbox tooltip's Channel value.
L["TRADE_OUTPUT_GROUP"] = "Чат группы"
L["TRADE_OUTPUT_SELF"] = "Только мне"
L["TRADE_TOOLTIP_DESCRIPTION"] =
	"Публикует итоги в чате, когда этот обмен завершится."
L["TRADE_CHECKBOX_LABEL"] = "Оповестить"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] =
	"Сообщает группе, кто хранит предметы каждого качества и что вы раздали."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Включить оповещения о получателях"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"] =
	"Сообщает группе, кто хранит предметы каждого качества, всякий раз, когда вы назначаете получателя."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] =
	"Включить оповещения об автоматической раздаче"
L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"] =
	"Сообщает о каждом предмете, который GogoLoot раздает автоматически, начиная с выбранного качества."
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"] =
	"Об автоматической раздаче предметов ниже этого качества не сообщается."

L["MASTER_LOOTER_ANNOUNCE_MANUAL"] = "Включить оповещения о ручной раздаче"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"] =
	'Сообщает о каждом предмете любого качества, который вы раздаете сами через меню "%s", той же строкой, что и при автоматической раздаче. О неудачной раздаче сообщается в любом случае.'

--------------------------------------------------------------------------------
-- Options: Loot Toasts and Loot Sounds
--------------------------------------------------------------------------------

-- Argument: the game's own name for the General chat tab.
L["LOOT_TOASTS_PANEL_DESCRIPTION"] =
	'На несколько секунд показывает на экране каждый предмет и каждую монету, которые вы подбираете, чтобы ничего не упустить, пока Быстрый сбор скрывает окно добычи. Пока уведомления включены, игровые строки о добыче можно убрать из вкладки чата "%s".'
L["LOOT_TOASTS_ENABLE"] = "Включить уведомления о добыче"
-- Also the tooltip of the same switch in the General panel's Features section.
L["LOOT_TOASTS_SWITCH_DESCRIPTION"] =
	'Показывает уведомления о добыче, выбранной в разделе "Фильтры", вашей и вашей группы.'
-- The dropdown beside Enable Loot Toasts: the game's Item Loot and Money Loot chat settings for the General tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"] =
	"Отключить стандартные сообщения о добыче"
L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"] = "Включить стандартные сообщения о добыче"
-- Arguments: the game's own names for its Item Loot and Money Loot chat settings, then for the General chat tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"] =
	'"Отключить стандартные сообщения о добыче" выключает "%s" и "%s" во вкладке чата "%s", пока уведомления о добыче включены, а при выключении уведомлений они возвращаются. Это та же настройка, что и в параметрах этой вкладки, а у других вкладок свои настройки.'

-- The Loot Toasts panel's two section headers.
L["LOOT_TOASTS_STACK_HEADER"] = "Стопка"
L["LOOT_TOASTS_TEXT_HEADER"] = "Текст"

--[[
    Filters: a row per item type, captioned with the game's own name for it,
    each with a Mine box and a Group box. Weapon, Armor, Trade Goods and Gem
    carry a quality dropdown beside each ticked box. Argument in each tooltip:
    the row's item type, as the client names it.
]]
-- Shown on the Filters panel while Loot Toasts is off.
L["LOOT_TOASTS_OFF_NOTE"] =
	"Пока уведомления о добыче выключены, эти настройки не используются."
-- The Filters panel's description.
L["LOOT_TOASTS_FILTERS_CAPTION"] =
	"Выберите, какая добыча получает уведомление и что в нем написано, для вашей добычи и добычи группы. Рядом с добычей группы показывается имя подобравшего."
L["LOOT_TOASTS_FILTER_MINE"] = "Мое"
L["LOOT_TOASTS_FILTER_GROUP"] = "Группа"
L["LOOT_TOASTS_FILTER_MINE_DESCRIPTION"] =
	'Показывает подбираемые вами предметы типа "%s".'
L["LOOT_TOASTS_FILTER_GROUP_DESCRIPTION"] =
	'Показывает предметы типа "%s", которые подбирает любой участник группы или рейда, с именем подобравшего.'
L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"] =
	'Показывает подбираемые вами предметы типа "%s" не ниже качества, выбранного рядом.'
L["LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION"] =
	'Показывает предметы типа "%s" не ниже качества, выбранного рядом, которые подбирает любой участник группы или рейда, с именем подобравшего.'
L["LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION"] =
	'Самое низкое качество подбираемых вами предметов типа "%s", для которого показывается уведомление.'
L["LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION"] =
	'Самое низкое качество подбираемых группой предметов типа "%s", для которого показывается уведомление.'

-- The three Filters rows after the item types, which aren't item types themselves: their captions (Money's is the client's MONEY) and their boxes' tooltips.
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP"] = "Персональные при поднятии"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION"] =
	"Показывает каждый подбираемый вами предмет, персональный при поднятии, любого типа и качества."
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION"] =
	"Показывает каждый подбираемый группой предмет, персональный при поднятии, любого типа и качества."
L["LOOT_TOASTS_FILTER_OPENABLES"] = "Открываемые предметы"
L["LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION"] =
	"Показывает подбираемые вами контейнеры, которые GogoLoot может открыть, включая запертые ящики, любого качества."
L["LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION"] =
	"Показывает подбираемые группой контейнеры, которые GogoLoot может открыть, включая запертые ящики, любого качества."
L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"] =
	'Показывает уведомление о подобранных вами монетах. Игра не сообщает о деньгах других игроков, поэтому флажка "Группа" нет.'

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast it follows the item
    (LOOT_TOASTS_WON_ROLL); on a group member's, their name
    (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Победный бросок"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"Добавляет к уведомлению бросок, которым вы выиграли предмет, например (%s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Добавляет к уведомлению участника группы бросок, которым он выиграл предмет, например (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_WON_ROLL"] = "%s (%s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Количество в сумках"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Добавляет к уведомлениям о вашей добыче, сколько таких предметов у вас теперь с собой, например x3 (27), если их больше, чем указано в самом уведомлении."
-- How many came, after the item on a toast. Argument: the count.
L["LOOT_TOASTS_QUANTITY"] = "x%d"
-- Bag Count, after the item and its count. Argument: how many the player carries.
L["LOOT_TOASTS_BAG_COUNT"] = "(%d)"

-- Stack
L["LOOT_TOASTS_MAX_ITEMS"] = "Максимум уведомлений"
L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"] =
	"Сколько уведомлений может быть на экране одновременно; самое старое исчезает, освобождая место."
L["LOOT_TOASTS_UNLIMITED"] = "Без ограничений"
L["LOOT_TOASTS_DURATION"] = "Секунд на экране"
L["LOOT_TOASTS_DURATION_DESCRIPTION"] =
	"Сколько секунд каждое уведомление остается на экране, прежде чем исчезнуть."
L["LOOT_TOASTS_GROWTH"] = "Направление"
L["LOOT_TOASTS_GROWTH_DESCRIPTION"] =
	"Куда сдвигаются старые уведомления, прочь от самого нового: вверх или вниз."
L["LOOT_TOASTS_GROW_UP"] = "Вверх"
L["LOOT_TOASTS_GROW_DOWN"] = "Вниз"
L["LOOT_TOASTS_ALIGN"] = "Выравнивание"
L["LOOT_TOASTS_ALIGN_DESCRIPTION"] =
	"По какой стороне рамки выравниваются уведомления."
L["LOOT_TOASTS_ALIGN_LEFT"] = "Слева"
L["LOOT_TOASTS_ALIGN_RIGHT"] = "Справа"

-- Text
L["LOOT_TOASTS_FONT"] = "Шрифт"
L["LOOT_TOASTS_FONT_DESCRIPTION"] = "Шрифт текста уведомлений."
L["LOOT_TOASTS_FONT_DEFAULT"] = "По умолчанию"
L["LOOT_TOASTS_FONT_SIZE"] = "Размер шрифта"
L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"] =
	"Размер текста уведомлений; значки увеличиваются и уменьшаются вместе с ним."
L["LOOT_TOASTS_OUTLINE"] = "Контур шрифта"
L["LOOT_TOASTS_OUTLINE_DESCRIPTION"] =
	"Контур вокруг текста уведомлений, благодаря которому его легко читать на ярком фоне."
L["LOOT_TOASTS_OUTLINE_NONE"] = "Нет"
L["LOOT_TOASTS_OUTLINE_OUTLINE"] = "Контур"
L["LOOT_TOASTS_OUTLINE_THICK"] = "Толстый контур"
L["LOOT_TOASTS_OUTLINE_MONOCHROME"] = "Монохромный"
L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"] = "Монохромный контур"

-- Position
L["LOOT_TOASTS_UNLOCK"] = "Разблокировать позицию"
L["LOOT_TOASTS_LOCK"] = "Заблокировать позицию"
L["LOOT_TOASTS_RESET"] = "Сбросить позицию"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] =
	"Показывает или скрывает рамку, за которую уведомления можно перетащить на новое место."
L["LOOT_TOASTS_RESET_DESCRIPTION"] =
	"Возвращает уведомления на исходное место над центром экрана."

-- The drag handle: its title, the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_HANDLE_TITLE"] = "Уведомления о добыче GogoLoot"
L["LOOT_TOASTS_CLICK_DRAG"] = "Зажмите и перетащите, чтобы переместить"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "Правый клик, чтобы заблокировать"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "Отключить уведомления о добыче"
-- The stand-in item on the sample toasts, and in every Example line.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "Пример предмета"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"Проигрывает сигнал при добыче выбранного качества или выше и звук сумки, когда %s приносит добычу."
L["LOOT_SOUNDS_ENABLE"] = "Включить звук добычи"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Проигрывает сигнал, когда вы забираете с трупа или из сундука предмет выбранного качества или выше."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] =
	"Самое низкое качество предмета, для которого проигрывается звук добычи."
L["LOOT_SOUNDS_TEST"] = "Проигрывает звук добычи."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "Включить звук: %s"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] =
	"Проигрывает звук сумки, когда %s действительно что-то приносит."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "Проигрывает звук: %s."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"Открывает за вас моллюсков, ящики, кошельки и взломанные запертые ящики в сумках, когда свободных ячеек в сумках не меньше %d."
L["AUTOMATED_OPENING_ENABLE"] = "Включить Автооткрытие"
-- Also the tooltip of the same switch in the General panel's Features section. Argument: the game's own name for its Auto Loot setting.
L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"] =
	'Открывает по одному контейнеру за раз и ждет, пока вы в бою, произносите заклинание, в незаметности или пока открыто окно торговца, банка, почты, аукциона или обмена. Пока включено, включает игровую настройку "%s".'
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"] = "Только вне подземелий"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Ничего не открывает, пока вы в подземелье, рейде или на поле боя."
L["AUTOMATED_OPENING_ONLY_SOLO"] = "Только в одиночку"
L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"] =
	"Ничего не открывает, пока вы в группе или рейде."

-- Lockboxes
-- Arguments: the game's own name for the Rogue class, then for the Lockpicking skill.
L["LOCKBOXES_SECTION_DESCRIPTION"] =
	'Запертый ящик не откроется, пока его не взломает %s. Подсказки показывают уровень навыка "%s", нужный для каждого ящика, а оповещения сообщают, когда ящик ждет взлома.'
L["LOCKBOXES_TOOLTIPS_ENABLE"] = "Включить подсказки запертых ящиков"
-- Argument: the game's own name for the Lockpicking skill.
L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"] =
	'Добавляет в подсказку каждого запертого ящика нужный уровень навыка "%s".'
L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"] =
	"Показывать подсказки запертых ящиков только разбойникам или всем персонажам."
L["LOCKBOXES_NOTIFICATIONS_ENABLE"] = "Включить оповещения о запертых ящиках"
L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Сообщает в чате, когда вы получаете запертый ящик, который откроется после взлома."
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] =
	"Показывать оповещения о запертых ящиках только разбойникам или всем персонажам."
L["LOCKBOXES_FOR_ROGUES"] = "Для разбойников"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "Для всех персонажей"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking" line (ITEM_REQ_SKILL), followed by a skill number. Argument:
    the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "Ваш навык: %s"

-- On the Automated Opening panel, below its switch.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "Включить оповещения об игнорировании"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	'Сообщает в чате, когда GogoLoot не трогает контейнер, потому что в Списке контейнеров выбрано "Игнорировать", и почему.'

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	'Все контейнеры, которые знает GogoLoot, и что с ними делает Автооткрытие. "Игнорировать" оставляет контейнер закрытым, а Быстрый сбор оставляет его вам в окне добычи. Изменения действуют для всех ваших персонажей.'
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] =
	'Пока Автооткрытие выключено, используется только "Игнорировать": оно по-прежнему не дает Быстрому сбору забирать эти предметы.'
L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"] =
	"Возвращает список к исходному виду: у каждого предмета восстанавливается настройка по умолчанию, удаленные предметы возвращаются, а добавленные удаляются."
L["OPENABLE_ITEMS_RESTORE_CONFIRM"] =
	"Вернуть список к исходному виду? Все измененные настройки, а также добавленные и удаленные предметы будут отменены."
L["OPENABLE_ITEMS_ADD_DESCRIPTION"] =
	'Введите ID предмета или перетащите предмет сюда, чтобы добавить его в список с настройкой "Открывать". Снаряжение и сумки добавить нельзя: при использовании они надеваются.'
L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"] =
	'Добавляет в список предмет из ваших сумок с настройкой "Открывать". Снаряжение и сумки не предлагаются: при использовании они надеваются.'
L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"] =
	"Удаляет этот предмет из списка. После этого GogoLoot считает его обычным предметом: никогда не открывает и собирает как любой другой."
L["OPENABLE_ITEMS_REMOVE_CONFIRM"] =
	"Удалить этот предмет из списка? Чтобы вернуть его, добавьте его снова."
L["OPENABLE_ITEMS_ACTION_DESCRIPTION"] =
	"Задает, что Автооткрытие делает с этим контейнером."

-- The Openables List dropdown, one per item.
L["OPENING_ACTION_OPEN"] = "Открывать"
L["OPENING_ACTION_IGNORE"] = "Игнорировать"

--[[
    The reason an item's default carries, shown as a short silver tag on its
    Openables List row whatever it is set to. Sell Sealed covers both a raid
    boss drop and a container that can hold Bind on Pickup loot.
]]
L["OPENING_TAG_SEALED"] = "Продать закрытым"
L["OPENING_TAG_UNIQUE"] = "Возможен уникальный"

--[[
    Each tag explained, under the item's tooltip on the Openables List. The
    item's own tooltip is directly above, so these never name the item.
]]
-- Argument: the game's own name for the Rogue class.
L["OPENING_REASON_LOCKED_CLASS"] =
	"Его должен взломать %s. После взлома он открывается, как любой другой контейнер."
L["OPENING_REASON_RAID"] =
	"Добыча с рейдового или мирового босса. Неоткрытый контейнер можно передать или продать, часто дороже его содержимого."
L["OPENING_REASON_BIND_ON_PICKUP"] =
	"Может содержать предметы, персональные при поднятии. Закрытым его еще можно передать или продать."
L["OPENING_REASON_UNIQUE"] =
	"Может содержать уникальный предмет. Если такой у вас уже есть, открытие завершится ошибкой."
