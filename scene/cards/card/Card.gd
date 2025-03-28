extends Node2D
class_name card
var card_info={

}

var damage_source :String= ''
var level :int= 0
signal shoot
var max_level
func _ready() -> void:
	name = card_info.id
	damage_source = card_info.id
	if card_info.has('routines'):
		for rou in card_info.routines:
			var r = add_routine(rou)
			shoot.connect(r.attacks)
	SignalBus.upgrade_group.connect(upgrade_card)
	SignalBus.del_card.connect(destroy)
	SignalBus.use_card.connect(on_use_card)
	if table.Upgrade.has(card_info.upgrade_group):
		max_level = table.Upgrade[card_info.upgrade_group].level

func on_use_card(id,cost_rate):
	if id != card_info.id:
		return
	if player_var.mana<card_info.mana/player_var.mana_cost*cost_rate:
		AudioManager.play_sfx('music_sfx_error')
		return

	player_var.mana-=card_info.mana/player_var.mana_cost*cost_rate
	SignalBus.player_invincible.emit(card_info.invincible_time)
	SignalBus.true_use_card.emit(card_info.id)
	if card_info.has('is_following'):
		if not card_info.is_following:
			emit_signal("shoot",true,global_position)
		else:
			emit_signal("shoot")
	if card_info.has('buff'):
		for i in card_info.buff.size():
			SignalBus.player_add_buff.emit(card_info.buff[i],card_info.buff_value_factor[i],card_info.id)
	if card_info.has('special'):
		match card_info.special:
			'dash':
				var tween = create_tween()
				tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
				tween.tween_property(player_var.player_node,'global_position',player_var.player_node.global_position + Vector2.from_angle(player_var.player_diretion_angle) * card_info.special_parameter[0],0.5)

				#player_var.player_node.global_position += Vector2.from_angle(player_var.player_diretion_angle) * card_info.special_parameter[0]
	#get buff

func add_routine(id):
	var routinepre = PresetManager.getpre('routine').instantiate()
	routinepre.position = Vector2(0,0)
	routinepre.routine_info = table.Routine[id].duplicate()
	routinepre.damage_source = damage_source

	add_child(routinepre)
	return routinepre


func upgrade_card(group):
	if card_info.upgrade_group != group:
		return

	level += 1
	if(level == max_level):
		SignalBus.upgrade_max.emit(card_info.id)

func destroy(id):
	if card_info.id != id:
		return
	for child in get_children():
		if child.has_method('destroy'):
			child.destroy()
	queue_free()
