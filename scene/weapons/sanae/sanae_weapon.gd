extends ranged_weapon_base

var bullet_small_pre
var bullet_mid_pre
var bullet_big_pre
# Called when the node enters the scene tree for the first time.
@export var bulletnum = 0
func _ready():
	basic_colddown = 1.2
	shoot_range = 180

	print("sanae_ready")
	bullet_small_pre = preload("res://scene/weapons/bullets/sanae_bullet/small/sanae_bullet_small.tscn")
	bullet_mid_pre = preload("res://scene/weapons/bullets/sanae_bullet/mid/sanae_bullet_mid.tscn")
	bullet_big_pre = preload("res://scene/weapons/bullets/sanae_bullet/big/sanae_bullet_big.tscn")
	set_range_and_colddown()

	pass # Replace with function body.


func _physics_process(_delta):
	var nearest_enemy = get_nearest_enemy_inarea()
	player_var.nearest_enemy = nearest_enemy
	
	if nearest_enemy:
	
		look_at(nearest_enemy.global_position)		
		auto_attack()
	if player_var.weapon_random_list["早苗"] > level:
		updateWeapon()
		level += 1
func auto_attack():

	var generate_position 
	var direction
	if shoot_ready:
		for i in range(player_var.bullet_times + bulletnum):
			generate_position = $".".global_position +   $".".global_position.direction_to(get_nearest_enemy_inarea().global_position) * randi_range(-player_var.bullet_times,player_var.bullet_times)
			#direction = global_position.angle_to_point(get_nearest_enemy_inarea().global_position)
			direction = global_rotation
			var random_bullet = randi_range(0,100) + player_var.luck
			if random_bullet > 95:
				shoot(bullet_big_pre,generate_position,direction)
			elif random_bullet > 70:
				shoot(bullet_mid_pre,generate_position,direction)
			else :
				shoot(bullet_small_pre,generate_position,direction)
			
			
			
		shoot_ready = false
		shoot_timer.start()
func updateWeapon():
	print("updated")
	bulletnum += 1
	pass
