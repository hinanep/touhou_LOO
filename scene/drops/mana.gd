extends drop




func _ready():
	$AnimatedSprite2D.scale = Vector2(value/20.0,value/20.0)
	mana = value
	experience = 0
	score = 0
	set_physics_process(false)
	await get_tree().create_timer(0.1).timeout
	$".".visible = true
