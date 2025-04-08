extends drop


func _ready():
	experience = 100
	score = 10000
	not_fusioning = false
	set_physics_process(false)
func _on_body_entered(_body):
	game_manager.add_exp(experience)


	if not player_var.CpManager.random_choose_cp():
		for j in 3:
			rand_upgrade()

	var color = randi_range(1,3)
	match color:
		#red
		1:
			SignalBus.fly_to_player.emit(2,1,1,false)
			#get_tree().call_group("drop","fly_to_player",2,1,1)
			game_manager.add_exp(player_var.exp_need)
		#green
		2:
			SignalBus.fly_to_player.emit(1,2,1,false)
			#get_tree().call_group("drop","fly_to_player",1,2,1)
			SignalBus.plate_use_card.emit()
		#blue
		3:
			SignalBus.fly_to_player.emit(1,1,2,true)
			#get_tree().call_group("drop","fly_to_player",1,1,2,true)
	queue_free()

func rand_upgrade():
	var selected = RandomPool.random_nselect_from_have(1)
	if selected.is_empty():
		print('no upgradeable')
		return
	for id in selected:
		match selected[id]:
			'skill':
				SignalBus.try_add_skill.emit(id)
			'card':
				SignalBus.try_add_card.emit(id)
			'passive':
				SignalBus.try_add_passive.emit(id)
