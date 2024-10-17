extends Node
var wazanum_have = 0
var wazanum_max = 3
var waza_maxlevel = 8
@export var waza_name_path_pair = {
	"base_range":"res://scene/weapons/beginning_weapon/beginning_ranged_attack/beginning_ranged_attack.tscn",
	"base_melee":"res://scene/weapons/weapon_base/melee_base/melee_weapon_base.tscn",
	"reimu" : "res://scene/weapons/reimu/reimu_weapon.tscn",
	"sanae": "res://scene/weapons/sanae/sanae_weapon.tscn",
	"alice": "res://scene/weapons/alice_weapon/alice_weapon.tscn"
}
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

func _ready():
	waza_pool["unchoosed"]["base_range"] = {
		"level":0
	}
	waza_pool["unchoosed"]["base_melee"] = {
		"level":0
	}
	waza_pool["unchoosed"]["reimu"] = {
		"level":0
	}
	waza_pool["unchoosed"]["sanae"] = {
		"level":0
	}
	waza_pool["unchoosed"]["alice"] = {
		"level":0
	}

	pass # Replace with function body.




func add_waza(wazaname):
	
	
	if(waza_pool["choosed"].has(wazaname)):
		upgrade_waza(wazaname)
		return
	if(waza_pool["max"].has(wazaname)):
		return	
	
	wazanum_have += 1
	if wazanum_have >= wazanum_max:
		player_var.waza_num_full = true
	
	waza_list[wazaname] = 1
	waza_pool["choosed"][wazaname]=waza_pool["unchoosed"][wazaname]
	waza_pool["unchoosed"].erase(wazaname)
	player_var.waza_full = false
	
	var path = waza_name_path_pair[wazaname]
	var weapon = load(path)
	weapon = weapon.instantiate()
	
	player_var.player_node.get_node("WazaManager").add_child(weapon)
	weapon.position = Vector2(0,0)
	
func upgrade_waza(wazaname):
	waza_list[wazaname] += 1

	waza_pool["choosed"][wazaname]["level"] += 1
	if(waza_pool["choosed"][wazaname]["level"]== waza_maxlevel):
		waza_pool["max"][wazaname] = waza_pool["choosed"][wazaname]
		waza_pool["choosed"].erase(wazaname)
		if is_allmaxlevel():
			player_var.waza_full = true
	get_tree().call_group(wazaname,"upgrade_waza")

func is_allmaxlevel():
	if(player_var.waza_num_full):
		for wazaname in waza_list:
			if(waza_list[wazaname]!=waza_maxlevel):
				return false		
		return true
