extends Node
var is_uping = false
func _ready():

	pass

func add_exp(value):

	player_var.player_exp += value
	AudioManager.play_sfx("music_sfx_pickup")
	if is_uping!=true and player_var.player_exp >= player_var.exp_need[player_var.level]:
		is_uping = true
		level_up()



func add_score(value):

	player_var.point += value * player_var.point_ratio
func add_mana(mana):

	player_var.mana += mana
	if(player_var.mana > player_var.mana_max):
		player_var.mana = player_var.mana_max
	if(player_var.mana < 0):
		player_var.mana = 0


func level_up():

	AudioManager.play_sfx("music_sfx_levelup")
	player_var.player_exp -= player_var.exp_need[player_var.level]
	player_var.level += 1
	G.get_gui_view_manager().open_view("LevelUp")
