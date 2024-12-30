extends trace_bullet


var attack_cd:bool = true
func _ready():
	basic_speed = 300
	$attack_timer.wait_time = 0.5
	#if get_tree().has_group("elite"):
		#target = get_tree().get_first_node_in_group("elite")
	super._ready()

	
	#velocity = global_position.direction_to(player_var.nearest_enemy.global_position) * player_var.bullet_speed_ratio * basic_speed
func _physics_process(delta):
	if get_tree().has_group("elite"):
		target = get_tree().get_first_node_in_group("elite")
	super._physics_process(delta)
	if   attack_cd and has_overlapping_bodies():
		print(get_overlapping_bodies())
		for enemy in get_overlapping_bodies():
			
			if enemy.has_method("take_damage"):
				bullet_damage(enemy,basic_damage)
				print("takeit")
		attack_cd = false
		$attack_timer.start()
func _on_body_entered(body):
	
	
	#print("hit")
	emit_signal("on_hit")
	if body.has_method("take_damage"):
		bullet_damage(body,basic_damage)
	


func _on_attack_timer_timeout():
	attack_cd = true
	pass # Replace with function body.
