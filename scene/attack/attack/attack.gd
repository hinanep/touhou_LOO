class_name Attack extends CharacterBody2D

# 信号：当此节点完成使命，应返回对象池时发出
signal returned_to_pool(node: Node)
# 信号：当击杀敌人时发出
signal killed_enemy(enemy_position: Vector2)

signal online
# --- 导出属性 ---
var attack_info: Dictionary = {}

# --- 状态变量 ---
var penetration_count: int = 0
var is_active: bool = false
var damage_source: String = ""
var lock_routine
var batch_num
# --- 组件引用 ---
@onready var lock_component = $lock_component
@onready var move_component = $move_component
@onready var damage_area: Area2D = $damage_area
@onready var duration_timer: Timer = $duration_timer
@export var particles: Array[Node] = [] # 示例
@onready var texture = $lock_component
var dot_tween:Tween
#=============================================================================
# 生命周期 & 对象池接口
#=============================================================================

# Godot生命周期方法: 仅在节点首次实例化时执行一次。
func _ready() -> void:
	# 一次性设置，不会在重用时改变
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	duration_timer.timeout.connect(_on_duration_timeout)
	killed_enemy.connect(_on_enemy_killed)



	SignalBus.renew_state.connect(_update_dynamic_stats)
	SignalBus.boss_stage.connect(_set_boss_mode)
	origin_scale = texture.scale
# 公开的初始化接口，由对象池在每次取出节点时调用
func initialize(attack_id: String, p_transform: Transform2D, p_damage_source: String, batch_num:int) -> void:
	self.damage_source = p_damage_source
	self.global_transform = p_transform
	self.penetration_count = 0
	self.batch_num = batch_num
	if attack_info.is_empty():
		attack_info = table.Attack.get(attack_id,{})
		if attack_info.has("reflection"):
			if attack_info.reflection.has("enemy"):
				set_collision_mask_value(2,true)

	if attack_info.get("damage_times") == "dot":
		dot_tween = create_tween().set_loops()
		dot_tween.tween_interval(0.25)
		dot_tween.tween_callback(do_dot)
	# 更新基于等级和玩家属性的动态属性
	_update_dynamic_stats(attack_id)

	# 激活节点
	_set_active(true)
	online.emit()
	# 初始化子组件
	lock_component.initialize($".", attack_info, lock_routine)
	move_component.initialize($".",attack_info,lock_component)

	# 重启特效和计时器
	for p:GPUParticles2D in particles:
		p.restart()


	if attack_info.get("duration", 0.0) > 0.0:
		duration_timer.start()


	show()
# 使节点失活并通知对象池回收
func _return_to_pool(reason: String = "") -> void:
	if not is_active: return

	if attack_info.get("destroying_routine_creation", []).size() > 0:
		_trigger_routines_on_event(attack_info.destroying_routine_creation)

	_set_active(false)
	returned_to_pool.emit(self)

#=============================================================================
# 核心逻辑
#=============================================================================

func _physics_process(delta: float) -> void:
	if not is_active: return
	# 将更新任务委托给移动组件
	move_component.physics_update(delta)

func do_dot():

	var all_mon3ter = damage_area.get_overlapping_bodies()
	if all_mon3ter.is_empty():
		return
	_trigger_routines_on_event(attack_info.get("hitting_routine_creation", []))
	for mon3ter in damage_area.get_overlapping_bodies():
		do_damage_to(mon3ter)

func _on_damage_area_body_entered(body: Node) -> void:
	if not body.has_method("mob_take_damage"):
		return

	_trigger_routines_on_event(attack_info.get("hitting_routine_creation", []))
	do_damage_to(body)


func do_damage_to(body):
	var damage_amount = attack_info.get("damage", 0.0)
	var damage_type = attack_info.get("damage_type", "danma")

	var final_damage = 0.0
	if damage_type == "danma":
		final_damage = player_var.player_make_bullet_damage(damage_amount * attack_info.get("magical_addition_efficiency", 1.0), damage_source)
	else:
		final_damage = player_var.player_make_melee_damage(damage_amount * attack_info.get("physical_addition_efficiency", 1.0), damage_source)

	body.mob_take_damage(final_damage)
	_apply_debuffs(body)

	if body.hp <= 0:
		killed_enemy.emit(body.global_position)

	penetration_count += 1
	if penetration_count >= attack_info.get("penetration", 1):
		_return_to_pool("penetration_limit")


