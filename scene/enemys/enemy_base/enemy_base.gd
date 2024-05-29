class_name enemy_base extends CharacterBody2D
@onready var player= get_tree().get_first_node_in_group("player")
var max_hp = 200
var hp = max_hp
var speed = 40
var basic_damage = 10
@onready var progress_bar = $ProgressBar
@onready var damage_area = $damage_area
@onready var attack_cd = $damage_area/attack_cd

func _ready():
	pass
	

func _physics_process(delta):
	move_to_player()
	pass


#移动方式：走向玩家
func move_to_player():
	velocity = get_diretion_to_player() * speed
	
	#近身减速防止模型重叠的神秘bug（，过近远离
	if get_distance_to_player() < 20:
		velocity *=  (get_distance_to_player() - 10)/20
	
	move_and_slide()
#到玩家方向单位向量
func get_diretion_to_player():
	if player:
		return(player.global_position - global_position).normalized()
	return Vector2.ZERO
#到玩家距离
func get_distance_to_player():
	if player:
		return global_position.distance_to(player.global_position)
	return Vector2.ZERO
#受伤
func take_damage(damage):
	hp -= damage
	
	progress_bar.value = hp/max_hp * 100

	if hp <= 0:
		died()
#似了
func died():
	print("died")
	queue_free()


func damage_area_body_entered(body):
	print("attack")
	attack_cd.start()
	
	player.take_damage(player_var.enemy_make_damage(basic_damage))
	pass # Replace with function body.


func attack_cd_timeout():
	print("attack")
	var playerinrange = damage_area.get_overlapping_bodies()
	if playerinrange:
		player.take_damage(player_var.enemy_make_damage(basic_damage))
	else:
		attack_cd.stop()
	pass # Replace with function body.
