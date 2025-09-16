class_name enemy_base extends CharacterBody2D
@onready var player_node = get_tree().get_first_node_in_group("player")

#var modi = player_var.time_secs /1800.0
var mob_id :int
var hp
var drops_path = "drops_p"
var target
var invincible = false
var multi = 1.0
var drop_num = 1.0
signal die(id)
var is_inscreen:bool = false
var mob_info :Dictionary

@onready var progress_bar = $AvoidanceModule
@onready var collisionshape = $buff
@onready var melee_damage_area = $melee_damage_area
@onready var melee_attack_cd = $melee_damage_area/melee_attack_cd
@onready var sprite = $AnimatedSprite2D
# 2. 获取对 C# 模块子节点的引用
@onready var avoidance_module = $AvoidanceModule


var movement:Callable
var creep_move:bool
var atkable = true
var moveable = true

# --- 避障参数 ---
var scalex = 0.28
var scaledir = 1

# 1. 定义怪物属性。C# 模块将会读取这些值。
@export var radius: float = 80.0
@export var max_speed: float = 50



func _ready():

	set_z_index(1)
	set_z_as_relative(false)
	scalex = sprite.scale.x
	name = mob_info.id

	hp = mob_info.health

	progress_bar._set_size(Vector2(144,20))
	collision_layer = 2
	collision_mask = 0
	radius = collisionshape.shape.radius / 1
	max_speed =mob_info.speed
	if mob_info.has('type') and mob_info["type"] == 'elite':
		drops_path = "drops_plate"
		set_scale(Vector2(2,2))
		radius *= 2
	avoidance_module.regis(radius,max_speed)
	melee_battle_ready(mob_info.physical_damage == 0)

	match mob_info.movement:
		'default':
			movement = move_to_target
		'creep':
			movement = creep
			var creeptimer = Timer.new()
			creeptimer.wait_time = 0.6
			creeptimer.timeout.connect(
				func():
					creep_move = !creep_move
			)
			add_child(creeptimer)
			creeptimer.start()
		'static':
			movement = stay

	setbuff(multi,multi,multi,multi)

	if mob_info.has('danmaku_creator'):
		SignalBus.d4c_create.emit(mob_info.danmaku_creator,global_position,$".",mob_info.magical_damage)
	if not mob_info.has('boss'):
		SignalBus.clear_enemy.connect(died)
		SignalBus.kill_all.connect(died.bind(true))
		bullet_battle_ready(mob_info.magical_damage == 0)

	if player_node:
		velocity = global_position.direction_to(player_node.global_position) * mob_info.speed

	choose_default_anime()


#根据表选择适当的移动函数（初始化时选择
func _physics_process(delta):

	if moveable:
		movement.call()
	sprite.scale.x = clampf(sprite.scale.x + 0.05 *scaledir,-scalex,scalex)

func choose_default_anime():
	var df = []
	for anim:String in sprite.sprite_frames.get_animation_names():
		if anim.contains('default'):
			df.push_back(anim)
	sprite.animation = df[randi_range(0,df.size()-1)]

func get_desired_velocity():
	return Vector2.ZERO.move_toward((player_node.global_position-global_position)*2,mob_info.speed)

var is_turning = false
func turn_to_right(to_right:bool):
	pass

#移动方式：走向玩家
func move_to_target():
	var idea_v = get_desired_velocity()

	var safe_velocity = avoidance_module.CalculateSafeVelocity(idea_v)

	set_velocity(safe_velocity)

	if idea_v.x > 0:
		scaledir = -1
	else:
		scaledir = 1
	move_and_slide()
func stay():
	pass

#移动方式：蛄蛹（初始化时设置了定时反转creep_move变量）
func creep():
	if creep_move:
		move_to_target()

#伤害数字表示
func damage_num_display(num):

	$DamageNum.showdamage(num)



