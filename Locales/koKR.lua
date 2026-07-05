local L = LibStub("AceLocale-3.0"):NewLocale("GogoLoot", "koKR")
if not L then return end

--[[
    Source locale: every other locale falls back to these strings. Translate
    the values only. Never change the L["KEY"] names, the %s / %d placeholders,
    or the {rt4} raid marker — code and other locales rely on them.
]]

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "버전 %s. 설정(이 메시지를 비활성화하는 옵션 포함)은 설정 > 애드온 > GogoLoot에서 찾을 수 있습니다. 애드온이 마음에 드시나요? 친구들에게 알려주세요! (="
L["MESSAGE_AUTO_LOOT_ENABLED"] = "GogoLoot가 정상적으로 작동하려면 자동 획득이 필요합니다. 자동 획득이 활성화되었습니다."
L["MESSAGE_NOT_MASTER_LOOTER"] = "현재 전리품 담당자가 아닙니다."

--------------------------------------------------------------------------------
-- Chat Announcement Templates
--------------------------------------------------------------------------------

L["MESSAGE_LOOT_ANNOUNCE"] = "%s을(를) %s에게 주었습니다."
L["MESSAGE_DESTINATION_SET"] = "%s님이 모든 %s 아이템을 받습니다."
L["MESSAGE_DESTINATION_LEFT"] = "%s님이 파티를 떠났습니다. 이제 %s님이 모든 %s 아이템을 받습니다."

L["MESSAGE_TRADE_GAVE_RECEIVED"] = "%s을(를) %s에게 주고 %s을(를) 받았습니다."
L["MESSAGE_TRADE_GAVE"] = "%s을(를) %s에게 주었습니다."
L["MESSAGE_TRADE_RECEIVED"] = "%s에게서 %s을(를) 받았습니다."

--------------------------------------------------------------------------------
-- Master Loot Distribution Errors
--------------------------------------------------------------------------------

L["ERROR_BAG_FULL"] = "아이템을 받을 플레이어의 가방에 여유 공간이 없습니다."
L["ERROR_MAX_COUNT"] = "선택한 플레이어는 이미 해당 아이템을 너무 많이 가지고 있습니다."
L["ERROR_OUT_OF_RANGE"] = "선택한 플레이어가 시야에 없습니다."
L["ERROR_NOT_IN_GROUP"] = "선택한 플레이어가 더 이상 파티나 공격대에 없습니다."

--------------------------------------------------------------------------------
-- Options Tab Names
--------------------------------------------------------------------------------

L["TAB_MASTER_LOOTER"] = "전리품 담당자"
L["TAB_AUTOMATED_ROLLS"] = "자동 주사위"
L["TAB_ANNOUNCEMENTS"] = "알림"

--------------------------------------------------------------------------------
-- Minimap Button
--------------------------------------------------------------------------------

-- GogoLoot is a proper noun; keep it untranslated.
L["ADDON_TITLE"] = "GogoLoot"
L["STATUS_ENABLED"] = "Enabled"
L["STATUS_DISABLED"] = "Disabled"

L["MINIMAP_AUTO_GREED"] = "자동 차상위"
L["MINIMAP_AUTO_GREED_DESCRIPTION"] = "선택한 품질 임계값 이하의 대상 아이템에 대해 자동으로 차상위를 굴립니다. 이 기능이 꺼져 있으면 사용자 지정 주사위 목록을 포함하여 어떤 주사위도 자동으로 굴리지 않습니다."
L["MINIMAP_SPEEDY_LOOT"] = "빠른 획득"
L["MINIMAP_SPEEDY_LOOT_DESCRIPTION"] = "전리품 창을 표시하지 않고 즉시 전리품을 획득합니다."

L["MINIMAP_LEFT_CLICK"] = "좌클릭"
L["MINIMAP_RIGHT_CLICK"] = "우클릭"
L["MINIMAP_TOGGLE"] = "전환"
L["MINIMAP_OPTIONS"] = "GogoLoot Options"
L["MINIMAP_OPTIONS_KEYBIND"] = "Shift + Middle-Click"

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
L["ROLL_MANUAL"] = "수동 주사위"
L["ROLL_GREED"] = "차상위"
L["ROLL_NEED"] = "입찰"
L["ROLL_PASS"] = "포기"

