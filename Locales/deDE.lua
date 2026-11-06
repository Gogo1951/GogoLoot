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

-- The Full Name: leads every printed line, and names the options panels, window titles and the mini-map header. A proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
-- The Short Name: closes every sent message and names the add-on on tooltip lines other than the mini-map header. A proper noun; keep it untranslated.
L["ADDON_SHORT_NAME"] = "GogoLoot"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Version %s. Die Einstellungen (inklusive der Option, diese Nachricht abzuschalten) findest du unter Optionen > AddOns > GogoLoot. Gefällt dir dieses Add-on? Erzähl einem Freund davon, favorisiere es auf CurseForge oder gib ihm einen Star auf GitHub. (="
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
L["MESSAGE_LOOT_LEFT_ON_CORPSE"] = "%s Ein Teil der Beute ist an der Leiche liegen geblieben."
--[[
    Standard Loot Messages taking the General tab's loot lines off, or putting
    them back. Arguments: the game's own names for its Item Loot and Money Loot
    chat settings, then for the General chat tab.
]]
L["MESSAGE_STANDARD_LOOT_MESSAGES_OFF"] =
	"%s und %s wurden in deinem Chat-Reiter %s abgeschaltet, solange Beutehinweise aktiv sind."
L["MESSAGE_STANDARD_LOOT_MESSAGES_ON"] = "%s und %s wurden in deinem Chat-Reiter %s wieder eingeschaltet."

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

-- The first feature panel, holding the one Speedy Loot switch.
L["TAB_SPEEDY_LOOT"] = "Blitz-Plündern"
L["TAB_AUTOMATED_ROLLS"] = "Automatisches Würfeln"
L["TAB_ITEM_OVERRIDES"] = "Gegenstandsausnahmen"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "Charakterregeln"
-- The panel for everything GogoLoot posts to chat; also its row in the mini-map button's tooltip.
L["TAB_ANNOUNCEMENTS"] = "Beuteankündigungen"
-- Headers of the two sections on the Loot Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Handelsankündigungen"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Plündermeister-Ankündigungen"
L["TAB_LOOT_TOASTS"] = "Beutehinweise"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Filter"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Beutegeräusche"
L["TAB_AUTOMATED_OPENING"] = "Automatisches Öffnen"
-- A child panel of Automated Opening, beside the Openables List.
L["TAB_LOCKBOXES"] = "Schließkassetten"
L["TAB_OPENABLE_ITEMS"] = "Behälterliste"
-- Named for its switch, Enable Automated Master Looting. Roll Macro follows it.
L["TAB_MASTER_LOOTER"] = "Automatische Beuteverteilung"
-- Header of a section on the Automated Master Looting panel.
L["TAB_LOOT_DESTINATIONS"] = "Beuteempfänger"
L["TAB_IGNORE_LIST"] = "Ignorierliste"
-- The panel after Automated Master Looting, named for its switch, Enable Roll Macro.
L["TAB_ROLL_MACRO"] = "Würfelmakro"
-- The panel after Roll Macro, for the Loot Master and Loot Tracker windows; also the Loot Master window's title.
L["TAB_LOOT_MASTER"] = "Beutemeister"

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
    The tooltip titles each feature with its options-panel name, and gives
    each a description of its own, two lines at most: the panels' longer text
    doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Würfelt für dich auf geeignete Gegenstände bis zur gewählten Qualität."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] =
	"Öffnet Muscheln, Kisten, Geldbeutel und aufgeschlossene Schließkassetten in deinen Taschen."
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
L["MINIMAP_TOGGLE"] = "Ein/Aus"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Verschlossene Gegenstände"
-- Under the list. Argument: the game's own name for the Rogue class.
L["MINIMAP_LOCKED_ITEMS_HINT"] = "Ein %s kann sie für dich knacken."
-- The same, shown to a Rogue. Argument: the game's own name for Pick Lock.
L["MINIMAP_LOCKED_ITEMS_HINT_ROGUE"] = "Nutze %s, um sie zu öffnen."
L["MINIMAP_OPTIONS"] = "GogoLoot-Optionen"
L["MINIMAP_OPTIONS_KEYBIND"] = "Umschalt + Mittelklick"

-- Heads the items on the Roll List still on a trade clock, soonest first, under Locked Items.
L["MINIMAP_TRADABLE_LOOT"] = "Handelbare Beute"
-- Under the first few of them. Argument: how many more there are.
L["MINIMAP_TRADABLE_MORE"] = "%d weitere"
-- The loot windows' block: its title, how many items are on the Roll List, its description and its click.
L["MINIMAP_LOOT_WINDOWS"] = "Beutemeister und Beuteverfolgung"
L["MINIMAP_TO_HAND_OUT"] = "Zu vergeben: %d"
L["MINIMAP_LOOT_WINDOWS_DESCRIPTION"] = "Vergib per Wurf, was du noch handeln kannst, und verfolge jeden Wurf."
L["MINIMAP_MIDDLE_CLICK"] = "Mittelklick"
L["MINIMAP_OPEN"] = "Öffnen"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Manuell"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "Nur %s"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s und niedriger"

-- How many of an item, after its link: on a toast, in a trade summary, in the mini-map's Locked Items and in Add from Bags. Argument: the count.
L["ITEM_QUANTITY"] = "x%d"
-- An item and how many, the way the game's own loot lines write it, in the loot windows and their chat lines. Arguments: the item's link, then the count.
L["ITEM_QUANTITY_LINK"] = "%sx%d"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List and Item Overrides bring text of their own), the hint the
    box shows while empty, and its button.
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
-- Shown in place of the rows when the Ignore List or Item Overrides is empty, since both refill at login.
L["ITEM_LIST_EMPTY_REFILLS"] =
	"Diese Liste ist leer, daher kehren ihre Standardeinträge beim nächsten Einloggen zurück. Standard wiederherstellen holt sie sofort zurück."

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

-- Shown under every setting that prints or sends a chat line. Argument: the message, drawn as it arrives in chat.
L["OPTIONS_EXAMPLE"] = "Beispiel: %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Blitz-Plündern leert Leichen ohne Beutefenster, wählt je nach Qualität automatisch Bedarf, Gier oder Passen, und die Automatische Beuteverteilung verteilt die Beute für dich. Muscheln, Behälter und aufgeschlossene Schließkassetten öffnen sich von selbst. Schneller plündern, früher pullen."
L["WELCOME_MESSAGE"] = "Willkommensnachricht aktivieren"
L["WELCOME_MESSAGE_DESCRIPTION"] =
	"Zeigt bei jedem Einloggen die Version von GogoLoot und wo du diese Einstellungen findest."
