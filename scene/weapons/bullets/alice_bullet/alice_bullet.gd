extends direction_bullet
@onready var attack_timer = $attack_timer
@onready var destroy_timer = $destroy_timer

@onready var attack = $attack
var move = true
var attackable = true
func _ready():
	basic_speed = 500
	basic_damage = 8
	destroy_timer.start()

func _physics_process(delta):
	if move:
		var direction = Vector2.RIGHT.rotated(rotation)
		position += direction * player_var.bullet_speed_ratio * basic_speed * delta
	else:
		var enemy_in_range = get_overlapping_bodies()
		if enemy_in_range and attackable:
			attackable = false
			attack_timer.start()
			for enemy in enemy_in_range:
				if enemy.has_method("take_damage"):
					enemy.take_damage(player_var.player_make_bullet_damage(basic_damage))
	attack.rotation += 0.5
	

func _on_body_entered(body):
	move = false
	if body.has_method("take_damage"):
		body.take_damage(player_var.player_make_bullet_damage(basic_damage))



func _on_destroy_timer_timeout():
	queue_free()
	pass # Replace with function body.


func _on_attack_timer_timeout():
	attackable = true
	pass # Replace with function body.
