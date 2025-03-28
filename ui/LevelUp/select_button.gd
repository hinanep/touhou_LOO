extends TextureButton

signal upgrade_selected
func _ready() -> void:
	pass
func set_text(type,id):
	var newlevel
	var upgroup
	$describe.text = "[color=white]"
	match type:
		'skill':
			newlevel = player_var.SkillManager.get_skill_level(id)+1
			upgroup = table.Skill[id].upgrade_group
			$weapon.text =table.TID[id][player_var.language]+" Lv."+String.num(newlevel )

		'card':
			newlevel = player_var.CardManager.get_card_level(id)+1
			upgroup = table.SpellCard[id].upgrade_group
			$weapon.text =table.TID[id][player_var.language]+" Lv."+String.num(newlevel )
		'passive':
			newlevel = player_var.PassiveManager.get_passive_level(id)+1
			upgroup = table.Passive[id].upgrade_group
			$weapon.text =table.TID[id][player_var.language]+" Lv."+String.num(newlevel )
	if newlevel == 1:
		$describe.text = "[color=white]"+table.TID[id+'_dsc'][player_var.language]
	else:

		for upkey in table.Upgrade[upgroup]:
			try_upgrade_text(upgroup,newlevel,upkey)

func try_upgrade_text(upgroup,newlevel,property):
	if table.Upgrade[upgroup].has(property) and table.Upgrade[upgroup][property] is Array:
		if property == 'buff_addition':
			$describe.text += table.TID[property][player_var.language] + ' ' + str(table.Upgrade[upgroup][property][newlevel-1])+'\n'
			return
		if table.Upgrade[upgroup][property][newlevel-1] != table.Upgrade[upgroup][property][newlevel-2]:
			$describe.text += table.TID[property][player_var.language] + ' ' +str(table.Upgrade[upgroup][property][newlevel-2]) + '->' + str(table.Upgrade[upgroup][property][newlevel-1])+'\n'


func _on_button_up():
	emit_signal("upgrade_selected")



func _on_focus_entered():
	$describe.visible = true
	$describe/AnimatedSprite2D.visible = true




func _on_focus_exited():
	$describe.visible = false
	$describe/AnimatedSprite2D.visible = false
