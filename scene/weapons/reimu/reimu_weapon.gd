extends ranged_weapon_base

var bulletnum
var target 
# Called when the node enters the scene tree for the first time.
func _ready():
	basic_colddown = 0.7
	print("reimu_ready")
	waza_name = "reimu"
	shoot_range = 200
	bulletnum = 3
	cp_list = {
	"reima":{
	"on_hit":["res://scene/weapons/modifier/on_hit/on_hit.tscn"],
	"on_flying":[],
	"on_emit":[]
	}
}
	bullet_pre = preload("res://scene/weapons/bullets/reimu_bullet/reimu_bullet.tscn")


	super._ready()
	pass # Replace with function body.


func _physics_process(_delta):
	var nearest_enemy = has_nearest_enemy_inarea()
	
	if nearest_enemy:
		
		#look_at(player_var.nearest_enemy.global_position)		
		auto_attack()
		
func auto_attack():

	var generate_position 
	var direction
	
	if shoot_ready:
		target =  player_var.nearest_enemy
		shoot_ready = false
		shoot_timer.start()
		for i in range(player_var.bullet_times + bulletnum):
			generate_position = $".".global_position 
			#direction = global_position.angle_to_point(get_nearest_enemy_inarea().global_position)
			direction = 0
			
			await  get_tree().create_timer(0.1).timeout
			shoot(bullet_pre,generate_position,direction,target)

		

func upgrade_waza():
	print("updated")
	basic_colddown *= 0.9
	pass

func cp_active(x_name):
	super.cp_active(x_name)
