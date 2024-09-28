extends Area2D


var basic_damage = 0

var destroy_timer

signal on_hit


func _ready():
	destroy_timer = $Timer
	destroy_timer.start()
	print("laserin")	
	var enemy_in_range = get_overlapping_bodies()
	if enemy_in_range:
			for enemy in enemy_in_range:
				if enemy.has_method("take_damage"):
					enemy.take_damage(player_var.player_make_bullet_damage(basic_damage))
func _physics_process(delta):
	var enemy_in_range = get_overlapping_bodies()
	if enemy_in_range:
			for enemy in enemy_in_range:
				if enemy.has_method("take_damage"):
					enemy.take_damage(player_var.player_make_bullet_damage(basic_damage))
	pass
	
func _on_timer_timeout():
	queue_free()

func _on_hit():
	emit_signal("on_hit")
	pass
