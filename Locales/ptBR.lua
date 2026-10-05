local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "ptBR")
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
	"Versão %s. As configurações (incluindo a opção de desativar esta mensagem) ficam em Opções > AddOns > GogoLoot. Curtindo o add-on? Conte para um amigo! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Por segurança, a janela de opções não pode ser aberta durante o combate."
-- Argument: the game's own name for its Auto Loot setting.
L["MESSAGE_AUTO_LOOT_SETTING_ON"] =
	"A opção %s do jogo foi ativada, pois o Saque Rápido e a Abertura Automática precisam dela."
-- Argument: the game's own word for Master Looter.
L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"] = "Você não é o %s no momento."

-- Automated Opening. Argument: the number of free bag slots opening waits for.
L["MESSAGE_OPENING_PAUSED"] =
	"A Abertura Automática está pausada até você ter pelo menos %d espaços livres nas bolsas."
L["MESSAGE_OPENING_RESUMED"] = "A Abertura Automática foi retomada."

-- Argument: the item's link.
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] = "%s será aberto automaticamente assim que for destrancado."
L["MESSAGE_ITEM_IGNORED"] = "%s está definido como Ignorar, então a Abertura Automática não vai mexer nele."
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s vem de um chefe de raide ou chefe mundial, então a Abertura Automática vai deixá-lo fechado para você negociar ou vender."
L["MESSAGE_ITEM_IGNORED_UNIQUE"] =
	"%s pode conter um item único, então a Abertura Automática vai deixá-lo para você abrir."
L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] = "%s ficou na janela de saque para você mesmo saquear."
-- The Openables List's Add Item refusing gear or a bag. Argument: the item's link, or its ID while uncached.
L["MESSAGE_ITEM_NOT_OPENABLE"] = "%s seria equipado em vez de aberto, então não pode entrar na Lista de Abríveis."

-- Automated Rolls' Print Item in Chat. Arguments: the game's word for the roll (Need or Greed), then the item's link.
L["MESSAGE_ROLL_PRINT"] = "Você rolou %s em %s."
-- The same after a Pass. Argument: the item's link.
L["MESSAGE_ROLL_PASS_PRINT"] = "Você passou em %s."
--[[
    Hide Roll Messages' winner summary. Arguments: the winner, the item's link,
    then the winning roll as LOOT_TOASTS_ROLL_RESULT words it ("Greed 95"). The
    NO_ROLL forms are for a win whose roll wasn't seen; the YOU forms for the
    player's own win, without the winner.
]]
L["MESSAGE_ROLL_WON_PRINT"] = "%s ganhou %s com %s."
L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"] = "%s ganhou %s."
L["MESSAGE_ROLL_YOU_WON_PRINT"] = "Você ganhou %s com %s."
L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"] = "Você ganhou %s."

