extends CanvasLayer

var select_num = 3
var card_button_pre = PresetManager.getpre("ui_select_button")

var selected
var ban_mode = false
func _ready():
	selected = RandomPool.random_nselect_from_allpool(select_num)
	for id in selected:
		var card_button = card_button_pre.instantiate()
		card_button.set_text(selected[id],id)
		card_button.upgrade_selected.connect(on_button_selected.bind(id))
		$select_buttons.add_child(card_button)


	if $select_buttons.get_child_count()!=0:
		$select_buttons.get_child(0).grab_focus()
	else:
		player_var.point_ratio *= 1.1
		call_deferred("close_levelup")




func on_button_selected(id):
	if ban_mode:
		match selected[id]:
			'skill':
				SignalBus.ban_skill.emit(id)
			'card':
				SignalBus.ban_card.emit(id)
			'passive':
				SignalBus.ban_passive.emit(id)

	else:
		match selected[id]:
			'skill':
				SignalBus.try_add_skill.emit(id)
			'card':
				SignalBus.try_add_card.emit(id)
			'passive':
				SignalBus.try_add_passive.emit(id)


	call_deferred("close_levelup")


func close_levelup():
	$"..".close_self()




func _on_reroll_button_up():
	for b in $select_buttons.get_children():
		b.free()
	_ready()
	if $select_buttons.get_child_count()!=0:
		$select_buttons.get_child(0).grab_focus()



func _on_ban_button_up():
	if $select_buttons.get_child_count()!=0:
		$select_buttons.get_child(0).grab_focus()
	if !ban_mode:
		$back2.set_modulate(Color(1, 0, 0))
	else:
		$back2.set_modulate(Color(1, 1, 1))
	ban_mode = !ban_mode



func _on_abandon_button_up():
	player_var.point_ratio += 1

	call_deferred("close_levelup")
