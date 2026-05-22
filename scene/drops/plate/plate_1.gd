extends drop
class_name PlateKey
## 飞碟钥匙颜色：1=红 2=绿 3=蓝，掉落时锁定
var ufo_color: int = 1


func _ready() -> void:
	not_fusioning = false
	set_physics_process(false)
	ufo_color = randi_range(1, 3)


## 范围内玩家进入：无活跃飞碟时发射生成信号并销毁；否则忽略
func _on_body_entered(_body) -> void:
	AudioManager.play_sfx("music_sfx_pickup")
	SignalBus.ufo_spawn_requested.emit(ufo_color, global_position)
	queue_free()
