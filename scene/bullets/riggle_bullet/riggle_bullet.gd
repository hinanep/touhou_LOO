extends trace_bullet



func _ready():
	basic_speed = 300
	#if get_tree().has_group("elite"):
		#target = get_tree().get_first_node_in_group("elite")
	super._ready()

	
	#velocity = global_position.direction_to(player_var.nearest_enemy.global_position) * player_var.bullet_speed_ratio * basic_speed
func _physics_process(delta):
	if get_tree().has_group("elite"):
		target = get_tree().get_first_node_in_group("elite")
	super._physics_process(delta)
func _on_body_entered(body):
	
	
	#print("hit")
	emit_signal("on_hit")
	if body.has_method("take_damage"):
		body.take_damage(player_var.player_make_bullet_damage(basic_damage))
	
