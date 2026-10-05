local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "koKR")
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
	"버전 %s. 설정(이 메시지를 끄는 옵션 포함)은 설정 > 애드온 > GogoLoot에서 찾을 수 있습니다. 애드온이 마음에 드시나요? 친구에게도 알려 주세요! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "안전을 위해 전투 중에는 설정 창을 열 수 없습니다."
-- Argument: the game's own name for its Auto Loot setting.
L["MESSAGE_AUTO_LOOT_SETTING_ON"] = "빠른 획득과 자동 열기에 필요한 게임의 %s 설정을 켰습니다."
-- Argument: the game's own word for Master Looter.
L["MESSAGE_NOT_CURRENT_MASTER_LOOTER"] = "현재 %s 역할을 맡고 있지 않습니다."

-- Automated Opening. Argument: the number of free bag slots opening waits for.
L["MESSAGE_OPENING_PAUSED"] = "가방 빈 칸이 %d칸 이상 될 때까지 자동 열기를 일시 중지합니다."
L["MESSAGE_OPENING_RESUMED"] = "자동 열기를 다시 시작합니다."

-- Argument: the item's link.
L["MESSAGE_ITEM_WILL_AUTO_OPEN"] = "%s: 잠금이 풀리면 자동으로 열립니다."
L["MESSAGE_ITEM_IGNORED"] = "%s: 무시로 설정되어 있어 자동 열기가 건드리지 않습니다."
L["MESSAGE_ITEM_IGNORED_RAID"] =
	"%s: 공격대 또는 필드 우두머리에게서 얻은 아이템이므로, 거래하거나 판매할 수 있도록 자동 열기가 열지 않고 남겨 둡니다."
L["MESSAGE_ITEM_IGNORED_UNIQUE"] =
	"%s: 고유 아이템이 들어 있을 수 있어, 직접 열 수 있도록 자동 열기가 열지 않고 남겨 둡니다."
L["MESSAGE_ITEM_LEFT_IN_LOOT_WINDOW"] = "%s: 직접 획득할 수 있도록 전리품 창에 남겨 두었습니다."
-- The Openables List's Add Item refusing gear or a bag. Argument: the item's link, or its ID while uncached.
L["MESSAGE_ITEM_NOT_OPENABLE"] =
	"%s: 열지 않고 착용하는 아이템이므로 열기 목록에 추가할 수 없습니다."

-- Automated Rolls' Print Item in Chat. Arguments: the game's word for the roll (Need or Greed), then the item's link.
L["MESSAGE_ROLL_PRINT"] = "%s 주사위를 굴렸습니다: %s."
-- The same after a Pass. Argument: the item's link.
L["MESSAGE_ROLL_PASS_PRINT"] = "주사위 굴리기를 포기했습니다: %s."
--[[
    Hide Roll Messages' winner summary. Arguments: the winner, the item's link,
    then the winning roll as LOOT_TOASTS_ROLL_RESULT words it ("Greed 95"). The
    NO_ROLL forms are for a win whose roll wasn't seen; the YOU forms for the
    player's own win, without the winner.
]]
L["MESSAGE_ROLL_WON_PRINT"] = "%s님이 아이템을 차지했습니다: %s, %s."
L["MESSAGE_ROLL_WON_NO_ROLL_PRINT"] = "%s님이 아이템을 차지했습니다: %s."
L["MESSAGE_ROLL_YOU_WON_PRINT"] = "아이템을 차지했습니다: %s, %s."
L["MESSAGE_ROLL_YOU_WON_NO_ROLL_PRINT"] = "아이템을 차지했습니다: %s."

