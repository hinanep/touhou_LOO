extends drop



func _ready():
	experience = 0
	score = 1
	mana = 0
	SignalBus.fly_to_player.connect(fly_to_player)

	$".".visible = true

func fly_to_player(exp_buff = 1.0,mana_buff = 1.0,score_buff = 1.0,point_ratio_buff = false):
	experience *= exp_buff
	mana *= mana_buff
	score *= score_buff
	if point_ratio_buff:
		point_ratio = point_ratio_buff
