local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "itIT")
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
	"Versione %s. Trovi le impostazioni (compresa l'opzione per disattivare questo messaggio) in Opzioni > AddOn > GogoLoot. Ti piace questo add-on? Parlane a un amico, aggiungilo ai Preferiti su CurseForge o lasciagli una Star su GitHub. (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Per sicurezza, l'interfaccia delle opzioni non può essere aperta in combattimento."
-- Argument: the game's own name for its Auto Loot setting.
L["MESSAGE_AUTO_LOOT_SETTING_ON"] =
	"Attivata l'opzione %s del gioco, necessaria per Bottino rapido e Apertura automatica."
-- Argument: the game's own word for Master Looter.
L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"] = "Al momento non sei %s."

-- Automated Opening. Argument: the number of free bag slots opening waits for.
L["MESSAGE_OPENING_PAUSED"] = "Apertura automatica è in pausa finché non avrai almeno %d spazi liberi nelle sacche."
L["MESSAGE_OPENING_RESUMED"] = "Apertura automatica è ripresa."

-- Argument: the item's link.
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] = "%s si aprirà automaticamente una volta sbloccato."
L["MESSAGE_ITEM_IGNORED"] = "%s è impostato su Ignora, quindi Apertura automatica lo lascerà stare."
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s proviene da un boss di incursione o mondiale, quindi Apertura automatica lo lascerà chiuso perché tu possa scambiarlo o venderlo."
L["MESSAGE_ITEM_IGNORED_UNIQUE"] =
	"%s può contenere un oggetto unico, quindi Apertura automatica lascerà che sia tu ad aprirlo."
L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] = "%s è stato lasciato nella finestra del bottino perché tu lo raccolga."
--[[
    Standard Loot Messages taking the General tab's loot lines off, or putting
    them back. Arguments: the game's own names for its Item Loot and Money Loot
    chat settings, then for the General chat tab.
]]
L["MESSAGE_STANDARD_LOOT_MESSAGES_OFF"] =
	"Disattivati %s e %s nella tua scheda di chat %s finché Avvisi del bottino è attivo."
L["MESSAGE_STANDARD_LOOT_MESSAGES_ON"] = "Riattivati %s e %s nella tua scheda di chat %s."

-- The Openables List's Add Item refusing gear or a bag. Argument: the item's link, or its ID while uncached.
L["MESSAGE_ITEM_NOT_OPENABLE"] =
	"%s verrebbe equipaggiato invece che aperto, quindi non può entrare nell'Elenco apribili."

-- Automated Rolls' Print Item in Chat. Arguments: the game's word for the roll (Need or Greed), then the item's link.
L["MESSAGE_ROLL_PRINT"] = "Hai scelto %s per %s."
-- The same after a Pass. Argument: the item's link.
L["MESSAGE_ROLL_PASS_PRINT"] = "Hai passato %s."
--[[
    Hide Roll Messages' winner summary. Arguments: the winner, the item's link,
    then the winning roll as LOOT_TOASTS_ROLL_RESULT words it ("Greed 95"). The
    NO_ROLL forms are for a win whose roll wasn't seen; the YOU forms for the
    player's own win, without the winner.
]]
L["MESSAGE_ROLL_WON_PRINT"] = "%s ha vinto %s con %s."
L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"] = "%s ha vinto %s."
L["MESSAGE_ROLL_YOU_WON_PRINT"] = "Hai vinto %s con %s."
L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"] = "Hai vinto %s."

--[[
    A trade summary printed to the player alone (the trade Channel's Me Only):
    the Chat Announcement Templates below, printed, so each ends on its
    punctuation. Arguments as theirs: items, then the partner, then what came
    back.
]]
L["MESSAGE_GAVE_PRINT"] = "Hai dato %s a %s."
L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "Hai dato %s a %s e ricevuto %s."
L["MESSAGE_TRADE_RECEIVED_PRINT"] = "Hai ricevuto %s da %s."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "Dato %s a %s"
L["MESSAGE_DESTINATION_SET"] = "%s terrà gli oggetti di qualità %s per il gruppo"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s terrà tutto il bottino per il gruppo"
-- Arguments: the player who left, the master looter, then the qualities they held, joined by commas.
L["MESSAGE_DESTINATION_LEFT"] = "%s ha lasciato il gruppo. Ora %s terrà gli oggetti di qualità %s per il gruppo"
-- The same when they held every quality. Arguments: the player who left, then the master looter.
L["MESSAGE_DESTINATION_LEFT_ALL"] = "%s ha lasciato il gruppo. Ora %s terrà tutto il bottino per il gruppo"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Dato %s a %s, ricevuto %s"
L["MESSAGE_TRADE_RECEIVED"] = "Ricevuto %s da %s"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "%s ha le sacche piene: %s"
L["ERROR_MAX_COUNT"] = "%s ne ha già troppi: %s"
L["ERROR_OUT_OF_RANGE"] = "%s è fuori portata: %s"
L["ERROR_NOT_IN_GROUP"] = "%s non è più nel gruppo o nell'incursione: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "Impossibile consegnare il bottino a %s: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

-- The first feature panel, holding the one Speedy Loot switch.
L["TAB_SPEEDY_LOOT"] = "Bottino rapido"
L["TAB_AUTOMATED_ROLLS"] = "Tiri automatici"
L["TAB_ITEM_OVERRIDES"] = "Eccezioni per oggetto"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "Regole per personaggio"
-- The panel for everything GogoLoot posts to chat; also its row in the mini-map button's tooltip.
L["TAB_ANNOUNCEMENTS"] = "Annunci del bottino"
-- Headers of the two sections on the Loot Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Annunci di scambio"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Annunci del Responsabile del bottino"
L["TAB_LOOT_TOASTS"] = "Avvisi del bottino"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Filtri"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Suoni del bottino"
L["TAB_AUTOMATED_OPENING"] = "Apertura automatica"
-- A child panel of Automated Opening, beside the Openables List.
L["TAB_LOCKBOXES"] = "Cassette"
L["TAB_OPENABLE_ITEMS"] = "Elenco apribili"
-- The last feature panel, named for its switch, Enable Automated Master Looting.
L["TAB_MASTER_LOOTER"] = "Consegna automatica del bottino"
-- Header of a section on the Automated Master Looting panel.
L["TAB_LOOT_DESTINATIONS"] = "Destinazioni del bottino"
L["TAB_IGNORE_LIST"] = "Elenco ignorati"
-- The panel after Automated Master Looting, named for its switch, Enable Roll Macro.
L["TAB_ROLL_MACRO"] = "Macro dei tiri"
-- The panel after Roll Macro, for the Loot Master and Loot Tracker windows; also the Loot Master window's title.
L["TAB_LOOT_MASTER"] = "Gestore del bottino"

-- A child panel's title where the Settings tree can't nest it: the parent's title, then its own.
L["TAB_NESTED_FORMAT"] = "%s: %s"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Attivo"
L["STATUS_DISABLED"] = "Disattivo"
-- Automated Opening is on but waiting for empty bag slots.
L["STATUS_PAUSED"] = "In pausa"

--[[
    The tooltip titles each feature with its options-panel name, and gives
    each a description of its own, two lines at most: the panels' longer text
    doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Tira per te sugli oggetti idonei fino alla qualità che scegli."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] = "Apre vongole, casse, borsellini e cassette sbloccate nelle tue sacche."
L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"] =
	"Pubblica in chat i riepiloghi degli scambi e le consegne del Responsabile del bottino."
L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"] = "Consegna il bottino ai giocatori che hai scelto per ogni qualità."
--[[
    The tooltip's read-back of each group context's roll, one line each under
    the description. Arguments: the game's own word for Party or Raid, the roll,
    then (all but Manual) the highest quality it rolls on.
]]
L["MINIMAP_ROLLS_SETTING"] = "%s: %s, %s"
L["MINIMAP_ROLLS_SETTING_MANUAL"] = "%s: %s"

L["MINIMAP_LEFT_CLICK"] = "Clic sinistro"
L["MINIMAP_RIGHT_CLICK"] = "Clic destro"
L["MINIMAP_SHIFT_LEFT_CLICK"] = "Maiusc + Clic sinistro"
L["MINIMAP_SHIFT_RIGHT_CLICK"] = "Maiusc + Clic destro"
L["MINIMAP_TOGGLE"] = "Attiva/Disattiva"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Oggetti chiusi"
L["MINIMAP_OPTIONS"] = "Opzioni di GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Maiusc + Clic centrale"

-- Heads the items on the Roll List still on a trade clock, soonest first, under Locked Items.
L["MINIMAP_TRADABLE_LOOT"] = "Bottino scambiabile"
-- Under the first few of them. Argument: how many more there are.
L["MINIMAP_TRADABLE_MORE"] = "Altri %d"
-- The loot windows' block: its title, how many items are on the Roll List, its description and its click.
L["MINIMAP_LOOT_WINDOWS"] = "Gestore e Monitor del bottino"
L["MINIMAP_TO_HAND_OUT"] = "%d da consegnare"
L["MINIMAP_LOOT_WINDOWS_DESCRIPTION"] = "Assegna con un tiro ciò che puoi ancora scambiare e segui ogni tiro."
L["MINIMAP_MIDDLE_CLICK"] = "Clic centrale"
L["MINIMAP_OPEN"] = "Apri"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Manuale"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "Solo %s"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s e inferiore"

-- How many of an item, after its link: on a toast, in a trade summary, in the mini-map's Locked Items and in Add from Bags. Argument: the count.
L["ITEM_QUANTITY"] = "x%d"
-- An item and how many, the way the game's own loot lines write it, in the loot windows and their chat lines. Arguments: the item's link, then the count.
L["ITEM_QUANTITY_LINK"] = "%sx%d"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List brings text of its own), the hint the box shows while empty,
    and its button.
]]
L["ITEM_LIST_ADD"] = "Aggiungi oggetto"
L["ITEM_LIST_ADD_DESCRIPTION"] = "Inserisci l'ID di un oggetto o trascina qui un oggetto per aggiungerlo all'elenco."
L["ITEM_LIST_ADD_PLACEHOLDER"] = "Trascina qui un oggetto o scrivi il suo ID"
L["ITEM_LIST_ADD_BUTTON"] = "Aggiungi"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "Filtra oggetti..."
L["ITEM_LIST_FILTER_DESCRIPTION"] =
	"Mostra solo gli oggetti il cui nome, ID oggetto, impostazione o etichetta contiene ciò che scrivi."
