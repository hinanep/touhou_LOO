extends Node2D
var sum_damage = 0
func showdamage(num):
	$"../AvoidanceModule".visible = true
	sum_damage += num

	visible = true
	$damage.text = String.num_int64(sum_damage)
	scale = Vector2(0.3,0.3) * clamp(log(sum_damage)/log(10),0.6,2)
	position = Vector2(2*randf()-1.5,randf()-1)*8
	$damage.set_modulate(modulate-Color(0, 1, 1, 0)*clamp(log(sum_damage)/4,0.5,5))
	$AnimationPlayer.play("new_animation")
	$disappear.start()
#func _on_animation_player_animation_finished(_anim_name):
	#queue_free()


func _on_disappear_timeout() -> void:
	visible = false
	sum_damage = 0