L["MINIMAP_BUTTON_ENABLE"] = "Minikarten-Schaltfläche aktivieren"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Zeigt die GogoLoot-Schaltfläche an der Minikarte. Linksklick schaltet Automatisches Würfeln um, Rechtsklick Automatisches Öffnen, Umschalt + Linksklick Beuteankündigungen und Umschalt + Rechtsklick die Automatische Beuteverteilung."

L["OPTIONS_COMMANDS_HEADER"] = "/Befehle"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Öffnet das Optionsfenster dieses Add-ons."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Funktionen"

-- The opening line of the Speedy Loot panel, above its switch.
L["SPEEDY_LOOT_DESCRIPTION"] =
	"Nimmt alles von einer Leiche, sobald du sie öffnest, damit du nie auf das Beutefenster warten musst."
L["SPEEDY_LOOT_ENABLE"] = "Blitz-Plündern aktivieren"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"Leert jede Leiche, sobald du sie öffnest, ohne das Beutefenster zu zeigen. Halte beim Plündern Umschalt gedrückt, um stattdessen das Fenster zu sehen. Schaltet die Spieleinstellung %s ein und pausiert, solange du %s bist."

--[[
    The Roll Macro panel. %s is the macro's name, "- Roll", the same in every
    locale. General Macros is the tab of the game's Macros window that every
    character on the account shares; /macro is the game's command and stays
    English.
]]
L["ROLL_MACRO_DESCRIPTION"] =
	"Legt in deinen Allgemeinen Makros ein Makro namens %s mit Goldmünzen-Symbol an, damit jeder Charakter deines Accounts es auf eine Aktionsleiste ziehen kann."
--[[
    The three rows under it, each beside the game's name for a mouse button
    (MINIMAP_LEFT_CLICK and its neighbours). Right-click is the off-spec roll;
    a raid roll picks a number from 1 to the group's size.
]]
L["ROLL_MACRO_LEFT_CLICK"] = "1-100 würfeln"
L["ROLL_MACRO_RIGHT_CLICK"] = "1-99 würfeln"
L["ROLL_MACRO_MIDDLE_CLICK"] = "Schlachtzugswurf"
L["ROLL_MACRO_ENABLE"] = "Würfelmakro aktivieren"
-- Under the three rows, in silver: what Middle-Click's raid roll is for and how to read it.
L["ROLL_MACRO_RAID_ROLL_NOTE"] =
	"Ein Schlachtzugswurf vergibt einen Gegenstand an einen zufälligen Spieler. Gewürfelt wird von 1 bis zur Anzahl der Spieler in deiner Gruppe, also steht jede Zahl für einen Spieler: Zähl deine Schlachtzugs- oder Gruppenliste bis zur gewürfelten Zahl ab, um den Gewinner zu finden. Allein würfelt es 1-100."
L["ROLL_MACRO_SWITCH_DESCRIPTION"] =
	"Hält das Makro %s in deinen Allgemeinen Makros: Linksklick würfelt 1-100, Rechtsklick 1-99, Mittelklick einen Schlachtzugswurf. Schaltest du das ab, wird es gelöscht."
--[[
    Printed to chat when Enable Roll Macro is switched on or off, or the macro
    can't be made. In ROLL_MACRO_ADDED the second %s is /m, the game's command
    for its Macros window, drawn in blue.
]]
L["ROLL_MACRO_ADDED"] =
	"Das Makro %s liegt in deinen Allgemeinen Makros. Gib %s ein und zieh es auf eine Aktionsleiste."
L["ROLL_MACRO_REMOVED"] = "Das Makro %s wurde gelöscht."
L["ROLL_MACRO_FULL_LOADING"] =
	"Das Makro %s konnte nicht angelegt werden: Deine Allgemeinen Makros sind voll. Lösche eines, dann wird es nach dem nächsten Ladebildschirm angelegt."

--------------------------------------------------------------------------------
-- Options: Feedback & Support Panel
--------------------------------------------------------------------------------

-- "Star" stays GitHub's English button label in every locale; Discord, CurseForge, Wago and GitHub stay as written.
L["OPTIONS_LEVEL_UP_TITLE"] = "Hilf GogoLoot beim Stufenaufstieg"
L["OPTIONS_LEVEL_UP_INTRO"] =
	"Dieses Add-on wurde von Spielern gebaut, die dieses Spiel lieben und es für alle so unterhaltsam wie möglich machen wollen. Wir werden nie um Spenden bitten. Die wahre Belohnung ist das Wissen, dass unsere Arbeit das Spiel für dich ein bisschen besser macht. Wenn das so ist, würden wir gern davon hören!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Hier ein paar Wege, wie du uns helfen kannst, mehr Spieler zu erreichen."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Feedback geben: Einen Fehler gefunden oder eine Idee? Sag es uns auf Discord. Dein Feedback hilft uns, das Add-on zu verbessern, und Pull Requests sind immer willkommen."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Erzähl es einem Freund: Kennst du jemanden, dem dieses Add-on gefallen könnte? Erzähl ihm davon. Mundpropaganda hilft mehr Spielern, großartige Add-ons zu entdecken."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Auf CurseForge favorisieren: Öffne unten den CurseForge-Link, melde dich an und klick auf den Stern unter der Schaltfläche Download. Favoriten helfen mehr Spielern, das Add-on zu entdecken."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Star auf GitHub vergeben: Öffne unten den GitHub-Link, melde dich an und klick oben rechts auf Star. Stars helfen dem Projekt, sich für mehr kostenlose Entwicklerwerkzeuge zu qualifizieren."
L["OPTIONS_LEVEL_UP_THANKS"] = "Danke, dass du GogoLoot gewählt hast!"

L["OPTIONS_FEEDBACK"] = "Feedback & Unterstützung"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Links für Feedback und Hilfe"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "Um einen Link zu kopieren, klick in sein Feld und drück dann Strg+A und Strg+C."
-- The version line at the foot of the Feedback & Support panel.
L["OPTIONS_VERSION"] = "Version %s"

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

