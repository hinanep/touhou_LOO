extends direction_bullet

var velocity
var collision_info
var cbb
var bounce_times = 20
func _ready():
	basic_speed = 300
	basic_damage = 8
	cbb = $CharacterBody2D
	velocity = Vector2.from_angle(diretion) * player_var.bullet_speed_ratio * basic_speed
	super._ready()
func _physics_process(delta):
	velocity *= 0.998
	position += velocity * delta
	collision_info = cbb.move_and_collide(velocity * delta,true)
	if collision_info:
		bounce_times -= 1

		velocity = velocity.bounce(collision_info.get_normal())
		if collision_info.get_collider().has_method("take_damage"):
			collision_info.get_collider().take_damage(player_var.player_make_bullet_damage(basic_damage))
		if bounce_times <0:
			_on_destroy_timer_timeout()
func _on_body_entered(_body):
	pass
	#if body.has_method("take_damage"):
		#body.take_damage(player_var.player_make_bullet_damage(basic_damage))
	


func _on_destroy_timer_timeout():
	_on_destroy()
	queue_free()
	pass # Replace with function body.

