extends card


func _ready():	
	mana_cost = 40
	duration_time = 5
	card_name = "marisa"
	print(card_name)
	print(level)
	super._ready()
func _process(_delta):
	pass

func card_init(card_dic):
	super.card_init(card_dic)
	
	AudioManager.play_sfx("sfx_masterspark")


	

func _on_invincible_time_timeout():
	super._on_invincible_time_timeout()


func _on_endtime_timeout():
	super._on_endtime_timeout()
