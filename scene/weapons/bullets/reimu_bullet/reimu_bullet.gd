extends trace_bullet
func _ready():
	timer.start()
	basic_speed = 200
	velocity = global_position.direction_to(player_var.nearest_enemy.global_position) * player_var.bullet_speed_ratio * basic_speed
