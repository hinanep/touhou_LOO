extends drop
class_name PlateKey
## 飞碟钥匙颜色：1=红 2=绿 3=蓝 4=彩，掉落时锁定
var ufo_color: int = 1


func _ready() -> void:
	not_fusioning = false
	set_physics_process(false)
	ufo_color = _roll_ufo_color()


## 按 Global 表权重随机钥匙颜色 1..4
func _roll_ufo_color() -> int:
	var samples: Array = [
		[1, table.get_global_variable("red_ufo_weight", 3.0)],
		[2, table.get_global_variable("green_ufo_weight", 3.0)],
		[3, table.get_global_variable("blue_ufo_weight", 3.0)],
		[4, table.get_global_variable("colorful_ufo_weight", 1.0)],
	]
	var sum := 0.0
	var weight_delta: Array = []
	for sample in samples:
		var w := float(sample[1])
		if w <= 0.0:
			continue
		sum += w
		weight_delta.append([int(sample[0]), w])
	if sum <= 0.0:
		return randi_range(1, 4)
	var r := randf_range(0.0, sum)
	for entry in weight_delta:
		r -= float(entry[1])
		if r < 0.0:
			return int(entry[0])
	return int(weight_delta[weight_delta.size() - 1][0])


## 范围内玩家进入：无活跃飞碟时发射生成信号并销毁；否则忽略
func _on_body_entered(_body) -> void:
	AudioManager.play_sfx("music_sfx_pickup")
	SignalBus.ufo_spawn_requested.emit(ufo_color, global_position)
	queue_free()
