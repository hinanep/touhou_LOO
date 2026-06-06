extends enemy_base
var stage: int = table.keine.keys().size()
var tmp_stage: int = 0
var reincarnation: bool = false
var boss_info: Dictionary
var progress_routine: Dictionary = {}
var progress_time: float = 0
var diretion: Vector2 = Vector2.ZERO
var move_func: Callable = move_stay
var boatcard: PackedScene = preload("res://scene/enemys/boss/keine/fireboat/boatscard.tscn")
signal trigger(id: String)
var state: String = 'nons' #'nons'|'spell_quarter'|'spell_full'|'spell_time'


func boss_init(id: String) -> void:
	boss_info = table[id]
	for i in boss_info.keys().size():
		if not boss_info[boss_info.keys()[i]].is_dialog:
			mob_info = boss_info[boss_info.keys()[i]]
func fight_begin() -> void:
	start_progess(0)
func _ready() -> void:
	drops_path = "drops_plate"
	AudioManager.play_once_loop_bgm('music_keine_intro','music_keine_loop')

	collisionshape = $CollisionShape2D
	$buff.brittle_modify = 0
	super._ready()
	collision_mask = 32
	SignalBus.clear_enemy.emit(true)
	SignalBus.pause_spawner.emit(true)
	velocity = Vector2.ZERO
	SignalBus.kill_all.connect(died.bind(true))
	SignalBus.boss_set_stage.connect(start_progess)
func _physics_process(delta: float) -> void:
	move_func.call(delta)
	_face_player()

const _FACE_HYST := 40.0

## 根据玩家水平位置更新 scaledir，并以与 enemy_base 相同步长渐变朝向
func _face_player() -> void:
	if not is_instance_valid(player_var.player_node):
		return
	var dx: float = player_var.player_node.global_position.x - global_position.x
	# move_random 会使 Boss 横向穿过玩家垂线，|dx| 很小时反复翻转 scaledir 导致抽搐
	if dx > _FACE_HYST:
		scaledir = -1
	elif dx < -_FACE_HYST:
		scaledir = 1
	sprite.scale.x = clampf(sprite.scale.x - 0.05 * scaledir, -abs(scalex), abs(scalex))

func died(disppear: bool = false) -> void:

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
		start_progess(tmp_stage+1)
		return
	invincible = true



	player_var.is_invincible = true
	drop()

	$AnimatedSprite2D.play("die")
	AudioManager.play_sfx('music_sfx_break')
	await  get_tree().create_timer(6,false,true).timeout
	AudioManager.bgm_over()
	queue_free()
	G.get_gui_view_manager().close_all_view()
	G.get_gui_view_manager().open_view("ClearMenu")

var dush_speed: float = 0
var colli: bool = false
@onready var time_tween: Tween
func dush(speed: float, time: float, charge_time: float) -> void:
	$"轨迹".visible = true
	diretion = global_position.direction_to(player_var.player_node.global_position)
	await get_tree().create_timer(charge_time,false).timeout

	dush_speed = speed
	move_func = move_dush

	time_tween = create_tween()
	RunSession.underrecycle_tween.append(time_tween)
	time_tween.tween_interval(time)
	time_tween.tween_callback(func():
		move_func = move_stay
		)

var after_dush_trigger_2_2: bool = true
func move_dush(delta: float) -> void:

	var colli_info: KinematicCollision2D = move_and_collide(diretion * dush_speed * delta)
	if colli_info is KinematicCollision2D:
		$"轨迹".visible = false
		if after_dush_trigger_2_2:
			trigger.emit('brou_keine_ns2_2')
		else:
			trigger.emit('brou_keine_ns2_4')
		after_dush_trigger_2_2 = not after_dush_trigger_2_2
		if time_tween.is_valid():
			time_tween.kill()
		move_func = move_stay