--[[
    A trade summary printed to the player alone (the trade Channel's Me Only):
    the Chat Announcement Templates below, printed, so each ends on its
    punctuation. Arguments as theirs: items, then the partner, then what came
    back.
]]
L["MESSAGE_GAVE_PRINT"] = "Deu %s para %s."
L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "Deu %s para %s, recebeu %s."
L["MESSAGE_TRADE_RECEIVED_PRINT"] = "Recebeu %s de %s."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "Deu %s para %s"
L["MESSAGE_DESTINATION_SET"] = "%s vai guardar os itens de qualidade %s para o grupo"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s vai guardar todo o saque para o grupo"
-- Arguments: the player who left, the master looter, then the qualities they held, joined by commas.
L["MESSAGE_DESTINATION_LEFT"] = "%s saiu do grupo. Agora %s vai guardar os itens de qualidade %s para o grupo"
-- The same when they held every quality. Arguments: the player who left, then the master looter.
L["MESSAGE_DESTINATION_LEFT_ALL"] = "%s saiu do grupo. Agora %s vai guardar todo o saque para o grupo"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Deu %s para %s, recebeu %s"
L["MESSAGE_TRADE_RECEIVED"] = "Recebeu %s de %s"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "As bolsas de %s estão cheias: %s"
L["ERROR_MAX_COUNT"] = "%s já tem o máximo permitido de: %s"
L["ERROR_OUT_OF_RANGE"] = "%s está fora de alcance: %s"
L["ERROR_NOT_IN_GROUP"] = "%s não está mais no grupo ou raide: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "Não foi possível entregar o saque para %s: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_AUTOMATED_ROLLS"] = "Rolagens Automáticas"
L["TAB_ITEM_OVERRIDES"] = "Exceções de Itens"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "Regras de Personagem"
-- The panel for everything GogoLoot posts to chat.
L["TAB_ANNOUNCEMENTS"] = "Anúncios"
-- Headers of the two sections on the Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "Anúncios de Troca"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "Anúncios do Mestre do Saque"
L["TAB_LOOT_TOASTS"] = "Avisos de Saque"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "Filtros"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "Sons de Saque"
L["TAB_AUTOMATED_OPENING"] = "Abertura Automática"
-- Header of a section on the Automated Opening panel.
L["TAB_LOCKBOXES"] = "Cofres"
L["TAB_OPENABLE_ITEMS"] = "Lista de Abríveis"
L["TAB_MASTER_LOOTER"] = "Mestre do Saque"
-- Header of a section on the Master Looter panel.
L["TAB_LOOT_DESTINATIONS"] = "Destinos do Saque"
L["TAB_IGNORE_LIST"] = "Lista de Ignorados"

-- A child panel's title where the Settings tree can't nest it: the parent's title, then its own.
L["TAB_NESTED_FORMAT"] = "%s: %s"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Ativado"
L["STATUS_DISABLED"] = "Desativado"
-- Automated Opening is on but waiting for empty bag slots.
L["STATUS_PAUSED"] = "Pausado"

--[[
    The tooltip titles each feature with its options-panel name (Automated
    Master Looting excepted, since its panel is titled Master Looter), and
    gives each a description of its own, two lines at most: the panels' longer
    text doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Rola por você nos itens elegíveis até a qualidade que você escolher."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] =
	"Abre mariscos, caixotes, bolsas de moedas e cofres arrombados nas suas bolsas."
L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"] = "Publica no chat os resumos de trocas e as entregas do Mestre do Saque."
L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"] =
	"Entrega o saque aos jogadores que você escolheu para cada qualidade."
--[[
    The tooltip's read-back of each group context's roll, one line each under
    the description. Arguments: the game's own word for Party or Raid, the roll,
    then (all but Manual) the highest quality it rolls on.
]]
L["MINIMAP_ROLLS_SETTING"] = "%s: %s, %s"
L["MINIMAP_ROLLS_SETTING_MANUAL"] = "%s: %s"

L["MINIMAP_LEFT_CLICK"] = "Clique esquerdo"
L["MINIMAP_RIGHT_CLICK"] = "Clique direito"
L["MINIMAP_SHIFT_LEFT_CLICK"] = "Shift + Clique esquerdo"
L["MINIMAP_SHIFT_RIGHT_CLICK"] = "Shift + Clique direito"
-- The tooltip's title for the Automated Master Looting block, the feature its switch names.
L["MINIMAP_AUTOMATED_MASTER_LOOTING"] = "Mestre do Saque Automatizado"
L["MINIMAP_TOGGLE"] = "Alternar"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "Itens trancados"
L["MINIMAP_OPTIONS"] = "Opções do GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Clique do meio"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "Manual"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "Só %s"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s e abaixo"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List brings text of its own), the hint the box shows while empty,
    and its button.
]]
L["ITEM_LIST_ADD"] = "Adicionar Item"
L["ITEM_LIST_ADD_DESCRIPTION"] = "Digite a ID de um item ou arraste um item até aqui para adicioná-lo à lista."
L["ITEM_LIST_ADD_PLACEHOLDER"] = "Solte o item aqui ou digite a ID"
L["ITEM_LIST_ADD_BUTTON"] = "Adicionar"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "Filtrar itens..."
L["ITEM_LIST_FILTER_DESCRIPTION"] =
	"Mostra só os itens cujo nome, ID, configuração ou etiqueta contém o que você digitar."
L["ITEM_LIST_NO_MATCHES"] = "Nenhum item corresponde ao filtro."

-- The header over what the player just added to an item list, at its top until they filter it or close the window.
L["ITEM_LIST_NEW"] = "Novos"

-- The kind filter beside every item list's search box: its first choice (the rest are the list's headers) and its tooltip.
L["ITEM_LIST_KIND_ALL"] = "Mostrar Todos os Tipos de Itens"
L["ITEM_LIST_KIND_DESCRIPTION"] = "Mostra todos os itens da lista, ou só os itens de um tipo."

--[[
    The Add from Bags dropdown beside every item list's add box: its resting
    text and tooltip, then what it reads, greyed out, when everything carried
    is already on the list. The Openables List brings a tooltip of its own.
]]
L["ITEM_LIST_ADD_FROM_BAGS"] = "Adicionar das Bolsas"
L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"] = "Adiciona à lista um item que você carrega."
L["ITEM_LIST_BAGS_EMPTY"] = "Nada nas bolsas para adicionar"
L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"] = "Todos os itens que você carrega já estão na lista."

