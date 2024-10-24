extends Node
var wazanum_have
var wazanum_max
var waza_maxlevel

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

func add_waza(wazaname):
	if(waza_pool["choosed"].has(wazaname)):
		upgrade_waza(wazaname)
		return
	if(waza_pool["max"].has(wazaname)):
		return	
	CpManager.raise_weight_to_cp(wazaname)
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

func clear_all():
	print("waza_clear")
	wazanum_have = 0
	wazanum_max = 6
	waza_maxlevel = 8
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

func _init():
	wazanum_have = 0
	wazanum_max = 6
	waza_maxlevel = 2
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
		"weight":5,
		"cn":"灵梦",
		"type":"skill",#技能、符卡、衍生
		"locking_type":"nearest_enemy",#目标、定向、随机方向
		"attack_pre":"res://scene/weapons/bullets/reimu_bullet/reimu_bullet.tscn",#发射实体路径
		"diretion":Vector2(0,0),#发射方向
		"diretion_rotation":0,#发射方向旋转角（逆时针角度）
		"creation_distance":0,#距离生成位置的距离
		
		"creating_position":"",#生成位置：在自机处、最近几名敌人处、什么神秘地方处,
		"creating_rule":"",#生成一组、一个个生成
		"attack_gen_times":"",#基础生成次数
		"basic_colddown":1.0,
		"Physical_Addition_Efficiency":0.0,
		"Magical_Addition_Efficiency":1.0,
		"Speed_Efficiency":1.0,
		"Duration_Efficiency":1.0,
		"Range_Efficiency":1.0,
		"Magical_Times_Efficiency":1.0,
		"Physical_Times_Efficiency":1.0,
		"Reduction_Efficiency":1.0,
		"cp_map":{},
		"upgrade_map":{
			"Damage_Addition":[],
			"Bullet_Speed_Addition":[],
			"Duration_Addition":[],
			"Range_Addition":[],
			"Times_Addition":[],
			"Debuff_Addition":[],
			"Cd_Reduction":[]
						}
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
