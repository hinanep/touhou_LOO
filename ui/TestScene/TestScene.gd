extends BaseGUIView
func _ready() -> void:
	G.get_gui_view_manager().open_view("Hud")
	G.get_gui_view_manager().open_view("TestHud")
	AudioManager.play_background_bgm("music_bgm_oldworld")
	RunSession.tmp_scene = $"."
	RunSession.air_wall_top = $air_wall/top.position.y
	RunSession.air_wall_bottom = $air_wall/down.position.y
	RunSession.air_wall_left = $air_wall/left.position.x
	RunSession.air_wall_right = $air_wall/right.position.x
	print("top")
	print($air_wall/top.position.y)
	print(RunSession.air_wall_top)
var pauseing: bool = false
var pause_id: int
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):

			pause_id = G.get_gui_view_manager().open_view("PauseMenu")

	if event.is_action_pressed("clockup"):
		if Engine.time_scale >0.8:
			Engine.time_scale = 0.1
		else:
			Engine.time_scale = 1.0

func _open() -> void:
	player_var.new_scene()
	RunSession.SpawnManager = $SpawnManager
	player_var.is_uping = false

	for i in 0:
		var dummm: Node = preload("res://scene/enemys/dummy/dummy.tscn").instantiate()
		dummm.position.x += 2*100
		$SpawnManager.add_mob(dummm)

	RunSession.worldenvir = $WorldEnvironment

	for i in  2:
		for j in 5:
			summonhappy(Vector2(48*(i-10),30*(j-10)))
var tname: String = 'enm_memhappy'
var mobpre: PackedScene = PresetManager.getpre(tname)
func summonhappy(p: Vector2) -> void:

	if mobpre == null:
		return
	var mob: Node2D = mobpre.instantiate()
	mob.global_position = p
	mob.mob_info = table.Enemy[tname].duplicate()
	mob.drop_num = 1.0
	RunSession.SpawnManager.add_mob(mob)


func _close() -> void:

	AudioManager.stop_background_bgm()




func open() -> void:

	_open()


func close() -> void:
	_close()


func close_self() -> void:
	G.get_gui_view_manager().close_view(viewInstanceId)
	# 清理所有计时器
	player_var._clear_all_tweens()
