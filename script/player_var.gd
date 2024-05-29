extends Node

var player_hp = 200
var player_speed = 300.0 #移动速度
var colddown_reduce = 0.2#冷却缩减
var damageRatio = 2.0	#玩家造成伤害比率
var bullet_speed_ratio = 1 #子弹速度比率
var range_add_ratio = 1.5 #攻击范围增加？
var critical_rate = 0.25 #暴击率
var critical_damage = 2 #暴击伤害比率

#玩家造成伤害公式
func player_make_damage(basic_damage):
	#if randf() < critical_rate:
	#	return basic_damage * damageRatio * critical_damage
	#else:
		return basic_damage * damageRatio 
#敌人造成伤害公式
func enemy_make_damage(basic_damage):
	return basic_damage
