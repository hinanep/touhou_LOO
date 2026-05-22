extends enemy_base
## 飞碟事件敌怪：吸收期吸入记忆碎片并入账；击破由 UfoManager 结算。

const _DEFAULT_ABSORB_MAX_DURATION := 2.5
const _DEFAULT_HP_PER_FRAGMENT := 8.0
const _ABSORB_TWEEN_SEC := 0.35
const _COLORFUL_HUE_STEP := 2
const _COLORFUL_HUE_MOD := 256
const _COLORFUL_ANIM := &"all"
const _COLORFUL_SPRITE_S := 0.67
const _COLORFUL_SPRITE_V := 0.9
const _COLORFUL_LIGHT_S := 0.5
const _COLORFUL_LIGHT_V := 1.0
const _COLORFUL_FRAME_TICKS := 10

## 运行时状态：与表配置、吸收批次及 UfoManager 协作相关字段
## @ufo_color 事件颜色 1=红 2=绿 3=蓝 4=彩，由 UfoManager 生成时赋值
## @absorb_phase 是否处于吸收期；数值在吸收开始时一次性入账
## @_ufo_manager UfoManager 节点引用，用于入账与击破通知
## @_absorb_visual_running 是否正在播放批量吸入 tween
## @_pending_destroy 动画结束后待 queue_free 的掉落物
## @_absorb_max_duration 吸收期最长秒数（兜底结束吸收阶段）
## @_hp_per_fragment 按场上碎片数增加的最大生命系数
var ufo_color: int = 1
var absorb_phase: bool = true
var _ufo_manager: Node = null
var _absorb_visual_running: bool = false
var _pending_destroy: Array = []
var _absorb_max_duration: float = _DEFAULT_ABSORB_MAX_DURATION
var _hp_per_fragment: float = _DEFAULT_HP_PER_FRAGMENT
var _colorful_hue: int = 0
var _colorful_frame: int = 0
var _colorful_frame_tick: int = 0
var _colorful_active: bool = false

@onready var _absorb_duration_timer: Timer = $absorb_duration_timer
@onready var light_layer: AnimatedSprite2D = $light


## 节点就绪：补全 mob_info、读表调参、禁用离屏秒杀并延迟开启吸收阶段
## @return 无
func _ready() -> void:
	if mob_info.is_empty():
		mob_info = {"id": "enm_ufo", "type": "ufo", "movement": "static", "health": 500.0, "speed": 0.0}
	mob_info["type"] = "ufo"
	mob_info["movement"] = "static"
	_read_tuning_from_mob_info()
	drops_path = ""
	super._ready()
	if has_node("outscreen_disppear"):
		$outscreen_disppear.stop()
	_apply_color_visual()
	call_deferred("_start_absorb_phase")


## 注入 UfoManager，供吸收入账与击破回调
## @param mgr UfoManager 节点
## @return 无
func set_ufo_manager(mgr: Node) -> void:
	_ufo_manager = mgr


## 是否仍处于吸收阶段
## @return 吸收中为 true
func has_active_absorb_phase() -> bool:
	return absorb_phase


## 判断节点是否为可吸收的记忆碎片（exp/mana/point，非钥匙、未飞向玩家）
## @param node drops 子节点
## @return 可吸收为 true
func _is_absorbable_drop(node: Node) -> bool:
	if not node is drop:
		return false
	if node.is_in_group("treasure_chests"):
		return false
	if node.is_physics_processing():
		return false
	return true


## 从 mob_info 读取吸收期调参，缺省用脚本常量
## @return 无
func _read_tuning_from_mob_info() -> void:
	if mob_info.has("absorb_max_duration"):
		_absorb_max_duration = float(mob_info["absorb_max_duration"])
	if mob_info.has("hp_per_fragment"):
		_hp_per_fragment = float(mob_info["hp_per_fragment"])


## 按 ufo_color 设置精灵与光晕表现
func _apply_color_visual() -> void:
	if ufo_color == 4:
		_start_colorful_visual()
	else:
		_apply_non_colorful_visual()


## 红/绿/蓝飞碟：隐藏 light，sprite 恢复白色并切换对应动画
func _apply_non_colorful_visual() -> void:
	_stop_colorful_visual()
	match ufo_color:
		1:
			sprite.animation = &"red"
		2:
			sprite.animation = &"green"
		3:
			sprite.animation = &"blue"
		_:
			pass
	sprite.modulate = Color.WHITE


