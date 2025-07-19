extends Node2D
@export var boats = []
signal link_line
func _ready() -> void:
	for child in get_children():
		if child is enemy_base :
			boats.push_back(child)
	active()

func active():
	for boat in boats:
		if boat:
			var tween:Tween = boat.create_tween()
			tween.tween_property(boat,'position',boat.position + Vector2(-800,800),0.5)
			await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(1.0).timeout
	link_line.emit()
