extends direction_bullet
func _ready():
	destroy_timer = $Timer
	basic_speed = 200
	basic_damage = 20
	destroy_timer.start()

func _on_body_entered(body):

	#print("hit")
	_on_hit()

	if body.has_method("take_damage"):
		bullet_damage(body,basic_damage)
