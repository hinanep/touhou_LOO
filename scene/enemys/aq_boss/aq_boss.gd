extends enemy_base
var stage = 2
var reincarnation = false
func _ready():
	max_hp *= 10000
	hp = max_hp
	speed = 40
	basic_melee_damage *= 10
	basic_bullet_damage *= 10
	drops_path = "res://scene/drops/plate_1.tscn"
	AudioManager.play_bgm("saga")
	#启用体术攻击，默认攻击范围圆形
	melee_battle_ready()
	super._ready()
	#启用弹幕攻击，需设置弹幕攻击方式
	bullet_battle_ready()
	
	get_tree().call_group("monster","queue_free")
	get_tree().call_group("spawner","change_pause")
func _physics_process(_delta):
	move_to_target()
	
func move_to_target():
	if !invinsible:
		velocity = get_diretion_to_target() * speed * debuff["speed"]
	move_and_slide()
func died():
	if reincarnation == true:
		return
	stage -= 1
	if stage > 0:
		reincarnation = true
		next_stage()
		return
	invinsible = true
	
	get_tree().call_group("spawner","change_pause")
	print("aq sile")
	player_var.is_invincible = true
	drop()
	$danma/sekibankiWeapon.active = false
	$AnimatedSprite2D.play("die")
	await  get_tree().create_timer(6).timeout
	AudioManager.bgm_over()
	queue_free()
	G.get_gui_view_manager().close_all_view()
	G.get_gui_view_manager().open_view("ClearMenu")
#弹幕攻击方法，待实例实现
func bullet_attack():
	
	pass
	
func next_stage():
	invinsible = true
	AudioManager.play_bgm("kami")
	#bullet_damage_area.monitoring = false
	$danma/sekibankiWeapon.active = false
	$reincarnation.start()
	pass
	
#体术攻击方法，可重新实现
#func melee_attack(playernode):
#	playernode.take_damage(player_var.enemy_make_damage(basic_melee_damage))
func reincarnation_over():
	invinsible = false
	reincarnation = false
	$danma/sekibankiWeapon.active = true
	$reincarnation.stop()
	bullet_damage_area.monitoring = true
	pass


func _on_reincarnation_timeout():
	hp += max_hp * 0.04
	progress_bar.value = hp/max_hp * 100
	if(hp >= max_hp):
		reincarnation_over()
	pass # Replace with function body.


func _on_animated_sprite_2d_animation_finished():
	$Explosion.set_emitting(true)
	pass # Replace with function body.
