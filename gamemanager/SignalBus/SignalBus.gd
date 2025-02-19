extends Node
#skill
signal try_add_skill(id)
signal add_skill(skill_info)
signal del_skill(id)
signal upgrade_skill(id)
signal ban_skill(id)

signal try_add_card(id)
signal add_card(card_info)
signal del_card(id)
signal upgrade_card(id)
signal ban_card(id)


signal use_card(id)
signal true_use_card(id)
signal card_select_next()
signal card_select_before()

signal upgrade_max(anyname)

signal player_hurt
signal player_invincible(seconds)
signal spellcard_cast


#func _ready() -> void:
	#print('logs')
	#player_hurt.connect(_on_player_hurt)
#func _on_player_hurt(n) -> void:
	#print('logs')
	#print(n)
