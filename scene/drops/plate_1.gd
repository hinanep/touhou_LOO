extends drops_base


func _ready():
	experience = 10000
	score = 10000

func _on_body_entered(_body):
	get_tree().call_group("crystal","fly_to_player")
	for i in range(3):
		if CpManager.random_choose_cp():
			continue
		else:
			#random upgrade waza/card/passive
			pass
	queue_free()
