## GlobalSignalBus.gd (或者根据你的项目命名)
##
## 一个全局的信号总线/事件管理器节点 (通常用作 Autoload/单例)。
## 定义了游戏中各种系统之间通信所需的信号。
## 这样做可以解耦各个系统，例如玩家 (Player)、技能系统 (SkillSystem)、
## 卡牌系统 (CardSystem)、UI 等，它们只需要连接到这个总线上的相关信号，
## 而不需要直接相互引用。
##
## 还包含一个可选的调试日志功能，可以在开发过程中打印出被触发的信号。
extends Node

# ==================== 技能 (Skill) 相关信号 ====================
## 尝试添加技能时发出 (例如：玩家选择、捡起道具、升级选择时)。
## 其他系统可以监听此信号来验证是否满足添加条件。
## @param id: Variant - 通常是技能的唯一标识符 (如 String 或 int)。
signal try_add_skill(id)
## 在确认满足添加技能的条件后发出。
## @param skill_info: Dictionary/Object - 包含要添加技能的详细信息。
signal add_skill(skill_info)
## 尝试删除/移除某个技能时发出。
## @param id: Variant - 要删除的技能的唯一标识符。
signal del_skill(id)
## 尝试禁用/Ban 某个技能时发出 (使其无法被获取或使用)。
## @param id: Variant - 要禁用的技能的唯一标识符。
signal ban_skill(id)

# ==================== 行为/效果触发 (Routine Trigger) ====================
## 请求触发一个预定义的行为或效果序列 (Routine)。
## 常用于触发技能效果、视觉特效、生成弹幕等。
## @param routine_id: Variant - 要触发的行为的唯一标识符。
## @param force_world_position: Vector2/Vector3 (可选) - 强制在指定的全局位置触发。
## @param input_position: Vector2/Vector3 (可选) - 输入的位置信息 (例如鼠标点击位置)。
## @param input_rotation: float/Vector3 (可选) - 输入的旋转信息。
## @param parent_node: Node (可选) - 指定生成效果的父节点。
signal trigger_routine_by_id(routine_id, force_world_position, input_position, input_rotation, parent_node)

# ==================== 卡牌 (Card) 相关信号 ====================
## 尝试添加卡牌时发出。
## @param id: Variant - 卡牌的唯一标识符。
signal try_add_card(id)
## 确认添加卡牌后发出。
## @param card_info: Dictionary/Object - 包含卡牌的详细信息。
signal add_card(card_info)
## 尝试删除/移除卡牌时发出。
## @param id: Variant - 要删除的卡牌的唯一标识符。
signal del_card(id)
## 尝试禁用/Ban 卡牌时发出。
## @param id: Variant - 要禁用的卡牌的唯一标识符。
signal ban_card(id)
## 玩家尝试使用卡牌时发出 (可能在使用前需要检查条件或消耗资源)。
## @param id: Variant - 要使用的卡牌的唯一标识符。
## @param cost_rate: float (可选) - 使用卡牌的成本倍率 (例如，某些效果可能增加消耗)。
signal use_card(id, cost_rate)
## 确认卡牌成功使用后发出 (条件满足，资源已消耗)。
## @param id: Variant - 成功使用的卡牌的唯一标识符。
signal true_use_card(id)
## 请求切换卡牌选择时发出 (例如按左右键切换)。
## @param bias: int - 切换方向和幅度 (例如 +1 向右切换一个，-1 向左切换一个)。
signal card_select_next(bias)
## 在特定的 "操作板" (Plate) 上使用卡牌时发出 (可能指代某种特殊的 UI 或游戏区域)。
signal plate_use_card

# ==================== 被动技能 (Passive) 相关信号 ====================
## 尝试添加被动技能时发出。
## @param id: Variant - 被动技能的唯一标识符。
signal try_add_passive(id)
## 确认添加被动技能后发出。
## @param psv_info: Dictionary/Object - 包含被动技能的详细信息。
signal add_passive(psv_info)
## 尝试删除/移除被动技能时发出。
## @param id: Variant - 要删除的被动技能的唯一标识符。
signal del_passive(id)
## 尝试禁用/Ban 被动技能时发出。
## @param id: Variant - 要禁用的被动技能的唯一标识符。
signal ban_passive(id)

# ==================== 玩家状态 (Player Status) 相关信号 ====================
## 玩家受到伤害时发出。
signal player_hurt
## 给予玩家短暂无敌状态时发出。
## @param seconds: float - 无敌状态的持续时间（秒）。
signal player_invincible(seconds)
## 给玩家添加状态效果 (Buff) 时发出。
## @param buff_id: Variant - Buff 的唯一标识符。
## @param buff_intensity: float/int (可选) - Buff 的强度或层数。
## @param buff_source: Variant (可选) - Buff 的来源标识 (用于区分和管理)。
signal player_add_buff(buff_id, buff_intensity, buff_source)
## 根据来源移除玩家身上的 Buff 时发出。
## @param source: Variant - 要移除的 Buff 的来源标识。
signal player_del_buff_by_source(source)

# ==================== 特殊技能/符卡 (Spellcard) ====================
## 施放符卡/大招时发出。
signal spellcard_cast

