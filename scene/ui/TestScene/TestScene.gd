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
	if event.is_action_pressed("clockup"):
		if Engine.time_scale >0.8:
			Engine.time_scale = 0.1
		else:
			Engine.time_scale = 1.0
func _open():
	GameManager.upping = false
	var dummm = preload("res://scene/enemys/dummy/dummy.tscn").instantiate()
	dummm.position.x += 100
	SpawnManager.add_mob(dummm)
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
