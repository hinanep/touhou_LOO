extends Node

var player_melee_damage_ratio = 1.0#- 体术伤害倍率：影响体术类技能的伤害
var player_bullet_damage_ratio = 1.0#- 弹幕伤害倍率：影响弹幕类技能的伤害
var bullet_speed_ratio = 1.0 #子弹速度比率
var keep_time = 1.0 #持续时间#
var range_add_ratio = 1.0 #攻击范围
var bullet_times = 1 #弹幕发射数量
var melee_times = 1 # 体术攻击次数
var colddown_reduce = 0.0#冷却缩减

var player_hp_max = 200.0 #生命上限
var player_hp_regen = 0.0 #每秒生命回复
var lifesteal = 0.0 #吸血：造成伤害时回复伤害量与吸血相乘的生命值
var player_speed = 150.0 #移动速度
var player_life_addi = 0 #- 残机：血量耗尽后游戏结束，但如果还有残机的话可以消耗一残机满血继续
var defence_melee = 100.0 #- 体术防御：受到敌人碰撞伤害（能直接被玩家击破的东西接触玩家时的伤害）时获得与体术防御相关的减免
var defence_bullet = 0.0 #- 弹幕防御：受到敌人弹幕伤害时获得与弹幕防御相关的减免
var invincible_time = 1 #- 受伤后无敌时间：受到伤害后的无敌时间

var range_pick = 30#- 拾取范围：拾取记忆碎片的最大距离
var luck = 1.0 #- 幸运：影响各种与概率相关的东西
var experience_ratio = 1.0 #- 经验倍率：影响每一记忆碎片增加多少经验
var point_ratio = 1.0#- 得点倍率：影响每一记忆碎片增加多少分数
var power_ratio = 1.0#- 符力倍率：影响每一记忆碎片增加多少符力
var change_times = 2#- 刷新排除次数：增加刷新与排除的次数。前者可刷新升级时可选的记忆结晶，后者可使选择的记忆结晶在本局游戏剩余时间内不再出现
var curse = 1.0 #- 诅咒：增加敌人的各属性和刷新率
var power_max = 2000#- 符力上限：可存储的最大符力

@onready var ui_manager = get_tree().get_first_node_in_group("UiManager")

#运行时使用
var nearest_enemy
var nearest_enemy_position
var player_hp = player_hp_max
var power = power_max 
var point:int = 0
var player_exp = 0
var level = 0
var is_invincible = false
var time_secs = 0
var player_diretion_angle = 0

var card_full = false
var card_num_full = false

var waza_num_full = false
var waza_full = false

var passive_num_full = false
var passive_full = false

var is_card_casting = false
var player_node
var exp_need = [12,24,36,48,60,72,84,96,108,132,156,184,216,260,292,348,384,408,432,456,480,504,9999]

var damage_sum = {
	"none" : 0
}
#玩家造成伤害公式
func player_make_melee_damage(basic_damage,damage_source = "none"):
	#if randf() < critical_rate:
	#	return basic_damage * damageRatio * critical_damage
	#else:
		basic_damage *= player_melee_damage_ratio
		damage_sum[damage_source] += basic_damage 
		return basic_damage 
func player_make_bullet_damage(basic_damage,damage_source = "none"):
	#if randf() < critical_rate:
	#	return basic_damage * damageRatio * critical_damage
	#else:
		basic_damage *= player_bullet_damage_ratio
		damage_sum[damage_source] += basic_damage 
		return basic_damage
		
#敌人造成伤害公式
func enemy_make_damage(basic_damage):
	return basic_damage


#玩家受到伤害公式
func player_take_melee_damage(player,damage):
	player.take_damage(damage * 10 / (10 + defence_melee))
	

func player_take_bullet_damage(player,damage):
	player.take_damage(damage * 10 / (10 + defence_bullet))

func player_get_heal(heal):
	player_hp += heal
	player_hp = min(player_hp,player_hp_max)




	
func clear_all():
	player_melee_damage_ratio = 1.0#- 体术伤害倍率：影响体术类技能的伤害
	player_bullet_damage_ratio = 1.0#- 弹幕伤害倍率：影响弹幕类技能的伤害
	bullet_speed_ratio = 1.0 #子弹速度比率
	keep_time = 1.0 #持续时间#
	range_add_ratio = 1.0 #攻击范围
	bullet_times = 1 #弹幕发射数量
	melee_times = 1 # 体术攻击次数
	colddown_reduce = 0.0#冷却缩减

	player_hp_max = 200.0 #生命上限
	player_hp_regen = 0.0 #每秒生命回复
	lifesteal = 0.0 #吸血：造成伤害时回复伤害量与吸血相乘的生命值
	player_speed = 150.0 #移动速度
	player_life_addi = 0 #- 残机：血量耗尽后游戏结束，但如果还有残机的话可以消耗一残机满血继续
	defence_melee = 100.0 #- 体术防御：受到敌人碰撞伤害（能直接被玩家击破的东西接触玩家时的伤害）时获得与体术防御相关的减免
	defence_bullet = 0.0 #- 弹幕防御：受到敌人弹幕伤害时获得与弹幕防御相关的减免
	invincible_time = 1 #- 受伤后无敌时间：受到伤害后的无敌时间

	range_pick = 30#- 拾取范围：拾取记忆碎片的最大距离
	luck = 1.0 #- 幸运：影响各种与概率相关的东西
	experience_ratio = 1.0 #- 经验倍率：影响每一记忆碎片增加多少经验
	point_ratio = 1.0#- 得点倍率：影响每一记忆碎片增加多少分数
	power_ratio = 1.0#- 符力倍率：影响每一记忆碎片增加多少符力
	change_times = 2#- 刷新排除次数：增加刷新与排除的次数。前者可刷新升级时可选的记忆结晶，后者可使选择的记忆结晶在本局游戏剩余时间内不再出现
	curse = 1.0 #- 诅咒：增加敌人的各属性和刷新率
	power_max = 2000#- 符力上限：可存储的最大符力



	#运行时使用
	nearest_enemy = null
	nearest_enemy_position = Vector2(0,0)
	player_hp = player_hp_max
	power = power_max 
	point = 0
	player_exp = 0
	level = 0
	is_invincible = false
	time_secs = 0

	card_full = false
	card_num_full = false

	waza_num_full = false
	waza_full = false

	passive_num_full = false
	passive_full = false

	is_card_casting = false
	player_node = null
	exp_need = [12,24,36,48,60,72,84,96,108,132,156,184,216,260,292,348,384,408,432,456,480,504,9999]
	pass
