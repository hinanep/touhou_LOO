extends BaseGUIView

@onready var _properties_root: CanvasLayer = $pp

func _on_back_button_pressed():

	G.get_gui_view_manager().clear_to_start()

var is_pausing = false

func _is_level_up_open() -> bool:
	var vm = G.get_gui_view_manager()
	for view in vm.viewInstanceMap.values():
		if view.config.id == &"LevelUp":
			return true
	return false

func _sync_properties_visibility() -> void:
	_properties_root.visible = not _is_level_up_open()

func _process(_delta: float) -> void:
	_sync_properties_visibility()

func _open():
	if get_tree().paused:
		is_pausing = true
	else:
		get_tree().paused = true
	_sync_properties_visibility()

func _unhandled_key_input(event: InputEvent) -> void:

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
