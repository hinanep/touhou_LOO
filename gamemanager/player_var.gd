extends Node

var player_melee_damage_ratio#- 体术伤害倍率：影响体术类技能的伤害
var player_bullet_damage_ratio #- 弹幕伤害倍率：影响弹幕类技能的伤害
var bullet_speed_ratio #子弹速度比率
var keep_time  #持续时间#
var range_add_ratio#攻击范围
var danma_times  #弹幕发射数量加成
var melee_times  # 体术攻击次数
var colddown_reduce #冷却缩减

var player_hp_max: #生命上限
	get:
		return (player_hp_max+hp_max_ex)*hp_max_ex_percent
var hp_max_ex = 200
var hp_max_ex_percent = 1.5

var player_hp_regen  #每秒生命回复
var lifesteal  #吸血：造成伤害时回复伤害量与吸血相乘的生命值
var player_speed  #移动速度
var player_life_addi  #- 残机：血量耗尽后游戏结束，但如果还有残机的话可以消耗一残机满血继续
var defence_melee  #- 体术防御：受到敌人碰撞伤害（能直接被玩家击破的东西接触玩家时的伤害）时获得与体术防御相关的减免
var defence_bullet #- 弹幕防御：受到敌人弹幕伤害时获得与弹幕防御相关的减免
var invincible_time  #- 受伤后无敌时间：受到伤害后的无敌时间

var range_pick #- 拾取范围：拾取记忆碎片的最大距离
var luck  #- 幸运：影响各种与概率相关的东西
var experience_ratio  #- 经验倍率：影响每一记忆碎片增加多少经验
var point_ratio #- 得点倍率：影响每一记忆碎片增加多少分数
var mana_ratio #- 符力倍率：影响每一记忆碎片增加多少符力
var change_times #- 刷新排除次数：增加刷新与排除的次数。前者可刷新升级时可选的记忆结晶，后者可使选择的记忆结晶在本局游戏剩余时间内不再出现
var curse  #- 诅咒：增加敌人的各属性和刷新率
var mana_max #- 符力上限：可存储的最大符力
var skill_level_max
var skill_num_max

var language = 'CHS'

#运行时使用
var SkillManager :SkillManagers
var CardManager :CardManagers
var SpawnManager :SpawnManagers
var PassiveManager :PassiveManagers
var CpManager :CpManagers
var dep:dep_formula = dep_formula.new()
var player_hp
var mana
var mana_cost
var point:int
var player_exp
var level
var is_invincible
var time_secs
var player_diretion_angle

var card_full #没有能升级的符卡并且卡位满了
var card_num_full #卡位满了
var card_level_max
var card_num_max



var passive_num_full
var passive_full
var passive_level_max
var passive_num_max

var is_card_casting
var player_node
var exp_need

var damage_sum

func _ready() -> void:
	ini()
	pass
func new_scene():
	if SkillManager!=null:
		SkillManager.destroy()
		SkillManager.free()
	if CardManager!=null:
		CardManager.destroy()
		CardManager.free()
	if PassiveManager!=null:
		PassiveManager.destroy()
		PassiveManager.free()
	if CpManager!=null:
		CpManager.destroy()
		CpManager.free()

	SkillManager = SkillManagers.new()
	CardManager = CardManagers.new()
	PassiveManager = PassiveManagers.new()
	CpManager = CpManagers.new()
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
func player_take_melee_damage(player_ins,damage):

	damage = damage * 10.0
	damage /= 10 + defence_melee
	player_ins.take_damage(damage)

func player_take_bullet_damage(player_ins,damage):
	player_ins.take_damage(damage * 10 / (10 + defence_bullet))

func player_get_heal(heal):
	player_hp += heal
	player_hp = min(player_hp,player_hp_max)

func ini():
	var ini_list = initial_status.new().status
	for property in ini_list:
		set(property,ini_list[property])
