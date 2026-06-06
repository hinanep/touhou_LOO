extends Node2D
func _ready() -> void:
	var tween: Tween = $Passive.create_tween().set_speed_scale(2)
	RunSession.underrecycle_tween.append(tween)
	tween.set_loops()
	tween.tween_property($Passive,'offset',Vector2.ZERO,0.5)
	tween.tween_property($Passive,'offset',Vector2(0,-800),0.5)
	tween = null