-- Loot Method Labels
L["LOOT_METHOD_FREE_FOR_ALL"] = "자유 획득"
L["LOOT_METHOD_ROUND_ROBIN"] = "차례대로 획득"
L["LOOT_METHOD_MASTER"] = "전리품 담당자"
L["LOOT_METHOD_GROUP"] = "주사위 굴림"
L["LOOT_METHOD_NEED_BEFORE_GREED"] = "주사위 굴림 (착용자 우선)"

-- Threshold Labels
L["THRESHOLD_POOR_ONLY"] = "하급만"
L["THRESHOLD_COMMON_LOWER"] = "일반 및 그 이하"
L["THRESHOLD_UNCOMMON_LOWER"] = "고급 및 그 이하"
L["THRESHOLD_RARE_LOWER"] = "희귀 및 그 이하"
L["THRESHOLD_EPIC_LOWER"] = "영웅 및 그 이하"

-- Placeholder shown in both item lists until the client caches an item's info
L["ITEM_LOADING"] = "불러오는 중... (ID: %d)"

-- Version prefix in the options panel and minimap tooltip
L["VERSION_LABEL"] = "버전"

--------------------------------------------------------------------------------
-- Options: General
--------------------------------------------------------------------------------

L["GENERAL_DESCRIPTION"] = "자동 전리품 담당자로 장비를 쓸어 담고, 획귀가 아닌 전리품에 대해 입찰 또는 차상위를 자동으로 굴리며, 모든 거래를 채팅창에 투명하게 알리세요. 퀘스트 아이템, 도안, 탈것, 애완동물, 전설 아이템은 항상 안전합니다. 전리품 때문에 멈추지 마세요 — 주그 주그!"
L["WELCOME_MESSAGE"] = "환영 메시지 활성화"
L["MINIMAP_BUTTON_ENABLE"] = "Enable Minimap Button"

L["COMMANDS"] = "/명령어"
L["COMMANDS_DESCRIPTION"] = "GogoLoot 옵션 인터페이스를 엽니다."

L["SPEEDY_LOOT_HEADER"] = "빠른 획득"
L["SPEEDY_LOOT_DESCRIPTION"] = "전리품 창을 표시하지 않고 즉시 전리품을 획득하여 시간을 절약합니다."
L["SPEEDY_LOOT_ENABLE"] = "빠른 획득 활성화"

L["FEEDBACK_SUPPORT"] = "피드백 및 지원"

-- CurseForge / GitHub / Discord are proper nouns — do not translate.
L["CURSEFORGE"] = "CurseForge"
L["GITHUB"] = "GitHub"
L["DISCORD"] = "Discord"

--------------------------------------------------------------------------------
-- Options: Profiles
--------------------------------------------------------------------------------

L["OPTIONS_RESET_ALL_PROFILES"] = "Reset All Profiles"
L["OPTIONS_RESET_ALL_PROFILES_DESCRIPTION"] = "Reset every profile on this account back to default settings."
L["OPTIONS_RESET_ALL_PROFILES_CONFIRM"] = "This will reset ALL profiles on your account back to default settings — every character. There is no undo. Continue?"

--------------------------------------------------------------------------------
-- Options: Master Looter
--------------------------------------------------------------------------------

L["MASTER_LOOTER_CURRENT_LOOT_DESCRIPTION"] = "Your group's current loot method and loot threshold."
L["MASTER_LOOTER_LOOT_TYPE"] = "획득 방식 (읽기 전용, 게임 메뉴에서 변경)"
L["MASTER_LOOTER_LOOT_THRESHOLD"] = "획득 일치 (읽기 전용, 게임 메뉴에서 변경)"
L["MASTER_LOOTER_SET_BY"] = "(Set by %s)"
L["MASTER_LOOTER_NOT_LEADER_WARNING"] = "Only the group leader can change the loot method and threshold."

