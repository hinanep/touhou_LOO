extends Node
@onready var body: enemy_base = $".." as enemy_base
var brittle_modify: float = 1.0
var airbone_diretion: Vector2 = Vector2(0,0)
var buff_list: Dictionary = {
		'slowdown'={
			on_create=Callable(func(intensity: float, duration: float, source: Node2D):
			body.mob_info.speed *= 1-intensity

				),
			on_update=Callable(func(intensity: float):
			pass
				),
			on_destroy=Callable(func(intensity: float):
			body.mob_info.speed /= 1-intensity

				),
		},
		'root'={
			on_create=Callable(func(intensity: float, duration: float, source: Node2D):
			body.moveable = false
				),
			on_update=Callable(func(intensity: float):
			pass
				),
			on_destroy=Callable(func(intensity: float):
			body.moveable = true
				),
		},
		'freeze'={
			on_create=Callable(func(intensity: float, duration: float, source: Node2D):
			body.moveable = false
			body.atkable = false
				),
			on_update=Callable(func(intensity: float):
			pass
				),
			on_destroy=Callable(func(intensity: float):
			body.moveable = true
			body.atkable = true
				),
		},
		'airborne'={
			on_create=Callable(func(intensity: float, duration: float, source: Node2D):
			airbone_diretion = (body.global_position-source.global_position).normalized()
			body.moveable = false
				),
			on_update=Callable(func(intensity: float):
			body.global_position += airbone_diretion *intensity
				),
			on_destroy=Callable(func(intensity: float):
			body.moveable = true
				),
		},
		'brittle'={
			on_create=Callable(func(intensity: float, duration: float, source: Node2D):
			brittle_modify = intensity
				),
			on_update=Callable(func(intensity: float):
			pass
				),
			on_destroy=Callable(func(intensity: float):
			brittle_modify = 1.0
				),
		},
		'kill'={
			on_create=Callable(func(intensity: float, duration: float, source: Node2D):
			body.mob_take_damage(9999)
				),
			on_update=Callable(func(intensity: float):
			pass
				),
			on_destroy=Callable(func(intensity: float):
			pass
				),
		}
}
var buff_engaging: Dictionary = {

}
func add_buff(buff_id: String, intensity: float, duration: float, source: Node2D) -> void:
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
