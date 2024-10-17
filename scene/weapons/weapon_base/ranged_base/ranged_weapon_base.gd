class_name ranged_weapon_base extends Node2D
@onready var shoot_timer = $shootTimer
@onready var attack_range = $attack_range

var attack_modifier = {
	"on_hit":[],
	"on_flying":[],
	"on_emit":[]
}
var waza_name = ""
var shoot_range = 200
var basic_colddown = 1
var shoot_ready = true
var level = 1
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
		for i in range(player_var.bullet_times):
			generate_position = $".".global_position +   $".".global_position.direction_to(get_nearest_enemy_inarea().global_position) * randi_range(-player_var.bullet_times,player_var.bullet_times)
			direction = global_position.angle_to_point(get_nearest_enemy_inarea().global_position)
			shoot(bullet_pre,generate_position,direction)
			
		shoot_ready = false
		shoot_timer.start()
		
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
	
func shoot(bullet_pree,generate_position,generate_rotation):	
	AudioManager.play_sfx("sfx_bulletshoot")
	var new_bullet = bullet_pree.instantiate()
	if !attack_modifier["on_hit"].is_empty():
		for modi in attack_modifier["on_hit"]:
			var new_modifier = load(modi).instantiate()
			new_bullet.get_node("on_hit").add_child(new_modifier)
			
	#if !attack_modifier["on_flying"].is_empty():
	#if !attack_modifier["on_emit"].is_empty():
	#te.is_empty()
	new_bullet.global_position = generate_position
	new_bullet.global_rotation = generate_rotation
		
	$".".add_child(new_bullet)



