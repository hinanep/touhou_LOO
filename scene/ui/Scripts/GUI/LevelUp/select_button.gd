extends TextureButton

signal upgrade_selected
func set_upgrade_text(upgrage):
	$weapon.text = upgrage
func _on_button_up():
	emit_signal("upgrade_selected")
	pass # Replace with function body.
	
