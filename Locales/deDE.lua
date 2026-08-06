local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "deDE")
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
	"Version %s. Einstellungen (einschließlich der Option, diese Nachricht zu deaktivieren) findest du unter Optionen > AddOns > GogoLoot. Gefällt dir das Add-on? Erzähl einem Freund davon! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Aus Sicherheitsgründen kann das Optionsmenü im Kampf nicht geöffnet werden."
L["MESSAGE_AUTO_LOOT_ENABLED"] =
	"Automatisches Plündern wurde aktiviert. Schnelles Plündern benötigt es, um zu funktionieren."
L["MESSAGE_NOT_MASTER_LOOTER"] = "Du bist derzeit nicht der Plündermeister."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "%s an %s gegeben."
L["MESSAGE_DESTINATION_SET"] = "%s erhält nun alle %s Gegenstände."
L["MESSAGE_DESTINATION_SET_ALL"] = "%s wird die gesamte Beute für die Gruppe aufbewahren."
L["MESSAGE_DESTINATION_LEFT"] = "%s hat die Gruppe verlassen. %s erhält nun alle %s Gegenstände."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "%s an %s gegeben, %s erhalten."
L["MESSAGE_TRADE_RECEIVED"] = "%s von %s erhalten."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "Die Taschen von %s sind voll: %s"
L["ERROR_MAX_COUNT"] = "%s hat bereits zu viele von: %s"
L["ERROR_OUT_OF_RANGE"] = "%s ist nicht in Reichweite: %s"
L["ERROR_NOT_IN_GROUP"] = "%s ist nicht mehr in der Gruppe oder im Schlachtzug: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "Konnte %s nicht geben: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "Plündermeister"
L["TAB_AUTOMATED_ROLLS"] = "Automatisches Würfeln"
L["TAB_ANNOUNCEMENTS"] = "Ankündigungen"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Aktiviert"
L["STATUS_DISABLED"] = "Deaktiviert"

--[[
    The tooltip titles each feature with its options-panel name rather than
    keeping its own copy: Automated Rolls uses TAB_AUTOMATED_ROLLS, Speedy Loot
    uses SPEEDY_LOOT_HEADER and SPEEDY_LOOT_DESCRIPTION. Only the roll
    description below is unique to the tooltip, where the panel's longer text
    would not fit.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] =
	"Würfelt für dich auf berechtigte Gegenstände bis zu der von dir gewählten Qualität."

L["MINIMAP_LEFT_CLICK"] = "Linksklick"
L["MINIMAP_RIGHT_CLICK"] = "Rechtsklick"
L["MINIMAP_TOGGLE"] = "Ein-/Ausschalten"
L["MINIMAP_OPTIONS"] = "GogoLoot Optionen"
L["MINIMAP_OPTIONS_KEYBIND"] = "Umschalt + Mittelklick"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- Quality Labels
L["QUALITY_POOR"] = "Schlecht"
L["QUALITY_COMMON"] = "Gewöhnlich"
L["QUALITY_UNCOMMON"] = "Ungewöhnlich"
L["QUALITY_RARE"] = "Selten"
L["QUALITY_EPIC"] = "Episch"

-- Roll Action Labels
L["ROLL_MANUAL"] = "Manuell"
L["ROLL_GREED"] = "Gier"
L["ROLL_NEED"] = "Bedarf"
L["ROLL_PASS"] = "Passen"

-- Loot Method Labels
L["LOOT_METHOD_FREE_FOR_ALL"] = "Jeder gegen jeden"
L["LOOT_METHOD_ROUND_ROBIN"] = "Reihum"
L["LOOT_METHOD_MASTER"] = "Plündermeister"
L["LOOT_METHOD_GROUP"] = "Plündern als Gruppe"
L["LOOT_METHOD_NEED_BEFORE_GREED"] = "Bedarf vor Gier"

-- Threshold Labels
L["THRESHOLD_POOR_ONLY"] = "Nur Schlecht"
L["THRESHOLD_COMMON_LOWER"] = "Gewöhnlich & Niedriger"
L["THRESHOLD_UNCOMMON_LOWER"] = "Ungewöhnlich & Niedriger"
L["THRESHOLD_RARE_LOWER"] = "Selten & Niedriger"
L["THRESHOLD_EPIC_LOWER"] = "Episch & Niedriger"

-- Shared by both item lists: the Master Looter ignore list and the Custom Roll List
L["ITEM_LIST_ADD"] = "Gegenstand hinzufügen"
L["ITEM_LIST_ADD_DESCRIPTION"] =
	"Gib eine Gegenstands-ID ein oder ziehe einen Gegenstand hierher, um ihn der Liste hinzuzufügen."

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "Laden... (ID: %d)"

-- Appended to the Automated Rolls description.
L["SAFETY_SKIP_NOTE"] =
	"Questgegenstände, Rezepte, Bücher, Reittiere, Haustiere und legendäre Gegenstände werden immer übersprungen."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] =
	"Rezepte, Bücher, Reittiere, Haustiere und legendäre Gegenstände werden immer übersprungen."

