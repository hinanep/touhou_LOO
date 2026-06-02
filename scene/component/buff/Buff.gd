extends Object
class_name Buffs

var process_time: float = 0.0
var end_time: float = INF
var buff_info: Dictionary
var target: Node = player_var
var source: String
var intensity: float = 1.0
signal del_this_buff


func _init(buff_inf: Dictionary, buff_intensity: float, buff_source: String) -> void:
	buff_info = buff_inf
	source = buff_source
	intensity = buff_intensity

	on_create()


func on_create() -> void:

	target.set(buff_info.property, target.get(buff_info.property) + buff_info.base_buff_value * intensity)

	if buff_info.type == 'disposable':
		on_destroy()


func on_update(delta: float) -> void:
	if process_time > end_time:
		on_destroy()
		call_deferred('free')
		return
	process_time += delta


func on_destroy() -> void:
	if buff_info.type == 'disposable':
		return
	target.set(buff_info.property, target.get(buff_info.property) - buff_info.base_buff_value * intensity)


func on_refresh() -> void:
	pass
