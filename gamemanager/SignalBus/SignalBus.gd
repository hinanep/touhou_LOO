extends Node
#skill
#尝试在player上添加技能，选择、捡起、升级技能时发出，
signal try_add_skill(id)
#判定满足加技能条件后发出
signal add_skill(skill_info)
#尝试删除技能时发出 ：ban
signal del_skill(id)
#满足升级组升级条件时发出
signal upgrade_group(id)
signal upgrade_skill(id)
#尝试ban技能时发出
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
signal player_add_buff(buff_id,buff_source)
signal spellcard_cast


func _ready() -> void:
	var signal_dic = get_signal_list()

	for sig in signal_dic:
		connect(sig.name,_on_signal_emit.bind(sig.name))


func _on_signal_emit(message,names) -> void:

	print('------')
	print('signal emitted:')
	print(names)
	print('------')
	print('message:')
	print(message)
	print('------')
	#print(n)
