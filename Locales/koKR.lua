local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "koKR")
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
	"버전 %s. 설정(이 메시지를 비활성화하는 옵션 포함)은 설정 > 애드온 > GogoLoot에서 찾을 수 있습니다. 애드온이 마음에 드시나요? 친구들에게 알려주세요! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "안전을 위해 전투 중에는 설정 창을 열 수 없습니다."
L["MESSAGE_AUTO_LOOT_ENABLED"] =
	"자동 획득이 활성화되었습니다. 빠른 획득이 작동하려면 필요합니다."
L["MESSAGE_NOT_MASTER_LOOTER"] = "현재 전리품 담당자가 아닙니다."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

-- Shared by master loot hand-outs and trade summaries. Arguments: items, then recipient.
L["MESSAGE_GAVE"] = "%s을(를) %s에게 주었습니다."
L["MESSAGE_DESTINATION_SET"] = "%s님이 모든 %s 아이템을 받습니다."
L["MESSAGE_DESTINATION_SET_ALL"] = "%s님이 파티의 모든 전리품을 보관합니다."
L["MESSAGE_DESTINATION_LEFT"] =
	"%s님이 파티를 떠났습니다. 이제 %s님이 모든 %s 아이템을 받습니다."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "%s을(를) %s에게 주고 %s을(를) 받았습니다."
L["MESSAGE_TRADE_RECEIVED"] = "%s에게서 %s을(를) 받았습니다."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "%s님의 가방이 가득 찼습니다: %s"
L["ERROR_MAX_COUNT"] = "%s님은 이미 너무 많이 가지고 있습니다: %s"
L["ERROR_OUT_OF_RANGE"] = "%s님이 너무 멀리 있습니다: %s"
L["ERROR_NOT_IN_GROUP"] = "%s님이 더 이상 파티나 공격대에 없습니다: %s"
L["ERROR_DISTRIBUTION_FAILED"] = "%s님에게 줄 수 없습니다: %s"

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "전리품 담당자"
L["TAB_AUTOMATED_ROLLS"] = "자동 주사위"
L["TAB_ANNOUNCEMENTS"] = "알림"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

L["STATUS_ENABLED"] = "활성화됨"
L["STATUS_DISABLED"] = "비활성화됨"

--[[
    The tooltip titles each feature with its options-panel name rather than
    keeping its own copy: Automated Rolls uses TAB_AUTOMATED_ROLLS, Speedy Loot
    uses SPEEDY_LOOT_HEADER and SPEEDY_LOOT_DESCRIPTION. Only the roll
    description below is unique to the tooltip, where the panel's longer text
    would not fit.
]]
L["MINIMAP_AUTOMATED_ROLLS_DESCRIPTION"] =
	"선택한 품질 이하의 대상 아이템에 대해 대신 주사위를 굴립니다."

L["MINIMAP_LEFT_CLICK"] = "좌클릭"
L["MINIMAP_RIGHT_CLICK"] = "우클릭"
L["MINIMAP_TOGGLE"] = "전환"
L["MINIMAP_OPTIONS"] = "GogoLoot 설정"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + 가운데 클릭"

--------------------------------------------------------------------------------
-- Shared Labels
--------------------------------------------------------------------------------

-- Quality Labels
L["QUALITY_POOR"] = "하급"
L["QUALITY_COMMON"] = "일반"
L["QUALITY_UNCOMMON"] = "고급"
L["QUALITY_RARE"] = "희귀"
L["QUALITY_EPIC"] = "영웅"

-- Roll Action Labels
L["ROLL_MANUAL"] = "수동"
L["ROLL_GREED"] = "차상위"
L["ROLL_NEED"] = "입찰"
L["ROLL_PASS"] = "포기"

-- Loot Method Labels
L["LOOT_METHOD_FREE_FOR_ALL"] = "자유 획득"
L["LOOT_METHOD_ROUND_ROBIN"] = "차례대로 획득"
L["LOOT_METHOD_MASTER"] = "전리품 담당자"
L["LOOT_METHOD_GROUP"] = "주사위 굴림"
L["LOOT_METHOD_NEED_BEFORE_GREED"] = "전용 우선 획득"

-- Threshold Labels
L["THRESHOLD_POOR_ONLY"] = "하급만"
L["THRESHOLD_COMMON_LOWER"] = "일반 및 그 이하"
L["THRESHOLD_UNCOMMON_LOWER"] = "고급 및 그 이하"
L["THRESHOLD_RARE_LOWER"] = "희귀 및 그 이하"
L["THRESHOLD_EPIC_LOWER"] = "영웅 및 그 이하"

-- Shared by both item lists: the Master Looter ignore list and the Custom Roll List
L["ITEM_LIST_ADD"] = "아이템 추가"
L["ITEM_LIST_ADD_DESCRIPTION"] =
	"목록에 추가하려면 아이템 ID를 입력하거나 아이템을 여기로 끌어다 놓으세요."

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "불러오는 중... (ID: %d)"

-- Appended to the Automated Rolls description.
L["SAFETY_SKIP_NOTE"] =
	"퀘스트 아이템, 도안, 책, 탈것, 애완동물, 전설 아이템은 항상 건너뜁니다."