L["ITEM_LIST_NO_MATCHES"] = "Nessun oggetto corrisponde al filtro."

-- The header over what the player just added to an item list, at its top until they filter it or close the window.
L["ITEM_LIST_NEW"] = "Nuovi"

-- The kind filter beside every item list's search box: its first choice (the rest are the list's headers) and its tooltip.
L["ITEM_LIST_KIND_ALL"] = "Mostra tutti i tipi di oggetti"
L["ITEM_LIST_KIND_DESCRIPTION"] = "Mostra tutti gli oggetti dell'elenco, o solo quelli di un tipo."

--[[
    The Add from Bags dropdown beside every item list's add box: its resting
    text and tooltip, then what it reads, greyed out, when everything carried
    is already on the list. The Openables List brings a tooltip of its own.
]]
L["ITEM_LIST_ADD_FROM_BAGS"] = "Aggiungi dalle sacche"
L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"] = "Aggiunge all'elenco un oggetto che porti con te."
L["ITEM_LIST_BAGS_EMPTY"] = "Nelle sacche non c'è nulla da aggiungere"
L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"] = "Ogni oggetto che porti con te è già nell'elenco."

-- The button at the foot of every item list; each list's tooltip and confirmation say what it restores.
L["ITEM_LIST_RESTORE"] = "Ripristina predefiniti"

-- Placeholder shown in the item lists until the client caches an item's info.
L["ITEM_LOADING"] = "Caricamento... (ID: %d)"

--[[
    Appended to the Automated Rolls description. Item Overrides is the one way
    a Bind on Pickup or quest item gets rolled on; nothing ever rolls on the
    rest.
]]
L["SAFETY_SKIP_NOTE"] =
	"Non tira mai su ricette, libri, cavalcature, mascotte o leggendari, e tira sugli oggetti Si vincola alla raccolta o di missione solo se sono in Eccezioni per oggetto."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] = "Ricette, libri, cavalcature, mascotte e leggendari restano sempre a te."

--[[
    Shown under each announcement's toggle, under Print Item in Chat and Hide
    Roll Messages, and under Enable Ignore Notifications. Argument: the
    message, as GogoLoot sends or prints it.
]]
L["OPTIONS_EXAMPLE"] = "Esempio: %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Bottino rapido svuota i cadaveri senza finestra del bottino, sceglie Necessità, Avidità o Passo in base alla qualità, e la Consegna automatica del bottino distribuisce il bottino per te. Vongole, contenitori e cassette sbloccate si aprono da soli. Raccogli più in fretta, attacca prima."
L["WELCOME_MESSAGE"] = "Attiva messaggio di benvenuto"
L["WELCOME_MESSAGE_DESCRIPTION"] = "Mostra la versione di GogoLoot e dove trovare queste impostazioni a ogni accesso."
L["MINIMAP_BUTTON_ENABLE"] = "Attiva pulsante della minimappa"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Mostra il pulsante di GogoLoot sulla minimappa. Clic sinistro attiva o disattiva Tiri automatici, Clic destro Apertura automatica, Maiusc + Clic sinistro Annunci del bottino e Maiusc + Clic destro Consegna automatica del bottino."

L["OPTIONS_COMMANDS_HEADER"] = "/Comandi"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Apre l'interfaccia delle opzioni di questo add-on."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Funzioni"

-- The opening line of the Speedy Loot panel, above its switch.
L["SPEEDY_LOOT_DESCRIPTION"] =
	"Prende tutto da un cadavere appena lo apri, così non aspetti mai la finestra del bottino."
L["SPEEDY_LOOT_ENABLE"] = "Attiva Bottino rapido"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"Svuota ogni cadavere appena lo apri, senza mostrare la finestra del bottino. Tieni premuto Maiusc mentre raccogli per vedere invece la finestra. Attiva l'opzione %s del gioco e si fa da parte mentre sei %s."

--[[
    The Roll Macro panel. %s is the macro's name, "- Roll", the same in every
    locale. General Macros is the tab of the game's Macros window that every
    character on the account shares; /macro is the game's command and stays
    English.
]]
L["ROLL_MACRO_DESCRIPTION"] =
	"Aggiunge alle tue Macro generali una macro chiamata %s, con l'icona delle monete d'oro, così ogni personaggio del tuo account può trascinarla su una barra delle azioni."
--[[
    The three rows under it, each beside the game's name for a mouse button
    (MINIMAP_LEFT_CLICK and its neighbours). Right-click is the off-spec roll;
    a raid roll picks a number from 1 to the group's size.
]]
L["ROLL_MACRO_LEFT_CLICK"] = "Tira 1-100"
L["ROLL_MACRO_RIGHT_CLICK"] = "Tira 1-99"
L["ROLL_MACRO_MIDDLE_CLICK"] = "Tiro d'incursione"
L["ROLL_MACRO_ENABLE"] = "Attiva Macro dei tiri"
-- Under the three rows, in silver: what Middle-Click's raid roll is for and how to read it.
L["ROLL_MACRO_RAID_ROLL_NOTE"] =
	"Un tiro d'incursione assegna un oggetto a qualcuno a caso. Tira da 1 al numero di giocatori del tuo gruppo, quindi ogni numero corrisponde a un giocatore: scorri l'elenco dell'incursione o del gruppo fino al numero uscito per trovare il vincitore. Da solo, tira 1-100."
L["ROLL_MACRO_SWITCH_DESCRIPTION"] =
	"Mantiene la macro %s nelle tue Macro generali: Clic sinistro tira 1-100, Clic destro 1-99, Clic centrale un tiro d'incursione. Disattivandola, la macro viene eliminata."
--[[
    Printed to chat when Enable Roll Macro is switched on or off, or the macro
    can't be made. In ROLL_MACRO_ADDED the second %s is /m, the game's command
    for its Macros window, drawn in blue.
]]
L["ROLL_MACRO_ADDED"] = "La macro %s è nelle tue Macro generali. Scrivi %s e trascinala su una barra delle azioni."
L["ROLL_MACRO_REMOVED"] = "La macro %s è stata eliminata."
L["ROLL_MACRO_FULL"] =
	"Impossibile aggiungere la macro %s: le tue Macro generali sono piene. Eliminane una e verrà aggiunta al prossimo accesso."

--------------------------------------------------------------------------------
-- Options: Feedback & Support Panel
--------------------------------------------------------------------------------

-- "Star" stays GitHub's English button label in every locale; Discord, CurseForge, Wago and GitHub stay as written.
L["OPTIONS_LEVEL_UP_TITLE"] = "Aiuta GogoLoot a salire di livello"
L["OPTIONS_LEVEL_UP_INTRO"] =
	"Questo add-on è stato creato da giocatori che amano questo gioco e vogliono renderlo il più divertente possibile per tutti. Non chiederemo mai donazioni. La vera soddisfazione è sapere che il nostro lavoro rende il gioco un po' migliore per te. Se è così, ci piacerebbe saperlo!"
L["OPTIONS_LEVEL_UP_WAYS"] = "Ecco alcuni modi in cui puoi aiutarci a raggiungere più giocatori."
L["OPTIONS_LEVEL_UP_FEEDBACK"] =
	"• Invia un feedback: hai trovato un bug o hai un'idea? Faccelo sapere su Discord. Il tuo parere ci aiuta a migliorare l'add-on, e le pull request sono sempre benvenute."
L["OPTIONS_LEVEL_UP_FRIEND"] =
	"• Parlane a un amico: conosci qualcuno a cui potrebbe piacere questo add-on? Raccontaglielo. Il passaparola aiuta più giocatori a scoprire ottimi add-on."
L["OPTIONS_LEVEL_UP_CURSEFORGE"] =
	"• Aggiungilo ai Preferiti su CurseForge: apri il link di CurseForge qui sotto, accedi e clicca sulla stella sotto il pulsante Download. I Preferiti aiutano più giocatori a scoprire l'add-on."
L["OPTIONS_LEVEL_UP_GITHUB"] =
	"• Lascia una Star su GitHub: apri il link di GitHub qui sotto, accedi e clicca su Star in alto a destra. Le Star aiutano il progetto a ottenere più strumenti gratuiti per sviluppatori."
