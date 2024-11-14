extends direction_bullet

var velocity
func _ready():
	basic_speed = 500
	basic_damage = 8
	velocity = Vector2.from_angle(diretion) * player_var.bullet_speed_ratio * basic_speed
	super._ready()
func _physics_process(delta):

	position += velocity * delta






func _on_destroy_timer_timeout():
	queue_free()
	pass # Replace with function body.


