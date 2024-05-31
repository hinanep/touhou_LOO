extends CanvasLayer
@onready var hp = $hp
@onready var hp_text = $hp/hp_text

@onready var card_power = $card_power
@onready var card_power_text = $card_power/card_power_text

@onready var point_ratio_text = $point_ratio/text
@onready var point_text = $point/text

@onready var exp_bar = $exp_bar
@onready var level_number = $exp_bar/level_number


func _ready():
	hp.max_value = player_var.player_hp_max
	$card_power.max_value = player_var.power_max
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	hp_display()
	card_power_display()
	point_and_ratio_display()
	exp_display()
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
	exp_bar.value = player_var.exp
	level_number.text = ("%d" % player_var.level)
	pass
