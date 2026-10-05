local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "esMX")
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
	"Versión %s. Encontrarás la configuración (incluida la opción de desactivar este mensaje) en Opciones > AddOns > GogoLoot. ¿Te gusta el accesorio? ¡Cuéntaselo a un amigo! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Por seguridad, la ventana de opciones no se puede abrir en combate."
-- Argument: the game's own name for its Auto Loot setting.
L["MESSAGE_AUTO_LOOT_SETTING_ON"] =
	"Se activó la opción %s del juego, que necesitan Despojo rápido y Apertura automática."
-- Argument: the game's own word for Master Looter.
L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"] = "Ahora mismo no eres el %s."

-- Automated Opening. Argument: the number of free bag slots opening waits for.
L["MESSAGE_OPENING_PAUSED"] =
	"Apertura automática está en pausa hasta que tengas al menos %d espacios libres en las bolsas."
L["MESSAGE_OPENING_RESUMED"] = "Apertura automática se reanudó."

-- Argument: the item's link.
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] = "%s se abrirá automáticamente en cuanto se desbloquee."
L["MESSAGE_ITEM_IGNORED"] = "%s está en Ignorar, así que Apertura automática no lo tocará."
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s viene de un jefe de banda o del mundo, así que Apertura automática lo dejará cerrado para que lo comercies o lo vendas."
L["MESSAGE_ITEM_IGNORED_UNIQUE"] =
	"%s puede contener un objeto único, así que Apertura automática te lo deja para que lo abras tú."
L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] = "%s se quedó en la ventana de botín para que lo despojes tú."
-- The Openables List's Add Item refusing gear or a bag. Argument: the item's link, or its ID while uncached.
L["MESSAGE_ITEM_NOT_OPENABLE"] =
	"%s se equiparía en lugar de abrirse, así que no puede entrar en la Lista de contenedores."

-- Automated Rolls' Print Item in Chat. Arguments: the game's word for the roll (Need or Greed), then the item's link.
L["MESSAGE_ROLL_PRINT"] = "Elegiste %s para %s."
-- The same after a Pass. Argument: the item's link.
L["MESSAGE_ROLL_PASS_PRINT"] = "Dejaste pasar %s."
--[[
    Hide Roll Messages' winner summary. Arguments: the winner, the item's link,
    then the winning roll as LOOT_TOASTS_ROLL_RESULT words it ("Greed 95"). The
    NO_ROLL forms are for a win whose roll wasn't seen; the YOU forms for the
    player's own win, without the winner.
]]
L["MESSAGE_ROLL_WON_PRINT"] = "%s ganó %s, %s."
L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"] = "%s ganó %s."
L["MESSAGE_ROLL_YOU_WON_PRINT"] = "Ganaste %s, %s."
L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"] = "Ganaste %s."

