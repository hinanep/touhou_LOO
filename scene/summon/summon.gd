class_name summon extends Node2D
var summon_info =  {
	"id": "sum_alice_base",
	"using_upgrade": "upg_alice",
	"type": "base",
	"effective_condition": "",
	"duration": 6.0,
	"dependence": "",
	"can_be_hited": false,
	"initial_hp": 1.0,
	"automatic_routine": [
	  "rou_alice_attachment1_base"
	],
	"cd": 1.0,
	"movement": "sandsoldier",
	"movement_parameter": [
	  2.0
	],
	"creating_routine": [],
	"destroying_routine": [],
	"special": []
  }
signal shoot
var level = 0
var upgrade_info = {

}
var hp
var target_location:Vector2
var damage_source = ''
func _ready():
	name = summon_info.id

	SignalBus.upgrade_group.connect(upgrade_summon)

	if summon_info.has('special'):
		if summon_info.special.has('scdestroy'):
			SignalBus.true_use_card.connect(scdestroy)


	var cd_timer = $cd_timer
	var duration = $duration
	cd_timer.wait_time = summon_info.cd
	cd_timer.timeout.connect(gen_routines)
	duration.wait_time = summon_info.duration
	duration.timeout.connect(destroy.bind(summon_info.id))
	cd_timer.start()
	duration.start()
	top_level = true
	global_position = position
	var target = player_var.SpawnManager.get_nearest_mob(global_position)
	if target!=null:
		target_location = target.global_position
	else:
		target_location = global_position

	on_create()
	if summon_info.movement=='sandsoldier':
		rediretion()
func _physics_process(delta: float) -> void:

	global_position =global_position.move_toward(target_location,delta * 1000)
	$Line2D.set_point_position(1,player_var.player_node.global_position-global_position)

func rediretion():
	while(true):
		await get_tree().create_timer(summon_info.movement_parameter[0]).timeout
		var target = player_var.SpawnManager.get_nearest_mob(global_position)
		if target!=null:
			target_location = target.global_position

func on_create():
	if summon_info.has('creating_routine'):
		for rs in summon_info.creating_routine:
			SignalBus.trigger_routine_by_id.emit(rs,true,global_position,global_rotation)




func gen_routines():
	if summon_info.has('automatic_routine'):
		for rs in summon_info.automatic_routine:
			SignalBus.trigger_routine_by_id.emit(rs,true,global_position,global_rotation)


func upgrade_summon(group):
	if summon_info.upgrade_group != group:
		return

	level += 1
	if(level == player_var.summon_level_max):
		SignalBus.upgrade_max.emit(summon_info.id)

func scdestroy(scid):
	for rs in summon_info.special_routine:
		SignalBus.trigger_routine_by_id.emit(rs,true,global_position,global_rotation)
	destroy(summon_info.id)


func destroy(id):
	if summon_info.id != id:
		return
	if summon_info.has('destroying_routine'):
		for rs in summon_info.destroying_routine:
			SignalBus.trigger_routine_by_id.emit(rs,true,global_position,global_rotation)
	for child in get_children():
		if child.has_method('destroy'):
			child.destroy()
	queue_free()
