class_name trace_bullet extends Area2D

@onready var timer = $Timer
var basic_speed = 500
var basic_damage = 10
var trace_strenth = 0.1
var velocity = Vector2(0.0,0.0)
var target_velocity = Vector2(0.0,0.0)
signal on_hit
func _ready():
	timer.start()
	velocity = global_position.direction_to(player_var.nearest_enemy.global_position) * player_var.bullet_speed_ratio * basic_speed
func _physics_process(delta):
	#print(player_var.nearest_enemy.global_position)
	if player_var.nearest_enemy:
		
		target_velocity = global_position.direction_to(player_var.nearest_enemy.global_position) * player_var.bullet_speed_ratio * basic_speed
		velocity = lerp(velocity,target_velocity,trace_strenth)
	
	position += velocity * delta
	
func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	queue_free()
	#print("hit")
	emit_signal("on_hit")
	if body.has_method("take_damage"):
		body.take_damage(player_var.player_make_bullet_damage(basic_damage))


