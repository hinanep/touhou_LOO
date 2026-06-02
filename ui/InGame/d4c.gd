extends Node2D
func _ready() -> void:
	SignalBus.d4c_create.connect(new_d4c)

func new_d4c(id: String, g_position: Vector2, parent: Node2D, damage: float, callback: Callable) -> void:

	var nd4c: Node2D = PresetManager.getpre('d4c').instantiate()

	nd4c.damage = damage
	nd4c.gen_position = g_position

	if nd4c.d4c_init(id,parent) == 'parent':

		parent.add_child(nd4c)
	else:

		add_child(nd4c)
	#if parent.has_method('release'):
	if callback!=null:
		nd4c.die.connect(callback)
	nd4c.global_position = g_position
	nd4c = null