## 彩色飞碟：显示 light、停止自动播放，启用 HSV 与手动帧
func _start_colorful_visual() -> void:
	_colorful_hue = 0
	_colorful_frame = 0
	_colorful_frame_tick = 0
	sprite.animation = _COLORFUL_ANIM
	sprite.stop()
	sprite.frame = 0
	light_layer.visible = true
	light_layer.animation = _COLORFUL_ANIM
	light_layer.stop()
	light_layer.frame = 0
	_colorful_active = true
	sprite.modulate = Color.from_hsv(0.0, _COLORFUL_SPRITE_S, _COLORFUL_SPRITE_V)
	light_layer.modulate = Color.from_hsv(0.0, _COLORFUL_LIGHT_S, _COLORFUL_LIGHT_V)
	set_process(true)


## 关闭彩色飞碟 HSV 循环与 light，并将 sprite 恢复为默认白色
func _stop_colorful_visual() -> void:
	_colorful_active = false
	set_process(false)
	if is_instance_valid(sprite):
		sprite.modulate = Color.WHITE
	if is_instance_valid(light_layer):
		light_layer.visible = false


func _process(_delta: float) -> void:
	if not _colorful_active:
		return
	_apply_colorful_hsv_and_frame()


## 每帧：H 0..255 步进 +2；每 10 帧 sprite/light 的 frame +1
func _apply_colorful_hsv_and_frame() -> void:
	_colorful_hue = (_colorful_hue + _COLORFUL_HUE_STEP) % _COLORFUL_HUE_MOD
	var hue := float(_colorful_hue) / 255.0
	sprite.modulate = Color.from_hsv(hue, _COLORFUL_SPRITE_S, _COLORFUL_SPRITE_V)
	light_layer.modulate = Color.from_hsv(hue, _COLORFUL_LIGHT_S, _COLORFUL_LIGHT_V)
	if sprite.sprite_frames == null or light_layer.sprite_frames == null:
		return
	var frame_count := sprite.sprite_frames.get_frame_count(_COLORFUL_ANIM)
	if frame_count <= 0:
		return
	_colorful_frame_tick += 1
	if _colorful_frame_tick < _COLORFUL_FRAME_TICKS:
		return
	_colorful_frame_tick = 0
	_colorful_frame = (_colorful_frame + 1) % frame_count
	sprite.frame = _colorful_frame
	var light_frame_count := light_layer.sprite_frames.get_frame_count(_COLORFUL_ANIM)
	if light_frame_count > 0:
		light_layer.frame = _colorful_frame % light_frame_count


## 开启吸收：扫描碎片、抬 HP、一次性入账，并并行播放吸入动画
## @return 无
func _start_absorb_phase() -> void:
	absorb_phase = true
	var candidates: Array = _collect_absorb_candidates()
	_apply_hp_from_fragment_count(candidates.size())
	_commit_absorb_ledger(candidates)
	_absorb_duration_timer.wait_time = _absorb_max_duration
	_absorb_duration_timer.one_shot = true
	_absorb_duration_timer.start()
	_run_absorb_visuals_batch(candidates)


## 根据场上可吸收碎片数量抬高当前 HP
## @param fragment_count 候选碎片数量
## @return 无
func _apply_hp_from_fragment_count(fragment_count: int) -> void:
	var base_hp := float(mob_info.get("health", hp))
	hp = base_hp + _hp_per_fragment * float(fragment_count)
	mob_info["health"] = hp
	progress_bar.value = 100.0


## 收集 SpawnManager/drops 下全部可吸收碎片
## @return drop 节点数组
func _collect_absorb_candidates() -> Array:
	var result: Array = []
	var drops_root := _get_drops_root()
	if drops_root == null:
		return result
	for child in drops_root.get_children():
		if _is_absorbable_drop(child):
			result.append(child)
	return result


## 获取掉落物父节点
## @return drops 节点，不可用则为 null
func _get_drops_root() -> Node:
	if RunSession.SpawnManager == null or not is_instance_valid(RunSession.SpawnManager):
		return null
	return RunSession.SpawnManager.get_node_or_null("drops")


## 吸收开始时一次性写入 UfoManager 账本（逻辑与动画分离）
## @param candidates 可吸收 drop 列表
## @return 无
func _commit_absorb_ledger(candidates: Array) -> void:
	for node in candidates:
		if not is_instance_valid(node) or not node is drop:
			continue
		var piece := node as drop
		var exp_v := float(piece.experience) * float(piece.value)
		var mana_v := float(piece.mana) * float(piece.value)
		var score_v := float(piece.score) * float(piece.value)
		if _ufo_manager != null and _ufo_manager.has_method("add_to_ledger"):
			_ufo_manager.add_to_ledger(exp_v, mana_v, score_v, 1)
		else:
			push_warning("[ufo_enemy] UfoManager 未注入，碎片数值未入账")


