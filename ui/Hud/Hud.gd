extends BaseGUIView

@onready var hp = $hud/hp
@onready var hp_text = $hud/hp/hp_text

@onready var card_mana = $hud/card_mana
@onready var card_mana_text = $hud/card_mana/card_mana_text


@onready var point_ratio_text = $hud/point_ratio/text
@onready var point_text = $hud/point/text

@onready var exp_bar = $hud/exp_bar
@onready var level_number = $hud/exp_bar/level_number

@onready var card_container = $hud/card_container
@onready var skill_container = $hud/skill_container
@onready var cp_container = $hud/cp_container
func _ready():
	hp.max_value = player_var.player_hp_max
	card_mana.max_value = player_var.mana_max
	SignalBus.add_skill.connect(add_skill)
	SignalBus.add_card.connect(on_add_card)
	SignalBus.del_card.connect(on_del_card)
	SignalBus.card_select_before.connect(card_display_left)
	SignalBus.card_select_next.connect(card_display_right)




func hp_display():
	hp.value = player_var.player_hp
	hp_text.text = ("%d" % player_var.player_hp) + "/" + str(player_var.player_hp_max)

func card_mana_display():
	card_mana.value = player_var.mana
	card_mana.max_value = player_var.mana_max
	card_mana_text.text = str(player_var.mana) + "/" + str(player_var.mana_max)

func point_and_ratio_display():
	point_ratio_text.text = ("%.2f" % player_var.point_ratio)

	point_text.text = str(player_var.point)

func exp_display():
	exp_bar.max_value = player_var.exp_need[player_var.level]
	exp_bar.value = player_var.player_exp
	level_number.text = ("%d" % player_var.level)





var card_selecting = 0
var card_having
var card_tex_pre = PresetManager.getpre("ui_card_texture")
var cp_and_skill_texture = PresetManager.getpre("ui_cp_and_skill_texture")

func card_display_left():

	card_having = card_container.get_child_count()
	if(card_having==0):
		return
	card_selecting = (card_selecting-1)%card_having
	card_container.get_child((card_selecting+1)%card_having).set_expand_mode(0)
	card_container.get_child((card_selecting+1)%card_having).set_stretch_mode(3)
	card_container.get_child(card_selecting).set_expand_mode(2)
	card_container.get_child(card_selecting).set_stretch_mode(4)

func card_display_right():
	card_having = card_container.get_child_count()
	if(card_having==0):
		return
	card_selecting = (card_selecting+1)%card_having
	card_container.get_child((card_selecting-1)%card_having).set_expand_mode(0)
	card_container.get_child((card_selecting-1)%card_having).set_stretch_mode(3)
	card_container.get_child(card_selecting).set_expand_mode(2)
	card_container.get_child(card_selecting).set_stretch_mode(4)


func on_add_card(card_info):

	var newcard = card_tex_pre.instantiate()
	newcard.set_card(card_info)

	card_container.add_child(newcard)

	card_having = card_container.get_child_count()

	for child in card_container.get_children():
		child.set_expand_mode(0)
		child.set_stretch_mode(3)
	card_container.get_child(card_selecting).set_expand_mode(2)
	card_container.get_child(card_selecting).set_stretch_mode(4)

func on_del_card(id):
	await get_tree().create_timer(0.1).timeout
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

		cp_container.add_child(newcp)



func _on_renew_timer_timeout():
	hp_display()
	card_mana_display()
	point_and_ratio_display()
	exp_display()
