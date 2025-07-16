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

	SignalBus.add_skill.connect(add_skill)
	SignalBus.add_card.connect(on_add_card)
	SignalBus.add_passive.connect(add_passive)

	SignalBus.del_card.connect(on_del_card)

	SignalBus.card_select_next.connect(card_display)
	SignalBus.cp_active.connect(add_cp)

	SignalBus.set_bosstimer.connect(set_boss_timer)

func hp_display():

	hp_cont.offset.x = 350 - player_var.player_hp/player_var.player_hp_max * 350
	hp_text.text = ("%d" % player_var.player_hp) + "/" + ("%d" % player_var.player_hp_max)

func card_mana_display():


	mana_cont.offset.x = 350 - player_var.mana/player_var.mana_max * 350

	mana_text.text = str(player_var.mana) + "/" + str(player_var.mana_max)

func point_and_ratio_display():
	point_ratio_text.text = ("%.2f" % player_var.point_ratio)

	point_text.text = str(player_var.point)

func exp_display():
	exp_cont.offset.x = -320 + player_var.player_exp/player_var.exp_need * 320

	level_text.text = ("%d" % player_var.level)

func life_display():
	match player_var.player_life_addi:
		0:
			$hud/life/life1/have.visible = false
			$hud/life/life2/have.visible = false
		1:
			$hud/life/life1/have.visible = true
			$hud/life/life2/have.visible = false
		_:
			$hud/life/life1/have.visible = true
			$hud/life/life2/have.visible = true





var card_selecting = 0
var card_having
var card_tex_pre = PresetManager.getpre("ui_card_texture")
var cp_and_skill_texture = PresetManager.getpre("ui_cp_and_skill_texture")


func card_display(bias):
	card_having = card_container.get_child_count()
	if(card_having==0):
		return
	if bias!=0:
		card_container.get_child(card_selecting).set_highlight(false)
		#card_container.get_child(card_selecting).set_expand_mode(0)
		#card_container.get_child(card_selecting).set_stretch_mode(3)

		card_selecting = int(card_selecting+bias)%card_having

	card_container.get_child(card_selecting).set_highlight(true)
		#card_container.get_child(card_selecting).set_expand_mode(2)
		#card_container.get_child(card_selecting).set_stretch_mode(4)

		#$hud/card_now/crystal.set_texture(card_container.get_child(card_selecting).card_texture)

	$hud/card_now/cardid.text = card_container.get_child(card_selecting).describe

	$hud/card_now/enoughmana.visible =not (card_container.get_child(card_selecting).manacost > player_var.mana)
	#TODO:多语言
	if player_var.free_card > 0:
		$hud/card_now/manacost.text = '符力消耗：0!'
		$hud/card_now/enoughmana.visible = true
	else:
		$hud/card_now/manacost.text = '符力消耗：' + str(card_container.get_child(card_selecting).manacost/player_var.mana_cost)

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
		child.set_expand_mode(0)
		child.set_stretch_mode(3)
	card_container.get_child(card_selecting).set_expand_mode(2)
	card_container.get_child(card_selecting).set_stretch_mode(4)

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
