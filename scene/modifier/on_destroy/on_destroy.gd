extends Node2D

func _ready():
	$"../..".on_destroy.connect(destroy)

func destroy():

	print("bullet_destroy")
	var bomb = PresetManager.getpre("bullet_tamatsukuri_bomb").instantiate()
	bomb.global_transform= global_transform

	player_var.player_node.call_deferred("add_child",bomb)

	pass
