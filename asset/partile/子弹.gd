extends Sprite2D
var velo = Vector2(10,0)
var state = 1
func _physics_process(delta: float) -> void:

	global_position+=velo

	velo+=Vector2(0,10)*delta*state
	if velo.y > 10:
		state = -1

	$Line2D.add_point(global_position)

	if $Line2D.get_point_count() > 10:
		$Line2D.remove_point(0)
