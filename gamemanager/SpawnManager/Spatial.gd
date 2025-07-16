# SpatialGrid.gd
# 一个用于管理 2D 空间中节点位置的网格系统

class_name SpatialGrid
extends RefCounted # 使用 RefCounted 使其可以被共享和管理，而不是 Node

# 网格单元格的大小 (世界单位)
var cell_size: Vector2

# 存储网格数据的主要字典
# 键: Vector2i (单元格坐标)
# 值: Array[Node] (在该单元格中的节点列表)
var grid: Dictionary = {}

# --- 初始化 ---

# 构造函数，需要传入单元格大小
func _init(p_cell_size: Vector2):
	if p_cell_size.x <= 0 or p_cell_size.y <= 0:
		printerr("SpatialGrid: Cell size must be positive.")
		cell_size = Vector2(100, 100) # 提供一个默认值
	else:
		cell_size = p_cell_size

# --- 核心功能 ---

# 将世界坐标转换为网格单元格坐标 (整数)
func world_to_cell(world_position: Vector2) -> Vector2i:
	# 使用 floor 向下取整，确保坐标对应正确的单元格
	var cell_x = floor(world_position.x / cell_size.x)
	var cell_y = floor(world_position.y / cell_size.y)
	return Vector2i(int(cell_x), int(cell_y))

# 向网格中添加一个对象 (例如敌人节点)
func add_object(obj: Node, position: Vector2):
	var cell_coords: Vector2i = world_to_cell(position)

	# 如果该单元格在字典中不存在，则创建它
	if not grid.has(cell_coords):
		grid[cell_coords] = []

	# 将对象添加到对应的单元格列表中 (如果尚未存在)
	if not grid[cell_coords].has(obj):
		grid[cell_coords].append(obj)
		# 可选: 在对象本身存储其当前单元格，以便快速更新
		if obj.has_method("set_current_grid_cell"):
			obj.set_current_grid_cell(cell_coords)

# 从网格中移除一个对象
func remove_object(obj: Node, position: Vector2):
	var cell_coords: Vector2i = world_to_cell(position)

	# 检查单元格是否存在以及对象是否在该单元格中
	if grid.has(cell_coords) and grid[cell_coords].has(obj):
		grid[cell_coords].erase(obj)
		# 如果移除后单元格变空，可以选择从字典中删除该键以节省内存
		if grid[cell_coords].is_empty():
			grid.erase(cell_coords)
		# 可选: 清除对象存储的单元格信息
		#if obj.has_method("set_current_grid_cell"):
			#obj.set_current_grid_cell(null) # 使用 null 或其他标记表示不在网格中

# 当对象位置更新时，更新其在网格中的位置
# 返回 true 如果对象的单元格发生了改变, 否则返回 false
func update_object_position(obj: Node, old_position: Vector2, new_position: Vector2) -> bool:
	var old_cell: Vector2i = world_to_cell(old_position)
	var new_cell: Vector2i = world_to_cell(new_position)

	# 只有当对象跨越了单元格边界时才需要更新
	if old_cell != new_cell:
		# 从旧单元格移除
		if grid.has(old_cell) and grid[old_cell].has(obj):
			grid[old_cell].erase(obj)
			if grid[old_cell].is_empty():
				grid.erase(old_cell)

		# 添加到新单元格
		if not grid.has(new_cell):
			grid[new_cell] = []
		if not grid[new_cell].has(obj): # 再次检查以防万一
			grid[new_cell].append(obj)

		# 可选: 更新对象自身存储的单元格信息
		if obj.has_method("set_current_grid_cell"):
			obj.set_current_grid_cell(new_cell)
		return true # 单元格已改变

	return false # 仍在同一单元格内

# --- 查询功能 ---

# 获取指定单元格内的所有对象
func get_objects_in_cell(cell_coords: Vector2i) -> Array:
	if grid.has(cell_coords):
		# 返回数组的副本，以防外部修改影响内部数据
		return grid[cell_coords].duplicate()
	else:
		return [] # 返回空数组