-- The Automated Master Looting variant: quest items are a toggle there, so they are not on this list.
L["SAFETY_SKIP_NOTE_MASTER_LOOTER"] = "도안, 책, 탈것, 애완동물, 전설 아이템은 항상 건너뜁니다."

-- Version prefix in the options panel
L["VERSION_LABEL"] = "버전"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] =
	"자동 전리품 담당자, 자동 주사위, 투명한 알림으로 장비를 쓸어 담으세요. 퀘스트 아이템, 도안, 탈것, 애완동물, 전설 아이템은 항상 안전합니다. 전리품이 여러분의 zug을 늦추지 않게 하세요!"
L["WELCOME_MESSAGE"] = "환영 메시지 활성화"
L["MINIMAP_BUTTON_ENABLE"] = "미니맵 버튼 활성화"

L["OPTIONS_COMMANDS_HEADER"] = "/명령어"
L["OPTIONS_COMMAND"] = "/gl"
L["OPTIONS_COMMAND_ALTERNATE"] = "/gogoloot"
L["OPTIONS_COMMAND_DESCRIPTION"] = "이 애드온의 설정 창을 엽니다."

L["SPEEDY_LOOT_HEADER"] = "빠른 획득"
L["SPEEDY_LOOT_DESCRIPTION"] = "전리품 창을 숨겨 거의 즉시 획득합니다."
L["SPEEDY_LOOT_ENABLE"] = "빠른 획득 활성화"

L["FEEDBACK_SUPPORT"] = "피드백 및 지원"

-- CurseForge / GitHub / Discord / Wago are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"
L["WAGO"] = "Wago"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_HEADER"] = "현재 전리품 설정"
L["MASTER_LOOTER_LOOT_METHOD"] = "획득 방식"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "획득 기준"
--[[
    Shown above the two dropdowns whenever the player is in a group, naming
    whoever controls them — including the player themselves. Argument: the group
    leader. Hidden only while solo, where there is no leader to name.
]]
L["MASTER_LOOTER_CURRENT_LOOT_CONTROLLED_BY"] = "이 설정은 %s님이 관리합니다."

L["MASTER_LOOTER_AUTO_DESCRIPTION"] =
	"전리품 담당자일 때 지정한 플레이어에게 전리품을 분배합니다."
--[[
    AUTO_ENABLE is the master switch for the whole feature, not the instance half
    of a pair: with it off nothing distributes anywhere. AUTO_OUTSIDE and
    AUTO_QUEST_ITEMS are its sub-options and read as fragments under it.
]]
L["MASTER_LOOTER_AUTO_ENABLE"] = "자동 전리품 담당자 활성화"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "인스턴스 외부에서도"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] =
	"주의: 야외 우두머리 전리품은 거래할 수 없으므로 권장하지 않습니다!"
L["MASTER_LOOTER_AUTO_QUEST_ITEMS"] = "퀘스트 아이템 포함"
L["MASTER_LOOTER_AUTO_QUEST_ITEMS_DESCRIPTION"] =
	"본인이 직접 조종하는 캐릭터를 육성할 때를 위해 퀘스트 아이템도 분배합니다. 파티에 하나만 떨어지는 퀘스트 아이템만 분배할 수 있습니다. 퀘스트 중인 모든 플레이어가 각자 획득하는 우두머리의 머리 같은 아이템은 전리품 담당자를 거치지 않습니다."
--[[
    Both are shown whether the toggle is on or off: they are what somebody reads
    to decide whether to tick it at all. The NOTE covers what has to be true for
    the option to do anything; the CAUTION covers who it is for, and leads with
    the same word as the outside-instances one above it.
]]
L["MASTER_LOOTER_AUTO_QUEST_ITEMS_NOTE"] =
	"대부분의 퀘스트 아이템은 일반 품질이므로, 획득 기준을 일반 이하로 설정해야만 작동합니다. 그마저도 모든 퀘스트 아이템을 분배할 수 있는 것은 아닙니다."
L["MASTER_LOOTER_AUTO_QUEST_ITEMS_CAUTION"] =
	"주의: 멀티박싱을 즐기는 플레이어를 위한 기능이며, 공격대에서는 권장하지 않습니다."

L["MASTER_LOOTER_POPUP_TITLE"] = "GogoLoot // 빠른 설정"
L["MASTER_LOOTER_POPUP_DESCRIPTION"] = "분배자가 될 때마다 전리품을 설정할 수 있는 창을 엽니다."
L["MASTER_LOOTER_POPUP_ENABLE"] = "분배자 창 활성화"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "전리품 대상"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "GogoLoot이 분배하는 전리품을 받을 대상을 선택하세요."
L["MASTER_LOOTER_DESTINATION_SELF"] = "자신"
L["MASTER_LOOTER_SEND_ALL"] = "모든 전리품 받을 대상"
L["MASTER_LOOTER_SEND_ALL_DESCRIPTION"] =
	"모든 품질 등급을 한 명에게 보냅니다. 아래에서 등급별로 따로 지정할 수 있습니다."
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "%s 아이템을 받을 사람을 선택하세요."

