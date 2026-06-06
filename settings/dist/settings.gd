
extends Node
# 这个脚本你需要挂到游戏的Autoload才能全局读表


static func loader(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var txt: String = file.get_as_text()
	var data: Dictionary = JSON.parse_string(txt)
	file.close()
	return data

var Atk_Dependence: Dictionary = loader('res://settings/dist/AtkDependence/Atk_Dependence.json')
var Attack: Dictionary = loader('res://settings/dist/Attack/Attack.json')
var keine: Dictionary = loader('res://settings/dist/BossProcess/keine.json')
var keine_routine: Dictionary = loader('res://settings/dist/BossRoutine/keine_routine.json')
var Buff: Dictionary = loader('res://settings/dist/Buff/Buff.json')
var Couple: Dictionary = loader('res://settings/dist/Couple/Couple.json')
var danma: Dictionary = loader('res://settings/dist/Danmaku/danma.json')
var d4c: Dictionary = loader('res://settings/dist/DanmakuCreator/d4c.json')
var dialog_s1a: Dictionary = loader('res://settings/dist/Dialog/dialog_s1a.json')
var dialog_s1b: Dictionary = loader('res://settings/dist/Dialog/dialog_s1b.json')
var stage1_after: Dictionary = loader('res://settings/dist/Dialogues/stage1_after.json')
var stage1_before: Dictionary = loader('res://settings/dist/Dialogues/stage1_before.json')
var Enemy: Dictionary = loader('res://settings/dist/Enemy/Enemy.json')
var Global: Dictionary = loader('res://settings/dist/Global/Global.json')
var Passive: Dictionary = loader('res://settings/dist/Passive/Passive.json')
var routine: Dictionary = loader('res://settings/dist/Routine/routine.json')
var skill: Dictionary = loader('res://settings/dist/Skill/skill.json')
var SpellCard: Dictionary = loader('res://settings/dist/SpellCard/SpellCard.json')
var Stage1: Dictionary = loader('res://settings/dist/StageProcess/Stage1.json')
var Sum_Dependence: Dictionary = loader('res://settings/dist/SumDependence/Sum_Dependence.json')
var Summoned: Dictionary = loader('res://settings/dist/Summoned/Summoned.json')
var TID: Dictionary = loader('res://settings/dist/TID/TID.json')
var TID_UI: Dictionary = loader('res://settings/dist/TID/TID_UI.json')
var Upgrade: Dictionary = loader('res://settings/dist/Upgrade/Upgrade.json')
