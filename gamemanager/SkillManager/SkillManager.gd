extends Object
class_name SkillManagers
var skill_num_have = 0
var skill_num_full = false
var skill_full = false

var skill_info = {
	id = '',
	upgrade_group = '',
	skills = [],
	cd = 1.0,
	cd_reduction_efficicency = 1.0

}
var skill_pool = {
	#id : skill_info
	locked = {},
	unlocked = {},
	choosed = {},
	max = {},
	banned = {}
}

#id:node
var skill_list = {}

func _init() -> void:
	SignalBus.try_add_skill.connect(on_try_add_skill)
	SignalBus.add_skill.connect(on_add_skill)
	SignalBus.del_skill.connect(on_del_skill)
	SignalBus.upgrade_max.connect(on_upgrade_skill_max)
	SignalBus.ban_skill.connect(on_ban_skill)
	SignalBus.upgrade_skill.connect(on_upgrade_skill)

	skill_pool.unlocked = table.Skill.duplicate()
	for skills in skill_pool.unlocked:
		skill_pool.unlocked[skills]['weight'] = 1

func on_try_add_skill(id):
	if(skill_pool.choosed.has(id)):
		SignalBus.upgrade_skill.emit(id)
		return
	if(skill_pool.max.has(id)):
		return
	if(skill_pool.locked.has(id)):
		on_unlock_skill(id)
	SignalBus.add_skill.emit(skill_pool.unlocked[id])

func on_add_skill(ski_info):
	var id = ski_info.id
	player_var.damage_sum[id] = 0
	skill_num_have += 1
	if skill_num_have >= player_var.skill_num_max:
		skill_num_full = true
	skill_full = false

	skill_pool.choosed[id]=skill_pool.unlocked[id]
	skill_pool.unlocked.erase(id)
	skill_list[id] = 0
	if id == "ski_basemagic_base" or id == "ski_basephysics_base":
		skill_pool.max[id] = skill_pool.choosed[id]
		skill_pool.choosed.erase(id)
	else:
		SignalBus.upgrade_skill.emit(id)

func on_del_skill(id):
	if(skill_pool.choosed.has(id)):
		skill_pool.unlocked[id]=skill_pool.choosed[id]
		skill_pool.choosed.erase(id)


	elif(skill_pool.max.has(id)):
		skill_pool.unlocked[id]=skill_pool.max[id]
		skill_pool.max.erase(id)
	else:
		return

	skill_num_have -= 1

	skill_num_full = false
	skill_full = false

func on_upgrade_skill(id):
	skill_list[id] += 1

func on_upgrade_skill_max(id):

	skill_pool.max[id] = skill_pool.choosed[id]
	skill_pool.choosed.erase(id)

	if skill_num_full and skill_pool.choosed.is_empty():
		skill_full = true




func on_ban_skill(id):
	if(skill_pool.unlocked.has(id)):
		skill_pool.banned[id]=skill_pool.unlocked[id]
		skill_pool.unlocked.erase(id)

	elif(skill_pool.choosed.has(id)):
		skill_pool.banned[id]=skill_pool.choosed[id]
		skill_pool.unlocked.erase(id)
		SignalBus.del_skill.emit(id)

	else:
		return false

func on_unlock_skill(id):
	skill_pool.unlocked[id] = skill_pool.banned[id]
	skill_pool.banned.erase(id)


func get_skill_by_name(id):
	if(skill_pool.choosed.has(id)):
		return skill_pool.choosed[id]
	if(skill_pool.unlocked.has(id)):
		return skill_pool.unlocked[id]
	if(skill_pool.max.has(id)):
		return skill_pool.max[id]
	return null

func get_skill_level(id):
	if skill_list.has(id):
		return skill_list[id]
	else:
		return 0
func destroy():
	SignalBus.try_add_skill.disconnect(on_try_add_skill)
	SignalBus.add_skill.disconnect(on_add_skill)
	SignalBus.del_skill.disconnect(on_del_skill)
	SignalBus.upgrade_max.disconnect(on_upgrade_skill_max)
	SignalBus.ban_skill.disconnect(on_ban_skill)
	SignalBus.upgrade_skill.disconnect(on_upgrade_skill)
