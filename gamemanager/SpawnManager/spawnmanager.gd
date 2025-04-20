extends Node
class_name SpawnManagers
var event_list = {}

var spawner_pre

@onready var spawnmanager_node = $"."

var mob_dic:Dictionary
var id = 0
const GRID_CELL_SIZE = Vector2(100, 100)
var spatial_grid: SpatialGrid
var audit_timer = 0.0
const AUDIT_INTERVAL = 15.0 # 每 15 秒检查一次
func _ready() -> void:
	spatial_grid =SpatialGrid.new(GRID_CELL_SIZE)
	#WorkerThreadPool
	#thread.start(find_closest_enemies)





func add_spawn_event(spawner_init):
	var new_spawner = spawner_pre.instantiate()
	spawnmanager_node.add_child(new_spawner)
	new_spawner.spawner_init(spawner_init,spawnmanager_node)


func spawnmanager_init(eventlist):
	spawner_pre = PresetManager.getpre("enemy_spawner")
	event_list = table.get(eventlist)
	for event in event_list:
		add_spawn_event(event_list[event])

func add_mob(mob_ins):
	#TODO:在生成实例前终止
	#if mob_dic.size()>300:
		#mob_ins.free()
		#return

	mob_ins.die.connect(del_mob)
	mob_ins.mob_id = id
	mob_dic[id] = mob_ins
	id += 1
	spatial_grid.add_object(mob_ins,mob_ins.global_position)
	spawnmanager_node.add_child(mob_ins)



func del_mob(mob_id):

	if is_instance_valid(mob_dic.get(mob_id)) and spatial_grid:
		# 假设敌人有 global_position
		spatial_grid.remove_object(mob_dic[mob_id], mob_dic[mob_id].last_position)

	# 从活动列表中移除

	mob_dic.erase(mob_id)


func update_enemy_position_in_grid(enemy: Node, old_pos: Vector2, new_pos: Vector2):
	if spatial_grid:
		spatial_grid.update_object_position(enemy, old_pos, new_pos)


func get_strongest_mob():
	if mob_dic.is_empty():
		return null
	var maxmob =mob_dic[mob_dic.keys()[0]]
	for mob in mob_dic:
		if mob_dic[mob].is_inscreen and mob_dic[mob].hp > maxmob.hp:
			maxmob = mob_dic[mob]
	return maxmob
func clear():
	printerr('spawnmanager has been clear')
	for child in spawnmanager_node.get_children():
		child.queue_free()

	id = 0
	mob_dic = {}
