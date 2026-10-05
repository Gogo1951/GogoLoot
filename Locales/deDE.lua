local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "deDE")
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
	"Version %s. Die Einstellungen (auch die Option, diese Nachricht abzuschalten) findest du unter Optionen > AddOns > GogoLoot. Gefällt dir das Add-on? Erzähl deinen Freunden davon! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Zur Sicherheit lässt sich das Optionsfenster im Kampf nicht öffnen."
-- Argument: the game's own name for its Auto Loot setting.
L["MESSAGE_AUTO_LOOT_SETTING_ON"] =
	"Die Spieleinstellung %s wurde eingeschaltet, da Blitz-Plündern und Automatisches Öffnen sie benötigen."
-- Argument: the game's own word for Master Looter.
L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"] = "Du bist derzeit nicht der %s."

-- Automated Opening. Argument: the number of free bag slots opening waits for.
L["MESSAGE_OPENING_PAUSED"] = "Automatisches Öffnen pausiert, bis du mindestens %d freie Taschenplätze hast."
L["MESSAGE_OPENING_RESUMED"] = "Automatisches Öffnen läuft wieder."

-- Argument: the item's link.
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] = "%s wird automatisch geöffnet, sobald es aufgeschlossen ist."
L["MESSAGE_ITEM_IGNORED"] = "%s steht auf Ignorieren, daher lässt Automatisches Öffnen es in Ruhe."
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s stammt von einem Schlachtzugs- oder Weltboss, daher lässt Automatisches Öffnen es ungeöffnet, damit du es handeln oder verkaufen kannst."
L["MESSAGE_ITEM_IGNORED_UNIQUE"] =
	"%s kann einen einzigartigen Gegenstand enthalten, daher überlässt Automatisches Öffnen dir das Öffnen."
L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] = "%s wurde im Beutefenster liegen gelassen, damit du es selbst plündern kannst."
-- The Openables List's Add Item refusing gear or a bag. Argument: the item's link, or its ID while uncached.
L["MESSAGE_ITEM_NOT_OPENABLE"] = "%s würde angelegt statt geöffnet, daher kann es nicht in die Behälterliste."

-- Automated Rolls' Print Item in Chat. Arguments: the game's word for the roll (Need or Greed), then the item's link.
L["MESSAGE_ROLL_PRINT"] = "Du hast %s auf %s gewürfelt."
-- The same after a Pass. Argument: the item's link.
L["MESSAGE_ROLL_PASS_PRINT"] = "Du hast bei %s gepasst."
--[[
    Hide Roll Messages' winner summary. Arguments: the winner, the item's link,
    then the winning roll as LOOT_TOASTS_ROLL_RESULT words it ("Greed 95"). The
    NO_ROLL forms are for a win whose roll wasn't seen; the YOU forms for the
    player's own win, without the winner.
]]
L["MESSAGE_ROLL_WON_PRINT"] = "%s hat %s gewonnen, %s."
L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"] = "%s hat %s gewonnen."
L["MESSAGE_ROLL_YOU_WON_PRINT"] = "Du hast %s gewonnen, %s."
L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"] = "Du hast %s gewonnen."

