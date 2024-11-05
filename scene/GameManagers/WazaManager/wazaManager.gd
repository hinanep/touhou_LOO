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

	var weapon = load(path)
	weapon = weapon.instantiate()
	weapon.waza_config = waza_pool["unchoosed"][wazaname]
	player_var.player_node.get_node("WazaManager").add_child(weapon)
	weapon.position = Vector2(0,0)
	
	waza_pool["choosed"][wazaname]=waza_pool["unchoosed"][wazaname]
	waza_pool["unchoosed"].erase(wazaname)
	waza_list[wazaname] = waza_pool["choosed"][wazaname]["level"]
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

func _init():
	wazanum_have = 0
	wazanum_max = 6
	waza_maxlevel = 3
	waza_pool["unchoosed"]["base_range"] = {
	"waza_name" : "base_range",
	"level":waza_maxlevel-1,
	"path":"res://scene/weapons/beginning_weapon/beginning_ranged_attack/beginning_ranged_attack.tscn",
	"weight":1,#随机权重
	"cn":"",#中文名
	"type":"skill",#技能、符卡、衍生0
	
	"locking_type":"diretion",#目标、定向、随机方向01
	"attack_pre":"res://scene/weapons/bullets/beginning_bullet/beginning_bullet.tscn",#发射实体路径1
	"diretion_rotation":0,#发射方向旋转角（逆时针角度）1
	"creation_distance":0,#距离生成位置的距离1
	
	"creating_position":"self",#生成位置：在自机处、最近几名敌人处、什么神秘地方处,1
	"creating_rule":"one",#生成一组、一个个生成1
	"attack_gen_times":1,#生成次数1
	"basic_colddown":1,#1
	
	
	"Physical_Addition_Efficiency":0.0,#
	"Magical_Addition_Efficiency":1.0,#
	"Speed_Efficiency":1.0,#
	"Duration_Efficiency":1.0,#
	"Range_Efficiency":1.0,
	
	"Magical_Times_Efficiency":1,#1
	"Physical_Times_Efficiency":1.0,#1	
	"Reduction_Efficiency":1.0,#1
	
	"cp_map":{},#
	"upgrade_map":{#
		"Damage_Addition":[1,2,3,4,5,6,7,1],
		"Bullet_Speed_Addition":[1,2,3,4,5,6,7,1],
		"Duration_Addition":[1,1,1,1,1,1,1,1],
		"Range_Addition":[1,2,3,5,6,6,6,1],
		"Times":[1,2,3,4,4,4,4,1],
		"Debuff_Addition":[1,1,1,1,1,1,1,1],
		"colddown":[1,0.9,0.8,0.7,0.6,0.6,0.6,1]
					},	#
	"shoot_sfx":"sfx_bulletshoot"
		}
	waza_pool["unchoosed"]["base_melee"] = {
		"level":waza_maxlevel-1,
		"path":"res://scene/weapons/weapon_base/melee_base/melee_weapon_base.tscn"
	}
	waza_pool["unchoosed"]["reimu"] = {
	"waza_name" : "reimu",
	"level":0,
	"path":"res://scene/weapons/reimu/reimu_weapon.tscn",
	"weight":5,#随机权重
	"cn":"灵梦",#中文名
	"type":"skill",#技能、符卡、衍生0
	
	"locking_type":"nearest_enemy",#目标、定向、随机方向01
	"attack_pre":"res://scene/weapons/bullets/reimu_bullet/reimu_bullet.tscn",#发射实体路径1
	"diretion_rotation":0,#发射方向旋转角（逆时针角度）1
	"creation_distance":0,#距离生成位置的距离1
	
	"creating_position":"self",#生成位置：在自机处、最近几名敌人处、什么神秘地方处,1
	"creating_rule":"one",#生成一组、一个个生成1
	"attack_gen_times":1,#生成次数1
	"basic_colddown":1,#1
	
	
	"Physical_Addition_Efficiency":0.0,#
	"Magical_Addition_Efficiency":1.0,#
	"Speed_Efficiency":1.0,#
	"Duration_Efficiency":1.0,#
	"Range_Efficiency":1.0,
	
	"Magical_Times_Efficiency":1,#1
	"Physical_Times_Efficiency":1.0,#1	
	"Reduction_Efficiency":1.0,#1
	
	"cp_map":{
		"reima":{
	"on_hit":["res://scene/weapons/modifier/on_hit/on_hit.tscn"],
	"on_flying":[],
	"on_emit":[],
	"on_destroy":[]
	}
	},#
	"upgrade_map":{#
		"Damage_Addition":[1,2,3,4,5,6,7,8],
		"Bullet_Speed_Addition":[1,2,3,4,5,6,7,8],
		"Duration_Addition":[1,1,1,1,1,1,1,1],
		"Range_Addition":[1,2,3,5,6,6,6,6],
		"Times":[1,2,3,4,4,4,4,4],
		"Debuff_Addition":[1,1,1,1,1,1,1,1],
		"colddown":[1,0.9,0.8,0.7,0.6,0.6,0.6,0.6]
					},	#
	"shoot_sfx":"sfx_bulletshoot"
		}
	waza_pool["unchoosed"]["sanae"] = {
		"waza_name" : "sanae",
		"level":0,
		"path":"res://scene/weapons/sanae/sanae_weapon.tscn",
		"weight":1,
		"cn":"早苗",	#
		"type":"skill",#技能、符卡、衍生0
	
		"locking_type":"nearest_enemy",#目标、定向、随机方向01
		"attack_pre":"",#发射实体路径1
		"diretion_rotation":0,#发射方向旋转角（逆时针角度）1
		"creation_distance":0,#距离生成位置的距离1
		
		"creating_position":"self",#生成位置：在自机处、最近几名敌人处、什么神秘地方处,1
		"creating_rule":"one",#生成一组、一个个生成1
		"attack_gen_times":1,#生成次数1
		"basic_colddown":1,#1
		
		
		"Physical_Addition_Efficiency":0.0,#
		"Magical_Addition_Efficiency":1.0,#
		"Speed_Efficiency":1.0,#
		"Duration_Efficiency":1.0,#
		"Range_Efficiency":1.0,
		
		"Magical_Times_Efficiency":1,#1
		"Physical_Times_Efficiency":1.0,#1	
		"Reduction_Efficiency":1.0,#1
		
		"cp_map":{},#
		"upgrade_map":{#
			"Damage_Addition":[1,2,3,4,5,6,7,8],
			"Bullet_Speed_Addition":[1,2,3,4,5,6,7,8],
			"Duration_Addition":[1,1,1,1,1,1,1,1],
			"Range_Addition":[1,2,3,5,6,6,6,6],
			"Times":[1,2,3,4,4,4,4,4],
			"Debuff_Addition":[1,1,1,1,1,1,1,1],
			"colddown":[1,0.9,0.8,0.7,0.6,0.6,0.6,0.6]
						},
		"shoot_sfx":"sfx_bulletshoot"
	}
	waza_pool["unchoosed"]["alice"] = {
		"waza_name" : "alice",
		"level":0,
		"path":"res://scene/weapons/alice_weapon/alice_weapon.tscn",
		"weight":2,
		"cn":"爱丽丝",
		"type":"skill",#技能、符卡、衍生0
	
		"locking_type":"random",#目标、定向、随机方向01
		"attack_pre":"res://scene/weapons/bullets/alice_bullet/alice_bullet.tscn",#发射实体路径1
		"diretion_rotation":0,#发射方向旋转角（逆时针角度）1
		"creation_distance":0,#距离生成位置的距离1
		
		"creating_position":"self",#生成位置：在自机处、最近几名敌人处、什么神秘地方处,1
		"creating_rule":"one",#生成一组、一个个生成1
		"attack_gen_times":1,#生成次数1
		"basic_colddown":1,#1
		
		
		"Physical_Addition_Efficiency":0.0,#
		"Magical_Addition_Efficiency":1.0,#
		"Speed_Efficiency":1.0,#
		"Duration_Efficiency":1.0,#
		"Range_Efficiency":1.0,
		
		"Magical_Times_Efficiency":1,#1
		"Physical_Times_Efficiency":1.0,#1	
		"Reduction_Efficiency":1.0,#1
		
		"cp_map":{},#
		"upgrade_map":{#
			"Damage_Addition":[1,2,3,4,5,6,7,8],
			"Bullet_Speed_Addition":[1,2,3,4,5,6,7,8],
			"Duration_Addition":[1,1,1,2,3,3,3,3],
			"Range_Addition":[1,2,2,2,2,2,2,2],
			"Times":[1,1,2,2,2,2,2,2],
			"Debuff_Addition":[1,1,1,1,1,1,1,1],
			"colddown":[1,0.9,0.8,0.7,0.6,0.6,0.6,0.6]
						},
		"shoot_sfx":"sfx_bulletshoot"
	}
	waza_pool["unchoosed"]["sekibanki"] = {
		"waza_name" : "sekibanki",
		"level":0,
		"path":"res://scene/weapons/sekibanki/sekibanki_weapon.tscn",
		"weight":0,
		"cn":"赤蛮奇",
		"type":"skill",#技能、符卡、衍生0
	
		"locking_type":"random",#目标、定向、随机方向01
		"attack_pre":"res://scene/weapons/bullets/fly_head_bullet/fly_head.tscn",#发射实体路径1
		"diretion_rotation":0,#发射方向旋转角（逆时针角度）1
		"creation_distance":0,#距离生成位置的距离1
		
		"creating_position":"self",#生成位置：在自机处、最近几名敌人处、什么神秘地方处,1
		"creating_rule":"one",#生成一组、一个个生成1
		"attack_gen_times":3,#生成次数1
		"basic_colddown":3,#1
		
		
		"Physical_Addition_Efficiency":0.0,#
		"Magical_Addition_Efficiency":1.0,#
		"Speed_Efficiency":1.0,#
		"Duration_Efficiency":1.0,#
		"Range_Efficiency":1.0,
		
		"Magical_Times_Efficiency":1,#1
		"Physical_Times_Efficiency":1.0,#1	
		"Reduction_Efficiency":1.0,#1
		
		"cp_map":{},#
		"upgrade_map":{#
			"Damage_Addition":[1,2,3,4,5,6,7,8],
			"Bullet_Speed_Addition":[1,1.1,1.1,1.1,1.1,1.1,1.1,1.1],
			"Duration_Addition":[1,2,2,2,3,3,3,3],
			"Range_Addition":[1,1.1,1.2,1.3,1.4,1.5,1.6,1.7],
			"Times":[3,4,5,6,6,6,6,6],
			"Debuff_Addition":[1,1,1,1,1,1,1,1],
			"colddown":[1,0.9,0.8,0.7,0.6,0.6,0.6,0.6]
						},
		"shoot_sfx":"sfx_bulletshoot"

	}
	
	waza_pool["unchoosed"]["tamatsukuri"] = {
		"waza_name" : "tamatsukuri",
		"level":0,
		"path":"res://scene/weapons/tamatsukuri/tamatsukuri.tscn",
		"weight":15,
		"cn":"魅须丸",
		"type":"skill",#技能、符卡、衍生0
	
		"locking_type":"random",#目标、定向、随机方向01
		"attack_pre":"res://scene/weapons/bullets/tamatsukuri_bullet/tamatsukuri_bullet.tscn",#发射实体路径1
		"diretion_rotation":0,#发射方向旋转角（逆时针角度）1
		"creation_distance":0,#距离生成位置的距离1
		
		"creating_position":"self",#生成位置：在自机处、最近几名敌人处、什么神秘地方处,1
		"creating_rule":"one",#生成一组、一个个生成1
		"attack_gen_times":1,#生成次数1
		"basic_colddown":1,#1
		
		
		"Physical_Addition_Efficiency":0.0,#
		"Magical_Addition_Efficiency":1.0,#
		"Speed_Efficiency":1.0,#
		"Duration_Efficiency":1.0,#
		"Range_Efficiency":1.0,
		
		"Magical_Times_Efficiency":1,#1
		"Physical_Times_Efficiency":1.0,#1	
		"Reduction_Efficiency":1.0,#1
		
		"cp_map":{
			"reitama":{
		"on_hit":[],
		"on_flying":[],
		"on_emit":[],
		"on_destroy":["res://scene/weapons/modifier/on_destroy/on_destroy.tscn"]
		}
		},#
		"upgrade_map":{#
			"Damage_Addition":[1,2,3,4,5,6,7,8],
			"Bullet_Speed_Addition":[1,1.1,1.1,1.1,1.1,1.1,1.1,1.1],
			"Duration_Addition":[1,2,2,2,3,3,3,3],
			"Range_Addition":[1,1.1,1.2,1.3,1.4,1.5,1.6,1.7],
			"Times":[1,2,2,2,2,2,2,2],
			"Debuff_Addition":[1,1,1,1,1,1,1,1],
			"colddown":[1,0.9,0.8,0.7,0.6,0.6,0.6,0.6]
						},
		"shoot_sfx":"sfx_bulletshoot"

	}

	waza_pool["unchoosed"]["medicine"] = {
		"waza_name" : "medicine",
		"level":0,
		"path":"res://scene/weapons/medicine/medicine_weapon.tscn",
		"weight":1,
		"cn":"梅蒂欣",
		"type":"skill",#技能、符卡、衍生0
	
		"locking_type":"random",#目标、定向、随机方向01
		"attack_pre":"res://scene/weapons/bullets/medicine_bullet/medicine_bullet.tscn",#发射实体路径1
		"diretion_rotation":0,#发射方向旋转角（逆时针角度）1
		"creation_distance":0,#距离生成位置的距离1
		
		"creating_position":"self",#生成位置：在自机处、最近几名敌人处、什么神秘地方处,1
		"creating_rule":"one",#生成一组、一个个生成1
		"attack_gen_times":3,#生成次数1
		"basic_colddown":1,#1
		
		
		"Physical_Addition_Efficiency":0.0,#
		"Magical_Addition_Efficiency":1.0,#
		"Speed_Efficiency":1.0,#
		"Duration_Efficiency":1.0,#
		"Range_Efficiency":1.0,
		
		"Magical_Times_Efficiency":1,#1
		"Physical_Times_Efficiency":1.0,#1	
		"Reduction_Efficiency":1.0,#1
		
		"cp_map":{},#
		"upgrade_map":{#
			"Damage_Addition":[1,2,3,4,5,6,7,8],
			"Bullet_Speed_Addition":[1,1.1,1.1,1.1,1.1,1.1,1.1,1.1],
			"Duration_Addition":[1,2,2,2,3,3,3,3],
			"Range_Addition":[1,1.1,1.2,1.3,1.4,1.5,1.6,1.7],
			"Times":[3,4,5,6,6,6,6,6],
			"Debuff_Addition":[1,1,1,1,1,1,1,1],
			"colddown":[1,0.9,0.8,0.7,0.6,0.6,0.6,0.6]
						},
		"shoot_sfx":"sfx_bulletshoot"

	}
	waza_pool["unchoosed"]["rumia"] = {
		"waza_name" : "rumia",
		"level":0,
		"path":"res://scene/weapons/rumia/rumia_weapon.tscn",
		"weight":150,
		"cn":"露米娅",
		"type":"skill",#技能、符卡、衍生0
	
		"locking_type":"random",#目标、定向、随机方向01
		"attack_pre":"res://scene/weapons/bullets/rumia_bullet/rumia_bullet.tscn",#发射实体路径1
		"diretion_rotation":0,#发射方向旋转角（逆时针角度）1
		"creation_distance":0,#距离生成位置的距离1
		
		"creating_position":"self",#生成位置：在自机处、最近几名敌人处、什么神秘地方处,1
		"creating_rule":"one",#生成一组、一个个生成1
		"attack_gen_times":1,#生成次数1
		"basic_colddown":1,#1
		
		
		"Physical_Addition_Efficiency":0.0,#
		"Magical_Addition_Efficiency":1.0,#
		"Speed_Efficiency":1.0,#
		"Duration_Efficiency":1.0,#
		"Range_Efficiency":1.0,
		
		"Magical_Times_Efficiency":1,#1
		"Physical_Times_Efficiency":1.0,#1	
		"Reduction_Efficiency":1.0,#1
		
		"cp_map":{},#
		"upgrade_map":{#
			"Damage_Addition":[1,2,3,4,5,6,7,8],
			"Bullet_Speed_Addition":[1,1.1,1.1,1.1,1.1,1.1,1.1,1.1],
			"Duration_Addition":[1,2,2,2,3,3,3,3],
			"Range_Addition":[1,1.1,1.2,1.3,1.4,1.5,1.6,1.7],
			"Times":[3,4,5,6,6,6,6,6],
			"Debuff_Addition":[1,1,1,1,1,1,1,1],
			"colddown":[1,0.9,0.8,0.7,0.6,0.6,0.6,0.6]
						},
		"shoot_sfx":"sfx_bulletshoot"

	}
