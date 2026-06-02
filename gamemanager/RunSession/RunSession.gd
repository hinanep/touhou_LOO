extends Node
## 单局运行时会话：记忆结晶 Manager、刷怪、场景绑定、Boss 演出与局内 Tween 回收。

var SkillManager: SkillManagers
var CardManager: CardManagers
var PassiveManager: PassiveManagers
var CpManager: CpManagers
var SpawnManager: SpawnManagers
var MonsterAvoidanceManager: Node

var tmp_scene: Node
var worldenvir: WorldEnvironment
var air_wall_top: float
var air_wall_bottom: float
var air_wall_left: float
var air_wall_right: float
var underrecycle_tween: Array[Tween] = []
var need_glow: int = 0
## Boss 战进行中；供 Attack 从对象池取出时同步透明度
var is_boss_stage: bool = false


## 新局开始：清空局内修饰并重建各 Manager
func begin_run() -> void:
	is_boss_stage = false
	RunModifiers.clear()
	_destroy_managers()
	SkillManager = SkillManagers.new()
	CardManager = CardManagers.new()
	PassiveManager = PassiveManagers.new()
	CpManager = CpManagers.new()
	MonsterAvoidanceManager = get_node('/root/MonsterAvoidanceManager')
	MonsterAvoidanceManager.Reset()


## 回主菜单或放弃本局：释放 Manager 与场景引用
func end_run() -> void:
	is_boss_stage = false
	clear_tweens()
	if SpawnManager != null and is_instance_valid(SpawnManager):
		SpawnManager.clear()
	_destroy_managers()
	tmp_scene = null
	worldenvir = null
	SpawnManager = null
	need_glow = 0


func clear_tweens() -> void:
	for tween in underrecycle_tween:
		if tween is Tween and tween.is_valid():
			tween.kill()
	underrecycle_tween.clear()


func _destroy_managers() -> void:
	if SkillManager != null:
		SkillManager.destroy()
		SkillManager.free()
		SkillManager = null
	if CardManager != null:
		CardManager.destroy()
		CardManager.free()
		CardManager = null
	if PassiveManager != null:
		PassiveManager.destroy()
		PassiveManager.free()
		PassiveManager = null
	if CpManager != null:
		CpManager.destroy()
		CpManager.free()
		CpManager = null


## Boss 入场：镜头、空气墙、刷 Boss
func boss_coming(id: String) -> void:
	_dismiss_active_ufos_for_boss()
	SignalBus.kill_all.emit()
	var mv: Tween = player_var.player_node.create_tween()
	underrecycle_tween.append(mv)
	var tmpcamera: Camera2D = get_viewport().get_camera_2d()
	tmpcamera.top_level = true
	mv.set_parallel()
	mv.tween_property(player_var.player_node, 'global_position', Vector2(-400, 0), 0.1)
	mv.tween_property(tmpcamera, 'global_position', Vector2(0, 0), 0.1)
	var viewport_size: Vector2 = Vector2(1920, 1080)
	await mv.finished
	air_wall_bottom = viewport_size.y / 2
	air_wall_top = -viewport_size.y / 2
	air_wall_left = -viewport_size.x / 2
	air_wall_right = viewport_size.x / 2
	if tmp_scene != null:
		tmp_scene.get_node('air_wall/left').position.x = -viewport_size.x / 2
		tmp_scene.get_node('air_wall/right').position.x = viewport_size.x / 2
		tmp_scene.get_node('air_wall/top').position.y = -viewport_size.y / 2
		tmp_scene.get_node('air_wall/down').position.y = viewport_size.y / 2
	lock_camera()
	var boss: Node2D = PresetManager.getpre(id).instantiate() as Node2D
	boss.boss_init(id)
	boss.position = Vector2(2000, 1000)
	SpawnManager.add_mob(boss)
	mv = boss.create_tween()
	underrecycle_tween.append(mv)
	mv.tween_property(boss, 'global_position', Vector2(600, 0), 3)
	await mv.finished
	boss.fight_begin()
	is_boss_stage = true
	SignalBus.boss_stage.emit(true)


## Boss 入场前无结算清场未击破飞碟
func _dismiss_active_ufos_for_boss() -> void:
	if SpawnManager == null or not is_instance_valid(SpawnManager):
		return
	var ufo_mgr := SpawnManager.get_node_or_null("UfoManager")
	if ufo_mgr != null and ufo_mgr.has_method("dismiss_all_active_ufos"):
		ufo_mgr.dismiss_all_active_ufos()


func lock_camera() -> void:
	var tmpcamera: Camera2D = get_viewport().get_camera_2d()
	if tmpcamera == null:
		return
	tmpcamera.limit_bottom = int(air_wall_bottom * 2)
	tmpcamera.limit_left = int(air_wall_left * 2)
	tmpcamera.limit_right = int(air_wall_right * 2)
	tmpcamera.limit_top = int(air_wall_top * 2)


func screen_black(intensity: float, in_time: float, duration_time: float, out_time: float) -> void:
	if player_var.player_node == null:
		return
	var black_mo: CanvasItem = player_var.player_node.get_node('black') as CanvasItem
	var blacking: Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	underrecycle_tween.append(blacking)
	blacking.tween_property(black_mo, 'modulate', Color(1, 1, 1, intensity), in_time)
	blacking.tween_interval(duration_time)
	blacking.tween_property(black_mo, 'modulate', Color(1, 1, 1, 0), out_time)


func require_env_glowing(getin: bool) -> void:
	if worldenvir == null:
		return
	if getin:
		need_glow += 1
		worldenvir.environment.set_glow_enabled(true)
	else:
		need_glow -= 1
		if need_glow <= 0:
			need_glow = 0
			worldenvir.environment.set_glow_enabled(false)
