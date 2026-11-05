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

-- The Full Name: leads every printed line, and names the options panels, window titles and the mini-map header. A proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
-- The Short Name: closes every sent message and names the add-on on tooltip lines other than the mini-map header. A proper noun; keep it untranslated.
L["ADDON_SHORT_NAME"] = "GogoLoot"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Версия %s. Настройки (в том числе отключение этого сообщения) находятся в меню Настройки > Модификации > GogoLoot. Нравится аддон? Расскажите о нем друзьям, добавьте его в избранное на CurseForge или поставьте звезду на GitHub. (="
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
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] =
	"%s откроется автоматически, как только его отопрут."
L["MESSAGE_ITEM_IGNORED"] =
	'%s: выбрано "Игнорировать", поэтому Автооткрытие его не трогает.'
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s: добыча с рейдового или мирового босса, поэтому Автооткрытие оставит его закрытым, чтобы его можно было передать или продать."
L["MESSAGE_ITEM_IGNORED_UNIQUE"] =
	"%s: может содержать уникальный предмет, поэтому Автооткрытие оставит его, чтобы вы открыли сами."
L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] =
	"%s: оставлено в окне добычи, чтобы вы забрали сами."
L["MESSAGE_LOOT_LEFT_ON_CORPSE"] = "%s Часть добычи осталась на трупе."
--[[
    Standard Loot Messages taking the General tab's loot lines off, or putting
    them back. Arguments: the game's own names for its Item Loot and Money Loot
    chat settings, then for the General chat tab.
]]
L["MESSAGE_STANDARD_LOOT_MESSAGES_OFF"] =
	'Отключены "%s" и "%s" во вкладке чата "%s", пока уведомления о добыче включены.'
L["MESSAGE_STANDARD_LOOT_MESSAGES_ON"] = 'Снова включены "%s" и "%s" во вкладке чата "%s".'

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

-- The first feature panel, holding the one Speedy Loot switch.
L["TAB_SPEEDY_LOOT"] = "Быстрый сбор"
L["TAB_AUTOMATED_ROLLS"] = "Автоброски"
L["TAB_ITEM_OVERRIDES"] = "Особые предметы"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "Правила персонажей"
-- The panel for everything GogoLoot posts to chat; also its row in the mini-map button's tooltip.
L["TAB_ANNOUNCEMENTS"] = "Оповещения о добыче"
-- Headers of the two sections on the Loot Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Оповещения об обмене"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Оповещения ответственного"
L["TAB_LOOT_TOASTS"] = "Уведомления о добыче"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Фильтры"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Звуки добычи"
L["TAB_AUTOMATED_OPENING"] = "Автооткрытие"
-- A child panel of Automated Opening, beside the Openables List.
L["TAB_LOCKBOXES"] = "Запертые ящики"
L["TAB_OPENABLE_ITEMS"] = "Список контейнеров"
-- Named for its switch, Enable Automated Master Looting. Roll Macro follows it.
L["TAB_MASTER_LOOTER"] = "Автораздача"
-- Header of a section on the Automated Master Looting panel.
L["TAB_LOOT_DESTINATIONS"] = "Получатели добычи"
L["TAB_IGNORE_LIST"] = "Список исключений"
-- The panel after Automated Master Looting, named for its switch, Enable Roll Macro.
L["TAB_ROLL_MACRO"] = "Макрос бросков"
-- The panel after Roll Macro, for the Loot Master and Loot Tracker windows; also the Loot Master window's title.
L["TAB_LOOT_MASTER"] = "Распорядитель добычи"

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
    The tooltip titles each feature with its options-panel name, and gives
    each a description of its own, two lines at most: the panels' longer text
    doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] =
	"Бросает кубики за вас на подходящие предметы вплоть до выбранного качества."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] =
	"Открывает в сумках моллюсков, ящики, кошельки, а также запертые ящики, как только их отопрут."
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
L["MINIMAP_TOGGLE"] = "Переключить"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Запертые предметы"
-- Under the list. Argument: the game's own name for the Rogue class.
L["MINIMAP_LOCKED_ITEMS_HINT"] = "%s может вскрыть их для вас."
-- The same, shown to a Rogue. Argument: the game's own name for Pick Lock.
L["MINIMAP_LOCKED_ITEMS_HINT_ROGUE"] = 'Используйте "%s", чтобы отпереть их.'
L["MINIMAP_OPTIONS"] = "Настройки GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + средний клик"

-- Heads the items on the Roll List still on a trade clock, soonest first, under Locked Items.
L["MINIMAP_TRADABLE_LOOT"] = "Передаваемая добыча"
-- Under the first few of them. Argument: how many more there are.
L["MINIMAP_TRADABLE_MORE"] = "Еще: %d"
-- The loot windows' block: its title, how many items are on the Roll List, its description and its click.
L["MINIMAP_LOOT_WINDOWS"] = "Распорядитель добычи и Журнал добычи"
L["MINIMAP_TO_HAND_OUT"] = "Раздать: %d"
L["MINIMAP_LOOT_WINDOWS_DESCRIPTION"] =
	"Разыгрывайте то, что еще можно передать, и следите за каждым броском."
L["MINIMAP_MIDDLE_CLICK"] = "Средний клик"
L["MINIMAP_OPEN"] = "Открыть"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Вручную"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "Только %s"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s и ниже"

-- How many of an item, after its link: on a toast, in a trade summary, in the mini-map's Locked Items and in Add from Bags. Argument: the count.
L["ITEM_QUANTITY"] = "x%d"
-- An item and how many, the way the game's own loot lines write it, in the loot windows and their chat lines. Arguments: the item's link, then the count.
L["ITEM_QUANTITY_LINK"] = "%sx%d"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List and Item Overrides bring text of their own), the hint the
    box shows while empty, and its button.
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
-- Shown in place of the rows when the Ignore List or Item Overrides is empty, since both refill at login.
L["ITEM_LIST_EMPTY_REFILLS"] =
	'Список пуст, поэтому стандартные предметы вернутся при следующем входе в игру. Кнопка "Восстановить по умолчанию" вернет их сразу.'

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

