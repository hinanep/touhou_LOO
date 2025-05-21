extends BaseGUIView
func _ready():
	G.get_gui_view_manager().open_view("Hud")
	G.get_gui_view_manager().open_view("TestHud")
	AudioManager.play_background_bgm("music_bgm_oldworld")
	#$Spawner.spawn_list.pre = PresetManager.getpre("enemy_boss_aq")
	player_var.tmp_scene = $"."
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
	player_var.SpawnManager = $SpawnManager
	player_var.is_uping = false
	for i in 0:
		var dummm = preload("res://scene/enemys/dummy/dummy.tscn").instantiate()
		dummm.position.x += 2*100
		$SpawnManager.add_mob(dummm)
	player_var.boss_coming('keine')

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

func lock_camera():
	var camera:Camera2D = get_viewport().get_camera_2d()
	#camera.position_smoothing_enabled = true
	camera.limit_bottom = player_var.air_wall_bottom
	camera.limit_left = player_var.air_wall_left
	camera.limit_right = player_var.air_wall_right
	camera.limit_top = player_var.air_wall_top

func create_boss() -> void:
	var camera:Camera2D = get_viewport().get_camera_2d()
	var mv :Tween= player_var.player_node.create_tween()
	mv.set_parallel()
	#get_viewport().get_camera_2d().position_smoothing_enabled = true
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