# 寻找距离指定点最近的N个敌人 (优化版：逐层搜索网格)
# ... (参数和返回说明同前) ...
func find_closest_enemies(center_position: Vector2, count: int, max_radius: float, exclude_self: Node = null) -> Array[Node]:
	if not spatial_grid or not spatial_grid.cell_size: # 确保网格和cell_size有效
		printerr("SpatialGrid not initialized or cell_size invalid.")
		return []

	if count <= 0 or max_radius <= 0:
		return []

	var max_radius_sq: float = max_radius * max_radius # 预计算平方半径

	var candidates: Array = [] # 存储 [距离平方, 节点]
	var checked_cells: Dictionary = {} # 存储已检查的单元格坐标 (Vector2i -> bool)

	var center_cell: Vector2i = spatial_grid.world_to_cell(center_position)

	# 使用 Array 作为队列来存储待检查的单元格层
	var current_layer: Array[Vector2i] = [center_cell]
	checked_cells[center_cell] = true # 标记中心单元格已访问

	while not current_layer.is_empty():

		# --- 优化检查：是否可以提前终止? ---
		var min_dist_sq_to_layer: float = INF # 到当前层所有单元格的最小距离平方
		for cell in current_layer:
			var dist_sq = spatial_grid.get_min_distance_sq_to_cell(center_position, cell)
			min_dist_sq_to_layer = min(min_dist_sq_to_layer, dist_sq)

		if min_dist_sq_to_layer > max_radius_sq:
			break

		# 如果已经找到了足够的候选者，并且它们中的第 N 个比当前层所有单元格的最近距离还要近，
		# 那么更外层的单元格必然更远，可以停止搜索。
		if candidates.size() >= count:
			# 需要对现有候选者排序以找到第 N 个的距离
			candidates.sort_custom(func(a, b): return a[0] < b[0])
			var nth_dist_sq = candidates[count - 1][0]
			if nth_dist_sq < min_dist_sq_to_layer:
				# print("Early exit: Nth candidate (%s) is closer than the next layer (%s)" % [sqrt(nth_dist_sq), sqrt(min_dist_sq_to_layer)])
				break # 提前退出循环

		# --- 处理当前层的单元格 ---
		var next_layer_candidates: Dictionary = {} # 使用字典防止重复添加下一层单元格

		for cell_coords in current_layer:
			# 再次检查距离，如果单元格本身完全在 max_radius 之外，可以跳过
			# 注意：get_min_distance_sq_to_cell 计算的是到边界的距离，如果点在内部距离为0
			# 如果单元格到点的最小距离已超限，则该单元格内不可能有符合条件的点
			if cell_coords != center_cell:

				 # 但保留此检查可以避免处理那些明显过远的单元格内的对象
				var cell_dist_sq = spatial_grid.get_min_distance_sq_to_cell(center_position, cell_coords)
				if cell_dist_sq > max_radius_sq:
					continue

			# 获取单元格内的对象
			var objects_in_cell: Array= spatial_grid.get_objects_in_cell(cell_coords)
			for obj in objects_in_cell:
				if not is_instance_valid(obj) or obj == exclude_self:
					continue

				#if not obj.has_meta("global_position"):
					#continue # 跳过没有位置信息的对象

				var dist_sq = obj.global_position.distance_squared_to(center_position)

				# 检查是否在最大半径内
				if dist_sq <= max_radius_sq:
					candidates.append([dist_sq, obj])

			# --- 查找并添加下一层的邻居单元格 ---
			# 遍历当前单元格的8个方向邻居
			for dx in range(-1, 2): # -1, 0, 1
				for dy in range(-1, 2): # -1, 0, 1
					if dx == 0 and dy == 0: # 跳过自身
						continue

					var neighbor_coords = cell_coords + Vector2i(dx, dy)

					# 如果邻居单元格没有被检查过，则添加到下一层候选列表
					if not checked_cells.has(neighbor_coords):
						checked_cells[neighbor_coords] = true # 标记为已访问（将在下一轮处理）
						next_layer_candidates[neighbor_coords] = true # 添加到下一层，字典自动去重

			# 更新当前层为下一层 (修正类型问题 - 使用 append)
			var typed_next_layer: Array[Vector2i] = [] # 创建一个新的、正确类型的数组
			for key in next_layer_candidates.keys():
				# key 变量在这里会被推断为 Variant，但我们知道它是 Vector2i
				typed_next_layer.append(key) # 将 key 添加到类型化的数组中
			current_layer = typed_next_layer


	# --- 循环结束后处理 ---
	# 最终排序（如果在循环中没有每次都排序，或者提前退出了）
	candidates.sort_custom(func(a, b): return a[0] < b[0])

	# 提取前 N 个结果
	var final_results: Array[Node] = []
	var num_to_return = min(count, candidates.size())
	for i in range(num_to_return):
		final_results.append(candidates[i][1])

	return final_results

# 定期检查或按需调用此函数，清理网格中的无效引用
func audit_spatial_grid():
	if not is_instance_valid(spatial_grid): return

	var cells_to_delete_if_empty = [] # 记录清理后变空的单元格

	# 遍历所有单元格坐标
	# 使用 .keys().duplicate() 避免在迭代时修改字典导致问题
	for cell_coords in spatial_grid.grid.keys().duplicate():
		var cell_array = spatial_grid.grid[cell_coords]

		# 使用反向循环或创建一个新数组来安全地移除元素
		var cleaned_array = []

		for i in range(cell_array.size() - 1, -1, -1):
			if not is_instance_valid(cell_array[i]):

				cell_array.remove_at(i) # 直接在原数组中移除

		# 如果单元格在清理后变空了
		if cell_array.is_empty():

			cells_to_delete_if_empty.append(cell_coords)

	# 清理结束后，统一删除那些变空的单元格
	for cell_coords in cells_to_delete_if_empty:
		if spatial_grid.grid.has(cell_coords): # 再次检查以防万一
			spatial_grid.grid.erase(cell_coords)

