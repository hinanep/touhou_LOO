extends Node2D
var power = player_var.power
var cardnum_now = 0
var cardnum_have = 1
var cardnum_max = 3
var card_list = [
]
var card_pre_list = [
]
@export var name_path_pair = {
	"marisa": "res://scene/cards/masterapark/masterspark.tscn"
}
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
	player_var.player_node.get_node("CardManager").add_child(cardpre)
	cardpre.position = Vector2(0,0)

	
func _ready():
	add_card("marisa")
	
func add_card(cardname):
	var cardpath = name_path_pair[cardname]
	cardnum_have += 1
	if cardnum_have >= cardnum_max:
		player_var.card_full = true
	card_list.append(cardpath)
	card_pre_list.append(load(cardpath))
	
		