-- The pop-up's own title, which code joins with the add-on name: "Quick Settings // GogoLoot".
L["QUICK_SETTINGS_TITLE"] = "Schnelleinstellungen"
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
	"Deine Ignorierliste durch die Standardgegenstände deiner Erweiterung ersetzen?"
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
L["ROLLS_PARTY_AND_RAID_HEADER"] = "Würfeln in Gruppe und Schlachtzug"
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
-- Shown on Item Overrides and Character Rules while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "Diese Einstellungen werden nicht verwendet, solange Automatisches Würfeln aus ist."
L["ITEM_OVERRIDES_ENABLE"] = "Gegenstandsausnahmen aktivieren"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"Verwendet die unten festgelegten Würfe. Ist das aus, folgen diese Gegenstände wie alle anderen den Qualitätseinstellungen."
-- Shown under Enable Item Overrides while it is off.
L["ITEM_OVERRIDES_OFF_NOTE"] = "Diese Würfe werden nicht verwendet, solange die Gegenstandsausnahmen aus sind."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] =
	"Ersetzt deine Gegenstandsausnahmen durch die Standardgegenstände deiner Erweiterung."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"Deine Gegenstandsausnahmen durch die Standardgegenstände deiner Erweiterung ersetzen?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "Legt den automatischen Wurf für diesen Gegenstand fest."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "Entfernt diesen Gegenstand aus den Gegenstandsausnahmen."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "Diesen Gegenstand samt Wurf aus den Gegenstandsausnahmen entfernen?"
L["ITEM_OVERRIDES_ADD_DESCRIPTION"] =
	"Gib eine Gegenstands-ID ein oder zieh einen Gegenstand hierher, um ihn mit der Einstellung Manuell der Liste hinzuzufügen."

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
L["ANNOUNCEMENTS_ENABLE"] = "Beuteankündigungen aktivieren"
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
-- The trade window checkbox tooltip's line naming when summaries are posted.
L["TRADE_WHEN"] = "Wann"
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
-- The checkbox under Enable Loot Toasts, and its tooltip.
L["LOOT_TOASTS_TOOLTIPS_ENABLE"] = "Tooltips für Gegenstände in Beutehinweisen aktivieren"
L["LOOT_TOASTS_TOOLTIPS_DESCRIPTION"] =
	"Zeigt den Tooltip eines Gegenstands, wenn du auf seinen Hinweis zeigst. Aus ignorieren die Hinweise die Maus, sodass du Gegner und Leichen dahinter anvisieren und anklicken kannst."
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
-- The Container row is the bag class; clams, crates and lockboxes have the Openables row.
L["LOOT_TOASTS_FILTER_CONTAINER_MINE_DESCRIPTION"] =
	'Zeigt die Taschen, die du plünderst. Muscheln, Kisten und Schließkassetten findest du unter "Zum Öffnen".'
L["LOOT_TOASTS_FILTER_CONTAINER_GROUP_DESCRIPTION"] =
	'Zeigt die Taschen, die jemand in deiner Gruppe oder deinem Schlachtzug plündert, mit dem Namen des Plündernden. Muscheln, Kisten und Schließkassetten findest du unter "Zum Öffnen".'

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
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast "You Won" takes the
    looter's place (LOOT_TOASTS_YOU_WON_ROLL: the item, the roll); on a group
    member's, their name (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Siegerwurf"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"Fügt dem Beutehinweis den Wurf hinzu, mit dem du einen Gegenstand gewonnen hast, etwa (Gewonnen, %s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Fügt dem Beutehinweis eines Gruppenmitglieds den Wurf hinzu, mit dem es einen Gegenstand gewonnen hat, etwa (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_YOU_WON_ROLL"] = "%s (Gewonnen, %s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Taschenbestand"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Fügt den Beutehinweisen für deine eigene Beute hinzu, wie viele du jetzt bei dir trägst, etwa x3 (27), sobald du mehr trägst als die Anzahl im Hinweis."
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
L["LOOT_TOASTS_ALIGN_TOASTS"] = "Hinweise ausrichten"
L["LOOT_TOASTS_ALIGN_TOASTS_DESCRIPTION"] = "An welcher Seite des Griffs sich die Hinweise ausrichten."
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
L["LOOT_TOASTS_RESET_CONFIRM"] = "Die Beutehinweise an ihre Standardposition zurücksetzen?"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "Zeigt oder verbirgt den Griff, mit dem du die Hinweise an eine neue Stelle ziehst."
L["LOOT_TOASTS_RESET_DESCRIPTION"] = "Setzt die Hinweise an ihre Standardposition oberhalb der Bildschirmmitte zurück."

-- The drag handle, titled "Loot Toasts // GogoLoot" by code: the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_CLICK_DRAG"] = "Klicken + Ziehen zum Verschieben"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "Rechtsklick zum Sperren"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "Beutehinweise deaktivieren"
-- The stand-in item on the sample toasts the position preview shows; Example lines link real items.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "Beispielgegenstand"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"Spielt einen Klang für Beute ab der gewählten Qualität und ein Taschengeräusch, wenn %s etwas erbeutet."
-- The Loot Sounds panel's master switch, also in the General panel's Features section; its tooltip names no position on either.
L["LOOT_SOUNDS_SWITCH"] = "Beutegeräusche aktivieren"
L["LOOT_SOUNDS_SWITCH_DESCRIPTION"] = "Schaltet alle Beutegeräusche von GogoLoot ein oder aus."
-- The chime's own toggle, under the master switch.
L["LOOT_SOUNDS_ENABLE"] = "Beuteklang aktivieren"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Spielt einen Klang, wenn du einen Gegenstand ab der gewählten Qualität von einer Leiche oder aus einer Truhe plünderst."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "Die niedrigste Gegenstandsqualität, die den Beuteklang abspielt."
L["LOOT_SOUNDS_TEST"] = "Spielt den Beuteklang ab."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "%s-Geräusch aktivieren"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "Spielt ein Taschengeräusch, wenn %s tatsächlich etwas erbeutet."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "Spielt das %s-Geräusch ab."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"Öffnet Muscheln, Kisten, Geldbeutel und aufgeschlossene Schließkassetten in deinen Taschen für dich, sobald du mindestens %d freie Taschenplätze hast."
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
-- Shown under Enable Lockbox Notifications while it is on and Automated Opening is off.
L["LOCKBOXES_NOTIFICATIONS_OFF_NOTE"] =
	"Schließkassetten-Meldungen werden nicht verwendet, solange Automatisches Öffnen aus ist."
