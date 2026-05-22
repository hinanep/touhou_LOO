extends drop

## 飞碟钥匙颜色：1=红 2=绿 3=蓝，掉落时锁定
var ufo_color: int = 1


func _ready() -> void:
	not_fusioning = false
	set_physics_process(false)
	ufo_color = randi_range(1, 3)
	_apply_ufo_color_visual()


## 按 ufo_color 显示对应色盘帧与宇宙贴图 tint
func _apply_ufo_color_visual() -> void:
	var plate_sprite: AnimatedSprite2D = $AnimatedSprite2D
	plate_sprite.visible = true
	match ufo_color:
		1:
			plate_sprite.frame = 2
		2:
			plate_sprite.frame = 1
		3:
			plate_sprite.frame = 0
		_:
			plate_sprite.frame = 0
	var tint := Color.WHITE
	match ufo_color:
		1:
			tint = Color(1.0, 0.7, 0.7, 1.0)
		2:
			tint = Color(0.7, 1.0, 0.7, 1.0)
		3:
			tint = Color(0.7, 0.7, 1.0, 1.0)
		_:
			pass
	if has_node("Sprite2D/Sprite2D"):
		$"Sprite2D/Sprite2D".self_modulate = tint


## 范围内玩家进入：无活跃飞碟时发射生成信号并销毁；否则忽略
func _on_body_entered(_body) -> void:
	var ufo_mgr: Node = _get_ufo_manager()
	if ufo_mgr != null and ufo_mgr.has_method("has_active_ufo") and ufo_mgr.has_active_ufo():
		return
	AudioManager.play_sfx("music_sfx_pickup")
	SignalBus.ufo_spawn_requested.emit(ufo_color, global_position)
	queue_free()


func _get_ufo_manager() -> Node:
	if player_var.SpawnManager == null or not is_instance_valid(player_var.SpawnManager):
		return null
	return player_var.SpawnManager.get_node_or_null("UfoManager")
