extends Node2D
var os = Vector2(4,0.4)
var duratime = 5
func _ready() -> void:
	duratime = $"../../duration_timer".wait_time

	$"../..".start.connect(func():
		player_var.shake_screen(duratime,0.1,0.15)
		AudioManager.play_sfx('music_sfx_masterspark',-10,5.9-duratime)
		player_var.screen_black(0.5,0.3,duratime,0.2)
		)

	#os = scale

func _on_visibility_changed() -> void:
	if visible:
		player_var.worldenvir.environment.set_glow_enabled(true)
		scale.y = 0
		var tween = create_tween()
		print('tweening')
		tween.tween_property($".",'scale',os,0.5)
		tween.tween_interval(5.0)
		tween.tween_property($".",'scale',os*Vector2(1,0),0.5)
		await tween.finished
		print('tweened')
		tween.kill()
	else:

		player_var.worldenvir.environment.set_glow_enabled(false)



func _on_tree_exited() -> void:

	player_var.worldenvir.environment.set_glow_enabled(false)
