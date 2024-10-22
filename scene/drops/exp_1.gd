extends drops_base


func _ready():
	experience = randi_range(1,3)
	score = 1

	$AnimatedSprite2D.scale = Vector2(experience/20.0,experience/20.0)

