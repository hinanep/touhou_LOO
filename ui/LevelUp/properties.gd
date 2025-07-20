extends VBoxContainer

# 存储所有创建的pp预制体实例
var pp_list = []

# 攻击类属性列表
var attack_properties = [
	"player_melee_damage_ratio",
	"player_bullet_damage_ratio",
	"bullet_speed_ratio",
	"bullet_duration_ratio",
	"range_add_ratio",
	"danma_times",
	"melee_times",
	"colddown_reduce"
]

# 防御类属性列表
var defense_properties = [
	"player_hp_max",
	"hp_max_ex_percent",
	"player_hp_regen",
	"lifesteal",
	"player_speed",
	"player_life_addi",
	"defence_melee",
	"defence_bullet",
	"invincible_time"
]

# 成长类属性列表
var growth_properties = [
	"range_pick",
	"luck",
	"experience_ratio",
	"point_ratio",
	"mana_ratio",
	"change_times",
	"curse",
	"mana_max"
]

# 属性名称映射（用于显示中文名称）
var property_names = {
	"player_melee_damage_ratio": "体术伤害倍率",
	"player_bullet_damage_ratio": "弹幕伤害倍率",
	"bullet_speed_ratio": "子弹速度比率",
	"bullet_duration_ratio": "持续时间",
	"range_add_ratio": "攻击范围",
	"danma_times": "弹幕发射数量加成",
	"melee_times": "体术攻击次数",
	"colddown_reduce": "冷却缩减",
	"player_hp_max": "生命上限",
	"hp_max_ex_percent": "百分比生命上限",
	"player_hp_regen": "每秒生命回复",
	"lifesteal": "吸血",
	"player_speed": "移动速度",
	"player_life_addi": "残机",
	"defence_melee": "体术防御",
	"defence_bullet": "弹幕防御",
	"invincible_time": "受伤后无敌时间",
	"range_pick": "拾取范围",
	"luck": "幸运",
	"experience_ratio": "经验倍率",
	"point_ratio": "得点倍率",
	"mana_ratio": "符力倍率",
	"change_times": "刷新排除次数",
	"curse": "诅咒",
	"mana_max": "符力上限"
}

# 存储预览的属性变化
var preview_changes = {}

func _ready():
	gen_properties()
	pass
func _physics_process(delta: float) -> void:
	update_all_properties()

func gen_properties():
	# 清空现有列表
	for pp in pp_list:
		pp.queue_free()
	pp_list.clear()

	# 获取pp预制体
	var pp_scene = PresetManager.getpre('property_text')

	# 创建攻击类属性显示
	create_property_section("攻击类属性", attack_properties, pp_scene)

	# 创建防御类属性显示
	create_property_section("防御类属性", defense_properties, pp_scene)

	# 创建成长类属性显示
	create_property_section("成长类属性", growth_properties, pp_scene)

func create_property_section(section_name: String, properties: Array, pp_scene: PackedScene):
	# 创建分类标题
	var title_pp = pp_scene.instantiate()
	add_child(title_pp)
	pp_list.append(title_pp)
	set_pp_text(title_pp, "[color=yellow]" + section_name + "[/color]")

	# 创建每个属性的显示
	for property in properties:
		var pp = pp_scene.instantiate()
		add_child(pp)
		pp_list.append(pp)
		update_property_text(pp, property)

func update_property_text(pp, property_name: String):
	var property_value = player_var.get(property_name)
	var display_name = property_names.get(property_name, property_name)

	# 格式化数值显示
	var value_text = ""
	if property_value != null:
		if property_value is float:
			value_text = "%.2f" % property_value
		elif property_value is int:
			value_text = str(property_value)
		else:
			value_text = str(property_value)
	else:
		value_text = "未设置"

	# 检查是否有预览变化
	if preview_changes.has(property_name):
		var preview_value = preview_changes[property_name]
		var preview_text = ""
		if preview_value is float:
			preview_text = "%.2f" % preview_value
		elif preview_value is int:
			preview_text = str(preview_value)
		else:
			preview_text = str(preview_value)
		value_text += " -> " + preview_text

	set_pp_text(pp, display_name + ": " + value_text)

func set_pp_text(pp, text):
	pp.text = text

