extends Node2D

var event_list = {
	"slime":{
	"pre":preload("res://scene/enemys/slime/slime.tscn"),
	"spawn_mode":"duration",
	"start_time":0,
	"end_time":300,
	"tick_time":2,
	"number":4,
	"param_buff":0.9
},
"elite_slime":{
	"pre":preload("res://scene/enemys/elite_slime/elite_slime.tscn"),
	"spawn_mode":"once",
	"start_time":15,
	"end_time":60,
	"tick_time":2,
	"number":1,
	"param_buff":10
}
}

var spawner_pre = preload("res://scene/enemys/spawner.tscn")

var spawnmanager_node

func add_spawn_event(spawner_init):
	var new_spawner = spawner_pre.instantiate()
	spawnmanager_node.add_child(new_spawner)
	new_spawner.spawner_init(spawner_init)
	
	#player_var.player_node.get_parent().get_node("SpawnManager").add_child(new_spawner)
	pass

func prepare_all_spawn_event(spawnmanager):
	spawnmanager_node = spawnmanager
	for event in event_list:
		add_spawn_event(event_list[event])
