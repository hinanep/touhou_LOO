extends Node2D
class_name cp
var cp_info = {}
func _ready() -> void:
	SignalBus.true_use_card.connect(on_using_card)
	SignalBus.player_hurt.connect(on_player_hurt)
	pass
func on_unlocking():
	for i in range(cp_info.giving_buff_moment.size()):
		if cp_info.giving_buff_moment[i]=='getting':
			trigger_buff(i)

func on_using_card(id):
	for i in range(cp_info.giving_buff_moment.size()):
		if cp_info.giving_buff_moment[i]=='sc':
			trigger_buff(i)
	for i in range(cp_info.creating_routine.size()):
		if cp_info.creating_routine_moment[i]=='sc':
			SignalBus.trigger_routine_by_id.emit(cp_info.creating_routine[i],null)
func trigger_buff(i):
	if cp_info.get('buff_value_factor_depend',[]).size()>i:
		SignalBus.player_add_buff.emit(cp_info.giving_buff[i],
										player_var.dep.operate_dep(cp_info.get('buff_value_factor_depend')[i],
																	cp_info.buff_value_factor[i]),
										cp_info.id)
	else:
		SignalBus.player_add_buff.emit(cp_info.giving_buff[i],

										cp_info.buff_value_factor[i],
										cp_info.id)
func on_player_hurt():
	for i in range(cp_info.creating_routine.size()):
		if cp_info.creating_routine_moment[i]=='hurt':
			SignalBus.trigger_routine_by_id.emit(cp_info.creating_routine[i],null)
