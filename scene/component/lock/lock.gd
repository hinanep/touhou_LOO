class_name LockComponent extends Node

# 使用枚举更清晰
enum LockType {
	ROUTINE,
	NEAREST,
	STRONGEST,
	FRONT,
	NONE
}

# --- 私有状态变量 ---
var _lock_func: Callable
var _lock_target: Node = null
var _lock_position: Vector2 = Vector2.INF # 使用 Vector2.INF 代表无效位置

# --- 外部引用 ---
var _body: Node2D
var _attack_info: Dictionary
var _spawn_manager = player_var.SpawnManager

#=============================================================================
# 生命周期与 API
#=============================================================================

# 公开的初始化接口，由 Attack 节点调用
func initialize(p_body: Node2D, p_attack_info: Dictionary, lock_routine: Node = null) -> void:
	self._body = p_body
	self._attack_info = p_attack_info

	var locking_type_str = p_attack_info.get("locking_type", "none")

	match locking_type_str:
		"routine":
			_lock_func = Callable(self, "_find_null_target") # 初始目标由外部设定
			_lock_target = lock_routine
		"nearest":
			_lock_func = Callable(self, "_find_nearest_target")
		"strongest":
			_lock_func = Callable(self, "_find_strongest_target")
		"front":
			_lock_func = Callable(self, "_find_front_target")
		_: # 包括 "none" 和 null
			_lock_func = Callable(self, "_find_null_target")

# [API] 外部调用的主方法，执行索敌
func find_next_target() -> bool:
	# 关键：每次索敌前，先重置之前的状态
	_reset_target()

	# 执行具体的索敌策略
	_lock_func.call()

	# 如果找到了任意一种有效目标，则返回 true
	return is_instance_valid(_lock_target) or _lock_position != Vector2.INF

# [API] 获取目标节点（如果目标是节点的话）
func get_target_node() -> Node:
	return _lock_target if is_instance_valid(_lock_target) else null

# [API] 获取目标位置（无论目标是节点还是坐标）
func get_target_position() -> Vector2:
	find_next_target()
	if is_instance_valid(_lock_target):
		return _lock_target.global_position
	return _lock_position

#=============================================================================
# 内部方法
#=============================================================================

# 重置目标状态
func _reset_target() -> void:
	_lock_position = Vector2.INF
	if is_instance_valid(_lock_target):
		return


# --- 索敌策略实现 ---

# 寻找最近的敌人
func _find_nearest_target() -> void:
	# 从 attack_info 读取配置，提供默认值
	var range = _attack_info.get("locking_range", 1000.0)
	var target_array: Array = _spawn_manager.find_closest_enemies(_body.global_position, 1, range, null)

	if not target_array.is_empty():
		_lock_target = target_array[0]

# 寻找最强的敌人
func _find_strongest_target() -> void:
	_lock_target = _spawn_manager.get_strongest_mob()

# 寻找玩家前方的某个点
func _find_front_target() -> void:
	if not is_instance_valid(player_var.player_node):
		return

	# 从 attack_info 读取配置，提供默认值
	var distance = _attack_info.get("locking_distance", 400.0)
	var direction_vec = Vector2.from_angle(player_var.player_diretion_angle)
	_lock_position = player_var.player_node.global_position + direction_vec * distance

# 不进行索敌
func _find_null_target() -> void:
	# 就是字面意思，什么都不做
	pass
