extends Node2D
var power = player_var.power
var cardnum_now = 0
var cardnum_have = 0
var cardnum_max = 3
var card_maxlevel = 8
var card_list = {
	
}
	#card_name:level
var c
var card_pool = {
	"unchoosed":{
		#card_name:{"level":,"power?":, ...}
	},
	"choosed":{},
	"max":{}
}


func _init():
	card_pool["unchoosed"]["marisa"] = {
		"level":0,
		"power_cost":40,
		"path":"res://scene/cards/masterapark/masterspark.tscn",
		"pre":null
	}

func _input(event):
	
	if cardnum_have:
		if event.is_action_pressed("use_card"):
			use_card()
			print("usepress")
		if event.is_action_pressed("card_next"):
			cardnum_now += 1
			cardnum_now %= cardnum_have
		if event.is_action_pressed("card_before"):
			cardnum_now -= 1
			cardnum_now %= cardnum_have
		
func use_card():
	var cardname = card_list.keys()[cardnum_now]
	print(cardname)#name
	
	if(card_pool["choosed"].has(cardname)):
		c = card_pool["choosed"][cardname]
	else:
		c = card_pool["max"][cardname]
	if(player_var.power<c["power_cost"]):
		return
	player_var.power -= c["power_cost"]
	var cardpre = c["pre"].instantiate()
	cardpre.card_init(c)
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
	var cardpath = card_pool["unchoosed"][cardname]["path"]
	
	cardnum_have += 1
	if cardnum_have >= cardnum_max:
		player_var.card_num_full = true
	player_var.card_full = false
	card_list[cardname] = 1
	card_pool["choosed"][cardname]=card_pool["unchoosed"][cardname]
	card_pool["unchoosed"].erase(cardname)
	card_pool["choosed"][cardname]["pre"] = load(cardpath)
	card_pool["choosed"][cardname]["level"] = 1
	
func upgrade_card(cardname):
	card_list[cardname] += 1
	card_pool["choosed"][cardname]["level"] += 1
	if(card_pool["choosed"][cardname]["level"]== card_maxlevel):
		card_pool["max"][cardname] = card_pool["choosed"][cardname]
		card_pool["choosed"].erase(cardname)
		if is_card_allmaxlevel():
			player_var.card_full = true


func is_card_allmaxlevel():
	if player_var.card_num_full:
		for cardname in card_list:
			if(card_list[cardname]!=card_maxlevel):
				return false		
		return true
	pass
