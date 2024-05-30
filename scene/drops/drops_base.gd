class_name drops_base extends Area2D
@onready var player= get_tree().get_first_node_in_group("player")
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")

var exp = 1
var score = 1


func _on_body_entered(body):
	print("Exp+3, good bye!")
	# game_manager.add_exp(exp)
	# game_manager.add_score(score)
	queue_free()
	pass
