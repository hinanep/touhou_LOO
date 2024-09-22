extends BaseGUIView
func _ready():
	G.get_gui_view_manager().open_view("Hud")
	AudioManager.play_bgm("Ruins")
