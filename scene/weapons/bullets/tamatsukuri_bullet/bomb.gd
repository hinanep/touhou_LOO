extends Node2D

@export var bombParticle : PackedScene
var basic_damage
func _ready():
	#await  get_tree().create_timer(0.2).timeout
	basic_damage = 10
	Kill()
	await  get_tree().create_timer(0.1).timeout
	var enemy_in_range = $explo_area.get_overlapping_bodies()
	if enemy_in_range:
			for enemy in enemy_in_range:
				if enemy.has_method("take_damage"):
					print("爆炸输出！！")
					enemy.take_damage(player_var.player_make_bullet_damage(basic_damage))
func Kill():
	AudioManager.play_sfx("explosion")
	var _particle = bombParticle.instantiate()
	
	if player_var.player_node != null:
		player_var.player_node.call_deferred("add_child",_particle)
	_particle.global_transform = global_transform
	_particle.set_emitting(true)
	
	#var enemy_in_range = $explo_area.get_overlapping_bodies()
	#if enemy_in_range:
			#for enemy in enemy_in_range:
				#if enemy.has_method("take_damage"):
					#print("爆炸输出！！")
					#enemy.take_damage(player_var.player_make_bullet_damage(basic_damage))

	


func _on_animated_sprite_2d_animation_finished():
	queue_free()
	pass # Replace with function body.