## 关闭掉落物交互与融合，仅保留可被 tween 的显示
## @param piece 目标 drop
## @return 无
func _prepare_drop_for_absorb_visual(piece: drop) -> void:
	piece.not_fusioning = false
	piece.set_physics_process(false)
	piece.monitoring = false
	piece.monitorable = false
	piece.collision_layer = 0
	piece.collision_mask = 0
	if piece.has_node("AnimationPlayer"):
		var anim_player: AnimationPlayer = piece.get_node("AnimationPlayer")
		if anim_player is AnimationPlayer:
			anim_player.stop()


## 并行 tween 将所有碎片拉向飞碟，结束后隐藏并进入待销毁序列
## @param candidates 可吸收 drop 列表
## @return 无
func _run_absorb_visuals_batch(candidates: Array) -> void:
	var valid: Array[drop] = []
	for node in candidates:
		if is_instance_valid(node) and node is drop:
			valid.append(node as drop)
	if valid.is_empty():
		if absorb_phase:
			_end_absorb_phase()
		return
	_absorb_visual_running = true
	_pending_destroy.clear()
	var tween := create_tween()
	tween.set_parallel(true)
	RunSession.underrecycle_tween.append(tween)
	for piece in valid:
		_prepare_drop_for_absorb_visual(piece)
		_pending_destroy.append(piece)
		tween.tween_property(piece, "global_position", global_position, _ABSORB_TWEEN_SEC)
	await tween.finished
	_finalize_absorb_visuals()
	_absorb_visual_running = false
	if absorb_phase:
		_end_absorb_phase()


## 动画结束：隐藏节点并 queue_free（不再参与碰撞/融合）
## @return 无
func _finalize_absorb_visuals() -> void:
	var pending: Array = _pending_destroy.duplicate()
	_pending_destroy.clear()
	for piece in pending:
		if not is_instance_valid(piece):
			continue
		piece.visible = false
		piece.process_mode = Node.PROCESS_MODE_DISABLED
		piece.queue_free()


## 吸收最长时长到达，强制结束吸收期
## @return 无
func _on_absorb_duration_timer_timeout() -> void:
	_end_absorb_phase()


## 结束吸收期；若动画仍在播也标记结束
## @return 无
func _end_absorb_phase() -> void:
	if not absorb_phase:
		return
	absorb_phase = false
	if _absorb_duration_timer.time_left > 0.0:
		_absorb_duration_timer.stop()


## 击破或清场时停止吸收相关定时器
## @return 无
func _cleanup_absorb_timers() -> void:
	if is_instance_valid(_absorb_duration_timer):
		_absorb_duration_timer.stop()


## 死亡入口：清场消失不走结算，玩家击破走 UfoManager
## @param disppear 为 true 时表示 kill_all/离屏清怪，不掉落、不结算
## @return 无
func died(disppear: bool = false) -> void:
	if disppear:
		_stop_colorful_visual()
		_cleanup_absorb_timers()
		_flush_pending_destroy()
		emit_signal("die", mob_id)
		call_deferred("queue_free")
		return
	_finish_player_kill()


## 玩家击破：通知 UfoManager 并移除自身，不触发 plate 掉落
## @return 无
func _finish_player_kill() -> void:
	_stop_colorful_visual()
	invincible = true
	atkable = false
	set_physics_process(false)
	_cleanup_absorb_timers()
	_flush_pending_destroy()
	_cleanup_connections()
	var ledger: Dictionary = {}
	if _ufo_manager != null and _ufo_manager.has_method("get_ledger"):
		ledger = _ufo_manager.get_ledger()
	if _ufo_manager != null and _ufo_manager.has_method("notify_killed"):
		_ufo_manager.notify_killed(ledger, global_position)
	emit_signal("die", mob_id)
	queue_free()


## 立即销毁尚未完成的吸收表现节点
## @return 无
func _flush_pending_destroy() -> void:
	for piece in _pending_destroy:
		if is_instance_valid(piece):
			piece.queue_free()
	_pending_destroy.clear()


## 覆盖基类掉落，飞碟事件不再掉落钥匙
## @return 无
func drop() -> void:
	pass


## 离屏时仅更新标记，不启动 outscreen_disppear 秒杀
## @return 无
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	is_inscreen = false


## 覆盖基类离屏超时，飞碟不传送、不消失
## @return 无
func _on_outscreen_disppear_timeout() -> void:
	pass
