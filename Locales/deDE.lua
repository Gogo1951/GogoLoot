local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "deDE")
if not L then return end

--------------------------------------------------------------------------------
-- Chat Messages (printed to local chat frame via PrintMessage)
--------------------------------------------------------------------------------

L["MSG_SETTINGS_RESET_UPDATE"] = "Die Einstellungen wurden für dieses Update zurückgesetzt. Verwende /gl, um deine Optionen zu überprüfen."
L["MSG_SETTINGS_RESET_DEFAULTS"] = "Alle Einstellungen wurden auf die Standardwerte zurückgesetzt."
L["MSG_AUTO_LOOT_ENABLED"] = "Automatisches Plündern ist erforderlich, damit GogoLoot ordnungsgemäß funktioniert. Automatisches Plündern wurde aktiviert."
L["MSG_NOT_MASTER_LOOTER"] = "Du bist derzeit nicht der Plündermeister."

--------------------------------------------------------------------------------
-- Chat Announcement Templates (sent to other players via GogoLoot:Announce)
--------------------------------------------------------------------------------

L["MSG_PREFIX"] = "{rt4} "
L["MSG_SUFFIX"] = " // GogoLoot"

L["MSG_LOOT_ANNOUNCE"] = "%s an %s gegeben."
L["MSG_DESTINATION_SET"] = "%s erhält nun alle %s Gegenstände."
L["MSG_DESTINATION_LEFT"] = "%s hat die Gruppe verlassen. %s erhält nun alle %s Gegenstände."

L["MSG_TRADE_GAVE_RECEIVED"] = "%s an %s gegeben, %s erhalten."
L["MSG_TRADE_GAVE"] = "%s an %s gegeben."
L["MSG_TRADE_RECEIVED"] = "%s von %s erhalten."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors (sent to group via GogoLoot:Announce)
--------------------------------------------------------------------------------

L["ERR_BAG_FULL"] = "Der Spieler, den du ausgewählt hast, hat keinen Platz mehr in den Taschen."
L["ERR_MAX_COUNT"] = "Der Spieler, den du ausgewählt hast, hat bereits zu viele dieser Gegenstände."
L["ERR_OUT_OF_RANGE"] = "Der ausgewählte Spieler ist nicht in Reichweite."
L["ERR_NOT_IN_GROUP"] = "Der ausgewählte Spieler ist nicht mehr in der Gruppe oder im Schlachtzug."

--------------------------------------------------------------------------------
-- Options Panel Tab Names
--------------------------------------------------------------------------------

L["TAB_GENERAL"] = "GogoLoot"
L["TAB_AUTOMATED_ROLLS"] = "Automatisches Würfeln"
L["TAB_MASTER_LOOTER"] = "Plündermeister"
L["TAB_TRADE_ANNOUNCEMENTS"] = "Ankündigungen"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "Aktiviert"
L["STATUS_DISABLED"] = "Deaktiviert"

L["MINIMAP_AUTO_GREED"] = "Auto-Gier"
L["MINIMAP_AUTO_GREED_DESC"] = "Würfelt automatisch Gier auf berechtigte Gegenstände auf oder unter dem ausgewählten Qualitätsschwellenwert."
L["MINIMAP_SPEEDY_LOOT"] = "Schnelles Plündern"
L["MINIMAP_SPEEDY_LOOT_DESC"] = "Nimmt Beute sofort auf, ohne das Beutefenster anzuzeigen."

L["MINIMAP_LEFT_CLICK"] = "Linksklick"
L["MINIMAP_RIGHT_CLICK"] = "Rechtsklick"
L["MINIMAP_TOGGLE"] = "Ein-/Ausschalten"
L["MINIMAP_HINT"] = "Weitere Einstellungen findest du unter Optionen > AddOns > GogoLoot."

--------------------------------------------------------------------------------
-- Quality Labels
--------------------------------------------------------------------------------

L["QUALITY_POOR"] = "Schlecht"
L["QUALITY_COMMON"] = "Gewöhnlich"
L["QUALITY_UNCOMMON"] = "Ungewöhnlich"
L["QUALITY_RARE"] = "Selten"
L["QUALITY_EPIC"] = "Episch"

