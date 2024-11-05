extends enemy_base

func _ready():
	max_hp *= 10000
	hp = max_hp
	speed = 40
	basic_melee_damage *= 10
	basic_bullet_damage *= 10
	drops_path = "res://scene/drops/plate_1.tscn"
	
	#启用体术攻击，默认攻击范围圆形
	melee_battle_ready()
	super._ready()
	#启用弹幕攻击，需设置弹幕攻击方式
	bullet_battle_ready()
	$Explosion.set_emitting(true)
	get_tree().call_group("monster","queue_free")
	get_tree().call_group("spawner","change_pause")
func _physics_process(_delta):
	move_to_target()
	
	pass
func died():
	get_tree().call_group("spawner","change_pause")
	print("aq sile")
	drop()
	queue_free()
#弹幕攻击方法，待实例实现
func bullet_attack():
	
	pass
	
#体术攻击方法，可重新实现
#func melee_attack(playernode):
#	playernode.take_damage(player_var.enemy_make_damage(basic_melee_damage))