-- Shown under every setting that prints or sends a chat line. Argument: the message, drawn as it arrives in chat.
L["OPTIONS_EXAMPLE"] = "Пример: %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	'Быстрый сбор опустошает трупы без окна добычи, Автоброски выбирают "Нужно", "Не откажусь" или "Отказаться" по качеству, а Автораздача раздает добычу за вас. Моллюски, контейнеры и запертые ящики, как только их отопрут, открываются сами. Собирайте быстрее, начинайте бой раньше.'
L["WELCOME_MESSAGE"] = "Включить приветствие"
L["WELCOME_MESSAGE_DESCRIPTION"] =
	"При каждом входе в игру показывает версию GogoLoot и где найти эти настройки."
L["MINIMAP_BUTTON_ENABLE"] = "Включить кнопку у миникарты"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Показывает кнопку GogoLoot у миникарты. Левый клик включает и выключает Автоброски, правый клик делает то же с Автооткрытием, Shift + левый клик с оповещениями о добыче, а Shift + правый клик с Автораздачей."

L["OPTIONS_COMMANDS_HEADER"] = "/Команды"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Открывает окно настроек этого аддона."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Функции"

-- The opening line of the Speedy Loot panel, above its switch.
L["SPEEDY_LOOT_DESCRIPTION"] =
	"Забирает всю добычу с трупа в момент открытия, так что вам не придется ждать окна добычи."
L["SPEEDY_LOOT_ENABLE"] = "Включить Быстрый сбор"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	'Забирает всю добычу с трупа сразу, не показывая окно добычи. Удерживайте Shift при сборе, чтобы увидеть окно. Включает игровую настройку "%s" и не срабатывает, пока у вас роль "%s".'

--[[
    The Roll Macro panel. %s is the macro's name, "- Roll", the same in every
    locale. General Macros is the tab of the game's Macros window that every
    character on the account shares; /macro is the game's command and stays
    English.
]]
L["ROLL_MACRO_DESCRIPTION"] =
	'Добавляет в ваши общие макросы макрос "%s" со значком золотых монет, чтобы любой персонаж вашей учетной записи мог перетащить его на панель команд.'
--[[
    The three rows under it, each beside the game's name for a mouse button
    (MINIMAP_LEFT_CLICK and its neighbours). Right-click is the off-spec roll;
    a raid roll picks a number from 1 to the group's size.
]]
L["ROLL_MACRO_LEFT_CLICK"] = "Бросок 1-100"
L["ROLL_MACRO_RIGHT_CLICK"] = "Бросок 1-99"
L["ROLL_MACRO_MIDDLE_CLICK"] = "Рейдовый бросок"
L["ROLL_MACRO_ENABLE"] = "Включить макрос бросков"
-- Under the three rows, in silver: what Middle-Click's raid roll is for and how to read it.
L["ROLL_MACRO_RAID_ROLL_NOTE"] =
	"Рейдовый бросок отдает предмет случайному игроку. Он бросает от 1 до числа игроков в вашей группе, так что каждое число соответствует одному игроку: отсчитайте по списку рейда или группы выпавшее число, чтобы найти победителя. В одиночку бросает 1-100."
L["ROLL_MACRO_SWITCH_DESCRIPTION"] =
	'Хранит макрос "%s" в ваших общих макросах: левый клик бросает 1-100, правый клик 1-99, средний клик делает рейдовый бросок. При выключении макрос удаляется.'
--[[
    Printed to chat when Enable Roll Macro is switched on or off, or the macro
    can't be made. In ROLL_MACRO_ADDED the second %s is /m, the game's command
    for its Macros window, drawn in blue.
]]
L["ROLL_MACRO_ADDED"] =
	'Макрос "%s" добавлен в общие макросы. Введите %s и перетащите его на панель команд.'
L["ROLL_MACRO_REMOVED"] = 'Макрос "%s" удален.'
L["ROLL_MACRO_FULL_LOADING"] =
	'Не удалось добавить макрос "%s": общие макросы заполнены. Удалите один, и макрос добавится после следующего экрана загрузки.'

--------------------------------------------------------------------------------
-- Options: Feedback & Support Panel
--------------------------------------------------------------------------------

-- "Star" stays GitHub's English button label in every locale; Discord, CurseForge, Wago and GitHub stay as written.
L["OPTIONS_LEVEL_UP_TITLE"] = "Помогите GogoLoot повысить уровень"
L["OPTIONS_LEVEL_UP_INTRO"] =
	"Этот аддон создали игроки, которые любят эту игру и хотят сделать ее как можно веселее для всех. Мы никогда не попросим пожертвований. Настоящую радость нам приносит знание, что наша работа делает игру для вас хоть немного лучше. Если это так, мы будем рады об этом услышать!"
L["OPTIONS_LEVEL_UP_WAYS"] =
	"Вот несколько способов помочь нам найти больше игроков."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Поделитесь отзывом: нашли ошибку или есть идея? Расскажите нам в Discord. Ваши отзывы помогают улучшать аддон, а пул-реквесты всегда приветствуются."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Расскажите другу: знаете кого-то, кому может понравиться этот аддон? Расскажите ему о нем. Сарафанное радио помогает большему числу игроков находить отличные аддоны."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Добавьте в избранное на CurseForge: откройте ссылку на CurseForge ниже, войдите и нажмите на звездочку под кнопкой скачивания. Избранное помогает большему числу игроков найти аддон."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Поставьте звезду на GitHub: откройте ссылку на GitHub ниже, войдите и нажмите Star в правом верхнем углу. Звезды помогают проекту получить доступ к бесплатным инструментам для разработчиков."