# ==================== 升级 (Upgrade) 相关信号 ====================
## 当某个升级组满足升级条件时发出 (例如，某系列技能达到特定等级组合)。
## @param group: Variant - 升级组的标识符。
signal upgrade_group(group)
## 当某个东西 (技能、属性等) 达到最高等级时发出。
## @param anyname: Variant - 达到最高级的项目名称或标识符。
signal upgrade_max(anyname)
## 激活某个 CP (组件/特性点/?) 时发出。
## @param cp_info: Dictionary/Object - 激活的 CP 的信息。
signal cp_active(cp_info)
## 删除/移除某个 CP 时发出。
## @param cp_id: Variant - 要删除的 CP 的标识符。
signal cp_del(cp_id)

# ==================== 增益 (Boost) 相关信号 ====================
## 应用攻击相关的增益时发出。
## @param attack_info: Dictionary/Object - 包含攻击增益的详细信息 (如增幅、持续时间等)。
signal atk_boost(attack_info)
## 应用召唤物相关的增益时发出。
## @param sum_info: Dictionary/Object - 包含召唤物增益的详细信息。
signal sum_boost(sum_info)

# ==================== 掉落物 (Drop) 相关信号 ====================
## 请求在指定位置生成掉落物时发出。
## @param id: Variant - 掉落物的类型标识符 (如 'exp', 'mana', 'item_id')。
## @param global_position: Vector2/Vector3 - 掉落物生成的全局位置。
## @param value: Variant (可选) - 掉落物的数值 (例如经验值数量、金币数量)。
signal drop(id, global_position, value)
## 通知掉落物 (经验、法力、分数等) 开始飞向玩家。
## 可以携带一些影响最终获取量的 Buff 信息。
## @param exp_buff: float - 经验获取倍率/加成。
## @param mana_buff: float - 法力获取倍率/加成。
## @param score_buff: float - 分数获取倍率/加成。
## @param point_ratio_buff: float - 点数 (?) 获取倍率/加成。
signal fly_to_player(exp_buff, mana_buff, score_buff, point_ratio_buff)

signal d4c_create(id,position,parent,damage)
# ==================== 调试/控制 相关信号 ====================
signal clear_enemy(not_drop:bool)
signal pause_spawner(is_pause:bool)
signal add_mob_to_manager(mob_node)
signal boss_set_stage(stage:int)
signal kill_all
signal set_bosstimer(time:float)
signal shutter
# ==================== 调试日志 (Debug Log) ====================
## 是否启用信号发射日志记录功能。设置为 true 时，大部分信号触发时会在控制台打印信息。
@export var is_log: bool = false # 在编辑器中勾选以启用日志

## 初始化函数。如果 is_log 为 true，则连接所有信号到日志处理函数。
func _ready() -> void:
	if is_log:
		var signal_dic: Array = get_signal_list() # 获取此脚本定义的所有信号

		for sig in signal_dic:
			var signal_name: StringName = sig["name"]
			# 避免连接过于频繁或复杂的信号，以免日志刷屏
			if signal_name == &"trigger_routine_by_id":
				continue
			if signal_name == &"fly_to_player": # 这个也可能很频繁
				continue

			# 连接信号到 _on_signal_emit 函数。
			# 使用 bind 将信号名称作为参数传递给处理函数，以便知道是哪个信号触发了。
			# 注意：这里只绑定了信号名称到 message2 参数。
			var callable = Callable(self, "_on_signal_emit")
			var bound_callable = callable.bind('[color=green][b]SIGNAL EMITTED:[/b][/color] ' + str(signal_name))
			var err = connect(signal_name, bound_callable)
			if err != OK:
				printerr("Failed to connect signal for logging: ", signal_name, " Error code: ", err)


## 当 is_log 为 true 时，处理已连接信号的发射事件，并打印日志。
## 注意：这个函数的设计主要是为了打印触发的 *信号名称*。
## 它声明了多个参数 (message1-message6) 来尝试捕获信号可能传递的参数，
## 但由于 _ready 中 bind 的方式，只有 message2 会稳定接收到信号名称字符串。
## 如果信号实际传递了参数，它们可能（但不保证）会被 message1, message3 等捕获，
## 具体取决于信号参数的数量和类型与这些函数参数的匹配程度。
## 主要目的是调试，查看哪些事件正在发生。
func _on_signal_emit(
		message1 = "", # 可能捕获信号的第1个参数 (如果存在且类型匹配)
		message2 = "", # 接收由 bind() 传入的信号名称字符串
		message3 = "", # 可能捕获信号的第2个参数
		message4 = "", # 可能捕获信号的第3个参数
		message5 = "", # 可能捕获信号的第4个参数
		message6 = ""  # 可能捕获信号的第5个参数
	) -> void:

		print_rich("[color=yellow][b]------[/b][/color]") # 分隔符

		# 打印由 bind 传入的信号名称 (放在 message2)
		print_rich(message2)

		# 尝试打印其他可能捕获到的参数
		print_rich("  Arg1: " + str(message1))
		print_rich("  Arg2: " + str(message3))
		print_rich("  Arg3: " + str(message4))
		print_rich("  Arg4: " + str(message5))
		print_rich("  Arg5: " + str(message6))

		print_rich("[color=yellow][b]------[/b][/color]") # 分隔符
