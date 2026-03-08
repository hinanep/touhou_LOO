extends TextureRect

var selfname = ''
var id = ''
var level = 0
var upgrade_group
var cpable = []

func _ready() -> void:
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
		shake_amount = 2.5
		set_instance_shader_parameter("shake_strength", shake_amount)
		if is_holding:
			hold_timer += delta
			var progress = hold_timer / delete_time
			# 更新 Shader 参数
			set_instance_shader_parameter("progress", progress)
			# 进度越高，抖动越剧烈
			shake_amount = 2.5 * (1+progress)

			if hold_timer >= delete_time:
				SignalBus.delete_mode.emit(false)
				print("execute del")

				$RichTextLabel.hide()
				delete_mode = false

				set_instance_shader_parameter("is_boob", true)
				var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
				tween.tween_method(
									func(val): set_instance_shader_parameter("boob_progress", val),
									0.0,  # 起始值
									0.1,  # 结束值
									0.5   # 时长
								).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

				# 动画完成后自动销毁
				await  tween.finished

				SignalBus.del_skill.emit(id)
				SignalBus.del_passive.emit(id)
				SignalBus.cp_del.emit(id)



		else:
			# 松开后快速回弹重置（可选）
			hold_timer = lerp(hold_timer, 0.0, delta * 10)
			set_instance_shader_parameter("progress", hold_timer / delete_time)
			shake_amount = 0

# 监听鼠标输入
func out_of_delete_mode():
	shake_amount = 0
	set_instance_shader_parameter("shake_strength", shake_amount)
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_holding = event.pressed
			if not is_holding:
				hold_timer = 0.0 # 松开重置
func set_skill(skill_info):
		id = skill_info.id
		cpable = player_var.CpManager.get_cpable_array(id)
		selfname = table.TID[id][player_var.language]
		upgrade_group = skill_info.upgrade_group

		set_texture(PresetManager.getpre('img_'+id))
		$RichTextLabel.text ='[center]'+ selfname

		SignalBus.del_skill.connect(destroy)
		SignalBus.cp_del.connect(destroy)
		SignalBus.del_passive.connect(destroy)
		SignalBus.upgrade_group.connect(upgrade)

func set_cp(cp_info):
		id = cp_info.id

		selfname = table.TID[id][player_var.language]
		upgrade_group =null
		set_texture(PresetManager.getpre('img_'+id))
		$RichTextLabel.text ='[center]'+ selfname
		SignalBus.cp_del.connect(destroy)

func set_psv(psv_info):
		id = psv_info.id

		selfname = table.TID[id][player_var.language]
		upgrade_group = psv_info.upgrade_group

		set_texture(PresetManager.getpre('img_'+id))
		$RichTextLabel.text ='[center]'+ selfname


		SignalBus.del_passive.connect(destroy)
		SignalBus.upgrade_group.connect(upgrade)

func delete_mode_toggle(on:bool):
	delete_mode = on
func destroy(did):
	if id == did:
		queue_free()

func upgrade(upname,currentLevel):
	if upgrade_group == upname:
		level += 1
		#$RichTextLabel.text ='[center]'+ selfname + '\nLV.' + str(level)
		$RichTextLabel.text ='[center]' + 'LV.' + str(level)

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
