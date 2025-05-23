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

	for uccp in table.Couple:
		var cps = table.Couple[uccp]
		var cp_button = PresetManager.getpre("ui_test_skillbutton").instantiate()
		$testhud/cp_container.add_child(cp_button)
		cp_button.set_texture('img_'+cps.id)
		cp_button.set_tooltip_text(cps.id)
		cp_button.selected.connect(on_cpbutton_select.bind(cps.id))

	for psv in table.Passive:
		var psv_info = table.Passive[psv]
		var psv_button = PresetManager.getpre("ui_test_skillbutton").instantiate()
		$testhud/psv_container.add_child(psv_button)
		psv_button.set_texture('img_'+psv_info.id)
		psv_button.set_tooltip_text(psv_info.id)
		psv_button.selected.connect(on_psvbutton_select.bind(psv_info.id))

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

func on_psvbutton_select(psvname):
	$testhud/Button.grab_focus()
	type = "psv"
	tname = psvname


func _on_update_pressed():
	match type:
		"skill":
			SignalBus.try_add_skill.emit(tname)

		"cp":
			player_var.CpManager.add_cp(tname)
			pass
		"psv":
			SignalBus.try_add_passive.emit(tname)
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
			SignalBus.cp_del.emit(tname)
			pass
		"psv":
			SignalBus.del_passive.emit(tname)

		"card":
			SignalBus.del_card.emit(tname)
		"none":
			pass
	$testhud/Button.grab_focus()
	pass # Replace with function body.


func _on_levelup_pressed():
	player_var.player_exp += player_var.exp_need


func _on_moremana_pressed():
	player_var.mana += (player_var.mana_max)
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