--[[
    A trade summary printed to the player alone (the trade Channel's Me Only):
    the Chat Announcement Templates below, printed, so each ends on its
    punctuation. Arguments as theirs: items, then the partner, then what came
    back.
]]
L["MESSAGE_GAVE_PRINT"] = "%s an %s gegeben."
L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "%s an %s gegeben, %s erhalten."
L["MESSAGE_TRADE_RECEIVED_PRINT"] = "%s von %s erhalten."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "%s an %s gegeben"
L["MESSAGE_DESTINATION_SET"] = "%s verwahrt Gegenstände der Qualität %s für die Gruppe"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s verwahrt die gesamte Beute für die Gruppe"
-- Arguments: the player who left, the master looter, then the qualities they held, joined by commas.
L["MESSAGE_DESTINATION_LEFT"] =
	"%s hat die Gruppe verlassen. %s verwahrt nun Gegenstände der Qualität %s für die Gruppe"
-- The same when they held every quality. Arguments: the player who left, then the master looter.
L["MESSAGE_DESTINATION_LEFT_ALL"] = "%s hat die Gruppe verlassen. %s verwahrt nun die gesamte Beute für die Gruppe"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "%s an %s gegeben, %s erhalten"
L["MESSAGE_TRADE_RECEIVED"] = "%s von %s erhalten"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "Die Taschen von %s sind voll: %s"
L["ERROR_MAX_COUNT"] = "%s hat bereits zu viele von: %s"
L["ERROR_OUT_OF_RANGE"] = "%s ist außer Reichweite: %s"
L["ERROR_NOT_IN_GROUP"] = "%s ist nicht mehr in der Gruppe oder im Schlachtzug: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "Beute konnte nicht an %s vergeben werden: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_AUTOMATED_ROLLS"] = "Automatisches Würfeln"
L["TAB_ITEM_OVERRIDES"] = "Gegenstandsausnahmen"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "Charakterregeln"
-- The panel for everything GogoLoot posts to chat.
L["TAB_ANNOUNCEMENTS"] = "Ankündigungen"
-- Headers of the two sections on the Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Handelsankündigungen"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Plündermeister-Ankündigungen"
L["TAB_LOOT_TOASTS"] = "Beutehinweise"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Filter"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Beutegeräusche"
L["TAB_AUTOMATED_OPENING"] = "Automatisches Öffnen"
-- Header of a section on the Automated Opening panel.
L["TAB_LOCKBOXES"] = "Schließkassetten"
L["TAB_OPENABLE_ITEMS"] = "Behälterliste"
L["TAB_MASTER_LOOTER"] = "Plündermeister"
-- Header of a section on the Master Looter panel.
L["TAB_LOOT_DESTINATIONS"] = "Beuteempfänger"
L["TAB_IGNORE_LIST"] = "Ignorierliste"

-- A child panel's title where the Settings tree can't nest it: the parent's title, then its own.
L["TAB_NESTED_FORMAT"] = "%s: %s"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Aktiviert"
L["STATUS_DISABLED"] = "Deaktiviert"
-- Automated Opening is on but waiting for empty bag slots.
L["STATUS_PAUSED"] = "Pausiert"

--[[
    The tooltip titles each feature with its options-panel name (Automated
    Master Looting excepted, since its panel is titled Master Looter), and
    gives each a description of its own, two lines at most: the panels' longer
    text doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Würfelt für dich auf geeignete Gegenstände bis zur gewählten Qualität."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] =
	"Öffnet Muscheln, Kisten, Geldbörsen und geknackte Schließkassetten in deinen Taschen."
L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"] = "Postet Handelszusammenfassungen und Plündermeister-Vergaben im Chat."
L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"] =
	"Vergibt Beute an die Spieler, die du für jede Qualität gewählt hast."
--[[
    The tooltip's read-back of each group context's roll, one line each under
    the description. Arguments: the game's own word for Party or Raid, the roll,
    then (all but Manual) the highest quality it rolls on.
]]
L["MINIMAP_ROLLS_SETTING"] = "%s: %s, %s"
L["MINIMAP_ROLLS_SETTING_MANUAL"] = "%s: %s"

L["MINIMAP_LEFT_CLICK"] = "Linksklick"
L["MINIMAP_RIGHT_CLICK"] = "Rechtsklick"
L["MINIMAP_SHIFT_LEFT_CLICK"] = "Umschalt + Linksklick"
L["MINIMAP_SHIFT_RIGHT_CLICK"] = "Umschalt + Rechtsklick"
-- The tooltip's title for the Automated Master Looting block, the feature its switch names.
L["MINIMAP_AUTOMATED_MASTER_LOOTING"] = "Automatische Beuteverteilung"
L["MINIMAP_TOGGLE"] = "Ein/Aus"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Verschlossene Gegenstände"
L["MINIMAP_OPTIONS"] = "GogoLoot-Optionen"
L["MINIMAP_OPTIONS_KEYBIND"] = "Umschalt + Mittelklick"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Manuell"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "Nur %s"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s und niedriger"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List brings text of its own), the hint the box shows while empty,
    and its button.
]]
L["ITEM_LIST_ADD"] = "Gegenstand hinzufügen"
L["ITEM_LIST_ADD_DESCRIPTION"] =
	"Gib eine Gegenstands-ID ein oder zieh einen Gegenstand hierher, um ihn der Liste hinzuzufügen."
L["ITEM_LIST_ADD_PLACEHOLDER"] = "Gegenstand hierher ziehen oder ID eingeben"
L["ITEM_LIST_ADD_BUTTON"] = "Hinzufügen"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "Gegenstände filtern..."
L["ITEM_LIST_FILTER_DESCRIPTION"] =
	"Zeigt nur die Gegenstände, deren Name, Gegenstands-ID, Einstellung oder Markierung deine Eingabe enthält."
L["ITEM_LIST_NO_MATCHES"] = "Keine Gegenstände passen zu deinem Filter."

-- The header over what the player just added to an item list, at its top until they filter it or close the window.
L["ITEM_LIST_NEW"] = "Neu"

-- The kind filter beside every item list's search box: its first choice (the rest are the list's headers) and its tooltip.
L["ITEM_LIST_KIND_ALL"] = "Alle Gegenstandsarten anzeigen"
L["ITEM_LIST_KIND_DESCRIPTION"] = "Zeigt jeden Gegenstand der Liste oder nur die Gegenstände einer Art."

--[[
    The Add from Bags dropdown beside every item list's add box: its resting
    text and tooltip, then what it reads, greyed out, when everything carried
    is already on the list. The Openables List brings a tooltip of its own.
]]
L["ITEM_LIST_ADD_FROM_BAGS"] = "Aus Taschen hinzufügen"
L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"] = "Fügt der Liste einen Gegenstand hinzu, den du bei dir trägst."
L["ITEM_LIST_BAGS_EMPTY"] = "In deinen Taschen ist nichts hinzuzufügen"
L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"] = "Jeder Gegenstand, den du bei dir trägst, steht bereits auf der Liste."

-- The button at the foot of every item list; each list's tooltip and confirmation say what it restores.
L["ITEM_LIST_RESTORE"] = "Standard wiederherstellen"