-- The button at the foot of every item list; each list's tooltip and confirmation say what it restores.
L["ITEM_LIST_RESTORE"] = "Restaurar Padrões"

-- Placeholder shown in the item lists until the client caches an item's info.
L["ITEM_LOADING"] = "Carregando... (ID: %d)"

--[[
    Appended to the Automated Rolls description. Item Overrides is the one way
    a Bind on Pickup or quest item gets rolled on; nothing ever rolls on the
    rest.
]]
L["SAFETY_SKIP_NOTE"] =
	"Nunca rola em receitas, livros, montarias, mascotes ou lendários, e só rola em itens que se vinculam ao ser recolhidos ou itens de missão se estiverem em Exceções de Itens."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] = "Receitas, livros, montarias, mascotes e lendários sempre ficam para você."

--[[
    Shown under each announcement's toggle, under Print Item in Chat and Hide
    Roll Messages, and under Enable Ignore Notifications. Argument: the
    message, as GogoLoot sends or prints it.
]]
L["OPTIONS_EXAMPLE"] = "Exemplo: %s"

-- The muted version line at the foot of the General panel.
L["OPTIONS_VERSION"] = "Versão %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"O Saque Rápido esvazia corpos num piscar de olhos, as Rolagens Automáticas e o Mestre do Saque Automatizado decidem quem fica com o quê, e a Abertura Automática abre cada marisco e caixote. Os Avisos de Saque mostram tudo, e itens de missão, receitas, montarias, mascotes e lendários ficam a salvo. Não deixe o saque frear a sua correria!"
L["WELCOME_MESSAGE"] = "Ativar Mensagem de Boas-vindas"
L["WELCOME_MESSAGE_DESCRIPTION"] =
	"Mostra a versão do GogoLoot e onde encontrar estas configurações sempre que você entra no jogo."
L["MINIMAP_BUTTON_ENABLE"] = "Ativar Botão do Minimapa"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"Mostra o botão do GogoLoot no minimapa. Clique esquerdo alterna as Rolagens Automáticas, Clique direito a Abertura Automática, Shift + Clique esquerdo os Anúncios e Shift + Clique direito o Mestre do Saque Automatizado."

L["OPTIONS_COMMANDS_HEADER"] = "/Comandos"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre a janela de opções deste add-on."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "Recursos"

L["SPEEDY_LOOT_ENABLE"] = "Ativar Saque Rápido"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"Esvazia cada corpo assim que você o abre, sem mostrar a janela de saque. Segure Shift ao saquear para ver a janela. Ativa a opção %s do jogo e fica inativo enquanto você é o %s."

L["FEEDBACK_SUPPORT"] = "Feedback e Suporte"

-- CurseForge / GitHub / Discord / Wago are proper nouns; do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "Configurações de Saque do Grupo"
L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"] =
	"Define como o saque do grupo é distribuído. Só o líder do grupo pode mudar isso."
L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"] =
	"Define a qualidade de item mais baixa à qual o método de saque se aplica. Só o líder do grupo pode mudar isso."

--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them, including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "Estas configurações são controladas por %s."
-- Shown in the same place while solo, where the two dropdowns are greyed out.
L["MASTER_LOOTER_SOLO_NOTE"] = "Entre em um grupo para mudar isto. Só o líder do grupo pode."

-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"] =
	"Entrega cada item ao jogador escolhido para a qualidade dele assim que você abre a janela de saque, enquanto você é o %s."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "Ativar Mestre do Saque Automatizado"
L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"] =
	"Liga ou desliga as entregas automáticas. Só funciona dentro de masmorras e raides, a menos que Também Fora de Instâncias esteja ativado."
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Também Fora de Instâncias"
L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Também entrega o saque no mundo aberto. O saque de chefes mundiais não pode ser negociado, então isso não é recomendado."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "Incluir Itens de Missão"
L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"] =
	"Também entrega itens de missão, para ajudar a upar um personagem que você mesmo joga. Só funciona com limite de saque Comum ou abaixo, e só para itens de missão que caem uma vez para o grupo todo. Não recomendado em raides."

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Configurações Rápidas"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_POPUP_TOOLTIP"] = "Abre estas configurações em uma janela sempre que você se torna o %s."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Ativar Janela do Mestre do Saque"

