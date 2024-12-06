extends BaseGUIView
var type = "none"
var tname = ""
func _ready():
	for ucwaza in WazaManager.waza_pool.unchoosed:
		var wz = WazaManager.waza_pool.unchoosed[ucwaza]
		var waza_button = PresetManager.getpre("ui_test_wazabutton").instantiate()
		$testhud/waza_container.add_child(waza_button)
		waza_button.set_texture(wz.waza_image)
		waza_button.set_tooltip_text(wz.waza_name)
		waza_button.selected.connect(on_wazabutton_select.bind(wz.waza_name))
		
	for uccard in CardManager.card_pool.unchoosed:
		var cd = CardManager.card_pool.unchoosed[uccard]
		var card_button = PresetManager.getpre("ui_test_wazabutton").instantiate()
		$testhud/card_container.add_child(card_button)
		card_button.set_texture(cd.card_image)
		card_button.set_tooltip_text(cd.cn)
		card_button.selected.connect(on_cardbutton_select.bind(cd.card_name))


func on_wazabutton_select(wazaname):
	$testhud/Button.grab_focus()
	type = "waza"
	tname = wazaname


func on_cardbutton_select(cardname):
	$testhud/Button.grab_focus()
	type = "card"
	tname = cardname

	


func _on_update_pressed():
	match type:
		"waza":
			WazaManager.add_waza(tname)
			
		"cp":
			pass
		"passive":
			pass
		"card":
			CardManager.add_card(tname)
			
		"none":
			pass
	$testhud/Button.grab_focus()
	pass # Replace with function body.


func _on_delete_pressed():
	match type:
		"waza":
			WazaManager.del_waza(tname)
			
		"cp":
			pass
		"passive":
			pass
		"card":
			CardManager.del_card(tname)
		"none":
			pass
	$testhud/Button.grab_focus()
	pass # Replace with function body.


func _on_levelup_pressed():
	GameManager.level_up()
	$testhud/Button.grab_focus()
	pass # Replace with function body.


func _on_moremana_pressed():
	GameManager.add_power(player_var.power_max)
	$testhud/Button.grab_focus()
	pass # Replace with function body.
