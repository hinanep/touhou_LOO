extends drop




func _ready():
	$AnimatedSprite2D.scale = Vector2(value/20.0,value/20.0)
	await get_tree().create_timer(0.1).timeout
	$".".visible = true
	set_physics_process(false)
func _on_body_entered(_body):


	game_manager.add_mana(value)

	queue_free()
