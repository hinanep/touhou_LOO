extends Node
#skill
#尝试在player上添加技能，选择、捡起、升级技能时发出，
signal try_add_skill(id)
#判定满足加技能条件后发出
signal add_skill(skill_info)
#尝试删除技能时发出 ：ban
signal del_skill(id)
#尝试ban技能时发出
signal ban_skill(id)
signal trigger_routine_by_id(routine_id,
							force_world_position,
							input_position,
							input_rotation,
							parent_node)

signal try_add_card(id)
signal add_card(card_info)
signal del_card(id)
signal ban_card(id)


signal use_card(id,cost_rate)
signal true_use_card(id)
signal card_select_next(bias)

signal plate_use_card
#尝试在player上添加技能，选择、捡起、升级技能时发出，
signal try_add_passive(id)
#判定满足加技能条件后发出
signal add_passive(psv_info)
#尝试删除技能时发出 ：ban
signal del_passive(id)
#尝试ban技能时发出
signal ban_passive(id)


signal player_hurt
signal player_invincible(seconds)
signal player_add_buff(buff_id,buff_intensity,buff_source)
signal player_del_buff_by_source(source)

signal spellcard_cast
#满足升级组升级条件时发出
signal upgrade_group(group)
signal upgrade_max(anyname)
signal cp_active(cp_info)
signal cp_del(cp_id)
signal atk_boost(attack_info)
signal sum_boost(sum_info)

signal drop(id,global_position,value)
signal fly_to_player(exp_buff,mana_buff,score_buff ,point_ratio_buff)
var is_log = true
func _ready() -> void:
	var signal_dic = get_signal_list()

	for sig in signal_dic:
		if sig.name =='trigger_routine_by_id':
			continue
		connect(sig.name,_on_signal_emit.bind('[color=green][b]SIGNAL EMITTED:[/b][/color]'+sig.name))


func _on_signal_emit(message1='',message2='',message3='',message4='',message5='',message6='') -> void:
	if(is_log):
		print_rich("[color=yellow][b]------[/b][/color]")
		#var n = {}

		print_rich(message2)
		print_rich(message1)
		print_rich(message3)
		print_rich(message4)
		print_rich(message5)
		print_rich(message6)
		print_rich("[color=yellow][b]------[/b][/color]")
