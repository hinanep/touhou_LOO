extends Object
class_name PassiveManagers
var passive_num_have = 0
var passive_num_full = false
var passive_full = false

var passive_info = {
	"id": "psv_patchouli",
	"upgrade_group": "upg_patchouli",
	"type": "base",
	"buff": [
	  "buff_max_mana_forever"
	],
	"buff_value_factor": [
	  1.0
	]

}
var passive_pool = {
	#id : passive_info
	locked = {},
	unlocked = {},
	choosed = {},
	max = {},
	banned = {}
}

#id:node
var passive_list = {}

func _init() -> void:
	SignalBus.try_add_passive.connect(on_try_add_passive)
	SignalBus.add_passive.connect(on_add_passive)
	SignalBus.del_passive.connect(on_del_passive)
	SignalBus.upgrade_max.connect(on_upgrade_passive_max)
	SignalBus.ban_passive.connect(on_ban_passive)
	SignalBus.upgrade_group.connect(on_upgrade_passive)

	passive_pool.unlocked = table.Passive.duplicate()
	for passives in passive_pool.unlocked:
		passive_pool.unlocked[passives]['weight'] = 1

func on_try_add_passive(id):
	if(passive_pool.choosed.has(id)):
		SignalBus.upgrade_group.emit(passive_pool.choosed[id].upgrade_group)
		return
	if(passive_pool.max.has(id)):
		return
	if(passive_pool.locked.has(id)):
		on_unlock_passive(id)
	SignalBus.add_passive.emit(passive_pool.unlocked[id])

func on_add_passive(ski_info):
	var id = ski_info.id
	player_var.damage_sum[id] = 0
	passive_num_have += 1
	if passive_num_have >= player_var.passive_num_max:
		passive_num_full = true
	passive_full = false

	passive_pool.choosed[id]=passive_pool.unlocked[id]
	passive_pool.unlocked.erase(id)
	passive_list[id] = 0

	SignalBus.upgrade_group.emit(passive_pool.choosed[id].upgrade_group)

func on_del_passive(id):
	if(passive_pool.choosed.has(id)):
		passive_pool.unlocked[id]=passive_pool.choosed[id]
		passive_pool.choosed.erase(id)


	elif(passive_pool.max.has(id)):
		passive_pool.unlocked[id]=passive_pool.max[id]
		passive_pool.max.erase(id)
	else:
		return

	passive_num_have -= 1

	passive_num_full = false
	passive_full = false

func on_upgrade_passive(group):
	for psvi in passive_list:
		if get_passive_by_name(psvi).upgrade_group == group:
			passive_list[psvi] += 1

func on_upgrade_passive_max(id):
	if not passive_list.has(id):
		return
	passive_pool.max[id] = passive_pool.choosed[id]
	passive_pool.choosed.erase(id)

	if passive_num_full and passive_pool.choosed.is_empty():
		passive_full = true




func on_ban_passive(id):
	if(passive_pool.unlocked.has(id)):
		passive_pool.banned[id]=passive_pool.unlocked[id]
		passive_pool.unlocked.erase(id)

	elif(passive_pool.choosed.has(id)):
		passive_pool.banned[id]=passive_pool.choosed[id]
		passive_pool.unlocked.erase(id)
		SignalBus.del_passive.emit(id)

	else:
		return false

func on_unlock_passive(id):
	pass

func get_passive_by_name(id):
	if(passive_pool.choosed.has(id)):
		return passive_pool.choosed[id]
	if(passive_pool.unlocked.has(id)):
		return passive_pool.unlocked[id]
	if(passive_pool.max.has(id)):
		return passive_pool.max[id]
	return null

func get_passive_level(id):
	if passive_list.has(id):
		return passive_list[id]
	else:
		return 0
func destroy():
	SignalBus.try_add_passive.disconnect(on_try_add_passive)
	SignalBus.add_passive.disconnect(on_add_passive)
	SignalBus.del_passive.disconnect(on_del_passive)
	SignalBus.upgrade_max.disconnect(on_upgrade_passive_max)
	SignalBus.ban_passive.disconnect(on_ban_passive)
	SignalBus.upgrade_group.disconnect(on_upgrade_passive)