L["OPTIONS_LEVEL_UP_THANKS"] = "Спасибо, что выбрали GogoLoot!"

L["OPTIONS_FEEDBACK"] = "Отзывы и поддержка"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Ссылки для отзывов и поддержки"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] =
	"Чтобы скопировать ссылку, щелкните по ее полю и нажмите Ctrl+A, затем Ctrl+C."
-- The version line at the foot of the Feedback & Support panel.
L["OPTIONS_VERSION"] = "Версия %s"

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

-- The pop-up's own title, which code joins with the add-on name: "Quick Settings // GogoLoot".
L["QUICK_SETTINGS_TITLE"] = "Быстрые настройки"
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
	"Заменить ваш Список исключений стандартными предметами для вашего дополнения?"
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
L["ROLLS_PARTY_AND_RAID_HEADER"] = "Броски в группе и рейде"
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
-- Shown on Item Overrides and Character Rules while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] =
	"Пока Автоброски выключены, эти настройки не используются."
L["ITEM_OVERRIDES_ENABLE"] = "Включить Особые предметы"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"Использует броски, заданные ниже. Если выключено, эти предметы следуют настройкам качества, как и все остальные."
-- Shown under Enable Item Overrides while it is off.
L["ITEM_OVERRIDES_OFF_NOTE"] =
	"Пока Особые предметы выключены, эти броски не используются."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] =
	"Заменяет ваши Особые предметы стандартными предметами для вашего дополнения."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"Заменить ваши Особые предметы стандартными предметами для вашего дополнения?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] =
	"Задает автоматический бросок для этого предмета."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "Удаляет этот предмет из Особых предметов."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] =
	"Удалить этот предмет и его бросок из Особых предметов?"
L["ITEM_OVERRIDES_ADD_DESCRIPTION"] =
	'Введите ID предмета или перетащите предмет сюда, чтобы добавить его в список с действием "Вручную".'

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
L["ANNOUNCEMENTS_ENABLE"] = "Включить оповещения о добыче"
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
-- The trade window checkbox tooltip's line naming when summaries are posted.
L["TRADE_WHEN"] = "Когда"
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
-- The Container row is the bag class; clams, crates and lockboxes have the Openables row.
L["LOOT_TOASTS_FILTER_CONTAINER_MINE_DESCRIPTION"] =
	'Показывает подбираемые вами сумки. Моллюски, ящики и запертые ящики находятся в строке "Открываемые предметы".'
L["LOOT_TOASTS_FILTER_CONTAINER_GROUP_DESCRIPTION"] =
	'Показывает сумки, которые подбирает любой участник группы или рейда, с именем подобравшего. Моллюски, ящики и запертые ящики находятся в строке "Открываемые предметы".'

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
	'Показывает уведомления о подобранных вами монетах. Игра не сообщает о монетах других игроков, поэтому флажка "Группа" здесь нет.'

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast "You Won" takes the
    looter's place (LOOT_TOASTS_YOU_WON_ROLL: the item, the roll); on a group
    member's, their name (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Победный бросок"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"Добавляет к уведомлению бросок, которым вы выиграли предмет, например (Вы выиграли, %s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Добавляет к уведомлению участника группы бросок, которым он выиграл предмет, например (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_YOU_WON_ROLL"] = "%s (Вы выиграли, %s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Количество в сумках"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Добавляет к уведомлениям о вашей добыче, сколько таких предметов у вас теперь с собой, например x3 (27), если их больше, чем указано в самом уведомлении."
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
L["LOOT_TOASTS_ALIGN_TOASTS"] = "Выравнивание уведомлений"
L["LOOT_TOASTS_ALIGN_TOASTS_DESCRIPTION"] =
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
L["LOOT_TOASTS_RESET_CONFIRM"] =
	"Вернуть уведомления о добыче на исходное место?"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] =
	"Показывает или скрывает рамку, за которую уведомления можно перетащить на новое место."
L["LOOT_TOASTS_RESET_DESCRIPTION"] =
	"Возвращает уведомления на исходное место над центром экрана."

-- The drag handle, titled "Loot Toasts // GogoLoot" by code: the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_CLICK_DRAG"] = "Зажмите и перетащите, чтобы переместить"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "Правый клик, чтобы заблокировать"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "Отключить уведомления о добыче"
-- The stand-in item on the sample toasts the position preview shows; Example lines link real items.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "Пример предмета"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"Проигрывает сигнал при добыче выбранного качества или выше и звук сумки, когда %s приносит добычу."
-- The Loot Sounds panel's master switch, also in the General panel's Features section; its tooltip names no position on either.
L["LOOT_SOUNDS_SWITCH"] = "Включить звуки добычи"
L["LOOT_SOUNDS_SWITCH_DESCRIPTION"] = "Включает и выключает все звуки добычи GogoLoot."
-- The chime's own toggle, under the master switch.
L["LOOT_SOUNDS_ENABLE"] = "Включить сигнал добычи"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Проигрывает сигнал, когда вы забираете с трупа или из сундука предмет выбранного качества или выше."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] =
	"Самое низкое качество предмета, для которого проигрывается сигнал добычи."
L["LOOT_SOUNDS_TEST"] = "Проигрывает сигнал добычи."
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
	"Открывает за вас в сумках моллюсков, ящики, кошельки, а также запертые ящики, как только их отопрут, если свободных ячеек не меньше %d."
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
	"Сообщает в чате, когда вы получаете запертый ящик, который откроется, как только его отопрут."
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] =
	"Показывать оповещения о запертых ящиках только разбойникам или всем персонажам."
-- Shown under Enable Lockbox Notifications while it is on and Automated Opening is off.
L["LOCKBOXES_NOTIFICATIONS_OFF_NOTE"] =
	"Пока Автооткрытие выключено, оповещения о запертых ящиках не используются."
