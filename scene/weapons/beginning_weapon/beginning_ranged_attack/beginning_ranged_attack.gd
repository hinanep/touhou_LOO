extends ranged_weapon_base
var direction
func _ready():
	direction = 0.0
	super._ready()
func _physics_process(_delta):
	
	var nearest_enemy = get_nearest_enemy_inarea()
	if nearest_enemy:
		#print(nearest_enemy.global_position)
		#look_at(nearest_enemy.global_position)		
		auto_attack(direction,waza_config["creation_distance"])
	

	
func _unhandled_key_input(event):
	var imputangle = Input.get_vector("move_left","move_right","move_up","move_down").angle()
	if event.is_released() and imputangle == 0:
		return
	direction = imputangle
