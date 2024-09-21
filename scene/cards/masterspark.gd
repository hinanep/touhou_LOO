extends Node2D
var power_consume = 40
var endtime = 5

func _ready():
	if player_var.power >= power_consume:
		init()
		
	else:
		print("low mana")
		queue_free()
	pass
func _process(delta):
	pass

func init():
	print("card init")
	player_var.power -= power_consume
	$endtime.wait_time = endtime
	$endtime.start()
	AudioManager.play_sfx("sfx_masterspark")
	player_var.is_invincible = true

func _on_endtime_timeout():
	print("card timeout")
	player_var.is_invincible = false
	queue_free()
	pass # Replace with function body.
