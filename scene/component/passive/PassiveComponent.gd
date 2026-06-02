extends Node2D


func _ready() -> void:
	SignalBus.add_passive.connect(on_add_passive)
	pass


func on_add_passive(passive_info: Dictionary) -> void:
	var path: String = 'passive'
	var passivepre_packed: PackedScene = PresetManager.getpre(path)
	var passivepre: Node = passivepre_packed.instantiate()
	passivepre.psv_info = passive_info
	add_child(passivepre)
	passivepre.position = Vector2(0, 0)
