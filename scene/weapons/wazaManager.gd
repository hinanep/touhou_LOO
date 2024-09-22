extends Node


#"res://scene/weapons/weapon_base/ranged_base/ranged_weapon_base.tscn"
@export var waza_name_path_pair = {
	"base":"res://scene/weapons/beginning_weapon/beginning_ranged_attack/beginning_ranged_attack.tscn",
	"reimu" : "res://scene/weapons/reimu/reimu_weapon.tscn",
	"sanae": "res://scene/weapons/sanae/sanae_weapon.tscn",
	"alice": "res://scene/weapons/alice_weapon/alice_weapon.tscn"
}
func _ready():
	#var weapon_path = "res://scene/weapons/reimu/reimu_weapon.tscn"
	
	#addWeapon(weapon_path)

	pass # Replace with function body.




func addWeapon(name):
	var path = waza_name_path_pair[name]
	var weapon = load(path)
	weapon = weapon.instantiate()
	
	player_var.player_node.get_node("WazaManager").add_child(weapon)
	weapon.position = Vector2(0,0)

	
func updateWeapon():
	pass
