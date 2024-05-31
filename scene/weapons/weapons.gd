extends Node

@onready var player = $".."
#"res://scene/weapons/weapon_base/ranged_base/ranged_weapon_base.tscn"
func _ready():
	var weapon_path = "res://scene/weapons/reimu/reimu_weapon.tscn"
	
	addWeapon(weapon_path)
	addWeapon("res://scene/weapons/beginning_weapon/beginning_ranged_attack/beginning_ranged_attack.tscn")
	pass # Replace with function body.


func _process(delta):
	#print(player.global_position)
	pass

func addWeapon(path):
	var weapon = load(path)
	weapon = weapon.instantiate()
	weapon.global_position = player.global_position
	
	$".".add_child(weapon)
	
func updateWeapon():
	pass
