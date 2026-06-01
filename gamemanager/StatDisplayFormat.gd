extends RefCounted
class_name StatDisplayFormat

## player_var 语义为整数的属性，显示时不带小数
const INTEGER_PROPERTIES: Array[StringName] = [
	&"player_life_addi",
	&"change_times",
	&"free_card",
	&"level",
	&"point",
	&"max_point",
	&"skill_level_max",
	&"skill_num_max",
	&"card_level_max",
	&"card_num_max",
	&"summon_level_max",
	&"passive_num_max",
]

## 内部为 float，但 UI 上以整数向下取整展示的资源类属性
const FLOOR_DISPLAY_PROPERTIES: Array[StringName] = [
	&"player_hp",
	&"player_hp_max",
	&"mana",
	&"mana_max",
	&"player_exp",
]


## 按属性名格式化 player_var / 升级表数值
static func format_property(property_name: StringName, value: Variant) -> String:
	if value == null:
		return "未设置"
	if property_name in INTEGER_PROPERTIES:
		return str(int(floor(float(value))))
	if property_name in FLOOR_DISPLAY_PROPERTIES:
		return str(int(floor(float(value))))
	if value is int:
		return str(value)
	if value is float:
		return "%.2f" % value
	return str(value)


## HUD 资源条数值：向下取整为整数文本
static func format_hud_value(value: Variant) -> String:
	return str(int(floor(float(value))))
