extends Area2D
@onready var shoot_timer = $shootTimer
@onready var kick_timer = $kickTimer

const basic_colddown = 1
const kick_range = 10


var shoot_ready = true
var kick_ready = true
func _ready():
	shoot_timer.wait_time = basic_colddown * (1 - player_var.colddown_reduce)
	kick_timer.wait_time = basic_colddown * (1 - player_var.colddown_reduce)
	
func _on_shoot_timer_timeout():
	shoot_ready = true

func _on_kick_timer_timeout():
	kick_ready = true
	
func _physics_process(delta):
	var enemy_in_range = get_overlapping_bodies() #area范围内的物体
	if !enemy_in_range.is_empty():
		var target_enemy = enemy_in_range.front()
		look_at(target_enemy.global_position)
		if shoot_ready:
			shoot()
			shoot_ready = false
			shoot_timer.start()
			
		if kick_ready and global_position.distance_to(target_enemy.global_position) < kick_range * player_var.range_add_ratio:
			kick()
			kick_ready = false
			kick_timer.start()
	pass
	
func shoot():
	const bullet_pre = preload("res://scene/bullet.tscn")
	var new_bullet = bullet_pre.instantiate()
	new_bullet.position = $".".position
	$".".add_child(new_bullet)

func kick():
	print("kick")
	pass




