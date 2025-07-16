extends drop



func _ready():
	experience = randi_range(1,3)
	score = experience
	mana = experience
	$AnimatedSprite2D.scale = Vector2(experience/20.0,experience/20.0)
	SignalBus.fly_to_player.connect(fly_to_player)

	$".".visible = true
	set_physics_process(false)
