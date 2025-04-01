extends drop


func _ready():
	experience = 100
	score = 10000
	set_physics_process(false)
func _on_body_entered(_body):
	game_manager.add_exp(experience)

	for i in range(3):
		if player_var.CpManager.random_choose_cp():
			continue
		else:
			#random upgrade waza/card/passive
			pass
	var color = randi_range(1,3)
	match color:
		#red
		1:
			get_tree().call_group("drop","fly_to_player",2,1,1)
			game_manager.add_exp(player_var.exp_need)
		#green
		2:
			get_tree().call_group("drop","fly_to_player",1,2,1)
			SignalBus.plate_use_card.emit()
		#blue
		3:
			get_tree().call_group("drop","fly_to_player",1,1,2,true)
	queue_free()
