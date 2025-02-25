extends BaseGUIView
var type = "none"
var tname = ""
func _ready():
	for ucskill in table.Skill:
		var ski = table.Skill[ucskill]
		var skill_button = PresetManager.getpre("ui_test_skillbutton").instantiate()
		$testhud/skill_container.add_child(skill_button)
		skill_button.set_texture('img_'+ski.id)
		skill_button.set_tooltip_text(ski.id)
		skill_button.selected.connect(on_skillbutton_select.bind(ski.id))

	for uccard in table.SpellCard:
		var cd = table.SpellCard[uccard]
		var card_button = PresetManager.getpre("ui_test_skillbutton").instantiate()
		$testhud/card_container.add_child(card_button)
		card_button.set_texture('img_'+cd.id)
		card_button.set_tooltip_text(cd.id)
		card_button.selected.connect(on_cardbutton_select.bind(cd.id))

	for uccp in CpManager.cp_pool.unactive:
		var cp = CpManager.cp_pool.unactive[uccp]
		var cp_button = PresetManager.getpre("ui_test_skillbutton").instantiate()
		$testhud/cp_container.add_child(cp_button)
		cp_button.set_texture(cp.cp_image)
		cp_button.set_tooltip_text(cp.cn)
		cp_button.selected.connect(on_cpbutton_select.bind(cp.name))

func on_skillbutton_select(skillname):
	$testhud/Button.grab_focus()
	type = "skill"
	tname = skillname


func on_cardbutton_select(cardname):
	$testhud/Button.grab_focus()
	type = "card"
	tname = cardname

func on_cpbutton_select(cpname):
	$testhud/Button.grab_focus()
	type = "cp"
	tname = cpname



func _on_update_pressed():
	match type:
		"skill":
			SignalBus.try_add_skill.emit(tname)

		"cp":
			CpManager.add_cp(tname)
			pass
		"passive":
			pass
		"card":
			SignalBus.try_add_card.emit(tname)

		"none":
			pass
	$testhud/Button.grab_focus()
	pass # Replace with function body.


func _on_delete_pressed():
	match type:
		"skill":
			SignalBus.del_skill.emit(tname)

		"cp":
			CpManager.del_cp(tname)
			pass
		"passive":
			pass
		"card":
			SignalBus.del_card.emit(tname)
		"none":
			pass
	$testhud/Button.grab_focus()
	pass # Replace with function body.


func _on_levelup_pressed():
	GameManager.level_up()

	pass # Replace with function body.


func _on_moremana_pressed():
	GameManager.add_power(player_var.power_max)
	$testhud/Button.grab_focus()
	pass # Replace with function body.

func p_o(id):
	var obj = instance_from_id(int(id))
	if obj:
		prints(obj, obj.owner, obj.get_script().get_script_property_list())





func _on_button_2_pressed():
	p_o($testhud/TextEdit.text)
	pass # Replace with function body.


func _on_button_3_pressed():
	print_orphan_nodes()
