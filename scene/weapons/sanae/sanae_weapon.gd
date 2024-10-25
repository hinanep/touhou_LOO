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
	super._ready()

	pass # Replace with function body.


			
func auto_attack(angle=0,distance=0):
	
	if shoot_ready:
		shoot_ready = false
		shoot_timer.start()
		
		for i in range(int(waza_config["attack_gen_times"] * waza_config["Magical_Times_Efficiency"])):
			if(waza_config["creating_position"] == "self"):
				gen_position = global_position
			gen_position +=  Vector2.from_angle(angle) * distance
			match waza_config["locking_type"]:
				"diretion":					
					pass
				"nearest_enemy":
					angle = global_position.direction_to(player_var.nearest_enemy_position).angle()
					var random_bullet = randi_range(0,100) + player_var.luck
					await  get_tree().create_timer(0.1).timeout
					if random_bullet > 95:
						shoot(bullet_big_pre,gen_position,angle,bullet_modi_map,player_var.nearest_enemy)
					elif random_bullet > 70:
						shoot(bullet_mid_pre,gen_position,angle,bullet_modi_map,player_var.nearest_enemy)
					else :
						shoot(bullet_small_pre,gen_position,angle,bullet_modi_map,player_var.nearest_enemy)
					
					continue
				"random":
					angle = randf_range(0,2*PI)
			var random_bullet = randi_range(0,100) + player_var.luck
			await  get_tree().create_timer(0.1).timeout
			if random_bullet > 95:
				shoot(bullet_big_pre,gen_position,angle,bullet_modi_map,player_var.nearest_enemy)
			elif random_bullet > 70:
				shoot(bullet_mid_pre,gen_position,angle,bullet_modi_map,player_var.nearest_enemy)
			else :
				shoot(bullet_small_pre,gen_position,angle,bullet_modi_map,player_var.nearest_enemy)	
			

func upgrade_waza():

	super.upgrade_waza()
	pass