L["LOCKBOXES_FOR_ROGUES"] = "Для разбойников"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "Для всех персонажей"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking (225)" line (ITEM_MIN_SKILL), or under GogoLoot's own
    ITEM_REQ_SKILL line where the client prints none, followed by a skill
    number. Argument: the game's own name for the Lockpicking skill.
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
-- The same while Speedy Loot is off too.
L["OPENABLE_ITEMS_ALL_OFF_NOTE"] =
	"Пока Автооткрытие и Быстрый сбор выключены, эти настройки не используются."
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
L["ROLL_CALL_START"] = "Бросайте /roll на %s, %d сек"
-- Arguments: the seconds left, then the item.
L["ROLL_CALL_LAST_SECONDS"] = "Осталось %d сек на %s"
-- +10 Seconds. Arguments: the seconds added, then the item.
L["ROLL_CALL_EXTENDED"] = "Еще %d сек на %s"
-- Arguments: the item, then the rolls that didn't count, each one of the four lines below, joined by commas.
L["ROLL_CALL_NOT_COUNTED"] = "Не засчитано на %s: %s"
-- Arguments: the player, then their roll.
L["ROLL_CALL_NOT_COUNTED_EARLY"] = "ранний бросок игрока %s (%d)"
L["ROLL_CALL_NOT_COUNTED_REPEAT"] = "лишний бросок игрока %s (%d)"
-- Arguments: the player, their roll, then the range they rolled in.
L["ROLL_CALL_NOT_COUNTED_RANGE"] = "игрок %s: %d (%d-%d)"
L["ROLL_CALL_NOT_COUNTED_NOT_TIED"] = "игрок %s: %d (не в перебросе)"
-- Arguments: the tied players, the roll they tied at, the item, the tied players again, then the seconds.
L["ROLL_CALL_TIE"] = "%s: ничья (%d) на %s. Только %s, снова /roll, %d сек"
-- With Re-roll Ties off. Arguments: the tied players, the roll they tied at, then the item.
L["ROLL_CALL_TIE_HELD"] = "%s: ничья (%d) на %s. Будет переброс"
-- Arguments: the winner, the item, then the winning roll.
L["ROLL_CALL_WINS"] = "%s выигрывает %s (%d)"
-- After a disqualification or a restore changed who won. Arguments as above.
L["ROLL_CALL_NOW_WINS"] = "Теперь %s выигрывает %s (%d)"
-- Argument: the item.
L["ROLL_CALL_NOBODY"] =
	"Никто не бросил на %s. Пока предмет остается в моем списке"
L["ROLL_CALL_NOBODY_LEFT"] =
	"На %s не осталось засчитанных бросков. Предмет возвращается в мой список"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_DISQUALIFIED_NO_REASON"] = "Бросок игрока %s (%d) на %s дисквалифицирован"
-- The same with a reason. Arguments: the player, their roll, the item, then one of the ROLL_DISQUALIFY_REASON_ lines.
L["ROLL_CALL_DISQUALIFIED_BECAUSE"] = "Бросок игрока %s (%d) на %s дисквалифицирован: %s"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_RESTORED"] = "Бросок игрока %s (%d) на %s восстановлен"
-- Arguments: the item, then the seconds.
L["ROLL_CALL_VOIDED"] =
	"Все броски на %s аннулированы. Бросайте снова /roll, %d сек"
-- Argument: the item.
L["ROLL_CALL_CANCELED"] = "Розыгрыш %s отменен. Пока не бросайте"
L["ROLL_CALL_PAUSED"] = "Пока не бросайте. Розыгрыш %s на паузе"
-- Arguments: the item, then the seconds left.
L["ROLL_CALL_RESUMED"] = "Розыгрыш %s продолжается, осталось %d сек"
-- Each argument: items, joined by commas.
L["ROLL_CALL_ROLL_ALL"] = "Разыгрываем по порядку: %s"
L["ROLL_CALL_UP_FOR_ROLL"] = "Разыгрывается: %s"
L["ROLL_CALL_FLOOR_LOOT"] = "Разыгрывается общая добыча: %s"
-- Drops by boss posted to the group, a line per boss. Arguments: the boss, then its drops, joined by commas.
L["DROPS_POST_LINE"] = "%s: %s"

--------------------------------------------------------------------------------
-- Roll Calls: Printed
--------------------------------------------------------------------------------

-- Outside a group there's nobody to send to. Argument: the line a group would have seen.
L["ROLL_CALL_SOLO_PREVIEW"] =
	"Вы не в группе, поэтому это никуда не отправлено: %s"
-- Arguments: the winner, then the item.
L["ROLL_CALL_WON_PRINT"] =
	"%s выигрывает %s. Начните обмен с этим игроком, и GogoLoot положит предмет в окно обмена."

--------------------------------------------------------------------------------
-- Roll Tags and Reasons
--------------------------------------------------------------------------------

-- Beside a roll in the loot windows: why it doesn't count, or where it stands.
L["ROLL_TAG_EARLY"] = "Бросок до объявления"
L["ROLL_TAG_LATE"] = "Бросок после закрытия"
L["ROLL_TAG_REPEAT"] = "Лишний бросок, не засчитан"
-- Arguments: the range the player rolled in.
L["ROLL_TAG_RANGE"] = "Не тот диапазон (%d-%d)"
L["ROLL_TAG_NOT_TIED"] = "Не участвует в перебросе"
L["ROLL_TAG_DISQUALIFIED"] = "Дисквалифицирован"
-- Argument: one of the reasons below.
L["ROLL_TAG_DISQUALIFIED_BECAUSE"] = "Дисквалифицирован: %s"
L["ROLL_TAG_WINNER"] = "Победитель"
L["ROLL_TAG_HIGHEST"] = "Пока лучший"
L["ROLL_TAG_TIED"] = "Ничья"

