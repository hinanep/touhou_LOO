extends cards
var recover = 40
func _ready():
	mana_cost = 44
	duration_time = 1

	id = "fairy"

	super._ready()
func _process(_delta):
	pass

func card_init(card_dic):
	super.card_init(card_dic)


func active():
	AudioManager.play_sfx("music_sfx_spellcard")
	player_var.player_get_heal(recover)

	super.active()

	pass


func _on_invincible_time_timeout():
	super._on_invincible_time_timeout()


func _on_endtime_timeout():
	super._on_endtime_timeout()
