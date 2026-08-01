local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "esES")
if not L then
	return
end

--[[
    Translated from enUS.lua, the source locale any missing key falls back to.
    Translate the values only. Never change the L["KEY"] names, the %s / %d
    placeholders, or the {rt4} raid marker — code and enUS.lua rely on them.
]]

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Versión %s. Los ajustes (incluyendo la opción de desactivar este mensaje) se encuentran en Opciones > AddOns > GogoLoot. ¿Disfrutando del add-on? ¡Cuéntaselo a un amigo! (="
L["MESSAGE_AUTO_LOOT_ENABLED"] = "Se ha activado el despojo automático. Despojo Rápido lo necesita para funcionar."
L["MESSAGE_NOT_MASTER_LOOTER"] = "Actualmente no eres el Maestro Despojador."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

L["MESSAGE_GAVE"] = "Entregó %s a %s."
L["MESSAGE_DESTINATION_SET"] = "%s recibirá todos los objetos de calidad %s."
L["MESSAGE_DESTINATION_SET_ALL"] = "%s guardará todo el botín para el grupo."
L["MESSAGE_DESTINATION_LEFT"] = "%s ha abandonado el grupo. %s ahora recibirá todos los objetos de calidad %s."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Entregó %s a %s, recibió %s."
L["MESSAGE_TRADE_RECEIVED"] = "Recibió %s de %s."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "Las bolsas de %s están llenas: %s"
L["ERROR_MAX_COUNT"] = "%s ya tiene demasiados de: %s"
L["ERROR_OUT_OF_RANGE"] = "%s está fuera de alcance: %s"
L["ERROR_NOT_IN_GROUP"] = "%s ya no está en el grupo ni en la banda: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "No se pudo dar a %s: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "Maestro Despojador"
L["TAB_AUTOMATED_ROLLS"] = "Tiradas Automáticas"
L["TAB_ANNOUNCEMENTS"] = "Anuncios"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- GogoLoot is a proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "Activado"
L["STATUS_DISABLED"] = "Desactivado"

--[[
    The tooltip titles each feature with its options-panel name rather than
    keeping its own copy: Automated Rolls uses TAB_AUTOMATED_ROLLS, Speedy Loot
    uses SPEEDY_LOOT_HEADER and SPEEDY_LOOT_DESCRIPTION. Only the roll
    description below is unique to the tooltip, where the panel's longer text
    would not fit.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Tira por ti por los objetos elegibles hasta la calidad que elijas."

L["MINIMAP_LEFT_CLICK"] = "Clic izquierdo"
L["MINIMAP_RIGHT_CLICK"] = "Clic derecho"
L["MINIMAP_TOGGLE"] = "Alternar"
L["MINIMAP_OPTIONS"] = "Opciones de GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Clic central"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- Quality Labels
L["QUALITY_POOR"] = "Pobre"
L["QUALITY_COMMON"] = "Común"
L["QUALITY_UNCOMMON"] = "Poco común"
L["QUALITY_RARE"] = "Raro"
L["QUALITY_EPIC"] = "Épico"

-- Roll Action Labels
L["ROLL_MANUAL"] = "Manual"
L["ROLL_GREED"] = "Codicia"
L["ROLL_NEED"] = "Necesidad"
L["ROLL_PASS"] = "Pasar"

-- Loot Method Labels
L["LOOT_METHOD_FREE_FOR_ALL"] = "Libre para todos"
L["LOOT_METHOD_ROUND_ROBIN"] = "Por turnos"
L["LOOT_METHOD_MASTER"] = "Maestro despojador"
L["LOOT_METHOD_GROUP"] = "Botín de grupo"
L["LOOT_METHOD_NEED_BEFORE_GREED"] = "Necesidad antes que codicia"

-- Threshold Labels
L["THRESHOLD_POOR_ONLY"] = "Solo Pobre"
L["THRESHOLD_COMMON_LOWER"] = "Común y Menor"
L["THRESHOLD_UNCOMMON_LOWER"] = "Poco común y Menor"
L["THRESHOLD_RARE_LOWER"] = "Raro y Menor"
L["THRESHOLD_EPIC_LOWER"] = "Épico y Menor"

-- Shared by both item lists: the Master Looter ignore list and the Custom Roll List
L["ITEM_LIST_ADD"] = "Añadir Objeto"
L["ITEM_LIST_ADD_DESCRIPTION"] = "Introduce el ID de un objeto o arrastra un objeto aquí para añadirlo a la lista."

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "Cargando... (ID: %d)"

-- Version prefix in the options panel and minimap tooltip
L["VERSION_LABEL"] = "Versión"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] =
	"Aspira el equipo con Saqueo Maestro automatizado, Tiradas Automáticas y Anuncios transparentes. Los objetos de misión, recetas, monturas, mascotas y legendarios quedan a salvo. ¡Que el botín no frene tu zug!"
L["WELCOME_MESSAGE"] = "Activar Mensaje de Bienvenida"
L["MINIMAP_BUTTON_ENABLE"] = "Activar Botón del Minimapa"

L["COMMANDS"] = "/Comandos"
L["COMMANDS_DESCRIPTION"] = "Abre la interfaz de opciones de GogoLoot."

L["SPEEDY_LOOT_HEADER"] = "Despojo Rápido"
L["SPEEDY_LOOT_DESCRIPTION"] = "Oculta la ventana de botín para saquear casi al instante."
L["SPEEDY_LOOT_ENABLE"] = "Activar Despojo Rápido"

L["FEEDBACK_SUPPORT"] = "Comentarios y Soporte"

-- CurseForge / GitHub / Discord / Wago are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"] = "El método y umbral de botín actual de tu grupo."
L["MASTER_LOOTER_LOOT_METHOD"] = "Método de Botín"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "Umbral de Botín"
L["MASTER_LOOTER_SET_BY"] = "(Establecido por %s)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "Solo el líder del grupo puede cambiar el método y el umbral de botín."

L["MASTER_LOOTER_AUTO_HEADER"] = "Maestro Despojador Automático"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] =
	"Distribuye el botín a los jugadores que designes mientras eres Maestro Despojador. Los objetos de misión, recetas, libros, monturas, mascotas y legendarios siempre se omiten."
L["MASTER_LOOTER_AUTO_ENABLE"] = "Activar Maestro Despojador Automático en Estancias"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Activar Maestro Despojador Automático fuera de Estancias"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] =
	"Precaución: Debido a que el botín de los jefes de mundo no es intercambiable, ¡esto no es recomendable!"

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Ajustes rápidos"
L["MASTER_LOOTER_POPUP_DESCRIPTION"] =
	"Abre una ventana para configurar el botín cuando te conviertas en Saqueador Maestro."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Activar ventana de Saqueador Maestro"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "Destinos del Botín"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"Asigna a un miembro del grupo para que reciba los objetos de cada nivel de calidad."
L["MASTER_LOOTER_DESTINATION_SELF"] = "A mí mismo"
L["MASTER_LOOTER_SEND_ALL"] = "Enviar todo el botín a"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] =
	"Envía todas las calidades a un jugador. Ajusta las calidades individuales abajo para anularlo."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Elige quién recibe los objetos de calidad %s."

