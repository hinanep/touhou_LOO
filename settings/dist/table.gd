extends Node
# 这个脚本你需要挂到游戏的Autoload才能全局读表


static func loader(path:String):
	var islog = false
	var file = FileAccess.open(path,FileAccess.READ)
	var txt = file.get_as_text()
	var data = JSON.parse_string(txt)
	file.close()
	for key in data.keys():
		for skey in data[key].keys():
			if is_null(data[key][skey]):
				if islog:
					print('--')
					print(key)
					print(skey)
				data[key].erase(skey)
	return data


var Attack = loader('res://settings/dist/Attack/Attack.json')
var Buff = loader('res://settings/dist/Buff/Buff.json')
var Enemy = loader('res://settings/dist/Enemy/Enemy.json')
var Passive = loader('res://settings/dist/Passive/Passive.json')
var Routine = loader('res://settings/dist/Routine/Routine.json')
var Skill = loader('res://settings/dist/Skill/Skill.json')
var SpellCard = loader('res://settings/dist/SpellCard/SpellCard.json')
var Stage1 = loader('res://settings/dist/StageProcess/Stage1.json')
var StageProcess = loader('res://settings/dist/StageProcess/StageProcess.json')



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
