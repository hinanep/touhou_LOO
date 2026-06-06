# routine.gd (重构后)
class_name Routine extends Node2D

# --- 核心属性 ---
var active: bool = true
var routine_info: Dictionary = {}
var level: int = 0
var damage_source: String = ""

# --- 节点引用和预制体 ---
@onready var interval_timer: Timer = $interval_timer

# 预加载攻击和召唤物的场景
var attack_prefabs: Array[PackedScene] = []
var summon_prefabs: Array[PackedScene] = []

# --- 对象池 ---
var attack_pools: Dictionary = {}
var summon_pools: Dictionary = {}
var _attack_pools_warmed: bool = false

const _ATTACK_SCENE_PATH := "res://scene/attack/attack_ins/%s.tscn"

# 初始化
func _ready() -> void:
	name = routine_info.id
	add_to_group(routine_info.id)

	_connect_signals()
	_initialize_prefabs_and_pools()

	if routine_info.get("interval", 0.0) > 0.01:
		interval_timer.wait_time = routine_info.interval
	else:
		interval_timer.stop()

# --- 信号连接 ---
func _connect_signals() -> void:
	SignalBus.trigger_routine_by_id.connect(on_trigger_called)

# --- 初始化 ---
func _initialize_prefabs_and_pools() -> void:
	# 初始化攻击
	var creating_attacks: Array = routine_info.get("creating_attack", [])
	for attack_id in creating_attacks:
		var prefab := _load_attack_packed_scene(attack_id)
		if prefab == null:
			continue
		attack_prefabs.append(prefab)
		# 为每种攻击创建一个独立的对象池
		var pool_container: Node
		if table.resolve_attack(attack_id).get('reference_system', 'world') == 'world':
			pool_container = Node.new() # 创建一个节点来持有实例化的对象
		else:
			pool_container = Node2D.new() # 跟随父节点
		add_child(pool_container)
		attack_pools[attack_id] = (ObjectPool.new(prefab, pool_container))

	# 初始化召唤物
	var creating_summons: Array = routine_info.get("creating_summoned", [])
	for summon_id in creating_summons:
		var prefab: PackedScene = load("res://scene/summon/summon_ins/" + summon_id + ".tscn")
		summon_prefabs.append(prefab)
		var pool_container: Node = Node.new()
		add_child(pool_container)
		summon_pools[summon_id] = (ObjectPool.new(prefab, pool_container))


## 加载攻击场景（走 ResourceLoader 缓存，避免重复读盘）
## @param attack_id 攻击表 id，对应 atk_*.tscn 文件名
## @return PackedScene，失败返回 null
func _load_attack_packed_scene(attack_id: String) -> PackedScene:
	var path := _ATTACK_SCENE_PATH % attack_id
	var prefab: PackedScene = ResourceLoader.load(path) as PackedScene
	if prefab == null:
		push_error("[Routine] 无法加载攻击场景: %s" % path)
	return prefab


## 对本 routine 各攻击池离屏预热一次（由 AttackParticleWarmup 在开局或新技能后 await）
func warmup_attack_pools_once() -> void:
	if _attack_pools_warmed:
		return
	await _warmup_attack_pools()
	_attack_pools_warmed = true


## 对本 routine 各攻击池离屏预热粒子
func _warmup_attack_pools() -> void:
	for attack_id in attack_pools:
		var pool: ObjectPool = attack_pools[attack_id]
		await _warmup_single_attack_pool(pool)


## 从池取一个实例，触发粒子 restart 后等待 2 帧再归还
## @param pool 攻击对象池
func _warmup_single_attack_pool(pool: ObjectPool) -> void:
	var instance: Node = pool.get_object(pool.parent_node)
	if not is_instance_valid(instance):
		return
	instance.hide()
	instance.process_mode = Node.PROCESS_MODE_DISABLED
	if instance.has_method("warmup_particles"):
		instance.warmup_particles()
	elif "particles" in instance:
		for node in instance.particles:
			if node is GPUParticles2D:
				(node as GPUParticles2D).restart()
	await _wait_warmup_frame()
	await _wait_warmup_frame()
	pool.return_object(instance)


## 预热等待一帧（树暂停时 process_always 定时器仍可触发）
func _wait_warmup_frame() -> void:
	var tree := get_tree()
	if tree == null:
		return
	await tree.create_timer(0.0, true, false, false).timeout


