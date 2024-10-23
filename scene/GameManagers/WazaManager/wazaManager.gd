extends Node
var wazanum_have = 0
var wazanum_max = 3+2
var waza_maxlevel = 8

var waza_pool = {
	"unchoosed":{
		#waza_name(string):{ level(int)}
	},
	"choosed":{},
	"max":{}
}
var waza_list = {
	#waza_name(string): level(int)
}

func _init():
	waza_pool["unchoosed"]["base_range"] = {
		"level":waza_maxlevel-1,
		"path":"res://scene/weapons/beginning_weapon/beginning_ranged_attack/beginning_ranged_attack.tscn"
	}
	waza_pool["unchoosed"]["base_melee"] = {
		"level":waza_maxlevel-1,
		"path":"res://scene/weapons/weapon_base/melee_base/melee_weapon_base.tscn"
	}
	waza_pool["unchoosed"]["reimu"] = {
		"level":0,
		"path":"res://scene/weapons/reimu/reimu_weapon.tscn",
		"weight":1,
		"cn":"灵梦"
	}
	waza_pool["unchoosed"]["sanae"] = {
		"level":0,
		"path":"res://scene/weapons/sanae/sanae_weapon.tscn",
		"weight":1,
		"cn":"早苗"
	}
	waza_pool["unchoosed"]["alice"] = {
		"level":0,
		"path":"res://scene/weapons/alice_weapon/alice_weapon.tscn",
		"weight":1,
		"cn":"爱丽丝"
	}
	waza_pool["unchoosed"]["sekibanki"] = {
		"level":0,
		"path":"res://scene/weapons/sekibanki/sekibanki_weapon.tscn",
		"weight":5,
		"cn":"赤蛮奇"
	}

func add_waza(wazaname):
	if(waza_pool["choosed"].has(wazaname)):
		upgrade_waza(wazaname)
		return
	if(waza_pool["max"].has(wazaname)):
		return	
		
	var path = waza_pool["unchoosed"][wazaname]["path"]
	
	wazanum_have += 1
	if wazanum_have >= wazanum_max:
		player_var.waza_num_full = true
	player_var.waza_full = false
	
	waza_pool["choosed"][wazaname]=waza_pool["unchoosed"][wazaname]
	waza_pool["unchoosed"].erase(wazaname)
	waza_list[wazaname] = waza_pool["choosed"][wazaname]["level"]
	upgrade_waza(wazaname)
	
	
	var weapon = load(path)
	weapon = weapon.instantiate()
	
	player_var.player_node.get_node("WazaManager").add_child(weapon)
	weapon.position = Vector2(0,0)
	
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
