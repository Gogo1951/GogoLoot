local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "itIT")
if not L then return end

--[[
    Source locale: every other locale falls back to these strings. Translate
    the values only. Never change the L["KEY"] names, the %s / %d placeholders,
    or the {rt4} raid marker — code and other locales rely on them.
]]

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Versione %s. Le impostazioni (inclusa l'opzione per disabilitare questo messaggio) si trovano in Opzioni > Addon > GogoLoot. Ti piace l'add-on? Parlane a un amico! (="
L["MESSAGE_AUTO_LOOT_ENABLED"] = "Il Depredamento Automatico è necessario affinché GogoLoot funzioni correttamente. È stato attivato."
L["MESSAGE_NOT_MASTER_LOOTER"] = "Al momento non sei il Maestro del Bottino."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

L["MESSAGE_LOOT_ANNOUNCE"] = "Dato %s a %s."
L["MESSAGE_DESTINATION_SET"] = "%s riceverà tutti gli oggetti %s."
L["MESSAGE_DESTINATION_LEFT"] = "%s ha lasciato il gruppo. %s ora riceverà tutti gli oggetti %s."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Dato %s a %s, ricevuto %s."
L["MESSAGE_TRADE_GAVE"] = "Dato %s a %s."
L["MESSAGE_TRADE_RECEIVED"] = "Ricevuto %s da %s."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "Il giocatore che hai selezionato per ricevere quell'oggetto non ha spazio nelle borse."
L["ERROR_MAX_COUNT"] = "Il giocatore che hai selezionato ha già troppi di questo oggetto."
L["ERROR_OUT_OF_RANGE"] = "Il giocatore che hai selezionato per ricevere quell'oggetto non è nel raggio d'azione."
L["ERROR_NOT_IN_GROUP"] = "Il giocatore selezionato non è più nel gruppo o nell'incursione."

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "Maestro del Bottino"
L["TAB_AUTOMATED_ROLLS"] = "Tiri Automatici"
L["TAB_ANNOUNCEMENTS"] = "Annunci"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- GogoLoot is a proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "Abilitato"
L["STATUS_DISABLED"] = "Disabilitato"

L["MINIMAP_AUTO_GREED"] = "Cupidità Automatica"
L["MINIMAP_AUTO_GREED_DESCRIPTION"] = "Tira automaticamente su Cupidità per gli oggetti idonei di qualità pari o inferiore alla soglia selezionata."
L["MINIMAP_SPEEDY_LOOT"] = "Depredamento Rapido"
L["MINIMAP_SPEEDY_LOOT_DESCRIPTION"] = "Raccoglie istantaneamente il bottino senza mostrare la finestra di bottino."

L["MINIMAP_LEFT_CLICK"] = "Clic Sinistro"
L["MINIMAP_RIGHT_CLICK"] = "Clic Destro"
L["MINIMAP_TOGGLE"] = "Attiva/Disattiva"
L["MINIMAP_OPTIONS"] = "Opzioni GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Maiusc + Clic Centrale"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- Quality Labels
L["QUALITY_POOR"] = "Scadente"
L["QUALITY_COMMON"] = "Comune"
L["QUALITY_UNCOMMON"] = "Non comune"
L["QUALITY_RARE"] = "Raro"
L["QUALITY_EPIC"] = "Epico"

-- Roll Action Labels
L["ROLL_MANUAL"] = "Tiro Manuale"
L["ROLL_GREED"] = "Cupidità"
L["ROLL_NEED"] = "Necessità"
L["ROLL_PASS"] = "Passa"

-- Loot Method Labels
L["LOOT_METHOD_FREE_FOR_ALL"] = "Libero"
L["LOOT_METHOD_ROUND_ROBIN"] = "Turnazione"
L["LOOT_METHOD_MASTER"] = "Maestro del Bottino"
L["LOOT_METHOD_GROUP"] = "Bottino di Gruppo"
L["LOOT_METHOD_NEED_BEFORE_GREED"] = "Necessità prima di Cupidità"

-- Threshold Labels
L["THRESHOLD_POOR_ONLY"] = "Solo Scadente"
L["THRESHOLD_COMMON_LOWER"] = "Comune e Inferiore"
L["THRESHOLD_UNCOMMON_LOWER"] = "Non comune e Inferiore"
L["THRESHOLD_RARE_LOWER"] = "Raro e Inferiore"
L["THRESHOLD_EPIC_LOWER"] = "Epico e Inferiore"

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "Caricamento... (ID: %d)"

-- Version prefix in the options panel and minimap tooltip
L["VERSION_LABEL"] = "Versione"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] = "Raccogli l'equipaggiamento con il Maestro del Bottino automatico, tira automaticamente Necessità o Cupidità sui bottini non-BoP e annuncia in modo trasparente ogni scambio in chat. Oggetti di missione, ricette, cavalcature, mascotte e leggendari sono sempre al sicuro. Non lasciare che il bottino rallenti il tuo zug!"
L["WELCOME_MESSAGE"] = "Abilita Messaggio di Benvenuto"
L["MINIMAP_BUTTON_ENABLE"] = "Abilita Pulsante Minimappa"

L["COMMANDS"] = "/Comandi"
L["COMMANDS_DESCRIPTION"] = "Apre l'interface delle opzioni di GogoLoot."

L["SPEEDY_LOOT_HEADER"] = "Depredamento Rapido"
L["SPEEDY_LOOT_DESCRIPTION"] = "Raccoglie istantaneamente il bottino senza mostrare la finestra, risparmiando tempo tra le uccisioni."
L["SPEEDY_LOOT_ENABLE"] = "Abilita Depredamento Rapido"

L["FEEDBACK_SUPPORT"] = "Feedback e Supporto"

-- CurseForge / GitHub / Discord are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

--------------------------------------------------------------------------------
-- Options: Profiles
--------------------------------------------------------------------------------

L["OPTIONS_RESET_ALL_PROFILES"] = "Ripristina tutti i profili"
L["OPTIONS_RESET_ALL_PROFILES_DESCRIPTION"] = "Ripristina ogni profilo su questo account alle impostazioni predefinite."
L["OPTIONS_RESET_ALL_PROFILES_CONFIRM"] = "Questo ripristinerà TUTTI i profili sul tuo account alle impostazioni predefinite — per ogni personaggio. Non è possibile annullare. Continuare?"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"] = "Il metodo e la soglia di bottino attuali del tuo gruppo."
L["MASTER_LOOTER_LOOT_TYPE"] = "Tipo di Bottino"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "Soglia del Bottino"
L["MASTER_LOOTER_SET_BY"] = "(Impostato da %s)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "Solo il capogruppo può cambiare il metodo e la soglia del bottino."

L["MASTER_LOOTER_AUTO_HEADER"] = "Maestro del Bottino Automatico"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] = "Distribuisce automaticamente il bottino ai giocatori designati quando sei il Maestro del Bottino. Oggetti di missione, libri, ricette, cavalcature, mascotte e leggendari vengono sempre saltati ed appariranno nella finestra di bottino standard."
L["MASTER_LOOTER_AUTO_ENABLE"] = "Abilita Maestro del Bottino Automatico in Istanza"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Abilita Maestro del Bottino Automatico fuori dalle Istanze"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] = "Attenzione: Poiché il bottino dei boss mondiali non è scambiabile, è sconsigliato!"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "Destinazioni del Bottino"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "Assegna a un membro del gruppo la ricezione di oggetti per ogni livello di qualità."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Te Stesso"
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Scegli chi riceve oggetti %s."