L["OPTIONS_LEVEL_UP_THANKS"] = "Grazie per aver scelto GogoLoot!"

L["OPTIONS_FEEDBACK"] = "Feedback e supporto"
L["OPTIONS_FEEDBACK_LINKS_HEADER"] = "Link per feedback e supporto"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_COPY_LINK"] = "Per copiare un link, clicca sulla sua casella, poi premi Ctrl+A e Ctrl+C."
-- The version line at the foot of the Feedback & Support panel.
L["OPTIONS_VERSION"] = "Versione %s"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "Impostazioni del bottino di gruppo"
L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"] =
	"Stabilisce come viene distribuito il bottino del gruppo. Solo il capogruppo può cambiarlo."
L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"] =
	"Stabilisce la qualità minima degli oggetti a cui si applica il metodo di predazione. Solo il capogruppo può cambiarla."

--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them, including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "Queste impostazioni sono gestite da %s."
-- Shown in the same place while solo, where the two dropdowns are greyed out.
L["MASTER_LOOTER_SOLO_NOTE"] = "Unisciti a un gruppo per cambiarle. Solo il capogruppo può farlo."

-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"] =
	"Consegna ogni oggetto al giocatore che hai scelto per la sua qualità appena apri la finestra del bottino, mentre sei %s."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "Attiva Consegna automatica del bottino"
L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"] =
	"Attiva o disattiva le consegne automatiche. Funziona solo nelle spedizioni e nelle incursioni, a meno che Anche fuori dalle istanze non sia attivo."
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Anche fuori dalle istanze"
L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Consegna il bottino anche nel mondo aperto. Il bottino dei boss mondiali non è scambiabile, quindi è sconsigliato."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "Includi oggetti di missione"
L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"] =
	"Consegna anche gli oggetti di missione, per potenziare un personaggio che giochi tu stesso. Funziona solo con una soglia del bottino Comune o inferiore, e solo per gli oggetti di missione che cadono una sola volta per tutto il gruppo. Sconsigliato in incursione."

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Impostazioni rapide"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_POPUP_TOOLTIP"] = "Apre queste impostazioni in una finestra ogni volta che diventi %s."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Attiva finestra del Responsabile del bottino"

L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"Scegli chi riceve ogni qualità. Una qualità senza nessuno scelto resta per te nella finestra del bottino."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Me stesso"
-- The first choice in every destination dropdown: nobody picked, so that quality waits in the loot window.
L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"] = "Finestra del bottino"
L["MASTER_LOOTER_SEND_ALL"] = "Invia tutto il bottino a"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] = "Assegna ogni qualità qui sotto a un solo giocatore."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Stabilisce chi riceve gli oggetti di qualità %s."
-- Shown under Loot Destinations while Automated Master Looting is on and no quality has anybody picked.
L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] =
	"Non hai ancora scelto nessuno, quindi tutto il bottino ti aspetta nella finestra del bottino."

L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Gli oggetti di questo elenco non vengono mai consegnati automaticamente. Restano nella finestra del bottino perché sia tu a consegnarli."
-- Shown on the Ignore List while Automated Master Looting is off.
L["MASTER_LOOTER_OFF_NOTE"] =
	"Queste impostazioni non vengono usate finché la funzione Consegna automatica del bottino è disattivata."
L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"] =
	"Sostituisce l'Elenco ignorati con gli oggetti predefiniti della tua espansione."
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"Il tuo Elenco ignorati verrà sostituito con gli oggetti predefiniti della tua espansione. Continuare?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Rimuove questo oggetto dall'Elenco ignorati."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_PANEL_DESCRIPTION"] =
	"Sceglie per te %s, %s o %s sul bottino di gruppo, fino alla qualità che scegli, con impostazioni separate per gruppi e incursioni."
L["ROLLS_ENABLE"] = "Attiva Tiri automatici"
L["ROLLS_ENABLE_DESCRIPTION"] =
	"Attiva o disattiva i tiri automatici, comprese Eccezioni per oggetto e Regole per personaggio."
L["ROLLS_IN_PARTY"] = "In gruppo"
L["ROLLS_IN_RAID"] = "In incursione"
-- The caption of the quality row under In Party and under In Raid, shown while that roll isn't Manual.
L["ROLLS_UP_TO_QUALITY"] = "Fino alla qualità"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: la qualità più alta su cui tira GogoLoot."
L["ROLLS_ACTION_CHOOSE"] = "%s: il tiro che fa GogoLoot. Manuale lascia il tiro a te."
-- Section headers on the Automated Rolls panel.
L["ROLLS_LOOT_THRESHOLDS_HEADER"] = "Soglie del bottino"
L["ROLLS_MESSAGES_HEADER"] = "Messaggi dei tiri"
L["ROLLS_PRINT_ITEM"] = "Scrivi oggetto in chat"
L["ROLLS_PRINT_ITEM_DESCRIPTION"] =
	"Scrive nella tua chat ogni oggetto su cui GogoLoot tira e il tiro che ha fatto. La finestra del tiro si chiude appena GogoLoot tira, così ti resta traccia di cosa è uscito."
L["ROLLS_HIDE_MESSAGES"] = "Nascondi messaggi dei tiri"
-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_HIDE_MESSAGES_TOOLTIP"] =
	"Nasconde le righe di chat del gioco per ogni tiro: chi ha scelto %s, %s o %s, e ogni numero tirato. Ciò che ha ricevuto ogni vincitore resta in chat."
-- The dropdown beside Hide Roll Messages.
L["ROLLS_WINNER_SUMMARY_PRINT"] = "Scrivi riepilogo dei vincitori"
L["ROLLS_WINNER_SUMMARY_NONE"] = "Non scrivere riepilogo dei vincitori"
L["ROLLS_WINNER_SUMMARY_DESCRIPTION"] =
	"Scrivi riepilogo dei vincitori mette in chat una riga per ogni vittoria, con il vincitore, l'oggetto e il tiro vincente, al posto della riga del gioco. Non scrivere riepilogo dei vincitori lascia la riga del gioco che dice chi ha vinto."

--[[
    Item Overrides, under Automated Rolls: items with a roll action of their
    own.
]]
L["ITEM_OVERRIDES_DESCRIPTION"] =
	"Stabilisce il tiro per oggetti specifici, prima delle impostazioni di qualità. È l'unico modo in cui GogoLoot tira su un oggetto Si vincola alla raccolta o di missione."
-- Shown on Item Overrides and Character Rules while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "Queste impostazioni non vengono usate finché la funzione Tiri automatici è disattivata."
L["ITEM_OVERRIDES_ENABLE"] = "Attiva Eccezioni per oggetto"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"Usa i tiri impostati qui sotto. Se è disattivo, questi oggetti seguono le impostazioni di qualità come tutti gli altri."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] =
	"Sostituisce le tue Eccezioni per oggetto con gli oggetti predefiniti della tua espansione."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"Le tue Eccezioni per oggetto verranno sostituite con gli oggetti predefiniti della tua espansione. Continuare?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "Stabilisce il tiro automatico per questo oggetto."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "Rimuove questo oggetto da Eccezioni per oggetto."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "Rimuovere questo oggetto e il suo tiro da Eccezioni per oggetto?"

--[[
    Character Rules, under Automated Rolls: the stats whose gear each
    character leaves to the player. The stat names come from the game's own
    strings.
]]
-- Arguments: the game's own name for Intellect, then for the Warrior class, then Intellect again.
L["CHARACTER_RULES_PANEL_DESCRIPTION"] =
	"Lascia a te l'equipaggiamento con le statistiche che scegli, personaggio per personaggio: imposta %s su Manuale per il tuo %s, e l'equipaggiamento con %s mantiene la sua finestra del tiro mentre tutto il resto viene tirato come al solito. Le Eccezioni per oggetto hanno comunque la precedenza."
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "Attributi primari"
L["CHARACTER_RULES_SECONDARY"] = "Attributi secondari"
-- The first of the two choices in each stat's dropdown: no rule, so the rest of Automated Rolls decides.
L["CHARACTER_RULES_STANDARD"] = "Tiro automatico standard"
L["CHARACTER_RULES_ACTION_DESCRIPTION"] =
	"%s: Manuale lascia a te, su questo personaggio, l'equipaggiamento con questa statistica, finestra del tiro compresa. Tiro automatico standard ci tira come su qualsiasi altro oggetto."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"Pubblica in chat i riepiloghi degli scambi e le consegne del Responsabile del bottino, così tutti sanno dove è finito il bottino."
L["ANNOUNCEMENTS_ENABLE"] = "Attiva Annunci del bottino"
-- Also the tooltip of the same switch in the General panel's Features section, so it names no position on the panel.
L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"] =
	"Attiva o disattiva tutti gli annunci. Quando è disattivo, GogoLoot non invia nulla al gruppo o ai partner di scambio, nemmeno per gli oggetti che consegni tu."

-- Trade Announcements
L["TRADE_DESCRIPTION"] = "Pubblica un riepilogo di ogni scambio completato: oggetti, incantamenti e oro."
L["TRADE_ENABLE"] = "Attiva annunci di scambio"
L["TRADE_ENABLE_DESCRIPTION"] =
	"Pubblica un riepilogo quando uno scambio si conclude. La casella Annuncia nella finestra di scambio è questo stesso interruttore."
