extends BaseGUIView
func _ready():
	G.get_gui_view_manager().open_view("Hud")
	AudioManager.play_background_bgm("music_bgm_oldworld")
	scene_init()

var pauseing = false
var pause_id


func _unhandled_key_input(event: InputEvent) -> void:
	if get_tree()==null:
		return
	if event.is_action_pressed("pause"):
			pause_id = G.get_gui_view_manager().open_view("PauseMenu")

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
	player_var.SpawnManager.clear()
	print('clear')
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

func lock_camera():
	var camera:Camera2D = get_viewport().get_camera_2d()
	#camera.position_smoothing_enabled = true
	camera.limit_bottom = player_var.air_wall_bottom
	camera.limit_left = player_var.air_wall_left
	camera.limit_right = player_var.air_wall_right
	camera.limit_top = player_var.air_wall_top

func _on_end_game_timeout() -> void:



	while true:
		var interval = get_tree().create_timer(1)
		await interval.timeout
		interval = null
		if player_var.SpawnManager.mob_dic.is_empty():

			var mv :Tween= player_var.player_node.create_tween()
			var camera:Camera2D = get_viewport().get_camera_2d()
			mv.set_parallel()

			mv.tween_property(player_var.player_node,'global_position',Vector2(-200,0),1)
			mv.tween_property(camera,'global_position',Vector2(0,0),1)
			await mv.finished
			player_var.air_wall_bottom = 270
			player_var.air_wall_top = -270
			player_var.air_wall_left = -480
			player_var.air_wall_right = 480

			$air_wall/left.position.x = -480
			$air_wall/right.position.x = 480
			$air_wall/top.position.y = -270
			$air_wall/down.position.y = 270
			lock_camera()

			var boss = PresetManager.getpre('keine').instantiate()

			boss.boss_init('keine')
			boss.position = Vector2(1000,500)
			$SpawnManager.add_mob(boss)
			mv = boss.create_tween()
			mv.tween_property(boss,'global_position',Vector2(300,0),3)
			await mv.finished
			boss.fight_begin()
			return
