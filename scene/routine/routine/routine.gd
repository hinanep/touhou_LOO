class_name routine extends Node2D

var active = true


var routine_info = {

  }

var gen_position
var gen_rotation
var attack_nodes = []
var summons = []
var level = 0
var damage_source = ''

#初始化
func _ready():
	name = routine_info.id
	add_to_group(routine_info.id)
	SignalBus.trigger_routine_by_id.connect(called)
	SignalBus.upgrade_group.connect(upgrade_routine)

	for atk in table.Attack:
		if table.Attack[atk].routine_group == routine_info.id:
			var atknode = add_attack(atk)
			if routine_info.has('creating_attack') and atk in routine_info.creating_attack:
				attack_nodes.append(atknode)

	for sum in table.Summoned:
		if table.Summoned[sum].routine_group == routine_info.id:
			var sumnode = add_summon(sum)
			if routine_info.has('creating_summoned') and sum in routine_info.creating_summoned:
				summons.append(sumnode)

	#if routine_info.has("creating_attack"):
		#for id in routine_info.creating_attack:
			#attack_nodes.append(add_attack(id))

	#if routine_info.has('creating_summoned'):
		#for sum in routine_info.creating_summoned:
			#var spre = PresetManager.getpre(sum)
#
			#summons[sum] = spre


#根据表中对应项获取攻击生成位置
func get_gen_position(force_world_position:bool,input_position,input_rotation):
	if force_world_position:
		gen_position = input_position
		gen_rotation = input_rotation
		return
	match routine_info.zero_point:
		'character':
			gen_position = player_var.player_node.global_position

		'input':
			gen_position = input_position


	match routine_info.system_front:
		'character':
			gen_rotation = player_var.player_diretion_angle
		'world':
			gen_rotation = 0
		'input':
			gen_rotation = input_rotation


	var add_vector
	match routine_info.system_type:

		'rectangular':
			add_vector =Vector2(routine_info.position[0],routine_info.position[1])

		'polar':
			add_vector =Vector2.from_angle(rad_to_deg( routine_info.gen_position[1]))*routine_info.gen_position[0]
	gen_position += add_vector.rotated(gen_rotation)

#外部调用生成接口，由信号总线中 trigger_routine_by_id 控制，输入：调用招式id，强制输入对应世界坐标生成，输入位置，输入旋转，强制父节点（使生成攻击作为其子节点（生成攻击通常作为本招式子节点））
func called(routine_id,force_world_position,input_position,input_rotation,parent_node):
	if routine_id != routine_info.id:
		return

	if parent_node == null:
		parent_node = $"."


	attacks(force_world_position,input_position,input_rotation,true,parent_node)

#生成所有攻击，与单次相比可以控制多个单次间的间隔时间，生成次数等
func attacks(force_world_position=false,input_position=Vector2(0,0),input_rotation=0,has_interval=true,parent_node = $"."):

	for i in range(int(routine_info.times +player_var.danma_times * routine_info.danma_times_efficiency)):

		match routine_info.one_creating_type:
			'single':
					if has_interval:
						await  get_tree().create_timer(routine_info.interval).timeout
					get_gen_position(force_world_position,input_position,input_rotation)
					single_attack(gen_position,gen_rotation,parent_node)
					single_summon(gen_position,gen_rotation)

			'multi_together':
				for j in range(routine_info.one_creating_parameter[0]):
					if has_interval:
						await  get_tree().create_timer(routine_info.interval).timeout
					get_gen_position(force_world_position,input_position,input_rotation)
					single_attack(gen_position,gen_rotation,parent_node)
					single_summon(gen_position,gen_rotation)

#生成单次攻击,在传入父节点时认为生成坐标是相对父节点的坐标，否则是世界坐标
func single_attack(generate_position,generate_rotation,parent_node ):
	#AudioManager.play_sfx(routine_info["shoot_sfx"])
	if routine_info.has('special_creating_attack'):
		match routine_info.special_creating_attack:
			'probability':
				var new_attack = attack_nodes[select_from_luck()].duplicate()
				if parent_node != $".":


					new_attack.position = generate_position
					#new_attack.rotation = generate_rotation
				else:

					new_attack.global_position = generate_position
					#new_attack.rotation = generate_rotation

				parent_node.add_child(new_attack)

	else:
		for attack_node in attack_nodes:
			if parent_node != null:
				var new_attack = attack_node.duplicate()

				if parent_node != $".":
						new_attack.global_position = parent_node.global_position + gen_position
						#new_attack.rotation = generate_rotation
				else:
						new_attack.global_position = generate_position
						#new_attack.rotation = generate_rotation

				parent_node.add_child(new_attack)

#生成单次召唤物 TODO：随机种类召唤物
func single_summon(generate_position,generate_rotation):

	#if routine_info.has('special_creating_attack'):
		#match routine_info.special_creating_attack:
			#'probability':
				#var new_attack = attack_nodes[select_from_luck()].duplicate()
#
				#new_attack.global_position = generate_position
				#new_attack.rotation = generate_rotation
				#$".".add_child(new_attack)
#
	#else:
		for sumnode in summons:
			var new_sum  = sumnode.duplicate()
			new_sum.global_position = generate_position
			$".".add_child(new_sum)
		#for summon_id in summons:
			#var new_summon = summons[summon_id].instantiate()
			#new_summon.summon_info = table.Summoned[summon_id]
			#new_summon.global_position = generate_position
			##new_summon.rotation = generate_rotation
			#$".".add_child(new_summon)

#随机生成使用，根据幸运返回选择生成的攻击 TODO：解耦合，实现根据输入与幸运返回
func select_from_luck():
	var sum = 0
	var weight_delta = []
	for i in range(routine_info.special_creating_attack_parameter.size()/2):
		var tmp =  routine_info.special_creating_attack_parameter[i*2] *pow(1+player_var.luck, routine_info.special_creating_attack_parameter[i*2+1])
		sum += tmp
		weight_delta.append(tmp)
	var r = randf_range(0,sum)
	for i in range(routine_info.special_creating_attack_parameter.size()/2):
		r -= weight_delta[i]
		if r<0:
			return i

#根据group升级招式，level1没有属性提升且算法会数组越界所以特判
func upgrade_routine(group):
	if not routine_info.has("upgrade_group"):
		return
	if routine_info.upgrade_group != group:
		return
	level += 1
	if level == 1:
		return
	routine_info.times += table.Upgrade[group].times_addition[level-1] - table.Upgrade[group].times_addition[level-2]

#招式初始化时使用，按表将需要使用的攻击加入子节点并使其休眠，生成攻击时复制其
func add_attack(id):
	var attack_info = table.Attack[id]

	#var attack_pre = PresetManager.getpre('attack').instantiate()

	var attack_pre = load("res://scene/attack/attack_ins/"+id+".tscn").instantiate()

	attack_pre.attack_info = attack_info
	attack_pre.node_active = false
	attack_pre.damage_source = damage_source

	add_child(attack_pre)
	return attack_pre


#招式初始化时使用，按表将需要使用的召唤物加入子节点并使其休眠，生成攻击时复制其
func add_summon(id):
	var summon_info = table.Summoned[id]

	var summon_pre = load("res://scene/summon/summon_ins/"+id+".tscn").instantiate()

	summon_pre.summon_info = summon_info
	summon_pre.node_active = false
	summon_pre.damage_source = damage_source

	add_child(summon_pre)
	return summon_pre

#销毁所有子节点，销毁招式
func destroy():
	for child in get_children():
		if child.has_method('destroy'):
			child.destroy('routine_destroy')
	queue_free()
