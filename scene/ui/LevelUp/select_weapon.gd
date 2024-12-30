extends CanvasLayer
var player
var select_num = 3
var card_button_pre = PresetManager.getpre("ui_select_button")
# Called when the node enters the scene tree for the first time.
var cards_wazas_selected
var ban_mode = false
func _ready():
	player = get_tree().get_first_node_in_group("player")
		
	cards_wazas_selected = RandomPool.random_nselect_from_allpool(select_num)

	for c in cards_wazas_selected["cards"]:
		if c != null:
			var card_button = card_button_pre.instantiate()
			$select_buttons.add_child(card_button)
			#多语言支持尚未
			var cd = CardManager.get_upable_card_by_name(c)
			card_button.set_upgrade_text(cd["cn"]+" Lv."+String.num(cd["level"]+1))
			card_button.set_describe_text(cd["describe_text"][cd["level"]])
			card_button.upgrade_selected.connect(on_button_selected.bind(c))
			
	for w in cards_wazas_selected["wazas"]:
		if w != null:
			var waza_button = card_button_pre.instantiate()
			$select_buttons.add_child(waza_button)
			#多语言支持尚未
			var wz = WazaManager.get_upable_waza_by_name(w)
			waza_button.set_upgrade_text(wz["cn"]+" Lv."+String.num(wz["level"]+1))
			waza_button.set_describe_text(wz["describe_text"][wz["level"]])
			waza_button.upgrade_selected.connect(on_button_selected.bind(w))
	
	for b in cards_wazas_selected["buffs"]:
		if b != null:
			var buff_button = card_button_pre.instantiate()
			$select_buttons.add_child(buff_button)
			#多语言支持尚未
			var bf = BuffManager.get_upable_buff_by_name(b)
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
		if(cards_wazas_selected["wazas"].has(upgrade)):	
			WazaManager.ban_routine(upgrade)
	
		#if(cards_wazas_selected["cards"].has(upgrade)):
			#CardManager.add_card(upgrade)
		#if(cards_wazas_selected["buffs"].has(upgrade)):
			#BuffManager.add_buff(upgrade,false)
	else:
		if(cards_wazas_selected["wazas"].has(upgrade)):	
			WazaManager.add_waza(upgrade)
		
		if(cards_wazas_selected["cards"].has(upgrade)):
			CardManager.add_card(upgrade)
		if(cards_wazas_selected["buffs"].has(upgrade)):
			BuffManager.add_buff(upgrade,false)


	call_deferred("close_levelup")
	GameManager.add_exp(0)
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
