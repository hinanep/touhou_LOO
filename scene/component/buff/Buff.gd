class_name Buff
var process_time:float= 0
var end_time:float = INF
var next_buff:Buff
func _init() -> void:
	pass
func on_create():
	pass
func on_update(delta):
	if process_time > end_time:
		return
	process_time += delta

func on_destroy():
	pass
func on_refresh():
	pass
