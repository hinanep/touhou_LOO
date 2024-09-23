class_name direction_bullet extends Area2D
var basic_speed = 200
var basic_damage = 10
var destroy_timer

signal on_hit


func _ready():
	destroy_timer = $Timer
	destroy_timer.start()

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * player_var.bullet_speed_ratio * basic_speed * delta
	
func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	queue_free()
	#print("hit")
	_on_hit()
	if body.has_method("take_damage"):
		body.take_damage(player_var.player_make_bullet_damage(basic_damage))

func _on_hit():
	emit_signal("on_hit")
	pass
