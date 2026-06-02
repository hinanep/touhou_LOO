extends Node2D
func _ready() -> void:
	SignalBus.drop.connect(new_drop)

func new_drop(id: String, in_global_position: Vector2, value: float) -> void:
	var drops: Node2D = PresetManager.getpre(id).instantiate()

	drops.global_position =in_global_position
	drops.value = value
	call_deferred("add_child",drops)