#受到伤害
func mob_take_damage(damage):
	if invincible:
		return
	damage_num_display(damage)
	hp -= damage
	progress_bar.value = hp/mob_info.health * 100
	if hp <= 0:
		died()


#似了
func died(disppear = false):
	if(disppear):
		emit_signal('die',mob_id)
		call_deferred('queue_free')
		return
	drop()
	emit_signal('die',mob_id)
	invincible = true
	atkable = false
	set_physics_process(false)

	# 清理所有信号连接
	_cleanup_connections()

	if(sprite.sprite_frames.has_animation('die')):
		sprite.play('die')
		await sprite.animation_finished
	else:
		var tween = create_tween().tween_property(sprite,'skew',PI/2,0.5)
		player_var.underrecycle_tween.append(tween)
		await tween.finished
		tween = null
	queue_free()

# 清理所有信号连接
func _cleanup_connections():
	# 断开体术攻击相关的信号连接
	if melee_damage_area and is_instance_valid(melee_damage_area):
		if melee_damage_area.body_entered.is_connected(melee_damage_area_body_entered):
			melee_damage_area.body_entered.disconnect(melee_damage_area_body_entered)
		if melee_damage_area.body_exited.is_connected(_on_melee_damage_area_body_exited):
			melee_damage_area.body_exited.disconnect(_on_melee_damage_area_body_exited)

	if melee_attack_cd and is_instance_valid(melee_attack_cd):
		if melee_attack_cd.timeout.is_connected(melee_attack_cd_timeout):
			melee_attack_cd.timeout.disconnect(melee_attack_cd_timeout)


#掉落
func drop():
	SignalBus.drop.emit(drops_path,global_position,drop_num)


#体术攻击准备就绪，体术攻击敌人ready中调用
func melee_battle_ready(disable = false):
	if disable:
		$melee_damage_area.queue_free()
		return
	# 使用call_deferred避免在物理查询刷新期间修改monitoring
	call_deferred("set_melee_monitoring", true)

	# 确保信号只连接一次
	if not melee_damage_area.body_entered.is_connected(melee_damage_area_body_entered):
		melee_damage_area.body_entered.connect(melee_damage_area_body_entered)
	if not melee_attack_cd.timeout.is_connected(melee_attack_cd_timeout):
		melee_attack_cd.timeout.connect(melee_attack_cd_timeout)
	if not melee_damage_area.body_exited.is_connected(_on_melee_damage_area_body_exited):
		melee_damage_area.body_exited.connect(_on_melee_damage_area_body_exited)

# 延迟设置体术攻击Area2D监控状态
func set_melee_monitoring(active: bool):
	melee_damage_area.monitoring = active

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
func melee_attack(body):
	if not atkable:
		return
	if body.has_method('take_damage'):
		body.take_damage('melee',mob_info.physical_damage)


#弹幕攻击准备就绪，弹幕攻击敌人ready中调用
func bullet_battle_ready(disable = false):
	if disable:
		return






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
func setbuff(hpm,melee_damage,danma_damage,speed):
	mob_info.health *= hpm
	hp *= hpm
	mob_info.physical_damage *= melee_damage
	if mob_info.has('magical_damage'):
		mob_info.magical_damage *= danma_damage
	#mob_info.speed *= speed

#得到了debuff
func set_debuff(buff_name,intensity,duration,source):
	$buff.add_buff(buff_name,intensity,duration,source)

#进入屏幕时触发
func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	#navi.avoidance_enabled = true
	is_inscreen =true
	$outscreen_disppear.stop()
#离开屏幕时触发
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	#navi.avoidance_enabled = false
	$outscreen_disppear.start()
	is_inscreen = false


func _on_outscreen_disppear_timeout() -> void:
	if mob_info.type == 'zako':
		died(true)
	else:
		global_position = player_node.global_position + Vector2.from_angle(randf_range(-PI,PI)) * 1000
		print('tp to player')
func highlight():
	$AnimatedSprite2D.modulate = Color(0,1,1,1)
