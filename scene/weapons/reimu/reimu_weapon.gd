extends ranged_weapon_base


var target 
# Called when the node enters the scene tree for the first time.
func _ready():

	print("reimu_ready")



	cp_list = {
	"reima":{
	"on_hit":["res://scene/weapons/modifier/on_hit/on_hit.tscn"],
	"on_flying":[],
	"on_emit":[]
	}
}


	super._ready()
	pass # Replace with function body.


func cp_active(x_name):
	super.cp_active(x_name)
