
extends Area2D


var basic_damage = 10

var destroy_timer

signal on_hit


func _ready():
	destroy_timer = $Timer
	destroy_timer.start()

	var enemy_in_range = get_overlapping_bodies()
	if enemy_in_range:
			for enemy in enemy_in_range:
				if enemy.has_method("take_damage"):
					enemy.take_damage(player_var.player_make_bullet_damage(basic_damage,"rumia"))
				if enemy.has_method("set_debuff"):
					enemy.set_debuff("speed",0.2,1)
func _physics_process(_delta):
	var enemy_in_range = get_overlapping_bodies()
	if enemy_in_range:
			for enemy in enemy_in_range:
				if enemy.has_method("set_debuff"):
					enemy.set_debuff("speed",0.5,1)
					enemy.set_debuff("target_rediretion",$".",1)
	pass

func _on_timer_timeout():
	queue_free()

func _on_hit():
	emit_signal("on_hit")
	pass
