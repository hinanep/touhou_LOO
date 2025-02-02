extends ranged_weapon_base
var direction
func _ready():
	direction = 0.0
	super._ready()



func _unhandled_key_input(event):
	var imputangle = Input.get_vector("move_left","move_right","move_up","move_down").angle()
	if event.is_released() and imputangle == 0:
		return
	direction = imputangle
func upgrade_waza():
	pass