L["LOCKBOXES_FOR_ROGUES"] = "Für Schurken"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "Für alle Charaktere"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking (225)" line (ITEM_MIN_SKILL), or under GogoLoot's own
    ITEM_REQ_SKILL line where the client prints none, followed by a skill
    number. Argument: the game's own name for the Lockpicking skill.
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
-- The same while Speedy Loot is off too.
L["OPENABLE_ITEMS_ALL_OFF_NOTE"] =
	"Diese Einstellungen werden nicht verwendet, solange Automatisches Öffnen und Blitz-Plündern aus sind."
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
L["ROLL_CALL_START"] = "Würfelt um %s mit /roll, %d Sekunden"
-- Arguments: the seconds left, then the item.
L["ROLL_CALL_LAST_SECONDS"] = "Noch %d Sekunden für %s"
-- +10 Seconds. Arguments: the seconds added, then the item.
L["ROLL_CALL_EXTENDED"] = "%d Sekunden mehr für %s"
-- Arguments: the item, then the rolls that didn't count, each one of the four lines below, joined by commas.
L["ROLL_CALL_NOT_COUNTED"] = "Nicht gezählt bei %s: %s"
-- Arguments: the player, then their roll.
L["ROLL_CALL_NOT_COUNTED_EARLY"] = "Früher Wurf von %s (%d)"
L["ROLL_CALL_NOT_COUNTED_REPEAT"] = "Zusatzwurf von %s (%d)"
-- Arguments: the player, their roll, then the range they rolled in.
L["ROLL_CALL_NOT_COUNTED_RANGE"] = "Wurf von %s: %d (%d-%d)"
L["ROLL_CALL_NOT_COUNTED_NOT_TIED"] = "Wurf von %s: %d (nicht im Stechen)"
-- Arguments: the tied players, the roll they tied at, the item, the tied players again, then the seconds.
L["ROLL_CALL_TIE"] = "%s gleichauf mit %d bei %s. Nur %s, erneut /roll, %d Sekunden"
-- With Re-roll Ties off. Arguments: the tied players, the roll they tied at, then the item.
L["ROLL_CALL_TIE_HELD"] = "%s gleichauf mit %d bei %s. Ein Stechen folgt"
-- Arguments: the winner, the item, then the winning roll.
L["ROLL_CALL_WINS"] = "%s gewinnt %s mit %d"
-- After a disqualification or a restore changed who won. Arguments as above.
L["ROLL_CALL_NOW_WINS"] = "%s gewinnt jetzt %s mit %d"
-- Argument: the item.
L["ROLL_CALL_NOBODY"] = "Niemand hat auf %s gewürfelt. Es bleibt vorerst auf meiner Liste"
L["ROLL_CALL_NOBODY_LEFT"] = "Kein Wurf auf %s zählt mehr. Es kommt zurück auf meine Liste"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_DISQUALIFIED_NO_REASON"] = "Ich habe den Wurf von %s (%d) auf %s disqualifiziert"
-- The same with a reason. Arguments: the player, their roll, the item, then one of the ROLL_DISQUALIFY_REASON_ lines.
L["ROLL_CALL_DISQUALIFIED_BECAUSE"] = "Ich habe den Wurf von %s (%d) auf %s disqualifiziert: %s"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_RESTORED"] = "Ich habe den Wurf von %s (%d) auf %s wiederhergestellt"
-- Arguments: the item, then the seconds.
L["ROLL_CALL_VOIDED"] = "Ich habe alle Würfe auf %s annulliert. Würfelt erneut mit /roll, %d Sekunden"
-- Argument: the item.
L["ROLL_CALL_CANCELED"] = "Würfeln um %s abgebrochen. Haltet eure Würfe zurück"
L["ROLL_CALL_PAUSED"] = "Haltet eure Würfe zurück. %s ist pausiert"
-- Arguments: the item, then the seconds left.
L["ROLL_CALL_RESUMED"] = "Würfeln um %s läuft wieder, noch %d Sekunden"
-- Each argument: items, joined by commas.
L["ROLL_CALL_ROLL_ALL"] = "Wird der Reihe nach ausgewürfelt: %s"
L["ROLL_CALL_UP_FOR_ROLL"] = "Zum Auswürfeln: %s"
L["ROLL_CALL_FLOOR_LOOT"] = "Bodenbeute zum Auswürfeln: %s"
-- Drops by boss posted to the group, a line per boss. Arguments: the boss, then its drops, joined by commas.
L["DROPS_POST_LINE"] = "%s: %s"

--------------------------------------------------------------------------------
-- Roll Calls: Printed
--------------------------------------------------------------------------------

-- Outside a group there's nobody to send to. Argument: the line a group would have seen.
L["ROLL_CALL_SOLO_PREVIEW"] = "Du bist in keiner Gruppe, daher ging das an niemanden: %s"
-- Arguments: the winner, then the item.
L["ROLL_CALL_WON_PRINT"] =
	"%s hat %s gewonnen. Öffne einen Handel mit diesem Spieler, und GogoLoot legt es ins Fenster."

--------------------------------------------------------------------------------
-- Roll Tags and Reasons
--------------------------------------------------------------------------------

-- Beside a roll in the loot windows: why it doesn't count, or where it stands.
L["ROLL_TAG_EARLY"] = "Vor dem Aufruf gewürfelt"
L["ROLL_TAG_LATE"] = "Nach dem Ende gewürfelt"
L["ROLL_TAG_REPEAT"] = "Zusatzwurf, zählt nicht"
-- Arguments: the range the player rolled in.
L["ROLL_TAG_RANGE"] = "Falscher Bereich (%d-%d)"
L["ROLL_TAG_NOT_TIED"] = "Nicht im Stechen"
L["ROLL_TAG_DISQUALIFIED"] = "Disqualifiziert"
-- Argument: one of the reasons below.
L["ROLL_TAG_DISQUALIFIED_BECAUSE"] = "Disqualifiziert: %s"
L["ROLL_TAG_WINNER"] = "Gewinner"
L["ROLL_TAG_HIGHEST"] = "Bisher am höchsten"
L["ROLL_TAG_TIED"] = "Gleichstand"

