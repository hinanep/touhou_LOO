extends direction_bullet
func _ready():
	basic_speed = 200
	basic_damage = 20
	timer.start()

func _on_body_entered(body):
	#queue_free()
	#print("hit")
	
	if body.has_method("take_damage"):
		body.take_damage(player_var.player_make_bullet_damage(basic_damage))

