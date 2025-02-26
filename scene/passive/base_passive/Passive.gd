
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

func _ready():
	SignalBus.upgrade_group.connect(upgrade_passive)
	#trigger_buff()

func upgrade_passive(group):
	if group == psv_info.upgrade_group:
		trigger_buff()

func del():
	SignalBus.player_del_buff_by_source.emit(psv_info.id)
	queue_free()

func trigger_buff():
	for i in range(psv_info.buff.size()):
		SignalBus.player_add_buff.emit(psv_info.buff[i],psv_info.buff_value_factor[i],psv_info.id)
