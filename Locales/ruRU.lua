local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "ruRU")
if not L then return end

--[[
    Source locale: every other locale falls back to these strings. Translate
    the values only. Never change the L["KEY"] names, the %s / %d placeholders,
    or the {rt4} raid marker — code and other locales rely on them.
]]

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Версия %s. Настройки (включая возможность отключения этого сообщения) находятся в меню Настройки > Модификации > GogoLoot. Нравится аддон? Расскажите о нем друзьям! (="
L["MESSAGE_AUTO_LOOT_ENABLED"] = "Для правильной работы GogoLoot требуется Автосбор. Автосбор включен."
L["MESSAGE_NOT_MASTER_LOOTER"] = "В данный момент вы не являетесь ответственным за добычу."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

L["MESSAGE_LOOT_ANNOUNCE"] = "Передал %s игроку %s."
L["MESSAGE_DESTINATION_SET"] = "%s будет получать все предметы качества: %s."
L["MESSAGE_DESTINATION_LEFT"] = "%s покинул(а) группу. %s теперь будет получать все предметы качества: %s."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Передал %s игроку %s, получил %s."
L["MESSAGE_TRADE_GAVE"] = "Передал %s игроку %s."
L["MESSAGE_TRADE_RECEIVED"] = "Получил %s от %s."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "У выбранного игрока нет места в сумках для этого предмета."
L["ERROR_MAX_COUNT"] = "У выбранного игрока уже слишком много таких предметов."
L["ERROR_OUT_OF_RANGE"] = "Выбранный игрок находится вне зоны досягаемости."
L["ERROR_NOT_IN_GROUP"] = "Выбранный игрок больше не состоит в группе или рейде."

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "Ответственный"
L["TAB_AUTOMATED_ROLLS"] = "Автоброски"
L["TAB_ANNOUNCEMENTS"] = "Оповещения"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- GogoLoot is a proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "Enabled"
L["STATUS_DISABLED"] = "Disabled"

L["MINIMAP_AUTO_GREED"] = "Авто-'Не откажусь'"
L["MINIMAP_AUTO_GREED_DESCRIPTION"] = "Автоматически выбирает 'Не откажусь' для подходящих предметов выбранного или более низкого качества. Когда эта опция отключена, броски не автоматизируются — включая Пользовательский список бросков."
L["MINIMAP_SPEEDY_LOOT"] = "Быстрый сбор"
L["MINIMAP_SPEEDY_LOOT_DESCRIPTION"] = "Мгновенно собирает добычу без показа окна добычи."

L["MINIMAP_LEFT_CLICK"] = "ЛКМ"
L["MINIMAP_RIGHT_CLICK"] = "ПКМ"
L["MINIMAP_TOGGLE"] = "Переключить"
L["MINIMAP_OPTIONS"] = "GogoLoot Options"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Middle-Click"

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
L["ROLL_MANUAL"] = "Бросок вручную"
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

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "Загрузка... (ID: %d)"

-- Version prefix in the options panel and minimap tooltip
L["VERSION_LABEL"] = "Версия"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] = "Собирайте экипировку с помощью автоматического ответственного за добычу, автоматически бросайте 'Мне нужно' или 'Не откажусь' для предметов, не становящихся персональными при получении, и прозрачно объявляйте о каждом обмене в чате. Задания, рецепты, транспорт, питомцы и легендарные предметы всегда в безопасности. Не позволяйте добыче тормозить вас — зуг-зуг!"
L["WELCOME_MESSAGE"] = "Включить приветственное сообщение"
L["MINIMAP_BUTTON_ENABLE"] = "Enable Minimap Button"

L["COMMANDS"] = "/Команды"
L["COMMANDS_DESCRIPTION"] = "Открывает меню настроек GogoLoot."

L["SPEEDY_LOOT_HEADER"] = "Быстрый сбор"
L["SPEEDY_LOOT_DESCRIPTION"] = "Мгновенно собирает добычу без показа окна добычи, экономя время между убийствами."
L["SPEEDY_LOOT_ENABLE"] = "Включить Быстрый сбор"

L["FEEDBACK_SUPPORT"] = "Обратная связь и поддержка"

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
L["MASTER_LOOTER_LOOT_TYPE"] = "Тип распределения добычи (только чтение, измените в меню игры)"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "Порог добычи (только чтение, измените в меню игры)"
L["MASTER_LOOTER_SET_BY"] = "(Set by %s)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "Only the group leader can change the loot method and threshold."

L["MASTER_LOOTER_AUTO_HEADER"] = "Автоматический ответственный за добычу"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] = "Автоматически распределяет добычу между назначенными игроками, когда вы являетесь ответственным за добычу. Задания, книги, рецепты, транспорт, питомцы и легендарные предметы всегда пропускаются и будут отображаться в стандартном окне добычи."
L["MASTER_LOOTER_AUTO_ENABLE"] = "Включить автоматическое распределение добычи в инстансах"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Включить автоматическое распределение добычи вне инстансов"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] = "Внимание: Поскольку добычу с мировых боссов нельзя передать, это не рекомендуется!"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "Назначения добычи"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "Назначьте участника группы для получения предметов каждого уровня качества."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Себе"
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Выберите, кто получит предметы качества %s."

