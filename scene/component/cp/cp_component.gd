extends Node2D
func _ready() -> void:
	SignalBus.cp_active.connect(on_add_cp)

func on_add_cp(cp_info):
	var path = 'cp'
	var cppre = PresetManager.getpre(path)
	cppre = cppre.instantiate()
	cppre.cp_info = cp_info
	add_child(cppre)
	cppre.position = Vector2(0,0)