L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"Escolha quem recebe cada qualidade. Uma qualidade sem ninguém escolhido fica na janela de saque para você."
L["MASTER_LOOTER_DESTINATION_SELF"] = "Eu mesmo"
-- The first choice in every destination dropdown: nobody picked, so that quality waits in the loot window.
L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"] = "Janela de Saque"
L["MASTER_LOOTER_SEND_ALL"] = "Enviar Todo o Saque Para"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] = "Define um único jogador para todas as qualidades abaixo."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Define quem recebe os itens de qualidade %s."
-- Shown under Loot Destinations while Automated Master Looting is on and no quality has anybody picked.
L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] =
	"Ninguém foi escolhido ainda, então todo o saque espera na janela de saque por você."

L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Os itens desta lista nunca são entregues automaticamente. Eles esperam na janela de saque para você mesmo entregar."
-- Shown on the Ignore List while Automated Master Looting is off.
L["MASTER_LOOTER_OFF_NOTE"] =
	"Estas configurações não são usadas enquanto o Mestre do Saque Automatizado estiver desativado."
L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"] = "Substitui a Lista de Ignorados pelos itens padrão da sua expansão."
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"Isso vai substituir sua Lista de Ignorados pelos itens padrão da sua expansão. Continuar?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Remove este item da Lista de Ignorados."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_PANEL_DESCRIPTION"] =
	"Rola %s, %s ou %s por você no saque em grupo, até a qualidade que você escolher, com configurações separadas para grupos e raides."
L["ROLLS_ENABLE"] = "Ativar Rolagens Automáticas"
L["ROLLS_ENABLE_DESCRIPTION"] =
	"Liga ou desliga as rolagens automáticas, incluindo as Exceções de Itens e as Regras de Personagem."
L["ROLLS_IN_PARTY"] = "Em Grupo"
L["ROLLS_IN_RAID"] = "Em Raide"
-- The caption of the quality row under In Party and under In Raid, shown while that roll isn't Manual.
L["ROLLS_UP_TO_QUALITY"] = "Até a Qualidade"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: a qualidade mais alta em que o GogoLoot rola."
L["ROLLS_ACTION_CHOOSE"] = "%s: a rolagem que o GogoLoot faz. Manual deixa a rolagem com você."
-- Section headers on the Automated Rolls panel.
L["ROLLS_LOOT_THRESHOLDS_HEADER"] = "Limites de Saque"
L["ROLLS_MESSAGES_HEADER"] = "Mensagens de Rolagem"
L["ROLLS_PRINT_ITEM"] = "Mostrar Item no Chat"
L["ROLLS_PRINT_ITEM_DESCRIPTION"] =
	"Mostra no seu chat cada item em que o GogoLoot rola e a rolagem que ele fez. A janela de rolagem fecha assim que o GogoLoot rola, então este é o seu registro do que apareceu."
L["ROLLS_HIDE_MESSAGES"] = "Ocultar Mensagens de Rolagem"
-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_HIDE_MESSAGES_TOOLTIP"] =
	"Oculta as linhas de chat do jogo para cada rolagem: quem escolheu %s, %s ou %s, e cada número rolado. O que cada vencedor recebeu continua no chat."
-- The dropdown beside Hide Roll Messages.
L["ROLLS_WINNER_SUMMARY_PRINT"] = "Mostrar Resumo do Vencedor"
L["ROLLS_WINNER_SUMMARY_NONE"] = "Não Mostrar Resumo do Vencedor"
L["ROLLS_WINNER_SUMMARY_DESCRIPTION"] =
	"Mostrar Resumo do Vencedor põe no chat uma linha para cada vitória, com o vencedor, o item e a rolagem vencedora, no lugar da linha do próprio jogo. Não Mostrar Resumo do Vencedor mantém a linha do jogo dizendo quem ganhou."

--[[
    Item Overrides, under Automated Rolls: items with a roll action of their
    own.
]]
L["ITEM_OVERRIDES_DESCRIPTION"] =
	"Define a rolagem para itens específicos, antes das configurações de qualidade. É a única forma de o GogoLoot rolar em um item que se vincula ao ser recolhido ou em um item de missão."
-- Shown on Item Overrides while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "Estas configurações não são usadas enquanto as Rolagens Automáticas estiverem desativadas."
L["ITEM_OVERRIDES_ENABLE"] = "Ativar Exceções de Itens"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"Usa as rolagens definidas abaixo. Desativado, estes itens seguem as configurações de qualidade como qualquer outro."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] = "Substitui suas Exceções de Itens pelos itens padrão da sua expansão."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"Isso vai substituir suas Exceções de Itens pelos itens padrão da sua expansão. Continuar?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "Define a rolagem automática para este item."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "Remove este item das Exceções de Itens."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] = "Remover este item e a rolagem dele das Exceções de Itens?"