L["TRADE_CONDITION_DESCRIPTION"] =
	"Sceglie quando pubblicare i riepiloghi: sempre, in gruppo o incursione, o solo in incursione."
L["TRADE_CONDITION_ALWAYS"] = "Sempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "In gruppo o incursione"
L["TRADE_CONDITION_RAID_ONLY"] = "In incursione"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "Canale"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	"%s invia ogni riepilogo al tuo partner di scambio. Chat di gruppo lo pubblica nel gruppo o nell'incursione, e fuori da un gruppo lo sussurra comunque. Solo io lo scrive nella tua chat e non lo invia a nessuno."
-- The Channel dropdown's choices (Whisper is the client's WHISPER), and the trade window checkbox tooltip's Channel value.
L["TRADE_OUTPUT_GROUP"] = "Chat di gruppo"
L["TRADE_OUTPUT_SELF"] = "Solo io"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Pubblica in chat un riepilogo quando questo scambio si conclude."
L["TRADE_CHECKBOX_LABEL"] = "Annuncia"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Dice al gruppo chi tiene ogni qualità e cosa hai consegnato."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Attiva annunci di destinazione"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"] =
	"Dice al gruppo chi tiene ogni qualità ogni volta che imposti una destinazione."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Attiva annunci di consegna automatica"
L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"] =
	"Annuncia ogni oggetto che GogoLoot consegna automaticamente, di qualità pari o superiore a quella che scegli."
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"] =
	"Le consegne automatiche sotto questa qualità non vengono annunciate."

L["MASTER_LOOTER_ANNOUNCE_MANUAL"] = "Attiva annunci di consegna manuale"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"] =
	"Annuncia ogni oggetto che consegni tu dal menu del %s, qualunque sia la qualità, con la stessa formulazione di una consegna automatica. Una consegna non riuscita viene segnalata in ogni caso."

--------------------------------------------------------------------------------
-- Options: Loot Toasts and Loot Sounds
--------------------------------------------------------------------------------

-- Argument: the game's own name for the General chat tab.
L["LOOT_TOASTS_PANEL_DESCRIPTION"] =
	"Mostra a schermo per qualche secondo ogni oggetto e moneta che raccogli, così non ti sfugge nulla mentre Bottino rapido nasconde la finestra del bottino. Con gli avvisi attivi, le righe del bottino del gioco possono sparire dalla tua scheda di chat %s."
L["LOOT_TOASTS_ENABLE"] = "Attiva Avvisi del bottino"
-- Also the tooltip of the same switch in the General panel's Features section.
L["LOOT_TOASTS_SWITCH_DESCRIPTION"] = "Mostra un avviso per il bottino che scegli in Filtri, tuo e del tuo gruppo."
-- The dropdown beside Enable Loot Toasts: the game's Item Loot and Money Loot chat settings for the General tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"] = "Disattiva messaggi standard del bottino"
L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"] = "Attiva messaggi standard del bottino"
-- Arguments: the game's own names for its Item Loot and Money Loot chat settings, then for the General chat tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"] =
	"Disattiva messaggi standard del bottino toglie %s e %s dalla tua scheda di chat %s finché Avvisi del bottino è attivo, e disattivare Avvisi del bottino li ripristina. È la stessa opzione delle Impostazioni di quella scheda, e le altre schede mantengono le proprie."

-- The Loot Toasts panel's two section headers.
L["LOOT_TOASTS_STACK_HEADER"] = "Pila"
L["LOOT_TOASTS_TEXT_HEADER"] = "Testo"

--[[
    Filters: a row per item type, captioned with the game's own name for it,
    each with a Mine box and a Group box. Weapon, Armor, Trade Goods and Gem
    carry a quality dropdown beside each ticked box. Argument in each tooltip:
    the row's item type, as the client names it.
]]
-- Shown on the Filters panel while Loot Toasts is off.
L["LOOT_TOASTS_OFF_NOTE"] =
	"Queste impostazioni non vengono usate finché la funzione Avvisi del bottino è disattivata."
-- The Filters panel's description.
L["LOOT_TOASTS_FILTERS_CAPTION"] =
	"Scegli cosa riceve un avviso, e cosa dice, per il tuo bottino e per quello del gruppo. Il bottino del gruppo mostra accanto il nome di chi l'ha raccolto."
L["LOOT_TOASTS_FILTER_MINE"] = "Miei"
L["LOOT_TOASTS_FILTER_GROUP"] = "Gruppo"
L["LOOT_TOASTS_FILTER_MINE_DESCRIPTION"] = "Mostra gli oggetti di tipo %s che raccogli."
L["LOOT_TOASTS_FILTER_GROUP_DESCRIPTION"] =
	"Mostra gli oggetti di tipo %s raccolti da chiunque nel tuo gruppo o incursione, con il nome di chi li raccoglie."
L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"] =
	"Mostra gli oggetti di tipo %s che raccogli, di qualità pari o superiore a quella indicata accanto."
L["LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION"] =
	"Mostra gli oggetti di tipo %s raccolti da chiunque nel tuo gruppo o incursione, di qualità pari o superiore a quella indicata accanto, con il nome di chi li raccoglie."
L["LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION"] =
	"La qualità minima degli oggetti di tipo %s che raccogli per cui compare un avviso."
L["LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION"] =
	"La qualità minima degli oggetti di tipo %s raccolti dal gruppo per cui compare un avviso."

-- The three Filters rows after the item types, which aren't item types themselves: their captions (Money's is the client's MONEY) and their boxes' tooltips.
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP"] = "Si vincola alla raccolta"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION"] =
	"Mostra ogni oggetto Si vincola alla raccolta che ottieni, qualunque siano tipo e qualità."
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION"] =
	"Mostra ogni oggetto Si vincola alla raccolta che ottiene il tuo gruppo, qualunque siano tipo e qualità."
L["LOOT_TOASTS_FILTER_OPENABLES"] = "Apribili"
L["LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION"] =
	"Mostra i contenitori che raccogli e che GogoLoot può aprire, cassette comprese, qualunque sia la loro qualità."
L["LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION"] =
	"Mostra i contenitori raccolti dal tuo gruppo che GogoLoot può aprire, cassette comprese, qualunque sia la loro qualità."
