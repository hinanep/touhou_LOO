extends BaseGUIView
func _ready():
	G.get_gui_view_manager().open_view("Hud")
	G.get_gui_view_manager().open_view("TestHud")
	AudioManager.play_background_bgm("music_bgm_oldworld")
	#$Spawner.spawn_list.pre = PresetManager.getpre("enemy_boss_aq")
var pauseing = false
var pause_id
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):

			pause_id = G.get_gui_view_manager().open_view("PauseMenu")

	if event.is_action_pressed("clockup"):
		if Engine.time_scale >0.8:
			Engine.time_scale = 0.1
		else:
			Engine.time_scale = 1.0
func _open():
	player_var.new_scene()

	player_var.is_uping = false
	for i in 1:
		var dummm = preload("res://scene/enemys/dummy/dummy.tscn").instantiate()
		dummm.position.x += 2*i
		player_var.SpawnManager = $SpawnManager

		$SpawnManager.add_mob(dummm)
	#for i in  10:
		#dummm = preload("res://scene/enemys/enemy_base/enemy_base.tscn").instantiate()
		#dummm.position.x += 100
		#$SpawnManager.add_mob(dummm)


	#for i in 2000:
		#SignalBus.drop.emit("drops_p",%player.global_position+Vector2(randf_range(-1,1),randf_range(-1,1))*400)
func _physics_process(delta: float) -> void:
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
