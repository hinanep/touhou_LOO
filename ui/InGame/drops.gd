extends Node2D
func _ready() -> void:
	SignalBus.drop.connect(new_drop)

func new_drop(id,in_global_position):
	var drops = PresetManager.getpre(id).instantiate()

	drops.global_position =in_global_position
	call_deferred("add_child",drops)