-- The reasons offered when the loot master disqualifies a roll, also sent after ROLL_CALL_DISQUALIFIED_BECAUSE's colon.
L["ROLL_DISQUALIFY_REASON_NOT_ELIGIBLE"] = "Нет права на этот предмет"
L["ROLL_DISQUALIFY_REASON_ALREADY_WON"] = "Сегодня уже есть выигрыш"
L["ROLL_DISQUALIFY_REASON_FOR_SOMEONE_ELSE"] = "Бросок за другого игрока"
L["ROLL_DISQUALIFY_REASON_NONE"] = "Без указания причины"

--------------------------------------------------------------------------------
-- Loot Master Window
--------------------------------------------------------------------------------

-- The tabs. Argument: how many items each holds.
L["LOOT_MASTER_TAB_ROLL_LIST"] = "Список розыгрыша (%d)"
L["LOOT_MASTER_TAB_FLOOR_LOOT"] = "Общая добыча (%d)"
L["LOOT_MASTER_TAB_AWARDED"] = "Выдано (%d)"
L["LOOT_MASTER_TAB_SOFT_RESERVES"] = "Софт-резервы"

-- The Roll List's buttons.
L["LOOT_MASTER_ROLL"] = "Разыграть"
L["LOOT_MASTER_ROLL_AGAIN"] = "Разыграть снова"
L["LOOT_MASTER_ROLL_ALL"] = "Разыграть все"
L["LOOT_MASTER_PAUSE"] = "Пауза"
L["LOOT_MASTER_RESUME"] = "Продолжить"
L["LOOT_MASTER_STOP"] = "Стоп"
L["LOOT_MASTER_LIST_IN_RAID"] = "Огласить в рейде"
L["LOOT_MASTER_MOVE_UP"] = "Выше"
L["LOOT_MASTER_MOVE_DOWN"] = "Ниже"
-- Argument: the seconds added.
L["LOOT_MASTER_EXTEND"] = "+%d сек."
L["LOOT_MASTER_CLOSE_NOW"] = "Закрыть сейчас"
L["LOOT_MASTER_VOID"] = "Аннулировать все броски"
L["LOOT_MASTER_CANCEL_ROLL"] = "Отменить розыгрыш"
L["LOOT_MASTER_TAKE_OFF"] = "Убрать из списка"
-- Argument: the winner.
L["LOOT_MASTER_GIVE"] = "Передать игроку %s"
L["LOOT_MASTER_TRADE"] = "Обмен: %s"
L["LOOT_MASTER_ANNOUNCE_WINNER"] = "Объявить победителя"
L["LOOT_MASTER_HANDED_OUT"] = "Отметить как выданное"
L["LOOT_MASTER_REROLL_TIED"] = "Переброс ничьей"
L["LOOT_MASTER_DISQUALIFY"] = "Дисквалифицировать"
L["LOOT_MASTER_RESTORE"] = "Восстановить"

-- A row's trade clock, where it has none to show.
L["LOOT_MASTER_ON_CORPSE"] = "На трупе"
L["LOOT_MASTER_CORPSE_CLOSED"] = "Труп закрыт"
L["LOOT_MASTER_BOUND"] = "Персональный"
L["LOOT_MASTER_NO_LIMIT"] = "Без ограничений"

-- A row's state. Argument: how many rolls have landed.
L["LOOT_MASTER_STATUS_ROLLING"] = "Розыгрыш, бросков: %d"
L["LOOT_MASTER_STATUS_TIE_BREAK"] = "Переброс, бросков: %d"
L["LOOT_MASTER_STATUS_ON_HOLD"] = "Пауза, бросков: %d"
-- STATUS_TIED and STATUS_NOBODY also title a finished roll in the Loot Tracker.
L["LOOT_MASTER_STATUS_TIED"] = "Ничья"
L["LOOT_MASTER_STATUS_NOBODY"] = "Никто не бросил"
L["LOOT_MASTER_STATUS_SOULBOUND"] = "Стал персональным"
L["LOOT_MASTER_STATUS_UP_NEXT"] = "Следующий"

-- The first line of an opened row.
L["LOOT_MASTER_HEADLINE_ROLLING"] = "Розыгрыш, осталось %d сек."
L["LOOT_MASTER_HEADLINE_ON_HOLD"] = "На паузе, осталось %d сек."
-- Arguments: the tied players, then the seconds left.
L["LOOT_MASTER_HEADLINE_TIE_BREAK"] = "Переброс для %s, осталось %d сек."
-- Arguments: the winner, then the winning roll.
L["LOOT_MASTER_HEADLINE_WON"] = "%s побеждает с броском %d."
-- Arguments: the tied players, then the roll they tied at.
L["LOOT_MASTER_HEADLINE_TIED"] = "%s: ничья (%d)."
L["LOOT_MASTER_HEADLINE_SOULBOUND"] =
	"Стал персональным, передать его больше нельзя."
-- Argument: the boss. Also under the game's own trade line on a bag item's tooltip while it is on the Roll List.
L["LOOT_MASTER_LOOTED_FROM"] = "Добыто: %s."
L["LOOT_MASTER_FROM_FLOOR_LOOT"] = "Из общей добычи."
-- After the line above. Argument: how long, in the game's own words for time.
L["LOOT_MASTER_TRADABLE_FOR"] = "Можно передать еще %s."
-- Headings over a row's rolls; ROUND_SO_FAR also heads an open roll in the Loot Tracker.
L["LOOT_MASTER_ROUND_SO_FAR"] = "Броски на данный момент"
L["LOOT_MASTER_ROUND_ROLLS"] = "Броски"
L["LOOT_MASTER_ROUND_FIRST"] = "Первый бросок"
L["LOOT_MASTER_ROUND_TIE_BREAK"] = "Переброс"
-- Arguments: how many, then their names. Also in the Loot Tracker.
L["LOOT_MASTER_HASNT_ROLLED"] = "Не бросили (%d): %s"

