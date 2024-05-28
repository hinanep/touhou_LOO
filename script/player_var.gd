extends Node

const player_speed = 300.0 #移动速度
const colddown_reduce = 0.2#冷却缩减
const damageRatio = 2.0	#玩家造成伤害比率
const bullet_speed_ratio = 1 #子弹速度比率
const range_add_ratio = 1.5 #攻击范围增加？
const critical_rate = 0.25 #暴击率
const critical_damage = 2 #暴击伤害比率

#玩家造成伤害公式
func player_make_damage(basic_damage):
	if randf() < critical_rate:
		return basic_damage * damageRatio * critical_damage
	else:
		return basic_damage * damageRatio 
