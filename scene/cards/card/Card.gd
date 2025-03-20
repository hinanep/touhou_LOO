extends Node2D
class_name card
var card_info={
	"id": "sc_daiyousei",
	"type": "base",
	"routine": [
	  "rou_marisa"
	],
	"buff": [],
	"buff_value_factor": [],
	"special": "none",
	"special_parameter": [],
	"mana": 500.0,
	"invincible_time": 0.5,
	"invicible_time_depend": "none"
}

var damage_source :String= ''
var level :int= 0
signal shoot
var max_level = player_var.card_level_max
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



func on_use_card(id):
	if id != card_info.id:
		return
	if player_var.mana<card_info.mana/player_var.mana_cost:
		return

	player_var.mana-=card_info.mana/player_var.mana_cost
	SignalBus.player_invincible.emit(card_info.invincible_time)
	SignalBus.true_use_card.emit(card_info.id)
	emit_signal("shoot")
	#get buff

func add_routine(id):
	var routinepre = PresetManager.getpre('routine').instantiate()
	routinepre.position = Vector2(0,0)
	routinepre.routine_info = table.Routine[id]
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