--[[
    Character Rules, under Automated Rolls: the stats whose gear each
    character leaves to the player. The stat names come from the game's own
    strings.
]]
-- Arguments: the game's own name for Intellect, then for the Warrior class, then Intellect again.
L["CHARACTER_RULES_PANEL_DESCRIPTION"] =
	"Deixa com você os equipamentos com os atributos que você escolher, personagem por personagem: defina %s como Manual no seu %s, e os equipamentos com %s mantêm a janela de rolagem enquanto todo o resto rola normalmente. As Exceções de Itens ainda vêm primeiro."
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "Atributos Primários"
L["CHARACTER_RULES_SECONDARY"] = "Atributos Secundários"
-- The first of the two choices in each stat's dropdown: no rule, so the rest of Automated Rolls decides.
L["CHARACTER_RULES_STANDARD"] = "Rolagem Automática Padrão"
L["CHARACTER_RULES_ACTION_DESCRIPTION"] =
	"%s: Manual deixa com você os equipamentos com esse atributo neste personagem, janela de rolagem e tudo. Rolagem Automática Padrão rola neles como em qualquer outro item."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"Publica no chat os resumos de trocas e as entregas do Mestre do Saque, para que todos saibam para onde o saque foi."
L["ANNOUNCEMENTS_ENABLE"] = "Ativar Anúncios"
-- Also the tooltip of the same switch in the General panel's Features section, so it names no position on the panel.
L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"] =
	"Liga ou desliga todos os anúncios. Desativado, o GogoLoot não envia nada ao seu grupo nem aos seus parceiros de troca, nem mesmo os itens que você entrega pessoalmente."

-- Trade Announcements
L["TRADE_DESCRIPTION"] = "Publica um resumo de cada troca concluída: itens, encantamentos e ouro."
L["TRADE_ENABLE"] = "Ativar Anúncios de Troca"
L["TRADE_ENABLE_DESCRIPTION"] =
	"Publica um resumo quando uma troca é concluída. A caixa Anunciar na janela de troca é esta mesma opção."
L["TRADE_CONDITION_DESCRIPTION"] =
	"Escolhe quando os resumos de troca são publicados: sempre, quando em grupo ou raide, ou quando em raide."
L["TRADE_CONDITION_ALWAYS"] = "Sempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Em Grupo ou Raide"
L["TRADE_CONDITION_RAID_ONLY"] = "Em Raide"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "Canal"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	"%s envia cada resumo ao seu parceiro de troca. Chat do Grupo publica no grupo ou raide, e sussurra mesmo assim fora de um grupo. Só Eu mostra no seu próprio chat e não envia a ninguém."
-- The Channel dropdown's choices (Whisper is the client's WHISPER), and the trade window checkbox tooltip's Channel value.
L["TRADE_OUTPUT_GROUP"] = "Chat do Grupo"
L["TRADE_OUTPUT_SELF"] = "Só Eu"
L["TRADE_TOOLTIP_DESCRIPTION"] = "Publica um resumo da troca no chat quando esta troca for concluída."
L["TRADE_CHECKBOX_LABEL"] = "Anunciar"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Informa ao grupo quem guarda cada qualidade e o que você já entregou."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Ativar Anúncios de Destino"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"] =
	"Informa ao grupo quem guarda cada qualidade sempre que você define um destino."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Ativar Anúncios de Entrega Automática"
L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"] =
	"Anuncia cada item que o GogoLoot entrega automaticamente, na qualidade que você escolher ou acima."
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"] =
	"Entregas automáticas abaixo desta qualidade não são anunciadas."

L["MASTER_LOOTER_ANNOUNCE_MANUAL"] = "Ativar Anúncios de Entrega Manual"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"] =
	"Anuncia cada item que você mesmo entrega pelo menu do %s, seja qual for a qualidade, com o mesmo texto de uma entrega automática. Uma entrega que falha é informada de qualquer forma."

--------------------------------------------------------------------------------
-- Options: Loot Toasts and Loot Sounds
--------------------------------------------------------------------------------

-- Argument: the game's own name for the General chat tab.
L["LOOT_TOASTS_PANEL_DESCRIPTION"] =
	"Mostra na tela por alguns segundos cada item e moeda que você saqueia, para que nada passe despercebido enquanto o Saque Rápido oculta a janela de saque. Com os avisos ativados, as linhas de saque do próprio jogo podem sair da sua aba de chat %s."
L["LOOT_TOASTS_ENABLE"] = "Ativar Avisos de Saque"
-- Also the tooltip of the same switch in the General panel's Features section.
L["LOOT_TOASTS_SWITCH_DESCRIPTION"] =
	"Mostra um aviso para o saque que você escolher em Filtros, o seu e o do seu grupo."
