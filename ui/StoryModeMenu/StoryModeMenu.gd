extends BaseGUIView


func _process(_delta):
	if Input.is_key_pressed(KEY_ESCAPE):

		_on_esc_button_pressed()
	# _on_esc_button_pressed()
	pass


func _on_esc_button_pressed():
	G.get_gui_view_manager().open_view("StartMenu")
	close_self()
	pass # Replace with function body.


func _on_play_button_button_up():


	player_var.ini()
	G.get_gui_view_manager().open_view("InGame")
	close_self()
	pass # Replace with function body.
