extends BaseGUIView

const _StatDisplayFormat = preload("res://gamemanager/StatDisplayFormat.gd")

@onready var hp_cont = $hud/hp/hp_mask/hp_cont
@onready var hp_text = $hud/hp/hp_text

@onready var mana_cont = $hud/mana/mana_mask/mana_cont
@onready var mana_text = $hud/mana/card_mana_text


@onready var point_ratio_text = $hud/point_ratio/text
@onready var point_text = $hud/point/text

@onready var exp_cont = $hud/exp/exp_mask/exp_cont
@onready var level_text = $hud/exp/level_text

@onready var card_container = $hud/card_container
@onready var skill_container = $hud/skill_container
@onready var cp_container = $hud/cp_container
@onready var psv_container = $hud/psv_container

func _ready():
	_delete_mode_containers = [skill_container, psv_container, card_container]

	SignalBus.add_skill.connect(add_skill)
	SignalBus.add_card.connect(on_add_card)
	SignalBus.add_passive.connect(add_passive)

	SignalBus.del_card.connect(on_del_card)

	SignalBus.card_select_next.connect(card_display)
	SignalBus.cp_active.connect(add_cp)

	SignalBus.set_bosstimer.connect(set_boss_timer)
	SignalBus.delete_mode.connect(_on_delete_mode_changed)

	player_var.stat_changed.connect(_on_stat_changed)
	_refresh_all_stats()

func _refresh_all_stats() -> void:
	hp_display()
	card_mana_display()
	point_and_ratio_display()
	exp_display()
	life_display()
	_refresh_card_now()

func _on_stat_changed(stat_name: StringName) -> void:
	match stat_name:
		player_var.STAT_HP, player_var.STAT_HP_MAX:
			hp_display()
		player_var.STAT_MANA, player_var.STAT_MANA_MAX, player_var.STAT_FREE_CARD:
			card_mana_display()
			_refresh_card_now()
		player_var.STAT_EXP, player_var.STAT_LEVEL:
			exp_display()
		player_var.STAT_POINT, player_var.STAT_POINT_RATIO:
			point_and_ratio_display()
		player_var.STAT_LIFE:
			life_display()
		_:
			pass

func hp_display():

	#hp_cont.offset.x =   player_var.player_hp/player_var.player_hp_max * 275 - 275
	$hud/hp/hp_mask.size.x = player_var.player_hp/player_var.player_hp_max * 280 +45
	hp_text.text = _StatDisplayFormat.format_hud_value(player_var.player_hp) + "/" + _StatDisplayFormat.format_hud_value(player_var.player_hp_max)

func card_mana_display():

	$hud/mana/mana_mask.size.x = player_var.mana/player_var.mana_max * 360
	#mana_cont.offset.x = 350 - player_var.mana/player_var.mana_max * 350

	mana_text.text = _StatDisplayFormat.format_hud_value(player_var.mana) + "/" + _StatDisplayFormat.format_hud_value(player_var.mana_max)

func exp_display():
	$hud/exp/exp_mask.size.x = player_var.player_exp/player_var.exp_need * 370 + 37
	#exp_cont.offset.x = -320 + player_var.player_exp/player_var.exp_need * 320

	level_text.text = ("%d" % player_var.level)

func point_and_ratio_display():
	point_ratio_text.text = ("%.2f" % player_var.point_ratio)

	point_text.text = str(player_var.point)


@onready var life1 = $hud/life/lifeBack1/life1
@onready var life2 = $hud/life/lifeBack2/life2

func life_display():
	match player_var.player_life_addi:
		0:
			life1.visible = false
			life2.visible = false

		1:
			life1.visible = true
			life2.visible = false
		_:
			life1.visible = true
			life2.visible = true





var card_selecting = 0
var card_having
var cp_and_skill_texture = PresetManager.getpre("ui_cp_and_skill_texture")

var _delete_mode_active := false
var _delete_mode_containers: Array[HBoxContainer] = []


func card_display(bias):
	card_having = card_container.get_child_count()
	if card_having == 0:
		return
	if bias != 0:
		card_container.get_child(card_selecting).set_highlight(false)
		card_selecting = int(card_selecting + bias) % card_having
		card_container.get_child(card_selecting).set_highlight(true)
	_refresh_card_now()

