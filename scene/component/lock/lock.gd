extends RefCounted
class_name LockComponent
var lock_func:Callable
var lock_target = null
var lock_position = null
var body
var SpawnManager = player_var.SpawnManager
func _init(B,locking_type,lock_routine = null):
	body = B

	match locking_type:
		'routine':
			lock_target = lock_routine
			lock_func = find_null_target
		'nearest':
			lock_func = find_nearest_target
		'strongest':
			lock_func = find_strongest_target
		'front':
			lock_func = find_front_target
		null:
			lock_func = find_null_target


func find_nearest_target():
	lock_target = SpawnManager.get_nearest_mob(body.global_position)
	return lock_target


func find_strongest_target():
	lock_target = SpawnManager.get_strongest_mob()
	return lock_target


func find_front_target():
	lock_position = player_var.player_node.global_position  + 400*Vector2.from_angle(player_var.player_diretion_angle)
	return lock_position


func find_null_target():
	return null


func  find_next_target():
	lock_func.call()
	return true
