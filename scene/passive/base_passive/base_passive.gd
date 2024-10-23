
class_name buff extends Node2D
@onready var endTimer = $endTimer
var buff_strongth = 1.5
var effect_var_name = ""
var buff_name = ""
var buff_level = 0
func buff_init():
	
	player_var.set(effect_var_name,effect_var_name*buff_strongth)
	pass
func upgrade_buff():
	buff_level += 1
	pass

func _ready():
	add_to_group(buff_name)
