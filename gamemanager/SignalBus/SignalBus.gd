extends Node
#skill
signal try_add_skill(skill_name)
signal add_skill(skill_info)
signal del_skill(skill_name)
signal upgrade_skill(skill_name)
signal ban_skill(skill_name)

signal try_add_card(card_name)
signal add_card(card_info)
signal del_card(card_name)
signal upgrade_card(card_name)
signal ban_card(card_name)
signal try_use_card()
signal use_card(card_name)


signal upgrade_max(anyname)

signal player_hurt
signal spellcard_cast
