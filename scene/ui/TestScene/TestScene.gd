extends BaseGUIView
func _ready():
	G.get_gui_view_manager().open_view("Hud")
	G.get_gui_view_manager().open_view("TestHud")
	AudioManager.play_background_bgm("music_bgm_oldworld")
	#$Spawner.spawn_list.pre = PresetManager.getpre("enemy_boss_aq")
var pauseing = false
var pause_id
func _input(event):
	if event.is_action_pressed("pause"):
		if !pauseing:
			pause_id = G.get_gui_view_manager().open_view("PauseMenu")
		else:
			G.get_gui_view_manager().close_view(pause_id)
		pauseing = !pauseing
		
func _open():
	GameManager.upping = false
	pass
	

func _close():
	AudioManager.stop_background_bgm()

	pass
	
	
func open():
	_open()
	
	
func close():
	_close() 
	
	
func close_self():
	G.get_gui_view_manager().close_view(viewInstanceId)
