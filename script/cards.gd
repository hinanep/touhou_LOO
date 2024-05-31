extends Node2D
var power = player_var.power
func _input(event):
	if event.is_action_pressed("use_card"):
		use_card()

func use_card():
	player_var.power -= 40