-- The dropdown beside Enable Loot Toasts: the game's Item Loot and Money Loot chat settings for the General tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"] = "Desativar Mensagens de Saque Padrão"
L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"] = "Ativar Mensagens de Saque Padrão"
-- Arguments: the game's own names for its Item Loot and Money Loot chat settings, then for the General chat tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"] =
	"Desativar desliga %s e %s na sua aba de chat %s enquanto os Avisos de Saque estiverem ativados, e desligar os Avisos de Saque os traz de volta. É a mesma opção das Configurações dessa aba, e as outras abas mantêm as suas."

-- The Loot Toasts panel's two section headers.
L["LOOT_TOASTS_STACK_HEADER"] = "Pilha"
L["LOOT_TOASTS_TEXT_HEADER"] = "Texto"

--[[
    Filters: a row per item type, captioned with the game's own name for it,
    each with a Mine box and a Group box. Weapon, Armor, Trade Goods and Gem
    carry a quality dropdown beside each ticked box. Argument in each tooltip:
    the row's item type, as the client names it.
]]
-- Shown on the Filters panel while Loot Toasts is off.
L["LOOT_TOASTS_OFF_NOTE"] = "Estas configurações não são usadas enquanto os Avisos de Saque estiverem desativados."
-- The Filters panel's description.
L["LOOT_TOASTS_FILTERS_CAPTION"] =
	"Escolha o que ganha um aviso, e o que ele diz, para o seu saque e o do seu grupo. O saque do grupo mostra ao lado o nome de quem saqueou."
L["LOOT_TOASTS_FILTER_MINE"] = "Meu"
L["LOOT_TOASTS_FILTER_GROUP"] = "Grupo"
L["LOOT_TOASTS_FILTER_MINE_DESCRIPTION"] = "Mostra os itens do tipo %s que você saqueia."
L["LOOT_TOASTS_FILTER_GROUP_DESCRIPTION"] =
	"Mostra os itens do tipo %s que alguém do seu grupo ou raide saqueia, com o nome de quem saqueou."
L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"] =
	"Mostra os itens do tipo %s que você saqueia, na qualidade ao lado ou acima."
L["LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION"] =
	"Mostra os itens do tipo %s que alguém do seu grupo ou raide saqueia, na qualidade ao lado ou acima, com o nome de quem saqueou."
L["LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION"] =
	"A qualidade mínima para os itens do tipo %s que você saqueia ganharem um aviso."
L["LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION"] =
	"A qualidade mínima para os itens do tipo %s que seu grupo saqueia ganharem um aviso."

-- The three Filters rows after the item types, which aren't item types themselves: their captions (Money's is the client's MONEY) and their boxes' tooltips.
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP"] = "Vincula-se ao ser recolhido"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION"] =
	"Mostra todo item que você saqueia e que se vincula ao ser recolhido, seja qual for o tipo ou a qualidade."
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION"] =
	"Mostra todo item que seu grupo saqueia e que se vincula ao ser recolhido, seja qual for o tipo ou a qualidade."
L["LOOT_TOASTS_FILTER_OPENABLES"] = "Abríveis"
L["LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION"] =
	"Mostra os recipientes que você saqueia e que o GogoLoot pode abrir, cofres incluídos, seja qual for a qualidade."
L["LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION"] =
	"Mostra os recipientes que seu grupo saqueia e que o GogoLoot pode abrir, cofres incluídos, seja qual for a qualidade."
