extends Node2D

var event_list = {
	"slime":{
	"pre":preload("res://scene/enemys/slime/slime.tscn"),
	"spawn_mode":"duration",
	"start_time":0,
	"end_time":300,
	"tick_time":2,
	"number":2,
	"param_buff":0.9
},
"bat_blue":{
	"pre":preload("res://scene/enemys/bat_blue/bat_blue.tscn"),
	"spawn_mode":"duration",
	"start_time":0,
	"end_time":300,
	"tick_time":2,
	"number":2,
	"param_buff":0.9
},
"bat_purple":{
	"pre":preload("res://scene/enemys/bat_purple/bat_purple.tscn"),
	"spawn_mode":"duration",
	"start_time":0,
	"end_time":300,
	"tick_time":2,
	"number":2,
	"param_buff":0.9
},
"bug_orange":{
	"pre":preload("res://scene/enemys/bug_orange/bug_orange.tscn"),
	"spawn_mode":"duration",
	"start_time":0,
	"end_time":300,
	"tick_time":2,
	"number":2,
	"param_buff":0.9
},
"bug_pink":{
	"pre":preload("res://scene/enemys/bug_pink/bug_pink.tscn"),
	"spawn_mode":"duration",
	"start_time":0,
	"end_time":300,
	"tick_time":2,
	"number":2,
	"param_buff":0.9
},
"slime_blue":{
	"pre":preload("res://scene/enemys/slime_blue/slime_blue.tscn"),
	"spawn_mode":"duration",
	"start_time":0,
	"end_time":300,
	"tick_time":2,
	"number":2,
	"param_buff":0.9
},
"slime_green":{
	"pre":preload("res://scene/enemys/slime_green/slime_green.tscn"),
	"spawn_mode":"duration",
	"start_time":0,
	"end_time":300,
	"tick_time":2,
	"number":2,
	"param_buff":0.9
},
"kedama":{
	"pre":preload("res://scene/enemys/kedama/kedama.tscn"),
	"spawn_mode":"duration",
	"start_time":0,
	"end_time":300,
	"tick_time":2,
	"number":2,
	"param_buff":0.9
},
"ghost":{
	"pre":preload("res://scene/enemys/ghost/ghost.tscn"),
	"spawn_mode":"duration",
	"start_time":0,
	"end_time":300,
	"tick_time":2,
	"number":2,
	"param_buff":0.9
},
"elite_slime":{
	"pre":preload("res://scene/enemys/elite_slime/elite_slime.tscn"),
	"spawn_mode":"duration",
	"start_time":5,
	"end_time":300,
	"tick_time":10,
	"number":1,
	"param_buff":10
},
"aq":{
	"pre":preload("res://scene/enemys/aq_boss/aq_boss.tscn"),
	"spawn_mode":"once",
	"start_time":5,
	"end_time":300,
	"tick_time":1,
	"number":1,
	"param_buff":1
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
