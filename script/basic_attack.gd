extends Area2D
@onready var shoot_timer = $shootTimer
@onready var kick_timer = $kickTimer
@onready var kickarea = $kickarea

const basic_colddown = 1
const kick_range = 50
const kick_basic_damage = 10

var shoot_ready = true
var kick_ready = true
func _ready():
	shoot_timer.wait_time = basic_colddown * (1 - player_var.colddown_reduce)
	kick_timer.wait_time = basic_colddown * (1 - player_var.colddown_reduce)
	$kickarea/kickarea_box.set_scale(Vector2(player_var.range_add_ratio,player_var.range_add_ratio))
func _on_shoot_timer_timeout():
	shoot_ready = true

func _on_kick_timer_timeout():
	kick_ready = true

func enemy_near(a,b):
	return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
func _physics_process(delta):
	
	$kickarea/kick_anime.play("none")
	var enemy_in_range = get_overlapping_bodies() #area范围内的物体
	if !enemy_in_range.is_empty():
		
		var target_enemy =enemy_in_range.reduce(func(min,val):return val if enemy_near(val,min) else min)
		
		look_at(target_enemy.global_position)
		if shoot_ready:
			shoot()
			shoot_ready = false
			shoot_timer.start()
			
		if kick_ready and global_position.distance_to(target_enemy.global_position) < kick_range * player_var.range_add_ratio:
			kick()
			print("kick")
			kick_ready = false
			kick_timer.start()
	pass
	
func shoot():
	const bullet_pre = preload("res://scene/bullet.tscn")
	var new_bullet = bullet_pre.instantiate()
	new_bullet.global_position = $".".global_position
	new_bullet.global_rotation = $".".global_rotation
	$".".add_child(new_bullet)

func kick():
	var enemy_in_kick_range = kickarea.get_overlapping_bodies()
	#todo:体术动画
	$kickarea/kick_anime.play("kick")
	for enemy in enemy_in_kick_range:
		if enemy.has_method("take_damage"):
			enemy.take_damage(player_var.player_make_damage(kick_basic_damage))
	print("kick")
	




