extends Node2D
func _ready() -> void:
	SignalBus.drop.connect(new_drop)

func new_drop(id,in_global_position,value):
	var drops = PresetManager.getpre(id).instantiate()

	drops.global_position =in_global_position
	drops.value = value
	call_deferred("add_child",drops)
