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

func _ready():
	hp.max_value = player_var.player_hp_max
	card_power.max_value = player_var.power_max
	for cardname in CardManager.card_list.keys():
		add_card(CardManager.get_active_card_by_name(cardname))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	hp_display()
	card_power_display()
	point_and_ratio_display()
	exp_display()
	card_display()
	pass

func hp_display():
	hp.value = player_var.player_hp
	hp_text.text = ("%d" % player_var.player_hp) + "/" + str(player_var.player_hp_max)

func card_power_display():
	card_power.value = player_var.power
	card_power_text.text = str(player_var.power) + "/" + str(player_var.power_max)

func point_and_ratio_display():
	point_ratio_text.text = ("%.2f" % player_var.point_ratio)
	
	point_text.text = str(player_var.point)

func exp_display():
	exp_bar.max_value = player_var.exp_need[player_var.level]
	exp_bar.value = player_var.player_exp
	level_number.text = ("%d" % player_var.level)
	pass

var cardnum_before=0
var cardnum=0
var left=0
var cardnum_now = 0
var card_tex_pre = preload("res://scene/ui/Assets/GUI/Hud/card_texture.tscn")
func card_display():
	if(card_container.get_child_count()==0):
		return
	#cardnum = CardManager.cardnum_have
	cardnum_now = CardManager.cardnum_now
	
	for child in card_container.get_children():
		child.set_expand_mode(0)
		child.set_stretch_mode(3)

	#left = cardnum_before - CardManager.cardnum_now		
	#if(left !=0):
		#print("left")
		#print(left)
	#card_container.move_child(card_container.get_child(0),-left)
	
	card_container.get_child(CardManager.cardnum_now).set_expand_mode(2)
	card_container.get_child(CardManager.cardnum_now).set_stretch_mode(4)
	#cardnum_before = cardnum_now

func add_card(card_list):
	print("adding card")
	var newcard = card_tex_pre.instantiate()
	newcard.set_texture(load(card_list["card_image"]))
	card_container.add_child(newcard)
