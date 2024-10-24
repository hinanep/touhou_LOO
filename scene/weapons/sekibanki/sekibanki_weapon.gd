extends ranged_weapon_base


# Called when the node enters the scene tree for the first time.
@export var bulletnum = 4
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

	
	if nearest_enemy:
	
		look_at(nearest_enemy.global_position)		
		auto_attack()

func auto_attack():

	var generate_position 
	var direction
	if shoot_ready:
		shoot_ready = false
		shoot_timer.start()
		for i in range(player_var.bullet_times + bulletnum):
			generate_position = $".".global_position
			#direction = global_position.angle_to_point(get_nearest_enemy_inarea().global_position)
			#generate_position = $".".global_position
			direction = global_rotation
			await  get_tree().create_timer(0.1).timeout
			shoot(bullet_pre,generate_position,direction)
			
			
			

func upgrade_waza():
	print("updated")
	bulletnum += 1
	pass
