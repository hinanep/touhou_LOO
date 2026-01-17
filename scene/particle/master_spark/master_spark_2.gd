extends Node2D
var os = Vector2(4,0.4)
var duratime = 5

func _ready() -> void:


	$"../..".online.connect(func():
		duratime = $"../../duration_timer".wait_time
		player_var.shake_screen(duratime,0.1,0.15)
		AudioManager.play_sfx('music_sfx_masterspark',-10,5.9-duratime)
		player_var.screen_black(0.5,0.3,duratime,0.2)
		online(duratime)
		)

	os = scale

func online(duratime) -> void:

		player_var.require_env_glowing(true)
		scale.y = 0
		var tween = create_tween()
		tween.tween_property($".",'scale',os,0.5)
		await get_tree().create_timer(duratime-1,false).timeout
		tween = create_tween()
		tween.tween_property($".",'scale',os*Vector2(1,0),0.5)
		await tween.finished







#
#func _on_attack_visibility_changed() -> void:
	#player_var.require_env_glowing(false)


func _on_hidden() -> void:
	player_var.require_env_glowing(false)
