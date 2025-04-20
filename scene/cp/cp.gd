extends Node2D
class_name cp
var cp_info = {
	id='cp_marisa_alice_patchouli'
}
func _ready() -> void:
	SignalBus.true_use_card.connect(on_using_card)
	SignalBus.player_hurt.connect(on_player_hurt)
	SignalBus.cp_del.connect(destroy)
	on_unlocking()
func on_unlocking():
	AudioManager.play_sfx("music_sfx_cp")
	if cp_info.has('giving_buff_moment'):
		for i in range(cp_info.giving_buff_moment.size()):
			if cp_info.giving_buff_moment[i]=='getting':
				print('trigger')
				trigger_buff(i)
	$CanvasLayer/RichTextLabel.text = table.TID[cp_info.id][player_var.language]
	$CanvasLayer/RichTextLabel/Sprite2D.set_texture(PresetManager.getpre('img_'+cp_info.id))
	popup()
func on_using_card(id):

	if cp_info.has('giving_buff_moment'):
		for i in range(cp_info.giving_buff_moment.size()):
			if cp_info.giving_buff_moment[i]=='sc':
				trigger_buff(i)

	if cp_info.has('creating_routine'):
		for i in range(cp_info.creating_routine.size()):
			if cp_info.creating_routine_moment[i]=='sc':
				SignalBus.trigger_routine_by_id.emit(cp_info.creating_routine[i],false,global_position,rotation,null)
func trigger_buff(i):
	if cp_info.get('buff_value_factor_depend',[]).size()>i:
		SignalBus.player_add_buff.emit(cp_info.giving_buff[i],
										player_var.dep.operate_dep(cp_info.get('buff_value_factor_depend')[i],
																	cp_info.buff_value_factor[i]),
										cp_info.id)
	else:
		SignalBus.player_add_buff.emit(cp_info.giving_buff[i],

										cp_info.buff_value_factor[i],
										cp_info.id)
func on_player_hurt():
	if(cp_info.has('creating_routine')):
		for i in range(cp_info.creating_routine.size()):
			if cp_info.creating_routine_moment[i]=='hurt':
				SignalBus.trigger_routine_by_id.emit(cp_info.creating_routine[i],false,global_position,rotation,null)
func destroy(desid):
	if desid == cp_info.id:
		SignalBus.player_del_buff_by_source.emit(cp_info.id)
		queue_free()

func popup() -> void:

	var panel = $CanvasLayer/PopupPanel
	var text = $CanvasLayer/RichTextLabel
	$CanvasLayer.visible = true
	var flush:Tween = panel.create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_speed_scale(70)

	flush.tween_property(panel,'modulate',Color(1,1,1,0.1),3)
	flush.tween_property(panel,'modulate',Color(1,1,1,1),1)
	flush.set_loops(3)


	await get_tree().create_timer(0.1).timeout

	var expand = text.create_tween().set_ease(Tween.EASE_OUT).set_speed_scale(3)

	expand.tween_property(text,'scale',Vector2(0.4,0.6),1)
	expand.tween_property(text,'scale',Vector2(0.6,0.6),2)


	await  expand.finished

	var disappear = panel.create_tween()

	disappear.tween_interval(1)
	disappear.set_parallel().tween_property(panel,'scale',Vector2(0.5,0),0.5)
	disappear.set_parallel().tween_property(text,'scale',Vector2(0.3,0.3),0.5)
	disappear.set_parallel().tween_property(text,'position',Vector2(400,0),0.5)
	await get_tree().create_timer(3).timeout
	$CanvasLayer.visible = false
