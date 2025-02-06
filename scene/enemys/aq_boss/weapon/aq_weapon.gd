extends skill


func _ready():
		skill_info = {
		"waza_name" : "aq",
		"level":0,
		"path":"waza_sekibanki",
		"weight":0,
		"cn":"赤蛮奇",
		"type":"skill",#技能、符卡、衍生0

		"locking_type":"random",#目标、定向、随机方向01
		"attack_pre":"aq_punch",#发射实体路径1
		"diretion_rotation":0,#发射方向旋转角（逆时针角度）1
		"creation_distance":0,#距离生成位置的距离1

		"creating_position":"self",#生成位置：在自机处、最近几名敌人处、什么神秘地方处,1
		"creating_rule":"one",#生成一组、一个个生成1
		"attack_gen_times":20,#生成次数1
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
		"shoot_sfx":"music_sfx_shoot"

	}

		super._ready()
		bullet_modi_map ={
		"Damage_Addition":1,
		"Bullet_Speed_Addition":1,
		"Duration_Addition":1,
		"Range_Addition":1,
		"Debuff_Addition":1,
		"damage_source":"none"
	}
		pass # Replace with function body.






func upgrade_waza():

	super.upgrade_waza()
	pass
