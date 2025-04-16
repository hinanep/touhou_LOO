extends enemy_base

func _ready():
	max_hp *= 20
	hp = max_hp
	speed = 40
	basic_melee_damage *= 50
	basic_bullet_damage *= 10
	drops_path = "drops_p"

	#启用体术攻击，默认攻击范围圆形
	melee_battle_ready()
	bullet_battle_ready(true)
	super._ready()
	#启用弹幕攻击，需设置弹幕攻击方式
	#bullet_battle_ready()

func _physics_process(_delta):
	move_to_target()
	pass