-- Version prefix in the options panel
L["VERSION_LABEL"] = "Version"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] =
	"Sauge Ausrüstung mit automatischem Plündermeistern, automatischem Würfeln und transparenten Ankündigungen ein. Questgegenstände, Rezepte, Reittiere, Haustiere und legendäre Gegenstände bleiben sicher. Lass die Beute deinen Zug nicht ausbremsen!"
L["WELCOME_MESSAGE"] = "Willkommensnachricht aktivieren"
L["MINIMAP_BUTTON_ENABLE"] = "Minikarten-Button aktivieren"

L["OPTIONS_COMMANDS_HEADER"] = "/Befehle"
L["OPTIONS_COMMAND"] = "/gl"
L["OPTIONS_COMMAND_ALTERNATE"] = "/gogoloot"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Öffnet das Optionsmenü dieses Add-ons."

L["SPEEDY_LOOT_HEADER"] = "Schnelles Plündern"
L["SPEEDY_LOOT_DESCRIPTION"] = "Blendet das Beutefenster aus, um fast sofort zu plündern."
L["SPEEDY_LOOT_ENABLE"] = "Schnelles Plündern aktivieren"

L["FEEDBACK_SUPPORT"] = "Feedback & Unterstützung"

-- CurseForge / GitHub / Discord / Wago are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "Aktuelle Beute-Einstellungen"
L["MASTER_LOOTER_LOOT_METHOD"] = "Beutemethode"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "Plünderschwellenwert"
--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them — including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "Diese Einstellungen werden von %s verwaltet."

L["MASTER_LOOTER_AUTO_DESCRIPTION"] = "Verteilt Beute an deine festgelegten Spieler, während du Plündermeister bist."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "Automatischen Plündermeister aktivieren"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Auch außerhalb von Instanzen"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] =
	"Vorsicht: Da Beute von Weltbossen nicht handelbar ist, wird dies nicht empfohlen!"
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "Questgegenstände einbeziehen"
L["MASTER_LOOTER_AUTO_QUEST_ITEMS_DESCRIPTION"] =
	"Verteilt auch Questgegenstände, um einen Charakter zu boosten, den du selbst spielst. Verteilt werden können nur Questgegenstände, die einmal für die Gruppe fallen. Was jeder Spieler auf der Quest für sich selbst plündert, etwa der Kopf eines Bosses, geht nie durch den Plündermeister."
--[[
    Both are shown whether the toggle is on or off: they are what somebody reads
    to decide whether to tick it at all. The NOTE covers what has to be true for
    the option to do anything; the CAUTION covers who it is for, and leads with
    the same word as the outside-instances one above it.
]]
L["MASTER_LOOTER_AUTO_QUEST_ITEMS_NOTE"] =
	"Da die meisten Questgegenstände von gewöhnlicher Qualität sind, funktioniert dies nur, wenn dein Plünderschwellenwert auf Gewöhnlich oder niedriger steht. Und selbst dann ist nicht jeder Questgegenstand für den Plündermeister geeignet."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS_CAUTION"] =
	"Vorsicht: Dies ist für Spieler gedacht, die gerne Dual-Boxen, und wird für Schlachtzüge nicht empfohlen."

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Schnelleinstellungen"
L["MASTER_LOOTER_POPUP_DESCRIPTION"] = "Öffnet ein Fenster zum Einrichten der Beute, sobald du Plündermeister wirst."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Plündermeister-Fenster aktivieren"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "Beuteziele"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "Wähle, wer die von GogoLoot verteilte Beute erhält."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Selbst"
L["MASTER_LOOTER_SEND_ALL"] = "Gesamte Beute senden an"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] =
	"Sende jede Qualitätsstufe an einen Spieler. Stelle einzelne Stufen unten abweichend ein."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Wähle, wer %s Gegenstände erhält."

L["MASTER_LOOTER_TIERS_INDIVIDUAL"] = "Qualitätsstufen einzeln festlegen"
L["MASTER_LOOTER_TIERS_INDIVIDUAL_DESCRIPTION"] =
	"Zeigt eine Zeile pro Qualitätsstufe, damit verschiedene Stufen an verschiedene Spieler gehen können."

--[[
    Appended to the toggle above only while the tier rows are collapsed, and only
    for this one state. Send All Loot To reads blank both when nothing is set and
    when the tiers disagree; it is honest about the first and silent about the
    second, so with the rows collapsed a per-tier setup would be invisible
    without this. A shared destination is already named in that dropdown and is
    deliberately not repeated here.
]]
L["MASTER_LOOTER_TIERS_SUMMARY_MIXED"] = "Stufen unterscheiden sich"

