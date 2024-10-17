extends CanvasLayer
var player
var select_num = 3
var card_button_pre = preload("res://scene/ui/Scripts/GUI/LevelUp/select_button.tscn")
# Called when the node enters the scene tree for the first time.
var cards_wazas_selected
func _ready():
	player = get_tree().get_first_node_in_group("player")
		
	cards_wazas_selected = RandomPool.random_nselect_from_allpool(select_num)

	for c in cards_wazas_selected["cards"]:
		if c != null:
			var card_button = card_button_pre.instantiate()
			$select_buttons.add_child(card_button)
			#多语言支持尚未
			print(c)
			card_button.set_upgrade_text(c)
			card_button.upgrade_selected.connect(on_button_selected.bind(c))
	for w in cards_wazas_selected["wazas"]:
		if w != null:
			var waza_button = card_button_pre.instantiate()
			$select_buttons.add_child(waza_button)
			#多语言支持尚未
			print(w)
			waza_button.set_upgrade_text(w)
			waza_button.upgrade_selected.connect(on_button_selected.bind(w))


	$select_buttons.get_child(0).grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	pass

func on_button_selected(upgrade):
	
	if(cards_wazas_selected["wazas"].has(upgrade)):	
		WazaManager.add_waza(upgrade)
	else:
		if(cards_wazas_selected["cards"].has(upgrade)):
			CardManager.add_card(upgrade)
	visible = false
	get_tree().paused = false
	pass # Replace with function body.
	
	

	
