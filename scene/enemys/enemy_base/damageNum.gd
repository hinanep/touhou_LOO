extends Node2D

func showdamage(num):
	$damage.text = String.num_int64(num)
	scale *= clamp(log(num)/log(10),0.6,5)
	position = Vector2(2*randf()-1.2,randf()-2)*7
	$damage.set_modulate(modulate-Color(0, 1, 1, 0)*clamp(log(num)/4,0.5,5))
func _on_animation_player_animation_finished(_anim_name):
	queue_free()