func _apply_debuffs(body: Node) -> void:
	if not attack_info.has("debuff") or not body.has_method("set_debuff"):
		return

	var debuffs = attack_info.get("debuff", [])
	for i in debuffs.size():
		body.set_debuff(debuffs[i], attack_info.debuff_intensity[i], attack_info.debuff_duration[i], self)

#=============================================================================
# 升级与状态更新
#=============================================================================

func _update_dynamic_stats(id) -> void:
	if id != attack_info.id:
		return
	# 更新形状和尺寸
	_update_shape_and_size()

	# 更新持续时间
	var duration = attack_info.get("duration", 0.0)
	if duration > 0.0:
		if attack_info.has("duration_dependence"):
			duration = player_var.dep.operate_dep(attack_info.duration_dependence, duration)
		duration_timer.wait_time = duration




#=============================================================================
# 形状与视觉
#=============================================================================
var origin_scale = Vector2.ZERO
var shape_set = false
func _update_shape_and_size() -> void:
	var shape_type = attack_info.get("shape", "circle")
	var shape_node = damage_area.get_node("CollisionShape2D")
	var new_shape: Shape2D
	var size_add = 1.0
	if attack_info.has("size_dependence"):
		size_add = player_var.dep.operate_dep(attack_info.size_dependence, size_add)

	var final_scale = Vector2.ONE * player_var.range_add_ratio * size_add
	if final_scale.x/self.scale.x == 1:

		pass
	else:
		for particle:GPUParticles2D in particles:
			particle.process_material.scale_min *= final_scale/self.scale
			particle.process_material.scale_max *= final_scale/self.scale
		self.scale = final_scale
		
	if shape_set:
		return
		
	match shape_type:
		"circle":
			new_shape = _create_circle_shape()
		"rectangle_center", "rectangle_edge":
			var is_edge = (shape_type == "rectangle_edge")
			new_shape = _create_rectangle_shape(is_edge)

	if new_shape:
		shape_node.shape = new_shape
	shape_set = true


func _create_circle_shape() -> CircleShape2D:
	var shape = CircleShape2D.new()
	shape.radius = attack_info.size[0]
	texture.scale = origin_scale * shape.radius / 20
	for particle:GPUParticles2D in particles:
		particle.process_material.scale_min *= shape.radius / 20
		particle.process_material.scale_max *= shape.radius / 20
	return shape

func _create_rectangle_shape(is_edge_aligned: bool) -> RectangleShape2D:
	var shape = RectangleShape2D.new()
	shape.size = Vector2(attack_info.size[0], attack_info.size[1])
	texture.scale = origin_scale * shape.size / 20
	if is_edge_aligned:
		var shape_node = damage_area.get_node("CollisionShape2D")
		shape_node.position = Vector2(0, -shape.size.y / 2.0)
	return shape

func _trigger_routines_on_event(routines_to_trigger: Array) -> void:
	for routine_id in routines_to_trigger:
		SignalBus.trigger_routine_by_id.emit(routine_id, true, global_position, rotation, null)

func _on_enemy_killed(enemy_position: Vector2) -> void:
	if attack_info.has('defeating_item_creation'):
		for item in attack_info.defeating_item_creation:
			drop_item(item,attack_info.defeating_item_creation_value,enemy_position)
#消弹
func _on_bullet_erase_area_body_entered(body):
	body.disable(false)
	body.destroy.emit(body)
	if attack_info.has('eraseing_item_creation'):
		for item in attack_info.eraseing_item_creation:
			drop_item(item,attack_info.eraseing_item_creation_value,body.global_position)


func _set_boss_mode(is_boss: bool) -> void:
	if attack_info.damage_belong.contains("sc"): return
	modulate.a = 0.15 if is_boss else 1.0

#=============================================================================
# 工具函数
#=============================================================================

func _set_active(p_active: bool) -> void:
	self.is_active = p_active
	self.visible = p_active
	set_physics_process(p_active)
	if not p_active and dot_tween is Tween:
		dot_tween.kill()
	call_deferred("set_monitoring", p_active) # 延迟执行以避免物理引擎冲突

func set_monitoring(p_active: bool) -> void:
	if is_instance_valid(damage_area):
		damage_area.monitoring = p_active

func _on_duration_timeout() -> void:
	_return_to_pool("duration_timeout")


func _on_screen_exited() -> void:
	_return_to_pool("screen_exited")

#掉落
func drop_item(item,value,dposition):
	SignalBus.drop.emit('drops_'+item,dposition,value)
