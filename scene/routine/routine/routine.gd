class_name routine extends Node2D

var active = true
var routine_modifier = {
	"on_hit":[],
	"on_flying":[],
	"on_emit":[],
	"on_destroy":[]
}

var routine_info = {
	"routine_name": "rou_reimu",
	"group_id": "rou_reimu",
	"upgrade_group": "upg_reimu",
	"type": "base",
	"damage_type": "danma",
	"effective_group": "none",
	"locking_type": "none",
	"locking_parameter": [],
	"special_creating_attack": "none",
	"special_creating_attack_parameter": [],
	"creating_attack": [
	  "atk_reimu_base"
	],
	"special_creating_summoned": "none",
	"special_creating_summoned_parameter": [],
	"creating_summoned": [],
	"special_creating": "none",
	"once_creating_type": "single",
	"once_creating_parameter": [],
	"times_depend": "none",
	"times": 3,
	"interval": 0.2,
	"zeropoint": "input",
	"system_front": "input",
	"system_type": "rectangular",
	"position_depend": [
	  "none,none"
	],
	"gen_position": [
	  0,
	  0
	],
	"danma_times_efficiency": 1.0,
	"melee_times_efficiency": 0.0
  }

var gen_position
var gen_rotation
var attack_nodes = []
var level = 0
var damage_source = ''
func _ready():
	name = routine_info.routine_name
	add_to_group(routine_info.routine_name)
	add_to_group(routine_info.upgrade_group)
	add_to_group(routine_info.effective_group)

	for attack_name in routine_info.creating_attack:
		if attack_name == 'none':
			continue
		add_attack(attack_name)
	match routine_info.type:
		'base':
			get_parent().shoot.connect(attacks)
		'ex':
			pass
	for summon in routine_info.creating_summoned:
		summon = PresetManager.getpre(summon)



func get_gen_position(force_world_position:bool,input_position,input_rotation):
	if force_world_position:
		gen_position = input_position
		gen_rotation = input_rotation
		return
	match routine_info.zeropoint:
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
			add_vector =Vector2(routine_info.gen_position[0],routine_info.gen_position[1])
			pass
		'polar':
			add_vector =Vector2.from_angle(rad_to_deg( routine_info.gen_position[1]))*routine_info.gen_position[0]
	gen_position += add_vector


func attacks(force_world_position=false,input_position=Vector2(0,0),input_rotation=0,has_interval=true):

	for i in range(int(routine_info.times +player_var.danma_times * routine_info.danma_times_efficiency)):

		match routine_info.once_creating_type:
			'single':
					if has_interval:
						await  get_tree().create_timer(routine_info.interval).timeout
					get_gen_position(force_world_position,input_position,input_rotation)

					single_attack(gen_position,gen_rotation)
			'multi':
				for j in range(routine_info.once_creating_parameter[0]):
					if has_interval:
						await  get_tree().create_timer(routine_info.interval).timeout
					get_gen_position(force_world_position,input_position,input_rotation)
					single_attack(gen_position,gen_rotation)


func single_attack(generate_position,generate_rotation):
	#AudioManager.play_sfx(routine_info["shoot_sfx"])
	match routine_info.special_creating_attack:
		'probability':
			var new_attack = attack_nodes[select_from_luck()].duplicate()

			new_attack.global_position = generate_position
			new_attack.rotation = generate_rotation
			new_attack.set_active(true)
			$".".add_child(new_attack)
		'none':

			for attack_node in attack_nodes:
				var new_attack = attack_node.duplicate()

				new_attack.global_position = generate_position
				new_attack.rotation = generate_rotation
				$".".add_child(new_attack)


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


func add_attack(attack_name):
	var attack_info = table.attack_skill[attack_name]

	#var attack_pre = PresetManager.getpre('attack').instantiate()
	var attack_pre = load("res://scene/attack/attack_ins/"+attack_name+".tscn").instantiate()

	attack_pre.attack_info = attack_info
	attack_pre.node_active = false
	attack_pre.set_upgrade(level)
	attack_pre.damage_source = damage_source
	for modi in routine_modifier:
		attack_pre.attack_modifier[modi].append(routine_modifier[modi])
	add_child(attack_pre)
	attack_nodes.append(attack_pre)

func destroy():
	for child in get_children():
		if child.has_method('destroy'):
			child.destroy('routine_destroy')
	queue_free()
