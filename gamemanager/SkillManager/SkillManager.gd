extends Node
var skill_num_have = 0
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
func _ready():
	skill_pool.unlocked = table.skill.duplicate()
	for skills in skill_pool.unlocked:
		skill_pool.unlocked[skills]['weight'] = 1

func add_skill(skill_name):
	if(skill_pool.choosed.has(skill_name)):
		upgrade_skill(skill_name)
		return
	if(skill_pool.max.has(skill_name)):
		return
	if(skill_pool.locked.has(skill_name)):
		unlock_skill(skill_name)
	CpManager.raise_weight_to_cp(skill_name)
	var path = 'skill'
	player_var.damage_sum[skill_name] = 0
	skill_num_have += 1
	if skill_num_have >= player_var.skill_num_max:
		player_var.skill_num_full = true
	player_var.skill_full = false

	var skillpre = PresetManager.getpre(path)
	skillpre = skillpre.instantiate()
	skillpre.skill_info = skill_pool.unlocked[skill_name]
	player_var.player_node.get_node("skill").add_child(skillpre)
	skillpre.position = Vector2(0,0)

	skill_pool.choosed[skill_name]=skill_pool.unlocked[skill_name]
	skill_pool.unlocked.erase(skill_name)
	skill_list[skill_name] = skillpre
	get_tree().call_group("hud","add_skill",skill_pool.choosed[skill_name])
	upgrade_skill(skill_name)


func del_skill(skill_name):
	if(skill_pool.choosed.has(skill_name)):
		skill_pool.unlocked[skill_name]=skill_pool.choosed[skill_name]
		skill_pool.choosed.erase(skill_name)


	elif(skill_pool.max.has(skill_name)):
		skill_pool.unlocked[skill_name]=skill_pool.max[skill_name]
		skill_pool.max.erase(skill_name)
	else:
		return
	skill_list.erase(skill_name)
	player_var.skill_num_have -= 1

	player_var.skill_num_full = false
	player_var.skill_full = false

	skill_list[skill_name].destroy()

	CpManager.del_to_maxlist(skill_name)


func upgrade_skill(skill_name):

	if(skill_list[skill_name].level >= player_var.skill_max_level):
		return
	skill_list[skill_name].level += 1
	skill_list[skill_name].upgrade_skill()

	if(skill_list[skill_name].level == player_var.skill_max_level):

		skill_pool.max[skill_name] = skill_pool.choosed[skill_name]
		skill_pool.choosed.erase(skill_name)
		CpManager.add_to_maxlist(skill_name)
		if player_var.skill_num_full and skill_pool.choosed.is_empty():
			player_var.skill_full = true




func ban_skill(skill_name):
	if(skill_pool.unlocked.has(skill_name)):
		skill_pool.banned[skill_name]=skill_pool.unlocked[skill_name]
		skill_pool.unlocked.erase(skill_name)

	elif(skill_pool.choosed.has(skill_name)):
		skill_pool.banned[skill_name]=skill_pool.choosed[skill_name]
		del_skill(skill_name)
		skill_pool.unlocked.erase(skill_name)

	else:
		return false

func unlock_skill(skill_name):
	pass
func get_skill_by_name(skill_name):
	if(skill_pool["choosed"].has(skill_name)):
		return skill_pool["choosed"][skill_name]
	if(skill_pool["unlocked"].has(skill_name)):
		return skill_pool["unchoosed"][skill_name]
	if(skill_pool["max"].has(skill_name)):
		return skill_pool["max"][skill_name]
	return null

func clear_all():
	skill_pool.unlocked = table.skill.duplicate()
	for skills in skill_pool.unlocked:
		skill_pool.unlocked[skills]['weight'] = 1

#func call_routine_generate(routine_name,gposition,rotation):
	#for ski in skill_list:
		#for child in skill_list[ski].get_children():
			#if child.is_in_group(routine_name):
				#child.attacks(true,gposition,rotation)
