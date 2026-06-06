extends Node2D
func _ready() -> void:
	SignalBus.drop.connect(new_drop)

func new_drop(id: String, in_global_position: Vector2, value: float) -> void:
	var drop_node: Node2D = PresetManager.getpre(id).instantiate()
	drop_node.value = value
	# 入树前用父节点换算本地坐标，延迟 add_child 时首帧即为正确位置
	drop_node.position = to_local(in_global_position)
	call_deferred("add_child", drop_node)
