extends BaseGUIView
func _ready():
	G.get_gui_view_manager().open_view("Hud")
	AudioManager.play_background_bgm("music_bgm_oldworld")
	scene_init()

var pauseing = false
var pause_id


func _input(event):
	if event.is_action_pressed("pause"):
		if !pauseing:
			pause_id = G.get_gui_view_manager().open_view("PauseMenu")
		else:
			G.get_gui_view_manager().close_view(pause_id)
		pauseing = !pauseing
	if event.is_action_pressed("clockup"):
		if Engine.time_scale <1.5:
			Engine.time_scale = 2.0
		else:
			Engine.time_scale = 1.0
func _open():
	GameManager.upping = false
	pass


func _close():
	AudioManager.stop_background_bgm()

	pass
func _process(delta):
	print_orphan_nodes()

func open():
	_open()


func close():
	_close()


func close_self():
	G.get_gui_view_manager().close_view(viewInstanceId)

func scene_init():
	SkillManager.add_skill("ski_basemagic")
	SkillManager.add_skill("ski_basephysics")
	CardManager.add_card("fairy")
	var event_list = {
#第一波：绿色史莱姆 0~15s
"slime_green_1":{
	"pre":PresetManager.getpre("enemy_zako_slime_green"),
	"spawn_mode":"duration",
	"start_time":0,
	"end_time":15,
	"tick_time":2,
	"number":10,
	"param_buff":0.75
},

#第二波:蓝色蝙蝠 15~30s
"bat_blue_1":{
	"pre":PresetManager.getpre("enemy_zako_bat_blue"),
	"spawn_mode":"duration",
	"start_time":15,
	"end_time":30,
	"tick_time":2,
	"number":10,
	"param_buff":1
},

#精英：精英史莱姆 30s
"elite_slime_1":{
	"pre":PresetManager.getpre("enemy_elite_slime"),
	"spawn_mode":"once",
	"start_time":30,
	"end_time":30,
	"tick_time":1,
	"number":1,
	"param_buff":1
},

#第三波：橙色虫虫 30~45s
"bug_orange_1":{
	"pre":PresetManager.getpre("enemy_zako_bug_orange"),
	"spawn_mode":"duration",
	"start_time":30,
	"end_time":45,
	"tick_time":2,
	"number":15,
	"param_buff":1.25
},

#第四波：毛玉 45~60s
"kedama_1":{
	"pre":PresetManager.getpre("enemy_zako_kedama"),
	"spawn_mode":"duration",
	"start_time":45,
	"end_time":60,
	"tick_time":2,
	"number":15,
	"param_buff":1.5
},

#精英：精英史莱姆 60s
"elite_slime_2":{
	"pre":PresetManager.getpre("enemy_elite_slime"),
	"spawn_mode":"once",
	"start_time":60,
	"end_time":60,
	"tick_time":1,
	"number":1,
	"param_buff":1.5
},

#第五波：蓝色史莱姆 60~75s
"slime_blue_1":{
	"pre":PresetManager.getpre("enemy_zako_slime_blue"),
	"spawn_mode":"duration",
	"start_time":60,
	"end_time":75,
	"tick_time":2,
	"number":20,
	"param_buff":1.75
},

#第六波：紫色蝙蝠 75~90s
"bat_purple_1":{
	"pre":PresetManager.getpre("enemy_zako_bat_purple"),
	"spawn_mode":"duration",
	"start_time":75,
	"end_time":90,
	"tick_time":2,
	"number":20,
	"param_buff":2
},

#精英：精英史莱姆 90s
"elite_slime_3":{
	"pre":PresetManager.getpre("enemy_elite_slime"),
	"spawn_mode":"once",
	"start_time":90,
	"end_time":90,
	"tick_time":1,
	"number":1,
	"param_buff":2
},

#第七波：粉色虫虫 90~105s
"bug_pink_1":{
	"pre":PresetManager.getpre("enemy_zako_bug_pink"),
	"spawn_mode":"duration",
	"start_time":90,
	"end_time":105,
	"tick_time":2,
	"number":25,
	"param_buff":2
},

#第八波：鬼火 105~120s
"ghost_1":{
	"pre":PresetManager.getpre("enemy_zako_ghost"),
	"spawn_mode":"duration",
	"start_time":105,
	"end_time":120,
	"tick_time":2,
	"number":25,
	"param_buff":2
},

#精英：精英史莱姆 120s
"elite_slime_4":{
	"pre":PresetManager.getpre("enemy_elite_slime"),
	"spawn_mode":"once",
	"start_time":120,
	"end_time":120,
	"tick_time":1,
	"number":2,
	"param_buff":2
},

#第九波：绿色史莱姆和蓝色蝙蝠 120s~135s
"slime_green_2":{
	"pre":PresetManager.getpre("enemy_zako_slime_green"),
	"spawn_mode":"duration",
	"start_time":120,
	"end_time":135,
	"tick_time":2,
	"number":15,
	"param_buff":2
},
"bat_blue_2":{
	"pre":PresetManager.getpre("enemy_zako_bat_blue"),
	"spawn_mode":"duration",
	"start_time":120,
	"end_time":135,
	"tick_time":2,
	"number":15,
	"param_buff":2
},

#第十波：橙色虫虫和蓝色史莱姆 135~150s
"bug_orange_2":{
	"pre":PresetManager.getpre("enemy_zako_bug_orange"),
	"spawn_mode":"duration",
	"start_time":135,
	"end_time":150,
	"tick_time":2,
	"number":20,
	"param_buff":2
},
"slime_blue_2":{
	"pre":PresetManager.getpre("enemy_zako_slime_blue"),
	"spawn_mode":"duration",
	"start_time":135,
	"end_time":150,
	"tick_time":2,
	"number":20,
	"param_buff":2
},

#精英：精英史莱姆 150s
"elite_slime_5":{
	"pre":PresetManager.getpre("enemy_elite_slime"),
	"spawn_mode":"once",
	"start_time":150,
	"end_time":150,
	"tick_time":1,
	"number":3,
	"param_buff":2
},

#第十一波：紫色蝙蝠和粉色虫虫 150~165s
"bat_purple_2":{
	"pre":PresetManager.getpre("enemy_zako_bat_purple"),
	"spawn_mode":"duration",
	"start_time":150,
	"end_time":165,
	"tick_time":2,
	"number":25,
	"param_buff":2
},
"bug_pink_2":{
	"pre":PresetManager.getpre("enemy_zako_bug_pink"),
	"spawn_mode":"duration",
	"start_time":150,
	"end_time":165,
	"tick_time":2,
	"number":25,
	"param_buff":2
},

#第十二波：毛玉和鬼火 165s~180s
"kedama_2":{
	"pre":PresetManager.getpre("enemy_zako_kedama"),
	"spawn_mode":"duration",
	"start_time":165,
	"end_time":180,
	"tick_time":2,
	"number":30,
	"param_buff":1.5
},
"ghost_2":{
	"pre":PresetManager.getpre("enemy_zako_ghost"),
	"spawn_mode":"duration",
	"start_time":165,
	"end_time":180,
	"tick_time":2,
	"number":30,
	"param_buff":1.5
},

#BOSS：阿求 180s
"aq":{
	"pre":PresetManager.getpre("enemy_boss_aq"),
	"spawn_mode":"once",
	"start_time":180,
	"end_time":300,
	"tick_time":1,
	"number":1,
	"param_buff":1
}
}
	SpawnManager.prepare_all_spawn_event($SpawnManager,event_list)