-- Placeholder shown in the item lists until the client caches an item's info.
L["ITEM_LOADING"] = "Wird geladen... (ID: %d)"

--[[
    Appended to the Automated Rolls description. Item Overrides is the one way
    a Bind on Pickup or quest item gets rolled on; nothing ever rolls on the
    rest.
]]
L["SAFETY_SKIP_NOTE"] =
	"Auf Rezepte, Bücher, Reittiere, Haustiere und legendäre Gegenstände wird nie gewürfelt, auf beim Aufheben gebundene Gegenstände und Questgegenstände nur, wenn sie in den Gegenstandsausnahmen stehen."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] =
	"Rezepte, Bücher, Reittiere, Haustiere und legendäre Gegenstände bleiben immer für dich liegen."

--[[
    Shown under each announcement's toggle, under Print Item in Chat and Hide
    Roll Messages, and under Enable Ignore Notifications. Argument: the
    message, as GogoLoot sends or prints it.
]]
L["OPTIONS_EXAMPLE"] = "Beispiel: %s"

-- The muted version line at the foot of the General panel.
L["OPTIONS_VERSION"] = "Version %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Blitz-Plündern leert Leichen im Handumdrehen, Automatisches Würfeln und die Beuteverteilung regeln, wer was bekommt, und Automatisches Öffnen knackt jede Muschel und Kiste. Beutehinweise zeigen dir alles, und Questgegenstände, Rezepte, Reittiere, Haustiere und legendäre Gegenstände bleiben unangetastet. Lass dich von der Beute nicht ausbremsen!"
L["WELCOME_MESSAGE"] = "Willkommensnachricht aktivieren"
L["WELCOME_MESSAGE_DESCRIPTION"] =
	"Zeigt bei jedem Einloggen die Version von GogoLoot und wo du diese Einstellungen findest."
L["MINIMAP_BUTTON_ENABLE"] = "Minikarten-Schaltfläche aktivieren"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Zeigt die GogoLoot-Schaltfläche an der Minikarte. Linksklick schaltet Automatisches Würfeln um, Rechtsklick Automatisches Öffnen, Umschalt + Linksklick Ankündigungen und Umschalt + Rechtsklick Automatische Beuteverteilung."

L["OPTIONS_COMMANDS_HEADER"] = "/Befehle"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Öffnet das Optionsfenster dieses Add-ons."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Funktionen"

L["SPEEDY_LOOT_ENABLE"] = "Blitz-Plündern aktivieren"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"Leert jede Leiche, sobald du sie öffnest, ohne das Beutefenster zu zeigen. Halte beim Plündern Umschalt gedrückt, um stattdessen das Fenster zu sehen. Schaltet die Spieleinstellung %s ein und pausiert, solange du %s bist."

L["FEEDBACK_SUPPORT"] = "Feedback & Unterstützung"

-- CurseForge / GitHub / Discord / Wago are proper nouns; do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "Beuteeinstellungen der Gruppe"
L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"] =
	"Legt fest, wie die Beute deiner Gruppe verteilt wird. Nur der Gruppenanführer kann das ändern."
L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"] =
	"Legt die niedrigste Gegenstandsqualität fest, für die die Plündermethode gilt. Nur der Gruppenanführer kann das ändern."

--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them, including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "Diese Einstellungen werden von %s verwaltet."
-- Shown in the same place while solo, where the two dropdowns are greyed out.
L["MASTER_LOOTER_SOLO_NOTE"] =
	"Tritt einer Gruppe bei, um diese Einstellungen zu ändern. Das kann nur der Gruppenanführer."

-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"] =
	"Vergibt jeden Gegenstand an den Spieler, den du für seine Qualität gewählt hast, sobald du das Beutefenster öffnest, solange du %s bist."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "Automatische Beuteverteilung aktivieren"
L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"] =
	"Schaltet die automatischen Vergaben ein oder aus. Sie laufen nur in Dungeons und Schlachtzügen, es sei denn, Auch außerhalb von Instanzen ist aktiv."
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Auch außerhalb von Instanzen"
L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Vergibt Beute auch in der offenen Welt. Beute von Weltbossen ist nicht handelbar, daher wird das nicht empfohlen."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "Questgegenstände einbeziehen"
L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"] =
	"Vergibt auch Questgegenstände, um einen Charakter zu boosten, den du selbst spielst. Funktioniert nur bei einer Seltenheitsschwelle von Verbreitet oder niedriger und nur für Questgegenstände, die einmal für die ganze Gruppe fallen. In Schlachtzügen nicht empfohlen."

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Schnelleinstellungen"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_POPUP_TOOLTIP"] = "Öffnet diese Einstellungen in einem Fenster, sobald du %s wirst."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Plündermeister-Fenster aktivieren"

L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"Wähle, wer jede Qualität erhält. Eine Qualität ohne gewählten Spieler bleibt für dich im Beutefenster."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Ich selbst"
-- The first choice in every destination dropdown: nobody picked, so that quality waits in the loot window.
L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"] = "Beutefenster"
L["MASTER_LOOTER_SEND_ALL"] = "Gesamte Beute an"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] = "Setzt alle Qualitäten unten auf einen Spieler."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Legt fest, wer Gegenstände der Qualität %s erhält."
-- Shown under Loot Destinations while Automated Master Looting is on and no quality has anybody picked.
L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] =
	"Noch ist niemand gewählt, daher wartet die gesamte Beute für dich im Beutefenster."

