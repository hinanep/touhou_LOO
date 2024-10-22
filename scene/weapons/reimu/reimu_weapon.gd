extends ranged_weapon_base

@export var bulletnum = 0

var laser
# Called when the node enters the scene tree for the first time.
func _ready():
	basic_colddown = 0.7
	print("reimu_ready")
	waza_name = "reimu"
	cp_list = {
	"reima":{
	"on_hit":["res://scene/weapons/modifier/on_hit/on_hit.tscn"],
	"on_flying":[],
	"on_emit":[]
	}
}
	bullet_pre = preload("res://scene/weapons/bullets/reimu_bullet/reimu_bullet.tscn")
	laser = preload("res://scene/weapons/bullets/laser_bullet/laser.tscn")
	
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
			direction = randf_range(-PI,PI)
			shoot(bullet_pre,generate_position,direction)
			#shoot(laser,generate_position,direction)
			
		shoot_ready = false
		shoot_timer.start()

func upgrade_waza():
	print("updated")
	basic_colddown *= 0.9
	pass

func cp_active(name):
	super.cp_active(name)