--[[
    A trade summary printed to the player alone (the trade Channel's Me Only):
    the Chat Announcement Templates below, printed, so each ends on its
    punctuation. Arguments as theirs: items, then the partner, then what came
    back.
]]
L["MESSAGE_GAVE_PRINT"] = "Entregué %s a %s."
L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "Entregué %s a %s, recibí %s."
L["MESSAGE_TRADE_RECEIVED_PRINT"] = "Recibí %s de %s."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "Entregué %s a %s"
L["MESSAGE_DESTINATION_SET"] = "%s guardará los objetos de calidad %s para el grupo"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s guardará todo el botín para el grupo"
-- Arguments: the player who left, the master looter, then the qualities they held, joined by commas.
L["MESSAGE_DESTINATION_LEFT"] = "%s dejó el grupo. Ahora %s guardará los objetos de calidad %s para el grupo"
-- The same when they held every quality. Arguments: the player who left, then the master looter.
L["MESSAGE_DESTINATION_LEFT_ALL"] = "%s dejó el grupo. Ahora %s guardará todo el botín para el grupo"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Entregué %s a %s, recibí %s"
L["MESSAGE_TRADE_RECEIVED"] = "Recibí %s de %s"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "Las bolsas de %s están llenas: %s"
L["ERROR_MAX_COUNT"] = "%s ya tiene demasiados: %s"
L["ERROR_OUT_OF_RANGE"] = "%s está fuera de alcance: %s"
L["ERROR_NOT_IN_GROUP"] = "%s ya no está en el grupo ni en la banda: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "No se pudo entregar el botín a %s: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_AUTOMATED_ROLLS"] = "Tiradas automáticas"
L["TAB_ITEM_OVERRIDES"] = "Excepciones de objetos"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "Reglas por personaje"
-- The panel for everything GogoLoot posts to chat.
L["TAB_ANNOUNCEMENTS"] = "Anuncios"
-- Headers of the two sections on the Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Anuncios de comercio"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Anuncios de maestro despojador"
L["TAB_LOOT_TOASTS"] = "Avisos de botín"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Filtros"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Sonidos de botín"
L["TAB_AUTOMATED_OPENING"] = "Apertura automática"
-- Header of a section on the Automated Opening panel.
L["TAB_LOCKBOXES"] = "Cajas fuertes"
L["TAB_OPENABLE_ITEMS"] = "Lista de contenedores"
L["TAB_MASTER_LOOTER"] = "Maestro despojador"
-- Header of a section on the Master Looter panel.
L["TAB_LOOT_DESTINATIONS"] = "Destinos del botín"
L["TAB_IGNORE_LIST"] = "Lista de ignorados"

-- A child panel's title where the Settings tree can't nest it: the parent's title, then its own.
L["TAB_NESTED_FORMAT"] = "%s: %s"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Activado"
L["STATUS_DISABLED"] = "Desactivado"
-- Automated Opening is on but waiting for empty bag slots.
L["STATUS_PAUSED"] = "En pausa"

--[[
    The tooltip titles each feature with its options-panel name (Automated
    Master Looting excepted, since its panel is titled Master Looter), and
    gives each a description of its own, two lines at most: the panels' longer
    text doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Tira por ti en los objetos elegibles hasta la calidad que elijas."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] =
	"Abre las almejas, cajones, bolsas de monedas y cajas fuertes ya forzadas de tus bolsas."
L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"] =
	"Publica en el chat los resúmenes de comercio y los repartos del maestro despojador."
L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"] = "Reparte el botín a los jugadores que elegiste para cada calidad."
--[[
    The tooltip's read-back of each group context's roll, one line each under
    the description. Arguments: the game's own word for Party or Raid, the roll,
    then (all but Manual) the highest quality it rolls on.
]]
L["MINIMAP_ROLLS_SETTING"] = "%s: %s, %s"
L["MINIMAP_ROLLS_SETTING_MANUAL"] = "%s: %s"

L["MINIMAP_LEFT_CLICK"] = "Clic izquierdo"
L["MINIMAP_RIGHT_CLICK"] = "Clic derecho"
L["MINIMAP_SHIFT_LEFT_CLICK"] = "Mayús + clic izquierdo"
L["MINIMAP_SHIFT_RIGHT_CLICK"] = "Mayús + clic derecho"
-- The tooltip's title for the Automated Master Looting block, the feature its switch names.
L["MINIMAP_AUTOMATED_MASTER_LOOTING"] = "Reparto automático"
L["MINIMAP_TOGGLE"] = "Activar/desactivar"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Objetos bloqueados"
L["MINIMAP_OPTIONS"] = "Opciones de GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Mayús + clic central"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Manual"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "Solo %s"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s o inferior"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List brings text of its own), the hint the box shows while empty,
    and its button.
]]
L["ITEM_LIST_ADD"] = "Añadir objeto"
L["ITEM_LIST_ADD_DESCRIPTION"] = "Escribe el ID de un objeto o arrastra un objeto aquí para añadirlo a la lista."
L["ITEM_LIST_ADD_PLACEHOLDER"] = "Suelta un objeto aquí o escribe su ID"
L["ITEM_LIST_ADD_BUTTON"] = "Añadir"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "Filtrar objetos..."
L["ITEM_LIST_FILTER_DESCRIPTION"] =
	"Muestra solo los objetos cuyo nombre, ID, opción o etiqueta contenga lo que escribas."
L["ITEM_LIST_NO_MATCHES"] = "Ningún objeto coincide con el filtro."

-- The header over what the player just added to an item list, at its top until they filter it or close the window.
L["ITEM_LIST_NEW"] = "Nuevos"

-- The kind filter beside every item list's search box: its first choice (the rest are the list's headers) and its tooltip.
L["ITEM_LIST_KIND_ALL"] = "Mostrar todos los tipos de objeto"
L["ITEM_LIST_KIND_DESCRIPTION"] = "Muestra todos los objetos de la lista, o solo los de un tipo."

--[[
    The Add from Bags dropdown beside every item list's add box: its resting
    text and tooltip, then what it reads, greyed out, when everything carried
    is already on the list. The Openables List brings a tooltip of its own.
]]
L["ITEM_LIST_ADD_FROM_BAGS"] = "Añadir desde las bolsas"
L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"] = "Añade a la lista un objeto que llevas encima."
L["ITEM_LIST_BAGS_EMPTY"] = "No hay nada en tus bolsas para añadir"
L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"] = "Todos los objetos que llevas ya están en la lista."

