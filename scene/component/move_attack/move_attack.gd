extends RefCounted
class_name MoveComponent
var move_type:Callable
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
var velocity_system_front = {
			character='character',

			world='world',

			lock='lock',

			routine='routine',

			random='random',
}
func _init(B,attack_in,lock_com:LockComponent,diretion_routine=Vector2(0,0)):
	body = B
	attack_info = attack_in
	if !attack_info.moving:
		move_type = move_stay
		return
	lock = lock_com
	diretion = diretion_routine
	ref = !attack_info.reflection.is_empty()
	match attack_info.moving_rule:
		moving_rule.straight:
			move_type = Callable(move_straight)
		moving_rule.trail:
			move_type = Callable(move_trace_target)
		moving_rule.sekibanki:
			move_type = Callable(move_sekibanki)
			body.top_level = true
			velocity = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * player_var.bullet_speed_ratio * attack_info.moving_parameter[0]
		moving_rule.polar:
			move_type = Callable(move_polar)

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

#velocity:vector2 diretion:null
func move_trace_target(delta):
	if lock.lock_target == null:
		if not velocity is int:
			body.position += velocity  * delta
		else:
			velocity = attack_info.moving_parameter[0] * Vector2(1,0)
		lock.find_next_target()
		return

	acc = body.global_position.direction_to(lock.lock_target.global_position) * attack_info.moving_parameter[1]
	velocity += acc
	velocity = velocity.normalized() * min(velocity.length(),attack_info.moving_parameter[2])
	body.rotation = velocity.angle() + PI/2
	return body.move_and_collide(velocity * delta)
	#body.position += velocity * delta


func move_straight(delta):
	if diretion == Vector2(0,0):
		velocity = attack_info.moving_parameter[0]
		acc = attack_info.moving_parameter[1]
		match attack_info.velocity_system_front:
			velocity_system_front.character:
				diretion = Vector2.from_angle(player_var.player_diretion_angle)

			velocity_system_front.world:
				diretion = Vector2(1,0)

			velocity_system_front.lock:
				var t = lock.find_next_target()
				if t is Vector2:
					diretion = body.global_position.direction_to(t)
				elif t != null:
					diretion = body.global_position.direction_to(t.global_position)

				else:
					diretion = Vector2.from_angle(player_var.player_diretion_angle)

			velocity_system_front.routine:
				pass

			velocity_system_front.random:
				diretion = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()

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
	return body.move_and_collide(velocity * delta)

func move_stay(_delta):
	return null

#func reflection(normal:Vector2):
	#normal = normal.normalized()
	#velocity = attack_info.moving_parameter[0]
	#diretion = diretion - 2*normal.dot(diretion)*normal
