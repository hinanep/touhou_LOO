
extends Node
# 这个脚本你需要挂到游戏的Autoload才能全局读表


static func loader(path:String):
	var file = FileAccess.open(path,FileAccess.READ)
	var txt = file.get_as_text()
	var data = JSON.parse_string(txt)
	file.close()
	return data

var attack_skill = loader('res://settings/dist/Attack/attack_skill.json')
var routine = loader('res://settings/dist/Routine/routine.json')
var skill = loader('res://settings/dist/Skill/skill.json')
var Sheet1 = loader('res://settings/dist/TID/Sheet1.json')