L["LOOT_MASTER_EMPTY"] =
	"Раздавать пока нечего. Подобранная добыча, которую можно передать, попадает сюда сама; чтобы добавить любой другой предмет из сумок, щелкните по нему с Alt."
-- The line beside the Roll List's buttons.
L["LOOT_MASTER_STATE_PAUSED"] = "Пауза."
L["LOOT_MASTER_STATE_ROLL_ALL"] = "Разыгрываем все: осталось %d."
L["LOOT_MASTER_STATE_ONE_AT_A_TIME"] = "По одному розыгрышу за раз."
L["LOOT_MASTER_STATE_WAITING"] = "Ждут розыгрыша: %d."
-- The foot of the Roll List. Arguments: how many items, then the time left on the soonest trade clock.
L["LOOT_MASTER_FOOTER"] = "Раздать: %d."
L["LOOT_MASTER_FOOTER_CLOCK"] =
	"Раздать: %d, ближайший срок обмена истекает через %s."
L["LOOT_MASTER_ALT_CLICK_HINT"] = "Alt + клик по предмету в сумке, чтобы добавить"

-- The Disqualify window.
L["LOOT_MASTER_DISQUALIFY_TITLE"] = "Дисквалификация броска"
-- Arguments: the player, their roll, then the item.
L["LOOT_MASTER_DISQUALIFY_BODY"] =
	"Исключить бросок игрока %s (%d) из розыгрыша %s? Позже его можно восстановить."
L["LOOT_MASTER_DISQUALIFY_REASON"] = "Причина"
L["LOOT_MASTER_DISQUALIFY_TELLS"] = "GogoLoot сообщит группе:"
-- Argument: the item.
L["LOOT_MASTER_VOID_CONFIRM"] =
	"Аннулировать все броски на %s и объявить розыгрыш заново?"

-- Printed by the Loot Master.
L["LOOT_MASTER_ROLL_ALL_DONE"] =
	"Розыгрыш всех предметов завершен. Все предметы из списка розыгрыша разыграны."
L["LOOT_MASTER_ROLL_ALL_PAUSED"] =
	'Розыгрыш всех предметов приостановлен. Новые розыгрыши не начнутся, пока вы не нажмете "Продолжить".'
L["LOOT_MASTER_ROLL_ALL_RESUMED"] = "Розыгрыш всех предметов возобновлен."
L["LOOT_MASTER_ROLL_ALL_STOPPED"] =
	"Розыгрыш всех предметов остановлен. Текущий розыгрыш все равно завершится."
-- Arguments: the item, then the whole minutes left.
L["LOOT_MASTER_TRADE_TIME_LOW"] = "%s можно передать еще %d мин."
-- Argument: the item.
L["LOOT_MASTER_TRADE_TIME_OVER"] = "%s больше нельзя передать."
-- Arguments: the item, the winner, then their winning roll.
L["LOOT_MASTER_TRADE_FILLED"] =
	"В окно обмена положено: %s для игрока %s (победный бросок: %d)."
-- Arguments: the winner, then the item.
L["LOOT_MASTER_NOT_A_CANDIDATE"] = "Игроку %s нельзя отдать %s с этого трупа."
-- Argument: the item.
L["LOOT_MASTER_ADDED"] = "%s: добавлено в список розыгрыша."
L["LOOT_MASTER_NOT_TRADABLE"] =
	"%s: предмет нельзя передать, поэтому его нельзя добавить в список розыгрыша."
-- Argument: how many joined.
L["LOOT_MASTER_FLOOR_ADDED"] =
	"Предметы общей добычи добавлены в список розыгрыша: %d."
L["LOOT_MASTER_OFF"] =
	"Распорядитель добычи выключен. Включите его в меню Настройки > Модификации > GogoLoot > Распорядитель добычи."

-- A bag item's tooltip, under the game's own trade line, while it is on the Roll List.
L["LOOT_MASTER_TOOLTIP_ON_ROLL_LIST"] = "В списке розыгрыша."
-- Arguments: the winner, then their winning roll.
L["LOOT_MASTER_TOOLTIP_WON_BY"] = "Победитель: %s, бросок %d."

-- Floor Loot. The add box, filter and Add from Bags use the item lists' own words (ITEM_LIST_*).
L["LOOT_MASTER_FLOOR_DESCRIPTION"] =
	"Добыча без таймера обмена, которую вы хотите разыграть: материалы, рецепты, снаряжение, персональное при надевании. Список начинается пустым, так что разыгрывается только то, что вы добавите. Один розыгрыш на стопку."
L["LOOT_MASTER_FLOOR_EMPTY"] =
	'Здесь пока пусто. Выберите предмет в меню "Добавить из сумок" или перетащите его в поле выше.'
-- Argument: how many the bags hold.
L["LOOT_MASTER_FLOOR_IN_BAGS"] = "В сумках: %d"
L["LOOT_MASTER_FLOOR_ON_ROLL_LIST"] = "В списке розыгрыша"
L["LOOT_MASTER_FLOOR_REMOVE"] = "Убирает этот предмет из общей добычи."
-- The heading for an item whose kind the game hasn't said yet.
L["LOOT_MASTER_FLOOR_OTHER"] = "Прочее"
L["LOOT_MASTER_FLOOR_ADD_ALL"] = "Добавить все в список розыгрыша"
-- Add from Bags' two headings.
L["LOOT_MASTER_FLOOR_MENU_PICKED_UP"] = "Подобрано в этом подземелье"
L["LOOT_MASTER_FLOOR_MENU_BAGS"] = "Также в ваших сумках"
-- Argument: what was typed.
L["LOOT_MASTER_FLOOR_NOT_FOUND"] =
	'В сумках нет передаваемых предметов, подходящих под "%s".'

