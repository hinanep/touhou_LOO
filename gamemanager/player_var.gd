extends Node

var player_melee_damage_ratio#- 体术伤害倍率：影响体术类技能的伤害
var player_bullet_damage_ratio #- 弹幕伤害倍率：影响弹幕类技能的伤害
var bullet_speed_ratio #子弹速度比率
var keep_time  #持续时间#
var range_add_ratio#攻击范围
var danma_times  #弹幕发射数量加成
var melee_times  # 体术攻击次数
var colddown_reduce #冷却缩减
var player_hp=0:
	get:
		return player_hp
	set(value):
		player_hp = clamp(value,-1,player_hp_max)
var player_hp_max = 0: #生命上限
	get:
		return (player_hp_max+hp_max_ex)*hp_max_ex_percent
	set(value):
		var ex = value - player_hp_max
		player_hp_max = value
		player_hp += ex

var hp_max_ex = 0
var hp_max_ex_percent = 1

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
var point_ratio=1 #- 得点倍率：影响每一记忆碎片增加多少分数
var mana_ratio #- 符力倍率：影响每一记忆碎片增加多少符力
var change_times #- 刷新排除次数：增加刷新与排除的次数。前者可刷新升级时可选的记忆结晶，后者可使选择的记忆结晶在本局游戏剩余时间内不再出现
var curse  #- 诅咒：增加敌人的各属性和刷新率
var mana_max=0: #- 符力上限：可存储的最大符力
			set(value):
				var ex = value - mana_max
				mana_max = value
				mana += ex
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

var air_wall_top
var air_wall_bottom
var air_wall_left
var air_wall_right

var mana=0:
		set(value):
			mana = clamp(value,0,mana_max)
var mana_cost
var last_cardcost = 100
var point:int:
	set(value):
		point = point + (value-point) *point_ratio
var is_uping = false
var player_exp=0:
	set(value):

		if value - player_exp > 0:
			AudioManager.play_sfx("music_sfx_pickup")
		player_exp = value
		if is_uping!=true and player_var.player_exp >= player_var.exp_need:
			is_uping = true
			level_up()
var level=0
var is_invincible
var time_secs
var player_diretion_angle

var card_full #没有能升级的符卡并且卡位满了
var card_num_full #卡位满了
var card_level_max
var card_num_max

var summon_level_max



var passive_num_max

var is_card_casting
var player_node
var exp_need:
	get:
		return level*12 +12

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
func player_take_melee_damage(damage):
	return damage /( 1 + defence_melee)


func player_take_danma_damage(damage):
	return damage /( 1 + defence_bullet)

func player_get_heal(heal):
	player_hp += heal
	player_hp = min(player_hp,player_hp_max)

func level_up():

	AudioManager.play_sfx("music_sfx_levelup")
	player_var.player_exp -= player_var.exp_need
	player_var.level += 1
	G.get_gui_view_manager().open_view("LevelUp")

func shake_screen(time,interval,intensity,speed,camera:Node2D=player_node.get_node('Camera2D')):
	var offset
	if camera == null:
		return
	var ct:Tween = camera.create_tween().set_speed_scale(speed)
	while(time > 0):
		ct.tween_property(camera,'position',Vector2.ZERO+Vector2(randf_range(-intensity,intensity),randf_range(-intensity,intensity)),interval)
		time-=interval

	ct.tween_property(camera,'position',Vector2.ZERO,interval)
	ct = null

func ini():
	var ini_list = initial_status.new()
	for property in ini_list.status:
		set(property,ini_list.status[property])
	ini_list = null