# 获取与给定矩形区域重叠的所有单元格内的对象
# 注意: 这会返回所有在 *重叠单元格* 内的对象，
# 可能需要进一步精确检查对象位置是否真的在矩形内。
func get_objects_in_area(query_rect: Rect2) -> Array[Node]:
	var objects_found: Array[Node] = []
	var min_cell: Vector2i = world_to_cell(query_rect.position)
	var max_cell: Vector2i = world_to_cell(query_rect.position + query_rect.size)

	# 遍历所有可能重叠的单元格
	for x in range(min_cell.x, max_cell.x + 1):
		for y in range(min_cell.y, max_cell.y + 1):
			var cell_coords = Vector2i(x, y)
			if grid.has(cell_coords):
				# 将该单元格的所有对象添加到结果列表
				# 使用 extend 而不是 append，因为 grid[cell_coords] 是一个数组
				objects_found.append_array(grid[cell_coords])

	# 可选: 进行精确过滤 (如果需要)
	# var precise_objects: Array[Node] = []
	# for obj in objects_found:
	#	 if query_rect.has_point(obj.global_position): # 假设对象有 global_position
	#		 precise_objects.append(obj)
	# return precise_objects

	# 去重 (因为一个对象可能因为查询区域跨越多个单元格而被多次添加)
	# 如果一个对象只存在于一个单元格中，理论上不会重复。
	# 但如果查询逻辑复杂，或对象可能错误地存在于多个单元格，去重是保险的。
	# 这里用 Dictionary 实现简单去重：
	var unique_objects_dict = {}
	for obj in objects_found:
		unique_objects_dict[obj] = true # 利用字典键的唯一性

	return unique_objects_dict.keys() # 返回去重后的对象列表


# 获取距离给定点特定半径范围内的所有对象
# 类似 get_objects_in_area，先找到覆盖查询圆形的边界框对应的单元格，
# 然后再对这些单元格内的对象进行精确的距离检查。
func get_objects_near_point(center: Vector2, radius: float) -> Array[Node]:
	var objects_found: Array[Node] = []
	var radius_sq: float = radius * radius # 使用平方距离避免开方运算

	# 计算包含查询圆形的轴对齐包围盒 (AABB)
	var query_bounds = Rect2(center - Vector2(radius, radius), Vector2(radius, radius) * 2)

	# 获取可能包含相关对象的单元格范围
	var min_cell: Vector2i = world_to_cell(query_bounds.position)
	var max_cell: Vector2i = world_to_cell(query_bounds.position + query_bounds.size)

	# 遍历这些单元格
	for x in range(min_cell.x, max_cell.x + 1):
		for y in range(min_cell.y, max_cell.y + 1):
			var cell_coords = Vector2i(x, y)
			if grid.has(cell_coords):
				# 对单元格内的每个对象进行精确距离检查
				for obj in grid[cell_coords]:
					# 假设对象有 global_position 属性
					if obj.global_position.distance_squared_to(center) < radius_sq:
						objects_found.append(obj)

	# 去重 (理由同上)
	var unique_objects_dict = {}
	for obj in objects_found:
		unique_objects_dict[obj] = true

	return unique_objects_dict.keys()


# --- 清理 ---

# 清空整个网格
func clear():
	grid.clear()


# 计算一个点到指定单元格边界的最小平方距离
# 用于优化搜索，判断是否需要继续检查更远的单元格
func get_min_distance_sq_to_cell(point: Vector2, cell_coords: Vector2i) -> float:
	if cell_size.x <= 0 or cell_size.y <= 0:
		printerr("get_min_distance_sq_to_cell: Invalid cell_size.")
		return 0.0 # 或者返回一个错误值

	# 计算单元格的边界
	var cell_min_x: float = float(cell_coords.x) * cell_size.x
	var cell_max_x: float = cell_min_x + cell_size.x
	var cell_min_y: float = float(cell_coords.y) * cell_size.y
	var cell_max_y: float = cell_min_y + cell_size.y

	# 计算点到单元格边界在 x 和 y 轴上的最近距离分量
	var dx: float = 0.0
	if point.x < cell_min_x:
		dx = cell_min_x - point.x
	elif point.x > cell_max_x:
		dx = point.x - cell_max_x
	# else: dx = 0.0 (点在单元格的 x 范围内)

	var dy: float = 0.0
	if point.y < cell_min_y:
		dy = cell_min_y - point.y
	elif point.y > cell_max_y:
		dy = point.y - cell_max_y
	# else: dy = 0.0 (点在单元格的 y 范围内)

	# 勾股定理计算平方距离
	return dx * dx + dy * dy
