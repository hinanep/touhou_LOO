
class_name passive extends Node2D

var psv_info:Dictionary = {
	"id": "psv_saki_base",
	"upgrade_group": "upg_saki",
	"type": "base",
	"buff": [
	  "buff_bullet_speed_forever"
	],
	"buff_value_factor": [
	  1.0
	]
  }
var level = 0
var max_level
func _ready():
	SignalBus.upgrade_group.connect(upgrade_passive)
	SignalBus.del_passive.connect(del)
	max_level = table.Upgrade[psv_info.upgrade_group].level
func upgrade_passive(group):
	if group != psv_info.upgrade_group:
		return
	level+=1
	var intensity = table.Upgrade[psv_info.upgrade_group].buff_addition[level-1]
	trigger_buff(intensity)

	if(level == max_level):
		SignalBus.upgrade_max.emit(psv_info.id)
func del(id):
	if id == psv_info.id:
		SignalBus.player_del_buff_by_source.emit(psv_info.id)
		queue_free()

func trigger_buff(intensity):
	for i in range(psv_info.buff.size()):
		SignalBus.player_add_buff.emit(psv_info.buff[i],psv_info.buff_value_factor[i]*intensity,psv_info.id)
