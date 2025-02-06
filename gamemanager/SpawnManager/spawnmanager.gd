extends Node

var event_list = {}

var spawner_pre

@onready var spawnmanager_node = $"."
var mob_map = AStar2D.new()
var mob_dic:Dictionary
var id = 0
func _physics_process(_delta):
	draw_astar_map()

func draw_astar_map():
		var ast = AStar2D.new()
		for i in mob_dic:
			if mob_dic[i]!=null:
				ast.add_point(i,mob_dic[i].global_position)
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
	spawnmanager_node.add_child(mob_ins)

	mob_ins.die.connect(del_mob)
	mob_ins.mob_id = id
	mob_dic[id] = mob_ins
	id += 1

func del_mob(mob_id):
	mob_dic.erase(mob_id)
	draw_astar_map()

func get_nearest_mob(search_position):
	if mob_dic.is_empty():
		return null
	return mob_dic[mob_map.get_closest_point(search_position)]
func get_strongest_mob():
	if mob_dic.is_empty():
		return null
	var maxmob =mob_dic[mob_dic.keys()[0]]
	for mob in mob_dic:
		if mob_dic[mob].hp > maxmob.hp:
			maxmob = mob_dic[mob]
	return maxmob
func clear():
	for child in spawnmanager_node.get_children():
		child.queue_free()
	mob_map = AStar2D.new()
	id = 0
	mob_dic = {}
