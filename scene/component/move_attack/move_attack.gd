class_name MoveComponent extends Node

# 使用枚举代替字典，更清晰、安全
enum MoveRule { STRAIGHT, TRAIL, SEKIBANKI, POLAR, STAY }
enum DirectionSource { CHARACTER, WORLD, LOCK, ROUTINE, RANDOM }

# --- 状态变量 ---
var move_type: Callable
var rotate_type: Callable

var body: Node2D
var attack_info: Dictionary
var lock: LockComponent

var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.RIGHT
var acceleration: float = 0.0

var polar_len: float = 0.0
var polar_angle: float = 0.0

var has_reflection: bool = false
var next_found_counter: int = 0
var exist_time: float = 0.0

#=============================================================================
# 生命周期
#=============================================================================

# 公开的初始化接口，由 Attack 节点在每次重生时调用
func initialize(p_body: Node2D, p_attack_info: Dictionary, p_lock_comp: LockComponent) -> void:
	self.body = p_body
	self.attack_info = p_attack_info
	self.lock = p_lock_comp
	self.has_reflection = attack_info.has("reflection")
	if has_reflection:
		body.collision_mask = 0
		if "enemy" in attack_info.reflection:
			body.collision_mask += 2
		if "wall" in attack_info.reflection:
			body.collision_mask += 32

	_reset_state_variables()

	_set_initial_direction_and_rotation()
	_setup_movement_strategy()
	_setup_rotation_strategy()

# 每次重生时重置状态
func _reset_state_variables() -> void:
	velocity = Vector2.ZERO
	direction = Vector2.RIGHT
	acceleration = 0.0
	polar_len = 0.0
	polar_angle = 0.0
	next_found_counter = 0
	exist_time = 0.0

#=============================================================================
# 主更新循环
#=============================================================================

# 由 Attack 节点的 _physics_process 调用
func physics_update(delta: float) -> void:
	var collision_info = move_type.call(delta)
	rotate_type.call(delta)

	if has_reflection and collision_info is KinematicCollision2D:
		var normal = collision_info.get_normal()
		velocity = velocity.bounce(normal)
		# 简化：方向向量直接从速度向量得出
		if velocity.length_squared() > 0:
			direction = velocity.normalized()

#=============================================================================
# 初始化辅助函数
#=============================================================================

func _set_initial_direction_and_rotation() -> void:
	lock.find_next_target()
	var initial_rotation = deg_to_rad(attack_info.get("ri", 0.0))

	var ri_dep = attack_info.get("ri_dependence", "")
	match ri_dep:
		"lock":
			var target_pos = lock.get_target_position()
			if target_pos != Vector2.INF:
				initial_rotation += body.global_position.angle_to_point(target_pos)
		"character":
			initial_rotation += player_var.player_diretion_angle

	body.rotation = initial_rotation
	direction = Vector2.from_angle(body.rotation)

func _setup_movement_strategy() -> void:
	#if attack_info.get("reference_system", 'character') == 'world':
		#body.top_level = true
	if not attack_info.get("moving", true):
		move_type = Callable(self, "move_stay")
		return

	var rule_str = attack_info.get("moving_rule", "stay")
	match rule_str:
		"straight":
			move_type = Callable(self, "move_straight")
			_move_straight_init()
		"trail":
			move_type = Callable(self, "move_trace_target")
			var speed = attack_info.get("moving_parameter", [0])[0]
			velocity = direction * speed
		"sekibanki":
			move_type = Callable(self, "move_sekibanki")
			var speed = attack_info.get("moving_parameter", [0])[0]
			velocity = Vector2.from_angle(randf_range(0, TAU)) * player_var.bullet_speed_ratio * speed
		"polar":
			move_type = Callable(self, "move_polar")
			polar_angle = attack_info.get("moving_parameter", [0])[0] + 120 * body.batch_num
		_:
			move_type = Callable(self, "move_stay")

func _setup_rotation_strategy() -> void:
	var rule_str = attack_info.get("rotation_rule", "none")
	match rule_str:
		"uniform":
			rotate_type = Callable(self, "rot_uniform")
		"speed":
			rotate_type = Callable(self, "rot_towards_velocity")
		"locking":
			rotate_type = Callable(self, "rot_locking")
		_:
			rotate_type = Callable(self, "rot_stay")

#=============================================================================
# 移动策略实现
#=============================================================================

func move_stay(_delta: float) -> KinematicCollision2D: return null

