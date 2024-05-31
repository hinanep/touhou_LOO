extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
var hp = player_var.player_hp_max
var is_invincible = false
func _ready():
	$invincible_time.wait_time = player_var.invincible_time
func _physics_process(delta):
	#移动
	
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * player_var.player_speed
	move_and_slide()
	
	#动画
	if direction:
		animated_sprite_2d.play("run")
		pass
	else:
		animated_sprite_2d.play("stay")
		pass

func take_damage(damage):
	if is_invincible:
		print("invincible active")
		return
	animated_sprite_2d.play("be_hit")
	hp -= damage
	player_var.player_hp = hp
	
	if hp < 0:
		died()
		
	is_invincible = true
	$invincible_time.start()
		
func died():
	get_tree().reload_current_scene()


func _on_invincible_time_timeout():
	is_invincible = false