L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"] =
	"Mostra un avviso per le monete che raccogli. Il gioco non segnala le monete degli altri giocatori, quindi non c'è la casella Gruppo."

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast "You Won" takes the
    looter's place (LOOT_TOASTS_YOU_WON_ROLL: the item, the roll); on a group
    member's, their name (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Tiro vincente"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"Aggiunge al suo avviso il tiro con cui hai vinto un oggetto, ad esempio (Hai vinto, %s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Aggiunge all'avviso di un membro del gruppo il tiro con cui ha vinto un oggetto, ad esempio (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_YOU_WON_ROLL"] = "%s (Hai vinto, %s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Quantità nelle sacche"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Aggiunge agli avvisi del tuo bottino quanti ne porti ora con te, ad esempio x3 (27), quando ne porti più della quantità indicata dall'avviso."
-- Bag Count, after the item and its count. Argument: how many the player carries.
L["LOOT_TOASTS_BAG_COUNT"] = "(%d)"

-- Stack
L["LOOT_TOASTS_MAX_ITEMS"] = "Numero massimo di avvisi"
L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"] =
	"Il numero massimo di avvisi a schermo insieme; il più vecchio sparisce per fare spazio."
L["LOOT_TOASTS_UNLIMITED"] = "Illimitati"
L["LOOT_TOASTS_DURATION"] = "Secondi a schermo"
L["LOOT_TOASTS_DURATION_DESCRIPTION"] = "Per quanti secondi resta ogni avviso prima di svanire."
L["LOOT_TOASTS_GROWTH"] = "Direzione di crescita"
L["LOOT_TOASTS_GROWTH_DESCRIPTION"] =
	"Se gli avvisi più vecchi si spostano in alto o in basso, lontano dal più recente."
L["LOOT_TOASTS_GROW_UP"] = "Verso l'alto"
L["LOOT_TOASTS_GROW_DOWN"] = "Verso il basso"
L["LOOT_TOASTS_ALIGN"] = "Allineamento"
L["LOOT_TOASTS_ALIGN_DESCRIPTION"] = "Su quale lato della maniglia si allineano gli avvisi."
L["LOOT_TOASTS_ALIGN_LEFT"] = "Sinistra"
L["LOOT_TOASTS_ALIGN_RIGHT"] = "Destra"

-- Text
L["LOOT_TOASTS_FONT"] = "Carattere"
L["LOOT_TOASTS_FONT_DESCRIPTION"] = "Il carattere con cui sono scritti gli avvisi."
L["LOOT_TOASTS_FONT_DEFAULT"] = "Predefinito"
L["LOOT_TOASTS_FONT_SIZE"] = "Dimensione carattere"
L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"] =
	"La dimensione del testo degli avvisi; le icone si ingrandiscono e si rimpiccioliscono di conseguenza."
L["LOOT_TOASTS_OUTLINE"] = "Contorno carattere"
L["LOOT_TOASTS_OUTLINE_DESCRIPTION"] =
	"Il contorno attorno al testo degli avvisi, che lo mantiene leggibile su sfondi luminosi."
L["LOOT_TOASTS_OUTLINE_NONE"] = "Nessuno"
L["LOOT_TOASTS_OUTLINE_OUTLINE"] = "Contorno"
L["LOOT_TOASTS_OUTLINE_THICK"] = "Contorno spesso"
L["LOOT_TOASTS_OUTLINE_MONOCHROME"] = "Monocromatico"
L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"] = "Contorno monocromatico"

-- Position
L["LOOT_TOASTS_UNLOCK"] = "Sblocca posizione"
L["LOOT_TOASTS_LOCK"] = "Blocca posizione"
L["LOOT_TOASTS_RESET"] = "Reimposta posizione"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "Mostra o nasconde la maniglia per trascinare gli avvisi in un nuovo punto."
L["LOOT_TOASTS_RESET_DESCRIPTION"] = "Riporta gli avvisi al punto predefinito, sopra il centro dello schermo."

-- The drag handle: its title, the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_HANDLE_TITLE"] = "Avvisi del bottino di GogoLoot"
L["LOOT_TOASTS_CLICK_DRAG"] = "Clic + Trascina per spostare"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "Clic destro per bloccare"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "Disattiva Avvisi del bottino"
-- The stand-in item on the sample toasts, and in every Example line.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "Oggetto di esempio"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"Riproduce un rintocco per il bottino di qualità pari o superiore a quella che scegli, e un suono di sacca quando %s ottiene qualcosa."
-- The Loot Sounds panel's master switch, also in the General panel's Features section; its tooltip names no position on either.
L["LOOT_SOUNDS_SWITCH"] = "Attiva Suoni del bottino"
L["LOOT_SOUNDS_SWITCH_DESCRIPTION"] = "Attiva o disattiva tutti i suoni del bottino di GogoLoot."
-- The chime's own toggle, under the master switch.
L["LOOT_SOUNDS_ENABLE"] = "Attiva rintocco del bottino"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Riproduce un rintocco quando raccogli da un cadavere o da un forziere un oggetto di qualità pari o superiore a quella che scegli."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] =
	"La qualità minima degli oggetti che fa suonare il rintocco del bottino."
L["LOOT_SOUNDS_TEST"] = "Riproduce il rintocco del bottino."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "Attiva suono di %s"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "Riproduce un suono di sacca quando %s ottiene davvero qualcosa."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "Riproduce il suono di %s."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"Apre per te vongole, casse, borsellini e cassette sbloccate nelle tue sacche, ogni volta che hai almeno %d spazi liberi nelle sacche."
L["AUTOMATED_OPENING_ENABLE"] = "Attiva Apertura automatica"
-- Also the tooltip of the same switch in the General panel's Features section. Argument: the game's own name for its Auto Loot setting.
L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"] =
	"Apre un contenitore alla volta e si ferma in combattimento, durante un lancio, in furtività o quando è aperta la finestra di un mercante, della banca, della cassetta postale, della casa d'aste o dello scambio. Mentre è attiva, abilita l'opzione %s del gioco."
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"] = "Solo fuori dalle istanze"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Non apre nulla mentre sei in una spedizione, un'incursione o un campo di battaglia."
L["AUTOMATED_OPENING_ONLY_SOLO"] = "Solo da solo"
L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"] = "Non apre nulla mentre sei in gruppo o in incursione."

-- Lockboxes
-- Arguments: the game's own name for the Rogue class, then for the Lockpicking skill.
L["LOCKBOXES_SECTION_DESCRIPTION"] =
	"Una cassetta non si apre finché un %s non la scassina. Queste opzioni mostrano il livello di %s richiesto da ognuna e ti avvisano quando una è in attesa."
L["LOCKBOXES_TOOLTIPS_ENABLE"] = "Attiva descrizioni delle cassette"
-- Argument: the game's own name for the Lockpicking skill.
L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"] = "Aggiunge alla descrizione di ogni cassetta il livello di %s richiesto."
L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"] =
	"Stabilisce se le descrizioni delle cassette compaiono solo per i Ladri o per tutti i personaggi."
L["LOCKBOXES_NOTIFICATIONS_ENABLE"] = "Attiva notifiche delle cassette"
L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Ti avvisa in chat quando raccogli una cassetta che si aprirà una volta sbloccata."
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] =
	"Stabilisce se le notifiche delle cassette compaiono solo per i Ladri o per tutti i personaggi."
-- Shown under Enable Lockbox Notifications while it is on and Automated Opening is off.
L["LOCKBOXES_NOTIFICATIONS_OFF_NOTE"] =
	"Le notifiche delle cassette non vengono usate finché la funzione Apertura automatica è disattivata."
L["LOCKBOXES_FOR_ROGUES"] = "Per i Ladri"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "Per tutti i personaggi"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking (225)" line (ITEM_MIN_SKILL), or under GogoLoot's own
    ITEM_REQ_SKILL line where the client prints none, followed by a skill
    number. Argument: the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "Il tuo livello di %s"

-- On the Automated Opening panel, below its switch.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "Attiva notifiche di Ignora"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Ti avvisa in chat quando GogoLoot lascia stare un contenitore perché l'Elenco apribili dice Ignora, e ti spiega perché."

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	"Ogni contenitore che GogoLoot conosce, e cosa ne fa Apertura automatica. Ignora tiene chiuso un contenitore, e Bottino rapido lo lascia per te nella finestra del bottino. Le tue modifiche valgono per tutti i tuoi personaggi."
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] =
	"Finché la funzione Apertura automatica è disattivata si usa solo Ignora: impedisce comunque a Bottino rapido di prenderli."
-- The same while Speedy Loot is off too.
L["OPENABLE_ITEMS_ALL_OFF_NOTE"] =
	"Queste impostazioni non vengono usate finché Apertura automatica e Bottino rapido sono disattivati."
L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"] =
	"Riporta l'elenco ai valori predefiniti: ogni oggetto torna alla sua impostazione predefinita, gli oggetti rimossi ritornano e quelli aggiunti spariscono."
L["OPENABLE_ITEMS_RESTORE_CONFIRM"] =
	"Riportare l'elenco ai valori predefiniti? Ogni impostazione modificata e ogni oggetto aggiunto o rimosso verranno annullati."
L["OPENABLE_ITEMS_ADD_DESCRIPTION"] =
	"Inserisci l'ID di un oggetto o trascina qui un oggetto per aggiungerlo all'elenco, impostato su Apri. Equipaggiamento e sacche non si possono aggiungere, perché usarli li equipaggia."
L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"] =
	"Aggiunge all'elenco un oggetto che porti con te, impostato su Apri. Equipaggiamento e sacche non vengono proposti, perché usarli li equipaggia."
L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"] =
	"Rimuove questo oggetto dall'elenco. GogoLoot lo tratterà poi come un oggetto normale: mai aperto, e raccolto come qualsiasi altro."
L["OPENABLE_ITEMS_REMOVE_CONFIRM"] = "Rimuovere questo oggetto dall'elenco? Aggiungilo di nuovo per recuperarlo."
L["OPENABLE_ITEMS_ACTION_DESCRIPTION"] = "Stabilisce cosa fa Apertura automatica con questo contenitore."

-- The Openables List dropdown, one per item.
L["OPENING_ACTION_OPEN"] = "Apri"
L["OPENING_ACTION_IGNORE"] = "Ignora"

--[[
    The reason an item's default carries, shown as a short silver tag on its
    Openables List row whatever it is set to. Sell Sealed covers both a raid
    boss drop and a container that can hold Bind on Pickup loot.
]]
L["OPENING_TAG_SEALED"] = "Vendi sigillato"
L["OPENING_TAG_UNIQUE"] = "Può contenere unico"

--[[
    Each tag explained, under the item's tooltip on the Openables List. The
    item's own tooltip is directly above, so these never name the item.
]]
-- Argument: the game's own name for the Rogue class.
L["OPENING_REASON_LOCKED_CLASS"] =
	"Serve un %s per scassinarlo. Una volta scassinato, si apre come qualsiasi altro contenitore."
L["OPENING_REASON_RAID"] =
	"Lasciato da un boss di incursione o mondiale. Un contenitore non aperto si può ancora scambiare o vendere, spesso per più di quanto contiene."
L["OPENING_REASON_BIND_ON_PICKUP"] =
	"Può contenere bottino Si vincola alla raccolta. Sigillato, si può ancora scambiare o vendere."
