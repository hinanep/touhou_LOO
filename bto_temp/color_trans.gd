#该脚本实现一些贴图的炫彩色相变化

extends AnimatedSprite2D

func _process(delta: float) -> void:
	var h = self_modulate.h + delta / 3
	if h > 1.0:
		h -= 1
	self_modulate = Color.from_hsv(h, self_modulate.s, self_modulate.v, self_modulate.a)
