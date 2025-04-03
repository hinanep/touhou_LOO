class_name drop extends Area2D
@onready var player_node= get_tree().get_first_node_in_group("player")
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")

var value = 1
var experience = 1
var score = 1
var mana = 1
var move = false
var speed_ratio = 200
var point_ratio = false
func _ready() -> void:
	set_physics_process(false)

func _physics_process(delta):
	if player_node:
		position +=  global_position.direction_to(player_node.global_position) * delta * speed_ratio

func _on_body_entered(_body):

	game_manager.add_exp(experience*value)
	game_manager.add_score(score*value)
	game_manager.add_mana(mana*value)
	if point_ratio:
		player_var.point_ratio += 0.01
	queue_free()

func fly_to_player(exp_buff = 1.0,mana_buff = 1.0,score_buff = 1.0,point_ratio_buff = false):
	experience *= exp_buff
	mana *= mana_buff
	score *= score_buff
	if point_ratio_buff:
		point_ratio = point_ratio_buff
	set_physics_process(true)
