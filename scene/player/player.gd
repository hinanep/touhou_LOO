extends CharacterBody2D
class_name player
@onready var animated_sprite_2d = $AnimatedSprite2D

var direction = Vector2.ZERO

## 屏幕坐标：-y 上 / +y 下，对应素材文件夹名（向前/向后与美术资源对调）
const _FAIRY_DIRS := {
	"forward": "向后",
	"back": "向前",
	"left": "向左",
	"right": "向右",
}
const _FAIRY_BASE := "res://asset/pic/fairy"
@export var _move_fps := 14.0
@export var _idle_fps := 10.0
## 仅在与竖直方向夹角 ≤ 此值（度）时用前/后动画，其余（含斜向）用左/右
@export var _vertical_facing_half_angle_deg := 15.0

var _last_facing := "forward"
var _current_anim := ""

func _init():
	player_var.player_node = $"."
	player_var.player_hp = player_var.player_hp_max

func _ready():
	SignalBus.player_invincible.connect(on_player_invincible)
	player_var.camera = get_viewport().get_camera_2d()
	var sf := _build_fairy_sprite_frames()
	if sf and sf.get_animation_names().size() > 0:
		animated_sprite_2d.sprite_frames = sf
	_last_facing = "forward"
	_play_anim_if_changed("idle_back")

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("slow_mode"):
		$CollisionShape2D/colli_point.set_visible(!$CollisionShape2D/colli_point.is_visible())

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		player_var.player_diretion_angle = Vector2(1, 0).angle_to(direction)
		var facing := _facing_from_direction(direction)
		_last_facing = facing
		_play_anim_if_changed("move_%s" % facing)
	else:
		_play_anim_if_changed("idle_%s" % _last_facing)

	velocity = direction * player_var.player_speed
	move_and_slide()

func _facing_from_direction(d: Vector2) -> String:
	var dn := d.normalized()
	var thresh := cos(deg_to_rad(_vertical_facing_half_angle_deg))
	if dn.dot(Vector2.UP) >= thresh:
		return "forward"
	if dn.dot(Vector2.DOWN) >= thresh:
		return "back"
	return "right" if dn.x > 0.0 else "left"

func _play_anim_if_changed(anim_name: String) -> void:
	if anim_name == _current_anim:
		return
	if not animated_sprite_2d.sprite_frames:
		return
	if not animated_sprite_2d.sprite_frames.has_animation(anim_name):
		return
	_current_anim = anim_name
	animated_sprite_2d.play(anim_name)

func _build_fairy_sprite_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	for key in _FAIRY_DIRS:
		var folder: String = _FAIRY_DIRS[key]
		var move_dir := "%s/%s/move" % [_FAIRY_BASE, folder]
		var idle_dir := "%s/%s/idle" % [_FAIRY_BASE, folder]
		var move_anim := "move_%s" % key
		var idle_anim := "idle_%s" % key
		_add_animation_from_folder(sf, move_anim, move_dir, _move_fps)
		_add_animation_from_folder(sf, idle_anim, idle_dir, _idle_fps)
	return sf

func _add_animation_from_folder(sf: SpriteFrames, anim_name: String, folder_path: String, fps: float) -> void:
	var names := _list_png_sorted(folder_path)
	if names.is_empty():
		return
	sf.add_animation(anim_name)
	sf.set_animation_loop(anim_name, true)
	var frame_dur := 1.0 / maxf(fps, 0.001)
	for fn in names:
		var tex: Texture2D = load(folder_path.path_join(fn))
		if tex:
			sf.add_frame(anim_name, tex, frame_dur)

func _list_png_sorted(folder_path: String) -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(folder_path)
	if dir == null:
		return out
	for fn in dir.get_files():
		if fn.ends_with(".png") and not fn.ends_with(".import"):
			out.append(fn)
	out.sort_custom(func(a: String, b: String) -> bool:
		return _png_sort_key(a) < _png_sort_key(b)
	)
	return out

func _png_sort_key(fn: String) -> int:
	var base := fn.get_basename()
	var parts := base.split("_")
	if parts.size() >= 2:
		return parts[parts.size() - 1].to_int()
	return 0

func take_damage(type, damage):
	if player_var.is_invincible:
		return

	$AnimationPlayer.play("hurt")
	AudioManager.play_sfx("music_sfx_hurt")
	match type:
		"melee":
			player_var.player_hp -= player_var.player_take_melee_damage(damage)
		"danma":
			player_var.player_hp -= player_var.player_take_danma_damage(damage)

	SignalBus.player_hurt.emit()
	if player_var.player_hp < 0.1:
		died()
	SignalBus.player_invincible.emit(player_var.invincible_time)

func on_player_invincible(time):
	player_var.is_invincible = true
	$invincible_time.stop()
	$invincible_time.wait_time = time
	$invincible_time.start()

func died():
	AudioManager.play_sfx("music_sfx_die")
	if player_var.player_life_addi > 0:
		player_var.player_life_addi -= 1
		player_var.player_hp = player_var.player_hp_max
		player_var.mana = player_var.mana_max
		return
	G.get_gui_view_manager().close_all_view()

	G.get_gui_view_manager().open_view("ClearMenu")

func _on_invincible_time_timeout():
	player_var.is_invincible = false

func _on_pickup_area_body_entered(body):
	if body.has_method("fly_to_player"):
		body.fly_to_player()

func _on_pickup_area_area_entered(area):
	if area.has_method("fly_to_player"):
		area.fly_to_player()
