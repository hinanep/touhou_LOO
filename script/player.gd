extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
var hp = player_var.player_hp_max
var enemy_detect_zone
var enemy_in_zone
func _init():
	player_var.player_node = $"."
	pass
func _ready():
	$invincible_time.wait_time = player_var.invincible_time
	enemy_detect_zone = $enemy_detect_area
	
	WazaManager.add_waza("base_range")
	WazaManager.add_waza("base_melee")
	CardManager.add_card("fairy")
	CardManager.add_card("test")

	SpawnManager.prepare_all_spawn_event($"../SpawnManager")
	request_ready()
	pass
func _enter_tree():
	
	pass
func _physics_process(_delta):
	#移动
	
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * player_var.player_speed
	
	move_and_slide()
	
	#动画
	if direction:
		animated_sprite_2d.play("run")
		pass
	else:
		animated_sprite_2d.play("stay")
		pass
	enemy_in_zone = enemy_detect_zone.get_overlapping_bodies()
	if !enemy_in_zone.is_empty():	
		player_var.nearest_enemy = enemy_in_zone.reduce(func(min_e,val):return val if enemy_near(val,min_e) else min_e)
		if player_var.nearest_enemy!=null:
			player_var.nearest_enemy_position = player_var.nearest_enemy.global_position
			
func take_damage(damage):
	if player_var.is_invincible:
		print("invincible active")
		return
	animated_sprite_2d.play("be_hit")
	hp -= damage
	player_var.player_hp = hp
	
	if hp < 0:
		died()
		
	player_var.is_invincible = true
	$invincible_time.start()
		
func died():
	G.get_gui_view_manager().close_all_view()
	
	G.get_gui_view_manager().open_view("StartMenu")


func _on_invincible_time_timeout():
	player_var.is_invincible = false



func _on_pickup_area_body_entered(body):
	if body.has_method("fly_to_player"):
		body.fly_to_player()
	pass # Replace with function body.

func _on_pickup_area_area_entered(area):

	if area.has_method("fly_to_player"):
		area.fly_to_player()
	pass # Replace with function body.
	
func enemy_near(a,b):
	return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)
