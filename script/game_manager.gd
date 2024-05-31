extends Node


var Exp = 0
var Score = 0
@onready var exp_pick_sound = $exp_pick_sound
@onready var music = $music
@onready var UiManager = get_tree().get_first_node_in_group("UiManager")

var kill_num = 0

#signal level_up()

func _ready():
	
	pass
func add_exp(value):
	
	exp_pick_sound.play()
	player_var.exp += value
	if(player_var.exp >= player_var.exp_need[player_var.level]):
		level_up()
		
func add_score(value):
	
	player_var.point += value * player_var.point_ratio
func add_power(power):
	
	player_var.power += power
	if(player_var.power > player_var.power_max):
		player_var.power = player_var.power_max
	if(player_var.power < 0):
		player_var.power = 0

#func emit_level_up():
#	level_up.emit()

func level_up():
	player_var.exp -= player_var.exp_need[player_var.level]
	player_var.level += 1
	#todo
	get_tree().paused = true
	UiManager.get_node("select_weapon").visible = true


func _on_audio_stream_player_finished():
	music.play()

