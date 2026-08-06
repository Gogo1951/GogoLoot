local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "itIT")
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
	"Versione %s. Le impostazioni (inclusa l'opzione per disabilitare questo messaggio) si trovano in Opzioni > Addon > GogoLoot. Ti piace l'add-on? Parlane a un amico! (="
L["CHAT_OPTIONS_IN_COMBAT"] =
	"Per precauzione, l'interfaccia delle opzioni non può essere aperta durante il combattimento."
L["MESSAGE_AUTO_LOOT_ENABLED"] =
	"Il depredamento automatico è stato attivato. Il Depredamento Rapido ne ha bisogno per funzionare."
L["MESSAGE_NOT_MASTER_LOOTER"] = "Al momento non sei il Maestro del Bottino."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "Dato %s a %s."
L["MESSAGE_DESTINATION_SET"] = "%s riceverà tutti gli oggetti %s."
L["MESSAGE_DESTINATION_SET_ALL"] = "%s conserverà tutto il bottino per il gruppo."
L["MESSAGE_DESTINATION_LEFT"] = "%s ha lasciato il gruppo. %s ora riceverà tutti gli oggetti %s."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Dato %s a %s, ricevuto %s."
L["MESSAGE_TRADE_RECEIVED"] = "Ricevuto %s da %s."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "Le borse di %s sono piene: %s"
L["ERROR_MAX_COUNT"] = "%s ha già troppi di: %s"
L["ERROR_OUT_OF_RANGE"] = "%s è fuori portata: %s"
L["ERROR_NOT_IN_GROUP"] = "%s non è più nel gruppo o nell'incursione: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "Impossibile dare a %s: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "Maestro del Bottino"
L["TAB_AUTOMATED_ROLLS"] = "Tiri Automatici"
L["TAB_ANNOUNCEMENTS"] = "Annunci"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Abilitato"
L["STATUS_DISABLED"] = "Disabilitato"

--[[
    The tooltip titles each feature with its options-panel name rather than
    keeping its own copy: Automated Rolls uses TAB_AUTOMATED_ROLLS, Speedy Loot
    uses SPEEDY_LOOT_HEADER and SPEEDY_LOOT_DESCRIPTION. Only the roll
    description below is unique to the tooltip, where the panel's longer text
    would not fit.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Tira per te sugli oggetti idonei fino alla qualità scelta."

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
L["ROLL_MANUAL"] = "Manuale"
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

-- Shared by both item lists: the Master Looter ignore list and the Custom Roll List
L["ITEM_LIST_ADD"] = "Aggiungi Oggetto"
L["ITEM_LIST_ADD_DESCRIPTION"] = "Inserisci un ID oggetto o trascina un oggetto qui per aggiungerlo alla lista."

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "Caricamento... (ID: %d)"

-- Appended to the Automated Rolls description.
L["SAFETY_SKIP_NOTE"] =
	"Oggetti di missione, ricette, libri, cavalcature, mascotte e leggendari vengono sempre saltati."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] = "Ricette, libri, cavalcature, mascotte e leggendari vengono sempre saltati."

-- Version prefix in the options panel
L["VERSION_LABEL"] = "Versione"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] =
	"Aspira l'equipaggiamento con il Maestro del Bottino Automatico, i Tiri Automatici e Annunci trasparenti. Oggetti di missione, ricette, cavalcature, mascotte e leggendari restano al sicuro. Non lasciare che il bottino rallenti il tuo zug!"
L["WELCOME_MESSAGE"] = "Abilita Messaggio di Benvenuto"
L["MINIMAP_BUTTON_ENABLE"] = "Abilita Pulsante Minimappa"

L["OPTIONS_COMMANDS_HEADER"] = "/Comandi"
L["OPTIONS_COMMAND"] = "/gl"
L["OPTIONS_COMMAND_ALTERNATE"] = "/gogoloot"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Apre l'interfaccia delle opzioni di questo add-on."

