extends Line2D
@export var boat1: Node2D
@export var boat2: Node2D
@export var segment_count: int = 20  # 可控制的分段数

var is_burning1: bool = false
var is_burning2: bool = false
@export var start_burn:int = 0

func _ready() -> void:
	# 创建线条点
	visible = false
	boat1.lines_withboat.push_back($".")
	boat2.lines_withboat.push_back($".")
	is_burning1 = false
	is_burning2 = false
	boat1.die.connect(boat_die_disconnect)
	boat2.die.connect(boat_die_disconnect)
	get_parent().get_parent().get_parent().link_line.connect(set_ready)
	await  get_tree().create_timer(4.8).timeout
	if start_burn <2:
		#call_deferred('on_fire_from',boat1)
		call_deferred('start_burning',0)

func set_ready():
	create_gra()
	create_line_points()

	var tween = create_tween()
	player_var.underrecycle_tween.append(tween)
	tween.tween_property(material,'shader_parameter/progress',0.0,0.0)
	visible = true
	tween.tween_property(material,'shader_parameter/progress',1.0,0.5)



func boat_die_disconnect(_id):
	queue_free()
func create_line_points():
	# 清除现有点
	clear_points()


	# 计算线条总长度和方向
	var line_start = boat1.position
	var line_end = boat2.position
	var line_direction = (line_end - line_start).normalized()
	var line_length = line_start.distance_to(line_end)
	var segment_length = line_length / segment_count

	# 创建多个点来形成线条
	for i in range(segment_count + 1):  # segment_count + 1个点形成segment_count段
		var point = line_start + line_direction * (i * segment_length)
		add_point(point)

func create_gra():
	gradient = Gradient.new()
	gradient.set_color(0,Color.RED)
	gradient.set_color(1,Color.RED)

	gradient.add_point(0.001,Color.RED)
	gradient.add_point(0.002,Color.WHITE)
	gradient.add_point(0.998,Color.WHITE)
	gradient.add_point(0.999,Color.RED)


func start_burning(start_point: int):
	if start_point == 0:
		if is_burning1:
			return
		is_burning1 = true
		var tween = create_tween()
		player_var.underrecycle_tween.append(tween)
		tween.tween_property($".",'left_fire',1,2)
	else:
		if is_burning2:
			return
		is_burning2 = true
		var tween = create_tween()
		player_var.underrecycle_tween.append(tween)
		tween.tween_property($".",'right_fire',0,2)


var left_fire = 0.001
var right_fire = 0.999
var fired = false
func update_burn_effect():
	if not (is_burning1 or is_burning2):
		return
	if left_fire +0.05> right_fire:
		gradient.set_color(1,Color.RED)
		gradient.set_color(2,Color.RED)
		gradient.set_color(3,Color.RED)
		gradient.set_color(4,Color.RED)
		fired = true
		if left_fire > 0.9 and not is_burning2:

			# 检查boat2是否存在且有fire属性
			if boat2 and is_instance_valid(boat2) and boat2.has_method('on_fire'):
				boat2.on_fire()
		if right_fire < 0.1 and not is_burning1:
			# 检查boat1是否存在且有on_fire方法
			if boat1 and is_instance_valid(boat1) and boat1.has_method('on_fire'):
				boat1.on_fire()
		return
	gradient.set_offset(2,left_fire+0.01)
	gradient.set_offset(1,left_fire)


	gradient.set_offset(3,right_fire-0.01)
	gradient.set_offset(4,right_fire)
func _process(delta):
	if not (boat1 or boat2):
		queue_free()
	if is_burning1 or is_burning2:
		if not fired:

			update_burn_effect()


func on_fire_from(boatx: Node2D):
	if boatx == boat1:
		start_burning(0)

	elif boatx == boat2:
		start_burning(1)


func _on_fireball_timeout() -> void:
	if fired:
		return
	if is_burning1 and boat1 and boat2:
		SignalBus.d4c_create.emit('dcrt_keine_sc2_2', boat1.global_position+(boat2.global_position- boat1.global_position)*left_fire, $".", 30)
	if is_burning2 and boat1 and boat2:

		SignalBus.d4c_create.emit('dcrt_keine_sc2_2',   boat1.global_position+(boat2.global_position- boat1.global_position)*right_fire, $".", 30)
