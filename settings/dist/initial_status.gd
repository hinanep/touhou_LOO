extends RefCounted
class_name InitialStatus

const _PlayerVar = preload("res://gamemanager/player_var.gd")

var player_melee_damage_ratio: float = 1.0 #- 体术伤害倍率：影响体术类技能的伤害
var player_bullet_damage_ratio: float = 1.0 #- 弹幕伤害倍率：影响弹幕类技能的伤害
var bullet_speed_ratio: float = 1.0 #子弹速度比率
var bullet_duration_ratio: float = 1.0 #持续时间#
var range_add_ratio: float = 1.0 #攻击范围
var danma_times: int = 0 #弹幕发射数量加成
var melee_times: int = 0 # 体术攻击次数
var colddown_reduce: float = 0.0 #冷却缩减

var player_hp_max: float = 200.0 #生命上限
var player_hp_regen: float = 0.0 #每秒生命回复
var lifesteal: float = 0.0 #吸血：造成伤害时回复伤害量与吸血相乘的生命值
var player_speed: float = 300.0 #移动速度
var player_life_addi: int = 0 #- 残机：血量耗尽后游戏结束，但如果还有残机的话可以消耗一残机满血继续
var defence_melee: float = 0.0 #- 体术防御：受到敌人碰撞伤害（能直接被玩家击破的东西接触玩家时的伤害）时获得与体术防御相关的减免
var defence_bullet: float = 0.0 #- 弹幕防御：受到敌人弹幕伤害时获得与弹幕防御相关的减免
var invincible_time: float = 1.0 #- 受伤后无敌时间：受到伤害后的无敌时间

var range_pick: float = 30.0 #- 拾取范围：拾取记忆碎片的最大距离
var luck: float = 1.0 #- 幸运：影响各种与概率相关的东西
var experience_ratio: float = 1.0 #- 经验倍率：影响每一记忆碎片增加多少经验
var point_ratio: float = 1.0 #- 得点倍率：影响每一记忆碎片增加多少分数
var mana_ratio: float = 1.0 #- 符力倍率：影响每一记忆碎片增加多少符力
var change_times: int = 2 #- 刷新排除次数：增加刷新与排除的次数。前者可刷新升级时可选的记忆结晶，后者可使选择的记忆结晶在本局游戏剩余时间内不再出现
var curse: float = 1.0 #- 诅咒：增加敌人的各属性和刷新率
var mana_max: float = 2000.0 #- 符力上限：可存储的最大符力
var skill_level_max: int = 6
var skill_num_max: int = 6
var summon_level_max: int = 6
var last_cardcost: float = 100.0
var player_hp: float = 2000.0
var mana: float = 2000.0
var mana_cost: float = 1.0
var point: int = 0
var player_exp: float = 0.0
var level: int = 0
var is_invincible: bool = false
var time_secs: float = 0.0
var player_diretion_angle: float = 0.0
var is_uping: bool = false
var card_full: bool = false #没有能升级的符卡并且卡位满了
var card_num_full: bool = false #卡位满了
var card_level_max: int = 6
var card_num_max: int = 3
var free_card: int = 0
var passive_num_max: int = 3
var is_card_casting: bool = false
var damage_sum: Dictionary[String, float] = {"none": 0.0}


## 将初始属性写入 player_var 节点
func apply_to(target: _PlayerVar) -> void:
	target.player_melee_damage_ratio = player_melee_damage_ratio
	target.player_bullet_damage_ratio = player_bullet_damage_ratio
	target.bullet_speed_ratio = bullet_speed_ratio
	target.bullet_duration_ratio = bullet_duration_ratio
	target.range_add_ratio = range_add_ratio
	target.danma_times = danma_times
	target.melee_times = melee_times
	target.colddown_reduce = colddown_reduce
	target.player_hp_max = player_hp_max
	target.player_hp_regen = player_hp_regen
	target.lifesteal = lifesteal
	target.player_speed = player_speed
	target.player_life_addi = player_life_addi
	target.defence_melee = defence_melee
	target.defence_bullet = defence_bullet
	target.invincible_time = invincible_time
	target.range_pick = range_pick
	target.luck = luck
	target.experience_ratio = experience_ratio
	target.point_ratio = point_ratio
	target.mana_ratio = mana_ratio
	target.change_times = change_times
	target.curse = curse
	target.mana_max = mana_max
	target.skill_level_max = skill_level_max
	target.skill_num_max = skill_num_max
	target.summon_level_max = summon_level_max
	target.last_cardcost = last_cardcost
	target.player_hp = player_hp
	target.mana = mana
	target.mana_cost = mana_cost
	target.point = point
	target.player_exp = player_exp
	target.level = level
	target.is_invincible = is_invincible
	target.time_secs = time_secs
	target.player_diretion_angle = player_diretion_angle
	target.is_uping = is_uping
	target.card_full = card_full
	target.card_num_full = card_num_full
	target.card_level_max = card_level_max
	target.card_num_max = card_num_max
	target.free_card = free_card
	target.passive_num_max = passive_num_max
	target.is_card_casting = is_card_casting
	target.damage_sum = damage_sum.duplicate()
