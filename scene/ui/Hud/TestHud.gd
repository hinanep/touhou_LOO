extends BaseGUIView
var type = "waza"
var tname = ""
func _ready():
	for ucwaza in WazaManager.waza_pool.unchoosed:
		var wz = WazaManager.waza_pool.unchoosed[ucwaza]
		var waza_button = PresetManager.getpre("ui_test_wazabutton").instantiate()
		$testhud/waza_container.add_child(waza_button)
		waza_button.set_texture(wz.waza_image)
		waza_button.set_tooltip_text(wz.waza_name)
		waza_button.selected.connect(on_wazabutton_select.bind(wz.waza_name))


func on_wazabutton_select(wazaname):
	type = "waza"
	tname = wazaname
	print(tname)
	


func _on_update_pressed():
	match type:
		"waza":
			WazaManager.add_waza(tname)
			pass
		"cp":
			pass
		"passive":
			pass
		"card":
			pass
	pass # Replace with function body.


func _on_delete_pressed():
	match type:
		"waza":
			WazaManager.del_waza(tname)
			pass
		"cp":
			pass
		"passive":
			pass
		"card":
			pass
	pass # Replace with function body.
