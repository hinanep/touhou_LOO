extends TextureButton

signal selected
var point
#func set_upgrade_text(upgrage):
	#$weapon.text = upgrage
#func set_describe_text(describe):
	#$describe.text = "[color=white]"+describe
func set_texture(image):
	if image!=null:
		set_texture_normal(PresetManager.getpre(image))
	size = Vector2(1400,1400)

func _on_button_up():
	emit_signal("selected")
	point.global_position = global_position



#
#func _on_focus_entered():
	#$describe.visible = true
	#$AnimatedSprite2D.visible = true
	#pass # Replace with function body.
#
#
#func _on_focus_exited():
	#$describe.visible = false
	#$AnimatedSprite2D.visible = false
	#pass # Replace with function body.
