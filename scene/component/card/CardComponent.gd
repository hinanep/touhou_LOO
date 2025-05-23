extends Node2D
var thisname
var cardnum_have = 0
var cardnum_now
var card_arr = []
func _ready() -> void:
	cardnum_now = 0
	SignalBus.add_card.connect(on_add_card)
	SignalBus.del_card.connect(on_del_card)
	#SignalBus.card_select_before.connect(card_select_change.bind(-1))
	SignalBus.card_select_next.connect(card_select_change)
	SignalBus.plate_use_card.connect(func():
		SignalBus.use_card.emit(card_arr[cardnum_now],0)
		)
func on_add_card(card_info):
	var path = 'card'
	var cardpre = PresetManager.getpre(path)
	cardnum_have += 1
	cardpre = cardpre.instantiate()
	cardpre.card_info = card_info
	cardpre.position = Vector2(0,0)
	card_arr.push_back(card_info.id)
	add_child(cardpre)
func card_select_change(bias):
	cardnum_now = int(cardnum_now+bias)%cardnum_have
func _unhandled_key_input(event: InputEvent) -> void:
	if cardnum_have!=0:
		if event.is_action_pressed("use_card"):
			SignalBus.use_card.emit(card_arr[cardnum_now],1)


		if event.is_action_pressed("card_next") or event.is_action_pressed("card_before"):
			SignalBus.card_select_next.emit(Input.get_axis('card_before','card_next'))

func on_del_card(id):
	card_arr.erase(id)
	cardnum_have -= 1
	if cardnum_have !=0:
		cardnum_now = cardnum_now%cardnum_have
	else:
		cardnum_now = 0
