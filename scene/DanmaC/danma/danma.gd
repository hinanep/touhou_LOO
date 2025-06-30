extends CharacterBody2D

var d_info = {
	type='dmk_ball',

	danmaku_moving_rule = '',
	danmaku_moving_parameter='',
	danmaku_damage='',

	danmaku_apart_rule='',

	danmaku_apart_var =[],
	danmaku_apart_point=[],
	danmaku_apart_parameter=[],


}
var exist_time = 0
var move_func:Callable
var damage = 0
signal destroy(this_node)
func danma_init(d4c_info:Dictionary):
	d_info = d4c_info
	change_type_to(d_info.danmaku_type)
	change_move_type_to(d_info.danmaku_moving_rule)

#另需要在创建时传入diretion

func _ready() -> void:
	velocity = Vector2.ZERO


func _physics_process(delta: float) -> void:
	move_func.call(delta)

func change_type_to(type: String):
	var cshape
	match type:
		'dmk_ball':
			cshape = CircleShape2D.new()
			cshape.radius = 1
			$texture.set_texture(PresetManager.getpre('img_tama'))
			$texture.offset.y=0

			change_size_to(20)

		'dmk_rice':
			cshape = CircleShape2D.new()
			cshape.radius = 1
			$texture.set_texture(PresetManager.getpre('img_rice'))
			$texture.offset.y=0
			change_size_to(12)
		'dmk_mentos':
			cshape = CircleShape2D.new()
			cshape.radius = 1
			$texture.set_texture(PresetManager.getpre('img_tama'))
			$texture.offset.y=0
			change_size_to(40)
		'dmk_laserpre':
			cshape = RectangleShape2D.new()
			cshape.size = Vector2(1,0)
			$colli_area.position.x=0.5
			$damage_area/colli_da.position.x=0.5
			$damage_area.monitoring = false
			$texture.set_texture(PresetManager.getpre('img_laserpre'))
			$texture.rotation = -PI/2
			$texture.offset.y=16
			$texture.modulate = Color(0.3,1,1,1)
			var sizex = 100
			var sizey = 2
			$texture.scale = Vector2(0.15,0.03)
			$".".scale = Vector2(sizex,sizey)
			#$damage_area.scale =Vector2(sizex,sizey)
			#$colli_area.scale = Vector2(sizex,sizey)
			#$VisibleOnScreenNotifier2D.scale = Vector2(sizex,sizey)
			$VisibleOnScreenNotifier2D.rect = Rect2(-0.5,-0.5,1,1)
		'dmk_laser':
			$texture.set_texture(PresetManager.getpre('img_laser'))
			$texture.rotation = -PI/2
			$damage_area.monitoring = true
			cshape = RectangleShape2D.new()
			cshape.size = Vector2(1,1)
			$colli_area.position.x=0.5
			$damage_area/colli_da.position.x=0.5
			$texture.offset.y=16
			$texture.modulate = Color(0.3,1,1,1)
			var sizex = 100
			var sizey = 12
			$texture.scale = Vector2(0.03,0.03)
			$".".scale = Vector2(sizex,sizey)
			#$damage_area.scale =Vector2(sizex,sizey)
			#$colli_area.scale = Vector2(sizex,sizey)
			#$VisibleOnScreenNotifier2D.scale = Vector2(sizex,sizey)

			$VisibleOnScreenNotifier2D.rect = Rect2(-0.5,-0.5,1,1)
	$colli_area.shape = cshape
	$damage_area/colli_da.shape = cshape

func change_size_to(size:float):
	$texture.scale = Vector2(size * 0.06,size * 0.06)
	$damage_area.scale =Vector2(size,size)
	$colli_area.scale = Vector2(size,size)

func change_move_type_to(move:String):
	match move:
		'straight':
			move_straight_init()
			move_func = move_straight
		_:
			move_func = move_stay

var progress_p = 0
var next_checkpoint = -1
func progress_check():
	match d_info.danmaku_apart_rule:
		'time':
			while exist_time > next_checkpoint:

				apply_checkpoint(progress_p)
				progress_p+=1

				if progress_p >= d_info.danmaku_apart_point.size():
					next_checkpoint = 9999
					continue
				else:
					next_checkpoint =d_info.danmaku_apart_point[progress_p]

func apply_checkpoint(point):
	#if point >= d_info.danmaku_apart_point.size():
			#return
	match d_info.danmaku_apart_var[point]:
		'type':
			change_type_to(d_info.danmaku_apart_parameter[point])



var diretion:Vector2 = Vector2.ZERO
var acc = 0
var velo = 0
func move_straight_init():
	acc = d_info.danmaku_moving_parameter[0]
func move_straight(delta):
	velo = min(d_info.danmaku_moving_parameter[1],velo+acc*delta)
	velocity = velo * diretion
	move_and_slide()
func move_stay(delta):
	pass

func _on_timer_timeout() -> void:
	exist_time+=$exist.wait_time
	if  d_info.get('danmaku_apart_rule')=='' or d_info.get('danmaku_apart_rule')==null:
		$exist.stop()
	else:
		if next_checkpoint ==-1:
			next_checkpoint = d_info.danmaku_apart_point[0]
		progress_check()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	destroy.emit($".")

func _on_damage_area_body_entered(body: Node2D) -> void:

	if body.has_method('take_damage'):
		body.take_damage('danma',damage)
		if(d_info.danmaku_type != 'dmk_laser'):
			destroy.emit($".")


		#queue_free()
