# BattleUtils.gd (添加到 Autoload)
class_name BattleUtils
# 计算生成位置和旋转，返回一个 Transform2D
static func calculate_spawn_transform(routine_info: Dictionary, player_node: Node, input_position: Vector2, input_rotation: float) -> Transform2D:
	var final_position: Vector2
	var final_rotation: float

	# 计算基准位置
	match routine_info.zero_point:
		'character':
			final_position = player_node.global_position
		'input':
			final_position = input_position
		_:
			final_position = Vector2.ZERO # 提供一个默认值

	# 计算基准旋转
	match routine_info.system_front:
		'character':
			final_rotation = player_node.global_rotation # 使用全局旋转更稳妥
		'world':
			final_rotation = 0.0
		'input':
			final_rotation = input_rotation
		_:
			final_rotation = 0.0 # 提供一个默认值

	# 计算偏移向量
	var offset_vector: Vector2
	match routine_info.system_type:
		'rectangular':
			offset_vector = Vector2(routine_info.position[0], routine_info.position[1])
		'polar':
			# 注意：Godot 的角度单位是弧度，rad_to_deg 可能不是必须的
			offset_vector = Vector2.from_angle(routine_info.gen_position[1]) * routine_info.gen_position[0]
		_:
			offset_vector = Vector2.ZERO

	# 应用旋转并添加到最终位置
	final_position += offset_vector.rotated(final_rotation)

	return Transform2D(final_rotation, final_position)
