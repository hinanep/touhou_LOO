extends CanvasLayer
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("player")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_select_1_button_up():
	print(player_var.random_weapons_selected[0])
	addWeapon(player_var.random_weapons_selected[0])
	visible = false
	get_tree().paused = false
	pass # Replace with function body.


func _on_select_2_button_up():
	addWeapon(player_var.random_weapons_selected[1])
	visible = false
	get_tree().paused = false
	pass # Replace with function body.


func _on_select_3_button_up():
	addWeapon(player_var.random_weapons_selected[2])
	visible = false
	get_tree().paused = false
	pass # Replace with function body.
	
func addWeapon(numbers):
	var name = player_var.get_name_from_numbers(numbers)
	if player_var.weapon_random_list[name] > 0:
		player_var.weapon_random_list[name] += 1
		return
	var path = player_var.weapon_name_path_pair[name]
	player_var.weapon_random_list[name] += 1
	var weapon = load(path)
	weapon = weapon.instantiate()
	#weapon.global_position = player.global_position
	
	player.get_node("weapons").add_child(weapon)
	

