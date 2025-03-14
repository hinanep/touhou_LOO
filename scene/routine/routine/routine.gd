class_name routine extends Node2D

var active = true
var routine_modifier = {
	"on_hit":[],
	"on_flying":[],
	"on_emit":[],
	"on_destroy":[]
}

var routine_info = {

  }

var gen_position
var gen_rotation
var attack_nodes = []
var summons = {}
var level = 0
var damage_source = ''
func _ready():
	name = routine_info.id
	add_to_group(routine_info.id)
	SignalBus.trigger_routine_by_id.connect(called)
	if routine_info.has("upgrade_group"):
		add_to_group(routine_info.upgrade_group)
	if routine_info.has("effective_condition"):
		add_to_group(routine_info.effective_condition)
	if routine_info.has("creating_attack"):
		for id in routine_info.creating_attack:
			add_attack(id)

	if routine_info.has('creating_summoned'):
		for summon in routine_info.creating_summoned:
			var spre = PresetManager.getpre(summon)

			summons[summon] = spre



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
			gen_rotation = player_var.player_node.rotation
		'world':
			gen_rotation = 0
		'input':
			gen_rotation = input_rotation


	var add_vector
	match routine_info.system_type:

		'rectangular':
			add_vector =Vector2(routine_info.position[0],routine_info.position[1])
			pass
		'polar':
			add_vector =Vector2.from_angle(rad_to_deg( routine_info.gen_position[1]))*routine_info.gen_position[0]
	gen_position += add_vector

func called(routine_id,force_world_position,input_position,input_rotation,parent_node):
	if routine_id != routine_info.id:
		return

	if parent_node == null:
		parent_node = $"."


	attacks(force_world_position,input_position,input_rotation,true,parent_node)

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


func single_attack(generate_position,generate_rotation,parent_node ):
	#AudioManager.play_sfx(routine_info["shoot_sfx"])
	if routine_info.has('special_creating_attack'):
		match routine_info.special_creating_attack:
			'probability':
				var new_attack = attack_nodes[select_from_luck()].duplicate()
				if parent_node != $".":


					new_attack.position = generate_position
					new_attack.rotation = generate_rotation
				else:

					new_attack.global_position = generate_position
					new_attack.rotation = generate_rotation

				parent_node.add_child(new_attack)

	else:
		for attack_node in attack_nodes:
			if parent_node != null:
				var new_attack = attack_node.duplicate()

				if parent_node != $".":
						new_attack.global_position = parent_node.global_position + gen_position
						new_attack.rotation = generate_rotation
				else:
						new_attack.global_position = generate_position
						new_attack.rotation = generate_rotation

				parent_node.add_child(new_attack)
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
		for summon_id in summons:
			var new_summon = summons[summon_id].instantiate()
			new_summon.summon_info = table.Summoned[summon_id]
			new_summon.global_position = generate_position
			new_summon.rotation = generate_rotation
			$".".add_child(new_summon)


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

func upgrade_routine():
	level += 1

	pass

func set_upgrade(nlevel:int):
	level = nlevel
	pass


func add_attack(id):
	var attack_info = table.Attack[id]

	#var attack_pre = PresetManager.getpre('attack').instantiate()
	var attack_pre = load("res://scene/attack/attack_ins/"+id+".tscn").instantiate()

	attack_pre.attack_info = attack_info
	attack_pre.node_active = false
	attack_pre.set_upgrade(level)
	attack_pre.damage_source = damage_source
	for modi in routine_modifier:
		attack_pre.attack_modifier[modi].append(routine_modifier[modi])
	add_child(attack_pre)
	attack_nodes.append(attack_pre)

func add_summon(id):
	var summon_info = table.Summoned[id]


	var summon_pre = load("res://scene/attack/attack_ins/"+id+".tscn").instantiate()

	summon_pre.summon_info = summon_info
	summon_pre.node_active = false
	summon_pre.set_upgrade(level)
	summon_pre.damage_source = damage_source
	#for modi in routine_modifier:
		#summon_pre.attack_modifier[modi].append(routine_modifier[modi])
	add_child(summon_pre)
	summons.append(summon_pre)

func destroy():
	for child in get_children():
		if child.has_method('destroy'):
			child.destroy('routine_destroy')
	queue_free()
