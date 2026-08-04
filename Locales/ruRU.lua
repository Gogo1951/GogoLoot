local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "ruRU")
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
	"Версия %s. Настройки (включая возможность отключения этого сообщения) находятся в меню Настройки > Модификации > GogoLoot. Нравится аддон? Расскажите о нем друзьям! (="
L["CHAT_OPTIONS_IN_COMBAT"] =
	"В целях безопасности меню настроек нельзя открыть в бою."
L["MESSAGE_AUTO_LOOT_ENABLED"] =
	"Автосбор включен. Он необходим для работы Быстрого сбора."
L["MESSAGE_NOT_MASTER_LOOTER"] =
	"В данный момент вы не являетесь ответственным за добычу."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "Передал %s игроку %s."
L["MESSAGE_DESTINATION_SET"] = "%s будет получать все предметы качества: %s."
L["MESSAGE_DESTINATION_SET_ALL"] = "%s будет хранить всю добычу для группы."
L["MESSAGE_DESTINATION_LEFT"] =
	"%s покинул(а) группу. %s теперь будет получать все предметы качества: %s."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Передал %s игроку %s, получил %s."
L["MESSAGE_TRADE_RECEIVED"] = "Получил %s от %s."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "Сумки игрока %s заполнены: %s"
L["ERROR_MAX_COUNT"] = "У игрока %s уже слишком много: %s"
L["ERROR_OUT_OF_RANGE"] = "%s находится вне зоны досягаемости: %s"
L["ERROR_NOT_IN_GROUP"] = "%s больше не состоит в группе или рейде: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "Не удалось передать игроку %s: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "Ответственный"
L["TAB_AUTOMATED_ROLLS"] = "Автоброски"
L["TAB_ANNOUNCEMENTS"] = "Оповещения"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Включено"
L["STATUS_DISABLED"] = "Отключено"

--[[
    The tooltip titles each feature with its options-panel name rather than
    keeping its own copy: Automated Rolls uses TAB_AUTOMATED_ROLLS, Speedy Loot
    uses SPEEDY_LOOT_HEADER and SPEEDY_LOOT_DESCRIPTION. Only the roll
    description below is unique to the tooltip, where the panel's longer text
    would not fit.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] =
	"Бросает кубик за вас на подходящие предметы вплоть до выбранного качества."

L["MINIMAP_LEFT_CLICK"] = "ЛКМ"
L["MINIMAP_RIGHT_CLICK"] = "ПКМ"
L["MINIMAP_TOGGLE"] = "Переключить"
L["MINIMAP_OPTIONS"] = "Настройки GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + средняя кнопка мыши"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- Quality Labels
L["QUALITY_POOR"] = "Низкое"
L["QUALITY_COMMON"] = "Обычное"
L["QUALITY_UNCOMMON"] = "Необычное"
L["QUALITY_RARE"] = "Редкое"
L["QUALITY_EPIC"] = "Эпическое"

-- Roll Action Labels
L["ROLL_MANUAL"] = "Вручную"
L["ROLL_GREED"] = "Не откажусь"
L["ROLL_NEED"] = "Мне нужно"
L["ROLL_PASS"] = "Пас"

-- Loot Method Labels
L["LOOT_METHOD_FREE_FOR_ALL"] = "Каждый за себя"
L["LOOT_METHOD_ROUND_ROBIN"] = "По очереди"
L["LOOT_METHOD_MASTER"] = "Ответственный за добычу"
L["LOOT_METHOD_GROUP"] = "Групповая добыча"
L["LOOT_METHOD_NEED_BEFORE_GREED"] = "Приоритет по нужности"

-- Threshold Labels
L["THRESHOLD_POOR_ONLY"] = "Только низкое"
L["THRESHOLD_COMMON_LOWER"] = "Обычное и ниже"
L["THRESHOLD_UNCOMMON_LOWER"] = "Необычное и ниже"
L["THRESHOLD_RARE_LOWER"] = "Редкое и ниже"
L["THRESHOLD_EPIC_LOWER"] = "Эпическое и ниже"

-- Shared by both item lists: the Master Looter ignore list and the Custom Roll List
L["ITEM_LIST_ADD"] = "Добавить предмет"
L["ITEM_LIST_ADD_DESCRIPTION"] =
	"Введите ID предмета или перетащите предмет сюда, чтобы добавить его в список."

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "Загрузка... (ID: %d)"

-- Appended to both the Automated Master Looting and the Automated Rolls description.
L["SAFETY_SKIP_NOTE"] =
	"Задания, рецепты, книги, транспорт, питомцы и легендарные предметы всегда пропускаются."

-- Version prefix in the options panel
L["VERSION_LABEL"] = "Версия"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] =
	"Собирайте снаряжение с Автоматическим ответственным за добычу, Автобросками и прозрачными Оповещениями. Задания, рецепты, транспорт, питомцы и легендарные предметы всегда в безопасности. Не позволяйте добыче замедлять ваш zug!"
L["WELCOME_MESSAGE"] = "Включить приветственное сообщение"
L["MINIMAP_BUTTON_ENABLE"] = "Включить кнопку на миникарте"

L["OPTIONS_COMMANDS_HEADER"] = "/Команды"
L["OPTIONS_COMMAND"] = "/gl"
L["OPTIONS_COMMAND_ALTERNATE"] = "/gogoloot"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Открывает меню настроек этого аддона."

