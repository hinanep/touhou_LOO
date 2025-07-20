extends TextureButton

signal upgrade_selected
var b_type = ''
var b_id = ''
func _ready() -> void:
	pass

func set_text(type,id):
	var newlevel:int
	var upgroup
	$describe.text = "[color=white]"
	set_crystal_texture('img_'+id)
	b_type = type
	b_id = id
	match type:
		'skill':
			self_modulate = Color('ffd1d1')
			newlevel = player_var.SkillManager.get_skill_level(id)+1
			upgroup = table.Skill[id].upgrade_group
			if newlevel == 1:
				$weapon.text =table.TID[id][player_var.language]+"  [color=red]New!!!"

			else:
				$weapon.text =table.TID[id][player_var.language]+" Lv."+str(newlevel-1)+'->'+str(newlevel)

		'card':
			self_modulate = Color('daffd1')
			newlevel = player_var.CardManager.get_card_level(id)+1
			upgroup = table.SpellCard[id].upgrade_group
			if newlevel == 1:
				$weapon.text =table.TID[id][player_var.language]+"  [color=red]New!!!"
			else:
				$weapon.text =table.TID[id][player_var.language]+" Lv."+str(newlevel-1)+'->'+str(newlevel)
		'passive':
			self_modulate = Color('d1f1ff')
			newlevel = player_var.PassiveManager.get_passive_level(id)+1
			upgroup = table.Passive[id].upgrade_group
			if newlevel == 1:
				$weapon.text =table.TID[id][player_var.language]+"  [color=red]New!!!"
			else:
				$weapon.text =table.TID[id][player_var.language]+" Lv."+str(newlevel-1)+'->'+str(newlevel)
	if newlevel == 1:
		$describe.text += table.TID[id+'_dsc'][player_var.language]
	for upkey in table.Upgrade[upgroup]:
		try_upgrade_text(id,upgroup,newlevel,upkey)
	$icon.set_texture(PresetManager.getpre('img_'+type+'_icon'))
func try_upgrade_text(id,upgroup,newlevel,property):


	if table.Upgrade[upgroup].has(property) and table.Upgrade[upgroup][property] is Array:
		#如果这是一个被动技能
		if property == 'buff_addition':
			#等级1时被动技能只需要显示buff基础数值
			if newlevel == 1:
				$describe.text += ' '+str( table.Buff[ table.Passive[id].buff[0] ].base_buff_value )
				return
			#技能描述
			$describe.text += " [color=white]"+table.TID[id+'_dsc'][player_var.language]
			#添加buff基础数值
			$describe.text +=' ' + str( table.Buff[ table.Passive[id].buff[0] ].base_buff_value * table.Upgrade[upgroup][property][newlevel-1])
			#本次升级技能倍率
			#$describe.text += '\n '+table.TID[property][player_var.language] + ' ' + str(table.Upgrade[upgroup][property][newlevel-1])+'x\n'
			return
		if table.Upgrade[upgroup][property][newlevel-1] != table.Upgrade[upgroup][property][newlevel-2]:
			if newlevel == 1:
				return
			$describe.text += ' '+table.TID[property][player_var.language] + ' ' +str(table.Upgrade[upgroup][property][newlevel-2]) + '->' + str(table.Upgrade[upgroup][property][newlevel-1])+'\n'

func set_crystal_texture(image):
	if image!=null:
		$crystal.set_texture(PresetManager.getpre(image))

func _on_button_up():
	emit_signal("upgrade_selected")



func _on_focus_entered():
	if b_type == 'passive':
		get_parent().get_parent().get_parent().set_property_change(b_id)
	#$describe.visible = true
	#$describe/AnimatedSprite2D.visible = true




func _on_focus_exited():
	if b_type == 'passive':
		get_parent().get_parent().get_parent().set_property_change('')
	#$describe.visible = false
	#$describe/AnimatedSprite2D.visible = false
