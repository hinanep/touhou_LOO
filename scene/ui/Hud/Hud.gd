extends BaseGUIView

@onready var hp = $hud/hp
@onready var hp_text = $hud/hp/hp_text

@onready var card_power = $hud/card_power
@onready var card_power_text = $hud/card_power/card_power_text

@onready var point_ratio_text = $hud/point_ratio/text
@onready var point_text = $hud/point/text

@onready var exp_bar = $hud/exp_bar
@onready var level_number = $hud/exp_bar/level_number

@onready var card_container = $hud/card_container
@onready var waza_container = $hud/waza_container
@onready var cp_container = $hud/cp_container
func _ready():
	hp.max_value = player_var.player_hp_max
	card_power.max_value = player_var.power_max
	for cardname in CardManager.card_list.keys():
		add_card(CardManager.get_active_card_by_name(cardname))



func hp_display():
	hp.value = player_var.player_hp
	hp_text.text = ("%d" % player_var.player_hp) + "/" + str(player_var.player_hp_max)

func card_power_display():
	card_power.value = player_var.power
	card_power.max_value = player_var.power_max
	card_power_text.text = str(player_var.power) + "/" + str(player_var.power_max)

func point_and_ratio_display():
	point_ratio_text.text = ("%.2f" % player_var.point_ratio)
	
	point_text.text = str(player_var.point)

func exp_display():
	exp_bar.max_value = player_var.exp_need[player_var.level]
	exp_bar.value = player_var.player_exp
	level_number.text = ("%d" % player_var.level)
	pass




var cardnum_now = 0
var card_tex_pre = PresetManager.getpre("ui_card_texture")
var cp_and_waza_texture = PresetManager.getpre("ui_cp_and_waza_texture")
func card_display():
	if(card_container.get_child_count()==0):
		return

	cardnum_now = CardManager.cardnum_now
	
	for child in card_container.get_children():
		child.set_expand_mode(0)
		child.set_stretch_mode(3)


	card_container.get_child(cardnum_now).set_expand_mode(2)
	card_container.get_child(cardnum_now).set_stretch_mode(4)


func add_card(card_list):
	print("adding card")
	var newcard = card_tex_pre.instantiate()
	newcard.set_texture(PresetManager.getpre(card_list["card_image"]))
	newcard.get_child(0).text = card_list["cn"]
	newcard.add_to_group(card_list["card_name"])
	card_container.add_child(newcard)

func add_waza(waza_list):
	print("adding waza")
	if waza_list.has("waza_image"):
		if waza_list.waza_name == "base_range" or  waza_list.waza_name == "base_melee":
			return
		var newwaza = cp_and_waza_texture.instantiate()
		newwaza.add_to_group(waza_list["waza_name"])
		newwaza.set_texture(PresetManager.getpre(waza_list["waza_image"]))
		newwaza.get_child(0).text = waza_list["cn"]
		waza_container.add_child(newwaza)

func add_cp(cp_list):
	print("adding cp")
	if cp_list.has("cp_image"):
		var newcp = cp_and_waza_texture.instantiate()
		newcp.set_texture(PresetManager.getpre(cp_list["cp_image"]))
		newcp.add_to_group(cp_list["name"])
		newcp.get_child(0).text = cp_list["cn"]
		cp_container.add_child(newcp)
	


func _on_renew_timer_timeout():
	hp_display()
	card_power_display()
	point_and_ratio_display()
	exp_display()
	card_display()

