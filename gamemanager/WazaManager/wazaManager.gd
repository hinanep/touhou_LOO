extends Node
var wazanum_have
var wazanum_max
var waza_maxlevel

var waza_pool = {
	"unchoosed":{
		#waza_name(string):{ level(int)}
	},
	"choosed":{},
	"max":{},
	"banned":{}
}
var waza_list = {
	#waza_name(string): level(int)
}

func add_waza(wazaname):
	if(waza_pool["choosed"].has(wazaname)):
		upgrade_waza(wazaname)
		return
	if(waza_pool["max"].has(wazaname)):
		return
	CpManager.raise_weight_to_cp(wazaname)
	var path = waza_pool["unchoosed"][wazaname]["path"]
	player_var.damage_sum[wazaname] = 0
	wazanum_have += 1
	if wazanum_have >= wazanum_max:
		player_var.waza_num_full = true
	player_var.waza_full = false

	var weapon = PresetManager.getpre(path)
	weapon = weapon.instantiate()
	weapon.waza_config = waza_pool["unchoosed"][wazaname]
	player_var.player_node.get_node("WazaManager").add_child(weapon)
	weapon.position = Vector2(0,0)

	waza_pool["choosed"][wazaname]=waza_pool["unchoosed"][wazaname]
	waza_pool["unchoosed"].erase(wazaname)
	waza_list[wazaname] = waza_pool["choosed"][wazaname]["level"]
	get_tree().call_group("hud","add_waza",waza_pool["choosed"][wazaname])
	upgrade_waza(wazaname)

func upgrade_waza(wazaname):
	waza_list[wazaname] += 1

	waza_pool["choosed"][wazaname]["level"] += 1
	if(waza_pool["choosed"][wazaname]["level"]>= waza_maxlevel):
		waza_pool["max"][wazaname] = waza_pool["choosed"][wazaname]
		waza_pool["choosed"].erase(wazaname)
		CpManager.add_to_maxlist(wazaname)
		if is_waza_allmaxlevel():
			player_var.waza_full = true

	get_tree().call_group(wazaname,"upgrade_waza")

func is_waza_allmaxlevel():
	if player_var.waza_num_full:
		for wazaname in waza_list:
			if(waza_list[wazaname]!=waza_maxlevel):
				return false
		return true

func get_upable_waza_by_name(wazaname):
	if(waza_pool["choosed"].has(wazaname)):
		return waza_pool["choosed"][wazaname]
	if(waza_pool["unchoosed"].has(wazaname)):
		return waza_pool["unchoosed"][wazaname]
	return null

func clear_all():
	print("waza_clear")
	wazanum_have = 0
	wazanum_max = 6
	waza_maxlevel = 3
	waza_pool = {
	"unchoosed":{
		#waza_name(string):{ level(int)}
	},
	"choosed":{},
	"max":{}
}
	waza_list = {
	#waza_name(string): level(int)
}
	_init()

func del_waza(wazaname):

	if(waza_pool["choosed"].has(wazaname)):
		waza_pool["unchoosed"][wazaname]=waza_pool["choosed"][wazaname]
		waza_pool["choosed"].erase(wazaname)


	elif(waza_pool["max"].has(wazaname)):
		waza_pool["unchoosed"][wazaname]=waza_pool["max"][wazaname]
		waza_pool["max"].erase(wazaname)
	else:
		return
	waza_list.erase(wazaname)
	wazanum_have -= 1

	player_var.waza_num_full = false
	player_var.waza_full = false

	get_tree().call_group(wazaname,"queue_free")

	waza_pool["unchoosed"][wazaname]["level"] = 0

	CpManager.del_to_maxlist(wazaname)

func ban_routine(routine_name):
	if(waza_pool["unchoosed"].has(routine_name)):
		waza_pool["banned"][routine_name]=waza_pool["unchoosed"][routine_name]
		waza_pool["unchoosed"].erase(routine_name)


	elif(waza_pool["choosed"].has(routine_name)):
		waza_pool["banned"][routine_name]=waza_pool["choosed"][routine_name]
		del_waza(routine_name)
		waza_pool["unchoosed"].erase(routine_name)

	else:
		return false
func _init():
	wazanum_have = 0
	wazanum_max = 6
	waza_maxlevel = 3
	#waza_pool["unchoosed"] = table.unlock.data.duplicate()
