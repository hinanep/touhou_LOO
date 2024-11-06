extends card

var basic_damage
var diretion_angle = 0
var activing = false
func _ready():
	$damage_tick.wait_time = 0.5
	basic_damage = 10
	mana_cost = 44
	duration_time = 5
	card_name = "marisa"
	print(card_name)
	print(level)
	super._ready()
func _process(_delta):
	
	
	if activing:
		diretion_angle += 0.001 * (player_var.player_diretion_angle - diretion_angle)
		$".".rotation = diretion_angle
		get_tree().call_group("enemy_bullet","queue_free")
	pass

func card_init(card_dic):
	super.card_init(card_dic)
	


func active():
	
	activing = true
	AudioManager.play_sfx("sfx_masterspark")
	
	$".".rotation =player_var.player_diretion_angle
	diretion_angle = player_var.player_diretion_angle
	
	$Sprite2D.set_visible(true)
	$damage_tick.start()
	$".".set_monitoring(true)
	var enemy_in_range = $".".get_overlapping_bodies()
	if enemy_in_range:
			for enemy in enemy_in_range:
				if enemy.has_method("take_damage"):
					enemy.take_damage(player_var.player_make_bullet_damage(basic_damage))

	super.active()
	
	pass
func upgrade_card():
	super.upgrade_card()

func _on_invincible_time_timeout():
	super._on_invincible_time_timeout()


func _on_endtime_timeout():
	activing = false
	$".".set_monitoring(false)
	$Sprite2D.set_visible(false)
	$damage_tick.stop()
	#$CPUParticles2D.set_emitting(false)
	
	super._on_endtime_timeout()


func _on_damage_tick_timeout():
	
	var enemy_in_range = $".".get_overlapping_bodies()
	if enemy_in_range:
			for enemy in enemy_in_range:
				if enemy.has_method("take_damage"):
					enemy.take_damage(player_var.player_make_bullet_damage(basic_damage))
	pass # Replace with function body.
