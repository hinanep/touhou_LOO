extends ranged_weapon_base
var direction
func _ready():
	direction = 0.0
	set_range_and_colddown()
	bullet_pre = preload("res://scene/weapons/bullets/beginning_bullet/beginning_bullet.tscn")
func _physics_process(delta):
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

func _input(event):
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right") or event.is_action_pressed("move_up") or event.is_action_pressed("move_down"):
		direction = Input.get_vector("move_left","move_right","move_up","move_down").angle()
