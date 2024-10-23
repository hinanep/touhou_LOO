extends BaseGUIView

var is_pausing = false
func _open():
	if get_tree().paused:
		is_pausing = true
	else:
		get_tree().paused = true
	pass
	

func _close():
	if !is_pausing:
		get_tree().paused = false
	pass
	
	
func open():
	_open()
	
	
func close():
	_close() 
	
	
func close_self():
	G.get_gui_view_manager().close_view(viewInstanceId)
