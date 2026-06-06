extends BaseGUIView


func _open() -> void:

	player_var.request_game_pause()
	set_process_input(false)
	await get_tree().create_timer(0.5,false).timeout
	set_process_input(true)



func _close() -> void:
	player_var.release_game_pause()


func open() -> void:
	_open()


func close() -> void:

	_close()


func close_self() -> void:


	G.get_gui_view_manager().close_view(viewInstanceId)
	player_var.is_uping = false
	player_var._bonus_pick_active = false
	player_var.player_exp += 0
	player_var.call_deferred("_try_open_bonus_upgrade_select")

func set_property_change(id: String) -> void:

	$pp/properties.set_passive_preview(id)
