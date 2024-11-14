extends Node





@onready var UiManager = get_tree().get_first_node_in_group("UiManager")

var upping = false
func _ready():
	
	pass

func add_exp(value):
	
	player_var.player_exp += value
	AudioManager.play_sfx("music_sfx_pickup")

	if(player_var.player_exp >= player_var.exp_need[player_var.level]) and upping == false:
		upping = true
		level_up()

		
func add_score(value):
	
	player_var.point += value * player_var.point_ratio
func add_power(power):
	
	player_var.power += power
	if(player_var.power > player_var.power_max):
		player_var.power = player_var.power_max
	if(player_var.power < 0):
		player_var.power = 0


func level_up():

	AudioManager.play_sfx("music_sfx_levelup")
	player_var.player_exp -= player_var.exp_need[player_var.level]
	player_var.level += 1
	G.get_gui_view_manager().open_view("LevelUp")
	



