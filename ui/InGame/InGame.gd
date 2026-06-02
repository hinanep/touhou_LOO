extends BaseGUIView

@onready var _warmup_overlay: Control = $WarmupLoadingLayer/WarmupLoadingOverlay

func _ready() -> void:
	G.get_gui_view_manager().open_view("Hud")
	AudioManager.play_background_bgm("music_bgm_oldworld")
	await scene_init()
	RunSession.tmp_scene = $"."
var pauseing: bool = false
var pause_id: int
var first: bool = true


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
		if first:
			table.dialogues = table.stage1_before
		else:
			table.dialogues = table.stage1_after

		first = !first
		print_debug(table.dialogues)
		G.get_gui_view_manager().open_view("DialogueMenu")


func _open() -> void:
	RunSession.worldenvir = $WorldEnvironment


func _close() -> void:
	AudioManager.stop_background_bgm()
	if RunSession.SpawnManager != null:
		RunSession.SpawnManager.clear()
	# 清理所有计时器
	RunSession.clear_tweens()



func open() -> void:
	RunSession.air_wall_top = $air_wall/top.position.y
	RunSession.air_wall_bottom = $air_wall/down.position.y
	RunSession.air_wall_left = $air_wall/left.position.x
	RunSession.air_wall_right = $air_wall/right.position.x
	_open()


func close() -> void:
	_close()

func close_self() -> void:

	G.get_gui_view_manager().close_view(viewInstanceId)

func scene_init() -> void:
	player_var.new_scene()
	SignalBus.try_add_skill.emit("ski_basemagic")
	SignalBus.try_add_skill.emit("ski_basephysics")
	SignalBus.try_add_card.emit("sc_daiyousei")
	$SpawnManager.spawnmanager_init('Stage1')
	RunSession.SpawnManager = $SpawnManager
	_show_warmup_overlay()
	await get_tree().process_frame
	await get_tree().process_frame
	_hide_warmup_overlay()


## 显示开局预热遮罩并暂停局内逻辑
func _show_warmup_overlay() -> void:
	_warmup_overlay.show()
	player_var.request_game_pause()


## 隐藏开局预热遮罩并恢复局内逻辑
func _hide_warmup_overlay() -> void:
	_warmup_overlay.hide()
	player_var.release_game_pause()

func lock_camera() -> void:
	var camera:Camera2D = get_viewport().get_camera_2d()
	#camera.position_smoothing_enabled = true
	camera.limit_bottom = RunSession.air_wall_bottom
	camera.limit_left = RunSession.air_wall_left
	camera.limit_right = RunSession.air_wall_right
	camera.limit_top = RunSession.air_wall_top

func _on_end_game_timeout() -> void:



	while true:
		var interval: SceneTreeTimer = get_tree().create_timer(1,false)
		await interval.timeout
		interval = null
		if RunSession.SpawnManager.mob_dic.is_empty():
			SignalBus.shutter.emit()

			player_var.boss_coming('keine')
			return
