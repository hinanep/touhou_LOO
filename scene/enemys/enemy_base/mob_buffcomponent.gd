extends Node
@onready var body = $".."
var brittle_modify = 1.0
var airbone_diretion=Vector2(0,0)
var buff_list={
		'slowdown'={
			on_create=Callable(func(intensity,duration,source):
			body.mob_info.speed *= 1-intensity

				),
			on_update=Callable(func(intensity):
			pass
				),
			on_destroy=Callable(func(intensity):
			body.mob_info.speed /= 1-intensity

				),
		},
		'root'={
			on_create=Callable(func(intensity,duration,source):
			body.moveable = false
				),
			on_update=Callable(func(intensity):
			pass
				),
			on_destroy=Callable(func(intensity):
			body.moveable = true
				),
		},
		'freeze'={
			on_create=Callable(func(intensity,duration,source):
			body.moveable = false
			body.atkable = false
				),
			on_update=Callable(func(intensity):
			pass
				),
			on_destroy=Callable(func(intensity):
			body.moveable = true
			body.atkable = true
				),
		},
		'airborne'={
			on_create=Callable(func(intensity,duration,source):
			airbone_diretion = (body.global_position-source.global_position).normalized()
			body.moveable = false
				),
			on_update=Callable(func(intensity):
			body.global_position += airbone_diretion *intensity
				),
			on_destroy=Callable(func(intensity):
			body.moveable = true
				),
		},
		'brittle'={
			on_create=Callable(func(intensity,duration,source):
			brittle_modify = intensity
				),
			on_update=Callable(func(intensity):
			pass
				),
			on_destroy=Callable(func(intensity):
			brittle_modify = 1.0
				),
		},
		'kill'={
			on_create=Callable(func(intensity,duration,source):
			body.mob_take_damage(9999)
				),
			on_update=Callable(func(intensity):
			pass
				),
			on_destroy=Callable(func(intensity):
			pass
				),
		}
}
var buff_engaging={

}
func add_buff(buff_id,intensity,duration,source):
	intensity *= brittle_modify
	if buff_engaging.has(buff_id):
		if intensity < buff_engaging[buff_id][0]:
			return
		elif intensity == buff_engaging[buff_id][0]:
			buff_engaging[buff_id][1] =max(duration,buff_engaging[buff_id][1])
			return
	buff_engaging[buff_id] = [0,0]
	buff_engaging[buff_id][0] = intensity
	buff_engaging[buff_id][1] = duration
	buff_list[buff_id].on_create.call(intensity,duration,source)
func _physics_process(delta: float) -> void:
	for id in buff_engaging.keys():
		buff_list[id].on_update.call(buff_engaging[id][0])

		buff_engaging[id][1]-=delta
		if buff_engaging[id][1]<0:
			buff_list[id].on_destroy.call(buff_engaging[id][0])
			buff_engaging.erase(id)