-- The reasons offered when the loot master disqualifies a roll, also sent after ROLL_CALL_DISQUALIFIED_BECAUSE's colon.
L["ROLL_DISQUALIFY_REASON_NOT_ELIGIBLE"] = "Nicht berechtigt für diesen Gegenstand"
L["ROLL_DISQUALIFY_REASON_ALREADY_WON"] = "Hat heute schon einen Gegenstand gewonnen"
L["ROLL_DISQUALIFY_REASON_FOR_SOMEONE_ELSE"] = "Für jemand anderen gewürfelt"
L["ROLL_DISQUALIFY_REASON_NONE"] = "Kein Grund angegeben"

--------------------------------------------------------------------------------
-- Loot Master Window
--------------------------------------------------------------------------------

-- The tabs. Argument: how many items each holds.
L["LOOT_MASTER_TAB_ROLL_LIST"] = "Würfelliste (%d)"
L["LOOT_MASTER_TAB_FLOOR_LOOT"] = "Bodenbeute (%d)"
L["LOOT_MASTER_TAB_AWARDED"] = "Vergeben (%d)"
L["LOOT_MASTER_TAB_SOFT_RESERVES"] = "Soft-Reservierungen"

-- The Roll List's buttons.
L["LOOT_MASTER_ROLL"] = "Würfeln"
L["LOOT_MASTER_ROLL_AGAIN"] = "Erneut würfeln"
L["LOOT_MASTER_ROLL_ALL"] = "Alle auswürfeln"
L["LOOT_MASTER_PAUSE"] = "Pausieren"
L["LOOT_MASTER_RESUME"] = "Fortsetzen"
L["LOOT_MASTER_STOP"] = "Stoppen"
L["LOOT_MASTER_LIST_IN_RAID"] = "Im Schlachtzug auflisten"
L["LOOT_MASTER_MOVE_UP"] = "Nach oben"
L["LOOT_MASTER_MOVE_DOWN"] = "Nach unten"
-- Argument: the seconds added.
L["LOOT_MASTER_EXTEND"] = "+%d Sekunden"
L["LOOT_MASTER_CLOSE_NOW"] = "Jetzt beenden"
L["LOOT_MASTER_VOID"] = "Alle Würfe annullieren"
L["LOOT_MASTER_CANCEL_ROLL"] = "Würfeln abbrechen"
L["LOOT_MASTER_TAKE_OFF"] = "Von der Liste nehmen"
-- Argument: the winner.
L["LOOT_MASTER_GIVE"] = "An %s geben"
L["LOOT_MASTER_TRADE"] = "Mit %s handeln"
L["LOOT_MASTER_ANNOUNCE_WINNER"] = "Gewinner ankündigen"
L["LOOT_MASTER_HANDED_OUT"] = "Als vergeben markieren"
L["LOOT_MASTER_REROLL_TIED"] = "Gleichstand neu würfeln"
L["LOOT_MASTER_DISQUALIFY"] = "Disqualifizieren"
L["LOOT_MASTER_RESTORE"] = "Wiederherstellen"

-- A row's trade clock, where it has none to show.
L["LOOT_MASTER_ON_CORPSE"] = "Auf der Leiche"
L["LOOT_MASTER_CORPSE_CLOSED"] = "Leiche geschlossen"
L["LOOT_MASTER_BOUND"] = "Gebunden"
L["LOOT_MASTER_NO_LIMIT"] = "Keine Frist"

-- A row's state. Argument: how many rolls have landed.
L["LOOT_MASTER_STATUS_ROLLING"] = "Läuft, %d Würfe"
L["LOOT_MASTER_STATUS_TIE_BREAK"] = "Stechen, %d Würfe"
L["LOOT_MASTER_STATUS_ON_HOLD"] = "Angehalten, %d Würfe"
-- STATUS_TIED and STATUS_NOBODY also title a finished roll in the Loot Tracker.
L["LOOT_MASTER_STATUS_TIED"] = "Gleichstand"
L["LOOT_MASTER_STATUS_NOBODY"] = "Niemand gewürfelt"
L["LOOT_MASTER_STATUS_SOULBOUND"] = "Jetzt seelengebunden"
L["LOOT_MASTER_STATUS_UP_NEXT"] = "Als Nächstes"

-- The first line of an opened row.
L["LOOT_MASTER_HEADLINE_ROLLING"] = "Würfeln läuft, noch %d Sekunden."
L["LOOT_MASTER_HEADLINE_ON_HOLD"] = "Angehalten bei noch %d Sekunden."
-- Arguments: the tied players, then the seconds left.
L["LOOT_MASTER_HEADLINE_TIE_BREAK"] = "Stechen für %s, noch %d Sekunden."
-- Arguments: the winner, then the winning roll.
L["LOOT_MASTER_HEADLINE_WON"] = "%s hat mit %d gewonnen."
-- Arguments: the tied players, then the roll they tied at.
L["LOOT_MASTER_HEADLINE_TIED"] = "%s gleichauf mit %d."
L["LOOT_MASTER_HEADLINE_SOULBOUND"] = "Jetzt seelengebunden, daher nicht mehr handelbar."
-- Argument: the boss. Also under the game's own trade line on a bag item's tooltip while it is on the Roll List.
L["LOOT_MASTER_LOOTED_FROM"] = "Erbeutet von %s."
L["LOOT_MASTER_FROM_FLOOR_LOOT"] = "Aus der Bodenbeute."
-- After the line above. Argument: how long, in the game's own words for time.
L["LOOT_MASTER_TRADABLE_FOR"] = "Noch %s handelbar."
-- Headings over a row's rolls; ROUND_SO_FAR also heads an open roll in the Loot Tracker.
L["LOOT_MASTER_ROUND_SO_FAR"] = "Bisherige Würfe"
L["LOOT_MASTER_ROUND_ROLLS"] = "Würfe"
L["LOOT_MASTER_ROUND_FIRST"] = "Erster Wurf"
L["LOOT_MASTER_ROUND_TIE_BREAK"] = "Stechen"
-- Arguments: how many, then their names. Also in the Loot Tracker.
L["LOOT_MASTER_HASNT_ROLLED"] = "Noch nicht gewürfelt (%d): %s"

