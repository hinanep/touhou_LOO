
extends Node2D

func _ready():
	$"../..".on_hit.connect(hit)

func hit():
	var laser=PresetManager.getpre("bullet_laser").instantiate()
	

	laser.global_transform= global_transform
	if player_var.player_node!=null:
		player_var.player_node.call_deferred("add_child",laser)

	pass
