local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "deDE")
if not L then return end

--[[
    Source locale: every other locale falls back to these strings. Translate
    the values only. Never change the L["KEY"] names, the %s / %d placeholders,
    or the {rt4} raid marker — code and other locales rely on them.
]]

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Version %s. Einstellungen (einschließlich der Option, diese Nachricht zu deaktivieren) findest du unter Optionen > AddOns > GogoLoot. Gefällt dir das Add-on? Erzähl einem Freund davon! (="
L["MESSAGE_AUTO_LOOT_ENABLED"] = "Automatisches Plündern ist erforderlich, damit GogoLoot ordnungsgemäß funktioniert. Automatisches Plündern wurde aktiviert."
L["MESSAGE_NOT_MASTER_LOOTER"] = "Du bist derzeit nicht der Plündermeister."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

L["MESSAGE_LOOT_ANNOUNCE"] = "%s an %s gegeben."
L["MESSAGE_DESTINATION_SET"] = "%s erhält nun alle %s Gegenstände."
L["MESSAGE_DESTINATION_LEFT"] = "%s hat die Gruppe verlassen. %s erhält nun alle %s Gegenstände."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "%s an %s gegeben, %s erhalten."
L["MESSAGE_TRADE_GAVE"] = "%s an %s gegeben."
L["MESSAGE_TRADE_RECEIVED"] = "%s von %s erhalten."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "Der Spieler, den du ausgewählt hast, hat keinen Platz mehr in den Taschen."
L["ERROR_MAX_COUNT"] = "Der Spieler, den du ausgewählt hast, hat bereits zu viele dieser Gegenstände."
L["ERROR_OUT_OF_RANGE"] = "Der ausgewählte Spieler ist nicht in Reichweite."
L["ERROR_NOT_IN_GROUP"] = "Der ausgewählte Spieler ist nicht mehr in der Gruppe oder im Schlachtzug."

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "Plündermeister"
L["TAB_AUTOMATED_ROLLS"] = "Automatisches Würfeln"
L["TAB_ANNOUNCEMENTS"] = "Ankündigungen"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- GogoLoot is a proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "Aktiviert"
L["STATUS_DISABLED"] = "Deaktiviert"

L["MINIMAP_AUTO_GREED"] = "Auto-Gier"
L["MINIMAP_AUTO_GREED_DESCRIPTION"] = "Würfelt automatisch Gier auf berechtigte Gegenstände auf oder unter dem ausgewählten Qualitätsschwellenwert."
L["MINIMAP_SPEEDY_LOOT"] = "Schnelles Plündern"
L["MINIMAP_SPEEDY_LOOT_DESCRIPTION"] = "Nimmt Beute sofort auf, ohne das Beutefenster anzuzeigen."

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
L["ROLL_MANUAL"] = "Manuelles Würfeln"
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

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "Laden... (ID: %d)"

-- Version prefix in the options panel and minimap tooltip
L["VERSION_LABEL"] = "Version"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] = "Sauge Ausrüstung mit automatischem Plündermeister auf, würfle automatisch Bedarf oder Gier für nicht-BoP Drops und kündige jeden Handel transparent im Chat an. Questgegenstände, Rezepte, Reittiere, Haustiere und legendäre Gegenstände sind immer sicher. Lass dich von der Beute nicht ausbremsen — Zug zug!"
L["WELCOME_MESSAGE"] = "Willkommensnachricht aktivieren"
L["MINIMAP_BUTTON_ENABLE"] = "Minikarten-Button aktivieren"

L["COMMANDS"] = "/Befehle"
L["COMMANDS_DESCRIPTION"] = "Öffnet das Optionsmenü von GogoLoot."

L["SPEEDY_LOOT_HEADER"] = "Schnelles Plündern"
L["SPEEDY_LOOT_DESCRIPTION"] = "Nimmt Beute sofort auf, ohne das Beutefenster anzuzeigen, was Zeit zwischen den Kills spart."
L["SPEEDY_LOOT_ENABLE"] = "Schnelles Plündern aktivieren"

L["FEEDBACK_SUPPORT"] = "Feedback & Support"

-- CurseForge / GitHub / Discord are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

--------------------------------------------------------------------------------
-- Options: Profiles
--------------------------------------------------------------------------------

L["OPTIONS_RESET_ALL_PROFILES"] = "Alle Profile zurücksetzen"
L["OPTIONS_RESET_ALL_PROFILES_DESCRIPTION"] = "Setzt jedes Profil auf diesem Account auf die Standardeinstellungen zurück."
L["OPTIONS_RESET_ALL_PROFILES_CONFIRM"] = "Dadurch werden ALLE Profile auf deinem Account (jeder Charakter) auf die Standardeinstellungen zurückgesetzt. Dies kann nicht rückgängig gemacht werden. Fortfahren?"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"] = "Die aktuelle Beuteart und der Plünderschwellenwert deiner Gruppe."
L["MASTER_LOOTER_LOOT_TYPE"] = "Beuteart"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "Plünderschwellenwert"
L["MASTER_LOOTER_SET_BY"] = "(Eingestellt von %s)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "Nur der Gruppenanführer kann die Beuteart und den Schwellenwert ändern."