L["LOOT_MASTER_EMPTY"] =
	"Noch nichts zu vergeben. Handelbare Beute, die du aufhebst, landet von selbst hier; mit Alt-Klick fügst du jeden anderen Taschengegenstand hinzu."
-- The line beside the Roll List's buttons.
L["LOOT_MASTER_STATE_PAUSED"] = "Pausiert."
L["LOOT_MASTER_STATE_ROLL_ALL"] = "Alle auswürfeln: noch %d."
L["LOOT_MASTER_STATE_ONE_AT_A_TIME"] = "Ein Wurf nach dem anderen."
L["LOOT_MASTER_STATE_WAITING"] = "Warten auf einen Wurf: %d."
-- The foot of the Roll List. Arguments: how many items, then the time left on the soonest trade clock.
L["LOOT_MASTER_FOOTER"] = "Zu vergeben: %d."
L["LOOT_MASTER_FOOTER_CLOCK"] = "Zu vergeben: %d, die nächste Handelsfrist endet in %s."
L["LOOT_MASTER_ALT_CLICK_HINT"] = "Alt-Klick auf einen Taschengegenstand fügt ihn hinzu"

-- The Disqualify window.
L["LOOT_MASTER_DISQUALIFY_TITLE"] = "Wurf disqualifizieren"
-- Arguments: the player, their roll, then the item.
L["LOOT_MASTER_DISQUALIFY_BODY"] =
	"Den Wurf von %s (%d) für %s aus der Wertung nehmen? Du kannst ihn später wiederherstellen."
L["LOOT_MASTER_DISQUALIFY_REASON"] = "Grund"
L["LOOT_MASTER_DISQUALIFY_TELLS"] = "GogoLoot sagt der Gruppe:"
-- Argument: the item.
L["LOOT_MASTER_VOID_CONFIRM"] = "Alle Würfe auf %s verwerfen und erneut zum Würfeln aufrufen?"

-- Printed by the Loot Master.
L["LOOT_MASTER_ROLL_ALL_DONE"] =
	"Alle auswürfeln ist fertig. Jeder Gegenstand auf der Würfelliste wurde ausgewürfelt."
L["LOOT_MASTER_ROLL_ALL_PAUSED"] = "Alle auswürfeln pausiert. Nichts Neues startet, bis du Fortsetzen drückst."
L["LOOT_MASTER_ROLL_ALL_RESUMED"] = "Alle auswürfeln fortgesetzt."
L["LOOT_MASTER_ROLL_ALL_STOPPED"] = "Alle auswürfeln gestoppt. Ein laufender Wurf wird noch beendet."
-- Arguments: the item, then the whole minutes left.
L["LOOT_MASTER_TRADE_TIME_LOW"] = "%s kann noch %d Minuten gehandelt werden."
-- Argument: the item.
L["LOOT_MASTER_TRADE_TIME_OVER"] = "%s kann nicht mehr gehandelt werden."
-- Arguments: the item, the winner, then their winning roll.
L["LOOT_MASTER_TRADE_FILLED"] = "%s ins Handelsfenster für %s gelegt (gewonnen mit %d)."
-- Arguments: the winner, then the item.
L["LOOT_MASTER_NOT_A_CANDIDATE"] = "%s kann %s nicht von dieser Leiche erhalten."
-- Argument: the item.
L["LOOT_MASTER_ADDED"] = "%s steht jetzt auf der Würfelliste."
L["LOOT_MASTER_NOT_TRADABLE"] = "%s ist nicht handelbar und kann daher nicht auf die Würfelliste."
-- Argument: how many joined.
L["LOOT_MASTER_FLOOR_ADDED"] = "Bodenbeute auf die Würfelliste übernommen: %d."
L["LOOT_MASTER_OFF"] = "Der Beutemeister ist aus. Schalte ihn unter Optionen > AddOns > GogoLoot > Beutemeister ein."

-- A bag item's tooltip, under the game's own trade line, while it is on the Roll List.
L["LOOT_MASTER_TOOLTIP_ON_ROLL_LIST"] = "Auf der Würfelliste."
-- Arguments: the winner, then their winning roll.
L["LOOT_MASTER_TOOLTIP_WON_BY"] = "Gewonnen von %s mit %d."

-- Floor Loot. The add box, filter and Add from Bags use the item lists' own words (ITEM_LIST_*).
L["LOOT_MASTER_FLOOR_DESCRIPTION"] =
	"Beute ohne Handelsfrist, die du auswürfeln willst: Materialien, Rezepte, beim Anlegen gebundene Ausrüstung. Die Liste startet leer, also wird nur ausgewürfelt, was du hinzufügst. Ein Wurf pro Stapel."
L["LOOT_MASTER_FLOOR_EMPTY"] =
	"Noch nichts hier. Wähle etwas unter Aus Taschen hinzufügen oder zieh einen Gegenstand auf das Feld oben."
-- Argument: how many the bags hold.
L["LOOT_MASTER_FLOOR_IN_BAGS"] = "In Taschen: %d"
L["LOOT_MASTER_FLOOR_ON_ROLL_LIST"] = "Auf der Würfelliste"
L["LOOT_MASTER_FLOOR_REMOVE"] = "Nimmt diesen Gegenstand aus der Bodenbeute."
-- The heading for an item whose kind the game hasn't said yet.
L["LOOT_MASTER_FLOOR_OTHER"] = "Sonstiges"
L["LOOT_MASTER_FLOOR_ADD_ALL"] = "Alle auf die Würfelliste"
-- Add from Bags' two headings.
L["LOOT_MASTER_FLOOR_MENU_PICKED_UP"] = "In dieser Instanz aufgehoben"
L["LOOT_MASTER_FLOOR_MENU_BAGS"] = "Außerdem in deinen Taschen"
-- Argument: what was typed.
L["LOOT_MASTER_FLOOR_NOT_FOUND"] = 'Nichts Handelbares in deinen Taschen passt zu "%s".'

-- Awarded.
L["LOOT_MASTER_AWARDED_EMPTY"] =
	"Noch nichts vergeben. Ein gewonnener Gegenstand landet hier, sobald der Gewinner ihn hat."