-- The button at the foot of every item list; each list's tooltip and confirmation say what it restores.
L["ITEM_LIST_RESTORE"] = "Restaurar predeterminados"

-- Placeholder shown in the item lists until the client caches an item's info.
L["ITEM_LOADING"] = "Cargando... (ID: %d)"

--[[
    Appended to the Automated Rolls description. Item Overrides is the one way
    a Bind on Pickup or quest item gets rolled on; nothing ever rolls on the
    rest.
]]
L["SAFETY_SKIP_NOTE"] =
	"Nunca tira en recetas, libros, monturas, mascotas ni legendarios, y solo tira en objetos ligados al recogerlos o de misión si están en Excepciones de objetos."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] = "Las recetas, libros, monturas, mascotas y legendarios siempre se quedan para ti."

--[[
    Shown under each announcement's toggle, under Print Item in Chat and Hide
    Roll Messages, and under Enable Ignore Notifications. Argument: the
    message, as GogoLoot sends or prints it.
]]
L["OPTIONS_EXAMPLE"] = "Ejemplo: %s"

-- The muted version line at the foot of the General panel.
L["OPTIONS_VERSION"] = "Versión %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Despojo rápido vacía los cadáveres en un abrir y cerrar de ojos, Tiradas automáticas y Reparto automático deciden quién se lleva qué, y Apertura automática revienta cada almeja y cada cajón. Avisos de botín te lo enseña todo, y los objetos de misión, recetas, monturas, mascotas y legendarios quedan a salvo. ¡Que el botín no te frene!"
L["WELCOME_MESSAGE"] = "Activar mensaje de bienvenida"
L["WELCOME_MESSAGE_DESCRIPTION"] =
	"Muestra la versión de GogoLoot y dónde encontrar esta configuración cada vez que inicias sesión."
L["MINIMAP_BUTTON_ENABLE"] = "Activar botón del minimapa"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Muestra el botón de GogoLoot en el minimapa. Clic izquierdo activa o desactiva Tiradas automáticas; Clic derecho, Apertura automática; Mayús + clic izquierdo, Anuncios; y Mayús + clic derecho, Reparto automático."

L["OPTIONS_COMMANDS_HEADER"] = "/Comandos"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre la ventana de opciones de este accesorio."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Funciones"

L["SPEEDY_LOOT_ENABLE"] = "Activar Despojo rápido"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"Vacía cada cadáver en cuanto lo abres, sin mostrar la ventana de botín. Mantén presionado Mayús al despojar para ver la ventana. Activa la opción %s del juego y no actúa mientras eres %s."

L["FEEDBACK_SUPPORT"] = "Comentarios y soporte"

-- CurseForge / GitHub / Discord / Wago are proper nouns; do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "Configuración de botín del grupo"
L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"] =
	"Decide cómo se reparte el botín de tu grupo. Solo el líder del grupo puede cambiarlo."
L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"] =
	"Fija la calidad mínima de objeto a la que se aplica el reparto de botín. Solo el líder del grupo puede cambiarla."

--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them, including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "Esta configuración la controla %s."
-- Shown in the same place while solo, where the two dropdowns are greyed out.
L["MASTER_LOOTER_SOLO_NOTE"] =
	"Únete a un grupo para cambiar esta configuración. Solo el líder del grupo puede hacerlo."

-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"] =
	"Entrega cada objeto al jugador que elegiste para su calidad en cuanto abres la ventana de botín, mientras eres %s."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "Activar Reparto automático"
L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"] =
	"Activa o desactiva el reparto automático. Solo funciona dentro de calabozos y bandas, salvo que actives También fuera de instancias."
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "También fuera de instancias"
L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Reparte el botín también en el mundo abierto. El botín de los jefes del mundo no se puede comerciar, así que no se recomienda."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "Incluir objetos de misión"
L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"] =
	"Reparte también los objetos de misión, para subir a un personaje que llevas tú mismo. Solo funciona con un límite de botín Común o inferior, y solo con objetos de misión que caen una vez para todo el grupo. No se recomienda en bandas."

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Configuración rápida"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_POPUP_TOOLTIP"] = "Abre esta configuración en una ventana cada vez que pasas a ser %s."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Activar ventana de maestro despojador"

