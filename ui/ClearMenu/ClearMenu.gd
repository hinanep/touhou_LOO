extends BaseGUIView


func _on_back_button_pressed() -> void:


	G.get_gui_view_manager().call_deferred("clear_to_start")

func _open() -> void:
	$CanvasLayer/RichTextLabel/RichTextLabel.text =String.num_int64(player_var.point)
	var format_damage: String = " : %.2f \n"
	for source in player_var.damage_sum:
		if player_var.damage_sum[source] < 1.0:
			continue
		$CanvasLayer/damagesum.text += table.TID[source][player_var.language]
		$CanvasLayer/damagesum.text += format_damage % player_var.damage_sum[source]
	pass


func _close() -> void:

	pass


func open() -> void:
	_open()


func close() -> void:
	_close()


func close_self() -> void:
	G.get_gui_view_manager().close_view(viewInstanceId)
