#该脚本实现一些贴图的旋转

extends GPUParticles2D

@export_group("Auto Rotate")
@export var rotate_speed : int

func _process(delta: float) -> void:
	rotate(rotate_speed * PI * delta)
