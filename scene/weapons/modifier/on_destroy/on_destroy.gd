extends Node2D

func _ready():
	$"../..".on_destroy.connect(destroy)

func destroy():

	print("bullet_destroy")
	var bomb = load("res://scene/weapons/bullets/tamatsukuri_bullet/bomb.tscn").instantiate()
	bomb.global_transform= global_transform

	player_var.player_node.call_deferred("add_child",bomb)

	pass