L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"] =
	"Mostra um aviso para as moedas que você saqueia. O jogo não informa as moedas dos outros jogadores, então não há caixa Grupo."

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast it follows the item
    (LOOT_TOASTS_WON_ROLL); on a group member's, their name
    (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "Rolagem Vencedora"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] = "Adiciona ao aviso a rolagem com que você ganhou o item, como (%s)."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"Adiciona ao aviso de um membro do grupo a rolagem com que ele ganhou o item, como (%s, %s)."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_WON_ROLL"] = "%s (%s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "Total nas Bolsas"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"Adiciona aos avisos do seu próprio saque quantos você carrega agora, como x3 (27), quando você carrega mais do que a quantidade mostrada no aviso."
-- How many came, after the item on a toast. Argument: the count.
L["LOOT_TOASTS_QUANTITY"] = "x%d"
-- Bag Count, after the item and its count. Argument: how many the player carries.
L["LOOT_TOASTS_BAG_COUNT"] = "(%d)"

-- Stack
L["LOOT_TOASTS_MAX_ITEMS"] = "Máximo de Avisos"
L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"] = "O máximo de avisos na tela ao mesmo tempo; o mais antigo sai para dar lugar."
L["LOOT_TOASTS_UNLIMITED"] = "Ilimitado"
L["LOOT_TOASTS_DURATION"] = "Segundos na Tela"
L["LOOT_TOASTS_DURATION_DESCRIPTION"] = "Quantos segundos cada aviso fica na tela antes de sumir."
L["LOOT_TOASTS_GROWTH"] = "Direção de Crescimento"
L["LOOT_TOASTS_GROWTH_DESCRIPTION"] = "Se os avisos mais antigos sobem ou descem, afastando-se do mais recente."
L["LOOT_TOASTS_GROW_UP"] = "Para Cima"
L["LOOT_TOASTS_GROW_DOWN"] = "Para Baixo"
L["LOOT_TOASTS_ALIGN"] = "Alinhar Itens"
L["LOOT_TOASTS_ALIGN_DESCRIPTION"] = "Em que lado da alça os avisos se alinham."
L["LOOT_TOASTS_ALIGN_LEFT"] = "Esquerda"
L["LOOT_TOASTS_ALIGN_RIGHT"] = "Direita"

-- Text
L["LOOT_TOASTS_FONT"] = "Fonte"
L["LOOT_TOASTS_FONT_DESCRIPTION"] = "A fonte usada nos avisos."
L["LOOT_TOASTS_FONT_DEFAULT"] = "Padrão"
L["LOOT_TOASTS_FONT_SIZE"] = "Tamanho da Fonte"
L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"] = "O tamanho do texto dos avisos; os ícones crescem e diminuem junto."
L["LOOT_TOASTS_OUTLINE"] = "Contorno da Fonte"
L["LOOT_TOASTS_OUTLINE_DESCRIPTION"] =
	"O contorno desenhado em volta do texto dos avisos, que o mantém legível sobre cenários claros."
L["LOOT_TOASTS_OUTLINE_NONE"] = "Nenhum"
L["LOOT_TOASTS_OUTLINE_OUTLINE"] = "Contorno"
L["LOOT_TOASTS_OUTLINE_THICK"] = "Contorno Grosso"
L["LOOT_TOASTS_OUTLINE_MONOCHROME"] = "Monocromático"
L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"] = "Contorno Monocromático"

-- Position
L["LOOT_TOASTS_UNLOCK"] = "Destravar Posição"
L["LOOT_TOASTS_LOCK"] = "Travar Posição"
L["LOOT_TOASTS_RESET"] = "Redefinir Posição"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "Mostra ou oculta a alça para arrastar os avisos para outro lugar."
L["LOOT_TOASTS_RESET_DESCRIPTION"] = "Leva os avisos de volta à posição padrão, acima do centro da tela."

-- The drag handle: its title, the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_HANDLE_TITLE"] = "Avisos de Saque do GogoLoot"
L["LOOT_TOASTS_CLICK_DRAG"] = "Clique e arraste para posicionar"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "Clique direito para travar"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "Desativar Avisos de Saque"
-- The stand-in item on the sample toasts, and in every Example line.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "Item de Exemplo"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"Toca um sinal para saques na qualidade que você escolher ou acima, e um som de bolsa quando %s pega algo."
L["LOOT_SOUNDS_ENABLE"] = "Ativar Som de Saque"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"Toca um sinal quando você saqueia de um corpo ou baú um item na qualidade que você escolher ou acima."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "A qualidade de item mais baixa que toca o som de saque."
L["LOOT_SOUNDS_TEST"] = "Toca o som de saque."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "Ativar Som de %s"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] = "Toca um som de bolsa quando %s realmente pega algo."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "Toca o som de %s."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"Abre para você mariscos, caixotes, bolsas de moedas e cofres arrombados nas suas bolsas, sempre que você tiver pelo menos %d espaços livres nas bolsas."
L["AUTOMATED_OPENING_ENABLE"] = "Ativar Abertura Automática"
-- Also the tooltip of the same switch in the General panel's Features section. Argument: the game's own name for its Auto Loot setting.
L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"] =
	"Abre um recipiente por vez e espera durante combate, lançamento de feitiços, furtividade, ou enquanto um mercador, banco, caixa de correio, casa de leilões ou janela de troca estiver aberto. Ativa a opção %s do jogo enquanto estiver ativada."
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"] = "Só Fora de Instâncias"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"Não abre nada enquanto você estiver em uma masmorra, raide ou campo de batalha."
L["AUTOMATED_OPENING_ONLY_SOLO"] = "Só Sozinho"
L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"] = "Não abre nada enquanto você estiver em grupo ou raide."

