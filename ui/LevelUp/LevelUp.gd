extends BaseGUIView


func _open():

	get_tree().paused = true



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
	$properties.set_passive_preview(id)
