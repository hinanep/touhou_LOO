extends RefCounted
class_name Buff
var process_time:float= 0
var end_time:float = INF
var buff_info:Dictionary
var target = player_var
var source
func _init(buff_inf,buff_source) -> void:
	buff_info = buff_inf
	source = buff_source
	on_create()

func on_create():
	target.set(buff_info.property,target.get(buff_info.property) + buff_info.base_buff_value)

	pass
func on_update(delta):
	if process_time > end_time:
		return
	process_time += delta

func on_destroy():
	if buff_info.type =='disposable':
		return
	target.set(buff_info.property,target.get(buff_info.property) - buff_info.base_buff_value)


func on_refresh():
	pass
