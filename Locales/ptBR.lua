local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "ptBR")
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
	"Versão %s. As configurações (incluindo a opção de desativar esta mensagem) podem ser encontradas em Opções > AddOns > GogoLoot. Gostando do add-on? Conte para um amigo! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Por precaução, a interface de opções não pode ser aberta durante o combate."
L["MESSAGE_AUTO_LOOT_ENABLED"] = "O Saque Automático foi ativado. O Saque Rápido precisa dele para funcionar."
L["MESSAGE_NOT_MASTER_LOOTER"] = "Você não é o Mestre Saqueador no momento."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "Deu %s para %s."
L["MESSAGE_DESTINATION_SET"] = "%s receberá todos os itens %s."
L["MESSAGE_DESTINATION_SET_ALL"] = "%s vai guardar todo o saque para o grupo."
L["MESSAGE_DESTINATION_LEFT"] = "%s saiu do grupo. %s agora receberá todos os itens %s."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "Deu %s para %s, recebeu %s."
L["MESSAGE_TRADE_RECEIVED"] = "Recebeu %s de %s."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "As bolsas de %s estão cheias: %s"
L["ERROR_MAX_COUNT"] = "%s já tem itens demais de: %s"
L["ERROR_OUT_OF_RANGE"] = "%s está fora de alcance: %s"
L["ERROR_NOT_IN_GROUP"] = "%s não está mais no grupo ou raide: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "Não foi possível dar para %s: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "Mestre Saqueador"
L["TAB_AUTOMATED_ROLLS"] = "Rolagens Automáticas"
L["TAB_ANNOUNCEMENTS"] = "Anúncios"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "Ativado"
L["STATUS_DISABLED"] = "Desativado"

--[[
    The tooltip titles each feature with its options-panel name rather than
    keeping its own copy: Automated Rolls uses TAB_AUTOMATED_ROLLS, Speedy Loot
    uses SPEEDY_LOOT_HEADER and SPEEDY_LOOT_DESCRIPTION. Only the roll
    description below is unique to the tooltip, where the panel's longer text
    would not fit.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] = "Rola por você em itens elegíveis até a qualidade escolhida."

L["MINIMAP_LEFT_CLICK"] = "Botão Esquerdo"
L["MINIMAP_RIGHT_CLICK"] = "Botão Direito"
L["MINIMAP_TOGGLE"] = "Alternar"
L["MINIMAP_OPTIONS"] = "Opções do GogoLoot"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Clique do meio"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- Quality Labels
L["QUALITY_POOR"] = "Pobre"
L["QUALITY_COMMON"] = "Comum"
L["QUALITY_UNCOMMON"] = "Incomum"
L["QUALITY_RARE"] = "Raro"
L["QUALITY_EPIC"] = "Épico"

-- Roll Action Labels
L["ROLL_MANUAL"] = "Manual"
L["ROLL_GREED"] = "Ganância"
L["ROLL_NEED"] = "Necessidade"
L["ROLL_PASS"] = "Passar"

-- Loot Method Labels
L["LOOT_METHOD_FREE_FOR_ALL"] = "Livre para Todos"
L["LOOT_METHOD_ROUND_ROBIN"] = "Alternado"
L["LOOT_METHOD_MASTER"] = "Mestre Saqueador"
L["LOOT_METHOD_GROUP"] = "Saque em Grupo"
L["LOOT_METHOD_NEED_BEFORE_GREED"] = "Necessidade Antes da Ganância"

-- Threshold Labels
L["THRESHOLD_POOR_ONLY"] = "Apenas Pobre"
L["THRESHOLD_COMMON_LOWER"] = "Comum e Inferior"
L["THRESHOLD_UNCOMMON_LOWER"] = "Incomum e Inferior"
L["THRESHOLD_RARE_LOWER"] = "Raro e Inferior"
L["THRESHOLD_EPIC_LOWER"] = "Épico e Inferior"

-- Shared by both item lists: the Master Looter ignore list and the Custom Roll List
L["ITEM_LIST_ADD"] = "Adicionar Item"
L["ITEM_LIST_ADD_DESCRIPTION"] = "Insira um ID de item ou arraste um item aqui para adicioná-lo à lista."

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "Carregando... (ID: %d)"

-- Appended to the Automated Rolls description.
L["SAFETY_SKIP_NOTE"] = "Itens de missão, receitas, livros, montarias, mascotes e lendários são sempre ignorados."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] = "Receitas, livros, montarias, mascotes e lendários são sempre ignorados."

