extends CharacterBody2D
class_name player
@onready var animated_sprite_2d = $AnimatedSprite2D

var direction = Vector2(0,0)
func _init():
	player_var.player_node = $"."
	player_var.player_hp = player_var.player_hp_max
	pass
func _ready():
	SignalBus.player_invincible.connect(on_player_invincible)
	player_var.camera =get_viewport().get_camera_2d()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("slow_mode"):
		$CollisionShape2D/colli_point.set_visible(!$CollisionShape2D/colli_point.is_visible())


func _physics_process(_delta: float) -> void:
	#移动
	direction = Input.get_vector("move_left","move_right","move_up","move_down")
	if direction:
		player_var.player_diretion_angle =Vector2(1,0).angle_to( direction)
	if direction.x <0:
			animated_sprite_2d.play("left")
	elif direction.x >0:
			animated_sprite_2d.play("stay")
	velocity = direction * player_var.player_speed


	move_and_slide()


func take_damage(type,damage):

	if player_var.is_invincible:
		return

	$AnimationPlayer.play("hurt")
	AudioManager.play_sfx("music_sfx_hurt")
	match type:
		'melee':
			player_var.player_hp -= player_var.player_take_melee_damage(damage)
		'danma':
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
	pass # Replace with function body.

func _on_pickup_area_area_entered(area):

	if area.has_method("fly_to_player"):
		area.fly_to_player()
	pass # Replace with function body.
