extends direction_bullet
func _ready():
	destroy_timer = $Timer
	basic_speed = 100
	basic_damage = 100
	destroy_timer.start()
func _physics_process(delta):
	super._physics_process(delta)
	$AnimatedSprite2D.rotation += 0.1



func _on_body_entered(body):

	_on_hit()
	if body.has_method("take_damage"):
		body.take_damage(player_var.player_make_bullet_damage(basic_damage))
