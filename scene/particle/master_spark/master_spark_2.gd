extends Node2D
func _ready() -> void:
	$"../..".start.connect(func():
		player_var.shake_screen(5,0.1,0.35)
		AudioManager.play_sfx('music_sfx_masterspark')
		player_var.screen_black(0.7,0.3,5,2)
		)

func _on_visibility_changed() -> void:
	if visible:
		print("visible")
		$WorldEnvironment.environment.set_glow_enabled(true)
	else:
		print("invisible")
		$WorldEnvironment.environment.set_glow_enabled(false)
	print($WorldEnvironment.environment.is_glow_enabled())
	print("set glow on?")


func _on_tree_exited() -> void:

	$WorldEnvironment.environment.set_glow_enabled(false)
