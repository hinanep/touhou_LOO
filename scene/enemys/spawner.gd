extends Node2D
var path_follow_2d

var spawnTimer 
var startTimer 
var endTimer
var spawn_list = {
	"pre":"",
	"spawn_mode":"once",
	"start_time":0,
	"end_time":0,
	"tick_time":1,
	"number":1,
	"param_buff":1
}
func spawner_init(spawner_initlist):
	spawn_list=spawner_initlist
	spawnTimer = $spawnTimer
	startTimer = $startTimer
	endTimer   = $endTimer
	path_follow_2d = player_var.player_node.get_node("monster_spawn_line").get_node("PathFollow2D")
	spawnTimer.wait_time = maxf(spawn_list["tick_time"],0.1)
	match spawn_list["spawn_mode"]:
		"duration":
			startTimer.wait_time =  maxf(spawn_list["start_time"] - player_var.time_secs,0.1)
			startTimer.start()
			
			endTimer.wait_time = spawn_list["end_time"] - player_var.time_secs
			endTimer.start()
		"once":
			startTimer.wait_time =   maxf(spawn_list["start_time"] - player_var.time_secs,0.1)
			startTimer.start()
			spawnTimer.set_one_shot(true)


func spawn_mob():
	path_follow_2d = player_var.player_node.get_node("monster_spawn_line").get_node("PathFollow2D")
	var mob = spawn_list["pre"].instantiate()
	path_follow_2d.progress_ratio = randf()
	mob.global_position = path_follow_2d.global_position
	mob.setbuff(spawn_list["param_buff"])
	$".".add_child(mob)



func _on_timer_timeout():
	for i in range(spawn_list["number"]):
		spawn_mob()


func _on_start_timer_timeout():
	spawnTimer.start()
	pass # Replace with function body.


func _on_end_timer_timeout():
	spawnTimer.stop()
	pass # Replace with function body.
func change_pause():
	
	if spawnTimer.is_paused() == true:
		spawnTimer.set_paused(false)
	else:
		spawnTimer.set_paused(true)
