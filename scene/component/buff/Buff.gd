extends Object
class_name Buffs
var process_time:float= 0
var end_time:float = INF
var buff_info:Dictionary
var target = player_var
var source
var intensity = 1.0
signal  del_this_buff
func _init(buff_inf,buff_intensity,buff_source) -> void:
	buff_info = buff_inf
	source = buff_source
	intensity = buff_intensity

	on_create()

func on_create():

	target.set(buff_info.property,target.get(buff_info.property) + buff_info.base_buff_value * intensity)

	if buff_info.type =='disposable':
		on_destroy()

func on_update(delta):
	if process_time > end_time:
		on_destroy()
		call_deferred('free')
		return
	process_time += delta

func on_destroy():
	if buff_info.type =='disposable':
		return
	target.set(buff_info.property,target.get(buff_info.property) - buff_info.base_buff_value * intensity)


func on_refresh():
	pass
