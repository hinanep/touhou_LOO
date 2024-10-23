extends Node2D
var max_list = []
var cp_pool = {
	"unactive":{
		#cp_name:{ ...}
		#不满足条件：组件未满或不存在
	},
	"active":{},#满足条件但未启用
	"choosed":{}#已启用
}

func _init():
	cp_pool["unactive"]["reima"] = {
		"name":"reima",
		"effect_group":["reimu","marisa"],

		"weight":1,
		"cp_image":"res://asset/记忆结晶羁绊图标/魔理沙.png"
	}

func add_to_maxlist(name):
	max_list.append(name)
	activate_cp(get_cp_unactive(name))
func raise_weight_to_cp(name):
	for cp in cp_pool["unactive"]:
		if cp_pool["unactive"][cp]["effect_group"].has(name):
			for x_name in cp_pool["unactive"][cp]["effect_group"]:
				if(WazaManager.waza_pool["unchoosed"].has(x_name)):
					WazaManager.waza_pool["unchoosed"][x_name]["weight"] *=1.1
				if(CardManager.card_pool["unchoosed"].has(x_name)):
					CardManager.card_pool["unchoosed"][x_name]["weight"] *=1.1
					
func get_cp_unactive(name):
	var find = false
	var cp_array = []
	print("get_cp_unactive")
	print(name)
	for cp in cp_pool["unactive"]:
		if cp_pool["unactive"][cp]["effect_group"].has(name):
			
			find = true
			for x in cp_pool["unactive"][cp]["effect_group"]:
				if x in max_list:
					continue
				else:
					find = false
					break
			if find:
				cp_array.append(cp_pool["unactive"][cp]["name"])

	return cp_array

func activate_cp(cp_array):
	if cp_array.is_empty():
		return
	for cp_name in cp_array:
		cp_pool["active"][cp_name] = cp_pool["unactive"][cp_name]
		cp_pool["unactive"].erase(cp_name)
		
func random_choose_cp():
	if cp_pool["active"].is_empty():
		return false

	var cp_name = cp_pool["active"].keys()[randi_range(0,cp_pool["active"].size()-1)]
	cp_pool["choosed"][cp_name] = cp_pool["active"][cp_name]
	cp_pool["active"].erase(cp_name)
	get_tree().call_group(cp_name,"cp_active",cp_name)
	return true
func clear_all():
	max_list = []
	cp_pool = {
	"unactive":{
		#cp_name:{ ...}
	},
	"active":{},
	"choosed":{}
}
	_init()
