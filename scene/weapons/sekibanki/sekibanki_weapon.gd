extends ranged_weapon_base


# Called when the node enters the scene tree for the first time.
@export var bulletnum = 0
func _ready():
	basic_colddown = 0.5
	shoot_range = 180
	waza_name = "sekibanki"
	print("sekibanki_ready")
	bullet_pre = preload("res://scene/weapons/bullets/fly_head_bullet/fly_head.tscn")

	super._ready()

	pass # Replace with function body.


func _physics_process(_delta):
	var nearest_enemy = get_nearest_enemy_inarea()
	player_var.nearest_enemy = nearest_enemy
	
	if nearest_enemy:
	
		look_at(nearest_enemy.global_position)		
		auto_attack()

func auto_attack():

	var generate_position 
	var direction
	if shoot_ready:
		for i in range(player_var.bullet_times + bulletnum):
			generate_position = $".".global_position +   $".".global_position.direction_to(get_nearest_enemy_inarea().global_position) * randi_range(-player_var.bullet_times,player_var.bullet_times)
			#direction = global_position.angle_to_point(get_nearest_enemy_inarea().global_position)
			#generate_position = $".".global_position
			direction = global_rotation

			shoot(bullet_pre,generate_position,direction)
			
			
			
		shoot_ready = false
		shoot_timer.start()
func upgrade_waza():
	print("updated")
	bulletnum += 1
	pass
