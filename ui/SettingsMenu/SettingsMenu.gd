extends BaseGUIView


func _on_back_button_pressed():
	G.get_gui_view_manager().open_view("StartMenu")
	close_self()
	pass # Replace with function body.