# --- 外部调用接口 ---
func on_trigger_called(routine_id: String, force_world_position: bool, input_pos: Vector2, input_rot: float, parent_node: Variant) -> void:
	if routine_id != routine_info.id or not active:
		return

	# 如果没有指定父节点，则使用世界作为父节点 (get_tree().root)
	var spawn_parent: Node = parent_node if is_instance_valid(parent_node) else $"."



	# 启动攻击流程，不再等待它完成
	_execute_attack_flow(force_world_position, input_pos, input_rot, spawn_parent)

# --- 核心攻击流程 ---
func _execute_attack_flow(force_world_pos: bool = false, input_pos: Vector2 = Vector2.ZERO, input_rot: float = 0, parent: Node = $".") -> void:
	if not active:
		return
	AudioManager.play_sfx("music_sfx_shoot")

	var times: int = int(routine_info.times + player_var.danma_times * routine_info.danma_times_efficiency)

	for i in range(times):
		match routine_info.one_creating_type:
			'single':
				if interval_timer.is_stopped() == false:
					await interval_timer.timeout
				_spawn_all_creations(force_world_pos, input_pos, input_rot, parent, i)

			'multi_together':
				# 这里可以根据具体需求实现更复杂的逻辑
				# 例如，一次性生成多个，但每个有微小的时间或位置差
				for j in range(routine_info.one_creating_parameter[0]):
					if interval_timer.is_stopped() == false:
						await interval_timer.timeout
					_spawn_all_creations(force_world_pos, input_pos, input_rot, parent, j)

# --- 生成逻辑 ---
func _spawn_all_creations(force_world_pos: bool, input_pos: Vector2, input_rot: float, parent: Node2D, batch_num: int) -> void:
	var spawn_transform: Transform2D
	if force_world_pos:
		spawn_transform = Transform2D(0, input_pos)
		spawn_transform.rotated(input_rot)

	else:
		# 使用工具类计算位置
		spawn_transform = BattleUtils.calculate_spawn_transform(routine_info, player_var.player_node, parent.global_position + input_pos,parent.global_rotation + input_rot)

	# 生成攻击
	if routine_info.has('special_creating_attack'):
		match routine_info.special_creating_attack:
			'probability':
				var pool_index: int = _select_pool_index_by_luck()
				if pool_index != -1:
					_spawn_instance_from_pool(attack_pools.keys()[pool_index],attack_pools[attack_pools.keys()[pool_index]], spawn_transform, parent, batch_num)
	else:
		for atkid in attack_pools:
			_spawn_instance_from_pool(atkid,attack_pools[atkid], spawn_transform, parent, batch_num)

	# 生成召唤物
	for sumid in summon_pools:
		_spawn_instance_from_pool(sumid,summon_pools[sumid], spawn_transform, parent, batch_num)

# 从指定的对象池生成一个实例
func _spawn_instance_from_pool(id: String, pool: ObjectPool, transform: Transform2D, parent: Node, batch_num: int) -> void:
	if parent == $".":
		parent = null
	var instance: Node = pool.get_object(parent)
	if not is_instance_valid(instance):
		return

	# 设置实例的属性
	# 假设实例有这些属性和方法，需要你在攻击/召唤物脚本中定义
	#instance.global_transform = transform
	if instance.has_method("initialize"):
		instance.initialize(id,transform, damage_source, batch_num)




# 根据幸运值选择池的索引
func _select_pool_index_by_luck() -> int:
	# (你的 select_from_luck 函数逻辑可以移到这里，保持不变)
	var sum: float = 0
	var weight_delta: Array = []
	var params: Array = routine_info.special_creating_attack_parameter
	for i in range(params.size() / 2):
		var tmp: float = params[i*2] * pow(1 + player_var.luck, params[i*2+1])
		sum += tmp
		weight_delta.append(tmp)
	var r: float = randf_range(0, sum)
	for i in range(params.size() / 2):
		r -= weight_delta[i]
		if r < 0:
			return i
	return -1 # 如果没选中，返回-1

# --- 节点生命周期结束 ---
func _exit_tree() -> void:
	destroy()

func destroy() -> void:
	if not active: return
	active = false
	for pool in attack_pools: attack_pools[pool].clear()
	for pool in summon_pools: summon_pools[pool].clear()
	queue_free()
