extends Node

signal stat_changed(stat_name: StringName)

const STAT_HP := &"hp"
const STAT_HP_MAX := &"hp_max"
const STAT_MANA := &"mana"
const STAT_MANA_MAX := &"mana_max"
const STAT_EXP := &"exp"
const STAT_LEVEL := &"level"
const STAT_POINT := &"point"
const STAT_POINT_RATIO := &"point_ratio"
const STAT_LIFE := &"life"
const STAT_FREE_CARD := &"free_card"

const _InitialStatus = preload("res://settings/dist/initial_status.gd")

## HUD 相关 stat 变化时发出 stat_changed
func _emit_stat(stat_name: StringName) -> void:
	stat_changed.emit(stat_name)

##############攻击类#################
var player_melee_damage_ratio: float = 1.0 #- 体术伤害倍率：影响体术类技能的伤害
var player_bullet_damage_ratio: float = 1.0 #- 弹幕伤害倍率：影响弹幕类技能的伤害
var bullet_speed_ratio: float = 1.0 #子弹速度比率
var bullet_duration_ratio: float = 1.0 #持续时间#
var range_add_ratio: float = 1.0 #攻击范围
var danma_times: float = 0.0 #弹幕发射数量加成
var melee_times: float = 0.0 # 体术攻击次数
var colddown_reduce: float = 0.0 #冷却缩减

##############防御类#################

var _player_hp_max_base: float = 0.0
var player_hp_max: float: #生命上限
	get:
		return (_player_hp_max_base + hp_max_ex) * hp_max_ex_percent
	set(value):
		if _player_hp_max_base == value:
			return
		var ex := value - _player_hp_max_base
		_player_hp_max_base = value
		_emit_stat(STAT_HP_MAX)
		player_hp += ex

var hp_max_ex: float = 0.0:
	set(value):
		if hp_max_ex == value:
			return
		hp_max_ex = value
		_emit_stat(STAT_HP_MAX)
var hp_max_ex_percent: float = 1.0:
	set(value):
		if hp_max_ex_percent == value:
			return
		hp_max_ex_percent = value
		_emit_stat(STAT_HP_MAX)
var player_hp_regen: float = 0.0 #每秒生命回复
var lifesteal: float = 0.0 #吸血：造成伤害时回复伤害量与吸血相乘的生命值
var player_speed: float = 0.0 #移动速度
var player_life_addi: int = 0: #- 残机：血量耗尽后游戏结束，但如果还有残机的话可以消耗一残机满血继续
	set(value):
		if player_life_addi == value:
			return
		player_life_addi = value
		_emit_stat(STAT_LIFE)

var defence_melee: float = 0.0 #- 体术防御：受到敌人碰撞伤害（能直接被玩家击破的东西接触玩家时的伤害）时获得与体术防御相关的减免
var defence_bullet: float = 0.0 #- 弹幕防御：受到敌人弹幕伤害时获得与弹幕防御相关的减免
var invincible_time: float = 0.0 #- 受伤后无敌时间：受到伤害后的无敌时间

###########成长类######################

var range_pick: float = 0.0 #- 拾取范围：拾取记忆碎片的最大距离
var luck: float = 0.0 #- 幸运：影响各种与概率相关的东西
var experience_ratio: float = 1.0 #- 经验倍率：影响每一记忆碎片增加多少经验
var point_ratio: float = 1.0: #- 得点倍率：影响每一记忆碎片增加多少分数
	set(value):
		if point_ratio == value:
			return
		point_ratio = value
		_emit_stat(STAT_POINT_RATIO)
var mana_ratio: float = 1.0 #- 符力倍率：影响每一记忆碎片增加多少符力
var change_times: int = 0 #- 刷新排除次数：增加刷新与排除的次数。前者可刷新升级时可选的记忆结晶，后者可使选择的记忆结晶在本局游戏剩余时间内不再出现
var curse: float = 1.0 #- 诅咒：增加敌人的各属性和刷新率
var mana_max: float = 0.0: #- 符力上限：可存储的最大符力
	set(value):
		if mana_max == value:
			return
		var ex := value - mana_max
		mana_max = value
		_emit_stat(STAT_MANA_MAX)
		mana += ex

#######################################

var skill_level_max: int = 0
var skill_num_max: int = 0

var language: String = 'CHS'

var dep: dep_formula = dep_formula.new()
var player_hp: float = 0.0:
	set(value):
		var new_hp := clampf(value, -1.0, player_hp_max)
		if player_hp == new_hp:
			return
		player_hp = new_hp
		_emit_stat(STAT_HP)
var mana: float = 0.0:
	set(value):
		var new_mana := clampf(value, 0.0, mana_max)
		if mana == new_mana:
			return
		mana = new_mana
		_emit_stat(STAT_MANA)
var mana_cost: float = 1.0
var last_cardcost: float = 100.0
var max_point: int = 0
var point: int = 0:
	set(value):
		var new_point := int(point + (value - point) * point_ratio)
		if point == new_point:
			return
		point = new_point
		_emit_stat(STAT_POINT)
var is_uping: bool = false
var _bonus_pick_active: bool = false
var _bonus_pick_queue: int = 0
var player_exp: float = 0.0:
	set(value):
		if value - player_exp > 0.0:
			AudioManager.play_sfx("music_sfx_pickup")
		if player_exp == value:
			return
		player_exp = value
		_emit_stat(STAT_EXP)
		if is_uping != true and player_var.player_exp >= player_var.exp_need:
			is_uping = true
			level_up()
var level: int = 0:
	set(value):
		if level == value:
			return
		level = value
		_emit_stat(STAT_LEVEL)
var is_invincible: bool = false
var time_secs: float = 0.0
var player_diretion_angle: float = 0.0