--[[
    A trade summary printed to the player alone (the trade Channel's Me Only):
    the Chat Announcement Templates below, printed, so each ends on its
    punctuation. Arguments as theirs: items, then the partner, then what came
    back.
]]
L["MESSAGE_GAVE_PRINT"] = "%s 전달: %s."
L["MESSAGE_TRADE_GAVE_RECEIVED_PRINT"] = "%s 전달: %s, 받음: %s."
L["MESSAGE_TRADE_RECEIVED_PRINT"] = "%s 받음: %s에게서."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "%s 전달: %s"
L["MESSAGE_DESTINATION_SET"] = "%s님이 파티의 %s 아이템을 보관합니다"
L["MESSAGE_DESTINATION_SET_ALL"] = "%s님이 파티의 모든 전리품을 보관합니다"
-- Arguments: the player who left, the master looter, then the qualities they held, joined by commas.
L["MESSAGE_DESTINATION_LEFT"] =
	"%s님이 파티를 떠났습니다. 이제 %s님이 파티의 %s 아이템을 보관합니다"
-- The same when they held every quality. Arguments: the player who left, then the master looter.
L["MESSAGE_DESTINATION_LEFT_ALL"] =
	"%s님이 파티를 떠났습니다. 이제 %s님이 파티의 모든 전리품을 보관합니다"

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "%s 전달: %s, 받음: %s"
L["MESSAGE_TRADE_RECEIVED"] = "%s 받음: %s에게서"

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "%s님의 가방이 가득 찼습니다: %s"
L["ERROR_MAX_COUNT"] = "%s님은 이미 너무 많이 가지고 있습니다: %s"
L["ERROR_OUT_OF_RANGE"] = "%s님이 너무 멀리 있습니다: %s"
L["ERROR_NOT_IN_GROUP"] = "%s님이 더 이상 파티나 공격대에 없습니다: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "%s님에게 전리품을 주지 못했습니다: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_AUTOMATED_ROLLS"] = "자동 주사위"
L["TAB_ITEM_OVERRIDES"] = "아이템별 설정"
-- A child panel of Automated Rolls: each character's rolls by the stats on the gear.
L["TAB_CHARACTER_RULES"] = "캐릭터별 규칙"
-- The panel for everything GogoLoot posts to chat.
L["TAB_ANNOUNCEMENTS"] = "공지"
-- Headers of the two sections on the Announcements panel; Trade Announcements also titles the trade window checkbox's tooltip.
L["TAB_TRADE_ANNOUNCEMENTS"] = "거래 공지"
L["TAB_MASTER_LOOTER_ANNOUNCEMENTS"] = "전리품 전담 공지"
L["TAB_LOOT_TOASTS"] = "획득 알림"
-- A child panel of Loot Toasts: which loot gets a toast, and what it says.
L["TAB_LOOT_TOAST_FILTERS"] = "필터"
-- The panel right after Loot Toasts.
L["TAB_LOOT_SOUNDS"] = "획득 소리"
L["TAB_AUTOMATED_OPENING"] = "자동 열기"
-- Header of a section on the Automated Opening panel.
L["TAB_LOCKBOXES"] = "잠긴 상자"
L["TAB_OPENABLE_ITEMS"] = "열기 목록"
L["TAB_MASTER_LOOTER"] = "전리품 전담"
-- Header of a section on the Master Looter panel.
L["TAB_LOOT_DESTINATIONS"] = "전리품 받을 사람"
L["TAB_IGNORE_LIST"] = "무시 목록"

-- A child panel's title where the Settings tree can't nest it: the parent's title, then its own.
L["TAB_NESTED_FORMAT"] = "%s: %s"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "사용"
L["STATUS_DISABLED"] = "사용 안 함"
-- Automated Opening is on but waiting for empty bag slots.
L["STATUS_PAUSED"] = "일시 중지"

--[[
    The tooltip titles each feature with its options-panel name (Automated
    Master Looting excepted, since its panel is titled Master Looter), and
    gives each a description of its own, two lines at most: the panels' longer
    text doesn't fit a tooltip.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] =
	"선택한 품질까지 대상 아이템에 대신 주사위를 굴립니다."
L["MINIMAP_AUTOMATED_OPENING_DESCRIPTION"] =
	"가방 속 조개, 상자, 동전 주머니, 자물쇠를 딴 잠긴 상자를 엽니다."
L["MINIMAP_ANNOUNCEMENTS_DESCRIPTION"] = "거래 요약과 전리품 분배 내역을 대화창에 게시합니다."
L["MINIMAP_AUTOMATED_MASTER_LOOTING_DESCRIPTION"] =
	"품질별로 지정한 플레이어에게 전리품을 분배합니다."
--[[
    The tooltip's read-back of each group context's roll, one line each under
    the description. Arguments: the game's own word for Party or Raid, the roll,
    then (all but Manual) the highest quality it rolls on.
]]
L["MINIMAP_ROLLS_SETTING"] = "%s: %s, %s"
L["MINIMAP_ROLLS_SETTING_MANUAL"] = "%s: %s"

L["MINIMAP_LEFT_CLICK"] = "왼쪽 클릭"
L["MINIMAP_RIGHT_CLICK"] = "오른쪽 클릭"
L["MINIMAP_SHIFT_LEFT_CLICK"] = "Shift + 왼쪽 클릭"
L["MINIMAP_SHIFT_RIGHT_CLICK"] = "Shift + 오른쪽 클릭"
-- The tooltip's title for the Automated Master Looting block, the feature its switch names.
L["MINIMAP_AUTOMATED_MASTER_LOOTING"] = "자동 전리품 분배"
L["MINIMAP_TOGGLE"] = "켜기/끄기"

-- Heads the list of lockboxes in the bags still waiting to be unlocked.
L["MINIMAP_LOCKED_ITEMS"] = "잠긴 아이템"
L["MINIMAP_OPTIONS"] = "GogoLoot 설정"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 가운데 클릭"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- The roll dropdowns' own choice; Need, Greed and Pass are the client's NEED, GREED and PASS.
L["ROLL_MANUAL"] = "수동"

-- The Up to Quality choice for Poor. Argument: the game's own quality name.
L["THRESHOLD_ONLY"] = "%s만"
-- Every other Up to Quality choice. Argument: the game's own quality name.
L["THRESHOLD_AND_LOWER"] = "%s 이하"

--[[
    The add box above every item list: its tooltip's title and text (the
    Openables List brings text of its own), the hint the box shows while empty,
    and its button.
]]
L["ITEM_LIST_ADD"] = "아이템 추가"
L["ITEM_LIST_ADD_DESCRIPTION"] =
	"아이템 ID를 입력하거나 아이템을 여기로 끌어다 놓으면 목록에 추가됩니다."
L["ITEM_LIST_ADD_PLACEHOLDER"] = "아이템을 끌어다 놓거나 ID 입력"
L["ITEM_LIST_ADD_BUTTON"] = "추가"

-- The filter above every item list: its placeholder, its tooltip, and the line shown when nothing matches.
L["ITEM_LIST_FILTER_PLACEHOLDER"] = "아이템 검색..."
L["ITEM_LIST_FILTER_DESCRIPTION"] =
	"이름, 아이템 ID, 설정 또는 태그에 입력한 내용이 포함된 아이템만 표시합니다."
L["ITEM_LIST_NO_MATCHES"] = "검색 조건에 맞는 아이템이 없습니다."

-- The header over what the player just added to an item list, at its top until they filter it or close the window.
L["ITEM_LIST_NEW"] = "새 항목"

-- The kind filter beside every item list's search box: its first choice (the rest are the list's headers) and its tooltip.
L["ITEM_LIST_KIND_ALL"] = "모든 종류의 아이템 표시"
L["ITEM_LIST_KIND_DESCRIPTION"] =
	"목록의 모든 아이템을 표시하거나, 한 종류의 아이템만 표시합니다."

--[[
    The Add from Bags dropdown beside every item list's add box: its resting
    text and tooltip, then what it reads, greyed out, when everything carried
    is already on the list. The Openables List brings a tooltip of its own.
]]
L["ITEM_LIST_ADD_FROM_BAGS"] = "가방에서 추가"
L["ITEM_LIST_ADD_FROM_BAGS_DESCRIPTION"] = "가지고 있는 아이템을 목록에 추가합니다."
L["ITEM_LIST_BAGS_EMPTY"] = "가방에 추가할 아이템 없음"
L["ITEM_LIST_BAGS_EMPTY_DESCRIPTION"] = "가지고 있는 모든 아이템이 이미 목록에 있습니다."

-- The button at the foot of every item list; each list's tooltip and confirmation say what it restores.
L["ITEM_LIST_RESTORE"] = "기본값 복원"

-- Placeholder shown in the item lists until the client caches an item's info.
L["ITEM_LOADING"] = "불러오는 중... (ID: %d)"

--[[
    Appended to the Automated Rolls description. Item Overrides is the one way
    a Bind on Pickup or quest item gets rolled on; nothing ever rolls on the
    rest.
]]
L["SAFETY_SKIP_NOTE"] =
	"제조법, 책, 탈것, 애완동물, 전설 아이템에는 절대 주사위를 굴리지 않으며, 획득 시 귀속 아이템과 퀘스트 아이템은 아이템별 설정에 있을 때만 굴립니다."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] =
	"제조법, 책, 탈것, 애완동물, 전설 아이템은 항상 직접 분배하도록 남겨 둡니다."