var v: float = 0
var stan: float = 2
var move: float = 1
var mode: int = 0
func move_random(delta: float) -> void:
	v+=delta
	if mode == 0:
		if v > stan:
			mode = 1
			v = 0
			velocity = mob_info.speed * Vector2.from_angle(randf()*2*PI) + 0.5*global_position.distance_to(Vector2(300,0))*global_position.direction_to(Vector2(300,0))
	if mode == 1:
		if v > move:
			mode = 0
			v = 0
			velocity = Vector2.ZERO


	move_and_slide()

func trigger_routine(id: String) -> void:
	pass
func move_stay(_delta: float) -> void:
	pass
func start_progess(phase: int) -> void:
	if phase == -1:
		tmp_stage = tmp_stage + 1
	else:
		tmp_stage = phase
	if tmp_stage >= boss_info.keys().size():
		reincarnation = false
		hp = 0
		died()
		return

	if boss_info[boss_info.keys()[tmp_stage]].is_dialog:
		#TODO:触发对话并在触发后回来到stage+1的状态
		#SignalBus.triggertalk.emit(dialogs1,callback)
		start_progess(tmp_stage+1)
		return
	mob_info = boss_info[boss_info.keys()[tmp_stage]]
	progress_routine.clear()
	SignalBus.clear_enemy.emit(true)
	move_func = move_stay
	set_cardstate(mob_info.hp_hud)
	atkable = false
	var t: Tween = create_tween()
	RunSession.underrecycle_tween.append(t)
	t.tween_property($".", 'global_position', Vector2(600, 0), 1)
	$melee_damage_area.scale = Vector2(mob_info.physical_radius,mob_info.physical_radius)
	invincible = true

	progress_time = 0
	$progress_timer.stop()




	if not mob_info.is_sc:
		var reincarnation_tween: Tween = create_tween()
		RunSession.underrecycle_tween.append(reincarnation_tween)
		reincarnation_tween.set_parallel()
		reincarnation_tween.tween_property($".","hp",mob_info.health,2)
		reincarnation_tween.tween_property(progress_bar,"value",100,2)
		await reincarnation_tween.finished

	else:
		hp = mob_info.health
		progress_bar.value = 100
		var reincarnation_tween: Tween = create_tween()
		reincarnation_tween.tween_interval(4)
	reincarnation_over()


func reincarnation_over() -> void:

	if mob_info.is_survial_card:
		invincible = true
	else:
		invincible = false
	reincarnation = false
	atkable = true

	if mob_info.movement:

		move_func = move_random
		$AnimatedSprite2D.play("move")
	else:
		move_func = move_stay
		$AnimatedSprite2D.play("default")

	if mob_info.has('sc_tid') and mob_info.sc_tid != '':
		$hud/card/RichTextLabel.text = table.TID[mob_info.sc_tid][player_var.language]
		popup()
		$AnimatedSprite2D.play("sc_casting")
		if mob_info.sc_tid == 'esc_keine_2':
			var bc: Node2D = boatcard.instantiate()
			bc.global_position = Vector2(0,0)
			add_child(bc)
	else:
		$hud/card.visible = false


	for child in $danma.get_children():
		child.destroy()
	var rt: Dictionary = table.get(mob_info.boss + '_routine')
	var br: PackedScene = PresetManager.getpre('boss_routine')
	for key in rt:
		if   rt[key].boss == mob_info.id:

			var nbr: Node2D = br.instantiate()
			nbr.br_init(rt[key])
			trigger.connect(nbr.get_triggered)

			$danma.add_child(nbr)

			progress_routine[key] = rt[key]
	SignalBus.set_bosstimer.emit(mob_info.time)
	$progress_timer.start()
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("default")


func spellcard_timeover() -> void:
	AudioManager.play_sfx('music_sfx_break')
	SignalBus.pause_boss_hud_time.emit(true)
	died()

