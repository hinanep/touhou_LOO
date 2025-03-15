extends Node2D

func showdamage(num):
	$damage.text = String.num_int64(num)
	scale *=  log(num)/log(10)
	$damage.set_modulate(modulate-Color(0, 1, 1, 0)*log(num)/4)
func _on_animation_player_animation_finished(_anim_name):
	queue_free()
	pass # Replace with function body.
