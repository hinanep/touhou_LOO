extends Node2D

var event_list = {}

var spawner_pre

var spawnmanager_node
var mob_map = AStar2D.new()
var mob_array:Array
func _physics_process(_delta):
	draw_astar_map()

func draw_astar_map():
		var ast = AStar2D.new()
		for i in range(mob_array.size()):
			ast.add_point(i,mob_array[i].global_position)
		mob_map = ast

func add_spawn_event(spawner_init):
	var new_spawner = spawner_pre.instantiate()
	spawnmanager_node.add_child(new_spawner)
	new_spawner.spawner_init(spawner_init)


func prepare_all_spawn_event(spawnmanager,eventlist):
	spawner_pre = PresetManager.getpre("enemy_spawner")
	spawnmanager_node = spawnmanager
	event_list = eventlist

	for event in event_list:
		add_spawn_event(event_list[event])

func add_mob(mob_ins):
	add_child(mob_ins)
	mob_array.append(mob_ins)
	mob_ins.die.connect(del_mob)
	mob_ins.mob_id = mob_array.size()

func del_mob(id):
	mob_array.pop_at(id)
	draw_astar_map()
func get_nearest_mob(position):
	if mob_array.is_empty():
		return null
	return mob_array[mob_map.get_closest_point(position)]
func get_strongest_mob():
	if mob_array.is_empty():
		return null
	var max = mob_array[0]
	for mob in mob_array:
		if mob.hp > max.hp:
			max = mob
	return max
#event:
#"slime_green_1":{
	#"pre":PresetManager.getpre("enemy_zako_slime_green"),
	#"spawn_mode":"duration",
	#"start_time":0,
	#"end_time":15,
	#"tick_time":2,
	#"number":10,
	#"param_buff":0.75
#}
