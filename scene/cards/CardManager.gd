extends Node2D
var power = player_var.power
var cardnum_now = 0
var cardnum_have = 1

var cardnum_max = 3
var card_list = [
]
var card_pre_list = [
]
#这里可以优化为一个列表，但是这样测试比较方便（
func _input(event):
	
	if cardnum_have:
		if event.is_action_pressed("use_card"):
			use_card()
		if event.is_action_pressed("card_next"):
			cardnum_now += 1
			cardnum_now %= cardnum_have
		if event.is_action_pressed("card_before"):
			cardnum_now -= 1
			cardnum_now %= cardnum_have
		
func use_card():
	print(card_list[cardnum_now])
	var cardpre = card_pre_list[cardnum_now].instantiate()
	$".".add_child(cardpre)
	
func _ready():
	add_card("res://scene/cards/masterapark/masterspark.tscn")
	
func add_card(cardpath):
	cardnum_have += 1
	if cardnum_have >= cardnum_max:
		player_var.card_full = true
	card_list.append(cardpath)
	card_pre_list.append(load(cardpath))
	
		
