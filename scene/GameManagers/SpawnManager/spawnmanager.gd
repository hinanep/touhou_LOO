extends Node2D

var event_list = {
#第一波：绿色史莱姆 0~15s
"slime_green_1":{
	"pre":preload("res://scene/enemys/slime_green/slime_green.tscn"),
	"spawn_mode":"duration",
	"start_time":0,
	"end_time":15,
	"tick_time":2,
	"number":10,
	"param_buff":0.75
},

#第二波:蓝色蝙蝠 15~30s
"bat_blue_1":{
	"pre":preload("res://scene/enemys/bat_blue/bat_blue.tscn"),
	"spawn_mode":"duration",
	"start_time":15,
	"end_time":30,
	"tick_time":2,
	"number":10,
	"param_buff":1
},

#精英：精英史莱姆 30s
"elite_slime_1":{
	"pre":preload("res://scene/enemys/elite_slime/elite_slime.tscn"),
	"spawn_mode":"once",
	"start_time":30,
	"end_time":30,
	"tick_time":1,
	"number":1,
	"param_buff":10
},

#第三波：橙色虫虫 30~45s
"bug_orange_1":{
	"pre":preload("res://scene/enemys/bug_orange/bug_orange.tscn"),
	"spawn_mode":"duration",
	"start_time":30,
	"end_time":45,
	"tick_time":2,
	"number":15,
	"param_buff":1.25
},

#第四波：毛玉 45~60s
"kedama_1":{
	"pre":preload("res://scene/enemys/kedama/kedama.tscn"),
	"spawn_mode":"duration",
	"start_time":45,
	"end_time":60,
	"tick_time":2,
	"number":15,
	"param_buff":1.5
},

#精英：精英史莱姆 60s
"elite_slime_2":{
	"pre":preload("res://scene/enemys/elite_slime/elite_slime.tscn"),
	"spawn_mode":"once",
	"start_time":60,
	"end_time":60,
	"tick_time":1,
	"number":1,
	"param_buff":15
},

#第五波：蓝色史莱姆 60~75s
"slime_blue_1":{
	"pre":preload("res://scene/enemys/slime_blue/slime_blue.tscn"),
	"spawn_mode":"duration",
	"start_time":60,
	"end_time":75,
	"tick_time":2,
	"number":20,
	"param_buff":1.75
},

#第六波：紫色蝙蝠 75~90s
"bat_purple_1":{
	"pre":preload("res://scene/enemys/bat_purple/bat_purple.tscn"),
	"spawn_mode":"duration",
	"start_time":75,
	"end_time":90,
	"tick_time":2,
	"number":20,
	"param_buff":2
},

#精英：精英史莱姆 90s
"elite_slime_3":{
	"pre":preload("res://scene/enemys/elite_slime/elite_slime.tscn"),
	"spawn_mode":"once",
	"start_time":90,
	"end_time":90,
	"tick_time":1,
	"number":1,
	"param_buff":20
},

#第七波：粉色虫虫 90~105s
"bug_pink_1":{
	"pre":preload("res://scene/enemys/bug_pink/bug_pink.tscn"),
	"spawn_mode":"duration",
	"start_time":90,
	"end_time":105,
	"tick_time":2,
	"number":25,
	"param_buff":2
},

#第八波：鬼火 105~120s
"ghost_1":{
	"pre":preload("res://scene/enemys/ghost/ghost.tscn"),
	"spawn_mode":"duration",
	"start_time":105,
	"end_time":120,
	"tick_time":2,
	"number":25,
	"param_buff":2
},

#精英：精英史莱姆 120s
"elite_slime_4":{
	"pre":preload("res://scene/enemys/elite_slime/elite_slime.tscn"),
	"spawn_mode":"once",
	"start_time":120,
	"end_time":120,
	"tick_time":1,
	"number":2,
	"param_buff":15
},

#第九波：绿色史莱姆和蓝色蝙蝠 120s~135s
"slime_green_2":{
	"pre":preload("res://scene/enemys/slime_green/slime_green.tscn"),
	"spawn_mode":"duration",
	"start_time":120,
	"end_time":135,
	"tick_time":2,
	"number":15,
	"param_buff":2
},
"bat_blue_2":{
	"pre":preload("res://scene/enemys/bat_blue/bat_blue.tscn"),
	"spawn_mode":"duration",
	"start_time":120,
	"end_time":135,
	"tick_time":2,
	"number":15,
	"param_buff":2
},

#第十波：橙色虫虫和蓝色史莱姆 135~150s
"bug_orange_2":{
	"pre":preload("res://scene/enemys/bug_orange/bug_orange.tscn"),
	"spawn_mode":"duration",
	"start_time":135,
	"end_time":150,
	"tick_time":2,
	"number":20,
	"param_buff":2
},
"slime_blue_2":{
	"pre":preload("res://scene/enemys/slime_blue/slime_blue.tscn"),
	"spawn_mode":"duration",
	"start_time":135,
	"end_time":150,
	"tick_time":2,
	"number":20,
	"param_buff":2
},

#精英：精英史莱姆 150s
"elite_slime_5":{
	"pre":preload("res://scene/enemys/elite_slime/elite_slime.tscn"),
	"spawn_mode":"once",
	"start_time":30,
	"end_time":150,
	"tick_time":1,
	"number":3,
	"param_buff":15
},

#第十一波：紫色蝙蝠和粉色虫虫 150~165s
"bat_purple_2":{
	"pre":preload("res://scene/enemys/bat_purple/bat_purple.tscn"),
	"spawn_mode":"duration",
	"start_time":150,
	"end_time":165,
	"tick_time":2,
	"number":25,
	"param_buff":2
},
"bug_pink_2":{
	"pre":preload("res://scene/enemys/bug_pink/bug_pink.tscn"),
	"spawn_mode":"duration",
	"start_time":150,
	"end_time":165,
	"tick_time":2,
	"number":25,
	"param_buff":2
},

#第十二波：毛玉和鬼火 165s~180s
"kedama_2":{
	"pre":preload("res://scene/enemys/kedama/kedama.tscn"),
	"spawn_mode":"duration",
	"start_time":165,
	"end_time":180,
	"tick_time":2,
	"number":30,
	"param_buff":2
},
"ghost_2":{
	"pre":preload("res://scene/enemys/ghost/ghost.tscn"),
	"spawn_mode":"duration",
	"start_time":165,
	"end_time":180,
	"tick_time":2,
	"number":30,
	"param_buff":2
},

#BOSS：阿求 180s
"aq":{
	"pre":preload("res://scene/enemys/aq_boss/aq_boss.tscn"),
	"spawn_mode":"once",
	"start_time":180,
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