L["MASTER_LOOTER_IGNORE_HEADER"] = "Ignorieren-Liste"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Aufgeführte Gegenstände werden nicht automatisch verteilt und bleiben zur manuellen Zuweisung."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "Standard-Ignorieren-Liste wiederherstellen"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"Dadurch wird deine Plündermeister-Ignorieren-Liste durch die Standardgegenstände für deine Erweiterung ersetzt. Fortfahren?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Diesen Gegenstand aus der Ignorieren-Liste entfernen."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] =
	"Würfelt für dich auf nicht beim Aufheben gebundene Gegenstände bis zu der von dir gewählten Qualität, in Gruppen wie in Schlachtzügen."
L["ROLLS_ENABLE"] = "Automatisches Würfeln aktivieren"
L["ROLLS_THRESHOLD_HEADER"] = "Schwellenwerte"
L["ROLLS_THRESHOLD_DESCRIPTION"] =
	"Lege die Qualitätsgrenze und den Wurf fest, den GogoLoot für dich macht, getrennt für Gruppen und Schlachtzüge."
L["ROLLS_IN_PARTY"] = "In der Gruppe"
L["ROLLS_IN_RAID"] = "Im Schlachtzug"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: automatisch auf Gegenstände dieser Qualität und darunter würfeln."
L["ROLLS_ACTION_CHOOSE"] = "%s: welchen Wurf GogoLoot für dich macht, oder ob es dir den Wurf überlässt."

L["ROLLS_CUSTOM_LIST"] = "Benutzerdefinierte Würfelliste"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] =
	"Gegenstände auf dieser Liste haben ihre eigene Würfelregel, die den Schwellenwert überschreibt."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "Benutzerdefinierte Würfelliste aktivieren"
L["ROLLS_RESTORE_DEFAULTS"] = "Standard-Würfelliste wiederherstellen"
L["ROLLS_RESTORE_CONFIRM"] =
	"Dadurch wird deine benutzerdefinierte Würfelliste durch die Standardgegenstände für deine Erweiterung ersetzt. Fortfahren?"
L["ROLLS_CHOOSE_ACTION"] = "Wähle die automatische Würfelaktion für diesen Gegenstand."
L["ROLLS_REMOVE_DESCRIPTION"] = "Diesen Gegenstand aus der benutzerdefinierten Würfelliste entfernen."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "Handelsankündigungen"
L["TRADE_DESCRIPTION"] =
	"Postet eine Zusammenfassung jedes abgeschlossenen Handels: Gegenstände, Verzauberungen und Gold."
L["TRADE_ENABLE"] = "Handelsankündigungen aktivieren"
L["TRADE_CONDITION"] = "Wann"
L["TRADE_CONDITION_ALWAYS"] = "Immer"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Nur in Gruppe oder Schlachtzug"
L["TRADE_CONDITION_RAID_ONLY"] = "Nur im Schlachtzug"
L["TRADE_OUTPUT"] = "Nachrichtenausgabe"
L["TRADE_OUTPUT_WHISPER"] = "Flüstern"
L["TRADE_OUTPUT_GROUP"] = "Gruppenchat"
L["TRADE_EXAMPLE"] = "Beispiel: {rt4} GogoLoot // [Gegenstand X] x2, [Gegenstand Y] an Fathom gegeben."
L["TRADE_TOOLTIP_DESCRIPTION"] = "Postet eine Handelszusammenfassung im Chat, wenn dieser Handel abgeschlossen ist."
L["TRADE_TOOLTIP_OUTPUT"] = "Aktuelle Ausgabe"
L["TRADE_CHECKBOX_LABEL"] = "Ankündigen"

-- Master Looter Announcements
--[[
    Deliberately short. The two clauses this used to carry are both said better
    elsewhere on the panel: the quality threshold is a control the reader can
    see, and ANNOUNCE_MANUAL_NOTE says the manual half in the one place it
    answers a question the threshold has just raised.
]]
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Postet Plündermeister-Aktivitäten in den Gruppenchat."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Ankündigungen für Beuteempfänger aktivieren"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] =
	"Beispiel: {rt4} GogoLoot // Aevala erhält nun alle Epischen Gegenstände."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Automatische Plündermeister-Ankündigungen aktivieren"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "Automatischer Ankündigungsschwellenwert"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Beispiel: {rt4} GogoLoot // Hat [Gegenstand X] an Fathom gegeben."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] =
	"Hinweis: Jeder manuell verteilte Gegenstand wird immer angekündigt, unabhängig von der Qualität."