--[[
    Shown under each announcement's toggle, under Print Item in Chat and Hide
    Roll Messages, and under Enable Ignore Notifications. Argument: the
    message, as GogoLoot sends or prints it.
]]
L["OPTIONS_EXAMPLE"] = "예시: %s"

-- The muted version line at the foot of the General panel.
L["OPTIONS_VERSION"] = "버전 %s"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"빠른 획득은 시체를 눈 깜짝할 새에 비우고, 자동 주사위와 자동 전리품 분배는 누가 무엇을 가질지 정해 주며, 자동 열기는 조개와 상자를 모조리 열어젖힙니다. 획득 알림이 이 모든 것을 보여 주고, 퀘스트 아이템, 제조법, 탈것, 애완동물, 전설 아이템은 안전하게 지켜집니다. 전리품 때문에 질주를 늦추지 마세요!"
L["WELCOME_MESSAGE"] = "환영 메시지 사용"
L["WELCOME_MESSAGE_DESCRIPTION"] =
	"접속할 때마다 GogoLoot의 버전과 이 설정을 찾는 위치를 표시합니다."
L["MINIMAP_BUTTON_ENABLE"] = "미니맵 버튼 사용"
L["MINIMAP_BUTTON_CLICKS_DESCRIPTION"] =
	"미니맵에 GogoLoot 버튼을 표시합니다. 왼쪽 클릭은 자동 주사위, 오른쪽 클릭은 자동 열기, Shift + 왼쪽 클릭은 공지, Shift + 오른쪽 클릭은 자동 전리품 분배를 켜거나 끕니다."

L["OPTIONS_COMMANDS_HEADER"] = "/명령어"
L["OPTIONS_COMMAND"] = "/gogo"
L["OPTIONS_COMMAND_DESCRIPTION"] = "이 애드온의 설정 창을 엽니다."

-- The section holding every feature's switch.
L["OPTIONS_FEATURES_HEADER"] = "기능"

L["SPEEDY_LOOT_ENABLE"] = "빠른 획득 사용"
--[[
    Shift is the game's default Auto Loot key; holding it shows the loot window
    as usual. Arguments: the game's own names for its Auto Loot setting, then
    for Master Looter.
]]
L["SPEEDY_LOOT_SWITCH_DESCRIPTION"] =
	"시체를 여는 즉시 전리품 창 없이 모두 획득합니다. 전리품 창을 보려면 Shift 키를 누른 채 획득하세요. 게임의 %s 설정을 켜며, %s 역할을 맡는 동안에는 작동하지 않습니다."

L["FEEDBACK_SUPPORT"] = "피드백 및 지원"

-- CurseForge / GitHub / Discord / Wago are proper nouns; do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "파티 전리품 설정"
L["MASTER_LOOTER_LOOT_METHOD_DESCRIPTION"] =
	"파티의 전리품을 나누는 방식을 정합니다. 파티장만 변경할 수 있습니다."
L["MASTER_LOOTER_LOOT_THRESHOLD_DESCRIPTION"] =
	"획득 방식이 적용되는 가장 낮은 아이템 품질을 정합니다. 파티장만 변경할 수 있습니다."

--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them, including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "이 설정은 %s님이 관리합니다."
-- Shown in the same place while solo, where the two dropdowns are greyed out.
L["MASTER_LOOTER_SOLO_NOTE"] = "변경하려면 파티에 참여하세요. 파티장만 변경할 수 있습니다."

-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_AUTO_PANEL_DESCRIPTION"] =
	"%s 역할을 맡는 동안, 전리품 창을 여는 즉시 각 아이템을 품질별로 지정한 플레이어에게 분배합니다."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "자동 전리품 분배 사용"
L["MASTER_LOOTER_AUTO_ENABLE_DESCRIPTION"] =
	"자동 분배를 켜거나 끕니다. '인스턴스 밖에서도'를 켜지 않으면 던전과 공격대 안에서만 작동합니다."
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "인스턴스 밖에서도"
L["MASTER_LOOTER_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"필드에서도 전리품을 분배합니다. 필드 우두머리 전리품은 거래할 수 없으므로 권장하지 않습니다."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "퀘스트 아이템 포함"
L["MASTER_LOOTER_QUEST_ITEMS_DESCRIPTION"] =
	"직접 조작하는 다른 캐릭터를 육성할 때를 위해 퀘스트 아이템도 분배합니다. 획득 기준이 일반 이하일 때만, 그리고 파티 전체에 하나만 떨어지는 퀘스트 아이템에만 작동합니다. 공격대에서는 권장하지 않습니다."

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // 빠른 설정"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_POPUP_TOOLTIP"] = "%s 역할을 맡게 될 때마다 이 설정을 창으로 엽니다."
L["MASTER_LOOTER_POPUP_ENABLE"] = "전리품 전담 팝업 사용"

L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] =
	"품질별로 받을 사람을 선택하세요. 받을 사람이 없는 품질은 전리품 창에 남겨 둡니다."
L["MASTER_LOOTER_DESTINATION_SELF"] = "자신"
-- The first choice in every destination dropdown: nobody picked, so that quality waits in the loot window.
L["MASTER_LOOTER_DESTINATION_LOOT_WINDOW"] = "전리품 창"
L["MASTER_LOOTER_SEND_ALL"] = "모든 전리품 받을 사람"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] = "아래의 모든 품질을 한 플레이어에게 지정합니다."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "%s 아이템을 받을 사람을 정합니다."
-- Shown under Loot Destinations while Automated Master Looting is on and no quality has anybody picked.
L["MASTER_LOOTER_NO_DESTINATIONS_NOTE"] =
	"아직 받을 사람이 없어 모든 전리품이 전리품 창에 남아 있습니다."