-- Version prefix in the options panel
L["VERSION_LABEL"] = "Versão"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] =
	"Aspire equipamentos com o Mestre Saqueador Automático, Rolagens Automáticas e Anúncios transparentes. Itens de missão, receitas, montarias, mascotes e lendários ficam a salvo. Não deixe o saque atrasar o seu zug!"
L["WELCOME_MESSAGE"] = "Ativar Mensagem de Boas-vindas"
L["MINIMAP_BUTTON_ENABLE"] = "Ativar Botão do Minimapa"

L["OPTIONS_COMMANDS_HEADER"] = "/Comandos"
L["OPTIONS_COMMAND"] = "/gl"
L["OPTIONS_COMMAND_ALTERNATE"] = "/gogoloot"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre a interface de opções deste add-on."

L["SPEEDY_LOOT_HEADER"] = "Saque Rápido"
L["SPEEDY_LOOT_DESCRIPTION"] = "Oculta a janela de saque para saquear quase instantaneamente."
L["SPEEDY_LOOT_ENABLE"] = "Ativar Saque Rápido"

L["FEEDBACK_SUPPORT"] = "Feedback e Suporte"

-- CurseForge / GitHub / Discord / Wago are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "Configurações de Saque Atuais"
L["MASTER_LOOTER_LOOT_METHOD"] = "Método de Saque"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "Limite de Saque"
--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them — including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "Estas configurações são controladas por %s."

L["MASTER_LOOTER_AUTO_DESCRIPTION"] = "Distribui o saque aos jogadores designados enquanto você é o Mestre Saqueador."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "Ativar Mestre Saqueador Automático"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "Também Fora de Instâncias"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] =
	"Cuidado: Como o saque de chefes mundiais não é trocável, isso não é aconselhável!"
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "Incluir Itens de Missão"
L["MASTER_LOOTER_AUTO_QUEST_ITEMS_DESCRIPTION"] =
	"Também distribui itens de missão, para impulsionar um personagem que você mesmo joga. Só podem ser distribuídos os itens de missão que caem como um único item para o grupo. O que cada jogador em missão saqueia por conta própria, como a cabeça de um chefe, nunca passa pelo Mestre Saqueador."
--[[
    Both are shown whether the toggle is on or off: they are what somebody reads
    to decide whether to tick it at all. The NOTE covers what has to be true for
    the option to do anything; the CAUTION covers who it is for, and leads with
    the same word as the outside-instances one above it.
]]
L["MASTER_LOOTER_AUTO_QUEST_ITEMS_NOTE"] =
	"Como a maioria dos itens de missão é de qualidade Comum, isso só funciona com o seu limite de saque definido como Comum ou inferior. E mesmo assim, nem todos os itens de missão são elegíveis para o Mestre Saqueador."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS_CAUTION"] =
	"Cuidado: Isto é voltado para quem joga com vários personagens ao mesmo tempo, e não é recomendado em raides."

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // Configurações rápidas"
L["MASTER_LOOTER_POPUP_DESCRIPTION"] =
	"Abre uma janela para configurar o saque sempre que você se tornar Saqueador Mestre."
L["MASTER_LOOTER_POPUP_ENABLE"] = "Ativar janela do Saqueador Mestre"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "Destinos do Saque"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "Escolha quem recebe o saque distribuído pelo GogoLoot."
L["MASTER_LOOTER_DESTINATION_SELF"] = "A si mesmo"
L["MASTER_LOOTER_SEND_ALL"] = "Enviar todo o saque para"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] =
	"Envia todas as qualidades para um jogador. Ajuste as qualidades individuais abaixo para substituir."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "Escolha quem recebe itens %s."

L["MASTER_LOOTER_TIERS_INDIVIDUAL"] = "Definir Níveis de Qualidade Individualmente"
L["MASTER_LOOTER_TIERS_INDIVIDUAL_DESCRIPTION"] =
	"Mostra uma linha para cada nível de qualidade, para que níveis diferentes vão para jogadores diferentes."