L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"Elige quién recibe cada calidad. Una calidad sin nadie elegido se queda en la ventana de botín para ti."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Yo"
-- The first choice in every destination dropdown: nobody picked, so that quality waits in the loot window.
L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"] = "Ventana de botín"
L["MASTER_LOOTER_SEND_ALL"] = "Enviar todo el botín a"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] = "Asigna todas las calidades de abajo a un solo jugador."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Elige quién recibe los objetos de calidad %s."
-- Shown under Loot Destinations while Automated Master Looting is on and no quality has anybody picked.
L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] =
	"Aún no hay nadie elegido, así que todo el botín espera en la ventana de botín para ti."

L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Los objetos de esta lista nunca se reparten automáticamente. Esperan en la ventana de botín para que los repartas tú."
-- Shown on the Ignore List while Automated Master Looting is off.
L["MASTER_LOOTER_OFF_NOTE"] = "Esta configuración no se usa mientras Reparto automático está desactivado."
L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"] =
	"Sustituye la Lista de ignorados por los objetos predeterminados de tu expansión."
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"Se sustituirá tu Lista de ignorados por los objetos predeterminados de tu expansión. ¿Continuar?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Quita este objeto de la Lista de ignorados."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_PANEL_DESCRIPTION"] =
	"Tira %s, %s o %s por ti en el botín de grupo, hasta la calidad que elijas, con una configuración distinta para grupos y bandas."
L["ROLLS_ENABLE"] = "Activar Tiradas automáticas"
L["ROLLS_ENABLE_DESCRIPTION"] =
	"Activa o desactiva las tiradas automáticas, incluidas Excepciones de objetos y Reglas por personaje."
L["ROLLS_IN_PARTY"] = "En grupo"
L["ROLLS_IN_RAID"] = "En banda"
-- The caption of the quality row under In Party and under In Raid, shown while that roll isn't Manual.
L["ROLLS_UP_TO_QUALITY"] = "Hasta la calidad"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: la calidad más alta en la que tira GogoLoot."
L["ROLLS_ACTION_CHOOSE"] = "%s: la tirada que hace GogoLoot. Manual te deja la tirada a ti."
-- Section headers on the Automated Rolls panel.
L["ROLLS_LOOT_THRESHOLDS_HEADER"] = "Límites de botín"
L["ROLLS_MESSAGES_HEADER"] = "Mensajes de tiradas"
L["ROLLS_PRINT_ITEM"] = "Mostrar objeto en el chat"
L["ROLLS_PRINT_ITEM_DESCRIPTION"] =
	"Muestra en tu chat cada objeto en el que tira GogoLoot y la tirada que hizo. La ventana de tirada se cierra en cuanto GogoLoot tira, así que este es tu registro de lo que salió."
L["ROLLS_HIDE_MESSAGES"] = "Ocultar mensajes de tiradas"
-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_HIDE_MESSAGES_TOOLTIP"] =
	"Oculta las líneas de chat del juego de cada tirada: quién eligió %s, %s o %s, y cada número obtenido. Lo que recibió cada ganador se queda en el chat."
-- The dropdown beside Hide Roll Messages.
L["ROLLS_WINNER_SUMMARY_PRINT"] = "Mostrar resumen del ganador"
L["ROLLS_WINNER_SUMMARY_NONE"] = "No mostrar resumen del ganador"
L["ROLLS_WINNER_SUMMARY_DESCRIPTION"] =
	"Mostrar resumen del ganador pone una línea en el chat por cada victoria, con el ganador, el objeto y la tirada ganadora, en lugar de la línea del propio juego. No mostrar resumen del ganador deja la línea del juego que dice quién ganó."

--[[
    Item Overrides, under Automated Rolls: items with a roll action of their
    own.
]]
L["ITEM_OVERRIDES_DESCRIPTION"] =
	"Fija la tirada de objetos concretos, por encima de la configuración de calidad. Es la única forma de que GogoLoot tire en un objeto ligado al recogerlo o de misión."
-- Shown on Item Overrides while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "Esta configuración no se usa mientras Tiradas automáticas está desactivado."
L["ITEM_OVERRIDES_ENABLE"] = "Activar Excepciones de objetos"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"Usa las tiradas fijadas abajo. Si está desactivado, estos objetos siguen la configuración de calidad como cualquier otro."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] =
	"Sustituye tus Excepciones de objetos por los objetos predeterminados de tu expansión."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"Se sustituirán tus Excepciones de objetos por los objetos predeterminados de tu expansión. ¿Continuar?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "Fija la tirada automática para este objeto."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "Quita este objeto de Excepciones de objetos."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "¿Quitar este objeto y su tirada de Excepciones de objetos?"