func process_mob_movement(delta):
	# --- 0. 检查依赖项 ---
	#if not is_instance_valid(spatial_grid) or not Engine.has_singleton("WorkerThreadPool"):
		## 如果网格无效或线程池不可用，则跳过优化逻辑
		## (你可能需要添加一个不使用线程的备用逻辑)
		##_apply_forces_and_move(delta) # 假设有一个应用力并移动的函数
		#return

	# --- 1. 等待并收集上一帧 (N-1) 的计算结果 ---
	var previous_results = {} # 创建一个临时字典来收集结果
	results_mutex.lock() # 锁定以安全访问共享字典
	previous_results = avoidance_results.duplicate(true) # 深度复制结果
	avoidance_results.clear() # 清空共享字典，为下次计算做准备
	results_mutex.unlock()

	# 等待上一帧提交的所有任务完成
	for task_id in avoidance_task_ids:
		WorkerThreadPool.wait_for_task_completion(task_id)
	avoidance_task_ids.clear() # 清空任务 ID 列表

	# --- 2. 应用上一帧 (N-1) 计算出的避障力到当前帧 (N) ---
	# (这部分逻辑与步骤 4 的移动合并)

	# --- 3. 准备当前帧 (N) 的计算数据 ---
	var enemies_data_to_process = [] # 存储需要计算的敌人及其邻居信息

	# 3.1 收集所有有效敌人的 ID 和位置 (主线程)
	var current_enemy_positions = {} # {id: pos}
	var current_enemy_targets = {} # {id: target_velocity} (假设敌人有目标速度)
	for id in mob_dic.keys():
		var enemy = mob_dic[id]
		if is_instance_valid(enemy):
			current_enemy_positions[id] = enemy.global_position
			# 假设 Enemy 有一个 get_desired_velocity() 方法
			if enemy.has_method("get_desired_velocity"):
				current_enemy_targets[id] = enemy.get_desired_velocity()
			else:
				current_enemy_targets[id] = Vector2.ZERO

	# 3.2 为每个敌人查询邻居 (主线程，访问 SpatialGrid)
	for id in current_enemy_positions:
		var enemy_pos = current_enemy_positions[id]
		# 在主线程安全地查询空间网格
		var neighbors_nodes = find_closest_enemies( # 使用 EnemyManager 的方法
			enemy_pos,
			AVOIDANCE_NEIGHBOR_QUERY_COUNT,
			AVOIDANCE_RADIUS,
			mob_dic[id] # 排除自己
		)

		# 提取邻居的位置 (或其他线程安全的数据)
		var neighbor_positions = PackedVector2Array() # 使用 PackedArray 更安全
		for neighbor_node in neighbors_nodes:
			if is_instance_valid(neighbor_node):
				neighbor_positions.append(neighbor_node.global_position)

		# 将需要传递给工作线程的数据打包
		enemies_data_to_process.append({
			"id": id,
			"pos": enemy_pos,
			"neighbors": neighbor_positions
		})

	# --- 4. 分发当前帧 (N) 的计算任务到线程池 (主线程) ---
	for enemy_data in enemies_data_to_process:
		# 创建 Callable 指向静态计算函数
		var task_callable = Callable(self, "_calculate_avoidance_task").bind(
			enemy_data["id"],
			enemy_data["pos"],
			enemy_data["neighbors"],
			AVOIDANCE_RADIUS_SQ, # 传入平方值避免在线程中重复计算
			AVOIDANCE_STRENGTH,
			results_mutex, # 传入互斥锁引用
			avoidance_results # 传入共享结果字典引用 (线程将写入这里)
		)
		# 添加任务到线程池，并存储任务 ID
		var task_id = WorkerThreadPool.add_task(task_callable)
		avoidance_task_ids.append(task_id)

	# 启动线程池处理任务 (如果需要/或者它自动处理)
	# WorkerThreadPool.start() - 通常不需要手动调用 start

	# --- 5. 应用力并移动 (主线程) ---
	# 在这里，我们将上一帧计算出的力 (存储在 previous_results 中) 应用到当前帧
	_apply_forces_and_move(previous_results, current_enemy_targets, delta)


