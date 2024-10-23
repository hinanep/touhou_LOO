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
	
	GameManager.upping = false
	print("levelup closed")
	G.get_gui_view_manager().close_view(viewInstanceId)
	get_tree().paused = false
