extends Node
class_name UfoManager
## 局内飞碟事件编排：监听生成/击破信号，维护账本，击破后消弹、结算；羁绊即时，随机升级在击破时立即应用；红/彩碟 legacy 额外选取直开 LevelUp，左侧悬浮窗仅展示。
## 挂于 InGame/SpawnManager/UfoManager；依赖 SignalBus 信号名 ufo_spawn_requested、ufo_killed（须在 SignalBus.gd 声明后类型检查才完整）。

const _SIGNAL_SPAWN := &"ufo_spawn_requested"
const _SIGNAL_KILLED := &"ufo_killed"
const _UFO_ENEMY_TABLE_ID := "enm_ufo"
const _VFX_PARTICLE_CAP := 20
var _active_ufos: Array[Node] = []
var _ufo_scene: PackedScene = null
var _ufo_mob_info_template: Dictionary = {}
var settlement_payload: Dictionary[String, Variant] = {}
var _settlement_kill_position: Vector2 = Vector2.ZERO

@export var ufo_enemy_preset_id: String = _UFO_ENEMY_TABLE_ID


func _ready() -> void:
	_init_ufo_prefab()
	_connect_bus_signal(_SIGNAL_SPAWN, _on_ufo_spawn_requested)
	_connect_bus_signal(_SIGNAL_KILLED, _on_ufo_killed)


## 初始化时加载飞碟预制体与 Enemy 表行模板，召唤时只 instantiate
func _init_ufo_prefab() -> void:
	_ufo_scene = null
	_ufo_mob_info_template = {}
	if not PresetManager.preset_map.has(ufo_enemy_preset_id):
		push_error(
			"[UfoManager] PresetManager 无预制体 '%s'，请先配置 ufo_enemy 场景" % ufo_enemy_preset_id
		)
		return
	var loaded: Resource = PresetManager.getpre(ufo_enemy_preset_id)
	if loaded == null or not loaded is PackedScene:
		push_error("[UfoManager] 预制体 '%s' 未加载或不是 PackedScene" % ufo_enemy_preset_id)
		return
	_ufo_scene = loaded
	if table.Enemy.has(ufo_enemy_preset_id):
		_ufo_mob_info_template = table.Enemy[ufo_enemy_preset_id].duplicate()
	else:
		push_warning("[UfoManager] table.Enemy 无 '%s'，使用最小 mob_info" % ufo_enemy_preset_id)
		_ufo_mob_info_template = {"id": ufo_enemy_preset_id}


## 是否仍有进行中的飞碟（可多只并存）
func has_active_ufo() -> bool:
	_prune_active_ufos()
	return not _active_ufos.is_empty()


func _prune_active_ufos() -> void:
	for i in range(_active_ufos.size() - 1, -1, -1):
		if not is_instance_valid(_active_ufos[i]):
			_active_ufos.remove_at(i)


func _register_active_ufo(ufo: Node) -> void:
	if ufo == null:
		return
	_prune_active_ufos()
	if ufo not in _active_ufos:
		_active_ufos.append(ufo)


func _unregister_active_ufo(ufo: Node) -> void:
	if ufo == null:
		return
	var idx := _active_ufos.find(ufo)
	if idx >= 0:
		_active_ufos.remove_at(idx)


## Boss 入场等：无结算清掉所有未击破飞碟（先出活跃表再 died(true)，避免 die 回退误结算）
func dismiss_all_active_ufos() -> void:
	_prune_active_ufos()
	var snapshot: Array[Node] = _active_ufos.duplicate()
	for ufo in snapshot:
		_unregister_active_ufo(ufo)
		if ufo == null or not is_instance_valid(ufo):
			continue
		if ufo.has_method("died"):
			ufo.died(true)
		else:
			ufo.queue_free()
	_clear_hostile_danmaku()
	settlement_payload = {}
	_settlement_kill_position = Vector2.ZERO
	_close_settlement_views()


## 关闭所有 UfoSettlement 悬浮窗
func _close_settlement_views() -> void:
	if G == null:
		return
	var vm: GUIViewManager = G.get_gui_view_manager()
	if vm == null:
		return
	var to_close: Array[int] = []
	for instance_id in vm.viewInstanceMap.keys():
		var view: BaseGUIView = vm.viewInstanceMap[instance_id]
		if view.config.id == &"UfoSettlement":
			to_close.append(instance_id)
	for instance_id in to_close:
		vm.close_view(instance_id)


func _connect_bus_signal(signal_name: StringName, callable: Callable) -> void:
	if not SignalBus.has_signal(signal_name):
		push_error("[UfoManager] SignalBus 缺少信号: %s" % signal_name)
		return
	var err := SignalBus.connect(signal_name, callable)
	if err != OK:
		push_error("[UfoManager] 连接 %s 失败: %s" % [signal_name, err])