L["MASTER_LOOTER_IGNORE_HEADER"] = "Lista de Ignorados"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Los objetos de la lista omiten la distribución automática y quedan para asignación manual."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "Restaurar Lista de Ignorados Predeterminada"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"Esto reemplazará tu lista de ignorados del maestro despojador con los objetos predeterminados para tu expansión. ¿Continuar?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Elimina este objeto de la lista de ignorados."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] =
	"Tira por ti por los objetos que no se ligan al recogerlos hasta la calidad que elijas, tanto en grupo como en banda. Los objetos de misión, recetas, libros, monturas, mascotas y legendarios siempre se omiten."
L["ROLLS_ENABLE"] = "Activar Tiradas Automáticas"
L["ROLLS_THRESHOLD_HEADER"] = "Umbrales"
L["ROLLS_THRESHOLD_DESCRIPTION"] =
	"Elige el límite de calidad y la tirada que GogoLoot hace por ti, por separado para grupos y bandas."
L["ROLLS_IN_PARTY"] = "En grupo"
L["ROLLS_IN_RAID"] = "En banda"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: tira automáticamente por los objetos de esta calidad o inferior."
L["ROLLS_ACTION_CHOOSE"] = "%s: qué tirada hace GogoLoot por ti, o si te deja la tirada a ti."

L["ROLLS_CUSTOM_LIST"] = "Lista de Tirada Personalizada"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "Los objetos de esta lista tienen su propia regla de tirada que anula el umbral."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "Activar Lista de tirada personalizada"
L["ROLLS_RESTORE_DEFAULTS"] = "Restaurar Lista de Tirada Personalizada Predeterminada"
L["ROLLS_RESTORE_CONFIRM"] =
	"Esto reemplazará tu lista de tirada personalizada con los objetos predeterminados para tu expansión. ¿Continuar?"
L["ROLLS_CHOOSE_ACTION"] = "Elige la acción de tirada automática para este objeto."
L["ROLLS_REMOVE_DESCRIPTION"] = "Elimina este objeto de la lista de tirada personalizada."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "Anuncios de Intercambio"
L["TRADE_DESCRIPTION"] = "Publica un resumen de cada intercambio completado: objetos, encantamientos y oro."
L["TRADE_ENABLE"] = "Activar Anuncios de Intercambio"
L["TRADE_CONDITION"] = "Cuándo"
L["TRADE_CONDITION_ALWAYS"] = "Siempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Solo en Grupo o Banda"
L["TRADE_CONDITION_RAID_ONLY"] = "Solo en Banda"
L["TRADE_OUTPUT"] = "Salida del Mensaje"
L["TRADE_OUTPUT_WHISPER"] = "Susurro"
L["TRADE_OUTPUT_GROUP"] = "Chat de Grupo"
L["TRADE_EXAMPLE"] = "Ejemplo: {rt4} GogoLoot // Entregó [Objeto X] x2, [Objeto Y] a Fathom."
L["TRADE_TOOLTIP_DESCRIPTION"] = "Publica un resumen en el chat cuando este intercambio se completa."
L["TRADE_TOOLTIP_OUTPUT"] = "Salida actual"
L["TRADE_CHECKBOX_LABEL"] = "Anunciar"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] =
	"Publica la actividad del maestro despojador en el chat de grupo. Las distribuciones automáticas utilizan un umbral de calidad para evitar el spam; las distribuciones manuales siempre se anuncian."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Activar mensajes de destino del botín"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] =
	"Ejemplo: {rt4} GogoLoot // Aevala recibirá todos los objetos de calidad Épica."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Activar Anuncios de Distribución Automática"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "Umbral de Anuncio Automático"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Ejemplo: {rt4} GogoLoot // Entregó [Objeto X] a Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] =
	"Nota: Todo objeto distribuido manualmente se anuncia siempre, sin importar su calidad."
