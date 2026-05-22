extends BaseGUIView

const _AUTO_CLOSE_SEC := 3.0

var _closing: bool = false
@onready var dim = $CanvasLayer/dim
@onready var body = $CanvasLayer/panel/margin/vbox/body



func _ready() -> void:
	$auto_close_timer.wait_time = _AUTO_CLOSE_SEC
	$auto_close_timer.one_shot = true
	if dim.has_signal("gui_input"):
		dim.gui_input.connect(_on_dim_gui_input)


## 打开：冻结局内并填充结算文案
func _open() -> void:
	_closing = false
	get_tree().paused = true
	_fill_from_payload()
	$auto_close_timer.start()


## 关闭：解冻并通知 UfoManager 播 VFX、结束事件
func _close() -> void:
	if get_tree().paused:
		get_tree().paused = false
	_notify_manager_closed()


func _fill_from_payload() -> void:
	var payload: Dictionary = _fetch_payload()
	if payload.is_empty():
		body.text = _tid_text("ufo_settlement_title")
		return
	var ledger: Dictionary = payload.get("ledger", {})
	var display: Dictionary = payload.get("display", {})
	var lines: PackedStringArray = PackedStringArray()
	lines.append(_tid_text("ufo_settlement_title"))
	lines.append("")
	var frag_n := int(ledger.get("fragment_count", 0))
	lines.append(_tid_format("ufo_settlement_fragments", [frag_n]))
	lines.append(
		_tid_format(
			"ufo_settlement_exp",
			[
				int(display.get("exp_final", 0)),
				str(display.get("exp_mul", 1.0)),
				str(player_var.experience_ratio),
			]
		)
	)
	lines.append(
		_tid_format(
			"ufo_settlement_mana",
			[
				int(display.get("mana_final", 0)),
				str(display.get("mana_mul", 1.0)),
				str(player_var.mana_ratio),
			]
		)
	)
	lines.append(
		_tid_format(
			"ufo_settlement_score",
			[
				int(display.get("score_final", 0)),
				str(display.get("score_mul", 1.0)),
				str(player_var.point_ratio),
			]
		)
	)
	lines.append("")
	var cp_id: String = str(payload.get("cp_id", ""))
	if cp_id != "":
		lines.append(_tid_text("ufo_settlement_cp_header"))
		lines.append("  · " + _resolve_entry_name(cp_id))
	var upgrade_ids: Array = payload.get("upgrade_ids", [])
	if upgrade_ids.size() > 0:
		lines.append(_tid_text("ufo_settlement_upgrade_header"))
		for up_id in upgrade_ids:
			lines.append("  · " + _resolve_entry_name(str(up_id)))
	var legacy_key: String = str(display.get("legacy_line_tid_key", ""))
	if legacy_key != "":
		lines.append("")
		lines.append(_tid_text(legacy_key))
	lines.append("")
	lines.append(_tid_text("ufo_settlement_skip_hint"))
	body.text = "\n".join(lines)



func _fetch_payload() -> Dictionary:
	if RunSession.SpawnManager == null or not is_instance_valid(RunSession.SpawnManager):
		return {}
	var mgr := RunSession.SpawnManager.get_node_or_null("UfoManager")
	if mgr != null and mgr.has_method("get_settlement_payload"):
		return mgr.get_settlement_payload()
	return {}


func _resolve_entry_name(entry_id: String) -> String:
	if entry_id == "":
		return ""
	if table.TID.has(entry_id):
		return table.TID[entry_id][player_var.language]
	return entry_id


func _tid_text(key: String) -> String:
	if table.TID.has(key):
		return str(table.TID[key][player_var.language])
	return key


func _tid_format(key: String, args: Array) -> String:
	var template := _tid_text(key)
	if args.is_empty():
		return template
	return template % args


func _on_dim_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close_self()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed():
		close_self()


func _on_continue_pressed() -> void:
	close_self()


func _on_auto_close_timer_timeout() -> void:
	close_self()


func close_self() -> void:
	if _closing:
		return
	_closing = true
	if is_instance_valid($auto_close_timer):
		$auto_close_timer.stop()
	G.get_gui_view_manager().close_view(viewInstanceId)


func _notify_manager_closed() -> void:
	if RunSession.SpawnManager == null or not is_instance_valid(RunSession.SpawnManager):
		return
	var mgr := RunSession.SpawnManager.get_node_or_null("UfoManager")
	if mgr != null and mgr.has_method("on_settlement_closed"):
		mgr.on_settlement_closed()
