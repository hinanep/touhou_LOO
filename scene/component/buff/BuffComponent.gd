extends Node2D
class_name BuffComponent
var permanent_buff:Array
var temporary_buff:Array
var buff_cursor:Buff
var new_buff:Buff
func _init() -> void:
	SignalBus.player_add_buff.connect(add_buff)
	pass
func _physics_process(delta: float) -> void:

	for sbuff:Buff in temporary_buff:
		sbuff.on_update(delta)

func add_buff(buff_id,source):

	var buff_info = table.buff[buff_id]
	new_buff = Buff.new(buff_info,source)
	match buff_info.type:
		'forever':
			permanent_buff.push_back(new_buff)
		'disposable':
			temporary_buff.push_back(new_buff)




func del_buff_by_source():
	pass
