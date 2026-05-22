extends Node
## 只读配置表 Autoload；局内数值变更经 RunModifiers.resolve 查询，勿直接改写 Attack/Skill 等字段。


static func loader(path: String) -> Dictionary:
	var txt = FileAccess.get_file_as_string(path)
	var data: Dictionary = JSON.parse_string(txt)
	for key in data.keys():
		for skey in data[key].keys():
			if is_null(data[key][skey]):
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

var dialogues: Dictionary = {}

var stage1_after = loader('res://settings/dist/Dialogues/stage1_after.json')
var stage1_before = loader('res://settings/dist/Dialogues/stage1_before.json')


static func is_null(datax) -> bool:
	match typeof(datax):
		TYPE_STRING:
			if datax == '':
				return true
		TYPE_ARRAY:
			return datax.is_empty()
		_:
			return false
	return false


func clear_session_state() -> void:
	RunModifiers.clear()
	dialogues = {}


func get_base_table(table_name: String) -> Dictionary:
	match table_name:
		'Attack':
			return Attack
		'Skill':
			return Skill
		'Routine':
			return Routine
		'Summoned':
			return Summoned
		'SpellCard':
			return SpellCard
		'Passive':
			return Passive
		'Buff':
			return Buff
		_:
			return {}


func get_base_row(table_name: String, row_id: String) -> Dictionary:
	var base_table = get_base_table(table_name)
	if base_table.has(row_id):
		return base_table[row_id]
	return {}


func resolve_attack(row_id: String) -> Dictionary:
	return RunModifiers.resolve('Attack', row_id)


func resolve_skill(row_id: String) -> Dictionary:
	return RunModifiers.resolve('Skill', row_id)


func resolve_routine(row_id: String) -> Dictionary:
	return RunModifiers.resolve('Routine', row_id)


func resolve_summoned(row_id: String) -> Dictionary:
	return RunModifiers.resolve('Summoned', row_id)
