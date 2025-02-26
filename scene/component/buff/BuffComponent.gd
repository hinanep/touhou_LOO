extends Node2D
class_name BuffComponent

var buffs:Array

var new_buff:Buff
signal buff_update
func _init() -> void:
	SignalBus.player_add_buff.connect(add_buff)

func _physics_process(delta: float) -> void:
	if get_signal_connection_list('buff_update'):
		buff_update.emit()

func add_buff(buff_id,buff_intensity,source):
	var buff_info = table.Buff[buff_id]
	new_buff = Buff.new(buff_info,source)
	buffs.push_back(new_buff)
