extends Node2D
var power = player_var.power
var cardnum_now = 0
var cardnum_have = 0
var cardnum_max = 3
var card_maxlevel = 8
var card_list = [
	#card_name
]
var c
var card_pool = {
	"unchoosed":{
		#card_name:{"level":,"power?":, ...}
	},
	"choosed":{},
	"max":{}
}
var card_pre_list = {
	#card_name:pre
}
@export var name_path_pair = {
	"marisa": "res://scene/cards/masterapark/masterspark.tscn"
}
#这里可以优化为一个列表，但是这样测试比较方便（
func _init():
	card_pool["unchoosed"]["marisa"] = {
		"level":0,
		"power_cost":40
	}
	pass
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
	print(card_list[cardnum_now])#name
	if(card_pool["choosed"].has(card_list[cardnum_now])):
		c = card_pool["choosed"][card_list[cardnum_now]]
	else:
		c = card_pool["max"][card_list[cardnum_now]]
	if(player_var.power<c["power_cost"]):
		return
	player_var.power -= c["power_cost"]
	var cardpre = card_pre_list[card_list[cardnum_now]].instantiate()
	
	player_var.player_node.get_node("CardManager").add_child(cardpre)
	cardpre.position = Vector2(0,0)

	
func _ready():
	add_card("marisa")
	
func add_card(cardname):
	if(card_pool["choosed"].has(cardname)):
		upgrade_card(cardname)
		return
	if(card_pool["max"].has(cardname)):
		return	
	var cardpath = name_path_pair[cardname]
	
	cardnum_have += 1
	if cardnum_have >= cardnum_max:
		player_var.card_num_full = true
	
	card_list.append(cardname)
	card_pool["choosed"][cardname]=card_pool["unchoosed"][cardname]
	card_pool["unchoosed"].erase(cardname)
	card_pre_list[cardname] = load(cardpath)
	
func upgrade_card(cardname):
	card_pool["choosed"][cardname]["level"] += 1
	if(card_pool["choosed"][cardname]["level"]== card_maxlevel):
		card_pool["max"][cardname] = card_pool["choosed"][cardname]
		card_pool["choosed"].erase(cardname)
	get_tree().call_group(cardname,"upgrade_card")

