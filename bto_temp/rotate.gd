extends GPUParticles2D

func _process(delta: float) -> void:
	rotate(4 * PI * delta)
