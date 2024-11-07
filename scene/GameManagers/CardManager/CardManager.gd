extends Node2D
var power = player_var.power
var cardnum_now
var cardnum_have 
var cardnum_max 
var card_maxlevel
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
	cardnum_now = 0
	cardnum_have = 0
	cardnum_max = 3
	card_maxlevel = 2
	card_pool["unchoosed"]["marisa"] = {
		"level":0,
		"power_cost":40,
		"path":"res://scene/cards/masterapark/masterspark.tscn",
		"pre":null,
		"weight":1,
		"card_image":"res://asset/记忆结晶羁绊图标/魔理沙.png",
		"node":null,
		"cn":"魔理沙",
		"describe_text":["强大的魔炮，强大的卡牌伴随着代价","属性上升","属性上升","属性上升","属性上升","属性上升","属性上升","属性上升"]
	}
	card_pool["unchoosed"]["fairy"] = {
		"level": card_maxlevel-1,
		"power_cost":40,
		"path":"res://scene/cards/beginning_card/beginning_card.tscn",
		"pre":null,
		"weight":1,
		"card_image":"res://asset/记忆结晶羁绊图标/早苗.png",
		"node":null,
		"cn":"大妖精"
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
	c["node"].active()
	
	
func _ready():
	pass
	
func add_card(cardname):
	if(card_pool["choosed"].has(cardname)):
		upgrade_card(cardname)
		return
	if(card_pool["max"].has(cardname)):
		return	
	CpManager.raise_weight_to_cp(cardname)
	var cardpath = card_pool["unchoosed"][cardname]["path"]
	get_tree().call_group("hud","add_card",card_pool["unchoosed"][cardname])
	cardnum_have += 1
	if cardnum_have >= cardnum_max:
		player_var.card_num_full = true
	player_var.card_full = false
	
	card_list[cardname] = 0
	card_pool["choosed"][cardname]=card_pool["unchoosed"][cardname]
	card_pool["unchoosed"].erase(cardname)
	card_pool["choosed"][cardname]["pre"] = load(cardpath)
	var node = card_pool["choosed"][cardname]["pre"].instantiate()
	node.card_init(card_pool["choosed"][cardname])
	player_var.player_node.get_node("CardManager").add_child(node)
	
	node.position = Vector2(0,0)
	card_pool["choosed"][cardname]["node"] = node
	upgrade_card(cardname)
	
func upgrade_card(cardname):
	get_tree().call_group(cardname,"upgrade_card")
	card_list[cardname] += 1
	card_pool["choosed"][cardname]["level"] += 1
	if(card_pool["choosed"][cardname]["level"]>= card_maxlevel):
		card_pool["max"][cardname] = card_pool["choosed"][cardname]
		card_pool["choosed"].erase(cardname)
		CpManager.add_to_maxlist(cardname)
		if is_card_allmaxlevel():
			player_var.card_full = true


func is_card_allmaxlevel():
	if player_var.card_num_full:
		for cardname in card_list:
			if(card_list[cardname]!=card_maxlevel):
				return false		
		return true
	pass

func get_active_card_by_name(cardname):
	if(card_pool["choosed"].has(cardname)):
		return card_pool["choosed"][cardname]
	if(card_pool["max"].has(cardname)):
		return card_pool["max"][cardname]
	return null

func get_upable_card_by_name(cardname):
	if(card_pool["choosed"].has(cardname)):
		return card_pool["choosed"][cardname]
	if(card_pool["unchoosed"].has(cardname)):
		return card_pool["unchoosed"][cardname]
	return null

func clear_all():
	print("card_clear")

	card_list = {
	
}
	#card_name:level

	card_pool = {
	"unchoosed":{
		#card_name:{"level":,"power?":, ...}
	},
	"choosed":{},
	"max":{}
}
	_init()
