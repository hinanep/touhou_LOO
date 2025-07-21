extends drop



func _ready():
	super._ready()
	experience = randi_range(1,3)
	score = experience
	mana = experience
	$AnimatedSprite2D.scale = Vector2(log(experience+1)/5.0,log(experience+1)/5.0)
	SignalBus.fly_to_player.connect(fly_to_player)

	$".".visible = true
