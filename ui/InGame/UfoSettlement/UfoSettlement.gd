extends BaseGUIView

const _MIN_DISPLAY_SEC := 1.0
const _AUTO_CLOSE_SEC := 10.0
const _UNIT_MUL_EPS := 1e-5
const _COLORFUL_HUE_STEP := 2
const _COLORFUL_HUE_MOD := 256
const _COLORFUL_RAINBOW_S := 0.67
const _COLORFUL_RAINBOW_V := 0.9

@export var body_font_size: int = 18

var _closing: bool = false
var _open_time_msec: int = 0
@onready var dim = $CanvasLayer/dim
@onready var body = $CanvasLayer/panel/margin/vbox/body


func _ready() -> void:
	$auto_close_timer.wait_time = _AUTO_CLOSE_SEC
	$auto_close_timer.one_shot = true
	if dim.has_signal("gui_input"):
		dim.gui_input.connect(_on_dim_gui_input)
	_apply_body_text_style()


## 打开：冻结局内并填充结算文案
func _open() -> void:
	_closing = false
	_open_time_msec = Time.get_ticks_msec()
	player_var.request_game_pause()
	_fill_from_payload()
	$auto_close_timer.start()


## 关闭：先结算入账（可能打开升级界面），再释放本界面暂停引用
func _close() -> void:
	_notify_manager_closed()
	player_var.release_game_pause()


func _fill_from_payload() -> void:
	var payload: Dictionary = _fetch_payload()
	if payload.is_empty():
		body.text = ""
		return
	var ledger: Dictionary = payload.get("ledger", {})
	var display: Dictionary = payload.get("display", {})
	var ufo_color: int = int(payload.get("color", 0))
	var lines: PackedStringArray = PackedStringArray()
	var frag_n := int(ledger.get("fragment_count", 0))
	lines.append(_ui_tid_format("ufo_settlement_fragments", [frag_n]))
	_append_reward_lines(lines, display, ufo_color)
	var cp_id: String = str(payload.get("cp_id", ""))
	var upgrade_ids: Array = payload.get("upgrade_ids", [])
	if cp_id != "":
		lines.append("")
		lines.append(_ui_tid_text("ufo_settlement_cp_header"))
		lines.append(_resolve_entry_name(cp_id))
		var dsc_key := cp_id + "_dsc"
		if table.TID.has(dsc_key):
			lines.append(_tid_text(dsc_key))
	elif upgrade_ids.size() > 0:
		lines.append("")
		lines.append(_ui_tid_text("ufo_settlement_upgrade_header"))
		var names: PackedStringArray = PackedStringArray()
		for up_id in upgrade_ids:
			names.append(_resolve_entry_name(str(up_id)))
		lines.append(" ".join(names))
	var legacy_key: String = str(display.get("legacy_line_tid_key", ""))
	if legacy_key != "":
		lines.append("")
		lines.append(_format_legacy_line(legacy_key, display, ufo_color))
	body.text = _center_bbcode_lines(lines)


## 正文 RichTextLabel：水平/垂直居中，字号由 body_font_size 控制
func _apply_body_text_style() -> void:
	if not is_instance_valid(body):
		return
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body.add_theme_font_size_override("normal_font_size", body_font_size)
	body.add_theme_font_size_override("bold_font_size", body_font_size)


## 多行 BBCode 逐行居中
func _center_bbcode_lines(lines: PackedStringArray) -> String:
	if lines.is_empty():
		return ""
	var centered: PackedStringArray = PackedStringArray()
	for line in lines:
		if line.is_empty():
			centered.append("")
		else:
			centered.append("[center]" + line + "[/center]")
	return "\n".join(centered)


## 按 display 账本底数追加经验/符力/分数公式行（底数>0 才输出）
func _append_reward_lines(lines: PackedStringArray, display: Dictionary, ufo_color: int) -> void:
	var exp_base := float(display.get("exp_base", 0))
	if exp_base > 0.0:
		lines.append(
			_format_gain_line(
				"ufo_settlement_exp",
				"exp",
				exp_base,
				float(display.get("exp_mul", 1.0)),
				player_var.experience_ratio,
				float(display.get("exp_final", 0)),
				ufo_color
			)
		)
	var mana_base := float(display.get("mana_base", 0))
	if mana_base > 0.0:
		lines.append(
			_format_gain_line(
				"ufo_settlement_mana",
				"mana",
				mana_base,
				float(display.get("mana_mul", 1.0)),
				player_var.mana_ratio,
				float(display.get("mana_final", 0)),
				ufo_color
			)
		)
	var score_base := float(display.get("score_base", 0))
	if score_base > 0.0:
		lines.append(
			_format_gain_line(
				"ufo_settlement_score",
				"score",
				score_base,
				float(display.get("score_mul", 1.0)),
				player_var.point_ratio,
				float(display.get("score_final", 0)),
				ufo_color
			)
		)


