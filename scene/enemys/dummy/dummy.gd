extends enemy_base
var sumdamage = 0.0
var dpstick = 0.2
var damage_array = []
func _ready():
	max_hp *= 2000
	hp = max_hp
	speed = 25
	basic_melee_damage *= 50
	basic_bullet_damage *= 10
	drops_path = "drops_p"
	$dps.wait_time = dpstick
	#启用体术攻击，默认攻击范围圆形
	#melee_battle_ready()
	super._ready()
	#启用弹幕攻击，需设置弹幕攻击方式
	#bullet_battle_ready()

func _physics_process(_delta):
	hp = max_hp
	pass
#弹幕攻击方法，待实例实现
func bullet_attack():
	pass
func take_damage(damage):
	if invincible:
		return
	damage_num_display(damage)
	hp -= damage
	progress_bar.value = hp/max_hp * 100
	sumdamage += damage
	$dps_reset.start()
#体术攻击方法，可重新实现
#func melee_attack(playernode):
#	playernode.take_damage(player_var.enemy_make_damage(basic_melee_damage))


var count = 0
func _on_dps_timeout():


	damage_array.push_front(sumdamage)
	sumdamage = 0
	damage_array.resize(25)
	var result = damage_array.reduce(func(a,num):
		if num == null:
			return a+0
		return a + num;
		)

	$dps2.text = String.num(result/5,2)
	pass # Replace with function body.


func _on_dps_reset_timeout():
	sumdamage = 0

	pass # Replace with function body.
