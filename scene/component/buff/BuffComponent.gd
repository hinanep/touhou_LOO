extends RefCounted
class_name BuffComponent
var buffs:Buff
var buff_cursor:Buff
var new_buff:Buff
func _init() -> void:
	pass
func _physics_process(delta: float) -> void:
	buff_cursor = buffs
	while (buff_cursor!=null):
		pass

func add_buff(buff_name):
	if refresh_buff(buff_name):
		return
	new_buff = Buff.new()
	new_buff.next_buff = buffs
	buffs = new_buff



func del_buff():
	pass

func refresh_buff(buff_name):

	return false