-- Awarded.
L["LOOT_MASTER_AWARDED_EMPTY"] =
	"Пока ничего не выдано. Выигранный предмет появится здесь, когда победитель его получит."
-- Arguments: the winning roll, then the time it was handed out.
L["LOOT_MASTER_AWARDED_ROLLED"] = "Бросок %d, %s"
-- Argument: the time it was handed out.
L["LOOT_MASTER_AWARDED_GIVEN"] = "Выдано %s"
L["LOOT_MASTER_AWARDED_CLEAR"] = "Очистить"

-- Soft Reserves, a placeholder for now.
L["LOOT_MASTER_SOFT_RESERVES_DESCRIPTION"] =
	"Вставьте сюда строку софт-резервов, чтобы увидеть, кто что зарезервировал. Скоро: пока эта вкладка лишь заготовка."
L["LOOT_MASTER_SOFT_RESERVES_PLACEHOLDER"] = "Импорт софт-резервов пока не готов."
L["LOOT_MASTER_SOFT_RESERVES_IMPORT"] = "Импорт"

--------------------------------------------------------------------------------
-- Loot Tracker Window
--------------------------------------------------------------------------------

L["LOOT_TRACKER_TITLE"] = "Журнал добычи"
L["LOOT_TRACKER_TAB_ROLLS"] = "Броски"
L["LOOT_TRACKER_TAB_DROPS"] = "Добыча"
L["LOOT_TRACKER_NO_ROLL"] = "Сегодня бросков еще не было."
-- Argument: who called the roll.
L["LOOT_TRACKER_CALLED_BY"] = "Объявил: %s"
L["LOOT_TRACKER_SPOTTED"] = "Замечено в чате, автор: %s"
-- Argument: whole seconds left.
L["LOOT_TRACKER_SECONDS_LEFT"] = "Осталось %d с"
-- A roll called without GogoLoot. Argument: who called it.
L["LOOT_TRACKER_UNSYNCED_NOTE"] =
	"%s не использует GogoLoot, поэтому здесь броски, замеченные в чате и проверенные по обычным правилам: 1-100, только первый бросок. Последнее слово за объявившим розыгрыш."
L["LOOT_TRACKER_ON_HOLD"] = "Пауза. Дождитесь объявления, чтобы бросить снова."
L["LOOT_TRACKER_TIE_BREAK_ROLLS"] = "Броски переброса"
-- Arguments: the winner, then the winning roll.
L["LOOT_TRACKER_WON_WITH"] = "%s побеждает с броском %d"
L["LOOT_TRACKER_CLOSED"] = "Закрыто"
-- The sort buttons.
L["LOOT_TRACKER_SORT_HIGH"] = "Наивысшие"
L["LOOT_TRACKER_SORT_TIME"] = "По порядку"
L["LOOT_TRACKER_ROLL"] = "Бросок (1-100)"
-- Beside the player's own roll, and the line beside the Roll and Pass buttons.
L["LOOT_TRACKER_YOU"] = "Вы"
L["LOOT_TRACKER_YOU_ROLLED"] = "Вы выбросили %d."
L["LOOT_TRACKER_YOU_PASSED"] = "Вы отказались."
L["LOOT_TRACKER_NOT_ROLLED"] = "Вы еще не бросали."
L["LOOT_TRACKER_NOT_IN_TIE_BREAK"] = "Сейчас бросают только игроки с ничьей."
L["LOOT_TRACKER_EARLIER"] = "Ранее сегодня"
--[[
    The word, in lower case, that marks a group chat line with an item link as
    a call for rolls by someone without GogoLoot. "roll" is always read too.
]]
L["LOOT_TRACKER_ROLL_WORD"] = "ролл"

-- Drops.
L["LOOT_TRACKER_SHOW_WINNERS"] = "Показать, кто что получил"
L["LOOT_TRACKER_DROPS_EMPTY"] =
	"Добыча пока не замечена. Она появится здесь, когда будут убиты боссы и обысканы трупы."
L["LOOT_TRACKER_DROPS_NOTHING_SEEN"] = "Никто с GogoLoot его еще не обыскал."
L["LOOT_TRACKER_NOT_HANDED_OUT"] = "Еще не выдано"
L["LOOT_TRACKER_PRINT"] = "Вывести"
L["LOOT_TRACKER_POST"] = "Отправить в рейд"
L["LOOT_TRACKER_COPY"] = "Копировать"
L["LOOT_TRACKER_COPY_TITLE"] = "Копировать: Ctrl+C"

-- Drops by boss, printed and copied.
L["DROPS_TRASH"] = "Трэш"
L["DROPS_NONE"] = "Добыча еще не записана."
-- Argument: the instance.
L["DROPS_PRINT_HEADER"] = "Добыча (%s):"
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
	"Разыгрывайте добычу, которую еще можно передать, с таймером обмена у каждого предмета, и следите за каждым броском в Журнале добычи. Средний клик по кнопке у миникарты или команды /gogo master и /gogo tracker."
L["LOOT_MASTER_ENABLE"] = "Включить Распорядителя добычи"
L["LOOT_MASTER_ENABLE_DESCRIPTION"] =
	"Отслеживает добычу, которую еще можно передать, и объявляет на нее розыгрыши. Если выключено, Распорядитель добычи и Журнал добычи не открываются, а броски не считываются."
L["LOOT_MASTER_OPEN"] = "Открыть Распорядителя добычи"
L["LOOT_TRACKER_OPEN"] = "Открыть Журнал добычи"
-- A dropdown choice. Argument: the number.
L["LOOT_MASTER_SECONDS"] = "%d сек."
L["LOOT_MASTER_MINUTES"] = "%d мин."
L["LOOT_MASTER_KEEP_RAIDS"] = "%d"