# 更新所有属性显示
func update_all_properties():
	for i in range(pp_list.size()):
		var pp = pp_list[i]
		# 跳过标题行
		if i == 0 or i == len(attack_properties) + 1 or i == len(attack_properties) + len(defense_properties) + 2:
			continue

		# 计算当前属性在哪个分类中
		var property_index = 0
		var current_properties = []

		if i <= len(attack_properties):
			current_properties = attack_properties
			property_index = i - 1
		elif i <= len(attack_properties) + len(defense_properties) + 1:
			current_properties = defense_properties
			property_index = i - len(attack_properties) - 2
		else:
			current_properties = growth_properties
			property_index = i - len(attack_properties) - len(defense_properties) - 3

		if property_index >= 0 and property_index < current_properties.size():
			update_property_text(pp, current_properties[property_index])

# 设置属性变化预览
func set_property_preview(property_name: String, new_value):
	preview_changes[property_name] = new_value

# 清除属性变化预览
func clear_property_preview(property_name: String = ""):
	if property_name.is_empty():
		preview_changes.clear()
	else:
		preview_changes.erase(property_name)

# 批量设置多个属性的变化预览
func set_multiple_property_previews(changes: Dictionary):
	for property_name in changes:
		preview_changes[property_name] = changes[property_name]

# 根据技能ID设置属性变化预览
func set_skill_preview(skill_id: String):
	clear_property_preview()

	# 这里可以根据技能ID来设置预期的属性变化
	# 示例：根据技能类型设置不同的属性变化
	if table.Skill.has(skill_id):
		var skill_info = table.Skill[skill_id]

		# 根据技能类型设置预览变化
		match skill_info.get("type", ""):
			"attack":
				# 攻击类技能可能影响伤害相关属性
				var current_damage = 1.0
				if player_var.has("player_bullet_damage_ratio"):
					current_damage = player_var.get("player_bullet_damage_ratio")
				set_property_preview("player_bullet_damage_ratio", current_damage + 0.5)

				var current_speed = 1.0
				if player_var.has("bullet_speed_ratio"):
					current_speed = player_var.get("bullet_speed_ratio")
				set_property_preview("bullet_speed_ratio", current_speed + 0.2)

			"defense":
				# 防御类技能可能影响生命相关属性
				var current_hp = 100
				if player_var.has("player_hp_max"):
					current_hp = player_var.get("player_hp_max")
				set_property_preview("player_hp_max", current_hp + 50)

				var current_defense = 0
				if player_var.has("defence_bullet"):
					current_defense = player_var.get("defence_bullet")
				set_property_preview("defence_bullet", current_defense + 0.3)

			"growth":
				# 成长类技能可能影响经验相关属性
				var current_exp_ratio = 1.0
				if player_var.has("experience_ratio"):
					current_exp_ratio = player_var.get("experience_ratio")
				set_property_preview("experience_ratio", current_exp_ratio + 0.2)

				var current_luck = 0
				if player_var.has("luck"):
					current_luck = player_var.get("luck")
				set_property_preview("luck", current_luck + 1)

			_:
				# 默认情况，根据技能描述或其他逻辑设置
				pass

# 根据被动技能ID设置属性变化预览
func set_passive_preview(passive_id: String):
	clear_property_preview()

	if table.Passive.has(passive_id):
		var passive_info = table.Passive[passive_id]

		# 根据被动技能的效果设置预览
		if passive_info.has("buff"):
			for buff_id in passive_info.buff:
				if table.Buff.has(buff_id):
					var buff_info = table.Buff[buff_id]
					var property_name = buff_info.get("property", "")
					var current_value = 0
					if player_var.has(property_name):
						current_value = player_var.get(property_name)
					var new_value = current_value + buff_info.get("base_buff_value", 0)
					set_property_preview(property_name, new_value)

# 根据符卡ID设置属性变化预览
func set_card_preview(card_id: String):
	clear_property_preview()

	if table.SpellCard.has(card_id):
		var card_info = table.SpellCard[card_id]

		# 根据符卡效果设置预览
		# 这里可以根据符卡的具体效果来设置属性变化
		# 示例：
		var current_damage = 1.0
		if player_var.has("player_bullet_damage_ratio"):
			current_damage = player_var.get("player_bullet_damage_ratio")
		set_property_preview("player_bullet_damage_ratio", current_damage + 1.0)

		var current_mana = 100
		if player_var.has("mana_max"):
			current_mana = player_var.get("mana_max")
		set_property_preview("mana_max", current_mana + 20)
