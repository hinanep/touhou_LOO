extends TextureRect

var selfname = ''
var id = ''
var level = 0
var upgrade_group
var cpable = []

func _ready() -> void:
	SignalBus.focus_on.connect(detact_focus)
	SignalBus.focus_off.connect(set_highlight.bind(false))

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


func destroy(did):
	if id == did:
		queue_free()

func upgrade(upname):
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
