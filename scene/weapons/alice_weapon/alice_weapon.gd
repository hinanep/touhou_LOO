extends ranged_weapon_base

@export var bulletnum = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	basic_colddown = 1.5
	print("alice_ready")
	bullet_pre = preload("res://scene/weapons/bullets/alice_bullet/alice_bullet.tscn")
	set_range_and_colddown()
	pass # Replace with function body.


func _physics_process(_delta):
	var nearest_enemy = get_nearest_enemy_inarea()
	player_var.nearest_enemy = nearest_enemy
	
	if nearest_enemy:
	
		look_at(nearest_enemy.global_position)		
		auto_attack()
		
	if player_var.weapon_random_list["爱丽丝"] > level:
		updateWeapon()
		level += 1
func auto_attack():

	var generate_position 
	var direction
	if shoot_ready:
		for i in range(player_var.bullet_times + bulletnum):
			generate_position = $".".global_position +   $".".global_position.direction_to(get_nearest_enemy_inarea().global_position) * randi_range(-player_var.bullet_times,player_var.bullet_times)
			#direction = global_position.angle_to_point(get_nearest_enemy_inarea().global_position)
			direction = randf_range(-PI,PI)
			shoot(bullet_pre,generate_position,direction)
			
			
		shoot_ready = false
		shoot_timer.start()

func updateWeapon():
	print("updated")
	bulletnum += 1
	pass
