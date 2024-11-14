extends BaseGUIView


func _open():

	get_tree().paused = true

	

func _close():
	if get_tree().has_group("pause_menu"):
		return
	get_tree().paused = false
	pass
	
	
func open():
	_open()
	
	
func close():
	_close() 
	
	
func close_self():
	
	GameManager.upping = false

	G.get_gui_view_manager().close_view(viewInstanceId)

