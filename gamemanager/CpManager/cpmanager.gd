extends Object
class_name CpManagers
var cp_pool = {
	locked={},
	unlocked={},
	ready={},
	actived={}
}
var max_list = []
#"cp_reimu_marisa": {
	#"id": "cp_reimu_marisa",
	#"partment": [
	  #"ski_reimu",
	  #"sc_marisa"
	#],
	#"creating_routine": [
	  #"rou_reimu_marisa1_base",
	  #"rou_reimu_marisa2_base"
	#],
	#"creating_routine_moment": [
	  #"hurt"
	#],
	#"giving_buff": [],
	#"giving_buff_moment": [],
	#"buff_value_factor_depend": [],
	#"buff_value_factor": [
	  #1.0
	#]
  #}
func _init():
	SignalBus.del_skill.connect(del_to_maxlist)
	SignalBus.upgrade_max.connect(add_to_maxlist)
	SignalBus.cp_del.connect(cp_del)
	cp_pool.unlocked = table.Couple.duplicate()
#当某个技能？升满，加入满级列表，留待羁绊解锁判断
func add_to_maxlist(id):
	max_list.append(id)
	activate_cp(get_cp_unactive(id))
#从满级列表删除某个技能？
func del_to_maxlist(id):
	if max_list.has(id):
		max_list.erase(id)

	#删除该技能已解锁的羁绊
	for cps in cp_pool.ready:
		if cp_pool.ready[cps].partment.has(id):
			cp_pool.unlocked[cps] = cp_pool.ready[cp]
			cp_pool.ready.erase(cps)
	for cps in cp_pool.actived:
		if cp_pool.actived[cps].partment.has(id):
			SignalBus.cp_del.emit(cps)

func raise_weight_to_cp(xname):
	for cps in cp_pool.unlocked:
		if cp_pool.unlocked[cps].partment.has(xname):
			for id in cp_pool.unlocked[cps].partment:
				if(player_var.SkillManager.skill_pool.unlocked.has(id)):
					player_var.SkillManager.skill_pool.unlocked["weight"] *=1.1
				if(player_var.CardManager.card_pool.unlocked.has(id)):
					player_var.CardManager.card_pool.unlocked[id]["weight"] *=1.1
				if(player_var.PassiveManager.buff_pool.unlocked.has(id)):
					player_var.PassiveManager.buff_pool.unlocked[id]["weight"] *=1.1
func get_cp_unactive(id):
	var find = false
	var cp_array = []

	for cps in cp_pool.unlocked:
		if cp_pool.unlocked[cps].partment.has(id):

			find = true
			for x in cp_pool.unlocked[cps].partment:
				if x in max_list:
					continue
				else:
					find = false
					break
			if find:
				cp_array.append(cp_pool.unlocked[cps].id)

	return cp_array

func activate_cp(cp_array):
	if cp_array.is_empty():
		return
	for cpid in cp_array:
		cp_pool.ready[cpid] = cp_pool.unlocked[cpid]
		cp_pool.unlocked.erase(cpid)


func random_choose_cp():
	if cp_pool.ready.is_empty():
		return false
	AudioManager.play_sfx("music_sfx_cp")
	var cpid = cp_pool.ready.keys()[randi_range(0,cp_pool.ready.size()-1)]
	add_cp(cpid)
	return true

func add_cp(cpid):
	if cp_pool.actived.has(cpid):
		return
	if cp_pool.ready.has(cpid):
		cp_pool.actived[cpid] = cp_pool.ready[cpid]
		cp_pool.ready.erase(cpid)
	if cp_pool.unlocked.has(cpid):
		cp_pool.actived[cpid] = cp_pool.unlocked[cpid]
		cp_pool.unlocked.erase(cpid)
	player_var.damage_sum[cpid] = 0

	SignalBus.cp_active.emit(cp_pool.actived[cpid])



func cp_del(cpid):
	if cp_pool.actived.has(cpid):
		cp_pool.unlocked[cpid] = cp_pool.actived[cpid]
		cp_pool.actived.erase(cpid)
func destroy():
	SignalBus.del_skill.disconnect(del_to_maxlist)
	SignalBus.upgrade_max.disconnect(add_to_maxlist)
	SignalBus.cp_del.disconnect(cp_del)
	pass