--[[
    Character Rules, under Automated Rolls: the stats whose gear each
    character leaves to the player. The stat names come from the game's own
    strings.
]]
-- Arguments: the game's own name for Intellect, then for the Warrior class, then Intellect again.
L["CHARACTER_RULES_PANEL_DESCRIPTION"] =
	"Te deja a ti el equipo con los atributos que elijas, personaje a personaje: pon %s en Manual en tu %s, y el equipo con %s conserva su ventana de tirada mientras todo lo demás se tira como siempre. Excepciones de objetos sigue teniendo prioridad."
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "Atributos principales"
L["CHARACTER_RULES_SECONDARY"] = "Atributos secundarios"
-- The first of the two choices in each stat's dropdown: no rule, so the rest of Automated Rolls decides.
L["CHARACTER_RULES_STANDARD"] = "Tirada automática estándar"
L["CHARACTER_RULES_ACTION_DESCRIPTION"] =
	"%s: Manual te deja a ti el equipo que lo tenga en este personaje, con su ventana de tirada incluida. Tirada automática estándar tira en él como en cualquier otro objeto."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"Publica en el chat los resúmenes de comercio y los repartos del maestro despojador, para que todos sepan adónde fue el botín."
L["ANNOUNCEMENTS_ENABLE"] = "Activar Anuncios"
-- Also the tooltip of the same switch in the General panel's Features section, so it names no position on the panel.
L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"] =
	"Activa o desactiva todos los anuncios. Mientras esté desactivado, GogoLoot no envía nada a tu grupo ni a las personas con quienes comercias, ni siquiera los objetos que repartes tú."

-- Trade Announcements
L["TRADE_DESCRIPTION"] = "Publica un resumen de cada comercio completado: objetos, encantamientos y oro."
L["TRADE_ENABLE"] = "Activar Anuncios de comercio"
L["TRADE_ENABLE_DESCRIPTION"] =
	"Publica un resumen al completar un comercio. La casilla Anunciar de la ventana de comercio es este mismo interruptor."
L["TRADE_CONDITION_DESCRIPTION"] =
	"Elige cuándo se publican los resúmenes de comercio: siempre, en grupo o banda, o solo en banda."
L["TRADE_CONDITION_ALWAYS"] = "Siempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "En grupo o banda"
L["TRADE_CONDITION_RAID_ONLY"] = "En banda"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "Canal"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	"%s envía cada resumen a la persona con quien comercias. Chat de grupo lo publica en tu grupo o banda, y fuera de un grupo lo susurra igualmente. Solo yo lo muestra en tu propio chat y no lo envía a nadie."
-- The Channel dropdown's choices (Whisper is the client's WHISPER), and the trade window checkbox tooltip's Channel value.
L["TRADE_OUTPUT_GROUP"] = "Chat de grupo"
L["TRADE_OUTPUT_SELF"] = "Solo yo"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Publica un resumen del comercio en el chat cuando se complete."
L["TRADE_CHECKBOX_LABEL"] = "Anunciar"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Dice a tu grupo quién guarda cada calidad y qué has repartido."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Activar anuncios de destino"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"] =
	"Dice al grupo quién guarda cada calidad cada vez que fijas un destino."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Activar anuncios de reparto automático"
L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"] =
	"Anuncia cada objeto que GogoLoot reparte automáticamente, de la calidad que elijas o superior."
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"] =
	"Los repartos automáticos por debajo de esta calidad no se anuncian."

L["MASTER_LOOTER_ANNOUNCE_MANUAL"] = "Activar anuncios de reparto manual"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"] =
	"Anuncia cada objeto que repartes tú desde el menú de %s, sea cual sea su calidad, con el mismo texto que un reparto automático. Un reparto fallido se notifica en cualquier caso."

--------------------------------------------------------------------------------
-- Options: Loot Toasts and Loot Sounds
--------------------------------------------------------------------------------

-- Argument: the game's own name for the General chat tab.
L["LOOT_TOASTS_PANEL_DESCRIPTION"] =
	"Muestra en pantalla durante unos segundos cada objeto y moneda que despojas, para que no se te escape nada mientras Despojo rápido oculta la ventana de botín. Con los avisos activados, las líneas de botín del propio juego pueden dejar de aparecer en tu pestaña de chat %s."
