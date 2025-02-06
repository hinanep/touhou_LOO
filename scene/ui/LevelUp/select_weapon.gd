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
			var cd = player_var.CardManager.get_upable_card_by_name(c)
			card_button.set_upgrade_text(cd["cn"]+" Lv."+String.num(cd["level"]+1))
			card_button.set_describe_text(cd["describe_text"][cd["level"]])
			card_button.upgrade_selected.connect(on_button_selected.bind(c))

	for w in cards_skills_selected["skills"]:
		if w != null:
			var skill_button = card_button_pre.instantiate()
			$select_buttons.add_child(skill_button)
			#多语言支持尚未

			skill_button.set_upgrade_text(w+" Lv."+String.num(player_var.SkillManager.get_skill_level(w)+1))
			#skill_button.set_describe_text(ski["describe_text"][ski["level"]])
			skill_button.upgrade_selected.connect(on_button_selected.bind(w))

	for b in cards_skills_selected["passives"]:
		if b != null:
			var buff_button = card_button_pre.instantiate()
			$select_buttons.add_child(buff_button)
			#多语言支持尚未
			var bf = PassiveManager.get_upable_buff_by_name(b)
			buff_button.set_upgrade_text(bf["cn"]+" Lv."+String.num(bf["level"]+1))
			buff_button.set_describe_text(bf["describe_text"][bf["level"]])
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
			player_var.SkillManager.ban_skill(upgrade)

		#if(cards_skills_selected["cards"].has(upgrade)):
			#CardManager.add_card(upgrade)
		#if(cards_skills_selected["buffs"].has(upgrade)):
			#BuffManager.add_buff(upgrade,false)
	else:
		if(cards_skills_selected["skills"].has(upgrade)):

			SignalBus.try_add_skill.emit(upgrade)

		if(cards_skills_selected["cards"].has(upgrade)):
			player_var.CardManager.add_card(upgrade)
		if(cards_skills_selected["passives"].has(upgrade)):
			PassiveManager.add_buff(upgrade,false)


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
