class_name direction_bullet extends Area2D
@onready var timer = $Timer
var basic_speed = 200
var basic_damage = 10
func _ready():
	timer.start()

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * player_var.bullet_speed_ratio * basic_speed * delta
	
func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	queue_free()
	#print("hit")
	
	if body.has_method("take_damage"):
		body.take_damage(player_var.player_make_bullet_damage(basic_damage))