## 拾钥匙后：生成飞碟并登记活跃引用（多只飞碟可并存）
func _on_ufo_spawn_requested(color: int, pickup_position: Vector2) -> void:
	if color < 1 or color > 4:
		push_warning("[UfoManager] 无效 color=%s，应为 1..4" % color)
		return
	var ufo := _spawn_ufo(color, pickup_position)
	if ufo == null:
		return
	_register_active_ufo(ufo)
	_bind_ufo_to_manager(ufo)


## 飞碟被击破：消弹 → 符力/得分入账 → 羁绊即时/升级预选 → 经验入账与 VFX → 左侧结算悬浮窗（定时消失）
func _on_ufo_killed(ufo: Node, ledger: Dictionary, color: int, kill_global_position: Vector2) -> void:
	if ufo == null or not is_instance_valid(ufo):
		return
	_prune_active_ufos()
	if ufo not in _active_ufos:
		return
	_unregister_active_ufo(ufo)
	if ledger.is_empty():
		ledger = {}
	else:
		ledger = ledger.duplicate()
	if color < 1 or color > 4:
		if "ufo_color" in ufo:
			color = int(ufo.ufo_color)
	_settlement_kill_position = kill_global_position
	_clear_hostile_danmaku()
	var display: Dictionary[String, Variant] = _compute_settlement_display(ledger, color)
	var pending_ledger_exp: float = _compute_pending_ledger_exp(ledger, color)
	var bonus_pick: bool = _has_bonus_pick(color)
	_apply_ledger_and_legacy(ledger, color)
	var extra: Dictionary[String, Variant] = _apply_cp_or_upgrades()
	_build_settlement_payload(ledger, color, extra, display, pending_ledger_exp, bonus_pick)
	_show_settlement_ui()
	_apply_kill_rewards()



func _spawn_ufo(color: int, pickup_position: Vector2) -> Node:
	var spawn_mgr := _get_spawn_manager()
	if spawn_mgr == null:
		push_error("[UfoManager] RunSession.SpawnManager 不可用")
		return null
	if _ufo_scene == null:
		push_error("[UfoManager] 飞碟预制体未初始化，检查 _init_ufo_prefab")
		return null
	var ufo: Node = _ufo_scene.instantiate()
	if "mob_info" in ufo:
		ufo.mob_info = _ufo_mob_info_template.duplicate(true)
	ufo.set("ufo_color", color)
	ufo.global_position = pickup_position
	spawn_mgr.add_mob(ufo)
	if ufo.has_method("_apply_color_visual"):
		ufo.call_deferred("_apply_color_visual")
	return ufo


## 将管理器引用交给飞碟（ufo_enemy 击破时发 SignalBus.ufo_killed 或调 notify_killed）
func _bind_ufo_to_manager(ufo: Node) -> void:
	if ufo.has_method("set_ufo_manager"):
		ufo.set_ufo_manager(self)
	if ufo.has_signal("die") and not ufo.die.is_connected(_on_ufo_die_fallback):
		ufo.die.connect(_on_ufo_die_fallback.bind(ufo))


func _on_ufo_die_fallback(_mob_id: int, ufo: Node) -> void:
	if ufo == null or not is_instance_valid(ufo) or ufo not in _active_ufos:
		return
	var ledger: Dictionary = {}
	var color: int = 1
	if "ufo_color" in ufo:
		color = int(ufo.ufo_color)
	if ufo.has_method("get_absorb_ledger"):
		ledger = ufo.get_absorb_ledger()
	var pos: Vector2 = ufo.global_position
	_emit_killed(ufo, ledger, color, pos)


## 击破时由 ufo_enemy 调用，统一走 SignalBus 击破信号
func notify_killed(
	ufo: Node,
	ledger: Dictionary = {},
	color: int = 0,
	kill_position: Vector2 = Vector2.ZERO
) -> void:
	_emit_killed(ufo, ledger, color, kill_position)


func _emit_killed(ufo: Node, ledger: Dictionary, color: int, kill_global_position: Vector2) -> void:
	if SignalBus.has_signal(_SIGNAL_KILLED):
		SignalBus.ufo_killed.emit(ufo, ledger, color, kill_global_position)
	else:
		_on_ufo_killed(ufo, ledger, color, kill_global_position)


func _get_spawn_manager() -> SpawnManagers:
	if RunSession.SpawnManager != null and is_instance_valid(RunSession.SpawnManager):
		return RunSession.SpawnManager
	return null


func _get_d4c_root() -> Node:
	var spawn_mgr := _get_spawn_manager()
	if spawn_mgr == null:
		return null
	if spawn_mgr.has_node("d4c"):
		return spawn_mgr.get_node("d4c")
	return null


