extends Node2D


func _ready() -> void:
	SignalBus.cp_active.connect(on_add_cp)


func on_add_cp(cp_info: Dictionary) -> void:
	var path: String = 'cp'
	var cppre_packed: PackedScene = PresetManager.getpre(path)
	var cppre: Node = cppre_packed.instantiate()
	cppre.cp_info = cp_info
	add_child(cppre)
	cppre.position = Vector2(0, 0)
