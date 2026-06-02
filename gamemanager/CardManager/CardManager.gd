extends Object
class_name CardManagers

var cardnum_have: int


var card_list: Dictionary[String, int] = {}

var card_num_max: int = 5

var _card_pool_locked: Dictionary[String, Dictionary] = {}
var _card_pool_unlocked: Dictionary[String, Dictionary] = {}
var _card_pool_choosed: Dictionary[String, Dictionary] = {}
var _card_pool_max: Dictionary[String, Dictionary] = {}
var _card_pool_banned: Dictionary[String, Dictionary] = {}

var card_pool: Dictionary = {
	"locked": _card_pool_locked,
	"unlocked": _card_pool_unlocked,
	"choosed": _card_pool_choosed,
	"max": _card_pool_max,
	"banned": _card_pool_banned,
}


func _init() -> void:

	cardnum_have = 0
	SignalBus.try_add_card.connect(on_try_add_card)
	SignalBus.add_card.connect(on_add_card)
	SignalBus.del_card.connect(on_del_card)
	SignalBus.upgrade_max.connect(on_upgrade_card_max)
	SignalBus.ban_card.connect(on_ban_card)
	SignalBus.upgrade_group.connect(on_upgrade_card)
	card_pool.unlocked = RunModifiers.duplicate_resolved_table('SpellCard')
	for id in card_pool.unlocked:
		if id != 'sc_daiyousei':
			card_pool.unlocked[id]['weight'] = 1
		else:
			card_pool.unlocked[id]['weight'] = 0

func on_try_add_card(id: String) -> void:
	if(card_pool.choosed.has(id)):
		SignalBus.upgrade_group.emit(card_pool.choosed[id].upgrade_group,card_list[id])
		return
	if(card_pool.max.has(id)):
		return
	if(card_pool.locked.has(id)):
		on_unlock_card(id)
	SignalBus.add_card.emit(card_pool.unlocked[id])

func on_add_card(card_info: Dictionary) -> void:
	var id: String = card_info.id
	player_var.damage_sum[id] = 0.0
	cardnum_have += 1
	if cardnum_have >= card_num_max:
		player_var.card_num_full = true
	player_var.card_full = false

	card_pool.choosed[id]=card_pool.unlocked[id]
	card_pool.unlocked.erase(id)
	card_list[id] = 0
	if id == "sc_daiyousei" :
		card_pool.max[id] = card_pool.choosed[id]
		card_pool.choosed.erase(id)
		return
	SignalBus.upgrade_group.emit(card_pool.choosed[id].upgrade_group,card_list[id])

func on_del_card(id: String) -> void:
	card_list.erase(id)
	if(card_pool.choosed.has(id)):
		card_pool.unlocked[id]=card_pool.choosed[id]
		card_pool.choosed.erase(id)


	elif(card_pool.max.has(id)):
		card_pool.unlocked[id]=card_pool.max[id]
		card_pool.max.erase(id)
	else:
		return

	cardnum_have -= 1

	player_var.card_num_full = false
	player_var.card_full = false

func on_upgrade_card(group: String, level: Variant) -> void:
	for cardi in card_list:
		if  get_card_by_name(cardi).upgrade_group == group:
			card_list[cardi] += 1

func on_upgrade_card_max(id: String) -> void:
	if not card_list.has(id):
		return
	card_pool.max[id] = card_pool.choosed[id]
	card_pool.choosed.erase(id)

	if player_var.card_num_full and card_pool.choosed.is_empty():
		player_var.card_full = true




func on_ban_card(id: String) -> Variant:
	if(card_pool.unlocked.has(id)):
		card_pool.banned[id]=card_pool.unlocked[id]
		card_pool.unlocked.erase(id)
		return true

	elif(card_pool.choosed.has(id)):
		card_pool.banned[id]=card_pool.choosed[id]
		card_pool.unlocked.erase(id)
		SignalBus.del_card.emit(id)
		return true

	else:
		return false

func on_unlock_card(id: String) -> void:
	pass

func get_card_by_name(id: String) -> Variant:
	if(card_pool.choosed.has(id)):
		return card_pool.choosed[id]
	if(card_pool.unlocked.has(id)):
		return card_pool.unlocked[id]
	if(card_pool.max.has(id)):
		return card_pool.max[id]
	return null

func get_card_level(id: String) -> int:
	if card_list.has(id):
		return card_list[id]
	else:
		return 0
func destroy() -> void:
	SignalBus.try_add_card.disconnect(on_try_add_card)
	SignalBus.add_card.disconnect(on_add_card)
	SignalBus.del_card.disconnect(on_del_card)
	SignalBus.upgrade_max.disconnect(on_upgrade_card_max)
	SignalBus.ban_card.disconnect(on_ban_card)
	#SignalBus.upgrade_group.disconnect(on_upgrade_card)