L["LOOT_TOASTS_ENABLE"] = "Activar Avisos de botín"
-- Also the tooltip of the same switch in the General panel's Features section.
L["LOOT_TOASTS_SWITCH_DESCRIPTION"] = "Muestra un aviso para el botín que elijas en Filtros, el tuyo y el de tu grupo."
-- The dropdown beside Enable Loot Toasts: the game's Item Loot and Money Loot chat settings for the General tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"] = "Desactivar mensajes de botín estándar"
L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"] = "Activar mensajes de botín estándar"
-- Arguments: the game's own names for its Item Loot and Money Loot chat settings, then for the General chat tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"] =
	"Desactivar apaga %s y %s en tu pestaña de chat %s mientras Avisos de botín está activado, y al desactivar Avisos de botín vuelven. Es la misma opción que en la Configuración de esa pestaña, y las demás pestañas conservan la suya."

-- The Loot Toasts panel's two section headers.
L["LOOT_TOASTS_STACK_HEADER"] = "Pila de avisos"
L["LOOT_TOASTS_TEXT_HEADER"] = "Texto"

--[[
    Filters: a row per item type, captioned with the game's own name for it,
    each with a Mine box and a Group box. Weapon, Armor, Trade Goods and Gem
    carry a quality dropdown beside each ticked box. Argument in each tooltip:
    the row's item type, as the client names it.
]]
-- Shown on the Filters panel while Loot Toasts is off.
L["LOOT_TOASTS_OFF_NOTE"] = "Esta configuración no se usa mientras Avisos de botín está desactivado."
-- The Filters panel's description.
L["LOOT_TOASTS_FILTERS_CAPTION"] =
	"Elige qué recibe un aviso y qué dice, para tu propio botín y el de tu grupo. El botín de tu grupo muestra al lado el nombre de quien lo despoja."
L["LOOT_TOASTS_FILTER_MINE"] = "Mío"
L["LOOT_TOASTS_FILTER_GROUP"] = "Grupo"
L["LOOT_TOASTS_FILTER_MINE_DESCRIPTION"] = "Muestra los objetos de tipo %s que despojas."
L["LOOT_TOASTS_FILTER_GROUP_DESCRIPTION"] =
	"Muestra los objetos de tipo %s que despoja cualquiera de tu grupo o banda, con el nombre de quien los despoja."
L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"] =
	"Muestra los objetos de tipo %s que despojas, de la calidad indicada al lado o superior."
L["LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION"] =
	"Muestra los objetos de tipo %s que despoja cualquiera de tu grupo o banda, de la calidad indicada al lado o superior, con el nombre de quien los despoja."
L["LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION"] =
	"La calidad mínima que deben tener los objetos de tipo %s que despojas para recibir un aviso."
L["LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION"] =
	"La calidad mínima que deben tener los objetos de tipo %s que despoja tu grupo para recibir un aviso."

-- The three Filters rows after the item types, which aren't item types themselves: their captions (Money's is the client's MONEY) and their boxes' tooltips.
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP"] = "Se liga al recogerlo"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION"] =
	"Muestra todo objeto ligado al recogerlo que despojes, sea cual sea su tipo o calidad."
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION"] =
	"Muestra todo objeto ligado al recogerlo que despoje tu grupo, sea cual sea su tipo o calidad."
L["LOOT_TOASTS_FILTER_OPENABLES"] = "Para abrir"
L["LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION"] =
	"Muestra los contenedores que despojas y que GogoLoot puede abrir, cajas fuertes incluidas, sea cual sea su calidad."
L["LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION"] =
	"Muestra los contenedores que despoja tu grupo y que GogoLoot puede abrir, cajas fuertes incluidas, sea cual sea su calidad."
