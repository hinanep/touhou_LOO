class_name melee_weapon_base extends Node2D


@onready var melee_timer = $meleeTimer
@onready var attack_range = $attack_range

const basic_colddown = 1
const kick_range = 50
const kick_basic_damage = 10

var kick_ready = true
var nearest_enemy
var waza_config = {
	"waza_name" : "",
	"level":0,
	"path":"",
	"weight":0,#随机权重
	"cn":"",#中文名
	"type":"skill",#技能、符卡、衍生
	"locking_type":"",#目标、定向、随机方向
	"attack_pre":"",#发射实体路径
	"diretion":Vector2(0,0),#发射方向
	"diretion_rotation":0,#发射方向旋转角（逆时针角度）
	"creation_distance":0,#距离生成位置的距离

	"creating_position":"",#生成位置：在自机处、最近几名敌人处、什么神秘地方处,
	"creating_rule":"",#生成一组、一个个生成
	"attack_gen_times":"",#基础生成次数
	"basic_colddown":1.0,
	"Physical_Addition_Efficiency":0.0,
	"Magical_Addition_Efficiency":1.0,
	"Speed_Efficiency":1.0,
	"Duration_Efficiency":1.0,
	"Range_Efficiency":1.0,
	"Magical_Times_Efficiency":1.0,
	"Physical_Times_Efficiency":1.0,
	"Reduction_Efficiency":1.0,
	"cp_map":{},
	"upgrade_map":{
		"Damage_Addition":[],
		"Bullet_Speed_Addition":[],
		"Duration_Addition":[],
		"Range_Addition":[],
		"Times_Addition":[],
		"Debuff_Addition":[],
		"Cd_Reduction":[]
					}
	}
func _ready():
	set_range_and_colddown()
	$meleeTimer.timeout.connect(_on_kick_timer_timeout)
func _physics_process(_delta):


	nearest_enemy = get_nearest_enemy_inarea()
	if nearest_enemy:
		look_at(nearest_enemy.global_position)
		auto_attack()

func set_range_and_colddown():
	melee_timer.wait_time = basic_colddown * (1 - player_var.colddown_reduce)
	attack_range.set_scale(Vector2(player_var.range_add_ratio,player_var.range_add_ratio))

func _on_kick_timer_timeout():
	kick_ready = true

func enemy_near(a,b):
	return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)

func get_nearest_enemy_inarea():
	var enemy_in_range = attack_range.get_overlapping_bodies() #area范围内的物体
	if !enemy_in_range.is_empty():
		return enemy_in_range.reduce(func(mine,val):return val if enemy_near(val,mine) else mine)
	return null


func auto_attack():
	if kick_ready:
		kick()
		kick_ready = false
		melee_timer.start()

func kick():
	var enemy_in_kick_range = attack_range.get_overlapping_bodies()
	$Sprite2D/AnimationPlayer.play("attack")
	for enemy in enemy_in_kick_range:
		if enemy.has_method("take_damage"):
			enemy.take_damage(player_var.player_make_melee_damage(kick_basic_damage,"base_melee"))
