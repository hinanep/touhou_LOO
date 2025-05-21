extends CanvasLayer

var arrow_scene: PackedScene = preload("res://scene/drops/plate/arrow/arrow.tscn")
@export var target_group: String = "treasure_chests"
@export var screen_margin: float = 50.0
# 新增：当宝箱在屏幕上时，箭头在宝箱上方的垂直偏移量（像素单位，在世界空间中）
@export var on_screen_vertical_offset: float = 40.0

var active_arrows: Dictionary = {}
var viewport_size: Vector2
var camera: Camera2D
var safe_rect
# Helper function to get or create an arrow instance for a chest
func _ensure_arrow_exists(chest_id) -> Node2D:
	if active_arrows.has(chest_id):
		var existing_arrow = active_arrows[chest_id]
		if is_instance_valid(existing_arrow):
			return existing_arrow
		else:
			# 箭头实例失效，移除旧条目，稍后会创建新的
			active_arrows.erase(chest_id)

	# 创建新箭头
	if not arrow_scene:
		arrow_scene = preload("res://scene/drops/plate/arrow/arrow.tscn")
		printerr("ChestIndicatorManager: Arrow Scene is not set!")
		return null # 返回 null，调用处需要处理

	var new_arrow = arrow_scene.instantiate()
	add_child(new_arrow)
	active_arrows[chest_id] = new_arrow
	return new_arrow


func _ready():
	await get_tree().process_frame
	camera = get_viewport().get_camera_2d()
	if not camera:
		printerr("ChestIndicatorManager: Could not find Camera2D.")
		set_process(false)
		return
	_on_viewport_size_changed() # 初始化 viewport_size
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	viewport_size = get_viewport().get_visible_rect().size
var chest_screen_pos: Vector2
	# 获取必要的摄像机信息
var cam_global_pos: Vector2
var cam_screen_center: Vector2
var cam_zoom: Vector2
var chest_world_pos: Vector2

func _process(delta):
	if not is_instance_valid(camera):
		camera = get_viewport().get_camera_2d()
		if not camera:
			_clear_all_arrows()
			set_process(false)
			printerr("ChestIndicatorManager: Camera became invalid.")
			return
		else:
			_on_viewport_size_changed()

	safe_rect = Rect2(screen_margin-viewport_size.x/4, screen_margin-viewport_size.y/4,
						  viewport_size.x/2 - screen_margin * 2,
						  viewport_size.y/2 - screen_margin * 2)

	var current_chests: Dictionary = {}
	for chest in get_tree().get_nodes_in_group(target_group):
		if is_instance_valid(chest) and chest.has_method("get_global_position"): # 确保是 Node2D 或其子类
			current_chests[chest.get_instance_id()] = chest

	# 获取必要的摄像机信息
	cam_global_pos = camera.global_position
	cam_screen_center = viewport_size/2
	cam_zoom = camera.get_zoom() # 注意 zoom 是 Vector2

	# --- 更新或创建箭头 ---
	for chest_id in current_chests:
		var chest = current_chests[chest_id]
		chest_world_pos = chest.global_position

		# 将宝箱世界坐标转换为屏幕坐标 - 使用新的计算公式
		chest_screen_pos = cam_screen_center + (chest_world_pos - cam_global_pos) * cam_zoom

		var is_visible_on_screen = Rect2(Vector2(0,60), viewport_size).has_point(chest_screen_pos)


		var arrow_instance = _ensure_arrow_exists(chest_id)
		if not is_instance_valid(arrow_instance): continue

		if is_visible_on_screen:
			# --- 行为：宝箱在屏幕内 ---
			var arrow_target_world_pos = chest_world_pos + Vector2(0, -on_screen_vertical_offset)

			# 将世界坐标转换为屏幕坐标 (CanvasLayer 坐标) - 使用新的计算公式
			var arrow_screen_pos
			arrow_screen_pos = (arrow_target_world_pos - cam_global_pos) * cam_zoom+viewport_size/2

			arrow_instance.position = arrow_screen_pos
			arrow_instance.rotation = PI / 2.0 # 假设箭头向右为0度
			# arrow_instance.visible = arrow_screen_pos.distance_to(chest_screen_pos) > 10.0 # 可选

		else:
			# --- 行为：宝箱在屏幕外 ---
			var direction = chest_world_pos - cam_global_pos
			arrow_instance.rotation = direction.angle()


			arrow_instance.position = intersect_center_ray_rect_min_t(direction,safe_rect)* cam_zoom+viewport_size/2


			arrow_instance.visible = true

	# --- 清理不再存在的宝箱对应的箭头 ---
	var chest_ids_to_remove: Array = []
	for existing_chest_id in active_arrows:
		if not current_chests.has(existing_chest_id):
			var arrow_to_remove = active_arrows[existing_chest_id]
			if is_instance_valid(arrow_to_remove):
				arrow_to_remove.queue_free()
			chest_ids_to_remove.append(existing_chest_id)

	for id_to_remove in chest_ids_to_remove:
		active_arrows.erase(id_to_remove)


func _clear_all_arrows():
	for chest_id in active_arrows:
		var arrow = active_arrows[chest_id]
		if is_instance_valid(arrow):
			arrow.queue_free()
	active_arrows.clear()

func _exit_tree():
	_clear_all_arrows()

# 计算从矩形中心出发的射线与矩形边界的交点 (基于最小 t 值)
# direction: 射线的方向向量 (Vector2)，不需要是单位向量
# rect: 矩形 (Rect2)
# 返回: 交点 (Vector2) 或 null (如果 direction 是零向量)

const CMP_EPSILON = 0.00001 # 定义一个足够小的浮点数比较阈值

static func intersect_center_ray_rect_min_t(direction: Vector2, rect: Rect2) -> Variant:


	# 2. 获取中心和半尺寸
	var center: Vector2 = rect.get_center()
	var half_size: Vector2 = rect.size / 2.0


	# 3. 计算到达垂直边界和水平边界所需的参数 t (取绝对值)
	var tx: float = INF # 初始化为无穷大
	if abs(direction.x) > CMP_EPSILON:
		tx = abs(half_size.x / direction.x)

	var ty: float = INF # 初始化为无穷大
	if abs(direction.y) > CMP_EPSILON:
		ty = abs(half_size.y / direction.y)

	# 4. 找出最小的 t 值，即射线第一次碰到边界的参数
	#    如果 tx 和 ty 都是 INF，意味着 direction 也是零 (理论上第一步已处理)
	if tx == INF and ty == INF:
		printerr("Intersection check failed: Could not determine intersection t (direction might be zero despite check?).")
		return null # 无法计算交点

	var t_intersect: float = min(tx, ty)

	# 5. 计算交点坐标
	var intersection_point: Vector2 = center + direction * t_intersect

	return intersection_point