L["OPENING_REASON_UNIQUE"] = "Può contenere un oggetto unico. Aprirlo fallisce con un errore se ne porti già uno."

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
L["ROLL_CALL_START"] = "Tirate per %s con /roll, %d secondi"
-- Arguments: the seconds left, then the item.
L["ROLL_CALL_LAST_SECONDS"] = "Restano %d secondi per %s"
-- +10 Seconds. Arguments: the seconds added, then the item.
L["ROLL_CALL_EXTENDED"] = "%d secondi in più per %s"
-- Arguments: the item, then the rolls that didn't count, each one of the four lines below, joined by commas.
L["ROLL_CALL_NOT_COUNTED"] = "Non validi per %s: %s"
-- Arguments: the player, then their roll.
L["ROLL_CALL_NOT_COUNTED_EARLY"] = "%s, tiro anticipato (%d)"
L["ROLL_CALL_NOT_COUNTED_REPEAT"] = "%s, tiro extra (%d)"
-- Arguments: the player, their roll, then the range they rolled in.
L["ROLL_CALL_NOT_COUNTED_RANGE"] = "%s, %d (%d-%d)"
L["ROLL_CALL_NOT_COUNTED_NOT_TIED"] = "%s, %d (fuori dallo spareggio)"
-- Arguments: the tied players, the roll they tied at, the item, the tied players again, then the seconds.
L["ROLL_CALL_TIE"] = "%s pari con %d per %s. Solo %s, /roll di nuovo, %d secondi"
-- With Re-roll Ties off. Arguments: the tied players, the roll they tied at, then the item.
L["ROLL_CALL_TIE_HELD"] = "%s pari con %d per %s. Ci sarà uno spareggio"
-- Arguments: the winner, the item, then the winning roll.
L["ROLL_CALL_WINS"] = "%s vince %s con %d"
-- After a disqualification or a restore changed who won. Arguments as above.
L["ROLL_CALL_NOW_WINS"] = "Ora %s vince %s con %d"
-- Argument: the item.
L["ROLL_CALL_NOBODY"] = "Nessuno ha tirato per %s. Per ora resta nella mia lista"
L["ROLL_CALL_NOBODY_LEFT"] = "Nessun tiro per %s è ancora valido. Torna nella mia lista"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_DISQUALIFIED_NO_REASON"] = "Ho squalificato il tiro di %s (%d) per %s"
-- The same with a reason. Arguments: the player, their roll, the item, then one of the ROLL_DISQUALIFY_REASON_ lines.
L["ROLL_CALL_DISQUALIFIED_BECAUSE"] = "Ho squalificato il tiro di %s (%d) per %s: %s"
-- Arguments: the player, their roll, then the item.
L["ROLL_CALL_RESTORED"] = "Ho ripristinato il tiro di %s (%d) per %s"
-- Arguments: the item, then the seconds.
L["ROLL_CALL_VOIDED"] = "Ho annullato tutti i tiri per %s. Tirate di nuovo con /roll, %d secondi"
-- Argument: the item.
L["ROLL_CALL_CANCELED"] = "Tiro per %s annullato. Aspettate a tirare"
L["ROLL_CALL_PAUSED"] = "Aspettate a tirare. %s è in pausa"
-- Arguments: the item, then the seconds left.
L["ROLL_CALL_RESUMED"] = "Tiri riaperti per %s, restano %d secondi"
-- Each argument: items, joined by commas.
L["ROLL_CALL_ROLL_ALL"] = "Si tira per questi, in ordine: %s"
L["ROLL_CALL_UP_FOR_ROLL"] = "In palio: %s"
L["ROLL_CALL_FLOOR_LOOT"] = "Bottino comune in palio: %s"
-- Drops by boss posted to the group, a line per boss. Arguments: the boss, then its drops, joined by commas.
L["DROPS_POST_LINE"] = "%s: %s"

--------------------------------------------------------------------------------
-- Roll Calls: Printed
--------------------------------------------------------------------------------

-- Outside a group there's nobody to send to. Argument: the line a group would have seen.
L["ROLL_CALL_SOLO_PREVIEW"] = "Non sei in un gruppo, quindi questo messaggio non è arrivato a nessuno: %s"
-- Arguments: the winner, then the item.
L["ROLL_CALL_WON_PRINT"] =
	"%s ha vinto %s. Apri uno scambio con questo giocatore e GogoLoot lo metterà nella finestra."

--------------------------------------------------------------------------------
-- Roll Tags and Reasons
--------------------------------------------------------------------------------

-- Beside a roll in the loot windows: why it doesn't count, or where it stands.
L["ROLL_TAG_EARLY"] = "Tirato prima della chiamata"
L["ROLL_TAG_LATE"] = "Tirato dopo la chiusura"
L["ROLL_TAG_REPEAT"] = "Tiro extra, non vale"
-- Arguments: the range the player rolled in.
L["ROLL_TAG_RANGE"] = "Intervallo sbagliato (%d-%d)"
L["ROLL_TAG_NOT_TIED"] = "Fuori dallo spareggio"
L["ROLL_TAG_DISQUALIFIED"] = "Squalificato"
-- Argument: one of the reasons below.
L["ROLL_TAG_DISQUALIFIED_BECAUSE"] = "Squalificato: %s"
L["ROLL_TAG_WINNER"] = "Vincitore"
L["ROLL_TAG_HIGHEST"] = "Il più alto finora"
L["ROLL_TAG_TIED"] = "In parità"

-- The reasons offered when the loot master disqualifies a roll, also sent after ROLL_CALL_DISQUALIFIED_BECAUSE's colon.
L["ROLL_DISQUALIFY_REASON_NOT_ELIGIBLE"] = "Non idoneo per questo oggetto"
L["ROLL_DISQUALIFY_REASON_ALREADY_WON"] = "Ha già vinto un oggetto stasera"
L["ROLL_DISQUALIFY_REASON_FOR_SOMEONE_ELSE"] = "Ha tirato per qualcun altro"
L["ROLL_DISQUALIFY_REASON_NONE"] = "Nessun motivo indicato"

--------------------------------------------------------------------------------
-- Loot Master Window
--------------------------------------------------------------------------------

-- The tabs. Argument: how many items each holds.
L["LOOT_MASTER_TAB_ROLL_LIST"] = "Elenco tiri (%d)"
L["LOOT_MASTER_TAB_FLOOR_LOOT"] = "Bottino comune (%d)"
L["LOOT_MASTER_TAB_AWARDED"] = "Assegnati (%d)"
L["LOOT_MASTER_TAB_SOFT_RESERVES"] = "Prenotazioni"

-- The Roll List's buttons.
L["LOOT_MASTER_ROLL"] = "Tira"
L["LOOT_MASTER_ROLL_AGAIN"] = "Tira di nuovo"
L["LOOT_MASTER_ROLL_ALL"] = "Tira tutto"
L["LOOT_MASTER_PAUSE"] = "Pausa"
L["LOOT_MASTER_RESUME"] = "Riprendi"
L["LOOT_MASTER_STOP"] = "Ferma"
L["LOOT_MASTER_LIST_IN_RAID"] = "Elenca in incursione"
L["LOOT_MASTER_MOVE_UP"] = "Sposta su"
L["LOOT_MASTER_MOVE_DOWN"] = "Sposta giù"
-- Argument: the seconds added.
L["LOOT_MASTER_EXTEND"] = "+%d secondi"
L["LOOT_MASTER_CLOSE_NOW"] = "Chiudi ora"
L["LOOT_MASTER_VOID"] = "Annulla tutti i tiri"
L["LOOT_MASTER_CANCEL_ROLL"] = "Annulla tiro"
L["LOOT_MASTER_TAKE_OFF"] = "Togli dall'elenco"
-- Argument: the winner.
L["LOOT_MASTER_GIVE"] = "Dai a %s"
L["LOOT_MASTER_TRADE"] = "Scambia con %s"
L["LOOT_MASTER_ANNOUNCE_WINNER"] = "Annuncia vincitore"
L["LOOT_MASTER_HANDED_OUT"] = "Segna come consegnato"
L["LOOT_MASTER_REROLL_TIED"] = "Spareggio tra pari"
L["LOOT_MASTER_DISQUALIFY"] = "Squalifica"
L["LOOT_MASTER_RESTORE"] = "Ripristina"

-- A row's trade clock, where it has none to show.
L["LOOT_MASTER_ON_CORPSE"] = "Sul cadavere"
L["LOOT_MASTER_CORPSE_CLOSED"] = "Cadavere chiuso"
L["LOOT_MASTER_BOUND"] = "Vincolato"
L["LOOT_MASTER_NO_LIMIT"] = "Nessun limite"

-- A row's state. Argument: how many rolls have landed.
L["LOOT_MASTER_STATUS_ROLLING"] = "Tiri in corso, %d tiri"
L["LOOT_MASTER_STATUS_TIE_BREAK"] = "Spareggio, %d tiri"
L["LOOT_MASTER_STATUS_ON_HOLD"] = "In attesa, %d tiri"
-- STATUS_TIED and STATUS_NOBODY also title a finished roll in the Loot Tracker.
L["LOOT_MASTER_STATUS_TIED"] = "In parità"
L["LOOT_MASTER_STATUS_NOBODY"] = "Nessuno ha tirato"
L["LOOT_MASTER_STATUS_SOULBOUND"] = "Ora vincolato all'anima"
L["LOOT_MASTER_STATUS_UP_NEXT"] = "Il prossimo"

-- The first line of an opened row.
L["LOOT_MASTER_HEADLINE_ROLLING"] = "Tiri in corso, restano %d secondi."
L["LOOT_MASTER_HEADLINE_ON_HOLD"] = "In attesa, con %d secondi rimasti."
-- Arguments: the tied players, then the seconds left.
L["LOOT_MASTER_HEADLINE_TIE_BREAK"] = "Spareggio per %s, restano %d secondi."
-- Arguments: the winner, then the winning roll.
L["LOOT_MASTER_HEADLINE_WON"] = "%s ha vinto con %d."
-- Arguments: the tied players, then the roll they tied at.
L["LOOT_MASTER_HEADLINE_TIED"] = "%s in parità con %d."
L["LOOT_MASTER_HEADLINE_SOULBOUND"] = "Ora è vincolato all'anima, quindi non si può più scambiare."
-- Argument: the boss. Also under the game's own trade line on a bag item's tooltip while it is on the Roll List.
L["LOOT_MASTER_LOOTED_FROM"] = "Raccolto da %s."
L["LOOT_MASTER_FROM_FLOOR_LOOT"] = "Dal Bottino comune."
-- After the line above. Argument: how long, in the game's own words for time.
L["LOOT_MASTER_TRADABLE_FOR"] = "Scambiabile per altri %s."
-- Headings over a row's rolls; ROUND_SO_FAR also heads an open roll in the Loot Tracker.
L["LOOT_MASTER_ROUND_SO_FAR"] = "Tiri finora"
L["LOOT_MASTER_ROUND_ROLLS"] = "Tiri"
L["LOOT_MASTER_ROUND_FIRST"] = "Primo tiro"
L["LOOT_MASTER_ROUND_TIE_BREAK"] = "Spareggio"
-- Arguments: how many, then their names. Also in the Loot Tracker.
L["LOOT_MASTER_HASNT_ROLLED"] = "Non hanno tirato (%d): %s"