L["LOOT_MASTER_CALLING_HEADER"] = "Объявление розыгрышей"
L["LOOT_MASTER_ROLL_LENGTH"] = "Длительность розыгрыша"
L["LOOT_MASTER_ROLL_LENGTH_DESCRIPTION"] = "Сколько длится розыгрыш."
L["LOOT_MASTER_ANNOUNCE_IN"] = "Куда объявлять"
L["LOOT_MASTER_ANNOUNCE_IN_DESCRIPTION"] =
	"Куда идут объявления розыгрышей, ничьих и пауз."
L["LOOT_MASTER_CHANNEL_GROUP"] = "Чат группы"
L["LOOT_MASTER_ANNOUNCE_IN_NOTE"] =
	"Если вы не лидер и не помощник, вместо объявления рейду используется чат группы. Победители всегда объявляются в чате группы."
-- Argument: the seconds.
L["LOOT_MASTER_WARN_LAST_SECONDS"] = "Предупреждать за %d сек. до конца"
L["LOOT_MASTER_WARN_LAST_SECONDS_DESCRIPTION"] =
	"Сообщает группе, что розыгрыш скоро закроется."
-- Argument: the seconds.
L["LOOT_MASTER_STRETCH_LATE"] = "Добавлять %d сек. при позднем броске"
L["LOOT_MASTER_STRETCH_LATE_DESCRIPTION"] =
	"Бросок в последние секунды немного продлевает розыгрыш, чтобы никого не отрезало из-за задержки."
L["LOOT_MASTER_END_EARLY"] =
	"Завершать досрочно, когда все бросили или отказались"
L["LOOT_MASTER_END_EARLY_DESCRIPTION"] =
	'Закрывает розыгрыш, как только каждый участник группы бросил или написал "pass".'
L["LOOT_MASTER_REROLL_TIES"] = "Переброс ничьей между игроками с ничьей"
L["LOOT_MASTER_REROLL_TIES_DESCRIPTION"] =
	'Сразу объявляет переброс для игроков с ничьей. Если выключено, ничья ждет, пока вы не нажмете "Переброс ничьей".'
L["LOOT_MASTER_ROLL_ALL_PAUSE"] = "Пауза между предметами при розыгрыше всех"
L["LOOT_MASTER_ROLL_ALL_PAUSE_DESCRIPTION"] =
	"Сколько ждать после розыгрыша, прежде чем объявить следующий, при розыгрыше всех предметов."

L["LOOT_MASTER_COUNTING_HEADER"] = "Засчитываемые броски"
-- Argument: the seconds of grace.
L["LOOT_MASTER_COUNTING_DESCRIPTION"] =
	"Обычный /roll (1-100), только первый у каждого игрока вашей группы, пока розыгрыш открыт (запас на задержку: %d сек.). Незасчитанные броски остаются в списке с указанием причины."
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED"] = "Объявлять незасчитанные броски"
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED_DESCRIPTION"] =
	"Когда розыгрыш закрывается, перечисляет одной строкой незасчитанные броски и причины. О дисквалифицированном вами броске объявляется всегда."

L["LOOT_MASTER_TRADE_HEADER"] = "Передаваемая добыча"
L["LOOT_MASTER_OPEN_ON_TRADABLE"] =
	"Открывать, когда я добываю передаваемый предмет"
L["LOOT_MASTER_OPEN_ON_TRADABLE_DESCRIPTION"] =
	"Открывает Распорядителя добычи, когда в ваши сумки попадает предмет, персональный при поднятии, который еще можно передать, пока вы в группе."
L["LOOT_MASTER_TRADE_WARN"] = "Предупреждать, когда время на обмен истекает"
L["LOOT_MASTER_TRADE_WARN_DESCRIPTION"] =
	"Один раз сообщает в чате, когда предмет из списка розыгрыша вот-вот станет персональным."
L["LOOT_MASTER_TRADE_WARN_WHEN"] =
	"Сколько времени на обмен остается в момент предупреждения."
L["LOOT_MASTER_TRADE_AUTO_FILL"] = "Класть выигранное в окно обмена"
L["LOOT_MASTER_TRADE_AUTO_FILL_DESCRIPTION"] =
	'Когда вы начинаете обмен с победителем, выигранное им кладется в окно обмена само. Нажать "Обмен" все равно нужно вам.'

L["LOOT_MASTER_FLOOR_HEADER"] = "Общая добыча"
L["LOOT_MASTER_FLOOR_PANEL_DESCRIPTION"] =
	'Общая добыча начинается пустой и содержит только то, что вы добавите. В меню "Добавить из сумок" сначала идет то, что вы подобрали в этом подземелье.'
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE"] =
	"Убирать предметы, которых больше нет в сумках"
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE_DESCRIPTION"] =
	"Убирает предмет из общей добычи, когда у вас его не осталось: передали, продали или использовали."
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE"] = "Очищать общую добычу при выходе из рейда"
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE_DESCRIPTION"] =
	"Каждый рейд начинается с пустым списком общей добычи."

L["LOOT_TRACKER_OPEN_ON_ROLL"] = "Открывать, когда кто-то объявляет розыгрыш"
L["LOOT_TRACKER_OPEN_ON_ROLL_DESCRIPTION"] =
	"Открывает Журнал добычи, когда кто-то в вашей группе объявляет розыгрыш, через GogoLoot или объявлением рейду."
L["LOOT_TRACKER_AUTO_CLOSE"] = "Закрываться после окончания розыгрыша"
L["LOOT_TRACKER_AUTO_CLOSE_DESCRIPTION"] =
	"Журнал добычи, открывшийся сам, закрывается через 30 секунд после окончания розыгрыша, если над ним нет курсора."
L["LOOT_TRACKER_KEEP_DROPS"] = "Рейдов в истории добычи"
L["LOOT_TRACKER_KEEP_DROPS_DESCRIPTION"] = 'Сколько рейдов помнит вкладка "Добыча".'