L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Gegenstände auf dieser Liste werden nie automatisch vergeben. Sie warten im Beutefenster, damit du sie selbst vergibst."
-- Shown on the Ignore List while Automated Master Looting is off.
L["MASTER_LOOTER_OFF_NOTE"] =
	"Diese Einstellungen werden nicht verwendet, solange die Automatische Beuteverteilung aus ist."
L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"] =
	"Ersetzt die Ignorierliste durch die Standardgegenstände deiner Erweiterung."
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"Deine Ignorierliste wird durch die Standardgegenstände deiner Erweiterung ersetzt. Fortfahren?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Entfernt diesen Gegenstand von der Ignorierliste."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_PANEL_DESCRIPTION"] =
	"Würfelt für dich %s, %s oder %s auf Gruppenbeute, bis zur gewählten Qualität, mit getrennten Einstellungen für Gruppen und Schlachtzüge."
L["ROLLS_ENABLE"] = "Automatisches Würfeln aktivieren"
L["ROLLS_ENABLE_DESCRIPTION"] =
	"Schaltet das automatische Würfeln ein oder aus, Gegenstandsausnahmen und Charakterregeln eingeschlossen."
L["ROLLS_IN_PARTY"] = "In der Gruppe"
L["ROLLS_IN_RAID"] = "Im Schlachtzug"
-- The caption of the quality row under In Party and under In Raid, shown while that roll isn't Manual.
L["ROLLS_UP_TO_QUALITY"] = "Bis zur Qualität"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: die höchste Qualität, auf die GogoLoot würfelt."
L["ROLLS_ACTION_CHOOSE"] = "%s: der Wurf, den GogoLoot macht. Manuell überlässt dir den Wurf."
-- Section headers on the Automated Rolls panel.
L["ROLLS_LOOT_THRESHOLDS_HEADER"] = "Seltenheitsschwellen"
L["ROLLS_MESSAGES_HEADER"] = "Würfelnachrichten"
L["ROLLS_PRINT_ITEM"] = "Gegenstand im Chat ausgeben"
L["ROLLS_PRINT_ITEM_DESCRIPTION"] =
	"Gibt jeden Gegenstand, auf den GogoLoot würfelt, und den gewählten Wurf in deinem Chat aus. Das Würfelfenster schließt sich, sobald GogoLoot würfelt, so siehst du hier trotzdem, was gefallen ist."
L["ROLLS_HIDE_MESSAGES"] = "Würfelnachrichten ausblenden"
-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_HIDE_MESSAGES_TOOLTIP"] =
	"Blendet die Chatzeilen des Spiels zu jedem Wurf aus: wer %s, %s oder %s gewählt hat, und jede gewürfelte Zahl. Was jeder Gewinner erhalten hat, bleibt im Chat."
-- The dropdown beside Hide Roll Messages.
L["ROLLS_WINNER_SUMMARY_PRINT"] = "Siegerübersicht ausgeben"
L["ROLLS_WINNER_SUMMARY_NONE"] = "Keine Siegerübersicht ausgeben"
L["ROLLS_WINNER_SUMMARY_DESCRIPTION"] =
	"Siegerübersicht ausgeben schreibt für jeden Gewinn eine Zeile in den Chat, mit Gewinner, Gegenstand und Siegerwurf, anstelle der Zeile des Spiels. Keine Siegerübersicht ausgeben lässt die Zeile des Spiels stehen, die den Gewinner nennt."

--[[
    Item Overrides, under Automated Rolls: items with a roll action of their
    own.
]]
L["ITEM_OVERRIDES_DESCRIPTION"] =
	"Legt den Wurf für bestimmte Gegenstände fest, vorrangig vor den Qualitätseinstellungen. Nur so würfelt GogoLoot auf einen beim Aufheben gebundenen Gegenstand oder Questgegenstand."
-- Shown on Item Overrides while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "Diese Einstellungen werden nicht verwendet, solange Automatisches Würfeln aus ist."
L["ITEM_OVERRIDES_ENABLE"] = "Gegenstandsausnahmen aktivieren"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"Verwendet die unten festgelegten Würfe. Ist das aus, folgen diese Gegenstände wie alle anderen den Qualitätseinstellungen."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] =
	"Ersetzt deine Gegenstandsausnahmen durch die Standardgegenstände deiner Erweiterung."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"Deine Gegenstandsausnahmen werden durch die Standardgegenstände deiner Erweiterung ersetzt. Fortfahren?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "Legt den automatischen Wurf für diesen Gegenstand fest."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "Entfernt diesen Gegenstand aus den Gegenstandsausnahmen."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "Diesen Gegenstand samt Wurf aus den Gegenstandsausnahmen entfernen?"

