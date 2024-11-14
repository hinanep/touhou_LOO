extends ranged_weapon_base


# Called when the node enters the scene tree for the first time.

func _ready():
	print("rumia_ready")
	attack_modifier["on_hit"].append("modifier_rumia")

	super._ready()

	pass # Replace with function body.



func upgrade_waza():

	super.upgrade_waza()
	pass