--[[
    Appended to the toggle above only while the tier rows are collapsed, and only
    for this one state. Send All Loot To reads blank both when nothing is set and
    when the tiers disagree; it is honest about the first and silent about the
    second, so with the rows collapsed a per-tier setup would be invisible
    without this. A shared destination is already named in that dropdown and is
    deliberately not repeated here.
]]
L["MASTER_LOOTER_TIERS_SUMMARY_MIXED"] = "os níveis diferem"

L["MASTER_LOOTER_IGNORE_HEADER"] = "Lista de Ignorados"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"Itens listados ignoram a distribuição automática e ficam para atribuição manual."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "Restaurar Lista de Ignorados Padrão"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"Isso substituirá sua lista de ignorados do mestre saqueador pelos itens padrão de sua expansão. Continuar?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "Remover este item da lista de ignorados."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] =
	"Rola por você em itens não Vinculados ao Recolher até a qualidade escolhida, tanto em grupo quanto em raide."
L["ROLLS_ENABLE"] = "Ativar Rolagens Automáticas"
L["ROLLS_THRESHOLD_HEADER"] = "Limites"
L["ROLLS_THRESHOLD_DESCRIPTION"] =
	"Defina o limite de qualidade e a rolagem que o GogoLoot faz por você, separadamente para grupo e raide."
L["ROLLS_IN_PARTY"] = "Em grupo"
L["ROLLS_IN_RAID"] = "Em raide"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: rola automaticamente em itens desta qualidade ou inferior."
L["ROLLS_ACTION_CHOOSE"] = "%s: qual rolagem o GogoLoot faz por você, ou se deixa a rolagem com você."

L["ROLLS_CUSTOM_LIST"] = "Lista de Rolagem Personalizada"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "Dê a itens específicos sua própria ação de rolagem, substituindo o limite."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "Ativar Lista de Rolagem Personalizada"
L["ROLLS_RESTORE_DEFAULTS"] = "Restaurar Lista de Rolagem Personalizada Padrão"
L["ROLLS_RESTORE_CONFIRM"] =
	"Isso substituirá sua lista de rolagem personalizada pelos itens padrão de sua expansão. Continuar?"
L["ROLLS_CHOOSE_ACTION"] = "Escolha a ação de rolagem automática para este item."
L["ROLLS_REMOVE_DESCRIPTION"] = "Remove este item da lista de rolagem personalizada."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "Anúncios de Troca"
L["TRADE_DESCRIPTION"] = "Publica um resumo de cada troca concluída: itens, encantamentos e ouro."
L["TRADE_ENABLE"] = "Ativar Anúncios de Troca"
L["TRADE_CONDITION"] = "Quando"
L["TRADE_CONDITION_ALWAYS"] = "Sempre"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "Apenas em Grupo ou Raide"
L["TRADE_CONDITION_RAID_ONLY"] = "Apenas em Raide"
L["TRADE_OUTPUT"] = "Saída da Mensagem"
L["TRADE_OUTPUT_WHISPER"] = "Sussurro"
L["TRADE_OUTPUT_GROUP"] = "Chat do Grupo"
L["TRADE_EXAMPLE"] = "Exemplo: {rt4} GogoLoot // Deu [Item X] x2, [Item Y] para Fathom."
L["TRADE_TOOLTIP_DESCRIPTION"] = "Posta um resumo no chat quando esta troca for concluída."
L["TRADE_TOOLTIP_OUTPUT"] = "Saída Atual"
L["TRADE_CHECKBOX_LABEL"] = "Anunciar"

-- Master Looter Announcements
--[[
    Deliberately short. The two clauses this used to carry are both said better
    elsewhere on the panel: the quality threshold is a control the reader can
    see, and ANNOUNCE_MANUAL_NOTE says the manual half in the one place it
    answers a question the threshold has just raised.
]]
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "Posta a atividade do mestre saqueador no chat do grupo."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "Ativar anúncios de destino do saque"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] = "Exemplo: {rt4} GogoLoot // Aevala receberá todos os itens Épicos."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "Ativar Anúncios de Saque Automático"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "Limite de Anúncio Automático"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Exemplo: {rt4} GogoLoot // Deu [Item X] para Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] =
	"Nota: Todo item distribuído manualmente é sempre anunciado, independentemente da qualidade."
