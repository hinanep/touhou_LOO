extends Node2D
var path_follow_2d

var spawnTimer
var startTimer
var endTimer
var mob_pre
var SpawnManager
var mob_info
var spawn_list = {
	"enemy_type":"",
	"spawn_type":"once",
	"start_time":0,
	"end_time":0,
	"tick_time":1,
	"amount_parameter":1,
	'enemy_attribute_boost':1,
	'enemy_barrage_boost':1
}
func spawner_init(spawner_initlist,parent):
	SpawnManager = parent
	spawn_list=spawner_initlist
	spawnTimer = $spawnTimer
	startTimer = $startTimer
	endTimer   = $endTimer
	path_follow_2d = player_var.player_node.get_node("monster_spawn_line").get_node("PathFollow2D")
	spawnTimer.wait_time = maxf(spawn_list["tick_time"],0.1)
	match spawn_list["spawn_type"]:
		"zako":
			startTimer.wait_time =  maxf(spawn_list["start_time"] - player_var.time_secs,0.1)
			startTimer.start()

			endTimer.wait_time = spawn_list["end_time"] - player_var.time_secs
			endTimer.start()
		"elite":
			startTimer.wait_time =   maxf(spawn_list["start_time"] - player_var.time_secs,0.1)
			startTimer.start()
			spawnTimer.set_one_shot(true)
			endTimer.wait_time = startTimer.wait_time + 1
			endTimer.start()
	mob_pre = PresetManager.getpre(spawn_list["enemy_type"])
	mob_info = table.Enemy[spawn_list["enemy_type"]]
	path_follow_2d = player_var.player_node.get_node("monster_spawn_line").get_node("PathFollow2D")

func _ready() -> void:
	SignalBus.pause_spawner.connect(change_pause)
func spawn_mob():

	if path_follow_2d!=null:
		path_follow_2d.progress_ratio = randf()
	var mob = mob_pre.instantiate()
	mob.global_position = path_follow_2d.global_position
	mob.mob_info = mob_info.duplicate()
	mob.multi = (spawn_list['enemy_attribute_boost'])
	if spawn_list["spawn_type"] == 'elite':
		mob.drops_path = "drops_plate"
		mob.set_scale(Vector2(4,4))

	mob.drop_num = 1.0

	SpawnManager.add_mob(mob)



func _on_timer_timeout():
	if SpawnManager.mob_dic.size()>1:
		if spawn_list["spawn_type"] == 'zako':
			return
	for i in range(spawn_list["amount_parameter"]):
		spawn_mob()


func _on_start_timer_timeout():
	spawnTimer.start()



func _on_end_timer_timeout():
	spawnTimer.stop()
	queue_free()

func change_pause(is_pause):


	spawnTimer.set_paused(is_pause)
