extends direction_bullet
func _ready():
	destroy_timer = $Timer
	basic_speed = 300
	basic_damage = 10
	destroy_timer.start()
