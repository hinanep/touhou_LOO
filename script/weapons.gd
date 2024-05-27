extends Node

@onready var player = $".."

func _ready():
	addWeapon("res://scene/basic_attack.tscn")
	pass # Replace with function body.



func _process(delta):
	#print(player.global_position)
	pass

func addWeapon(path):
	var weapon = load(path)
	weapon = weapon.instantiate()
	weapon.position = player.global_position
	$".".add_child(weapon)
	
func updateWeapon():
	pass
