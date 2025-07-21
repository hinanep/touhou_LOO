extends drop



func _ready():
	experience = 0
	score = 1
	mana = 0
	SignalBus.fly_to_player.connect(fly_to_player)

	$".".visible = true
