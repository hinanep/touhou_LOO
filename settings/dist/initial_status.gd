extends RefCounted
class_name  initial_status
var status = {
	player_melee_damage_ratio = 1.0,#- 体术伤害倍率：影响体术类技能的伤害
	player_bullet_damage_ratio = 1.0,#- 弹幕伤害倍率：影响弹幕类技能的伤害
	bullet_speed_ratio = 1.0 ,#子弹速度比率
	keep_time = 1.0 ,#持续时间#
	range_add_ratio = 1.0 ,#攻击范围
	danma_times = 0, #弹幕发射数量加成
	melee_times = 0, # 体术攻击次数
	colddown_reduce = 0.0,#冷却缩减

	player_hp_max = 200.0, #生命上限
	player_hp_regen = 0.0, #每秒生命回复
	lifesteal = 0.0, #吸血：造成伤害时回复伤害量与吸血相乘的生命值
	player_speed = 300.0 ,#移动速度
	player_life_addi = 0, #- 残机：血量耗尽后游戏结束，但如果还有残机的话可以消耗一残机满血继续
	defence_melee = 0.0 ,#- 体术防御：受到敌人碰撞伤害（能直接被玩家击破的东西接触玩家时的伤害）时获得与体术防御相关的减免
	defence_bullet = 0.0, #- 弹幕防御：受到敌人弹幕伤害时获得与弹幕防御相关的减免
	invincible_time = 1 ,#- 受伤后无敌时间：受到伤害后的无敌时间

	range_pick = 30,#- 拾取范围：拾取记忆碎片的最大距离
	luck = 1.0, #- 幸运：影响各种与概率相关的东西
	experience_ratio = 1.0 ,#- 经验倍率：影响每一记忆碎片增加多少经验
	point_ratio = 1.0,#- 得点倍率：影响每一记忆碎片增加多少分数
	mana_ratio = 1.0,#- 符力倍率：影响每一记忆碎片增加多少符力
	change_times = 2,#- 刷新排除次数：增加刷新与排除的次数。前者可刷新升级时可选的记忆结晶，后者可使选择的记忆结晶在本局游戏剩余时间内不再出现
	curse = 1.0, #- 诅咒：增加敌人的各属性和刷新率
	mana_max = 2000,#- 符力上限：可存储的最大符力
	skill_level_max = 6,
	skill_num_max = 6,
	summon_level_max = 6,
	last_cost = 100,
	player_hp = 2000.0,
	mana = 2000,
	mana_cost= 1,
	point = 0,
	player_exp = 0,
	level = 0,
	is_invincible = false,
	time_secs = 0,
	player_diretion_angle = 0,
	is_uping = false,
	card_full = false,#没有能升级的符卡并且卡位满了
	card_num_full = false,#卡位满了
	card_level_max = 6,
	card_num_max = 3,

	air_wall_top = -10000,
	air_wall_bottom = 10000,
	air_wall_left = -10000,
	air_wall_right = 10000,



	passive_num_max = 3,

	is_card_casting = false,
	exp_need = [12,24,36,48,60,72,84,96,108,132,156,184,216,260,292,348,384,408,432,456,480,504,9223372036854775807],

	damage_sum = {
		"none" : 0
	}
}
