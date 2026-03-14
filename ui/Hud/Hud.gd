extends BaseGUIView

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

func hp_display():

	#hp_cont.offset.x =   player_var.player_hp/player_var.player_hp_max * 275 - 275
	$hud/hp/hp_mask.size.x = player_var.player_hp/player_var.player_hp_max * 280 +45
	hp_text.text = ("%d" % player_var.player_hp) + "/" + ("%d" % player_var.player_hp_max)

func card_mana_display():

	$hud/mana/mana_mask.size.x = player_var.mana/player_var.mana_max * 360
	#mana_cont.offset.x = 350 - player_var.mana/player_var.mana_max * 350

	mana_text.text = str(player_var.mana) + "/" + str(player_var.mana_max)

func exp_display():
	$hud/exp/exp_mask.size.x = player_var.player_exp/player_var.exp_need * 370 + 37
	#exp_cont.offset.x = -320 + player_var.player_exp/player_var.exp_need * 320

	level_text.text = ("%d" % player_var.level)

func point_and_ratio_display():
	point_ratio_text.text = ("%.2f" % player_var.point_ratio)

	point_text.text = str(player_var.point)



func life_display():
	match player_var.player_life_addi:
		0:
			$hud/life/have.visible = false
			$hud/life/have2.visible = false

		1:
			$hud/life/have.visible = true
			$hud/life/have2.visible = false
		_:
			$hud/life/have.visible = true
			$hud/life/have2.visible = true





var card_selecting = 0
var card_having
var card_tex_pre = PresetManager.getpre("ui_card_texture")
var cp_and_skill_texture = PresetManager.getpre("ui_cp_and_skill_texture")

var _delete_mode_active := false
var _delete_mode_containers: Array[HBoxContainer] = []


func card_display(bias):
	card_having = card_container.get_child_count()
	if(card_having==0):
		return
	if bias!=0:
		card_container.get_child(card_selecting).set_highlight(false)
		#card_container.get_child(card_selecting).set_expand_mode(0)
		#card_container.get_child(card_selecting).set_stretch_mode(3)

	card_selecting = int(card_selecting+bias)%card_having

	var now_selected = card_container.get_child(card_selecting)
	now_selected.set_highlight(true)


	$hud/card_now/cardid.text = now_selected.describe

	$hud/card_now/enoughmana.visible =not (now_selected.manacost > player_var.mana)
	#TODO:多语言
	if player_var.free_card > 0:
		$hud/card_now/manacost.text = '符力消耗：0!'
		$hud/card_now/enoughmana.visible = true
	else:
		$hud/card_now/manacost.text = '符力消耗：' + str(now_selected.manacost/player_var.mana_cost)

func on_add_card(card_info):

	var newcard = card_tex_pre.instantiate()
	newcard.set_card(card_info)

	card_container.add_child(newcard)

	card_having = card_container.get_child_count()

	for child in card_container.get_children():
		child.set_expand_mode(2)
		child.set_stretch_mode(4)
	#card_container.get_child(card_selecting).set_expand_mode(2)
	#card_container.get_child(card_selecting).set_stretch_mode(4)

func on_del_card(id):

	card_having = card_container.get_child_count()
	if(card_having==0):
		return
	card_selecting = (card_selecting)%card_having
	for child in card_container.get_children():
		child.set_expand_mode(2)
		child.set_stretch_mode(4)


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

func _on_renew_timer_timeout():
	hp_display()
	card_mana_display()
	point_and_ratio_display()
	exp_display()
	card_display(0)
	life_display()
	$hud/fps/text.text = str(Engine.get_frames_per_second())

func _on_delete_mode_changed(on: bool) -> void:
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
			if row_idx > 0:
				var top_row = rows[row_idx - 1]
				if top_row.size() > 0:
					var top_col = col_idx % top_row.size()
					btn.focus_neighbor_top = btn.get_path_to(top_row[top_col])
			if row_idx < rows.size() - 1:
				var bot_row = rows[row_idx + 1]
				if bot_row.size() > 0:
					var bot_col = col_idx % bot_row.size()
					btn.focus_neighbor_bottom = btn.get_path_to(bot_row[bot_col])
	if first_focus:
		first_focus.grab_focus()

func _teardown_delete_mode_focus() -> void:
	for c in _delete_mode_containers:
		for child in c.get_children():
			if child is Control:
				child.focus_mode = Control.FOCUS_NONE

func _input(event: InputEvent) -> void:
	if _delete_mode_active and event.is_action_pressed("ui_cancel"):
		SignalBus.delete_mode.emit(false)
		get_viewport().set_input_as_handled()
