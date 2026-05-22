extends Node2D

const _AttackParticleWarmup = preload("res://scene/attack/attack/AttackParticleWarmup.gd")

func _ready() -> void:
	SignalBus.add_skill.connect(on_add_skill)
	pass
func on_add_skill(skill_info):
	var path = 'skill'
	var skillpre = PresetManager.getpre(path)
	skillpre = skillpre.instantiate()
	skillpre.skill_info = skill_info
	add_child(skillpre)
	skillpre.position = Vector2(0,0)
	var warmup = _AttackParticleWarmup.new()
	await warmup.warmup_under(skillpre)
