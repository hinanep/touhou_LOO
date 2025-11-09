class_name Skill extends Node2D

## 该技能发射所有 routine 的信号
signal shoot

## 技能数据
var skill_info: Dictionary = {
	id = 'default_skill',
	upgrade_group = '',
	routines = [],
	cd = 1.0,
	cd_reduction_efficicency = 1.0
}

var active: bool = true
var level: int = 0
var max_level: int = 0
var damage_source: String = ""

@onready var cd_timer: Timer = $cd_timer

#-----------------------------------------------------------------------------
# Godot 生命周期方法
#-----------------------------------------------------------------------------

func _ready() -> void:
	name = skill_info.id
	damage_source = skill_info.id

	add_to_group(skill_info.id)
	if skill_info.has("upgrade_group"):
		add_to_group(skill_info.upgrade_group)

	_connect_signals()

	# --- 【已恢复】使用你原来的初始化逻辑 ---
	for aroutine in table.Routine:
		if table.Routine[aroutine].skill_group == skill_info.id:
			var r = add_routine(aroutine)
			if aroutine in skill_info.routines:
				shoot.connect(r._execute_attack_flow)
	# --- 恢复结束 ---

	if table.Upgrade.has(skill_info.upgrade_group):
		max_level = table.Upgrade[skill_info.upgrade_group].level

	# 初始化并启动计时器
	_update_cooldown_timer(skill_info.id)
	cd_timer.start()

	# 立即触发一次
	_fire()

#-----------------------------------------------------------------------------
# 初始化和信号连接
#-----------------------------------------------------------------------------

func _connect_signals() -> void:
	SignalBus.renew_state.connect(_update_cooldown_timer)
	SignalBus.del_skill.connect(_on_destroy_signal)
	cd_timer.timeout.connect(_on_cd_timer_timeout)

# --- 【已恢复】使用你原来的预制体加载方式 ---
func add_routine(id: String) -> Node:
	var routine_instance = PresetManager.getpre('routine').instantiate()
	routine_instance.position = Vector2.ZERO
	routine_instance.routine_info = table.Routine[id].duplicate()
	routine_instance.damage_source = self.damage_source

	add_child(routine_instance)
	return routine_instance
# --- 恢复结束 ---

#-----------------------------------------------------------------------------
# 核心功能
#-----------------------------------------------------------------------------

## 【保留的优化】触发所有 routine
func _fire() -> void:
	if not active:
		return
	shoot.emit()

## 【保留的优化】更新冷却计时器的时间
func _update_cooldown_timer(id) -> void:
	if id != skill_info.id:
		return
	var base_cd = skill_info.get("cd", 1.0)
	var efficiency = skill_info.get("cd_reduction_efficicency", 1.0)

	var player_cd_reduction_factor = 1.0 + player_var.colddown_reduce * efficiency

	var final_cd = base_cd / (player_cd_reduction_factor)
	cd_timer.wait_time = max(0.1, final_cd)

#-----------------------------------------------------------------------------
# 信号回调
#-----------------------------------------------------------------------------

func _on_cd_timer_timeout() -> void:
	_fire()


func _on_destroy_signal(id: String) -> void:
	if skill_info.id != id:
		return

	active = false
	for child in get_children():
		if is_instance_valid(child) and child.has_method('destroy'):
			child.destroy()

	queue_free()
