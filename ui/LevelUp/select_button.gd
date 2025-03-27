extends TextureButton

signal upgrade_selected
func _ready() -> void:
	pass
func set_text(type,id):
	match type:
		'skill':
			$weapon.text =table.TID[id][player_var.language]+" Lv."+String.num(player_var.SkillManager.get_skill_level(id)+1)
		'card':
			$weapon.text =table.TID[id][player_var.language]+" Lv."+String.num(player_var.CardManager.get_card_level(id)+1)
		'passive':
			$weapon.text =table.TID[id][player_var.language]+" Lv."+String.num(player_var.PassiveManager.get_passive_level(id)+1)
	$describe.text = "[color=white]"+table.TID[id+'_dsc'][player_var.language]


func _on_button_up():
	emit_signal("upgrade_selected")



func _on_focus_entered():
	$describe.visible = true
	$AnimatedSprite2D.visible = true




func _on_focus_exited():
	$describe.visible = false
	$AnimatedSprite2D.visible = false
