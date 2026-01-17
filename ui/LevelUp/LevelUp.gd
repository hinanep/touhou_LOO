extends BaseGUIView


func _open():

	get_tree().paused = true
	set_process_input(false)
	await get_tree().create_timer(0.5,false).timeout
	set_process_input(true)



func _close():
	get_tree().paused = false
	pass


func open():
	_open()


func close():

	_close()


func close_self():


	G.get_gui_view_manager().close_view(viewInstanceId)
	player_var.is_uping = false
	player_var.player_exp += 0

func set_property_change(id):

	$pp/properties.set_passive_preview(id)