L["SPEEDY_LOOT_HEADER"] = "Быстрый сбор"
L["SPEEDY_LOOT_DESCRIPTION"] =
	"Скрывает окно добычи для почти мгновенного сбора."
L["SPEEDY_LOOT_ENABLE"] = "Включить Быстрый сбор"

L["FEEDBACK_SUPPORT"] = "Обратная связь и поддержка"

-- CurseForge / GitHub / Discord / Wago are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"] =
	"Текущий способ распределения добычи и порог качества вашей группы."
L["MASTER_LOOTER_LOOT_METHOD"] = "Метод распределения добычи"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "Порог добычи"
L["MASTER_LOOTER_SET_BY"] = "(Установлено: %s)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] =
	"Только лидер группы может изменить способ распределения добычи и порог качества."

L["MASTER_LOOTER_AUTO_HEADER"] = "Автоматический ответственный за добычу"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] =
	"Распределяет добычу назначенным игрокам, пока вы ответственный за добычу."
L["MASTER_LOOTER_AUTO_ENABLE"] =
	"Включить автоматическое распределение добычи в инстансах"
L["MASTER_LOOTER_AUTO_OUTSIDE"] =
	"Включить автоматическое распределение добычи вне инстансов"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] =
	"Внимание: Поскольку добычу с мировых боссов нельзя передать, это не рекомендуется!"

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Быстрые настройки"
L["MASTER_LOOTER_POPUP_DESCRIPTION"] =
	"Открывает окно настройки добычи, когда вы становитесь распределяющим добычу."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Включить окно распределения добычи"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "Назначения добычи"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"Назначьте участника группы для получения предметов каждого уровня качества."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Себе"
L["MASTER_LOOTER_SEND_ALL"] = "Отправлять всю добычу"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] =
	"Отправляет предметы всех качеств одному игроку. Настройте отдельные качества ниже, чтобы изменить это."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Выберите, кто получит предметы качества %s."

L["MASTER_LOOTER_IGNORE_HEADER"] = "Список исключений"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Предметы из списка пропускают автоматическое распределение и остаются для ручной раздачи."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "Восстановить стандартный список исключений"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"Ваш список исключений для ответственного за добычу будет заменен стандартными предметами для вашего дополнения. Продолжить?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] =
	"Удалить этот предмет из списка исключений."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] =
	"Бросает кубик за вас на предметы, не персональные при получении, вплоть до выбранного качества, как в подземельях, так и в рейдах."
L["ROLLS_ENABLE"] = "Включить автоматические броски"
L["ROLLS_THRESHOLD_HEADER"] = "Пороги"
L["ROLLS_THRESHOLD_DESCRIPTION"] =
	"Задайте предел качества и бросок, который GogoLoot делает за вас, отдельно для подземелий и рейдов."
L["ROLLS_IN_PARTY"] = "В группе"
L["ROLLS_IN_RAID"] = "В рейде"
L["ROLLS_THRESHOLD_CHOOSE"] =
	"%s: автоматический бросок на предметы этого качества и ниже."
L["ROLLS_ACTION_CHOOSE"] =
	"%s: какой бросок GogoLoot делает за вас или оставляет бросок вам."

L["ROLLS_CUSTOM_LIST"] = "Пользовательский список бросков"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] =
	"Задайте отдельным предметам собственное действие броска, которое переопределяет порог."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "Включить пользовательский список бросков"
L["ROLLS_RESTORE_DEFAULTS"] =
	"Восстановить стандартный пользовательский список"
L["ROLLS_RESTORE_CONFIRM"] =
	"Ваш пользовательский список бросков будет заменен стандартными предметами для вашего дополнения. Продолжить?"
L["ROLLS_CHOOSE_ACTION"] =
	"Выберите автоматическое действие броска для этого предмета."
L["ROLLS_REMOVE_DESCRIPTION"] =
	"Удалить этот предмет из пользовательского списка бросков."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "Оповещения об обмене"
L["TRADE_DESCRIPTION"] =
	"Публикует сводку каждого завершенного обмена: предметы, чары и золото."
L["TRADE_ENABLE"] = "Включить оповещения об обмене"
L["TRADE_CONDITION"] = "Когда"
L["TRADE_CONDITION_ALWAYS"] = "Всегда"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Только в группе или рейде"
L["TRADE_CONDITION_RAID_ONLY"] = "Только в рейде"
L["TRADE_OUTPUT"] = "Вывод сообщений"
L["TRADE_OUTPUT_WHISPER"] = "Шепот"
L["TRADE_OUTPUT_GROUP"] = "Чат группы"
L["TRADE_EXAMPLE"] =
	"Пример: {rt4} GogoLoot // Передал [Предмет X] x2, [Предмет Y] игроку Fathom."
L["TRADE_TOOLTIP_DESCRIPTION"] =
	"Опубликовать сводку в чат по завершении этого обмена."
L["TRADE_TOOLTIP_OUTPUT"] = "Текущий вывод"
L["TRADE_CHECKBOX_LABEL"] = "Оповестить"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] =
	"Публикует действия ответственного за добычу в групповой чат. Автоматическое распределение использует порог качества, чтобы избежать спама; ручное распределение объявляется всегда."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Включить сообщения о получателях добычи"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] =
	"Пример: {rt4} GogoLoot // Aevala будет получать все Эпические предметы."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Оповещения об автоматическом распределении"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "Порог автооповещений"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] =
	"Пример: {rt4} GogoLoot // Передано [Предмет X] игроку Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] =
	"Примечание: каждый предмет, выданный вручную, объявляется всегда, независимо от качества."
