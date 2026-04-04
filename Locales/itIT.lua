local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "itIT")
if not L then return end

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["MSG_SETTINGS_RESET_UPDATE"] = "Le impostazioni sono state ripristinate per questo aggiornamento. Usa /gl per rivedere le tue opzioni."
L["MSG_SETTINGS_RESET_DEFAULTS"] = "Tutte le impostazioni sono state riportate ai valori predefiniti."
L["MSG_CONFLICT_DETECTED"] = "Rilevati addon di bottino in conflitto."
L["MSG_CONFLICT_ADDON"] = "Addon in conflitto: %s"
L["MSG_AUTO_LOOT_ENABLED"] = "Il Depredamento Automatico è necessario affinché GogoLoot funzioni correttamente. È stato attivato."
L["MSG_NOT_MASTER_LOOTER"] = "Al momento non sei il Maestro del Bottino."

--------------------------------------------------------------------------------
-- Quality Labels
--------------------------------------------------------------------------------

L["QUALITY_POOR"] = "Scadente"
L["QUALITY_COMMON"] = "Comune"
L["QUALITY_UNCOMMON"] = "Non comune"
L["QUALITY_RARE"] = "Raro"
L["QUALITY_EPIC"] = "Epico"

--------------------------------------------------------------------------------
-- Roll Action Labels
--------------------------------------------------------------------------------

L["ROLL_MANUAL"] = "Tiro Manuale"
L["ROLL_GREED"] = "Cupidità"
L["ROLL_NEED"] = "Necessità"
L["ROLL_PASS"] = "Passa"

--------------------------------------------------------------------------------
-- Loot Method Labels
--------------------------------------------------------------------------------

L["LOOT_METHOD_FFA"] = "Libero"
L["LOOT_METHOD_ROUND_ROBIN"] = "Turnazione"
L["LOOT_METHOD_MASTER"] = "Maestro del Bottino"
L["LOOT_METHOD_GROUP"] = "Bottino di Gruppo"
L["LOOT_METHOD_NBG"] = "Necessità prima di Cupidità"

--------------------------------------------------------------------------------
-- Threshold Labels
--------------------------------------------------------------------------------

L["THRESHOLD_POOR_ONLY"] = "Solo Scadente"
L["THRESHOLD_COMMON_LOWER"] = "Comune e Inferiore"
L["THRESHOLD_UNCOMMON_LOWER"] = "Non comune e Inferiore"
L["THRESHOLD_RARE_LOWER"] = "Raro e Inferiore"
L["THRESHOLD_EPIC_LOWER"] = "Epico e Inferiore"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL"] = "Generale"
L["GENERAL_DESC"] = "Impostazioni base che si applicano ogni volta che GogoLoot è attivo."
L["SPEEDY_LOOT"] = "Abilita Depredamento Rapido"
L["SPEEDY_LOOT_DESC"] = "Raccoglie istantaneamente il bottino senza mostrare la finestra, risparmiando tempo tra le uccisioni."

L["COMMANDS"] = "/Comandi"
L["COMMANDS_DESC_GL"] = "Apre l'interfaccia delle opzioni di GogoLoot."
L["COMMANDS_DESC_GOGOLOOT"] = "Apre l'interfaccia delle opzioni di GogoLoot."

L["RESET"] = "Ripristina"
L["RESET_DESC"] = "Cancella tutte le impostazioni di GogoLoot e ripristina ogni opzione al suo valore predefinito."
L["RESET_ALL"] = "Ripristina tutte le opzioni GogoLoot"
L["RESET_CONFIRM"] = "Questo ripristinerà TUTTE le impostazioni di GogoLoot ai valori predefiniti. Questa operazione è irreversibile. Continuare?"

L["FEEDBACK_SUPPORT"] = "Feedback e Supporto"
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

L["ITEM_LOADING"] = "Caricamento... (ID: %d)"

