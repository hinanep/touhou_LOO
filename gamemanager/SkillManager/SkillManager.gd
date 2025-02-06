extends RefCounted
class_name SkillManagers
var skill_num_have = 0
var skill_num_full = false
var skill_full = false

var skill_info = {
	skill_name = '',
	upgrade_group = '',
	skills = [],
	cd = 1.0,
	cd_reduction_efficicency = 1.0

}
var skill_pool = {
	#skill_name : skill_info
	locked = {},
	unlocked = {},
	choosed = {},
	max = {},
	banned = {}
}

#skill_name:node
var skill_list = {}

func _init() -> void:
	SignalBus.try_add_skill.connect(on_try_add_skill)
	SignalBus.add_skill.connect(on_add_skill)
	SignalBus.del_skill.connect(on_del_skill)
	SignalBus.upgrade_max.connect(on_upgrade_skill_max)
	SignalBus.ban_skill.connect(on_ban_skill)
	SignalBus.upgrade_skill.connect(on_upgrade_skill)

	skill_pool.unlocked = table.skill.duplicate()
	for skills in skill_pool.unlocked:
		skill_pool.unlocked[skills]['weight'] = 1

func on_try_add_skill(skill_name):
	if(skill_pool.choosed.has(skill_name)):
		SignalBus.upgrade_skill.emit(skill_name)
		return
	if(skill_pool.max.has(skill_name)):
		return
	if(skill_pool.locked.has(skill_name)):
		on_unlock_skill(skill_name)
	SignalBus.add_skill.emit(skill_pool.unlocked[skill_name])

func on_add_skill(ski_info):
	var skill_name = ski_info.skill_name
	player_var.damage_sum[skill_name] = 0
	skill_num_have += 1
	if skill_num_have >= player_var.skill_num_max:
		skill_num_full = true
	skill_full = false

	skill_pool.choosed[skill_name]=skill_pool.unlocked[skill_name]
	skill_pool.unlocked.erase(skill_name)
	skill_list[skill_name] = 0
	if skill_name == "ski_basemagic" or skill_name == "ski_basephysics":
		skill_pool.max[skill_name] = skill_pool.choosed[skill_name]
		skill_pool.choosed.erase(skill_name)
	else:
		SignalBus.upgrade_skill.emit(skill_name)

func on_del_skill(skill_name):
	if(skill_pool.choosed.has(skill_name)):
		skill_pool.unlocked[skill_name]=skill_pool.choosed[skill_name]
		skill_pool.choosed.erase(skill_name)


	elif(skill_pool.max.has(skill_name)):
		skill_pool.unlocked[skill_name]=skill_pool.max[skill_name]
		skill_pool.max.erase(skill_name)
	else:
		return

	skill_num_have -= 1

	skill_num_full = false
	skill_full = false

func on_upgrade_skill(skill_name):
	skill_list[skill_name] += 1

func on_upgrade_skill_max(skill_name):

	skill_pool.max[skill_name] = skill_pool.choosed[skill_name]
	skill_pool.choosed.erase(skill_name)

	if skill_num_full and skill_pool.choosed.is_empty():
		skill_full = true




func on_ban_skill(skill_name):
	if(skill_pool.unlocked.has(skill_name)):
		skill_pool.banned[skill_name]=skill_pool.unlocked[skill_name]
		skill_pool.unlocked.erase(skill_name)

	elif(skill_pool.choosed.has(skill_name)):
		skill_pool.banned[skill_name]=skill_pool.choosed[skill_name]
		skill_pool.unlocked.erase(skill_name)
		SignalBus.del_skill.emit(skill_name)

	else:
		return false

func on_unlock_skill(skill_name):
	pass

func get_skill_by_name(skill_name):
	if(skill_pool.choosed.has(skill_name)):
		return skill_pool.choosed[skill_name]
	if(skill_pool.unlocked.has(skill_name)):
		return skill_pool.unlocked[skill_name]
	if(skill_pool.max.has(skill_name)):
		return skill_pool.max[skill_name]
	return null

func get_skill_level(skill_name):
	if skill_list.has(skill_name):
		return skill_list[skill_name]
	else:
		return 0
