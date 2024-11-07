extends BaseGUIView


func _on_back_button_pressed():
	#G.get_gui_view_manager().close_all_view()

	G.get_gui_view_manager().open_view("StartMenu")
	close_self()
	pass # Replace with function body.

func _open():

	pass
	

func _close():

	pass
	
	
func open():
	_open()
	
	
func close():
	_close() 
	
	
func close_self():
	G.get_gui_view_manager().close_view(viewInstanceId)