## 遍历 SpawnManager/d4c 下敌对弹幕并 disable
func _clear_hostile_danmaku() -> void:
	var d4c_root := _get_d4c_root()
	if d4c_root == null:
		return
	_clear_danmaku_recursive(d4c_root)


func _clear_danmaku_recursive(node: Node) -> void:
	if node is danma and node.has_method("disable"):
		node.disable(false)
	for child in node.get_children():
		_clear_danmaku_recursive(child)


## 按颜色从 Global 表取账本倍率
func _get_color_multipliers(color: int) -> Dictionary[String, Variant]:
	var red_rate: float = table.get_global_variable("red_ufo_rate", 2.0)
	var green_rate: float = table.get_global_variable("green_ufo_rate", 2.0)
	var blue_rate: float = table.get_global_variable("blue_ufo_rate", 2.0)
	var exp_mul := 1.0
	var mana_mul := 1.0
	var score_mul := 1.0
	match color:
		1:
			exp_mul = red_rate
		2:
			mana_mul = green_rate
		3:
			score_mul = blue_rate
		4:
			exp_mul = red_rate
			mana_mul = green_rate
			score_mul = blue_rate
		_:
			pass
	return {"exp_mul": exp_mul, "mana_mul": mana_mul, "score_mul": score_mul}


## 蓝碟 legacy：按吸收碎片数计算得点倍率增量
func _compute_blue_point_ratio_delta(fragment_count: int) -> float:
	var coeff: float = table.get_global_variable("blue_ufo_pv_coefficient", 0.01)
	return float(fragment_count) * coeff


## 红/彩碟 legacy：额外升级选取（不灌经验，结算后直开 LevelUp）
func _has_bonus_pick(color: int) -> bool:
	return color == 1 or color == 4


## 击破时立即施加的颜色 legacy（红/彩经验除外）
func _apply_color_legacy(color: int, fragment_count: int) -> void:
	var blue_delta := _compute_blue_point_ratio_delta(fragment_count)
	match color:
		2:
			player_var.free_card += 1
		3:
			player_var.point_ratio += blue_delta
		4:
			player_var.free_card += 1
			player_var.point_ratio += blue_delta
		_:
			pass


## 结算面板 legacy 文案 TID key
func _get_legacy_tid_key(color: int) -> String:
	match color:
		1:
			return "ufo_settlement_legacy_red"
		2:
			return "ufo_settlement_legacy_green"
		3:
			return "ufo_settlement_legacy_blue"
		4:
			return "ufo_settlement_legacy_colorful"
		_:
			return ""


## 账本经验击破时发放；符力/得分与即时 legacy 击破时入账
func _compute_pending_ledger_exp(ledger: Dictionary, color: int) -> float:
	var mul := _get_color_multipliers(color)
	var exp_base := float(ledger.get("exp", 0))
	return exp_base * float(mul["exp_mul"]) * player_var.experience_ratio


func _apply_ledger_and_legacy(ledger: Dictionary, color: int) -> void:
	var mul := _get_color_multipliers(color)
	var mana_base := float(ledger.get("mana", 0))
	var score_base := float(ledger.get("score", 0))
	player_var.mana += mana_base * float(mul["mana_mul"]) * player_var.mana_ratio
	player_var.point += score_base * float(mul["score_mul"]) * player_var.point_ratio
	_apply_color_legacy(color, int(ledger.get("fragment_count", 0)))


## 击破一次：随机羁绊（立即激活），失败则预选三次升级
func _apply_cp_or_upgrades() -> Dictionary[String, Variant]:
	var result: Dictionary[String, Variant] = {"cp_id": "", "upgrade_ids": [], "upgrade_picks": []}
	var actived_before: Array = []
	if RunSession.CpManager != null:
		actived_before = RunSession.CpManager.cp_pool.actived.keys()
	if RunSession.CpManager != null and RunSession.CpManager.random_choose_cp():
		for cpid in RunSession.CpManager.cp_pool.actived.keys():
			if cpid not in actived_before:
				result["cp_id"] = str(cpid)
				break
	else:
		for _i in 3:
			var pick := _pick_upgrade_once()
			if pick.is_empty():
				continue
			var up_id := str(pick.get("id", ""))
			if up_id != "":
				result["upgrade_ids"].append(up_id)
				result["upgrade_picks"].append(pick.duplicate())
	return result


## 随机预选一次升级，返回 { id, kind }，无可用项则返回空字典（不 emit）
func _pick_upgrade_once() -> Dictionary[String, Variant]:
	var selected: Dictionary[String, String] = RandomPool.random_nselect_from_have(1)
	if selected.is_empty():
		return {}
	for id in selected:
		var kind := str(selected[id])
		if kind == "skill" or kind == "card" or kind == "passive":
			return {"id": str(id), "kind": kind}
	return {}