L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"] =
	"Muestra un aviso con las monedas que despojas. El juego no informa del dinero de otros jugadores, así que no hay casilla Grupo."

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast it follows the item
    (LOOT_TOASTS_WON_ROLL); on a group member's, their name
    (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Tirada ganadora"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] = "Añade a su aviso la tirada con la que ganaste un objeto, como (%s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Añade a su aviso la tirada con la que un miembro del grupo ganó un objeto, como (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_WON_ROLL"] = "%s (%s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Cantidad en bolsas"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Añade a los avisos de tu propio botín cuántos llevas ahora, como x3 (27), en cuanto llevas más de los que indica el aviso."
-- How many came, after the item on a toast. Argument: the count.
L["LOOT_TOASTS_QUANTITY"] = "x%d"
-- Bag Count, after the item and its count. Argument: how many the player carries.
L["LOOT_TOASTS_BAG_COUNT"] = "(%d)"

-- Stack
L["LOOT_TOASTS_MAX_ITEMS"] = "Máximo de avisos"
L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"] =
	"El máximo de avisos en pantalla a la vez; el más antiguo se va para hacer sitio."
L["LOOT_TOASTS_UNLIMITED"] = "Ilimitado"
L["LOOT_TOASTS_DURATION"] = "Segundos en pantalla"
L["LOOT_TOASTS_DURATION_DESCRIPTION"] = "Cuántos segundos dura cada aviso antes de desvanecerse."
L["LOOT_TOASTS_GROWTH"] = "Dirección de crecimiento"
L["LOOT_TOASTS_GROWTH_DESCRIPTION"] =
	"Si los avisos más antiguos se desplazan hacia arriba o hacia abajo, alejándose del más reciente."
L["LOOT_TOASTS_GROW_UP"] = "Hacia arriba"
L["LOOT_TOASTS_GROW_DOWN"] = "Hacia abajo"
L["LOOT_TOASTS_ALIGN"] = "Alinear objetos"
L["LOOT_TOASTS_ALIGN_DESCRIPTION"] = "A qué lado del ancla se alinean los avisos."
L["LOOT_TOASTS_ALIGN_LEFT"] = "Izquierda"
L["LOOT_TOASTS_ALIGN_RIGHT"] = "Derecha"

-- Text
L["LOOT_TOASTS_FONT"] = "Fuente"
L["LOOT_TOASTS_FONT_DESCRIPTION"] = "La fuente con la que se escriben los avisos."
L["LOOT_TOASTS_FONT_DEFAULT"] = "Predeterminada"
L["LOOT_TOASTS_FONT_SIZE"] = "Tamaño de fuente"
L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"] = "El tamaño del texto de los avisos; los iconos crecen y se encogen con él."
L["LOOT_TOASTS_OUTLINE"] = "Contorno de fuente"
L["LOOT_TOASTS_OUTLINE_DESCRIPTION"] =
	"El contorno alrededor del texto de los avisos, que lo mantiene legible sobre fondos claros."
L["LOOT_TOASTS_OUTLINE_NONE"] = "Ninguno"
L["LOOT_TOASTS_OUTLINE_OUTLINE"] = "Contorno"
L["LOOT_TOASTS_OUTLINE_THICK"] = "Contorno grueso"
L["LOOT_TOASTS_OUTLINE_MONOCHROME"] = "Monocromo"
L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"] = "Contorno monocromo"

-- Position
L["LOOT_TOASTS_UNLOCK"] = "Desbloquear posición"
L["LOOT_TOASTS_LOCK"] = "Bloquear posición"
L["LOOT_TOASTS_RESET"] = "Restablecer posición"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "Muestra u oculta el ancla para arrastrar los avisos a otro lugar."
L["LOOT_TOASTS_RESET_DESCRIPTION"] =
	"Devuelve los avisos a su posición predeterminada, encima del centro de la pantalla."

-- The drag handle: its title, the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_HANDLE_TITLE"] = "Avisos de botín de GogoLoot"
L["LOOT_TOASTS_CLICK_DRAG"] = "Clic y arrastrar para mover"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "Clic derecho para bloquear"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "Desactivar Avisos de botín"
-- The stand-in item on the sample toasts, and in every Example line.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "Objeto de ejemplo"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"Reproduce un sonido para el botín de la calidad que elijas o superior, y un sonido de bolsa cuando %s se lleva algo."
L["LOOT_SOUNDS_ENABLE"] = "Activar sonido de botín"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Reproduce un sonido cuando despojas de un cadáver o cofre un objeto de la calidad que elijas o superior."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "La calidad mínima de objeto que reproduce el sonido de botín."
L["LOOT_SOUNDS_TEST"] = "Reproduce el sonido de botín."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "Activar sonido de %s"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "Reproduce un sonido de bolsa cuando %s se lleva algo de verdad."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "Reproduce el sonido de %s."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"Abre por ti las almejas, cajones, bolsas de monedas y cajas fuertes ya forzadas de tus bolsas, siempre que tengas al menos %d espacios libres en las bolsas."
L["AUTOMATED_OPENING_ENABLE"] = "Activar Apertura automática"
-- Also the tooltip of the same switch in the General panel's Features section. Argument: the game's own name for its Auto Loot setting.
L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"] =
	"Abre un contenedor cada vez y espera si estás en combate, lanzando un hechizo, en sigilo, o con la ventana de un mercader, del banco, del buzón, de la casa de subastas o de comercio abierta. Activa la opción %s del juego mientras está activada."
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"] = "Solo fuera de instancias"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"No abre nada mientras estás en un calabozo, banda o campo de batalla."
L["AUTOMATED_OPENING_ONLY_SOLO"] = "Solo en solitario"
L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"] = "No abre nada mientras estás en un grupo o banda."

-- Lockboxes
-- Arguments: the game's own name for the Rogue class, then for the Lockpicking skill.
L["LOCKBOXES_SECTION_DESCRIPTION"] =
	"Una caja fuerte no se abre hasta que un %s la fuerce. Estas opciones muestran la habilidad de %s que necesita cada una y te avisan cuando hay una esperando."
L["LOCKBOXES_TOOLTIPS_ENABLE"] = "Activar descripciones de cajas fuertes"
-- Argument: the game's own name for the Lockpicking skill.
L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"] =
	"Añade a la descripción de cada caja fuerte la habilidad de %s que necesita."
L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"] =
	"Elige si las descripciones de cajas fuertes aparecen solo para pícaros o para todos los personajes."
L["LOCKBOXES_NOTIFICATIONS_ENABLE"] = "Activar avisos de cajas fuertes"
L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Te avisa en el chat cuando despojas una caja fuerte que se abrirá en cuanto se desbloquee."
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] =
	"Elige si los avisos de cajas fuertes aparecen solo para pícaros o para todos los personajes."
L["LOCKBOXES_FOR_ROGUES"] = "Para pícaros"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "Para todos los personajes"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking" line (ITEM_REQ_SKILL), followed by a skill number. Argument:
    the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "Tu %s"

-- On the Automated Opening panel, below its switch.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "Activar avisos de Ignorar"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Te avisa en el chat cuando GogoLoot no toca un contenedor porque la Lista de contenedores dice Ignorar, y por qué."

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	"Todos los contenedores que conoce GogoLoot y qué hace Apertura automática con cada uno. Ignorar mantiene un contenedor cerrado, y Despojo rápido lo deja en la ventana de botín para ti. Tus cambios se aplican a todos tus personajes."
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] =
	"Mientras Apertura automática está desactivada, solo se usa Ignorar: sigue impidiendo que Despojo rápido se lleve estos objetos."
L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"] =
	"Devuelve la lista a sus valores predeterminados: cada objeto recupera su opción predeterminada, los quitados vuelven y los añadidos se van."
L["OPENABLE_ITEMS_RESTORE_CONFIRM"] =
	"¿Devolver la lista a sus valores predeterminados? Se desharán todas las opciones que cambiaste y todos los objetos que añadiste o quitaste."
L["OPENABLE_ITEMS_ADD_DESCRIPTION"] =
	"Escribe el ID de un objeto o arrastra un objeto aquí para añadirlo a la lista, en Abrir. No se puede añadir equipo ni bolsas, porque al usarlos se equipan."
L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"] =
	"Añade a la lista un objeto que llevas encima, en Abrir. No se ofrecen equipo ni bolsas, porque al usarlos se equipan."
L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"] =
	"Quita este objeto de la lista. GogoLoot lo trata entonces como un objeto normal: nunca se abre y se despoja como cualquier otro."
L["OPENABLE_ITEMS_REMOVE_CONFIRM"] = "¿Quitar este objeto de la lista? Añádelo de nuevo para recuperarlo."
L["OPENABLE_ITEMS_ACTION_DESCRIPTION"] = "Elige qué hace Apertura automática con este contenedor."

-- The Openables List dropdown, one per item.
L["OPENING_ACTION_OPEN"] = "Abrir"
L["OPENING_ACTION_IGNORE"] = "Ignorar"

--[[
    The reason an item's default carries, shown as a short silver tag on its
    Openables List row whatever it is set to. Sell Sealed covers both a raid
    boss drop and a container that can hold Bind on Pickup loot.
]]
L["OPENING_TAG_SEALED"] = "Vender cerrado"
L["OPENING_TAG_UNIQUE"] = "Posible único"

--[[
    Each tag explained, under the item's tooltip on the Openables List. The
    item's own tooltip is directly above, so these never name the item.
]]
-- Argument: the game's own name for the Rogue class.
L["OPENING_REASON_LOCKED_CLASS"] =
	"Necesita que un %s lo fuerce. Una vez forzado, se abre como cualquier otro contenedor."
L["OPENING_REASON_RAID"] =
	"Lo suelta un jefe de banda o del mundo. Un contenedor sin abrir se puede comerciar o vender, a menudo por más de lo que contiene."
L["OPENING_REASON_BIND_ON_PICKUP"] = "Puede contener botín ligado al recogerlo. Cerrado, se puede comerciar o vender."
L["OPENING_REASON_UNIQUE"] = "Puede contener un objeto único. Abrirlo falla con un error si ya llevas uno."
