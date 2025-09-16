extends BaseGUIView
func _ready():
	G.get_gui_view_manager().open_view("Hud")
	G.get_gui_view_manager().open_view("TestHud")
	AudioManager.play_background_bgm("music_bgm_oldworld")
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

	player_var.worldenvir = $WorldEnvironment

	for i in  20:
		for j in 20:
			summonhappy(Vector2(48*(i-10),30*(j-10)))
var tname = 'enm_memhappy'
var mobpre = PresetManager.getpre(tname)
func summonhappy(p) -> void:

	if mobpre == null:
		return
	var mob = mobpre.instantiate()
	mob.global_position = p
	mob.mob_info = table.Enemy[tname].duplicate()
	mob.drop_num = 1.0
	player_var.SpawnManager.add_mob(mob)


func _close():

	AudioManager.stop_background_bgm()




func open():
	_open()


func close():
	_close()


func close_self():
	G.get_gui_view_manager().close_view(viewInstanceId)
	# 清理所有计时器
	player_var._clear_all_tweens()