L["MASTER_LOOTER_AUTO_HEADER"] = "자동 전리품 담당자"
L["MASTER_LOOTER_AUTO_DESCRIPTION"] = "당신이 전리품 담당자일 때 지정된 플레이어에게 전리품을 자동으로 분배합니다. 퀘스트 아이템, 책, 도안, 탈것, 애완동물, 전설은 항상 건너뛰며 표준 전리품 창에 나타납니다."
L["MASTER_LOOTER_AUTO_ENABLE"] = "인스턴스에서 자동 전리품 담당자 활성화"
L["MASTER_LOOTER_AUTO_OUTSIDE"] = "인스턴스 외부에서 자동 전리품 담당자 활성화"
L["MASTER_LOOTER_AUTO_OUTSIDE_CAUTION"] = "주의: 야외 우두머리 전리품은 거래할 수 없으므로 권장하지 않습니다!"

L["MASTER_LOOTER_DESTINATION_HEADER"] = "전리품 대상"
L["MASTER_LOOTER_DESTINATION_DESCRIPTION"] = "각 품질 등급의 아이템을 받을 파티원을 할당하세요."
L["MASTER_LOOTER_DESTINATION_SELF"] = "자신"
L["MASTER_LOOTER_DESTINATION_CHOOSE"] = "%s 아이템을 받을 사람을 선택하세요."

L["MASTER_LOOTER_IGNORE_HEADER"] = "무시 목록"
L["MASTER_LOOTER_IGNORE_DESCRIPTION"] = "이 목록의 아이템은 자동으로 분배되지 않으며 수동 할당을 위해 표준 전리품 창에 나타납니다."
L["MASTER_LOOTER_IGNORE_RESTORE"] = "기본 무시 목록 복원"
L["MASTER_LOOTER_IGNORE_RESTORE_CONFIRM"] = "전리품 담당자 무시 목록을 현재 확장팩의 기본 아이템으로 바꿉니다. 계속하시겠습니까?"
L["MASTER_LOOTER_IGNORE_ADD_DESCRIPTION"] = "무시 목록에 추가하려면 아이템 ID를 입력하거나 아이템 링크를 붙여넣으세요."
L["MASTER_LOOTER_IGNORE_ADD"] = "아이템 추가"
L["MASTER_LOOTER_IGNORE_REMOVE"] = "제거"
L["MASTER_LOOTER_IGNORE_REMOVE_DESCRIPTION"] = "무시 목록에서 이 아이템을 제거합니다."

--------------------------------------------------------------------------------
-- Options: Automated Rolls
--------------------------------------------------------------------------------

L["ROLLS_DESCRIPTION"] = "선택한 품질 이하의 획득 시 귀속이 아닌 아이템에 대해 자동으로 차상위를 굴립니다. 퀘스트 아이템, 책, 도안, 탈것, 애완동물, 전설 아이템은 항상 건너뜁니다. 획득 시 귀속(획귀) 아이템은 임계값에 의해 자동으로 차상위가 굴려지지 않지만, 아래의 사용자 지정 주사위 목록을 통해 자동화할 수 있습니다. 사용자 지정 주사위 목록의 아이템은 임계값 대신 설정된 작업(입찰, 차상위, 포기)을 따릅니다. 자동 주사위가 꺼져 있으면 사용자 지정 주사위 목록을 포함하여 어떤 주사위도 자동으로 굴리지 않습니다."
L["ROLLS_ENABLE"] = "자동 주사위 활성화"
L["ROLLS_THRESHOLD"] = "자동 차상위 임계값"