L["SPEEDY_LOOT_HEADER"] = "Depredamento Rapido"
L["SPEEDY_LOOT_DESCRIPTION"] = "Nasconde la finestra del bottino per un saccheggio quasi istantaneo."
L["SPEEDY_LOOT_ENABLE"] = "Abilita Depredamento Rapido"

L["FEEDBACK_SUPPORT"] = "Feedback e Supporto"

-- CurseForge / GitHub / Discord / Wago are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "Impostazioni Bottino Attuali"
L["MASTER_LOOTER_LOOT_METHOD"] = "Metodo di Bottino"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "Soglia del Bottino"
--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them — including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "Queste impostazioni sono controllate da %s."

L["MASTER_LOOTER_AUTO_DESCRIPTION"] = "Distribuisce il bottino ai giocatori designati mentre sei Maestro del Bottino."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "Abilita Maestro del Bottino Automatico"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Anche fuori dalle Istanze"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] =
	"Attenzione: Poiché il bottino dei boss mondiali non è scambiabile, è sconsigliato!"
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "Includi Oggetti di Missione"
L["MASTER_LOOTER_AUTO_QUEST_ITEMS_DESCRIPTION"] =
	"Distribuisce anche gli oggetti di missione, per potenziare un personaggio che giochi tu stesso. Possono essere distribuiti solo gli oggetti di missione che cadono in un unico esemplare per il gruppo. Ciò che ogni giocatore in missione raccoglie per sé, come la testa di un boss, non passa mai dal Maestro del Bottino."
--[[
    Both are shown whether the toggle is on or off: they are what somebody reads
    to decide whether to tick it at all. The NOTE covers what has to be true for
    the option to do anything; the CAUTION covers who it is for, and leads with
    the same word as the outside-instances one above it.
]]
L["MASTER_LOOTER_AUTO_QUEST_ITEMS_NOTE"] =
	"Poiché la maggior parte degli oggetti di missione è di qualità Comune, questo funziona solo con la soglia del bottino impostata su Comune o inferiore. E anche allora, non tutti gli oggetti di missione sono idonei al Maestro del Bottino."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS_CAUTION"] =
	"Attenzione: Questo è pensato per chi gioca più personaggi insieme e non è consigliato nelle incursioni."

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Impostazioni rapide"
L["MASTER_LOOTER_POPUP_DESCRIPTION"] =
	"Apre una finestra per impostare il bottino ogni volta che diventi Saccheggiatore Maestro."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Attiva la finestra del Saccheggiatore Maestro"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "Destinazioni del Bottino"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "Scegli chi riceve il bottino distribuito da GogoLoot."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Te Stesso"
L["MASTER_LOOTER_SEND_ALL"] = "Invia tutto il bottino a"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] =
	"Invia ogni livello di qualità a un solo giocatore. Imposta i singoli livelli qui sotto per sovrascriverlo."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Scegli chi riceve oggetti %s."

L["MASTER_LOOTER_TIERS_INDIVIDUAL"] = "Imposta i Livelli di Qualità Singolarmente"
L["MASTER_LOOTER_TIERS_INDIVIDUAL_DESCRIPTION"] =
	"Mostra una riga per ogni livello di qualità, così livelli diversi possono andare a giocatori diversi."

--[[
    Appended to the toggle above only while the tier rows are collapsed, and only
    for this one state. Send All Loot To reads blank both when nothing is set and
    when the tiers disagree; it is honest about the first and silent about the
    second, so with the rows collapsed a per-tier setup would be invisible
    without this. A shared destination is already named in that dropdown and is
    deliberately not repeated here.
]]
L["MASTER_LOOTER_TIERS_SUMMARY_MIXED"] = "i livelli differiscono"

