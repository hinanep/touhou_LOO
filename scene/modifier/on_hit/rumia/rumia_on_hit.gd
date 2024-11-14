extends Node2D

func _ready():
	$"../..".on_hit.connect(hit)

func hit():
	var bh=PresetManager.getpre("bullet_rumia_blackhole").instantiate()
	
	bh.global_transform= global_transform
	if player_var.player_node!=null:
		player_var.player_node.call_deferred("add_child",bh)

	pass
