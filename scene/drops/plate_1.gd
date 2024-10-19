extends drops_base


func _ready():
	experience = 10000
	score = 10000

func _on_body_entered(_body):
	get_tree().call_group("crystal","fly_to_player")
	queue_free()
