extends buff

func _ready():
	buff_strongth = 1
	effect_var_name = "power_max"
	buff_name = "pachuli"
	buff_level = 0	
	super._ready()

	
	
func upgrade_buff():
	
	#super.upgrade_buff()
	print("pachuli up")
	player_var.set(effect_var_name,player_var.get(effect_var_name)+1000)
	player_var.set("power",player_var.get("power")+1000)
	#player_var.set(effect_var_name,player_var.get(effect_var_name)/buff_strongth)
	#buff_level += 1
	#buff_strongth *= 1.1
	#player_var.set(effect_var_name,player_var.get(effect_var_name)*buff_strongth)
	

func del():
	super.del()
