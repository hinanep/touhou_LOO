
class_name card extends Node2D

var level = 1
var maxlevel = 8
var damage_type = 1
var mana_cost = 44
var duration_time = 6
var invincible_time = 6
var locking_type = 0
var locking_target = null
var card_name = ""
func _ready():
	add_to_group(card_name)


func active():
	$endtime.wait_time = duration_time
	$endtime.start()
	$invincible_time.wait_time = invincible_time
	$invincible_time.start()
	player_var.is_invincible = true
	player_var.is_card_casting = true
	pass
	
func card_init(card_dic):
	level = card_dic["level"]
	print("card init")
	
func upgrade_card():
	#CardManager.card_pool["choosed"][card_name]["power_cost"] -= 4
	pass
func _on_invincible_time_timeout():
	player_var.is_invincible = false
	



func _on_endtime_timeout():
	player_var.is_card_casting = false


