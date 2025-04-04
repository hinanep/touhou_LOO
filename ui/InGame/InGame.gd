extends BaseGUIView
func _ready():
	G.get_gui_view_manager().open_view("Hud")
	AudioManager.play_background_bgm("music_bgm_oldworld")
	scene_init()

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
		if Engine.time_scale <1.5:
			Engine.time_scale = 2.0
		else:
			Engine.time_scale = 1.0

	if event.is_action_pressed("dialogue"):
		G.get_gui_view_manager().open_view("DialogueMenu")


func _open():
	pass


func _close():
	AudioManager.stop_background_bgm()

	pass


func open():
	player_var.air_wall_top = $air_wall/top.position.y
	player_var.air_wall_bottom = $air_wall/down.position.y
	player_var.air_wall_left = $air_wall/left.position.x
	player_var.air_wall_right = $air_wall/right.position.x
	_open()


func close():
	_close()

func close_self():

	G.get_gui_view_manager().close_view(viewInstanceId)

func scene_init():
	player_var.new_scene()
	SignalBus.try_add_skill.emit("ski_basemagic")
	SignalBus.try_add_skill.emit("ski_basephysics")
	SignalBus.try_add_card.emit("sc_daiyousei")
	$SpawnManager.spawnmanager_init('Stage1')
	player_var.SpawnManager = $SpawnManager


func _on_end_game_timeout() -> void:
	AudioManager.play_sfx("music_sfx_clear")
	await get_tree().create_timer(5.0).timeout
	G.get_gui_view_manager().close_all_view()
	G.get_gui_view_manager().open_view("ClearMenu")