L["MASTER_LOOTER_IGNORE_HEADER"] = "Lista Ignorati"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] = "Gli oggetti in questa lista non verranno distribuiti automaticamente e appariranno in una finestra di bottino standard per un'assegnazione manuale."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "Ripristina Lista Ignorati Predefinita"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] = "Questo sostituirà la tua lista ignorati del maestro del bottino con gli oggetti predefiniti per la tua espansione. Continuare?"
L["MASTER_LOOTER_IGNORE_ADD_DESCRIPTION"] = "Inserisci un ID oggetto o incolla un link dell'oggetto per aggiungerlo alla lista degli ignorati."
L["MASTER_LOOTER_IGNORE_ADD"] = "Aggiungi Oggetto"
L["MASTER_LOOTER_IGNORE_REMOVE"] = "Rimuovi"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Rimuovi questo oggetto dalla lista degli ignorati."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] = "Tira automaticamente su Cupidità per oggetti Non Vincolati alla raccolta (BoE) di qualità pari o inferiore a quella selezionata. Oggetti di missione, libri, ricette, cavalcature, mascotte e leggendari vengono sempre saltati."
L["ROLLS_ENABLE"] = "Abilita Tiri Automatici"
L["ROLLS_THRESHOLD"] = "Soglia Cupidità Automatica"

