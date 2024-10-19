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
var card_tex_pre = preload("res://scene/ui/Assets/GUI/Hud/card_texture.tscn")
func card_display():
	if(card_container.get_child_count()==0):
		return
	cardnum = CardManager.cardnum_have
	card_container.get_child(cardnum/2).set_expand_mode(0)
	
	cardnum = CardManager.card_list.size()
	left = cardnum_before - CardManager.cardnum_now
	for i in range(left):
		
		$card_container.move_child(get_child(0),-1)
	card_container.get_child(cardnum/2).set_expand_mode(3)
	cardnum_before = CardManager.cardnum_now

func add_card(card_list):
	var newcard = card_tex_pre.instantiate()
	newcard.set_texture(load(card_list["card_image"]))
	card_container.add_child(newcard)