L["MASTER_LOOTER_IGNORE_HEADER"] = "Lista Ignorati"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Gli oggetti elencati saltano la distribuzione automatica e restano per l'assegnazione manuale."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "Ripristina Lista Ignorati Predefinita"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"Questo sostituirà la tua lista ignorati del maestro del bottino con gli oggetti predefiniti per la tua espansione. Continuare?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Rimuovi questo oggetto dalla lista degli ignorati."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] =
	"Tira per te sugli oggetti non vincolati alla raccolta fino alla qualità scelta, sia in gruppo che in incursione."
L["ROLLS_ENABLE"] = "Abilita Tiri Automatici"
L["ROLLS_THRESHOLD_HEADER"] = "Soglie"
L["ROLLS_THRESHOLD_DESCRIPTION"] =
	"Imposta il limite di qualità e il tiro che GogoLoot effettua per te, separatamente per gruppo e incursione."
L["ROLLS_IN_PARTY"] = "In gruppo"
L["ROLLS_IN_RAID"] = "In incursione"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: tira automaticamente sugli oggetti di questa qualità o inferiore."
L["ROLLS_ACTION_CHOOSE"] = "%s: quale tiro effettua GogoLoot per te, o se lascia il tiro a te."

L["ROLLS_CUSTOM_LIST"] = "Lista Tiri Personalizzati"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "Gli oggetti in questa lista hanno una loro regola di tiro che annulla la soglia."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "Abilita Lista Tiri Personalizzati"
L["ROLLS_RESTORE_DEFAULTS"] = "Ripristina Lista Tiri Personalizzati Predefinita"
L["ROLLS_RESTORE_CONFIRM"] =
	"Questo sostituirà la tua lista tiri personalizzati con gli oggetti predefiniti per la tua espansione. Continuare?"
L["ROLLS_CHOOSE_ACTION"] = "Scegli l'azione di tiro automatica per questo oggetto."
L["ROLLS_REMOVE_DESCRIPTION"] = "Rimuove questo oggetto dalla lista tiri personalizzati."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "Annunci di Scambio"
L["TRADE_DESCRIPTION"] = "Pubblica un riepilogo di ogni scambio completato: oggetti, incantamenti e oro."
L["TRADE_ENABLE"] = "Abilita Annunci di Scambio"
L["TRADE_CONDITION"] = "Quando"
L["TRADE_CONDITION_ALWAYS"] = "Sempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Solo in Gruppo o Incursione"
L["TRADE_CONDITION_RAID_ONLY"] = "Solo in Incursione"
L["TRADE_OUTPUT"] = "Output Messaggio"
L["TRADE_OUTPUT_WHISPER"] = "Sussurro"
L["TRADE_OUTPUT_GROUP"] = "Chat di Gruppo"
L["TRADE_EXAMPLE"] = "Esempio: {rt4} GogoLoot // Dato [Oggetto X] x2, [Oggetto Y] a Fathom."
L["TRADE_TOOLTIP_DESCRIPTION"] = "Invia un riepilogo nella chat quando questo scambio è completato."
L["TRADE_TOOLTIP_OUTPUT"] = "Output Corrente"
L["TRADE_CHECKBOX_LABEL"] = "Annuncia"

-- Master Looter Announcements
--[[
    Deliberately short. The two clauses this used to carry are both said better
    elsewhere on the panel: the quality threshold is a control the reader can
    see, and ANNOUNCE_MANUAL_NOTE says the manual half in the one place it
    answers a question the threshold has just raised.
]]
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Invia l'attività del maestro del bottino nella chat di gruppo."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Abilita gli annunci sulla destinazione del bottino"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] = "Esempio: {rt4} GogoLoot // Aevala riceverà tutti gli oggetti Epici."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Abilita Annunci Distribuzione Automatica"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "Soglia Annunci Automatici"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Esempio: {rt4} GogoLoot // Dato [Oggetto X] a Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] =
	"Nota: Ogni oggetto distribuito manualmente viene sempre annunciato, indipendentemente dalla qualità."