# --- 多线程避障相关变量 ---
# 存储上一帧分发的任务 ID
var avoidance_task_ids: Array = []
# 存储上一帧计算完成的结果 { enemy_id: avoidance_force }
var avoidance_results: Dictionary = {}
# 用于保护 avoidance_results 字典的互斥锁
var results_mutex: Mutex = Mutex.new()

# 敌人避障计算参数 (可以从 Enemy 脚本移动到这里，或者每个 Enemy 仍有自己的参数)
const AVOIDANCE_RADIUS = 40.0 # 示例值
const AVOIDANCE_STRENGTH = 3000.0 # 示例值
const AVOIDANCE_NEIGHBOR_QUERY_COUNT = 6 # 示例值
const AVOIDANCE_RADIUS_SQ = AVOIDANCE_RADIUS * AVOIDANCE_RADIUS # 预计算平方值

func _physics_process(delta):
	audit_timer += delta
	if audit_timer >= AUDIT_INTERVAL:
		audit_timer = 0.0
		audit_spatial_grid()
	#process_mob_movement(delta)


# 静态方法或普通方法，用于在工作线程中执行纯计算
# !! 重要: 此函数内绝对不能访问任何 Godot 节点或非线程安全的全局变量 !!
# !! 只能使用传入的参数和局部变量进行计算 !!
static func _calculate_avoidance_task(enemy_id, enemy_pos, neighbor_positions, radius_sq, strength, mutex, results):
	var avoidance_force = Vector2.ZERO
	for neighbor_pos in neighbor_positions:
		var to_neighbor = neighbor_pos - enemy_pos
		var dist_sq = to_neighbor.length_squared()

		if dist_sq > 0.001 and dist_sq < radius_sq:
			# var weight = strength / dist_sq # 或者其他计算方式

			var weight = strength * (1.0 - sqrt(dist_sq / radius_sq)) # 线性衰减示例

			# 避免在距离非常近时力度无限大或过大
			#weight = min(weight, strength * 10.0) # 示例：限制最大权重

			var away_direction = -to_neighbor.normalized()
			avoidance_force += away_direction * weight
	#avoidance_force = avoidance_force.limit_length(500)

	# 使用互斥锁安全地写入共享的结果字典
	mutex.lock()
	results[enemy_id] = avoidance_force
	mutex.unlock()
	# 任务完成


# 辅助函数：应用力和移动敌人 (在主线程执行)
func _apply_forces_and_move(forces_from_last_frame: Dictionary, current_targets: Dictionary, delta):
	for id in mob_dic:
		var enemy = mob_dic[id]
		if not is_instance_valid(enemy): continue

		## 获取敌人期望的速度 (来自当前帧的AI逻辑)
		#var desired_velocity = current_targets.get(id, Vector2.ZERO)
#
		## 获取上一帧计算出的避障力
		#var avoidance = forces_from_last_frame.get(id, Vector2.ZERO)
		var final_velocity = current_targets.get(id, Vector2.ZERO) + forces_from_last_frame.get(id, Vector2.ZERO)*0.5
		#final_velocity = lerp(current_targets.get(id, Vector2.ZERO),forces_from_last_frame.get(id, Vector2.ZERO),0.8)
		if final_velocity.length_squared() > enemy.mob_info.speed * enemy.mob_info.speed:
			final_velocity = final_velocity.normalized() * enemy.mob_info.speed
		# 结合速度 (这里的 enemy 需要是 CharacterBody2D 或类似节点)
		enemy.velocity = enemy.velocity.move_toward(final_velocity,150)


		# 执行移动
		enemy.move_and_slide()
