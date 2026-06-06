extends Object
class_name SkillManagers
var skill_num_have: int = 0
var skill_num_full: bool = false
var skill_full: bool = false

var skill_info: Dictionary = {
	id = '',
	upgrade_group = '',
	skills = [],
	cd = 1.0,
	cd_reduction_efficicency = 1.0

}
var _skill_pool_locked: Dictionary[String, Dictionary] = {}
var _skill_pool_unlocked: Dictionary[String, Dictionary] = {}
var _skill_pool_choosed: Dictionary[String, Dictionary] = {}
var _skill_pool_max: Dictionary[String, Dictionary] = {}
var _skill_pool_banned: Dictionary[String, Dictionary] = {}

var skill_pool: Dictionary = {
	# id : skill_info
	"locked": _skill_pool_locked,
	"unlocked": _skill_pool_unlocked,
	"choosed": _skill_pool_choosed,
	"max": _skill_pool_max,
	"banned": _skill_pool_banned,
}

#id:node
var skill_list: Dictionary[String, int] = {}

func _init() -> void:
	SignalBus.try_add_skill.connect(on_try_add_skill)
	SignalBus.add_skill.connect(on_add_skill)
	SignalBus.del_skill.connect(on_del_skill)
	SignalBus.upgrade_max.connect(on_upgrade_skill_max)
	SignalBus.ban_skill.connect(on_ban_skill)
	SignalBus.upgrade_group.connect(on_upgrade_skill)

	skill_pool.unlocked = RunModifiers.duplicate_resolved_table('Skill')
	for id in skill_pool.unlocked:
		if id == "ski_basemagic" or id == "ski_basephysics":
			skill_pool.unlocked[id]['weight'] = 0
		else:
			skill_pool.unlocked[id]['weight'] = 1


func on_try_add_skill(id: String) -> void:
	if(skill_pool.choosed.has(id)):
		SignalBus.upgrade_group.emit(skill_pool.choosed[id].upgrade_group,skill_list[id])
		return
	if(skill_pool.max.has(id)):
		return
	if(skill_pool.locked.has(id)):
		on_unlock_skill(id)
	SignalBus.add_skill.emit(skill_pool.unlocked[id])

func on_add_skill(ski_info: Dictionary) -> void:
	var id: String = ski_info.id
	player_var.damage_sum[id] = 0.0
	skill_num_have += 1
	if skill_num_have >= player_var.skill_num_max:
		skill_num_full = true
	skill_full = false

	skill_pool.choosed[id]=skill_pool.unlocked[id]
	skill_pool.unlocked.erase(id)
	skill_list[id] = 0
	if id == "ski_basemagic" or id == "ski_basephysics":
		skill_pool.max[id] = skill_pool.choosed[id]
		skill_pool.choosed.erase(id)
	else:
		SignalBus.upgrade_group.emit(skill_pool.choosed[id].upgrade_group,0)

func on_del_skill(id: String) -> void:
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

func on_upgrade_skill(group: String, currentlevel: Variant) -> void:
	for skilli in skill_list:
		if get_skill_by_name(skilli).upgrade_group == group:
			skill_list[skilli] += 1


func on_upgrade_skill_max(id: String) -> void:
	if not skill_list.has(id):
		return
	skill_pool.max[id] = skill_pool.choosed[id]
	skill_pool.choosed.erase(id)

	if skill_num_full and skill_pool.choosed.is_empty():
		skill_full = true




func on_ban_skill(id: String) -> Variant:
	if(skill_pool.unlocked.has(id)):
		skill_pool.banned[id]=skill_pool.unlocked[id]
		skill_pool.unlocked.erase(id)
		return true
	elif(skill_pool.choosed.has(id)):
		skill_pool.banned[id]=skill_pool.choosed[id]
		skill_pool.unlocked.erase(id)
		SignalBus.del_skill.emit(id)
		return true
	else:
		return false

func on_unlock_skill(id: String) -> void:
	skill_pool.unlocked[id] = skill_pool.banned[id]
	skill_pool.banned.erase(id)


func get_skill_by_name(id: String) -> Variant:
	if(skill_pool.choosed.has(id)):
		return skill_pool.choosed[id]
	if(skill_pool.unlocked.has(id)):
		return skill_pool.unlocked[id]
	if(skill_pool.max.has(id)):
		return skill_pool.max[id]
	if(skill_pool.banned.has(id)):
		return skill_pool.banned[id]
	if(skill_pool.locked.has(id)):
		return skill_pool.locked[id]
	return null

func get_skill_level(id: String) -> int:
	if skill_list.has(id):
		return skill_list[id]
	else:
		return 0
func destroy() -> void:
	SignalBus.try_add_skill.disconnect(on_try_add_skill)
	SignalBus.add_skill.disconnect(on_add_skill)
	SignalBus.del_skill.disconnect(on_del_skill)
	SignalBus.upgrade_max.disconnect(on_upgrade_skill_max)
	SignalBus.ban_skill.disconnect(on_ban_skill)
	SignalBus.upgrade_group.disconnect(on_upgrade_skill)
