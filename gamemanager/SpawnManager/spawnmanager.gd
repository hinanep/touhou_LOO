extends Node2D

var event_list = {}

var spawner_pre 

var spawnmanager_node

func add_spawn_event(spawner_init):
	var new_spawner = spawner_pre.instantiate()
	spawnmanager_node.add_child(new_spawner)
	new_spawner.spawner_init(spawner_init)
	
	#player_var.player_node.get_parent().get_node("SpawnManager").add_child(new_spawner)
	pass

func prepare_all_spawn_event(spawnmanager,eventlist):
	spawner_pre = PresetManager.getpre("enemy_spawner")
	spawnmanager_node = spawnmanager
	event_list = eventlist

	for event in event_list:
		add_spawn_event(event_list[event])

func event_list_init():
	pass
