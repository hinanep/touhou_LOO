extends drop



func _ready() -> void:
	experience = 0
	score = 1
	mana = 0
	SignalBus.fly_to_player.connect(fly_to_player)

	$".".visible = true

func fly_to_player(exp_buff: float = 1.0, mana_buff: float = 1.0, score_buff: float = 1.0, point_ratio_buff: bool = false) -> void:
	experience *= exp_buff
	mana *= mana_buff
	score *= score_buff
	if point_ratio_buff:
		point_ratio = point_ratio_buff
