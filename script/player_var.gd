extends Node

var player_melee_damage_ratio = 1.0#- 体术伤害倍率：影响体术类技能的伤害
var player_bullet_damage_ratio = 1.0#- 弹幕伤害倍率：影响弹幕类技能的伤害
var bullet_speed_ratio = 1.0 #子弹速度比率
var keep_time = 1.0 #持续时间#
var range_add_ratio = 1.0 #攻击范围
var bullet_times = 1 #弹幕发射数量
var melee_times = 1 # 体术攻击次数
var colddown_reduce = 0.0#冷却缩减

var player_hp_max = 20000.0 #生命上限
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
var power_max = 100#- 符力上限：可存储的最大符力

@onready var ui_manager = get_tree().get_first_node_in_group("UiManager")
#待移除？
#var damageRatio = 1.0	#玩家造成伤害比率，全局增加
#var critical_rate = 0.25 #暴击率
#var critical_damage = 2 #暴击伤害比率
#运行时使用
var nearest_enemy
var player_hp = player_hp_max
var power = power_max 
var point = 0
var player_exp = 0
var level = 0

var exp_need = [1,2,3,4,5,6,7,8,100000]

var random_weapons_selected = [0,0,0,0,0]

var weapon_random_list = { "灵梦": 0,
					"早苗" :0,
					"爱丽丝":0
					}
var weapon_name_path_pair ={
	"灵梦" : "res://scene/weapons/reimu/reimu_weapon.tscn",
	"早苗": "res://scene/weapons/sanae/sanae_weapon.tscn",
	"爱丽丝": "res://scene/weapons/alice_weapon/alice_weapon.tscn"
}
#玩家造成伤害公式
func player_make_melee_damage(basic_damage):
	#if randf() < critical_rate:
	#	return basic_damage * damageRatio * critical_damage
	#else:
		return basic_damage * player_melee_damage_ratio
func player_make_bullet_damage(basic_damage):
	#if randf() < critical_rate:
	#	return basic_damage * damageRatio * critical_damage
	#else:
		return basic_damage * player_bullet_damage_ratio
		
#敌人造成伤害公式
func enemy_make_damage(basic_damage):
	return basic_damage


#玩家受到伤害公式
func player_take_melee_damage(player,damage):
	player.take_damage(damage * 10 / (10 + defence_melee))
	

func player_take_bullet_damage(player,damage):
	player.take_damage(damage * 10 / (10 + defence_bullet))

func get_name_from_numbers(numbers):
	return weapon_random_list.keys()[numbers]

func select_weapon_path(weapon_numbers):
	return weapon_name_path_pair[weapon_random_list.keys()[weapon_numbers]]

func random3_weapons_number_select():
	for i in range(3):

		random_weapons_selected[i]=randi_range(0,weapon_random_list.size()-1)
	#ui_manager.get_node("select_weapon").get_node("select_buttons").get_node("select_1").get_node("weapon1").text = weapon_random_list.keys()[random_weapons_selected[0]]
	#ui_manager.get_node("select_weapon").get_node("select_buttons").get_node("select_2").get_node("weapon2").text = weapon_random_list.keys()[random_weapons_selected[1]]
	#ui_manager.get_node("select_weapon").get_node("select_buttons").get_node("select_3").get_node("weapon3").text = weapon_random_list.keys()[random_weapons_selected[2]]
	#$%select_buttons.get_node("select_1").get_node("weapon1").text = weapon_random_list.keys()[random_weapons_selected[0]]
	#$%select_buttons.get_node("select_2").get_node("weapon2").text = weapon_random_list.keys()[random_weapons_selected[1]]
	#$%select_buttons.get_node("select_3").get_node("weapon3").text = weapon_random_list.keys()[random_weapons_selected[2]]


func delete_weapon_from_list(weapon_name):
	weapon_random_list.erase(weapon_name)
	
func _ready():
	#random3_weapons_number_select()
	pass