L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"이 목록의 아이템은 절대 자동으로 분배하지 않습니다. 직접 분배할 수 있도록 전리품 창에 남겨 둡니다."
-- Shown on the Ignore List while Automated Master Looting is off.
L["MASTER_LOOTER_OFF_NOTE"] =
	"자동 전리품 분배가 꺼져 있는 동안에는 이 설정이 사용되지 않습니다."
L["MASTER_LOOTER_IGNORE_RESTORE_DESCRIPTION"] =
	"무시 목록을 현재 확장팩의 기본 아이템으로 바꿉니다."
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"무시 목록을 현재 확장팩의 기본 아이템으로 바꿉니다. 계속하시겠습니까?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "무시 목록에서 이 아이템을 제거합니다."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_PANEL_DESCRIPTION"] =
	"주사위 굴림 방식의 전리품에서 선택한 품질까지 %s, %s, %s 중 하나를 대신 선택합니다. 파티와 공격대를 따로 설정할 수 있습니다."
L["ROLLS_ENABLE"] = "자동 주사위 사용"
L["ROLLS_ENABLE_DESCRIPTION"] =
	"아이템별 설정과 캐릭터별 규칙을 포함해 자동 주사위를 켜거나 끕니다."
L["ROLLS_IN_PARTY"] = "파티에서"
L["ROLLS_IN_RAID"] = "공격대에서"
-- The caption of the quality row under In Party and under In Raid, shown while that roll isn't Manual.
L["ROLLS_UP_TO_QUALITY"] = "최대 품질"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: GogoLoot가 주사위를 굴리는 가장 높은 품질입니다."
L["ROLLS_ACTION_CHOOSE"] =
	"%s: GogoLoot가 선택할 주사위입니다. 수동은 직접 선택하도록 남겨 둡니다."
-- Section headers on the Automated Rolls panel.
L["ROLLS_LOOT_THRESHOLDS_HEADER"] = "획득 기준"
L["ROLLS_MESSAGES_HEADER"] = "주사위 메시지"
L["ROLLS_PRINT_ITEM"] = "대화창에 아이템 표시"
L["ROLLS_PRINT_ITEM_DESCRIPTION"] =
	"GogoLoot가 주사위를 굴린 아이템과 선택한 주사위를 대화창에 하나씩 표시합니다. GogoLoot가 주사위를 굴리면 주사위 창이 바로 닫히므로, 무엇이 나왔는지 확인할 수 있는 기록이 됩니다."
L["ROLLS_HIDE_MESSAGES"] = "주사위 메시지 숨기기"
-- Arguments: the game's own words for Need, Greed and Pass.
L["ROLLS_HIDE_MESSAGES_TOOLTIP"] =
	"주사위마다 나오는 게임의 대화창 메시지를 숨깁니다. 누가 %s, %s, %s 중 무엇을 선택했는지와 굴린 모든 숫자가 해당됩니다. 각 승자가 무엇을 받았는지는 대화창에 그대로 남습니다."
-- The dropdown beside Hide Roll Messages.
L["ROLLS_WINNER_SUMMARY_PRINT"] = "승자 요약 표시"
L["ROLLS_WINNER_SUMMARY_NONE"] = "승자 요약 표시 안 함"
L["ROLLS_WINNER_SUMMARY_DESCRIPTION"] =
	"'승자 요약 표시'는 게임 자체 메시지 대신, 승리할 때마다 승자, 아이템, 승리 주사위를 담은 한 줄을 대화창에 표시합니다. '승자 요약 표시 안 함'은 누가 이겼는지 알려 주는 게임의 메시지를 그대로 둡니다."

--[[
    Item Overrides, under Automated Rolls: items with a roll action of their
    own.
]]
L["ITEM_OVERRIDES_DESCRIPTION"] =
	"특정 아이템의 주사위를 품질 설정보다 우선하여 정합니다. GogoLoot가 획득 시 귀속 아이템이나 퀘스트 아이템에 주사위를 굴리는 유일한 방법입니다."
-- Shown on Item Overrides while Automated Rolls is off.
L["ROLLS_OFF_NOTE"] = "자동 주사위가 꺼져 있는 동안에는 이 설정이 사용되지 않습니다."
L["ITEM_OVERRIDES_ENABLE"] = "아이템별 설정 사용"
L["ITEM_OVERRIDES_ENABLE_DESCRIPTION"] =
	"아래에 정한 주사위를 사용합니다. 끄면 이 아이템들도 다른 아이템처럼 품질 설정을 따릅니다."
L["ITEM_OVERRIDES_RESTORE_DESCRIPTION"] =
	"아이템별 설정을 현재 확장팩의 기본 아이템으로 바꿉니다."
L["ITEM_OVERRIDES_RESTORE_CONFIRM"] =
	"아이템별 설정을 현재 확장팩의 기본 아이템으로 바꿉니다. 계속하시겠습니까?"
L["ITEM_OVERRIDES_ACTION_DESCRIPTION"] = "이 아이템에 자동으로 선택할 주사위를 정합니다."
L["ITEM_OVERRIDES_REMOVE_DESCRIPTION"] = "아이템별 설정에서 이 아이템을 제거합니다."
L["ITEM_OVERRIDES_REMOVE_CONFIRM"] =
	"아이템별 설정에서 이 아이템과 주사위 설정을 제거하시겠습니까?"

--[[
    Character Rules, under Automated Rolls: the stats whose gear each
    character leaves to the player. The stat names come from the game's own
    strings.
]]
-- Arguments: the game's own name for Intellect, then for the Warrior class, then Intellect again.
L["CHARACTER_RULES_PANEL_DESCRIPTION"] =
	"선택한 능력치가 붙은 장비를 캐릭터별로 직접 처리하도록 남겨 둡니다. 예를 들어 %s 능력치를 '수동'으로 설정하면 %s 캐릭터에서는 %s 장비에 주사위 창이 그대로 뜨고, 나머지는 평소처럼 주사위를 굴립니다. 아이템별 설정이 여전히 우선합니다."