L["ROLLS_CUSTOM_LIST"] = "사용자 지정 주사위 목록"
L["ROLLS_CUSTOM_LIST_DESCRIPTION"] = "이 목록의 아이템은 임계값을 무시하는 고유한 주사위 규칙을 갖습니다. 스컬지석이나 악마의 룬 같은 획득 시 귀속 아이템을 자동화하는 유일한 방법입니다. 각 아이템을 수동 주사위, 차상위, 입찰 또는 포기로 설정하세요. 이 목록은 자동 주사위가 활성화되어 있는 동안에만 적용됩니다. 퀘스트 아이템, 책, 도안, 탈것, 애완동물, 전설은 설정과 관계없이 항상 건너뜁니다."
L["ROLLS_CUSTOM_LIST_ENABLE"] = "사용자 지정 주사위 목록 활성화"
L["ROLLS_RESTORE_DEFAULTS"] = "기본 사용자 지정 주사위 목록 복원"
L["ROLLS_RESTORE_CONFIRM"] = "사용자 지정 주사위 목록을 현재 확장팩의 기본 아이템으로 바꿉니다. 계속하시겠습니까?"
L["ROLLS_ADD_ITEM_DESCRIPTION"] = "아이템 ID를 입력하거나 아이템을 여기로 드래그하여 목록에 추가하세요."
L["ROLLS_ADD_ITEM"] = "아이템 추가"
L["ROLLS_CHOOSE_ACTION"] = "Choose the automatic roll action for this item."
L["ROLLS_REMOVE"] = "제거"
L["ROLLS_REMOVE_DESCRIPTION"] = "사용자 지정 주사위 목록에서 이 아이템을 제거합니다."

--------------------------------------------------------------------------------
-- Options: Announcements
--------------------------------------------------------------------------------

-- Trade Announcements
L["TRADE_HEADER"] = "거래 알림"
L["TRADE_DESCRIPTION"] = "거래된 아이템, 마법부여, 골드를 포함하여 완료된 거래 요약을 채팅에 자동으로 게시합니다."
L["TRADE_ENABLE"] = "거래 알림 활성화"
L["TRADE_CONDITION"] = "조건"
L["TRADE_CONDITION_ALWAYS"] = "항상"
L["TRADE_CONDITION_PARTY_OR_RAID"] = "파티 또는 공격대일 때만"
L["TRADE_CONDITION_RAID_ONLY"] = "공격대일 때만"
L["TRADE_OUTPUT"] = "메시지 출력"
L["TRADE_OUTPUT_WHISPER"] = "귓속말"
L["TRADE_OUTPUT_GROUP"] = "파티 대화"
L["TRADE_EXAMPLE"] = "예시: {rt4} [아이템 X] x2, [아이템 Y]을(를) Fathom에게 주었습니다. // GogoLoot"
L["TRADE_TOOLTIP_DESCRIPTION"] = "이 거래가 완료되면 채팅에 요약을 게시합니다."
L["TRADE_TOOLTIP_OUTPUT"] = "현재 출력"
L["TRADE_CHECKBOX_LABEL"] = "알림"

-- Master Looter Announcements
L["MASTER_LOOTER_ANNOUNCE_DESCRIPTION"] = "투명성을 위해 전리품 담당자 활동을 파티 대화에 게시합니다. 일상적인 자동 획득으로 인해 채팅창이 도배되지 않도록 수동 및 자동 분배에 대한 임계값을 별도로 구성하세요."

L["MASTER_LOOTER_ANNOUNCE_DESTINATION"] = "전리품 담당자 지정 시 메시지 활성화"
L["MASTER_LOOTER_ANNOUNCE_DESTINATION_EXAMPLE"] = "예시: {rt4} GogoLoot // Aevala님이 모든 영웅 아이템을 받습니다."

L["MASTER_LOOTER_ANNOUNCE_AUTO"] = "자동 전리품 담당자 알림 활성화"
L["MASTER_LOOTER_ANNOUNCE_AUTO_THRESHOLD"] = "자동 알림 임계값"
L["MASTER_LOOTER_ANNOUNCE_AUTO_EXAMPLE"] = "Example: {rt4} GogoLoot // Gave [Item X] to Fathom."

L["MASTER_LOOTER_ANNOUNCE_MANUAL_NOTE"] = "Note: Every item distributed manually is always announced, regardless of quality."