L["MASTER_LOOTER_TIERS_INDIVIDUAL"] = "품질 등급을 개별 설정"
L["MASTER_LOOTER_TIERS_INDIVIDUAL_DESCRIPTION"] =
	"품질 등급마다 행을 표시하여 등급별로 다른 플레이어에게 보낼 수 있습니다."

--[[
    Appended to the toggle above only while the tier rows are collapsed, and only
    for this one state. Send All Loot To reads blank both when nothing is set and
    when the tiers disagree; it is honest about the first and silent about the
    second, so with the rows collapsed a per-tier setup would be invisible
    without this. A shared destination is already named in that dropdown and is
    deliberately not repeated here.
]]
L["MASTER_LOOTER_TIERS_SUMMARY_MIXED"] = "등급별로 다름"

L["MASTER_LOOTER_IGNORE_HEADER"] = "무시 목록"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] =
	"목록의 아이템은 자동 분배를 건너뛰고 수동 분배로 남습니다."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "기본 무시 목록 복원"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] =
	"전리품 담당자 무시 목록을 현재 확장팩의 기본 아이템으로 바꿉니다. 계속하시겠습니까?"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "무시 목록에서 이 아이템을 제거합니다."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] =
	"파티와 공격대 모두에서 선택한 품질 이하의 획득 시 귀속이 아닌 아이템에 대해 대신 주사위를 굴립니다."
L["ROLLS_ENABLE"] = "자동 주사위 활성화"
L["ROLLS_THRESHOLD_HEADER"] = "임계값"
L["ROLLS_THRESHOLD_DESCRIPTION"] =
	"파티와 공격대 각각에 대해 품질 상한과 GogoLoot이 대신 굴릴 주사위를 설정합니다."
L["ROLLS_IN_PARTY"] = "파티에서"
L["ROLLS_IN_RAID"] = "공격대에서"
L["ROLLS_THRESHOLD_CHOOSE"] = "%s: 이 품질 이하의 아이템에 자동으로 주사위를 굴립니다."
L["ROLLS_ACTION_CHOOSE"] =
	"%s: GogoLoot이 대신 굴릴 주사위, 또는 직접 굴리도록 남겨 둘지 선택합니다."

L["ROLLS_CUSTOM_LIST"] = "사용자 지정 주사위 목록"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] =
	"특정 아이템에 임계값을 무시하는 고유한 주사위 동작을 지정합니다."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "사용자 지정 주사위 목록 활성화"
L["ROLLS_RESTORE_DEFAULTS"] = "기본 사용자 지정 주사위 목록 복원"
L["ROLLS_RESTORE_CONFIRM"] =
	"사용자 지정 주사위 목록을 현재 확장팩의 기본 아이템으로 바꿉니다. 계속하시겠습니까?"
L["ROLLS_CHOOSE_ACTION"] = "이 아이템에 대한 자동 주사위 동작을 선택하세요."
L["ROLLS_REMOVE_DESCRIPTION"] = "사용자 지정 주사위 목록에서 이 아이템을 제거합니다."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "거래 알림"
L["TRADE_DESCRIPTION"] = "완료된 각 거래의 요약을 게시합니다: 아이템, 마법부여, 골드."
L["TRADE_ENABLE"] = "거래 알림 활성화"
L["TRADE_CONDITION"] = "조건"
L["TRADE_CONDITION_ALWAYS"] = "항상"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "파티 또는 공격대일 때만"
L["TRADE_CONDITION_RAID_ONLY"] = "공격대일 때만"
L["TRADE_OUTPUT"] = "메시지 출력"
L["TRADE_OUTPUT_WHISPER"] = "귓속말"
L["TRADE_OUTPUT_GROUP"] = "파티 대화"
L["TRADE_EXAMPLE"] = "예시: {rt4} GogoLoot // [아이템 X] x2, [아이템 Y]을(를) Fathom에게 주었습니다."
L["TRADE_TOOLTIP_DESCRIPTION"] = "이 거래가 완료되면 채팅에 요약을 게시합니다."
L["TRADE_TOOLTIP_OUTPUT"] = "현재 출력"
L["TRADE_CHECKBOX_LABEL"] = "알림"

-- Master Looter Announcements
--[[
    Deliberately short. The two clauses this used to carry are both said better
    elsewhere on the panel: the quality threshold is a control the reader can
    see, and ANNOUNCE_MANUAL_NOTE says the manual half in the one place it
    answers a question the threshold has just raised.
]]
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "전리품 담당자 활동을 파티 대화에 게시합니다."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "전리품 분배 대상 알림 활성화"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] =
	"예시: {rt4} GogoLoot // Aevala님이 모든 영웅 아이템을 받습니다."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "자동 전리품 담당자 알림 활성화"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "자동 알림 임계값"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] =
	"예시: {rt4} GogoLoot // [아이템 X]을(를) Fathom님에게 주었습니다."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] =
	"참고: 수동으로 분배한 아이템은 품질과 관계없이 항상 알립니다."
