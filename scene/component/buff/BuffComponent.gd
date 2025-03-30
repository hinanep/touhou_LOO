extends Node2D
class_name BuffComponent

var buffs:Dictionary

var new_buff:Buffs
signal buff_update
func _init() -> void:
	SignalBus.player_add_buff.connect(player_add_buff)
	SignalBus.player_del_buff_by_source.connect(del_buff_by_source)
func _physics_process(delta: float) -> void:

	buff_update.emit()

func player_add_buff(buff_id,buff_intensity,source):
	var buff_info = table.Buff[buff_id].duplicate()
	new_buff = Buffs.new(buff_info,buff_intensity,source)

	if not buffs.has(source):
		buffs[source] = []
	buffs[source].push_back(new_buff)

func del_buff_by_source(source):
	if not buffs.has(source):
		return
	for b in buffs[source]:
		b.on_destroy()
	buffs.erase(source)
