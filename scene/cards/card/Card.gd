extends Node2D
class_name card
var card_info={

}

var damage_source :String= ''
var level :int= 0
signal shoot
func _ready() -> void:
	name = card_info.card_name
	damage_source = card_info.caed_name
	for rou in card_info.routine:
		add_routine(rou)
	SignalBus.upgrade_card.connect(upgrade_card)
	SignalBus.del_card.connect(destroy)
	SignalBus.use_card.connect(on_use_card)

func on_try_use_card(card_name):
	if card_name != card_info.card_name:
		return


func on_use_card(card_name):
	if card_name != card_info.card_name:
		return
	emit_signal("shoot")
	SignalBus.use_card.emit(card_info.card_name)
	#get buff

func add_routine(routine_name):
	var routinepre = PresetManager.getpre('routine').instantiate()
	routinepre.position = Vector2(0,0)
	routinepre.routine_info = table.routine[routine_name]
	routinepre.damage_source = damage_source
	routinepre.set_upgrade(level)
	add_child(routinepre)


func upgrade_card(card_name):
	if card_info.card_name != card_name:
		return

	level += 1
	if(level == player_var.card_level_max):
		SignalBus.upgrade_max.emit(card_name)

func destroy(card_name):
	if card_info.card_name != card_name:
		return
	for child in get_children():
		if child.has_method('destroy'):
			child.destroy()
	queue_free()
