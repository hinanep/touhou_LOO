class_name drops_base extends Area2D
@onready var player= get_tree().get_first_node_in_group("player")
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

var exp = 1
var score = 1
var power = 1
var move = false
var speed_ratio = 200
func _physics_process(delta):
	if move:
		position +=  global_position.direction_to(player.global_position) * delta * speed_ratio
		pass
func _on_body_entered(body):

	game_manager.add_exp(exp)
	game_manager.add_score(score)
	game_manager.add_power(power)

	queue_free()

func fly_to_player():
	move = true
