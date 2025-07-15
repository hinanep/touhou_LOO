extends Node2D
var boss_routine_info = {
	"id": "brou_keine_ns1_1",
	"boss": "bprc_keine_ns1",
	"phase_number": 1,
	"is_auto": true,
	"auto_interval": 999999.0,
	"first_use_time": 1.0,
	"type": "create",
	"create_rule": "inplace",
	"create_parameter": [],
	"creature_id": "",
	"physical_rule": "",
	"physical_parameter": [],
	"followup": ""
  }
signal end()
var num_limit = 1

var viewport_size:Vector2
func br_init(br_info):
	boss_routine_info = br_info
func _ready() -> void:
	camera = get_viewport().get_camera_2d()
	if boss_routine_info.end_time > 0:

		$end_time.wait_time = boss_routine_info.end_time
		$end_time.start()
	if boss_routine_info.is_auto:
		await get_tree().create_timer(boss_routine_info.first_use_time,false,true).timeout
		shoot()
		$auto_emit.wait_time = boss_routine_info.auto_interval
		$auto_emit.start()

	get_viewport().size_changed.connect(_on_viewport_size_changed)
	viewport_size = Vector2(1920,1080)
func _on_viewport_size_changed():

	viewport_size = get_viewport().get_visible_rect().size
var camera:Camera2D
func get_triggered(id:String):
	if id == boss_routine_info.id:
		shoot()
func shoot():
	if num_limit < 1:
		return
	if boss_routine_info.is_auto:
		num_limit -= 1
	match boss_routine_info.type:
		'enemy':
			var gen_position:Vector2 = Vector2.ZERO
			var enemy_pre :PackedScene = PresetManager.getpre(boss_routine_info.creature_id)
			var mob_info = table.Enemy[boss_routine_info.creature_id]


			var ne
			match boss_routine_info.create_rule:
				'inplace':
					ne = enemy_pre.instantiate()
					ne.mob_info = mob_info.duplicate()
					gen_position = global_position
					ne.global_position = gen_position
					ne.die.connect(release)
					SignalBus.add_mob_to_manager.emit(ne)
				'circle':
					var gen_angle = boss_routine_info.create_parameter[2]*PI/180
					for i in boss_routine_info.create_parameter[0]:
						gen_position =global_position+ Vector2.from_angle(gen_angle) * boss_routine_info.create_parameter[1]

						gen_angle+= 2*PI/boss_routine_info.create_parameter[0]
						ne = enemy_pre.instantiate()
						ne.mob_info = mob_info.duplicate()
						ne.global_position = gen_position
						ne.die.connect(release)
						SignalBus.add_mob_to_manager.emit(ne)
				'screen_line':
					var bias = Vector2(boss_routine_info.create_parameter[2]-boss_routine_info.create_parameter[0],boss_routine_info.create_parameter[3]-boss_routine_info.create_parameter[1])/(boss_routine_info.create_parameter[4]-1)
					gen_position = Vector2(boss_routine_info.create_parameter[0],boss_routine_info.create_parameter[1])

					for i in boss_routine_info.create_parameter[4]:
						ne = enemy_pre.instantiate()
						ne.mob_info = mob_info.duplicate()
						ne.die.connect(release)
						ne.global_position = screen_to_world(gen_position)
						SignalBus.add_mob_to_manager.emit(ne)

						gen_position += bias
		'dcreator':
			var gen_position:Vector2 = Vector2.ZERO
			match boss_routine_info.create_rule:
				'inplace':
					gen_position = global_position
					SignalBus.d4c_create.emit(boss_routine_info.creature_id,gen_position,$".",boss_routine_info.danmaku_damage)
				'circle':
					var gen_angle = boss_routine_info.create_parameter[2]*PI/180
					for i in boss_routine_info.create_parameter[0]:
						gen_position = Vector2.from_angle(gen_angle) * boss_routine_info.create_parameter[1]
						SignalBus.d4c_create.emit(boss_routine_info.creature_id,gen_position,$".",boss_routine_info.danmaku_damage)
						gen_angle+= 2*PI/boss_routine_info.create_parameter[0]
				'screen_line':
					var bias = Vector2(boss_routine_info.create_parameter[2]-boss_routine_info.create_parameter[0],boss_routine_info.create_parameter[3]-boss_routine_info.create_parameter[1])/(boss_routine_info.create_parameter[4]-1)
					gen_position = Vector2(boss_routine_info.create_parameter[0],boss_routine_info.create_parameter[1])

					for i in boss_routine_info.create_parameter[4]:

						SignalBus.d4c_create.emit(boss_routine_info.creature_id,screen_to_world(gen_position),$".",boss_routine_info.danmaku_damage)
						gen_position += bias


		'physical':
			if boss_routine_info.physical_rule =='aimed_charge':
				rush(get_parent().get_parent())
				release('rush')
func screen_to_world(p:Vector2):
	viewport_size = Vector2(1920,1080)


	return camera.get_screen_center_position() + ( p-viewport_size/2)

func _on_auto_emit_timeout() -> void:
	if get_parent().get_parent().atkable:
		shoot()

func destroy():
	end.emit()
	queue_free()
func _on_end_time_timeout() -> void:
	destroy()

func rush(body:CharacterBody2D):

	body.dush(boss_routine_info['physical_parameter'][0],boss_routine_info['physical_parameter'][1],boss_routine_info['physical_parameter'][2])

func release(_id):
	num_limit+=1;
