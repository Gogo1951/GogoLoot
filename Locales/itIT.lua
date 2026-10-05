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
	"Versione %s. Trovi le impostazioni (compresa l'opzione per disattivare questo messaggio) in Opzioni > Add-on > GogoLoot. Ti piace l'add-on? Parlane a un amico! (="
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

L["TAB_AUTOMATED_ROLLS"] = "Tiri automatici"
L["TAB_ITEM_OVERRIDES"] = "Eccezioni per oggetto"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "Regole per personaggio"
-- The panel for everything GogoLoot posts to chat.
L["TAB_ANNOUNCEMENTS"] = "Annunci"
-- Headers of the two sections on the Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Annunci di scambio"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Annunci del Responsabile del bottino"
L["TAB_LOOT_TOASTS"] = "Avvisi del bottino"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Filtri"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Suoni del bottino"
L["TAB_AUTOMATED_OPENING"] = "Apertura automatica"
-- Header of a section on the Automated Opening panel.
L["TAB_LOCKBOXES"] = "Cassette"
L["TAB_OPENABLE_ITEMS"] = "Elenco apribili"
L["TAB_MASTER_LOOTER"] = "Responsabile del bottino"
-- Header of a section on the Master Looter panel.
L["TAB_LOOT_DESTINATIONS"] = "Destinazioni del bottino"
L["TAB_IGNORE_LIST"] = "Elenco ignorati"

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
    The tooltip titles each feature with its options-panel name (Automated
    Master Looting excepted, since its panel is titled Master Looter), and
    gives each a description of its own, two lines at most: the panels' longer
    text doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Tira per te sugli oggetti idonei fino alla qualità che scegli."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] = "Apre vongole, casse, borsellini e cassette scassinate nelle tue sacche."
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
-- The tooltip's title for the Automated Master Looting block, the feature its switch names.
L["MINIMAP_AUTOMATED_MASTER_LOOTING"] = "Consegna automatica del bottino"
L["MINIMAP_TOGGLE"] = "Attiva/Disattiva"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Oggetti chiusi"
L["MINIMAP_OPTIONS"] = "Opzioni di GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Maiusc + Clic centrale"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Manuale"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "Solo %s"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s e inferiore"

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

-- The muted version line at the foot of the General panel.
L["OPTIONS_VERSION"] = "Versione %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Bottino rapido svuota i cadaveri in un lampo, Tiri automatici e Consegna automatica del bottino decidono chi prende cosa, e Apertura automatica spalanca ogni vongola e cassa. Avvisi del bottino ti mostrano tutto, mentre oggetti di missione, ricette, cavalcature, mascotte e leggendari restano al sicuro. Non lasciare che il bottino ti rallenti la corsa!"
L["WELCOME_MESSAGE"] = "Attiva messaggio di benvenuto"
L["WELCOME_MESSAGE_DESCRIPTION"] = "Mostra la versione di GogoLoot e dove trovare queste impostazioni a ogni accesso."
L["MINIMAP_BUTTON_ENABLE"] = "Attiva pulsante della minimappa"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Mostra il pulsante di GogoLoot sulla minimappa. Clic sinistro attiva o disattiva Tiri automatici, Clic destro Apertura automatica, Maiusc + Clic sinistro Annunci e Maiusc + Clic destro Consegna automatica del bottino."

L["OPTIONS_COMMANDS_HEADER"] = "/Comandi"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Apre l'interfaccia delle opzioni di questo add-on."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Funzioni"

L["SPEEDY_LOOT_ENABLE"] = "Attiva Bottino rapido"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"Svuota ogni cadavere appena lo apri, senza mostrare la finestra del bottino. Tieni premuto Maiusc mentre raccogli per vedere invece la finestra. Attiva l'opzione %s del gioco e si fa da parte mentre sei %s."

L["FEEDBACK_SUPPORT"] = "Feedback e supporto"

-- CurseForge / GitHub / Discord / Wago are proper nouns; do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

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
-- Shown on Item Overrides while Automated Rolls is off.
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
L["ANNOUNCEMENTS_ENABLE"] = "Attiva annunci"
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
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast it follows the item
    (LOOT_TOASTS_WON_ROLL); on a group member's, their name
    (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Tiro vincente"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"Aggiunge all'avviso il tiro con cui hai vinto un oggetto, ad esempio (%s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Aggiunge all'avviso di un membro del gruppo il tiro con cui ha vinto un oggetto, ad esempio (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_WON_ROLL"] = "%s (%s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Quantità nelle sacche"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Aggiunge agli avvisi del tuo bottino quanti ne porti ora con te, ad esempio x3 (27), quando ne porti più della quantità indicata dall'avviso."
-- How many came, after the item on a toast. Argument: the count.
L["LOOT_TOASTS_QUANTITY"] = "x%d"
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
L["LOOT_SOUNDS_ENABLE"] = "Attiva suono del bottino"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Riproduce un rintocco quando raccogli da un cadavere o da un forziere un oggetto di qualità pari o superiore a quella che scegli."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "La qualità minima degli oggetti che riproduce il suono del bottino."
L["LOOT_SOUNDS_TEST"] = "Riproduce il suono del bottino."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "Attiva suono di %s"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "Riproduce un suono di sacca quando %s ottiene davvero qualcosa."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "Riproduce il suono di %s."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"Apre per te vongole, casse, borsellini e cassette scassinate nelle tue sacche, ogni volta che hai almeno %d spazi liberi."
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
L["LOCKBOXES_FOR_ROGUES"] = "Per i Ladri"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "Per tutti i personaggi"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking" line (ITEM_REQ_SKILL), followed by a skill number. Argument:
    the game's own name for the Lockpicking skill.
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
