extends card


func _ready():	
	mana_cost = 40
	duration_time = 5
	card_name = "marisa"
	super._ready()
func _process(_delta):
	pass

func card_init():
	super.card_init()
	
	AudioManager.play_sfx("sfx_masterspark")

func card_upgrade():
	super.card_upgrade()
	

func _on_invincible_time_timeout():
	super._on_invincible_time_timeout()


func _on_endtime_timeout():
	super._on_endtime_timeout()
