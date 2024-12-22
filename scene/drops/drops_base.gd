class_name drops_base extends Area2D
@onready var player= get_tree().get_first_node_in_group("player")
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")


var experience = 1
var score = 1
var power = 1
var move = false
var speed_ratio = 200
var point_ratio = false
func _physics_process(delta):
	if move:
		position +=  global_position.direction_to(player.global_position) * delta * speed_ratio
		pass
func _on_body_entered(_body):

	game_manager.add_exp(experience)
	game_manager.add_score(score)
	game_manager.add_power(power)
	if point_ratio:
		player_var.point_ratio += 0.01
	queue_free()

func fly_to_player(exp_buff = 1.0,power_buff = 1.0,score_buff = 1.0,point_ratio_buff = false):
	experience *= exp_buff
	power *= power_buff
	score *= score_buff
	if point_ratio_buff:
		point_ratio = point_ratio_buff
	move = true