-- Arguments: the winning roll, then the time it was handed out.
L["LOOT_MASTER_AWARDED_ROLLED"] = "Wurf %d, %s"
-- Argument: the time it was handed out.
L["LOOT_MASTER_AWARDED_GIVEN"] = "Vergeben: %s"
L["LOOT_MASTER_AWARDED_CLEAR"] = "Leeren"

-- Soft Reserves, a placeholder for now.
L["LOOT_MASTER_SOFT_RESERVES_DESCRIPTION"] =
	"Füge hier einen Text mit Soft-Reservierungen ein, um zu sehen, wer was reserviert hat. Kommt bald: Dieser Reiter ist vorerst nur ein Platzhalter."
L["LOOT_MASTER_SOFT_RESERVES_PLACEHOLDER"] = "Der Import von Soft-Reservierungen ist noch nicht fertig."
L["LOOT_MASTER_SOFT_RESERVES_IMPORT"] = "Importieren"

--------------------------------------------------------------------------------
-- Loot Tracker Window
--------------------------------------------------------------------------------

L["LOOT_TRACKER_TITLE"] = "Beuteverfolgung"
L["LOOT_TRACKER_TAB_ROLLS"] = "Würfe"
L["LOOT_TRACKER_TAB_DROPS"] = "Beute"
L["LOOT_TRACKER_NO_ROLL"] = "Heute Abend noch kein Wurf."
-- Argument: who called the roll.
L["LOOT_TRACKER_CALLED_BY"] = "Aufgerufen von %s"
L["LOOT_TRACKER_SPOTTED"] = "Im Chat entdeckt, von %s"
-- Argument: whole seconds left.
L["LOOT_TRACKER_SECONDS_LEFT"] = "noch %d s"
-- A roll called without GogoLoot. Argument: who called it.
L["LOOT_TRACKER_UNSYNCED_NOTE"] =
	"%s nutzt GogoLoot nicht, daher sind das die im Chat gesehenen Würfe, geprüft nach den üblichen Regeln: 1-100, nur der erste Wurf. Das letzte Wort hat, wer zum Würfeln aufgerufen hat."
L["LOOT_TRACKER_ON_HOLD"] = "Angehalten. Warte auf den Aufruf, um erneut zu würfeln."
L["LOOT_TRACKER_TIE_BREAK_ROLLS"] = "Würfe im Stechen"
-- Arguments: the winner, then the winning roll.
L["LOOT_TRACKER_WON_WITH"] = "%s hat mit %d gewonnen"
L["LOOT_TRACKER_CLOSED"] = "Beendet"
-- The sort buttons.
L["LOOT_TRACKER_SORT_HIGH"] = "Höchste"
L["LOOT_TRACKER_SORT_TIME"] = "Reihenfolge"
L["LOOT_TRACKER_ROLL"] = "Würfeln (1-100)"
-- Beside the player's own roll, and the line beside the Roll and Pass buttons.
L["LOOT_TRACKER_YOU"] = "Du"
L["LOOT_TRACKER_YOU_ROLLED"] = "Du hast %d gewürfelt."
L["LOOT_TRACKER_YOU_PASSED"] = "Du hast gepasst."
L["LOOT_TRACKER_NOT_ROLLED"] = "Du hast nicht gewürfelt."
L["LOOT_TRACKER_NOT_IN_TIE_BREAK"] = "Jetzt würfeln nur die Spieler im Stechen."
L["LOOT_TRACKER_EARLIER"] = "Früher heute Abend"
--[[
    The word, in lower case, that marks a group chat line with an item link as
    a call for rolls by someone without GogoLoot. "roll" is always read too.
]]
L["LOOT_TRACKER_ROLL_WORD"] = "würfel"

-- Drops.
L["LOOT_TRACKER_SHOW_WINNERS"] = "Zeigen, wer was bekam"
L["LOOT_TRACKER_DROPS_EMPTY"] =
	"Noch keine Beute gesehen. Sie erscheint hier, sobald Bosse sterben und Leichen geplündert werden."
L["LOOT_TRACKER_DROPS_NOTHING_SEEN"] = "Noch hat niemand mit GogoLoot es geplündert."
L["LOOT_TRACKER_NOT_HANDED_OUT"] = "Noch nicht vergeben"
L["LOOT_TRACKER_PRINT"] = "Ausgeben"
L["LOOT_TRACKER_POST"] = "Im Schlachtzug posten"
L["LOOT_TRACKER_COPY"] = "Kopieren"
L["LOOT_TRACKER_COPY_TITLE"] = "Mit Strg+C kopieren"

-- Drops by boss, printed and copied.
L["DROPS_TRASH"] = "Gewöhnliche Gegner"
L["DROPS_NONE"] = "Noch keine Beute erfasst."
-- Argument: the instance.
L["DROPS_PRINT_HEADER"] = "Beute in %s:"
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
	"Vergib per Wurf, was du noch handeln kannst, mit der Handelsfrist an jedem Gegenstand, und verfolge jeden Wurf in der Beuteverfolgung. Mittelklick auf die Minikarten-Schaltfläche, oder gib /gogo master bzw. /gogo tracker ein."
L["LOOT_MASTER_ENABLE"] = "Beutemeister aktivieren"
L["LOOT_MASTER_ENABLE_DESCRIPTION"] =
	"Verfolgt die Beute, die du noch handeln kannst, und ruft zum Würfeln darum auf. Ist das aus, öffnen sich Beutemeister und Beuteverfolgung nie, und kein Wurf wird gelesen."
L["LOOT_MASTER_OPEN"] = "Beutemeister öffnen"
L["LOOT_TRACKER_OPEN"] = "Beuteverfolgung öffnen"
-- A dropdown choice. Argument: the number.
L["LOOT_MASTER_SECONDS"] = "%d Sekunden"
L["LOOT_MASTER_MINUTES"] = "%d Minuten"
L["LOOT_MASTER_KEEP_RAIDS"] = "%d"

