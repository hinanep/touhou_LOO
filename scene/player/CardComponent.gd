extends Node2D
var thisname
var cardnum_have = false
func _ready() -> void:
	SignalBus.add_card.connect(on_add_card)
	pass
func on_add_card(card_info):
	var path = 'card'
	var cardpre = PresetManager.getpre(path)
	cardpre = cardpre.instantiate()
	cardpre.card_info = card_info
	add_child(cardpre)
	cardpre.position = Vector2(0,0)
func _input(event):
	pass
	#if cardnum_have:
		#if event.is_action_pressed("use_card"):
			#SignalBus.use_card.emit()
		#if event.is_action_pressed("card_next"):
			#cardnum_now += 1
			#cardnum_now %= cardnum_have
		#if event.is_action_pressed("card_before"):
			#cardnum_now -= 1
			#cardnum_now %= cardnum_have

#func on_use_card(card_name):
	#if thisname == card_name:
		#pass
