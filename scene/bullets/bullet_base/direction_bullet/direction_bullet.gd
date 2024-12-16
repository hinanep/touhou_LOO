class_name direction_bullet extends Area2D
var basic_speed = 500
var basic_damage = 20
var destroy_timer
var diretion:float
var target
signal on_hit
signal on_destroy
var bullet_modi_map ={
		"Damage_Addition":1,
		"Bullet_Speed_Addition":1,
		"Duration_Addition":1,
		"Range_Addition":1,
		"Debuff_Addition":1,
	}

func _ready():
	destroy_timer = $destroy_timer
	destroy_timer.wait_time *=  bullet_modi_map["Duration_Addition"]
	destroy_timer.start()
	basic_damage *= bullet_modi_map["Damage_Addition"]
	basic_speed *= bullet_modi_map["Bullet_Speed_Addition"]
	scale *= bullet_modi_map["Range_Addition"]

	
func _physics_process(delta):
	#var direction = Vector2.RIGHT.rotated(rotation)

	position += Vector2.from_angle(diretion) * player_var.bullet_speed_ratio * basic_speed * delta
	rotation = diretion + PI/2
func _on_timer_timeout():
	_on_destroy()
	queue_free()
#func _exit_tree():
	#_on_destroy()
func _on_body_entered(body):
	
	#print("hit")
	_on_hit()
	
	if body.has_method("take_damage"):
		bullet_damage(body,basic_damage)
		queue_free()
func _on_hit():
	emit_signal("on_hit")
	pass

func _on_destroy():
	emit_signal("on_destroy")
	pass
	
func bullet_damage(body,damage,damage_source = bullet_modi_map.damage_source):
	body.take_damage(player_var.player_make_bullet_damage(basic_damage,damage_source))
