class_name skill extends Node2D
var active = true

var skill_info = {
	id = '',
	upgrade_group = '',
	routines = ["rou_reimu"],
	cd = 1.0,
	cd_reduction_efficicency = 1.0

}
signal shoot
var level = 0
var max_level
var upgrade_info = {

}
var damage_source = ''


func _ready():
	name = skill_info.id
	add_to_group(skill_info.id)
	add_to_group(skill_info.upgrade_group)
	SignalBus.upgrade_group.connect(upgrade_skill)
	SignalBus.del_skill.connect(destroy)

	damage_source = skill_info.id
	var cd_timer = $cd_timer
	cd_timer.wait_time = skill_info.cd  / (1+player_var.colddown_reduce * skill_info.cd_reduction_efficicency)
	cd_timer.timeout.connect(gen_routines)

	cd_timer.start()

	for aroutine in table.Routine:
		if table.Routine[aroutine].skill_group == skill_info.id:

			var r = add_routine(aroutine)

			if aroutine in skill_info.routines:
				shoot.connect(r.attacks)
	gen_routines()
	if table.Upgrade.has(skill_info.upgrade_group):
		max_level = table.Upgrade[skill_info.upgrade_group].level


func add_routine(id):
		var routinepre = PresetManager.getpre('routine').instantiate()
		routinepre.position = Vector2(0,0)
		routinepre.routine_info = table.Routine[id].duplicate()
		routinepre.damage_source = damage_source

		add_child(routinepre)
		return routinepre


func gen_routines():
	if not active:
		return
	emit_signal("shoot")


func upgrade_skill(group):
	if skill_info.upgrade_group != group:
		return
	if(level+1 > player_var.skill_level_max):
		return
	level += 1

	if level == 1:
		return

	$cd_timer.wait_time = skill_info.cd  /(1+table.Upgrade[group].cd_reduction[level-1]) / (1+player_var.colddown_reduce * skill_info.cd_reduction_efficicency)

	if(level == max_level):
		SignalBus.upgrade_max.emit(skill_info.id)


func destroy(id):
	if skill_info.id != id:
		return
	active = false
	for child in get_children():
		if child.has_method('destroy'):
			child.destroy()

	queue_free()