var card_full: bool = false #没有能升级的符卡并且卡位满了
var card_num_full: bool = false #卡位满了
var card_level_max: int = 0
var card_num_max: int = 0

var summon_level_max: int = 0

var free_card: int = 0:
	set(value):
		if free_card == value:
			return
		free_card = value
		_emit_stat(STAT_FREE_CARD)

var passive_num_max: int = 0

var is_card_casting: bool = false
var player_node: Node2D
var exp_need: float:
	get:
		var diff: float = table.get_global_variable("upgrade_exp_difference", 15.0)
		return float(level) * diff + diff

var damage_sum: Dictionary[String, float] = {"none": 0.0}
var _game_pause_depth: int = 0


## 申请局内暂停：引用计数 +1 并保持树暂停
func request_game_pause() -> void:
	_game_pause_depth += 1
	get_tree().paused = true


## 释放一次局内暂停申请：计数归零时才解除树暂停
func release_game_pause() -> void:
	if _game_pause_depth <= 0:
		return
	_game_pause_depth -= 1
	if _game_pause_depth == 0:
		get_tree().paused = false


func _reset_game_pause_state() -> void:
	_game_pause_depth = 0
	get_tree().paused = false


func _ready() -> void:
	ini()


func _physics_process(delta: float) -> void:
	if shake_damage > 0.0:
		shake_damage -= delta
		shake_screen_damage(shake_damage)


func new_scene() -> void:
	_reset_game_pause_state()
	_bonus_pick_active = false
	_bonus_pick_queue = 0
	RunSession.begin_run()


#玩家造成伤害公式
func player_make_melee_damage(basic_damage: float, damage_source: String = "none") -> float:
	basic_damage *= player_melee_damage_ratio
	if not damage_sum.has(damage_source):
		damage_sum[damage_source] = 0.0
	damage_sum[damage_source] += basic_damage
	return basic_damage


func player_make_bullet_damage(basic_damage: float, damage_source: String = "none") -> float:
	basic_damage *= player_bullet_damage_ratio
	if not damage_sum.has(damage_source):
		damage_sum[damage_source] = 0.0
	damage_sum[damage_source] += basic_damage
	return basic_damage


#敌人造成伤害公式
func enemy_make_damage(basic_damage: float) -> float:
	return basic_damage


#玩家受到伤害公式
func player_take_melee_damage(damage: float) -> float:
	return damage / (1.0 + defence_melee)


func player_take_danma_damage(damage: float) -> float:
	return damage / (1.0 + defence_bullet)


func player_get_heal(heal: float) -> void:
	player_hp += heal
	player_hp = minf(player_hp, player_hp_max)


func level_up() -> void:
	AudioManager.play_sfx("music_sfx_levelup")
	player_var.player_exp -= player_var.exp_need
	player_var.level += 1
	G.get_gui_view_manager().open_view("LevelUp")


## 红/彩碟 legacy：排队一次额外升级选取，不改动 level 与 player_exp
func request_bonus_upgrade_select() -> void:
	_bonus_pick_queue += 1
	call_deferred("_try_open_bonus_upgrade_select")


## 队列非空且当前无升级界面时，打开 LevelUp 供玩家三选一
func _try_open_bonus_upgrade_select() -> void:
	if _bonus_pick_queue <= 0:
		return
	if is_uping or _is_level_up_open():
		return
	_bonus_pick_queue -= 1
	_bonus_pick_active = true
	is_uping = true
	G.get_gui_view_manager().open_view("LevelUp")


## 升级界面关闭后清除 bonus 标志并尝试打开队列中的下一次选取
func clear_bonus_pick_active() -> void:
	_bonus_pick_active = false
	call_deferred("_try_open_bonus_upgrade_select")


func _is_level_up_open() -> bool:
	if G == null or G.get_gui_view_manager() == null:
		return false
	var vm: Node = G.get_gui_view_manager()
	for view in vm.viewInstanceMap.values():
		if view.config.id == &"LevelUp":
			return true
	return false


var shake_damage: float = 0.0:
	set(value):
		shake_damage = clampf(value, 0.0, 1.0)
var noise: FastNoiseLite = FastNoiseLite.new()
var camera: Camera2D


func shake_screen_damage(damage: float) -> void:
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.01
	noise.seed = 420

	var shakei_offsetx := 30.0 * pow(damage, 2.0) * noise.get_noise_1d(Time.get_ticks_msec())
	var shakei_offsety := 30.0 * pow(damage, 2.0) * noise.get_noise_1d(Time.get_ticks_msec() + 1)
	var shakei_angle := 0.3 * pow(damage, 2.0) * noise.get_noise_1d(Time.get_ticks_msec() + 2)
	if not camera:
		return
	camera.position = Vector2(shakei_offsetx, shakei_offsety)
	camera.rotation = shakei_angle


func shake_screen(time: float, interval: float, intensity: float) -> void:
	var ct: Tween = camera.create_tween().set_loops(int(time / interval))
	RunSession.underrecycle_tween.append(ct)
	ct.tween_callback(func():
		shake_damage += intensity
	).set_delay(interval)

	ct = null


func boss_coming(id: String) -> void:
	await RunSession.boss_coming(id)


func lock_camera() -> void:
	RunSession.lock_camera()


func screen_black(intensity: float, in_time: float, duration_time: float, out_time: float) -> void:
	RunSession.screen_black(intensity, in_time, duration_time, out_time)


func require_env_glowing(getin: bool) -> void:
	RunSession.require_env_glowing(getin)


func _clear_all_tweens() -> void:
	RunSession.clear_tweens()


func ini() -> void:
	_reset_game_pause_state()
	_InitialStatus.new().apply_to(self)
