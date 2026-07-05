local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "esES")
if not L then return end

--[[
    Source locale: every other locale falls back to these strings. Translate
    the values only. Never change the L["KEY"] names, the %s / %d placeholders,
    or the {rt4} raid marker — code and other locales rely on them.
]]

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Versión %s. Los ajustes (incluyendo la opción de desactivar este mensaje) se encuentran en Opciones > AddOns > GogoLoot. ¿Disfrutando del add-on? ¡Cuéntaselo a un amigo! (="
L["MESSAGE_AUTO_LOOT_ENABLED"] = "El despojo automático es necesario para que GogoLoot funcione correctamente. Se ha activado el despojo automático."
L["MESSAGE_NOT_MASTER_LOOTER"] = "Actualmente no eres el Maestro Despojador."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

L["MESSAGE_LOOT_ANNOUNCE"] = "Entregó %s a %s."
L["MESSAGE_DESTINATION_SET"] = "%s recibirá todos los objetos de calidad %s."
L["MESSAGE_DESTINATION_LEFT"] = "%s ha abandonado el grupo. %s ahora recibirá todos los objetos de calidad %s."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Entregó %s a %s, recibió %s."
L["MESSAGE_TRADE_GAVE"] = "Entregó %s a %s."
L["MESSAGE_TRADE_RECEIVED"] = "Recibió %s de %s."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "El jugador que seleccionaste para recibir ese objeto no tiene espacio en sus bolsas."
L["ERROR_MAX_COUNT"] = "El jugador que seleccionaste para recibir ese objeto ya tiene demasiados de ese objeto."
L["ERROR_OUT_OF_RANGE"] = "El jugador que seleccionaste para recibir ese objeto no está en el rango."
L["ERROR_NOT_IN_GROUP"] = "El jugador que seleccionaste para recibir ese objeto ya no está en el grupo o banda."

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

L["MINIMAP_AUTO_GREED"] = "Codicia Automática"
L["MINIMAP_AUTO_GREED_DESCRIPTION"] = "Tira automáticamente Codicia por los objetos elegibles de calidad igual o inferior al umbral seleccionado."
L["MINIMAP_SPEEDY_LOOT"] = "Despojo Rápido"
L["MINIMAP_SPEEDY_LOOT_DESCRIPTION"] = "Recoge el botín al instante sin mostrar la ventana de despojo."

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
L["ROLL_MANUAL"] = "Tirada Manual"
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

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "Cargando... (ID: %d)"

-- Version prefix in the options panel and minimap tooltip
L["VERSION_LABEL"] = "Versión"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] = "Aspira el equipo con el Maestro despojador automático, tira Necesidad o Codicia automáticamente en los botines que no se ligan al recogerlos, y anuncia de forma transparente cada intercambio en el chat. Los objetos de misión, recetas, monturas, mascotas y legendarios siempre están a salvo. ¡No dejes que el botín frene tu zug!"
L["WELCOME_MESSAGE"] = "Activar Mensaje de Bienvenida"
L["MINIMAP_BUTTON_ENABLE"] = "Activar Botón del Minimapa"

L["COMMANDS"] = "/Comandos"
L["COMMANDS_DESCRIPTION"] = "Abre la interfaz de opciones de GogoLoot."

L["SPEEDY_LOOT_HEADER"] = "Despojo Rápido"
L["SPEEDY_LOOT_DESCRIPTION"] = "Recoge el botín al instante sin mostrar la ventana de despojo, ahorrando tiempo entre muertes."
L["SPEEDY_LOOT_ENABLE"] = "Activar Despojo Rápido"

L["FEEDBACK_SUPPORT"] = "Comentarios y Soporte"

-- CurseForge / GitHub / Discord are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

--------------------------------------------------------------------------------
-- Options: Profiles
--------------------------------------------------------------------------------

L["OPTIONS_RESET_ALL_PROFILES"] = "Restablecer todos los perfiles"
L["OPTIONS_RESET_ALL_PROFILES_DESCRIPTION"] = "Restablece todos los perfiles de esta cuenta a los ajustes predeterminados."
L["OPTIONS_RESET_ALL_PROFILES_CONFIRM"] = "Esto restablecerá TODOS los perfiles de tu cuenta a los valores predeterminados, para cada personaje. No se puede deshacer. ¿Continuar?"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"] = "El método y umbral de botín actual de tu grupo."
L["MASTER_LOOTER_LOOT_TYPE"] = "Tipo de Botín"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "Umbral de Botín"
L["MASTER_LOOTER_SET_BY"] = "(Establecido por %s)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "Solo el líder del grupo puede cambiar el método y el umbral de botín."

