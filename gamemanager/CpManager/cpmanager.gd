extends Object
class_name CpManagers
#locked:未解锁，需要满足某些解锁条件如成就、局外等，被ban的羁绊也在这
#unlocked：已解锁，但尚未在局中满足激活条件
#ready：已满足激活条件，可以在激活羁绊时随机激活
#actived：已激活羁绊
var cp_pool = {
	locked={},
	unlocked={},
	ready={},
	actived={}
}
var max_list = []


func _init():
	#删除技能时，将其从（可能的）满级列表中移除
	SignalBus.del_skill.connect(del_to_maxlist)
	#技能升满时，将其加入满级列表
	SignalBus.upgrade_max.connect(add_to_maxlist)
	#删除cp时，调用
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
			cp_pool.unlocked[cps] = cp_pool.ready[cps]
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
func get_cpable_array(id):
	var cpable_array = []

	for cps in cp_pool.unlocked:
		if cp_pool.unlocked[cps].partment.has(id):

			for x in cp_pool.unlocked[cps].partment:
				if x != id:
					cpable_array.push_back(x)


	return cpable_array

func activate_cp(cp_array):
	if cp_array.is_empty():
		return
	for cpid in cp_array:
		cp_pool.ready[cpid] = cp_pool.unlocked[cpid]
		cp_pool.unlocked.erase(cpid)


func random_choose_cp():
	if cp_pool.ready.is_empty():
		return false

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


#如果待删除羁绊已激活，则将其打入已解锁 注：真正的删除羁绊操作在信号连接的cp实体处，这里只负责维护
func cp_del(cpid):
	if cp_pool.actived.has(cpid):
		cp_pool.unlocked[cpid] = cp_pool.actived[cpid]
		cp_pool.actived.erase(cpid)
#
func destroy():
	SignalBus.del_skill.disconnect(del_to_maxlist)
	SignalBus.upgrade_max.disconnect(add_to_maxlist)
	SignalBus.cp_del.disconnect(cp_del)
	pass
