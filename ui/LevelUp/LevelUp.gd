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
	GameManager.is_uping = false
	GameManager.add_exp(0)
