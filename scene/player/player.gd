extends CharacterBody2D
class_name player

var direction = Vector2.ZERO

@export var hurt_lock_seconds: float = 0.25

var state_lock_until: float = 0.0
var requested_anim_state: StringName = &""


var blend_position_paths = [
	"parameters/hurt/blend_position",
	"parameters/idle/blend_position",
	"parameters/move/blend_position",
	"parameters/sc/blend_position"

]
@onready var animation_tree = $AnimationTree
@onready var state_machine:AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

func _init():
	player_var.player_node = $"."
	player_var.player_hp = player_var.player_hp_max

func _ready():
	SignalBus.player_invincible.connect(on_player_invincible)
	player_var.camera = get_viewport().get_camera_2d()
	_request_anim_state(&"idle")


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("slow_mode"):
		$CollisionShape2D/colli_point.set_visible(!$CollisionShape2D/colli_point.is_visible())

var animation_diretion =Vector2.ZERO
func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction:
		player_var.player_diretion_angle = Vector2(1, 0).angle_to(direction)
		if animation_diretion != direction:
			animation_diretion = direction
			for path in blend_position_paths:
				animation_tree.set(path, animation_diretion)

	if not _is_locked():
		if direction:
			_request_anim_state(&"move")
		else:
			_request_anim_state(&"idle")
	velocity = direction * player_var.player_speed
	move_and_slide()




func take_damage(type, damage):
	if player_var.is_invincible:
		return

	_request_anim_state(&"hurt", hurt_lock_seconds, true)
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
	state_lock_until = 99999999.0
	AudioManager.play_sfx("music_sfx_die")
	if player_var.player_life_addi > 0:
		player_var.player_life_addi -= 1
		player_var.player_hp = player_var.player_hp_max
		player_var.mana = player_var.mana_max
		state_lock_until = 0.0
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

func _request_anim_state(next_state: StringName, lock_seconds: float = 0.0, force: bool = false) -> void:
	if _is_locked() and not force:
		return
	if lock_seconds > 0.0:
		state_lock_until = _now_seconds() + lock_seconds
	if requested_anim_state == next_state and not force:
		return
	requested_anim_state = next_state
	state_machine.travel(next_state)

func _is_locked() -> bool:
	if state_lock_until <= 0.0:
		return false
	return _now_seconds() < state_lock_until

func _now_seconds() -> float:
	return float(Time.get_ticks_msec()) / 1000.0