--[[
    Character Rules, under Automated Rolls: the stats whose gear each
    character leaves to the player. The stat names come from the game's own
    strings.
]]
-- Arguments: the game's own name for Intellect, then for the Warrior class, then Intellect again.
L["CHARACTER_RULES_PANEL_DESCRIPTION"] =
	"Überlässt dir Ausrüstung mit den gewählten Eigenschaften, für jeden Charakter einzeln: Stell %s bei deinem %s auf Manuell, und Ausrüstung mit %s behält ihr Würfelfenster, während auf alles andere wie gewohnt gewürfelt wird. Gegenstandsausnahmen haben weiterhin Vorrang."
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "Primäre Eigenschaften"
L["CHARACTER_RULES_SECONDARY"] = "Sekundäre Eigenschaften"
-- The first of the two choices in each stat's dropdown: no rule, so the rest of Automated Rolls decides.
L["CHARACTER_RULES_STANDARD"] = "Automatischer Standardwurf"
L["CHARACTER_RULES_ACTION_DESCRIPTION"] =
	"%s: Manuell überlässt dir Ausrüstung damit auf diesem Charakter, samt Würfelfenster. Automatischer Standardwurf würfelt darauf wie auf jeden anderen Gegenstand."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"Postet Handelszusammenfassungen und Plündermeister-Vergaben im Chat, damit alle wissen, wohin die Beute ging."
L["ANNOUNCEMENTS_ENABLE"] = "Ankündigungen aktivieren"
-- Also the tooltip of the same switch in the General panel's Features section, so it names no position on the panel.
L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"] =
	"Schaltet alle Ankündigungen ein oder aus. Solange das aus ist, sendet GogoLoot nichts an deine Gruppe oder Handelspartner, auch nicht für Gegenstände, die du selbst vergibst."

-- Trade Announcements
L["TRADE_DESCRIPTION"] =
	"Postet eine Zusammenfassung jedes abgeschlossenen Handels: Gegenstände, Verzauberungen und Gold."
L["TRADE_ENABLE"] = "Handelsankündigungen aktivieren"
L["TRADE_ENABLE_DESCRIPTION"] =
	"Postet eine Zusammenfassung, wenn ein Handel abgeschlossen ist. Das Kästchen Ankündigen im Handelsfenster ist derselbe Schalter."
L["TRADE_CONDITION_DESCRIPTION"] =
	"Legt fest, wann Handelszusammenfassungen gepostet werden: immer, in einer Gruppe oder einem Schlachtzug, oder nur im Schlachtzug."
L["TRADE_CONDITION_ALWAYS"] = "Immer"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "In Gruppe oder Schlachtzug"
L["TRADE_CONDITION_RAID_ONLY"] = "Im Schlachtzug"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "Kanal"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	"%s schickt jede Zusammenfassung an deinen Handelspartner. Gruppenchat postet sie in deine Gruppe oder deinen Schlachtzug und flüstert sie außerhalb einer Gruppe trotzdem. Nur ich zeigt sie in deinem eigenen Chat an und sendet sie an niemanden."
-- The Channel dropdown's choices (Whisper is the client's WHISPER), and the trade window checkbox tooltip's Channel value.
L["TRADE_OUTPUT_GROUP"] = "Gruppenchat"
L["TRADE_OUTPUT_SELF"] = "Nur ich"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Postet eine Handelszusammenfassung im Chat, wenn dieser Handel abgeschlossen ist."
L["TRADE_CHECKBOX_LABEL"] = "Ankündigen"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Sagt deiner Gruppe, wer welche Qualität verwahrt und was du vergeben hast."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Empfänger-Ankündigungen aktivieren"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"] =
	"Sagt der Gruppe, wer welche Qualität verwahrt, sobald du einen Empfänger festlegst."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Ankündigungen für automatische Vergaben aktivieren"
L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"] =
	"Kündigt jeden Gegenstand an, den GogoLoot automatisch vergibt, ab der gewählten Qualität."
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"] =
	"Automatische Vergaben unter dieser Qualität werden nicht angekündigt."

L["MASTER_LOOTER_ANNOUNCE_MANUAL"] = "Ankündigungen für manuelle Vergaben aktivieren"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"] =
	"Kündigt jeden Gegenstand an, den du selbst über das %s-Menü vergibst, unabhängig von seiner Qualität, im selben Wortlaut wie eine automatische Vergabe. Eine fehlgeschlagene Vergabe wird in jedem Fall gemeldet."

--------------------------------------------------------------------------------
-- Options: Loot Toasts and Loot Sounds
--------------------------------------------------------------------------------

-- Argument: the game's own name for the General chat tab.
L["LOOT_TOASTS_PANEL_DESCRIPTION"] =
	"Zeigt jeden Gegenstand und jede Münze, die du plünderst, für ein paar Sekunden auf dem Bildschirm, damit dir nichts entgeht, während Blitz-Plündern das Beutefenster ausblendet. Solange sie aktiv sind, können die Beutezeilen des Spiels aus deinem Chat-Reiter %s verschwinden."
L["LOOT_TOASTS_ENABLE"] = "Beutehinweise aktivieren"
-- Also the tooltip of the same switch in the General panel's Features section.
L["LOOT_TOASTS_SWITCH_DESCRIPTION"] =
	"Zeigt einen Beutehinweis für die Beute, die du unter Filter auswählst, deine eigene und die deiner Gruppe."
