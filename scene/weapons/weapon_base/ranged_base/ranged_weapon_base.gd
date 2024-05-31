class_name ranged_weapon_base extends Node2D
@onready var shoot_timer = $shootTimer
@onready var attack_range = $attack_range

var shoot_range = 200
var basic_colddown = 1
var shoot_ready = true

var bullet_pre = preload("res://scene/weapons/bullets/bullet_base/direction_bullet/direction_bullet.tscn")
func _ready():
	set_range_and_colddown()
	
func _physics_process(delta):
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
		return enemy_in_range.reduce(func(min,val):return val if enemy_near(val,min) else min)
	return null
	
func shoot(bullet_pre,generate_position,direction):	
	var new_bullet = bullet_pre.instantiate()
	new_bullet.global_position = generate_position
	new_bullet.global_rotation = direction
		
	$".".add_child(new_bullet)