--------------------------------------------------------------------------------
-- Roll Action Labels
--------------------------------------------------------------------------------

L["ROLL_MANUAL"] = "Manuelles Würfeln"
L["ROLL_GREED"] = "Gier"
L["ROLL_NEED"] = "Bedarf"
L["ROLL_PASS"] = "Passen"

--------------------------------------------------------------------------------
-- Loot Method Labels
--------------------------------------------------------------------------------

L["LOOT_METHOD_FFA"] = "Jeder gegen jeden"
L["LOOT_METHOD_ROUND_ROBIN"] = "Reihum"
L["LOOT_METHOD_MASTER"] = "Plündermeister"
L["LOOT_METHOD_GROUP"] = "Plündern als Gruppe"
L["LOOT_METHOD_NBG"] = "Bedarf vor Gier"

--------------------------------------------------------------------------------
-- Threshold Labels
--------------------------------------------------------------------------------

L["THRESHOLD_POOR_ONLY"] = "Nur Schlecht"
L["THRESHOLD_COMMON_LOWER"] = "Gewöhnlich & Niedriger"
L["THRESHOLD_UNCOMMON_LOWER"] = "Ungewöhnlich & Niedriger"
L["THRESHOLD_RARE_LOWER"] = "Selten & Niedriger"
L["THRESHOLD_EPIC_LOWER"] = "Episch & Niedriger"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL"] = "Allgemein"
L["GENERAL_DESC"] = "Grundeinstellungen, die gelten, wann immer GogoLoot aktiv ist."
L["SPEEDY_LOOT"] = "Schnelles Plündern aktivieren"
L["SPEEDY_LOOT_DESC"] = "Nimmt Beute sofort auf, ohne das Beutefenster anzuzeigen, was Zeit zwischen den Kills spart."

L["COMMANDS"] = "/Befehle"
L["COMMANDS_DESC"] = "Öffnet das Optionsmenü von GogoLoot."

L["RESET"] = "Zurücksetzen"
L["RESET_DESC"] = "Löscht alle GogoLoot-Einstellungen und stellt jede Option auf ihren Standardwert zurück."
L["RESET_ALL"] = "Alle GogoLoot-Optionen zurücksetzen"
L["RESET_CONFIRM"] = "Dadurch werden ALLE GogoLoot-Einstellungen auf ihre Standardwerte zurückgesetzt. Dies kann nicht rückgängig gemacht werden. Fortfahren?"

L["FEEDBACK_SUPPORT"] = "Feedback & Support"
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

L["ITEM_LOADING"] = "Laden... (ID: %d)"

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements

L["TRADE_HEADER"] = "Handelsankündigungen"
L["TRADE_DESC"] = "Postet automatisch eine Zusammenfassung abgeschlossener Handel in den Chat, einschließlich getauschter Gegenstände, Verzauberungen und Gold."
L["TRADE_ENABLE"] = "Handelsankündigungen aktivieren"
L["TRADE_ENABLE_DESC"] = "Postet eine Handelszusammenfassung, wenn ein Handel abgeschlossen ist."
L["TRADE_CONDITION"] = "Wenn in einer Gruppe"
L["TRADE_CONDITION_DESC"] = "Steuert, wann Handelsankündigungen aktiv sind."
L["TRADE_CONDITION_ALWAYS"] = "Immer"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Nur in Gruppe oder Schlachtzug"
L["TRADE_CONDITION_RAID_ONLY"] = "Nur im Schlachtzug"
L["TRADE_OUTPUT"] = "Nachrichtenausgabe"
L["TRADE_OUTPUT_DESC"] = "Wohin die Handelszusammenfassung gesendet wird."
L["TRADE_OUTPUT_WHISPER"] = "Flüstern"
L["TRADE_OUTPUT_GROUP"] = "Gruppenchat"
L["TRADE_OUTPUT_RAID"] = "Schlachtzugs-/Raidchat"
L["TRADE_EXAMPLE"] = "Beispiel: {rt4} Hat [Item X] x2, [Item Y] an Fathom gegeben. // GogoLoot"

