extends Node2D
@onready var path_follow_2d = $"../player/Path2D/PathFollow2D"

@onready var timer = $Timer



func spawn_mob(path):
	var SLIME = load(path).instantiate()
	path_follow_2d.progress_ratio = randf()
	SLIME.global_position = path_follow_2d.global_position
	$".".add_child(SLIME)

func _ready():
	spawn_mob("res://scene/enemys/slime/slime.tscn")


func _on_timer_timeout():
	spawn_mob("res://scene/enemys/slime/slime.tscn")
	spawn_mob("res://scene/enemys/slime/slime.tscn")
	spawn_mob("res://scene/enemys/slime/slime.tscn")
	spawn_mob("res://scene/enemys/slime/slime.tscn")
	pass
