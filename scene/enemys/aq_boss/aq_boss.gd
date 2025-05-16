extends enemy_base
var stage = table.keine.keys().size()
var tmp_stage = 0
var reincarnation = false
var boss_info:Dictionary
var progress_routine :Dictionary= {}
var progress_time = 0
var diretion:Vector2 = Vector2.ZERO
var move_func:Callable = move_stay
signal trigger(id)
func boss_init(id:String):
	boss_info = table[id]
	mob_info = boss_info[boss_info.keys()[0]]
func fight_begin():
	start_progess(0)
func _ready():
	drops_path = "drops_plate"
	AudioManager.play_bgm("music_bgm_saga")

	$buff.brittle_modify = 0
	melee_battle_ready()
	super._ready()

	collision_mask = 32
	SignalBus.clear_enemy.emit(true)
	SignalBus.pause_spawner.emit(true)

func _physics_process(delta: float) -> void:
	move_func.call(delta)
	if not global_position.is_equal_approx(last_position):

		player_var.SpawnManager.update_enemy_position_in_grid(self, last_position, global_position)

		# 更新上一帧的位置
		last_position = global_position
func died(disppear = false):

	if(disppear):
		emit_signal('die',mob_id)
		call_deferred('queue_free')
		return
	if reincarnation == true:
		return
	if hp < 10:
		spellcard_break()

	if tmp_stage+1 < stage:
		reincarnation = true
		tmp_stage += 1
		start_progess(tmp_stage)
		return
	invincible = true



	player_var.is_invincible = true
	drop()

	$AnimatedSprite2D.play("die")
	await  get_tree().create_timer(6,false,true).timeout
	AudioManager.bgm_over()
	queue_free()
	G.get_gui_view_manager().close_all_view()
	G.get_gui_view_manager().open_view("ClearMenu")

func move_dush(delta):
	var colli_info:KinematicCollision2D = move_and_collide(diretion * 200 * delta)
	if colli_info is KinematicCollision2D:
		trigger.emit('brou_keine_ns2_2')
		move_func = move_stay
var v = 0
func move_random(delta):
	v+=delta
	if v>1:
		v=0
		velocity = mob_info.speed * Vector2.from_angle(randf()*2*PI) + 0.5*global_position.distance_to(Vector2(300,0))*global_position.direction_to(Vector2(300,0))

	move_and_slide()

func trigger_routine(id):
	pass
func move_stay(delta):
	pass
func start_progess(phase:int):
	mob_info = boss_info[boss_info.keys()[phase]]
	progress_routine.clear()
	SignalBus.clear_enemy.emit(true)
	move_func = move_stay


	create_tween().tween_property($".",'global_position',Vector2(300,0),1)

	$melee_damage_area.scale = Vector2(mob_info.physical_radius,mob_info.physical_radius)
	invincible = true
	atkable = false
	progress_time = 0
	$progress_timer.stop()
	AudioManager.play_bgm("music_bgm_ff")
	if mob_info.is_sc:
		pass




	var reincarnation_tween = create_tween()
	reincarnation_tween.tween_property($".","hp",mob_info.health,3*(mob_info.health-hp)/mob_info.health)
	reincarnation_tween.tween_property($ProgressBar,"value",100,3*(mob_info.health-hp)/mob_info.health)
	await reincarnation_tween.finished
	reincarnation_over()


func reincarnation_over():

	if mob_info.is_survial_card:
		invincible = true
	else:
		invincible = false
	reincarnation = false
	atkable = true
	if mob_info.has('sc_tid') and mob_info.sc_tid != '':
		$hud/card/RichTextLabel.text = table.TID[mob_info.sc_tid][player_var.language]
		popup()
	else:
		$hud/card.visible = false
	if mob_info.movement:

		move_func = move_random
	else:
		move_func = move_stay

	for child in $danma.get_children():
		child.destroy()
	var rt = table.get(mob_info.boss + '_routine')
	var br = PresetManager.getpre('boss_routine')
	for key in rt:
		if   rt[key].boss == mob_info.id:

			var nbr = br.instantiate()
			nbr.br_init(rt[key])
			trigger.connect(nbr.get_triggered)

			$danma.add_child(nbr)

			progress_routine[key] = rt[key]
	$progress_timer.start()


func spellcard_timeover():

	died()
func spellcard_break():
	player_var.point += mob_info.initial_bonus - progress_time*mob_info.bonus_reduction_rate


func _on_animated_sprite_2d_animation_finished():
	pass


func _on_progress_timer_timeout() -> void:
	progress_time+=$progress_timer.wait_time
	if progress_time>mob_info.time:
		spellcard_timeover()


func _on_progress_bar_value_changed(value: float) -> void:
	$hud/bossbar.value = value

@onready var panel = $hud/card/PopupPanel
@onready var text = $hud/card/RichTextLabel
func popup() -> void:

	text.position = Vector2(-236,128)
	text.scale = Vector2(0.1,0.6)
	panel.scale = Vector2(0.6,0.6)
	$hud/card.visible = true
	var flush:Tween = panel.create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_speed_scale(70)

	flush.tween_property(panel,'modulate',Color(1,1,1,0.1),3)
	flush.tween_property(panel,'modulate',Color(1,1,1,1),1)
	flush.set_loops(3)


	var interval
	print('flushover')
	flush = null
	print('expandstart')
	var expand = text.create_tween().set_ease(Tween.EASE_OUT).set_speed_scale(3)

	expand.tween_property(text,'scale',Vector2(0.4,0.6),1)
	expand.tween_property(text,'scale',Vector2(0.6,0.6),2)


	await  expand.finished

	print('expandover')
	expand = null
	print('disstart')
	var disappear = panel.create_tween()

	disappear.tween_interval(1)
	disappear.set_parallel().tween_property(panel,'scale',Vector2(0.5,0),0.5)
	disappear.set_parallel().tween_property(text,'scale',Vector2(0.2,0.2),0.5)
	disappear.set_parallel().tween_property(text,'position',Vector2(300,850),0.5)
	disappear.tween_property(panel,'rotation',0,3.5)
	await disappear.finished
	print('disover')
	disappear = null


	#$CanvasLayer/card.visible = false
