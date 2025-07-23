extends Node
# 这个脚本你需要挂到游戏的Autoload才能全局读表


static func loader(path:String):
	var islog = false


	var txt =FileAccess.get_file_as_string(path)

	var data:Dictionary = JSON.parse_string(txt)

	for key in data.keys():
		for skey in data[key].keys():
			if is_null(data[key][skey]):
				if islog:
					print('--')
					print(key)
					print(skey)
				data[key].erase(skey)

	return data



var Atk_Dependence = loader('res://settings/dist/AtkDependence/Atk_Dependence.json')
var Attack = loader('res://settings/dist/Attack/Attack.json')
var keine = loader('res://settings/dist/BossProcess/keine.json')
var keine_routine = loader('res://settings/dist/BossRoutine/keine_routine.json')
var Buff = loader('res://settings/dist/Buff/Buff.json')
var Couple = loader('res://settings/dist/Couple/Couple.json')
var danma = loader('res://settings/dist/Danmaku/danma.json')
var d4c = loader('res://settings/dist/DanmakuCreator/d4c.json')
var dialog_s1 = loader('res://settings/dist/Dialog/dialog_s1.json')
var Enemy = loader('res://settings/dist/Enemy/Enemy.json')
var Passive = loader('res://settings/dist/Passive/Passive.json')
var Routine = loader('res://settings/dist/Routine/routine.json')
var Skill = loader('res://settings/dist/Skill/skill.json')
var SpellCard = loader('res://settings/dist/SpellCard/SpellCard.json')
var Stage1 = loader('res://settings/dist/StageProcess/Stage1.json')
var Sum_Dependence = loader('res://settings/dist/SumDependence/Sum_Dependence.json')
var Summoned = loader('res://settings/dist/Summoned/Summoned.json')
var TID = loader('res://settings/dist/TID/TID.json')
var Upgrade = loader('res://settings/dist/Upgrade/Upgrade.json')


static func is_null(datax):

	match typeof(datax):
		TYPE_STRING:
			if datax=='':
				return true
		TYPE_ARRAY:
			return datax.is_empty()

		_:
			return false
	return false
