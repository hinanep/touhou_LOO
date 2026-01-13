extends Attack

@export var particle_scale_need_change:bool = false
@export var particle_scale_min:Array = [1.0,1.0,1.0,1.0]
@export var particle_scale_max:Array = [1.0,1.0,1.0,1.0]

func _ready() -> void:
	super._ready()
	if not item_rect_changed.is_connected(_on_item_rect_changed):
		item_rect_changed.connect(_on_item_rect_changed)
	set_particle_scale(scale.x)

func set_particle_scale(sc:float):
	for i in particles.size():
		var particle:GPUParticles2D = particles[i]
		particle.process_material.set_param_min(8,particle_scale_min[i]*sc)
		particle.process_material.set_param_max(8,particle_scale_max[i]*sc)

func _on_item_rect_changed() -> void:
	if not particle_scale_need_change:
		return

	set_particle_scale(scale.x)
