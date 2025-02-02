extends drops_base

func _init() -> void:
	experience = randi_range(1,3)
	score = 1


func _ready():
	$AnimatedSprite2D.scale = Vector2(experience/20.0,experience/20.0)
	await get_tree().create_timer(0.1).timeout
	$".".visible = true
