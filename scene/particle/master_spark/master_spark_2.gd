extends Node2D
var os = Vector2(1,1)
var duratime = 1
func _ready() -> void:
	duratime = $"../../duration_timer".wait_time
	$"../..".start.connect(func():
		player_var.shake_screen(duratime,0.1,0.15)
		AudioManager.play_sfx('music_sfx_masterspark',-10,5.9-duratime)
		player_var.screen_black(0.5,0.3,duratime,0.2)
		)

	os = scale

func _on_visibility_changed() -> void:
	if visible:
		print("visible")
		player_var.worldenvir.environment.set_glow_enabled(true)
		scale.y = 0
		var tween = create_tween()
		player_var.underrecycle_tween.append(tween)
		tween.tween_property($".",'scale',os,0.2)
		tween.tween_interval(duratime)
		tween.tween_property($".",'scale',os*Vector2(1,0),0.1)
	else:
		print("not visible")
		player_var.worldenvir.environment.set_glow_enabled(false)



func _on_tree_exited() -> void:
	print("exittree")
	player_var.worldenvir.environment.set_glow_enabled(false)
