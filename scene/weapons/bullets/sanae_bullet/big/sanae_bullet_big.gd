extends direction_bullet
func _ready():
	destroy_timer = $Timer
	basic_speed = 100
	basic_damage = 100
	destroy_timer.start()
func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	
	position += direction * player_var.bullet_speed_ratio * basic_speed * delta
	$AnimatedSprite2D.rotation += 0.1

func _on_body_entered(body):
	#queue_free()
	#print("hit")
	
	if body.has_method("take_damage"):
		body.take_damage(player_var.player_make_bullet_damage(basic_damage))