L["MASTER_LOOTER_AUTO_HEADER"] = "Automatischer Plündermeister"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] = "Verteilt Beute automatisch an bestimmte Spieler, wenn du der Plündermeister bist. Questgegenstände, Bücher, Rezepte, Reittiere, Haustiere und legendäre Gegenstände werden immer übersprungen und erscheinen in einem Standard-Beutefenster."
L["MASTER_LOOTER_AUTO_ENABLE"] = "Automatischen Plündermeister in Instanzen aktivieren"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Automatischen Plündermeister außerhalb von Instanzen aktivieren"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] = "Vorsicht: Da Beute von Weltbossen nicht handelbar ist, wird dies nicht empfohlen!"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "Beuteziele"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "Weise ein Gruppenmitglied zu, um Gegenstände jeder Qualitätsstufe zu erhalten."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Selbst"
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Wähle, wer %s Gegenstände erhält."

L["MASTER_LOOTER_IGNORE_HEADER"] = "Ignorieren-Liste"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] = "Gegenstände auf dieser Liste werden nicht automatisch verteilt und erscheinen in einem Standard-Beutefenster zur manuellen Zuweisung."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "Standard-Ignorieren-Liste wiederherstellen"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] = "Dadurch wird deine Plündermeister-Ignorieren-Liste durch die Standardgegenstände für deine Erweiterung ersetzt. Fortfahren?"
L["MASTER_LOOTER_IGNORE_ADD_DESCRIPTION"] = "Gib eine Gegenstands-ID ein oder füge einen Gegenstandslink ein, um ihn der Ignorieren-Liste hinzuzufügen."
L["MASTER_LOOTER_IGNORE_ADD"] = "Gegenstand hinzufügen"
L["MASTER_LOOTER_IGNORE_REMOVE"] = "Entfernen"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Diesen Gegenstand aus der Ignorieren-Liste entfernen."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] = "Würfelt automatisch Gier auf nicht beim Aufheben gebundene Gegenstände (BoE) auf oder unter der ausgewählten Qualität. Questgegenstände, Bücher, Rezepte, Reittiere, Haustiere und legendäre Gegenstände werden immer übersprungen."
L["ROLLS_ENABLE"] = "Automatisches Würfeln aktivieren"
L["ROLLS_THRESHOLD"] = "Automatischer Gier-Schwellenwert"

L["ROLLS_CUSTOM_LIST"] = "Benutzerdefinierte Würfelliste"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "Gegenstände auf dieser Liste haben ihre eigene Würfelregel, die den Schwellenwert überschreibt."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "Benutzerdefinierte Würfelliste aktivieren"
L["ROLLS_RESTORE_DEFAULTS"] = "Standard-Würfelliste wiederherstellen"
L["ROLLS_RESTORE_CONFIRM"] = "Dadurch wird deine benutzerdefinierte Würfelliste durch die Standardgegenstände für deine Erweiterung ersetzt. Fortfahren?"
L["ROLLS_ADD_ITEM_DESCRIPTION"] = "Gib eine Gegenstands-ID ein oder ziehe einen Gegenstand hierher, um ihn der Liste hinzuzufügen."
L["ROLLS_ADD_ITEM"] = "Gegenstand hinzufügen"
L["ROLLS_CHOOSE_ACTION"] = "Wähle die automatische Würfelaktion für diesen Gegenstand."
L["ROLLS_REMOVE"] = "Entfernen"
L["ROLLS_REMOVE_DESCRIPTION"] = "Diesen Gegenstand aus der benutzerdefinierten Würfelliste entfernen."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "Handelsankündigungen"
L["TRADE_DESCRIPTION"] = "Postet automatisch eine Zusammenfassung abgeschlossener Handel in den Chat, einschließlich getauschter Gegenstände, Verzauberungen und Gold."
L["TRADE_ENABLE"] = "Handelsankündigungen aktivieren"
L["TRADE_CONDITION"] = "Wenn"
L["TRADE_CONDITION_ALWAYS"] = "Immer"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Nur in Gruppe oder Schlachtzug"
L["TRADE_CONDITION_RAID_ONLY"] = "Nur im Schlachtzug"
L["TRADE_OUTPUT"] = "Nachrichtenausgabe"
L["TRADE_OUTPUT_WHISPER"] = "Flüstern"
L["TRADE_OUTPUT_GROUP"] = "Gruppenchat"
L["TRADE_EXAMPLE"] = "Beispiel: {rt4} Hat [Item X] x2, [Item Y] an Fathom gegeben. // GogoLoot"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Postet eine Handelszusammenfassung im Chat, wenn dieser Handel abgeschlossen ist."
L["TRADE_TOOLTIP_OUTPUT"] = "Aktuelle Ausgabe"
L["TRADE_CHECKBOX_LABEL"] = "Ankündigen"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Postet Plündermeister-Aktivitäten zur Transparenz in den Gruppenchat. Automatische Verteilungen verwenden einen Qualitätsschwellenwert, um Spam zu vermeiden; manuelle Verteilungen werden immer angekündigt."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Nachrichten aktivieren, wenn Plündermeister gesetzt ist"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] = "Beispiel: {rt4} GogoLoot // Aevala erhält nun alle Epischen Gegenstände."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Automatische Plündermeister-Ankündigungen aktivieren"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "Automatischer Ankündigungsschwellenwert"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Beispiel: {rt4} GogoLoot // Hat [Item X] an Fathom gegeben."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] = "Hinweis: Jeder manuell verteilte Gegenstand wird immer angekündigt, unabhängig von der Qualität."
