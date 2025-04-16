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


@onready var bullet_damage_area = $bullet_damage_area
@onready var bullet_attack_cd = $bullet_damage_area/bullet_attack_cd
#@onready var navi = $NavigationAgent2D
var movement:Callable
var creep_move:bool
var atkable = true
var moveable = true

var last_position: Vector2 # 存储上一帧的位置，用于检测是否移动
const GRID_CELL_SIZE = Vector2(200, 200)
# 可选: 存储当前所在的单元格坐标，可以用于优化更新逻辑
var current_grid_cell: Vector2i = Vector2i(-1, -1) # 初始值表示无效或未知

# --- 避障参数 ---
# @export 用于让这些变量在 Godot 编辑器的检查器面板中可见并可编辑

# 避障检测半径：只对进入这个半径的邻居做出反应
var avoidance_radius: float = 40.0
# 避障力度：推开力的强度系数
var avoidance_strength: float = 1000.0
# 查询邻居数量：查找最近的多少个邻居来进行避障计算 (不必太多)
var avoidance_neighbor_query_count: int = 6
func _ready():
	#set_modulate(modulate-Color(0, 1, 1, 0)*modi*4)
	set_z_index(1)
	set_z_as_relative(false)

	name = mob_info.id
	#navi.max_speed = mob_info.speed
	hp = mob_info.health

	$ProgressBar._set_size(Vector2(144,20))
	collision_layer = 2
	collision_mask = 1
	#navi.target_position = player_node.global_position

	melee_battle_ready(mob_info.physical_damage == 0)
	bullet_battle_ready(mob_info.magical_damage == 0)
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

	setbuff(multi,multi,multi,multi)


	create_tween().tween_property($AnimatedSprite2D,'skew',0,1.5)
	last_position = global_position

#不用理解，避障用
func on_compute_safevelocity(safevelocity):
	velocity = safevelocity

#根据表选择适当的移动函数（初始化时选择
func _physics_process(_delta):
	if moveable:
		movement.call()
	if not global_position.is_equal_approx(last_position):
		# 如果有管理器引用，则通知管理器更新位置

		player_var.SpawnManager.update_enemy_position_in_grid(self, last_position, global_position)

		# 更新上一帧的位置
		last_position = global_position

func compute_safevelocity(idea_velocity):
	var avoidance_force: Vector2 = Vector2.ZERO

		# 查找附近需要避开的邻居
		# 注意：使用 avoidance_radius 作为搜索半径，并排除自身 (self)
	var neighbors: Array[Node] = player_var.SpawnManager.find_closest_enemies(
		global_position,
		avoidance_neighbor_query_count,
		avoidance_radius,
		self # 排除自己
		)
	if neighbors.is_empty():
		return idea_velocity
		# 遍历找到的邻居
	for neighbor in neighbors:
		if not is_instance_valid(neighbor): continue # 确保邻居仍然有效

		var to_neighbor: Vector2 = neighbor.global_position - global_position
		var dist_sq: float = to_neighbor.length_squared()

			# 检查距离是否在有效范围内 (大于0且小于避障半径平方)
		if dist_sq > 0.001 and dist_sq < avoidance_radius * avoidance_radius:
				# 计算排斥力强度，距离越近，力越大
				# 使用 1/distance 或 1/distance_sq，这里用 1/distance 比较常见
				# 为了避免除以零和开方，我们直接用平方距离比较，并调整强度计算
				# Strength = avoidance_strength / dist_sq  (反比于平方距离，变化更剧烈)
				# 或者 Strength = avoidance_strength * (1.0 - sqrt(dist_sq) / avoidance_radius) (线性衰减)
				# 我们选用反比于距离平方试试：
			var strength
			strength = avoidance_strength * (1.0 - sqrt(dist_sq) / avoidance_radius)
				# 计算远离邻居的方向向量 (单位向量)
			var away_direction = -to_neighbor.normalized()

				# 累加避障力
			avoidance_force += away_direction * strength

	# --- 3. 结合速度与力 ---
	# 将期望速度和计算出的避障力结合
	# 最简单的方式是直接相加，但可能需要调整权重或限制最大速度
	var final_velocity = idea_velocity + avoidance_force

	# 可选：限制最终速度不超过某个最大值 (例如 move_speed * 1.5)
	# var max_speed = move_speed * 1.5
	if final_velocity.length_squared() > mob_info.speed * mob_info.speed:
		final_velocity = final_velocity.normalized() * mob_info.speed

	# 将最终计算的速度赋给 CharacterBody2D 的 velocity 属性
	return final_velocity
#移动方式：走向玩家
func move_to_target():
	#if navi.avoidance_enabled:
		#if NavigationServer2D.map_get_iteration_id(navi.get_navigation_map()) == 0:
			#return
#
		#navi.get_next_path_position()
		#navi.set_velocity(global_position.direction_to(player_node.global_position) * mob_info.speed)
#
	#else:
		#velocity =  global_position.direction_to(player_node.global_position) * mob_info.speed
	velocity =  compute_safevelocity(global_position.direction_to(player_node.global_position) * mob_info.speed)
	$AnimatedSprite2D.flip_h = (velocity.x > 0)
	move_and_slide()

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
		#call_deferred("died")


#似了
func died(disppear = false):
	if(disppear):
		emit_signal('die',mob_id)
		queue_free()
		print('disppear')
		return
	drop()
	emit_signal('die',mob_id)
	invincible = true
	atkable = false
	set_physics_process(false)
	create_tween().tween_property($AnimatedSprite2D,'skew',PI/2,0.5)
	await get_tree().create_timer(0.5,false,true).timeout
	queue_free()

#掉落
func drop():
	SignalBus.drop.emit(drops_path,global_position,drop_num)


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
func setbuff(hpm,melee_damage,danma_damage,speed):
	mob_info.health *= hpm
	hp *= hpm
	mob_info.physical_damage *= melee_damage
	mob_info.magical_damage *= danma_damage
	mob_info.speed *= speed

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
		global_position = player_node.global_position + Vector2.from_angle(randf_range(-PI,PI)) * 500
		print('tp to player')
