extends Node

var skill_group = {}
var card_group = {}
var summon_group = {}
var routine_group = {}
var attack_group = {}

var boost_atk = []
var boost_sum = []
func _ready() -> void:
	SignalBus.upgrade_group.connect(_on_upgrade)
	SignalBus.cp_active.connect(_on_boost_active.bind(true))
	SignalBus.cp_del.connect(_on_boost_active.bind(false))
	init_group()
	for id in table.Attack:
		if table.Attack[id].type == 'boost':
			boost_atk.append(id)
	for id in table.Summoned:
		if table.Summoned[id].type == 'boost':
			boost_sum.append(id)
func addtogroup(tabledic:Dictionary,group):
	for id in tabledic:
		if tabledic[id].has('upgrade_group'):
			var skillsgroup = tabledic[id].upgrade_group
			if group.has(skillsgroup):
				group[skillsgroup].append(id)
func init_group():


	for group in table.Upgrade:
		match table.Upgrade[group].type:
			'skill':
				skill_group[group]= Array()

				routine_group[group]= Array()
				attack_group[group]= Array()
				summon_group[group]= Array()




			'spellcard':
				card_group[group]= Array()
				routine_group[group]= Array()
				attack_group[group]= Array()
				#addtogroup(table.SpellCard,card_group)
				#addtogroup(table.Routine,routine_group)
				#addtogroup(table.Attack,attack_group)
			'passive':
				pass
	addtogroup(table.Skill,skill_group)
	addtogroup(table.Routine,routine_group)
	addtogroup(table.Attack,attack_group)
	addtogroup(table.Summoned,summon_group)
	addtogroup(table.SpellCard,card_group)
func _on_upgrade(group,currentlevel):
	print("升级")
	print(group,currentlevel)
	up_skill(group,currentlevel)
	up_card(group,currentlevel)
	up_routine(group,currentlevel)
	up_attack(group,currentlevel)
	up_summon(group,currentlevel)

func _on_boost_active(cp_info: Dictionary,is_active: bool) -> void:
	print('boost')
	for boostid in boost_atk:
		var boost_info = table.Attack[boostid]
		if boost_info.effective_condition != cp_info.id:
			continue
		#应用/删除强化
		for id in table.Attack:
			var attack_info = table.Attack[id]
			if boost_info.get("routine_group") == attack_info.get("routine_group") and attack_info.type != 'boost':

				_apply_atk_boost_effects(boost_info,attack_info, is_active)
	for boostid in boost_sum:
		var boost_info = table.Summoned[boostid]
		for id in table.Summoned:
			var sum_info = table.Summoned[id]
			if boost_info.effective_condition != cp_info.id:
				continue
			if boost_info.get("routine_group")[0] in sum_info.get("routine_group") and sum_info.type != 'boost':

				_apply_sum_boost_effects(boost_info,sum_info, is_active)


func _apply_sum_boost_effects(boost_info: Dictionary,summon_info, is_active: bool) -> void:
	for key in boost_info:
		if key in ["id", "type", "routine_group", "effective_condition", "upgrade_group"] or boost_info[key] is bool:
			continue

		if not is_active: # 移除效果
			if not summon_info.has(key): continue
			match typeof(boost_info[key]):
				TYPE_ARRAY:
					for element in boost_info[key]:
						if summon_info[key].has(element): summon_info[key].erase(element)
				_:
					if typeof(summon_info[key]) in [TYPE_INT, TYPE_FLOAT]:
						summon_info[key] -= boost_info[key]
			continue

		# 添加效果
		if not summon_info.has(key):
			summon_info[key] = boost_info[key]
		else:
			match typeof(summon_info[key]):
				TYPE_ARRAY:
					for element in boost_info[key]:
						if not summon_info[key].has(element): summon_info[key].append(element)
				_:
					summon_info[key] += boost_info[key]


