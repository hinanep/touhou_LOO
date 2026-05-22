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


func addtogroup(tabledic: Dictionary, group) -> void:
	for id in tabledic:
		if tabledic[id].has('upgrade_group'):
			var skillsgroup = tabledic[id].upgrade_group
			if group.has(skillsgroup):
				group[skillsgroup].append(id)


func init_group() -> void:
	for group in table.Upgrade:
		match table.Upgrade[group].type:
			'skill':
				skill_group[group] = Array()
				routine_group[group] = Array()
				attack_group[group] = Array()
				summon_group[group] = Array()
			'spellcard':
				card_group[group] = Array()
				routine_group[group] = Array()
				attack_group[group] = Array()
			'passive':
				pass
	addtogroup(table.Skill, skill_group)
	addtogroup(table.Routine, routine_group)
	addtogroup(table.Attack, attack_group)
	addtogroup(table.Summoned, summon_group)
	addtogroup(table.SpellCard, card_group)


func _on_upgrade(group, currentlevel) -> void:
	print('升级')
	print(group, currentlevel)
	up_skill(group, currentlevel)
	up_card(group, currentlevel)
	up_routine(group, currentlevel)
	up_attack(group, currentlevel)
	up_summon(group, currentlevel)


func _on_boost_active(cp, is_active: bool) -> void:
	var cp_id = cp
	match typeof(cp):
		TYPE_DICTIONARY:
			cp_id = cp.get('id')

	for boostid in boost_atk:
		var boost_info = table.Attack[boostid]
		if boost_info.effective_condition != cp_id:
			continue
		for id in table.Attack:
			var attack_base = table.get_base_row('Attack', id)
			if boost_info.get('routine_group') == attack_base.get('routine_group') and attack_base.type != 'boost':
				RunModifiers.register_cp_row_patch(cp_id, 'Attack', id, boost_info, is_active)
	for boostid in boost_sum:
		var boost_info = table.Summoned[boostid]
		for id in table.Summoned:
			var sum_base = table.get_base_row('Summoned', id)
			if boost_info.effective_condition != cp_id:
				continue
			var b_groups = boost_info.get('routine_group', [])
			var s_groups = sum_base.get('routine_group', [])
			if b_groups.size() > 0 and (b_groups[0] in s_groups) and sum_base.type != 'boost':
				RunModifiers.register_cp_row_patch(cp_id, 'Summoned', id, boost_info, is_active)


func up_skill(group, currentlevel) -> void:
	if currentlevel == table.Upgrade[group].level:
		return
	for id in skill_group.get(group, []):
		var fields: Dictionary = {}
		if table.Upgrade[group].has('cd_reduction'):
			var base_row = table.get_base_row('Skill', id)
			fields['cd'] = base_row.cd / (1.0 + table.Upgrade[group]['cd_reduction'][currentlevel])
		if not fields.is_empty():
			RunModifiers.set_row_fields('Skill', id, fields)
			SignalBus.renew_state.emit(id)
		if currentlevel + 1 == table.Upgrade[group].level:
			SignalBus.upgrade_max.emit(id)


func up_card(group, currentlevel) -> void:
	if currentlevel == table.Upgrade[group].level:
		return
	for id in card_group.get(group, []):
		if currentlevel + 1 == table.Upgrade[group].level:
			SignalBus.upgrade_max.emit(id)


func up_routine(group, currentlevel) -> void:
	if currentlevel == table.Upgrade[group].level:
		return
	for id in routine_group.get(group, []):
		if table.Upgrade[group].has('times_addition'):
			var base_row = table.get_base_row('Routine', id)
			var fields = {
				'times': base_row.times + table.Upgrade[group]['times_addition'][currentlevel],
			}
			RunModifiers.set_row_fields('Routine', id, fields)
			SignalBus.renew_state.emit(id)


func up_attack(group, currentlevel) -> void:
	if currentlevel == table.Upgrade[group].level:
		return
	for id in attack_group.get(group, []):
		var base_row = table.get_base_row('Attack', id)
		var fields: Dictionary = {}
		if table.Upgrade[group].has('damage_addition'):
			fields['damage'] = base_row.damage * (1 + table.Upgrade[group]['damage_addition'][currentlevel])
		if table.Upgrade[group].has('bullet_speed_addition'):
			var moving: Array = []
			for i in base_row.moving_parameter.size():
				moving.append(
					base_row.moving_parameter[i]
					* (1 + table.Upgrade[group]['bullet_speed_addition'][currentlevel])
				)
			fields['moving_parameter'] = moving
		if table.Upgrade[group].has('duration_addition'):
			fields['duration'] = base_row.duration * (1 + table.Upgrade[group]['duration_addition'][currentlevel])
		if table.Upgrade[group].has('range_addition'):
			var sizes: Array = []
			for i in base_row.size.size():
				sizes.append(base_row.size[i] * (1 + table.Upgrade[group]['range_addition'][currentlevel]))
			fields['size'] = sizes
		if not fields.is_empty():
			RunModifiers.set_row_fields('Attack', id, fields)
		SignalBus.renew_state.emit(id)


func up_summon(group, currentlevel) -> void:
	if currentlevel == table.Upgrade[group].level:
		return
	for id in summon_group.get(group, []):
		var base_row = table.get_base_row('Summoned', id)
		var fields: Dictionary = {}
		if table.Upgrade[group].has('duration_addition'):
			fields['duration'] = base_row.duration * (1 + table.Upgrade[group]['duration_addition'][currentlevel])
		if table.Upgrade[group].has('cd_reduction'):
			fields['cd'] = base_row.cd / (1.0 + table.Upgrade[group]['cd_reduction'][currentlevel])
		if not fields.is_empty():
			RunModifiers.set_row_fields('Summoned', id, fields)
			SignalBus.renew_state.emit(id)
		SignalBus.renew_state.emit(id)
