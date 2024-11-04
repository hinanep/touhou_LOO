
extends Node2D

func _ready():
	$"../..".on_hit.connect(hit)

func hit():
	var laser=load("res://scene/weapons/bullets/laser_bullet/laser.tscn").instantiate()
	

	laser.global_transform= global_transform

	player_var.player_node.call_deferred("add_child",laser)

	pass
