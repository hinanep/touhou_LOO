extends Node2D
@onready var path_follow_2d = player_var.player_node.get_node("monster_spawn_line").get_node("PathFollow2D")

@onready var timer = $Timer



func spawn_mob(path):
	print("spawning")
	path_follow_2d = player_var.player_node.get_node("monster_spawn_line").get_node("PathFollow2D")
	var SLIME = load(path).instantiate()
	#$".".get_child()
	path_follow_2d.progress_ratio = randf()
	print(path_follow_2d.progress_ratio)
	print(path_follow_2d.global_position)
	print(player_var.player_node.global_position)
	SLIME.global_position = path_follow_2d.global_position
	$".".add_child(SLIME)

func _ready():
	timer.start()
	print("spawner on")
	pass


func _on_timer_timeout():
	for i in range(4):
		spawn_mob("res://scene/enemys/slime/slime.tscn")

	pass
