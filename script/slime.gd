extends CharacterBody2D
var player
const max_hp = 200
var hp = max_hp
const speed = 40
@onready var progress_bar = $ProgressBar

func _ready():
	player = get_node("/root/level01/player")
	
	
func _physics_process(delta):
	#移动
	if player:
		var direction = global_position.direction_to(player.global_position)
	#近身减速防止模型重叠的神秘bug（
		if global_position.distance_to(player.global_position) < 40:
			direction *=  global_position.distance_to(player.global_position)/40
	
		velocity = direction * speed
	
	move_and_slide()
	#攻击
	
func take_damage(damage):
	hp -= damage
	#print(hp)
	#print(progress_bar.value)
	progress_bar.value = hp/max_hp * 100

	if hp <= 0:
		print(" died")
		queue_free()
