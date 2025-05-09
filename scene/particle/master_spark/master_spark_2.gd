extends Node2D
func _ready() -> void:
	$"../..".start.connect(func():
		player_var.shake_screen(5,0.1,15,1)
		AudioManager.play_sfx('music_sfx_masterspark')
		)
func _on_visibility_changed() -> void:
	$WorldEnvironment.environment.set_glow_enabled(!$WorldEnvironment.environment.is_glow_enabled())



func _on_tree_exited() -> void:

	$WorldEnvironment.environment.set_glow_enabled(false)
