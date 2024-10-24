class_name trace_bullet extends Area2D

@onready var timer = $Timer
var basic_speed = 500
var basic_damage = 10
var trace_strenth = 0.1
var velocity = Vector2(0.0,0.0)
var target_velocity = Vector2(0.0,0.0)
var target = null

var target_lost = false
var detect_next_target = true
signal on_hit
func _ready():
	timer.start()
	#if(target!=null):
	#velocity = global_position.direction_to(target.global_position) * player_var.bullet_speed_ratio * basic_speed
	velocity = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * player_var.bullet_speed_ratio * basic_speed *0.5

	#rotation = velocity.angle()
func _physics_process(delta):
	#print(player_var.nearest_enemy.global_position)	
	if target!=null:
		
		target_velocity = global_position.direction_to(target.global_position) * player_var.bullet_speed_ratio * basic_speed
		velocity = lerp(velocity,target_velocity,trace_strenth)
	elif !target_lost and !detect_next_target:
		target_lost = true
		velocity = global_position.direction_to(player_var.nearest_enemy_position) *player_var.bullet_speed_ratio * basic_speed
	else:
		target = player_var.nearest_enemy
	rotation = velocity.angle() + PI/2
	position += velocity * delta
	
func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	queue_free()
	#print("hit")
	emit_signal("on_hit")
	if body.has_method("take_damage"):
		body.take_damage(player_var.player_make_bullet_damage(basic_damage))


