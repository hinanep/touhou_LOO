extends Node
class_name SpawnManagers
var event_list = {}

var spawner_pre

@onready var spawnmanager_node = $"."

var mob_dic:Dictionary
var id = 0
const GRID_CELL_SIZE = Vector2(50, 50)

var audit_timer = 0.0
const AUDIT_INTERVAL = 15.0 # 每 15 秒检查一次
func _ready() -> void:
	SignalBus.add_mob_to_manager.connect(add_mob)




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

	register_mob(mob_ins)
	spawnmanager_node.add_child(mob_ins)

func register_mob(mob):
	mob.die.connect(del_mob)
	mob.mob_id = id
	mob_dic[id] = mob
	id += 1


func del_mob(mob_id):
	if not mob_dic.has(mob_id):
		return

	var mob = mob_dic[mob_id]

	# 断开信号连接
	if mob and is_instance_valid(mob):
		# 断开所有可能的信号连接
		if mob.die.is_connected(del_mob):
			mob.die.disconnect(del_mob)

		# 清理C#避障模块引用
		if player_var.MonsterAvoidanceManager and mob.has_method("get_avoidance_module"):
			var avoidance_module = mob.get_avoidance_module()
			if avoidance_module:
				avoidance_module.Call("unregister")

	# 从字典中移除
	mob_dic.erase(mob_id)

func get_strongest_mob():
	if mob_dic.is_empty():
		return null
	var maxmob =mob_dic[mob_dic.keys()[0]]
	for mob in mob_dic:
		if mob_dic[mob] and mob_dic[mob].is_inscreen and mob_dic[mob].hp > maxmob.hp:
			maxmob = mob_dic[mob]
	return maxmob

func clear():
	printerr('spawnmanager has been clear')

	# 清理所有怪物
	for mob_id in mob_dic.keys():
		del_mob(mob_id)

	# 清理所有子节点
	for child in spawnmanager_node.get_children():
		if is_instance_valid(child):
			child.queue_free()

	id = 0
	mob_dic = {}
# 寻找距离指定点最近的N个敌人 (优化版：逐层搜索网格)
# ... (参数和返回说明同前) ...
func find_closest_enemies(center_position: Vector2, count: int, max_radius: float, exclude_self: Node = null,simple = false) -> Array[Node]:
	var final_results: Array[Node] = []
	final_results.append(player_var.MonsterAvoidanceManager.FindClosestEnemy(center_position, exclude_self))
	return final_results
