extends Sprite2D
func _ready() -> void:
	pass
func _physics_process(delta: float) -> void:
	position += Vector2(10,0)
	$Line2D.add_point(global_position)
	$Line2D.remove_point(0)