func _apply_atk_boost_effects(boost_info: Dictionary,attack_info, is_active: bool) -> void:
	# 遍历 boost 攻击的所有属性
	for key in boost_info:
		# 忽略元数据和无关属性
		if key in ["id", "type", "routine_group", "effective_condition"]:
			continue
		if boost_info[key] is bool:
			continue

		# --- 移除 Boost 效果的逻辑 ---
		if not is_active:
			# 检查本攻击是否真的有这个属性，避免出错
			if not attack_info.has(key):
				continue

			match typeof(boost_info[key]):
				# 如果是数组类型，则移除数组中的元素
				TYPE_ARRAY:
					for element in boost_info[key]:
						if attack_info[key].has(element):
							attack_info[key].erase(element)
				# 默认情况，处理数值类型
				_:
					if typeof(attack_info[key]) in [TYPE_INT, TYPE_FLOAT]:
						attack_info[key] -= boost_info[key]
			continue # 处理完移除后，进入下一次循环

		# --- 应用 Boost 效果的逻辑 ---
		# 如果本攻击原本没有这个属性，则直接添加
		if not attack_info.has(key):
			attack_info[key] = boost_info[key]
		# 如果已有该属性
		else:
			match typeof(attack_info[key]):
				# 如果是数组，则合并数组（避免重复添加）
				TYPE_ARRAY:
					for element in boost_info[key]:
						if not attack_info[key].has(element):
							attack_info[key].append(element)
				# 如果是数值，则直接相加
				_:
					attack_info[key] += boost_info[key]











func up_skill(group,currentlevel):
	if currentlevel == table.Upgrade[group].level:
		return
	for id in skill_group.get(group,[]):
		if table.Upgrade[group].has('cd_reduction'):
			table.Skill[id].cd = table.oSkill[id].cd/(1.0 + table.Upgrade[group]['cd_reduction'][currentlevel])
			SignalBus.renew_state.emit(id)

		if currentlevel+1 == table.Upgrade[group].level:
			SignalBus.upgrade_max.emit(id)

func up_card(group,currentlevel):
	if currentlevel == table.Upgrade[group].level:
		return
	for id in card_group.get(group,[]):
		if currentlevel+1 == table.Upgrade[group].level:
			SignalBus.upgrade_max.emit(id)


func up_routine(group,currentlevel):
	if currentlevel == table.Upgrade[group].level:
		return
	for id in routine_group.get(group,[]):
		if table.Upgrade[group].has('times_addition'):
			table.Routine[id].times = table.oRoutine[id].times + table.Upgrade[group]['times_addition'][currentlevel]

			SignalBus.renew_state.emit(id)


func up_attack(group,currentlevel):
	if currentlevel == table.Upgrade[group].level:
		return
	for id in attack_group.get(group,[]):
		if table.Upgrade[group].has("damage_addition"):
			table.Attack[id].damage = table.oAttack[id].damage *(1 + table.Upgrade[group]['damage_addition'][currentlevel])
		if table.Upgrade[group].has("bullet_speed_addition"):
			for i in table.Attack[id].moving_parameter.size():
				table.Attack[id].moving_parameter[i] = table.oAttack[id].moving_parameter[i] *(1 + table.Upgrade[group]['bullet_speed_addition'][currentlevel])

		if table.Upgrade[group].has("duration_addition"):
			table.Attack[id].duration = table.oAttack[id].duration *(1 + table.Upgrade[group]['duration_addition'][currentlevel])
		if table.Upgrade[group].has("range_addition"):
			for i in table.Attack[id].size.size():
				table.Attack[id].size[i] = table.oAttack[id].size[i] *(1 + table.Upgrade[group]['range_addition'][currentlevel])
		SignalBus.renew_state.emit(id)

func up_summon(group,currentlevel):
	if currentlevel == table.Upgrade[group].level:
		return
	for id in summon_group.get(group,[]):
		if table.Upgrade[group].has("duration_addition"):
			table.Summoned[id].duration = table.oSummoned[id].duration *(1 + table.Upgrade[group]['duration_addition'][currentlevel])
		if table.Upgrade[group].has('cd_reduction'):
			table.Summoned[id].cd = table.oSummoned[id].cd/(1.0 + table.Upgrade[group]['cd_reduction'][currentlevel])
			SignalBus.renew_state.emit(id)
		SignalBus.renew_state.emit(id)
