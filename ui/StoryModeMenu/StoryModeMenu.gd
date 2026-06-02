extends BaseGUIView


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):

		_on_esc_button_pressed()


func _on_esc_button_pressed() -> void:
	G.get_gui_view_manager().open_view("StartMenu")
	close_self()



func _on_play_button_button_up() -> void:


	G.get_gui_view_manager().open_view("InGame")
	close_self()