--[[
    The two section captions in a character's pane, on clients without the
    game's own STAT_CATEGORY_PRIMARY_ATTRIBUTES / _SECONDARY_ATTRIBUTES labels
    (Classic Era, TBC). WoW Forever and later show the game's own words.
]]
L["CHARACTER_RULES_PRIMARY"] = "주 능력치"
L["CHARACTER_RULES_SECONDARY"] = "보조 능력치"
-- The first of the two choices in each stat's dropdown: no rule, so the rest of Automated Rolls decides.
L["CHARACTER_RULES_STANDARD"] = "기본 자동 주사위"
L["CHARACTER_RULES_ACTION_DESCRIPTION"] =
	"%s: '수동'은 이 캐릭터에서 이 능력치가 붙은 장비를 주사위 창과 함께 직접 처리하도록 남겨 둡니다. '기본 자동 주사위'는 다른 아이템처럼 주사위를 굴립니다."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

L["ANNOUNCEMENTS_DESCRIPTION"] =
	"거래 요약과 전리품 분배 내역을 대화창에 게시해, 전리품이 어디로 갔는지 모두가 알 수 있게 합니다."
L["ANNOUNCEMENTS_ENABLE"] = "공지 사용"
-- Also the tooltip of the same switch in the General panel's Features section, so it names no position on the panel.
L["ANNOUNCEMENTS_ENABLE_DESCRIPTION"] =
	"모든 공지를 켜거나 끕니다. 꺼져 있으면 GogoLoot는 직접 분배한 아이템을 포함해 파티나 거래 상대에게 아무것도 보내지 않습니다."

-- Trade Announcements
L["TRADE_DESCRIPTION"] = "완료된 거래마다 아이템, 마법부여, 골드를 요약해 게시합니다."
L["TRADE_ENABLE"] = "거래 공지 사용"
L["TRADE_ENABLE_DESCRIPTION"] =
	"거래가 완료되면 요약을 게시합니다. 거래 창의 공지 확인란과 같은 설정입니다."
L["TRADE_CONDITION_DESCRIPTION"] =
	"거래 요약을 게시할 때를 선택합니다: 항상, 파티나 공격대에 있을 때, 공격대에 있을 때."
L["TRADE_CONDITION_ALWAYS"] = "항상"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "파티 또는 공격대일 때"
L["TRADE_CONDITION_RAID_ONLY"] = "공격대일 때"
-- The caption of the dropdown that picks where summaries go, and the trade window checkbox tooltip's line naming it.
L["TRADE_CHANNEL"] = "채널"
-- Argument: the game's own word for Whisper.
L["TRADE_CHANNEL_TOOLTIP"] =
	"%s: 각 요약을 거래 상대에게 보냅니다. 파티 대화: 파티나 공격대에 게시하며, 파티에 없을 때는 귓속말로 보냅니다. 나만 보기: 내 대화창에만 표시하고 아무에게도 보내지 않습니다."
-- The Channel dropdown's choices (Whisper is the client's WHISPER), and the trade window checkbox tooltip's Channel value.
L["TRADE_OUTPUT_GROUP"] = "파티 대화"
L["TRADE_OUTPUT_SELF"] = "나만 보기"
L["TRADE_TOOLTIP_DESCRIPTION"] = "이 거래가 완료되면 대화창에 거래 요약을 게시합니다."
L["TRADE_CHECKBOX_LABEL"] = "공지"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] =
	"품질별로 누가 보관하는지와 무엇을 분배했는지 파티에 알립니다."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "받을 사람 공지 사용"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_DESCRIPTION"] =
	"받을 사람을 지정할 때마다 품질별로 누가 보관하는지 파티에 알립니다."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "자동 분배 공지 사용"
L["MASTER_LOOTER_ANNOUNCE_AUTO_DESCRIPTION"] =
	"GogoLoot가 자동으로 분배한 아이템 중 선택한 품질 이상인 것을 하나씩 공지합니다."
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD_DESCRIPTION"] =
	"이 품질 미만의 자동 분배는 공지하지 않습니다."

L["MASTER_LOOTER_ANNOUNCE_MANUAL"] = "수동 분배 공지 사용"
-- Argument: the game's own word for Master Looter.
L["MASTER_LOOTER_ANNOUNCE_MANUAL_TOOLTIP"] =
	"%s 메뉴에서 직접 분배한 아이템을 품질과 관계없이 하나씩, 자동 분배와 같은 형식으로 공지합니다. 분배에 실패하면 이 설정과 관계없이 알립니다."

--------------------------------------------------------------------------------
-- Options: Loot Toasts and Loot Sounds
--------------------------------------------------------------------------------

-- Argument: the game's own name for the General chat tab.
L["LOOT_TOASTS_PANEL_DESCRIPTION"] =
	"획득한 아이템과 돈을 몇 초 동안 화면에 표시해, 빠른 획득이 전리품 창을 숨겨도 놓치는 것이 없게 합니다. 획득 알림을 켜 두는 동안에는 게임 자체 획득 메시지를 %s 대화 탭에서 뺄 수 있습니다."
L["LOOT_TOASTS_ENABLE"] = "획득 알림 사용"
-- Also the tooltip of the same switch in the General panel's Features section.
L["LOOT_TOASTS_SWITCH_DESCRIPTION"] =
	"필터에서 선택한 전리품을 알림으로 표시합니다. 내 전리품과 파티의 전리품 모두 해당됩니다."
-- The dropdown beside Enable Loot Toasts: the game's Item Loot and Money Loot chat settings for the General tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_DISABLE"] = "기본 획득 메시지 사용 안 함"
L["LOOT_TOASTS_STANDARD_MESSAGES_ENABLE"] = "기본 획득 메시지 사용"
-- Arguments: the game's own names for its Item Loot and Money Loot chat settings, then for the General chat tab.
L["LOOT_TOASTS_STANDARD_MESSAGES_TOOLTIP"] =
	"'기본 획득 메시지 사용 안 함'을 선택하면 획득 알림이 켜져 있는 동안 %s 및 %s 설정을 %s 대화 탭에서 끄고, 획득 알림을 끄면 다시 켭니다. 그 탭의 설정에 있는 것과 같은 설정이며, 다른 탭은 각자의 설정을 유지합니다."

-- The Loot Toasts panel's two section headers.
L["LOOT_TOASTS_STACK_HEADER"] = "알림 배치"
L["LOOT_TOASTS_TEXT_HEADER"] = "글자"

