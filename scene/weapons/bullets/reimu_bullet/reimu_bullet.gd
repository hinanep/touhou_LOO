extends trace_bullet

signal on_hit

func _ready():
	timer.start()
	basic_speed = 200
	velocity = global_position.direction_to(player_var.nearest_enemy.global_position) * player_var.bullet_speed_ratio * basic_speed

func _on_body_entered(body):
	emit_signal("on_hit")
	super._on_body_entered(body)
	