## 应用单次预选升级
func _apply_upgrade_pick(pick: Dictionary[String, Variant]) -> void:
	var entry_id := str(pick.get("id", ""))
	if entry_id == "":
		return
	match str(pick.get("kind", "")):
		"skill":
			SignalBus.try_add_skill.emit(entry_id)
		"card":
			SignalBus.try_add_card.emit(entry_id)
		"passive":
			SignalBus.try_add_passive.emit(entry_id)
		_:
			pass


## 击破结算时应用待处理的随机升级
func _apply_pending_upgrades(picks: Array) -> void:
	for pick in picks:
		if pick is Dictionary:
			_apply_upgrade_pick(pick)


## 按账本与颜色预计算面板展示数值（入账前调用）
func _compute_settlement_display(ledger: Dictionary, color: int) -> Dictionary[String, Variant]:
	var mul := _get_color_multipliers(color)
	var exp_mul := float(mul["exp_mul"])
	var mana_mul := float(mul["mana_mul"])
	var score_mul := float(mul["score_mul"])
	var exp_base := float(ledger.get("exp", 0))
	var mana_base := float(ledger.get("mana", 0))
	var score_base := float(ledger.get("score", 0))
	var fragment_count := int(ledger.get("fragment_count", 0))
	var blue_pv_delta := 0.0
	if color == 3 or color == 4:
		blue_pv_delta = _compute_blue_point_ratio_delta(fragment_count)
	return {
		"exp_base": exp_base,
		"mana_base": mana_base,
		"score_base": score_base,
		"exp_final": exp_base * exp_mul * player_var.experience_ratio,
		"mana_final": mana_base * mana_mul * player_var.mana_ratio,
		"score_final": score_base * score_mul * player_var.point_ratio,
		"exp_mul": exp_mul,
		"mana_mul": mana_mul,
		"score_mul": score_mul,
		"legacy_line_tid_key": _get_legacy_tid_key(color),
		"legacy_blue_point_ratio_delta": blue_pv_delta,
	}


## 组装传给 UfoSettlement 的 payload
func _build_settlement_payload(
	ledger: Dictionary,
	color: int,
	extra: Dictionary,
	display: Dictionary,
	pending_ledger_exp: float,
	bonus_pick: bool
) -> void:
	settlement_payload = {
		"ledger": ledger.duplicate(),
		"color": color,
		"cp_id": str(extra.get("cp_id", "")),
		"upgrade_ids": extra.get("upgrade_ids", []).duplicate(),
		"upgrade_picks": extra.get("upgrade_picks", []).duplicate(true),
		"display": display.duplicate(),
		"pending_ledger_exp": pending_ledger_exp,
		"bonus_pick": bonus_pick,
	}


## 供 UfoSettlement 读取
func get_settlement_payload() -> Dictionary[String, Variant]:
	return settlement_payload.duplicate(true)


## 打开左侧结算悬浮窗；未注册时跳过展示（入账由击破流程统一处理）
func _show_settlement_ui() -> void:
	if G == null or G.get_gui_view_manager() == null:
		return
	var vm := G.get_gui_view_manager()
	if not vm.has_method("open_view"):
		return
	if not vm.viewConfigMap.has("UfoSettlement"):
		return
	vm.open_view("UfoSettlement")


## 击破后发放经验、预选升级与 bonus，并清空 payload（与结算窗关闭无关）
func _apply_kill_rewards() -> void:
	if settlement_payload.is_empty():
		return
	var ledger: Dictionary = settlement_payload.get("ledger", {})
	var color: int = int(settlement_payload.get("color", 0))
	var kill_pos := _settlement_kill_position
	var pending_ledger_exp: float = float(settlement_payload.get("pending_ledger_exp", 0.0))
	var bonus_pick: bool = bool(settlement_payload.get("bonus_pick", false))
	var upgrade_picks: Array = settlement_payload.get("upgrade_picks", []).duplicate(true)
	settlement_payload = {}
	_settlement_kill_position = Vector2.ZERO
	if pending_ledger_exp > 0.0:
		player_var.player_exp += pending_ledger_exp
	if not upgrade_picks.is_empty():
		_apply_pending_upgrades(upgrade_picks)
	if bonus_pick:
		player_var.request_bonus_upgrade_select()
	_play_capped_fly_vfx(ledger, color, kill_pos)


## 代表粒子：主数值已入账，仅触发飞向自机的拾取表现
func _play_capped_fly_vfx(_ledger: Dictionary, color: int, _kill_global_position: Vector2) -> void:
	pass
