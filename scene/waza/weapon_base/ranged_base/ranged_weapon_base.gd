class_name ranged_weapon_base extends Node2D
@onready var shoot_timer = $shootTimer
@onready var attack_range = $attack_range
var active = true
var attack_modifier = {
	"on_hit":[],
	"on_flying":[],
	"on_emit":[],
	"on_destroy":[]
}
var cp_list = {

}
var waza_config = {
	 "routine_name":'sanae',  
	"cn":'早苗',  
	"damage_type":'danma',  
	"basic_cd":1.0,  
	"locking_type":'nearest_enemy',  
	"locking_param":[],  
	"gen_zeropoint":'self',  
	"gen_target":[],  
	"gen_position":[[0, 0]],  
	"inherit_rot":false,  
	"gen_rule":'random_event',  
	"gen_pre_arr":[],  
	"gen_type":'one',  
	"gen_lag":0.1,  
	"gen_times_dependence":0,  
	"gen_times":1,  
	"event1":['shoot', 'bullet_sanae_small'],  
	"event2":['shoot', 'bullet_sanae_mid'],  
	"event3":['shoot', 'bullet_sanae_big'],  
	"event_weight":[4, 2, 1],  
	"event_luckeff":[-1, 0, 1],  
	"melee_efficiency":1.0,  
	"danma_efficiency":1.0,  
	"speed_efficiency":1.0,  
	"duration_efficiency":1.0,  
	"range_efficiency":1.0,  
	"danma_times_efficiency":1.0,  
	"melee_times_efficiency":1.0,  
	"cd_efficicency":1.0,  
	"level":0,  
	"path":'waza_sanae',  
	"weight":1.0,  
	"waza_image":'image_waza_sanae',  
	"shoot_sfx":'music_sfx_shoot',  
	"cp_map":{},  
	"comment":['随机射出不同子弹', '属性上升', '属性上升', '属性上升', '属性上升', '属性上升', '属性上升', '属性上升'], }

var shoot_range = 200
var basic_colddown = 1
var shoot_ready = true
var gen_position
var bullet_pre 
var bullet_modi_map
var clockangle = 0
func _ready():
	set_range_and_colddown()
	add_to_group(waza_config["waza_name"])
	cp_list = waza_config["cp_map"]


	bullet_pre = PresetManager.getpre(waza_config["attack_pre"])
	bullet_modi_map ={
		"Damage_Addition":1,
		"Bullet_Speed_Addition":1,
		"Duration_Addition":1,
		"Range_Addition":1,
		"Debuff_Addition":1,
		"damage_source":waza_config["waza_name"]
	}
	if(waza_config["creating_position"] == "self"):
		gen_position = global_position
		
func auto_attack(angle=0,distance=0):
	
	#if shoot_ready:
		#shoot_ready = false
		#shoot_timer.start()
		
		for i in range(int(waza_config["attack_gen_times"] * waza_config["Magical_Times_Efficiency"])):
			if(waza_config["creating_position"] == "self"):
				gen_position = global_position
			gen_position +=  Vector2.from_angle(angle) * distance
			match waza_config["locking_type"]:
				"diretion":					
					pass
				"nearest_enemy":
					angle = global_position.direction_to(player_var.nearest_enemy_position).angle()
					shoot(bullet_pre,gen_position,angle,bullet_modi_map,player_var.nearest_enemy)
					if waza_config["creating_rule"] == "one":
						await  get_tree().create_timer(0.15).timeout
					
					continue
				"random":
					angle = randf_range(0,2*PI)
				"clock":
					clockangle +=  0.25*PI
					angle = clockangle
			if waza_config["creating_rule"] == "one":
				await  get_tree().create_timer(0.1).timeout
			shoot(bullet_pre,gen_position,angle,bullet_modi_map)
			
		
func set_range_and_colddown():
	shoot_timer.wait_time = waza_config["basic_colddown"] * (1 - player_var.colddown_reduce * waza_config["Reduction_Efficiency"])
	
	shoot_timer.one_shot = false
	shoot_timer.start()
	$attack_range/CollisionShape2D.set_scale(Vector2(player_var.range_add_ratio * shoot_range,player_var.range_add_ratio * shoot_range))
	
func _on_shoot_timer_timeout():
	
	if has_nearest_enemy_inarea() and active:
		auto_attack(waza_config["diretion_rotation"],waza_config["creation_distance"])


func enemy_near(a,b):
	return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)

