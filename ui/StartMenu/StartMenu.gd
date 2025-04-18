extends BaseGUIView


func _open():
	get_tree().paused = false

	pass


func _close():
	player_var.ini()
	pass


func _on_quit_button_pressed():
	get_tree().quit()
	pass # Replace with function body.


func _on_settings_button_pressed():
	G.get_gui_view_manager().open_view("SettingsMenu")
	close_self()
	pass # Replace with function body.


func _on_story_mode_button_pressed():
	G.get_gui_view_manager().open_view("StoryModeMenu")
	close_self()
	pass # Replace with function body.


func _on_wiki_button_pressed():
	G.get_gui_view_manager().open_view("WikiMenu")
	close_self()
	pass # Replace with function body.


func _on_shop_button_pressed():
	G.get_gui_view_manager().open_view("ShopMenu")
	close_self()
	pass # Replace with function body.


func _on_test_pressed():
	G.get_gui_view_manager().open_view("TestScene")
	close_self()
	pass # Replace with function body.
