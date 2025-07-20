extends Node2D
var os
func _ready() -> void:
	$"../..".start.connect(func():
		player_var.shake_screen(5,0.1,0.35)
		AudioManager.play_sfx('music_sfx_masterspark')
		player_var.screen_black(0.7,0.3,5,2)
		)

	os = scale

func _on_visibility_changed() -> void:
	if visible:

		$WorldEnvironment.environment.set_glow_enabled(true)
		scale.y = 0
		var tween = create_tween()
		tween.tween_property($".",'scale',os,0.5)
		tween.tween_interval(5.0)
		tween.tween_property($".",'scale',os*Vector2(1,0),0.5)
	else:
		$WorldEnvironment.environment.set_glow_enabled(false)



func _on_tree_exited() -> void:

	$WorldEnvironment.environment.set_glow_enabled(false)
