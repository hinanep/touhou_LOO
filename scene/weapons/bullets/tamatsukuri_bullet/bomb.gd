extends Node2D

@export var bombParticle : PackedScene

func _ready():
	#await  get_tree().create_timer(0.2).timeout
	Kill()

func Kill():
	var _particle = bombParticle.instantiate()
	if player_var.player_node != null:
		player_var.player_node.call_deferred("add_child",_particle)
	_particle.global_transform = global_transform
	_particle.set_emitting(true)

	queue_free()
