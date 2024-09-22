
class_name card extends Node2D

var level = 1
var maxlevel = 8
var damage_type = 1
var mana_cost = 40
var duration_time = 6
var invincible_time = 6
var locking_type = 0
var locking_target = null
	
func _ready():
	if player_var.power < mana_cost or player_var.is_card_casting:
		print("cant cast card")
		queue_free()
	else:
		player_var.power -= mana_cost
		$endtime.wait_time = duration_time
		$endtime.start()
		$invincible_time.wait_time = invincible_time
		$invincible_time.start()
		player_var.is_invincible = true
		player_var.is_card_casting = true
		card_init()
	
func card_init():
	print("card init")
	
func card_upgrade():
	level += 1
	if(level == maxlevel):
		#从随机池移除
		#查询可能出现的羁绊并加入羁绊池
		pass
	

func _on_invincible_time_timeout():
	player_var.is_invincible = false
	



func _on_endtime_timeout():
	player_var.is_card_casting = false
	queue_free()
