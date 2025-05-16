extends Node2D
class_name d4c
var d4c_info = {
	"Id": "dcrt_keine_sc1_1",
	"danmaku_type": "dmk_laserpre",
	"create_rule": "circle",
	"create_parameter": [
	  -600,
	  90
	],
	"create_amount": 2,
	"create_front": "world",
	"rotate_rule": "static",
	"rotate_parameter": [],
	"create_interval": 0.1,
	"max_create_times": 10,
	"is_destroy_with_parent": true,
	"moving_system": "parent",
	"moving_rule": "static",
	"moving_parameter": [],
	"danmaku_moving_rule": "straight",
	"danmaku_moving_parameter": [
	  0,
	  999999
	],
	"danmaku_damage": 30.0,
	"creator_apart_rule": "time",
	"creator_apart_var": [
	  "type"
	],
	"creator_apart_point": [
	  0.5
	],
	"creator_apart_parameter": [
	  "dmk_laser"
	],
	"danmaku_apart_rule": "",
	"danmaku_apart_var": [],
	"danmaku_apart_point": [],
	"danmaku_apart_parameter": []
  }

var zero_diretion:Vector2
var danma_pre :PackedScene = PresetManager.getpre('danma')
var shoot_func:Callable=stay
var move_func:Callable=stay
var rot_func:Callable=stay
var exist_time = 0
var parent_die_signal:Signal
#todo
var damage = 10
var gen_position:Vector2 = Vector2.ZERO
func d4c_init(id:String,parent):

	d4c_info = table.d4c[id].duplicate()
	global_position = parent.global_position
	return d4c_info.moving_system

func _ready() -> void:
	name = d4c_info.Id
	SignalBus.clear_enemy.connect(destroy)
	match d4c_info.create_front:
		'character':

			zero_diretion =gen_position.direction_to(player_var.player_node.global_position)
		'world':
			zero_diretion = Vector2.RIGHT
	match d4c_info.create_rule:
		'random':
			shoot_func = random_shoot
		'circle':
			shoot_func = circle_shoot
			zero_diretion = zero_diretion.rotated(d4c_info.create_parameter[1] * PI/180)
	match d4c_info.rotate_rule:
		'static':
			rot_func = stay
		'uniform':
			rot_func = rot_uniform
		'delay_uniform':
			rot_func = rot_delay_uniform
		'discrete_uniform':
			rot_func = rot_discrete_uniform
	if d4c_info.moving_system == 'world':
		top_level = true

	$shoot_interval.wait_time = d4c_info.create_interval
	$shoot_interval.start()
func _physics_process(delta: float) -> void:
	exist_time += delta

	move_func.call(delta)
	rot_func.call(delta)

func circle_shoot():
	var bias = 2*PI/d4c_info.create_amount
	var danma_velo = d4c_info.create_parameter[0]
	var danma_diretion:Vector2
	for i in range(d4c_info.create_amount):
		danma_diretion = zero_diretion.rotated(rotation+bias*i)
		shoot(danma_velo,danma_diretion)
func random_shoot():
	var danma_velo
	var danma_diretion
	for i in range(d4c_info.create_amount):
		danma_velo = randf_range(d4c_info.create_parameter[2],d4c_info.create_parameter[3])
		danma_diretion = zero_diretion.rotated(randf_range( d4c_info.create_parameter[0],d4c_info.create_parameter[1])*PI/180)
		shoot(danma_velo,danma_diretion)

var danma_pool = []
func add_to_pool(node):
	call_deferred('remove_child',node)
	await get_tree().physics_frame
	danma_pool.append(node)

func get_from_pool():
	var obj:Node2D
	if danma_pool.is_empty():
		obj = danma_pre.instantiate()
		obj.destroy.connect(add_to_pool)
	else:
		obj = danma_pool.pop_back()
	if obj == null:
		obj = danma_pre.instantiate()
		obj.destroy.connect(add_to_pool)
	return obj
func shoot(v,d):

	var newd = get_from_pool()
	newd.velo = v
	newd.diretion = d
	newd.rotation =Vector2.RIGHT.angle_to(d)
	newd.danma_init(d4c_info)
	newd.damage = damage
	newd.global_position = global_position


	add_child(newd)

func stay(delta):
	pass

func rot_uniform(delta):
	rotate(d4c_info.rotate_parameter[0]*PI/180*delta)
func rot_delay_uniform(delta):
	if exist_time < d4c_info.rotate_parameter[0]:
		return
	rotate(d4c_info.rotate_parameter[1]*PI/180*delta)

func rot_discrete_uniform(delta):
	if rot_times*d4c_info.rotate_parameter[0]<exist_time:
		rotate(d4c_info.rotate_parameter[1]*PI/180)
		rot_times += 1
var rot_times = 0
var shoot_times :int= 0
func _on_shoot_interval_timeout() -> void:

	progress_check()
	if d4c_info.create_front == 'character' and d4c_info.is_follow:
		zero_diretion =global_position.direction_to(player_var.player_node.global_position)
	shoot_func.call()
	shoot_times+=1
	if shoot_times >= d4c_info.max_create_times:
		$shoot_interval.stop()


var progress_p = 0
var progress_dc = 0
var next_checkpoint = -1
func destroy(is_drop):
	queue_free()
func progress_check():
	if d4c_info.get('creator_apart_rule')=='' or d4c_info.get('creator_apart_rule')==null:
		return
	if next_checkpoint ==-1:
		next_checkpoint = d4c_info.creator_apart_point[0]
	match d4c_info.creator_apart_rule:
		'time':
			while exist_time > next_checkpoint:
				apply_d4c_checkpoint(progress_dc)
				progress_dc+=1
				if progress_dc == d4c_info.creator_apart_point.size():
					next_checkpoint = 9999
					return
				next_checkpoint =d4c_info.creator_apart_point[progress_dc]
func apply_d4c_checkpoint(point):
	match d4c_info.creator_apart_var[point]:
		'type':
			d4c_info.danmaku_type = d4c_info.creator_apart_parameter[point]