L["TRADE_TOOLTIP_TITLE"] = "Handelsankündigungen"
L["TRADE_TOOLTIP_DESC"] = "Postet eine Handelszusammenfassung im Chat, wenn dieser Handel abgeschlossen ist."
L["TRADE_TOOLTIP_OUTPUT"] = "Aktuelle Ausgabe"
L["TRADE_CHECKBOX_LABEL"] = "Ankündigen"

-- Master Looter Announcements

L["ML_ANNOUNCE_HEADER"] = "Plündermeister Ankündigungen"
L["ML_ANNOUNCE_DESC"] = "Postet Plündermeister-Aktivitäten zur Transparenz in den Gruppenchat. Konfiguriere separate Schwellenwerte für automatische und manuelle Verteilungen, damit Routine-Auto-Loot den Chat nicht zuspammt, während manuelle Abweichungen sichtbar bleiben."

L["ML_ANNOUNCE_DESTINATION"] = "Nachrichten aktivieren, wenn Plündermeister gesetzt ist"
L["ML_ANNOUNCE_DESTINATION_DESC"] = "Kündigt an, wenn Beuteziele konfiguriert werden und wenn ein zugewiesener Spieler die Gruppe verlässt."
L["ML_ANNOUNCE_DESTINATION_EXAMPLE"] = "Beispiel: {rt4} Aevala erhält nun alle Epischen Gegenstände. // GogoLoot"

L["ML_ANNOUNCE_AUTO"] = "Automatische Plündermeister-Ankündigungen aktivieren"
L["ML_ANNOUNCE_AUTO_DESC"] = "Kündigt Gegenstände an, die automatisch von GogoLoot verteilt werden."
L["ML_ANNOUNCE_AUTO_THRESHOLD"] = "Automatischer Ankündigungsschwellenwert"
L["ML_ANNOUNCE_AUTO_THRESHOLD_DESC"] = "Kündige nur automatische Verteilungen ab dieser Qualität an."

L["ML_ANNOUNCE_MANUAL"] = "Manuelle Plündermeister-Ankündigungen aktivieren"
L["ML_ANNOUNCE_MANUAL_DESC"] = "Kündigt Gegenstände an, die manuell über das Dropdown-Menü verteilt werden. Standardmäßig niedriger als automatisch, damit Abweichungen von den Regeln für die Gruppe sichtbar sind."
L["ML_ANNOUNCE_MANUAL_THRESHOLD"] = "Manueller Ankündigungsschwellenwert"
L["ML_ANNOUNCE_MANUAL_THRESHOLD_DESC"] = "Kündige nur manuelle Verteilungen ab dieser Qualität an."

L["ML_ANNOUNCE_EXAMPLE"] = "Beispiel: {rt4} Hat [Item X] an Gogowarrior gegeben. // GogoLoot"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESC"] = "Würfelt automatisch Gier auf nicht beim Aufheben gebundene Gegenstände (BoE) auf oder unter der ausgewählten Qualität. Questgegenstände, Bücher, Rezepte, Reittiere, Haustiere und legendäre Gegenstände werden immer übersprungen. Beim Aufheben gebundene Gegenstände (BoP) werden niemals automatisch durch den Schwellenwert auf Gier gewürfelt, können jedoch über die benutzerdefinierte Würfelliste unten automatisiert werden."
L["ROLLS_ENABLE"] = "Automatisches Würfeln aktivieren"
L["ROLLS_ENABLE_DESC"] = "Würfelt automatisch Gier auf berechtigte Gegenstände auf oder unter dem Schwellenwert."
L["ROLLS_THRESHOLD"] = "Automatischer Gier-Schwellenwert"
L["ROLLS_THRESHOLD_DESC"] = "Für Gegenstände dieser Qualität oder niedriger wird automatisch Gier gewürfelt."