--[[
    Filters: a row per item type, captioned with the game's own name for it,
    each with a Mine box and a Group box. Weapon, Armor, Trade Goods and Gem
    carry a quality dropdown beside each ticked box. Argument in each tooltip:
    the row's item type, as the client names it.
]]
-- Shown on the Filters panel while Loot Toasts is off.
L["LOOT_TOASTS_OFF_NOTE"] = "획득 알림이 꺼져 있는 동안에는 이 설정이 사용되지 않습니다."
-- The Filters panel's description.
L["LOOT_TOASTS_FILTERS_CAPTION"] =
	"내 전리품과 파티의 전리품 각각에 대해 무엇을 알림으로 표시하고 어떤 내용을 담을지 선택하세요. 파티의 전리품에는 획득한 사람의 이름이 함께 표시됩니다."
L["LOOT_TOASTS_FILTER_MINE"] = "본인"
L["LOOT_TOASTS_FILTER_GROUP"] = "파티"
L["LOOT_TOASTS_FILTER_MINE_DESCRIPTION"] = "내가 획득한 %s 아이템을 표시합니다."
L["LOOT_TOASTS_FILTER_GROUP_DESCRIPTION"] =
	"파티나 공격대의 누군가가 획득한 %s 아이템을 획득한 사람의 이름과 함께 표시합니다."
L["LOOT_TOASTS_FILTER_MINE_RARITY_DESCRIPTION"] =
	"내가 획득한 %s 아이템 중 옆에서 선택한 품질 이상인 것을 표시합니다."
L["LOOT_TOASTS_FILTER_GROUP_RARITY_DESCRIPTION"] =
	"파티나 공격대의 누군가가 획득한 %s 아이템 중 옆에서 선택한 품질 이상인 것을 획득한 사람의 이름과 함께 표시합니다."
L["LOOT_TOASTS_FILTER_MINE_QUALITY_DESCRIPTION"] =
	"내가 획득한 %s 아이템 중 알림을 표시할 가장 낮은 품질입니다."
L["LOOT_TOASTS_FILTER_GROUP_QUALITY_DESCRIPTION"] =
	"파티가 획득한 %s 아이템 중 알림을 표시할 가장 낮은 품질입니다."

-- The three Filters rows after the item types, which aren't item types themselves: their captions (Money's is the client's MONEY) and their boxes' tooltips.
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP"] = "획득 시 귀속"
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_MINE_DESCRIPTION"] =
	"종류나 품질에 관계없이, 내가 획득한 모든 획득 시 귀속 아이템을 표시합니다."
L["LOOT_TOASTS_FILTER_BIND_ON_PICKUP_GROUP_DESCRIPTION"] =
	"종류나 품질에 관계없이, 파티가 획득한 모든 획득 시 귀속 아이템을 표시합니다."
L["LOOT_TOASTS_FILTER_OPENABLES"] = "열기 대상"
L["LOOT_TOASTS_FILTER_OPENABLES_MINE_DESCRIPTION"] =
	"품질에 관계없이, 내가 획득한 상자 중 GogoLoot가 열 수 있는 것을 잠긴 상자를 포함해 표시합니다."
L["LOOT_TOASTS_FILTER_OPENABLES_GROUP_DESCRIPTION"] =
	"품질에 관계없이, 파티가 획득한 상자 중 GogoLoot가 열 수 있는 것을 잠긴 상자를 포함해 표시합니다."
L["LOOT_TOASTS_FILTER_MONEY_DESCRIPTION"] =
	"내가 획득한 돈을 알림으로 표시합니다. 게임이 다른 플레이어가 획득한 돈을 알려 주지 않으므로 '파티' 확인란은 없습니다."

-- A group member's loot on a toast. Arguments: the item with its count, then the looter's name.
L["LOOT_TOASTS_LOOTED_BY"] = "%s (%s)"

--[[
    Winning Roll: the roll an item was won with, on its toast. The roll
    reads as the game's own word for Need or Greed, then the number
    (LOOT_TOASTS_ROLL_RESULT). On the player's own toast it follows the item
    (LOOT_TOASTS_WON_ROLL); on a group member's, their name
    (LOOT_TOASTS_LOOTED_BY_ROLL: the item, the looter, the roll).
]]
L["LOOT_TOASTS_WINNING_ROLL"] = "승리 주사위"
-- Argument: an example roll, as LOOT_TOASTS_ROLL_RESULT words it ("Greed 54").
L["LOOT_TOASTS_WINNING_ROLL_MINE_TOOLTIP"] =
	"아이템을 차지할 때 이긴 주사위를 (%s)처럼 그 알림에 추가합니다."
-- Arguments: an example group member, then an example roll ("Need 87").
L["LOOT_TOASTS_WINNING_ROLL_GROUP_TOOLTIP"] =
	"파티원이 아이템을 차지할 때 이긴 주사위를 (%s, %s)처럼 그 사람의 알림에 추가합니다."
L["LOOT_TOASTS_ROLL_RESULT"] = "%s %d"
L["LOOT_TOASTS_WON_ROLL"] = "%s (%s)"
L["LOOT_TOASTS_LOOTED_BY_ROLL"] = "%s (%s, %s)"

-- The Filters row adding how many the player carries to their own loot's toasts.
L["LOOT_TOASTS_FILTER_BAG_COUNT"] = "소지 개수"
L["LOOT_TOASTS_BAG_COUNT_DESCRIPTION"] =
	"알림에 표시된 수량보다 많이 가지고 있으면, 내 전리품 알림에 지금 가진 개수를 x3 (27)처럼 추가합니다."
-- How many came, after the item on a toast. Argument: the count.
L["LOOT_TOASTS_QUANTITY"] = "x%d"
-- Bag Count, after the item and its count. Argument: how many the player carries.
L["LOOT_TOASTS_BAG_COUNT"] = "(%d)"

-- Stack
L["LOOT_TOASTS_MAX_ITEMS"] = "최대 알림 수"
L["LOOT_TOASTS_MAX_ITEMS_DESCRIPTION"] =
	"화면에 동시에 표시되는 최대 알림 수입니다. 가장 오래된 알림부터 사라집니다."
