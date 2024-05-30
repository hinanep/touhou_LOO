extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$hp.max_value = player_var.player_hp_max
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hp_display()
	pass

func hp_display():
	$hp.value = player_var.player_hp
	$hp/hp_text.text = str(player_var.player_hp) + "/" + str(player_var.player_hp_max)
	
	pass
