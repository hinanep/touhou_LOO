extends trace_bullet



func _ready():
	timer.start()
	basic_speed = 300
	velocity = global_position.direction_to(player_var.nearest_enemy.global_position) * player_var.bullet_speed_ratio * basic_speed
func _physics_process(delta):
	#print(player_var.nearest_enemy.global_position)
	velocity +=100 *  global_position.direction_to(player_var.player_node.global_position) *delta*sqrt(global_position.distance_to(player_var.player_node.global_position)) 
	velocity +=  velocity.rotated(PI/2).normalized() * delta * 100
	velocity = velocity.normalized() * basic_speed * player_var.bullet_speed_ratio
	position += velocity * delta
	
func _on_body_entered(body):
	emit_signal("on_hit")
	if body.has_method("take_damage"):
		body.take_damage(player_var.player_make_bullet_damage(basic_damage))
	#super._on_body_entered(body)
	