func get_nearest_enemy_inarea():
	var enemy_in_range = attack_range.get_overlapping_bodies() #area范围内的物体
	if !enemy_in_range.is_empty():	
		return enemy_in_range.reduce(func(min_e,val):return val if enemy_near(val,min_e) else min_e)
	return null

func has_nearest_enemy_inarea():
	return attack_range.has_overlapping_bodies()
	
func shoot(bullet_pree,generate_position,generate_diretion,efficiency_map,target = null):	
	AudioManager.play_sfx(waza_config["shoot_sfx"])
	var new_bullet = bullet_pree.instantiate()
	
	if !attack_modifier["on_hit"].is_empty():
		for modi in attack_modifier["on_hit"]:
			var new_modifier = PresetManager.getpre(modi).instantiate()
			new_bullet.get_node("on_hit").add_child(new_modifier)
	if !attack_modifier["on_flying"].is_empty():
		for modi in attack_modifier["on_flying"]:
			var new_modifier = PresetManager.getpre(modi).instantiate()
			new_bullet.get_node("on_flying").add_child(new_modifier)
	if !attack_modifier["on_emit"].is_empty():
		for modi in attack_modifier["on_emit"]:
			var new_modifier = PresetManager.getpre(modi).instantiate()
			new_bullet.get_node("on_emit").add_child(new_modifier)	
	if !attack_modifier["on_destroy"].is_empty():
		for modi in attack_modifier["on_destroy"]:
			var new_modifier = PresetManager.getpre(modi).instantiate()
			new_bullet.get_node("on_destroy").add_child(new_modifier)	
			
	new_bullet.global_position = generate_position
	
	new_bullet.diretion = generate_diretion
	new_bullet.bullet_modi_map = efficiency_map
	if(target!=null):
		new_bullet.target = target
	$".".add_child(new_bullet)
	

func cp_active(x_name):
	print("waza_cp")
	print(x_name)
	if cp_list.has(x_name):
		for onhit in cp_list[x_name]["on_hit"]:	
			attack_modifier["on_hit"].append(onhit)

		for on_flying in cp_list[x_name]["on_flying"]:		
			attack_modifier["on_flying"].append(on_flying)
			
		for on_emit in cp_list[x_name]["on_emit"]:		
			attack_modifier["on_emit"].append(on_emit)
		
		for on_destroy in cp_list[x_name]["on_destroy"]:		
			attack_modifier["on_destroy"].append(on_destroy)
func cp_deactive(x_name):
	if cp_list.has(x_name):
		for onhit in cp_list[x_name]["on_hit"]:	
			attack_modifier["on_hit"].erase(onhit)
			
		for on_flying in cp_list[x_name]["on_flying"]:		
			attack_modifier["on_flying"].erase(on_flying)
			
		for on_emit in cp_list[x_name]["on_emit"]:		
			attack_modifier["on_emit"].erase(on_emit)
		
		for on_destroy in cp_list[x_name]["on_destroy"]:		
			attack_modifier["on_destroy"].erase(on_destroy)
func upgrade_waza():
	if waza_config["level"] > WazaManager.waza_maxlevel:
		return
	#waza_config["level"] += 1
	bullet_modi_map["Damage_Addition"] = waza_config["upgrade_map"]["Damage_Addition"][waza_config["level"]-1] * waza_config["Magical_Addition_Efficiency"]
	bullet_modi_map["Bullet_Speed_Addition"]= waza_config["upgrade_map"]["Bullet_Speed_Addition"][waza_config["level"]-1] * waza_config["Speed_Efficiency"]
	bullet_modi_map["Duration_Addition"]= waza_config["upgrade_map"]["Duration_Addition"][waza_config["level"]-1]*waza_config["Duration_Efficiency"]
	
	bullet_modi_map["Range_Addition"]= waza_config["upgrade_map"]["Range_Addition"][waza_config["level"]-1]*waza_config["Range_Efficiency"]
	
	#bullet_modi_map["Debuff_Addition"]= waza_config["upgrade_map"]["Debuff_Addition"][waza_config["level"]]
	shoot_timer.wait_time = waza_config["basic_colddown"] * (1 - player_var.colddown_reduce * waza_config["Reduction_Efficiency"]) * waza_config["upgrade_map"]["colddown"][waza_config["level"]-1]
	waza_config["attack_gen_times"] = waza_config["upgrade_map"]["Times"][waza_config["level"]-1]
	
