extends Node2D

func _ready():
	$"../..".on_hit.connect(hit)

func hit():
	print("hit!")
	print("---")
	pass