L["MASTER_LOOTER_IGNORE_HEADER"] = "Список исключений"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] = "Предметы из этого списка не будут распределяться автоматически и появятся в стандартном окне добычи для распределения вручную."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "Восстановить стандартный список исключений"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] = "Ваш список исключений для ответственного за добычу будет заменен стандартными предметами для вашего дополнения. Продолжить?"
L["MASTER_LOOTER_IGNORE_ADD_DESCRIPTION"] = "Введите ID предмета или вставьте ссылку на него, чтобы добавить в список исключений."
L["MASTER_LOOTER_IGNORE_ADD"] = "Добавить предмет"
L["MASTER_LOOTER_IGNORE_REMOVE"] = "Удалить"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Удалить этот предмет из списка исключений."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] = "Автоматически выбирает 'Не откажусь' для предметов, не становящихся персональными при получении, с выбранным или более низким качеством. Задания, книги, рецепты, транспорт, питомцы и легендарные предметы всегда пропускаются. Предметы, персональные при получении, никогда не разыгрываются автоматически по порогу, но их можно автоматизировать через Пользовательский список бросков ниже. Предметы из Пользовательского списка бросков следуют своему действию 'Мне нужно', 'Не откажусь' или 'Пас' вместо порога. Когда автоброски отключены, ничего не разыгрывается автоматически — включая Пользовательский список бросков."
L["ROLLS_ENABLE"] = "Включить автоматические броски"
L["ROLLS_THRESHOLD"] = "Порог автоматического 'Не откажусь'"

L["ROLLS_CUSTOM_LIST"] = "Пользовательский список бросков"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "Предметы из этого списка имеют собственные правила броска, которые игнорируют порог. Это единственный способ автоматизировать предметы, персональные при получении, такие как Камни Плети или Демонические руны. Настройте каждый предмет на Бросок вручную, Не откажусь, Мне нужно или Пас. Список действует только тогда, когда автоброски включены. Задания, книги, рецепты, транспорт, питомцы и легендарные предметы всегда пропускаются независимо от настроек."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "Включить пользовательский список бросков"
L["ROLLS_RESTORE_DEFAULTS"] = "Восстановить стандартный пользовательский список"
L["ROLLS_RESTORE_CONFIRM"] = "Ваш пользовательский список бросков будет заменен стандартными предметами для вашего дополнения. Продолжить?"
L["ROLLS_ADD_ITEM_DESCRIPTION"] = "Введите ID предмета или перетащите предмет сюда, чтобы добавить его в список."
L["ROLLS_ADD_ITEM"] = "Добавить предмет"
L["ROLLS_CHOOSE_ACTION"] = "Choose the automatic roll action for this item."
L["ROLLS_REMOVE"] = "Удалить"
L["ROLLS_REMOVE_DESCRIPTION"] = "Удалить этот предмет из пользовательского списка бросков."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "Оповещения об обмене"
L["TRADE_DESCRIPTION"] = "Автоматически публикует сводку завершенных обменов в чат, включая переданные предметы, чары и золото."
L["TRADE_ENABLE"] = "Включить оповещения об обмене"
L["TRADE_CONDITION"] = "Когда"
L["TRADE_CONDITION_ALWAYS"] = "Всегда"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Только в группе или рейде"
L["TRADE_CONDITION_RAID_ONLY"] = "Только в рейде"
L["TRADE_OUTPUT"] = "Вывод сообщений"
L["TRADE_OUTPUT_WHISPER"] = "Шепот"
L["TRADE_OUTPUT_GROUP"] = "Чат группы"
L["TRADE_EXAMPLE"] = "Пример: {rt4} Передал [Предмет X] x2, [Предмет Y] игроку Fathom. // GogoLoot"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Опубликовать сводку в чат по завершении этого обмена."
L["TRADE_TOOLTIP_OUTPUT"] = "Текущий вывод"
L["TRADE_CHECKBOX_LABEL"] = "Оповестить"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Публикует действия ответственного за добычу в групповой чат для прозрачности. Настройте отдельные пороги для автоматического и ручного распределения, чтобы обычный автосбор не засорял чат, а ручные отклонения оставались видимыми."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Оповещать о назначениях ответственного за добычу"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] = "Пример: {rt4} GogoLoot // Aevala будет получать все Эпическое предметы."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Оповещения об автоматическом распределении"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "Порог автооповещений"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Example: {rt4} GogoLoot // Gave [Item X] to Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] = "Note: Every item distributed manually is always announced, regardless of quality."
