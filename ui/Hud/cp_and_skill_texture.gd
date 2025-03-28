extends TextureRect

var selfname = ''
var id = ''
var level = 0
var upgrade_group

func set_skill(skill_info):
		id = skill_info.id

		selfname = table.TID[id][player_var.language]
		upgrade_group = skill_info.upgrade_group

		set_texture(PresetManager.getpre('img_'+id))
		$RichTextLabel.text = selfname

		SignalBus.del_skill.connect(destroy)
		SignalBus.upgrade_group.connect(upgrade)

func set_cp(cp_info):
		id = cp_info.id
		selfname = id
		#selfname = table.TID[id][player_var.language]
		upgrade_group =null
		set_texture(PresetManager.getpre('img_'+id))
		$RichTextLabel.text = selfname
		SignalBus.cp_del.connect(destroy)



func destroy(did):
	if id == did:
		queue_free()

func upgrade(upname):
	if upgrade_group == upname:
		level += 1
		$RichTextLabel.text = selfname + 'LV.' + str(level)
