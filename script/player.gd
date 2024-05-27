extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D


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