--------------------------------------------------------------------------------
-- Options: Trade Announcements
--------------------------------------------------------------------------------

L["TRADE_DESC"] = "Invia automaticamente un riepilogo degli scambi completati nella chat, inclusi oggetti, incantamenti e oro scambiati."
L["TRADE_ENABLE"] = "Abilita Annunci di Scambio"
L["TRADE_ENABLE_DESC"] = "Invia un riepilogo dello scambio quando viene completato."
L["TRADE_CONDITION"] = "Quando si è in Gruppo"
L["TRADE_CONDITION_DESC"] = "Controlla quando sono attivi gli annunci di scambio."
L["TRADE_CONDITION_ALWAYS"] = "Sempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Solo in Gruppo o Incursione"
L["TRADE_CONDITION_RAID_ONLY"] = "Solo in Incursione"
L["TRADE_OUTPUT"] = "Output Messaggio"
L["TRADE_OUTPUT_DESC"] = "Dove viene inviato il riepilogo dello scambio."
L["TRADE_OUTPUT_WHISPER"] = "Sussurro"
L["TRADE_OUTPUT_GROUP"] = "Chat di Gruppo"
L["TRADE_OUTPUT_RAID"] = "Chat di Incursione"
L["TRADE_EXAMPLE"] = "Esempio: {rt4} Ha dato [Oggetto X] x2, [Oggetto Y] a Fathom. // GogoLoot"

L["TRADE_TOOLTIP_TITLE"] = "Annunci di Scambio"
L["TRADE_TOOLTIP_DESC"] = "Invia un riepilogo nella chat quando questo scambio è completato."
L["TRADE_TOOLTIP_OUTPUT"] = "Output Corrente"
L["TRADE_CHECKBOX_LABEL"] = "Annuncia"

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESC"] = "Tira automaticamente su Cupidità per oggetti Non Vincolati alla raccolta di qualità pari o inferiore a quella selezionata. Oggetti di missione, libri, ricette, cavalcature, mascotte e leggendari vengono sempre saltati. Gli oggetti Vincolati alla raccolta non vengono mai tirati in automatico con Cupidità tramite la soglia, ma possono essere automatizzati tramite la Lista Tiri Personalizzati di seguito."
L["ROLLS_ENABLE"] = "Abilita Tiri Automatici"
L["ROLLS_ENABLE_DESC"] = "Tira automaticamente su Cupidità per oggetti idonei alla soglia o inferiori."
L["ROLLS_THRESHOLD"] = "Soglia Cupidità Automatica"
L["ROLLS_THRESHOLD_DESC"] = "Per gli oggetti di questa qualità o inferiore verrà tirato automaticamente su Cupidità."

L["ROLLS_CUSTOM_LIST"] = "Lista Tiri Personalizzati"
L["ROLLS_CUSTOM_LIST_DESC"] = "Gli oggetti in questa lista hanno una loro regola di tiro che annulla la soglia. Questo è l'unico modo per automatizzare oggetti Vincolati alla raccolta come Pietre del Flagello o Rune Demoniache. Imposta ogni oggetto su Tiro Manuale, Cupidità, Necessità o Passa. Oggetti di missione, libri, ricette, cavalcature, mascotte e leggendari vengono sempre saltati."
L["ROLLS_RESTORE_DEFAULTS"] = "Ripristina Lista Tiri Personalizzati Predefinita"
L["ROLLS_RESTORE_CONFIRM"] = "Questo sostituirà la tua lista tiri personalizzati con gli oggetti predefiniti per la tua espansione. Continuare?"
L["ROLLS_ADD_ITEM_DESC"] = "Inserisci un ID oggetto o incolla il link dell'oggetto per aggiungerlo alla lista."
L["ROLLS_ADD_ITEM"] = "Aggiungi Oggetto"
L["ROLLS_ADD_ITEM_TOOLTIP"] = "Inserisci l'ID o trascina il link dell'oggetto qui."
L["ROLLS_CHOOSE_ACTION"] = "Scegli l'azione di tiro automatica per questo oggetto."
L["ROLLS_REMOVE"] = "Rimuovi"
L["ROLLS_REMOVE_DESC"] = "Rimuove questo oggetto dalla lista tiri personalizzati."

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["ML_LOOT_TYPE"] = "Tipo di Bottino (sola lettura, cambia nel Menu di Gioco)"
L["ML_LOOT_THRESHOLD"] = "Soglia del Bottino (sola lettura, cambia nel Menu di Gioco)"