L["ROLLS_CUSTOM_LIST"] = "Benutzerdefinierte Würfelliste"
L["ROLLS_CUSTOM_LIST_DESC"] = "Gegenstände auf dieser Liste haben ihre eigene Würfelregel, die den Schwellenwert überschreibt. Dies ist die einzige Möglichkeit, beim Aufheben gebundene Gegenstände wie Geißelsteine oder Dämonische Runen zu automatisieren. Stelle jeden Gegenstand auf Manuelles Würfeln, Gier, Bedarf oder Passen ein. Questgegenstände, Bücher, Rezepte, Reittiere, Haustiere und legendäre Gegenstände werden unabhängig von der Einstellung immer übersprungen."
L["ROLLS_RESTORE_DEFAULTS"] = "Standard-Würfelliste wiederherstellen"
L["ROLLS_RESTORE_CONFIRM"] = "Dadurch wird deine benutzerdefinierte Würfelliste durch die Standardgegenstände für deine Erweiterung ersetzt. Fortfahren?"
L["ROLLS_ADD_ITEM_DESC"] = "Gib eine Gegenstands-ID ein oder ziehe einen Gegenstand hierher, um ihn der Liste hinzuzufügen."
L["ROLLS_ADD_ITEM"] = "Gegenstand hinzufügen"
L["ROLLS_ADD_ITEM_TOOLTIP"] = "Gegenstands-ID eingeben oder Gegenstandslink hierher ziehen."
L["ROLLS_CHOOSE_ACTION"] = "Wähle die automatische Würfelaktion für diesen Gegenstand."
L["ROLLS_REMOVE"] = "Entfernen"
L["ROLLS_REMOVE_DESC"] = "Diesen Gegenstand aus der benutzerdefinierten Würfelliste entfernen."

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["ML_LOOT_TYPE"] = "Beuteart (schreibgeschützt, Änderung über das Spielmenü)"
L["ML_LOOT_THRESHOLD"] = "Plünderschwellenwert (schreibgeschützt, Änderung über das Spielmenü)"

L["ML_AUTO_HEADER"] = "Automatischer Plündermeister"
L["ML_AUTO_DESC"] = "Verteilt Beute automatisch an bestimmte Spieler, wenn du der Plündermeister bist. Questgegenstände, Bücher, Rezepte, Reittiere, Haustiere und legendäre Gegenstände werden immer übersprungen und erscheinen in einem Standard-Beutefenster."
L["ML_AUTO_ENABLE"] = "Automatischen Plündermeister in Instanzen aktivieren"
L["ML_AUTO_ENABLE_DESC"] = "Verteilt Beute automatisch an konfigurierte Ziele."
L["ML_AUTO_OUTSIDE"] = "Automatischen Plündermeister außerhalb von Instanzen aktivieren"
L["ML_AUTO_OUTSIDE_CAUTION"] = "Vorsicht: Da Beute von Weltbossen nicht handelbar ist, wird dies nicht empfohlen!"

L["ML_DEST_HEADER"] = "Beuteziele"
L["ML_DEST_DESC"] = "Weise ein Gruppenmitglied zu, um Gegenstände jeder Qualitätsstufe zu erhalten."
L["ML_DEST_SELF"] = "Selbst"
L["ML_DEST_CHOOSE"] = "Wähle, wer %s Gegenstände erhält."

L["ML_IGNORE_HEADER"] = "Ignorieren-Liste"
L["ML_IGNORE_DESC"] = "Gegenstände auf dieser Liste werden nicht automatisch verteilt und erscheinen in einem Standard-Beutefenster zur manuellen Zuweisung."
L["ML_IGNORE_RESTORE"] = "Standard-Ignorieren-Liste wiederherstellen"
L["ML_IGNORE_RESTORE_CONFIRM"] = "Dadurch wird deine Plündermeister-Ignorieren-Liste durch die Standardgegenstände für deine Erweiterung ersetzt. Fortfahren?"
L["ML_IGNORE_ADD_DESC"] = "Gib eine Gegenstands-ID ein oder füge einen Gegenstandslink ein, um ihn der Ignorieren-Liste hinzuzufügen."
L["ML_IGNORE_ADD"] = "Gegenstand hinzufügen"
L["ML_IGNORE_ADD_TOOLTIP"] = "Gib eine Gegenstands-ID ein oder ziehe einen Gegenstand hierher, um ihn der Liste hinzuzufügen."
L["ML_IGNORE_REMOVE"] = "Entfernen"
L["ML_IGNORE_REMOVE_DESC"] = "Diesen Gegenstand aus der Ignorieren-Liste entfernen."