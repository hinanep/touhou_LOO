extends Node
var buffnum_have
var buffnum_max
var buff_maxlevel

var buff_pool = {
	"unchoosed":{
		#buff_name(string):{ level(int)}
	},
	"choosed":{},
	"max":{},
	"force_buff":{}
}
var buff_list = {
	#buff_name(string): level(int)
}

	
func _init():
	buffnum_have = 0
	buffnum_max = 5
	buff_maxlevel = 2
	buff_pool["unchoosed"]["pachuli"] = {
		"type":"stable",
		"level":0,
		"path":"passive_pachuli",
		"cn":"帕秋莉",
		"weight":5,
		"buff_image":"image_passive_pachuli",
		"describe_text":["增加符力","增加符力","增加符力","增加符力","增加符力","增加符力","增加符力","增加符力"]
		
	}


func add_buff(buffname,force_buff):
	if(buff_pool["choosed"].has(buffname)):
		upgrade_buff(buffname)
		return
	if(buff_pool["max"].has(buffname)):
		return	
	
	var path
	if !force_buff:
		CpManager.raise_weight_to_cp(buffname)
		path = buff_pool["unchoosed"][buffname]["path"]
		buffnum_have += 1
		if buffnum_have >= buffnum_max:
			player_var.passive_num_full = true
		player_var.passive_full = false
	
		buff_pool["choosed"][buffname]=buff_pool["unchoosed"][buffname]
		buff_pool["unchoosed"].erase(buffname)
		buff_list[buffname] = buff_pool["choosed"][buffname]["level"]

		
	else:
		path = buff_pool["force_buff"][buffname]["path"]
		buff_pool["choosed"][buffname]=buff_pool["force_buff"][buffname]
		
		buff_list[buffname] = buff_pool["choosed"][buffname]["level"]
		
	
	
	var buff1 =  PresetManager.getpre(path)
	buff1 = buff1.instantiate()
	
	player_var.player_node.get_node("buffManager").add_child(buff1)
	buff1.position = Vector2(0,0)
	upgrade_buff(buffname)
	
func upgrade_buff(buffname):
	buff_list[buffname] += 1

	buff_pool["choosed"][buffname]["level"] += 1
	if(buff_pool["choosed"][buffname]["level"]>= buff_maxlevel):
		buff_pool["max"][buffname] = buff_pool["choosed"][buffname]
		buff_pool["choosed"].erase(buffname)
		CpManager.add_to_maxlist(buffname)
		if is_buff_allmaxlevel():
			player_var.passive_full = true
	get_tree().call_group(buffname,"upgrade_buff")

func is_buff_allmaxlevel():
	if player_var.passive_num_full:
		for buffname in buff_list:
			if(buff_list[buffname]!=buff_maxlevel):
				return false		
		return true

func get_upable_buff_by_name(buffname):
	if(buff_pool["choosed"].has(buffname)):
		return buff_pool["choosed"][buffname]
	if(buff_pool["unchoosed"].has(buffname)):
		return buff_pool["unchoosed"][buffname]
	return null

func clear_all():
	print("buff_clear")

	buff_pool = {
	"unchoosed":{
		#buff_name(string):{ level(int)}
	},
	"choosed":{},
	"max":{}
}
	buff_list = {
	#buff_name(string): level(int)
}
	_init()