L["LOOT_MASTER_EMPTY"] =
	"Ancora niente da consegnare. Il bottino scambiabile che raccogli arriva qui da solo; usa Alt + Clic su qualsiasi altro oggetto nelle sacche per aggiungerlo."
-- The line beside the Roll List's buttons.
L["LOOT_MASTER_STATE_PAUSED"] = "In pausa."
L["LOOT_MASTER_STATE_ROLL_ALL"] = "Tira tutto: ne mancano %d."
L["LOOT_MASTER_STATE_ONE_AT_A_TIME"] = "Un tiro alla volta."
L["LOOT_MASTER_STATE_WAITING"] = "%d in attesa di un tiro."
-- The foot of the Roll List. Arguments: how many items, then the time left on the soonest trade clock.
L["LOOT_MASTER_FOOTER"] = "%d da consegnare."
L["LOOT_MASTER_FOOTER_CLOCK"] = "%d da consegnare, il prossimo tempo di scambio scade tra %s."
L["LOOT_MASTER_ALT_CLICK_HINT"] = "Alt + Clic su un oggetto nelle sacche per aggiungerlo"

-- The Disqualify window.
L["LOOT_MASTER_DISQUALIFY_TITLE"] = "Squalifica un tiro"
-- Arguments: the player, their roll, then the item.
L["LOOT_MASTER_DISQUALIFY_BODY"] = "Escludere il tiro di %s (%d) dalla corsa per %s? Potrai ripristinarlo in seguito."
L["LOOT_MASTER_DISQUALIFY_REASON"] = "Motivo"
L["LOOT_MASTER_DISQUALIFY_TELLS"] = "GogoLoot dice al gruppo:"
-- Argument: the item.
L["LOOT_MASTER_VOID_CONFIRM"] = "Scartare tutti i tiri per %s e chiedere di tirare di nuovo?"

-- Printed by the Loot Master.
L["LOOT_MASTER_ROLL_ALL_DONE"] = "Tira tutto è terminato. Ogni oggetto dell'Elenco tiri ha avuto il suo tiro."
L["LOOT_MASTER_ROLL_ALL_PAUSED"] = "Tira tutto è in pausa. Non parte nulla di nuovo finché non premi Riprendi."
L["LOOT_MASTER_ROLL_ALL_RESUMED"] = "Tira tutto è ripreso."
L["LOOT_MASTER_ROLL_ALL_STOPPED"] = "Tira tutto è fermo. Un tiro in corso arriva comunque alla fine."
-- Arguments: the item, then the whole minutes left.
L["LOOT_MASTER_TRADE_TIME_LOW"] = "%s si può scambiare per altri %d minuti."
-- Argument: the item.
L["LOOT_MASTER_TRADE_TIME_OVER"] = "%s non si può più scambiare."
-- Arguments: the item, the winner, then their winning roll.
L["LOOT_MASTER_TRADE_FILLED"] = "Messo %s nella finestra di scambio per %s, che l'ha vinto con %d."
-- Arguments: the winner, then the item.
L["LOOT_MASTER_NOT_A_CANDIDATE"] = "A %s non si può dare %s da questo cadavere."
-- Argument: the item.
L["LOOT_MASTER_ADDED"] = "%s è entrato nell'Elenco tiri."
L["LOOT_MASTER_NOT_TRADABLE"] = "%s non è scambiabile, quindi non può entrare nell'Elenco tiri."
-- Argument: how many joined.
L["LOOT_MASTER_FLOOR_ADDED"] = "Oggetti del Bottino comune entrati nell'Elenco tiri: %d."
L["LOOT_MASTER_OFF"] =
	"Il Gestore del bottino è disattivato. Attivalo in Opzioni > AddOn > GogoLoot > Gestore del bottino."

-- A bag item's tooltip, under the game's own trade line, while it is on the Roll List.
L["LOOT_MASTER_TOOLTIP_ON_ROLL_LIST"] = "Nell'Elenco tiri."
-- Arguments: the winner, then their winning roll.
L["LOOT_MASTER_TOOLTIP_WON_BY"] = "Vinto da %s con %d."

-- Floor Loot. The add box, filter and Add from Bags use the item lists' own words (ITEM_LIST_*).
L["LOOT_MASTER_FLOOR_DESCRIPTION"] =
	"Bottino senza tempo di scambio che vuoi mettere in palio: materiali, ricette, equipaggiamento Si vincola all'equipaggiamento. Parte vuoto, quindi si tira solo per ciò che aggiungi. Un tiro per pila."
L["LOOT_MASTER_FLOOR_EMPTY"] =
	"Ancora niente qui. Scegli da Aggiungi dalle sacche, o trascina un oggetto nella casella qui sopra."
-- Argument: how many the bags hold.
L["LOOT_MASTER_FLOOR_IN_BAGS"] = "%d nelle sacche"
L["LOOT_MASTER_FLOOR_ON_ROLL_LIST"] = "Nell'Elenco tiri"
L["LOOT_MASTER_FLOOR_REMOVE"] = "Toglie questo oggetto dal Bottino comune."
-- The heading for an item whose kind the game hasn't said yet.
L["LOOT_MASTER_FLOOR_OTHER"] = "Altro"
L["LOOT_MASTER_FLOOR_ADD_ALL"] = "Aggiungi tutto all'Elenco tiri"
-- Add from Bags' two headings.
L["LOOT_MASTER_FLOOR_MENU_PICKED_UP"] = "Raccolti in questa istanza"
L["LOOT_MASTER_FLOOR_MENU_BAGS"] = "Anche nelle tue sacche"
-- Argument: what was typed.
L["LOOT_MASTER_FLOOR_NOT_FOUND"] = 'Nelle tue sacche nessun oggetto scambiabile corrisponde a "%s".'

-- Awarded.
L["LOOT_MASTER_AWARDED_EMPTY"] = "Ancora niente consegnato. Un oggetto vinto arriva qui quando il vincitore lo riceve."
-- Arguments: the winning roll, then the time it was handed out.
L["LOOT_MASTER_AWARDED_ROLLED"] = "Tirato %d, %s"
-- Argument: the time it was handed out.
L["LOOT_MASTER_AWARDED_GIVEN"] = "Consegnato %s"
L["LOOT_MASTER_AWARDED_CLEAR"] = "Svuota"

-- Soft Reserves, a placeholder for now.
L["LOOT_MASTER_SOFT_RESERVES_DESCRIPTION"] =
	"Incolla qui una stringa di prenotazioni per vedere chi ha prenotato cosa. In arrivo: per ora questa scheda è solo un segnaposto."
L["LOOT_MASTER_SOFT_RESERVES_PLACEHOLDER"] = "L'importazione delle prenotazioni non è ancora pronta."
L["LOOT_MASTER_SOFT_RESERVES_IMPORT"] = "Importa"

--------------------------------------------------------------------------------
-- Loot Tracker Window
--------------------------------------------------------------------------------

L["LOOT_TRACKER_TITLE"] = "Monitor del bottino"
L["LOOT_TRACKER_TAB_ROLLS"] = "Tiri"
L["LOOT_TRACKER_TAB_DROPS"] = "Bottini"
L["LOOT_TRACKER_NO_ROLL"] = "Ancora nessun tiro stasera."
-- Argument: who called the roll.
L["LOOT_TRACKER_CALLED_BY"] = "Chiamato da %s"
L["LOOT_TRACKER_SPOTTED"] = "Visto in chat da %s"
-- Argument: whole seconds left.
L["LOOT_TRACKER_SECONDS_LEFT"] = "%ds rimasti"
-- A roll called without GogoLoot. Argument: who called it.
L["LOOT_TRACKER_UNSYNCED_NOTE"] =
	"%s non usa GogoLoot, quindi questi sono i tiri visti in chat, controllati con le regole solite: 1-100, solo il primo tiro. L'ultima parola spetta a chi ha chiamato il tiro."