L["LOOT_TOASTS_UNLIMITED"] = "무제한"
L["LOOT_TOASTS_DURATION"] = "표시 시간(초)"
L["LOOT_TOASTS_DURATION_DESCRIPTION"] = "각 알림이 사라지기 전까지 표시되는 시간(초)입니다."
L["LOOT_TOASTS_GROWTH"] = "쌓이는 방향"
L["LOOT_TOASTS_GROWTH_DESCRIPTION"] =
	"오래된 알림이 가장 최근 알림에서 위로 밀려날지 아래로 밀려날지 정합니다."
L["LOOT_TOASTS_GROW_UP"] = "위로"
L["LOOT_TOASTS_GROW_DOWN"] = "아래로"
L["LOOT_TOASTS_ALIGN"] = "항목 정렬"
L["LOOT_TOASTS_ALIGN_DESCRIPTION"] = "알림을 이동 핸들의 어느 쪽에 맞춰 정렬할지 정합니다."
L["LOOT_TOASTS_ALIGN_LEFT"] = "왼쪽"
L["LOOT_TOASTS_ALIGN_RIGHT"] = "오른쪽"

-- Text
L["LOOT_TOASTS_FONT"] = "글꼴"
L["LOOT_TOASTS_FONT_DESCRIPTION"] = "알림에 사용할 글꼴입니다."
L["LOOT_TOASTS_FONT_DEFAULT"] = "기본값"
L["LOOT_TOASTS_FONT_SIZE"] = "글꼴 크기"
L["LOOT_TOASTS_FONT_SIZE_DESCRIPTION"] = "알림 글자 크기입니다. 아이콘도 함께 커지고 작아집니다."
L["LOOT_TOASTS_OUTLINE"] = "글꼴 외곽선"
L["LOOT_TOASTS_OUTLINE_DESCRIPTION"] =
	"알림 글자 주위에 그리는 외곽선으로, 밝은 배경에서도 글자를 읽기 쉽게 합니다."
L["LOOT_TOASTS_OUTLINE_NONE"] = "없음"
L["LOOT_TOASTS_OUTLINE_OUTLINE"] = "외곽선"
L["LOOT_TOASTS_OUTLINE_THICK"] = "굵은 외곽선"
L["LOOT_TOASTS_OUTLINE_MONOCHROME"] = "단색"
L["LOOT_TOASTS_OUTLINE_MONOCHROME_OUTLINE"] = "단색 외곽선"

-- Position
L["LOOT_TOASTS_UNLOCK"] = "위치 잠금 해제"
L["LOOT_TOASTS_LOCK"] = "위치 잠금"
L["LOOT_TOASTS_RESET"] = "위치 초기화"
L["LOOT_TOASTS_LOCK_DESCRIPTION"] = "알림을 새 위치로 끌어 옮기는 핸들을 표시하거나 숨깁니다."
L["LOOT_TOASTS_RESET_DESCRIPTION"] = "알림을 화면 중앙 위쪽의 기본 위치로 되돌립니다."

-- The drag handle: its title, the two gestures it answers to, its button, and the preview rows.
L["LOOT_TOASTS_HANDLE_TITLE"] = "GogoLoot 획득 알림"
L["LOOT_TOASTS_CLICK_DRAG"] = "클릭 후 끌어서 위치 지정"
L["LOOT_TOASTS_RIGHT_CLICK_LOCK"] = "오른쪽 클릭으로 잠금"
L["LOOT_TOASTS_DISABLE_BUTTON"] = "획득 알림 끄기"
-- The stand-in item on the sample toasts, and in every Example line.
L["LOOT_TOASTS_EXAMPLE_ITEM"] = "예시 아이템"

-- Loot Sounds
-- Argument: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PANEL_DESCRIPTION"] =
	"선택한 품질 이상의 전리품에는 알림음을 재생하고, %s에 성공해 무언가를 얻으면 가방 소리를 재생합니다."
L["LOOT_SOUNDS_ENABLE"] = "획득 소리 사용"
L["LOOT_SOUNDS_ENABLE_DESCRIPTION"] =
	"시체나 상자에서 선택한 품질 이상의 아이템을 획득하면 알림음을 재생합니다."
L["LOOT_SOUNDS_MINIMUM_QUALITY_DESCRIPTION"] = "획득 소리를 재생하는 가장 낮은 아이템 품질입니다."
L["LOOT_SOUNDS_TEST"] = "획득 소리를 재생합니다."
-- Argument in each: the game's own name for Pick Pocket.
L["LOOT_SOUNDS_PICK_POCKET_SOUND_ENABLE"] = "%s 소리 사용"
L["LOOT_SOUNDS_PICK_POCKET_SOUND_DESCRIPTION"] =
	"%s에 실제로 성공해 무언가를 얻으면 가방 소리를 재생합니다."
L["LOOT_SOUNDS_PICK_POCKET_SOUND_TEST"] = "%s 소리를 재생합니다."

--------------------------------------------------------------------------------
-- Options: Automated Opening
--------------------------------------------------------------------------------

-- Argument: the number of free bag slots opening waits for.
L["AUTOMATED_OPENING_DESCRIPTION"] =
	"가방 빈 칸이 %d칸 이상이면 가방 속 조개, 상자, 동전 주머니, 자물쇠를 딴 잠긴 상자를 대신 엽니다."
L["AUTOMATED_OPENING_ENABLE"] = "자동 열기 사용"
-- Also the tooltip of the same switch in the General panel's Features section. Argument: the game's own name for its Auto Loot setting.
L["AUTOMATED_OPENING_SWITCH_DESCRIPTION"] =
	"상자를 한 번에 하나씩 열며, 전투 중, 시전 중, 은신 중이거나 상점, 은행, 우편함, 경매장, 거래 창이 열려 있을 때는 기다립니다. 사용하는 동안 게임의 %s 설정을 켭니다."
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES"] = "인스턴스 밖에서만"
L["AUTOMATED_OPENING_ONLY_OUTSIDE_INSTANCES_DESCRIPTION"] =
	"던전, 공격대, 전장 안에서는 아무것도 열지 않습니다."
L["AUTOMATED_OPENING_ONLY_SOLO"] = "혼자일 때만"
L["AUTOMATED_OPENING_ONLY_SOLO_DESCRIPTION"] =
	"파티나 공격대에 있는 동안에는 아무것도 열지 않습니다."

