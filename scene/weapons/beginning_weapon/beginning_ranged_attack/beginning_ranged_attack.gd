extends ranged_weapon_base
var direction
func _ready():
	direction = 0.0
	set_range_and_colddown()
	bullet_pre = preload("res://scene/weapons/bullets/beginning_bullet/beginning_bullet.tscn")
func _physics_process(_delta):
	var nearest_enemy = get_nearest_enemy_inarea()
	if nearest_enemy:
		
		auto_attack()

func auto_attack():

	var generate_position 
	
	if shoot_ready:
		for i in range(player_var.bullet_times):
			generate_position = $".".global_position +   $".".global_position.direction_to(get_nearest_enemy_inarea().global_position) * randi_range(-player_var.bullet_times,player_var.bullet_times)

			shoot(bullet_pre,generate_position,direction)
			
		shoot_ready = false
		shoot_timer.start()

func _unhandled_key_input(event):
	var imputangle = Input.get_vector("move_left","move_right","move_up","move_down").angle()
	if event.is_released() and imputangle == 0:
		return

	direction = imputangle