func _refresh_card_now() -> void:
	card_having = card_container.get_child_count()
	if card_having == 0:
		return
	if card_selecting >= card_having:
		card_selecting = card_having - 1
	var now_selected = card_container.get_child(card_selecting)
	$hud/card_now/cardid.text = now_selected.describe
	$hud/card_now/enoughmana.visible = not (now_selected.manacost > player_var.mana)
	#TODO:多语言
	if player_var.free_card > 0:
		$hud/card_now/manacost.text = '符力消耗：0!'
		$hud/card_now/enoughmana.visible = true
	else:
		$hud/card_now/manacost.text = '符力消耗：' + str(now_selected.manacost / player_var.mana_cost)

func on_add_card(card_info):
	var newcard = cp_and_skill_texture.instantiate()
	newcard.set_card(card_info)

	card_container.add_child(newcard)

	card_having = card_container.get_child_count()
	if card_having == 1:
		card_selecting = 0
	card_container.get_child(card_selecting).set_highlight(true)
	_refresh_card_now()

func on_del_card(_id):
	call_deferred("_on_del_card_deferred")

func _on_del_card_deferred() -> void:
	card_having = card_container.get_child_count()
	if card_having == 0:
		card_selecting = 0
		return
	if card_selecting >= card_having:
		card_selecting = card_having - 1
	for i in card_container.get_child_count():
		card_container.get_child(i).set_highlight(i == card_selecting)
	_refresh_card_now()

func add_skill(ski_info):
		if ski_info.id == "ski_basemagic" or ski_info.id == "ski_basephysics":
			return
		var newskill = cp_and_skill_texture.instantiate()

		newskill.set_skill(ski_info)

		skill_container.add_child(newskill)

func add_cp(cp_info):


		var newcp = cp_and_skill_texture.instantiate()
		newcp.set_cp(cp_info)
		cp_container.add_child(newcp)

func add_passive(psv_info):

		var newpsv = cp_and_skill_texture.instantiate()

		newpsv.set_psv(psv_info)

		psv_container.add_child(newpsv)

func set_boss_timer(card_time:float):
	$time.set_boss_timer(card_time)

func _on_fps_timer_timeout() -> void:
	$hud/fps/text.text = str(Engine.get_frames_per_second())

func _on_delete_mode_changed(on: bool,completed:bool) -> void:
	_delete_mode_active = on
	if on:
		_setup_delete_mode_focus()
	else:
		_teardown_delete_mode_focus()

func _setup_delete_mode_focus() -> void:
	var rows: Array[Array] = []
	for c in _delete_mode_containers:
		var row: Array = []
		for child in c.get_children():
			if child is Control:
				child.focus_mode = Control.FOCUS_ALL
				row.append(child)
		rows.append(row)
	# 每行向上/向下最近的非空行索引，空行时用于跨行焦点
	var next_non_empty_above: Array[int] = []
	var next_non_empty_below: Array[int] = []
	for row_idx in rows.size():
		var above := -1
		for i in range(row_idx - 1, -1, -1):
			if rows[i].size() > 0:
				above = i
				break
		next_non_empty_above.append(above)
		var below := -1
		for i in range(row_idx + 1, rows.size()):
			if rows[i].size() > 0:
				below = i
				break
		next_non_empty_below.append(below)
	var first_focus: Control = null
	for row_idx in rows.size():
		var row = rows[row_idx]
		for col_idx in row.size():
			var btn: Control = row[col_idx]
			if first_focus == null:
				first_focus = btn
			if col_idx > 0:
				btn.focus_neighbor_left = btn.get_path_to(row[col_idx - 1])
			if col_idx < row.size() - 1:
				btn.focus_neighbor_right = btn.get_path_to(row[col_idx + 1])
			if next_non_empty_above[row_idx] >= 0:
				var top_row = rows[next_non_empty_above[row_idx]]
				var top_col = col_idx % top_row.size()
				btn.focus_neighbor_top = btn.get_path_to(top_row[top_col])
			if next_non_empty_below[row_idx] >= 0:
				var bot_row = rows[next_non_empty_below[row_idx]]
				var bot_col = col_idx % bot_row.size()
				btn.focus_neighbor_bottom = btn.get_path_to(bot_row[bot_col])
	if first_focus:
		first_focus.call_deferred("grab_focus")

func _teardown_delete_mode_focus() -> void:
	for c in _delete_mode_containers:
		for child in c.get_children():
			if child is Control:
				child.focus_mode = Control.FOCUS_NONE

func _input(event: InputEvent) -> void:
	if _delete_mode_active and event.is_action_pressed("ui_cancel"):
		SignalBus.delete_mode.emit(false, false)
		get_viewport().set_input_as_handled()