-- Lockboxes
-- Arguments: the game's own name for the Rogue class, then for the Lockpicking skill.
L["LOCKBOXES_SECTION_DESCRIPTION"] =
	"잠긴 상자는 %s에게 따 달라고 해야 열 수 있습니다. 이 설정은 각 상자에 필요한 %s 숙련도를 보여 주고, 따야 할 상자가 생기면 알려 줍니다."
L["LOCKBOXES_TOOLTIPS_ENABLE"] = "잠긴 상자 툴팁 사용"
-- Argument: the game's own name for the Lockpicking skill.
L["LOCKBOXES_TOOLTIPS_SKILL_DESCRIPTION"] = "각 잠긴 상자에 필요한 %s 숙련도를 툴팁에 추가합니다."
L["LOCKBOXES_TOOLTIPS_SCOPE_DESCRIPTION"] =
	"잠긴 상자 툴팁을 도적에게만 표시할지 모든 캐릭터에게 표시할지 정합니다."
L["LOCKBOXES_NOTIFICATIONS_ENABLE"] = "잠긴 상자 알림 사용"
L["LOCKBOXES_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"잠금이 풀리면 열리게 될 잠긴 상자를 획득하면 대화창으로 알려 줍니다."
L["LOCKBOXES_NOTIFICATIONS_SCOPE_DESCRIPTION"] =
	"잠긴 상자 알림을 도적에게만 표시할지 모든 캐릭터에게 표시할지 정합니다."
L["LOCKBOXES_FOR_ROGUES"] = "도적만"
L["LOCKBOXES_FOR_ALL_CHARACTERS"] = "모든 캐릭터"

--[[
    The block a lockbox's own tooltip gains, under the game's own "Requires
    Lockpicking" line (ITEM_REQ_SKILL), followed by a skill number. Argument:
    the game's own name for the Lockpicking skill.
]]
L["LOCKBOXES_TOOLTIP_YOUR_SKILL_RANK"] = "내 %s"

-- On the Automated Opening panel, below its switch.
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE"] = "무시 알림 사용"
L["OPENABLE_ITEMS_NOTIFICATIONS_ENABLE_DESCRIPTION"] =
	"열기 목록에서 무시로 설정되어 GogoLoot가 상자를 열지 않을 때, 그 이유와 함께 대화창으로 알려 줍니다."

-- Openables List
L["OPENABLE_ITEMS_DESCRIPTION"] =
	"GogoLoot가 아는 모든 상자와 자동 열기가 각 상자를 어떻게 처리하는지 보여 줍니다. 무시로 설정한 상자는 열지 않으며, 빠른 획득도 전리품 창에 남겨 둡니다. 변경 사항은 모든 캐릭터에 적용됩니다."
-- Shown on the Openables List while Automated Opening is off.
L["OPENABLE_ITEMS_OFF_NOTE"] =
	"자동 열기가 꺼져 있는 동안에는 무시 설정만 사용됩니다. 무시로 설정한 아이템은 여전히 빠른 획득이 가져가지 않습니다."
L["OPENABLE_ITEMS_RESTORE_DESCRIPTION"] =
	"목록을 기본값으로 되돌립니다: 모든 아이템이 기본 설정으로 돌아가고, 제거한 아이템은 다시 나타나며, 추가한 아이템은 사라집니다."
L["OPENABLE_ITEMS_RESTORE_CONFIRM"] =
	"목록을 기본값으로 되돌리시겠습니까? 변경한 모든 설정과 추가하거나 제거한 모든 아이템이 원래대로 돌아갑니다."
L["OPENABLE_ITEMS_ADD_DESCRIPTION"] =
	"아이템 ID를 입력하거나 아이템을 여기로 끌어다 놓으면 열기로 설정되어 목록에 추가됩니다. 장비와 가방은 사용하면 착용되므로 추가할 수 없습니다."
L["OPENABLE_ITEMS_ADD_FROM_BAGS_DESCRIPTION"] =
	"가지고 있는 아이템을 열기로 설정해 목록에 추가합니다. 장비와 가방은 사용하면 착용되므로 목록에 나오지 않습니다."
L["OPENABLE_ITEMS_REMOVE_DESCRIPTION"] =
	"목록에서 이 아이템을 제거합니다. 이후 GogoLoot는 이 아이템을 일반 아이템으로 취급하여, 열지 않고 다른 아이템처럼 획득합니다."
L["OPENABLE_ITEMS_REMOVE_CONFIRM"] =
	"목록에서 이 아이템을 제거하시겠습니까? 다시 추가하면 되돌릴 수 있습니다."
L["OPENABLE_ITEMS_ACTION_DESCRIPTION"] = "자동 열기가 이 상자를 어떻게 처리할지 정합니다."

-- The Openables List dropdown, one per item.
L["OPENING_ACTION_OPEN"] = "열기"
L["OPENING_ACTION_IGNORE"] = "무시"

--[[
    The reason an item's default carries, shown as a short silver tag on its
    Openables List row whatever it is set to. Sell Sealed covers both a raid
    boss drop and a container that can hold Bind on Pickup loot.
]]
L["OPENING_TAG_SEALED"] = "미개봉 판매"
L["OPENING_TAG_UNIQUE"] = "고유 아이템 가능"

--[[
    Each tag explained, under the item's tooltip on the Openables List. The
    item's own tooltip is directly above, so these never name the item.
]]
-- Argument: the game's own name for the Rogue class.
L["OPENING_REASON_LOCKED_CLASS"] =
	"%s에게 따 달라고 해야 합니다. 자물쇠를 따고 나면 다른 상자처럼 열립니다."
L["OPENING_REASON_RAID"] =
	"공격대 또는 필드 우두머리가 떨어뜨립니다. 열지 않은 상자는 거래하거나 판매할 수 있으며, 내용물보다 비싸게 팔리는 경우가 많습니다."
L["OPENING_REASON_BIND_ON_PICKUP"] =
	"획득 시 귀속 아이템이 들어 있을 수 있습니다. 열지 않으면 거래하거나 판매할 수 있습니다."
L["OPENING_REASON_UNIQUE"] =
	"고유 아이템이 들어 있을 수 있습니다. 이미 가지고 있으면 열 때 오류가 발생합니다."