L["ROLLS_CUSTOM_LIST"] = "Lista Tiri Personalizzati"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "Gli oggetti in questa lista hanno una loro regola di tiro che annulla la soglia."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "Abilita Lista Tiri Personalizzati"
L["ROLLS_RESTORE_DEFAULTS"] = "Ripristina Lista Tiri Personalizzati Predefinita"
L["ROLLS_RESTORE_CONFIRM"] = "Questo sostituirà la tua lista tiri personalizzati con gli oggetti predefiniti per la tua espansione. Continuare?"
L["ROLLS_ADD_ITEM_DESCRIPTION"] = "Inserisci un ID oggetto o trascina un oggetto qui per aggiungerlo alla lista."
L["ROLLS_ADD_ITEM"] = "Aggiungi Oggetto"
L["ROLLS_CHOOSE_ACTION"] = "Scegli l'action di tiro automatica per questo oggetto."
L["ROLLS_REMOVE"] = "Rimuovi"
L["ROLLS_REMOVE_DESCRIPTION"] = "Rimuove questo oggetto dalla lista tiri personalizzati."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "Annunci di Scambio"
L["TRADE_DESCRIPTION"] = "Invia automaticamente un riepilogo degli scambi completati nella chat, inclusi oggetti, incantamenti e oro scambiati."
L["TRADE_ENABLE"] = "Abilita Annunci di Scambio"
L["TRADE_CONDITION"] = "Quando"
L["TRADE_CONDITION_ALWAYS"] = "Sempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Solo in Gruppo o Incursione"
L["TRADE_CONDITION_RAID_ONLY"] = "Solo in Incursione"
L["TRADE_OUTPUT"] = "Output Messaggio"
L["TRADE_OUTPUT_WHISPER"] = "Sussurro"
L["TRADE_OUTPUT_GROUP"] = "Chat di Gruppo"
L["TRADE_EXAMPLE"] = "Esempio: {rt4} Dato [Oggetto X] x2, [Oggetto Y] a Fathom. // GogoLoot"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Invia un riepilogo nella chat quando questo scambio è completato."
L["TRADE_TOOLTIP_OUTPUT"] = "Output Corrente"
L["TRADE_CHECKBOX_LABEL"] = "Annuncia"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Invia l'attività del maestro del bottino nella chat di gruppo per trasparenza. Le distribuzioni automatiche usano una soglia di qualità per evitare spam; le distribuzioni manuali sono sempre annunciate."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Abilita i Messaggi quando il Maestro del Bottino è Impostato"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] = "Esempio: {rt4} GogoLoot // Aevala riceverà tutti gli oggetti Epici."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Abilita Annunci Distribuzione Automatica"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "Soglia Annunci Automatici"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Esempio: {rt4} GogoLoot // Dato [Oggetto X] a Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] = "Nota: Ogni oggetto distribuito manualmente viene sempre annunciato, indipendentemente dalla qualità."
