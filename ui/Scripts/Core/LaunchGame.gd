extends Node


func _ready() -> void:

	G.get_gui_view_manager()._build_view_config_map()
	G.get_gui_view_manager().open_view("StartMenu")
	print(get_tree().get_processed_tweens())
