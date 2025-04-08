extends BaseGUIView


func _on_back_button_pressed():
	G.get_gui_view_manager().close_all_view()
	G.get_gui_view_manager().open_view("StartMenu")

var is_pausing = false
func _open():
	if get_tree().paused:
		is_pausing = true
	else:
		get_tree().paused = true

func _input(event: InputEvent) -> void:

	if event.is_action_pressed("pause"):
		#event.pressed= false
		close_self()



func _close():
	if is_pausing:
		pass
	else:
		get_tree().paused = false
	pass


func open():

	_open()


func close():
	_close()


func close_self():
	G.get_gui_view_manager().close_view(viewInstanceId)


func _on_continue_button_pressed() -> void:
	close_self()
	pass # Replace with function body.
