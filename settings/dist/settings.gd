
extends Node
# 这个脚本你需要挂到游戏的Autoload才能全局读表


static func loader(path:String):
    var file = FileAccess.open(path,FileAccess.READ)
    var txt = file.get_as_text()
    var data = JSON.parse_string(txt)
    file.close()
    return data

var Atk_Dependence = loader('res://settings/dist/AtkDependence/Atk_Dependence.json')
var Attack = loader('res://settings/dist/Attack/Attack.json')
var Buff = loader('res://settings/dist/Buff/Buff.json')
var Couple = loader('res://settings/dist/Couple/Couple.json')
var Enemy = loader('res://settings/dist/Enemy/Enemy.json')
var Passive = loader('res://settings/dist/Passive/Passive.json')
var routine = loader('res://settings/dist/Routine/routine.json')
var skill = loader('res://settings/dist/Skill/skill.json')
var SpellCard = loader('res://settings/dist/SpellCard/SpellCard.json')
var Stage1 = loader('res://settings/dist/StageProcess/Stage1.json')
var Sum_Dependence = loader('res://settings/dist/SumDependence/Sum_Dependence.json')
var Summoned = loader('res://settings/dist/Summoned/Summoned.json')
var TID = loader('res://settings/dist/TID/TID.json')
var Upgrade = loader('res://settings/dist/Upgrade/Upgrade.json')
