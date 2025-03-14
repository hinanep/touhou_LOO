extends CanvasLayer

var select_num = 3
var card_button_pre = PresetManager.getpre("ui_select_button")
# Called when the node enters the scene tree for the first time.
var cards_skills_selected
var ban_mode = false
func _ready():
	cards_skills_selected = RandomPool.random_nselect_from_allpool(select_num)

	for c in cards_skills_selected["cards"]:
		if c != null:
			var card_button = card_button_pre.instantiate()
			$select_buttons.add_child(card_button)
			#多语言支持尚未

			card_button.set_upgrade_text(table.TID[c][player_var.language]+" Lv."+String.num(player_var.CardManager.get_card_level(c)+1))
			card_button.set_describe_text(table.TID[c+'_dsc'][player_var.language])
			card_button.upgrade_selected.connect(on_button_selected.bind(c))

	for w in cards_skills_selected["skills"]:
		if w != null:
			var skill_button = card_button_pre.instantiate()
			$select_buttons.add_child(skill_button)
			#多语言支持尚未

			skill_button.set_upgrade_text(table.TID[w][player_var.language]+" Lv."+String.num(player_var.SkillManager.get_skill_level(w)+1))
			skill_button.set_describe_text(table.TID[w+'_dsc'][player_var.language])
			skill_button.upgrade_selected.connect(on_button_selected.bind(w))

	for b in cards_skills_selected["passives"]:
		if b != null:
			var buff_button = card_button_pre.instantiate()
			$select_buttons.add_child(buff_button)
			#多语言支持尚未

			buff_button.set_upgrade_text(table.TID[b][player_var.language]+" Lv."+String.num(player_var.PassiveManager.get_passive_level(b)+1))
			buff_button.set_describe_text(table.TID[b+'_dsc'][player_var.language])
			buff_button.upgrade_selected.connect(on_button_selected.bind(b))

	if $select_buttons.get_child_count()!=0:
		$select_buttons.get_child(0).grab_focus()
	else:
		player_var.point_ratio *= 1.1

		call_deferred("close_levelup")
		GameManager.add_exp(0)




func on_button_selected(upgrade):
	if ban_mode:
		if(cards_skills_selected["skills"].has(upgrade)):
			SignalBus.ban_skill.emit(upgrade)

		if(cards_skills_selected["cards"].has(upgrade)):
			SignalBus.ban_card.emit(upgrade)
		if(cards_skills_selected["buffs"].has(upgrade)):
			SignalBus.ban_passive.emit(upgrade)
	else:
		if(cards_skills_selected["skills"].has(upgrade)):

			SignalBus.try_add_skill.emit(upgrade)

		if(cards_skills_selected["cards"].has(upgrade)):
			SignalBus.try_add_card.emit(upgrade)

		if(cards_skills_selected["passives"].has(upgrade)):
			SignalBus.try_add_passive.emit(upgrade)



	call_deferred("close_levelup")
	pass # Replace with function body.

func close_levelup():
	$"..".close_self()




func _on_reroll_button_up():
	for b in $select_buttons.get_children():
		b.queue_free()
	_ready()
	if $select_buttons.get_child_count()!=0:
		$select_buttons.get_child(0).grab_focus()
	pass # Replace with function body.


func _on_ban_button_up():
	if $select_buttons.get_child_count()!=0:
		$select_buttons.get_child(0).grab_focus()
	if !ban_mode:
		$back2.set_modulate(Color(1, 0, 0))
	else:
		$back2.set_modulate(Color(1, 1, 1))
	ban_mode = !ban_mode
	pass # Replace with function body.


func _on_abandon_button_up():
	player_var.point_ratio += 1
	if $select_buttons.get_child_count()!=0:
		$select_buttons.get_child(0).grab_focus()
	close_levelup()
	pass # Replace with function body.
