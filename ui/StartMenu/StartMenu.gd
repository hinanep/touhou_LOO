extends BaseGUIView

@onready var _progress_layer: CanvasLayer = $progress
@onready var _progress_bar: TextureProgressBar = $progress/PresetLoadingOverlay/TextureProgressBar
var _preset_signals_connected := false

func _open():
	get_tree().paused = false
	# 显示并更新预设加载进度
	if PresetManager.is_loading:
		_progress_layer.visible = true
		_progress_bar.value = int(PresetManager.loading_progress * 100.0)
		if _preset_signals_connected == false:
			PresetManager.loading_progress_changed.connect(_on_preset_loading_progress_changed)
			PresetManager.loading_completed.connect(_on_preset_loading_completed)
			_preset_signals_connected = true
	else:
		_progress_layer.visible = false

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

func _on_preset_loading_progress_changed(p: float) -> void:
	_progress_bar.value = int(p * 100.0)

func _on_preset_loading_completed() -> void:
	_progress_bar.value = 100
	_progress_layer.visible = false
