extends BaseGUIView


func _on_back_button_pressed():
	#G.get_gui_view_manager().close_all_view()

	G.get_gui_view_manager().open_view("StartMenu")
	close_self()
	pass # Replace with function body.

func _open():
	$CanvasLayer/RichTextLabel/RichTextLabel.text =String.num_int64(player_var.point)
	var format_damage = " : %.2f \n"
	for source in player_var.damage_sum:
		if player_var.damage_sum[source] < 1:
			continue
		$CanvasLayer/damagesum.text += table.TID[source][player_var.language]
		$CanvasLayer/damagesum.text += format_damage % player_var.damage_sum[source]
	pass


func _close():

	pass


func open():
	_open()


func close():
	_close()


func close_self():
	G.get_gui_view_manager().close_view(viewInstanceId)
