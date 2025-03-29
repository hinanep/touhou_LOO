extends drop



func _ready():
	experience = randi_range(1,3)*value
	score = 1
	mana = 1
	$AnimatedSprite2D.scale = Vector2(experience/20.0,experience/20.0)
	await get_tree().create_timer(0.1).timeout
	$".".visible = true
	set_physics_process(false)
