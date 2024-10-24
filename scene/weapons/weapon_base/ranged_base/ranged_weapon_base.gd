class_name ranged_weapon_base extends Node2D
@onready var shoot_timer = $shootTimer
@onready var attack_range = $attack_range

var attack_modifier = {
	"on_hit":[],
	"on_flying":[],
	"on_emit":[]
}
var cp_list = {

}
var waza_config = {
	"waza_name" : "",
	"level":0,
	"path":"",
	"weight":0,#随机权重
	"cn":"",#中文名
	"type":"skill",#技能、符卡、衍生
	"locking_type":"",#目标、定向、随机方向
	"attack_pre":"",#发射实体路径
	"diretion":Vector2(0,0),#发射方向
	"diretion_rotation":0,#发射方向旋转角（逆时针角度）
	"creation_distance":0,#距离生成位置的距离
	
	"creating_position":"",#生成位置：在自机处、最近几名敌人处、什么神秘地方处,
	"creating_rule":"",#生成一组、一个个生成
	"attack_gen_times":"",#基础生成次数
	"basic_colddown":1.0,
	"Physical_Addition_Efficiency":0.0,
	"Magical_Addition_Efficiency":1.0,
	"Speed_Efficiency":1.0,
	"Duration_Efficiency":1.0,
	"Range_Efficiency":1.0,
	"Magical_Times_Efficiency":1.0,
	"Physical_Times_Efficiency":1.0,
	"Reduction_Efficiency":1.0,
	"cp_map":{},
	"upgrade_map":{
		"Damage_Addition":[],
		"Bullet_Speed_Addition":[],
		"Duration_Addition":[],
		"Range_Addition":[],
		"Times_Addition":[],
		"Debuff_Addition":[],
		"Cd_Reduction":[]
					}	
	}
	
var waza_name = ""
var shoot_range = 200
var basic_colddown = 1
var shoot_ready = true
var level = 0
var bullet_pre = preload("res://scene/weapons/bullets/bullet_base/direction_bullet/direction_bullet.tscn")
func _ready():
	set_range_and_colddown()
	add_to_group(waza_name)
func _physics_process(_delta):
	var nearest_enemy = get_nearest_enemy_inarea()
	if nearest_enemy:
		#print(nearest_enemy.global_position)
		look_at(nearest_enemy.global_position)		
		auto_attack()

func auto_attack():
	
	var generate_position 
	var direction
	if shoot_ready:
		shoot_ready = false
		shoot_timer.start()
		for i in range(player_var.bullet_times):
			generate_position = $".".global_position
			direction = global_position.angle_to_point(get_nearest_enemy_inarea().global_position)
			await  get_tree().create_timer(0.1).timeout
			shoot(bullet_pre,generate_position,direction)
			
		
func set_range_and_colddown():
	shoot_timer.wait_time = basic_colddown * (1 - player_var.colddown_reduce)
	$attack_range/CollisionShape2D.set_scale(Vector2(player_var.range_add_ratio * shoot_range,player_var.range_add_ratio * shoot_range))
	
func _on_shoot_timer_timeout():
	shoot_ready = true

func enemy_near(a,b):
	return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)

func get_nearest_enemy_inarea():
	var enemy_in_range = attack_range.get_overlapping_bodies() #area范围内的物体
	if !enemy_in_range.is_empty():	
		return enemy_in_range.reduce(func(min_e,val):return val if enemy_near(val,min_e) else min_e)
	return null

func has_nearest_enemy_inarea():
	return attack_range.has_overlapping_areas()
	
func shoot(bullet_pree,generate_position,generate_rotation,target = null):	
	AudioManager.play_sfx("sfx_bulletshoot")
	var new_bullet = bullet_pree.instantiate()
	if !attack_modifier["on_hit"].is_empty():
		for modi in attack_modifier["on_hit"]:
			var new_modifier = load(modi).instantiate()
			new_bullet.get_node("on_hit").add_child(new_modifier)
	if !attack_modifier["on_flying"].is_empty():
		for modi in attack_modifier["on_flying"]:
			var new_modifier = load(modi).instantiate()
			new_bullet.get_node("on_flying").add_child(new_modifier)
	if !attack_modifier["on_emit"].is_empty():
		for modi in attack_modifier["on_emit"]:
			var new_modifier = load(modi).instantiate()
			new_bullet.get_node("on_emit").add_child(new_modifier)	

	new_bullet.global_position = generate_position
	new_bullet.global_rotation = generate_rotation
	if(target!=null):
		new_bullet.target = target
	$".".add_child(new_bullet)
	

func cp_active(x_name):
	for onhit in cp_list[x_name]["on_hit"]:	
		attack_modifier["on_hit"].append(onhit)

	for on_flying in cp_list[x_name]["on_flying"]:		
		attack_modifier["on_flying"].append(on_flying)
		
	for on_emit in cp_list[x_name]["on_emit"]:		
		attack_modifier["on_emit"].append(on_emit)

