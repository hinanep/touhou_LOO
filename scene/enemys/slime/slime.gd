extends "res://scene/enemys/enemy_base/enemy_base.gd"

func _ready():
	max_hp = 100
	hp = max_hp
	speed = 40
	basic_melee_damage = 10
	basic_bullet_damage = 10
	
	#启用体术攻击，默认攻击范围圆形
	melee_battle_ready()
	
	#启用弹幕攻击，需设置弹幕攻击方式
	#bullet_battle_ready()
	
func _physics_process(delta):
	move_to_player()

#弹幕攻击方法，待实例实现
func bullet_attack():
	pass
	
#体术攻击方法，可重新实现
#func melee_attack(playernode):
#	playernode.take_damage(player_var.enemy_make_damage(basic_melee_damage))