-- The dropdown beside Enable Loot Toasts: the game's Item Loot and Money Loot chat settings for the General tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"] = "Standard-Beutenachrichten deaktivieren"
L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"] = "Standard-Beutenachrichten aktivieren"
-- Arguments: the game's own names for its Item Loot and Money Loot chat settings, then for the General chat tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"] =
	"Standard-Beutenachrichten deaktivieren schaltet %s und %s in deinem Chat-Reiter %s ab, solange Beutehinweise aktiv sind, und wenn du Beutehinweise abschaltest, kehren sie zurück. Es ist dieselbe Einstellung wie in den Einstellungen dieses Reiters, und andere Reiter behalten ihre eigenen."

-- The Loot Toasts panel's two section headers.
L["LOOT_TOASTS_STACK_HEADER"] = "Stapel"
L["LOOT_TOASTS_TEXT_HEADER"] = "Text"

--[[
    Filters: a row per item type, captioned with the game's own name for it,
    each with a Mine box and a Group box. Weapon, Armor, Trade Goods and Gem
    carry a quality dropdown beside each ticked box. Argument in each tooltip:
    the row's item type, as the client names it.
]]
-- Shown on the Filters panel while Loot Toasts is off.
L["LOOT_TOASTS_OFF_NOTE"] = "Diese Einstellungen werden nicht verwendet, solange Beutehinweise aus sind."
-- The Filters panel's description.
L["LOOT_TOASTS_FILTERS_CAPTION"] =
	"Wähle, was einen Beutehinweis bekommt und was darin steht, für deine eigene Beute und die deiner Gruppe. Bei Beute deiner Gruppe steht der Name des Plündernden daneben."
L["LOOT_TOASTS_FILTER_MINE"] = "Meine"
L["LOOT_TOASTS_FILTER_GROUP"] = "Gruppe"
L["LOOT_TOASTS_FILTER_MINE_DESCRIPTION"] = "Zeigt Gegenstände vom Typ %s, die du plünderst."
L["LOOT_TOASTS_FILTER_GROUP_DESCRIPTION"] =
	"Zeigt Gegenstände vom Typ %s, die jemand in deiner Gruppe oder deinem Schlachtzug plündert, mit dem Namen des Plündernden."
L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"] =
	"Zeigt Gegenstände vom Typ %s, die du plünderst, ab der daneben gewählten Qualität."
L["LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION"] =
	"Zeigt Gegenstände vom Typ %s, die jemand in deiner Gruppe oder deinem Schlachtzug plündert, ab der daneben gewählten Qualität, mit dem Namen des Plündernden."
L["LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION"] =
	"Die niedrigste Qualität, ab der Gegenstände vom Typ %s, die du plünderst, einen Beutehinweis bekommen."
L["LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION"] =
	"Die niedrigste Qualität, ab der Gegenstände vom Typ %s, die deine Gruppe plündert, einen Beutehinweis bekommen."

-- The three Filters rows after the item types, which aren't item types themselves: their captions (Money's is the client's MONEY) and their boxes' tooltips.
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP"] = "Beim Aufheben gebunden"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION"] =
	"Zeigt jeden beim Aufheben gebundenen Gegenstand, den du plünderst, unabhängig von Typ oder Qualität."
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION"] =
	"Zeigt jeden beim Aufheben gebundenen Gegenstand, den deine Gruppe plündert, unabhängig von Typ oder Qualität."
L["LOOT_TOASTS_FILTER_OPENABLES"] = "Zum Öffnen"
L["LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION"] =
	"Zeigt die Behälter, die du plünderst und die GogoLoot öffnen kann, Schließkassetten eingeschlossen, unabhängig von ihrer Qualität."
L["LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION"] =
	"Zeigt die Behälter, die deine Gruppe plündert und die GogoLoot öffnen kann, Schließkassetten eingeschlossen, unabhängig von ihrer Qualität."