-- Lockboxes
-- Arguments: the game's own name for the Rogue class, then for the Lockpicking skill.
L["LOCKBOXES_SECTION_DESCRIPTION"] =
	"Um cofre só abre depois que um %s o arromba. Estas opções mostram a habilidade de %s que cada um exige e avisam quando um está esperando."
L["LOCKBOXES_TOOLTIPS_ENABLE"] = "Ativar Dicas de Cofres"
-- Argument: the game's own name for the Lockpicking skill.
L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"] = "Adiciona à dica de cada cofre a habilidade de %s que ele exige."
L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"] =
	"Define se as dicas de cofres aparecem só para Ladinos ou para todos os personagens."
L["LOCKBOXES_NOTIFICATIONS_ENABLE"] = "Ativar Notificações de Cofres"
L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Avisa no chat quando você saqueia um cofre que será aberto assim que for destrancado."
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] =
	"Define se as notificações de cofres aparecem só para Ladinos ou para todos os personagens."
L["LOCKBOXES_FOR_ROGUES"] = "Para Ladinos"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "Para Todos os Personagens"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking" line (ITEM_REQ_SKILL), followed by a skill number. Argument:
    the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "Seu %s"

-- On the Automated Opening panel, below its switch.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "Ativar Avisos de Ignorados"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"Avisa no chat quando o GogoLoot deixa um recipiente de lado porque a Lista de Abríveis diz Ignorar, e por quê."

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	"Todo recipiente que o GogoLoot conhece e o que a Abertura Automática faz com ele. Ignorar mantém o recipiente lacrado, e o Saque Rápido o deixa na janela de saque para você. Suas alterações valem para todos os seus personagens."
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] =
	"Só Ignorar está em uso enquanto a Abertura Automática estiver desativada: ele ainda impede o Saque Rápido de pegar estes itens."
L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"] =
	"Volta a lista ao padrão: cada item volta à configuração padrão, os itens removidos retornam e os adicionados saem."
L["OPENABLE_ITEMS_RESTORE_CONFIRM"] =
	"Voltar a lista ao padrão? Toda configuração que você mudou e todo item que você adicionou ou removeu serão desfeitos."
L["OPENABLE_ITEMS_ADD_DESCRIPTION"] =
	"Digite a ID de um item ou arraste um item até aqui para adicioná-lo à lista, definido como Abrir. Equipamentos e bolsas não podem ser adicionados, pois usá-los os equipa."
L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"] =
	"Adiciona à lista um item que você carrega, definido como Abrir. Equipamentos e bolsas não são oferecidos, pois usá-los os equipa."
L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"] =
	"Remove este item da lista. O GogoLoot passa a tratá-lo como um item normal: nunca é aberto e é saqueado como qualquer outro."
L["OPENABLE_ITEMS_REMOVE_CONFIRM"] = "Remover este item da lista? Adicione-o de novo para trazê-lo de volta."
L["OPENABLE_ITEMS_ACTION_DESCRIPTION"] = "Define o que a Abertura Automática faz com este recipiente."

-- The Openables List dropdown, one per item.
L["OPENING_ACTION_OPEN"] = "Abrir"
L["OPENING_ACTION_IGNORE"] = "Ignorar"

--[[
    The reason an item's default carries, shown as a short silver tag on its
    Openables List row whatever it is set to. Sell Sealed covers both a raid
    boss drop and a container that can hold Bind on Pickup loot.
]]
L["OPENING_TAG_SEALED"] = "Vender Lacrado"
L["OPENING_TAG_UNIQUE"] = "Pode Ter Único"

--[[
    Each tag explained, under the item's tooltip on the Openables List. The
    item's own tooltip is directly above, so these never name the item.
]]
-- Argument: the game's own name for the Rogue class.
L["OPENING_REASON_LOCKED_CLASS"] =
	"Precisa de um %s para arrombá-lo. Depois de arrombado, abre como qualquer outro recipiente."
L["OPENING_REASON_RAID"] =
	"Deixado por um chefe de raide ou chefe mundial. Um recipiente fechado ainda pode ser negociado ou vendido, muitas vezes por mais do que o conteúdo."
L["OPENING_REASON_BIND_ON_PICKUP"] =
	"Pode conter saque que se vincula ao ser recolhido. Lacrado, ainda pode ser negociado ou vendido."
L["OPENING_REASON_UNIQUE"] = "Pode conter um item único. Abrir falha com um erro se você já tiver um."