L["LOOT_TRACKER_ON_HOLD"] = "In attesa. Aspetta la chiamata per tirare di nuovo."
L["LOOT_TRACKER_TIE_BREAK_ROLLS"] = "Tiri di spareggio"
-- Arguments: the winner, then the winning roll.
L["LOOT_TRACKER_WON_WITH"] = "%s ha vinto con %d"
L["LOOT_TRACKER_CLOSED"] = "Chiuso"
-- The sort buttons.
L["LOOT_TRACKER_SORT_HIGH"] = "Più alti"
L["LOOT_TRACKER_SORT_TIME"] = "In ordine di tiro"
L["LOOT_TRACKER_ROLL"] = "Tira (1-100)"
-- Beside the player's own roll, and the line beside the Roll and Pass buttons.
L["LOOT_TRACKER_YOU"] = "Tu"
L["LOOT_TRACKER_YOU_ROLLED"] = "Hai tirato %d."
L["LOOT_TRACKER_YOU_PASSED"] = "Hai passato."
L["LOOT_TRACKER_NOT_ROLLED"] = "Non hai tirato."
L["LOOT_TRACKER_NOT_IN_TIE_BREAK"] = "Ora tirano solo i giocatori in parità."
L["LOOT_TRACKER_EARLIER"] = "Prima, stasera"
--[[
    The word, in lower case, that marks a group chat line with an item link as
    a call for rolls by someone without GogoLoot. "roll" is always read too.
]]
L["LOOT_TRACKER_ROLL_WORD"] = "tirate"

-- Drops.
L["LOOT_TRACKER_SHOW_WINNERS"] = "Mostra chi ha preso cosa"
L["LOOT_TRACKER_DROPS_EMPTY"] =
	"Ancora nessun bottino visto. Comparirà qui man mano che i boss muoiono e i cadaveri vengono saccheggiati."
L["LOOT_TRACKER_DROPS_NOTHING_SEEN"] = "Nessuno con GogoLoot l'ha ancora saccheggiato."
L["LOOT_TRACKER_NOT_HANDED_OUT"] = "Non ancora consegnato"
L["LOOT_TRACKER_PRINT"] = "Scrivi"
L["LOOT_TRACKER_POST"] = "Pubblica in incursione"
L["LOOT_TRACKER_COPY"] = "Copia"
L["LOOT_TRACKER_COPY_TITLE"] = "Copia con Ctrl+C"

-- Drops by boss, printed and copied.
L["DROPS_TRASH"] = "Nemici minori"
L["DROPS_NONE"] = "Ancora nessun bottino registrato."
-- Argument: the instance.
L["DROPS_PRINT_HEADER"] = "Bottini in %s:"
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
	"Assegna con un tiro ciò che puoi ancora scambiare, con il tempo di scambio di ogni oggetto, e segui ogni tiro nel Monitor del bottino. Clic centrale sul pulsante della minimappa, oppure scrivi /gogo master o /gogo tracker."
L["LOOT_MASTER_ENABLE"] = "Attiva Gestore del bottino"
L["LOOT_MASTER_ENABLE_DESCRIPTION"] =
	"Tiene traccia del bottino che puoi ancora scambiare e chiede di tirare per assegnarlo. Se è disattivato, Gestore e Monitor del bottino non si aprono mai e nessun tiro viene letto."
L["LOOT_MASTER_OPEN"] = "Apri Gestore del bottino"
L["LOOT_TRACKER_OPEN"] = "Apri Monitor del bottino"
-- A dropdown choice. Argument: the number.
L["LOOT_MASTER_SECONDS"] = "%d secondi"
L["LOOT_MASTER_MINUTES"] = "%d minuti"
L["LOOT_MASTER_KEEP_RAIDS"] = "%d"

L["LOOT_MASTER_CALLING_HEADER"] = "Chiamata dei tiri"
L["LOOT_MASTER_ROLL_LENGTH"] = "Durata del tiro"
L["LOOT_MASTER_ROLL_LENGTH_DESCRIPTION"] = "Per quanto tempo resta aperto un tiro."
L["LOOT_MASTER_ANNOUNCE_IN"] = "Annuncia in"
L["LOOT_MASTER_ANNOUNCE_IN_DESCRIPTION"] = "Dove vanno le chiamate dei tiri, i pareggi e le pause."
L["LOOT_MASTER_CHANNEL_GROUP"] = "Chat di gruppo"
L["LOOT_MASTER_ANNOUNCE_IN_NOTE"] =
	"Avviso incursione ripiega sulla chat di gruppo quando non sei capo o assistente. I vincitori vanno sempre nella chat di gruppo."
-- Argument: the seconds.
L["LOOT_MASTER_WARN_LAST_SECONDS"] = "Avvisa quando restano %d secondi"
L["LOOT_MASTER_WARN_LAST_SECONDS_DESCRIPTION"] = "Avvisa il gruppo quando un tiro sta per chiudersi."
-- Argument: the seconds.
L["LOOT_MASTER_STRETCH_LATE"] = "Aggiungi %d secondi quando qualcuno tira in ritardo"
L["LOOT_MASTER_STRETCH_LATE_DESCRIPTION"] =
	"Un tiro negli ultimi secondi tiene il tiro aperto un po' più a lungo, così il lag non taglia fuori nessuno."
L["LOOT_MASTER_END_EARLY"] = "Chiudi prima quando tutti hanno tirato o passato"
L["LOOT_MASTER_END_EARLY_DESCRIPTION"] = "Chiude il tiro appena ogni membro del gruppo ha tirato o scritto passo."
L["LOOT_MASTER_REROLL_TIES"] = "Spareggio tra i giocatori in parità"
L["LOOT_MASTER_REROLL_TIES_DESCRIPTION"] =
	"Chiama subito uno spareggio per i giocatori in parità. Se è disattivato, un pareggio aspetta che tu prema Spareggio tra pari."
L["LOOT_MASTER_ROLL_ALL_PAUSE"] = "Pausa tra gli oggetti in Tira tutto"
L["LOOT_MASTER_ROLL_ALL_PAUSE_DESCRIPTION"] = "Quanto aspetta Tira tutto dopo un tiro prima di chiamare il successivo."

L["LOOT_MASTER_COUNTING_HEADER"] = "Tiri validi"
-- Argument: the seconds of grace.
L["LOOT_MASTER_COUNTING_DESCRIPTION"] =
	"Un semplice /roll (1-100), solo il primo di ogni giocatore, dal tuo gruppo, mentre il tiro è aperto (%d secondo di tolleranza per il lag). I tiri non validi restano nell'elenco con il motivo."
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED"] = "Annuncia i tiri non validi"
L["LOOT_MASTER_ANNOUNCE_NOT_COUNTED_DESCRIPTION"] =
	"Elenca i tiri non validi, e il motivo, in una sola riga quando il tiro si chiude. Un tiro che squalifichi viene sempre annunciato."

L["LOOT_MASTER_TRADE_HEADER"] = "Bottino scambiabile"
L["LOOT_MASTER_OPEN_ON_TRADABLE"] = "Apri quando raccolgo qualcosa di scambiabile"
L["LOOT_MASTER_OPEN_ON_TRADABLE_DESCRIPTION"] =
	"Apre il Gestore del bottino quando nelle tue sacche arriva bottino Si vincola alla raccolta ancora scambiabile mentre sei in gruppo."
L["LOOT_MASTER_TRADE_WARN"] = "Avvisami quando il tempo di scambio sta per scadere"
L["LOOT_MASTER_TRADE_WARN_DESCRIPTION"] =
	"Ti avvisa una volta, in chat, quando un oggetto dell'Elenco tiri sta per diventare vincolato all'anima."
L["LOOT_MASTER_TRADE_WARN_WHEN"] = "Quanto tempo di scambio resta quando vieni avvisato."
L["LOOT_MASTER_TRADE_AUTO_FILL"] = "Metti gli oggetti vinti nella finestra di scambio"
L["LOOT_MASTER_TRADE_AUTO_FILL_DESCRIPTION"] =
	"Quando apri uno scambio con un vincitore, ciò che ha vinto viene inserito per te. Devi comunque premere Scambia."

L["LOOT_MASTER_FLOOR_HEADER"] = "Bottino comune"
L["LOOT_MASTER_FLOOR_PANEL_DESCRIPTION"] =
	"Il Bottino comune parte vuoto e contiene solo ciò che aggiungi. Aggiungi dalle sacche elenca per primo ciò che hai raccolto in questa istanza."
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE"] = "Togli gli oggetti quando lasciano le mie sacche"
L["LOOT_MASTER_FLOOR_DROP_WHEN_GONE_DESCRIPTION"] =
	"Toglie un oggetto dal Bottino comune quando non te ne resta più nessuno: scambiato, venduto o usato."
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE"] = "Svuota il Bottino comune quando lascio l'incursione"
L["LOOT_MASTER_FLOOR_CLEAR_ON_LEAVE_DESCRIPTION"] = "Inizia ogni incursione con l'elenco del Bottino comune vuoto."

L["LOOT_TRACKER_OPEN_ON_ROLL"] = "Apri quando qualcuno chiama i tiri"
L["LOOT_TRACKER_OPEN_ON_ROLL_DESCRIPTION"] =
	"Apre il Monitor del bottino quando qualcuno del tuo gruppo chiama i tiri, con GogoLoot o con un avviso incursione."
L["LOOT_TRACKER_AUTO_CLOSE"] = "Chiudi da solo dopo la fine del tiro"
L["LOOT_TRACKER_AUTO_CLOSE_DESCRIPTION"] =
	"Un Monitor del bottino che si è aperto da solo si chiude 30 secondi dopo la fine del tiro, a meno che non ci sia sopra il mouse."
L["LOOT_TRACKER_KEEP_DROPS"] = "Incursioni da conservare in Bottini"
L["LOOT_TRACKER_KEEP_DROPS_DESCRIPTION"] = "Quante incursioni ricorda la scheda Bottini."