L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"] =
	"Zeigt einen Beutehinweis für die Münzen, die du plünderst. Das Spiel meldet keine Münzen anderer Spieler, daher gibt es kein Kästchen Gruppe."

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast it follows the item
    (LOOT_TOASTS_WON_ROLL); on a group member's, their name
    (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Siegerwurf"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"Fügt dem Beutehinweis den Wurf hinzu, mit dem du einen Gegenstand gewonnen hast, etwa (%s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Fügt dem Beutehinweis eines Gruppenmitglieds den Wurf hinzu, mit dem es einen Gegenstand gewonnen hat, etwa (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_WON_ROLL"] = "%s (%s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Taschenbestand"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Fügt den Beutehinweisen für deine eigene Beute hinzu, wie viele du jetzt bei dir trägst, etwa x3 (27), sobald du mehr trägst als die Anzahl im Hinweis."
-- How many came, after the item on a toast. Argument: the count.
L["LOOT_TOASTS_QUANTITY"] = "x%d"
-- Bag Count, after the item and its count. Argument: how many the player carries.
L["LOOT_TOASTS_BAG_COUNT"] = "(%d)"

-- Stack
L["LOOT_TOASTS_MAX_ITEMS"] = "Maximale Hinweise"
L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"] =
	"Die Höchstzahl gleichzeitiger Hinweise auf dem Bildschirm; der älteste macht Platz."
L["LOOT_TOASTS_UNLIMITED"] = "Unbegrenzt"
L["LOOT_TOASTS_DURATION"] = "Sekunden auf dem Bildschirm"
L["LOOT_TOASTS_DURATION_DESCRIPTION"] = "Wie viele Sekunden jeder Hinweis bleibt, bevor er ausblendet."
L["LOOT_TOASTS_GROWTH"] = "Wachstumsrichtung"
L["LOOT_TOASTS_GROWTH_DESCRIPTION"] = "Ob ältere Hinweise nach oben oder unten wandern, weg vom neuesten."
L["LOOT_TOASTS_GROW_UP"] = "Nach oben"
L["LOOT_TOASTS_GROW_DOWN"] = "Nach unten"
L["LOOT_TOASTS_ALIGN"] = "Ausrichtung"
L["LOOT_TOASTS_ALIGN_DESCRIPTION"] = "An welcher Seite des Griffs sich die Hinweise ausrichten."
L["LOOT_TOASTS_ALIGN_LEFT"] = "Links"
L["LOOT_TOASTS_ALIGN_RIGHT"] = "Rechts"

-- Text
L["LOOT_TOASTS_FONT"] = "Schriftart"
L["LOOT_TOASTS_FONT_DESCRIPTION"] = "Die Schriftart der Hinweise."
L["LOOT_TOASTS_FONT_DEFAULT"] = "Standard"
L["LOOT_TOASTS_FONT_SIZE"] = "Schriftgröße"
L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"] = "Die Größe des Hinweistexts; die Symbole wachsen und schrumpfen mit."
L["LOOT_TOASTS_OUTLINE"] = "Schriftkontur"
L["LOOT_TOASTS_OUTLINE_DESCRIPTION"] = "Die Kontur um den Hinweistext, die ihn vor hellem Hintergrund lesbar hält."
L["LOOT_TOASTS_OUTLINE_NONE"] = "Keine"
L["LOOT_TOASTS_OUTLINE_OUTLINE"] = "Kontur"
L["LOOT_TOASTS_OUTLINE_THICK"] = "Dicke Kontur"
L["LOOT_TOASTS_OUTLINE_MONOCHROME"] = "Einfarbig"
L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"] = "Einfarbige Kontur"

-- Position
L["LOOT_TOASTS_UNLOCK"] = "Position entsperren"
L["LOOT_TOASTS_LOCK"] = "Position sperren"
L["LOOT_TOASTS_RESET"] = "Position zurücksetzen"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "Zeigt oder verbirgt den Griff, mit dem du die Hinweise an eine neue Stelle ziehst."
L["LOOT_TOASTS_RESET_DESCRIPTION"] = "Setzt die Hinweise an ihre Standardposition oberhalb der Bildschirmmitte zurück."

-- The drag handle: its title, the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_HANDLE_TITLE"] = "GogoLoot-Beutehinweise"
L["LOOT_TOASTS_CLICK_DRAG"] = "Klicken + Ziehen zum Verschieben"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "Rechtsklick zum Sperren"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "Beutehinweise deaktivieren"
-- The stand-in item on the sample toasts, and in every Example line.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "Beispielgegenstand"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"Spielt einen Klang für Beute ab der gewählten Qualität und ein Taschengeräusch, wenn %s etwas erbeutet."
L["LOOT_SOUNDS_ENABLE"] = "Beutegeräusch aktivieren"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Spielt einen Klang, wenn du einen Gegenstand ab der gewählten Qualität von einer Leiche oder aus einer Truhe plünderst."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "Die niedrigste Gegenstandsqualität, die das Beutegeräusch abspielt."
L["LOOT_SOUNDS_TEST"] = "Spielt das Beutegeräusch ab."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "%s-Geräusch aktivieren"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "Spielt ein Taschengeräusch, wenn %s tatsächlich etwas erbeutet."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "Spielt das %s-Geräusch ab."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"Öffnet Muscheln, Kisten, Geldbörsen und geknackte Schließkassetten in deinen Taschen für dich, sobald du mindestens %d freie Taschenplätze hast."
L["AUTOMATED_OPENING_ENABLE"] = "Automatisches Öffnen aktivieren"
-- Also the tooltip of the same switch in the General panel's Features section. Argument: the game's own name for its Auto Loot setting.
L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"] =
	"Öffnet einen Behälter nach dem anderen und wartet im Kampf, beim Zaubern, in Verstohlenheit oder solange ein Händler, die Bank, ein Briefkasten, das Auktionshaus oder ein Handelsfenster offen ist. Schaltet die Spieleinstellung %s ein, solange es aktiv ist."
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"] = "Nur außerhalb von Instanzen"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Öffnet nichts, solange du in einem Dungeon, Schlachtzug oder Schlachtfeld bist."
L["AUTOMATED_OPENING_ONLY_SOLO"] = "Nur allein"
L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"] = "Öffnet nichts, solange du in einer Gruppe oder einem Schlachtzug bist."

-- Lockboxes
-- Arguments: the game's own name for the Rogue class, then for the Lockpicking skill.
L["LOCKBOXES_SECTION_DESCRIPTION"] =
	"Eine Schließkassette öffnet sich erst, wenn ein %s sie knackt. Diese Optionen zeigen dir die %s-Fertigkeit, die jede braucht, und melden dir, wenn eine wartet."
L["LOCKBOXES_TOOLTIPS_ENABLE"] = "Schließkassetten-Tooltips aktivieren"
-- Argument: the game's own name for the Lockpicking skill.
L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"] = "Fügt dem Tooltip jeder Schließkassette die nötige %s-Fertigkeit hinzu."
L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"] =
	"Legt fest, ob Schließkassetten-Tooltips nur für Schurken oder für jeden Charakter erscheinen."
L["LOCKBOXES_NOTIFICATIONS_ENABLE"] = "Schließkassetten-Meldungen aktivieren"
L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Meldet dir im Chat, wenn du eine Schließkassette plünderst, die sich öffnet, sobald sie aufgeschlossen ist."
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] =
	"Legt fest, ob Schließkassetten-Meldungen nur für Schurken oder für jeden Charakter erscheinen."
L["LOCKBOXES_FOR_ROGUES"] = "Für Schurken"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "Für alle Charaktere"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking" line (ITEM_REQ_SKILL), followed by a skill number. Argument:
    the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "Dein %s"

-- On the Automated Opening panel, below its switch.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "Ignorier-Meldungen aktivieren"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Meldet dir im Chat, wenn GogoLoot einen Behälter in Ruhe lässt, weil er in der Behälterliste auf Ignorieren steht, und warum."

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	"Jeder Behälter, den GogoLoot kennt, und was Automatisches Öffnen damit macht. Ignorieren lässt einen Behälter verschlossen, und Blitz-Plündern lässt ihn für dich im Beutefenster. Deine Änderungen gelten für alle deine Charaktere."
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] =
	"Solange Automatisches Öffnen aus ist, wird nur Ignorieren verwendet: Es hält Blitz-Plündern weiterhin davon ab, diese zu nehmen."
L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"] =
	"Setzt die Liste auf den Standard zurück: Jeder Gegenstand erhält wieder seine Standardeinstellung, entfernte Gegenstände kehren zurück und hinzugefügte verschwinden."
L["OPENABLE_ITEMS_RESTORE_CONFIRM"] =
	"Liste auf den Standard zurücksetzen? Jede geänderte Einstellung und jeder hinzugefügte oder entfernte Gegenstand wird rückgängig gemacht."
L["OPENABLE_ITEMS_ADD_DESCRIPTION"] =
	"Gib eine Gegenstands-ID ein oder zieh einen Gegenstand hierher, um ihn der Liste mit der Einstellung Öffnen hinzuzufügen. Ausrüstung und Taschen können nicht hinzugefügt werden, da sie beim Benutzen angelegt werden."
L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"] =
	"Fügt der Liste einen Gegenstand, den du bei dir trägst, mit der Einstellung Öffnen hinzu. Ausrüstung und Taschen werden nicht angeboten, da sie beim Benutzen angelegt werden."
L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"] =
	"Entfernt diesen Gegenstand von der Liste. GogoLoot behandelt ihn dann wie einen normalen Gegenstand: Er wird nie geöffnet und wie jeder andere geplündert."
L["OPENABLE_ITEMS_REMOVE_CONFIRM"] =
	"Diesen Gegenstand von der Liste entfernen? Füge ihn erneut hinzu, um ihn zurückzuholen."
L["OPENABLE_ITEMS_ACTION_DESCRIPTION"] = "Legt fest, was Automatisches Öffnen mit diesem Behälter macht."

-- The Openables List dropdown, one per item.
L["OPENING_ACTION_OPEN"] = "Öffnen"
L["OPENING_ACTION_IGNORE"] = "Ignorieren"

--[[
    The reason an item's default carries, shown as a short silver tag on its
    Openables List row whatever it is set to. Sell Sealed covers both a raid
    boss drop and a container that can hold Bind on Pickup loot.
]]
L["OPENING_TAG_SEALED"] = "Versiegelt verkaufen"
L["OPENING_TAG_UNIQUE"] = "Evtl. einzigartig"

--[[
    Each tag explained, under the item's tooltip on the Openables List. The
    item's own tooltip is directly above, so these never name the item.
]]
-- Argument: the game's own name for the Rogue class.
L["OPENING_REASON_LOCKED_CLASS"] =
	"Ein %s muss ihn knacken. Sobald er geknackt ist, öffnet er sich wie jeder andere Behälter."
L["OPENING_REASON_RAID"] =
	"Beute eines Schlachtzugs- oder Weltbosses. Ein ungeöffneter Behälter kann weiterhin gehandelt oder verkauft werden, oft für mehr, als sein Inhalt wert ist."
L["OPENING_REASON_BIND_ON_PICKUP"] =
	"Kann beim Aufheben gebundene Beute enthalten. Versiegelt kann er weiterhin gehandelt oder verkauft werden."
L["OPENING_REASON_UNIQUE"] =
	"Kann einen einzigartigen Gegenstand enthalten. Das Öffnen schlägt mit einem Fehler fehl, solange du bereits einen besitzt."