## 拼获得奖励行；仅飞碟颜色倍率段上色
func _format_gain_line(
	prefix_tid_key: String,
	stat: String,
	base: float,
	color_mul: float,
	player_mul: float,
	final: float,
	ufo_color: int
) -> String:
	var prefix := _ui_tid_text(prefix_tid_key)
	var has_color_mul := not _is_unit_multiplier(color_mul)
	var has_player_mul := not _is_unit_multiplier(player_mul)
	if not has_color_mul and not has_player_mul:
		if abs(base - final) < _UNIT_MUL_EPS:
			return prefix + _fmt_num(final)
		return prefix + _fmt_num(base) + "=" + _fmt_num(final)
	var result := prefix + _fmt_num(base)
	if has_color_mul:
		var mul_seg := "x" + _fmt_num(color_mul)
		if _should_color_color_mul(ufo_color, stat):
			mul_seg = _wrap_ufo_bbcolor(mul_seg, ufo_color)
		result += mul_seg
	if has_player_mul:
		result += "x" + _fmt_num(player_mul)
	return result + "=" + _fmt_num(final)


func _should_color_color_mul(ufo_color: int, stat: String) -> bool:
	match ufo_color:
		1:
			return stat == "exp"
		2:
			return stat == "mana"
		3:
			return stat == "score"
		4:
			return true
		_:
			return false


func _wrap_ufo_bbcolor(text: String, ufo_color: int) -> String:
	if ufo_color == 4:
		return _wrap_rainbow_bb(text)
	match ufo_color:
		1:
			return "[color=red]" + text + "[/color]"
		2:
			return "[color=green]" + text + "[/color]"
		3:
			return "[color=blue]" + text + "[/color]"
		_:
			return text


## 静态彩虹 BBCode（色相步进与局内彩飞碟一致）
func _wrap_rainbow_bb(text: String) -> String:
	if text.is_empty():
		return ""
	var out := ""
	var hue := 0
	for i in text.length():
		var ch := text.substr(i, 1)
		var col := Color.from_hsv(
			float(hue % _COLORFUL_HUE_MOD) / float(_COLORFUL_HUE_MOD),
			_COLORFUL_RAINBOW_S,
			_COLORFUL_RAINBOW_V
		)
		out += "[color=#" + col.to_html(false) + "]" + ch + "[/color]"
		hue += _COLORFUL_HUE_STEP
	return out


func _is_unit_multiplier(v: float) -> bool:
	return abs(v - 1.0) < _UNIT_MUL_EPS


func _fmt_num(v: float) -> String:
	if abs(v - round(v)) < _UNIT_MUL_EPS:
		return str(int(round(v)))
	var rounded: float = round(v * 100.0) / 100.0
	if abs(rounded - round(rounded)) < _UNIT_MUL_EPS:
		return str(int(round(rounded)))
	return "%.2f" % rounded


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


func _ui_tid_text(key: String) -> String:
	if table.TID_UI.has(key):
		return str(table.TID_UI[key][player_var.language])
	return key


func _ui_tid_format(key: String, args: Array) -> String:
	var template := _ui_tid_text(key)
	if args.is_empty():
		return template
	if template.find("{") != -1:
		return template.format(args)
	if args.size() == 1:
		return template % args[0]
	return template % args


func _tid_text(key: String) -> String:
	if table.TID.has(key):
		return str(table.TID[key][player_var.language])
	return key


func _format_legacy_line(legacy_key: String, display: Dictionary, ufo_color: int) -> String:
	var plain: String
	if legacy_key == "ufo_settlement_legacy_blue" or legacy_key == "ufo_settlement_legacy_colorful":
		var delta: float = float(display.get("legacy_blue_point_ratio_delta", 0.0))
		plain = _ui_tid_format(legacy_key, [str(delta)])
	else:
		plain = _ui_tid_text(legacy_key)
	if ufo_color >= 1 and ufo_color <= 4:
		return _wrap_ufo_bbcolor(plain, ufo_color)
	return plain


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


func _can_close_now() -> bool:
	return Time.get_ticks_msec() - _open_time_msec >= int(_MIN_DISPLAY_SEC * 1000.0)


func close_self() -> void:
	if _closing or not _can_close_now():
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
