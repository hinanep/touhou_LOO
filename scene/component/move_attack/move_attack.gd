extends RefCounted
class_name MoveComponent
var move_type:Callable
var rotate_type:Callable = move_stay
var velocity = 0
var diretion = Vector2(0,0)
var acc = 0
var body:CharacterBody2D
var polar_len = 0
var polar_angle = 0
var attack_info
var lock :LockComponent
var ref = false
var colli_info :KinematicCollision2D
var moving_rule = {
	straight='straight',
	trail='trail',
	sekibanki='sekibanki',
	polar='polar'

}
var diretions = {
			character='character',

			world='world',

			lock='lock',

			routine='routine',

			random='random',
}
func _init(B,attack_in,lock_com:LockComponent,diretion_routine=Vector2(0,0)):
	body = B
	attack_info = attack_in

	lock = lock_com
	lock.find_next_target()


	ref = attack_info.has('reflection')

	if attack_info.has('ri_dependence'):
		match attack_info.ri_dependence:
			'lock':
				if lock.lock_target!=null:
					body.rotation = body.global_position.angle_to_point(lock.lock_target.global_position)+deg_to_rad(attack_info.ri)
				elif lock.lock_position!=null:
					body.rotation = body.global_position.angle_to_point(lock.lock_position)+deg_to_rad(attack_info.ri)
			'character':
					body.rotation = player_var.player_diretion_angle
	else:
		body.rotation = deg_to_rad(attack_info.ri)
	diretion = Vector2.from_angle(body.rotation)

	if attack_info.has('moving_rule'):
		match attack_info.moving_rule:
			moving_rule.straight:
				move_straight_init()
				move_type = Callable(move_straight)
			moving_rule.trail:
				move_type = Callable(move_trace_target)
				velocity = attack_info.moving_parameter[0] * diretion * 10
			moving_rule.sekibanki:
				move_type = Callable(move_sekibanki)
				body.top_level = true
				velocity = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * player_var.bullet_speed_ratio * attack_info.moving_parameter[0]
			moving_rule.polar:
				move_type = Callable(move_polar)
	if !attack_info.moving:
		move_type = move_stay

	if attack_info.has('rotation_rule'):
		match attack_info.rotation_rule:
			'uniform':

					rotate_type = rot_uniform
			'speed':

					rotate_type = rot_speed
			'locking':
					rotate_type = rot_locking

	max_rad_perframe = deg_to_rad(attack_info.omega) /Engine.physics_ticks_per_second




func update(delta):
	colli_info = move_type.call(delta)

	if ref and colli_info is KinematicCollision2D:
		var normal = colli_info.get_normal()
		if velocity is Vector2:
			velocity = velocity.bounce(normal)
			velocity = velocity.normalized() * attack_info.moving_parameter[0]
		if diretion is Vector2:
			diretion = diretion.bounce(normal)
			velocity = attack_info.moving_parameter[0]

	rotate_type.call(delta)

func move_trace_target(delta):
	if lock.lock_target == null:

		body.position += velocity  * delta

		lock.find_next_target()
		return

	acc = body.global_position.direction_to(lock.lock_target.global_position) * attack_info.moving_parameter[1]
	velocity += acc*delta
	velocity = velocity.normalized() * min(velocity.length(),attack_info.moving_parameter[2])
	diretion = velocity.normalized()
	return body.move_and_collide(velocity * delta)
	#body.position += velocity * delta

func move_straight_init():
		velocity = attack_info.moving_parameter[0]
		acc = attack_info.moving_parameter[1]
		match attack_info.diretion:
			diretions.character:
				diretion = Vector2.from_angle(player_var.player_diretion_angle)

			diretions.world:
				diretion = Vector2(1,0)

			diretions.lock:
				lock.find_next_target()
				if lock.lock_position!=null:
					diretion = body.global_position.direction_to(lock.lock_position)
				elif  lock.lock_target!=null:
					diretion = body.global_position.direction_to(lock.lock_target.global_position)

				else:
					diretion = Vector2.from_angle(player_var.player_diretion_angle)

			diretions.routine:
				pass

			diretions.random:
				diretion = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()
func move_straight(delta):

	velocity = min(attack_info.moving_parameter[2],velocity+acc*delta)
	#body.position += velocity * diretion * delta
	return body.move_and_collide(velocity * diretion * delta)


func move_polar(delta):
	polar_len += attack_info.moving_parameter[0] * delta
	polar_angle += attack_info.moving_parameter[1] * delta
	body.position = Vector2.from_angle(deg_to_rad(polar_angle)) * polar_len



func move_sekibanki(delta):
	if(player_var.player_node != null):
		velocity +=0.5 * attack_info.moving_parameter[0] *  body.global_position.direction_to(player_var.player_node.global_position) *delta*sqrt(body.global_position.distance_to(player_var.player_node.global_position))
	velocity +=  velocity.rotated(PI/2).normalized() * delta * attack_info.moving_parameter[0]
	velocity = velocity.normalized() * attack_info.moving_parameter[0] * player_var.bullet_speed_ratio
	#body.position += velocity * delta
	diretion = velocity.normalized()
	return body.move_and_collide(velocity * delta)

func move_stay(_delta):

	return null

func rot_uniform(delta):
	body.rotation_degrees += attack_info.omega * delta
var target_rotate
func rot_speed(delta):

	target_rotate = Vector2.from_angle(body.rotation).angle_to(diretion)
	if abs(target_rotate) < deg_to_rad(attack_info.omega) *delta:
		body.rotate(target_rotate)
	else:
		if target_rotate > 0:
			body.rotate(deg_to_rad(attack_info.omega)*delta)
		else:
			body.rotate(-deg_to_rad(attack_info.omega)*delta)


func rot_locking(delta):
	if lock!=null:
		lock.find_next_target()
	var target_position
	if lock.lock_target!=null:
		target_position = lock.lock_target.global_position
	elif lock.lock_position!=null:
		target_position = lock.lock_position
	rotate_to_angle(body.global_position.angle_to_point(target_position),delta)

var max_rad_perframe
func rotate_to_angle(target_angle,delta):
	target_rotate = target_angle-body.rotation

	if target_rotate > PI:
		target_rotate -= 2*PI
	elif target_rotate < -PI:
		target_rotate += 2*PI
	if abs(target_rotate) < max_rad_perframe:
		body.rotate(target_rotate)
	else:
		if target_rotate > 0:
			body.rotate(max_rad_perframe)
		else:
			body.rotate(-max_rad_perframe)