func _move_straight_init() -> void:
	var params = attack_info.get("moving_parameter", [0, 0, 9999])
	var initial_speed = params[0] * attack_info.get("speed_efficiency", 1.0) * player_var.bullet_speed_ratio
	acceleration = params[1] * player_var.bullet_speed_ratio * attack_info.get("speed_efficiency", 1.0)
	match attack_info.get('diretion'):
		'character':
			direction = Vector2.from_angle(player_var.player_diretion_angle)
		'world':
			direction = Vector2.RIGHT
		'lock':
			if lock.find_next_target():
				direction = body.global_position.direction_to(lock.get_target_position())
			else:
				direction = Vector2.from_angle(player_var.player_diretion_angle)
		'random':
			direction = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()
	velocity = direction * initial_speed

func move_straight(delta: float) -> KinematicCollision2D:
	var max_speed = attack_info.get("moving_parameter", [0, 0, 9999])[2] * attack_info.get("speed_efficiency", 1.0) * player_var.bullet_speed_ratio
	velocity += direction * acceleration * delta
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	return body.move_and_collide(velocity * delta)

# 追踪移动（寻的）
func move_trace_target(delta: float) -> KinematicCollision2D:
	var target = lock.get_target_node()
	if not is_instance_valid(target):
		next_found_counter -= 1
		if next_found_counter <= 0:
			lock.find_next_target()
			next_found_counter = 30 # 每 30 帧索敌一次
	else:
		var params = attack_info.get("moving_parameter", [0, 0, 9999])
		var acceleration_factor = params[1] * player_var.bullet_speed_ratio * attack_info.get("speed_efficiency", 1.0)
		var max_speed = params[2] * player_var.bullet_speed_ratio * attack_info.get("speed_efficiency", 1.0)

		var accel_vec = body.global_position.direction_to(target.global_position) * acceleration_factor
		velocity += accel_vec * delta
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
		if velocity.length_squared() > 0:
			direction = velocity.normalized()

	return body.move_and_collide(velocity * delta)

# 极坐标移动（螺旋等）
func move_polar(delta: float) -> KinematicCollision2D:
	var params = attack_info.get("moving_parameter", [0, 0, 0])
	var radial_speed = params[1] * delta * player_var.bullet_speed_ratio * attack_info.get("speed_efficiency", 1.0)
	var angular_speed = params[2] * delta * player_var.bullet_speed_ratio * attack_info.get("speed_efficiency", 1.0)

	polar_len += radial_speed
	polar_angle += angular_speed

	body.position = Vector2.from_angle(deg_to_rad(polar_angle)) * polar_len
	return null

# 特殊移动：一边朝玩家加速，一边做切向运动
func move_sekibanki(delta: float) -> KinematicCollision2D:
	var speed = attack_info.get("moving_parameter", [0])[0]
	if is_instance_valid(player_var.player_node):
		var to_player = body.global_position.direction_to(player_var.player_node.global_position)
		var distance = body.global_position.distance_to(player_var.player_node.global_position)
		velocity += 0.5 * speed * to_player * delta * sqrt(distance)

	velocity += velocity.rotated(PI / 2).normalized() * delta * speed
	velocity = velocity.normalized() * speed * player_var.bullet_speed_ratio

	return body.move_and_collide(velocity * delta)

#=============================================================================
# 旋转策略实现
#=============================================================================

func rot_stay(_delta: float): pass

func rot_uniform(delta: float):
	body.rotation_degrees += attack_info.get("omega", 0.0) * delta

func rot_towards_velocity(delta: float):
	if velocity.length_squared() > 0.01:
		_rotate_towards(velocity.angle(), delta)

func rot_locking(delta: float):
	var target_pos = lock.get_target_position()
	if target_pos != Vector2.INF:
		var target_angle = body.global_position.angle_to_point(target_pos)
		_rotate_towards(target_angle, delta)

# 【统一的旋转逻辑】
func _rotate_towards(target_angle: float, delta: float) -> void:
	var omega_rad = deg_to_rad(attack_info.get("omega", 360.0))
	var max_rotation_this_frame = omega_rad * delta

	var angle_delta = angle_difference(body.rotation, target_angle)

	var rotation_amount = clamp(angle_delta, -max_rotation_this_frame, max_rotation_this_frame)
	body.rotate(rotation_amount)

# GDScript 3 & 4 兼容的角度差函数
func angle_difference(from, to):
	var diff = fmod(to - from + PI, TAU) - PI
	return diff if diff > -PI else diff + TAU
