extends TextureRect

enum IconType { CARD, SKILL, CP, PASSIVE }
var icon_type: IconType = IconType.SKILL

var selfname = ''
var id = ''
var level = 0
var upgrade_group
var cpable = []
# 符卡专用，供 Hud.card_display 使用
var cardname = ''
var describe = ''
var manacost = 0

var _red_x_label: Label
var _label_node: Control

func _ready() -> void:
	_red_x_label = get_node_or_null("redx") as Label
	_label_node = get_node_or_null("RichTextLabel") as Control

	_label_node = get_node_or_null("cn") as Control

	if _red_x_label:
		_red_x_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		_red_x_label.offset_left = 0
		_red_x_label.offset_top = 0
		_red_x_label.offset_right = 0
		_red_x_label.offset_bottom = 0
		# 按图标尺寸统一红叉相对大小，避免技能(120)与符卡(400)表现不一致
		var icon_size = min(size.x, size.y)
		if icon_size <= 0:
			icon_size = 120
		_red_x_label.add_theme_font_size_override("font_size", int(icon_size * 0.4))
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	SignalBus.focus_on.connect(detact_focus)
	SignalBus.focus_off.connect(set_highlight.bind(false))
	SignalBus.delete_mode.connect(delete_mode_toggle)

var delete_mode :bool= false
var is_holding :bool= false
var shake_amount =  0 # 抖动强度
@export var delete_time: float = 1.5 # 需长按多久触发删除
var hold_timer: float = 0.0

func _process(delta: float) -> void:
	if delete_mode:
		# 删除模式下所有类型（含 CARD）都使用抖动 shader
		shake_amount = 2.5
		set_instance_shader_parameter("shake_strength", shake_amount)
		if is_holding:
			hold_timer += delta
			var progress_val = hold_timer / delete_time
			set_instance_shader_parameter("progress", progress_val)
			shake_amount = 2.5 * (1.0 + progress_val)
			if hold_timer >= delete_time:
				SignalBus.delete_mode.emit(false, true)
				print("execute del")
				delete_mode = false
				if _label_node:
					_label_node.hide()
				set_instance_shader_parameter("is_boob", true)
				var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
				tween.tween_method(
					func(val): set_instance_shader_parameter("boob_progress", val),
					0.0, 0.1, 0.5
				).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				await tween.finished
				match icon_type:
					IconType.SKILL:
						SignalBus.del_skill.emit(id)
						SignalBus.ban_skill.emit(id)
					IconType.CARD:
						SignalBus.del_card.emit(id)
						SignalBus.ban_card.emit(id)
					IconType.PASSIVE:
						SignalBus.del_passive.emit(id)
						SignalBus.ban_passive.emit(id)
					IconType.CP:
						SignalBus.cp_del.emit(id)
		else:
			hold_timer = lerp(hold_timer, 0.0, delta * 10)
			set_instance_shader_parameter("progress", hold_timer / delete_time)
			shake_amount = 0

func _on_focus_entered() -> void:
	if delete_mode and _red_x_label:
		_red_x_label.visible = true

func _on_focus_exited() -> void:
	if _red_x_label:
		_red_x_label.visible = false

# 监听鼠标输入与键盘交互键
func out_of_delete_mode():
	shake_amount = 0
	set_instance_shader_parameter("shake_strength", shake_amount)
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_holding = event.pressed
			if not is_holding:
				hold_timer = 0.0 # 松开重置
	elif delete_mode and event is InputEventKey:
		if event.is_action("ui_accept"):
			is_holding = event.pressed
			if not is_holding:
				hold_timer = 0.0
			accept_event()

func set_card(card_info) -> void:
	icon_type = IconType.CARD
	id = card_info.id
	cardname = table.TID[card_info.id + "_name"][player_var.language]
	describe = "[center]" + cardname
	manacost = card_info.mana
	upgrade_group = card_info.upgrade_group
	cpable = player_var.CpManager.get_cpable_array(id)
	set_texture(PresetManager.getpre("img_" + id))
	if _label_node:
		_label_node.text = "[center]" + cardname
	SignalBus.del_card.connect(destroy)
	SignalBus.upgrade_group.connect(upgrade)

func set_skill(skill_info):
	icon_type = IconType.SKILL
	id = skill_info.id
	cpable = player_var.CpManager.get_cpable_array(id)
	selfname = table.TID[id][player_var.language]
	upgrade_group = skill_info.upgrade_group
	set_texture(PresetManager.getpre("img_" + id))
	if _label_node:
		_label_node.text = "[center]" + selfname
	SignalBus.del_skill.connect(destroy)
	SignalBus.upgrade_group.connect(upgrade)

func set_cp(cp_info):
	icon_type = IconType.CP
	id = cp_info.id
	selfname = table.TID[id][player_var.language]
	upgrade_group = null
	set_texture(PresetManager.getpre("img_" + id))
	if _label_node:
		_label_node.text = "[center]" + selfname
	SignalBus.cp_del.connect(destroy)

func set_psv(psv_info):
	icon_type = IconType.PASSIVE
	id = psv_info.id
	selfname = table.TID[id][player_var.language]
	upgrade_group = psv_info.upgrade_group
	set_texture(PresetManager.getpre("img_" + id))
	if _label_node:
		_label_node.text = "[center]" + selfname
	SignalBus.del_passive.connect(destroy)
	SignalBus.upgrade_group.connect(upgrade)

func delete_mode_toggle(on:bool,complete:bool):
	delete_mode = on
	if on:
		if has_focus() and _red_x_label:
			_red_x_label.visible = true
	else:
		# 退出删除模式：CARD 还原为原 bloom（无抖动），其他类型同样重置抖动参数
		set_instance_shader_parameter("shake_strength", 0)
		set_instance_shader_parameter("progress", 0)
		if _red_x_label:
			_red_x_label.visible = false
func destroy(did):
	if id == did:
		queue_free()

func upgrade(upname, currentLevel):
	if upgrade_group != upname or (icon_type == IconType.CARD and upgrade_group == "none"):
		return
	level += 1
	if _label_node:
		if icon_type == IconType.CARD:
			describe = cardname + "\nLV." + str(level)
			_label_node.text = "[center]LV." + str(level)
		else:
			_label_node.text = "[center]LV." + str(level)

func detact_focus(type,id):
	if id in cpable:
		set_highlight(true)
func set_highlight(is_hl):
	if is_hl:
		set_instance_shader_parameter("brightness",0.8)
		set_instance_shader_parameter("width",11.0)

	else:
		set_instance_shader_parameter("brightness",0.0)
		set_instance_shader_parameter("width",0.0)