L["MASTER_LOOTER_AUTO_HEADER"] = "Maestro Despojador Automático"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] = "Distribuye automáticamente el botín a los jugadores designados cuando eres el Maestro Despojador. Los objetos de misión, libros, recetas, monturas, mascotas y legendarios siempre se omiten y aparecerán en la ventana de botín estándar."
L["MASTER_LOOTER_AUTO_ENABLE"] = "Activar Maestro Despojador Automático en Estancias"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Activar Maestro Despojador Automático fuera de Estancias"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] = "Precaución: Debido a que el botín de los jefes de mundo no es intercambiable, ¡esto no es recomendable!"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "Destinos del Botín"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "Asigna a un miembro del grupo para que reciba los objetos de cada nivel de calidad."
L["MASTER_LOOTER_DESTINATION_SELF"] = "A mí mismo"
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Elige quién recibe los objetos de calidad %s."

L["MASTER_LOOTER_IGNORE_HEADER"] = "Lista de Ignorados"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] = "Los objetos de esta lista no se distribuirán automáticamente y aparecerán en la ventana de botín estándar para su asignación manual."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "Restaurar Lista de Ignorados Predeterminada"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] = "Esto reemplazará tu lista de ignorados del maestro despojador con los objetos predeterminados para tu expansión. ¿Continuar?"
L["MASTER_LOOTER_IGNORE_ADD_DESCRIPTION"] = "Introduce el ID de un objeto o pega un enlace de objeto para añadirlo a la lista de ignorados."
L["MASTER_LOOTER_IGNORE_ADD"] = "Añadir Objeto"
L["MASTER_LOOTER_IGNORE_REMOVE"] = "Eliminar"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Elimina este objeto de la lista de ignorados."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] = "Tira automáticamente Codicia por los objetos que no se ligan al recogerlos de calidad igual o inferior a la seleccionada. Los objetos de misión, libros, recetas, monturas, mascotas y legendarios siempre se omiten."
L["ROLLS_ENABLE"] = "Activar Tiradas Automáticas"
L["ROLLS_THRESHOLD"] = "Umbral de Codicia Automática"

L["ROLLS_CUSTOM_LIST"] = "Lista de Tirada Personalizada"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "Los objetos de esta lista tienen su propia regla de tirada que anula el umbral."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "Activar Lista de tirada personalizada"
L["ROLLS_RESTORE_DEFAULTS"] = "Restaurar Lista de Tirada Personalizada Predeterminada"
L["ROLLS_RESTORE_CONFIRM"] = "Esto reemplazará tu lista de tirada personalizada con los objetos predeterminados para tu expansión. ¿Continuar?"
L["ROLLS_ADD_ITEM_DESCRIPTION"] = "Introduce el ID de un objeto o arrastra un objeto aquí para añadirlo a la lista."
L["ROLLS_ADD_ITEM"] = "Añadir Objeto"
L["ROLLS_CHOOSE_ACTION"] = "Elige la acción de tirada automática para este objeto."
L["ROLLS_REMOVE"] = "Eliminar"
L["ROLLS_REMOVE_DESCRIPTION"] = "Elimina este objeto de la lista de tirada personalizada."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "Anuncios de Intercambio"
L["TRADE_DESCRIPTION"] = "Publica automáticamente en el chat un resumen de los intercambios completados, incluyendo objetos, encantamientos y oro intercambiado."
L["TRADE_ENABLE"] = "Activar Anuncios de Intercambio"
L["TRADE_CONDITION"] = "Cuándo"
L["TRADE_CONDITION_ALWAYS"] = "Siempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Solo en Grupo o Banda"
L["TRADE_CONDITION_RAID_ONLY"] = "Solo en Banda"
L["TRADE_OUTPUT"] = "Salida del Mensaje"
L["TRADE_OUTPUT_WHISPER"] = "Susurro"
L["TRADE_OUTPUT_GROUP"] = "Chat de Grupo"
L["TRADE_EXAMPLE"] = "Ejemplo: {rt4} Entregó [Objeto X] x2, [Objeto Y] a Fathom. // GogoLoot"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Publica un resumen en el chat cuando este intercambio se completa."
L["TRADE_TOOLTIP_OUTPUT"] = "Salida actual"
L["TRADE_CHECKBOX_LABEL"] = "Anunciar"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Publica la actividad del maestro despojador en el chat de grupo por transparencia. Las distribuciones automáticas utilizan un umbral de calidad para evitar el spam; las distribuciones manuales siempre se anuncian."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Activar mensajes cuando se establece el Maestro Despojador"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] = "Ejemplo: {rt4} GogoLoot // Aevala recibirá todos los objetos de calidad Épica."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Activar Anuncios de Distribución Automática"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "Umbral de Anuncio Automático"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Ejemplo: {rt4} GogoLoot // Entregó [Objeto X] a Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] = "Nota: Todo objeto distribuido manualmente se anuncia siempre, sin importar su calidad."
