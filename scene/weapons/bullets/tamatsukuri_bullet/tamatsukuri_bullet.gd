extends direction_bullet

var velocity
func _ready():
	basic_speed = 100
	basic_damage = 8
	velocity = Vector2.from_angle(diretion) * player_var.bullet_speed_ratio * basic_speed
	super._ready()
func _physics_process(delta):

	position += velocity * delta


func _on_body_entered(body):
	velocity = -velocity
	if body.has_method("take_damage"):
		body.take_damage(player_var.player_make_bullet_damage(basic_damage))



func _on_destroy_timer_timeout():
	_on_destroy()
	queue_free()
	pass # Replace with function body.


func _on_attack_timer_timeout():

	pass # Replace with function body.
