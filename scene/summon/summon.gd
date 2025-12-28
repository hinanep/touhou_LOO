class_name Summon extends Node2D

# 信号：通知对象池回收自己
signal returned_to_pool(node: Node)

# --- 核心属性 ---
var summon_info: Dictionary = {}
var summon_id: String = "" # 用于自我配置

# --- 状态变量 ---
var level: int = 0
var is_active: bool = false
var damage_source: String = ""

# --- 组件引用 ---
@onready var cooldown_timer: Timer = $cd_timer
@onready var duration_timer: Timer = $duration
@onready var redirection_timer: Timer = $rediretion

var target_location
#=============================================================================
# 生命周期 & 对象池接口
#=============================================================================
var move_func = move_stay
# 仅在节点首次实例化时执行一次，负责连接不依赖 summon_info 的信号
func _ready() -> void:
	duration_timer.timeout.connect(_on_duration_timeout)
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	redirection_timer.timeout.connect(_on_redirection_timeout)

	SignalBus.upgrade_group.connect(_on_upgrade_signal)
	SignalBus.true_use_card.connect(_on_sc_destroy)



# 公开的初始化接口，由 Routine 的对象池在每次取出节点时调用
func initialize(p_id: String, p_transform: Transform2D, p_damage_source: String,batch_num:int) -> void:
	# --- 自我配置 ---
	if self.summon_id != p_id:
		self.summon_id = p_id
		if not table.Summoned.has(summon_id):
			push_error("Summon ID not found in table: " + summon_id)
			return
		self.summon_info = table.Summoned[summon_id]
		_one_time_setup_from_info()

	# --- 每次重生时的重置逻辑 ---
	self.damage_source = p_damage_source
	self.global_transform = p_transform

	_set_active(true)

	# 初始化子组件
	if summon_info.has('movement'):
		if summon_info.movement=='sandsoldier':
			move_func = move_sandsol
			target_location = player_var.player_node.global_position
			_on_redirection_timeout()
	# 设置并启动计时器
	_setup_timers(p_id)

	# 处理创建时触发的 routine
	_trigger_routines("creating_routine")
	if is_instance_valid(player_var.player_node):
		$Line2D.set_point_position(1, player_var.player_node.global_position - global_position)
	show()
# 仅执行一次的、依赖 summon_info 的设置
func _one_time_setup_from_info() -> void:
	name = summon_info.get("id", "summon")

# 使节点失活并通知对象池回收
func _return_to_pool() -> void:
	if not is_active: return
	if $subattack.get_child_count()>0:
		for atk in $subattack.get_children():
			atk.queue_free()
	_trigger_routines("destroying_routine")
	_set_active(false)
	returned_to_pool.emit(self)

#=============================================================================
# 核心功能与协调
#=============================================================================

func _physics_process(delta: float) -> void:
	if not is_active: return
	# 将移动任务委托给移动组件
	move_func.call(delta)

	# 如果需要画线，在这里更新
	if is_instance_valid(player_var.player_node):
		$Line2D.set_point_position(1, player_var.player_node.global_position - global_position)

# 触发指定事件的 routine
func _trigger_routines(event_key: String) -> void:
	var routines_to_trigger = summon_info.get(event_key, [])
	if event_key == "automatic_routine":

		for routine_id in routines_to_trigger:
			# 注意：第三个参数 true 表示强制世界坐标生成
			# 第四个参数 Vector2.ZERO 表示生成的相对位置为(0,0)，即召唤物自身位置
			# 第五个参数 self 表示生成的 routine attack 是召唤物自身的子节点
			SignalBus.trigger_routine_by_id.emit(routine_id, false, Vector2.ZERO, global_rotation, $subattack)

	else:
		for routine_id in routines_to_trigger:
			# 注意：第三个参数 true 表示强制世界坐标生成
			# 第四个参数 Vector2.ZERO 表示生成的相对位置为(0,0)，即召唤物自身位置
			# 第五个参数 self 表示生成的 routine attack 是召唤物自身的子节点
			print(name)
			print(event_key)
			SignalBus.trigger_routine_by_id.emit(routine_id, true, global_position, global_rotation,0)

#=============================================================================
# 计时器与信号回调
#=============================================================================

func _setup_timers(id) -> void:
	if id != summon_info.id:
		return
	var cd = summon_info.get("cd", 0.0)
	if cd > 0:
		cooldown_timer.wait_time = cd
		cooldown_timer.start()

	var duration = summon_info.get("duration", 0.0)
	if summon_info.has("dependence"):
		duration = player_var.dep.operate_dep(summon_info.dependence, duration)

	duration_timer.wait_time = max(duration,0.1)
	duration_timer.start()

	if summon_info.get("movement") == "sandsoldier":
		var redir_interval = summon_info.get("movement_parameter", [1.0])[0]
		redirection_timer.wait_time = redir_interval
		redirection_timer.start()
		# 首次立即索敌
		_on_redirection_timeout()

func _on_duration_timeout() -> void:
	_return_to_pool()

func _on_cooldown_timeout() -> void:
	_trigger_routines("automatic_routine")

# 重新索敌的回调
func _on_redirection_timeout() -> void:
	# 将索敌任务委托给索敌组件
		var target = player_var.SpawnManager.find_closest_enemies(global_position,1,1000,null)

		if not target.is_empty():
			if is_instance_valid(target[0]):

				target_location = target[0].global_position



func _on_upgrade_signal(group: String,cur) -> void:
	if summon_info.get("upgrade_group") != group: return
	level += 1
	# TODO: 应用实际的升级效果

func _on_sc_destroy(scid: String) -> void:
	if not is_active: return
	if not summon_info.get("special", {}).has("scdestroy"): return
	_trigger_routines("special_routine")
	_return_to_pool()



#=============================================================================
# 工具函数
#=============================================================================

func _set_active(p_active: bool) -> void:
	self.is_active = p_active
	visible = p_active
	set_physics_process(p_active)

	# 暂停或启动所有计时器
	cooldown_timer.paused = not p_active
	duration_timer.paused = not p_active
	redirection_timer.paused = not p_active

func move_sandsol(delta):
	if global_position.distance_squared_to(target_location)<10:
		return
	global_position += global_position.direction_to(target_location)*delta * 400 * player_var.bullet_speed_ratio
func move_stay(delta):
	pass