L["LOOT_MASTER_CALLING_HEADER"] = "Würfelaufrufe"
L["LOOT_MASTER_ROLL_LENGTH"] = "Würfeldauer"
L["LOOT_MASTER_ROLL_LENGTH_DESCRIPTION"] = "Wie lange das Würfeln offen bleibt."
L["LOOT_MASTER_ANNOUNCE_IN"] = "Ankündigen in"
L["LOOT_MASTER_ANNOUNCE_IN_DESCRIPTION"] = "Wohin Würfelaufrufe, Gleichstände und Pausen gehen."
L["LOOT_MASTER_CHANNEL_GROUP"] = "Gruppenchat"
L["LOOT_MASTER_ANNOUNCE_IN_NOTE"] =
	"Schlachtzugswarnung weicht auf den Gruppenchat aus, wenn du weder Anführer noch Assistent bist. Gewinner gehen immer in den Gruppenchat."
-- Argument: the seconds.
L["LOOT_MASTER_WARN_LAST_SECONDS"] = "Bei %d verbleibenden Sekunden warnen"
L["LOOT_MASTER_WARN_LAST_SECONDS_DESCRIPTION"] = "Sagt der Gruppe, wenn das Würfeln gleich endet."
-- Argument: the seconds.
L["LOOT_MASTER_STRETCH_LATE"] = "%d Sekunden hinzufügen, wenn jemand spät würfelt"
L["LOOT_MASTER_STRETCH_LATE_DESCRIPTION"] =
	"Ein Wurf in den letzten Sekunden hält das Würfeln etwas länger offen, damit niemand durch Verzögerungen abgeschnitten wird."
L["LOOT_MASTER_END_EARLY"] = "Früher beenden, sobald alle gewürfelt oder gepasst haben"
L["LOOT_MASTER_END_EARLY_DESCRIPTION"] =
	"Beendet das Würfeln, sobald jedes Gruppenmitglied gewürfelt oder pass geschrieben hat."
L["LOOT_MASTER_REROLL_TIES"] = "Gleichstände unter den Beteiligten neu würfeln"
L["LOOT_MASTER_REROLL_TIES_DESCRIPTION"] =
	"Ruft sofort ein Stechen für die Gleichstehenden aus. Ist das aus, wartet ein Gleichstand, bis du Gleichstand neu würfeln drückst."
L["LOOT_MASTER_ROLL_ALL_PAUSE"] = "Pause zwischen Gegenständen bei Alle auswürfeln"
L["LOOT_MASTER_ROLL_ALL_PAUSE_DESCRIPTION"] =
	"Wie lange Alle auswürfeln nach einem Wurf wartet, bevor es den nächsten aufruft."

L["LOOT_MASTER_COUNTING_HEADER"] = "Gültige Würfe"
-- Argument: the seconds of grace.
L["LOOT_MASTER_COUNTING_DESCRIPTION"] =
	"Ein einfaches /roll (1-100), jeweils das erste pro Spieler, aus deiner Gruppe, solange das Würfeln offen ist (%d Sekunde Nachfrist für Verzögerungen). Ungültige Würfe bleiben mit Begründung in der Liste."
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED"] = "Ungültige Würfe ankündigen"
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED_DESCRIPTION"] =
	"Listet die ungültigen Würfe samt Grund in einer Zeile auf, wenn das Würfeln endet. Ein von dir disqualifizierter Wurf wird immer angekündigt."

L["LOOT_MASTER_TRADE_HEADER"] = "Handelbare Beute"
L["LOOT_MASTER_OPEN_ON_TRADABLE"] = "Öffnen, wenn ich etwas Handelbares plündere"
L["LOOT_MASTER_OPEN_ON_TRADABLE_DESCRIPTION"] =
	"Öffnet den Beutemeister, wenn beim Aufheben gebundene Beute, die du noch handeln kannst, in deinen Taschen landet, während du in einer Gruppe bist."
L["LOOT_MASTER_TRADE_WARN"] = "Warnen, wenn die Handelszeit knapp wird"
L["LOOT_MASTER_TRADE_WARN_DESCRIPTION"] =
	"Sagt dir einmal im Chat, wenn ein Gegenstand auf der Würfelliste bald seelengebunden wird."
L["LOOT_MASTER_TRADE_WARN_WHEN"] = "Wie viel Handelszeit noch bleibt, wenn du gewarnt wirst."
L["LOOT_MASTER_TRADE_AUTO_FILL"] = "Gewonnene Gegenstände ins Handelsfenster legen"
L["LOOT_MASTER_TRADE_AUTO_FILL_DESCRIPTION"] =
	"Öffnest du einen Handel mit einem Gewinner, wird sein Gewinn für dich hineingelegt. Auf Handeln klickst du weiterhin selbst."

L["LOOT_MASTER_FLOOR_HEADER"] = "Bodenbeute"
L["LOOT_MASTER_FLOOR_PANEL_DESCRIPTION"] =
	"Die Bodenbeute startet leer und enthält nur, was du hinzufügst. Aus Taschen hinzufügen listet zuerst auf, was du in dieser Instanz aufgehoben hast."
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE"] = "Gegenstände entfernen, sobald sie meine Taschen verlassen"
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE_DESCRIPTION"] =
	"Entfernt einen Gegenstand aus der Bodenbeute, sobald du keinen mehr davon hast: gehandelt, verkauft oder benutzt."
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE"] = "Bodenbeute leeren, wenn ich den Schlachtzug verlasse"
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE_DESCRIPTION"] = "Startet jeden Schlachtzug mit einer leeren Bodenbeute."

L["LOOT_TRACKER_OPEN_ON_ROLL"] = "Öffnen, wenn jemand zum Würfeln aufruft"
L["LOOT_TRACKER_OPEN_ON_ROLL_DESCRIPTION"] =
	"Öffnet die Beuteverfolgung, wenn jemand in deiner Gruppe zum Würfeln aufruft, mit GogoLoot oder per Schlachtzugswarnung."
L["LOOT_TRACKER_AUTO_CLOSE"] = "Nach Ende des Würfelns selbst schließen"
L["LOOT_TRACKER_AUTO_CLOSE_DESCRIPTION"] =
	"Eine von selbst geöffnete Beuteverfolgung schließt sich 30 Sekunden nach Ende des Würfelns, außer deine Maus ist darüber."
L["LOOT_TRACKER_KEEP_DROPS"] = "Gespeicherte Schlachtzüge unter Beute"
L["LOOT_TRACKER_KEEP_DROPS_DESCRIPTION"] = "Wie viele Schlachtzüge der Reiter Beute speichert."