func spellcard_break() -> void:
	AudioManager.play_sfx('music_sfx_break')
	SignalBus.pause_boss_hud_time.emit(true)
	SignalBus.disbullet.emit(true)
	SignalBus.clear_enemy.emit(true)
	player_var.point += mob_info.initial_bonus - progress_time*mob_info.bonus_reduction_rate
	await get_tree().create_timer(0.2,false).timeout
	SignalBus.fly_to_player.emit(1,1,1,1)

func _on_animated_sprite_2d_animation_finished() -> void:
	pass


func _on_progress_timer_timeout() -> void:
	progress_time+=$progress_timer.wait_time
	if progress_time>mob_info.time:
		spellcard_timeover()


func _on_progress_bar_value_changed(value: float) -> void:
	match state:
		'nons':
			$hud/hp/nons/nons_mask.size.y = 6.45 * value
		'spell_quarter':
			$hud/hp/nons/quar_mask.size.y = 2.16 * value
		'spell_full':
			$hud/hp/fullcard/full_mask.size.y = 8.58 * value
		'spell_time':
			$hud/hp/fullcard/time_mask.size.y = 8.58 * value

func set_cardstate(bossstate: String) -> void:
	state = bossstate
	match bossstate:
		'nons':
			$hud/hp/nons.visible = true
			$hud/hp/fullcard.visible = false
			$hud/hp/nons/nons_mask.visible = true
			$hud/hp/nons/quar_mask.visible = true
			$hud/hp/nons/nons_mask.size.y = 645
			$hud/hp/nons/quar_mask.size.y = 216
		'spell_quarter':
			$hud/hp/nons.visible = true
			$hud/hp/fullcard.visible = false
			$hud/hp/nons/nons_mask.visible = false
			$hud/hp/nons/quar_mask.visible = true
			$hud/hp/nons/quar_mask.size.y = 216
		'spell_full':
			$hud/hp/nons.visible = false
			$hud/hp/fullcard.visible = true
			$hud/hp/fullcard/full_mask.visible = true
			$hud/hp/fullcard/time_mask.visible = false
			$hud/hp/fullcard/full_mask.size.y = 858
		'spell_time':
			$hud/hp/nons.visible = false
			$hud/hp/fullcard.visible = true
			$hud/hp/fullcard/full_mask.visible = false
			$hud/hp/fullcard/time_mask.visible = true
			$hud/hp/fullcard/time_mask.size.y = 858

@onready var panel: TextureRect = $hud/card/PopupPanel
@onready var text: Label = $hud/card/RichTextLabel
func popup() -> void:

	text.position = Vector2(-236,128)
	text.scale = Vector2(0.1,0.6)
	panel.scale = Vector2(0.6,0.6)
	$hud/card.visible = true
	var flush: Tween = panel.create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_speed_scale(70)
	RunSession.underrecycle_tween.append(flush)
	flush.tween_property(panel,'modulate',Color(1,1,1,0.1),3)
	flush.tween_property(panel,'modulate',Color(1,1,1,1),1)
	flush.set_loops(3)


	flush = null

	var expand: Tween = text.create_tween().set_ease(Tween.EASE_OUT).set_speed_scale(3)
	RunSession.underrecycle_tween.append(expand)
	expand.tween_property(text,'scale',Vector2(0.4,0.6),1)
	expand.tween_property(text,'scale',Vector2(0.6,0.6),2)


	await  expand.finished


	expand = null

	var disappear: Tween = panel.create_tween()
	RunSession.underrecycle_tween.append(disappear)
	disappear.tween_interval(1)
	disappear.set_parallel().tween_property(panel,'scale',Vector2(0.5,0),0.5)
	disappear.set_parallel().tween_property(text,'scale',Vector2(0.2,0.2),0.5)
	disappear.set_parallel().tween_property(text,'position',Vector2(300,850),0.5)
	disappear.tween_property(panel,'rotation',0,3.5)
	await disappear.finished

	disappear = null


	#$CanvasLayer/card.visible = false
