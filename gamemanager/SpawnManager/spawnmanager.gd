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
const AUDIT_INTERVAL = 5.0 # 每 5 秒检查一次
func _ready() -> void:
	spatial_grid =SpatialGrid.new(GRID_CELL_SIZE)

func _physics_process(delta):
	audit_timer += delta
	if audit_timer >= AUDIT_INTERVAL:
		audit_timer = 0.0
		audit_spatial_grid()

#func draw_astar_map():
		#var ast = AStar2D.new()
		#for i in mob_dic:
			#if mob_dic[i]!=null:
				#ast.add_point(i,mob_dic[i].global_position)
		#mob_map = ast

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
	if is_instance_valid(mob_dic[mob_id]) and spatial_grid:
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
			if min_dist_sq_to_layer > max_radius_sq and cell_coords != center_cell: # 仅当最小距离大于0时检查
				 # 实际上，上面的 break 条件更强，这里可以简化或移除
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
	var invalid_found_count = 0

	# 遍历所有单元格坐标
	# 使用 .keys().duplicate() 避免在迭代时修改字典导致问题
	for cell_coords in spatial_grid.grid.keys().duplicate():
		var cell_array = spatial_grid.grid[cell_coords]
		var original_size = cell_array.size()

		# 使用反向循环或创建一个新数组来安全地移除元素
		var cleaned_array = []
		var cell_had_invalid = false
		for i in range(cell_array.size() - 1, -1, -1):
			var obj = cell_array[i]
			if is_instance_valid(obj):
				# cleaned_array.push_front(obj) # 如果要保持顺序，添加到新数组前端
				pass # 如果原地修改则什么都不做
			else:
				# 发现了无效引用！
				# print("Audit: Found invalid reference in cell %s at index %s. Removing." % [cell_coords, i])
				cell_array.remove_at(i) # 直接在原数组中移除
				cell_had_invalid = true
				invalid_found_count += 1

		# 如果单元格在清理后变空了
		if cell_array.is_empty() and cell_had_invalid: # 确保是因为清理才变空的
			# print("Audit: Cell %s became empty after cleaning invalid references. Removing cell." % cell_coords)
			cells_to_delete_if_empty.append(cell_coords)

	# 清理结束后，统一删除那些变空的单元格
	for cell_coords in cells_to_delete_if_empty:
		if spatial_grid.grid.has(cell_coords): # 再次检查以防万一
			spatial_grid.grid.erase(cell_coords)

	# if invalid_found_count > 0:
	#	 print("Spatial Grid Audit finished. Found and removed %s invalid references." % invalid_found_count)

# 你可以在 _process 中每隔一段时间调用一次 audit_spatial_grid()，或者在特定事件后调用
# 例如：
# var audit_timer = 0.0
# const AUDIT_INTERVAL = 5.0 # 每 5 秒检查一次
# func _process(delta):
#     audit_timer += delta
#     if audit_timer >= AUDIT_INTERVAL:
#         audit_timer = 0.0
#         audit_spatial_grid()
