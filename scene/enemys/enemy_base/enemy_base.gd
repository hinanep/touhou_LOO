class_name enemy_base extends CharacterBody2D
@onready var player_node = get_tree().get_first_node_in_group("player")

#var modi = player_var.time_secs /1800.0
var mob_id :int
var hp
var drops_path = "drops_p"
var target
var invincible = false
var multi = 1.0
signal die(id)
var mob_info = {
	"id": "enm_mempeace",
	"type": "zako",
	"movement": "default",
	"danma": "",
	"barrage_parameter": [],
	"shoot_interval": 0.0,
	"physical_damage": 5.0,
	"magical_damage": 0.0,
	"health": 100.0,
	"speed": 50.0
  }

@onready var progress_bar = $ProgressBar

@onready var melee_damage_area = $melee_damage_area
@onready var melee_attack_cd = $melee_damage_area/melee_attack_cd
var damageNum = preload("res://scene/enemys/enemy_base/damageNum.tscn")

@onready var bullet_damage_area = $bullet_damage_area
@onready var bullet_attack_cd = $bullet_damage_area/bullet_attack_cd
@onready var navi = $NavigationAgent2D
var movement:Callable
var creep_move:bool
var atkable = true
var moveable = true

func _ready():
	#set_modulate(modulate-Color(0, 1, 1, 0)*modi*4)
	set_z_index(1)
	set_z_as_relative(false)

	name = mob_info.id
	navi.max_speed = mob_info.speed
	hp = mob_info.health

	$ProgressBar._set_size(Vector2(144,20))
	collision_layer = 2
	collision_mask = 1
	navi.target_position = player_node.global_position

	melee_battle_ready(mob_info.physical_damage == 0)
	bullet_battle_ready(mob_info.magical_damage == 0)
	match mob_info.movement:
		'default':
			movement = move_to_target
		'creep':
			movement = creep
			var creeptimer = Timer.new()
			creeptimer.wait_time = 2
			creeptimer.timeout.connect(
				func():
					creep_move = !creep_move
			)
			add_child(creeptimer)
			creeptimer.start()

	setbuff(multi)

#不用理解，避障用
func on_compute_safevelocity(safevelocity):
	velocity = safevelocity

#根据表选择适当的移动函数（初始化时选择
func _physics_process(_delta):
	if moveable:
		movement.call()

#移动方式：走向玩家
func move_to_target():
	if navi.avoidance_enabled:
		if NavigationServer2D.map_get_iteration_id(navi.get_navigation_map()) == 0:
			return

		navi.get_next_path_position()
		navi.set_velocity(global_position.direction_to(player_node.global_position) * mob_info.speed)

	else:
		velocity =  global_position.direction_to(player_node.global_position) * mob_info.speed
	move_and_slide()

#移动方式：蛄蛹（初始化时设置了定时反转creep_move变量）
func creep():
	if creep_move:
		move_to_target()

#伤害数字表示
func damage_num_display(num):
	var d = damageNum.instantiate()
	d.showdamage(num)
	#d.global_position = global_position
	d.position = Vector2(2*randf()-1,randf())*5

	#$".".call_deferred("add_child",d)
	add_child(d)


#受到伤害
func take_damage(damage):
	if invincible:
		return
	damage_num_display(damage)
	hp -= damage
	progress_bar.value = hp/mob_info.health * 100
	if hp <= 0:
		died()
		#call_deferred("died")


#似了
func died():
	drop()
	emit_signal('die',mob_id)
	atkable = false
	await get_tree().create_timer(0.1).timeout
	queue_free()

#掉落
func drop():
	var drops = PresetManager.getpre(drops_path).instantiate()
	get_parent().call_deferred("add_child",drops)

	drops.global_position = global_position

#体术攻击准备就绪，体术攻击敌人ready中调用
func melee_battle_ready(disable = false):
	if disable:
		$melee_damage_area.queue_free()
		return
	melee_damage_area.monitoring = true

	melee_damage_area.body_entered.connect(melee_damage_area_body_entered)
	melee_attack_cd.timeout.connect(melee_attack_cd_timeout)
	melee_damage_area.body_exited.connect(_on_melee_damage_area_body_exited)
#疑似玩家进入体术攻击范围，开打
func melee_damage_area_body_entered(_body):
	if not _body is player:
		return

	melee_attack(_body)
	melee_attack_cd.start()

#疑似玩家离开体术攻击范围，停手
func _on_melee_damage_area_body_exited(body):
	if not body is player:
		return

	melee_attack_cd.stop()

#定时打人
func melee_attack_cd_timeout():
	melee_attack(player_node)


#体术攻击方法，可覆盖
func melee_attack(playernode):
	if not atkable:
		return
	player_var.player_take_melee_damage(playernode,player_var.enemy_make_damage(mob_info.physical_damage))


#弹幕攻击准备就绪，弹幕攻击敌人ready中调用
func bullet_battle_ready(disable = false):
	if disable:
		$bullet_damage_area.queue_free()
		return
	bullet_damage_area.monitoring = true
	bullet_damage_area.body_entered.connect(bullet_damage_area_body_entered)
	bullet_damage_area.body_exited.connect(_on_bullet_damage_area_body_exited)
	bullet_attack_cd.timeout.connect(bullet_attack_cd_timeout)


func bullet_damage_area_body_entered(_body):
	if not _body is player:
		return
	bullet_attack()
	bullet_attack_cd.start()

func _on_bullet_damage_area_body_exited(body):
	if not body is player:
		return

	bullet_attack_cd.stop()

#弹幕攻击方法，待实例实现
func bullet_attack():
	if not atkable:
		return

func bullet_attack_cd_timeout():
	bullet_attack()

#到玩家方向单位向量
func get_diretion_to_target():

	return(player_node.global_position - global_position).normalized()

#到玩家距离
func get_distance_to_player():
	if player_node:
		return global_position.distance_to(player_node.global_position)
	return Vector2.ZERO

#到玩家距离平方
func get_distance_squared_to_player():
	if player_node:
		return global_position.distance_squared_to(player_node.global_position)
	return Vector2.ZERO

#设置基础属性加成，读表
func setbuff(multi):
	mob_info.health *= multi
	hp *= multi
	mob_info.physical_damage *= multi
	mob_info.magical_damage *= multi

#得到了debuff
func set_debuff(buff_name,intensity,duration,source):
	$buff.add_buff(buff_name,intensity,duration,source)

#进入屏幕时触发
func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	navi.avoidance_enabled = true

#离开屏幕时触发
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	navi.avoidance_enabled = false
