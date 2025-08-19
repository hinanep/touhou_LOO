class_name summon extends Node2D
@export var summon_info =  {

  }
signal shoot
var index =0
signal over(this_node)
var	recycling = false
@export var level = 0

var node_active = true
var hp
var target_location:Vector2
var max_level = 0
@export var damage_source = ''
func spawn(true_level:int) -> void:
	if node_active:
		await tree_entered
		recycling = false
		level = true_level

func reinit():

	if summon_info.type == 'boost':
		return

	if summon_info.has('cd') and summon_info.cd > 0:
		var cd_timer = $cd_timer

		cd_timer.wait_time = summon_info.cd
		cd_timer.start()

	var duration = $duration
	var dt = player_var.dep.operate_dep(summon_info.get('dependence'),summon_info.duration)
	if dt>0:
		duration.wait_time =  player_var.dep.operate_dep(summon_info.get('dependence'),summon_info.duration)
		duration.start()

	target_location = player_var.player_node.global_position
	on_create()
	if summon_info.has('movement'):
		if summon_info.movement=='sandsoldier':
			$rediretion.wait_time = summon_info.movement_parameter[0]
			$rediretion.start()
			await get_tree().create_timer(0.1).timeout
			rediretion()

var first_ready = true
func _ready():
	if not first_ready:
		reinit()
		return
	first_ready = false
	name = summon_info.id
	set_active(node_active)
	if summon_info.type == 'base':
		SignalBus.sum_boost.connect(recive_boost)
	elif summon_info.type == 'boost':
		SignalBus.cp_active.connect(boost_active.bind(true))
		SignalBus.cp_del.connect(boost_active.bind(false))
		return

	SignalBus.upgrade_group.connect(upgrade_summon)

	if summon_info.has('special'):
		if summon_info.special.has('scdestroy'):
			SignalBus.true_use_card.connect(scdestroy)

	if summon_info.has('cd') and summon_info.cd > 0:
		var cd_timer = $cd_timer
		cd_timer.timeout.connect(gen_routines)

	var duration = $duration
	var dt = player_var.dep.operate_dep(summon_info.get('dependence'),summon_info.duration)
	if dt>0:
		duration.timeout.connect(destroy.bind(summon_info.id))


	top_level = true
	reinit()


func _physics_process(delta: float) -> void:

	global_position =global_position.move_toward(target_location,delta * 400 * player_var.bullet_speed_ratio)

	$Line2D.set_point_position(1,player_var.player_node.global_position-global_position)

func rediretion():

		var target = player_var.SpawnManager.find_closest_enemies(global_position,1,1000,null)
		if not target.is_empty():
			if is_instance_valid(target[0]):
				target_location = target[0].global_position

func on_create():
	if summon_info.has('creating_routine'):
		for rs in summon_info.creating_routine:
			SignalBus.trigger_routine_by_id.emit(rs,true,Vector2.ZERO,global_rotation,$".")




func gen_routines():
	if summon_info.has('automatic_routine'):
		for rs in summon_info.automatic_routine:

			SignalBus.trigger_routine_by_id.emit(rs,true,Vector2.ZERO,global_rotation,$".")


func upgrade_summon(group):
	if summon_info.upgrade_group != group:
		return

	level += 1


func scdestroy(scid):
	for rs in summon_info.special_routine:
		SignalBus.trigger_routine_by_id.emit(rs,true,global_position,global_rotation,null)
	destroy(summon_info.id)


func destroy(id):
	if recycling:
		return
	recycling = true
	if summon_info.id != id:
		return
	if summon_info.has('destroying_routine'):
		for rs in summon_info.destroying_routine:
			SignalBus.trigger_routine_by_id.emit(rs,true,global_position,global_rotation,null)
	for child in get_children():
		if child.has_method('destroy'):
			child.destroy('summon_destroy')
	get_parent().call_deferred('remove_child',$".")
	await get_tree().physics_frame
	over.emit($".")

func set_active(active:bool):
	$cd_timer.paused = !active
	$duration.paused = !active
	visible = active
	#$texture.visible = active
	set_process(active)
	set_physics_process(active)

#当本攻击是boost类型且接受到激活信号时触发
func boost_active(cp_info,is_active):
	if cp_info is String:
		cp_info = table.Couple[cp_info]
	if summon_info.effective_condition != cp_info.id:
		return
	SignalBus.sum_boost.emit(summon_info,is_active)

#当本攻击接受到boost攻击发出的boost信号时触发
func recive_boost(sum_info,is_active):

	if sum_info.routine_group[0] != summon_info.routine_group[0]:

		return

	for key in sum_info:
		if key == 'id' or key == 'type' or key =='routine_group' or key =='effective_condition'or key =='upgrade_group':
			continue
		if sum_info[key] is bool:
			continue
		if not is_active:
			match typeof(sum_info[key]):
				TYPE_ARRAY:
					for element in sum_info[key]:
						summon_info[key].erase(element)
				_:
					summon_info[key] -= sum_info[key]
			continue
		if not summon_info.has(key):
			summon_info[key] = sum_info[key]
		else:
			summon_info[key] += sum_info[key]
