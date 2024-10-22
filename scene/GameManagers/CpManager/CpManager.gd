extends Node2D
var max_list = []
var cp_pool = {
	"unactive":{
		#cp_name:{ ...}
	},
	"active":{},
	"choosed":{}
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
		
func choose_cp(cp_name):
	if cp_name == null:
		return
	cp_pool["choosed"][cp_name] = cp_pool["active"][cp_name]
	cp_pool["active"].erase(cp_name)
	get_tree().call_group(cp_name,"cp_active",cp_name)
