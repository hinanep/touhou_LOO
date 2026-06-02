extends Node2D
@export var boats: Array[enemy_base] = []
signal link_line
func _ready() -> void:
	for child in get_children():
		if child is enemy_base :
			boats.push_back(child)
	active()

func active() -> void:
	for boat in boats:
		if boat:
			var tween: Tween = boat.create_tween()
			RunSession.underrecycle_tween.append(tween)
			tween.tween_property(boat,'position',boat.position + Vector2(-800,800),0.5)
			await get_tree().create_timer(0.1,false).timeout
	await get_tree().create_timer(1.0,false).timeout
	link_line.emit()
