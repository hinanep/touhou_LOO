extends Node2D

const _AttackParticleWarmup = preload("res://scene/attack/attack/AttackParticleWarmup.gd")


func _ready() -> void:
	SignalBus.add_skill.connect(on_add_skill)
	pass


func on_add_skill(skill_info: Dictionary) -> void:
	var path: String = 'skill'
	var skillpre_packed: PackedScene = PresetManager.getpre(path)
	var skillpre: Node = skillpre_packed.instantiate()
	skillpre.skill_info = skill_info
	add_child(skillpre)
	skillpre.position = Vector2(0, 0)
	var warmup: AttackParticleWarmup = _AttackParticleWarmup.new()
	await warmup.warmup_under(skillpre)
