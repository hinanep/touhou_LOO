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
		"cn":"灵魔",
		"weight":1,
		"cp_image":"image_cp_reima"
	}
	cp_pool["unactive"]["reitama"] = {
		"name":"reitama",
		"effect_group":["reimu","tamatsukuri"],
		"cn":"灵丸",
		"weight":1,
		"cp_image":"image_cp_reitama"
	}

func add_to_maxlist(x_name):
	max_list.append(x_name)
	activate_cp(get_cp_unactive(x_name))
func del_to_maxlist(x_name):
	max_list.erase(x_name)

	for cp in cp_pool["active"]:
		if cp_pool["active"][cp]["effect_group"].has(x_name):
			cp_pool["unactive"][cp] = cp_pool["active"][cp]
			cp_pool["active"].erase(cp)
	for cp in cp_pool.choosed:
		if cp_pool.choosed[cp]["effect_group"].has(x_name):
			del_cp(cp)
func raise_weight_to_cp(xname):
	for cp in cp_pool["unactive"]:
		if cp_pool["unactive"][cp]["effect_group"].has(xname):
			for x_name in cp_pool["unactive"][cp]["effect_group"]:
				if(SkillManager.skill_pool.unlocked.has(x_name)):
					SkillManager.skill_pool.unlocked["weight"] *=1.1
				if(CardManager.card_pool["unchoosed"].has(x_name)):
					CardManager.card_pool["unchoosed"][x_name]["weight"] *=1.1
				if(BuffManager.buff_pool["unchoosed"].has(x_name)):
					BuffManager.buff_pool["unchoosed"][x_name]["weight"] *=1.1
func get_cp_unactive(x_name):
	var find = false
	var cp_array = []
	print("get_cp_unactive")
	print(x_name)
	for cp in cp_pool["unactive"]:
		if cp_pool["unactive"][cp]["effect_group"].has(x_name):

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
	AudioManager.play_sfx("music_sfx_cp")
	var cp_name = cp_pool["active"].keys()[randi_range(0,cp_pool["active"].size()-1)]
	add_cp(cp_name)
	return true

func add_cp(cp_name):
	if cp_pool["choosed"].has(cp_name):
		return
	if cp_pool["active"].has(cp_name):
		cp_pool["choosed"][cp_name] = cp_pool["active"][cp_name]
		cp_pool["active"].erase(cp_name)
	if cp_pool["unactive"].has(cp_name):
		cp_pool["choosed"][cp_name] = cp_pool["unactive"][cp_name]
		cp_pool["unactive"].erase(cp_name)
	player_var.damage_sum[cp_name] = 0
	for part in cp_pool["choosed"][cp_name]["effect_group"]:
		get_tree().call_group(part,"cp_active",cp_name)
	get_tree().call_group("hud","add_cp",cp_pool["choosed"][cp_name])

func del_cp(cp_name):
	if cp_pool.choosed.has(cp_name):
		cp_pool["unactive"][cp_name] = cp_pool["choosed"][cp_name]
		cp_pool["choosed"].erase(cp_name)
		for part in cp_pool["unactive"][cp_name]["effect_group"]:
			get_tree().call_group(part,"cp_deactive",cp_name)
		get_tree().call_group(cp_name,"queue_free")
	#get_tree().call_group("hud","del_cp",cp_pool["choosed"][cp_name])

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
