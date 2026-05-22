extends Node
## 局内配置叠加：在只读 table 基表之上合并升级覆盖与羁绊 CP 补丁，供 resolve 查询有效行。

var _row_overrides: Dictionary = {}
var _cp_patches: Dictionary = {}


func clear() -> void:
	_row_overrides.clear()
	_cp_patches.clear()


func set_row_fields(table_name: String, row_id: String, fields: Dictionary) -> void:
	if fields.is_empty():
		return
	if not _row_overrides.has(table_name):
		_row_overrides[table_name] = {}
	if not _row_overrides[table_name].has(row_id):
		_row_overrides[table_name][row_id] = {}
	for key in fields.keys():
		var value = fields[key]
		if value is Array:
			_row_overrides[table_name][row_id][key] = value.duplicate()
		else:
			_row_overrides[table_name][row_id][key] = value


func resolve(table_name: String, row_id: String) -> Dictionary:
	var base_row = table.get_base_row(table_name, row_id)
	if base_row.is_empty():
		return {}
	var result = base_row.duplicate(true)
	_merge_dict_into(result, _row_overrides.get(table_name, {}).get(row_id, {}))
	_apply_all_cp_patches(result, table_name, row_id)
	return result


func duplicate_resolved_table(table_name: String) -> Dictionary:
	var base_table = table.get_base_table(table_name)
	var resolved: Dictionary = {}
	for row_id in base_table.keys():
		resolved[row_id] = resolve(table_name, row_id)
	return resolved


func register_cp_row_patch(
	cp_id: String,
	table_name: String,
	row_id: String,
	boost_info: Dictionary,
	is_active: bool
) -> void:
	if not _cp_patches.has(cp_id):
		_cp_patches[cp_id] = {}
	if not is_active:
		if _cp_patches[cp_id].has(table_name):
			_cp_patches[cp_id][table_name].erase(row_id)
		return
	var base_row = _resolve_with_upgrades_only(table_name, row_id)
	var working = base_row.duplicate(true)
	_apply_boost_fields(boost_info, working, true)
	if not _cp_patches[cp_id].has(table_name):
		_cp_patches[cp_id][table_name] = {}
	_cp_patches[cp_id][table_name][row_id] = _extract_field_overrides(base_row, working)


func _resolve_with_upgrades_only(table_name: String, row_id: String) -> Dictionary:
	var base_row = table.get_base_row(table_name, row_id)
	if base_row.is_empty():
		return {}
	var result = base_row.duplicate(true)
	_merge_dict_into(result, _row_overrides.get(table_name, {}).get(row_id, {}))
	return result


func _apply_all_cp_patches(result: Dictionary, table_name: String, row_id: String) -> void:
	for cp_id in _cp_patches.keys():
		var table_map = _cp_patches[cp_id].get(table_name, {})
		if not table_map.has(row_id):
			continue
		_merge_dict_into(result, table_map[row_id])


func _merge_dict_into(target: Dictionary, patch: Dictionary) -> void:
	for key in patch.keys():
		var patch_value = patch[key]
		if patch_value is Array:
			target[key] = patch_value.duplicate()
		else:
			target[key] = patch_value


func _extract_field_overrides(base_row: Dictionary, modified_row: Dictionary) -> Dictionary:
	var overrides: Dictionary = {}
	for key in modified_row.keys():
		if not base_row.has(key):
			overrides[key] = _duplicate_value(modified_row[key])
			continue
		if not _values_equal(base_row[key], modified_row[key]):
			overrides[key] = _duplicate_value(modified_row[key])
	return overrides


func _duplicate_value(value) -> Variant:
	if value is Array:
		return value.duplicate()
	if value is Dictionary:
		return value.duplicate(true)
	return value


func _values_equal(a, b) -> bool:
	if a is Array and b is Array:
		return a == b
	return a == b


func _apply_boost_fields(boost_info: Dictionary, row: Dictionary, is_active: bool) -> void:
	for key in boost_info.keys():
		if key in ['id', 'type', 'routine_group', 'effective_condition', 'upgrade_group']:
			continue
		if boost_info[key] is bool:
			continue
		if not is_active:
			if not row.has(key):
				continue
			match typeof(boost_info[key]):
				TYPE_ARRAY:
					for element in boost_info[key]:
						if row[key].has(element):
							row[key].erase(element)
				_:
					if typeof(row[key]) in [TYPE_INT, TYPE_FLOAT]:
						row[key] -= boost_info[key]
			continue
		if not row.has(key):
			match typeof(boost_info[key]):
				TYPE_ARRAY:
					row[key] = boost_info[key].duplicate()
				_:
					row[key] = boost_info[key]
		else:
			match typeof(row[key]):
				TYPE_ARRAY:
					for element in boost_info[key]:
						if not row[key].has(element):
							row[key].append(element)
				_:
					row[key] += boost_info[key]