L["ML_AUTO_HEADER"] = "Maestro del Bottino Automatico"
L["ML_AUTO_DESC"] = "Distribuisce automaticamente il bottino ai giocatori designati quando sei il Maestro del Bottino. Oggetti di missione, libri, ricette, cavalcature, mascotte e leggendari vengono sempre saltati ed appariranno nella finestra di bottino standard."
L["ML_AUTO_ENABLE"] = "Abilita Maestro del Bottino Automatico in Istanza"
L["ML_AUTO_ENABLE_DESC"] = "Distribuisce automaticamente il bottino alle destinazioni configurate."
L["ML_AUTO_OUTSIDE"] = "Abilita Maestro del Bottino Automatico fuori dalle Istanze"
L["ML_AUTO_OUTSIDE_CAUTION"] = "Attenzione: Poiché il bottino dei boss mondiali non è scambiabile, è sconsigliato!"

L["ML_DEST_HEADER"] = "Destinazioni del Bottino"
L["ML_DEST_DESC"] = "Assegna a un membro del gruppo la ricezione di oggetti per ogni livello di qualità."
L["ML_DEST_SELF"] = "Te Stesso"
L["ML_DEST_CHOOSE"] = "Scegli chi riceve oggetti %s."

L["ML_ANNOUNCE_HEADER"] = "Annunci Bottino"
L["ML_ANNOUNCE_DESC"] = "Invia un messaggio nella chat di gruppo quando gli oggetti vengono distribuiti tramite il Maestro del Bottino. Le distribuzioni manuali sono sempre annunciate a prescindere dalla soglia."
L["ML_ANNOUNCE_ENABLE"] = "Abilita Annunci Bottino"
L["ML_ANNOUNCE_ENABLE_DESC"] = "Annuncia le distribuzioni di oggetti nella chat di gruppo."
L["ML_ANNOUNCE_THRESHOLD"] = "Soglia Annunci"
L["ML_ANNOUNCE_THRESHOLD_DESC"] = "Annuncia solo oggetti di questa qualità o superiore."
L["ML_ANNOUNCE_EXAMPLE"] = "Esempio: {rt4} Ha dato [Oggetto X] a Gogowarrior. // GogoLoot"

L["ML_IGNORE_HEADER"] = "Lista Ignorati"
L["ML_IGNORE_DESC"] = "Gli oggetti in questa lista non verranno distribuiti automaticamente e appariranno in una finestra di bottino standard per un'assegnazione manuale."
L["ML_IGNORE_RESTORE"] = "Ripristina Lista Ignorati Predefinita"
L["ML_IGNORE_RESTORE_CONFIRM"] = "Questo sostituirà la tua lista ignorati del maestro del bottino con gli oggetti predefiniti. Continuare?"
L["ML_IGNORE_ADD_DESC"] = "Inserisci un ID oggetto o incolla un link dell'oggetto per aggiungerlo alla lista degli ignorati."
L["ML_IGNORE_ADD"] = "Aggiungi Oggetto"
L["ML_IGNORE_ADD_TOOLTIP"] = "Inserisci l'ID o trascina il link dell'oggetto qui."
L["ML_IGNORE_REMOVE"] = "Rimuovi"
L["ML_IGNORE_REMOVE_DESC"] = "Rimuovi questo oggetto dalla lista degli ignorati."