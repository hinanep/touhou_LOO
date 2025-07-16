extends drop


func _ready():
	#拾起获得经验
	experience = 100

	#禁止飞碟合成/被合成大P点
	not_fusioning = false

	set_physics_process(false)
#@brief: 范围内存在玩家层单位（详见碰撞层）时触发，产生被拾起效果
#@param body 疑似玩家节点
#@return: 无
func _on_body_entered(_body):
	#添加经验
	player_var.player_exp += experience
	#音效
	AudioManager.play_sfx("music_sfx_pickup")
	#随机激活羁绊，若无羁绊激活，则随机升级三次
	if not player_var.CpManager.random_choose_cp():
		for j in 3:
			rand_upgrade()
	#随机颜色飞碟
	var color = randi_range(1,3)
	#不同颜色效果触发
	match color:
		#red
		1:
			SignalBus.fly_to_player.emit(2,1,1,false)

			player_var.player_exp += player_var.exp_need
		#green
		2:
			SignalBus.fly_to_player.emit(1,2,1,false)

			player_var.free_card += 1
		#blue
		3:
			SignalBus.fly_to_player.emit(1,1,2,true)


	queue_free()
#@brief: 随机升级，对已拥有技能、符卡、被动随机选择一个可升级的进行升级
#@param 无
#@return: 无
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
