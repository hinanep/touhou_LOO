extends CanvasLayer

func _ready() -> void:

	$".".visible = true
	var flush:Tween = $PopupPanel.create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_speed_scale(70)

	flush.tween_property($PopupPanel,'modulate',Color(1,1,1,0.1),3)
	flush.tween_property($PopupPanel,'modulate',Color(1,1,1,1),1)
	flush.set_loops(3)

	var interval = get_tree().create_timer(0.1)
	await interval.timeout
	interval = null
	var expand = $RichTextLabel.create_tween().set_ease(Tween.EASE_OUT).set_speed_scale(3)

	expand.tween_property($RichTextLabel,'scale',Vector2(0.7,1),1)
	expand.tween_property($RichTextLabel,'scale',Vector2(1,1),2)


	await  expand.finished

	var disappear = $PopupPanel.create_tween()

	disappear.tween_interval(1)
	disappear.set_parallel().tween_property($PopupPanel,'scale',Vector2(1,0),0.5)
	disappear.set_parallel().tween_property($RichTextLabel,'scale',Vector2(0.3,0.3),0.5)
	disappear.set_parallel().tween_property($RichTextLabel,'position',Vector2(500,-90),0.5)
