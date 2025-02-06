extends attack


#var velocity = Vector2(0.0,0.0)
#
#func _ready():
	#basic_speed =100
	#basic_damage = 50
	#super._ready()
	#velocity = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * player_var.bullet_speed_ratio * basic_speed
	#rotation = velocity.angle() + PI/2
#func _physics_process(delta):
	##print(player_var.nearest_enemy.global_position)
	##if(player_var.player_node != null):
		##velocity +=100 *  global_position.direction_to(player_var.player_node.global_position) *delta*sqrt(global_position.distance_to(player_var.player_node.global_position))
	##velocity +=  velocity.rotated(PI/2).normalized() * delta * basic_speed
	##velocity = velocity.normalized() * basic_speed * player_var.bullet_speed_ratio
	#position += velocity * delta
#
#func _on_body_entered(body):
	#emit_signal("on_hit")
#
	#if body.has_method("take_damage"):
		#body.take_damage(player_var.player_make_bullet_damage(basic_damage))
		#queue_free()
	##super._on_body_entered(body)
